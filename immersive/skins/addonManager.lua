local _, GW = ...

local function HandleAddonEntry(entry, treeNode)
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

        GW.AddListItemChildHoverTexture(entry)
        entry.IsSkinned = true
    end
    local addonIndex = treeNode:GetData().addonIndex
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
    AddonList.Dropdown:ClearAllPoints()
    AddonList.Dropdown:SetPoint("TOPLEFT", AddonList, "TOPLEFT", 12, -35)
    AddonList.ForceLoad:GwSkinCheckButton()
    AddonList.ForceLoad:SetSize(10, 10)
    AddonList.ForceLoad:ClearAllPoints()
    AddonList.ForceLoad:SetPoint("TOPRIGHT", AddonList, "TOPRIGHT", -160, -65)

    for _, region in next, { AddonList.ForceLoad:GetRegions() } do
        if region:IsObjectType("FontString") then
            region:SetTextColor(1, 1, 1)
        end
    end

    GW.SkinTextBox(AddonList.SearchBox.Middle, AddonList.SearchBox.Left, AddonList.SearchBox.Right)
    AddonList.SearchBox:ClearAllPoints()
    AddonList.SearchBox:SetPoint("TOPRIGHT", AddonList, "TOPRIGHT", -10, -38)

    AddonList.Performance.Header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

    AddonList.CloseButton:SetSize(25, 25)
    AddonList.CloseButton:ClearAllPoints()
    AddonList.CloseButton:SetPoint("TOPRIGHT", -5, 0)

    GW.HandleTrimScrollBar(AddonList.ScrollBar)
    GW.HandleScrollControls(AddonList)

    hooksecurefunc("AddonList_InitAddon", HandleAddonEntry)
    hooksecurefunc(AddonList.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
end
GW.LoadAddonListSkin = LoadAddonListSkin
