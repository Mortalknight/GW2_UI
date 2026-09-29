---@class GW2
local GW = select(2, ...)

local BACKGROUND = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png"
local EMPTY_SLOT_COLOR = CreateColor(0.35, 0.35, 0.35)
local FLYOUT_PADDING = 5

local function FitSlotArt(frame)
    local button = frame.UpgradeItemButton
    button:GetNormalTexture():GwSetInside()
    button:GetPushedTexture():SetColorTexture(GW.Colors.SkinColors.HeaderBorder:GetRGBA())
end
local skinnedFlyoutButtons = setmetatable({}, {__mode = "k"})

local function SkinFlyoutButton(button)
    button:GetNormalTexture():SetAlpha(0)
    button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true, 1, 1)
    GW.HandleIconBorder(button.IconBorder, button.backdrop, EMPTY_SLOT_COLOR)
end

local function SkinFlyout()
    local flyout = EquipmentFlyoutFrame
    local buttonFrame = flyout.buttonFrame
    for i = 1, buttonFrame.numBGs or 0 do
        buttonFrame["bg" .. i]:SetAlpha(0)
    end
    flyout.NavigationFrame.BottomBackground:SetAlpha(0)
    if not buttonFrame.backdrop then
        buttonFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    end

    local shown = flyout.numItemButtons or 0
    if shown > 0 then
        local columns = math.min(shown, EQUIPMENTFLYOUT_ITEMS_PER_ROW)
        local rows = math.ceil(shown / EQUIPMENTFLYOUT_ITEMS_PER_ROW)
        local backdrop = buttonFrame.backdrop
        backdrop:ClearAllPoints()
        backdrop:SetPoint("TOPLEFT", flyout.buttons[1], "TOPLEFT", -FLYOUT_PADDING, FLYOUT_PADDING)
        backdrop:SetSize(columns * (EFITEM_WIDTH + EFITEM_XOFFSET) - EFITEM_XOFFSET + 2 * FLYOUT_PADDING,
            rows * (EFITEM_HEIGHT - EFITEM_YOFFSET) + EFITEM_YOFFSET + 2 * FLYOUT_PADDING)
    end

    for _, button in ipairs(flyout.buttons) do
        if not skinnedFlyoutButtons[button] then
            skinnedFlyoutButtons[button] = true
            SkinFlyoutButton(button)
        end
    end
end

local function ApplyItemUpgradeSkin()
    if not GW.settings.skins.itemUpgrade.enabled then return end
    local frame = ItemUpgradeFrame

    frame:GwStripTextures()
    for _, art in ipairs({ItemUpgradeFrameBg, ItemUpgradeFramePortrait, frame.NineSlice, frame.TopTileStreaks, frame.TopBG, frame.BottomBG, frame.BottomBGShadow}) do
        art:Hide()
    end
    for _, art in ipairs({ItemUpgradeFramePlayerCurrenciesBorder, frame.UpgradeCostFrame.BGTex}) do
        art:GwStripTextures()
    end

    local width, height = frame:GetSize()
    frame.tex = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    frame.tex:SetPoint("TOP", frame, "TOP", 0, 20)
    frame.tex:SetSize(width + 50, height + 70)
    frame.tex:SetTexture(BACKGROUND)

    ItemUpgradeFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, "OUTLINE", 2)
    ItemUpgradeFrameTitleText:GwLockTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    frame.ItemInfo.UpgradeTo:SetFontObject("GameFontHighlightMedium")
    frame.ItemInfo.Dropdown:GwHandleDropDownBox()

    -- the item slot: a dark frame, the icon inside it, the quality on our border, grey while empty
    local slot = frame.UpgradeItemButton
    slot:GwStripTextures()
    slot.ButtonFrame:GwStripTextures()
    slot:GwCreateBackdrop("Transparent")
    slot.icon:GwSetInside(slot)
    GW.HandleIcon(slot.icon)
    GW.HandleIconBorder(slot.IconBorder, nil, EMPTY_SLOT_COLOR)
    FitSlotArt(frame)
    hooksecurefunc(frame, "UpdateUpgradeItemInfo", FitSlotArt)

    -- the current and the upgraded item side by side, in our tooltip look
    for _, preview in ipairs({frame.LeftItemPreviewFrame, frame.RightItemPreviewFrame}) do
        GW.Tooltip.SetStyle(preview)
    end

    -- runs on show and on every page change
    hooksecurefunc("EquipmentFlyout_UpdateItems", SkinFlyout)

    frame.UpgradeButton:GwSkinButton(false, true)
    frame.CloseButton:GwSkinButton(true)
    frame.CloseButton:SetSize(20, 20)
end

local function LoadItemUpgradeSkin()
    GW.RegisterLoadHook(ApplyItemUpgradeSkin, "Blizzard_ItemUpgradeUI", ItemUpgradeFrame)
end
GW.LoadItemUpgradeSkin = LoadItemUpgradeSkin
