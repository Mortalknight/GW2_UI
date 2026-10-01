---@class GW2
local GW = select(2, ...)

-- One combat log listener for all of GW2 UI. It only listens while an owner is registered and hands every entry to
-- the owners whose key is part of its sub event ("_DAMAGE" takes SPELL_DAMAGE, SWING_DAMAGE, ...), the owner first and
-- then the values of CombatLogGetCurrentEventInfo.

local listeners = {} -- [key][owner] = func

local function Dispatch(...)
    local subEvent = select(2, ...)
    for key, owners in pairs(listeners) do
        if strfind(subEvent, key, 1, true) then
            for owner, func in pairs(owners) do
                func(owner, ...)
            end
        end
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function()
    Dispatch(CombatLogGetCurrentEventInfo())
end)

local function UpdateListening()
    if next(listeners) then
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end

GW.CombatLog = {}

function GW.CombatLog.Register(owner, key, func)
    listeners[key] = listeners[key] or {}
    listeners[key][owner] = func
    UpdateListening()
end

-- without a key the owner leaves every key
function GW.CombatLog.Unregister(owner, key)
    for listenedKey, owners in pairs(listeners) do
        if not key or listenedKey == key then
            owners[owner] = nil
            if not next(owners) then
                listeners[listenedKey] = nil
            end
        end
    end
    UpdateListening()
end
