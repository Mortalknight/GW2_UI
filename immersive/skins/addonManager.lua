local _, GW = ...

local function HandleButton(entry, addonIndex)
    if not entry.IsSkinned then
        entry.Enabled:GwSkinCheckButton()
        entry.Enabled:SetSize(15, 15)
        entry.Enabled:SetHitRectInsets(0, 0, 0, 0)
        entry.LoadAddonButton:GwSkinButton(false, true)
        entry.LoadAddonButton.gwBorderFrame:Hide()

        entry.Title:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        entry.Status:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        entry.Reload:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        entry.Reload:SetTextColor(1.0, 0.3, 0.3)
        entry.LoadAddonButton.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)

        entry.IsSkinned = true
    end

    local checkstate = C_AddOns.GetAddOnEnableState(addonIndex)
    if checkstate == 2 then
        entry.Status:SetTextColor(0.7, 0.7, 0.7)
    else
        entry.Status:SetTextColor(0.4, 0.4, 0.4)
    end

    local _, _, _, _, reason = C_AddOns.GetAddOnInfo(addonIndex)
    local checktex = entry.Enabled:GetCheckedTexture()
    if reason == "DEP_DISABLED" then
        checktex:SetVertexColor(0.3, 0.3, 0.3)
        checktex:SetDesaturated(true)
    elseif checkstate == 1 then
        checktex:SetVertexColor(1, 0.93, 0.73)
        checktex:SetDesaturated(false)
    elseif checkstate == 2 then
        checktex:SetVertexColor(1, 1, 1)
        checktex:SetDesaturated(false)
    end

end

local function LoadAddonListSkin()
    if not GW.settings.ADDONLIST_SKIN_ENABLED then return end
    GW.HandlePortraitFrame(AddonList)

    GW.CreateFrameHeaderWithBody(AddonList, AddonListTitleText, "Interface/AddOns/GW2_UI/textures/character/addon-window-icon", {AddonList.ScrollBox}, nil, false, true)

    AddonListTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)
    AddonList.CloseButton:GwSkinButton(true)
    AddonList.EnableAllButton:GwSkinButton(false, true)
    AddonList.DisableAllButton:GwSkinButton(false, true)
    AddonList.OkayButton:GwSkinButton(false, true)
    AddonList.CancelButton:GwSkinButton(false, true)
    AddonList.Dropdown:GwHandleDropDownBox()
    AddonListForceLoad:GwSkinCheckButton()
    AddonListForceLoad:SetSize(10, 10)
    AddonListForceLoad:ClearAllPoints()
    AddonListForceLoad:SetPoint("TOPRIGHT", AddonList, "TOPRIGHT", -110, -55)

    AddonList.CloseButton:SetSize(25, 25)
    AddonList.CloseButton:ClearAllPoints()
    AddonList.CloseButton:SetPoint("TOPRIGHT", -5, 0)

    GW.HandleTrimScrollBar(AddonList.ScrollBar)
    GW.HandleScrollControls(AddonList)

    hooksecurefunc("AddonList_InitButton", HandleButton)
end
GW.LoadAddonListSkin = LoadAddonListSkin
