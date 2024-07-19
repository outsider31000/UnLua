local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__New = ____lualib.__TS__New
local __TS__ParseInt = ____lualib.__TS__ParseInt
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor
local ____exports = {}
local vscode = require("Plugins.LuaPanda.src.debug.vscode")
local ____events = require("Plugins.LuaPanda.src.debug.events")
local EventEmitter = ____events.EventEmitter
local ____logManager = require("Plugins.LuaPanda.src.common.logManager")
local DebugLogger = ____logManager.DebugLogger
local ____statusBarManager = require("Plugins.LuaPanda.src.common.statusBarManager")
local StatusBarManager = ____statusBarManager.StatusBarManager
____exports.LuaDebugRuntime = __TS__Class()
local LuaDebugRuntime = ____exports.LuaDebugRuntime
LuaDebugRuntime.name = "LuaDebugRuntime"
__TS__ClassExtends(LuaDebugRuntime, EventEmitter)
function LuaDebugRuntime.prototype.____constructor(self)
    EventEmitter.prototype.____constructor(self)
    self._breakpointId = 1
    self.breakStack = __TS__New(Array)
end
function LuaDebugRuntime.prototype.getBreakPointId(self)
    local ____self_0, ____breakpointId_1 = self, "_breakpointId"
    local ____self__breakpointId_2 = ____self_0[____breakpointId_1]
    ____self_0[____breakpointId_1] = ____self__breakpointId_2 + 1
    return ____self__breakpointId_2
end
function LuaDebugRuntime.prototype.start(self, callback, sendArgs)
    local arrSend = __TS__New(Object)
    for key in pairs(sendArgs) do
        arrSend[key] = String(nil, sendArgs[key])
    end
    self._dataProcessor:commandToDebugger("initSuccess", arrSend, callback)
end
function LuaDebugRuntime.prototype.continue(self, callback, callbackArgs, event)
    if event == nil then
        event = "continue"
    end
    DebugLogger:AdapterInfo("continue")
    local arrSend = __TS__New(Object)
    self._dataProcessor:commandToDebugger(event, arrSend, callback, callbackArgs)
end
function LuaDebugRuntime.prototype.continueWithFakeHitBk(self, callback, callbackArgs, event)
    if event == nil then
        event = "continue"
    end
    DebugLogger:AdapterInfo("continue")
    local arrSend = __TS__New(Object)
    arrSend.fakeBKPath = String(nil, self.breakStack[1].oPath)
    arrSend.fakeBKLine = String(nil, self.breakStack[1].line)
    arrSend.isFakeHit = String(nil, true)
    self._dataProcessor:commandToDebugger(event, arrSend, callback, callbackArgs)
end
function LuaDebugRuntime.prototype.getWatchedVariable(self, callback, callbackArgs, varName, frameId, event)
    if frameId == nil then
        frameId = 2
    end
    if event == nil then
        event = "getWatchedVariable"
    end
    DebugLogger:AdapterInfo("getWatchedVariable")
    local arrSend = __TS__New(Object)
    arrSend.varName = String(nil, varName)
    arrSend.stackId = String(nil, frameId)
    self._dataProcessor:commandToDebugger(event, arrSend, callback, callbackArgs)
end
function LuaDebugRuntime.prototype.getREPLExpression(self, callback, callbackArgs, expression, frameId, event)
    if frameId == nil then
        frameId = 2
    end
    if event == nil then
        event = "runREPLExpression"
    end
    DebugLogger:AdapterInfo("runREPLExpression")
    local arrSend = __TS__New(Object)
    arrSend.Expression = String(nil, expression)
    arrSend.stackId = String(nil, frameId)
    self._dataProcessor:commandToDebugger(event, arrSend, callback, callbackArgs)
