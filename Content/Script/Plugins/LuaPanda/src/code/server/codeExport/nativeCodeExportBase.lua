local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__ObjectDefineProperty = ____lualib.__TS__ObjectDefineProperty
local ____exports = {}
local Tools = require("Plugins.LuaPanda.src.code.server.codeTools")
local ____codeSymbol = require("Plugins.LuaPanda.src.code.server.codeSymbol")
local CodeSymbol = ____codeSymbol.CodeSymbol
local fs = require("Plugins.LuaPanda.src.code.server.codeExport.fs")
____exports.NativeCodeExportBase = __TS__Class()
local NativeCodeExportBase = ____exports.NativeCodeExportBase
NativeCodeExportBase.name = "NativeCodeExportBase"
function NativeCodeExportBase.prototype.____constructor(self)
end
function NativeCodeExportBase.loadIntelliSenseRes(self)
    local dirPath = self.LuaPandaInterfaceIntelliSenseResPath
    if fs:existsSync(dirPath) then
        CodeSymbol:refreshUserPreloadSymbals(dirPath)
    end
end
function NativeCodeExportBase.processNativeCodeDir(self, anaPath)
    return __TS__AsyncAwaiter(function(____awaiter_resolve)
    end)
end
__TS__ObjectDefineProperty(
    NativeCodeExportBase,
    "LuaPandaInterfaceIntelliSenseResPath",
    {get = function(self)
        if not self._LuaPandaInterfaceIntelliSenseResPath then
            if Tools:getVSCodeOpenedFolders() and #Tools:getVSCodeOpenedFolders() > 0 then
                self._LuaPandaInterfaceIntelliSenseResPath = tostring(Tools:getVSCodeOpenedFolders()[1]) .. "/.vscode/LuaPanda/IntelliSenseRes/"
            end
        end
        return self._LuaPandaInterfaceIntelliSenseResPath
    end}
)
return ____exports
