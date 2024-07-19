local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__Promise = ____lualib.__TS__Promise
local __TS__New = ____lualib.__TS__New
local Map = ____lualib.Map
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ArrayPush = ____lualib.__TS__ArrayPush
local __TS__ParseInt = ____lualib.__TS__ParseInt
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local ____exports = {}
local ____vscode_2Dlanguageserver = require("Plugins.LuaPanda.src.code.server.vscode-languageserver")
local DiagnosticSeverity = ____vscode_2Dlanguageserver.DiagnosticSeverity
local Range = ____vscode_2Dlanguageserver.Range
local Tools = require("Plugins.LuaPanda.src.code.server.codeTools")
local ____child_process = require("Plugins.LuaPanda.src.code.server.child_process")
local spawnSync = ____child_process.spawnSync
local os = require("Plugins.LuaPanda.src.code.server.os")
____exports.CodeLinting = __TS__Class()
local CodeLinting = ____exports.CodeLinting
CodeLinting.name = "CodeLinting"
function CodeLinting.prototype.____constructor(self)
end
function CodeLinting.processLinting(self, textDocument, settings, globalVariables)
    local fileName = Tools:uriToPath(Tools:urlDecode(textDocument.uri))
    local luacheck = self:getLuacheck(settings)
    local luacheckArgs = self:getLuacheckArgs(settings, fileName, globalVariables)
    local fileContent = textDocument:getText()
    local luacheckProcess = __TS__New(
        __TS__Promise,
        function(____, resolve, reject)
            local checkResult = spawnSync(nil, luacheck, luacheckArgs, {input = fileContent})
            if checkResult.status == 1 or checkResult.status == 2 then
                reject(
                    nil,
                    checkResult.output:join("\n")
                )
            elseif checkResult.status == 0 then
                resolve(nil)
            else
                resolve(nil)
            end
        end
    )
    return luacheckProcess
end
function CodeLinting.getLuacheck(self, settings)
    local luacheck = settings.codeLinting.luacheckPath
    if luacheck ~= "" then
        return luacheck
    end
    if os:type() == "Windows_NT" then
        luacheck = tostring(Tools:getVScodeExtensionPath()) .. "/res/luacheck/luacheck.exe"
    else
        luacheck = "/usr/local/bin/luacheck"
    end
    return luacheck
end
function CodeLinting.mergeIgnoreGlobals(self, globalsInSetting, globalVariables)
    local globalsMap = __TS__New(Map)
    for ____, g in ipairs(globalsInSetting) do
        globalsMap[g] = true
    end
    for ____, g in ipairs(globalVariables) do
        do
            if globalsMap[g] then
                goto __continue15
            end
            local arr = __TS__StringSplit(g, ".")
            globalsMap[arr[1]] = true
        end
        ::__continue15::
    end
    local ret = {}
    for key in pairs(globalsMap) do
        ret[#ret + 1] = key
    end
    return ret
end
function CodeLinting.getLuacheckArgs(self, settings, fileName, globalVariables)
    local luacheckArgs = {}
    local luaVersion = settings.codeLinting.luaVersion
    repeat
        local ____switch21 = luaVersion
        local ____cond21 = ____switch21 == "5.1"
        if ____cond21 then
            __TS__ArrayPush(luacheckArgs, "--std", "lua51")
            break
        end
        ____cond21 = ____cond21 or ____switch21 == "5.3"
        if ____cond21 then
            __TS__ArrayPush(luacheckArgs, "--std", "lua53")
            break
        end
        ____cond21 = ____cond21 or ____switch21 == "5.1+5.3"
        if ____cond21 then
            __TS__ArrayPush(luacheckArgs, "--std", "lua51+lua53")
            break
        end
    until true
    local userIgnoreGlobals = __TS__StringSplit(settings.codeLinting.ignoreGlobal, ";")
    local ignoreGlobals = self:mergeIgnoreGlobals(userIgnoreGlobals, globalVariables)
    if #ignoreGlobals > 0 then
        __TS__ArrayPush(
            luacheckArgs,
            "--globals",
            table.unpack(ignoreGlobals)
        )
    end
    local maxLineLength = settings.codeLinting.maxLineLength
    __TS__ArrayPush(
        luacheckArgs,
        "--max-line-length",
        tostring(maxLineLength)
    )
    luacheckArgs[#luacheckArgs + 1] = "--allow-defined"
    luacheckArgs[#luacheckArgs + 1] = "--ranges"
    luacheckArgs[#luacheckArgs + 1] = "--codes"
    __TS__ArrayPush(luacheckArgs, "--formatter", "plain")
    __TS__ArrayPush(luacheckArgs, "--filename", fileName)
    luacheckArgs[#luacheckArgs + 1] = "-"
    return luacheckArgs
end
function CodeLinting.parseLuacheckResult(self, luaErrorOrWarning, settings)
    local diagnosticArray = {}
    local maxNumberOfProblems = settings.codeLinting.maxNumberOfProblems
    local ignoreErrorCode = __TS__StringSplit(settings.codeLinting.ignoreErrorCode, ";")
    local luaErrorOrWarningArray = luaErrorOrWarning:split(nil)
    do
        local i = 0
        local problems = 0
        while i < #luaErrorOrWarningArray and problems < maxNumberOfProblems do
            do
                local regResult = self.luacheckResultRegExp:exec(luaErrorOrWarningArray[i + 1])
                if not regResult then
                    goto __continue24
                end
                local line = __TS__ParseInt(regResult[3])
                local startCharacter = __TS__ParseInt(regResult[4])
                local endCharacter = __TS__ParseInt(regResult[5])
                local errorType = regResult[6]
                local ____temp_0
                if errorType == "E" then
                    ____temp_0 = DiagnosticSeverity.Error
                else
                    ____temp_0 = DiagnosticSeverity.Warning
                end
                local severity = ____temp_0
                local errorCode = __TS__ParseInt(regResult[7])
                local message = regResult[8]
                local range = Range:create(line - 1, startCharacter - 1, line - 1, endCharacter)
                if __TS__ArrayIncludes(
                    ignoreErrorCode,
                    tostring(errorCode)
                ) then
                    goto __continue24
                end
                local diagnosic = {
                    range = range,
                    severity = severity,
                    code = errorCode,
                    message = message,
                    source = "lua-analyzer"
                }
                problems = problems + 1
                diagnosticArray[#diagnosticArray + 1] = diagnosic
            end
            ::__continue24::
            i = i + 1
        end
    end
    return diagnosticArray
end
CodeLinting.luacheckResultRegExp = nil
return ____exports
