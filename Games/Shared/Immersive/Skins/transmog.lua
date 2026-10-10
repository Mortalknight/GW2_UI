---@class GW2
local GW = select(2, ...)

-- Transmogrifier: outfit list, character preview and wardrobe. Slots and cards are pooled, they are styled
-- from their mixin updates and only touch what changed

local HEADER_OVERLAP = 11 -- blizzards panels start 21 below the top, our header covers 32
local CONTROL_HEIGHT = 20
local FILTER_WIDTH = 90
local CHECKBOX_SIZE = 18
local BUTTON_HEIGHT = 28
local SITUATION_DROPDOWN_WIDTH = 300
local ICON_SIZE = 45 -- the slot icon, blizzards slot frame around it is 59
local FLYOUT_HEIGHT = 14
local ILLUSION_OFFSET = 4 -- the top of an enchant slot below the slot frame of its weapon

local WINDOW_ICON = "Interface/AddOns/GW2_UI/textures/character/character-window-icon.png"
local LIST_SELECTED = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"
local ITEM_BORDER = "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png"
local ARROW_UP = "Interface/AddOns/GW2_UI/textures/uistuff/arrowup_up.png"
local ARROW_DOWN = "Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up.png"

-- the state blizzard shows with its card and slot art, as the tint of our borders
local STATE_COLOR = {
    default = GW.Colors.SkinColors.CardBorder,
    incomplete = GW.Colors.SkinColors.IconBorder,
    disabled = GW.Colors.SkinColors.DisabledBorder,
    applied = GW.Colors.SkinColors.Applied,
}

local TAB_ART_KEYS = {
    "Left", "Middle", "Right", "LeftActive", "MiddleActive", "RightActive",
    "LeftHighlight", "MiddleHighlight", "RightHighlight",
}

local function SetWhiteText(text, sizeType)
    text:GwSetFontTemplate(UNIT_NAME_FONT, sizeType or GW.Enum.TextSizeType.Normal)
    text:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
end

local function SetHighlight(texture, region)
    texture:SetColorTexture(GW.Colors.SkinColors.HighlightWhite:GetRGBA())
    texture:ClearAllPoints()
    texture:SetAllPoints(region)
end

-- a gold item border around the icon: the active outfit, equipped gear and the selected slot
local function SetActiveBorder(texture, icon)
    texture:SetTexture(ITEM_BORDER)
    texture:SetTexCoord(0, 1, 0, 1)
    texture:SetVertexColor(GW.Colors.TextColors.LightHeader:GetRGB())
    texture:ClearAllPoints()
    texture:SetAllPoints(icon)
end

local function SkinSearchBox(box)
    if box.Background then
        box.Background:Hide()
    end
    if box.NineSlice then
        box.NineSlice:Hide()
    end
    GW.SkinTextBox(box.Middle, box.Left, box.Right, nil, nil, nil, nil, nil, box)
    box:SetHeight(CONTROL_HEIGHT)
end

local function SkinDropdown(dropdown, width)
    if not dropdown then return end
    if not width then
        local current = dropdown:GetWidth()
        width = current > 1 and current or nil
    end
    dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, width)
    dropdown:SetHeight(CONTROL_HEIGHT)
    if dropdown.backdrop then
        dropdown.backdrop:ClearAllPoints()
        dropdown.backdrop:SetAllPoints(dropdown)
    end
end

local function SkinSearchAndFilter(frame)
    local search, filter = frame.SearchBox, frame.FilterButton
    SkinSearchBox(search)
    SkinDropdown(filter, FILTER_WIDTH)
    search:ClearAllPoints()
    search:SetPoint("RIGHT", filter, "LEFT", -10, 0)
    local reset = filter.ResetButton
    if reset then
        reset:GwSkinButton(true)
        reset:SetSize(14, 14)
        reset:ClearAllPoints()
        reset:SetPoint("CENTER", filter, "TOPRIGHT", -2, -2)
    end
end

-- the check box fills a 30x29 frame (MinimalCheckboxArtTemplate), only its art shrinks
local function SkinToggle(toggle)
    if not toggle then return end
    toggle.Checkbox:GwSkinCheckButton(false, CHECKBOX_SIZE, true)
    if toggle.Text then
        SetWhiteText(toggle.Text)
    end
end

