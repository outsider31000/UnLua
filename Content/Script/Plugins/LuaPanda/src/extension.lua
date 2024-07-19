local ____lualib = require("lualib_bundle")
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__New = ____lualib.__TS__New
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local showProgress, setRootFolders, showErrorMessage, showWarningMessage, showInformationMessage, LuaConfigurationProvider
local vscode = require("Plugins.LuaPanda.src.vscode")
local Net = require("Plugins.LuaPanda.src.net")
local path = require("Plugins.LuaPanda.src.path")
local ____luaDebug = require("Plugins.LuaPanda.src.debug.luaDebug")
local LuaDebugSession = ____luaDebug.LuaDebugSession
local ____logManager = require("Plugins.LuaPanda.src.common.logManager")
local DebugLogger = ____logManager.DebugLogger
local ____statusBarManager = require("Plugins.LuaPanda.src.common.statusBarManager")
local StatusBarManager = ____statusBarManager.StatusBarManager
local ____tools = require("Plugins.LuaPanda.src.common.tools")
local Tools = ____tools.Tools
local ____vscode_2Dlanguageclient = require("Plugins.LuaPanda.src.vscode-languageclient")
local LanguageClient = ____vscode_2Dlanguageclient.LanguageClient
local TransportKind = ____vscode_2Dlanguageclient.TransportKind
local ____vscode = require("Plugins.LuaPanda.src.vscode")
local workspace = ____vscode.workspace
local ____visualSetting = require("Plugins.LuaPanda.src.debug.visualSetting")
local VisualSetting = ____visualSetting.VisualSetting
local ____pathManager = require("Plugins.LuaPanda.src.common.pathManager")
local PathManager = ____pathManager.PathManager
function showProgress(self, message)
    StatusBarManager:showSetting(message)
end
function setRootFolders(self, ...)
    local rootFolders = {...}
    PathManager.rootFolderArray = rootFolders
end
function showErrorMessage(self, str)
    vscode.window:showErrorMessage(str)
end
function showWarningMessage(self, str)
    vscode.window:showWarningMessage(str)
end
function showInformationMessage(self, str)
    vscode.window:showInformationMessage(str)
end
local ____ = "use strict"
local client
function ____exports.activate(self, context)
    local reloadWindow = vscode.commands:registerCommand(
        "luapanda.reloadLuaDebug",
        function(self)
            vscode.commands:executeCommand("workbench.action.reloadWindow")
        end
    )
    context.subscriptions:push(reloadWindow)
    local LuaGarbageCollect = vscode.commands:registerCommand(
        "luapanda.LuaGarbageCollect",
        function(self)
            for ____, ____value in __TS__Iterator(LuaDebugSession.debugSessionArray) do
                local instance = ____value[2]
                instance:LuaGarbageCollect()
            end
            vscode.window:showInformationMessage("Lua Garbage Collect!")
        end
    )
    context.subscriptions:push(LuaGarbageCollect)
    local openSettingsPage = vscode.commands:registerCommand(
        "luapanda.openSettingsPage",
        function(self)
            do
                local function ____catch(____error)
                    DebugLogger:showTips("解析 launch.json 文件失败, 请检查此文件配置项是否异常, 或手动修改 launch.json 中的项目来完成配置!", 2)
                end
                local ____try, ____hasReturned = pcall(function()
                    local launchData = VisualSetting:getLaunchData(PathManager.rootFolderArray)
                    local panel = vscode.window:createWebviewPanel("LuaPanda Setting", "LuaPanda Setting", vscode.ViewColumn.One, {retainContextWhenHidden = true, enableScripts = true})
                    panel.webview.html = Tools:readFileContent(tostring(Tools.VSCodeExtensionPath) .. "/res/web/settings.html")
                    panel.webview:onDidReceiveMessage(
                        function(____, message)
                            VisualSetting:getWebMessage(message)
                        end,
                        nil,
                        context.subscriptions
                    )
                    panel.webview:postMessage(launchData)
                end)
                if not ____try then
                    ____catch(____hasReturned)
                end
            end
        end
    )
    context.subscriptions:push(openSettingsPage)
    local provider = __TS__New(LuaConfigurationProvider)
    context.subscriptions:push(vscode.debug:registerDebugConfigurationProvider("lua", provider))
    context.subscriptions:push(provider)
    local pkg = require(tostring(context.extensionPath) .. "/package.json")
    Tools.adapterVersion = pkg.version
    Tools.VSCodeExtensionPath = context.extensionPath
    DebugLogger:init()
    StatusBarManager:init()
    local serverModule = context:asAbsolutePath(path:join("out", "code", "server", "server.js"))
    local debugOptions = {execArgv = {"--nolazy", "--inspect=6009"}}
    local serverOptions = {run = {module = serverModule, transport = TransportKind.ipc}, debug = {module = serverModule, transport = TransportKind.ipc, options = debugOptions}}
    local clientOptions = {
        documentSelector = {{scheme = "file", language = "lua"}},
        synchronize = {fileEvents = workspace:createFileSystemWatcher("**/.clientrc")}
    }
    client = __TS__New(
        LanguageClient,
        "lua_analyzer",
        "Lua Analyzer",
        serverOptions,
        clientOptions
    )
    client:start()
    local ____self_0 = client:onReady()
    ____self_0["then"](
        ____self_0,
        function()
            Tools.client = client
            client:onNotification("setRootFolders", setRootFolders)
            client:onNotification("showProgress", showProgress)
            client:onNotification("showErrorMessage", showErrorMessage)
            client:onNotification("showWarningMessage", showWarningMessage)
            client:onNotification("showInformationMessage", showInformationMessage)
        end
    )
