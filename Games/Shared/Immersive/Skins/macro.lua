---@class GW2
local GW = select(2, ...)

-- One skin for the macro window of every client. The window itself is the same everywhere, what differs is its
-- art: the classic clients still use plain textures where mists and retail have nine slice frames, only they
-- have the old grid of macro buttons, and retail hangs the gw2 backgrounds behind the stripped list instead of
-- giving it a backdrop of its own.
local CLASSIC = GW.Classic or GW.TBC or GW.Wrath
local WINDOW_ICON = "Interface/AddOns/GW2_UI/textures/character/macro-window-icon.png"
local BUTTON_HIGHLIGHT = "Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png"

local function SkinSelectorButton(button)
    if button.Icon then
        GW.HandleItemButton(button, true)
    end
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
    local wanted, found = CLASSIC and 2 or 1, 0
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
    -- retail puts its detail backgrounds where the blizzard art was, so that has to go first
    if GW.Retail then
        MacroFrameInset:GwStripTextures()
        MacroFrame.MacroSelector.ScrollBox:GwStripTextures()
    end

    local detailBackgrounds = GW.Mists and {MacroFrameInset} or {MacroFrameInset, MacroFrame.MacroSelector.ScrollBox}
    GW.CreateFrameHeaderWithBody(MacroFrame, headerText, WINDOW_ICON, detailBackgrounds, nil, false, true)

    if GW.Retail then
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

    if MacroFrameInset.NineSlice then
        MacroFrameInset.NineSlice:Hide()
    end
    if CLASSIC then
        MacroFrameInset:GwStripTextures()
    end

    -- the box behind the macro text: a nine slice from mists on, plain textures before that
    local textBackground = MacroFrameTextBackground
    if CLASSIC then
        textBackground:GwStripTextures()
        textBackground:GwCreateBackdrop(GW.BackdropTemplates.Default)
    else
        if not textBackground.NineSlice.SetBackdrop then
            Mixin(textBackground.NineSlice, BackdropTemplateMixin)
            textBackground.NineSlice:HookScript("OnSizeChanged", textBackground.NineSlice.OnBackdropSizeChanged)
        end
        textBackground.NineSlice:SetBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
        textBackground.NineSlice:SetBackdropBorderColor(0, 0, 0)
    end

    for _, region in pairs(regions) do
        if region:GetObjectType() == "Texture" then
            region:Hide()
        end
    end
end

local function SkinScrollFrames()
    local selector = MacroFrame.MacroSelector
    if not GW.Retail then
        selector.ScrollBox:GwStripTextures()
        selector.ScrollBox:GwCreateBackdrop(GW.BackdropTemplates.Default)
    end
    GW.HandleTrimScrollBar(selector.ScrollBar)
    GW.HandleScrollControls(selector)

    -- the macro text has the new scrollbar on retail and the old one on the other clients
    if MacroFrameScrollFrame.ScrollBar then
        GW.HandleTrimScrollBar(MacroFrameScrollFrame.ScrollBar)
        GW.HandleScrollControls(MacroFrameScrollFrame)
    elseif _G.MacroFrameScrollFrameScrollBar then
        _G.MacroFrameScrollFrameScrollBar:GwSkinScrollBar()
    end
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
    if GW.Retail then
        MacroNewButton:SetPoint("BOTTOMRIGHT", -86, 4)
    end

    MacroFrameCloseButton:GwSkinButton(true)
    MacroFrameCloseButton:SetSize(25, 25)
    MacroFrameCloseButton:ClearAllPoints()
    MacroFrameCloseButton:SetPoint("TOPRIGHT", 0, 0)
end

local function SkinTabs()
    if CLASSIC then
        MacroFrameTab1:GwSkinTab()
        MacroFrameTab2:GwSkinTab()
        return
    end

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
    button:SetHighlightTexture(BUTTON_HIGHLIGHT)
    MacroFrameSelectedMacroBackground:GwKill()

    if MacroFrameSelectedMacroName then
        MacroFrameSelectedMacroName:SetTextColor(1, 1, 1)
    end
end

-- the grid of macro buttons; retail lists them in the selector instead
local function SkinMacroButtons()
    if not _G.MacroButton1 then return end

    for i = 1, _G.MAX_ACCOUNT_MACROS do
        local button = _G["MacroButton" .. i]
        local icon = _G["MacroButton" .. i .. "Icon"]

        if button then
            button:SetHighlightTexture(BUTTON_HIGHLIGHT)
            button:SetCheckedTexture(BUTTON_HIGHLIGHT)
            local index = 1
            for _, region in pairs({button:GetRegions()}) do
                if region:GetObjectType() == "Texture" then
                    if index == 1 then
                        region:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/spelliconempty.png")
                        region:SetSize(button:GetSize())
                    end
                    index = index + 1
                end
            end
        end

        if icon then
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end
    end
end

local function ApplyMacroOptionsSkin()
    if not GW.settings.MACRO_SKIN_ENABLED then return end

    local regions = {MacroFrame:GetRegions()}

    SkinWindow(regions, GetHeaderText(regions))
    SkinScrollFrames()
    SkinButtons()
    SkinTabs()
    SkinSelectedMacro()
    SkinMacroButtons()

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