-- the arrows keep their size, the helper would resize them and misalign the page text
local function SkinPagingControls(paging)
    for _, button in ipairs({paging.PrevPageButton, paging.NextPageButton}) do
        local width, height = button:GetSize()
        GW.HandleNextPrevButton(button, button == paging.PrevPageButton and "left" or "right")
        button:SetSize(width, height)
    end
    if paging.PageText then
        SetWhiteText(paging.PageText)
    end
end

-- our light buttons need dark text; blizzard sets its font objects again on state changes
local blackButtonFont
local function LockBlackFont(button)
    if button.gwLockingFont then return end
    if not blackButtonFont then
        blackButtonFont = CreateFont("GW2_TransmogBlackButtonFont")
        blackButtonFont:CopyFontObject(GameFontNormal)
        blackButtonFont:SetTextColor(GW.Colors.Fallback:GetRGB())
        blackButtonFont:SetShadowOffset(0, 0)
    end
    button.gwLockingFont = true
    button:SetNormalFontObject(blackButtonFont)
    button:SetHighlightFontObject(blackButtonFont)
    button.gwLockingFont = nil
end

-- our light button; blizzards shared button template turns the text gold / white on hover otherwise
local function SkinLightButton(button)
    button:GwSkinButton(false, true)
    LockBlackFont(button)
end

local function SkinOutfitEntry(entry)
    local iconButton = entry.OutfitIcon
    iconButton.Border:SetAlpha(0)
    GW.HandleIcon(iconButton.Icon, true, GW.BackdropTemplates.DefaultWithSmallBorder, true)
    SetActiveBorder(iconButton.OverlayActive, iconButton.Icon)
    local highlight = iconButton:GetHighlightTexture()
    if highlight then
        SetHighlight(highlight, iconButton.Icon)
    end

    local button = entry.OutfitButton
    button.NormalTexture:SetAlpha(0)
    -- the row reaches the scroll bar instead of blizzards fixed 208
    button:SetPoint("RIGHT", entry, "RIGHT", 0, 0)
    GW.AddListItemChildHoverTexture(button)

    -- an own selection texture; blizzards art goes, its save and new animations would show it again
    for _, key in ipairs({"Selected", "SelectedPurple", "Glow", "GlowPurple"}) do
        button[key]:SetTexture(nil)
    end
    local selected = button:CreateTexture(nil, "ARTWORK", nil, 1)
    selected:SetTexture(LIST_SELECTED)
    selected:SetVertexColor(GW.Colors.SkinColors.ListSelected:GetRGBA())
    selected:SetAllPoints(button)
    selected:SetShown(button.Selected:IsShown())
    hooksecurefunc(entry, "SetSelected", function(_, isSelected)
        selected:SetShown(isSelected)
    end)

    SetWhiteText(button.TextContent.Name)
    button.TextContent.SituationInfo:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
end

-- "Show Currently Equipped Gear": like the outfit icons; blizzards purple frame was larger than the icon
-- and covered the label
local function SkinEquippedGearFrame(spellFrame)
    if not spellFrame then return end
    local button = spellFrame.Button
    GW.HandleItemButton(button, true)
    local overlay = spellFrame.OverlayFX
    if overlay then
        SetActiveBorder(overlay.OverlayActive, button.Icon)
        overlay.OverlayLocked:ClearAllPoints()
        overlay.OverlayLocked:SetAllPoints(button)
    end
    SetWhiteText(spellFrame.Label)
end

local function SkinMoneyFrame(moneyFrame)
    moneyFrame.Background:Hide()
    GW.AddDetailsBackground(moneyFrame)
    local coins = moneyFrame.Money
    local name = coins:GetName()
    for _, coin in ipairs({"Gold", "Silver", "Copper"}) do
        local button = coins[coin .. "Button"] or (name and _G[name .. coin .. "Button"])
        local text = button and (button.Text or button:GetFontString())
        if text then
            GW.StyleMoneyText(text, coin)
        end
    end
end

