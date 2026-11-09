---@class GW2
local GW = select(2, ...)
local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local FONT_SIZE = 18 --the base font size to use at a scale of 1
local MIN_SCALE = 0.5 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 1.5 --the minimum duration to show cooldown text for

local TimeFormats = {
    [0] = "%.0fd",
    [1] = "%.0fh",
    [2] = "%.0fm",
    [3] = "%ds",
    [4] = "%d"
}

local function Cooldown_BelowScale(self)
    return self.fontScale and (self.fontScale < MIN_SCALE)
end

local function Cooldown_StopTimer(self)
    self.text:SetText("")
    self:Hide()
    self.endTime = nil
    self.endCooldown = nil
    self.nextUpdate = nil
end

local function Cooldown_UnbuggedTime(timer)
	return timer.buggedTime and (time() - GetTime()) or GetTime()
end

do
    local YEAR, DAY, HOUR, MINUTE = 31557600, 86400, 3600, 60
    local function GetTimeInfo(s, hideSecondLabel)
        if s < MINUTE then
            if hideSecondLabel then
                return TimeFormats[4]:format(s), 0.5
            else
                return TimeFormats[3]:format(s), 0.5
            end
        elseif s < HOUR then
            local mins = mod(s, HOUR) / MINUTE
            return TimeFormats[2]:format(mins), mins > 2 and 30 or 1
        elseif s < DAY then
            local hrs = mod(s, DAY) / HOUR
            return TimeFormats[1]:format(hrs), hrs > 1 and 60 or 30
        else
            local days = mod(s, YEAR) / DAY
            return TimeFormats[0]:format(days), days > 1 and 120 or 60
        end
    end
    GW.GetTimeInfo = GetTimeInfo
end

local function Cooldown_IsEnabled(self)
    if self.forceEnabled then
        return true
    elseif self.forceDisabled then
        return false
    else
        return true
    end
end

local function Cooldown_OnUpdate(self, elapsed)
    if self.paused then return end

    -- throttle
    if elapsed ~= -1 then
        local nextUpdate = self.nextUpdate
        if nextUpdate and nextUpdate > 0 then
            nextUpdate = nextUpdate - elapsed
            if nextUpdate > 0 then
                self.nextUpdate = nextUpdate
                return
            end
        end
    else
        self.nextUpdate = 0
    end

    if not Cooldown_IsEnabled(self) then
        Cooldown_StopTimer(self)
        return
    end

    if Cooldown_BelowScale(self) then
        self.text:SetText("")
        self.nextUpdate = 0.5
        return
    end

    local now = Cooldown_UnbuggedTime(self)

    if self.endCooldown and now >= self.endCooldown then
        return Cooldown_StopTimer(self)
    end

    if self.endTime then
        local remaining = self.endTime - now
        if remaining <= 0 then
            return Cooldown_StopTimer(self)
        end

        local text, nextUpdate = GW.GetTimeInfo(remaining, true)
        self.text:SetText(text)
        self.nextUpdate = nextUpdate or 0.5
    end
end

local function Cooldown_TimerUpdate(timer)
    if not timer.endTime or Cooldown_BelowScale(timer) then
        timer:Hide()
        return
    end
    timer:Show()
    Cooldown_OnUpdate(timer, -1)
end

local function ToggleBlizzardCooldownText(self, timer, request)
    if not (timer and self and self.SetHideCountdownNumbers) then
        return
    end
    local hide = (timer.hideBlizzard ~= false) and Cooldown_IsEnabled(timer) or false
    if request then
        return hide
    else
        self:SetHideCountdownNumbers(hide)
    end
end

local function Cooldown_OnSizeChanged(self, width, force)
    if GW.IsSecretValue(width) then
        if self.fontScale then return end
        width = nil
    end
    local scale = width and (floor(width + 0.5) / ICON_SIZE) or 1
    if (not force) and (scale == self.fontScale) then return end
    self.fontScale = scale

    if scale and (scale < MIN_SCALE) then
        scale = MIN_SCALE
    end

    if scale then
        self.text:SetFont(UNIT_NAME_FONT, (scale * FONT_SIZE), "OUTLINE")
    end

    if self.binding then
        self:SetShown(not Cooldown_BelowScale(self))
    elseif self.parent and self.endTime then
        Cooldown_TimerUpdate(self)
    end
end

-- on modern start and duration can be secret, an engine binding writes the text there
local countdownFormatter
if GW.isModern then
    -- same texts as GetTimeInfo without the second label
    countdownFormatter = C_StringUtil.CreateNumericRuleFormatter()
    countdownFormatter:SetBreakpoints({
        {threshold = 0, format = "%d", step = 1, rounding = Enum.NumericRuleFormatRounding.Floor},
        {threshold = 60, format = "%.0fm", components = {{div = 60, step = 1, rounding = Enum.NumericRuleFormatRounding.Nearest}}},
        {threshold = 3600, format = "%.0fh", components = {{div = 3600, step = 1, rounding = Enum.NumericRuleFormatRounding.Nearest}}},
        {threshold = 86400, format = "%.0fd", components = {{div = 86400, step = 1, rounding = Enum.NumericRuleFormatRounding.Nearest}}},
    })
end

