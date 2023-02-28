local _, GW = ...
local GetSetting = GW.GetSetting

local function Update(frame)
    if frame.upgradeInfo then
        frame.UpgradeItemButton:GetPushedTexture():SetColorTexture(0.9, 0.8, 0.1, 0.3)
    else
        frame.UpgradeItemButton:GetNormalTexture():GwSetInside()
    end
end

local function ApplyItemUpgradeSkin()
    if not GetSetting("ITEMUPGRADE_SKIN_ENABLED") then return end
    ItemUpgradeFrameBg:Hide()
    ItemUpgradeFramePortrait:Hide()
    ItemUpgradeFramePlayerCurrenciesBorder:GwStripTextures()
    ItemUpgradeFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    ItemUpgradeFrame:GwStripTextures()

    ItemUpgradeFrame.tex = ItemUpgradeFrame:CreateTexture("bg", "BACKGROUND", nil, -7)
    local w, h = ItemUpgradeFrame:GetSize()
    ItemUpgradeFrame.tex:SetPoint("TOP", ItemUpgradeFrame, "TOP", 0, 20)
    ItemUpgradeFrame.tex:SetSize(w + 50, h + 70)
    ItemUpgradeFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    ItemUpgradeFrame.UpgradeCostFrame.BGTex:GwStripTextures()

    ItemUpgradeFrame.NineSlice:Hide()
    ItemUpgradeFrame.TopTileStreaks:Hide()
    ItemUpgradeFrame.ItemInfo.UpgradeTo:SetFontObject("GameFontHighlightMedium")

    local button = ItemUpgradeFrame.UpgradeItemButton
    button:GwCreateBackdrop("Transparent")
    button:GwStripTextures()
    button:GetNormalTexture():GwSetInside()

    button.icon:GwSetInside(button)
    GW.HandleIcon(button.icon)

    ItemUpgradeFrame.BottomBGShadow:Hide()
    ItemUpgradeFrame.BottomBG:Hide()
    ItemUpgradeFrame.TopBG:Hide()

    local holder = button.ButtonFrame
    holder:GwStripTextures()

    hooksecurefunc(ItemUpgradeFrame, "Update", Update)

    GW.HandleIconBorder(button.IconBorder)

    ItemUpgradeFrame.UpgradeButton:GwSkinButton(false, true)

    ItemUpgradeFrame.ItemInfo.Dropdown:GwSkinDropDownMenu()

    ItemUpgradeFrame.CloseButton:GwSkinButton(true)
    ItemUpgradeFrame.CloseButton:SetSize(20, 20)
end

local function LoadItemUpgradeSkin()
    GW.RegisterLoadHook(ApplyItemUpgradeSkin, "Blizzard_ItemUpgradeUI", ItemUpgradeFrame)
end
GW.LoadItemUpgradeSkin = LoadItemUpgradeSkin