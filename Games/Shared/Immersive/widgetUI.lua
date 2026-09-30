---@class GW2
local GW = select(2, ...)

local BAR_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg.png"

-- the PvP capture bars below the minimap come in this widget set
local CAPTURE_BAR_WIDGET_SET = 2
-- sets whose bars break with our look (Cosmic Energy)
local UNSKINNED_WIDGET_SETS = { [283] = true }

local STATUS_BAR_ART = { "BGLeft", "BGRight", "BGCenter", "BorderLeft", "BorderRight", "BorderCenter", "Spark" }
local CAPTURE_BAR_ART = { "LeftLine", "RightLine", "BarBackground", "SparkNeutral", "Glow1", "Glow2", "Glow3" }
-- faction sides and the neutral middle of a capture bar
local CAPTURE_BAR_COLORS = {
    LeftBar = CreateColor(0.2, 0.6, 1),
    RightBar = CreateColor(0.9, 0.2, 0.2),
    NeutralBar = CreateColor(0.8, 0.8, 0.8),
}

-- only alpha: Blizzard reuses the widgets and would show hidden parts again
local function HideArt(frame, keys)
    for _, key in ipairs(keys) do
        if frame[key] then
            frame[key]:SetAlpha(0)
        end
    end
end

local function SkinStatusBarWidget(widget)
    local bar = widget.Bar
    if widget:IsForbidden() or not bar or UNSKINNED_WIDGET_SETS[widget.widgetSetID] then return end

    HideArt(bar, STATUS_BAR_ART)

    -- pooled widgets come back already skinned
    if bar.backdrop or GW.IsSecretValue(bar:GetWidth()) then return end
    bar:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    -- title and percent text
    if widget.Label then
        widget.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "")
    end
    if bar.Label then
        bar.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "")
    end
    if widget.Text then
        widget.Text:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    end
end

local function SkinCaptureBar(widget)
    if widget:IsForbidden() or not widget.LeftBar then return end

    widget.GlowPulseAnim:Stop()
    HideArt(widget, CAPTURE_BAR_ART)
    for key, color in pairs(CAPTURE_BAR_COLORS) do
        widget[key]:SetTexture(BAR_TEXTURE)
        widget[key]:SetVertexColor(color:GetRGB())
    end

    if not widget.backdrop then
        widget:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
        widget.backdrop:SetPoint("TOPLEFT", widget.LeftBar, -1, 1)
        widget.backdrop:SetPoint("BOTTOMRIGHT", widget.RightBar, 1, -1)
    end
    -- the frame level is reset when the widget is set up again
    widget.backdrop:SetFrameLevel(max(0, widget:GetFrameLevel() - 1))
end

local function OnCaptureBarSetup(widget, _, container)
    if container and container.widgetSetID == CAPTURE_BAR_WIDGET_SET then
        SkinCaptureBar(widget)
    end
end

-- ElvUI moves the same containers, two movers would fight over them
local function IsElvUIHandlingWidgets()
    local ace = LibStub and LibStub("AceAddon-3.0", true)
    local elvui = ace and ace:GetAddon("ElvUI", true)
    local blizzard = elvui and elvui:GetModule("Blizzard", true)
    return blizzard and blizzard.Initialized
end

local function KeepOnMover(container, _, anchor)
    local mover = container.gwMover
    if mover and anchor ~= mover then
        container:ClearAllPoints()
        container:SetPoint("CENTER", mover, "CENTER")
    end
end

local function AddMover(container, name, setting, size)
    if not container then return end
    GW.RegisterMovableFrame(container, name, setting, "Blizzard,Widgets", size, { GW.MoverOption.Scale })
    KeepOnMover(container)
    hooksecurefunc(container, "SetPoint", KeepOnMover)
end

local function WidgetUISetup()
    if IsElvUIHandlingWidgets() then return end

    AddMover(UIWidgetTopCenterContainerFrame, "TopWidget", "widgets.topCenter", { 58, 58 })
    AddMover(UIWidgetBelowMinimapContainerFrame, "BelowMinimapWidget", "widgets.belowMinimapContainer", { 150, 30 })
    AddMover(TicketStatusFrame, "GM Ticket Frame", "widgets.ticketStatus")
    if GW.Retail then
        AddMover(UIWidgetPowerBarContainerFrame, "PowerBarContainer", "widgets.powerBarContainer", { 100, 20 })
        AddMover(EventToastManagerFrame, "EventToastWidget", "widgets.eventToast", { 200, 20 })
        AddMover(BossBanner, "BossBannerWidget", "widgets.bossBanner", { 200, 20 })
    end

    hooksecurefunc(UIWidgetTemplateStatusBarMixin, "Setup", SkinStatusBarWidget)
    hooksecurefunc(UIWidgetTemplateCaptureBarMixin, "Setup", OnCaptureBarSetup)

    -- widgets that were set up before this ran, e.g. after a reload
    if UIWidgetPowerBarContainerFrame then
        for _, widget in pairs(UIWidgetPowerBarContainerFrame.widgetFrames) do
            SkinStatusBarWidget(widget)
        end
    end
    local belowMinimap = UIWidgetBelowMinimapContainerFrame
    for _, widget in pairs(belowMinimap.widgetFrames or {}) do
        OnCaptureBarSetup(widget, nil, belowMinimap)
    end
end
GW.WidgetUISetup = WidgetUISetup
