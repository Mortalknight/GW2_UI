---@class GW2
local GW = select(2, ...)

local BAR_PATH = "Interface/AddOns/GW2_UI/Textures/units/castingbars/"
local BAR_STYLES = {
    SwingTimerMainHandFrame = {texture = "yellow-norm"},
    SwingTimerOffHandFrame = {texture = "green-norm"},
    SwingTimerRangedFrame = {texture = "yellow-norm", color = CreateColor(0.5, 0.7, 1)},
}

local function ApplyBarPresentation(frame)
    local style = frame.gwBarStyle
    local statusBar = frame:GetStatusBar()
    statusBar:SetStatusBarTexture(BAR_PATH .. style.texture .. ".png")

    local fill = statusBar:GetStatusBarTexture()
    fill:SetDesaturated(style.color ~= nil)
    if style.color then
        fill:SetVertexColor(style.color:GetRGB())
    else
        fill:SetVertexColor(1, 1, 1)
    end

    frame.gwSpark:ClearAllPoints()
    frame.gwSpark:SetPoint("RIGHT", fill, "RIGHT", 0, 0)
end

local function UpdateSparkSize(frame)
    frame.gwSpark:SetSize(10, frame:GetHeight())
end

local function UpdateSparkShown(frame)
    frame.gwSpark:SetShown(frame.swingEndTime ~= nil)
end

local function SkinSwingTimer(frame, style)
    frame.gwBarStyle = style
    frame:GwStripTextures()

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(frame)
    background:SetTexture("Interface/AddOns/GW2_UI/textures/units/castingbarsdf.png")
    background:SetTexCoord(0, 0.5, 0, 0.25)
    background:SetVertexColor(1, 1, 1, 0.6)

    local statusBar = frame:GetStatusBar()
    statusBar:ClearAllPoints()
    statusBar:SetAllPoints(frame)

    local pip = frame:GetStatusBarPip()
    pip:SetTexture()
    pip:SetSize(1, 1)

    frame.gwSpark = statusBar:CreateTexture(nil, "OVERLAY")
    frame.gwSpark:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar-spark-white.png")
    frame.gwSpark:SetBlendMode("ADD")
    frame.gwSpark:SetVertexColor(1, 1, 1, 0.7)
    UpdateSparkSize(frame)
    UpdateSparkShown(frame)
    frame:HookScript("OnSizeChanged", UpdateSparkSize)
    hooksecurefunc(frame, "ResetSwingTimer", UpdateSparkShown)
    hooksecurefunc(frame, "ClearSwingTimer", UpdateSparkShown)

    frame:GetTypeLabelShadow():SetTexture()

    local typeLabel = frame:GetTypeLabel()
    typeLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    typeLabel:ClearAllPoints()
    typeLabel:SetPoint("LEFT", statusBar, "LEFT", 4, 0)

    local timeLabel = frame:GetTimeLabel()
    timeLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    timeLabel:ClearAllPoints()
    timeLabel:SetPoint("RIGHT", statusBar, "RIGHT", -4, 0)

    ApplyBarPresentation(frame)
    hooksecurefunc(frame, "InitializeBarPresentation", ApplyBarPresentation)
end

local function LoadSwingTimerSkin()
    for name, style in pairs(BAR_STYLES) do
        local frame = _G[name]
        if frame and frame.GetStatusBar then
            SkinSwingTimer(frame, style)
        end
    end
end
GW.LoadSwingTimerSkin = LoadSwingTimerSkin
