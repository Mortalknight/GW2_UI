local _, GW = ...

GwAchievementTrackerObjectiveMixin = {}

local START_PERCENTAGE_YELLOW = .66;
local START_PERCENTAGE_RED = .33;
local function GetTextColor(self, timeRemaining)
	local elapsed = self.duration - timeRemaining;
	local percentageLeft = 1 - ( elapsed / self.duration )
	if percentageLeft > START_PERCENTAGE_YELLOW then
		return 1, 1, 1;
	elseif percentageLeft > START_PERCENTAGE_RED then -- Start fading to yellow by eliminating blue
		local blueOffset = (percentageLeft - START_PERCENTAGE_RED) / (START_PERCENTAGE_YELLOW - START_PERCENTAGE_RED);
		return 1, 1, blueOffset;
	else
		local greenOffset = percentageLeft / START_PERCENTAGE_RED; -- Fade to red by eliminating green
		return 1, greenOffset, 0;
	end
end

local function TimerBarOnUpdate(self)
    local timeNow = GetTime()
	local timeRemaining = self.duration - (timeNow - self.startTime)
	self.TimerBar:SetValue(timeRemaining)
    if timeRemaining < 0 then
		-- hold at 0 for a moment
		if timeRemaining > -1 then
			timeRemaining = 0;
        else
            self.TimerBar:Hide()
            self:GetParent():GetParent():UpdateAchievementLayout()
		end
	end
	self.TimerBar.Label:SetText(SecondsToClock(timeRemaining))
	self.TimerBar.Label:SetTextColor(GetTextColor(self, timeRemaining))
end

function GwAchievementTrackerObjectiveMixin:AddTimer(duration, startTime)
    self.TimerBar:Show()
    self.TimerBar:SetMinMaxValues(0, duration)
    self.startTime = startTime;
    self.duration = duration;

    self:SetHeight(self:GetHeight() + 15)

    self.TimerBar:ClearAllPoints()
    if self.StatusBar:IsShown() then
        self.TimerBar:SetPoint("BOTTOMRIGHT", self.StatusBar, 0, -20)
    else
        self.TimerBar:SetPoint("BOTTOMRIGHT", self.ObjectiveText)
    end

    self:SetScript("OnUpdate", TimerBarOnUpdate)
end