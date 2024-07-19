local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__StringSubstr = ____lualib.__TS__StringSubstr
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__StringSubstring = ____lualib.__TS__StringSubstring
local __TS__StringReplace = ____lualib.__TS__StringReplace
local ____exports = {}
local ____logManager = require("Plugins.LuaPanda.src.common.logManager")
local DebugLogger = ____logManager.DebugLogger
local ____tools = require("Plugins.LuaPanda.src.common.tools")
local Tools = ____tools.Tools
local ____util = require("Plugins.LuaPanda.src.common.util")
local isArray = ____util.isArray
local vscode = require("Plugins.LuaPanda.src.common.vscode")
local pathReader = require("Plugins.LuaPanda.src.common.path-reader")
____exports.PathManager = __TS__Class()
local PathManager = ____exports.PathManager
PathManager.name = "PathManager"
function PathManager.prototype.____constructor(self, _luaDebugInstance, _consoleLog)
    self.useAutoPathMode = false
    self.pathCaseSensitivity = false
    self.luaDebugInstance = _luaDebugInstance
    self.consoleLog = _consoleLog
end
function PathManager.prototype.rebuildWorkspaceNamePathMap(self, rootPath)
    local beginMS = Tools:getCurrentMS()
    local _fileNameToPathMap = __TS__New(Array)
    local workspaceFiles = pathReader:files(rootPath, {sync = true})
    local workspaceFileCount = workspaceFiles.length
    local processFilNum = 0
    do
        local processingFileIdx = 0
        while processingFileIdx < workspaceFileCount do
            do
                local formatedPath = Tools:genUnifiedPath(workspaceFiles[processingFileIdx])
                local nameExtObject = Tools:getPathNameAndExt(formatedPath)
                if not Tools.extMap[nameExtObject.ext] then
                    goto __continue4
                end
                processFilNum = processFilNum + 1
                local fileNameKey = nameExtObject.name
                if _fileNameToPathMap[fileNameKey] then
                    if isArray(nil, _fileNameToPathMap[fileNameKey]) then
                        _fileNameToPathMap[fileNameKey]:push(formatedPath)
                    elseif type(_fileNameToPathMap[fileNameKey]) == "string" then
                        local tempSaveValue = _fileNameToPathMap[fileNameKey]
                        local tempArray = __TS__New(Array)
                        tempArray[#tempArray + 1] = tempSaveValue
                        tempArray[#tempArray + 1] = formatedPath
                        _fileNameToPathMap[fileNameKey] = tempArray
                    else
                        _fileNameToPathMap[fileNameKey] = formatedPath
                    end
                else
                    _fileNameToPathMap[fileNameKey] = formatedPath
                end
                local processingRate = math.floor(processingFileIdx / workspaceFileCount * 100)
                local completePath = ""
                if isArray(nil, _fileNameToPathMap[fileNameKey]) then
                    completePath = _fileNameToPathMap[fileNameKey][_fileNameToPathMap[fileNameKey].length - 1]
                elseif type(_fileNameToPathMap[fileNameKey]) == "string" then
                    completePath = _fileNameToPathMap[fileNameKey]
                end
                DebugLogger:AdapterInfo((((tostring(processingRate) .. "%  |  ") .. tostring(fileNameKey)) .. "   ") .. completePath)
                if fileNameKey == "LuaPanda" then
                    self.LuaPandaPath = completePath
                end
            end
            ::__continue4::
            processingFileIdx = processingFileIdx + 1
        end
    end
    local endMS = Tools:getCurrentMS()
    DebugLogger:AdapterInfo(((((("文件Map刷新完毕，使用了" .. tostring(endMS - beginMS)) .. "毫秒。检索了") .. tostring(workspaceFileCount)) .. "个文件， 其中") .. tostring(processFilNum)) .. "个lua类型文件")
    if processFilNum <= 0 then
        vscode.window:showErrorMessage("没有在工程中检索到lua文件。请检查launch.json文件中lua后缀(luaFileExtension)是否配置正确, 以及VSCode打开的工程是否正确", "确定")
        local noLuaFileTip = "[!] 没有在VSCode打开的工程中检索到lua文件，请进行如下检查\n 1. VSCode打开的文件夹是否正确 \n 2. launch.json 文件中 luaFileExtension 选项配置是否正确"
        DebugLogger:DebuggerInfo(noLuaFileTip)
        DebugLogger:AdapterInfo(noLuaFileTip)
    end
    self.fileNameToPathMap = _fileNameToPathMap
end
function PathManager.prototype.checkSameNameFile(self, distinguishSameNameFile)
    local sameNameFileStr
    for nameKey in pairs(self.fileNameToPathMap) do
        local completePath = self.fileNameToPathMap[nameKey]
        if isArray(nil, completePath) then
            if sameNameFileStr == nil then
                sameNameFileStr = "\nVSCode打开工程中存在以下同名lua文件: \n"
            end
            sameNameFileStr = ((sameNameFileStr .. " + ") .. tostring(completePath:join("\n + "))) .. "\n\n"
        end
    end
    if sameNameFileStr then
        if distinguishSameNameFile then
            sameNameFileStr = sameNameFileStr .. "distinguishSameNameFile 已开启。调试器[可以区分]同名文件中的断点。\n"
        else
            local sameNameFileTips = "[Tips] VSCode 打开目录中存在同名 lua 文件，请避免在这些文件中打断点。如确定需要区分同名文件中的断点，可按以下选择适合自己项目的操作:\n"
            sameNameFileTips = sameNameFileTips .. "方法1: LuaPanda启动时会索引 cwd 目录中的 lua 文件, 修改 launch.json 中的 cwd 配置路径, 过滤掉不参与运行的文件夹, 缩小索引范围来避免重复文件;\n"
            sameNameFileTips = sameNameFileTips .. "方法2: 在 launch.json 中加入 distinguishSameNameFile:true , 开启同名文件区分 (会采用更严格的路径校验方式区分同名文件);\n"
            sameNameFileTips = sameNameFileTips .. "方法3: 同名文件信息展示在 VSCode 控制台 OUTPUT - LuaPanda Debugger 中, 也可以尝试修改文件名;\n"
            self:consoleLog(sameNameFileTips, self.luaDebugInstance)
        end
        DebugLogger:DebuggerInfo(sameNameFileStr)
        DebugLogger:AdapterInfo(sameNameFileStr)
    end
end
function PathManager.prototype.checkFullPath(self, shortPath, oPath)
    if self.useAutoPathMode == false then
        return shortPath
    end
    if "@" == __TS__StringSubstr(shortPath, 0, 1) then
        shortPath = __TS__StringSubstr(shortPath, 1)
    end
    local nameExtObject = Tools:getPathNameAndExt(shortPath)
    local fileName = nameExtObject.name
    local fullPath
    if self.pathCaseSensitivity then
        fullPath = self.fileNameToPathMap[fileName]
    else
        for keyPath in pairs(self.fileNameToPathMap) do
            if string.lower(keyPath) == fileName then
                fullPath = self.fileNameToPathMap[keyPath]
                break
            end
        end
    end
    if fullPath then
        if isArray(nil, fullPath) then
            if oPath then
                return self:checkRightPath(shortPath, oPath, fullPath)
            else
                for ____, element in __TS__Iterator(fullPath) do
                    if element:indexOf(shortPath) then
                        return element
                    end
                end
            end
        elseif type(fullPath) == "string" then
            return fullPath
        end
    end
    DebugLogger:showTips(("调试器没有找到文件 " .. shortPath) .. " 。 请检查launch.json文件中lua后缀是否配置正确, 以及VSCode打开的工程是否正确", 2)
    return shortPath
end
function PathManager.prototype.checkRightPath(self, fileName, oPath, fullPathArray)
    if "@" == __TS__StringSubstr(oPath, 0, 1) then
        oPath = __TS__StringSubstr(oPath, 1)
    end
    if "./" == __TS__StringSubstr(oPath, 0, 2) then
        oPath = __TS__StringSubstr(oPath, 1)
    end
    oPath = Tools:genUnifiedPath(oPath)
    if not self.pathCaseSensitivity then
        oPath = string.lower(oPath)
    end
    local nameExtObject = Tools:getPathNameAndExt(fileName)
    fileName = nameExtObject.name
    local idx = oPath:lastIndexOf(fileName)
    oPath = __TS__StringSubstring(oPath, 0, idx - 1)
    oPath = (oPath .. "/") .. fileName
    oPath = __TS__StringReplace(oPath, nil, "/")
    for ____, iteratorPath in __TS__Iterator(fullPathArray) do
        local pathForCompare = iteratorPath
        if not self.pathCaseSensitivity then
            pathForCompare = iteratorPath:toLowerCase()
        end
        if pathForCompare:indexOf(oPath) >= 0 then
            return iteratorPath
        end
    end
    if Tools.developmentMode == true then
        local str = ((("file_name:" .. fileName) .. "  opath:") .. oPath) .. "无法命中任何文件路径!"
        DebugLogger:showTips(str)
        local Adapterlog = "同名文件无法命中!\n"
        for ____, iteratorPath in __TS__Iterator(fullPathArray) do
            Adapterlog = Adapterlog .. (" + " .. tostring(iteratorPath)) .. "\n"
        end
        Adapterlog = Adapterlog .. str
        DebugLogger:AdapterInfo(Adapterlog)
    end
    return fullPathArray[0]
end
PathManager.rootFolderArray = {}
return ____exports
