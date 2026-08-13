---@class GW2
local GW = select(2, ...)
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

local TEXTURE_PATH = "Interface/AddOns/GW2_UI/Textures/units/castingbars/"

-- which texture set and which color setting belong to a cast kind
local CASTINGBAR_KINDS = {
    cast = {textures = CASTINGBAR_TEXTURES.YELLOW, color = "CASTINGBAR_COLOR_CAST"},
    channel = {textures = CASTINGBAR_TEXTURES.GREEN, color = "CASTINGBAR_COLOR_CHANNEL"},
    empower = {textures = CASTINGBAR_TEXTURES.GREEN, color = "CASTINGBAR_COLOR_EMPOWER"},
    interrupted = {textures = CASTINGBAR_TEXTURES.RED, color = "CASTINGBAR_COLOR_INTERRUPTED"},
}

-- the color the last empower stage fades towards, the earlier stages sit between it
-- and the empower base color
local EMPOWER_STAGE_TINT = {r = 1, g = 0.96, b = 0.65}
local EMPOWER_STAGE_NUMERALS = {"I", "II", "III", "IV", "V", "VI"}

local settings = {}
GwCastingBarMixin = {}

local function UpdateSettings()
    settings.showSpellQueueWindow = GW.settings.PLAYER_CASTBAR_SHOW_SPELL_QUEUEWINDOW
    settings.width = tonumber(GW.settings.CASTINGBAR_WIDTH) or 176
    settings.height = tonumber(GW.settings.CASTINGBAR_HEIGHT) or 15
    settings.iconPosition = GW.settings.CASTINGBAR_ICON_POSITION or "HIDE"
    settings.showName = GW.settings.CASTINGBAR_SHOW_NAME
    settings.showTimer = GW.settings.CASTINGBAR_SHOW_TIMER
    settings.showLatency = GW.settings.CASTINGBAR_SHOW_LATENCY
    settings.customColors = GW.settings.CASTINGBAR_CUSTOM_COLORS
    settings.empowerStageColors = GW.settings.CASTINGBAR_EMPOWER_STAGE_COLORS
    settings.interruptShake = GW.settings.CASTINGBAR_INTERRUPT_SHAKE
    settings.interruptSound = GW.settings.CASTINGBAR_INTERRUPT_SOUND
end
GW.UpdateCastingBarSettings = UpdateSettings

-- the tick and pip template ships the default bar height, both have to follow the bar they
-- sit on - which is our own bar or, through the shared mixin, a unit frames casting bar
local function setSegmentHeight(segment, height)
    segment:SetHeight(height)
    if segment.line then
        segment.line:SetHeight(height)
    end
end

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
        setSegmentHeight(tick, self:GetHeight())
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
                if GW.IsSpellInSpellBook(auraId) or GW.IsSpellKnown(auraId) then
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

-- keeps the anchor the bar returns to, so the interrupt shake can offset it and put it back
function GwCastingBarMixin:SetBasePoint(point, relativeTo, relativePoint, x, y)
    self.gwBasePoint = self.gwBasePoint or {}
    local base = self.gwBasePoint
    base.point, base.relativeTo, base.relativePoint = point, relativeTo, relativePoint
    base.x, base.y = x or 0, y or 0

    self:ClearAllPoints()
    self:SetPoint(base.point, base.relativeTo, base.relativePoint, base.x, base.y)
end