local function SkinOutfitCollection(collection)
    for _, key in ipairs({"Background", "GradientTop", "GradientBottom"}) do
        collection[key]:Hide()
    end
    -- the divider has a fixed height of the panel, our window ends earlier
    local divider = collection.DividerBar
    divider:ClearAllPoints()
    divider:SetPoint("TOPRIGHT", collection, "TOPRIGHT", 2, 0)
    divider:SetPoint("BOTTOM", collection:GetParent(), "BOTTOM", 0, 0)

    local list = collection.OutfitList
    list.DividerTop:SetAlpha(0)
    list.DividerBottom:SetAlpha(0)
    GW.AddDetailsBackground(list)
    GW.HandleTrimScrollBar(list.ScrollBar)
    GW.HandleScrollControls(list)
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(list.ScrollBox, list.ScrollBar)
    GW.SkinScrollBoxFrames(list.ScrollBox, SkinOutfitEntry)

    SkinEquippedGearFrame(collection.ShowEquippedGearSpellFrame)

    local purchase = collection.PurchaseOutfitButton
    purchase:GwSkinButton(false, false)
    purchase:SetHeight(BUTTON_HEIGHT)
    LockBlackFont(purchase)
    -- blizzard moves the icon on mouse down / up, only its size is ours
    purchase.Icon:SetSize(16, 16)
    purchase.Text:ClearAllPoints()
    purchase.Text:SetPoint("CENTER", purchase, "CENTER", 0, 0)

    -- without blizzards green "unsaved changes" glow, the enabled state already says it
    local save = collection.SaveOutfitButton
    SkinLightButton(save)
    if GlowEmitterFactory then
        hooksecurefunc(GlowEmitterFactory, "Show", function(factory, target)
            if target == save then
                factory:Hide(save)
            end
        end)
    end

    collection.UsableDiscountText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    SkinMoneyFrame(collection.MoneyFrame)
end

-- border atlas -> state color, looked up once per atlas name
local slotColorByAtlas = setmetatable({}, {__index = function(cache, atlas)
    local color = STATE_COLOR.default
    if atlas:find("disabled", 1, true) then
        color = STATE_COLOR.disabled
    elseif atlas:find("transmogrified", 1, true) then
        color = STATE_COLOR.applied
    end
    cache[atlas] = color
    return color
end})

-- the empty slot art is an atlas and keeps its coordinates
local function CropSlotIcon(icon)
    if not icon:GetAtlas() then
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end
end

-- blizzard sets the border atlas as highlight on every update
local function SetSlotHighlight(slot)
    slot:SetHighlightTexture(ITEM_BORDER, "ADD")
    local highlight = slot:GetHighlightTexture()
    highlight:SetTexCoord(0, 1, 0, 1)
    highlight:SetAlpha(0.33)
    highlight:ClearAllPoints()
    highlight:SetAllPoints(slot.Icon)
end

local function SetFlyoutArrow(dropdown, open)
    dropdown.gwArrow:SetTexture(open and ARROW_DOWN or ARROW_UP)
end

local function SetFlyoutHighlight(dropdown)
    local highlight = dropdown:GetHighlightTexture()
    if highlight then
        SetHighlight(highlight, dropdown)
    end
end

local function SkinFlyoutDropdown(dropdown)
    dropdown.NormalTexture:SetAlpha(0)
    dropdown.PushedTexture:SetAlpha(0)
    hooksecurefunc(dropdown, "SetHighlightAtlas", SetFlyoutHighlight)
    SetFlyoutHighlight(dropdown)

    dropdown:SetSize(ICON_SIZE, FLYOUT_HEIGHT)
    dropdown:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    dropdown.gwArrow = dropdown:CreateTexture(nil, "OVERLAY")
    dropdown.gwArrow:SetSize(12, 12)
    dropdown.gwArrow:SetPoint("CENTER")
    SetFlyoutArrow(dropdown, false)
    hooksecurefunc(dropdown, "OnMenuOpened", function(self) SetFlyoutArrow(self, true) end)
    hooksecurefunc(dropdown, "OnMenuClosed", function(self) SetFlyoutArrow(self, false) end)
end

local function SkinSlot(slot)
    slot.gwSkinned = true
    if slot.FlyoutDropdown then
        SkinFlyoutDropdown(slot.FlyoutDropdown)
    end

    slot.Border:SetAlpha(0)
    slot.gwBorder = slot:CreateTexture(nil, "BORDER", nil, 1)
    slot.gwBorder:SetTexture(ITEM_BORDER)
    slot.gwBorder:SetAllPoints(slot.Icon)

    hooksecurefunc(slot.Icon, "SetTexture", CropSlotIcon)
    CropSlotIcon(slot.Icon)

    hooksecurefunc(slot, "SetHighlightAtlas", SetSlotHighlight)
    SetSlotHighlight(slot)

    if slot.SelectedFrame then
        SetActiveBorder(slot.SelectedFrame.Border, slot.Icon)
    end
end

