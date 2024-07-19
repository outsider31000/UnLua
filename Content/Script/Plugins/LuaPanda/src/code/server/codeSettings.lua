local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.LogLevel = LogLevel or ({})
____exports.LogLevel.DEBUG = 0
____exports.LogLevel[____exports.LogLevel.DEBUG] = "DEBUG"
____exports.LogLevel.INFO = 1
____exports.LogLevel[____exports.LogLevel.INFO] = "INFO"
____exports.LogLevel.ERROR = 2
____exports.LogLevel[____exports.LogLevel.ERROR] = "ERROR"
____exports.CodeSettings = __TS__Class()
local CodeSettings = ____exports.CodeSettings
CodeSettings.name = "CodeSettings"
function CodeSettings.prototype.____constructor(self)
end
CodeSettings.logLevel = ____exports.LogLevel.INFO
CodeSettings.isOpenDebugCode = false
CodeSettings.isAllowDefJumpPreload = true
return ____exports
