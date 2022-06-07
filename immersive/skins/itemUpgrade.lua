local _, GW = ...

local function Update(frame)
    if frame.upgradeInfo then
        frame.UpgradeItemButton:GetPushedTexture():SetColorTexture(0.9, 0.8, 0.1, 0.3)
    else
        frame.UpgradeItemButton:GetNormalTexture():SetInside()
    end
end

local function ApplyItemUpgradeSkin()
    if not GW.GetSetting("ITEMUPGRADE_SKIN_ENABLED") then return end
    ItemUpgradeFrameBg:Hide()
    ItemUpgradeFramePortrait:Hide()
    ItemUpgradeFramePlayerCurrenciesBorder:StripTextures()
    ItemUpgradeFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    ItemUpgradeFrame.tex = ItemUpgradeFrame:CreateTexture("bg", "BACKGROUND", nil,-7)
    local w, h = ItemUpgradeFrame:GetSize()
    ItemUpgradeFrame.tex:SetPoint("TOP", ItemUpgradeFrame, "TOP", 0, 20)
    ItemUpgradeFrame.tex:SetSize(w + 50, h + 70)
    ItemUpgradeFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    ItemUpgradeFrame.UpgradeCostFrame.BGTex:StripTextures()

    ItemUpgradeFrame.NineSlice:Hide()
    ItemUpgradeFrame.TitleBg:Hide()
    ItemUpgradeFrame.TopTileStreaks:Hide()
    ItemUpgradeFrame.BottomBG:CreateBackdrop('Transparent')
    ItemUpgradeFrame.ItemInfo.UpgradeTo:SetFontObject("GameFontHighlightMedium")

    local button = ItemUpgradeFrame.UpgradeItemButton
    button:CreateBackdrop("Transparent")
    button:StripTextures()
    button:GetNormalTexture():SetInside()

    button.icon:SetInside(button)
    GW.HandleIcon(button.icon)

    ItemUpgradeFrame.BottomBGShadow:Hide()
    ItemUpgradeFrame.BottomBG:Hide()
    ItemUpgradeFrame.TopBG:Hide()

    local holder = button.ButtonFrame
    holder:StripTextures()

    hooksecurefunc(ItemUpgradeFrame, "Update", Update)

    GW.HandleIconBorder(button.IconBorder)

    ItemUpgradeFrame.UpgradeButton:SkinButton(false, true)

    ItemUpgradeFrame.ItemInfo.Dropdown:SkinDropDownMenu()

    ItemUpgradeFrame.CloseButton:SkinButton(true)
    ItemUpgradeFrame.CloseButton:SetSize(20, 20)
end

local function LoadItemUpgradeSkin()
    GW.RegisterLoadHook(ApplyItemUpgradeSkin, "Blizzard_ItemUpgradeUI", ItemUpgradeFrame)
end
GW.LoadItemUpgradeSkin = LoadItemUpgradeSkin