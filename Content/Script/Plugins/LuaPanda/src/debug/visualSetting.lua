local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__New = ____lualib.__TS__New
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys
local ____exports = {}
local ____tools = require("Plugins.LuaPanda.src.common.tools")
local Tools = ____tools.Tools
local fs = require("Plugins.LuaPanda.src.debug.fs")
local vscode = require("Plugins.LuaPanda.src.debug.vscode")
local ____logManager = require("Plugins.LuaPanda.src.common.logManager")
local DebugLogger = ____logManager.DebugLogger
____exports.VisualSetting = __TS__Class()
local VisualSetting = ____exports.VisualSetting
VisualSetting.name = "VisualSetting"
function VisualSetting.prototype.____constructor(self)
end
function VisualSetting.setLaunchjson(self, rootFolder, key, value, tag)
    if tag == nil then
        tag = ""
    end
    local settings = self:readLaunchjson(rootFolder)
    for keyLaunch in pairs(settings.configurations) do
        local valueLaunch = settings.configurations[keyLaunch]
        if tag == "" or valueLaunch.tag == tag then
            valueLaunch[key] = value
        end
    end
    local launchJson = JSON:stringify(settings, nil, 4)
    Tools:writeFileContent(
        tostring(rootFolder) .. "/.vscode/launch.json",
        launchJson
    )
end
function VisualSetting.getLaunchjson(self, rootFolder, key, tag)
    if tag == nil then
        tag = ""
    end
    local settings = self:readLaunchjson(rootFolder)
    for keyLaunch in pairs(settings.configurations) do
        local valueLaunch = settings.configurations[keyLaunch]
        if tag == "" or valueLaunch.tag == tag then
            return valueLaunch[key]
        end
    end
end
function VisualSetting.readLaunchjson(self, rootFolder)
    local launchPath = tostring(rootFolder) .. "/.vscode/launch.json"
    local launchExist = fs:existsSync(launchPath)
    local jsonStr
    if not launchExist then
        local dotVScodeDirExist = fs:existsSync(tostring(rootFolder) .. "/.vscode")
        if not dotVScodeDirExist then
            fs:mkdirSync(tostring(rootFolder) .. "/.vscode")
        end
        local launchTemplate = Tools:readFileContent(tostring(Tools.VSCodeExtensionPath) .. "/res/others/launch.json")
        Tools:writeFileContent(
            tostring(rootFolder) .. "/.vscode/launch.json",
            launchTemplate
        )
        jsonStr = launchTemplate
    else
        jsonStr = Tools:readFileContent(launchPath)
    end
    if jsonStr == nil or jsonStr == "" then
        return nil
    end
    local reg = nil
    jsonStr = __TS__StringReplace(jsonStr, reg, "")
    local launchSettings = JSON:parse(jsonStr)
    return launchSettings
end
function VisualSetting.getLaunchData(self, rootFolderArray)
    local jsonObj = __TS__New(Object)
    local snippetsPath = tostring(Tools.VSCodeExtensionPath) .. "/res/snippets/snippets.json"
    local isOpenAnalyzer = true
    local snipContent = fs:readFileSync(snippetsPath)
    if tostring(snipContent):trim() == "" then
        isOpenAnalyzer = false
    end
    jsonObj.command = "init_setting"
    jsonObj.isOpenAnalyzer = isOpenAnalyzer
    jsonObj.configs = {}
    local index = 0
    for forderName in pairs(rootFolderArray) do
        local rootFolder = rootFolderArray[forderName]
        jsonObj.configs[index] = {path = rootFolder, ["launch.json"] = {}}
        local settings = self:readLaunchjson(rootFolder)
        for key in pairs(settings.configurations) do
            local v = settings.configurations[key]
            if v.tag == "normal" or v.name == "LuaPanda" then
                jsonObj.configs[index]["launch.json"][v.name] = v
            elseif v.tag == "attach" or v.name == "LuaPanda-Attach" then
                jsonObj.configs[index]["launch.json"][v.name] = v
            elseif v.tag == "independent_file" or v.name == "LuaPanda-IndependentFile" then
                jsonObj.configs[index]["launch.json"][v.name] = v
            end
        end
        if #__TS__ObjectKeys(jsonObj.configs[index]["launch.json"]) == 0 then
            local launchTemplate = Tools:readFileContent(tostring(Tools.VSCodeExtensionPath) .. "/res/others/launch.json")
            local settings = JSON:parse(launchTemplate)
            for key in pairs(settings.configurations) do
                local v = settings.configurations[key]
                if v.tag == "normal" or v.name == "LuaPanda" then
                    jsonObj.configs[index]["launch.json"][v.name] = v
                end
                if v.tag == "attach" or v.name == "LuaPanda-Attach" then
                    jsonObj.configs[index]["launch.json"][v.name] = v
                end
                if v.tag == "independent_file" or v.name == "LuaPanda-IndependentFile" then
                    jsonObj.configs[index]["launch.json"][v.name] = v
                end
            end
        end
        index = index + 1
    end
    return JSON:stringify(jsonObj)
