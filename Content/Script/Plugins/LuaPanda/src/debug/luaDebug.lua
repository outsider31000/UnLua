local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__New = ____lualib.__TS__New
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local __TS__Delete = ____lualib.__TS__Delete
local __TS__StringReplace = ____lualib.__TS__StringReplace
local __TS__ParseInt = ____lualib.__TS__ParseInt
local Map = ____lualib.Map
local __TS__ObjectDefineProperty = ____lualib.__TS__ObjectDefineProperty
local ____exports = {}
local vscode = require("Plugins.LuaPanda.src.debug.vscode")
local ____vscode_2Ddebugadapter = require("Plugins.LuaPanda.src.debug.vscode-debugadapter")
local LoggingDebugSession = ____vscode_2Ddebugadapter.LoggingDebugSession
local InitializedEvent = ____vscode_2Ddebugadapter.InitializedEvent
local TerminatedEvent = ____vscode_2Ddebugadapter.TerminatedEvent
local StoppedEvent = ____vscode_2Ddebugadapter.StoppedEvent
local BreakpointEvent = ____vscode_2Ddebugadapter.BreakpointEvent
local OutputEvent = ____vscode_2Ddebugadapter.OutputEvent
local Thread = ____vscode_2Ddebugadapter.Thread
local StackFrame = ____vscode_2Ddebugadapter.StackFrame
local Scope = ____vscode_2Ddebugadapter.Scope
local Source = ____vscode_2Ddebugadapter.Source
local Handles = ____vscode_2Ddebugadapter.Handles
local ____path = require("Plugins.LuaPanda.src.debug.path")
local basename = ____path.basename
local ____luaDebugRuntime = require("Plugins.LuaPanda.src.debug.luaDebugRuntime")
local LuaDebugRuntime = ____luaDebugRuntime.LuaDebugRuntime
local Net = require("Plugins.LuaPanda.src.debug.net")
local ____dataProcessor = require("Plugins.LuaPanda.src.debug.dataProcessor")
local DataProcessor = ____dataProcessor.DataProcessor
local ____logManager = require("Plugins.LuaPanda.src.common.logManager")
local DebugLogger = ____logManager.DebugLogger
local ____statusBarManager = require("Plugins.LuaPanda.src.common.statusBarManager")
local StatusBarManager = ____statusBarManager.StatusBarManager
local ____breakPoint = require("Plugins.LuaPanda.src.debug.breakPoint")
local LineBreakpoint = ____breakPoint.LineBreakpoint
local ConditionBreakpoint = ____breakPoint.ConditionBreakpoint
local LogPoint = ____breakPoint.LogPoint
local ____tools = require("Plugins.LuaPanda.src.common.tools")
local Tools = ____tools.Tools
local ____updateManager = require("Plugins.LuaPanda.src.debug.updateManager")
local UpdateManager = ____updateManager.UpdateManager
local ____threadManager = require("Plugins.LuaPanda.src.common.threadManager")
local ThreadManager = ____threadManager.ThreadManager
local ____pathManager = require("Plugins.LuaPanda.src.common.pathManager")
local PathManager = ____pathManager.PathManager
local ____visualSetting = require("Plugins.LuaPanda.src.debug.visualSetting")
local VisualSetting = ____visualSetting.VisualSetting
local ____require_result_0 = require("Plugins.LuaPanda.src.debug.await-notify")
local Subject = ____require_result_0.Subject
local fs = require("Plugins.LuaPanda.src.debug.fs")
____exports.LuaDebugSession = __TS__Class()
local LuaDebugSession = ____exports.LuaDebugSession
LuaDebugSession.name = "LuaDebugSession"
__TS__ClassExtends(LuaDebugSession, LoggingDebugSession)
function LuaDebugSession.prototype.____constructor(self)
    LoggingDebugSession.prototype.____constructor(self, "lua-debug.txt")
    self._configurationDone = __TS__New(Subject)
    self._variableHandles = __TS__New(Handles, 50000)
    self.UseLoadstring = false
    self._dbCheckBreakpoint = true
    self.connectionFlag = false
    self:setDebuggerLinesStartAt1(true)
    self:setDebuggerColumnsStartAt1(true)
    self._threadManager = __TS__New(ThreadManager)
    self._pathManager = __TS__New(PathManager, self, self.printLogInDebugConsole)
    self._runtime = __TS__New(LuaDebugRuntime)
    self._dataProcessor = __TS__New(DataProcessor)
    self._dataProcessor._runtime = self._runtime
    self._runtime._dataProcessor = self._dataProcessor
    self._runtime._pathManager = self._pathManager
    ____exports.LuaDebugSession._debugSessionArray:set(self._threadManager.CUR_THREAD_ID, self)
    self._runtime.TCPSplitChar = "|*|"
    self._runtime:on(
        "stopOnEntry",
        function()
            self:sendEvent(__TS__New(StoppedEvent, "entry", self._threadManager.CUR_THREAD_ID))
        end
    )
    self._runtime:on(
        "stopOnStep",
        function()
            self:sendEvent(__TS__New(StoppedEvent, "step", self._threadManager.CUR_THREAD_ID))
        end
    )
    self._runtime:on(
        "stopOnStepIn",
        function()
            self:sendEvent(__TS__New(StoppedEvent, "step", self._threadManager.CUR_THREAD_ID))
        end
    )
    self._runtime:on(
        "stopOnStepOut",
        function()
            self:sendEvent(__TS__New(StoppedEvent, "step", self._threadManager.CUR_THREAD_ID))
        end
    )
    self._runtime:on(
        "stopOnCodeBreakpoint",
        function()
            self:sendEvent(__TS__New(StoppedEvent, "breakpoint", self._threadManager.CUR_THREAD_ID))
        end
    )
    self._runtime:on(
        "stopOnBreakpoint",
        function()
            if self:checkIsRealHitBreakpoint() then
                self:sendEvent(__TS__New(StoppedEvent, "breakpoint", self._threadManager.CUR_THREAD_ID))
            else
                self._runtime:continueWithFakeHitBk(function()
                    DebugLogger:AdapterInfo("命中同名文件中的断点, 确认继续运行")
                end)
            end
        end
    )
    self._runtime:on(
        "stopOnException",
        function()
            self:sendEvent(__TS__New(StoppedEvent, "exception", self._threadManager.CUR_THREAD_ID))
        end
    )
    self._runtime:on(
        "stopOnPause",
        function()
            self:sendEvent(__TS__New(StoppedEvent, "exception", self._threadManager.CUR_THREAD_ID))
        end
    )
    self._runtime:on(
        "breakpointValidated",
        function(____, bp)
            self:sendEvent(__TS__New(BreakpointEvent, "changed", {verified = bp.verified, id = bp.id}))
        end
    )
    self._runtime:on(
        "logInDebugConsole",
        function(____, message)
            self:printLogInDebugConsole(message)
        end
    )
