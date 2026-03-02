local _, GW = ...

local DROPDOWN_WIDTH_OFFSET = 8

local function ButtonOnEnter(self)
    local normalTex = self:GetNormalTexture()
    if not normalTex then return end

    normalTex:SetVertexColor(0, 0, 0)
end

local function ButtonOnLeave(self)
    local normalTex = self:GetNormalTexture()
    if not normalTex then return end

    normalTex:SetVertexColor(1, 1, 1)
end

local function HandleResizeButton(button)
    if not button or button.IsSkinned then return end

    button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/resize.png")
    button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/resize.png")
    button:GetHighlightTexture():SetTexture("")

    local normalTex = button:GetNormalTexture()
    local pushedTex = button:GetPushedTexture()

    if not normalTex or not pushedTex then return end

    normalTex:SetVertexColor(1, 1, 1)
    normalTex:SetTexCoord(0, 1, 0, 1)
    normalTex:SetAllPoints()

    pushedTex:SetVertexColor(1, 1, 1)
    pushedTex:SetTexCoord(0, 1, 0, 1)
    pushedTex:SetAllPoints()

    button:HookScript("OnEnter", ButtonOnEnter)
    button:HookScript("OnLeave", ButtonOnLeave)

    button.IsSkinned = true
end

local function BackdropSetAlpha(self, alpha)
    local parent = self:GetParent()
    if parent and parent.backdrop then
        parent.backdrop:SetAlpha(alpha)
    end
end

local function HandleBackground(window, background, x1, y1, x2, y2)
    if not window or not background or window.backdrop then return end

    background:Hide()

    window:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    window.backdrop:GwNudgePoint(x1, y1, nil, "TOPLEFT")
    window.backdrop:GwNudgePoint(x2, y2, nil, "BOTTOMRIGHT")

    window.backdrop:SetAlpha(window.backgroundAlpha or 1)

    hooksecurefunc(background, "SetAlpha", BackdropSetAlpha)
end

local function DropdownSetWidth(self, width, overrideFlag)
    if overrideFlag then return end

    self:SetWidth(width + DROPDOWN_WIDTH_OFFSET, true)
end

local function HandleSessionTimer(window, sessionTimer)
    if not sessionTimer then return end

    sessionTimer:GwNudgePoint(-15)
    sessionTimer:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
end

local function HandleTypeDropdown(window, dropdown)
    if not dropdown or dropdown.IsSkinned then return end

    dropdown:SetSize(20, 20)
    dropdown:GwNudgePoint(nil, -2)

    local customArrow = not dropdown.customArrow and dropdown:CreateTexture(nil, "BACKGROUND")
    if customArrow then
        customArrow:SetPoint("CENTER")
        customArrow:SetSize(16, 16)
        customArrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")

        dropdown.customArrow = customArrow
    end

    if dropdown.Arrow then
        dropdown.Arrow:SetAlpha(0)
    end

    if dropdown.TypeName then
        dropdown.TypeName:GwNudgePoint(-4, -1)
        dropdown.TypeName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end

    dropdown.IsSkinned = true
end

local function HandleSessionDropdown(window, dropdown)
    if not dropdown or dropdown.IsSkinned then return end

    dropdown:GwSkinButton(false, true)

    dropdown:GwNudgePoint(nil, -3)
    dropdown:SetHeight(20)

    local newWidth = dropdown:GetWidth() + DROPDOWN_WIDTH_OFFSET
    dropdown:SetWidth(newWidth, true)

    hooksecurefunc(dropdown, "SetWidth", DropdownSetWidth)

    if dropdown.Arrow then
        dropdown.Arrow:SetAlpha(0)
    end

    if dropdown.ResetButton then
        dropdown.ResetButton:GwSkinButton(true)
    end

    if dropdown.SessionName then
        dropdown.SessionName:SetTextColor(0, 0, 0)
    end

    dropdown.IsSkinned = true
end

local function HandleSettingsDropdown(window, dropdown)
    if not dropdown or dropdown.IsSkinned then return end

    dropdown:GwSkinButton(false, false, false, true, false, true)

    dropdown:SetSize(20, 20)
    dropdown:GwNudgePoint(15, -2)

    if dropdown.Icon then
        dropdown.Icon:SetAlpha(0)
    end

    local customIcon = not dropdown.customIcon and dropdown:CreateTexture(nil, "BACKGROUND")
    if customIcon then
        customIcon:SetPoint("CENTER")
        customIcon:SetSize(20, 20)
        customIcon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/mainmenumicrobutton-up.png")

        dropdown.customIcon = customIcon
    end

    dropdown.IsSkinned = true
