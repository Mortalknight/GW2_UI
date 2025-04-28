local _, GW = ...

local timer = CreateFrame("Frame")
local duration = 30 * 60
local interval = 180 * 60
local startTimeStamp = 1725037205
local fadeDuration = 1.5

local function CrossfadeTextures(self, isActive)
    local fadeOutTex = isActive and self.splashart or self.splashart2
    local fadeInTex = isActive and self.splashart2 or self.splashart

    UIFrameFadeOut(fadeOutTex, fadeDuration, 1, 0)
    UIFrameFadeIn(fadeInTex, fadeDuration, 0, 1)
end
GW.GWCrossfadeTextures = CrossfadeTextures
--/run GW2_ADDON.GWCrossfadeTextures(GwSettingsWindow, true)
local function CheckFunction(self)
    local elapsedTotal = GetServerTime() - startTimeStamp
    local over         = elapsedTotal % interval
    local running      = over < duration

    if timer.isRunning ~= running then
        CrossfadeTextures(self, running)
    end

    timer.isRunning = running
end

local function StopBeledarsTicker()
    if timer.ticker then
        timer.ticker:Cancel()
        timer.ticker = nil
    end
end

local function StartBeledarsTicker(self)
    StopBeledarsTicker()
    timer.ticker = C_Timer.NewTicker(1, function() CheckFunction(self) end)
end

local function InitBeledarsSplashScreen(sWindow)
    sWindow:HookScript("OnShow", StartBeledarsTicker)
    sWindow:HookScript("OnHide", StopBeledarsTicker)

    CheckFunction(sWindow)
end
GW.InitBeledarsSplashScreen = InitBeledarsSplashScreen
