local _, GW = ...

local function AddForProfiling(unit, name, ...)
    local gName = "GW_" .. unit
    if not _G[gName] then
        _G[gName] = {}
    end
    _G[gName][name] = ...
end

local function Debug(...)
    if DLAPI then
        local msg = ""
        for i = 1, select("#", ...) do
            local arg = select(i, ...)
            msg = msg .. tostring(arg) .. " "
        end
        DLAPI.DebugLog("GW2", "%s", msg)
    end
end

local function Trace()
    if DLAPI then
        DLAPI.DebugLog("GW2Trace", "%s", "------------------------- Trace -------------------------")
        for i,v in ipairs({("\n"):split(debugstack(2))}) do
            if v ~= "" then
                DLAPI.DebugLog("GW2Trace", "%d: %s", i, v)
            end
        end
        DLAPI.DebugLog("GW2Trace", "%s", "---------------------------------------------------------")
    end
end

local function DebugOff()
    return
end
local function AddForProfilingOff()
    return
end
local function TraceOff()
    return
end

if DLAPI then
    GW.Debug = Debug
    GW.Trace = Trace
    GW.inDebug = true
    SetCVar("fstack_preferParentKeys", 0)
    Debug("debug log initialized")
else
    GW.Debug = DebugOff
    GW.Trace = TraceOff
    GW.inDebug = false
end
if Profiler then
    GW.AddForProfiling = AddForProfiling
else
    GW.AddForProfiling = AddForProfilingOff
end
