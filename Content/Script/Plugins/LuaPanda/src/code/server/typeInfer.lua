local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local Tools = require("Plugins.LuaPanda.src.code.server.codeTools")
local ____codeSymbol = require("Plugins.LuaPanda.src.code.server.codeSymbol")
local CodeSymbol = ____codeSymbol.CodeSymbol
local ____codeSettings = require("Plugins.LuaPanda.src.code.server.codeSettings")
local CodeSettings = ____codeSettings.CodeSettings
____exports.TypeInfer = __TS__Class()
local TypeInfer = ____exports.TypeInfer
TypeInfer.name = "TypeInfer"
function TypeInfer.prototype.____constructor(self)
end
function TypeInfer.SymbolTagForDefinitionEntry(self, symbolInfo, uri)
    local symbolName = symbolInfo.name
    self.retArray = {}
    self.startMS = Date:now()
    self:recursiveProcessSymbolTagForDefinition(uri, symbolName, {}, true)
    return self.retArray
end
function TypeInfer.SymbolTagForCompletionEntry(self, uri, searchPrefix)
    self.retArray = {}
    self.startMS = Date:now()
    self:recursiveProcessSymbolTagForCompletion(uri, searchPrefix, {}, true)
    return self.retArray
end
function TypeInfer.recursiveSearchTagForDefinition(self, element, uri, searchPrefix, tailListCache, isStripping)
    if isStripping == nil then
        isStripping = true
    end
    local findoutArr = self:searchTag(element, uri, 0) or ({})
    for ____, value in ipairs(findoutArr) do
        local uri = value.containerURI
        self:recursiveProcessSymbolTagForDefinition(uri, value.searchName, tailListCache, false)
        if value.tagType and #self.retArray == 0 then
            self:recursiveSearchTagForDefinition(
                value,
                uri,
                searchPrefix,
                tailListCache,
                isStripping
            )
        end
    end
end
function TypeInfer.recursiveSearchTagForCompletion(self, element, uri, searchPrefix, tailListCache, isStripping)
    if isStripping == nil then
        isStripping = true
    end
    local findoutArr = self:searchTag(element, uri, 1) or ({})
    if #findoutArr > self.maxSymbolCount then
        __TS__ArraySetLength(findoutArr, self.maxSymbolCount)
    end
    for ____, value in ipairs(findoutArr) do
        local uri = value.containerURI
        self:recursiveProcessSymbolTagForCompletion(uri, value.searchName, tailListCache, false)
        if value.tagType then
            self:recursiveSearchTagForCompletion(
                value,
                uri,
                searchPrefix,
                tailListCache,
                isStripping
            )
        end
    end
