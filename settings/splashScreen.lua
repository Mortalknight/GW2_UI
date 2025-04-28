local _, GW = ...

local timer = CreateFrame("Frame")
local duration = 30 * 60
local interval = 180 * 60
local startTimeStamp = 1725037205
local fadeDuration = 1.5

local function EaseInOutQuad(t)
    if t < 0.5 then
        return 2 * t * t
    else
        return -1 + (4 - 2 * t) * t
    end
end

local function CrossfadeTextures(self, dur, isActive)
    GW.Debug(isActive, "CrossfadeTextures", dur)
    if self.fadeTickerActive then return end
    self.fadeTickerActive = true

    local startTime = GetTime()

    self:SetScript("OnUpdate", function()
        local progress = (GetTime() - startTime) / dur

        if progress >= 1 then
            progress = 1
            self:SetScript("OnUpdate", nil)
            self.fadeTickerActive = nil
        end

        local eased = EaseInOutQuad(progress)

        if isActive then
            self.splashart2:SetAlpha(eased)
            self.splashart:SetAlpha(1 - eased)
        else
            self.splashart2:SetAlpha(1 - eased)
            self.splashart:SetAlpha(eased)
        end
    end)
end
GW.GWCrossfadeTextures = CrossfadeTextures
--/run GW2_ADDON.GWCrossfadeTextures(GwSettingsWindow, 1.5, true)
local function CheckFunction(self)
    local timeSinceStart = GetServerTime() - startTimeStamp
    local timeOver = timeSinceStart % interval
    local nextEventIndex = math.floor(timeSinceStart / interval) + 1
    local nextEventTimestamp = startTimeStamp + interval * nextEventIndex
    local wasRunning = timer.isRunning
    timer.timeOver = timeOver
    timer.nextEventIndex = nextEventIndex
    timer.nextEventTimestamp = nextEventTimestamp

    if timeOver < duration then
        timer.timeLeft = duration - timeOver
        timer.isRunning = true
    else
        timer.timeLeft = interval - timeOver
        timer.isRunning = false
    end

    if wasRunning ~= timer.isRunning then
        CrossfadeTextures(self, fadeDuration, timer.isRunning)
    end
end

local function StopBeledarsTicker()
    if timer.ticker then
        timer.ticker:Cancel()
        timer.ticker = nil
    end
end

local function StartBeledarsTicker(self)
    StopBeledarsTicker()

    if timer.ticker then
        timer.ticker:Cancel()
        timer.ticker = nil
    end
    timer.ticker = C_Timer.NewTicker(1, function() CheckFunction(self) end)
end

local function InitBeledarsSplashScreen(sWindow)
    sWindow:HookScript("OnShow", StartBeledarsTicker)
    sWindow:HookScript("OnHide", StopBeledarsTicker)

    CheckFunction(sWindow)
end
GW.InitBeledarsSplashScreen = InitBeledarsSplashScreen