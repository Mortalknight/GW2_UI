local _, GW = ...

local function EmberCourtCaptureBar() end

local function PVPCaptureBar(self)
    self.LeftLine:SetAlpha(0)
    self.RightLine:SetAlpha(0)
    self.BarBackground:SetAlpha(0)
    self.Glow1:SetAlpha(0)
    self.Glow2:SetAlpha(0)
    self.Glow3:SetAlpha(0)

    self.LeftBar:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg")
    self.RightBar:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg")
    self.NeutralBar:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg")

    self.LeftBar:SetVertexColor(0.2, 0.6, 1.0)
    self.RightBar:SetVertexColor(0.9, 0.2, 0.2)
    self.NeutralBar:SetVertexColor(0.8, 0.8, 0.8)

    if not self.backdrop then
        self:GwCreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
        self.backdrop:SetPoint("TOPLEFT", self.LeftBar, -1, 1)
        self.backdrop:SetPoint("BOTTOMRIGHT", self.RightBar, 1, -1)
    end
end

local captureBarSkins = {
    [2] = PVPCaptureBar,
    [252] = EmberCourtCaptureBar
}

local function TopCenterPosition(self, _, anchor)
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

    if not bar.backdrop then
        bar:GwCreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)

        bar.BGLeft:SetAlpha(0)
        bar.BGRight:SetAlpha(0)
        bar.BGCenter:SetAlpha(0)
        bar.BorderLeft:SetAlpha(0)
        bar.BorderRight:SetAlpha(0)
        bar.BorderCenter:SetAlpha(0)
        bar.Spark:SetAlpha(0)
    end
end

local function UIWidgetTemplateCaptureBar(self, _, widgetContainer)
    if not widgetContainer then return end
    local skinFunc = captureBarSkins[widgetContainer.widgetSetID]
    if skinFunc then skinFunc(self) end
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


local function WidgetUISetup()
    -- avoide conflict with elvui
    if not CheckElvUI() then
        GW.RegisterMovableFrame(UIWidgetTopCenterContainerFrame, "TopWidget", "TopCenterWidget_pos", ALL .. ",Blizzard,Widgets", {58, 58}, {"default", "scaleable"})
        GW.RegisterMovableFrame(UIWidgetPowerBarContainerFrame, "PowerBarContainer", "PowerBarContainer_pos", ALL .. ",Blizzard,Widgets", {100, 20}, {"default", "scaleable"})
        GW.RegisterMovableFrame(UIWidgetBelowMinimapContainerFrame, "BelowMinimapWidget", "BelowMinimapContainer_pos", ALL .. ",Blizzard,Widgets", {150, 30}, {"default", "scaleable"})

        C_Timer.After(0.5, function()
            UIWidgetTopCenterContainerFrame:ClearAllPoints()
            UIWidgetTopCenterContainerFrame:SetPoint("CENTER", UIWidgetTopCenterContainerFrame.gwMover, "CENTER")

            UIWidgetPowerBarContainerFrame:ClearAllPoints()
            UIWidgetPowerBarContainerFrame:SetPoint("CENTER", UIWidgetTopCenterContainerFrame.gwMover, "CENTER")

            UIWidgetBelowMinimapContainerFrame:ClearAllPoints()
            UIWidgetBelowMinimapContainerFrame:SetPoint("CENTER", UIWidgetBelowMinimapContainerFrame.gwMover, "CENTER")
        end)

        hooksecurefunc(UIWidgetTopCenterContainerFrame, "SetPoint", TopCenterPosition)
        hooksecurefunc(UIWidgetPowerBarContainerFrame, "SetPoint", TopCenterPosition)
        hooksecurefunc(UIWidgetBelowMinimapContainerFrame, "SetPoint", TopCenterPosition)

        hooksecurefunc(UIWidgetTemplateStatusBarMixin, "Setup", UIWidgetTemplateStatusBar)
        hooksecurefunc(UIWidgetTemplateCaptureBarMixin, "Setup", UIWidgetTemplateCaptureBar)

        -- handle power bar widgets after reload as Setup will have fired before this
        for _, widget in pairs(UIWidgetPowerBarContainerFrame.widgetFrames) do
            UIWidgetTemplateStatusBar(widget)
        end
    end
end
GW.WidgetUISetup = WidgetUISetup