end
function LuaDebugSession.prototype.checkIsRealHitBreakpoint(self)
    if not self._dbCheckBreakpoint then
        return true
    end
    local steak = self._runtime.breakStack
    local steakPath = steak[1].file
    local steakLine = steak[1].line
    for ____, bkMap in __TS__Iterator(self.breakpointsArray) do
        if bkMap.bkPath == steakPath then
            for ____, node in __TS__Iterator(bkMap.bksArray) do
                if node.line == steakLine then
                    return true
                end
            end
        end
    end
    return false
end
function LuaDebugSession.prototype.printLogInDebugConsole(self, message, instance)
    if instance == nil then
        instance = self
    end
    instance:sendEvent(__TS__New(
        OutputEvent,
        tostring(message) .. "\n",
        "console"
    ))
end
function LuaDebugSession.prototype.initializeRequest(self, response, args)
    DebugLogger:AdapterInfo("initializeRequest!")
    response.body = response.body or ({})
    response.body.supportsConfigurationDoneRequest = true
    response.body.supportsEvaluateForHovers = true
    response.body.supportsStepBack = false
    response.body.supportsSetVariable = true
    response.body.supportsFunctionBreakpoints = false
    response.body.supportsConditionalBreakpoints = true
    response.body.supportsHitConditionalBreakpoints = true
    response.body.supportsLogPoints = true
    self:sendResponse(response)
