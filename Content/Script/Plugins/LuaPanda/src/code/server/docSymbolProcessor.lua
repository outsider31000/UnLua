local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat
local __TS__ArrayJoin = ____lualib.__TS__ArrayJoin
local ____exports = {}
local luaparse = require("Plugins.LuaPanda.src.code.server.luaparse")
local Tools = require("Plugins.LuaPanda.src.code.server.codeTools")
local ____codeLogManager = require("Plugins.LuaPanda.src.code.server.codeLogManager")
local Logger = ____codeLogManager.Logger
local ____codeSymbol = require("Plugins.LuaPanda.src.code.server.codeSymbol")
local CodeSymbol = ____codeSymbol.CodeSymbol
local ____vscode_2Dlanguageserver = require("Plugins.LuaPanda.src.code.server.vscode-languageserver")
local Location = ____vscode_2Dlanguageserver.Location
local Range = ____vscode_2Dlanguageserver.Range
local Position = ____vscode_2Dlanguageserver.Position
local SymbolKind = ____vscode_2Dlanguageserver.SymbolKind
local ____trieTree = require("Plugins.LuaPanda.src.code.server.trieTree")
local trieTree = ____trieTree.trieTree
local ____util = require("Plugins.LuaPanda.src.code.server.util")
local isArray = ____util.isArray
local travelMode = travelMode or ({})
travelMode.BUILD = 0
travelMode[travelMode.BUILD] = "BUILD"
travelMode.GET_DEFINE = 1
travelMode[travelMode.GET_DEFINE] = "GET_DEFINE"
travelMode.FIND_REFS = 2
travelMode[travelMode.FIND_REFS] = "FIND_REFS"
____exports.DocSymbolProcessor = __TS__Class()
local DocSymbolProcessor = ____exports.DocSymbolProcessor
DocSymbolProcessor.name = "DocSymbolProcessor"
function DocSymbolProcessor.prototype.____constructor(self)
end
function DocSymbolProcessor.create(self, luaText, uri)
    local instance = __TS__New(____exports.DocSymbolProcessor)
    local path = Tools:uriToPath(uri)
    do
        local function ____catch(____error)
            instance.docInfo = __TS__New(
                Tools.docInformation,
                __TS__New(Object),
                uri,
                path
            )
            ____exports.DocSymbolProcessor.tempSaveInstance = instance
            do
                pcall(function()
                    luaparse:parse(luaText, {locations = true, scope = true, onCreateNode = instance.onCreateNode})
                end)
            end
            instance.docInfo.parseSucc = false
            return true, instance
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            local AST = luaparse:parse(luaText, {locations = true, scope = true, comments = true})
            instance.docInfo = __TS__New(Tools.docInformation, AST, uri, path)
            instance:buildDocDefineSymbols()
            instance.docInfo.parseSucc = true
            return true, instance
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end
function DocSymbolProcessor.prototype.getUri(self)
    return self.docInfo.docUri
end
function DocSymbolProcessor.prototype.getAllSymbolsDic(self)
    return self.docInfo.defineSymbols.allSymbols
end
function DocSymbolProcessor.prototype.getAllSymbolsTrie(self)
    return self.docInfo.defineSymbols.allSymbolsTrie
end
function DocSymbolProcessor.prototype.getGlobalSymbolsDic(self)
    return self.docInfo.defineSymbols.globalSymbols
end
function DocSymbolProcessor.prototype.getLocalSymbolsDic(self)
    return self.docInfo.defineSymbols.localSymbols
end
function DocSymbolProcessor.prototype.getChunksDic(self)
    return self.docInfo.defineSymbols.chunks
end
function DocSymbolProcessor.prototype.getAllSymbolsArray(self)
    return self.docInfo.defineSymbols.allSymbolsArray
end
function DocSymbolProcessor.prototype.getGlobalSymbolsArray(self)
    return self.docInfo.defineSymbols.globalSymbolsArray
end
function DocSymbolProcessor.prototype.getGlobalSymbolsTrie(self)
    return self.docInfo.defineSymbols.globalSymbolsTrie
end
function DocSymbolProcessor.prototype.getLocalSymbolsArray(self)
    return self.docInfo.defineSymbols.localSymbolsArray
end
function DocSymbolProcessor.prototype.getLocalSymbolsTrie(self)
    return self.docInfo.defineSymbols.localSymbolsTrie
end
function DocSymbolProcessor.prototype.getChunksArray(self)
    return self.docInfo.defineSymbols.chunksArray
end
function DocSymbolProcessor.prototype.getFileReturnArray(self)
    local chunks = self.docInfo.defineSymbols.chunks
    return chunks[self.docInfo.docPath].returnSymbol
end
function DocSymbolProcessor.prototype.getRequiresArray(self)
    return self.docInfo.requires
end
function DocSymbolProcessor.prototype.getReferencesArray(self)
    return self.docInfo.references
end
function DocSymbolProcessor.prototype.setReferences(self, references)
    local ____references_0 = references
    self.docInfo.references = ____references_0
    return ____references_0
end
function DocSymbolProcessor.prototype.buildSymbolTrie(self)
    local all = self:getAllSymbolsArray()
    self.docInfo.defineSymbols.allSymbolsTrie = trieTree:createSymbolTree(all)
    local global = self:getGlobalSymbolsArray()
    self.docInfo.defineSymbols.globalSymbolsTrie = trieTree:createSymbolTree(global)
    local ____local = self:getLocalSymbolsArray()
    self.docInfo.defineSymbols.localSymbolsTrie = trieTree:createSymbolTree(____local)
end
function DocSymbolProcessor.prototype.buildDocDefineSymbols(self)
    local deepLayer = __TS__New(Array)
    self.docCommentType = __TS__New(Array)
    self.callFunctionRecoder = __TS__New(Array)
    self:traversalAST(self.docInfo.docAST, travelMode.BUILD, deepLayer)
    self:processRequireArrayPath()
    self:buildSymbolTag()
    self:buildSymbolReturns()
    self:buildSymbolTrie()
end
function DocSymbolProcessor.prototype.searchDocSymbolfromPosition(self, pos)
    self.searchPosition = pos
    local container = __TS__New(Array)
    self.posSearchRet = __TS__New(Tools.searchRet)
    self:traversalAST(self.docInfo.docAST, travelMode.GET_DEFINE, container)
    return {sybinfo = self.posSearchRet.retSymbol, container = container}
end
function DocSymbolProcessor.prototype.searchDocSymbolReference(self, info)
    self.searchInfo = info
    self.refsLink = __TS__New(Array)
    self:traversalAST(
        self.docInfo.docAST,
        travelMode.FIND_REFS,
        __TS__New(Array)
    )
    return self.refsLink
end
function DocSymbolProcessor.prototype.searchDocRequireFileNameFromPosition(self, pos)
    local reqFiles = self:getRequiresArray()
    do
        local index = 0
        while index < #reqFiles do
            local element = reqFiles[index + 1]
            local res = self:isInASTLoc(element.loc, pos)
            if res then
                return element.reqName
            end
            index = index + 1
        end
    end
