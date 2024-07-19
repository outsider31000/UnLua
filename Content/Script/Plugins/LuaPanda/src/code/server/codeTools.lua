local ____lualib = require("lualib_bundle")
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local __TS__New = ____lualib.__TS__New
local __TS__Class = ____lualib.__TS__Class
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__StringSubstring = ____lualib.__TS__StringSubstring
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat
local Map = ____lualib.Map
local ____exports = {}
local path, os, connection, uriToPathCache, pathToUriCache
local ____codeLogManager = require("Plugins.LuaPanda.src.code.server.codeLogManager")
local Logger = ____codeLogManager.Logger
local ____vscode_2Duri = require("Plugins.LuaPanda.src.code.server.vscode-uri")
local URI = ____vscode_2Duri.default
local ____vscode_2Dlanguageserver = require("Plugins.LuaPanda.src.code.server.vscode-languageserver")
local Location = ____vscode_2Dlanguageserver.Location
local Position = ____vscode_2Dlanguageserver.Position
local SymbolKind = ____vscode_2Dlanguageserver.SymbolKind
local Range = ____vscode_2Dlanguageserver.Range
local fs = require("Plugins.LuaPanda.src.code.server.fs")
function ____exports.pathToUri(self, pathStr)
    if pathToUriCache[pathStr] then
        return pathToUriCache[pathStr]
    end
    local retUri
    if os:type() == "Windows_NT" then
        local pathArr = __TS__StringSplit(pathStr, path.sep)
        local stdPath = table.concat(pathArr, "/")
        retUri = "file:///" .. stdPath
    else
        retUri = "file://" .. pathStr
    end
    pathToUriCache[pathStr] = retUri
    return retUri
end
function ____exports.uriToPath(self, uri)
    if uriToPathCache[uri] then
        return uriToPathCache[uri]
    end
    local pathStr = URI:parse(uri).fsPath
    uriToPathCache[uri] = pathStr
    return pathStr
end
function ____exports.showProgressMessage(self, progress, message)
    connection:sendNotification(
        "showProgress",
        (tostring(progress) .. "% ") .. message
    )
    if progress == 100 then
        connection:sendNotification("showProgress", "LuaPanda 👍")
    end
end
function ____exports.splitToArrayByDot(self, input)
    local userInputTxt_DotToBlank = input:replace(nil, " ")
    local L = userInputTxt_DotToBlank:split(" ")
    return L
end
path = require("Plugins.LuaPanda.src.code.server.path")
local dir = require("Plugins.LuaPanda.src.code.server.path-reader")
os = require("Plugins.LuaPanda.src.code.server.os")
local urlencode = require("Plugins.LuaPanda.src.code.server.urlencode")
local initParameter
function ____exports.setInitPara(self, para)
    initParameter = para
end
local VScodeExtensionPath
function ____exports.getVScodeExtensionPath(self)
    return VScodeExtensionPath
