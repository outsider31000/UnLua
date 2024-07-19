local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____codeEditor = require("Plugins.LuaPanda.src.code.server.codeEditor")
local CodeEditor = ____codeEditor.CodeEditor
local Tools = require("Plugins.LuaPanda.src.code.server.codeTools")
local ____vscode_2Dlanguageserver = require("Plugins.LuaPanda.src.code.server.vscode-languageserver")
local CompletionItemKind = ____vscode_2Dlanguageserver.CompletionItemKind
local InsertTextFormat = ____vscode_2Dlanguageserver.InsertTextFormat
local ____codeSymbol = require("Plugins.LuaPanda.src.code.server.codeSymbol")
local CodeSymbol = ____codeSymbol.CodeSymbol
local ____codeDefinition = require("Plugins.LuaPanda.src.code.server.codeDefinition")
local CodeDefinition = ____codeDefinition.CodeDefinition
local ____typeInfer = require("Plugins.LuaPanda.src.code.server.typeInfer")
local TypeInfer = ____typeInfer.TypeInfer
local ____util = require("Plugins.LuaPanda.src.code.server.util")
local isArray = ____util.isArray
____exports.CodeCompletion = __TS__Class()
local CodeCompletion = ____exports.CodeCompletion
CodeCompletion.name = "CodeCompletion"
function CodeCompletion.prototype.____constructor(self)
end
function CodeCompletion.completionEntry(self, uri, pos)
    local luaText = CodeEditor:getCode(uri)
    local userInputString = Tools:getTextByPosition(luaText, pos)
    if userInputString == "---" then
        local completingArray = self:completionComment(uri, pos, luaText)
        return completingArray
    end
    userInputString = __TS__StringReplace(userInputString, nil, ".")
    local searchResArray = self:commonCompletionSearch(uri, userInputString) or ({})
    local retCompletionArray
    local userInputSplitArr = self:splitStringwithTrigger(userInputString)
    if userInputSplitArr and userInputSplitArr.length > 1 then
        local lastPrefixSearchRet = TypeInfer:SymbolTagForCompletionEntry(uri, userInputString) or ({})
        searchResArray = __TS__ArrayConcat(searchResArray, lastPrefixSearchRet)
        retCompletionArray = self:symbolToCompletionArray(searchResArray, true)
    else
        retCompletionArray = self:symbolToCompletionArray(searchResArray)
    end
    local retCompletionItem = self:completeItemDuplicateRemoval(retCompletionArray)
    return retCompletionItem
end
function CodeCompletion.fmtParamToSnippet(self, paramArray)
    local snippet = ("(" .. table.concat(
        __TS__ArrayMap(
            paramArray,
            function(____, param, i) return ((("${" .. tostring(i + 1)) .. ":") .. param) .. "}" end
        ),
        ", "
    )) .. ")"
    return snippet
