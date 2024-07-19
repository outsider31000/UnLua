local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor
local ____exports = {}
____exports.ThreadManager = __TS__Class()
local ThreadManager = ____exports.ThreadManager
ThreadManager.name = "ThreadManager"
function ThreadManager.prototype.____constructor(self)
    self._CUR_THREAD_ID = ____exports.ThreadManager.NEXT_THREAD_ID
    local ____exports_ThreadManager_0, ____NEXT_THREAD_ID_1 = ____exports.ThreadManager, "NEXT_THREAD_ID"
    ____exports_ThreadManager_0[____NEXT_THREAD_ID_1] = ____exports_ThreadManager_0[____NEXT_THREAD_ID_1] + 1
    local ____exports_ThreadManager_2, ____THREAD_ID_COUNTER_3 = ____exports.ThreadManager, "THREAD_ID_COUNTER"
    ____exports_ThreadManager_2[____THREAD_ID_COUNTER_3] = ____exports_ThreadManager_2[____THREAD_ID_COUNTER_3] + 1
end
function ThreadManager.prototype.destructor(self)
    local ____exports_ThreadManager_4, ____THREAD_ID_COUNTER_5 = ____exports.ThreadManager, "THREAD_ID_COUNTER"
    ____exports_ThreadManager_4[____THREAD_ID_COUNTER_5] = ____exports_ThreadManager_4[____THREAD_ID_COUNTER_5] - 1
    if ____exports.ThreadManager.THREAD_ID_COUNTER == 0 then
        ____exports.ThreadManager.NEXT_THREAD_ID = 0
    end
end
ThreadManager.THREAD_ID_COUNTER = 0
ThreadManager.NEXT_THREAD_ID = 0
__TS__SetDescriptor(
    ThreadManager.prototype,
    "CUR_THREAD_ID",
    {get = function(self)
        return self._CUR_THREAD_ID
    end},
    true
)
return ____exports