end
local VSCodeOpenedFolders = {}
function ____exports.getVSCodeOpenedFolders(self)
    if #VSCodeOpenedFolders == 0 and initParameter and initParameter.workspaceFolders then
        for ____, rootFold in __TS__Iterator(initParameter.workspaceFolders) do
            VSCodeOpenedFolders[#VSCodeOpenedFolders + 1] = ____exports.uriToPath(nil, rootFold.uri)
        end
    end
    return VSCodeOpenedFolders
end
function ____exports.addOpenedFolder(self, newFolders)
    local rootFolders = ____exports.getVSCodeOpenedFolders(nil)
    for ____, folder in __TS__Iterator(newFolders) do
        rootFolders[#rootFolders + 1] = ____exports.uriToPath(nil, folder.uri)
    end
end
function ____exports.removeOpenedFolder(self, beDelFolders)
    local rootFolders = ____exports.getVSCodeOpenedFolders(nil)
    for ____, folder in __TS__Iterator(beDelFolders) do
        do
            local idx = 0
            while idx < #rootFolders do
                if ____exports.uriToPath(nil, folder.uri) == rootFolders[idx + 1] then
                    __TS__ArraySplice(rootFolders, idx, 1)
                    break
                end
                idx = idx + 1
            end
        end
    end
end
function ____exports.setVScodeExtensionPath(self, _VScodeExtensionPath)
    VScodeExtensionPath = _VScodeExtensionPath
end
local loadedExt
function ____exports.initLoadedExt(self)
    loadedExt = __TS__New(Object)
end
function ____exports.getLoadedExt(self)
    return loadedExt
end
function ____exports.setLoadedExt(self, key)
    loadedExt[key] = true
end
function ____exports.setToolsConnection(self, conn)
    connection = conn
end
local fileName_Uri_Cache
uriToPathCache = __TS__New(Object)
pathToUriCache = __TS__New(Object)
____exports.SearchMode = SearchMode or ({})
____exports.SearchMode.ExactlyEqual = 0
____exports.SearchMode[____exports.SearchMode.ExactlyEqual] = "ExactlyEqual"
____exports.SearchMode.FuzzyMatching = 1
____exports.SearchMode[____exports.SearchMode.FuzzyMatching] = "FuzzyMatching"
____exports.SearchMode.PrefixMatch = 2
____exports.SearchMode[____exports.SearchMode.PrefixMatch] = "PrefixMatch"
____exports.SearchRange = SearchRange or ({})
____exports.SearchRange.AllSymbols = 0
____exports.SearchRange[____exports.SearchRange.AllSymbols] = "AllSymbols"
____exports.SearchRange.GlobalSymbols = 1
____exports.SearchRange[____exports.SearchRange.GlobalSymbols] = "GlobalSymbols"
____exports.SearchRange.LocalSymbols = 2
____exports.SearchRange[____exports.SearchRange.LocalSymbols] = "LocalSymbols"
____exports.TagReason = TagReason or ({})
____exports.TagReason.UserTag = 0
____exports.TagReason[____exports.TagReason.UserTag] = "UserTag"
____exports.TagReason.Equal = 1
____exports.TagReason[____exports.TagReason.Equal] = "Equal"
____exports.TagReason.MetaTable = 2
____exports.TagReason[____exports.TagReason.MetaTable] = "MetaTable"
____exports.searchRet = __TS__Class()
local searchRet = ____exports.searchRet
searchRet.name = "searchRet"
function searchRet.prototype.____constructor(self)
    self.isFindout = false
end
____exports.chunkClass = __TS__Class()
local chunkClass = ____exports.chunkClass
chunkClass.name = "chunkClass"
function chunkClass.prototype.____constructor(self, name, loc)
    self.chunkName = name
    self.loc = loc
end
____exports.docInformation = __TS__Class()
local docInformation = ____exports.docInformation
docInformation.name = "docInformation"
function docInformation.prototype.____constructor(self, docAST, docUri, docPath)
    self.parseSucc = true
    self.docAST = docAST
    self.docUri = docUri
    self.docPath = docPath
    self.defineSymbols = __TS__New(Object)
    self.defineSymbols.allSymbols = __TS__New(Array)
    self.defineSymbols.allSymbolsArray = __TS__New(Array)
    local ____ = self.defineSymbols.allSymbolsTrie
    self.defineSymbols.globalSymbols = __TS__New(Array)
    self.defineSymbols.globalSymbolsArray = __TS__New(Array)
    local ____ = self.defineSymbols.globalSymbolsTrie
    self.defineSymbols.localSymbols = __TS__New(Array)
    self.defineSymbols.localSymbolsArray = __TS__New(Array)
    local ____ = self.defineSymbols.localSymbolsTrie
    self.defineSymbols.chunks = __TS__New(Array)
    self.defineSymbols.chunksArray = __TS__New(Array)
    self.requires = __TS__New(Array)
    self.references = __TS__New(Array)
end
function ____exports.urlDecode(self, url)
    return urlencode:decode(url)
end
function ____exports.getPathNameAndExt(self, UriOrPath)
    local name_and_ext = path:basename(UriOrPath):split(".")
    local name = name_and_ext[0]
    local ext = name_and_ext[1]
    do
        local index = 2
        while index < name_and_ext.length do
            ext = (tostring(ext) .. ".") .. tostring(name_and_ext[index])
            index = index + 1
        end
    end
    return {name = name, ext = ext}
end
function ____exports.get_FileName_Uri_Cache(self)
    return fileName_Uri_Cache
end
function ____exports.AddTo_FileName_Uri_Cache(self, name, uri)
    fileName_Uri_Cache[name] = ____exports.urlDecode(nil, uri)
end
function ____exports.isinPreloadFolder(self, uri)
    if not uri then
        return false
    end
    local matchRes = uri:match(".vscode/LuaPanda/IntelliSenseRes")
    if matchRes then
        return true
    end
    return false
end
function ____exports.refresh_FileName_Uri_Cache(self)
    local totalFileNum = 0
    fileName_Uri_Cache = __TS__New(Array)
    local processFilNum = 0
    for ____, rootFolder in ipairs(____exports.getVSCodeOpenedFolders(nil)) do
        local rootFiles = dir:files(rootFolder, {sync = true})
        totalFileNum = totalFileNum + rootFiles.length
        do
            local idx = 0
            local len = rootFiles.length
            while idx < len do
                local name_and_ext = ____exports.getPathNameAndExt(nil, rootFiles[idx])
                local trname = name_and_ext.name
                local ext = name_and_ext.ext
                local validExt = ____exports.getLoadedExt(nil)
                if validExt[ext] then
                    local trUri = ____exports.pathToUri(nil, rootFiles[idx])
                    fileName_Uri_Cache[trname] = ____exports.urlDecode(nil, trUri)
                    Logger:DebugLog(trUri)
                    processFilNum = processFilNum + 1
                end
                idx = idx + 1
            end
        end
    end
    Logger:InfoLog(((("文件Cache刷新完毕，共计" .. tostring(totalFileNum)) .. "个文件， 其中") .. tostring(processFilNum)) .. "个lua类型文件")
    ____exports.showProgressMessage(nil, 100, "done!")
end
function ____exports.transFileNameToUri(self, requireName)
    if requireName == nil then
        return ""
    end
    local parseName = path:parse(requireName)
    local cacheUri = fileName_Uri_Cache[parseName.name]
    if cacheUri then
        return cacheUri
    end
    return ""
end
function ____exports.transWinDiskToUpper(self, uri)
    if os:type() == "Windows_NT" then
        local reg = nil
        uri = __TS__StringReplace(
            uri,
            reg,
            function(self, m)
                local diskSymbol = string.sub(m, 9, 9)
                diskSymbol = "file:///" .. string.upper(diskSymbol)
                return diskSymbol
            end
        )
        return uri
    end
end
function ____exports.getDirFiles(self, path)
    if path then
        return dir:files(path, {sync = true})
    end
end
function ____exports.getFileContent(self, path)
    if path == "" or path == nil then
        return ""
    end
    local data = fs:readFileSync(path)
    local dataStr = tostring(data)
    return dataStr
end
function ____exports.transPosStartLineTo1(self, position)
    position.line = position.line + 1
end
function ____exports.transPosStartLineTo0(self, position)
    position.line = position.line - 1
end
function ____exports.getTextByPosition(self, luaText, pos)
    if luaText == nil then
        return ""
    end
    local stringArr = __TS__StringSplit(luaText, nil)
    local startStr = __TS__StringSubstring(stringArr[pos.line], 0, pos.character)
    local reg = nil
    local blankStr = __TS__StringReplace(startStr, reg, " ")
    local finalArr = __TS__StringSplit(blankStr, " ")
    local retStr = table.remove(finalArr)
    return retStr
end
--- isNextLineHasFunction 使用正则判断下一行是否有function关键字，如果有返回true
-- 
-- @param luaText 文件内容
-- @param position 位置
function ____exports.isNextLineHasFunction(self, luaText, position)
    local luaTextArray = __TS__StringSplit(luaText, nil)
    if #luaTextArray <= position.line + 1 then
        return false
    end
    local nextLineText = luaTextArray[position.line + 1]
    local regExp = nil
    if regExp:exec(nextLineText) then
        return true
    end
    return false
end
function ____exports.createEmptyLocation(self, uri)
    local pos = Position:create(0, 0)
    local rg = Range:create(pos, pos)
    local retLoc = Location:create(uri, rg)
    return retLoc
end
function ____exports.isMatchedIgnoreRegExp(self, uri, ignoreRegExp)
    do
        local i = 0
        while i < #ignoreRegExp do
            do
                if ignoreRegExp[i + 1] == "" then
                    goto __continue62
                end
                local regExp = __TS__New(RegExp, ignoreRegExp[i + 1])
                if regExp:exec(uri) then
                    return true
                end
            end
            ::__continue62::
            i = i + 1
        end
    end
    return false
end
function ____exports.getNSpace(self, n)
    local str = ""
    do
        local i = 0
        while i < n do
            str = str .. " "
            i = i + 1
        end
    end
    return str
end
function ____exports.showTips(self, str, level)
    if level == 2 then
        connection:sendNotification("showErrorMessage", str)
    elseif level == 1 then
        connection:sendNotification("showWarningMessage", str)
    else
        connection:sendNotification("showInformationMessage", str)
    end
end
function ____exports.changeDicSymboltoArray(self, dic)
    local array = __TS__New(Array)
    for key in pairs(dic) do
        local element = dic[key]
        if __TS__ArrayIsArray(element) then
            for k in pairs(element) do
                local ele = element[k]
                array[#array + 1] = ele
            end
        else
            array[#array + 1] = element
        end
    end
    return array
end
local function getVerboseSymbolContainer(self, verboseSymbolInfo)
    local searchName = verboseSymbolInfo.searchName
    local searchNameArray = Array(nil)
    if searchName ~= "..." then
        searchName = __TS__StringReplace(searchName, nil, ".")
        searchName = __TS__StringReplace(searchName, nil, "")
        searchNameArray = ____exports.splitToArrayByDot(nil, searchName)
    end
    local searchNameContainer = Array(nil)
    do
        local i = 0
        while i < #searchNameArray - 1 do
            searchNameContainer[#searchNameContainer + 1] = __TS__New(____exports.chunkClass, searchNameArray[i + 1], nil)
            i = i + 1
        end
    end
    local containerList = Array(nil)
    containerList[#containerList + 1] = verboseSymbolInfo.containerList[1]
    do
        local i = 1
        while i < #verboseSymbolInfo.containerList do
            local chunkNameArray = ____exports.splitToArrayByDot(nil, verboseSymbolInfo.containerList[i + 1].chunkName)
            if chunkNameArray.length > 1 then
                do
                    local j = 0
                    while j < chunkNameArray.length do
                        containerList[#containerList + 1] = __TS__New(____exports.chunkClass, chunkNameArray[j], nil)
                        j = j + 1
                    end
                end
            else
                containerList[#containerList + 1] = verboseSymbolInfo.containerList[i + 1]
            end
            i = i + 1
        end
    end
    local verboseSymbolContainer = __TS__ArrayConcat(containerList, searchNameContainer)
    return verboseSymbolContainer
end
local function handleDocumentSymbolChildren(self, symbolContainer, documentSymbol, outlineSymbolArray, chunkMap)
    local index = chunkMap:get(symbolContainer[2].chunkName)
    if index == nil then
        return
    end
    local parent = outlineSymbolArray[index + 1]
    do
        local i = 2
        while i < #symbolContainer do
            do
                local j = 0
                while j < parent.children.length do
                    if symbolContainer[i + 1].chunkName == parent.children[j].originalName then
                        parent = parent.children[j]
                        break
                    end
                    j = j + 1
                end
            end
            i = i + 1
        end
    end
    if not parent.children then
        parent.children = __TS__New(Array)
    end
    parent.children:push(documentSymbol)
end
--- 列出本文件中的符号，用于在outline窗口中分层显示符号列表
-- 
-- @param symbolInfoArray CodeSymbol.getCertainDocSymbolsArray返回的符号信息数组
-- @return 本文件所有符号列表，DocumentSymbol数组，带有层次结构
function ____exports.getOutlineSymbol(self, symbolInfoArray)
    local outlineSymbolArray = Array(nil)
    local chunkMap = __TS__New(Map)
    do
        local i = 0
        while i < #symbolInfoArray do
            do
                local symbolInfo = symbolInfoArray[i + 1]
                local documentSymbol = {
                    name = symbolInfo.originalName,
                    kind = symbolInfo.kind,
                    range = symbolInfo.location.range,
                    selectionRange = symbolInfo.location.range,
                    children = Array(nil)
                }
                documentSymbol.originalName = symbolInfo.originalName
                if symbolInfo.kind == SymbolKind.Function then
                    documentSymbol.name = symbolInfo.name
                end
                local verboseSymbolContainer = getVerboseSymbolContainer(nil, symbolInfoArray[i + 1])
                if #verboseSymbolContainer > 1 then
                    handleDocumentSymbolChildren(
                        nil,
                        verboseSymbolContainer,
                        documentSymbol,
                        outlineSymbolArray,
                        chunkMap
                    )
                    goto __continue94
                end
                outlineSymbolArray[#outlineSymbolArray + 1] = documentSymbol
                chunkMap:set(symbolInfo.searchName, #outlineSymbolArray - 1)
            end
            ::__continue94::
            i = i + 1
        end
    end
    return outlineSymbolArray
end
return ____exports
