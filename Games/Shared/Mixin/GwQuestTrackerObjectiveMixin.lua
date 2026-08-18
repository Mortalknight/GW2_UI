---@class GW2
local GW = select(2, ...)

GwQuestTrackerObjectiveMixin = {}

local START_PERCENTAGE_YELLOW = 0.66
local START_PERCENTAGE_RED = 0.33
local function GetTextColor(self, timeRemaining)
	local elapsed = self.duration - timeRemaining
	local percentageLeft = 1 - (elapsed / self.duration)
	if percentageLeft > START_PERCENTAGE_YELLOW then
		return 1, 1, 1
	elseif percentageLeft > START_PERCENTAGE_RED then -- Start fading to yellow by eliminating blue
		local blueOffset = (percentageLeft - START_PERCENTAGE_RED) / (START_PERCENTAGE_YELLOW - START_PERCENTAGE_RED)
		return 1, 1, blueOffset
	else
		local greenOffset = percentageLeft / START_PERCENTAGE_RED -- Fade to red by eliminating green
		return 1, greenOffset, 0
	end
end

local function TimerBarOnUpdate(self, elapsed)
    -- The clock text only has second resolution; updating ~10x/s instead of every frame keeps
    -- the bar smooth enough while skipping the per-frame SecondsToClock/SetText/SetTextColor work.
    self.gwTimerThrottle = (self.gwTimerThrottle or 0) + (elapsed or 0)
    if self.gwTimerThrottle < 0.1 then
        return
    end
    self.gwTimerThrottle = 0

    local timeNow = GetTime()
	local timeRemaining = self.duration - (timeNow - self.startTime)
    if timeRemaining < 0 then
		-- hold at 0 for a moment
		if timeRemaining > -1 then
			timeRemaining = 0
        else
            self.TimerBar:Hide()
            self:GetParent():GetParent():UpdateLayout()
            self:SetScript("OnUpdate", nil)
		end
	end
	self.TimerBar.Label:SetText(SecondsToClock(timeRemaining))
	local r, g, b = GetTextColor(self, timeRemaining)
	self.TimerBar.Label:SetTextColor(r, g, b)
	self.TimerBar.clock:SetVertexColor(r, g, b)
end

local function statusBarSetValue(self, v)
    local f = self:GetParent()
    if not f then
        return
    end
    local min, mx = f.StatusBar:GetMinMaxValues()

    local width = math.max(1, math.min(10, 10 * ((v / mx) / 0.1)))
    f.StatusBar.Spark:SetPoint("RIGHT", f.StatusBar, "LEFT", 280 * (v / mx), 0)
    f.StatusBar.Spark:SetWidth(width)
    if f.StatusBar.precentage == nil or f.StatusBar.precentage == false then
        f.StatusBar.progress:SetText(v .. " / " .. mx)
    elseif f.isMythicKeystone then
        f.StatusBar.progress:SetText(GW.RoundDec((v / mx) * 100, 2) .. "%")
    else
        f.StatusBar.progress:SetText(math.floor((v / mx) * 100) .. "%")
    end

    f.StatusBar.Spark:SetShown(v ~= mx and v ~= min)
end

function GwQuestTrackerObjectiveMixin:AddTimer(duration, startTime)
    if not self.TimerBar then return end
    self.TimerBar:Show()
    self.startTime = startTime
    self.duration = duration

    -- Same visual distance in both cases: below the text rect its padding already provides
    -- empty space, below the status bar the border texture overhangs instead.
    local anchorToBar = self.StatusBar:IsShown()
    local offset = GW.GetObjectivesTimerGap()
    if anchorToBar then
        offset = offset + GW.GetObjectivesStatusBarBorderOverhang()
    else
        offset = offset - GW.GetObjectivesTextPadding()
    end

    self:SetHeight(self:GetHeight() + offset + GW.GetObjectivesTimerLabelHeight())

    self.TimerBar:ClearAllPoints()
    self.TimerBar:SetPoint("TOPRIGHT", anchorToBar and self.StatusBar or self.ObjectiveText, "BOTTOMRIGHT", 0, -offset)

    self:SetScript("OnUpdate", TimerBarOnUpdate)
end