local function UpdateSlot(slot)
    if not slot.gwSkinned then
        SkinSlot(slot)
    end
    local color = slotColorByAtlas[slot.Border:GetAtlas() or ""]
    if slot.gwBorderColor ~= color then
        slot.gwBorderColor = color
        slot.gwBorder:SetVertexColor(color:GetRGB())
    end
end

-- blizzard hangs the enchant slots of the bottom (weapon) slots 19 into the slot, over its larger art; on
-- our smaller icons that covered the weapon, they go below the icon instead
local function PlaceBottomIllusionSlots(preview)
    for illusion in preview.CharacterIllusionSlotFramePool:EnumerateActive() do
        local point, slot = illusion:GetPoint(1)
        if point == "TOP" and slot then
            illusion:ClearAllPoints()
            illusion:SetPoint("TOP", slot, "BOTTOM", 0, ILLUSION_OFFSET)
        end
    end
end

local function SkinCharacterPreview(preview)
    preview.Background:Hide()
    preview.Gradients:Hide()
    GW.AddDetailsBackground(preview)
    preview.tex:ClearAllPoints()
    preview.tex:SetPoint("TOPLEFT", preview, "TOPLEFT", 4, 0)
    preview.tex:SetPoint("BOTTOMRIGHT", preview, "BOTTOMRIGHT", -4, 0)

    for _, key in ipairs({"HideIgnoredToggle", "SheatheWeaponToggle", "PreviewedWeaponToggle"}) do
        SkinToggle(preview.ToggleOptions[key])
    end

    -- like the zoom and rotate buttons of the model
    local clear = preview.ClearAllPendingButton
    for _, key in ipairs({"NormalTexture", "PushedTexture", "HighlightTexture"}) do
        clear[key]:SetAlpha(0)
    end
    clear:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    clear:SetSize(24, 24)
    clear.Icon:SetSize(14, 14)
    clear.Icon:SetDesaturated(true)

    GW.HandleModelSceneControlFrame(preview.ModelScene.ControlFrame)

    hooksecurefunc(TransmogAppearanceSlotMixin, "Update", UpdateSlot)
    hooksecurefunc(TransmogIllusionSlotMixin, "Update", UpdateSlot)
    hooksecurefunc(preview, "SetupSlotSection", PlaceBottomIllusionSlots)
end

-- the display type buttons keep blizzards animated art; blizzard marks the active type by its font object,
-- ours keep that in our font: white while active, grey if not
local displayTypeFonts
local function SetDisplayTypeFont(button, font)
    if not displayTypeFonts then
        local _, size = GameFontNormal:GetFont()
        local function NewFont(name, color)
            local fontObject = CreateFont(name)
            fontObject:CopyFontObject(GameFontNormal)
            fontObject:SetFont(UNIT_NAME_FONT, size, "")
            fontObject:SetTextColor(color:GetRGB())
            return fontObject
        end
        displayTypeFonts = {
            active = NewFont("GW2_TransmogDisplayTypeActive", GW.Colors.FallbackWhite),
            inactive = NewFont("GW2_TransmogDisplayTypeInactive", GW.Colors.SkinColors.SubText),
        }
    end
    if font == displayTypeFonts.active or font == displayTypeFonts.inactive then return end
    local isActive = font == "GameFontHighlight" or font == GameFontHighlight
    local wanted = isActive and displayTypeFonts.active or displayTypeFonts.inactive
    if button:GetNormalFontObject() ~= wanted then
        button:SetNormalFontObject(wanted)
    end
end

local function SkinDisplayTypeButton(button)
    hooksecurefunc(button, "SetNormalFontObject", SetDisplayTypeFont)
    SetDisplayTypeFont(button, button:GetNormalFontObject())
end

local function SkinCard(card, highlight, stateTexture)
    card.gwSkinned = true
    card:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)
    card.Border:SetAlpha(0)
    stateTexture:SetAlpha(0)
    SetHighlight(highlight, card)
    highlight:SetBlendMode("ADD")
end

-- a pending card keeps its frame, blizzards animation around it shows the state
local function SetCardState(card, stateTexture, baseColor)
    local color = baseColor
    if stateTexture:IsShown() and not card.PendingFrame:IsShown() then
        color = STATE_COLOR.applied
    end
    if card.gwStateColor ~= color then
        card.gwStateColor = color
        card.backdrop:SetBackdropBorderColor(color:GetRGB())
    end
end

