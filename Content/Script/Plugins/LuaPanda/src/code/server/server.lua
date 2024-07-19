local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local Map = ____lualib.Map
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__Promise = ____lualib.__TS__Promise
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys
local ____exports = {}
local getDocumentSettings, validateTextDocument, connection, hasConfigurationCapability, globalSettings, documentSettings
local ____vscode_2Dlanguageserver = require("Plugins.LuaPanda.src.code.server.vscode-languageserver")
local createConnection = ____vscode_2Dlanguageserver.createConnection
local TextDocuments = ____vscode_2Dlanguageserver.TextDocuments
local ProposedFeatures = ____vscode_2Dlanguageserver.ProposedFeatures
local DidChangeConfigurationNotification = ____vscode_2Dlanguageserver.DidChangeConfigurationNotification
local fs = require("Plugins.LuaPanda.src.code.server.fs")
local Tools = require("Plugins.LuaPanda.src.code.server.codeTools")
local ____codeLogManager = require("Plugins.LuaPanda.src.code.server.codeLogManager")
local Logger = ____codeLogManager.Logger
local ____codeSymbol = require("Plugins.LuaPanda.src.code.server.codeSymbol")
local CodeSymbol = ____codeSymbol.CodeSymbol
local ____codeDefinition = require("Plugins.LuaPanda.src.code.server.codeDefinition")
local CodeDefinition = ____codeDefinition.CodeDefinition
local ____codeCompletion = require("Plugins.LuaPanda.src.code.server.codeCompletion")
local CodeCompletion = ____codeCompletion.CodeCompletion
local ____codeEditor = require("Plugins.LuaPanda.src.code.server.codeEditor")
local CodeEditor = ____codeEditor.CodeEditor
local ____codeFormat = require("Plugins.LuaPanda.src.code.server.codeFormat")
local CodeFormat = ____codeFormat.CodeFormat
local ____codeLinting = require("Plugins.LuaPanda.src.code.server.codeLinting")
local CodeLinting = ____codeLinting.CodeLinting
local ____codeReference = require("Plugins.LuaPanda.src.code.server.codeReference")
local CodeReference = ____codeReference.CodeReference
local ____nativeCodeExportBase = require("Plugins.LuaPanda.src.code.server.codeExport.nativeCodeExportBase")
local NativeCodeExportBase = ____nativeCodeExportBase.NativeCodeExportBase
function getDocumentSettings(self, resource)
    if not hasConfigurationCapability then
        return __TS__Promise.resolve(globalSettings)
    end
    local result = documentSettings:get(resource)
    if not result then
        result = connection.workspace:getConfiguration({scopeUri = resource, section = "lua_analyzer"})
        documentSettings:set(resource, result)
    end
    return result
end
function validateTextDocument(self, textDocument)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
        local settings = __TS__Await(getDocumentSettings(nil, textDocument.uri))
        if settings.codeLinting.enable == false then
            connection:sendDiagnostics({uri = textDocument.uri, diagnostics = {}})
            return ____awaiter_resolve(nil)
        end
        local ignoreFolderRegExpArray = settings.codeLinting.ignoreFolderRegularExpression:split(";")
        if ignoreFolderRegExpArray.length > 0 then
            if Tools:isMatchedIgnoreRegExp(textDocument.uri, ignoreFolderRegExpArray) then
                connection:sendDiagnostics({uri = textDocument.uri, diagnostics = {}})
                return ____awaiter_resolve(nil)
            end
        end
        local globalSymbols = CodeSymbol:getWorkspaceSymbols(Tools.SearchRange.GlobalSymbols)
        local globalVariables = __TS__ObjectKeys(globalSymbols)
        local luacheckProcess = CodeLinting:processLinting(textDocument, settings, globalVariables)
        luacheckProcess["then"](
            luacheckProcess,
            function()
                connection:sendDiagnostics({uri = textDocument.uri, diagnostics = {}})
            end,
            function(____, luaErrorOrWaining)
                local diagnosticArray = CodeLinting:parseLuacheckResult(luaErrorOrWaining, settings)
                connection:sendDiagnostics({uri = textDocument.uri, diagnostics = diagnosticArray})
            end
        ):catch(function()
            connection:sendDiagnostics({uri = textDocument.uri, diagnostics = {}})
        end)
    end)
