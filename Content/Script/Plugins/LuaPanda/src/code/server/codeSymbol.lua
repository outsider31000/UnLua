local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local Map = ____lualib.Map
local ____exports = {}
local Tools = require("Plugins.LuaPanda.src.code.server.codeTools")
local ____codeEditor = require("Plugins.LuaPanda.src.code.server.codeEditor")
local CodeEditor = ____codeEditor.CodeEditor
local ____docSymbolProcessor = require("Plugins.LuaPanda.src.code.server.docSymbolProcessor")
local DocSymbolProcessor = ____docSymbolProcessor.DocSymbolProcessor
local ____codeLogManager = require("Plugins.LuaPanda.src.code.server.codeLogManager")
local Logger = ____codeLogManager.Logger
local ____codeSettings = require("Plugins.LuaPanda.src.code.server.codeSettings")
local CodeSettings = ____codeSettings.CodeSettings
local dir = require("Plugins.LuaPanda.src.code.server.path-reader")
____exports.CodeSymbol = __TS__Class()
local CodeSymbol = ____exports.CodeSymbol
CodeSymbol.name = "CodeSymbol"
function CodeSymbol.prototype.____constructor(self)
end
function CodeSymbol.getCretainDocChunkDic(self, uri)
    local processor = self:getFileSymbolsFromCache(uri)
    if processor then
        return processor:getChunksDic()
    end
end
function CodeSymbol.createOneDocSymbols(self, uri, luaText)
    if not self.docSymbolMap:has(uri) then
        self:refreshOneDocSymbols(uri, luaText)
    end
end
function CodeSymbol.refreshOneDocSymbols(self, uri, luaText)
    if luaText == nil then
        luaText = CodeEditor:getCode(uri)
    end
    self:createDocSymbol(uri, luaText)
end
function CodeSymbol.createSymbolswithExt(self, luaExtname, rootpath)
    Tools:setLoadedExt(luaExtname)
    local exp = __TS__New(RegExp, luaExtname .. "$", "i")
    dir:readFiles(
        rootpath,
        {match = exp},
        function(self, err, content, filePath, next)
            if not err then
                local uri = Tools:pathToUri(filePath)
                if not Tools:isinPreloadFolder(uri) then
                    ____exports.CodeSymbol:createOneDocSymbols(uri, content)
                else
                    ____exports.CodeSymbol:refreshOneUserPreloadDocSymbols(Tools:uriToPath(uri))
                end
            end
            next(nil)
        end,
        function(____, err)
            if err then
                return
            end
        end
    )
end
function CodeSymbol.getOneDocSymbolsArray(self, uri, luaText, range)
    local docSymbals = {}
    self:createOneDocSymbols(uri, luaText)
    repeat
        local ____switch17 = range
        local ____cond17 = ____switch17 == Tools.SearchRange.GlobalSymbols
        if ____cond17 then
            docSymbals = self:getFileSymbolsFromCache(uri):getGlobalSymbolsArray()
            break
        end
        ____cond17 = ____cond17 or ____switch17 == Tools.SearchRange.LocalSymbols
        if ____cond17 then
            docSymbals = self:getFileSymbolsFromCache(uri):getLocalSymbolsArray()
            break
        end
        ____cond17 = ____cond17 or ____switch17 == Tools.SearchRange.AllSymbols
        if ____cond17 then
            docSymbals = self:getFileSymbolsFromCache(uri):getAllSymbolsArray()
            break
        end
    until true
    return docSymbals
end
function CodeSymbol.getOneDocSymbolsDic(self, uri, luaText, range)
    local docSymbals = {}
    self:createOneDocSymbols(uri, luaText)
    repeat
        local ____switch19 = range
        local ____cond19 = ____switch19 == Tools.SearchRange.GlobalSymbols
        if ____cond19 then
            docSymbals = self:getFileSymbolsFromCache(uri):getGlobalSymbolsDic()
            break
        end
        ____cond19 = ____cond19 or ____switch19 == Tools.SearchRange.LocalSymbols
        if ____cond19 then
            docSymbals = self:getFileSymbolsFromCache(uri):getLocalSymbolsDic()
            break
        end
        ____cond19 = ____cond19 or ____switch19 == Tools.SearchRange.AllSymbols
        if ____cond19 then
            docSymbals = self:getFileSymbolsFromCache(uri):getAllSymbolsDic()
            break
        end
    until true
    return docSymbals
end
function CodeSymbol.getOneDocReturnSymbol(self, uri)
    self:createOneDocSymbols(uri)
    local docSymbals = self.docSymbolMap:get(uri)
    if docSymbals then
        return docSymbals:getFileReturnArray()
    else
        return nil
    end
