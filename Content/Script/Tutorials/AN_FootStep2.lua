local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local AN_FootStep2 = __TS__Class()
AN_FootStep2.name = "AN_FootStep_Child_C"

__TS__ClassExtends(
    AN_FootStep2,
    UnLua.Class()
)
function AN_FootStep2.prototype.Received_Notify(self, MeshComp, Animation)
    print("foot step2222222222222222222222222222222222222")
    return true
end
local ____exports = AN_FootStep2
return ____exports
