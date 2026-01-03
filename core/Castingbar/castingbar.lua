local _, GW = ...
local lerp = GW.lerp
local TimeCount = GW.TimeCount
local RegisterMovableFrame = GW.RegisterMovableFrame
local animations = GW.animations
local IsIn = GW.IsIn

local CASTINGBAR_TEXTURES = {
    YELLOW = {
        NORMAL = "yellow-norm",
        HIGHLIGHT = "yellow-highlight"
    },
    RED = {
        NORMAL = "red-norm",
        HIGHLIGHT = "red-highlight"
    },
    GREEN = {
        NORMAL = "green-norm",
        HIGHLIGHT = "green-highlight"
    },
}
GW.CASTINGBAR_TEXTURES = CASTINGBAR_TEXTURES

local settings = {}
GwCastingBarMixin = {}

local function UpdateSettings()
    settings.showSpellQueueWindow = GW.settings.PLAYER_CASTBAR_SHOW_SPELL_QUEUEWINDOW
end
GW.UpdateCastingBarSettings = UpdateSettings

function GwCastingBarMixin:HideTicks()
    for _, tick in next, self.TickLines do
        tick:Hide()
    end
end

function GwCastingBarMixin:SetCastTicks(numTicks)
    self:HideTicks()

    if numTicks and numTicks <= 0 then
        return
    end

    local offset = self:GetWidth() / numTicks

    for i = 1, numTicks - 1 do
        local tick = self.TickLines[i]
        if not tick then
            tick = CreateFrame("Frame", nil, self, "GwCastingBarSegmentSep")
            tick.rank:Hide()
            self.TickLines[i] = tick
        end

        tick:ClearAllPoints()
        tick:SetPoint("TOPRIGHT", self, "TOPLEFT", offset * i, 0)
        tick:Show()
    end
end

function GwCastingBarMixin:CheckForTicks()
    local baseTicks = GW.ChannelTicks[self.spellID]

    local talentTicks = baseTicks and GW.TalentChannelTicks[self.spellID]
    if talentTicks then
        for auraId, tickCount in next, talentTicks do
            if GW.IsSpellKnown(auraId) then
                if GW.IsSpellKnownOrOverridesKnown(auraId) or GW.IsSpellKnown(auraId) then
					baseTicks = tickCount
					break
				end
            end
        end
    end

    local auraTicks = baseTicks and GW.AuraChannelTicks[self.spellID]
    if auraTicks then
        for auraID, tickCount in next, auraTicks.spells do
            local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(auraID)
            if auraInfo then
                baseTicks = tickCount
                break
            end
        end
    end

    local chainTicks = baseTicks and GW.ChainChannelTicks[self.spellID]
    if chainTicks then
        local now = GetTime()
        local seconds = GW.ChainChannelTime[self.spellID]
        local match = seconds and self.chainTime and self.chainTick == self.spellID

        if match and (now - seconds) < self.chainTime then
            baseTicks = baseTicks + chainTicks
        end

        self.chainTime = now
        self.chainTick = self.spellID
    else
        self.chainTick = nil
        self.chainTime = nil
    end

    local hasteTicks = baseTicks and GW.HastedChannelTicks[self.spellID]
    if hasteTicks then -- requires tickSize
        local haste = UnitSpellHaste("player") * 0.01
        local rate = 1 / baseTicks
        local first = rate * 0.5

        local bonus = 0
        if haste >= first then
            bonus = bonus + 1
        end

        local x = GW.RoundDec(first + rate, 2)
        while haste >= x do
            x = GW.RoundDec(first + (rate * bonus), 2)

            if haste >= x then
                bonus = bonus + 1
            end
        end

        self:SetCastTicks(baseTicks + bonus)
        self.hadTicks = true
    elseif baseTicks then
        self:SetCastTicks(baseTicks)
        self.hadTicks = true
    else
        self:HideTicks()
    end
end

function GwCastingBarMixin:Init(unit, showTradeSkills)
    UpdateSettings()
    self.unit = unit
    self.showCastbar = true
    self.spellID = nil
    self.isChanneling = false
    self.isEmpowered = false
    self.isCasting = false
    self.animationName = self:GetDebugName()
    self.showTradeSkills = showTradeSkills
    self.TickLines = {}
    self.numStages = 0
    self.showDetails = GW.settings.CASTINGBAR_DATA
    self.Pips = {}
    self.StagePoints = {}

    self.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    self.name:SetShadowOffset(1, -1)
    self.time:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    self.time:SetShadowOffset(1, -1)
    self:SetAlpha(0)

    if unit == "pet" then
        self:SetScript("OnEvent", self.OnPetEvent)
    else
        self:SetScript("OnEvent", self.OnEvent)
    end
    if unit == "player" then
        self:SetScript("OnUpdate", self.OnUpdate)
    end

    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    if GW.Retail then
        self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", unit)
        self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", unit)
        self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", unit)
    end
    if unit == "pet" then
        self:RegisterEvent("UNIT_PET")
        self.showCastbar = UnitIsPossessed("pet")
    end