end
function CodeSymbol.createFolderSymbols(self, path)
    if path == nil or path == "" then
        return
    end
    local filesArray = Tools:getDirFiles(path)
    filesArray:forEach(function(____, pathArray)
        local uri = Tools:pathToUri(pathArray)
        if not self.docSymbolMap:has(uri) then
            self:createDocSymbol(uri, pathArray)
        end
    end)
end
function CodeSymbol.refreshFolderSymbols(self, path)
    if path == nil or path == "" then
        return
    end
    local filesArray = Tools:getDirFiles(path)
    filesArray:forEach(function(____, element)
        self:createDocSymbol(element)
    end)
end
function CodeSymbol.createLuaPreloadSymbols(self, path)
    if path == nil or path == "" then
        return
    end
    local filesArray = Tools:getDirFiles(path)
    filesArray:forEach(function(____, pathElement)
        self:createPreLoadSymbals(
            Tools:pathToUri(pathElement),
            0
        )
    end)
end
function CodeSymbol.refreshUserPreloadSymbals(self, path)
    if path == nil or path == "" then
        return
    end
    local filesArray = Tools:getDirFiles(path)
    filesArray:forEach(function(____, pathElement)
        self:createPreLoadSymbals(
            Tools:pathToUri(pathElement),
            1
        )
    end)
end
function CodeSymbol.refreshOneUserPreloadDocSymbols(self, filePath)
    if filePath == nil or filePath == "" then
        return
    end
    self:createPreLoadSymbals(
        Tools:pathToUri(filePath),
        1
    )
end
function CodeSymbol.getWorkspaceSymbols(self, range)
    range = range or Tools.SearchRange.AllSymbols
    local filesMap = Tools:get_FileName_Uri_Cache()
    local g_symb = {}
    for fileUri in pairs(filesMap) do
        if not Tools:isinPreloadFolder(filesMap[fileUri]) then
            local g_s = self:getOneDocSymbolsDic(filesMap[fileUri], nil, range)
            for key in pairs(g_s) do
                local element = g_s[key]
                g_symb[key] = element
            end
        end
    end
    return g_symb
end
function CodeSymbol.searchSymbolReferenceinDoc(self, searchSymbol)
    local uri = searchSymbol.containerURI
    local docSymbals = self:getFileSymbolsFromCache(uri)
    return docSymbals:searchDocSymbolReference(searchSymbol)
end
function CodeSymbol.searchSymbolinDoc(self, uri, symbolStr, searchMethod, range)
    if range == nil then
        range = Tools.SearchRange.AllSymbols
    end
    if symbolStr == "" or uri == "" then
        return nil
    end
    local docSymbals = self:getFileSymbolsFromCache(uri)
    local retSymbols = docSymbals:searchMatchSymbal(symbolStr, searchMethod, range)
    return retSymbols
end
function CodeSymbol.getFileSymbolsFromCache(self, uri)
    local docSymbals = self.docSymbolMap:get(uri)
    if not docSymbals then
        docSymbals = self.userPreloadSymbolMap:get(uri)
    end
    if not docSymbals then
        docSymbals = self.luaPreloadSymbolMap:get(uri)
    end
    return docSymbals
end
function CodeSymbol.searchSymbolinWorkSpace(self, symbolStr, searchMethod, searchRange, isSearchPreload, useAlreadySearchList)
    if searchMethod == nil then
        searchMethod = Tools.SearchMode.FuzzyMatching
    end
    if searchRange == nil then
        searchRange = Tools.SearchRange.AllSymbols
    end
    if isSearchPreload == nil then
        isSearchPreload = false
    end
    if useAlreadySearchList == nil then
        useAlreadySearchList = false
    end
    if symbolStr == "" then
        return {}
    end
    local retSymbols = {}
    for ____, ____value in __TS__Iterator(self.docSymbolMap) do
        local key = ____value[1]
        local value = ____value[2]
        do
            if useAlreadySearchList then
                if self.alreadySearchList[key] then
                    goto __continue52
                end
            end
            local docSymbals = value:searchMatchSymbal(symbolStr, searchMethod, searchRange)
            retSymbols = __TS__ArrayConcat(retSymbols, docSymbals)
        end
        ::__continue52::
    end
    if isSearchPreload then
        local preS = self:searchUserPreLoadSymbols(symbolStr, searchMethod)
        retSymbols = __TS__ArrayConcat(retSymbols, preS)
        preS = self:searchLuaPreLoadSymbols(symbolStr, searchMethod)
        retSymbols = __TS__ArrayConcat(retSymbols, preS)
    end
    return retSymbols