end
function DocSymbolProcessor.prototype.searchMatchSymbal(self, symbalName, matchMode, searchRange)
    searchRange = searchRange or Tools.SearchRange.AllSymbols
    local retSymbols = {}
    local SymbolArrayForSearch
    if matchMode == Tools.SearchMode.ExactlyEqual then
        if searchRange == Tools.SearchRange.AllSymbols then
            SymbolArrayForSearch = self:getAllSymbolsDic()
        elseif searchRange == Tools.SearchRange.GlobalSymbols then
            SymbolArrayForSearch = self:getGlobalSymbolsDic()
        elseif searchRange == Tools.SearchRange.LocalSymbols then
            SymbolArrayForSearch = self:getLocalSymbolsDic()
        end
        local tgtSymbol = SymbolArrayForSearch[symbalName]
        if tgtSymbol then
            if __TS__ArrayIsArray(tgtSymbol) then
                retSymbols = tgtSymbol
            else
                retSymbols[#retSymbols + 1] = tgtSymbol
            end
        end
    elseif matchMode == Tools.SearchMode.PrefixMatch then
        local root
        if searchRange == Tools.SearchRange.AllSymbols then
            root = self:getAllSymbolsTrie()
        elseif searchRange == Tools.SearchRange.GlobalSymbols then
            root = self:getGlobalSymbolsTrie()
        elseif searchRange == Tools.SearchRange.LocalSymbols then
            root = self:getLocalSymbolsTrie()
        end
        local trieRes = trieTree:searchOnTrieTreeWithoutTableChildren(root, symbalName)
        if isArray(nil, trieRes) then
            retSymbols = trieRes
        end
    elseif matchMode == Tools.SearchMode.FuzzyMatching then
        if searchRange == Tools.SearchRange.AllSymbols then
            SymbolArrayForSearch = self:getAllSymbolsArray()
        elseif searchRange == Tools.SearchRange.GlobalSymbols then
            SymbolArrayForSearch = self:getGlobalSymbolsArray()
        elseif searchRange == Tools.SearchRange.LocalSymbols then
            SymbolArrayForSearch = self:getLocalSymbolsArray()
        end
        for idx in pairs(SymbolArrayForSearch) do
            local sym = SymbolArrayForSearch[idx]
            local searchName = sym.name
            if searchName then
                local reg = __TS__New(RegExp, symbalName, "i")
                local hit = searchName:match(reg)
                if hit then
                    retSymbols[#retSymbols + 1] = sym
                end
            end
        end
    end
    return retSymbols
end
function DocSymbolProcessor.prototype.isInLocation(self, loc1, loc2)
    if loc1.range.start.line <= loc2.line and loc1.range["end"].line >= loc2.line then
        if loc1.range.start.line == loc2.line then
            local character = loc1.range.start.character or loc1.range.start.column
            if character > loc2.character then
                return false
            end
        end
        if loc1.range["end"].line == loc2.line then
            local character = loc1.range["end"].character or loc1.range["end"].column
            if character < loc2.character then
                return false
            end
        end
        return true
    end
    return false
end
function DocSymbolProcessor.prototype.isInASTLoc(self, loc1, loc2)
    if loc1.start.line <= loc2.line and loc1["end"].line >= loc2.line then
        if loc1.start.line == loc2.line then
            local character = loc1.start.character or loc1.start.column
            if character > loc2.character then
                return false
            end
        end
        if loc1["end"].line == loc2.line then
            local character = loc1["end"].character or loc1["end"].column
            if character < loc2.character then
                return false
            end
        end
        return true
    end
    return false
end
function DocSymbolProcessor.prototype.createSymbolInfo(self, name, searchName, originalName, kind, location, isLocal, containerName, containerList, funcParamArray, tagType, reason)
    if searchName:match(":") then
        searchName = __TS__StringReplace(searchName, nil, ".")
    end
    return {
        name = name,
        searchName = searchName,
        originalName = originalName,
        kind = kind,
        location = location,
        isLocal = isLocal,
        containerURI = self.docInfo.docUri,
        containerPath = self.docInfo.docPath,
        containerName = containerName,
        containerList = containerList,
        funcParamArray = funcParamArray,
        tagType = tagType,
        tagReason = reason
    }
end
function DocSymbolProcessor.prototype.checkIsSymbolExist(self, name)
    if self:getAllSymbolsDic()[name] ~= nil then
        return true
    end
    return false
end
function DocSymbolProcessor.prototype.pushToAllList(self, symbol)
    if self.docInfo.defineSymbols.allSymbols[symbol.searchName] then
        local travlSymbol = self.docInfo.defineSymbols.allSymbols[symbol.searchName]
        if __TS__ArrayIsArray(travlSymbol) then
            travlSymbol[#travlSymbol + 1] = symbol
        else
            local newArray = __TS__New(Array)
            newArray[#newArray + 1] = travlSymbol
            newArray[#newArray + 1] = symbol
            self.docInfo.defineSymbols.allSymbols[symbol.searchName] = newArray
        end
    else
        self.docInfo.defineSymbols.allSymbols[symbol.searchName] = symbol
    end
    self.docInfo.defineSymbols.allSymbolsArray:push(symbol)
end
function DocSymbolProcessor.prototype.pushToLocalList(self, symbol)
    if self.docInfo.defineSymbols.localSymbols[symbol.searchName] then
        local travlSymbol = self.docInfo.defineSymbols.localSymbols[symbol.searchName]
        if __TS__ArrayIsArray(travlSymbol) then
            travlSymbol[#travlSymbol + 1] = symbol
        else
            local newArray = __TS__New(Array)
            newArray[#newArray + 1] = travlSymbol
            newArray[#newArray + 1] = symbol
            self.docInfo.defineSymbols.localSymbols[symbol.searchName] = newArray
        end
    else
        self.docInfo.defineSymbols.localSymbols[symbol.searchName] = symbol
    end
    self.docInfo.defineSymbols.localSymbolsArray:push(symbol)
end
function DocSymbolProcessor.prototype.pushToGlobalList(self, symbol)
    if self.docInfo.defineSymbols.globalSymbols[symbol.searchName] then
        local travlSymbol = self.docInfo.defineSymbols.globalSymbols[symbol.searchName]
        if __TS__ArrayIsArray(travlSymbol) then
            travlSymbol[#travlSymbol + 1] = symbol
        else
            local newArray = __TS__New(Array)
            newArray[#newArray + 1] = travlSymbol
            newArray[#newArray + 1] = symbol
            self.docInfo.defineSymbols.globalSymbols[symbol.searchName] = newArray
        end
    else
        self.docInfo.defineSymbols.globalSymbols[symbol.searchName] = symbol
    end
    self.docInfo.defineSymbols.globalSymbolsArray:push(symbol)
end
function DocSymbolProcessor.prototype.pushToAutoList(self, symbol)
    if symbol.isLocal then
        self:pushToLocalList(symbol)
    else
        self:pushToGlobalList(symbol)
    end
    self:pushToAllList(symbol)
end
function DocSymbolProcessor.prototype.pushToChunkList(self, name, chunk)
    if name:match(":") then
        if not name:match(__TS__New(RegExp, nil)) then
            name = name:replace(nil, ".")
        end
    end
    if self.docInfo.defineSymbols.chunks[name] then
        local travlSymbol = self.docInfo.defineSymbols.chunks[name]
        if __TS__ArrayIsArray(travlSymbol) then
            travlSymbol[#travlSymbol + 1] = chunk
        else
            local newArray = __TS__New(Array)
            newArray[#newArray + 1] = travlSymbol
            newArray[#newArray + 1] = chunk
            self.docInfo.defineSymbols.chunks[name] = newArray
        end
    else
        self.docInfo.defineSymbols.chunks[name] = chunk
    end
    self.docInfo.defineSymbols.chunksArray:push(chunk)
end
function DocSymbolProcessor.prototype.pushToCommentList(self, cmt)
    self.docCommentType:push(cmt)
end
function DocSymbolProcessor.prototype.recordFuncCall(self, cmt)
    self.callFunctionRecoder:push(cmt)
end
function DocSymbolProcessor.prototype.traversalAST(self, node, ____type, deepLayer, prefix, isBody)
    if __TS__ArrayIsArray(node) == true then
        local ASTArray = Array.prototype.slice(node)
        do
            local idx = 0
            local len = #ASTArray
            while idx < len do
                self:traversalAST(
                    ASTArray[idx + 1],
                    ____type,
                    deepLayer,
                    prefix,
                    isBody
                )
                if self.posSearchRet and self.posSearchRet.isFindout then
                    return
                end
                idx = idx + 1
            end
        end
    else
        local nodeType = node.type
        repeat
            local ____switch99 = nodeType
            local ____cond99 = ____switch99 == "Chunk"
            if ____cond99 then
                self:processChunk(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "LocalStatement"
            if ____cond99 then
                self:LocalStatement(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "FunctionDeclaration"
            if ____cond99 then
                self:processFunction(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "AssignmentStatement"
            if ____cond99 then
                self:processAssignment(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "CallExpression"
            if ____cond99 then
                self:processCallExpression(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "StringCallExpression"
            if ____cond99 then
                self:processStringCallExpression(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "CallStatement"
            if ____cond99 then
                self:processCallStatement(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "WhileStatement"
            if ____cond99 then
                self:processWhileStatement(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "RepeatStatement"
            if ____cond99 then
                self:processRepeatStatement(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "IfStatement"
            if ____cond99 then
                self:processIfStatement(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "ReturnStatement"
            if ____cond99 then
                self:processReturnStatement(
                    node,
                    ____type,
                    deepLayer,
                    prefix,
                    isBody
                )
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "ForNumericStatement"
            if ____cond99 then
                self:processForNumericStatement(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "ForGenericStatement"
            if ____cond99 then
                self:processForGenericStatement(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "BinaryExpression"
            if ____cond99 then
                self:processBinaryExpression(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "UnaryExpression"
            if ____cond99 then
                self:processUnaryExpression(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "MemberExpression"
            if ____cond99 then
                self:processMemberExpression(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "IndexExpression"
            if ____cond99 then
                self:processIndexExpression(node, ____type, deepLayer, prefix)
                break
            end
            ____cond99 = ____cond99 or ____switch99 == "Identifier"
            if ____cond99 then
                self:processIdentifier(node, ____type, deepLayer, prefix)
                break
            end
        until true
    end
    if self.posSearchRet and self.posSearchRet.isFindout then
        return
    end
end
function DocSymbolProcessor.prototype.onCreateNode(self, node)
    local deepLayer = __TS__New(Array)
    if node.type == "CallExpression" or node.type == "StringCallExpression" then
        ____exports.DocSymbolProcessor.tempSaveInstance:traversalAST(node, travelMode.BUILD, deepLayer)
    end
    if node.type == "LocalStatement" then
        ____exports.DocSymbolProcessor.tempSaveInstance:traversalAST(node, travelMode.BUILD, deepLayer)
    end
    if node.type == "FunctionDeclaration" then
        ____exports.DocSymbolProcessor.tempSaveInstance:traversalAST(node, travelMode.BUILD, deepLayer)
    end
end
function DocSymbolProcessor.prototype.processComments(self, commentArray)
    do
        local idx = 0
        local len = commentArray.length
        while idx < len do
            local comValue = commentArray[idx].value
            local strArr = comValue:split(" ")
            do
                local j = 0
                while j < strArr.length do
                    local element = strArr[j]
                    if element:match("-@type") or element:match("-@return") or element:match("-@param") then
                        local commentTypeIdx = j + 1
                        do
                            local k = commentTypeIdx
                            while k < strArr.length do
                                if strArr[k] ~= "" then
                                    commentTypeIdx = k
                                    break
                                end
                                k = k + 1
                            end
                        end
                        if element:match("-@param") then
                            local functionParameter = strArr[commentTypeIdx]
                            local newType = strArr[commentTypeIdx + 1]
                            local info = {reason = Tools.TagReason.UserTag, functionParameter = functionParameter, newType = newType, location = commentArray[idx].loc}
                            self:pushToCommentList(info)
                        else
                            local multiTypeArray = strArr[commentTypeIdx]:split(",")
                            for ____, multiElement in __TS__Iterator(multiTypeArray) do
                                local info = {reason = Tools.TagReason.UserTag, newType = multiElement, location = commentArray[idx].loc}
                                self:pushToCommentList(info)
                            end
                        end
                        break
                    end
                    j = j + 1
                end
            end
            idx = idx + 1
        end
    end
end
function DocSymbolProcessor.prototype.recordReference(self, fileUri, requireName)
    local requireFileUri = Tools:transFileNameToUri(requireName)
    if requireFileUri == "" then
        return
    end
    if CodeSymbol.docSymbolMap:has(requireFileUri) == false then
        CodeSymbol:createOneDocSymbols(requireFileUri)
    end
    local references = CodeSymbol.docSymbolMap:get(requireFileUri):getReferencesArray()
    if __TS__ArrayIncludes(references, fileUri) then
        return
    end
    references[#references + 1] = fileUri
end
function DocSymbolProcessor.prototype.createRetBase(self, baseName, baseLocal, identifer)
    local retBase = {name = baseName, isLocal = baseLocal, identiferStr = identifer}
    local ret = {isFindout = false, baseinfo = retBase}
    return ret
end
function DocSymbolProcessor.prototype.createRetSymbol(self, sybName, sybisLocal, sybLocation, sybPath)
    sybPath = sybPath or self.docInfo.docPath
    local retSymbol = {name = sybName, isLocal = sybisLocal, location = sybLocation, containerURI = sybPath}
    local ret = {isFindout = true, retSymbol = retSymbol}
    return ret
end
function DocSymbolProcessor.prototype.setTagTypeToSymbolInfo(self, symbol, tagType, tagReason)
    if symbol.tagReason ~= nil and symbol.tagReason == Tools.TagReason.UserTag then
        return false
    end
    symbol.tagType = tagType
    symbol.tagReason = tagReason
    return true
end
function DocSymbolProcessor.prototype.buildSymbolTag(self)
    local tagArray = self.docCommentType
    for key in pairs(tagArray) do
        local tagInfo = tagArray[key]
        local loc = tagInfo.location
        local reason = tagInfo.reason
        local functionParam = tagInfo.functionParameter
        local paramRealLine = 0
        do
            local index = 0
            while index < self:getAllSymbolsArray().length do
                local elm = self:getAllSymbolsArray()[index]
                if functionParam then
                    if tagInfo.newType == "Type" then
                        break
                    end
                    if reason == Tools.TagReason.UserTag and elm.location.range.start.line + 1 > loc["end"].line then
                        if paramRealLine == 0 then
                            paramRealLine = elm.location.range.start.line
                        elseif elm.location.range.start.line > paramRealLine then
                            break
                        end
                        if functionParam == elm.searchName then
                            self:setTagTypeToSymbolInfo(elm, tagInfo.newType, tagInfo.reason)
                            break
                        end
                    end
                else
                    if reason == Tools.TagReason.UserTag and elm.location.range.start.line + 1 == loc["end"].line then
                        local mulitTypeIdx = 0
                        while self:getAllSymbolsArray()[mulitTypeIdx + index].location.range.start.line + 1 == loc["end"].line do
                            local elm = self:getAllSymbolsArray()[mulitTypeIdx + index]
                            local res = self:setTagTypeToSymbolInfo(elm, tagInfo.newType, tagInfo.reason)
                            if res then
                                break
                            else
                                mulitTypeIdx = mulitTypeIdx + 1
                            end
                        end
                        break
                    end
                    if reason == Tools.TagReason.UserTag and elm.location.range.start.line == loc["end"].line then
                        self:setTagTypeToSymbolInfo(elm, tagInfo.newType, tagInfo.reason)
                        break
                    end
                    if reason == Tools.TagReason.Equal and elm.location.range.start.line + 1 == loc["end"].line then
                        if tagInfo.name and tagInfo.name == elm.searchName then
                            self:setTagTypeToSymbolInfo(elm, tagInfo.newType, tagInfo.reason)
                            break
                        end
                    end
                    if reason == Tools.TagReason.MetaTable and elm.searchName == tagInfo.oldType then
                        self:setTagTypeToSymbolInfo(elm, tagInfo.newType, tagInfo.reason)
                        break
                    end
                end
                index = index + 1
            end
        end
    end
end
function DocSymbolProcessor.prototype.processRequireArrayPath(self)
    local reqArray = self:getRequiresArray()
    for ____, reqPath in ipairs(reqArray) do
        reqPath.reqName = __TS__StringReplace(reqPath.reqName, nil, "/")
    end
end
function DocSymbolProcessor.prototype.buildSymbolReturns(self)
    local reqArray = self:getRequiresArray()
    for ____, element in ipairs(reqArray) do
        local loc = element.loc
        local reqName = element.reqName
        do
            local index = 0
            while index < self:getAllSymbolsArray().length do
                local elm = self:getAllSymbolsArray()[index]
                local aling = elm.location.range.start.line + 1
                local bling = loc.start.line
                if aling == bling then
                    elm.requireFile = reqName
                end
                index = index + 1
            end
        end
    end
    for ____, element in __TS__Iterator(self.callFunctionRecoder) do
        local loc = element.loc
        local funcName = element.functionName
        do
            local index = 0
            while index < self:getAllSymbolsArray().length do
                local elm = self:getAllSymbolsArray()[index]
                local aling = elm.location.range.start.line + 1
                local bling = loc.start.line
                if aling == bling then
                    elm.funcRets = funcName
                end
                index = index + 1
            end
        end
    end
end
function DocSymbolProcessor.prototype.baseProcess(self, baseNode)
    if baseNode.type == "MemberExpression" then
        local ret = self:baseProcess(baseNode.base)
        if not ret then
            return
        end
        local str = ret.name
        local isLocal = ret.isLocal
        local retStr = str + baseNode.indexer + baseNode.identifier.name
        local retObj = {name = retStr, isLocal = isLocal, origion = baseNode.identifier.name}
        return retObj
    elseif baseNode.type == "Identifier" then
        return {name = baseNode.name, isLocal = baseNode.isLocal}
    elseif baseNode.type == "StringLiteral" then
        return {name = baseNode.value, isLocal = false}
    elseif baseNode.type == "NumericLiteral" then
        return {name = baseNode.value, isLocal = false}
    elseif baseNode.type == "IndexExpression" then
        local ret = self:baseProcess(baseNode.base)
        local str = ret.name
        local isLocal = ret.isLocal
        local retObj
        if baseNode.index.type == "NumericLiteral" then
            local retStr = ((tostring(str) .. "[") .. tostring(baseNode.index.raw)) .. "]"
            retObj = {name = retStr, isLocal = isLocal, origion = baseNode.index.raw}
        end
        if baseNode.index.type == "Identifier" then
            local retStr = ((tostring(str) .. "[") .. tostring(baseNode.index.name)) .. "]"
            retObj = {name = retStr, isLocal = isLocal, origion = baseNode.index.name}
        end
        if baseNode.index.type == "MemberExpression" then
            local ret = self:baseProcess(baseNode.index)
            local retStr = ((tostring(str) .. "[") .. tostring(ret.name)) .. "]"
            retObj = {name = retStr, isLocal = isLocal, origion = ret.name}
        end
        if baseNode.index.type == "IndexExpression" then
            local ret = self:baseProcess(baseNode.index)
            local retStr = ((tostring(str) .. "[") .. tostring(ret.name)) .. "]"
            retObj = {name = retStr, isLocal = isLocal, origion = ret.name}
        end
        if baseNode.index.type == "StringLiteral" then
            local ret = self:baseProcess(baseNode.index)
            local retStr = ((tostring(str) .. "[\"") .. tostring(ret.name)) .. "\"]"
            retObj = {name = retStr, isLocal = isLocal, origion = ret.name}
        end
        if baseNode.index.type == "BinaryExpression" then
            local retL = self:baseProcess(baseNode.index.left)
            local retR = self:baseProcess(baseNode.index.right)
            local retStr = ((((tostring(str) .. "[") .. tostring(retL.name)) .. tostring(baseNode.index.operator)) .. tostring(retR.name)) .. "]"
            retObj = {name = retStr, isLocal = isLocal, origion = ret.name}
        end
        return retObj
    end
    return {name = "", isLocal = false}
end
function DocSymbolProcessor.prototype.MemberExpressionFind(self, baseNode)
    if baseNode == nil then
        Logger:log("baseNode == null")
    end
    if baseNode.type == "MemberExpression" then
        local ret = self:MemberExpressionFind(baseNode.base)
        if ret == nil or ret.isInStat == nil then
            ret.isInStat = 0
        end
        local nodeLoc = Location:create(self.docInfo.docUri, baseNode.identifier.loc)
        local isIn = self:isInLocation(nodeLoc, self.searchPosition)
        if isIn == true and ret.isInStat == 0 then
            ret.isInStat = 1
        end
        if isIn == false and ret.isInStat == 1 then
            return ret
        end
        local str = ret.name
        local isLocal = ret.isLocal
        local retStr = str + baseNode.indexer + baseNode.identifier.name
        return {name = retStr, isLocal = isLocal, isInStat = ret.isInStat}
    elseif baseNode.type == "IndexExpression" then
        local ret = self:MemberExpressionFind(baseNode.base)
        if ret == nil or ret.isInStat == nil then
            ret.isInStat = 0
        end
        local nodeLoc = Location:create(self.docInfo.docUri, baseNode.index.loc)
        local isIn = self:isInLocation(nodeLoc, self.searchPosition)
        if isIn == true and ret.isInStat == 0 then
            ret.isInStat = 1
        end
        if isIn == false and ret.isInStat == 1 then
            return ret
        end
        local str = ret.name
        local isLocal = ret.isLocal
        local retStr
        if baseNode.index.value then
            retStr = (tostring(str) .. ".") .. tostring(baseNode.index.value)
        end
        if baseNode.index.name then
            retStr = self:MemberExpressionFind(baseNode.index).name
        end
        return {name = retStr, isLocal = isLocal, isInStat = ret.isInStat}
    elseif baseNode.type == "CallExpression" then
        self:processCallExpression(baseNode, travelMode.GET_DEFINE, nil, "call EXp")
        if self.posSearchRet and self.posSearchRet.isFindout then
            return {name = self.posSearchRet.retSymbol.name, isLocal = self.posSearchRet.retSymbol.isLocal, isInStat = 1}
        else
            return {name = "", isLocal = true, isInStat = 0}
        end
    elseif baseNode.type == "StringCallExpression" then
        self:processStringCallExpression(baseNode, travelMode.GET_DEFINE, nil, "call EXp")
        if self.posSearchRet and self.posSearchRet.isFindout then
            return {name = self.posSearchRet.retSymbol.name, isLocal = self.posSearchRet.retSymbol.isLocal, isInStat = 1}
        else
            return {name = "", isLocal = true, isInStat = 0}
        end
    elseif baseNode.type == "Identifier" then
        local nodeLoc = Location:create(self.docInfo.docUri, baseNode.loc)
        local isIn = self:isInLocation(nodeLoc, self.searchPosition)
        if isIn == true then
            return {name = baseNode.name, isLocal = baseNode.isLocal, isInStat = 1}
        else
            return {name = baseNode.name, isLocal = baseNode.isLocal, isInStat = 0}
        end
    end
end
function DocSymbolProcessor.prototype.processChunk(self, node, ____type, deepLayer, prefix)
    if ____type == travelMode.BUILD then
        self:processComments(node.comments)
        local newChunk = __TS__New(Tools.chunkClass, self.docInfo.docPath, self.docInfo.docAST.loc)
        self:pushToChunkList(self.docInfo.docPath, newChunk)
        deepLayer:push(newChunk)
        self:traversalAST(
            node.body,
            ____type,
            deepLayer,
            prefix,
            true
        )
    end
    if ____type == travelMode.GET_DEFINE then
        local newChunk = __TS__New(Tools.chunkClass, self.docInfo.docPath, self.docInfo.docAST.loc)
        deepLayer:push(newChunk)
        self:traversalAST(node.body, ____type, deepLayer, prefix)
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
    if ____type == travelMode.FIND_REFS then
        self:traversalAST(node.body, ____type, deepLayer, prefix)
    end
end
function DocSymbolProcessor.prototype.processFunction(self, node, ____type, deepLayer, prefix)
    local searchRes = false
    local paraRecoder = __TS__New(Array)
    if ____type == travelMode.GET_DEFINE then
        local nodeLoc = Location:create(self.docInfo.docUri, node.loc)
        searchRes = self:isInLocation(nodeLoc, self.searchPosition)
        if searchRes == false then
            self.posSearchRet = __TS__New(Tools.searchRet)
        end
    end
    local searchHitPara = false
    local searchHitParaIdx = 0
    local paramArray = __TS__New(Array)
    do
        local idx = 0
        while idx < node.parameters.length do
            do
                local paraNode = node.parameters[idx]
                if paraNode.type == "VarargLiteral" then
                    paramArray[#paramArray + 1] = paraNode.value
                else
                    paramArray[#paramArray + 1] = paraNode.name
                end
                if ____type == travelMode.GET_DEFINE and searchRes == true and searchHitPara == false then
                    local nodeLoc1 = Location:create(self.docInfo.docUri, node.parameters[idx].loc)
                    searchHitPara = self:isInLocation(nodeLoc1, self.searchPosition)
                    if searchHitPara == true then
                        searchHitParaIdx = idx
                        goto __continue196
                    end
                end
                if ____type == travelMode.BUILD then
                    local loc = paraNode.loc
                    local name
                    if paraNode.type == "VarargLiteral" then
                        name = paraNode.value
                    else
                        name = paraNode.name
                    end
                    local isLocal = true
                    local loct = Location:create(
                        self.docInfo.docUri,
                        Range:create(
                            Position:create(loc.start.line - 1, loc.start.column),
                            Position:create(loc["end"].line - 1, loc["end"].column)
                        )
                    )
                    local smbInfo = self:createSymbolInfo(
                        name,
                        name,
                        name,
                        SymbolKind.Variable,
                        loct,
                        isLocal,
                        prefix,
                        __TS__ArrayConcat(deepLayer)
                    )
                    paraRecoder[#paraRecoder + 1] = smbInfo
                end
            end
            ::__continue196::
            idx = idx + 1
        end
    end
    local paramString = ("(" .. __TS__ArrayJoin(paramArray, ", ")) .. ")"
    local newChunk
    local functionName
    local functionSearchName = "NONAME"
    if node.identifier and node.identifier.type == "Identifier" then
        local loc = node.identifier.loc
        functionSearchName = node.identifier.name
        functionName = ("function " .. functionSearchName) .. paramString
        if ____type == travelMode.GET_DEFINE and searchRes == true then
            local nodeLoc1 = Location:create(self.docInfo.docUri, loc)
            local res1 = self:isInLocation(nodeLoc1, self.searchPosition)
            if res1 == true then
                self.posSearchRet = self:createRetSymbol(node.identifier.name, node.identifier.isLocal)
                return
            end
        end
        if ____type == travelMode.FIND_REFS then
            if functionSearchName == self.searchInfo.originalName then
                local loc = node.identifier.loc
                local nodeLoc1 = Location:create(self.docInfo.docUri, loc)
                self.refsLink:push(nodeLoc1)
            end
        end
        if ____type == travelMode.BUILD then
            local loct = Location:create(
                self.docInfo.docUri,
                Range:create(
                    Position:create(loc.start.line - 1, loc.start.column),
                    Position:create(loc["end"].line - 1, loc["end"].column)
                )
            )
            local pushObj = self:createSymbolInfo(
                functionSearchName,
                functionSearchName,
                functionSearchName,
                SymbolKind.Function,
                loct,
                node.identifier.isLocal,
                prefix,
                __TS__ArrayConcat(deepLayer),
                paramArray
            )
            newChunk = __TS__New(Tools.chunkClass, functionSearchName, node.loc)
            self:pushToChunkList(newChunk.chunkName, newChunk)
            pushObj.chunk = newChunk
            self:pushToAutoList(pushObj)
        end
    elseif node.identifier and node.identifier.type == "MemberExpression" then
        local baseInfo = self:baseProcess(node.identifier)
        functionSearchName = baseInfo.name
        functionName = ("function " .. functionSearchName) .. paramString
        if ____type == travelMode.GET_DEFINE and searchRes == true then
            local bname = self:MemberExpressionFind(node.identifier)
            if bname.isInStat and bname.isInStat > 0 then
                self.posSearchRet = self:createRetSymbol(bname.name, bname.isLocal)
                return
            end
        end
        if ____type == travelMode.FIND_REFS then
            if functionSearchName == self.searchInfo.originalName then
                local loc = node.identifier.loc
                local nodeLoc1 = Location:create(self.docInfo.docUri, loc)
                self.refsLink:push(nodeLoc1)
            end
        end
        if ____type == travelMode.BUILD then
            local bname = self:baseProcess(node.identifier)
            local originalName = bname.origion
            local loc = node.identifier.loc
            local rg = Location:create(
                self.docInfo.docUri,
                Range:create(
                    Position:create(loc.start.line - 1, loc.start.column),
                    Position:create(loc["end"].line - 1, loc["end"].column)
                )
            )
            local symbInfo = self:createSymbolInfo(
                functionName,
                functionSearchName,
                originalName,
                SymbolKind.Function,
                rg,
                bname.isLocal,
                prefix,
                __TS__ArrayConcat(deepLayer),
                paramArray
            )
            newChunk = __TS__New(Tools.chunkClass, functionSearchName, node.loc)
            self:pushToChunkList(newChunk.chunkName, newChunk)
            symbInfo.chunk = newChunk
            self:pushToAutoList(symbInfo)
            local sepArr = bname.name:split(":")
            if sepArr.length > 1 then
                local tagname = sepArr[0]
                local funcself = "self"
                local isLocal = true
                local posChunk = __TS__New(Tools.chunkClass, functionSearchName, node.loc)
                deepLayer[#deepLayer + 1] = posChunk
                local selfInfo = self:createSymbolInfo(
                    funcself,
                    funcself,
                    funcself,
                    SymbolKind.Variable,
                    rg,
                    isLocal,
                    prefix,
                    __TS__ArrayConcat(deepLayer),
                    nil,
                    tagname,
                    Tools.TagReason.Equal
                )
                self:pushToAutoList(selfInfo)
                table.remove(deepLayer)
            end
        end
    end
    local posChunk = __TS__New(Tools.chunkClass, functionSearchName, node.loc)
    deepLayer[#deepLayer + 1] = posChunk
    if ____type == travelMode.BUILD then
        do
            local idx = 0
            local len = #paraRecoder
            while idx < len do
                local parainfo = table.remove(paraRecoder)
                parainfo.containerName = functionSearchName
                parainfo.containerList = __TS__ArrayConcat(deepLayer)
                self:pushToAllList(parainfo)
                idx = idx + 1
            end
        end
    end
    if ____type == travelMode.GET_DEFINE then
        if searchHitPara == true then
            self.posSearchRet = self:createRetSymbol(node.parameters[searchHitParaIdx].name, node.parameters[searchHitParaIdx].isLocal)
            return
        end
    end
    self.funcReturnRecoder = nil
    self:traversalAST(node.body, ____type, deepLayer, functionName)
    if ____type == travelMode.GET_DEFINE then
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
    if ____type == travelMode.BUILD then
        if self.funcReturnRecoder then
            if newChunk then
                newChunk.returnSymbol = self.funcReturnRecoder
            else
            end
        end
    end
    table.remove(deepLayer)
end
function DocSymbolProcessor.prototype.LocalStatement(self, node, ____type, deepLayer, prefix)
    local searchRes = false
    local baseInfo
    if ____type == travelMode.GET_DEFINE then
        searchRes = self:isInLocation(
            Location:create(self.docInfo.docUri, node.loc),
            self.searchPosition
        )
    end
    do
        local idx = 0
        local len = node.variables.length
        while idx < len do
            if ____type == travelMode.BUILD then
                baseInfo = self:buildLvalueSymbals(node.variables[idx], ____type, deepLayer, prefix)
            end
            if ____type == travelMode.GET_DEFINE then
                self:searchLvalueSymbals(
                    node.variables[idx],
                    ____type,
                    deepLayer,
                    prefix,
                    searchRes
                )
                if self.posSearchRet and self.posSearchRet.isFindout then
                    return
                end
                baseInfo = self.posSearchRet.baseinfo
            end
            if ____type == travelMode.FIND_REFS then
                self:searchLvalueSymbals(
                    node.variables[idx],
                    ____type,
                    deepLayer,
                    prefix,
                    searchRes
                )
            end
            idx = idx + 1
        end
    end
    do
        local idx = 0
        local len = node.init.length
        while idx < len do
            if ____type == travelMode.BUILD then
                self:buildRvalueSymbals(
                    node.init[idx],
                    ____type,
                    deepLayer,
                    prefix,
                    baseInfo
                )
            end
            if ____type == travelMode.GET_DEFINE then
                self:searchRvalueSymbals(
                    node.init[idx],
                    ____type,
                    deepLayer,
                    prefix,
                    baseInfo,
                    searchRes
                )
                if self.posSearchRet and self.posSearchRet.isFindout then
                    return
                end
            end
            if ____type == travelMode.FIND_REFS then
                self:searchRvalueSymbals(
                    node.init[idx],
                    ____type,
                    deepLayer,
                    prefix,
                    baseInfo,
                    searchRes
                )
            end
            idx = idx + 1
        end
    end
end
function DocSymbolProcessor.prototype.processCallExpisSetMetatable(self, node, ____type, arg)
    if ____type == travelMode.BUILD then
        local len = arg.length
        if node.base.type == "Identifier" and node.base.name == "setmetatable" and node.base.isLocal == false and len == 2 then
            local oldName = self:baseProcess(arg[0])
            local newName = self:baseProcess(arg[1])
            local info = {reason = Tools.TagReason.MetaTable, newType = newName.name, oldType = oldName.name, location = nil}
            self:pushToCommentList(info)
        end
    end
end
function DocSymbolProcessor.prototype.processCallExpisFunctionCall(self, node, ____type, arg)
    if ____type == travelMode.BUILD then
        local functionName = self:baseProcess(node.base)
        local info = {functionName = functionName, loc = node.loc}
        self:recordFuncCall(info)
    end
end
function DocSymbolProcessor.prototype.processCallExpisRequire(self, node, ____type, arg)
    if ____type == travelMode.BUILD then
        local len = arg.length
        if node.base.type == "Identifier" and node.base.name == "require" and node.base.isLocal == false and len == 1 then
            if arg[0].type == "StringLiteral" and arg[0].value then
                local info = {reqName = arg[0].value, loc = arg[0].loc}
                local ____self_docInfo_requires_1 = self.docInfo.requires
                ____self_docInfo_requires_1[#____self_docInfo_requires_1 + 1] = info
                self:recordReference(self.docInfo.docUri, arg[0].value)
            end
        end
    end
end
function DocSymbolProcessor.prototype.processStringCallExpisRequire(self, node, ____type, arg)
    if ____type == travelMode.BUILD then
        if arg.type == "StringLiteral" and arg.value then
            local info = {reqName = arg.value, loc = arg.loc}
            local ____self_docInfo_requires_2 = self.docInfo.requires
            ____self_docInfo_requires_2[#____self_docInfo_requires_2 + 1] = info
            self:recordReference(self.docInfo.docUri, arg.value)
        end
    end
end
function DocSymbolProcessor.prototype.processStringCallExpression(self, node, ____type, deepLayer, prefix)
    if ____type == travelMode.BUILD then
        self:processStringCallExpisRequire(node, ____type, node.argument)
    end
    if ____type == travelMode.GET_DEFINE then
        local bname = self:MemberExpressionFind(node.base)
        if bname.isInStat and bname.isInStat > 0 then
            self.posSearchRet = self:createRetSymbol(bname.name, bname.isLocal)
            return
        end
    end
end
function DocSymbolProcessor.prototype.processCallExpression(self, node, ____type, deepLayer, prefix)
    local varArray = Array.prototype.slice(node.arguments)
    local len = #varArray
    self:processCallExpisRequire(node, ____type, varArray)
    self:processCallExpisSetMetatable(node, ____type, varArray)
    self:processCallExpisFunctionCall(node, ____type, varArray)
    do
        local idx = 0
        while idx < len do
            self:traversalAST(node.arguments[idx], ____type, deepLayer, prefix)
            if self.posSearchRet and self.posSearchRet.isFindout then
                return
            end
            idx = idx + 1
        end
    end
    if ____type == travelMode.GET_DEFINE then
        local bname = self:MemberExpressionFind(node.base)
        if bname.isInStat and bname.isInStat > 0 then
            self.posSearchRet = self:createRetSymbol(bname.name, bname.isLocal)
            return
        end
    end
    if ____type == travelMode.FIND_REFS then
        local bname = self:MemberExpressionFind(node.base)
        if bname == self.searchInfo.name then
            local loc = node.identifier.loc
            local nodeLoc1 = Location:create(self.docInfo.docUri, loc)
            self.refsLink:push(nodeLoc1)
        end
    end
end
function DocSymbolProcessor.prototype.processCallStatement(self, node, ____type, deepLayer, prefix)
    self:traversalAST(node.expression, ____type, deepLayer, prefix)
    if self.posSearchRet and self.posSearchRet.isFindout then
        return
    end
end
function DocSymbolProcessor.prototype.processIndexExpression(self, node, ____type, deepLayer, prefix)
    if ____type == travelMode.GET_DEFINE then
        local loc = node.index.loc
        local nodeLoc1 = Location:create(self.docInfo.docUri, loc)
        local retBool = self:isInLocation(nodeLoc1, self.searchPosition)
        if retBool == true then
            if node.base.type == "MemberExpression" then
                self.posSearchRet = self:processMemberExpression(node.base, ____type, deepLayer, prefix)
                if self.posSearchRet and self.posSearchRet.isFindout then
                    return
                end
            elseif node.base.type == "Identifier" then
                self:processIdentifier(node.base, ____type, deepLayer, prefix)
                if self.posSearchRet and self.posSearchRet.isFindout then
                    return
                end
                self:processIdentifier(node.index, ____type, deepLayer, prefix)
                if self.posSearchRet and self.posSearchRet.isFindout == true then
                    return
                end
            elseif node.base.type == "IndexExpression" then
                self:processIdentifier(node.index, ____type, deepLayer, prefix)
                if self.posSearchRet and self.posSearchRet.isFindout == true then
                    return
                end
            end
        end
        local bname = self:MemberExpressionFind(node.base)
        if bname.isInStat and bname.isInStat > 0 then
            self.posSearchRet = self:createRetSymbol(bname.name, bname.isLocal)
            return
        end
        return self:createRetBase(bname.name, bname.isLocal, node.index.value)
    end
end
function DocSymbolProcessor.prototype.processAssignment(self, node, ____type, deepLayer, prefix)
    local searchRes = false
    local baseInfo
    if ____type == travelMode.GET_DEFINE then
        local nodeLoc = Location:create(self.docInfo.docUri, node.loc)
        searchRes = self:isInLocation(nodeLoc, self.searchPosition)
    end
    if __TS__ArrayIsArray(node.variables) == true then
        local varArray = Array.prototype.slice(node.variables)
        local len = #varArray
        do
            local idx = 0
            while idx < len do
                if ____type == travelMode.BUILD then
                    baseInfo = self:buildLvalueSymbals(
                        node.variables[idx + 1],
                        ____type,
                        deepLayer,
                        prefix,
                        nil,
                        1
                    )
                end
                if ____type == travelMode.GET_DEFINE then
                    self:searchLvalueSymbals(
                        node.variables[idx + 1],
                        ____type,
                        deepLayer,
                        prefix,
                        searchRes
                    )
                    if self.posSearchRet and self.posSearchRet.isFindout then
                        return
                    end
                    if self.posSearchRet.baseinfo then
                        baseInfo = self.posSearchRet.baseinfo
                    end
                end
                if ____type == travelMode.FIND_REFS then
                    self:searchLvalueSymbals(
                        node.variables[idx + 1],
                        ____type,
                        deepLayer,
                        prefix,
                        searchRes
                    )
                end
                idx = idx + 1
            end
        end
    end
    if __TS__ArrayIsArray(node.init) == true then
        local varArray = Array.prototype.slice(node.init)
        local len = #varArray
        do
            local idx = 0
            while idx < len do
                if ____type == travelMode.BUILD then
                    self:buildRvalueSymbals(
                        node.init[idx + 1],
                        ____type,
                        deepLayer,
                        prefix,
                        baseInfo
                    )
                end
                if ____type == travelMode.GET_DEFINE then
                    self:searchRvalueSymbals(
                        node.init[idx + 1],
                        ____type,
                        deepLayer,
                        prefix,
                        baseInfo,
                        searchRes
                    )
                    if self.posSearchRet and self.posSearchRet.isFindout then
                        return
                    end
                end
                if ____type == travelMode.FIND_REFS then
                    self:searchRvalueSymbals(
                        node.init[idx + 1],
                        ____type,
                        deepLayer,
                        prefix,
                        baseInfo,
                        searchRes
                    )
                end
                idx = idx + 1
            end
        end
    end
end
function DocSymbolProcessor.prototype.processTableConstructorExpression(self, node, ____type, deepLayer, prefix, baseInfo)
    do
        local idx = 0
        local len = node.fields.length
        while idx < len do
            local idxNode = node.fields[idx]
            if ____type == travelMode.BUILD then
                if idxNode.type == "TableKeyString" then
                    local retInfo = self:buildLvalueSymbals(
                        idxNode.key,
                        ____type,
                        deepLayer,
                        prefix,
                        baseInfo
                    )
                    self:buildRvalueSymbals(
                        idxNode.value,
                        ____type,
                        deepLayer,
                        prefix,
                        retInfo
                    )
                end
                if idxNode.type == "TableKey" then
                    if idxNode.key.type == "StringLiteral" then
                        local orgname = idxNode.key.value
                        local displayName = (tostring(baseInfo.name) .. ".") .. tostring(orgname)
                        local rg = Location:create(
                            self.docInfo.docUri,
                            Range:create(
                                Position:create(idxNode.loc.start.line - 1, idxNode.loc.start.column),
                                Position:create(idxNode.loc["end"].line - 1, idxNode.loc["end"].column)
                            )
                        )
                        local symb = self:createSymbolInfo(
                            displayName,
                            displayName,
                            orgname,
                            SymbolKind.Variable,
                            rg,
                            baseInfo.isLocal,
                            prefix,
                            __TS__ArrayConcat(deepLayer)
                        )
                        self:pushToAutoList(symb)
                        local retInfo = {name = displayName, isLocal = baseInfo.isLocal}
                        self:buildRvalueSymbals(
                            idxNode.value,
                            ____type,
                            deepLayer,
                            prefix,
                            retInfo
                        )
                    end
                    if idxNode.key.type == "NumericLiteral" then
                        local orgname = idxNode.key.raw
                        local displayName = ((tostring(baseInfo.name) .. "[") .. tostring(orgname)) .. "]"
                        local rg = Location:create(
                            self.docInfo.docUri,
                            Range:create(
                                Position:create(idxNode.loc.start.line - 1, idxNode.loc.start.column),
                                Position:create(idxNode.loc["end"].line - 1, idxNode.loc["end"].column)
                            )
                        )
                        local symb = self:createSymbolInfo(
                            displayName,
                            displayName,
                            orgname,
                            SymbolKind.Variable,
                            rg,
                            baseInfo.isLocal,
                            prefix,
                            __TS__ArrayConcat(deepLayer)
                        )
                        self:pushToAutoList(symb)
                        local retInfo = {name = displayName, isLocal = baseInfo.isLocal}
                        self:buildRvalueSymbals(
                            idxNode.value,
                            ____type,
                            deepLayer,
                            prefix,
                            retInfo
                        )
                    end
                end
            end
            if ____type == travelMode.GET_DEFINE then
                if idxNode.type == "TableKeyString" then
                    local recBaseName = baseInfo.name
                    self:searchLvalueSymbals(
                        idxNode.key,
                        ____type,
                        deepLayer,
                        prefix,
                        true,
                        baseInfo
                    )
                    if self.posSearchRet and self.posSearchRet.isFindout then
                        return
                    end
                    self:searchRvalueSymbals(
                        idxNode.value,
                        ____type,
                        deepLayer,
                        prefix,
                        self.posSearchRet.baseinfo,
                        true
                    )
                    if self.posSearchRet and self.posSearchRet.isFindout then
                        return
                    end
                    baseInfo.name = recBaseName
                end
                if idxNode.type == "TableKey" then
                    if idxNode.key.type == "NumericLiteral" then
                        local recBaseName = baseInfo.name
                        baseInfo.name = ((tostring(baseInfo.name) .. "[") .. tostring(idxNode.key.value)) .. "]"
                        self:searchRvalueSymbals(
                            idxNode.value,
                            ____type,
                            deepLayer,
                            prefix,
                            baseInfo,
                            true
                        )
                        if self.posSearchRet and self.posSearchRet.isFindout then
                            return
                        end
                        baseInfo.name = recBaseName
                    end
                    if idxNode.key.type == "StringLiteral" then
                        local recBaseName = baseInfo.name
                        baseInfo.name = (tostring(baseInfo.name) .. ".") .. tostring(idxNode.key.value)
                        self:searchRvalueSymbals(
                            idxNode.value,
                            ____type,
                            deepLayer,
                            prefix,
                            baseInfo,
                            true
                        )
                        if self.posSearchRet and self.posSearchRet.isFindout then
                            return
                        end
                        baseInfo.name = recBaseName
                    end
                end
                if idxNode.type == "TableValue" then
                    if idxNode.value.type == "TableConstructorExpression" then
                        local recBaseName = baseInfo.name
                        self:processTableConstructorExpression(
                            idxNode.value,
                            ____type,
                            deepLayer,
                            prefix,
                            baseInfo
                        )
                        if self.posSearchRet and self.posSearchRet.isFindout then
                            return
                        end
                        baseInfo.name = recBaseName
                    end
                end
            end
            if ____type == travelMode.FIND_REFS then
                if idxNode.type == "TableKeyString" then
                    self:searchLvalueSymbals(
                        idxNode.key,
                        ____type,
                        deepLayer,
                        prefix,
                        true,
                        baseInfo
                    )
                    self:searchRvalueSymbals(
                        idxNode.value,
                        ____type,
                        deepLayer,
                        prefix,
                        self.posSearchRet.baseinfo,
                        true
                    )
                end
            end
            idx = idx + 1
        end
    end
end
function DocSymbolProcessor.prototype.processWhileStatement(self, node, ____type, deepLayer, prefix)
    self:traversalAST(node.body, ____type, deepLayer, prefix)
    if self.posSearchRet and self.posSearchRet.isFindout then
        return
    end
end
function DocSymbolProcessor.prototype.processRepeatStatement(self, node, ____type, deepLayer, prefix)
    self:traversalAST(node.body, ____type, deepLayer, prefix)
    if self.posSearchRet and self.posSearchRet.isFindout then
        return
    end
end
function DocSymbolProcessor.prototype.processMemberExpression(self, node, ____type, deepLayer, prefix, baseInfo, searchRes)
    if ____type == travelMode.GET_DEFINE then
        if node.type == "MemberExpression" then
            local loc = node.identifier.loc
            local nodeLoc1 = Location:create(self.docInfo.docUri, loc)
            local retBool = self:isInLocation(nodeLoc1, self.searchPosition)
            if retBool == true then
                local bname = self:baseProcess(node)
                self.posSearchRet = self:createRetSymbol(bname.name, bname.isLocal)
            end
            local bname = self:MemberExpressionFind(node.base)
            if bname.isInStat and bname.isInStat > 0 then
                self.posSearchRet = self:createRetSymbol(bname.name, bname.isLocal)
            end
            return self:createRetBase(bname.name, bname.isLocal, node.identifier.name)
        end
    end
end
function DocSymbolProcessor.prototype.processIdentifier(self, node, ____type, deepLayer, prefix, baseInfo, searchRes)
    if ____type == travelMode.GET_DEFINE then
        if node.type == "Identifier" then
            if baseInfo == nil or baseInfo.name == nil or baseInfo.name == "" then
                baseInfo = {name = node.name, isLocal = node.isLocal}
            else
                if baseInfo.identiferStr then
                    baseInfo.name = (((tostring(baseInfo.name) .. ".") .. tostring(baseInfo.identiferStr)) .. ".") .. tostring(node.name)
                else
                    baseInfo.name = (tostring(baseInfo.name) .. ".") .. tostring(node.name)
                end
            end
            local nodeLoc1 = Location:create(self.docInfo.docUri, node.loc)
            if self:isInLocation(nodeLoc1, self.searchPosition) then
                self.posSearchRet = self:createRetSymbol(baseInfo.name, baseInfo.isLocal)
            else
                self.posSearchRet = self:createRetBase(baseInfo.name, baseInfo.isLocal)
            end
        end
        if node.type == "BinaryExpression" then
        end
    end
    if ____type == travelMode.FIND_REFS then
        if node.type == "Identifier" then
            if baseInfo == nil or baseInfo.name == nil or baseInfo.name == "" then
                baseInfo = {name = node.name, isLocal = node.isLocal}
            else
                if baseInfo.identiferStr then
                    baseInfo.name = (((tostring(baseInfo.name) .. ".") .. tostring(baseInfo.identiferStr)) .. ".") .. tostring(node.name)
                else
                    baseInfo.name = (tostring(baseInfo.name) .. ".") .. tostring(node.name)
                end
            end
            if baseInfo.name == self.searchInfo.searchName then
                local nodeLoc1 = Location:create(self.docInfo.docUri, node.loc)
                self.refsLink:push(nodeLoc1)
            end
        end
    end
end
function DocSymbolProcessor.prototype.processBinaryExpression(self, node, ____type, deepLayer, prefix)
    if ____type == travelMode.GET_DEFINE then
        self:traversalAST(node.left, ____type, deepLayer, prefix)
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
        self:traversalAST(node.right, ____type, deepLayer, prefix)
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
    if ____type == travelMode.FIND_REFS then
        self:traversalAST(node.left, ____type, deepLayer, prefix)
        self:traversalAST(node.right, ____type, deepLayer, prefix)
    end
end
function DocSymbolProcessor.prototype.processUnaryExpression(self, node, ____type, deepLayer, prefix)
    if ____type == travelMode.GET_DEFINE then
        local argumentType = node.argument.type
        repeat
            local ____switch344 = argumentType
            local ____cond344 = ____switch344 == "Identifier"
            if ____cond344 then
                self:processIdentifier(node.argument, ____type, deepLayer, prefix)
                break
            end
            ____cond344 = ____cond344 or ____switch344 == "LogicalExpression"
            if ____cond344 then
                self:searchRvalueSymbals(node.argument.left, ____type, deepLayer, prefix)
                if self.posSearchRet and self.posSearchRet.isFindout then
                    break
                end
                self:searchRvalueSymbals(node.argument.right, ____type, deepLayer, prefix)
                break
            end
            ____cond344 = ____cond344 or ____switch344 == "IndexExpression"
            if ____cond344 then
                self:processIndexExpression(node.argument, ____type, deepLayer, prefix)
                break
            end
            ____cond344 = ____cond344 or ____switch344 == "BinaryExpression"
            if ____cond344 then
                self:processBinaryExpression(node.argument, ____type, deepLayer, prefix)
                break
            end
            ____cond344 = ____cond344 or ____switch344 == "CallExpression"
            if ____cond344 then
                self:processCallExpression(node.argument, ____type, deepLayer, prefix)
                break
            end
            ____cond344 = ____cond344 or ____switch344 == "MemberExpression"
            if ____cond344 then
                self:processMemberExpression(node.argument, ____type, deepLayer, prefix)
                break
            end
            ____cond344 = ____cond344 or ____switch344 == "UnaryExpression"
            if ____cond344 then
                self:processUnaryExpression(node.argument, ____type, deepLayer, prefix)
                break
            end
        until true
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
end
function DocSymbolProcessor.prototype.processIfStatement(self, ASTNode, ____type, deepLayer, prefix)
    local node = ASTNode.clauses
    if __TS__ArrayIsArray(node) == true then
        local ASTArray = Array.prototype.slice(node)
        do
            local idx = 0
            local len = #ASTArray
            while idx < len do
                if ASTArray[idx + 1].type == "IfClause" or ASTArray[idx + 1].type == "ElseifClause" then
                    if ASTArray[idx + 1].condition.type == "Identifier" then
                        self:processIdentifier(ASTArray[idx + 1].condition, ____type, deepLayer, prefix)
                        if self.posSearchRet and self.posSearchRet.isFindout then
                            return
                        end
                    end
                    if ASTArray[idx + 1].condition.type == "LogicalExpression" then
                        local node = ASTArray[idx + 1].condition
                        self:searchRvalueSymbals(node.left, ____type, deepLayer, prefix)
                        if self.posSearchRet and self.posSearchRet.isFindout then
                            return
                        end
                        self:searchRvalueSymbals(node.right, ____type, deepLayer, prefix)
                        if self.posSearchRet and self.posSearchRet.isFindout then
                            return
                        end
                    end
                    if ASTArray[idx + 1].condition.type == "IndexExpression" then
                        self:processIndexExpression(ASTArray[idx + 1].condition, ____type, deepLayer, prefix)
                        if self.posSearchRet and self.posSearchRet.isFindout then
                            return
                        end
                    end
                    if ASTArray[idx + 1].condition.type == "BinaryExpression" then
                        self:processBinaryExpression(ASTArray[idx + 1].condition, ____type, deepLayer, prefix)
                        if self.posSearchRet and self.posSearchRet.isFindout then
                            return
                        end
                    end
                    if ASTArray[idx + 1].condition.type == "CallExpression" then
                        self:processCallExpression(ASTArray[idx + 1].condition, ____type, deepLayer, prefix)
                        if self.posSearchRet and self.posSearchRet.isFindout then
                            return
                        end
                    end
                    if ASTArray[idx + 1].condition.type == "MemberExpression" then
                        self:processMemberExpression(ASTArray[idx + 1].condition, ____type, deepLayer, prefix)
                        if self.posSearchRet and self.posSearchRet.isFindout then
                            return
                        end
                    end
                    if ASTArray[idx + 1].condition.type == "UnaryExpression" then
                        self:processUnaryExpression(ASTArray[idx + 1].condition, ____type, deepLayer, prefix)
                        if self.posSearchRet and self.posSearchRet.isFindout then
                            return
                        end
                    end
                    self:traversalAST(ASTArray[idx + 1].body, ____type, deepLayer, prefix)
                    if self.posSearchRet and self.posSearchRet.isFindout then
                        return
                    end
                end
                if ASTArray[idx + 1].type == "ElseClause" then
                    self:traversalAST(ASTArray[idx + 1].body, ____type, deepLayer, prefix)
                    if self.posSearchRet and self.posSearchRet.isFindout then
                        return
                    end
                end
                idx = idx + 1
            end
        end
    end
end
function DocSymbolProcessor.prototype.processReturnStatement(self, ASTNode, ____type, deepLayer, prefix, isBody)
    if ____type == travelMode.GET_DEFINE then
        local node = ASTNode
        local varArray = Array.prototype.slice(node.arguments)
        do
            local idx = 0
            while idx < #varArray do
                self:traversalAST(varArray[idx + 1], ____type, deepLayer, prefix)
                if self.posSearchRet and self.posSearchRet.isFindout then
                    return
                end
                idx = idx + 1
            end
        end
    end
    if ____type == travelMode.BUILD then
        if isBody == true then
            if ASTNode.arguments.length == 1 then
                if ASTNode.arguments[0].type == "Identifier" then
                    local name = ASTNode.arguments[0].name
                    self.docInfo.defineSymbols.chunks[self.docInfo.docPath].returnSymbol = name
                end
            end
        else
            if ASTNode.arguments.length == 1 then
                if ASTNode.arguments[0].type == "Identifier" then
                    local name = ASTNode.arguments[0].name
                    self.funcReturnRecoder = name
                end
            end
        end
    end
end
function DocSymbolProcessor.prototype.processForGenericStatement(self, node, ____type, deepLayer, prefix)
    self:traversalAST(node.body, ____type, deepLayer, prefix)
    if self.posSearchRet and self.posSearchRet.isFindout then
        return
    end
end
function DocSymbolProcessor.prototype.processForNumericStatement(self, node, ____type, deepLayer, prefix)
    self:traversalAST(node.body, ____type, deepLayer, prefix)
    if self.posSearchRet and self.posSearchRet.isFindout then
        return
    end
end
function DocSymbolProcessor.prototype.buildLvalueSymbals(self, node, ____type, deepLayer, prefix, baseInfo, isAssign)
    local baseName = ""
    local baseLocal = true
    local displayName = ""
    local searchName = ""
    if node.type == "Identifier" then
        if baseInfo == nil then
            baseName = node.name
            baseLocal = node.isLocal
            displayName = node.name
        else
            baseLocal = baseInfo.isLocal
            baseName = (tostring(baseInfo.name) .. ".") .. tostring(node.name)
            displayName = baseName
        end
        searchName = baseName
        local isPush = true
        if isAssign == 1 then
            if baseLocal then
                isPush = false
            else
                if self:getGlobalSymbolsDic()[searchName] ~= nil then
                    isPush = false
                end
            end
        end
        if isPush == true then
            local loct = Location:create(
                self.docInfo.docUri,
                Range:create(
                    Position:create(node.loc.start.line - 1, node.loc.start.column),
                    Position:create(node.loc["end"].line - 1, node.loc["end"].column)
                )
            )
            local symb = self:createSymbolInfo(
                displayName,
                baseName,
                node.name,
                SymbolKind.Variable,
                loct,
                baseLocal,
                prefix,
                __TS__ArrayConcat(deepLayer)
            )
            self:pushToAutoList(symb)
        end
        return {name = baseName, isLocal = baseLocal}
    end
    if "MemberExpression" == node.type then
        local bname = self:baseProcess(node)
        local rg = Location:create(
            self.docInfo.docUri,
            Range:create(
                Position:create(node.loc.start.line - 1, node.loc.start.column),
                Position:create(node.loc["end"].line - 1, node.loc["end"].column)
            )
        )
        baseName = bname.name
        baseLocal = bname.isLocal
        if self:checkIsSymbolExist(bname.name) == false then
            local symb = self:createSymbolInfo(
                bname.name,
                bname.name,
                node.identifier.name,
                SymbolKind.Variable,
                rg,
                bname.isLocal,
                prefix,
                __TS__ArrayConcat(deepLayer)
            )
            self:pushToAutoList(symb)
        end
        return {name = baseName, isLocal = baseLocal}
    elseif "IndexExpression" == node.type then
        local baseInfo = self:baseProcess(node.base)
        if node.index.type == "StringLiteral" then
            local rg = Location:create(
                self.docInfo.docUri,
                Range:create(
                    Position:create(node.loc.start.line - 1, node.loc.start.column),
                    Position:create(node.loc["end"].line - 1, node.loc["end"].column)
                )
            )
            local displayName = (tostring(baseInfo.name) .. ".") .. tostring(node.index.value)
            if self:checkIsSymbolExist(displayName) == false then
                local symb = self:createSymbolInfo(
                    displayName,
                    displayName,
                    node.index.value,
                    SymbolKind.Variable,
                    rg,
                    baseInfo.isLocal,
                    prefix,
                    __TS__ArrayConcat(deepLayer)
                )
                self:pushToAutoList(symb)
            end
        end
        return {name = baseInfo.name, isLocal = baseInfo.isLocal}
    end
end
function DocSymbolProcessor.prototype.buildRvalueSymbals(self, node, ____type, deepLayer, prefix, baseInfo)
    if node == nil then
        return
    end
    if node.type == "TableConstructorExpression" then
        self:processTableConstructorExpression(
            node,
            ____type,
            deepLayer,
            prefix,
            baseInfo
        )
    end
    if node.type == "Identifier" then
        local info = {reason = Tools.TagReason.Equal, newType = node.name, location = node.loc, name = baseInfo.name}
        self:pushToCommentList(info)
    end
    if node.type == "MemberExpression" then
        local bname = self:baseProcess(node)
        local info = {reason = Tools.TagReason.Equal, newType = bname.name, location = node.loc, name = baseInfo.name}
        self:pushToCommentList(info)
    end
    self:traversalAST(node, ____type, deepLayer, prefix)
end
function DocSymbolProcessor.prototype.searchLvalueSymbals(self, node, ____type, deepLayer, prefix, searchRes, baseInfo)
    local localBaseInfo = baseInfo
    if node.type == "Identifier" then
        self:processIdentifier(
            node,
            ____type,
            deepLayer,
            prefix,
            localBaseInfo,
            searchRes
        )
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
        if self.posSearchRet and self.posSearchRet.isFindout == false then
            localBaseInfo = self.posSearchRet.baseinfo
        end
    end
    if node.type == "MemberExpression" then
        self:processMemberExpression(
            node,
            ____type,
            deepLayer,
            prefix,
            localBaseInfo,
            searchRes
        )
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
        if self.posSearchRet and self.posSearchRet.isFindout == false then
            localBaseInfo = self.posSearchRet.baseinfo
        end
    end
    if node.type == "CallExpression" then
        self:processCallExpression(node, ____type, deepLayer, prefix)
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
        if self.posSearchRet and self.posSearchRet.isFindout == false then
            localBaseInfo = self.posSearchRet.baseinfo
        end
    end
    if node.type == "BinaryExpression" then
        self:processBinaryExpression(node, ____type, deepLayer, prefix)
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
        if self.posSearchRet and self.posSearchRet.isFindout == false then
            localBaseInfo = self.posSearchRet.baseinfo
        end
    end
    if node.type == "IndexExpression" then
        self:processIndexExpression(node, ____type, deepLayer, prefix)
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
        if self.posSearchRet and self.posSearchRet.isFindout == false then
            localBaseInfo = self.posSearchRet.baseinfo
        end
    end
end
function DocSymbolProcessor.prototype.searchRvalueSymbals(self, node, ____type, deepLayer, prefix, baseInfo, searchRes)
    if node.type == "Identifier" then
        self:processIdentifier(
            node,
            ____type,
            deepLayer,
            prefix,
            nil,
            searchRes
        )
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
    if node.type == "MemberExpression" then
        self:processMemberExpression(node, ____type, deepLayer, prefix)
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
    if node.type == "TableConstructorExpression" then
        self:processTableConstructorExpression(
            node,
            ____type,
            deepLayer,
            prefix,
            baseInfo
        )
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
    if node.type == "CallExpression" then
        self:traversalAST(node, ____type, deepLayer, prefix)
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
    if node.type == "FunctionDeclaration" then
        self:traversalAST(node, ____type, deepLayer, prefix)
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
    if node.type == "LogicalExpression" then
        self:searchRvalueSymbals(
            node.left,
            ____type,
            deepLayer,
            prefix,
            baseInfo,
            searchRes
        )
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
        self:searchRvalueSymbals(
            node.right,
            ____type,
            deepLayer,
            prefix,
            baseInfo,
            searchRes
        )
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
    if node.type == "BinaryExpression" then
        self:searchRvalueSymbals(
            node.left,
            ____type,
            deepLayer,
            prefix,
            baseInfo,
            searchRes
        )
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
        self:searchRvalueSymbals(
            node.right,
            ____type,
            deepLayer,
            prefix,
            baseInfo,
            searchRes
        )
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
    if node.type == "IndexExpression" then
        self:processIndexExpression(node, ____type, deepLayer, prefix)
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
    if node.type == "UnaryExpression" then
        self:processUnaryExpression(node, ____type, deepLayer, prefix)
        if self.posSearchRet and self.posSearchRet.isFindout then
            return
        end
    end
end
return ____exports
