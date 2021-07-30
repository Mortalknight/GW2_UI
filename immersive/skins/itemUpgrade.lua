local _, GW = ...

local function ApplyItemUpgradeSkin()
    if not GW.GetSetting("ITEMUPGRADE_SKIN_ENABLED") then return end

    local ItemUpgradeFrame = _G.ItemUpgradeFrame
    _G.ItemUpgradeFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    ItemUpgradeFrame:StripTextures()
    ItemUpgradeFrame.tex = ItemUpgradeFrame:CreateTexture("bg", "BACKGROUND", nil, 0)
    local w, h = ItemUpgradeFrame:GetSize()
    ItemUpgradeFrame.tex:SetPoint("TOP", ItemUpgradeFrame, "TOP", 0, 20)
    ItemUpgradeFrame.tex:SetSize(w + 50, h + 70)
    ItemUpgradeFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")

    ItemUpgradeFrame.CloseButton:SkinButton(true)
    ItemUpgradeFrame.CloseButton:SetSize(20, 20)

    local TextFrame = ItemUpgradeFrame.TextFrame
    TextFrame:StripTextures()
    TextFrame:CreateBackdrop(GW.skins.constBackdropFrame)
    TextFrame.backdrop:SetPoint("TOPLEFT", ItemUpgradeFrame.ItemButton.IconTexture, "TOPRIGHT", 3, 1)
    TextFrame.backdrop:SetPoint("BOTTOMRIGHT", -6, 2)

    _G.ItemUpgradeFrameMoneyFrame:StripTextures()
    _G.ItemUpgradeFrameMoneyFrame.Currency.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    _G.ItemUpgradeFrameUpgradeButton:SkinButton(false, true)
    ItemUpgradeFrame.FinishedGlow:Kill()
    ItemUpgradeFrame.ButtonFrame:DisableDrawLayer("BORDER")
end

local function LoadItemUpgradeSkin()
    GW.RegisterSkin("Blizzard_ItemUpgradeUI", function() ApplyItemUpgradeSkin() end)
end
GW.LoadItemUpgradeSkin = LoadItemUpgradeSkin