end
function LuaDebugSession.prototype.configurationDoneRequest(self, response, args)
    LoggingDebugSession.prototype.configurationDoneRequest(self, response, args)
    self._configurationDone:notify()
end
function LuaDebugSession.prototype.attachRequest(self, response, args)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        __TS__Await(self._configurationDone:wait(1000))
        self:initProcess(response, args)
        self:sendResponse(response)
    end)
end
function LuaDebugSession.prototype.launchRequest(self, response, args)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        __TS__Await(self._configurationDone:wait(1000))
        self:initProcess(response, args)
        self:sendResponse(response)
    end)
end
function LuaDebugSession.prototype.copyAttachConfig(self, args)
    if args.tag == "attach" then
        if args.rootFolder then
            local settings = VisualSetting:readLaunchjson(args.rootFolder)
            for ____, launchValue in __TS__Iterator(settings.configurations) do
                if launchValue.tag == "normal" or launchValue.name == "LuaPanda" then
                    for key in pairs(launchValue) do
                        do
                            if key == "name" or key == "program" or args[key] then
                                goto __continue34
                            end
                            if key == "cwd" then
                                args[key] = launchValue[key]:replace(nil, args.rootFolder)
                                goto __continue34
                            end
                            args[key] = launchValue[key]
                        end
                        ::__continue34::
                    end
                end
            end
        end
    end
    return args