function GwCastingBarMixin:ApplySize()
    local width, height = settings.width, settings.height
    local iconSize = math.max(12, GW.RoundInt(height * 2))

    self:SetSize(width, height)
    self.progress:SetSize(width, height)

    -- width is set per cast (finish animation, empower stages), the height is ours
    self.highlight:SetSize(width, height)
    self.latency:SetHeight(height)

    self.icon:SetSize(iconSize, iconSize)
    self.icon:ClearAllPoints()
    if settings.iconPosition == "RIGHT" then
        self.icon:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 0, 0)
    else
        self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 0, 0)
    end

    -- the cast name takes whatever the timer leaves of the bar width
    local timeWidth = math.min(70, width * 0.4)
    self.time:SetWidth(timeWidth)
    self.name:SetWidth(math.max(20, width - timeWidth))

    if self.stage then
        -- the stage sits inside the bar, so it follows the bars height
        local sizeType = GW.Enum.TextSizeType.Small
        if height >= 26 then
            sizeType = GW.Enum.TextSizeType.Header
        elseif height >= 18 then
            sizeType = GW.Enum.TextSizeType.Normal
        end
        self.stage:GwSetFontTemplate(UNIT_NAME_FONT, sizeType, "OUTLINE")
    end

    for _, tick in next, self.TickLines or {} do
        setSegmentHeight(tick, height)
    end
    for _, pip in next, self.Pips or {} do
        setSegmentHeight(pip, height)
    end
end

-- without custom colors the flavored textures are used as they are, with them the painted
-- texture is desaturated first so the brush structure survives while the hue comes from the tint
local function resolveKind(kind)
    local kindInfo = CASTINGBAR_KINDS[kind] or CASTINGBAR_KINDS.cast
    return kindInfo, settings.customColors and GW.settings[kindInfo.color] or nil
end

-- the flash drawn over a finished or failed cast, set apart from the bar itself because a
-- finished cast flashes in the "done" art without repainting the bar underneath
function GwCastingBarMixin:SetHighlightKind(kind)
    if not self.progress then
        return
    end

    local kindInfo, color = resolveKind(kind)
    self.highlight:SetTexture(TEXTURE_PATH .. kindInfo.textures.HIGHLIGHT .. ".png")
    self.highlight:SetDesaturated(color ~= nil)
    self.highlight:SetVertexColor(color and color.r or 1, color and color.g or 1, color and color.b or 1)
    self.gwHighlightColor = color
end

function GwCastingBarMixin:SetCastKind(kind)
    -- the unit frame casting bars share this mixin but are the status bar themselves and bring
    -- their own art, only our own bar has the progress child with the textures below
    if not self.progress then
        return
    end

    local kindInfo, color = resolveKind(kind)
    self.gwCastKind = kind

    self.progress:SetStatusBarTexture(TEXTURE_PATH .. kindInfo.textures.NORMAL .. ".png")
    self:SetBarColor(color)
    self:SetHighlightKind(kind)
end

-- color of nil restores the untinted texture
function GwCastingBarMixin:SetBarColor(color)
    if not self.progress then
        return
    end

    local barTexture = self.progress:GetStatusBarTexture()
    if barTexture then
        barTexture:SetDesaturated(color ~= nil)
    end

    if color then
        self.progress:SetStatusBarColor(color.r, color.g, color.b)
    else
        self.progress:SetStatusBarColor(1, 1, 1)
    end

    self.gwBarColor = color
end

function GwCastingBarMixin:SetEmpowerStage(stage)
    if self.gwEmpowerStage == stage then
        return
    end
    self.gwEmpowerStage = stage

    if self.stage then
        local showStage = stage ~= nil and settings.empowerStageColors
        self.stage:SetShown(showStage)
        self.stage:SetText(showStage and (EMPOWER_STAGE_NUMERALS[stage] or stage) or "")
    end

    if not settings.empowerStageColors then
        return
    end

    if not stage then
        -- back to the plain color of whatever the bar is showing
        local _, color = resolveKind(self.gwCastKind)
        self:SetBarColor(color)
        return
    end

    -- the held stage brightens the bar towards EMPOWER_STAGE_TINT, so the stage is readable
    -- from the color alone. numStages counts the hold-at-max section as well, the highest stage
    -- one can actually hold is numStages - 1 and that one gets the full tint
    local base = (settings.customColors and GW.settings[CASTINGBAR_KINDS.empower.color]) or {r = 1, g = 0.72, b = 0.2}
    local p = (stage - 1) / math.max(1, (self.numStages or 0) - 2)
    self:SetBarColor({
        r = lerp(base.r, EMPOWER_STAGE_TINT.r, p),
        g = lerp(base.g, EMPOWER_STAGE_TINT.g, p),
        b = lerp(base.b, EMPOWER_STAGE_TINT.b, p),
    })
