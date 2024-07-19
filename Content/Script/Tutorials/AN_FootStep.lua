local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local AN_FootStep = __TS__Class()
AN_FootStep.name = "AN_FootStep"
__TS__ClassExtends(
    AN_FootStep,
    UnLua.Class()
)
function AN_FootStep.prototype.Received_Notify(self, MeshComp, Animation)
    print("foot step!!!!!!!!!!!!!!!!!!!!!!!!!")
    return true
end
local ____exports = AN_FootStep
return ____exports