end
function LuaDebugSession.prototype.initProcess(self, response, args)
    local os = require("Plugins.LuaPanda.src.debug.os")
    local path = require("Plugins.LuaPanda.src.debug.path")
    self:copyAttachConfig(args)
    self.VSCodeAsClient = args.VSCodeAsClient
    self.connectionIP = args.connectionIP
    self.TCPPort = args.connectionPort
    self._pathManager.CWD = args.cwd
    self._pathManager.rootFolder = args.rootFolder
    self._pathManager.useAutoPathMode = not not args.autoPathMode
    self._pathManager.pathCaseSensitivity = not not args.pathCaseSensitivity
    self._dbCheckBreakpoint = not not args.dbCheckBreakpoint
    if self._pathManager.useAutoPathMode == true then
        Tools:rebuildAcceptExtMap(args.luaFileExtension)
        local isCWDExist = fs:existsSync(args.cwd)
        if not isCWDExist then
            vscode.window:showErrorMessage(
                ("[Error] launch.json 文件中 cwd 指向的路径 " .. tostring(args.cwd)) .. " 不存在，请修改后再次运行！",
                "好的"
            )
            return
        end
        self._pathManager:rebuildWorkspaceNamePathMap(args.cwd)
        self._pathManager:checkSameNameFile(not not args.distinguishSameNameFile)
    end
    if args.tag ~= "independent_file" then
        do
            local function ____catch(____error)
                DebugLogger:AdapterInfo("[Error] 检查升级信息失败，可选择后续手动升级。 https://github.com/Tencent/LuaPanda/blob/master/Docs/Manual/update.md ")
            end
            local ____try, ____hasReturned = pcall(function()
                __TS__New(UpdateManager):checkIfLuaPandaNeedUpdate(self._pathManager.LuaPandaPath, args.cwd)
            end)
            if not ____try then
                ____catch(____hasReturned)
            end
        end
    end
    local sendArgs = __TS__New(Array)
    sendArgs.stopOnEntry = not not args.stopOnEntry
    sendArgs.luaFileExtension = args.luaFileExtension
    sendArgs.cwd = args.cwd
    sendArgs.isNeedB64EncodeStr = not not args.isNeedB64EncodeStr
    sendArgs.TempFilePath = args.TempFilePath
    sendArgs.logLevel = args.logLevel
    sendArgs.pathCaseSensitivity = args.pathCaseSensitivity
    sendArgs.OSType = os:type()
    sendArgs.clibPath = Tools:getClibPathInExtension()
    sendArgs.useCHook = args.useCHook
    sendArgs.adapterVersion = String(nil, Tools.adapterVersion)
    sendArgs.autoPathMode = self._pathManager.useAutoPathMode
    sendArgs.distinguishSameNameFile = not not args.distinguishSameNameFile
    sendArgs.truncatedOPath = String(nil, args.truncatedOPath)
    sendArgs.DevelopmentMode = String(nil, args.DevelopmentMode)
    Tools.developmentMode = args.DevelopmentMode
    if __TS__InstanceOf(args.docPathReplace, Array) and args.docPathReplace.length == 2 then
        self.replacePath = __TS__New(
            Array,
            Tools:genUnifiedPath(String(nil, args.docPathReplace[0])),
            Tools:genUnifiedPath(String(nil, args.docPathReplace[1]))
        )
    else
        self.replacePath = nil
    end
    self.autoReconnect = args.autoReconnect
    StatusBarManager:reset()
    if self.VSCodeAsClient then
        self:printLogInDebugConsole((("[Connecting] 调试器 VSCode Client 已启动，正在尝试连接。  TargetName:" .. tostring(args.name)) .. " Port:") .. tostring(args.connectionPort))
        self:startClient(sendArgs)
    else
        self:printLogInDebugConsole((("[Listening] 调试器 VSCode Server 已启动，正在等待连接。  TargetName:" .. tostring(args.name)) .. " Port:") .. tostring(args.connectionPort))
        self:startServer(sendArgs)
    end
    self.breakpointsArray = __TS__New(Array)
    self:sendEvent(__TS__New(InitializedEvent))
    if args.tag == "independent_file" then
        local retObject = Tools:getVSCodeAvtiveFilePath()
        if retObject.retCode ~= 0 then
            DebugLogger:DebuggerInfo(retObject.retMsg)
            return
        end
        local filePath = retObject.filePath
        if self._debugFileTermianl then
            self._debugFileTermianl:dispose()
        end
        self._debugFileTermianl = vscode.window:createTerminal({name = "Debug Lua File (LuaPanda)", env = {}})
        local pathCMD = "'"
        local pathArr = Tools.VSCodeExtensionPath:split(path.sep)
        local stdPath = pathArr:join("/")
        pathCMD = (pathCMD .. tostring(stdPath)) .. "/Debugger/?.lua;"
        pathCMD = pathCMD .. tostring(args.packagePath:join(";"))
        pathCMD = pathCMD .. "'"
        pathCMD = (" \"package.path = " .. pathCMD) .. ".. package.path; "
        local reqCMD = ("require('LuaPanda').start('127.0.0.1'," .. tostring(self.TCPPort)) .. ");\" "
        local doFileCMD = filePath
        local runCMD = (pathCMD .. reqCMD) .. tostring(doFileCMD)
        local LuaCMD
        if args.luaPath and args.luaPath ~= "" then
            LuaCMD = tostring(args.luaPath) .. " -e "
        else
            LuaCMD = "lua -e "
        end
        self._debugFileTermianl:sendText(LuaCMD .. runCMD, true)
        self._debugFileTermianl:show()
    else
        if args.program ~= nil and args.program:trim() ~= "" then
            if fs:existsSync(args.program) and fs:statSync(args.program):isFile() then
                if self._programTermianl then
                    self._programTermianl:dispose()
                end
                self._programTermianl = vscode.window:createTerminal({name = "Run Program File (LuaPanda)", env = {}})
                local progaamCmdwithArgs = ("\"" .. tostring(args.program)) .. "\""
                if os:type() == "Windows_NT" then
                    progaamCmdwithArgs = "& " .. progaamCmdwithArgs
                end
                for ____, arg in __TS__Iterator(args.args) do
                    progaamCmdwithArgs = (progaamCmdwithArgs .. " ") .. tostring(arg)
                end
                self._programTermianl:sendText(progaamCmdwithArgs, true)
                self._programTermianl:show()
            else
                local progError = "[Warning] 配置文件 launch.json 中的 program 路径有误: \n"
                progError = progError .. " + program 配置项的作用是，在调试器开始运行时拉起一个可执行文件（注意不是lua文件）。"
                progError = progError .. "如无需此功能，建议 program 设置为 \"\" 或从 launch.json 中删除 program 项。\n"
                progError = progError .. (" + 当前设置的 " .. tostring(args.program)) .. " 不存在或不是一个可执行文件。"
                self:printLogInDebugConsole(progError)
            end
        end
    end
