---@class GW2
local GW = select(2, ...)

-- One skin for the macro window of every client. The window itself is the same everywhere, what differs is its
-- art: the classic clients still use plain textures where mists and retail have nine slice frames.
local WINDOW_ICON = "Interface/AddOns/GW2_UI/textures/character/macro-window-icon.png"
local BUTTON_HIGHLIGHT = "Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png"
local SLOT_BACKGROUND = "Interface/AddOns/GW2_UI/textures/uistuff/spelliconempty.png"

local function AddIconBorder(button)
    button:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)
    button.backdrop:SetBackdropBorderColor(0.6, 0.6, 0.6)
    button:SetHighlightTexture(BUTTON_HIGHLIGHT)
    button:GetHighlightTexture():SetAllPoints(button.backdrop)
end

local function SkinSelectorButton(button)
    if button.gwSkinned or not button.Icon then return end
    button.gwSkinned = true

    for _, region in ipairs({button:GetRegions()}) do
        if region:IsObjectType("Texture") and region ~= button.Icon and region ~= button.SelectedTexture and region ~= button.Highlight then
            region:SetTexture(SLOT_BACKGROUND)
            region:SetAllPoints(button)
        end
    end
    button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    AddIconBorder(button)
    button.SelectedTexture:SetTexture(BUTTON_HIGHLIGHT)
    button.SelectedTexture:SetAllPoints(button.backdrop)
end

local function UpdateSelectorButtons(scrollBox)
    if scrollBox.view then
        scrollBox:ForEachFrame(SkinSelectorButton)
        return
    end
    for _, button in next, {scrollBox.ScrollTarget:GetChildren()} do
        SkinSelectorButton(button)
    end
end

-- the window title is the second font string on the classic clients, the first everywhere else
local function GetHeaderText(regions)
    local wanted, found = (GW.Classic or GW.TBC or GW.Wrath) and 2 or 1, 0
    for _, region in pairs(regions) do
        if region:GetObjectType() == "FontString" then
            found = found + 1
            if found == wanted then
                return region
            end
        end
    end
end

local function SkinWindow(regions, headerText)
    -- the detail backgrounds go where the blizzard art was, so that has to go first
    MacroFrameInset:GwStripTextures()
    if MacroFrameInset.NineSlice then
        MacroFrameInset.NineSlice:Hide()
    end
    MacroFrame.MacroSelector.ScrollBox:GwStripTextures()
    -- the box behind the macro text gets one on every client: a nine slice from mists on, plain textures before that
    local textBackground = MacroFrameTextBackground
    if textBackground.NineSlice then
        textBackground.NineSlice:Hide()
    else
        textBackground:GwStripTextures()
    end

    local detailBackgrounds = {MacroFrameInset, MacroFrame.MacroSelector.ScrollBox, MacroFrameTextBackground}
    GW.CreateFrameHeaderWithBody(MacroFrame, headerText, WINDOW_ICON, detailBackgrounds, nil, false, true)

    if GW.isModern then
        local header = MacroFrame.gwHeader
        header.BGLEFT:ClearAllPoints()
        header.BGLEFT:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
        header.BGLEFT:SetPoint("TOPRIGHT", header, "TOPRIGHT", 0, 0)
        header.BGRIGHT:ClearAllPoints()
        header.BGRIGHT:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
        header.BGRIGHT:SetPoint("TOPLEFT", header, "TOPLEFT", 0, 0)
        headerText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    end

    MacroFrameBg:Hide()
    MacroFrame.TopTileStreaks:Hide()
    if MacroFrame.TitleBg then
        MacroFrame.TitleBg:Hide()
    end
    if MacroFrame.NineSlice then
        MacroFrame.NineSlice:Hide()
    end
    MacroFrame:GwCreateBackdrop()
    MacroHorizontalBarLeft:Hide()

    textBackground:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)
    textBackground.backdrop:SetBackdropBorderColor(0, 0, 0)

    for _, region in pairs(regions) do
        if region:GetObjectType() == "Texture" then
            region:Hide()
        end
    end
end

