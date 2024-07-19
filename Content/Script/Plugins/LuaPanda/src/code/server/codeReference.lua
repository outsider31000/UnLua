local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat
local ____exports = {}
local ____codeSymbol = require("Plugins.LuaPanda.src.code.server.codeSymbol")
local CodeSymbol = ____codeSymbol.CodeSymbol
local ____codeDefinition = require("Plugins.LuaPanda.src.code.server.codeDefinition")
local CodeDefinition = ____codeDefinition.CodeDefinition
____exports.CodeReference = __TS__Class()
local CodeReference = ____exports.CodeReference
CodeReference.name = "CodeReference"
function CodeReference.prototype.____constructor(self)
end
function CodeReference.getSymbalReferences(self, info)
    local refRet = __TS__New(Array)
    local def = CodeDefinition:getSymbalDefine(info, true)
    local findDocRes = CodeSymbol:searchSymbolReferenceinDoc(def)
    __TS__ArrayConcat(refRet, findDocRes)
    do
        local index = 0
        while index < findDocRes.length do
            findDocRes[index].range.start.line = findDocRes[index].range.start.line - 1
            findDocRes[index].range.start.character = findDocRes[index].range.start.column
            findDocRes[index].range["end"].line = findDocRes[index].range["end"].line - 1
            findDocRes[index].range["end"].character = findDocRes[index].range["end"].column
            index = index + 1
        end
    end
    return findDocRes
end
return ____exports