end
function TypeInfer.recursiveProcessSymbolTagForDefinition(self, uri, searchPrefix, tailListCache, isStripping)
    if isStripping == nil then
        isStripping = true
    end
    if isStripping then
        if CodeSettings.isOpenDebugCode == false then
            if self.startMS + 2000 < Date:now() then
                return
            end
        end
        local searchPrefixArray = Tools:splitToArrayByDot(searchPrefix)
        do
            local index = searchPrefixArray.length - 1
            while index >= 0 do
                do
                    tailListCache:push(searchPrefixArray:pop())
                    local SCHName = searchPrefixArray:join(".")
                    local findTagRetSymbArray = self:searchMethodforDef(uri, SCHName)
                    if not findTagRetSymbArray or #findTagRetSymbArray == 0 then
                        goto __continue18
                    end
                    if #findTagRetSymbArray > self.maxSymbolCount then
                        __TS__ArraySetLength(findTagRetSymbArray, self.maxSymbolCount)
                    end
                    for key in pairs(findTagRetSymbArray) do
                        local uri = findTagRetSymbArray[key].containerURI
                        self:recursiveSearchTagForDefinition(
                            findTagRetSymbArray[key],
                            uri,
                            searchPrefix,
                            tailListCache,
                            isStripping
                        )
                    end
                end
                ::__continue18::
                index = index - 1
            end
        end
    else
        local temptailCache = tailListCache:concat()
        local newName = (tostring(searchPrefix) .. ".") .. tostring(temptailCache:pop())
        local addPrefixSearchArray = self:searchMethodforComp(uri, newName, Tools.SearchMode.ExactlyEqual)
        if #addPrefixSearchArray > self.maxSymbolCount then
            __TS__ArraySetLength(addPrefixSearchArray, self.maxSymbolCount)
        end
        for ____, element in ipairs(addPrefixSearchArray) do
            if element.tagType then
                local ____self_retArray_0 = self.retArray
                ____self_retArray_0[#____self_retArray_0 + 1] = element
            else
                if temptailCache.length > 0 then
                    self:recursiveProcessSymbolTagForDefinition(uri, newName, temptailCache, false)
                else
                    local ____self_retArray_1 = self.retArray
                    ____self_retArray_1[#____self_retArray_1 + 1] = element
                end
            end
        end
    end
end
function TypeInfer.recursiveProcessSymbolTagForCompletion(self, uri, searchPrefix, tailListCache, isStripping)
    if isStripping == nil then
        isStripping = true
    end
    if isStripping then
        if CodeSettings.isOpenDebugCode == false then
            if self.startMS + 2000 < Date:now() then
                return
            end
        end
        local searchPrefixArray = Tools:splitToArrayByDot(searchPrefix)
        do
            local index = searchPrefixArray.length - 1
            while index > 0 do
                do
                    tailListCache:push(searchPrefixArray:pop())
                    local SCHName = searchPrefixArray:join(".")
                    local findTagRetSymbArray = self:searchMethodforComp(uri, SCHName)
                    if not findTagRetSymbArray or #findTagRetSymbArray == 0 then
                        goto __continue35
                    end
                    if #findTagRetSymbArray > self.maxSymbolCount then
                        __TS__ArraySetLength(findTagRetSymbArray, self.maxSymbolCount)
                    end
                    for key in pairs(findTagRetSymbArray) do
                        local uri = findTagRetSymbArray[key].containerURI
                        self:recursiveSearchTagForCompletion(
                            findTagRetSymbArray[key],
                            uri,
                            searchPrefix,
                            tailListCache,
                            isStripping
                        )
                    end
                end
                ::__continue35::
                index = index - 1
            end
        end
    else
        local temptailCache = tailListCache:concat()
        local newName = (tostring(searchPrefix) .. ".") .. tostring(temptailCache:pop())
        local addPrefixSearchArray = self:searchMethodforComp(uri, newName, Tools.SearchMode.PrefixMatch)
        for ____, element in ipairs(addPrefixSearchArray) do
            if element.tagType then
                local ____self_retArray_2 = self.retArray
                ____self_retArray_2[#____self_retArray_2 + 1] = element
            else
                if temptailCache.length > 0 then
                    self:recursiveProcessSymbolTagForCompletion(uri, newName, temptailCache, false)
                else
                    local ____self_retArray_3 = self.retArray
                    ____self_retArray_3[#____self_retArray_3 + 1] = element
                end
            end
        end
    end
end
function TypeInfer.searchMethodCommon(self, uri, SCHName, method, operation)
    if method == nil then
        method = Tools.SearchMode.ExactlyEqual
    end
    if operation == 0 then
        return self:searchMethodforDef(uri, SCHName, method) or ({})
    elseif operation == 1 then
        return self:searchMethodforComp(uri, SCHName, method) or ({})
    end
end
function TypeInfer.searchMethodforComp(self, uri, SCHName, method)
    if method == nil then
        method = Tools.SearchMode.ExactlyEqual
    end
    local findTagRetSymbArray = CodeSymbol:searchSymbolinDoc(uri, SCHName, method)
    if findTagRetSymbArray == nil or findTagRetSymbArray and #findTagRetSymbArray <= 0 then
        findTagRetSymbArray = CodeSymbol:searchSymbolforCompletion(uri, SCHName, method, Tools.SearchRange.GlobalSymbols) or ({})
    end
    return findTagRetSymbArray
end
function TypeInfer.searchMethodforDef(self, uri, SCHName, method)
    if method == nil then
        method = Tools.SearchMode.ExactlyEqual
    end
    local findTagRetSymbArray = CodeSymbol:searchSymbolinDoc(uri, SCHName, method)
    if findTagRetSymbArray == nil or findTagRetSymbArray and #findTagRetSymbArray <= 0 then
        findTagRetSymbArray = CodeSymbol:searchSymbolforGlobalDefinition(uri, SCHName, method, Tools.SearchRange.GlobalSymbols) or ({})
    end
    return findTagRetSymbArray
end
function TypeInfer.searchTag(self, element, uri, operation)
    local findoutSymbs
    if element.tagType and (element.tagReason == Tools.TagReason.UserTag or element.tagReason == Tools.TagReason.Equal) then
        findoutSymbs = self:searchUserTag(uri, element, operation)
    elseif element.tagType and element.tagReason == Tools.TagReason.MetaTable then
        findoutSymbs = self:searchMetaTable(uri, element, operation)
    elseif element.requireFile and element.requireFile.length > 0 then
        findoutSymbs = self:searchRequire(element)
    elseif element.funcRets then
        findoutSymbs = self:searchFunctionReturn(element)
    elseif element.chunk and element.chunk.returnSymbol then
        local chunkRet = element.chunk.returnSymbol
        findoutSymbs = self:searchMethodCommon(uri, chunkRet, Tools.SearchMode.ExactlyEqual, operation)
    end
    for iterator in pairs(findoutSymbs) do
        if findoutSymbs[iterator] == element then
            __TS__ArraySplice(findoutSymbs, iterator, 1)
            break
        end
    end
    return findoutSymbs
end
function TypeInfer.searchRequire(self, element)
    local beRequiredUri = Tools:transFileNameToUri(element.requireFile)
    if #beRequiredUri == 0 then
        return
    end
    local beRequiredFilesRet = CodeSymbol:getOneDocReturnSymbol(beRequiredUri)
    if beRequiredFilesRet and #beRequiredFilesRet > 0 then
        local searchReturnSymbolInBeReqFile = CodeSymbol:searchSymbolinDoc(beRequiredUri, beRequiredFilesRet, Tools.SearchMode.ExactlyEqual)
        return searchReturnSymbolInBeReqFile
    end
    return {}
end
function TypeInfer.searchFunctionReturn(self, element)
    local uri = element.containerURI
    local searchName = element.funcRets.name
    local returnFuncList = CodeSymbol:searchSymbolinDoc(uri, searchName, Tools.SearchMode.ExactlyEqual)
    if returnFuncList == nil or returnFuncList and #returnFuncList <= 0 then
        returnFuncList = CodeSymbol:searchSymbolforCompletion(uri, searchName, Tools.SearchMode.ExactlyEqual)
    end
    local retrunSymbol = __TS__New(Array)
    if returnFuncList and #returnFuncList == 0 then
        local tempRetArray = self.retArray
        self.retArray = {}
        self:recursiveProcessSymbolTagForDefinition(uri, searchName, {})
        if #self.retArray > 0 then
            returnFuncList = self.retArray
            self.retArray = tempRetArray
        end
    end
    if returnFuncList and #returnFuncList > 0 then
        local retFuncSymbol = returnFuncList[1]
        local chunks = CodeSymbol:getCretainDocChunkDic(retFuncSymbol.containerURI)
        if chunks[retFuncSymbol.searchName] then
            local chunkRetSymbolName = chunks[retFuncSymbol.searchName].returnSymbol
            if retFuncSymbol.tagType ~= nil and retFuncSymbol.tagReason == Tools.TagReason.UserTag then
                chunkRetSymbolName = retFuncSymbol.tagType
            end
            retrunSymbol = CodeSymbol:searchSymbolinDoc(retFuncSymbol.containerURI, chunkRetSymbolName, Tools.SearchMode.ExactlyEqual)
            if retrunSymbol == nil or retrunSymbol and #retrunSymbol <= 0 then
                retrunSymbol = CodeSymbol:searchSymbolforCompletion(retFuncSymbol.containerURI, chunkRetSymbolName, Tools.SearchMode.ExactlyEqual)
            end
            return retrunSymbol
        end
    end
end
function TypeInfer.searchUserTag(self, uri, element, operation)
    local tag_type = element.tagType
    if tag_type then
        return self:searchMethodCommon(uri, tag_type, Tools.SearchMode.ExactlyEqual, operation)
    else
        return {}
    end
end
function TypeInfer.searchMetaTable(self, uri, element, operation)
    local tag_type = tostring(element.tagType) .. ".__index"
    if tag_type then
        local index_symbol = self:searchMethodCommon(uri, tag_type, Tools.SearchMode.ExactlyEqual, operation)
        for ____, element in ipairs(index_symbol) do
            do
                if not element.tagType then
                    goto __continue79
                end
                local searchName = element.tagType
                local tagRes = self:searchMethodCommon(element.containerURI, searchName, Tools.SearchMode.ExactlyEqual, operation)
                if tagRes then
                    return tagRes
                end
            end
            ::__continue79::
        end
    end
    return {}
end
TypeInfer.retArray = {}
TypeInfer.maxSymbolCount = 1
return ____exports