local function CreateCooldownTimer(parent)
    local timer = CreateFrame("Frame", nil, parent)
    timer:Hide()
    timer:SetAllPoints()
    timer.parent = parent
    parent.timer = timer

    local text = timer:CreateFontString(nil, "OVERLAY")
    text:SetPoint("CENTER", 1, 1)
    text:SetJustifyH("CENTER")
    text:SetTextColor(1, 1, 1)
    timer.text = text

    timer.hideBlizzard = true
    ToggleBlizzardCooldownText(parent, timer)

    if countdownFormatter then
        timer.duration = C_DurationUtil.CreateDuration()
        timer.binding = C_DurationUtil.CreateDurationTextBinding()
        timer.binding:SetFontString(text)
        timer.binding:SetFormatter(countdownFormatter)
        timer.binding:SetExpiredText("")
        timer.binding:SetZeroDurationText("")
        timer.binding:Disable()
    end

    Cooldown_OnSizeChanged(timer, parent:GetWidth(), true)
    parent:SetScript("OnSizeChanged", function(_, width)
        Cooldown_OnSizeChanged(timer, width, true)
    end)

    if not timer.binding then
        -- keep this after Cooldown_OnSizeChanged
        timer:SetScript("OnUpdate", Cooldown_OnUpdate)
        -- the throttle only counts down while the text shows, a bag opened again would keep the old time for a while
        timer:SetScript("OnShow", function(self) Cooldown_OnUpdate(self, -1) end)
    end

    return timer
end

local function OnSetCooldown(self, start, duration)
    if self.isHooked ~= 1 then return end

    if (not self.forceDisabled) and start and duration and duration > MIN_DURATION then
        local timer = self.timer or CreateCooldownTimer(self)
        timer.start = start
        timer.duration = duration
        timer.paused = nil

        local now = GetTime()
        if start <= (now + 1) then
            timer.endTime = start + duration
            timer.buggedTime = nil
        else
            -- https://github.com/Stanzilla/WoWUIBugs/issues/47
            local startup = time() - now
            local cdTime = (2 ^ 32) / 1000 - start
            local startTime = startup - cdTime
            timer.endTime = startTime + duration
            timer.buggedTime = true
        end

        timer.endCooldown = timer.endTime - 0.05
        Cooldown_TimerUpdate(timer)
    elseif self.timer then
        Cooldown_StopTimer(self.timer)
    end
end

local function OnPauseCooldown(self)
    local timer = self.timer
    if timer then
        timer.paused = Cooldown_UnbuggedTime(timer)
    end
end

local function OnResumeCooldown(self)
    local timer = self.timer
    if timer and timer.paused then
        -- calcuate time since paused
        local now = Cooldown_UnbuggedTime(timer)
        timer.endTime = timer.endTime + (now - timer.paused)
        timer.endCooldown = timer.endTime - 0.05
        timer.paused = nil
        Cooldown_TimerUpdate(self.timer)
    end
end

-- USED BY WEAKAURAS
local function ToggleCooldown(cooldown, switch)
    cooldown.isHooked = switch and 1 or 0

    if cooldown.timer then
        if switch then
            Cooldown_TimerUpdate(cooldown.timer)
        else
            Cooldown_StopTimer(cooldown.timer)
        end
    end
end

local function RegisterCooldown(cooldown)
    if not cooldown.isHooked then
        hooksecurefunc(cooldown, "SetCooldown", OnSetCooldown)

        if cooldown.Pause then
            hooksecurefunc(cooldown, "Pause", OnPauseCooldown)
            hooksecurefunc(cooldown, "Resume", OnResumeCooldown)
        end

        ToggleCooldown(cooldown, true)
    end
end

local function SetCountdownDuration(cooldown, durationObject)
    local binding = cooldown.timer.binding
    if durationObject then
        binding:SetDuration(durationObject)
        binding:Enable()
    else
        binding:Disable()
        cooldown.timer.text:SetText("")
    end
end

local function OnSetCountdown(self, start, duration, modRate)
    if GW.IsSecretValue(duration) or (duration and duration > MIN_DURATION) then
        -- https://github.com/Stanzilla/WoWUIBugs/issues/47
        if not GW.IsSecretValue(start) and start > GetTime() + 1 then
            start = start - (2 ^ 32) / 1000
        end
        self.timer.duration:SetTimeFromStart(start, duration, modRate)
        SetCountdownDuration(self, self.timer.duration)
    else
        SetCountdownDuration(self, nil)
    end
end

local function OnClearCountdown(self)
    SetCountdownDuration(self, nil)
end

local function RegisterCountdown(cooldown)
    if cooldown.timer then return end
    CreateCooldownTimer(cooldown)
    hooksecurefunc(cooldown, "SetCooldown", OnSetCountdown)
    hooksecurefunc(cooldown, "SetCooldownFromDurationObject", SetCountdownDuration)
    hooksecurefunc(cooldown, "Clear", OnClearCountdown)
end

function GW.SetCooldownText(cooldown, durationObject)
    if cooldown.timer and cooldown.timer.binding then
        SetCountdownDuration(cooldown, durationObject)
    end
end

GW.RegisterCooldown = GW.isModern and RegisterCountdown or RegisterCooldown
