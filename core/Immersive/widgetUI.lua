local _, GW = ...

local function BelowMinimap_EmberCourt() end

local function BelowMinimap_CaptureBar(self)
    if not self.LeftLine or not self.LeftBar then return end

    self.GlowPulseAnim:Stop()

    local hideElements = { "LeftLine", "RightLine", "BarBackground", "SparkNeutral", "Glow1", "Glow2", "Glow3" }
    for _, elem in ipairs(hideElements) do
        if self[elem] then
            self[elem]:SetAlpha(0)
        end
    end

    local texturePath = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg.png"
    self.LeftBar:SetTexture(texturePath)
    self.RightBar:SetTexture(texturePath)
    self.NeutralBar:SetTexture(texturePath)

    self.LeftBar:SetVertexColor(0.2, 0.6, 1.0)
    self.RightBar:SetVertexColor(0.9, 0.2, 0.2)
    self.NeutralBar:SetVertexColor(0.8, 0.8, 0.8)

    if not self.backdrop then
        self:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
        self.backdrop:SetPoint("TOPLEFT", self.LeftBar, -1, 1)
        self.backdrop:SetPoint("BOTTOMRIGHT", self.RightBar, 1, -1)
    else
        self.backdrop:SetFrameLevel(self:GetFrameLevel() - 1)
    end
end

local captureBarSkins = {
    [2] = BelowMinimap_CaptureBar,
    [252] = BelowMinimap_EmberCourt
}

local function UpdatePosition(self, _, anchor)
    local holder = self.gwMover
    if holder and anchor ~= holder then
        self:ClearAllPoints()
        self:SetPoint("CENTER", holder, "CENTER")
    end
end

local ignoreWidgetSetID = {
    [283] = true -- Cosmic Energy
}


local function UIWidgetTemplateStatusBar(self)
    local forbidden = self:IsForbidden()
    local bar = self.Bar

    if forbidden and bar then
        if bar.tooltip then bar.tooltip = nil end -- EmbeddedItemTooltip is tainted
        return
    elseif forbidden or ignoreWidgetSetID[self.widgetSetID] or not bar then
        return
    end

    local hideParts = { "BGLeft", "BGRight", "BGCenter", "BorderLeft", "BorderRight", "BorderCenter", "Spark" }
    for _, part in ipairs(hideParts) do
        if bar[part] then
            bar[part]:SetAlpha(0)
        end
    end

    if not bar.backdrop and not GW.IsSecretValue(bar:GetWidth()) then
        bar:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

        if self.Label then -- title
            self.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "SHADOW")
        end

        if bar.Label then -- percent text
            bar.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "SHADOW")
        end

        if self.Text then
            self.Text:SetTextColor(1, 1, 1)
        end
    end
end

local function BelowMinimap_UpdateBar(self, _, widgetContainer)
    if self:IsForbidden() or not widgetContainer then return end

    local skinFunc = captureBarSkins[widgetContainer.widgetSetID]
    if skinFunc then skinFunc(self) end
end

local function UIWidgetTemplateCaptureBar(self, widgetInfo, widgetContainer)
    if widgetContainer == UIWidgetBelowMinimapContainerFrame and widgetContainer.ProcessWidget then
        return
    end

    BelowMinimap_UpdateBar(self, widgetInfo, widgetContainer)
end

local function BelowMinimap_ProcessWidget(self, widgetID)
    if not self or not self.widgetFrames then return end

    if widgetID then
        local bar = self.widgetFrames[widgetID]
        if bar then
            BelowMinimap_UpdateBar(bar, nil, self)
        end
    else
        for _, bar in next, self.widgetFrames do
            BelowMinimap_UpdateBar(bar, nil, self)
        end
    end

end

local function CheckElvUI()
    if not LibStub then
        return false
    end
    local ace = LibStub("AceAddon-3.0", true)
    if not ace then
        return false
    end
    local elv = ace:GetAddon("ElvUI", true)
    if not elv then
        return false
    end
    local b = elv:GetModule("Blizzard")
    if not b then
        return false
    end

    GW.Debug(b.Initialized)
    return b.Initialized
end

local function BuildWidgetMover(container, moverName, setting, size)
    GW.RegisterMovableFrame(container, moverName, setting, ALL .. ",Blizzard,Widgets", size, {"default", "scaleable"})

    UpdatePosition(container, container.gwMover)
    hooksecurefunc(container, "SetPoint", UpdatePosition)
end

local function WidgetUISetup()
    -- avoide conflict with elvui
    if not CheckElvUI() then
        BuildWidgetMover(UIWidgetTopCenterContainerFrame, "TopWidget", "TopCenterWidget_pos", {58, 58})
        BuildWidgetMover(UIWidgetBelowMinimapContainerFrame, "BelowMinimapWidget", "BelowMinimapContainer_pos", {150, 30})
        BuildWidgetMover(TicketStatusFrame, "GM Ticket Frame", "TicketStatusFrame_pos")

        if GW.Retail then
           BuildWidgetMover(UIWidgetPowerBarContainerFrame, "PowerBarContainer", "PowerBarContainer_pos", {100, 20})
            BuildWidgetMover(EventToastManagerFrame, "EventToastWidget", "EventToastWidget_pos", {200, 20})
            BuildWidgetMover(BossBanner, "BossBannerWidget", "BossBannerWidget_pos", {200, 20})

            -- handle power bar widgets after reload as Setup will have fired before this
            for _, widget in pairs(UIWidgetPowerBarContainerFrame.widgetFrames) do
                UIWidgetTemplateStatusBar(widget)
            end
        end

        hooksecurefunc(UIWidgetTemplateStatusBarMixin, "Setup", UIWidgetTemplateStatusBar)
        hooksecurefunc(UIWidgetTemplateCaptureBarMixin, "Setup", UIWidgetTemplateCaptureBar)

        if UIWidgetBelowMinimapContainerFrame.ProcessWidget then
            hooksecurefunc(UIWidgetBelowMinimapContainerFrame, 'ProcessWidget', BelowMinimap_ProcessWidget)
        end

        BelowMinimap_ProcessWidget(UIWidgetBelowMinimapContainerFrame)
    end
end
GW.WidgetUISetup = WidgetUISetup