local function UpdateItemCard(card)
    if not card.gwSkinned then
        SkinCard(card, card.BorderHighlight, card.StateTexture)
    end
    SetCardState(card, card.StateTexture, STATE_COLOR.default)
end

local function UpdateSetCard(card)
    if not card.gwSkinned then
        -- blizzard sets its atlas on the highlight with every update, ours is a texture of its own
        card.Highlight:SetAlpha(0)
        SkinCard(card, card:CreateTexture(nil, "HIGHLIGHT"), card.TransmogStateTexture)
    end
    SetCardState(card, card.TransmogStateTexture, card.IncompleteOverlay:IsShown() and STATE_COLOR.incomplete or STATE_COLOR.default)
end

local function HideTabArt(tab)
    for _, key in ipairs(TAB_ART_KEYS) do
        if tab[key] then
            tab[key]:SetAlpha(0)
        end
    end
end

local function SkinTab(tab)
    if tab.gwSkinned then return end
    GW.HandleTabs(tab, "top")
    HideTabArt(tab)
    if tab.SelectedHighlight then
        tab.SelectedHighlight:SetAlpha(0)
    end
    hooksecurefunc(tab, "SetTabSelected", HideTabArt)
end

local function SkinTabs(tabHeaders)
    for _, tab in ipairs({tabHeaders:GetChildren()}) do
        SkinTab(tab)
    end
end

local function SkinSituationRow(situation)
    situation.Title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    SkinDropdown(situation.Dropdown, SITUATION_DROPDOWN_WIDTH)
end

-- blizzard colors the titles and resets the toggle font on every refresh: white while enabled, grey if not
local function SkinSituationRows(frame)
    GW.SkinPoolFrames(frame.SituationFramePool, SkinSituationRow)
    local color = C_TransmogOutfitInfo.GetOutfitSituationsEnabled() and GW.Colors.FallbackWhite or GW.Colors.SkinColors.Disabled
    for situation in frame.SituationFramePool:EnumerateActive() do
        situation.Title:SetTextColor(color:GetRGB())
    end
    SetWhiteText(frame.EnabledToggle.Text)
end

local function SkinItemsFrame(items)
    SkinSearchAndFilter(items)
    SkinDropdown(items.WeaponDropdown)
    SkinDropdown(items.WeaponSheatheDropdown)
    SkinToggle(items.SecondaryAppearanceToggle)
    SkinPagingControls(items.PagedContent.PagingControls)

    local displayTypes = items.DisplayTypes
    SkinDisplayTypeButton(displayTypes.DisplayTypeUnassignedButton)
    SkinDisplayTypeButton(displayTypes.DisplayTypeEquippedButton)

    -- the weapon type in the row of the display type buttons
    local weapon = items.WeaponDropdown
    weapon:SetHeight(BUTTON_HEIGHT)
    weapon:ClearAllPoints()
    weapon:SetPoint("LEFT", displayTypes, "RIGHT", 10, 0)

    items.ActiveSlotTitle:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    items.ActiveSlotTitle:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
end

local function SkinSetsFrame(sets)
    SkinSearchAndFilter(sets)
    SkinPagingControls(sets.PagedContent.PagingControls)
    sets.PagedContent.NoEntriesText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
end

local function SkinCustomSetsFrame(customSets)
    SkinLightButton(customSets.NewCustomSetButton)
    SkinPagingControls(customSets.PagedContent.PagingControls)
    customSets.PagedContent.NoEntriesText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
end

local function SkinSituationsFrame(situations)
    situations.Situations.Background:Hide()
    situations.Situations:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    SetWhiteText(situations.DescriptionText)
    SkinLightButton(situations.DefaultsButton)
    SkinLightButton(situations.ApplyButton)
    SkinToggle(situations.EnabledToggle)

    hooksecurefunc(situations, "Init", SkinSituationRows)
    hooksecurefunc(situations, "Refresh", SkinSituationRows)
end

