---@class GW2
local GW = select(2, ...)

local function HandleAddonEntry(entry, treeNode)
    if not entry.gwSkinned then
        entry.Enabled:GwSkinCheckButton(false, 15)
        entry.Enabled:SetHitRectInsets(0, 0, 0, 0)
        entry.LoadAddonButton:GwSkinButton(false, true)
        entry.LoadAddonButton.gwBorderFrame:Hide()

        entry.Title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        entry.Status:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        entry.Reload:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        entry.Reload:SetTextColor(GW.Colors.SkinColors.Negative:GetRGB())
        entry.LoadAddonButton.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)

        GW.AddListItemChildHoverTexture(entry)
        entry.gwSkinned = true
    end
    local state = entry.Enabled.state
    local statusColor = state == Enum.AddOnEnableState.All and GW.Colors.SkinColors.SubText or GW.Colors.SkinColors.Disabled
    entry.Status:SetTextColor(statusColor:GetRGB())
    local _, _, _, _, reason = C_AddOns.GetAddOnInfo(treeNode:GetData().addonIndex)
    local checktex = entry.Enabled:GetCheckedTexture()
    checktex:SetVertexColor(GW.Colors.FallbackWhite:GetRGB())
    checktex:SetDesaturated(false)
    checktex:SetAlpha((reason == "DEP_DISABLED" or state == Enum.AddOnEnableState.Some) and 0.4 or 1)
end

local function LoadAddonListSkin()
    if not GW.settings.skins.addonList.enabled then return end
    GW.HandlePortraitFrame(AddonList)

    GW.CreateFrameHeaderWithBody(AddonList, AddonList:GetTitleText(), "Interface/AddOns/GW2_UI/textures/character/addon-window-icon.png", {AddonList.ScrollBox}, nil, false, true)

    AddonList.CloseButton:GwSkinButton(true)
    AddonList.EnableAllButton:GwSkinButton(false, true)
    AddonList.DisableAllButton:GwSkinButton(false, true)
    AddonList.OkayButton:GwSkinButton(false, true)
    AddonList.CancelButton:GwSkinButton(false, true)
    AddonList.Dropdown:GwHandleDropDownBox()
    AddonList.Dropdown:ClearAllPoints()
    AddonList.Dropdown:SetPoint("TOPLEFT", AddonList, "TOPLEFT", 12, -35)
    AddonList.ForceLoad:GwSkinCheckButton(false, 10)
    AddonList.ForceLoad:ClearAllPoints()
    AddonList.ForceLoad:SetPoint("TOPRIGHT", AddonList, "TOPRIGHT", -160, -65)

    for _, region in next, { AddonList.ForceLoad:GetRegions() } do
        if region:IsObjectType("FontString") then
            region:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
            region:ClearAllPoints()
            region:SetPoint("LEFT", AddonList.ForceLoad, "RIGHT", 6, 0)
        end
    end

    GW.SkinEditBox(AddonList.SearchBox, {search = true})
    AddonList.SearchBox:ClearAllPoints()
    AddonList.SearchBox:SetPoint("TOPRIGHT", AddonList, "TOPRIGHT", -10, -38)

    AddonList.Performance.Header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    AddonList.CloseButton:SetSize(25, 25)
    AddonList.CloseButton:ClearAllPoints()
    AddonList.CloseButton:SetPoint("TOPRIGHT", -5, 0)

    GW.HandleTrimScrollBar(AddonList.ScrollBar)
    GW.HandleScrollControls(AddonList)

    hooksecurefunc("AddonList_InitAddon", HandleAddonEntry)
    hooksecurefunc(AddonList.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
end
GW.LoadAddonListSkin = LoadAddonListSkin
