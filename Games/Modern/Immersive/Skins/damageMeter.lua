---@class GW2
local GW = select(2, ...)

local DROPDOWN_WIDTH_OFFSET = 8

local RESIZE_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/resize.png"
local ARROW_TEXTURE = "Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png"

-- the resize grip turns dark while the mouse is on it
local function TintResizeGrip(button, shade)
    local normal = button:GetNormalTexture()
    if normal then
        normal:SetVertexColor(shade, shade, shade)
    end
end

local function HandleResizeButton(button)
    if not button or button.gwSkinned then return end
    button.gwSkinned = true

    button:GetHighlightTexture():SetTexture("")
    for _, state in ipairs({"Normal", "Pushed"}) do
        button["Set" .. state .. "Texture"](button, RESIZE_TEXTURE)
        local texture = button["Get" .. state .. "Texture"](button)
        texture:SetVertexColor(1, 1, 1)
        texture:SetTexCoord(0, 1, 0, 1)
        texture:SetAllPoints()
    end
    button:HookScript("OnEnter", function(self) TintResizeGrip(self, 0) end)
    button:HookScript("OnLeave", function(self) TintResizeGrip(self, 1) end)
end

local function BackdropSetAlpha(self, alpha)
    if self.backdrop then
        self.backdrop:SetAlpha(alpha)
    end
end

local function HandleBackground(window, background)
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

    sessionTimer:GwNudgePoint(4)
    sessionTimer:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
end

local function HandleTypeDropdown(window, dropdown)
    if not dropdown or dropdown.gwSkinned then return end

    dropdown:SetSize(20, 20)
    dropdown:GwNudgePoint(0, -2)

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
        dropdown.TypeName:GwNudgePoint(-2, -1)
        dropdown.TypeName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end

    dropdown.gwSkinned = true
end

local function HandleSessionDropdown(window, dropdown)
    if not dropdown or dropdown.gwSkinned then return end

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

end

local function HandleSettingsDropdown(window, dropdown)
    if not dropdown or dropdown.gwSkinned then return end

    dropdown:GwSkinButton(false, false, false, true, false, true)

    dropdown:SetSize(20, 20)
    dropdown:GwNudgePoint(2, 0)

    -- the cog of our micro menu instead of blizzards icon
    if dropdown.Icon then
        dropdown.Icon:SetAlpha(0)
    end
    if not dropdown.gwCog then
        dropdown.gwCog = dropdown:CreateTexture(nil, "BACKGROUND")
        dropdown.gwCog:SetPoint("CENTER")
        dropdown.gwCog:SetSize(20, 20)
        dropdown.gwCog:SetTexture("Interface/AddOns/GW2_UI/textures/icons/mainmenumicrobutton-up.png")
    end

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
    -- the slim bar of our windows, the meter is small
    local ScrollBar = window.GetScrollBar and window:GetScrollBar()
    if ScrollBar then
        GW.SkinSlimScrollBar(ScrollBar)
    end

    local ScrollBox = window.GetScrollBox and window:GetScrollBox()
    if ScrollBox and not ScrollBox.gwSkinned then
        hooksecurefunc(ScrollBox, "Update", ScrollBoxUpdate)

        ScrollBoxUpdate(ScrollBox)

        ScrollBox.gwSkinned = true
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
    if not sourceWindow or sourceWindow.gwSkinned then return end

    HandleBackground(sourceWindow, sourceWindow.Background)
    HandleScrollBoxes(sourceWindow)
    if sourceWindow.AnchorToSessionWindow then
        hooksecurefunc(sourceWindow, "AnchorToSessionWindow", RepositionResizeButton)
    end
    sourceWindow.gwSkinned = true
end

-- the own bar shown while the window is minimized keeps its background visible
local function HandleLocalPlayerEntry(self)
    local entry = self.MinimizeContainer.LocalPlayerEntry
    if not entry then return end
    HandleStatusBar(entry)
    if entry.StatusBar and entry.StatusBar.Background then
        entry.StatusBar.Background:SetAlpha(1)
    end
end

-- the minimize button is our arrow, pointing to the side while minimized
local function SetMinimized(self, collapsed)
    local button = self.MinimizeButton
    if not button then return end
    for _, state in ipairs({"Normal", "Pushed", "Highlight"}) do
        local texture = button["Get" .. state .. "Texture"](button)
        texture:SetTexture(ARROW_TEXTURE)
        texture:SetRotation(collapsed and math.pi / 2 or 0)
    end
end

local function HandleMinimizeContainer(window, container)
    if not container or container.gwSkinned then return end

    HandleBackground(window, container.Background)
    RepositionResizeButton(container)

    container.gwSkinned = true
end

local function HandleMinimizeButton(window, button)
    if not button or button.gwSkinned then return end

    button:SetSize(16, 16)
    button:GwNudgePoint(0)

    SetMinimized(window, window.isMinimized)
    hooksecurefunc(window, "SetMinimized", SetMinimized)

    button.gwSkinned = true
end

local function HandleSessionWindow(self)
    if self.gwSkinned then return end

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

    self.gwSkinned = true
end

local function SetupSessionWindow()
    DamageMeter:ForEachSessionWindow(HandleSessionWindow)
end

local function ApplyDamageMeterSkin()
    if not GW.settings.skins.damageMeter.enabled then return end

    hooksecurefunc(DamageMeter, "SetupSessionWindow", SetupSessionWindow)
    SetupSessionWindow()
end

function GW.LoadDamageMeterSkin()
    GW.RegisterLoadHook(ApplyDamageMeterSkin, "Blizzard_DamageMeter", DamageMeter)
end