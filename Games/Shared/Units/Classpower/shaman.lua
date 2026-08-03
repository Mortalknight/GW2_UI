---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- SHAMAN (elemental mana bar, enhancement Maelstrom Weapon)
if GW.myClassID ~= GW.Enum.ClassIndex.Shaman or GW.Classic or GW.TBC or GW.Wrath then return end

local function powerMaelstrom()
    local auraData = C_UnitAuras.GetPlayerAuraBySpellID(344179) -- None Secret

    if auraData and auraData.duration == nil then
        CP.frame.gwPower = -1
        auraData.applications = 0
    end

    if auraData and auraData.applications >= 5 then
        CP.frame.maelstrom.flare1:Show()
    else
        CP.frame.maelstrom.flare1:Hide()
    end
    if auraData and auraData.applications >= 10 then
        CP.frame.maelstrom.flare2:Show()
    else
        CP.frame.maelstrom.flare2:Hide()
    end

    for i = 1, 10 do
        if auraData and auraData.applications >= i then
            CP.frame.maelstrom["rune" .. i]:Show()
        else
            CP.frame.maelstrom["rune" .. i]:Hide()
        end
    end
end


local function setShaman(f)
    if GW.Retail then
        if GW.myspec == 1 then
            -- ele use extra mana bar on left
            CP.setManaBar(f)
            return true
        elseif GW.myspec == 2 then -- enh
            CP.SetClassPowerAnchor(f, f.gwMover, "TOPLEFT", 0, CP.GetAnchorMode() == "DEFAULT" and -10 or 0)
            f.background:SetTexture(nil)
            f.fill:SetTexture(nil)
            local fms = f.maelstrom
            fms:Show()

            f:SetScript("OnEvent", powerMaelstrom)
            powerMaelstrom()
            f:RegisterUnitEvent("UNIT_AURA", "player")
            return true
        end
    end

    return false
end

CP.setups[GW.Enum.ClassIndex.Shaman] = setShaman
