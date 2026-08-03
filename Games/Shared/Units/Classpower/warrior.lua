---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- WARRIOR (aura driven bars per spec, secret-proof aura trackers)
if GW.myClassID ~= GW.Enum.ClassIndex.Warrior or not GW.Retail then return end

-- Arms: own Rend bleed on the target (388539), Fury: Enrage uptime (184362),
-- Protection: Shield Block (132404/871, plus Last Stand while the Bolster talent is
-- taken). All removed in the 12.0 port and brought back via the secret-proof aura
-- tracker (engine-driven decay bar + countdown).
local function setWarrior(f)
    CP.SetClassPowerAnchor(f, f.gwMover, "TOPLEFT")
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f:SetWidth(313)

    local tracker
    if GW.myspec == 1 then -- arms
        tracker = CP.EnableAuraTracker(f, "WarriorRend", {
            unit = "target",
            filter = "HARMFUL|PLAYER",
            spellIDs = { [388539] = true },
            width = 313,
            height = 14,
            createWidgets = function(button) return CP.BuildTrackerBarWidgets(button, "frenzy", "frenzyspark", false, true) end,
            -- target switches change the unit behind the token — force a full refresh
            refreshEvents = { "PLAYER_TARGET_CHANGED" },
        })
    elseif GW.myspec == 2 then -- fury
        tracker = CP.EnableAuraTracker(f, "WarriorEnrage", {
            unit = "player",
            filter = "HELPFUL|PLAYER",
            spellIDs = { [184362] = true },
            width = 313,
            height = 14,
            createWidgets = function(button) return CP.BuildTrackerBarWidgets(button, "rage", "furyspark", false, true) end,
        })
    elseif GW.myspec == 3 then -- protection
        local spellIDs = { [132404] = true, [871] = true }
        if GW.IsSpellTalented(280001) then -- Bolster: Last Stand also grants Shield Block
            spellIDs[12975] = true
        end
        tracker = CP.EnableAuraTracker(f, "WarriorBlock", {
            unit = "player",
            filter = "HELPFUL|PLAYER",
            spellIDs = spellIDs,
            width = 313,
            height = 14,
            createWidgets = function(button) return CP.BuildTrackerBarWidgets(button, "bloster", "spark", false, true) end,
        })
    end

    if not tracker then return false end

    tracker:ClearAllPoints()
    tracker:SetPoint("LEFT", f, "LEFT", 0, CP.GetAnchorMode() == "DEFAULT" and -11 or 0)

    return true
end

CP.setups[GW.Enum.ClassIndex.Warrior] = setWarrior