end
function ____exports.deactivate(self)
    if not client then
        return nil
    end
    Tools.client = nil
    return client:stop()
end
LuaConfigurationProvider = __TS__Class()
LuaConfigurationProvider.name = "LuaConfigurationProvider"
function LuaConfigurationProvider.prototype.____constructor(self)
end
function LuaConfigurationProvider.prototype.resolveDebugConfiguration(self, folder, config, token)
    if not config.type and not config.name then
        local editor = vscode.window.activeTextEditor
        if editor and editor.document.languageId == "lua" then
            vscode.window:showInformationMessage("请先正确配置launch文件!")
            config.type = "lua"
            config.name = "LuaPanda"
            config.request = "launch"
        end
    end
    if config.noDebug then
        local retObject = Tools:getVSCodeAvtiveFilePath()
        if retObject.retCode ~= 0 then
            DebugLogger:DebuggerInfo(retObject.retMsg)
            return
        end
        local filePath = retObject.filePath
        if LuaConfigurationProvider.RunFileTerminal then
            LuaConfigurationProvider.RunFileTerminal:dispose()
        end
        LuaConfigurationProvider.RunFileTerminal = vscode.window:createTerminal({name = "Run Lua File (LuaPanda)", env = {}})
        local path = require("Plugins.LuaPanda.src.path")
        local pathCMD = "'"
        local pathArr = Tools.VSCodeExtensionPath:split(path.sep)
        local stdPath = pathArr:join("/")
        pathCMD = (pathCMD .. tostring(stdPath)) .. "/Debugger/?.lua;"
        pathCMD = pathCMD .. tostring(config.packagePath:join(";"))
        pathCMD = pathCMD .. "'"
        pathCMD = (" \"package.path = " .. pathCMD) .. ".. package.path;\" "
        local doFileCMD = filePath
        local runCMD = pathCMD .. tostring(doFileCMD)
        local LuaCMD
        if config.luaPath and config.luaPath ~= "" then
            LuaCMD = tostring(config.luaPath) .. " -e "
        else
            LuaCMD = "lua -e "
        end
        LuaConfigurationProvider.RunFileTerminal:sendText(LuaCMD .. runCMD, true)
        LuaConfigurationProvider.RunFileTerminal:show()
        return
    end
    if config.tag == nil then
        if config.name == "LuaPanda" then
            config.tag = "normal"
        elseif config.name == "LuaPanda-Attach" then
            config.tag = "attach"
        elseif config.name == "LuaPanda-IndependentFile" or config.name == "LuaPanda-DebugFile" then
            config.tag = "independent_file"
        end
    end
    if config.tag == "independent_file" then
        if not config.internalConsoleOptions then
            config.internalConsoleOptions = "neverOpen"
        end
    else
        if not config.internalConsoleOptions then
            config.internalConsoleOptions = "openOnSessionStart"
        end
    end
    config.rootFolder = "${workspaceFolder}"
    if not config.TempFilePath then
        config.TempFilePath = "${workspaceFolder}"
    end
    if config.DevelopmentMode ~= true then
        config.DevelopmentMode = false
    end
    if config.tag ~= "attach" then
        if not config.program then
            config.program = ""
        end
        if config.packagePath == nil then
            config.packagePath = {}
        end
        if config.truncatedOPath == nil then
            config.truncatedOPath = ""
        end
        if config.distinguishSameNameFile == nil then
            config.distinguishSameNameFile = false
        end
        if config.dbCheckBreakpoint == nil then
            config.dbCheckBreakpoint = false
        end
        if not config.args then
            config.args = __TS__New(Array)
        end
        if config.autoPathMode == nil then
            config.autoPathMode = true
        end
        if not config.cwd then
            config.cwd = "${workspaceFolder}"
        end
        if not config.luaFileExtension then
            config.luaFileExtension = ""
        else
            local firseLetter = config.luaFileExtension:substr(0, 1)
            if firseLetter == "." then
                config.luaFileExtension = config.luaFileExtension:substr(1)
            end
        end
        if config.stopOnEntry == nil then
            config.stopOnEntry = true
        end
        if config.pathCaseSensitivity == nil then
            config.pathCaseSensitivity = false
        end
        if config.connectionPort == nil then
            config.connectionPort = 8818
        end
        if config.logLevel == nil then
            config.logLevel = 1
        end
        if config.autoReconnect ~= true then
            config.autoReconnect = false
        end
        if config.updateTips == nil then
            config.updateTips = true
        end
        if config.useCHook == nil then
            config.useCHook = true
        end
        if config.isNeedB64EncodeStr == nil then
            config.isNeedB64EncodeStr = true
        end
        if config.VSCodeAsClient == nil then
            config.VSCodeAsClient = false
        end
        if config.connectionIP == nil then
            config.connectionIP = "127.0.0.1"
        end
    end
    if not self._server then
        self._server = Net:createServer(function(____, socket)
            local session = __TS__New(LuaDebugSession)
            session:setRunAsServer(true)
            session:start(socket, socket)
        end):listen(0)
    end
    config.debugServer = self._server:address().port
    return config
end
function LuaConfigurationProvider.prototype.dispose(self)
    if self._server then
        self._server:close()
    end
end
return ____exports