end
function LuaDebugRuntime.prototype.setVariable(self, callback, callbackArgs, name, newValue, variableRef, frameId, event)
    if variableRef == nil then
        variableRef = 0
    end
    if frameId == nil then
        frameId = 2
    end
    if event == nil then
        event = "setVariable"
    end
    DebugLogger:AdapterInfo("setVariable")
    local arrSend = __TS__New(Object)
    arrSend.varRef = String(nil, variableRef)
    arrSend.stackId = String(nil, frameId)
    arrSend.newValue = String(nil, newValue)
    arrSend.varName = String(nil, name)
    self._dataProcessor:commandToDebugger(event, arrSend, callback, callbackArgs)
end
function LuaDebugRuntime.prototype.getVariable(self, callback, callbackArgs, variableRef, frameId, event)
    if variableRef == nil then
        variableRef = 0
    end
    if frameId == nil then
        frameId = 2
    end
    if event == nil then
        event = "getVariable"
    end
    DebugLogger:AdapterInfo("getVariable")
    local arrSend = __TS__New(Object)
    arrSend.varRef = String(nil, variableRef)
    arrSend.stackId = String(nil, frameId)
    self._dataProcessor:commandToDebugger(
        event,
        arrSend,
        callback,
        callbackArgs,
        3
    )
end
function LuaDebugRuntime.prototype.stopRun(self, callback, callbackArgs, event)
    if event == nil then
        event = "stopRun"
    end
    local arrSend = __TS__New(Object)
    self._dataProcessor:commandToDebugger(event, arrSend, callback, callbackArgs)
end
function LuaDebugRuntime.prototype.step(self, callback, callbackArgs, event)
    if event == nil then
        event = "stopOnStep"
    end
    DebugLogger:AdapterInfo("step:" .. event)
    local arrSend = __TS__New(Object)
    self._dataProcessor:commandToDebugger(event, arrSend, callback, callbackArgs)
end
function LuaDebugRuntime.prototype.luaGarbageCollect(self, event)
    if event == nil then
        event = "LuaGarbageCollect"
    end
    local arrSend = __TS__New(Object)
    self._dataProcessor:commandToDebugger(event, arrSend)
end
function LuaDebugRuntime.prototype.setBreakPoint(self, path, bks, callback, callbackArgs)
    DebugLogger:AdapterInfo(("setBreakPoint " .. " path:") .. path)
    local arrSend = __TS__New(Object)
    arrSend.path = path
    arrSend.bks = bks
    self._dataProcessor:commandToDebugger("setBreakPoint", arrSend, callback, callbackArgs)
end
function LuaDebugRuntime.prototype.stack(self, startFrame, endFrame)
    return {frames = self.breakStack, count = #self.breakStack}
end
function LuaDebugRuntime.prototype.printLog(self, logStr)
    DebugLogger:DebuggerInfo("[Debugger Log]:" .. logStr)
end
function LuaDebugRuntime.prototype.refreshLuaMemoty(self, luaMemory)
    StatusBarManager:refreshLuaMemNum(__TS__ParseInt(luaMemory))
end
function LuaDebugRuntime.prototype.showTip(self, tip)
    vscode.window:showInformationMessage(tip)
end
function LuaDebugRuntime.prototype.showError(self, tip)
    vscode.window:showErrorMessage(tip)
end
function LuaDebugRuntime.prototype.logInDebugConsole(self, message)
    self:sendEvent("logInDebugConsole", message)
end
function LuaDebugRuntime.prototype.stop(self, stack, reason)
    stack:forEach(function(____, element)
        local linenum = element.line
        element.line = __TS__ParseInt(linenum)
        local getinfoPath = element.file
        local oPath = element.oPath
        element.file = self._pathManager:checkFullPath(getinfoPath, oPath)
    end)
    self.breakStack = stack
    self:sendEvent(reason)
end
function LuaDebugRuntime.prototype.sendEvent(self, event, ...)
    local args = {...}
    setImmediate(
        nil,
        function(____, _)
            self:emit(
                event,
                table.unpack(args)
            )
        end
    )
end
__TS__SetDescriptor(
    LuaDebugRuntime.prototype,
    "sourceFile",
    {
        get = function(self)
            return self._sourceFile
        end,
        set = function(self, char)
            self._TCPSplitChar = char
        end
    },
    true
)
return ____exports
