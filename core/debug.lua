local _, GW = ...

local D = DLAPI

local function Debug(...)
    local msg = ""
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        msg = msg .. tostring(arg) .. " "
    end
    D.DebugLog("GW2_UI", "%s", msg)
end

local function Trace()
    D.DebugLog("GW2Trace", "%s", "------------------------- Trace -------------------------")
    for i,v in ipairs({("\n"):split(debugstack(2))}) do
        if v ~= "" then
            D.DebugLog("GW2_UI", "%d: %s", i, v)
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
