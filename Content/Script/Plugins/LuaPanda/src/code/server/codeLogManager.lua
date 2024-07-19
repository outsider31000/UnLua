local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local ____codeSettings = require("Plugins.LuaPanda.src.code.server.codeSettings")
local CodeSettings = ____codeSettings.CodeSettings
local LogLevel = ____codeSettings.LogLevel
____exports.Logger = __TS__Class()
local Logger = ____exports.Logger
Logger.name = "Logger"
function Logger.prototype.____constructor(self)
end
function Logger.init(self)
end
function Logger.log(self, str, level)
    if not level then
        level = LogLevel.DEBUG
    end
    if str ~= "" and str ~= nil then
        if level == LogLevel.ERROR then
            self:ErrorLog(str)
        end
        if level == LogLevel.INFO then
            self:InfoLog(str)
        end
        if level == LogLevel.DEBUG then
            self:DebugLog(str)
        end
    end
end
function Logger.DebugLog(self, str)
    if CodeSettings.logLevel <= LogLevel.DEBUG then
        self.connection.console:log(str)
    end
end
function Logger.InfoLog(self, str)
    if CodeSettings.logLevel <= LogLevel.INFO then
        self.connection.console:log(str)
    end
end
function Logger.ErrorLog(self, str)
    if CodeSettings.logLevel <= LogLevel.ERROR then
        self.connection.console:log(str)
    end
end
return ____exports