end
function LuaDebugSession.prototype.startServer(self, sendArgs)
    self.connectionFlag = false
    self._server = Net:createServer(function(____, socket)
        self._dataProcessor._socket = socket
        self._runtime:start(
            function(____, _, info)
                self.connectionFlag = true
                self._server:close()
                local connectMessage = (("[Connected] VSCode Server 已建立连接! Remote device info  " .. tostring(socket.remoteAddress)) .. ":") .. tostring(socket.remotePort)
                DebugLogger:AdapterInfo(connectMessage)
                self:printLogInDebugConsole(connectMessage)
                self:printLogInDebugConsole("[Tips] 当停止在断点处时，可在调试控制台输入要观察变量或执行表达式. ")
                if info.UseLoadstring == "1" then
                    self.UseLoadstring = true
                else
                    self.UseLoadstring = false
                end
                if info.isNeedB64EncodeStr == "true" then
                    self._dataProcessor.isNeedB64EncodeStr = true
                else
                    self._dataProcessor.isNeedB64EncodeStr = false
                end
                if info.UseHookLib == "1" then
                end
                for ____, bkMap in __TS__Iterator(self.breakpointsArray) do
                    self._runtime:setBreakPoint(bkMap.bkPath, bkMap.bksArray, nil, nil)
                end
            end,
            sendArgs
        )
        socket:on(
            "end",
            function()
                DebugLogger:AdapterInfo("socket end")
            end
        )
        socket:on(
            "close",
            function()
                if self.connectionFlag then
                    self.connectionFlag = false
                    DebugLogger:AdapterInfo("Socket close!")
                    vscode.window:showInformationMessage("[LuaPanda] 调试器已断开连接")
                    __TS__Delete(self._dataProcessor, "_socket")
                    self:sendEvent(__TS__New(TerminatedEvent, self.autoReconnect))
                end
            end
        )
        socket:on(
            "data",
            function(____, data)
                DebugLogger:AdapterInfo("[Get Msg]:" .. tostring(data))
                self._dataProcessor:processMsg(tostring(data))
            end
        )
    end):listen(
        self.TCPPort,
        0,
        function(self)
            DebugLogger:AdapterInfo("listening...")
            DebugLogger:DebuggerInfo("listening...")
        end
    )
end
function LuaDebugSession.prototype.startClient(self, sendArgs)
    local begingConnect
    function begingConnect(self, instance)
        instance._client = Net:createConnection(instance.TCPPort, instance.connectionIP)
        instance._client:setTimeout(800)
        instance._client:on(
            "connect",
            function()
                clearInterval(nil, instance.connectInterval)
                instance._dataProcessor._socket = instance._client
                instance._runtime:start(
                    function(____, _, info)
                        local connectMessage = "[Connected] VSCode Client 已建立连接!"
                        DebugLogger:AdapterInfo(connectMessage)
                        instance:printLogInDebugConsole(connectMessage)
                        instance:printLogInDebugConsole("[Tips] 当停止在断点处时，可在调试控制台输入要观察变量或执行表达式.")
                        if info.UseLoadstring == "1" then
                            instance.UseLoadstring = true
                        else
                            instance.UseLoadstring = false
                        end
                        if info.isNeedB64EncodeStr == "true" then
                            instance._dataProcessor.isNeedB64EncodeStr = true
                        else
                            instance._dataProcessor.isNeedB64EncodeStr = false
                        end
                        if info.UseHookLib == "1" then
                        end
                        for ____, bkMap in __TS__Iterator(instance.breakpointsArray) do
                            instance._runtime:setBreakPoint(bkMap.bkPath, bkMap.bksArray, nil, nil)
                        end
                    end,
                    sendArgs
                )
            end
        )
        instance._client:on(
            "end",
            function()
                DebugLogger:AdapterInfo("client end")
                vscode.window:showInformationMessage("[LuaPanda] 调试器已断开连接")
                __TS__Delete(instance._dataProcessor, "_socket")
                instance:sendEvent(__TS__New(TerminatedEvent, instance.autoReconnect))
            end
        )
        instance._client:on(
            "close",
            function()
            end
        )
        instance._client:on(
            "data",
            function(____, data)
                DebugLogger:AdapterInfo("[Get Msg]:" .. tostring(data))
                instance._dataProcessor:processMsg(tostring(data))
            end
        )
    end
    self.connectInterval = setInterval(nil, begingConnect, 1000, self)