local function SkinWardrobeCollection(wardrobe)
    wardrobe.Background:Hide()
    local content = wardrobe.TabContent
    content.Background:Hide()
    content.Border:Hide()
    GW.AddDetailsBackground(content)

    local tabHeaders = wardrobe.TabHeaders
    SkinTabs(tabHeaders)
    hooksecurefunc(tabHeaders, "AddTab", SkinTabs)
    local _, _, _, x = tabHeaders:GetPoint(1)
    tabHeaders:ClearAllPoints()
    tabHeaders:SetPoint("BOTTOMLEFT", content, "TOPLEFT", x, 0)

    SkinItemsFrame(content.ItemsFrame)
    SkinSetsFrame(content.SetsFrame)
    SkinCustomSetsFrame(content.CustomSetsFrame)
    SkinSituationsFrame(content.SituationsFrame)

    hooksecurefunc(TransmogItemModelMixin, "UpdateItemBorder", UpdateItemCard)
    hooksecurefunc(TransmogSetModelMixin, "UpdateSet", UpdateSetCard)
    hooksecurefunc(TransmogCustomSetModelMixin, "UpdateSet", UpdateSetCard)
end

-- from the height that was set, a repeated call with the same size does not grow it again
local function GrowWindow(frame, height)
    if frame.gwGrowing then return end
    frame.gwGrowing = true
    frame:SetHeight(height + HEADER_OVERLAP)
    frame.gwGrowing = nil
end

local function SkinWindow(frame)
    GW.HandlePortraitFrame(frame)
    GW.HandlePortraitFrameArt(frame)

    local title = frame.TitleContainer and frame.TitleContainer.TitleText or TRANSMOGRIFY
    GW.CreateFrameHeaderWithBody(frame, title, WINDOW_ICON, nil, nil, false, true)
    local header = frame.gwHeader
    header.windowIcon:SetSize(48, 48)
    header.windowIcon:ClearAllPoints()
    header.windowIcon:SetPoint("CENTER", header, "BOTTOMLEFT", 30, 19)
    if header.headerText then
        header.headerText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    end
    frame:HookScript("OnShow", function()
        GW.SetHeaderPortrait(header, "npc")
    end)

    -- the frame grows by the part of blizzards panels our header would cover; addons like Plumber set
    -- blizzards size again on every show
    GrowWindow(frame, frame:GetHeight())
    hooksecurefunc(frame, "SetSize", function(self, _, height) GrowWindow(self, height) end)
    hooksecurefunc(frame, "SetHeight", GrowWindow)
    local _, _, _, x, y = frame.OutfitCollection:GetPoint(1)
    frame.OutfitCollection:ClearAllPoints()
    frame.OutfitCollection:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y - HEADER_OVERLAP)

    frame:SetClampedToScreen(true)
    frame:SetClampRectInsets(0, 0, header:GetHeight() - 20, 0)
    frame.CloseButton:ClearAllPoints()
    frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -2)

    local help = frame.HelpPlateButton
    if help then
        GW.SkinHelpIconButton(help, 20)
        help:ClearAllPoints()
        help:SetPoint("RIGHT", frame.CloseButton, "LEFT", -6, 0)
    end
end

-- Plumber: its quick access bar above the outfit list, created on the first show of the window
local function SkinPlumberQuickAccess(frame)
    for _, child in ipairs({frame:GetChildren()}) do
        if not child.gwSkinned then
            for _, button in ipairs({child:GetChildren()}) do
                if button.SetIconAndText then
                    child.gwSkinned = true
                    child:GwStripTextures()
                    -- left aligned above the equipped gear line, white like the texts around it
                    button:ClearAllPoints()
                    button:SetPoint("TOPLEFT", frame.OutfitCollection, "TOPLEFT", 16, -8)
                    button.Icon:ClearAllPoints()
                    button.Icon:SetPoint("LEFT", button, "LEFT", 0, 0)
                    SetWhiteText(button.Text)
                    button:HookScript("OnLeave", function(self)
                        self.Text:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
                    end)
                    return
                end
            end
        end
    end
end

local function SkinTransmogFrame()
    local frame = TransmogFrame
    SkinWindow(frame)
    SkinOutfitCollection(frame.OutfitCollection)
    SkinCharacterPreview(frame.CharacterPreview)
    SkinWardrobeCollection(frame.WardrobeCollection)
    frame.OutfitPopup:HookScript("OnShow", GW.HandleIconSelectionFrame)
    if C_AddOns.IsAddOnLoaded("Plumber") then
        frame:HookScript("OnShow", function()
            C_Timer.After(0, function() SkinPlumberQuickAccess(frame) end)
        end)
    end
end

local function LoadTransmogSkin()
    if not GW.settings.skins.transmog.enabled then return end
    GW.RegisterLoadHook(SkinTransmogFrame, "Blizzard_Transmog", TransmogFrame)
end
GW.LoadTransmogSkin = LoadTransmogSkin
