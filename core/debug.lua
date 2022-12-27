local _, GW = ...

local D = DLAPI
local P = Profiler

-- Deprecated; use AddProfiling instead
local function AddForProfiling(unit, name, ...)
    local gName = "GW2_" .. unit
    if not _G[gName] then
        _G[gName] = {}
    end
    GW[name] = ...
end

-- Adds local-only function refs into global namespace so that the profiler can "see" them
-- Only needed for functions that don't go into the GW obj (those show in GW2_ADDON scope)
-- Does nothing when the profiling addon is not enabled
local function AddProfiling(name, func)
    if not name or type(name) ~= "string" or not func or (type(func) ~= "function" and type(func) ~= "table") then
        return
    end
    local callLine, _ = strsplit("\n", debugstack(2, 1, 0), 2)
    local unit = gsub(gsub(callLine, '%[string "@Interface\\AddOns\\GW2_UI\\', ""), '%.lua".*', "")
    unit = gsub(gsub(unit, '\\', "::"), '/', "::")
    local gName = "GW2_" .. unit
    GW[name] = func
end

local function Debug(...)
    local msg = ""
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        msg = msg .. tostring(arg) .. " "
    end
    D.DebugLog("GW2", "%s", msg)
end

local function Trace()
    D.DebugLog("GW2Trace", "%s", "------------------------- Trace -------------------------")
    for i,v in ipairs({("\n"):split(debugstack(2))}) do
        if v ~= "" then
            D.DebugLog("GW2Trace", "%d: %s", i, v)
        end
    end
    D.DebugLog("GW2Trace", "%s", "---------------------------------------------------------")
end

local function EmptyFunc()
end

if D then
    GW.Debug = Debug
    GW.Trace = Trace
    GW.inDebug = true
    C_CVar.SetCVar("fstack_preferParentKeys", "0")
    Debug("debug log initialized")
else
    GW.Debug = EmptyFunc
    GW.Trace = EmptyFunc
    GW.inDebug = false
end
--if P then
    GW.AddForProfiling = AddForProfiling
    GW.AddProfiling = AddProfiling
--else
--    GW.AddForProfiling = EmptyFunc
--    GW.AddProfiling = EmptyFunc
--end
