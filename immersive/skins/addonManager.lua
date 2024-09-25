local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder

local function LoadAddonListSkin()
    if not GW.GetSetting("ADDONLIST_SKIN_ENABLED") then return end
    local AddonList = _G.AddonList
    GW.HandlePortraitFrame(AddonList)

    GW.CreateFrameHeaderWithBody(AddonList, AddonListTitleText, "Interface/AddOns/GW2_UI/textures/character/addon-window-icon", {AddonListScrollFrame})

    _G.AddonListBg:Hide()
    AddonList.TitleBg:Hide()
    AddonList.TopTileStreaks:Hide()
    _G.AddonListInsetInsetTopBorder:Hide()
    _G.AddonListInsetInsetBottomBorder:Hide()
    _G.AddonListInsetInsetLeftBorder:Hide()
    _G.AddonListInsetInsetRightBorder:Hide()
    _G.AddonListInsetInsetTopLeftCorner:Hide()
    _G.AddonListInsetInsetTopRightCorner:Hide()
    _G.AddonListInsetInsetBotRightCorner:Hide()
    _G.AddonListInsetInsetBotLeftCorner:Hide()
    AddonListInset:CreateBackdrop(constBackdropFrameBorder)

    AddonList.CloseButton:SkinButton(true)
    AddonList.EnableAllButton:SkinButton(false, true)
    AddonList.DisableAllButton:SkinButton(false, true)
    AddonList.OkayButton:SkinButton(false, true)
    AddonList.CancelButton:SkinButton(false, true)
    AddonList.Dropdown:GwHandleDropDownBox()
    _G.AddonListForceLoad:SkinCheckButton()
    _G.AddonListForceLoad:SetSize(18, 18)

    AddonList.CloseButton:SetSize(25, 25)
    AddonList.CloseButton:ClearAllPoints()
    AddonList.CloseButton:SetPoint("TOPRIGHT", 0, 0)

    for i = 1, _G.MAX_ADDONS_DISPLAYED do
        _G["AddonListEntry" .. i .. "Enabled"]:SkinCheckButton()
        _G["AddonListEntry" .. i .. "Enabled"]:SetHitRectInsets(0, 0, 0, 0)
        _G["AddonListEntry" .. i .. "Enabled"]:SetSize(15, 15)
        _G["AddonListEntry"  ..  i].LoadAddonButton:SkinButton(false, true)
    end

    _G.AddonListScrollFrame:SkinScrollFrame()
    _G.AddonListScrollFrameScrollBar:SkinScrollBar()

    hooksecurefunc("AddonList_Update", function()
        local numEntrys = C_AddOns.GetNumAddOns()

        for i = 1, MAX_ADDONS_DISPLAYED do
            local addonIndex = AddonList.offset + i

            if addonIndex <= numEntrys then

            local checkall
            local character = UIDropDownMenu_GetSelectedValue(AddonList.Dropdown)
            local entry = _G["AddonListEntry" .. i]
                entry.Enabled = entry.Enabled or _G["AddonListEntry" .. i .. "Enabled"]
            if character == true then
                character = nil
            else
                checkall = C_AddOns.GetAddOnEnableState(addonIndex)
            end

            entry.Reload:SetTextColor(1.0, 0.3, 0.3)

            local checkstate = C_AddOns.GetAddOnEnableState(addonIndex, character)
            local enabledForSome = not character and checkstate == 1
            local enabled = checkstate > 0
            local disabled = not enabled or enabledForSome

            if disabled then
                entry.Status:SetTextColor(0.4, 0.4, 0.4)
            else
                entry.Status:SetTextColor(0.7, 0.7, 0.7)
            end

            local checktex = entry.Enabled:GetCheckedTexture()
            if not enabled and checkall == 1 then
                checktex:SetVertexColor(0.3, 0.3, 0.3)
                checktex:SetDesaturated(true)
                checktex:Show()
            elseif not checkstate or checkstate == 0 then
                checktex:Hide()
            elseif checkstate == 1 then
                checktex:SetVertexColor(1, 0.93, 0.73)
                checktex:SetDesaturated(true)
                checktex:Show()
            elseif checkstate == 2 then
                checktex:SetVertexColor(1, 1, 1)
                checktex:SetDesaturated(false)
                checktex:Show()
            end
            end
        end
    end)
end
GW.LoadAddonListSkin = LoadAddonListSkin