local _, GW = ...
local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local FONT_SIZE = 18 --the base font size to use at a scale of 1
local MIN_SCALE = 0.5 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 1.5 --the minimum duration to show cooldown text for

local TimeFormats = {
    [0] = "%dd",
    [1] = "%dh",
    [2] = "%dm",
    [3] = "%ds"
}

do
    local YEAR, DAY, HOUR, MINUTE = 31557600, 86400, 3600, 60
    local function GetTimeInfo(s)
        if s < MINUTE then
            return TimeFormats[3]:format(s), 0.5
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

local function Cooldown_StopTimer(self)
    self:Hide()
end

local function Cooldown_BelowScale(self)
    return self.fontScale and (self.fontScale < MIN_SCALE)
end

local function Cooldown_OnUpdate(self, elapsed)
    local forced = elapsed == -1
    if forced then
        self.nextUpdate = 0
    elseif self.nextUpdate > 0 then
        self.nextUpdate = self.nextUpdate - elapsed
        return
    end

    if not Cooldown_IsEnabled(self) then
        Cooldown_StopTimer(self)
    else
        local now = GetTime()
        if self.endCooldown and now >= self.endCooldown then
            Cooldown_StopTimer(self)
        elseif Cooldown_BelowScale(self) then
            self.text:SetText("")
            if not forced then
                self.nextUpdate = 500
            end
        elseif self.endTime then
            local text, nextUpdate = GW.GetTimeInfo(self.endTime - now)
            if not forced then
                self.nextUpdate = nextUpdate
            end
            self.text:SetText(text)
        end
    end
end

local function ToggleBlizzardCooldownText(self, timer, request)
    -- we should hide the blizzard cooldown
    if timer and self and self.SetHideCountdownNumbers then
        local forceHide = timer.hideBlizzard
        if request then
            return forceHide or Cooldown_IsEnabled(timer)
        else
            self:SetHideCountdownNumbers(forceHide or Cooldown_IsEnabled(timer))
        end
    end
end

local function Cooldown_ForceUpdate(self)
    Cooldown_OnUpdate(self, -1)
    self:Show()
end

local function Cooldown_OnSizeChanged(self, width, force)
    local scale = width and (floor(width + 0.5) / ICON_SIZE)

    -- dont bother updating when the fontScale is the same, unless we are passing the force arg
    if scale and (scale == self.fontScale) and (force ~= true) then return end
    self.fontScale = scale

    -- this is needed because of skipScale variable, we wont allow a font size under the minscale
    if self.fontScale and (self.fontScale < MIN_SCALE) then
        scale = MIN_SCALE
    end

    if scale then
        self.text:SetFont(UNIT_NAME_FONT, (scale * FONT_SIZE), "OUTLINE")
    end
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

    Cooldown_OnSizeChanged(timer, parent:GetWidth())
    parent:SetScript("OnSizeChanged", function(_, width)
        Cooldown_OnSizeChanged(timer, width)
    end)

    -- keep this after Cooldown_OnSizeChanged
    timer:SetScript("OnUpdate", Cooldown_OnUpdate)

    return timer
end

local function OnSetCooldown(self, start, duration)
    if (not self.forceDisabled) and (start and duration) and (duration > MIN_DURATION) then
        local timer = self.timer or CreateCooldownTimer(self)
        timer.start = start
        timer.duration = duration
        timer.endTime = start + duration
        timer.endCooldown = timer.endTime - 0.05
        Cooldown_ForceUpdate(timer)
    elseif self.timer then
        Cooldown_StopTimer(self.timer)
    end
end

local function RegisterCooldown(cooldown)
    if not cooldown.isHooked then
        hooksecurefunc(cooldown, "SetCooldown", OnSetCooldown)
        cooldown.isHooked = true
    end
end
GW.RegisterCooldown = RegisterCooldown
