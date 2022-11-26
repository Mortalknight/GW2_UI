local _, GW = ...

local function LoadAddonListSkin()
    if not GW.GetSetting("ADDONLIST_SKIN_ENABLED") then return end
    GW.HandlePortraitFrame(AddonList)

    GW.CreateFrameHeaderWithBody(AddonList, AddonListTitleText, "Interface/AddOns/GW2_UI/textures/character/worldmap-window-icon", {AddonList.ScrollBox})

    AddonList.CloseButton:SkinButton(true)
    AddonList.EnableAllButton:SkinButton(false, true)
    AddonList.DisableAllButton:SkinButton(false, true)
    AddonList.OkayButton:SkinButton(false, true)
    AddonList.CancelButton:SkinButton(false, true)
    AddonCharacterDropDown:SkinDropDownMenu()
    AddonListForceLoad:SkinCheckButton()
    AddonListForceLoad:SetSize(10, 10)
    AddonListForceLoad:ClearAllPoints()
    AddonListForceLoad:SetPoint("TOPRIGHT", AddonList, "TOPRIGHT", -110, -55)

    AddonList.CloseButton:SetSize(25, 25)
    AddonList.CloseButton:ClearAllPoints()
    AddonList.CloseButton:SetPoint("TOPRIGHT", -5, 0)

    GW.HandleTrimScrollBar(AddonList.ScrollBar)

    hooksecurefunc("AddonList_Update", function()
        for _, entry in next, {AddonList.ScrollBox.ScrollTarget:GetChildren()} do
            local id = entry:GetID()

            local checkall
            local character = UIDropDownMenu_GetSelectedValue(AddonCharacterDropDown)
            if character == true then
                character = nil
            else
                checkall = GetAddOnEnableState(nil, id)
            end

            entry.Reload:SetTextColor(1.0, 0.3, 0.3)

            local checkstate = GetAddOnEnableState(character, id)
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
    end)

    hooksecurefunc(AddonList.ScrollBox, "Update", function(frame)
        for _, child in next, {frame.ScrollTarget:GetChildren()} do
            if not child.IsSkinned then
                child.Enabled:SkinCheckButton()
                child.Enabled:SetSize(15, 15)
                child.Enabled:SetHitRectInsets(0, 0, 0, 0)
                child.LoadAddonButton:SkinButton(false, true)

                child.IsSkinned = true
            end
        end
    end)
end
GW.LoadAddonListSkin = LoadAddonListSkin