end

local function HandleHeader(window, header)
    if not window or not header then return end

    header:SetTexture("Interface/Addons/GW2_UI/textures/uistuff/periodic-bg.png")
    header:SetVertexColor(0, 0, 0, 0.45)
    header:ClearAllPoints()
    header:SetPoint("TOPLEFT", 16, -2)
    header:SetPoint("BOTTOMRIGHT", window, "TOPRIGHT", -22, -32)
end

local function HandleStatusBar(self)
    local StatusBar = self.StatusBar
    if not StatusBar then return end

    if StatusBar.Background then
        StatusBar.Background:SetTexture("Interface/Addons/GW2_UI/textures/hud/castinbar-white.png")
        StatusBar.Background:SetVertexColor(0, 0, 0, 0)
    end

    if StatusBar.BackgroundEdge then
        StatusBar.BackgroundEdge:Hide()
    end

    StatusBar:GetStatusBarTexture():SetTexture("Interface/Addons/GW2_UI/textures/addonSkins/details_statusbar.png")
end

local function ScrollBoxUpdate(self)
    if not self.ForEachFrame then return end

    self:ForEachFrame(HandleStatusBar)
end

do
    local updating = false
    function GW.ScrollBoxSetPoint(self, point)
        if not updating and point == "TOPLEFT" then
            updating = true
            self:GwNudgePoint(-15)
            updating = false
        end
    end
end

local function HandleScrollBoxes(window)
    local ScrollBar = window.GetScrollBar and window:GetScrollBar()
    if ScrollBar then
        GW.HandleTrimScrollBar(ScrollBar)
        GW.HandleScrollControls(window)
    end

    local ScrollBox = window.GetScrollBox and window:GetScrollBox()
    if ScrollBox and not ScrollBox.IsSkinned then
        hooksecurefunc(ScrollBox, "Update", ScrollBoxUpdate)
        hooksecurefunc(ScrollBox, "SetPoint", GW.ScrollBoxSetPoint)

        ScrollBoxUpdate(ScrollBox)
        GW.ScrollBoxSetPoint(ScrollBox, "TOPLEFT")

        ScrollBox.IsSkinned = true
    end
end

local function RepositionResizeButton(self)
    local ResizeButton = self.backdrop and self.GetResizeButton and self:GetResizeButton()
    if not ResizeButton then return end

    HandleResizeButton(ResizeButton)

    ResizeButton:SetSize(20, 20)
    ResizeButton:ClearAllPoints()

    local isRightSide = not self.IsRightSide or self:IsRightSide()
    local point = isRightSide and "BOTTOMRIGHT" or "BOTTOMLEFT"
    local xOffset = isRightSide and -4 or 4

    ResizeButton:SetPoint(point, self.backdrop, point, xOffset, 4)
end

local function HandleSourceWindow(window, sourceWindow)
    if not sourceWindow or sourceWindow.IsSkinned then return end

    HandleBackground(sourceWindow, sourceWindow.Background, -4, nil, -18)
    HandleScrollBoxes(sourceWindow)

    if sourceWindow.AnchorToSessionWindow then
        hooksecurefunc(sourceWindow, "AnchorToSessionWindow", RepositionResizeButton)
    end

    sourceWindow.IsSkinned = true
end

local function HandleSessionWindow(self)
    if self.IsSkinned then return end

    HandleBackground(self, self.Background, 13, nil, -18)
    HandleHeader(self, self.Header)
    HandleTypeDropdown(self, self.DamageMeterTypeDropdown)
    HandleSessionDropdown(self, self.SessionDropdown)
    HandleSettingsDropdown(self, self.SettingsDropdown)
    HandleSourceWindow(self, self.SourceWindow)
    HandleSessionTimer(self, self.SessionTimer)
    HandleScrollBoxes(self)
    RepositionResizeButton(self)

    self.IsSkinned = true
end

local function SetupSessionWindow()
    DamageMeter:ForEachSessionWindow(HandleSessionWindow)
end

local function ApplyDamageMeterSkin()
    if not GW.settings.DamageMeterSkinEnabled then return end

    hooksecurefunc(DamageMeter, "SetupSessionWindow", SetupSessionWindow)
    SetupSessionWindow()
end

function GW.LoadDamageMeterSkin()
    GW.RegisterLoadHook(ApplyDamageMeterSkin, "Blizzard_DamageMeter", DamageMeter)
end