end

function GwCastingBarMixin:SetValues(name, icon)
    self.name:SetText(name)
    self.icon:SetTexture(icon)
    self.latency:Show()
end

function GwCastingBarMixin:Reset()
    if animations[self.animationName] then
        animations[self.animationName].completed = true
        animations[self.animationName].duration = 0
    end
    if self.hadTicks and self.unit == "player" then
        self:HideTicks()
        self.hadTicks = false
        self.chainTick = nil
        self.chainTime = nil
    end
end

local function getStageDuration(self, stage, unit)
    if stage == self.numStages then
        return GetUnitEmpowerHoldAtMaxTime(unit)
    else
        return GetUnitEmpowerStageDuration(unit, stage - 1)
    end
end

function GwCastingBarMixin:AddStages(stages, unit)
    local sumDuration = 0
    local elementSize = self:GetWidth()
    local lastOffset = 0

    if self.StagePoints then wipe(self.StagePoints) end

    for stage, stageSection in next, stages do
        local offset = lastOffset + (elementSize * stageSection)
        lastOffset = offset

        if unit == "player" then
            local duration = getStageDuration(self, stage, unit)
            sumDuration = sumDuration + duration
            self.StagePoints[stage]  = sumDuration / self.maxValue / 1000
        end

        local pip = self.Pips[stage]
        if not pip then
            pip = self:CreateNewBarSegment()
            self.Pips[stage] = pip
        end

        pip:ClearAllPoints()
        pip:Show()
        if stage < #stages then
            pip.rank:SetText(stage)
        end
        pip:SetPoint("TOP", self, "TOPLEFT", offset, 0)
        pip:SetPoint("BOTTOM", self, "BOTTOMLEFT", offset, 0)
    end
end

function GwCastingBarMixin:ClearStages()
    for _, pip in next, self.Pips do
        pip.rank:SetText("")
		pip:Hide()
	end
    self.numStages = 0
    if self.StagePoints then wipe(self.StagePoints) end
end

function GwCastingBarMixin:AddFinishAnimation(isStopped, isChanneling)
    self.animating = true
    local highlightColor = isStopped and CASTINGBAR_TEXTURES.RED.HIGHLIGHT or CASTINGBAR_TEXTURES.YELLOW.HIGHLIGHT
    self.highlight:SetTexture("Interface/AddOns/GW2_UI/Textures/units/castingbars/" .. highlightColor .. ".png")
    self.highlight:SetWidth(176)
    self.highlight:SetTexCoord(0, 1, 0, 1)

    if isStopped then
        self.progress:SetFillAmount(1)
        self.highlight:SetTexture("Interface/AddOns/GW2_UI/Textures/units/castingbars/" .. highlightColor .. ".png")
        self.progress:SetStatusBarTexture("Interface/AddOns/GW2_UI/Textures/units/castingbars/" .. CASTINGBAR_TEXTURES.RED.NORMAL .. ".png")
    end

    if isChanneling then
        self.animating = false
        if self:GetAlpha() > 0 then
            GW.AddToAnimation(self.animationName .. "FadeOut", 1, 0, GetTime(), 0.2, function(p)
                self:SetAlpha(math.min(1, math.max(0, p)))
            end)
            self.highlight:Hide()
            self.isCasting = false
            self.isChanneling = false
            self.isEmpowered = false
        end
    else
        self.highlight:Show()
        GW.AddToAnimation(self.animationName .. "Complete", 0, 1, GetTime(), isStopped and 0.5 or 0.2, function(p)
            self.highlight:SetVertexColor(1, 1, 1, lerp(1, 0.7, p))
        end, nil, function()
            self.animating = false
            if not self.isCasting and not self.isChanneling then
                if self:GetAlpha() > 0 then
                    GW.AddToAnimation(self.animationName .. "FadeOut", 1, 0, GetTime(), 0.2, function(p)
                        self:SetAlpha(math.min(1, math.max(0, p)))
                    end)
                    self.highlight:Hide()
                    self.isCasting = false
                    self.isChanneling = false
                    self.isEmpowered = false
                end
            end
        end)
    end
