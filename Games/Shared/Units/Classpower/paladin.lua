---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- PALADIN (holy power, protection Shield of the Righteous decay)
if GW.myClassID ~= GW.Enum.ClassIndex.Paladin or GW.Classic or GW.TBC or GW.Wrath then return end

local function powerSotR()
    local results = CP.GetAuraData("player", nil, "HELPFUL", 132403, 31850, 212641)

    if results == nil then
        return
    end
    local duration = -1
    local expires = -1
    for i = 1, #results do
        if results[i].expirationTime > expires then
            expires = results[i].expirationTime
            duration = results[i].duration
        end
    end
    if expires > 0 then
        local pre = (expires - GetTime()) / duration
        GW.AddToAnimation("DECAY_BAR", pre, 0, GetTime(), expires - GetTime(), function()
            local remainingPrecantage = (expires - GetTime()) / duration
            local remainingTime = duration * remainingPrecantage
            CP.frame.customResourceBar:SetCustomAnimation(remainingPrecantage, 0, remainingTime)
        end, "noease")
    end
end

local function UpdateHolyPowerPoints(self)
    local maxPoints = UnitPowerMax("player", Enum.PowerType.HolyPower)
    for _, v in pairs(self.paladin.power) do
        local id = tonumber(v:GetParentKey())
        if id > maxPoints then
            v:Hide()
        else
            v:Show()
        end
    end
end

local function powerHoly(self, event, ...)
    if event == "UNIT_AURA" then
        CP.HandleUnitAuraEvent(...)
        return
    elseif event == "UNIT_MAXPOWER" then
        UpdateHolyPowerPoints(self)
    end

    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "HOLY_POWER" then
        return
    end

    local old_power = self.gwPower
    local pwr = UnitPower("player", Enum.PowerType.HolyPower)
    local pwrThreshold = (GW.Retail and 3 or 1)
    if pwr < pwrThreshold then
        self.background:SetAlpha(0.2)
    else
        self.background:SetAlpha(1)
    end
    for _, v in pairs(self.paladin.power) do
        if v:IsShown() then
            local id = tonumber(v:GetParentKey())
            if old_power < id and pwr >= id then
                CP.animFlarePoint(self, v, 0.5)
            end
            if pwr >= pwrThreshold and id < (pwrThreshold - 1) then
                v:SetTexCoord(0, 0.5, 0.5, 1)
            elseif pwr >= id then
                v:SetTexCoord(0.5, 1, 0, 0.5)
            elseif pwr < id then
                v:SetTexCoord(0, 0.5, 0, 0.5)
            end
        end
    end
    self.gwPower = pwr
end

local function setPaladin(f)
    f.paladin:Show()

    f.background:ClearAllPoints()
    f.background:SetHeight(41)
    f.background:SetWidth(181)
    f.background:SetTexCoord(0, 0.70703125, 0, 0.640625)
    f.paladin:SetWidth(f.background:GetWidth())
    CP.SetClassPowerAnchor(f.paladin, f.gwMover, "TOPLEFT")
    CP.SetClassPowerAnchor(f.background, f.gwMover, "LEFT", 0, CP.GetAnchorMode() == "DEFAULT" and 2 or 0)

    f.background:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/holypower/background.png")

    f.fill:Hide()

    UpdateHolyPowerPoints(f)

    f:SetScript("OnEvent", powerHoly)
    powerHoly(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

    if GW.myspec == 2 then
        if GW.Retail then
            -- Shield of the Righteous decay: the aura values are secret in combat, so the
            -- bar is driven engine-side by a tracker container (the Lua-driven intensity
            -- overlays of the old animated bar are not possible with secrets)
            local tracker = CP.EnableAuraTracker(f, "PaladinShield", {
                unit = "player",
                filter = "HELPFUL",
                spellIDs = { [132403] = true, [31850] = true, [212641] = true },
                width = 164,
                height = 14,
                createWidgets = function(button) return CP.BuildTrackerBarWidgets(button, "bloster", nil, false, true) end,
            })
            CP.SetClassPowerCustomResourceBarAnchor(tracker, f.gwMover, f, 0, 0, 2, 4)
        else
            f.customResourceBar:SetWidth(164)
            CP.SetClassPowerCustomResourceBarAnchor(f.customResourceBar, f.gwMover, f, 0, 0, 2, 4)
            f.customResourceBar:Show()

            CP.setPowerTypePaladinShield(f.customResourceBar)

            f:RegisterUnitEvent("UNIT_AURA", "player")
            EventRegistry:RegisterCallback("GW2_UI.ClasspowerPlayerUnitAura", powerSotR, "GW2_UI")
        end
    end

    return true
end

CP.setups[GW.Enum.ClassIndex.Paladin] = setPaladin