local function SkinScrollFrames()
    local selector = MacroFrame.MacroSelector
    GW.HandleTrimScrollBar(selector.ScrollBar)
    GW.HandleScrollControls(selector)
    -- the classic template puts its trim bar flush into the corner, mainline insets its minimal bar
    selector.ScrollBar:ClearAllPoints()
    selector.ScrollBar:SetPoint("TOPRIGHT", selector, "TOPRIGHT", 5, -5)
    selector.ScrollBar:SetPoint("BOTTOMRIGHT", selector, "BOTTOMRIGHT", 5, 5)

    -- the macro text has the minimal bar on mainline, the old clients still give it the panel bar,
    -- there it gets a minimal bar at mainlines offsets instead
    local scrollBar = MacroFrameScrollFrame.ScrollBar
    if not GW.isModern then
        MacroFrameScrollFrameScrollBar:Hide()
        scrollBar = CreateFrame("EventFrame", nil, MacroFrameTextBackground, "MinimalScrollBar")
        scrollBar:SetPoint("TOPLEFT", MacroFrameScrollFrame, "TOPRIGHT", 6, -4)
        scrollBar:SetPoint("BOTTOMLEFT", MacroFrameScrollFrame, "BOTTOMRIGHT", 6, 5)
        ScrollUtil.InitScrollFrameWithScrollBar(MacroFrameScrollFrame, scrollBar)
    end
    GW.SkinSlimScrollBar(scrollBar)
end

local function SkinButtons()
    local buttons = {
        MacroSaveButton,
        MacroCancelButton,
        MacroDeleteButton,
        MacroNewButton,
        MacroExitButton,
        MacroEditButton,
    }
    for i = 1, #buttons do
        buttons[i]:GwSkinButton(false, true)
    end
    MacroDeleteButton:GwSkinNegativeButton()
    MacroNewButton:ClearAllPoints()
    MacroNewButton:SetPoint("BOTTOMRIGHT", MacroExitButton, "BOTTOMLEFT", -1, 0)

    MacroFrameCloseButton:GwSkinButton(true)
    MacroFrameCloseButton:SetSize(25, 25)
    MacroFrameCloseButton:ClearAllPoints()
    MacroFrameCloseButton:SetPoint("TOPRIGHT", 0, 0)
end

local function SkinTabs()
    GW.HandleTabs(MacroFrameTab1, "top")
    GW.HandleTabs(MacroFrameTab2, "top")
    MacroFrameTab1:SetHeight(25)
    MacroFrameTab2:SetHeight(25)
    MacroFrameTab1:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", 4, -35)
    MacroFrameTab2:SetPoint("LEFT", MacroFrameTab1, "RIGHT", 0, 0)
    MacroFrameTab1.Text:SetAllPoints(MacroFrameTab1)
    MacroFrameTab2.Text:SetAllPoints(MacroFrameTab2)
end

local function SkinSelectedMacro()
    local button = MacroFrameSelectedMacroButton

    -- the old clients draw a slot frame behind the icon
    if not GW.Retail then
        local index = 1
        for _, region in pairs({button:GetRegions()}) do
            if region:GetObjectType() == "Texture" then
                if index == 1 then
                    region:Hide()
                end
                index = index + 1
            end
        end
    end

    button:GwStripTextures()
    button:GwStyleButton()
    button:GetNormalTexture():SetTexture()
    button.Icon:GwSetInside()
    button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    AddIconBorder(button)
    MacroFrameSelectedMacroBackground:GwKill()

    if MacroFrameSelectedMacroName then
        MacroFrameSelectedMacroName:SetTextColor(1, 1, 1)
    end
end

local function ApplyMacroOptionsSkin()
    if not GW.settings.skins.macro.enabled then return end

    local regions = {MacroFrame:GetRegions()}

    SkinWindow(regions, GetHeaderText(regions))
    SkinScrollFrames()
    SkinButtons()
    SkinTabs()
    SkinSelectedMacro()

    hooksecurefunc(MacroFrame.MacroSelector.ScrollBox, "Update", UpdateSelectorButtons)

    MacroPopupFrame:HookScript("OnShow", function(self)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", 10, 0)

        if not self.gwSkinned then
            GW.HandleIconSelectionFrame(self)
        end
    end)
end

local function LoadMacroOptionsSkin()
    GW.RegisterLoadHook(ApplyMacroOptionsSkin, "Blizzard_MacroUI", MacroFrame)
end
GW.LoadMacroOptionsSkin = LoadMacroOptionsSkin
