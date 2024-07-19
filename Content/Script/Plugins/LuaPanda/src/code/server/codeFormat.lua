local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__New = ____lualib.__TS__New
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____codeEditor = require("Plugins.LuaPanda.src.code.server.codeEditor")
local CodeEditor = ____codeEditor.CodeEditor
local ____lua_2Dfmt = require("Plugins.LuaPanda.src.code.server.lua-fmt")
local formatText = ____lua_2Dfmt.formatText
local ____vscode_2Dlanguageserver = require("Plugins.LuaPanda.src.code.server.vscode-languageserver")
local TextEdit = ____vscode_2Dlanguageserver.TextEdit
local Range = ____vscode_2Dlanguageserver.Range
local Position = ____vscode_2Dlanguageserver.Position
local ____lua_2Dfmt = require("Plugins.LuaPanda.src.code.server.lua-fmt")
local producePatch = ____lua_2Dfmt.producePatch
local ____diff = require("Plugins.LuaPanda.src.code.server.diff")
local parsePatch = ____diff.parsePatch
local EditAction = EditAction or ({})
EditAction.Replace = 0
EditAction[EditAction.Replace] = "Replace"
EditAction.Insert = 1
EditAction[EditAction.Insert] = "Insert"
EditAction.Delete = 2
EditAction[EditAction.Delete] = "Delete"
local Edit = __TS__Class()
Edit.name = "Edit"
function Edit.prototype.____constructor(self, action, start)
    self.text = ""
    self.action = action
    self.start = start
    self["end"] = Position:create(0, 0)
end
____exports.CodeFormat = __TS__Class()
local CodeFormat = ____exports.CodeFormat
CodeFormat.name = "CodeFormat"
function CodeFormat.prototype.____constructor(self)
end
function CodeFormat.format(self, uri)
    local text = CodeEditor:getCode(uri)
    local formattedText = formatText(nil, text)
    if process.platform == "win32" then
        text = table.concat(
            __TS__StringSplit(text, "\r\n"),
            "\n"
        )
        formattedText = formattedText:split("\r\n"):join("\n")
    end
    return self:getEditsFromFormattedText(uri, text, formattedText)
end
function CodeFormat.getEditsFromFormattedText(self, documentUri, originalText, formattedText, startOffset)
    if startOffset == nil then
        startOffset = 0
    end
    local diff = producePatch(nil, documentUri, originalText, formattedText)
    local unifiedDiffs = parsePatch(nil, diff)
    local edits = {}
    local currentEdit = nil
    for ____, uniDiff in __TS__Iterator(unifiedDiffs) do
        for ____, hunk in __TS__Iterator(uniDiff.hunks) do
            local startLine = hunk.oldStart + startOffset
            for ____, line in __TS__Iterator(hunk.lines) do
                repeat
                    local ____switch10 = line[0]
                    local ____cond10 = ____switch10 == "-"
                    if ____cond10 then
                        if currentEdit == nil then
                            currentEdit = __TS__New(
                                Edit,
                                EditAction.Delete,
                                Position:create(startLine - 1, 0)
                            )
                        end
                        currentEdit["end"] = Position:create(startLine, 0)
                        startLine = startLine + 1
                        break
                    end
                    ____cond10 = ____cond10 or ____switch10 == "+"
                    if ____cond10 then
                        if currentEdit == nil then
                            currentEdit = __TS__New(
                                Edit,
                                EditAction.Insert,
                                Position:create(startLine - 1, 0)
                            )
                        elseif currentEdit.action == EditAction.Delete then
                            currentEdit.action = EditAction.Replace
                        end
                        currentEdit.text = currentEdit.text .. tostring(line:substr(1)) .. "\n"
                        break
                    end
                    ____cond10 = ____cond10 or ____switch10 == " "
                    if ____cond10 then
                        startLine = startLine + 1
                        if currentEdit ~= nil then
                            edits[#edits + 1] = currentEdit
                        end
                        currentEdit = nil
                        break
                    end
                until true
            end
        end
        if currentEdit ~= nil then
            edits[#edits + 1] = currentEdit
        end
    end
    return __TS__ArrayMap(
        edits,
        function(____, edit)
            repeat
                local ____switch20 = edit.action
                local ____cond20 = ____switch20 == EditAction.Replace
                if ____cond20 then
                    return TextEdit:replace(
                        Range:create(edit.start, edit["end"]),
                        edit.text
                    )
                end
                ____cond20 = ____cond20 or ____switch20 == EditAction.Insert
                if ____cond20 then
                    return TextEdit:insert(edit.start, edit.text)
                end
                ____cond20 = ____cond20 or ____switch20 == EditAction.Delete
                if ____cond20 then
                    return TextEdit:del(Range:create(edit.start, edit["end"]))
                end
            until true
        end
    )
end
return ____exports