function GwQuestTrackerObjectiveMixin:ApplyLayoutStyle()
    self.ObjectiveText:GwSetFontTemplate(UNIT_NAME_FONT, GW.IsObjectivesTrackerCompactMode() and GW.Enum.TextSizeType.Small or GW.Enum.TextSizeType.Normal)
    self.StatusBar.progress:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    self.TimerBar.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    self.ObjectiveText:ClearAllPoints()
    self.ObjectiveText:SetPoint("TOPRIGHT", self, "TOPRIGHT", -10, -GW.GetObjectivesRowTextOffset())
    -- both bars stack below the text in both modes; the row height in AddObjective is
    -- derived from exactly this geometry, so the two cannot drift apart
    self.StatusBar:ClearAllPoints()
    self.StatusBar:SetPoint("TOPRIGHT", self.ObjectiveText, "BOTTOMRIGHT", 0, -GW.GetObjectivesStatusBarGap())
    self.TimerBar:ClearAllPoints()
    self.TimerBar:SetHeight(GW.GetObjectivesTimerLabelHeight())
    self.TimerBar:SetPoint("TOPRIGHT", self.ObjectiveText, "BOTTOMRIGHT", 0, -(GW.GetObjectivesTimerGap() - GW.GetObjectivesTextPadding()))
    -- clock size and the text offset behind it are the only mode dependent parts, the
    -- elements themselves come from the template
    local iconSize = GW.GetObjectivesTimerIconSize()
    self.TimerBar.clock:SetSize(iconSize, iconSize)
    self.TimerBar.Label:ClearAllPoints()
    self.TimerBar.Label:SetPoint("TOPLEFT", self.TimerBar, "TOPLEFT", iconSize + 3, 0)
    self.TimerBar.Label:SetPoint("BOTTOMRIGHT", self.TimerBar, "BOTTOMRIGHT", 0, 0)
end

function GwQuestTrackerObjectiveMixin:OnShow()
    if not self.notChangeSize then
        self:SetHeight(50)
    end
    self.StatusBar.statusbarBg:Show()
end

function GwQuestTrackerObjectiveMixin:OnHide()
    if not self.notChangeSize then
        self:SetHeight(20)
    end
    self.StatusBar.statusbarBg:Hide()
end

function GwQuestTrackerObjectiveMixin:OnLoad()
    self:ApplyLayoutStyle()
    hooksecurefunc(self.StatusBar, "SetValue", statusBarSetValue)
end

local function GetCompletedStrikeLine(self, index)
    self.CompletedStrikeLines = self.CompletedStrikeLines or {}

    local line = self.CompletedStrikeLines[index]
    if line then
        return line
    end

    line = self:CreateTexture(nil, "OVERLAY")
    line:SetColorTexture(0.78, 0.78, 0.78, 0.7)
    line:SetHeight(1)
    self.CompletedStrikeLines[index] = line

    return line
end

function GwQuestTrackerObjectiveMixin:SetCompletedLineState(showLine)
    self.CompletedStrikeLines = self.CompletedStrikeLines or {}

    if not showLine then
        for i = 1, #self.CompletedStrikeLines do
            self.CompletedStrikeLines[i]:Hide()
        end
        return
    end

    local textWidth = self.ObjectiveText:GetStringWidth() or 0
    local maxWidth = self.ObjectiveText:GetWidth() or 0
    if maxWidth > 0 then
        textWidth = math.min(textWidth, maxWidth)
    end

    local lineCount = math.max(1, self.ObjectiveText:GetNumLines() or 1)
    local lineWidth = lineCount > 1 and math.max(1, maxWidth > 0 and maxWidth or textWidth) or math.max(1, textWidth)

    local _, fontSize = self.ObjectiveText:GetFont()
    local lineHeight = self.ObjectiveText:GetLineHeight() or fontSize or 12

    for i = 1, lineCount do
        local strike = GetCompletedStrikeLine(self, i)
        local strikeYOffset = -math.floor((((i - 1) * lineHeight) + (lineHeight * 0.5)) + 0.5)

        strike:SetWidth(lineWidth)
        strike:ClearAllPoints()
        strike:SetPoint("TOPLEFT", self.ObjectiveText, "TOPLEFT", 0, strikeYOffset)
        strike:Show()
    end

    for i = lineCount + 1, #self.CompletedStrikeLines do
        self.CompletedStrikeLines[i]:Hide()
    end
end
