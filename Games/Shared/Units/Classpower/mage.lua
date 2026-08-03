---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- MAGE (arcane charges)
-- NOTE: the old frost icicle bar (aura 205473) is gone — icicles are secret-value
-- driven since 12.0 and the aura carries no readable stack count anymore
if GW.myClassID ~= GW.Enum.ClassIndex.Mage or not GW.Retail then return end

local function powerArcane(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "ARCANE_CHARGES" then
        return
    end

    local old_power = self.gwPower
    old_power = old_power or -1

    local pwr = UnitPower("player", 16)
    local p = pwr - 1

    self.gwPower = pwr

    self.background:SetTexCoord(0, 1, 0.125 * 3, 0.125 * (3 + 1))
    self.fill:SetTexCoord(0, 1, 0.125 * p, 0.125 * (p + 1))

    if old_power < pwr and event ~= "CLASS_POWER_INIT" then
        CP.animFlare(self, 64, -32, 2, true)
    end
end

local function setMage(f)
    if GW.myspec == 1 then -- arcane
        CP.SetClassPowerAnchor(f, f.gwMover, "TOPLEFT", 0, CP.GetAnchorMode() == "DEFAULT" and 15 or 0)
        f:SetHeight(64)
        f:SetWidth(512)
        f.background:SetHeight(64)
        f.background:SetWidth(512)
        f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/arcane.png")
        f.background:SetTexCoord(0, 1, 0.125 * 3, 0.125 * (3 + 1))
        f.flare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/arcane-flash.png")
        f.flare:SetWidth(256)
        f.flare:SetHeight(256)
        f.fill:SetHeight(64)
        f.fill:SetWidth(512)
        f.fill:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/arcane.png")
        f.background:SetVertexColor(0, 0, 0, 0.5)

        f:SetScript("OnEvent", powerArcane)
        powerArcane(f, "CLASS_POWER_INIT")
        f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
        f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

        return true
    end

    return false
end

CP.setups[GW.Enum.ClassIndex.Mage] = setMage
