---@class GW2
local GW = select(2, ...)

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
    if self.backdrop then
        self.backdrop:SetAlpha(alpha)
    end
end

local function HandleBackground(window, background, x1, y1, x2, y2)
    if not window or not background or background.backdrop then return end

    background:SetTexture()

    background:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    background.backdrop:SetAlpha(background:GetAlpha())

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
    dropdown:GwNudgePoint(2, 0)

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

local function HandleScrollBoxes(window)
    local ScrollBar = window.GetScrollBar and window:GetScrollBar()
    if ScrollBar then
        GW.HandleTrimScrollBar(ScrollBar)
        GW.HandleScrollControls(window)
    end

    local ScrollBox = window.GetScrollBox and window:GetScrollBox()
    if ScrollBox and not ScrollBox.IsSkinned then
        hooksecurefunc(ScrollBox, "Update", ScrollBoxUpdate)

        ScrollBoxUpdate(ScrollBox)

        ScrollBox.IsSkinned = true
    end
end

local function RepositionResizeButton(container)
    local ResizeButton = container.ResizeButton
    if not ResizeButton then return end

    HandleResizeButton(ResizeButton)

    ResizeButton:SetSize(20, 20)
    ResizeButton:ClearAllPoints()

    local isRightSide = not container.IsRightSide or container:IsRightSide()
    local point = isRightSide and "BOTTOMRIGHT" or "BOTTOMLEFT"
    local xOffset = isRightSide and -4 or 4

    ResizeButton:SetPoint(point, container.Background, point, xOffset, 4)
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

local function HandleLocalPlayerEntry(self)
    local entry = self.MinimizeContainer.LocalPlayerEntry

    if not entry then return end

    HandleStatusBar(entry)

    local StatusBarBackground = entry.StatusBar and entry.StatusBar.Background
    if StatusBarBackground then
        StatusBarBackground:SetAlpha(1)
    end
end

local function SetMinimized(self, collapsed)
    local MinimizeButton = self.MinimizeButton
    if not MinimizeButton then return end

    local normalTexture = MinimizeButton:GetNormalTexture()
    local pushedTexture = MinimizeButton:GetPushedTexture()
    local highlightTexture = MinimizeButton:GetHighlightTexture()

    if collapsed then
        normalTexture:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        pushedTexture:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        highlightTexture:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        normalTexture:SetRotation(1.570796325)
        pushedTexture:SetRotation(1.570796325)
        highlightTexture:SetRotation(1.570796325)
    else
        normalTexture:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        pushedTexture:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        highlightTexture:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        normalTexture:SetRotation(0)
        pushedTexture:SetRotation(0)
        highlightTexture:SetRotation(0)
    end
end

local function HandleMinimizeContainer(window, container)
    if not container or container.IsSkinned then return end

    HandleBackground(window, container.Background, 13, nil, -18)
    RepositionResizeButton(container)

    container.IsSkinned = true
end

local function HandleMinimizeButton(window, button)
    if not button or button.IsSkinned then return end

    button:SetSize(16, 16)
    button:GwNudgePoint(13)

    SetMinimized(window, window.isMinimized)
    hooksecurefunc(window, "SetMinimized", SetMinimized)

    button.IsSkinned = true
end

local function HandleSessionWindow(self)
    if self.IsSkinned then return end

    HandleHeader(self, self.Header)
    HandleMinimizeButton(self, self.MinimizeButton)
    HandleMinimizeContainer(self, self.MinimizeContainer)
    HandleTypeDropdown(self, self.DamageMeterTypeDropdown)
    HandleSessionDropdown(self, self.SessionDropdown)
    HandleSettingsDropdown(self, self.SettingsDropdown)
    HandleSourceWindow(self.MinimizeContainer, self.MinimizeContainer.SourceWindow)
    HandleSessionTimer(self, self.SessionTimer)
    HandleScrollBoxes(self)

    if self.ShowLocalPlayerEntry then
        hooksecurefunc(self, "ShowLocalPlayerEntry", HandleLocalPlayerEntry)
    end

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