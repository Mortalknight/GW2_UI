local _, GW = ...
local lerp = GW.lerp
local TimeCount = GW.TimeCount
local RegisterMovableFrame = GW.RegisterMovableFrame
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local StopAnimation = GW.StopAnimation
local IsIn = GW.IsIn

local CASTBAR_STAGE_DURATION_INVALID = -1

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

local function UpdateSettings()
    settings.showSpellQueueWindow = GW.settings.PLAYER_CASTBAR_SHOW_SPELL_QUEUEWINDOW
end
GW.UpdateCastingBarSettings = UpdateSettings

local function HideTicks(self)
    for _, tick in next, self.TickLines do
        tick:Hide()
    end
end

local function SetCastTicks(frame, numTicks)
    HideTicks(frame)

    if numTicks and numTicks <= 0 then return end

    local offset = frame:GetWidth() / numTicks

    for i = 1, numTicks - 1 do
        local tick = frame.TickLines[i]
        if not tick then
            tick = CreateFrame("Frame", nil, frame, "GwCastingBarSegmentSep")
            tick.rank:Hide()
            frame.TickLines[i] = tick
        end

        tick:ClearAllPoints()
        tick:SetPoint("TOPRIGHT", frame, "TOPLEFT", offset * i, 0)
        tick:Show()
    end
end

local function GetTalentTicks(info)
    local _, _, _, selected = GetTalentInfo(info.tier, info.column, 1)
    return selected and info.ticks
end

local function CheckForTicks(self)
    local baseTicks = GW.ChannelTicks[self.spellID]

    local talentTicks = baseTicks and GW.TalentChannelTicks[self.spellID]
    local selectedTicks = talentTicks and GetTalentTicks(talentTicks)
    if selectedTicks then
        baseTicks = selectedTicks
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
            baseTicks = chainTicks
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

        SetCastTicks(self, baseTicks + bonus)
        self.hadTicks = true
    elseif baseTicks then
        SetCastTicks(self, baseTicks)
        self.hadTicks = true
    else
        HideTicks(self)
    end
end