end
function CodeCompletion.getDocCommentInsertText(self, functionName, paramArray)
    local docCommentSnippet = functionName .. " ${1:Description of the function}"
    local maxParamLength = 0
    __TS__ArrayForEach(
        paramArray,
        function(____, param)
            maxParamLength = math.max(maxParamLength, #param)
        end
    )
    local i = 2
    __TS__ArrayForEach(
        paramArray,
        function(____, param)
            param = param .. Tools:getNSpace(maxParamLength - #param)
            local ____param_2 = param
            local ____i_0 = i
            i = ____i_0 + 1
            local ____i_1 = i
            i = ____i_1 + 1
            docCommentSnippet = docCommentSnippet .. ((((("\n---@param " .. ____param_2) .. " ${") .. tostring(____i_0)) .. ":Type} ${") .. tostring(____i_1)) .. ":Description}"
        end
    )
    local ____i_3 = i
    i = ____i_3 + 1
    local ____i_4 = i
    i = ____i_4 + 1
    local ____i_5 = i
    i = ____i_5 + 1
    docCommentSnippet = docCommentSnippet .. ((((("\n${" .. tostring(____i_3)) .. ":---@return } ${") .. tostring(____i_4)) .. ":Type} ${") .. tostring(____i_5)) .. ":Description}"
    return docCommentSnippet
end
function CodeCompletion.getReturnComment(self)
    local completeItem = {
        label = "mark return",
        kind = CompletionItemKind.Snippet,
        insertText = "@return ",
        detail = "Mark return type for this function",
        insertTextFormat = InsertTextFormat.Snippet
    }
    return completeItem
end
function CodeCompletion.getDocCommentCompletingItem(self, uri, line)
    local functionInfo = CodeDefinition:getFunctionInfoByLine(uri, line)
    if functionInfo.functionName == "" then
        return nil
    end
    local completeItem = {
        label = functionInfo.functionName .. " comment",
        kind = CompletionItemKind.Snippet,
        insertText = self:getDocCommentInsertText(functionInfo.functionName, functionInfo.functionParam),
        detail = "Write comments or mark return type for this function.",
        insertTextFormat = InsertTextFormat.Snippet
    }
    return completeItem
end
function CodeCompletion.commentVarTypeTips(self, uri, line)
    local completeItem = {
        label = "@type",
        kind = CompletionItemKind.Snippet,
        insertText = "@type ${1:Type} ${2:Description}",
        detail = "comment var type",
        insertTextFormat = InsertTextFormat.Snippet
    }
    return completeItem
end
function CodeCompletion.splitStringwithTrigger(self, str)
    local userInputTxt_DotToBlank = str:replace(nil, " ")
    local userInputArr = userInputTxt_DotToBlank:split(" ")
    return userInputArr
end
function CodeCompletion.symbolToCompletionArray(self, retSymb, onlyKeepPostfix)
    if onlyKeepPostfix == nil then
        onlyKeepPostfix = false
    end
    if not isArray(nil, retSymb) then
        return {}
    end
    local completingArray = {}
    do
        local idx = 0
        while idx < retSymb.length do
            local finalInsertText = retSymb[idx].searchName
            if onlyKeepPostfix then
                local userInputSplitArr = self:splitStringwithTrigger(finalInsertText)
                finalInsertText = userInputSplitArr:pop()
            end
            local completeKind
            local labelTxt = finalInsertText
            repeat
                local ____switch21 = retSymb[idx].kind
                local ____cond21 = ____switch21 == 12
                if ____cond21 then
                    completeKind = CompletionItemKind.Function
                    finalInsertText = tostring(finalInsertText) .. self:fmtParamToSnippet(retSymb[idx].funcParamArray)
                    break
                end
                do
                    completeKind = CompletionItemKind.Text
                end
            until true
            local completeItem = {
                label = labelTxt,
                kind = completeKind,
                insertText = finalInsertText,
                detail = retSymb[idx].name,
                insertTextFormat = InsertTextFormat.Snippet
            }
            if completeItem.label == nil then
                completeItem.label = "error undefined!"
            else
                completingArray[#completingArray + 1] = completeItem
            end
            idx = idx + 1
        end
    end
    return completingArray
end
function CodeCompletion.commonCompletionSearch(self, uri, searchPrefix)
    local retSymb = CodeSymbol:searchSymbolforCompletion(uri, searchPrefix, Tools.SearchMode.PrefixMatch)
    if not isArray(nil, retSymb) then
        return {}
    end
    return retSymb
end
function CodeCompletion.completionComment(self, uri, pos, luaText)
    local completingArray = __TS__New(Array)
    if Tools:isNextLineHasFunction(luaText, pos) == true then
        completingArray[#completingArray + 1] = self:getDocCommentCompletingItem(uri, pos.line + 1)
        completingArray[#completingArray + 1] = self:getReturnComment()
    else
        completingArray[#completingArray + 1] = self:commentVarTypeTips(uri, pos.line)
    end
    return completingArray
end
function CodeCompletion.completeItemDuplicateRemoval(self, completingArray)
    local retCompItemList = __TS__New(Array)
    do
        local index = 0
        while index < completingArray.length do
            local DuplicateFlag = false
            local completeItem = completingArray[index]
            do
                local retIdx = 0
                local len = #retCompItemList
                while retIdx < len do
                    if self:ItemIsEq(completeItem, retCompItemList[retIdx + 1]) then
                        DuplicateFlag = true
                        break
                    end
                    retIdx = retIdx + 1
                end
            end
            if not DuplicateFlag then
                retCompItemList[#retCompItemList + 1] = completeItem
            end
            index = index + 1
        end
    end
    return retCompItemList
end
function CodeCompletion.ItemIsEq(self, item1, item2)
    if item1.label == item2.label and item1.kind == item2.kind and item1.insertText == item2.insertText and item1.insertTextFormat == item2.insertTextFormat then
        return true
    end
    return false
end
return ____exports
