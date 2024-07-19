local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local vscode = require("Plugins.LuaPanda.src.common.vscode")
____exports.DebugLogger = __TS__Class()
local DebugLogger = ____exports.DebugLogger
DebugLogger.name = "DebugLogger"
function DebugLogger.prototype.____constructor(self)
end
function DebugLogger.init(self)
    ____exports.DebugLogger.Ainfo = vscode.window:createOutputChannel("LuaPanda Adapter")
    ____exports.DebugLogger.Dinfo = vscode.window:createOutputChannel("LuaPanda Debugger")
    ____exports.DebugLogger.Dinfo:appendLine("LuaPanda initializing...")
end
function DebugLogger.DebuggerInfo(self, str)
    if str ~= "" and str ~= nil then
        ____exports.DebugLogger.Dinfo:appendLine(str)
    end
end
function DebugLogger.AdapterInfo(self, str)
    if str ~= "" and str ~= nil then
        ____exports.DebugLogger.Ainfo:appendLine(str)
    end
end
function DebugLogger.showTips(self, str, level)
    if level == 2 then
        vscode.window:showErrorMessage(str)
    elseif level == 1 then
        vscode.window:showWarningMessage(str)
    else
        vscode.window:showInformationMessage(str)
    end
end
return ____exports