end
local path = require("Plugins.LuaPanda.src.code.server.path")
connection = createConnection(nil, ProposedFeatures.all)
local documents = __TS__New(TextDocuments)
hasConfigurationCapability = false
local hasWorkspaceFolderCapability = false
local analyzerTotalSwitch = true
local defaultSettings = {codeLinting = {
    enable = true,
    luacheckPath = "",
    luaVersion = "5.1",
    checkWhileTyping = true,
    checkAfterSave = true,
    maxNumberOfProblems = 100,
    maxLineLength = 120,
    ignoreFolderRegularExpression = ".*/res/lua/\\w+\\.lua;.*vscode/LuaPanda/IntelliSenseRes/;",
    ignoreErrorCode = "",
    ignoreGlobal = ""
}}
globalSettings = defaultSettings
documentSettings = __TS__New(Map)
connection:onInitialize(function(____, initPara)
    local capabilities = initPara.capabilities
    Tools:setInitPara(initPara)
    Tools:setToolsConnection(connection)
    Logger.connection = connection
    hasConfigurationCapability = not not (capabilities.workspace and not not capabilities.workspace.configuration)
    hasWorkspaceFolderCapability = not not (capabilities.workspace and not not capabilities.workspace.workspaceFolders)
    Tools:setVScodeExtensionPath(path:dirname(path:dirname(path:dirname(__dirname))))
    Tools:initLoadedExt()
    local snippetsPath = tostring(Tools:getVScodeExtensionPath()) .. "/res/snippets/snippets.json"
    local snipContent = fs:readFileSync(snippetsPath)
    setImmediate(
        nil,
        function()
            connection:sendNotification(
                "setRootFolders",
                Tools:getVSCodeOpenedFolders()
            )
        end
    )
    if tostring(snipContent):trim() == "" then
        analyzerTotalSwitch = false
        setImmediate(
            nil,
            function()
                connection:sendNotification("showProgress", "LuaPanda")
            end
        )
        Logger:InfoLog("LuaAnalyzer closed!")
        return {capabilities = {}}
    end
    for ____, folder in ipairs(Tools:getVSCodeOpenedFolders()) do
        CodeSymbol:createSymbolswithExt("lua", folder)
        CodeSymbol:createSymbolswithExt("lua.bytes", folder)
    end
    setTimeout(nil, Tools.refresh_FileName_Uri_Cache, 0)
    local resLuaPath = tostring(Tools:getVScodeExtensionPath()) .. "/res/lua"
    CodeSymbol:createLuaPreloadSymbols(resLuaPath)
    NativeCodeExportBase:loadIntelliSenseRes()
    Logger:InfoLog("LuaAnalyzer init success!")
    return {capabilities = {
        documentSymbolProvider = true,
        workspaceSymbolProvider = true,
        definitionProvider = true,
        referencesProvider = false,
        documentFormattingProvider = true,
        documentRangeFormattingProvider = false,
        documentHighlightProvider = false,
        textDocumentSync = documents.syncKind,
        completionProvider = {
            triggerCharacters = __TS__StringSplit("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:", ""),
            resolveProvider = false
        },
        renameProvider = false,
        colorProvider = false
    }}
end)
connection:onNotification(
    "preAnalysisCpp",
    function(____, message)
        local msgObj = JSON:parse(message)
        local anaPath = msgObj.path
        NativeCodeExportBase:processNativeCodeDir(anaPath)
    end
)
connection:onInitialized(function()
    if hasConfigurationCapability then
        connection.client:register(DidChangeConfigurationNotification.type, nil)
    end
    if hasWorkspaceFolderCapability then
        connection.workspace:onDidChangeWorkspaceFolders(function(____, _event)
            Logger:DebugLog("Workspace folder change event received.")
            if _event.added.length > 0 then
                Tools:addOpenedFolder(_event.added)
                for ____, folder in ipairs(Tools:getVSCodeOpenedFolders()) do
                    CodeSymbol:refreshFolderSymbols(folder)
                end
            end
            if _event.removed.length > 0 then
                Tools:removeOpenedFolder(_event.removed)
            end
            setTimeout(nil, Tools.refresh_FileName_Uri_Cache, 0)
        end)
    end
end)
connection:onDocumentFormatting(function(____, handler)
    local uri = Tools:urlDecode(handler.textDocument.uri)
    local retCode = CodeFormat:format(uri)
    return retCode
end)
connection:onDidChangeConfiguration(function(____, change)
    if hasConfigurationCapability then
        documentSettings:clear()
    else
        globalSettings = change.settings.lua_analyzer or defaultSettings
    end
    documents:all():forEach(validateTextDocument)
end)
documents:onDidClose(function(____, e)
    documentSettings:delete(e.document.uri)
end)
connection:onCompletion(function(____, _textDocumentPosition)
    local uri = Tools:urlDecode(_textDocumentPosition.textDocument.uri)
    local pos = _textDocumentPosition.position
    do
        local function ____catch(____error)
            Logger:ErrorLog("[Error] onCompletion " .. tostring(____error.stack))
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            return true, CodeCompletion:completionEntry(uri, pos)
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end)
connection:onReferences(function(____, handler)
    return CodeReference:getSymbalReferences(handler)
end)
connection:onDefinition(function(____, handler)
    handler.textDocument.uri = Tools:urlDecode(handler.textDocument.uri)
    do
        local function ____catch(____error)
            Logger:ErrorLog("[Error] onDefinition " .. tostring(____error.stack))
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            return true, CodeDefinition:getSymbalDefine(handler)
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end)
connection:onDocumentSymbol(function(____, handler)
    local uri = handler.textDocument.uri
    local decUri = Tools:urlDecode(uri)
    local retSyms = CodeSymbol:getOneDocSymbolsArray(decUri, nil, Tools.SearchRange.AllSymbols)
    local retSymsArr
    do
        local function ____catch(____error)
            Logger:DebugLog((("error detected while processing outline symbols, error: " .. tostring(____error)) .. "\nstack:\n") .. tostring(____error.stack))
            retSymsArr = Tools:changeDicSymboltoArray(retSyms)
        end
        local ____try, ____hasReturned = pcall(function()
            retSymsArr = Tools:getOutlineSymbol(retSyms)
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
    return retSymsArr
end)
connection:onWorkspaceSymbol(function(____, handler)
    do
        local function ____catch(____error)
            Logger:ErrorLog("[Error] onWorkspaceSymbol " .. tostring(____error.stack))
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            local userInput = handler.query
            return true, CodeSymbol:searchSymbolinWorkSpace(userInput)
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end)
documents:onDidOpen(function(____, file)
    if file.document.languageId == "lua" and analyzerTotalSwitch then
        do
            local function ____catch(____error)
                Logger:ErrorLog("[Error] onDidOpen " .. tostring(____error.stack))
            end
            local ____try, ____hasReturned, ____returnValue = pcall(function()
                local uri = Tools:urlDecode(file.document.uri)
                local luaExtname = Tools:getPathNameAndExt(uri)
                local ext = luaExtname.ext
                local loadedExt = Tools:getLoadedExt()
                if loadedExt and loadedExt[ext] == true then
                    return true
                else
                    for ____, folder in ipairs(Tools:getVSCodeOpenedFolders()) do
                        CodeSymbol:createSymbolswithExt(ext, folder)
                    end
                    setTimeout(nil, Tools.refresh_FileName_Uri_Cache, 0)
                end
            end)
            if not ____try then
                ____hasReturned, ____returnValue = ____catch(____hasReturned)
            end
            if ____hasReturned then
                return ____returnValue
            end
        end
    end
end)
documents:onDidChangeContent(function(____, change)
    if change.document.languageId == "lua" and analyzerTotalSwitch then
        do
            local function ____catch(____error)
                Logger:ErrorLog("[Error] onDidChangeContent " .. tostring(____error.stack))
            end
            local ____try, ____hasReturned = pcall(function()
                local uri = Tools:urlDecode(change.document.uri)
                local text = change.document:getText()
                CodeEditor:saveCode(uri, text)
                if not Tools:isinPreloadFolder(uri) then
                    CodeSymbol:refreshOneDocSymbols(uri, text)
                else
                    CodeSymbol:refreshOneUserPreloadDocSymbols(Tools:uriToPath(uri))
                end
                local ____self_0 = getDocumentSettings(nil, uri)
                ____self_0["then"](
                    ____self_0,
                    function(____, settings)
                        if settings.codeLinting.checkWhileTyping == true then
                            validateTextDocument(nil, change.document)
                        end
                    end
                )
            end)
            if not ____try then
                ____catch(____hasReturned)
            end
        end
    end
end)
documents:onDidSave(function(____, change)
    if not analyzerTotalSwitch then
        return
    end
    do
        local function ____catch(____error)
            Logger:ErrorLog("[Error] onDidSave " .. tostring(____error.stack))
        end
        local ____try, ____hasReturned = pcall(function()
            local ____self_1 = getDocumentSettings(nil, change.document.uri)
            ____self_1["then"](
                ____self_1,
                function(____, settings)
                    if settings.codeLinting.checkAfterSave == true then
                        validateTextDocument(nil, change.document)
                    end
                end
            )
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end)
connection:onDocumentColor(function(____, handler)
    return __TS__New(Array)
end)
connection:onColorPresentation(function(____, handler)
    return __TS__New(Array)
end)
connection:onDocumentHighlight(function(____, handler)
    return __TS__New(Array)
end)
documents:listen(connection)
connection:listen()
return ____exports
