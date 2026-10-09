---@class GW2
local GW = select(2, ...)

GwObjectivesUnitFrameMixin = {}

function GwObjectivesUnitFrameMixin:OnHide()
    -- override per module
end

function GwObjectivesUnitFrameMixin:OnShow()
    -- override per module
end


function GwObjectivesUnitFrameMixin:UpdateHealth()
    local health = UnitHealth(self.gwUnit)
    local maxHealth = UnitHealthMax(self.gwUnit)
    self.health:SetMinMaxValues(0, maxHealth)

    if GW.isModern then
        self.health:SetValue(health, Enum.StatusBarInterpolation.ExponentialEaseOut)
        self.health.value:SetText(string.format("%.0f%%", UnitHealthPercent(self.gwUnit, true, CurveConstants.ScaleTo100)))
    else
        local healthPercentage = (health > 0 and maxHealth > 0) and (health / maxHealth) or 0
        self.health:SetValue(health)
        self.health.value:SetText(GW.RoundInt(healthPercentage * 100) .. "%")
    end
end

function GwObjectivesUnitFrameMixin:UpdatePower()
    local powerType, powerToken, altR, altG, altB = UnitPowerType(self.gwUnit)
    local power = UnitPower(self.gwUnit, powerType)
    local powerMax = UnitPowerMax(self.gwUnit, powerType)

    self.power:SetMinMaxValues(0, powerMax)

     if GW.Colors.PowerBarCustomColors[powerToken] then
        local pwcolor = GW.Colors.PowerBarCustomColors[powerToken]
        self.power:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    else
        self.power:SetStatusBarColor(altR or 0, altG or 0, altB or 0)
    end

    if GW.isModern then
        self.power:SetValue(power, Enum.StatusBarInterpolation.ExponentialEaseOut)
        self.power.value:SetText(string.format("%.0f%%", UnitPowerPercent(self.gwUnit, powerType, true, CurveConstants.ScaleTo100)))
    else
        local powerPercentage = (power > 0 and powerMax > 0) and (power / powerMax) or 0
        self.power:SetValue(power)
        self.power.value:SetText(GW.RoundInt(powerPercentage * 100) .. "%")
    end
end

function GwObjectivesUnitFrameMixin:UpdateName()
    local name = GW.GetUnitDisplayName(self.gwUnit)
    self.name:SetText(name)

    if GW.isModern then return end -- guid is secret
    self.guid = UnitGUID(self.gwUnit)
    if self.guid == UnitGUID("target") then
        self.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    else
        self.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small)
    end
end

function GwObjectivesUnitFrameMixin:OnEnter()
    if self.gwUnit then
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(self.gwUnit)
        GameTooltip:Show()
    end
end

function GwObjectivesUnitFrameMixin:OnLeave()
    GameTooltip_Hide()
end

local CASTBAR_TEXTURE = "Interface/AddOns/GW2_UI/textures/units/castingbars/%s.png"

local CAST_EVENTS = {
    UNIT_SPELLCAST_START = true,
    UNIT_SPELLCAST_STOP = true,
    UNIT_SPELLCAST_FAILED = true,
    UNIT_SPELLCAST_INTERRUPTED = true,
    UNIT_SPELLCAST_DELAYED = true,
    UNIT_SPELLCAST_CHANNEL_START = true,
    UNIT_SPELLCAST_CHANNEL_UPDATE = true,
    UNIT_SPELLCAST_CHANNEL_STOP = true,
    UNIT_SPELLCAST_INTERRUPTIBLE = true,
    UNIT_SPELLCAST_NOT_INTERRUPTIBLE = true,
}
if GW.Retail then
    CAST_EVENTS.UNIT_SPELLCAST_EMPOWER_START = true
    CAST_EVENTS.UNIT_SPELLCAST_EMPOWER_UPDATE = true
    CAST_EVENTS.UNIT_SPELLCAST_EMPOWER_STOP = true
end

function GwObjectivesUnitFrameMixin:RegisterCastbarEvents()
    for event in pairs(CAST_EVENTS) do
        self:RegisterUnitEvent(event, self.gwUnit)
    end
end

function GwObjectivesUnitFrameMixin:IsCastbarEvent(event)
    return CAST_EVENTS[event] == true
end

-- modern casts run on the engine timer (values are secret), the classic ones and the test mode on
-- our own start and end time
local function CastbarOnUpdate(bar)
    if bar.endTime then
        local remaining = bar.endTime - GetTime()
        if remaining <= 0 and bar.gwLoop then
            bar.endTime = GetTime() + bar.duration
            remaining = bar.duration
        end
        remaining = math.max(remaining, 0)
        bar:SetValue(bar.channeling and remaining or bar.duration - remaining)
        bar.timer:SetFormattedText("%.1f", remaining)
    else
        local duration = bar:GetTimerDuration()
        if duration then
            bar.timer:SetFormattedText("%.1f", duration:GetRemainingDuration())
        end
    end
end