end

function GwCastingBarMixin:OnUpdate(elapsed)
    if self.animating then return end

    if self.isCasting or self.isChanneling then
        if self.isCasting then
            self.duration = self.duration + elapsed
            if self.duration >= self.max then
                if not animations[self.animationName .. "FadeOut"] then
                    self:SetAlpha(0)
                end
                return
            end
        else
            self.duration = self.duration - elapsed
            if self.duration <= 0 then
                if not animations[self.animationName .. "FadeOut"] then
                    self:SetAlpha(0)
                end
                return
            end
        end
    else
        if not animations[self.animationName .. "FadeOut"] then
            self:SetAlpha(0)
        end
    end
end

function GwCastingBarMixin:OnEvent(event, unitID, ...)
    local spell, icon, startTime, endTime, isTradeSkill, castID, spellID, numStages, isEmpowered
    local barTexture = CASTINGBAR_TEXTURES.YELLOW.NORMAL
    local barHighlightTexture = CASTINGBAR_TEXTURES.YELLOW.HIGHLIGHT

    self.highlight:SetTexCoord(0, 1, 0, 1)
    self.highlight:SetWidth(176)

    if event == "PLAYER_ENTERING_WORLD" then
        local nameChannel = UnitChannelInfo(self.unit)
        local nameSpell = UnitCastingInfo(self.unit)
        if nameChannel then
            event = "UNIT_SPELLCAST_CHANNEL_START"
        elseif nameSpell then
            event = "UNIT_SPELLCAST_START"
        else
            self:Reset()
        end
    end

    if unitID ~= self.unit or not self.showCastbar then
        return
    end

    if IsIn(event, "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_DELAYED") then
        if IsIn(event, "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_EMPOWER_UPDATE") then
            spell, _, icon, startTime, endTime, isTradeSkill, _, spellID, isEmpowered, numStages = UnitChannelInfo(self.unit)
            if isEmpowered then
                endTime = endTime + GetUnitEmpowerHoldAtMaxTime(self.unit)
            end
            if isEmpowered then
                self.isEmpowered = true
                self.isChanneling = false
                self.isCasting = true
            else
                self.isEmpowered = false
                self.isChanneling = true
                self.isCasting = false
            end
            barTexture = CASTINGBAR_TEXTURES.GREEN.NORMAL
            barHighlightTexture = CASTINGBAR_TEXTURES.GREEN.HIGHLIGHT
        else
            spell, _, icon, startTime, endTime, isTradeSkill, castID, _, spellID = UnitCastingInfo(self.unit)
            self.isCasting = true
        end

        self.progress:SetStatusBarTexture("Interface/AddOns/GW2_UI/Textures/units/castingbars/" .. barTexture .. ".png")
        self.highlight:SetTexture("Interface/AddOns/GW2_UI/Textures/units/castingbars/" .. barHighlightTexture .. ".png")

        self:Reset()

        if not spell or (not self.showTradeSkills and isTradeSkill) then
            self:Reset()
            return
        end

        if self.showDetails then
            self:SetValues(spell, icon)
        end

        self.numStages = numStages and numStages + 1 or 0
        self.maxValue = (endTime - startTime) / 1000
        self.spellID = spellID
        self.castID = castID
        self.startTime = startTime / 1000
        self.endTime = endTime / 1000
        self.max = self.endTime - self.startTime

        if self.isChanneling then
            self.duration = endTime - GetTime()
        else
            self.duration = GetTime() - startTime
        end

        self.highlight:Hide()
        GW.StopAnimation(self.animationName)
        if self.isEmpowered then
            self:AddStages(UnitEmpoweredStagePercentages(self.unit), self.unit)
        else
            self:ClearStages()
        end

        if self.unit == "player" and GW.settings.showPlayerCastBarTicks and self.isChanneling then
            self:CheckForTicks()
        end

        GW.AddToAnimation(
            self.animationName,
            0,
            1,
            self.startTime,
            self.endTime - self.startTime,
            function(p)
                if self.showDetails then
                    self.time:SetText(TimeCount(self.endTime - GetTime(), true))
                end
                p = self.isChanneling and (1 - p) or p
                self.latency:ClearAllPoints()
                self.latency:SetPoint(self.isChanneling and "LEFT" or "RIGHT", self, self.isChanneling and "LEFT" or "RIGHT")
                self.progress:SetFillAmount(p)
                if self.numStages > 0 and self.StagePoints then
                    for i = 1, self.numStages - 1 do
                        local stage_percentage = self.StagePoints[i]
                        if stage_percentage <= p then
                            self.highlight:SetTexCoord(0, stage_percentage, 0, 1)
                            self.highlight:SetWidth(math.max(1, stage_percentage * 176))
                            self.highlight:Show()
                        end
                        if i == 1 and stage_percentage >= p then
                            self.highlight:Hide()
                        end
                    end
                end
                local lagWorld = select(4, GetNetStats()) / 1000
                local sqw = settings.showSpellQueueWindow and (tonumber(GetCVar("SpellQueueWindow")) or 0) / 1000 or 0
                self.latency:SetWidth(math.max(0.0001, math.min(1, ((sqw + lagWorld) / (self.endTime - self.startTime)))) * 176)
            end,
            "noease"
        )

        if GW.StopAnimation(self.animationName .. "FadeOut") then
            self:SetAlpha(1)
        elseif self:GetAlpha() < 1 then
            UIFrameFadeIn(self, 0.1, 0, 1)
        end
    elseif IsIn(event, "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_EMPOWER_STOP") then
        if (event == "UNIT_SPELLCAST_STOP" and self.castID == select(1, ...)) or
           ((event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") and (self.isChanneling or self.isEmpowered)) then
            if not self.animating then
                self:AddFinishAnimation(false, true)
            end
            self:Reset()
            self.isCasting = false
            self.isChanneling = false
            self.isEmpowered = false
        end
    elseif IsIn(event, "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_FAILED") then
        if self:IsShown() and self.isCasting and select(1, ...) == self.castID then
            if self.showDetails then
                self.name:SetText(event == "UNIT_SPELLCAST_FAILED" and FAILED or INTERRUPTED)
            end
            self:AddFinishAnimation(true)
            self.isCasting = false
            self.isChanneling = false
            self.isEmpowered = false
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and self.spellID == select(2, ...) and not self.isChanneling then
        self:AddFinishAnimation(false)
    end
end

function GwCastingBarMixin:OnPetEvent(event, unit, ...)
    if event == "UNIT_PET" then
        if unit == "player" then
            self.showCastbar = UnitIsPossessed("pet")
        end
        return
    end
    self:OnEvent(event, unit, ...)
end

function GwCastingBarMixin:CreateNewBarSegment()
    local segment = CreateFrame("Frame", nil, self, "GwCastingBarSegmentSep")
    segment.rank:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    segment.rank:SetShadowOffset(1, -1)
    return segment
end

local function TogglePlayerEnhancedCastbar(self, setShown)
    if not self then return end
    self.name:SetShown(setShown)
    self.icon:SetShown(setShown)
    self.latency:SetShown(setShown)
    self.time:SetShown(setShown)
    self.showDetails = setShown

    if self.gwMover then
        self:ClearAllPoints()
        if setShown then
            self.gwMover:SetSize(self:GetWidth() + self.icon:GetWidth(), math.max(self:GetHeight(), self.icon:GetHeight()))
            self:SetPoint("CENTER", self.gwMover, self.icon:GetWidth() / 2, -(self.icon:GetHeight() / 4))
        else
            self.gwMover:SetSize(self:GetWidth(), self:GetHeight())
            self:SetPoint("CENTER", self.gwMover)
        end
    end
end
GW.TogglePlayerEnhancedCastbar = TogglePlayerEnhancedCastbar

local function LoadCastingBar(name, unit, showTradeSkills)
    UpdateSettings()

    local GwCastingBar = CreateFrame("Frame", name, UIParent, "GwCastingBar")
    GW.AddStatusbarAnimation(GwCastingBar.progress, false)
    GwCastingBar.progress.customMaskSize = 64
    GwCastingBar.highlight = GwCastingBar.progress.highlight
    GwCastingBar.latency = GwCastingBar.progress.latency
    GwCastingBar:Init(unit, showTradeSkills)

    if name == "GwCastingBarPlayer" then
        RegisterMovableFrame(GwCastingBar, SHOW_ARENA_ENEMY_CASTBAR_TEXT, "castingbar_pos", ALL .. ",Blizzard", nil, {"default", "scaleable"})
        GwCastingBar:ClearAllPoints()
        GwCastingBar:SetPoint("CENTER", GwCastingBar.gwMover)
    else
        GwCastingBar:ClearAllPoints()
        GwCastingBar:SetPoint("TOPLEFT", GwCastingBarPlayer.gwMover, "TOPLEFT", 0, 35)
    end

    TogglePlayerEnhancedCastbar(GwCastingBar, GwCastingBar.showDetails)

    return GwCastingBar
end
GW.LoadCastingBar = LoadCastingBar
