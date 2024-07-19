local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local vscode = require("Plugins.LuaPanda.src.common.vscode")
local fs = require("Plugins.LuaPanda.src.common.fs")
local ____vscode_2Duri = require("Plugins.LuaPanda.src.common.vscode-uri")
local URI = ____vscode_2Duri.default
local path = require("Plugins.LuaPanda.src.common.path")
____exports.Tools = __TS__Class()
local Tools = ____exports.Tools
Tools.name = "Tools"
function Tools.prototype.____constructor(self)
end
function Tools.getLuaPathInExtension(self)
    local luaPathInVSCodeExtension = tostring(self.VSCodeExtensionPath) .. "/Debugger/LuaPanda.lua"
    return luaPathInVSCodeExtension
end
function Tools.getClibPathInExtension(self)
    local ClibPathInVSCodeExtension = tostring(self.VSCodeExtensionPath) .. "/Debugger/debugger_lib/plugins/"
    return ClibPathInVSCodeExtension
end
function Tools.readFileContent(self, path)
    if path == "" or path == nil then
        return ""
    end
    local data = fs:readFileSync(path)
    local dataStr = tostring(data)
    return dataStr
end
function Tools.writeFileContent(self, path, content)
    if path == "" or path == nil then
        return
    end
    fs:writeFileSync(path, content)
end
function Tools.genUnifiedPath(self, beProcessPath)
    beProcessPath = beProcessPath:replace(nil, "/")
    while beProcessPath:match(nil) do
        beProcessPath = beProcessPath:replace(nil, "/")
    end
    beProcessPath = beProcessPath:replace(
        nil,
        function(self, _____241)
            return _____241:toLocaleLowerCase()
        end
    )
    return beProcessPath
end
function Tools.getVSCodeAvtiveFilePath(self)
    local retObject = {retCode = 0, retMsg = "", filePath = ""}
    local activeWindow = vscode.window.activeTextEditor
    if activeWindow then
        local activeFileUri = ""
        local activeScheme = activeWindow.document.uri.scheme
        if activeScheme ~= "file" then
            local visableTextEditorArray = vscode.window.visibleTextEditors
            for key in pairs(visableTextEditorArray) do
                local editor = visableTextEditorArray[key]
                local editScheme = editor.document.uri.scheme
                if editScheme == "file" then
                    activeFileUri = editor.document.uri.fsPath
                    break
                end
            end
        else
            activeFileUri = activeWindow.document.uri.fsPath
        end
        if activeFileUri == "" then
            retObject.retMsg = "[Error]: adapter start file debug, but file Uri is empty string"
            retObject.retCode = -1
            return retObject
        end
        local pathArray = __TS__StringSplit(activeFileUri, path.sep)
        local filePath = table.concat(pathArray, "/")
        filePath = ("\"" .. filePath) .. "\""
        retObject.filePath = filePath
        return retObject
    else
        retObject.retMsg = "[Error]: can not get vscode activeWindow"
        retObject.retCode = -1
        return retObject
    end
end
function Tools.rebuildAcceptExtMap(self, userSetExt)
    ____exports.Tools.extMap = __TS__New(Object)
    ____exports.Tools.extMap.lua = true
    ____exports.Tools.extMap["lua.txt"] = true
    ____exports.Tools.extMap["lua.bytes"] = true
    if type(userSetExt) == "string" and userSetExt ~= "" then
        ____exports.Tools.extMap[userSetExt] = true
    end
end
function Tools.getCurrentMS(self)
    local currentMS = __TS__New(Date)
    return currentMS:getTime()
end
function Tools.getPathNameAndExt(self, UriOrPath)
    local name_and_ext = path:basename(UriOrPath):split(".")
    local name = name_and_ext[0]
    local ext = name_and_ext[1] or ""
    do
        local index = 2
        while index < name_and_ext.length do
            ext = (tostring(ext) .. ".") .. tostring(name_and_ext[index])
            index = index + 1
        end
    end
    return {name = name, ext = ext}
end
function Tools.getDirAndFileName(self, UriOrPath)
    local retObj = self:getPathNameAndExt(UriOrPath)
    local _dir = path:dirname(UriOrPath)
    retObj.dir = _dir
    return retObj
end
function Tools.removeDir(self, dir)
    local files
    do
        local function ____catch(err)
            if err.code == "ENOENT" then
                return true, false
            else
                error(err, 0)
            end
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            files = fs:readdirSync(dir)
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
    do
        local i = 0
        while i < files.length do
            local newPath = path:join(dir, files[i])
            local stat = fs:statSync(newPath)
            if stat:isDirectory() then
                self:removeDir(newPath)
            else
                fs:unlinkSync(newPath)
            end
            i = i + 1
        end
    end
    fs:rmdirSync(dir)
    return true
end
function Tools.uriToPath(self, uri)
    local pathStr = URI:parse(uri).fsPath
    return pathStr
end
Tools.developmentMode = false
return ____exports
