local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local BreakpointType = BreakpointType or ({})
BreakpointType.conditionBreakpoint = 0
BreakpointType[BreakpointType.conditionBreakpoint] = "conditionBreakpoint"
BreakpointType.logPoint = 1
BreakpointType[BreakpointType.logPoint] = "logPoint"
BreakpointType.lineBreakpoint = 2
BreakpointType[BreakpointType.lineBreakpoint] = "lineBreakpoint"
____exports.LineBreakpoint = __TS__Class()
local LineBreakpoint = ____exports.LineBreakpoint
LineBreakpoint.name = "LineBreakpoint"
function LineBreakpoint.prototype.____constructor(self, verified, line, id, column)
    self.verified = verified
    self.type = BreakpointType.lineBreakpoint
    self.line = line
end
____exports.ConditionBreakpoint = __TS__Class()
local ConditionBreakpoint = ____exports.ConditionBreakpoint
ConditionBreakpoint.name = "ConditionBreakpoint"
function ConditionBreakpoint.prototype.____constructor(self, verified, line, condition, id)
    self.verified = verified
    self.type = BreakpointType.conditionBreakpoint
    self.line = line
    self.condition = condition
end
____exports.LogPoint = __TS__Class()
local LogPoint = ____exports.LogPoint
LogPoint.name = "LogPoint"
function LogPoint.prototype.____constructor(self, verified, line, logMessage, id)
    self.verified = verified
    self.type = BreakpointType.logPoint
    self.line = line
    self.logMessage = logMessage
end
return ____exports