end
function VisualSetting.getWebMessage(self, message)
    local messageObj = JSON:parse(message.webInfo)
    repeat
        local ____switch32 = messageObj.command
        local removePath, res
        local ____cond32 = ____switch32 == "save_settings"
        if ____cond32 then
            self:processSaveSettings(messageObj)
            break
        end
        ____cond32 = ____cond32 or ____switch32 == "adb_reverse"
        if ____cond32 then
            self:processADBReverse(messageObj)
            break
        end
        ____cond32 = ____cond32 or ____switch32 == "on_off_analyzer"
        if ____cond32 then
            self:on_off_analyzer(messageObj)
            break
        end
        ____cond32 = ____cond32 or ____switch32 == "preAnalysisCpp"
        if ____cond32 then
            if not messageObj.path or messageObj.path:trim() == "" then
                DebugLogger:showTips("C++ 文件分析失败，传入路径为空!", 2)
            else
                if not fs:existsSync(messageObj.path:trim()) then
                    DebugLogger:showTips("输入了不存在的路径!", 2)
                    return
                end
                Tools.client:sendNotification("preAnalysisCpp", message.webInfo)
            end
            break
        end
        ____cond32 = ____cond32 or ____switch32 == "clearPreProcessFile"
        if ____cond32 then
            removePath = tostring(messageObj.rootFolder) .. "/.vscode/LuaPanda/"
            res = Tools:removeDir(removePath)
            if res then
                DebugLogger:showTips("文件夹已经清除")
            else
                DebugLogger:showTips("文件不存在", 2)
            end
            break
        end
    until true
end
function VisualSetting.on_off_analyzer(self, messageObj)
    local userControlBool = messageObj.switch
    local snippetsPath = tostring(Tools.VSCodeExtensionPath) .. "/res/snippets/snippets.json"
    local snippetsPathBackup = tostring(Tools.VSCodeExtensionPath) .. "/res/snippets/snippets_backup.json"
    if not userControlBool then
        fs:writeFileSync(snippetsPath, "")
        DebugLogger:showTips("您已关闭了代码辅助功能，重启VScode后将不再有代码提示!")
        return
    end
    if userControlBool then
        if fs:existsSync(snippetsPathBackup) then
            fs:writeFileSync(
                snippetsPath,
                fs:readFileSync(snippetsPathBackup)
            )
        end
        DebugLogger:showTips("您已打开了代码辅助功能，重启VScode后将会启动代码提示!")
        return
    end
end
function VisualSetting.processADBReverse(self, messageObj)
    local connectionPort = messageObj.connectionPort
    if self.ADBRevTerminal then
        self.ADBRevTerminal:dispose()
    end
    self.ADBRevTerminal = vscode.window:createTerminal({name = "ADB Reverse (LuaPanda)", env = {}})
    local cmd = (("adb reverse tcp:" .. tostring(connectionPort)) .. " tcp:") .. tostring(connectionPort)
    self.ADBRevTerminal:sendText(cmd, true)
    self.ADBRevTerminal:show()
end
function VisualSetting.processSaveSettings(self, messageObj)
    do
        local function ____catch(____error)
            DebugLogger:showTips("配置保存失败, 可能是由于 launch.json 文件无法写入. 请手动修改 launch.json 中的配置项来完成配置!", 2)
        end
        local ____try, ____hasReturned = pcall(function()
            local element = messageObj.configs
            local rootFolder = element.path
            local settings = self:readLaunchjson(rootFolder)
            local newConfig = element["launch.json"]
            for key in pairs(settings.configurations) do
                local target_name = settings.configurations[key].name
                if newConfig[target_name] then
                    settings.configurations[key] = newConfig[target_name]
                end
            end
            local launchJson = JSON:stringify(settings, nil, 4)
            Tools:writeFileContent(
                tostring(rootFolder) .. "/.vscode/launch.json",
                launchJson
            )
            DebugLogger:showTips("配置保存成功!")
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
return ____exports
