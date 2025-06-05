local _, GW = ...

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

local function TimerBarOnUpdate(self)
    local timeNow = GetTime()
	local timeRemaining = self.duration - (timeNow - self.startTime)
	self.TimerBar:SetValue(timeRemaining)
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
	self.TimerBar.Label:SetTextColor(GetTextColor(self, timeRemaining))
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
    self.TimerBar:SetMinMaxValues(0, duration)
    self.startTime = startTime
    self.duration = duration

    self:SetHeight(self:GetHeight() + 15)

    self.TimerBar:ClearAllPoints()
    if self.StatusBar:IsShown() then
        self.TimerBar:SetPoint("BOTTOMRIGHT", self.StatusBar, 0, -20)
    else
        self.TimerBar:SetPoint("BOTTOMRIGHT", self.ObjectiveText)
    end

    self:SetScript("OnUpdate", TimerBarOnUpdate)
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
    self.ObjectiveText:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    self.StatusBar.progress:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    self.TimerBar.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    hooksecurefunc(self.StatusBar, "SetValue", statusBarSetValue)
end