-- cast bar in place of the power bar; auras (where the container exists) at the right end of the
-- name line, the first group at the edge, the name keeps the rest of the line
function GwObjectivesUnitFrameMixin:InitCastbarAndAuras(refreshEvents, groups)
    local bar = self.castbar
    bar.spellName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    bar.timer:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    bar:SetScript("OnUpdate", CastbarOnUpdate)

    self.name:ClearAllPoints()
    self.name:SetPoint("TOPLEFT", self, "TOPLEFT", 10, 0)
    self.name:SetWordWrap(false)

    if not GW.CreateUnitAuraContainer then return end
    self.auraMaxFrames = {}
    for _, group in ipairs(groups) do
        self.auraMaxFrames[group.key] = group.maxFrameCount
        group.size = 16
        group.hideDuration = true
        group.thinBorder = true
    end
    self.auras = GW.CreateUnitAuraContainer({
        name = self:GetName() .. "Auras",
        unit = self.gwUnit,
        parent = self,
        tooltipAnchor = { "ANCHOR_BOTTOMLEFT", -5, -5 },
        refreshEvents = refreshEvents,
        anchorPoint = "TOPRIGHT",
        growLeft = true,
        maximumLineSize = 80,
        elementSpacing = 3,
        groups = groups,
    })
    self.auras:SetPoint("TOPRIGHT", self, "TOPRIGHT", -10, -2)
end

function GwObjectivesUnitFrameMixin:ApplyAuraSettings(enabled)
    local showAuras = self.auras ~= nil and enabled
    if self.auras then
        -- a group with no frames stops processing
        for _, group in ipairs(self.auras.gwConfig.groups) do
            group.maxFrameCount = showAuras and self.auraMaxFrames[group.key] or 0
        end
        self.auras:GwUpdateLayout()
    end
    self.name:SetWidth(showAuras and 205 or 290)
end

-- test auras in the look of the container buttons (1px frame, debuffs on their dispel color)
local function CreateTestAura(parent)
    local aura = CreateFrame("Frame", nil, parent)
    aura:SetSize(16, 16)
    aura.background = aura:CreateTexture(nil, "ARTWORK")
    aura.background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    aura.background:SetAllPoints()
    aura.icon = aura:CreateTexture(nil, "OVERLAY")
    aura.icon:SetPoint("TOPLEFT", 1, -1)
    aura.icon:SetPoint("BOTTOMRIGHT", -1, 1)
    aura.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    local overlay = aura:CreateTexture(nil, "OVERLAY", nil, 1)
    overlay:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-overlay.png")
    overlay:SetAllPoints(aura.icon)
    aura:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -5, -5)
        GameTooltip:SetSpellByID(self.spellID)
        GameTooltip:Show()
    end)
    aura:SetScript("OnLeave", GameTooltip_Hide)
    return aura
end

function GwObjectivesUnitFrameMixin:SetTestAuras(testAuras, enabled)
    self.gwTestAuras = self.gwTestAuras or {}
    for _, aura in ipairs(self.gwTestAuras) do
        aura:Hide()
    end
    if not testAuras or not enabled or not self.auras then return end

    for i, data in ipairs(testAuras) do
        local aura = self.gwTestAuras[i]
        if not aura then
            aura = CreateTestAura(self)
            aura:SetPoint("TOPRIGHT", self, "TOPRIGHT", -10 - (i - 1) * 19, -2)
            self.gwTestAuras[i] = aura
        end
        aura.spellID = data.spellID
        aura.icon:SetTexture(C_Spell.GetSpellTexture(data.spellID) or 134400)
        local color = data.dispelType and GW.Colors.DebuffColors[data.dispelType] or GW.Colors.Fallback
        aura.background:SetVertexColor(color:GetRGB())
        aura:Show()
    end
end

-- the cast takes the place of the power bar while it lasts
function GwObjectivesUnitFrameMixin:ShowCastbar(name, channeling, notInterruptible)
    local bar = self.castbar
    bar:SetStatusBarTexture(CASTBAR_TEXTURE:format(channeling and GW.CASTINGBAR_TEXTURES.GREEN.NORMAL or GW.CASTINGBAR_TEXTURES.YELLOW.NORMAL))
    bar:GetStatusBarTexture():SetDesaturated(notInterruptible)
    bar.spellName:SetText(name)
    bar.channeling = channeling
    bar:Show()
    self.power:Hide()
end

function GwObjectivesUnitFrameMixin:HideCastbar()
    self.castbar:Hide()
    self.castbar.endTime = nil
    self.castbar.gwLoop = nil
    self.power:Show()
end

function GwObjectivesUnitFrameMixin:UpdateCastbar(enabled)
    if not enabled then
        self:HideCastbar()
        return
    end

    local unit = self.gwUnit
    local channeling, isEmpowered = false, false
    local name, _, _, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
    if not name then
        name, _, _, startTime, endTime, _, notInterruptible, _, isEmpowered = UnitChannelInfo(unit)
        channeling = true
    end
    if not name then
        self:HideCastbar()
        return
    end

    local bar = self.castbar
    if GW.isModern then
        bar.endTime = nil
        -- empowered casts fill up like a normal cast
        local duration, direction
        if isEmpowered then
            duration, direction = UnitEmpoweredChannelDuration(unit), Enum.StatusBarTimerDirection.ElapsedTime
        elseif channeling then
            duration, direction = UnitChannelDuration(unit), Enum.StatusBarTimerDirection.RemainingTime
        else
            duration, direction = UnitCastingDuration(unit), Enum.StatusBarTimerDirection.ElapsedTime
        end
        bar:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate, direction)
    else
        bar.endTime = endTime / 1000
        bar.duration = (endTime - startTime) / 1000
        bar:SetMinMaxValues(0, bar.duration)
    end
    self:ShowCastbar(name, channeling, notInterruptible)
end

-- test mode: a looping cast without a unit
function GwObjectivesUnitFrameMixin:ShowTestCastbar(name, duration, notInterruptible)
    local bar = self.castbar
    bar.duration = duration
    bar.endTime = GetTime() + duration
    bar.gwLoop = true
    bar:SetMinMaxValues(0, duration)
    self:ShowCastbar(name, false, notInterruptible)
end