end
function CodeSymbol.searchSymbolforGlobalDefinition(self, uri, symbolStr, searchMethod, searchRange)
    if searchMethod == nil then
        searchMethod = Tools.SearchMode.ExactlyEqual
    end
    if searchRange == nil then
        searchRange = Tools.SearchRange.GlobalSymbols
    end
    if symbolStr == "" or uri == "" then
        return {}
    end
    local retSymbols = {}
    ____exports.CodeSymbol.alreadySearchList = __TS__New(Object)
    local preS = self:recursiveSearchRequireTree(uri, symbolStr, searchMethod, searchRange)
    if preS then
        retSymbols = __TS__ArrayConcat(retSymbols, preS)
    end
    if #retSymbols == 0 then
        local preS0 = self:searchSymbolinWorkSpace(
            symbolStr,
            searchMethod,
            Tools.SearchRange.GlobalSymbols,
            CodeSettings.isAllowDefJumpPreload,
            true
        )
        if preS0 then
            retSymbols = __TS__ArrayConcat(retSymbols, preS0)
        end
    end
    return retSymbols
end
function CodeSymbol.searchSymbolforCompletion(self, uri, symbolStr, searchMethod, searchRange)
    if searchMethod == nil then
        searchMethod = Tools.SearchMode.PrefixMatch
    end
    if searchRange == nil then
        searchRange = Tools.SearchRange.AllSymbols
    end
    if symbolStr == "" or uri == "" then
        return {}
    end
    local retSymbols = {}
    ____exports.CodeSymbol.alreadySearchList = __TS__New(Object)
    local preS = self:recursiveSearchRequireTree(uri, symbolStr, searchMethod, searchRange)
    if preS then
        retSymbols = __TS__ArrayConcat(retSymbols, preS)
    end
    local preS0 = self:searchSymbolinWorkSpace(
        symbolStr,
        searchMethod,
        Tools.SearchRange.GlobalSymbols,
        true,
        true
    )
    if preS0 then
        retSymbols = __TS__ArrayConcat(retSymbols, preS0)
    end
    return retSymbols
end
function CodeSymbol.searchLuaPreLoadSymbols(self, symbolStr, searchMethod)
    if not symbolStr or symbolStr == "" then
        return {}
    end
    local retSymbols = __TS__New(Array)
    self.luaPreloadSymbolMap:forEach(function(____, element)
        local res = element:searchMatchSymbal(symbolStr, searchMethod, Tools.SearchRange.GlobalSymbols)
        if #res > 0 then
            retSymbols = __TS__ArrayConcat(retSymbols, res)
        end
    end)
    return retSymbols
end
function CodeSymbol.searchUserPreLoadSymbols(self, symbolStr, searchMethod)
    if not symbolStr or symbolStr == "" then
        return {}
    end
    local retSymbols = __TS__New(Array)
    self.userPreloadSymbolMap:forEach(function(____, element)
        local res = element:searchMatchSymbal(symbolStr, searchMethod, Tools.SearchRange.GlobalSymbols)
        if #res > 0 then
            retSymbols = __TS__ArrayConcat(retSymbols, res)
        end
    end)
    return retSymbols
end
function CodeSymbol.updateReference(self, oldDocSymbol, newDocSymbol)
    if not oldDocSymbol then
        return
    end
    newDocSymbol:setReferences(oldDocSymbol:getReferencesArray())
    local lastRequireFileArray = oldDocSymbol:getRequiresArray()
    local currentRequireFiles = newDocSymbol:getRequiresArray()
    __TS__ArrayForEach(
        lastRequireFileArray,
        function(____, lastRequireFile)
            local needDeleteReference = true
            __TS__ArrayForEach(
                currentRequireFiles,
                function(____, currentRequireFile)
                    if currentRequireFile.reqName == lastRequireFile.reqName then
                        needDeleteReference = false
                        return
                    end
                end
            )
            if needDeleteReference then
                local lastRequireFileUri = Tools:transFileNameToUri(lastRequireFile.reqName)
                if #lastRequireFileUri == 0 then
                    return
                end
                local lastRequireFileDocSymbol = self.docSymbolMap:get(lastRequireFileUri)
                local lastRequireFileReference = lastRequireFileDocSymbol:getReferencesArray()
                local index = __TS__ArrayIndexOf(
                    lastRequireFileReference,
                    newDocSymbol:getUri()
                )
                __TS__ArraySplice(lastRequireFileReference, index, 1)
            end
        end
    )
