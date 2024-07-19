local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local Tools = require("Plugins.LuaPanda.src.code.server.codeTools")
local ____codeLogManager = require("Plugins.LuaPanda.src.code.server.codeLogManager")
local Logger = ____codeLogManager.Logger
____exports.CodeEditor = __TS__Class()
local CodeEditor = ____exports.CodeEditor
CodeEditor.name = "CodeEditor"
function CodeEditor.prototype.____constructor(self)
end
function CodeEditor.saveCode(self, uri, text)
    self.codeInEditor[uri] = text
end
function CodeEditor.getCode(self, uri)
    if self.codeInEditor[uri] then
        return self.codeInEditor[uri]
    else
        local luatxt = Tools:getFileContent(Tools:uriToPath(uri))
        if not luatxt then
            Logger:InfoLog("Can’t get file content. uri:" .. uri)
            return
        end
        return luatxt
    end
end
CodeEditor.codeInEditor = __TS__New(Map)
return ____exports
