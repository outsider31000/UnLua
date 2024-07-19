local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__StringTrim = ____lualib.__TS__StringTrim
local __TS__StringSubstring = ____lualib.__TS__StringSubstring
local __TS__ArraySplice = ____lualib.__TS__ArraySplice
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local ____logManager = require("Plugins.LuaPanda.src.common.logManager")
local DebugLogger = ____logManager.DebugLogger
____exports.DataProcessor = __TS__Class()
local DataProcessor = ____exports.DataProcessor
DataProcessor.name = "DataProcessor"
function DataProcessor.prototype.____constructor(self)
    self.isNeedB64EncodeStr = true
    self.orderList = __TS__New(Array)
    self.recvMsgQueue = __TS__New(Array)
    self.cutoffString = ""
    self.getDataJsonCatch = ""
end
function DataProcessor.prototype.processMsg(self, orgData)
    local data = __TS__StringTrim(orgData)
    if #self.cutoffString > 0 then
        data = self.cutoffString .. data
        self.cutoffString = ""
    end
    local pos = (string.find(data, self._runtime.TCPSplitChar, nil, true) or 0) - 1
    if pos < 0 then
        self:processCutoffMsg(data)
    else
        repeat
            do
                local data_save = __TS__StringSubstring(data, 0, pos)
                data = __TS__StringSubstring(data, pos + #self._runtime.TCPSplitChar, #data)
                local ____self_recvMsgQueue_0 = self.recvMsgQueue
                ____self_recvMsgQueue_0[#____self_recvMsgQueue_0 + 1] = data_save
                pos = (string.find(data, self._runtime.TCPSplitChar, nil, true) or 0) - 1
                if pos < 0 then
                    self:processCutoffMsg(data)
                end
            end
        until not (pos > 0)
        while #self.recvMsgQueue > 0 do
            local dt1 = table.remove(self.recvMsgQueue, 1)
            self:getData(String(nil, dt1))
        end
    end
    do
        local index = 0
        while index < #self.orderList do
            local element = self.orderList[index + 1]
            if element.timeOut and Date:now() > element.timeOut then
                local cb = element.callback
                cb(nil, element.callbackArgs)
                __TS__ArraySplice(self.orderList, index, 1)
            end
            index = index + 1
        end
    end
end
function DataProcessor.prototype.processCutoffMsg(self, orgData)
    local data = __TS__StringTrim(orgData)
    if #data > 0 then
        self.cutoffString = self.cutoffString .. data
    end
end
function DataProcessor.prototype.getData(self, data)
    local cmdInfo
    do
        local function ____catch(e)
            if self.isNeedB64EncodeStr then
                self._runtime:showError(" JSON  解析失败! " .. data)
                DebugLogger:AdapterInfo("[Adapter Error]: JSON  解析失败! " .. data)
            else
                self.getDataJsonCatch = data .. "|*|"
            end
            return true
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            if self.getDataJsonCatch ~= "" then
                data = self.getDataJsonCatch .. data
            end
            cmdInfo = JSON:parse(data)
            if self.isNeedB64EncodeStr and cmdInfo.info ~= nil then
                do
                    local i = 0
                    local len = cmdInfo.info.length
                    while i < len do
                        if cmdInfo.info[i].type == "string" then
                            cmdInfo.info[i].value = tostring(Buffer:from(cmdInfo.info[i].value, "base64"))
                        end
                        i = i + 1
                    end
                end
            end
            self.getDataJsonCatch = ""
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
    if self._runtime ~= nil then
        if cmdInfo == nil then
            self._runtime:showError("JSON 解析失败! no cmdInfo:" .. data)
            DebugLogger:AdapterInfo("[Adapter Error]:JSON解析失败  no cmdInfo:" .. data)
            return
        end
        if cmdInfo.cmd == nil then
            self._runtime:showError("JSON 解析失败! no cmd:" .. data)
            DebugLogger:AdapterInfo("[Adapter Warning]:JSON 解析失败 no cmd:" .. data)
        end
        if cmdInfo.callbackId ~= nil and cmdInfo.callbackId ~= "0" then
            do
                local index = 0
                while index < #self.orderList do
                    local element = self.orderList[index + 1]
                    if element.callbackId == cmdInfo.callbackId then
                        local cb = element.callback
                        if cmdInfo.info ~= nil then
                            cb(nil, element.callbackArgs, cmdInfo.info)
                        else
                            cb(nil, element.callbackArgs)
                        end
                        __TS__ArraySplice(self.orderList, index, 1)
                        return
                    end
                    index = index + 1
                end
            end
            DebugLogger:AdapterInfo("[Adapter Error]: 没有在列表中找到回调")
        else
            repeat
                local ____switch32 = cmdInfo.cmd
                local stackInfo, outputLog, consoleLog
                local ____cond32 = ____switch32 == "refreshLuaMemory"
                if ____cond32 then
                    self._runtime:refreshLuaMemoty(cmdInfo.info.memInfo)
                    break
                end
                ____cond32 = ____cond32 or ____switch32 == "tip"
                if ____cond32 then
                    self._runtime:showTip(cmdInfo.info.logInfo)
                    break
                end
                ____cond32 = ____cond32 or ____switch32 == "tipError"
                if ____cond32 then
                    self._runtime:showError(cmdInfo.info.logInfo)
                    break
                end
                ____cond32 = ____cond32 or (____switch32 == "stopOnCodeBreakpoint" or ____switch32 == "stopOnBreakpoint" or ____switch32 == "stopOnEntry" or ____switch32 == "stopOnStep" or ____switch32 == "stopOnStepIn" or ____switch32 == "stopOnStepOut")
                if ____cond32 then
                    stackInfo = cmdInfo.stack
                    self._runtime:stop(stackInfo, cmdInfo.cmd)
                    break
                end
                ____cond32 = ____cond32 or ____switch32 == "output"
                if ____cond32 then
                    outputLog = cmdInfo.info.logInfo
                    if outputLog ~= nil then
                        self._runtime:printLog(outputLog)
                    end
                    break
                end
                ____cond32 = ____cond32 or ____switch32 == "debug_console"
                if ____cond32 then
                    consoleLog = cmdInfo.info.logInfo
                    if consoleLog ~= nil then
                        self._runtime:logInDebugConsole(consoleLog)
                    end
                    break
                end
            until true
        end
    end
end
function DataProcessor.prototype.commandToDebugger(self, cmd, sendObject, callbackFunc, callbackArgs, timeOutSec)
    if timeOutSec == nil then
        timeOutSec = 0
    end
    local max = 999999999
    local min = 10
    local isSame = false
    local ranNum = 0
    local sendObj = __TS__New(Object)
    if callbackFunc ~= nil then
        repeat
            do
                isSame = false
                ranNum = math.floor(math.random() * (max - min + 1) + min)
                __TS__ArrayForEach(
                    self.orderList,
                    function(____, element)
                        if element.callbackId == ranNum then
                            isSame = true
                        end
                    end
                )
            end
        until not isSame
        local dic = __TS__New(Object)
        dic.callbackId = ranNum
        dic.callback = callbackFunc
        if timeOutSec > 0 then
            dic.timeOut = Date:now() + timeOutSec * 1000
        end
        if callbackArgs ~= nil then
            dic.callbackArgs = callbackArgs
        end
        local ____self_orderList_1 = self.orderList
        ____self_orderList_1[#____self_orderList_1 + 1] = dic
        sendObj.callbackId = tostring(ranNum)
    end
    sendObj.cmd = cmd
    sendObj.info = sendObject
    local str = ((JSON:stringify(sendObj) .. " ") .. self._runtime.TCPSplitChar) .. "\n"
    if self._socket ~= nil then
        DebugLogger:AdapterInfo("[Send Msg]:" .. str)
        self._socket:write(str)
    else
        DebugLogger:AdapterInfo("[Send Msg but socket deleted]:" .. str)
    end
end
return ____exports
