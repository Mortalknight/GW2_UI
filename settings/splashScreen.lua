local _, GW = ...

local timer = CreateFrame("Frame")
local duration = 30 * 60
local interval = 180 * 60
local startTimeStamp = 1725037205

local function ArtworkChange(isActive)
    if isActive then
        GwSettingsWindow.splashart:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/settingartwork-dark")
    else
        GwSettingsWindow.splashart:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/settingartwork")
    end
end

local function CheckFunction()
    local timeSinceStart = GetServerTime() - startTimeStamp
    timer.timeOver = timeSinceStart % interval
    timer.nextEventIndex = floor(timeSinceStart / interval) + 1
    timer.nextEventTimestamp = startTimeStamp + interval * timer.nextEventIndex
    timer.isRunningPrev = timer.isRunning

    if timer.timeOver < duration then
        timer.timeLeft = duration - timer.timeOver
        timer.isRunning = true
    else
        timer.timeLeft = interval - timer.timeOver
        timer.isRunning = false
    end

    if timer.isRunningPrev ~= timer.isRunning then
        -- needs artwork change
        ArtworkChange(timer.isRunning)
    end
end

local function StopBeledarsTicker()
    if timer.ticker then
        timer.ticker:Cancel()
        timer.ticker = nil
    end
end

local function StartBeledarsTicker()
    if timer.ticker then
        timer.ticker:Cancel()
        timer.ticker = nil
    end
    timer.ticker = C_Timer.NewTicker(1, CheckFunction)
end

local function InitBeledarsSplashScreen(sWindow)
    sWindow:HookScript("OnShow", StartBeledarsTicker)
    sWindow:HookScript("OnHide", StopBeledarsTicker)

    CheckFunction()
end
GW.InitBeledarsSplashScreen = InitBeledarsSplashScreen