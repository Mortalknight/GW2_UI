local _, GW = ...

local atlasColors = {
    ["UI-Frame-Bar-Fill-Blue"]				= {0.2, 0.6, 1.0},
    ["UI-Frame-Bar-Fill-Red"]				= {0.9, 0.2, 0.2},
    ["UI-Frame-Bar-Fill-Yellow"]			= {1.0, 0.6, 0.0},
    ["objectivewidget-bar-fill-left"]		= {0.2, 0.6, 1.0},
    ["objectivewidget-bar-fill-right"]		= {0.9, 0.2, 0.2},
    ["EmberCourtScenario-Tracker-barfill"]	= {0.9, 0.2, 0.2},
}

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
        self:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
        self.backdrop:SetPoint("TOPLEFT", self.LeftBar, -1, 1)
        self.backdrop:SetPoint("BOTTOMRIGHT", self.RightBar, 1, -1)
    end
end

local CaptureBarSkins = {
    [2] = PVPCaptureBar,
    [252] = EmberCourtCaptureBar
}

local function TopCenterPosition(self, _, b)
    local holder = UIWidgetTopCenterContainerFrame.gwMover
    if b and (b ~= holder) then
        self:ClearAllPoints()
        self:SetPoint("CENTER", holder, "CENTER")
    end
end

local function UpdateBarTexture(bar, atlas)
    if atlasColors[atlas] then
        bar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar")
        bar:SetStatusBarColor(unpack(atlasColors[atlas]))
    end
end


local function UIWidgetTemplateStatusBar(self)
    local bar = self.Bar
    local atlas = bar:GetStatusBarAtlas()
    UpdateBarTexture(bar, atlas)

    if not bar.backdrop then
        bar:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)

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
    local skinFunc = CaptureBarSkins[widgetContainer.widgetSetID]
    if skinFunc then skinFunc(self) end
end


local function WidgetUISetup()
    GW.RegisterMovableFrame(UIWidgetTopCenterContainerFrame, "TopWidget", "TopCenterWidget_pos", "VerticalActionBarDummy", {58, 58}, nil, {"default", "scaleable"})
    UIWidgetTopCenterContainerFrame:ClearAllPoints()
    UIWidgetTopCenterContainerFrame:SetPoint("CENTER", UIWidgetTopCenterContainerFrame.gwMover, "CENTER")

    hooksecurefunc(UIWidgetTopCenterContainerFrame, "SetPoint", TopCenterPosition)

    hooksecurefunc(UIWidgetTemplateStatusBarMixin, "Setup", UIWidgetTemplateStatusBar)
    hooksecurefunc(UIWidgetTemplateCaptureBarMixin, "Setup", UIWidgetTemplateCaptureBar)
end
GW.WidgetUISetup = WidgetUISetup
