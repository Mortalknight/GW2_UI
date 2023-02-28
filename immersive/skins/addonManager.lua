local _, GW = ...

local function SkinAddonList()
    if not GW.GetSetting("ADDONLIST_SKIN_ENABLED") then return end

    GW.HandlePortraitFrame(AddonList)

    GW.CreateFrameHeaderWithBody(AddonList, AddonListTitleText, "Interface/AddOns/GW2_UI/textures/character/addon-window-icon", {AddonList.ScrollBox})

    AddonList.CloseButton:GwSkinButton(true)
    AddonList.EnableAllButton:GwSkinButton(false, true)
    AddonList.DisableAllButton:GwSkinButton(false, true)
    AddonList.OkayButton:GwSkinButton(false, true)
    AddonList.CancelButton:GwSkinButton(false, true)
    AddonCharacterDropDown:GwSkinDropDownMenu()
    AddonListForceLoad:GwSkinCheckButton()
    AddonListForceLoad:SetSize(10, 10)
    AddonListForceLoad:ClearAllPoints()
    AddonListForceLoad:SetPoint("TOPRIGHT", AddonList, "TOPRIGHT", -110, -55)

    AddonList.CloseButton:SetSize(25, 25)
    AddonList.CloseButton:ClearAllPoints()
    AddonList.CloseButton:SetPoint("TOPRIGHT", -5, 0)

    for i = 1, _G.MAX_ADDONS_DISPLAYED do
        _G["AddonListEntry" .. i .. "Enabled"]:GwSkinCheckButton()
        _G["AddonListEntry" .. i .. "Enabled"]:SetHitRectInsets(0, 0, 0, 0)
        _G["AddonListEntry" .. i .. "Enabled"]:SetSize(15, 15)
        _G["AddonListEntry"  ..  i].LoadAddonButton:GwSkinButton(false, true)
    end

    AddonListScrollFrame:GwSkinScrollFrame()
    AddonListScrollFrameScrollBar:GwSkinScrollBar()

    hooksecurefunc("AddonList_Update", function()
        local numEntrys = GetNumAddOns()

        for i = 1, MAX_ADDONS_DISPLAYED do
            local addonIndex = AddonList.offset + i

            if addonIndex <= numEntrys then

            local checkall
            local character = UIDropDownMenu_GetSelectedValue(AddonCharacterDropDown)
            local entry = _G["AddonListEntry" .. i]
                entry.Enabled = entry.Enabled or _G["AddonListEntry" .. i .. "Enabled"]
            if character == true then
                character = nil
            else
                checkall = GetAddOnEnableState(nil, addonIndex)
            end

            entry.Reload:SetTextColor(1.0, 0.3, 0.3)

            local checkstate = GetAddOnEnableState(character, addonIndex)
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
GW.SkinAddonList = SkinAddonList