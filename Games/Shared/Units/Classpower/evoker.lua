---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- EVOKER (essence, augmentation Ebon Might)
if GW.myClassID ~= GW.Enum.ClassIndex.Evoker or not GW.Retail then return end

local FillingAnimationTime = 5.0

local function Essence_OnUpdate(self, elapsed)
    -- The animation speed only depends on haste/regen and barely changes between frames, so
    -- throttle the regen query and only push the multiplier to the animations when it changes.
    self.gwEssenceThrottle = (self.gwEssenceThrottle or 0) + (elapsed or 0)
    if self.gwEssenceThrottle < 0.1 then return end
    self.gwEssenceThrottle = 0

    local peace = GetPowerRegenForPowerType(Enum.PowerType.Essence)
    if GW.IsSecretValue(peace) then return end
    if (peace == nil or peace == 0) then
        peace = 0.2
    end
    local cooldownDuration = 1 / peace
    local animationSpeedMultiplier = FillingAnimationTime / cooldownDuration
    if animationSpeedMultiplier ~= self.gwEssenceSpeed then
        self.gwEssenceSpeed = animationSpeedMultiplier
        self.EssenceFilling.FillingAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier)
        self.EssenceFilling.CircleAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier)
    end
end
local function SetEssennceFull(self)
    self.EssenceFilling.FillingAnim:Stop()
    self.EssenceFilling.CircleAnim:Stop()
    self.EssenceFillDone:Show()
    self.EssenceEmpty:Hide()
    self:SetScript("OnUpdate", nil)
end

local function AnimOut(self)
    if (self.EssenceFull:IsShown() or self.EssenceFilling:IsShown() or self.EssenceFillDone:IsShown()) then
        self.EssenceDepleting:Show()
        self.EssenceFilling:Hide()
        self.EssenceEmpty:Hide()
        self.EssenceFillDone:Hide()
        self.EssenceFull:Hide()
        self.EssenceFilling.FillingAnim:Stop()
        self.EssenceFilling.CircleAnim:Stop()
        self:SetScript("OnUpdate", nil)
    end
end

local function AnimIn(self, animationSpeedMultiplier)
    self.EssenceFilling.FillingAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier)
    self.EssenceFilling.CircleAnim:SetAnimationSpeedMultiplier(animationSpeedMultiplier)
    self:SetScript("OnUpdate", Essence_OnUpdate)
    self.EssenceFilling:Show()
    self.EssenceDepleting:Hide()
    self.EssenceEmpty:Hide()
    self.EssenceFillDone:Hide()
    self.EssenceFull:Hide()
end

local function powerEssence(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "ESSENCE" then
        return
    end

    local pwrMax = UnitPowerMax("player", Enum.PowerType.Essence)
    local pwr = UnitPower("player", Enum.PowerType.Essence)
    self.gwPower = pwr

    local essenceSlots = min(max(pwrMax, 0), 6)
    if essenceSlots > 0 then
        local essenceWidth = essenceSlots * 32
        self.evoker:SetWidth(essenceWidth)
        self:SetWidth(essenceWidth)
        CP.SetClassPowerAnchor(self.evoker, self, "LEFT")
    end

    for i = 1, 6 do
        if i <= pwrMax then
            self.evoker["essence" .. i]:Show()
        else
            self.evoker["essence" .. i]:Hide()
        end
    end

    for i = 1, min(pwr, 6) do
        SetEssennceFull(self.evoker["essence" .. i])
    end
    for i = pwr + 1, 6 do
        AnimOut(self.evoker["essence" .. i])
    end

    local isAtMaxPoints = pwr == pwrMax
    local peace = GetPowerRegenForPowerType(Enum.PowerType.Essence)
    if GW.IsSecretValue(peace) then return end
    if (peace == nil or peace == 0) then
        peace = 0.2
    end
    local cooldownDuration = 1 / peace
    local animationSpeedMultiplier = FillingAnimationTime / cooldownDuration;
    if (not isAtMaxPoints and self.evoker["essence" .. pwr + 1] and not self.evoker["essence" .. pwr + 1].EssenceFull:IsShown()) then
        AnimIn(self.evoker["essence" .. pwr + 1], animationSpeedMultiplier)
    end
end

-- this needs also the essence bar

-- Ebon Might Spell that applies Aura on Self
local EBON_MIGHT_SELF_AURA_SPELL_ID = 395296

local function setEvoker(f)
    CP.SetClassPowerAnchor(f, f.gwMover, "TOPLEFT")
    f.barType = "essence"
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f.evoker:SetWidth(6 * 32)
    f:SetWidth(f.evoker:GetWidth())
    f:SetHeight(32)
    CP.SetClassPowerAnchor(f.evoker, f, "LEFT")
    f.evoker:Show()

    f:SetScript("OnEvent", powerEssence)
    powerEssence(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    f:RegisterUnitEvent("UNIT_POWER_POINT_CHARGE", "player")

    if GW.myspec == 3 then
        local tracker = CP.EnableAuraTracker(f, "EvokerEbonMight", {
            unit = "player",
            filter = "HELPFUL",
            spellIDs = { [EBON_MIGHT_SELF_AURA_SPELL_ID] = true },
            width = 115,
            height = 14,
            createWidgets = function(button) return CP.BuildTrackerBarWidgets(button, "agu", "furyspark", false, true) end,
        })
        CP.SetClassPowerCustomResourceBarAnchor(tracker, f.gwMover, f, 0, 0, 2, 4)
    end
    return true
end

CP.setups[GW.Enum.ClassIndex.Evoker] = setEvoker