end
function LuaDebugSession.prototype.setBreakPointsRequest(self, response, args)
    DebugLogger:AdapterInfo("setBreakPointsRequest")
    local path = args.source.path
    path = Tools:genUnifiedPath(path)
    if self.replacePath and self.replacePath.length == 2 then
        path = __TS__StringReplace(path, self.replacePath[1], self.replacePath[0])
    end
    local vscodeBreakpoints = __TS__New(Array)
    args.breakpoints:map(function(____, bp)
        local id = self._runtime:getBreakPointId()
        local breakpoint
        if bp.condition then
            breakpoint = __TS__New(
                ConditionBreakpoint,
                true,
                bp.line,
                bp.condition,
                id
            )
        elseif bp.logMessage then
            breakpoint = __TS__New(
                LogPoint,
                true,
                bp.line,
                bp.logMessage,
                id
            )
        else
            breakpoint = __TS__New(LineBreakpoint, true, bp.line, id)
        end
        vscodeBreakpoints[#vscodeBreakpoints + 1] = breakpoint
    end)
    response.body = {breakpoints = vscodeBreakpoints}
    if self.breakpointsArray == nil then
        self.breakpointsArray = __TS__New(Array)
    end
    local isbkPathExist = false
    for ____, bkMap in __TS__Iterator(self.breakpointsArray) do
        if bkMap.bkPath == path then
            bkMap.bksArray = vscodeBreakpoints
            isbkPathExist = true
        end
    end
    if not isbkPathExist then
        local bk = __TS__New(Object)
        bk.bkPath = path
        bk.bksArray = vscodeBreakpoints
        self.breakpointsArray:push(bk)
    end
    if self._dataProcessor._socket then
        local callbackArgs = __TS__New(Array)
        callbackArgs[#callbackArgs + 1] = self
        callbackArgs[#callbackArgs + 1] = response
        self._runtime:setBreakPoint(
            path,
            vscodeBreakpoints,
            function(self, arr)
                DebugLogger:AdapterInfo("确认断点")
                local ins = arr[0]
                ins:sendResponse(arr[1])
            end,
            callbackArgs
        )
    else
        self:sendResponse(response)
    end
end
function LuaDebugSession.prototype.stackTraceRequest(self, response, args)
    local ____temp_1
    if type(args.startFrame) == "number" then
        ____temp_1 = args.startFrame
    else
        ____temp_1 = 0
    end
    local startFrame = ____temp_1
    local ____temp_2
    if type(args.levels) == "number" then
        ____temp_2 = args.levels
    else
        ____temp_2 = 1000
    end
    local maxLevels = ____temp_2
    local endFrame = startFrame + maxLevels
    local stk = self._runtime:stack(startFrame, endFrame)
    response.body = {
        stackFrames = stk.frames:map(function(____, f)
            local source = f.file
            if self.replacePath and self.replacePath.length == 2 then
                source = source:replace(self.replacePath[0], self.replacePath[1])
            end
            return __TS__New(
                StackFrame,
                f.index,
                f.name,
                self:createSource(source),
                f.line
            )
        end),
        totalFrames = stk.count
    }
    self:sendResponse(response)
end
function LuaDebugSession.prototype.evaluateRequest(self, response, args)
    if args.context == "watch" or args.context == "hover" then
        local callbackArgs = __TS__New(Array)
        callbackArgs[#callbackArgs + 1] = self
        callbackArgs[#callbackArgs + 1] = response
        if self.UseLoadstring == false then
            local watchString = args.expression
            watchString = watchString:replace(nil, ".")
            watchString = watchString:replace(nil, "")
            watchString = watchString:replace(nil, "")
            watchString = watchString:replace(nil, "")
            args.expression = watchString
        end
        self._runtime:getWatchedVariable(
            function(____, arr, info)
                if info.length == 0 then
                    arr[1].body = {result = "未能查到变量的值", type = "string", variablesReference = 0}
                else
                    arr[1].body = {
                        result = info[0].value,
                        type = info[0].type,
                        variablesReference = __TS__ParseInt(info[0].variablesReference)
                    }
                end
                local ins = arr[0]
                ins:sendResponse(arr[1])
            end,
            callbackArgs,
            args.expression,
            args.frameId
        )
    elseif args.context == "repl" then
        local callbackArgs = __TS__New(Array)
        callbackArgs[#callbackArgs + 1] = self
        callbackArgs[#callbackArgs + 1] = response
        self._runtime:getREPLExpression(
            function(____, arr, info)
                if info.length == 0 then
                    arr[1].body = {result = "nil", variablesReference = 0}
                else
                    arr[1].body = {
                        result = info[0].value,
                        type = info[0].type,
                        variablesReference = __TS__ParseInt(info[0].variablesReference)
                    }
                end
                local ins = arr[0]
                ins:sendResponse(arr[1])
            end,
            callbackArgs,
            args.expression,
            args.frameId
        )
    else
        self:sendResponse(response)
    end
end
function LuaDebugSession.prototype.scopesRequest(self, response, args)
    local frameReference = args.frameId
    local scopes = __TS__New(Array)
    scopes[#scopes + 1] = __TS__New(
        Scope,
        "Local",
        self._variableHandles:create("10000_" .. tostring(frameReference)),
        false
    )
    scopes[#scopes + 1] = __TS__New(
        Scope,
        "Global",
        self._variableHandles:create("20000_" .. tostring(frameReference)),
        true
    )
    scopes[#scopes + 1] = __TS__New(
        Scope,
        "UpValue",
        self._variableHandles:create("30000_" .. tostring(frameReference)),
        false
    )
    response.body = {scopes = scopes}
    self:sendResponse(response)
end
function LuaDebugSession.prototype.setVariableRequest(self, response, args)
    local callbackArgs = __TS__New(Array)
    callbackArgs[#callbackArgs + 1] = self
    callbackArgs[#callbackArgs + 1] = response
    local referenceString = self._variableHandles:get(args.variablesReference)
    local referenceArray = {}
    if referenceString ~= nil then
        referenceArray = referenceString:split("_")
        if #referenceArray < 2 then
            DebugLogger:AdapterInfo("[variablesRequest Error] #referenceArray < 2 , #referenceArray = " .. tostring(#referenceArray))
            self:sendResponse(response)
            return
        end
    else
        referenceArray[1] = String(nil, args.variablesReference)
    end
    self._runtime:setVariable(
        function(____, arr, info)
            if info.success == "true" then
                arr[1].body = {
                    value = String(nil, info.value),
                    type = String(nil, info.type),
                    variablesReference = __TS__ParseInt(info.variablesReference)
                }
                DebugLogger:showTips(info.tip)
            else
                DebugLogger:showTips(("变量赋值失败 [" .. tostring(info.tip)) .. "]")
            end
            local ins = arr[0]
            ins:sendResponse(arr[1])
        end,
        callbackArgs,
        args.name,
        args.value,
        __TS__ParseInt(referenceArray[1]),
        __TS__ParseInt(referenceArray[2])
    )
end
function LuaDebugSession.prototype.variablesRequest(self, response, args)
    local callbackArgs = __TS__New(Array)
    callbackArgs[#callbackArgs + 1] = self
    callbackArgs[#callbackArgs + 1] = response
    local referenceString = self._variableHandles:get(args.variablesReference)
    local referenceArray = {}
    if referenceString ~= nil then
        referenceArray = referenceString:split("_")
        if #referenceArray < 2 then
            DebugLogger:AdapterInfo("[variablesRequest Error] #referenceArray < 2 , #referenceArray = " .. tostring(#referenceArray))
            self:sendResponse(response)
            return
        end
    else
        referenceArray[1] = String(nil, args.variablesReference)
    end
    self._runtime:getVariable(
        function(____, arr, info)
            if info == nil then
                info = __TS__New(Array)
            end
            local variables = __TS__New(Array)
            info:forEach(function(____, element)
                variables[#variables + 1] = {
                    name = element.name,
                    type = element.type,
                    value = element.value,
                    variablesReference = __TS__ParseInt(element.variablesReference)
                }
            end)
            arr[1].body = {variables = variables}
            local ins = arr[0]
            ins:sendResponse(arr[1])
        end,
        callbackArgs,
        __TS__ParseInt(referenceArray[1]),
        __TS__ParseInt(referenceArray[2])
    )
end
function LuaDebugSession.prototype.continueRequest(self, response, args)
    local callbackArgs = __TS__New(Array)
    callbackArgs[#callbackArgs + 1] = self
    callbackArgs[#callbackArgs + 1] = response
    self._runtime:continue(
        function(____, arr)
            DebugLogger:AdapterInfo("确认继续运行")
            local ins = arr[0]
            ins:sendResponse(arr[1])
        end,
        callbackArgs
    )
end
function LuaDebugSession.prototype.nextRequest(self, response, args)
    local callbackArgs = __TS__New(Array)
    callbackArgs[#callbackArgs + 1] = self
    callbackArgs[#callbackArgs + 1] = response
    self._runtime:step(
        function(____, arr)
            DebugLogger:AdapterInfo("确认单步")
            local ins = arr[0]
            ins:sendResponse(arr[1])
        end,
        callbackArgs
    )
end
function LuaDebugSession.prototype.stepInRequest(self, response, args)
    local callbackArgs = __TS__New(Array)
    callbackArgs[#callbackArgs + 1] = self
    callbackArgs[#callbackArgs + 1] = response
    self._runtime:step(
        function(____, arr)
            DebugLogger:AdapterInfo("确认StepIn")
            local ins = arr[0]
            ins:sendResponse(arr[1])
        end,
        callbackArgs,
        "stopOnStepIn"
    )
end
function LuaDebugSession.prototype.stepOutRequest(self, response, args)
    local callbackArgs = __TS__New(Array)
    callbackArgs[#callbackArgs + 1] = self
    callbackArgs[#callbackArgs + 1] = response
    self._runtime:step(
        function(____, arr)
            DebugLogger:AdapterInfo("确认StepOut")
            local ins = arr[0]
            ins:sendResponse(arr[1])
        end,
        callbackArgs,
        "stopOnStepOut"
    )
end
function LuaDebugSession.prototype.pauseRequest(self, response, args)
    vscode.window:showInformationMessage("pauseRequest!")
end
function LuaDebugSession.prototype.disconnectRequest(self, response, args)
    local disconnectMessage = "[Disconnect Request] 调试器已断开连接."
    DebugLogger:AdapterInfo(disconnectMessage)
    self:printLogInDebugConsole(disconnectMessage)
    local restart = args.restart
    if self.VSCodeAsClient then
        clearInterval(nil, self.connectInterval)
        local ____self_3 = self._client
        ____self_3["end"](____self_3)
    else
        local callbackArgs = __TS__New(Array)
        callbackArgs[#callbackArgs + 1] = restart
        self._runtime:stopRun(
            function(____, arr)
                DebugLogger:AdapterInfo("确认stop")
            end,
            callbackArgs,
            "stopRun"
        )
        self._server:close()
    end
    self._threadManager:destructor()
    ____exports.LuaDebugSession._debugSessionArray:delete(self._threadManager.CUR_THREAD_ID)
    self:sendResponse(response)
end
function LuaDebugSession.prototype.restartRequest(self, response, args)
    DebugLogger:AdapterInfo("restartRequest")
end
function LuaDebugSession.prototype.restartFrameRequest(self, response, args)
    DebugLogger:AdapterInfo("restartFrameRequest")
end
function LuaDebugSession.prototype.createSource(self, filePath)
    return __TS__New(
        Source,
        basename(nil, filePath),
        self:convertDebuggerPathToClient(filePath),
        nil,
        nil,
        nil
    )
end
function LuaDebugSession.prototype.threadsRequest(self, response)
    response.body = {threads = {__TS__New(
        Thread,
        self._threadManager.CUR_THREAD_ID,
        "thread " .. tostring(self._threadManager.CUR_THREAD_ID)
    )}}
    self:sendResponse(response)
end
function LuaDebugSession.prototype.LuaGarbageCollect(self)
    self._runtime:luaGarbageCollect()
end
LuaDebugSession._debugSessionArray = __TS__New(Map)
__TS__ObjectDefineProperty(
    LuaDebugSession,
    "debugSessionArray",
    {get = function(self)
        return ____exports.LuaDebugSession._debugSessionArray
    end}
)
return ____exports