end

function GwCastingBarMixin:AddInterruptFeedback()
    if settings.interruptSound then
        PlaySound(SOUNDKIT.IG_QUEST_FAILED)
    end

    local base = self.gwBasePoint
    if not settings.interruptShake or not base or not base.point then
        return
    end

    GW.AddToAnimation(self.animationName .. "Shake", 0, 1, GetTime(), 0.35, function(p)
        self:ClearAllPoints()
        self:SetPoint(base.point, base.relativeTo, base.relativePoint, base.x + math.sin(p * 42) * 5 * (1 - p), base.y)
    end, nil, function()
        self:ClearAllPoints()
        self:SetPoint(base.point, base.relativeTo, base.relativePoint, base.x, base.y)
    end)
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
    self.Pips = {}
    self.StagePoints = {}

    self.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    self.time:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    if self.stage then
        self.stage:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE")
        self.stage:Hide()
    end
    self:SetAlpha(0)

    if unit == "pet" then
        self:SetScript("OnEvent", self.OnPetEvent)
    else
        self:SetScript("OnEvent", self.OnEvent)
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
        -- UnitIsPossessed can return a secret boolean (12.1) — a later boolean test
        -- on it would throw for tainted code, fall back to hidden then
        local possessed = UnitIsPossessed("pet")
        self.showCastbar = not GW.IsSecretValue(possessed) and possessed
    end
end

function GwCastingBarMixin:SetValues(name, icon)
    self.name:SetText(name)
    self.icon:SetTexture(icon)
    if settings.showLatency then
        self.latency:Show()
    end
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
    if not stages then return end
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
        setSegmentHeight(pip, self:GetHeight())
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
    self:SetEmpowerStage(nil)
end

function GwCastingBarMixin:IsFinishAnimating()
    return self.finishAnimationUntil ~= nil and GetTime() < self.finishAnimationUntil
end

