local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__StringTrim = ____lualib.__TS__StringTrim
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__New = ____lualib.__TS__New
local __TS__ObjectDefineProperty = ____lualib.__TS__ObjectDefineProperty
local ____exports = {}
local Tools = require("Plugins.LuaPanda.src.code.server.codeTools")
local ____codeLogManager = require("Plugins.LuaPanda.src.code.server.codeLogManager")
local Logger = ____codeLogManager.Logger
local ____codeSymbol = require("Plugins.LuaPanda.src.code.server.codeSymbol")
local CodeSymbol = ____codeSymbol.CodeSymbol
local fs = require("Plugins.LuaPanda.src.code.server.codeExport.fs")
local dir = require("Plugins.LuaPanda.src.code.server.codeExport.path-reader")
local path = require("Plugins.LuaPanda.src.code.server.codeExport.path")
____exports.SluaCSharpProcessor = __TS__Class()
local SluaCSharpProcessor = ____exports.SluaCSharpProcessor
SluaCSharpProcessor.name = "SluaCSharpProcessor"
function SluaCSharpProcessor.prototype.____constructor(self)
end
function SluaCSharpProcessor.loadIntelliSenseRes(self)
    CodeSymbol:refreshUserPreloadSymbals(self.sluaCSharpInterfaceIntelliSenseResPath)
end
function SluaCSharpProcessor.processluaCSDir(self, cppDir)
    local intelLuaPath = self.sluaCSharpInterfaceIntelliSenseResPath
    if not intelLuaPath then
        Logger:ErrorLog("未打开文件夹，无法使用此功能！")
        Tools:showTips("未打开文件夹，无法使用此功能！")
    end
    local subDir = cppDir
    subDir = __TS__StringReplace(subDir, nil, " ")
    subDir = __TS__StringReplace(subDir, nil, " ")
    subDir = __TS__StringReplace(subDir, nil, "")
    subDir = __TS__StringTrim(subDir)
    subDir = __TS__StringReplace(subDir, nil, "-")
    local files = self:getCSharpFiles(cppDir)
    local fileCount = self:readSluaCSSymbols(files, subDir)
    CodeSymbol:refreshUserPreloadSymbals(intelLuaPath)
    return fileCount
end
function SluaCSharpProcessor.getCSharpFiles(self, dirPath)
    local options = {
        sync = true,
        recursive = true,
        valuetizer = function(self, stat, fileShortName, fileFullPath)
            if stat:isDirectory() then
                return fileFullPath
            end
            return fileShortName:match(nil) and fileFullPath or nil
        end
    }
    return dir:files(dirPath, "file", nil, options)
end
function SluaCSharpProcessor.readSluaCSSymbols(self, filepath, writepath)
    local sluaRootPath = self.sluaCSharpInterfaceIntelliSenseResPath + writepath
    self:makeDirSync(sluaRootPath)
    local fileCount = 0
    for ____, file in __TS__Iterator(filepath) do
        local codeTxt = Tools:getFileContent(file)
        if codeTxt then
            local luaTxt = self:parseSluaCSSymbols(codeTxt)
            if luaTxt and luaTxt ~= "" then
                fileCount = fileCount + 1
                local csFilePath = ((tostring(sluaRootPath) .. "/") .. tostring(path:basename(file, "cs"))) .. "lua"
                fs:writeFileSync(csFilePath, luaTxt)
            end
        end
    end
    if fileCount > 0 then
        local engineFileName = "Lua_UnityEngine.lua"
        local engineFileContent = "UnityEngine = {}"
        fs:writeFileSync(
            (tostring(sluaRootPath) .. "/") .. engineFileName,
            engineFileContent
        )
    end
    return fileCount
end
function SluaCSharpProcessor.makeDirSync(self, dirPath)
    if fs:existsSync(dirPath) then
        return
    end
    local baseDir = path:dirname(dirPath)
    self:makeDirSync(baseDir)
    fs:mkdirSync(dirPath)
end
function SluaCSharpProcessor.parseSluaCSSymbols(self, codeTxt)
    local currentClass
    local parentClass
    local members = {}
    local createTypeMetatableREG = nil
    local dver = codeTxt:match(createTypeMetatableREG)
    if not dver then
        return
    end
    if dver and dver.length == 2 then
        local paramsArray = dver[1]:split(",")
        if paramsArray.length == 4 and paramsArray[3]:trim():search("typeof") ~= 0 then
            paramsArray[2] = paramsArray[2] + paramsArray:pop()
        end
        if paramsArray.length == 3 then
            currentClass = paramsArray[2]:trim():match(nil)[1]
        elseif paramsArray.length == 4 then
            currentClass = paramsArray[2]:trim():match(nil)[1]
            parentClass = paramsArray[3]:trim():match(nil)[1]:replace("_", ".")
        end
    end
    local memberREG = nil
    local dver2 = codeTxt:match(memberREG)
    if dver2 then
        for ____, mems in __TS__Iterator(dver2) do
            local paras = mems:match(nil)
            if paras[2] then
                local functionObj = __TS__New(Object)
                functionObj.var = paras[2]
                functionObj.type = "variable"
                members[#members + 1] = functionObj
            elseif paras[3] then
                local varObj = __TS__New(Object)
                local functionNameStr = paras[3]
                functionNameStr = functionNameStr:replace(nil, "")
                varObj.var = tostring(functionNameStr) .. "()"
                varObj.type = "function"
                members[#members + 1] = varObj
            end
        end
    end
    local luaCode = tostring(currentClass) .. " = {}"
    if parentClass then
        luaCode = luaCode .. " ---@type " .. tostring(parentClass)
    end
    luaCode = luaCode .. "\n"
    for ____, oneMember in ipairs(members) do
        if oneMember.type == "variable" then
            luaCode = luaCode .. ((tostring(currentClass) .. ".") .. tostring(oneMember.var)) .. " = nil\n"
        elseif oneMember.type == "function" then
            luaCode = luaCode .. ((("function " .. tostring(currentClass)) .. ".") .. tostring(oneMember.var)) .. " end\n"
        end
    end
    return luaCode
end
__TS__ObjectDefineProperty(
    SluaCSharpProcessor,
    "sluaCSharpInterfaceIntelliSenseResPath",
    {get = function(self)
        if not self._sluaCSharpInterfaceIntelliSenseResPath then
            if Tools:getVSCodeOpenedFolders() and #Tools:getVSCodeOpenedFolders() > 0 then
                self._sluaCSharpInterfaceIntelliSenseResPath = tostring(Tools:getVSCodeOpenedFolders()[1]) .. "/.vscode/LuaPanda/IntelliSenseRes/SluaCSharpInterface/"
            end
        end
        return self._sluaCSharpInterfaceIntelliSenseResPath
    end}
)
return ____exports
