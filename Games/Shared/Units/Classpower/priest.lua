---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- PRIEST (shadow: mana bar on Retail, shadow orbs on Mists)
if GW.myClassID ~= GW.Enum.ClassIndex.Priest or GW.Classic or GW.TBC or GW.Wrath then return end

local function shadowOrbs(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "SHADOW_ORBS" then
        return
    end

    local currentOrbs = UnitPower("player", Enum.PowerType.ShadowOrbs)
    local old_power = self.gwPower
    if currentOrbs < 2 then
        self.background:SetAlpha(0.2)
    else
        self.background:SetAlpha(1)
    end
    for _, v in pairs(self.priest.power) do
        local id = tonumber(v:GetParentKey())
        if old_power < id and currentOrbs >= id then
            CP.animFlarePoint(self, v, 0.5)
        end
        if currentOrbs >= 3 and id < 4 then
            v:SetTexCoord(0, 0.5, 0.5, 1)
        elseif currentOrbs >= id then
            v:SetTexCoord(0.5, 1, 0, 0.5)
        elseif currentOrbs < id then
            v:SetTexCoord(0, 0.5, 0, 0.5)
        end
    end
    self.gwPower = currentOrbs
end


local function setPriest(f)
    if GW.myspec == 3 then -- shadow
        if GW.Retail then
            CP.setManaBar(f)
            return true
        elseif GW.Mists then
            f.priest:Show()

            f.background:ClearAllPoints()
            f.background:SetHeight(41)
            f.background:SetWidth(181)
            f.background:SetTexCoord(0, 0.70703125, 0, 0.640625)
            f.priest:SetWidth(f.background:GetWidth())
            CP.SetClassPowerAnchor(f.priest, f.gwMover, "TOPLEFT")
            CP.SetClassPowerAnchor(f.background, f.gwMover, "LEFT", 0, CP.GetAnchorMode() == "DEFAULT" and 2 or 0)

            f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/shadoworbs/background.png")

            f.fill:Hide()

            f:SetScript("OnEvent", shadowOrbs)
            shadowOrbs(f, "CLASS_POWER_INIT")
            f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

            return true
        end
    end

    return false
end

CP.setups[GW.Enum.ClassIndex.Priest] = setPriest
