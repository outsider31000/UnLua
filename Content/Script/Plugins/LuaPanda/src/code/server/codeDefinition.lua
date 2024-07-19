local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____vscode_2Dlanguageserver = require("Plugins.LuaPanda.src.code.server.vscode-languageserver")
local Location = ____vscode_2Dlanguageserver.Location
local SymbolKind = ____vscode_2Dlanguageserver.SymbolKind
local ____codeLogManager = require("Plugins.LuaPanda.src.code.server.codeLogManager")
local Logger = ____codeLogManager.Logger
local ____codeSymbol = require("Plugins.LuaPanda.src.code.server.codeSymbol")
local CodeSymbol = ____codeSymbol.CodeSymbol
local ____typeInfer = require("Plugins.LuaPanda.src.code.server.typeInfer")
local TypeInfer = ____typeInfer.TypeInfer
local Tools = require("Plugins.LuaPanda.src.code.server.codeTools")
local ____util = require("Plugins.LuaPanda.src.code.server.util")
local isArray = ____util.isArray
____exports.CodeDefinition = __TS__Class()
local CodeDefinition = ____exports.CodeDefinition
CodeDefinition.name = "CodeDefinition"
function CodeDefinition.prototype.____constructor(self)
end
function CodeDefinition.getSymbalDefine(self, info, isRetSymbol)
    isRetSymbol = isRetSymbol or false
    Tools:transPosStartLineTo1(info.position)
    local uri = info.textDocument.uri
    local astContainer = CodeSymbol.docSymbolMap:get(uri)
    if not astContainer then
        Logger:InfoLog("[Error] getSymbalDefine can’t find AST")
        return nil
    end
    local symbRet = astContainer:searchDocSymbolfromPosition(info.position)
    if symbRet ~= nil and symbRet.sybinfo ~= nil then
        local symbolInfo = symbRet.sybinfo
        local containerList = symbRet.container
        if symbolInfo.name:match(":") then
            symbolInfo.name = __TS__StringReplace(symbolInfo.name, nil, ".")
        end
        local symbInstance = self:directSearch(uri, symbolInfo.name, Tools.SearchMode.ExactlyEqual)
        if isArray(nil, symbInstance) and #symbInstance > 0 then
        else
            symbInstance = TypeInfer:SymbolTagForDefinitionEntry(symbolInfo, uri)
        end
        if not symbInstance or #symbInstance == 0 then
            return
        end
        Tools:transPosStartLineTo0(info.position)
        local finalRetSymbols
        if symbolInfo.isLocal then
            finalRetSymbols = self:judgeLocalDefinition(symbInstance, containerList, info)
            if not finalRetSymbols and symbInstance and #symbInstance > 0 then
                finalRetSymbols = symbInstance[1]
            end
        else
            finalRetSymbols = symbInstance[1]
        end
        if not finalRetSymbols then
            return
        end
        if isRetSymbol then
            return finalRetSymbols
        end
        local retLoc = Location:create(finalRetSymbols.containerURI, finalRetSymbols.location.range)
        return retLoc
    else
        local reqFileName = astContainer:searchDocRequireFileNameFromPosition(info.position)
        local uri = Tools:transFileNameToUri(reqFileName)
        if #uri > 0 then
            return Tools:createEmptyLocation(uri)
        end
        return
    end
end
function CodeDefinition.directSearch(self, uri, symbolStr, method)
    local ret = CodeSymbol:searchSymbolinDoc(uri, symbolStr, method) or ({})
    if #ret == 0 then
        ret = CodeSymbol:searchSymbolforGlobalDefinition(uri, symbolStr, method, Tools.SearchRange.GlobalSymbols) or ({})
    end
    return ret
end
function CodeDefinition.judgeLocalDefinition(self, findoutSymbols, containerList, docPosition)
    if not findoutSymbols or findoutSymbols.length <= 0 or not docPosition or not containerList or containerList.length <= 0 then
        return
    end
    if findoutSymbols.length == 1 then
        return findoutSymbols[0]
    end
    local commonDepth = self:findCommonDepth(containerList, findoutSymbols)
    local maxComDep = 0
    do
        local index = 0
        while index < #commonDepth do
            if maxComDep < commonDepth[index + 1] then
                maxComDep = commonDepth[index + 1]
            end
            index = index + 1
        end
    end
    local maxArray = __TS__New(Array)
    do
        local index = 0
        while index < #commonDepth do
            if maxComDep == commonDepth[index + 1] then
                maxArray[#maxArray + 1] = findoutSymbols[index]
            end
            index = index + 1
        end
    end
    if #maxArray == 1 then
        return maxArray[1]
    end
    return self:findUpNearestSymbol(docPosition.position, maxArray)
end
function CodeDefinition.findUpNearestSymbol(self, docPosition, maxArray)
    local distanceLineNumber = __TS__New(Array)
    local standardLine = docPosition.line
    for key in pairs(maxArray) do
        local element = maxArray[key]
        local upLine = element.location.range.start.line
        distanceLineNumber[key] = standardLine - upLine
    end
    local minComDep = 99999
    do
        local index = 0
        while index < #distanceLineNumber do
            if distanceLineNumber[index + 1] < minComDep and distanceLineNumber[index + 1] >= 0 then
                minComDep = distanceLineNumber[index + 1]
            end
            index = index + 1
        end
    end
    local minSymbolIdx = 0
    do
        local index = 0
        while index < #distanceLineNumber do
            if minComDep == distanceLineNumber[index + 1] then
                minSymbolIdx = index
                break
            end
            index = index + 1
        end
    end
    return maxArray[minSymbolIdx]
end
function CodeDefinition.findCommonDepth(self, standradDepth, beFindSymbolList)
    local retArray = __TS__New(Array)
    for key in pairs(beFindSymbolList) do
        do
            local element = beFindSymbolList[key]
            if standradDepth.length < element.containerList.length then
                retArray[key] = -1
                goto __continue35
            end
            do
                local index = 0
                while index < standradDepth.length do
                    local standardChunk = standradDepth[index]
                    local beAnalyzeDepth = element.containerList[index]
                    if standardChunk and beAnalyzeDepth and standardChunk.chunkName == beAnalyzeDepth.chunkName and standardChunk.loc.start.line == beAnalyzeDepth.loc.start.line and standardChunk.loc["end"].line == beAnalyzeDepth.loc["end"].line then
                        retArray[key] = index + 1
                    else
                        if standardChunk and not beAnalyzeDepth then
                        else
                            retArray[key] = -1
                        end
                    end
                    index = index + 1
                end
            end
        end
        ::__continue35::
    end
    return retArray
end
function CodeDefinition.getFunctionInfoByLine(self, uri, line)
    local displaySymbolArray = CodeSymbol:getOneDocSymbolsArray(uri, nil, Tools.SearchRange.AllSymbols)
    local result = {functionName = "", functionParam = {}}
    for key in pairs(displaySymbolArray) do
        local docDisplaySymbol = displaySymbolArray[key]
        if docDisplaySymbol.kind == SymbolKind.Function and docDisplaySymbol.location.range.start.line == line then
            result.functionName = docDisplaySymbol.searchName
            result.functionParam = docDisplaySymbol.funcParamArray
            return result
        end
    end
    return result
end
return ____exports