end
function CodeSymbol.createDocSymbol(self, uri, luaText)
    if uri == nil then
        return
    end
    if luaText == nil then
        luaText = Tools:getFileContent(Tools:uriToPath(uri))
    end
    local oldDocSymbol = self:getFileSymbolsFromCache(uri)
    local newDocSymbol = DocSymbolProcessor:create(luaText, uri)
    if newDocSymbol then
        Tools:AddTo_FileName_Uri_Cache(
            Tools:getPathNameAndExt(uri).name,
            uri
        )
        if newDocSymbol.docInfo.parseSucc then
            self.docSymbolMap:set(uri, newDocSymbol)
            self:updateReference(oldDocSymbol, newDocSymbol)
        else
            if not self:getFileSymbolsFromCache(uri) then
                self.docSymbolMap:set(uri, newDocSymbol)
            else
                if not self:getFileSymbolsFromCache(uri).docInfo.parseSucc then
                    self.docSymbolMap:set(uri, newDocSymbol)
                    self:updateReference(oldDocSymbol, newDocSymbol)
                end
            end
        end
    else
        return
    end
end
function CodeSymbol.createPreLoadSymbals(self, uri, ____type)
    local path = Tools:uriToPath(uri)
    local luaText = Tools:getFileContent(path)
    local docSymbol = DocSymbolProcessor:create(luaText, uri)
    if ____type == 0 then
        self.luaPreloadSymbolMap:set(uri, docSymbol)
    else
        self.userPreloadSymbolMap:set(uri, docSymbol)
    end
end
function CodeSymbol.recursiveSearchRequireTree(self, uri, symbolStr, searchMethod, searchRange, isFirstEntry)
    if searchRange == nil then
        searchRange = Tools.SearchRange.AllSymbols
    end
    if isFirstEntry == nil then
        isFirstEntry = true
    end
    if not uri or uri == "" then
        return {}
    end
    if not symbolStr or symbolStr == "" then
        return {}
    end
    local retSymbArray = __TS__New(Array)
    if isFirstEntry then
        self.deepCounter = 0
    else
        self.deepCounter = self.deepCounter + 1
        if self.deepCounter >= 50 then
            return retSymbArray
        end
    end
    if not self.docSymbolMap:has(uri) then
        Logger:log("createDocSymbals : " .. uri)
        local luaText = CodeEditor:getCode(uri)
        self:createDocSymbol(uri, luaText)
    end
    local docProcessor = self.docSymbolMap:get(uri)
    if docProcessor == nil or docProcessor.getRequiresArray == nil then
        Logger:log("get docProcessor or getRequireFiles error!")
        return {}
    end
    if self.alreadySearchList[uri] == 1 then
        return {}
    else
        self.alreadySearchList[uri] = 1
    end
    local docS = self.docSymbolMap:get(uri)
    local retSymbols = docS:searchMatchSymbal(symbolStr, searchMethod, searchRange)
    if #retSymbols > 0 then
        retSymbArray = __TS__ArrayConcat(retSymbArray, retSymbols)
    end
    local reqFiles = docProcessor:getRequiresArray()
    do
        local idx = #reqFiles - 1
        while idx >= 0 do
            local newuri = Tools:transFileNameToUri(reqFiles[idx + 1].reqName)
            if #newuri == 0 then
                return retSymbArray
            end
            local retSymbols = self:recursiveSearchRequireTree(
                newuri,
                symbolStr,
                searchMethod,
                searchRange,
                false
            )
            if retSymbols ~= nil and #retSymbols > 0 then
                retSymbArray = __TS__ArrayConcat(retSymbArray, retSymbols)
            end
            idx = idx - 1
        end
    end
    local refFiles = docProcessor:getReferencesArray()
    do
        local idx = #refFiles - 1
        while idx >= 0 do
            local newuri = refFiles[idx + 1]
            local retSymbols = self:recursiveSearchRequireTree(
                newuri,
                symbolStr,
                searchMethod,
                searchRange,
                false
            )
            if retSymbols ~= nil and #retSymbols > 0 then
                retSymbArray = __TS__ArrayConcat(retSymbArray, retSymbols)
            end
            idx = idx - 1
        end
    end
    return retSymbArray
end
CodeSymbol.docSymbolMap = __TS__New(Map)
CodeSymbol.luaPreloadSymbolMap = __TS__New(Map)
CodeSymbol.userPreloadSymbolMap = __TS__New(Map)
CodeSymbol.deepCounter = 0
return ____exports
