---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- HUNTER (BM Barbed Shot / SV Mongoose Fury, secret-proof aura trackers)
if GW.myClassID ~= GW.Enum.ClassIndex.Hunter or not GW.Retail then return end

-- BM: Barbed Shot bleed (217200) on the TARGET with a remaining-time bar (the 12.1
-- Frenzy rework moved the mechanic onto the target debuff), SV: Mongoose Fury
-- (259388, needs talent 259387) with stack counter. Removed in the 12.0 port,
-- brought back via the secret-proof aura tracker (engine-driven bar/counter).
-- The stack counter shows counts from 2 upwards (engine default).
local function setHunter(f)
    local isBM = GW.myspec == 1
    local isSV = GW.myspec == 3
    if not (isBM or isSV) then return false end

    CP.SetClassPowerAnchor(f, f.gwMover, "TOPLEFT")
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f:SetWidth(262)

    local tracker
    if isBM then
        tracker = CP.EnableAuraTracker(f, "HunterFrenzy", {
            -- Barbed Shot bleed lives on the TARGET; PLAYER restricts it to our own
            unit = "target",
            filter = "HARMFUL|PLAYER",
            spellIDs = { [217200] = true },
            width = 262,
            height = 14,
            -- no stacks anymore — countdown timer on the bar instead
            createWidgets = function(button) return CP.BuildTrackerBarWidgets(button, "frenzy", "frenzyspark", false, true) end,
            -- target switches change the unit behind the token — force a full refresh
            refreshEvents = { "PLAYER_TARGET_CHANGED" },
        })
    elseif isSV then
        tracker = CP.EnableAuraTracker(f, "HunterMongoose", {
            unit = "player",
            filter = "HELPFUL|PLAYER",
            spellIDs = { [259388] = true },
            width = 262,
            height = 14,
            createWidgets = function(button) return CP.BuildTrackerBarWidgets(button, "frenzy", "frenzyspark", true, true) end,
        })
    end
    tracker:ClearAllPoints()
    tracker:SetPoint("LEFT", f, "LEFT", 0, CP.GetAnchorMode() == "DEFAULT" and -11 or 0)

    return true
end

CP.setups[GW.Enum.ClassIndex.Hunter] = setHunter