function GwCastingBarMixin:AddFinishAnimation(isStopped, isChanneling)
    local flashDuration = isStopped and 0.5 or 0.2
    self.finishAnimationUntil = GetTime() + flashDuration
    self:SetEmpowerStage(nil)
    self:SetHighlightKind(isStopped and "interrupted" or "cast")
    self.highlight:SetWidth(self:GetWidth())
    self.highlight:SetTexCoord(0, 1, 0, 1)

    if isStopped then
        -- a stopped cast repaints the bar itself, a finished one only flashes
        self:SetCastKind("interrupted")
        self.progress:SetFillAmount(1)
        self:AddInterruptFeedback()
    end

    if isChanneling then
        self.finishAnimationUntil = nil -- no flash for a channel, nothing to wait for
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
        local color = self.gwHighlightColor
        local hr, hg, hb = color and color.r or 1, color and color.g or 1, color and color.b or 1
        GW.AddToAnimation(self.animationName .. "Complete", 0, 1, GetTime(), flashDuration, function(p)
            self.highlight:SetVertexColor(hr, hg, hb, lerp(1, 0.7, p))
        end, nil, function()
            self.finishAnimationUntil = nil
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

-- overrun watchdog for the player bar: hides the bar when a cast runs past its
-- end without a stop event. Armed on cast start, disarms itself once the bar
-- reached an end state - it does NOT run permanently
function GwCastingBarMixin:OnUpdate(elapsed)
    if self:IsFinishAnimating() then return end

    if self.isCasting or self.isChanneling then
        if self.isCasting then
            self.duration = self.duration + elapsed
            if self.duration >= self.max then
                if not animations[self.animationName .. "FadeOut"] then
                    self:SetAlpha(0)
                end
                self:SetScript("OnUpdate", nil)
                return
            end
        else
            self.duration = self.duration - elapsed
            if self.duration <= 0 then
                if not animations[self.animationName .. "FadeOut"] then
                    self:SetAlpha(0)
                end
                self:SetScript("OnUpdate", nil)
                return
            end
        end
    else
        if not animations[self.animationName .. "FadeOut"] then
            self:SetAlpha(0)
        end
        self:SetScript("OnUpdate", nil)
    end
end

function GwCastingBarMixin:OnEvent(event, unitID, ...)
    local spell, icon, startTime, endTime, isTradeSkill, castID, spellID, numStages, isEmpowered
    local castKind = "cast"

    self.highlight:SetTexCoord(0, 1, 0, 1)
    self.highlight:SetWidth(self:GetWidth())

    if event == "PLAYER_ENTERING_WORLD" then
        local nameChannel = UnitChannelInfo(self.unit)
        local nameSpell = UnitCastingInfo(self.unit)
        if nameChannel then
            event = "UNIT_SPELLCAST_CHANNEL_START"
        elseif nameSpell then
            event = "UNIT_SPELLCAST_START"
        else
            self:Reset()
            self:SetAlpha(0)
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
            castKind = isEmpowered and "empower" or "channel"
        else
            spell, _, icon, startTime, endTime, isTradeSkill, castID, _, spellID = UnitCastingInfo(self.unit)
            self.isCasting = true
        end

        self:SetEmpowerStage(nil)
        self:SetCastKind(castKind)

        self:Reset()

        if not spell or (not self.showTradeSkills and isTradeSkill) then
            self:Reset()
            return
        end

        self:SetValues(spell, icon)

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

        -- The latency indicator's anchor and width are constant for the whole cast
        -- (spell queue window, lag and cast span don't change per frame), so compute them
        -- once here instead of on every animation frame.
        self.latency:ClearAllPoints()
        self.latency:SetPoint(self.isChanneling and "LEFT" or "RIGHT", self, self.isChanneling and "LEFT" or "RIGHT")
        local lagWorld = select(4, GetNetStats()) / 1000
        local sqw = settings.showSpellQueueWindow and (tonumber(GetCVar("SpellQueueWindow")) or 0) / 1000 or 0
        local barWidth = self:GetWidth()
        self.latency:SetWidth(math.max(0.0001, math.min(1, ((sqw + lagWorld) / (self.endTime - self.startTime)))) * barWidth)

        GW.AddToAnimation(
            self.animationName,
            0,
            1,
            self.startTime,
            self.endTime - self.startTime,
            function(p)
                if settings.showTimer then
                    self.time:SetText(TimeCount(self.endTime - GetTime(), true))
                end
                p = self.isChanneling and (1 - p) or p
                self.progress:SetFillAmount(p)
                if self.numStages > 0 and self.StagePoints then
                    local reachedStage = 0
                    for i = 1, self.numStages - 1 do
                        local stage_percentage = self.StagePoints[i]
                        if stage_percentage <= p then
                            reachedStage = i
                            self.highlight:SetTexCoord(0, stage_percentage, 0, 1)
                            self.highlight:SetWidth(math.max(1, stage_percentage * barWidth))
                            self.highlight:Show()
                        end
                        if i == 1 and stage_percentage >= p then
                            self.highlight:Hide()
                        end
                    end
                    self:SetEmpowerStage(reachedStage > 0 and reachedStage or nil)
                end
            end,
            "noease"
        )

        if GW.StopAnimation(self.animationName .. "FadeOut") then
            self:SetAlpha(1)
        elseif self:GetAlpha() < 1 then
            UIFrameFadeIn(self, 0.1, 0, 1)
        end

        if self.unit == "player" then
            self:SetScript("OnUpdate", self.OnUpdate)
        end
    elseif IsIn(event, "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_EMPOWER_STOP") then
        if (event == "UNIT_SPELLCAST_STOP" and self.castID == select(1, ...)) or
           ((event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") and (self.isChanneling or self.isEmpowered)) then
            if not self:IsFinishAnimating() then
                self:AddFinishAnimation(false, true)
            end
            self:Reset()
            self.isCasting = false
            self.isChanneling = false
            self.isEmpowered = false
        end
    elseif IsIn(event, "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_FAILED") then
        if self:IsShown() and self.isCasting and select(1, ...) == self.castID then
            if settings.showName then
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
            local possessed = UnitIsPossessed("pet")
            self.showCastbar = not GW.IsSecretValue(possessed) and possessed
        end
        return
    end
    self:OnEvent(event, unit, ...)
end

function GwCastingBarMixin:CreateNewBarSegment()
    local segment = CreateFrame("Frame", nil, self, "GwCastingBarSegmentSep")
    segment.rank:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    return segment
end

-- spell name, timer, latency zone and icon each have their own setting; this shows or hides
-- them and fits the mover around whatever is left
local function ApplyDetailSettings(self)
    if not self then return end
    local showIcon = settings.iconPosition ~= "HIDE"
    self.name:SetShown(settings.showName)
    self.time:SetShown(settings.showTimer)
    self.latency:SetShown(settings.showLatency)
    self.icon:SetShown(showIcon)

    if self.gwMover then
        -- the mover covers the icon as well, so dragging grabs the whole thing
        local iconWidth = showIcon and self.icon:GetWidth() or 0
        local iconHeight = showIcon and self.icon:GetHeight() or 0
        self.gwMover:SetSize(self:GetWidth() + iconWidth, math.max(self:GetHeight(), iconHeight))

        local offsetX = iconWidth / 2
        if settings.iconPosition == "RIGHT" then
            offsetX = -offsetX
        end
        self:SetBasePoint("CENTER", self.gwMover, "CENTER", offsetX, -(iconHeight / 4))
    end
end

-- the pet bar rides above the player bar, with a gap that has to follow the bar height
local function AnchorPetCastbar()
    if not GwCastingBarPet or not GwCastingBarPlayer or not GwCastingBarPlayer.gwMover then
        return
    end
    GwCastingBarPet:SetBasePoint("TOPLEFT", GwCastingBarPlayer.gwMover, "TOPLEFT", 0, GwCastingBarPlayer:GetHeight() + 20)
end

local function LoadCastingBar(name, unit, showTradeSkills)
    UpdateSettings()

    local GwCastingBar = CreateFrame("Frame", name, UIParent, "GwCastingBar")
    GW.AddStatusbarAnimation(GwCastingBar.progress, false)
    GwCastingBar.progress.customMaskSize = 64
    GwCastingBar.highlight = GwCastingBar.progress.highlight
    GwCastingBar.latency = GwCastingBar.progress.latency
    GwCastingBar.stage = GwCastingBar.progress.stage
    GwCastingBar:Init(unit, showTradeSkills)
    GwCastingBar:ApplySize()
    GwCastingBar:SetCastKind("cast")

    if name == "GwCastingBarPlayer" then
        RegisterMovableFrame(GwCastingBar, SHOW_ARENA_ENEMY_CASTBAR_TEXT, "castingbar_pos", "Blizzard", nil, {"default", "scaleable"})
        GwCastingBar:SetBasePoint("CENTER", GwCastingBar.gwMover, "CENTER", 0, 0)
    else
        GwCastingBar:SetBasePoint("TOPLEFT", GwCastingBarPlayer.gwMover, "TOPLEFT", 0, GwCastingBarPlayer:GetHeight() + 20)
    end

    ApplyDetailSettings(GwCastingBar)

    return GwCastingBar
end
GW.LoadCastingBar = LoadCastingBar

-- re-applies every layout and color setting to the existing bars, used by the settings panel
local function UpdateCastingBarLayout()
    UpdateSettings()

    for _, bar in next, {GwCastingBarPlayer, GwCastingBarPet} do
        bar:ApplySize()
        bar:SetCastKind(bar.gwCastKind or "cast")
        ApplyDetailSettings(bar)
    end

    AnchorPetCastbar()
end
GW.UpdateCastingBarLayout = UpdateCastingBarLayout