local function createNewBarSegment(self)
    local segment = CreateFrame("Frame", self:GetName() .. "Segment" .. #self.segments + 1, self, "GwCastingBarSegmentSep")

    segment.rank:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    segment.rank:SetShadowOffset(1, -1)
    self.segments[#self.segments + 1] = segment

    return segment
end

local function AddStages(self, parent, barWidth)
    local sumDuration = 0
    local castBarLeft = self:GetLeft()
    local castBarRight = self:GetRight()
    local castBarWidth = castBarRight - castBarLeft
    self.StagePoints = {}

    local getStageDuration = function(stage)
        if stage == self.numStages then
            return GetUnitEmpowerHoldAtMaxTime(self.unit)
        else
            return GetUnitEmpowerStageDuration(self.unit, stage - 1)
        end
    end

    for i = 1, self.numStages - 1, 1 do
        local duration = getStageDuration(i)
        if duration > CASTBAR_STAGE_DURATION_INVALID then
            sumDuration = sumDuration + duration
            local portion = sumDuration / self.maxValue / 1000
            local segment = self.segments[i] or createNewBarSegment(self)
            self.StagePoints[i] = portion

            segment:SetPoint("TOPLEFT", (parent and parent or self), "TOPLEFT", (barWidth and barWidth or castBarWidth) * portion, 0)

            segment.rank:SetText(i)
            segment:Show()
        end
    end
end
GW.AddStages = AddStages

local function ClearStages(self)
    for k, _ in pairs(self.segments) do
        if self.segments[k] then
            self.segments[k]:Hide()
        end
    end

    self.numStages = 0
    table.wipe(self.StagePoints)
end
GW.ClearStages = ClearStages

local function barValues(self, name, icon)
    self.name:SetText(name)
    self.icon:SetTexture(icon)
    self.latency:Show()
end
GW.AddForProfiling("castingbar", "barValues", barValues)

local function barReset(self)
    if animations[self.animationName] then
        animations[self.animationName].completed = true
        animations[self.animationName].duration = 0
    end

    if self.hadTicks and self.unit == "player" then
        HideTicks(self)
        self.hadTicks = false
        self.chainTick = nil -- reset the chain
        self.chainTime = nil -- spell cast vars
    end
end
GW.AddForProfiling("castingbar", "barReset", barReset)

local function AddFinishAnimation(self, isStopped, isChanneling)
    self.animating = true
    local highlightColor = isStopped and CASTINGBAR_TEXTURES.RED.HIGHLIGHT or CASTINGBAR_TEXTURES.YELLOW.HIGHLIGHT
    self.highlight:SetTexture("Interface/AddOns/GW2_UI/Textures/units/castingbars/"..highlightColor)
    self.highlight:SetWidth(176)
    self.highlight:SetTexCoord(0,1,0,1);


    if isStopped then
        self.progress:SetFillAmount(1);
        self.highlight:SetTexture("Interface/AddOns/GW2_UI/Textures/units/castingbars/" .. highlightColor)
        self.progress:SetStatusBarTexture("Interface/AddOns/GW2_UI/Textures/units/castingbars/" .. CASTINGBAR_TEXTURES.RED.NORMAL)
    end

    if isChanneling then
        self.animating = false
        if self:GetAlpha() > 0 then
            AddToAnimation(
                self.animationName .. "FadeOut",
                1,
                0,
                GetTime(),
                0.2,
                function(p)
                    p = math.min(1, math.max(0, p))
                    self:SetAlpha(p)
                end
            )
            self.highlight:Hide()
            self.isCasting = false
            self.isChanneling = false
            self.reverseChanneling = false
        end
    else
        self.highlight:Show()
        AddToAnimation(
            self.animationName .. "Complete",
            0,
            1,
            GetTime(),
            isStopped and 0.5 or 0.2,
            function(p)
                self.highlight:SetVertexColor(1, 1, 1, lerp(1, 0.7, p))
            end,
            nil,
            function()
                self.animating = false
                if not self.isCasting and not self.isChanneling then
                    if self:GetAlpha() > 0 then
                        AddToAnimation(
                            self.animationName .. "FadeOut",
                            1,
                            0,
                            GetTime(),
                            0.2,
                            function(p)
                                p = math.min(1, math.max(0, p))
                                self:SetAlpha(p)
                            end, nil
                        )
                        self.highlight:Hide()
                        self.isCasting = false
                        self.isChanneling = false
                        self.reverseChanneling = false
                    end
                end
            end
        )
    end
end

local function castBar_OnEvent(self, event, unitID, ...)
    local spell, icon, startTime, endTime, isTradeSkill, castID, spellID, numStages
    local barTexture = CASTINGBAR_TEXTURES.YELLOW.NORMAL
    local barHighlightTexture = CASTINGBAR_TEXTURES.YELLOW.HIGHLIGHT
    self.highlight:SetTexCoord(0,1,0,1)
    self.highlight:SetWidth( 176)
    if event == "PLAYER_ENTERING_WORLD" then
        local nameChannel = UnitChannelInfo(self.unit)
        local nameSpell = UnitCastingInfo(self.unit)
        if nameChannel then
            event = "UNIT_SPELLCAST_CHANNEL_START"
        elseif nameSpell then
            event = "UNIT_SPELLCAST_START"
        else
            barReset(self)
        end
    end

    if unitID ~= self.unit or not self.showCastbar then
        return
    end

    if IsIn(event, "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_DELAYED") then
        if IsIn(event, "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_EMPOWER_UPDATE") then
            spell, _, icon, startTime, endTime, isTradeSkill, _, spellID, _, numStages = UnitChannelInfo(self.unit)
            local isChargeSpell = (numStages or 0) > 0
            if isChargeSpell then
                endTime = endTime + GetUnitEmpowerHoldAtMaxTime(self.unit)
            end

            if isChargeSpell then
                self.reverseChanneling = true
                self.isChanneling = false
                self.isCasting = true
            else
                self.reverseChanneling = false
                self.isChanneling = true
                self.isCasting = false
            end

            barTexture = CASTINGBAR_TEXTURES.GREEN.NORMAL
            barHighlightTexture = CASTINGBAR_TEXTURES.GREEN.HIGHLIGHT
        else
            spell, _, icon, startTime, endTime, isTradeSkill, castID, _, spellID = UnitCastingInfo(self.unit)

            self.isChanneling = false
            self.isCasting = true
            self.reverseChanneling = false
        end
        self.progress:SetStatusBarTexture("Interface/AddOns/GW2_UI/Textures/units/castingbars/"..barTexture)
        self.highlight:SetTexture("Interface/AddOns/GW2_UI/Textures/units/castingbars/"..barHighlightTexture)

        barReset(self)

        self.barHighLightCoords = barHighlightTexture

        if not spell or (not self.showTradeSkills and isTradeSkill) then
            barReset(self)
            return
        end

        if self.showDetails then
            barValues(self, spell, icon)
        end

        self.numStages = numStages and numStages + 1 or 0
        self.maxValue = (endTime - startTime) / 1000
        self.spellID = spellID
        self.castID = castID
        self.startTime = startTime / 1000
        self.endTime = endTime / 1000
        self.max = self.endTime -   self.startTime

        if self.isChanneling then
            self.duration = endTime - GetTime()
        else
            self.duration = GetTime() - startTime
        end

        self.highlight:Hide()

        StopAnimation(self.animationName)

        if self.reverseChanneling then
            AddStages(self)
        else
            ClearStages(self)
        end

        --channelTicks
        if self.unit == "player" and GW.settings.showPlayerCastBarTicks and self.isChanneling then
            CheckForTicks(self)
        end

        AddToAnimation(
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

                if self.numStages > 0 then
                    for i = 1, self.numStages - 1, 1 do
                        local stage_percentage = self.StagePoints[i]
                        if stage_percentage <= p then
                            self.highlight:SetTexCoord(0,stage_percentage,0,1)
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

        if StopAnimation(self.animationName .. "FadeOut") then
            self:SetAlpha(1)
        elseif self:GetAlpha() < 1 then
            UIFrameFadeIn(self, 0.1, 0, 1)
        end
    elseif IsIn(event, "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_EMPOWER_STOP") then
        if (event == "UNIT_SPELLCAST_STOP" and self.castID == select(1, ...)) or
            ((event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") and (self.isChanneling or self.reverseChanneling)) then
            if self.animating == nil or self.animating == false then
                AddFinishAnimation(self, false, true)
            end
            barReset(self)
            self.isCasting = false
            self.isChanneling = false
            self.reverseChanneling = false
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
        if self:IsShown() and self.isCasting and select(1, ...) == self.castID then
            if self.showDetails then
                if event == "UNIT_SPELLCAST_FAILED" then
                    self.name:SetText(FAILED)
                else
                    self.name:SetText(INTERRUPTED)
                end
            end
            AddFinishAnimation(self, true)
            self.isCasting = false
            self.isChanneling = false
            self.reverseChanneling = false
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and self.spellID == select(2, ...) and not self.isChanneling then
        AddFinishAnimation(self, false)
    end
end

local function petCastBar_OnEvent(self, event, unit, ...)
    if event == "UNIT_PET" then
        if unit == "player" then
            self.showCastbar = UnitIsPossessed("pet")
        end
        return
    end
    castBar_OnEvent(self, event, unit, ...)
end

local function onUpdate(self, elapsed)
    if self.animating then return end
    if self.isCasting or self.isChanneling then
        if self.isCasting then
            self.duration = self.duration + elapsed
            if self.duration >= self.max then
                if animations[self.animationName .. "FadeOut"] == nil then
                    self:SetAlpha(0)
                end
                return
            end
        else
            self.duration = self.duration - elapsed
            if self.duration <= 0 then
                if animations[self.animationName .. "FadeOut"] == nil then
                    self:SetAlpha(0)
                end
                return
            end
        end
    else
        if animations[self.animationName .. "FadeOut"] == nil then
            self:SetAlpha(0)
        end
    end
end

local function TogglePlayerEnhancedCastbar(self, setShown)
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
    GW.hookStatusbarBehaviour(GwCastingBar.progress,false);
    GwCastingBar.progress.customMaskSize = 64;
    GwCastingBar.highlight = GwCastingBar.progress.highlight;
    GwCastingBar.latency = GwCastingBar.progress.latency;

    GwCastingBar.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    GwCastingBar.name:SetShadowOffset(1, -1)
    GwCastingBar.time:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    GwCastingBar.time:SetShadowOffset(1, -1)

    GwCastingBar:SetAlpha(0)

    GwCastingBar.unit = unit
    GwCastingBar.showCastbar = true
    GwCastingBar.spellID = nil
    GwCastingBar.isChanneling = false
    GwCastingBar.reverseChanneling = false
    GwCastingBar.isCasting = false
    GwCastingBar.animationName = name
    GwCastingBar.showTradeSkills = showTradeSkills
    GwCastingBar.StagePoints = {}
    GwCastingBar.TickLines = {}
    GwCastingBar.numStages = 0
    GwCastingBar.showDetails = GW.settings.CASTINGBAR_DATA

    GwCastingBar.segments = {}

    if name == "GwCastingBarPlayer" then
        RegisterMovableFrame(GwCastingBar, SHOW_ARENA_ENEMY_CASTBAR_TEXT, "castingbar_pos", ALL .. ",Blizzard", nil, {"default", "scaleable"})
        GwCastingBar:ClearAllPoints()
        GwCastingBar:SetPoint("CENTER", GwCastingBar.gwMover)
    else
        GwCastingBar:ClearAllPoints()
        GwCastingBar:SetPoint("TOPLEFT", GwCastingBarPlayer.gwMover, "TOPLEFT", 0, 35)
    end

    TogglePlayerEnhancedCastbar(GwCastingBar, GwCastingBar.showDetails)

    GwCastingBar:SetScript("OnEvent", unit == "pet" and petCastBar_OnEvent or castBar_OnEvent)
    if unit == "player" then
        GwCastingBar:SetScript("OnUpdate", onUpdate)
    end

    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)
    GwCastingBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)

    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    if unit == "pet" then
        GwCastingBar:RegisterEvent("UNIT_PET")
        GwCastingBar.showCastbar = UnitIsPossessed(unit)
    end
end
GW.LoadCastingBar = LoadCastingBar
