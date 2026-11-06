---@class GW2
local GW = select(2, ...)

local BAR_TEXTURE = "Interface/AddOns/GW2_UI/textures/hud/castinbar-white.png"
local BACKGROUND_TEXTURE = "Interface/AddOns/GW2_UI/textures/hud/breathmeter.png"

-- Blizzard's label sits below its bar and the bar frame would cover it on top, so ours is a new one
local labels = {}

-- Setup gives the bar Blizzard's atlas and label for the timer type every time it starts
local function ApplyTimerLook(timerFrame, timer)
    local colors = GW.Colors.MirrorTimerColors
    timerFrame.StatusBar:SetStatusBarTexture(BAR_TEXTURE)
    timerFrame.StatusBar:SetStatusBarColor((colors[timer] or colors.EXHAUSTION):GetRGB())
    labels[timerFrame]:SetText(timerFrame.Text:GetText())
end

local function SkinTimer(timerFrame)
    timerFrame:GwStripTextures()
    timerFrame:SetSize(258, 22)
    timerFrame.Text:SetAlpha(0)

    local background = timerFrame:CreateTexture(nil, "BACKGROUND")
    background:SetTexture(BACKGROUND_TEXTURE)
    background:SetVertexColor(GW.Colors.MirrorTimerBackground:GetRGBA())
    background:SetAllPoints()

    local bar = timerFrame.StatusBar
    bar:ClearAllPoints()
    bar:SetAllPoints()

    local label = bar:CreateFontString(nil, "OVERLAY")
    label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE")
    label:SetPoint("CENTER", 0, -1)
    labels[timerFrame] = label

    hooksecurefunc(timerFrame, "Setup", ApplyTimerLook)
end

local function LoadMirrorTimers()
    for _, timerFrame in ipairs(MirrorTimerContainer.mirrorTimers) do
        SkinTimer(timerFrame)
    end
    -- timers that already run, e.g. after a reload under water
    for timer, timerFrame in pairs(MirrorTimerContainer.activeTimers) do
        ApplyTimerLook(timerFrame, timer)
    end
end
GW.LoadMirrorTimers = LoadMirrorTimers
