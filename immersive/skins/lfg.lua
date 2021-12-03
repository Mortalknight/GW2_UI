local _, GW = ...

local function HandleGoldIcon(button)
    local Button = _G[button]
    if Button.backdrop then return end

    local count = _G[button.."Count"]
    local nameFrame = _G[button.."NameFrame"]
    local iconTexture = _G[button.."IconTexture"]

    Button:CreateBackdrop()
    Button.backdrop:ClearAllPoints()
    Button.backdrop:SetPoint("LEFT", 1, 0)
    Button.backdrop:SetSize(42, 42)

    iconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    iconTexture:SetDrawLayer("OVERLAY")
    iconTexture:SetParent(Button.backdrop)
    iconTexture:SetInside()

    count:SetParent(Button.backdrop)
    count:SetDrawLayer("OVERLAY")

    nameFrame:SetTexture()
    nameFrame:SetSize(118, 39)
end

local function SkinItemButton(parentFrame, _, index)
    local parentName = parentFrame:GetName()
    local item = _G[parentName .. "Item" .. index]
    if item and not item.backdrop then
        item:CreateBackdrop()
        item.backdrop:ClearAllPoints()
        item.backdrop:SetPoint("LEFT", 1, 0)
        item.backdrop:SetSize(42, 42)

        item.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        item.Icon:SetDrawLayer("OVERLAY")
        item.Icon:SetParent(item.backdrop)
        item.Icon:SetInside()

        item.Count:SetDrawLayer("OVERLAY")
        item.Count:SetParent(item.backdrop)

        item.NameFrame:SetTexture()
        item.NameFrame:SetSize(118, 39)

        item.shortageBorder:SetTexture()

        item.roleIcon1:SetParent(item.backdrop)
        item.roleIcon2:SetParent(item.backdrop)

        GW.HandleIconBorder(item.IconBorder)
    end
end

local function HandleAffixIcons(self)
    local MapID, _, PowerLevel = C_ChallengeMode.GetSlottedKeystoneInfo()

    if MapID then
        local Name = C_ChallengeMode.GetMapUIInfo(MapID)

        if Name and PowerLevel then
            self.DungeonName:SetText(Name .. "|cffffffff - |r" .. "(" .. PowerLevel .. ")")
        end

        self.PowerLevel:SetText("")
    end

    for _, frame in ipairs(self.Affixes) do
        frame.Border:SetTexture()
        frame.Portrait:SetTexture()

        if frame.info then
            frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
        elseif frame.affixID then
            local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
            frame.Portrait:SetTexture(filedataid)
        end

        GW.HandleIcon(frame.Portrait, true)

        frame.Percent:SetFont(DAMAGE_TEXT_FONT, 16, "OUTLINE")
    end
end

local function SkinLookingForGroupFrames()
    if not GW.GetSetting("LFG_SKIN_ENABLED") then return end

    GW.HandlePortraitFrame(PVEFrame, true)

    RaidFinderQueueFrame:StripTextures(true)
    PVEFrameBg:Hide()
    PVEFrame.shadows:Kill()

    LFDQueueFramePartyBackfillBackfillButton:SkinButton(false, true)
    LFDQueueFramePartyBackfillNoBackfillButton:SkinButton(false, true)

    GroupFinderFrame.groupButton1.icon:SetTexture(133076) -- interface/icons/inv_helmet_08.blp
    GroupFinderFrame.groupButton2.icon:SetTexture(133074) -- interface/icons/inv_helmet_06.blp
    GroupFinderFrame.groupButton3.icon:SetTexture(464820) -- interface/icons/achievement_general_stayclassy.blp


    LFDQueueFrame:StripTextures(true)
    LFDQueueFrameRoleButtonTankIncentiveIcon:SetAlpha(0)
    LFDQueueFrameRoleButtonHealerIncentiveIcon:SetAlpha(0)
    LFDQueueFrameRoleButtonDPSIncentiveIcon:SetAlpha(0)
    LFDQueueFrameRoleButtonTank.shortageBorder:Kill()
    LFDQueueFrameRoleButtonDPS.shortageBorder:Kill()
    LFDQueueFrameRoleButtonHealer.shortageBorder:Kill()
    LFGDungeonReadyStatusCloseButton:SkinButton(true)

    local RoleButtons1 = {
        _G.LFDQueueFrameRoleButtonHealer,
        _G.LFDQueueFrameRoleButtonDPS,
        _G.LFDQueueFrameRoleButtonLeader,
        _G.LFDQueueFrameRoleButtonTank,
        _G.RaidFinderQueueFrameRoleButtonHealer,
        _G.RaidFinderQueueFrameRoleButtonDPS,
        _G.RaidFinderQueueFrameRoleButtonLeader,
        _G.RaidFinderQueueFrameRoleButtonTank,
        _G.RolePollPopupRoleButtonTank,
        _G.RolePollPopupRoleButtonHealer,
        _G.RolePollPopupRoleButtonDPS,
    }

    for _, roleButton in pairs(RoleButtons1) do
        local checkButton = roleButton.checkButton or roleButton.CheckButton
        checkButton:SkinCheckButton()
        checkButton:SetSize(15, 15)
    end

    hooksecurefunc("SetCheckButtonIsRadio", function(self)
        self:SkinCheckButton()
        self:SetSize(15, 15)
    end)

    local repositionCheckButtons = {
        LFGListApplicationDialog.TankButton.CheckButton,
        LFGListApplicationDialog.HealerButton.CheckButton,
        LFGListApplicationDialog.DamagerButton.CheckButton,
    }
    for _, checkButton in pairs(repositionCheckButtons) do
        checkButton:ClearAllPoints()
        checkButton:SetPoint("BOTTOMLEFT", 0, 0)
    end

    hooksecurefunc("LFGListApplicationDialog_UpdateRoles", function(dialog) --Copy from Blizzard, we just fix position
        local availTank, availHealer, availDPS = C_LFGList.GetAvailableRoles()

        local avail1, avail2
        if availTank then
            avail1 = dialog.TankButton
        end
        if availHealer then
            if avail1 then
                avail2 = dialog.HealerButton
            else
                avail1 = dialog.HealerButton
            end
        end
        if availDPS then
            if avail1 then
                avail2 = dialog.DamagerButton
            else
                avail1 = dialog.DamagerButton
            end
        end

        if avail2 then
            avail1:ClearAllPoints()
            avail1:SetPoint("TOPRIGHT", dialog, "TOP", -40, -35)
            avail2:ClearAllPoints()
            avail2:SetPoint("TOPLEFT", dialog, "TOP", 40, -35)
        elseif avail1 then
            avail1:ClearAllPoints()
            avail1:SetPoint("TOP", dialog, "TOP", 0, -35)
        end
    end)

    hooksecurefunc("LFG_DisableRoleButton", function(button)
        if button.checkButton:GetChecked() then
            button.checkButton:SetAlpha(1)
        else
            button.checkButton:SetAlpha(0)
        end

        if button.background then
            button.background:Show()
        end
    end)

    hooksecurefunc("LFG_EnableRoleButton", function(button)
        button.checkButton:SetAlpha(1)
    end)

    hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(button)
        if button.background then
            button.background:Show()
            button.background:SetDesaturated(true)
        end
    end)

    for i = 1, 3 do
        local bu = GroupFinderFrame["groupButton" .. i]
        bu.ring:Kill()
        bu.bg:Kill()
        bu:SkinButton(false, true)

        bu.icon:SetSize(45, 45)
        bu.icon:ClearAllPoints()
        bu.icon:SetPoint("LEFT", 10, 0)
        GW.HandleIcon(bu.icon)
        bu.icon:SetDrawLayer("OVERLAY")
    end
    hooksecurefunc("GroupFinderFrame_SelectGroupButton", function(idx)
        for i = 1, 3 do
            local bu = GroupFinderFrame["groupButton" .. i]
            if i == idx then
                bu.hover.skipHover = true
                bu.hover:SetAlpha(1)
                bu.hover:SetPoint("RIGHT", bu, "LEFT", bu:GetWidth(), 0)
            else
                bu.hover.skipHover = false
                bu.hover:SetAlpha(1)
                bu.hover:SetPoint("RIGHT", bu, "LEFT", 0, 0)
            end

        end
    end)

    for i = 1, 3 do
        _G["PVEFrameTab"..i]:SkinButton(false, true)
    end
    PVEFrameTab1:SetPoint("BOTTOMLEFT", PVEFrame, "BOTTOMLEFT", 19, -50)
    PVEFrameTab2:SetPoint("LEFT", PVEFrameTab1, "RIGHT", 1, 0)
    PVEFrameTab3:SetPoint("LEFT", PVEFrameTab2, "RIGHT", 1, 0)

    -- Raid finder
    LFDQueueFrameFindGroupButton:SkinButton(false, true)

    LFDParentFrame:StripTextures()
    LFDParentFrameInset:StripTextures()

    HandleGoldIcon("LFDQueueFrameRandomScrollFrameChildFrameMoneyReward")
    HandleGoldIcon("RaidFinderQueueFrameScrollFrameChildFrameMoneyReward")

    for i = 1, NUM_LFD_CHOICE_BUTTONS do
        _G["LFDQueueFrameSpecificListButton"..i].enableButton:SkinCheckButton()
        _G["LFDQueueFrameSpecificListButton"..i].enableButton:SetSize(15, 15)
    end

    hooksecurefunc("LFGDungeonListButton_SetDungeon", function(button)
        if button and button.expandOrCollapseButton:IsShown() then
            if button.isCollapsed then
                button.expandOrCollapseButton:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrow_right")
            else
                button.expandOrCollapseButton:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
            end
        end
    end)

    for i = 1, NUM_LFR_CHOICE_BUTTONS do
        local bu = _G["LFRQueueFrameSpecificListButton"..i].enableButton
        bu:SkinCheckButton()
        bu:SetSize(15, 15)
    end

    LFDQueueFrameTypeDropDown:SkinDropDownMenu()

    RaidFinderFrame:StripTextures()
    RaidFinderFrameRoleInset:StripTextures()
    RaidFinderQueueFrameSelectionDropDown:SkinDropDownMenu()
    RaidFinderFrameFindRaidButton:StripTextures()
    RaidFinderFrameFindRaidButton:SkinButton(false, true)
    RaidFinderQueueFrame:StripTextures()
    RaidFinderQueueFrameScrollFrameScrollBar:StripTextures()
    RaidFinderQueueFrameScrollFrame:SkinScrollFrame()
    RaidFinderQueueFrameScrollFrameScrollBar:SkinScrollBar()

    --Skin Reward Items (This works for all frames, LFD, Raid, Scenario)
    hooksecurefunc("LFGRewardsFrame_SetItemButton", SkinItemButton)

    -- Looking for raid
    LFRBrowseFrameListScrollFrame:StripTextures()

    LFRBrowseFrame:HookScript("OnShow", function()
        if not LFRBrowseFrameListScrollFrameScrollBar.skinned then
            LFRBrowseFrameListScrollFrame:SkinScrollFrame()
            LFRBrowseFrameListScrollFrameScrollBar:SkinScrollBar()
            LFRBrowseFrameListScrollFrameScrollBar.skinned = true
        end
    end)

    LFRBrowseFrameRoleInset:DisableDrawLayer("BORDER")
    LFRQueueFrameSpecificListScrollFrameScrollBackgroundTopLeft:Hide()
    LFRQueueFrameSpecificListScrollFrameScrollBackgroundBottomRight:Hide()
    LFRBrowseFrameColumnHeader1:SetWidth(94)
    LFRBrowseFrameColumnHeader2:SetWidth(38)

    LFRQueueFrameFindGroupButton:SkinButton(false, true)
    LFRQueueFrameAcceptCommentButton:SkinButton(false, true)

    LFRQueueFrameCommentScrollFrame:SkinScrollFrame()
    LFRQueueFrameCommentScrollFrameScrollBar:SkinScrollBar()
    LFDQueueFrameSpecificListScrollFrame:SkinScrollFrame()
    LFDQueueFrameSpecificListScrollFrameScrollBar:SkinScrollBar()
    LFDQueueFrameSpecificListScrollFrame:StripTextures()

    _G[_G.LFDQueueFrame.PartyBackfill:GetName().."BackfillButton"]:SkinButton(false, true)
    _G[_G.LFDQueueFrame.PartyBackfill:GetName().."NoBackfillButton"]:SkinButton(false, true)
    _G[_G.RaidFinderQueueFrame.PartyBackfill:GetName().."BackfillButton"]:SkinButton(false, true)
    _G[_G.RaidFinderQueueFrame.PartyBackfill:GetName().."NoBackfillButton"]:SkinButton(false, true)
    LFDQueueFrameRandomScrollFrameScrollBar:StripTextures()
    LFDQueueFrameRandomScrollFrameScrollBar:SkinScrollBar()
    LFDQueueFrameRandomScrollFrame:SkinScrollFrame()

    --LFGListFrame
    LFGListFrame.CategorySelection.Inset:StripTextures()
    LFGListFrame.CategorySelection.StartGroupButton:SkinButton(false, true)
    LFGListFrame.CategorySelection.StartGroupButton:ClearAllPoints()
    LFGListFrame.CategorySelection.StartGroupButton:SetPoint("BOTTOMLEFT", -1, 3)
    LFGListFrame.CategorySelection.FindGroupButton:SkinButton(false, true)
    LFGListFrame.CategorySelection.FindGroupButton:ClearAllPoints()
    LFGListFrame.CategorySelection.FindGroupButton:SetPoint("BOTTOMRIGHT", -6, 3)

    LFGListFrame.EntryCreation.Inset:StripTextures()
    LFGListFrame.EntryCreation.CancelButton:SkinButton(false, true)
    LFGListFrame.EntryCreation.ListGroupButton:SkinButton(false, true)
    LFGListFrame.EntryCreation.CancelButton:ClearAllPoints()
    LFGListFrame.EntryCreation.CancelButton:SetPoint("BOTTOMLEFT", -1, 3)
    LFGListFrame.EntryCreation.ListGroupButton:ClearAllPoints()
    LFGListFrame.EntryCreation.ListGroupButton:SetPoint("BOTTOMRIGHT", -6, 3)
    LFGListFrame.EntryCreation.Description:CreateBackdrop(GW.skins.constBackdropFrame, true, 5, 5)
    GW.HandleBlizzardRegions(LFGListFrame.EntryCreation.Description)

    LFGListFrame.EntryCreation.ItemLevel.EditBox:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true, 4)
    GW.HandleBlizzardRegions(LFGListFrame.EntryCreation.ItemLevel.EditBox)
    LFGListFrame.EntryCreation.MythicPlusRating.EditBox:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true, 4)
    GW.HandleBlizzardRegions(LFGListFrame.EntryCreation.MythicPlusRating.EditBox)
    LFGListFrame.EntryCreation.Name:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true, 4)
    GW.HandleBlizzardRegions(LFGListFrame.EntryCreation.Name)
    LFGListFrame.EntryCreation.PVPRating.EditBox:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true, 4)
    GW.HandleBlizzardRegions(LFGListFrame.EntryCreation.PVPRating.EditBox)
    LFGListFrame.EntryCreation.PvpItemLevel.EditBox:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true, 4)
    GW.HandleBlizzardRegions(LFGListFrame.EntryCreation.PvpItemLevel.EditBox)
    LFGListFrame.EntryCreation.VoiceChat.EditBox:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true, 4)
    GW.HandleBlizzardRegions(LFGListFrame.EntryCreation.VoiceChat.EditBox)

    LFGListEntryCreationActivityDropDown:SkinDropDownMenu()
    LFGListEntryCreationGroupDropDown:SkinDropDownMenu()
    LFGListEntryCreationPlayStyleDropdown:SkinDropDownMenu()

    LFGListFrame.EntryCreation.ItemLevel.CheckButton:SkinCheckButton()
    LFGListFrame.EntryCreation.MythicPlusRating.CheckButton:SkinCheckButton()
    LFGListFrame.EntryCreation.PrivateGroup.CheckButton:SkinCheckButton()
    LFGListFrame.EntryCreation.PVPRating.CheckButton:SkinCheckButton()
    LFGListFrame.EntryCreation.PvpItemLevel.CheckButton:SkinCheckButton()
    LFGListFrame.EntryCreation.VoiceChat.CheckButton:SkinCheckButton()

    LFGListFrame.EntryCreation.ItemLevel.CheckButton:SetSize(15, 15)
    LFGListFrame.EntryCreation.MythicPlusRating.CheckButton:SetSize(15, 15)
    LFGListFrame.EntryCreation.PrivateGroup.CheckButton:SetSize(15, 15)
    LFGListFrame.EntryCreation.PVPRating.CheckButton:SetSize(15, 15)
    LFGListFrame.EntryCreation.PvpItemLevel.CheckButton:SetSize(15, 15)
    LFGListFrame.EntryCreation.VoiceChat.CheckButton:SetSize(15, 15)

    LFGListFrame.EntryCreation.ActivityFinder.Dialog:StripTextures()
    LFGListFrame.EntryCreation.ActivityFinder.Dialog.BorderFrame:StripTextures()

    LFGListFrame.EntryCreation.ActivityFinder.Dialog.EntryBox:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true, 4)
    GW.HandleBlizzardRegions(LFGListFrame.EntryCreation.ActivityFinder.Dialog.EntryBox)
    LFGListEntryCreationSearchScrollFrameScrollBar:SkinScrollBar()
    LFGListEntryCreationSearchScrollFrame:SkinScrollFrame()
    LFGListFrame.EntryCreation.ActivityFinder.Dialog.SelectButton:SkinButton(false, true)
    LFGListFrame.EntryCreation.ActivityFinder.Dialog.CancelButton:SkinButton(false, true)

    LFGListApplicationDialog:StripTextures()
    LFGListApplicationDialog.SignUpButton:SkinButton(false, true)
    LFGListApplicationDialog.CancelButton:SkinButton(false, true)
    LFGListApplicationDialogDescription:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true, 4)
    GW.HandleBlizzardRegions(LFGListApplicationDialogDescription)

    LFGListInviteDialog:StripTextures()
    LFGListInviteDialog.AcknowledgeButton:SkinButton(false, true)
    LFGListInviteDialog.AcceptButton:SkinButton(false, true)
    LFGListInviteDialog.DeclineButton:SkinButton(false, true)

    LFGListFrame.SearchPanel.SearchBox:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true, 4)
    GW.HandleBlizzardRegions(LFGListFrame.SearchPanel.SearchBox)
    LFGListFrame.SearchPanel.BackButton:SkinButton(false, true)
    LFGListFrame.SearchPanel.SignUpButton:SkinButton(false, true)
    LFGListSearchPanelScrollFrameScrollChild.StartGroupButton:SkinButton(false, true)
    LFGListFrame.SearchPanel.BackButton:ClearAllPoints()
    LFGListFrame.SearchPanel.BackButton:SetPoint("BOTTOMLEFT", -1, 3)
    LFGListFrame.SearchPanel.SignUpButton:ClearAllPoints()
    LFGListFrame.SearchPanel.SignUpButton:SetPoint("BOTTOMRIGHT", -6, 3)
    LFGListFrame.SearchPanel.ResultsInset:StripTextures()
    LFGListSearchPanelScrollFrameScrollBar:SkinScrollBar()
    LFGListSearchPanelScrollFrame:SkinScrollFrame()

    if not LFGListFrame.SearchPanel.ResultsInset.SetBackdrop then
        _G.Mixin(LFGListFrame.SearchPanel.ResultsInset, _G.BackdropTemplateMixin)
        LFGListFrame.SearchPanel.ResultsInset:HookScript("OnSizeChanged", LFGListFrame.SearchPanel.ResultsInset.OnBackdropSizeChanged)
    end
    LFGListFrame.SearchPanel.ResultsInset:SetBackdrop(GW.constBackdropFrameColorBorder)
    LFGListFrame.SearchPanel.ResultsInset:SetBackdropBorderColor(0, 0, 0, 1)

    LFGListFrame.SearchPanel.FilterButton:SkinButton(false, true)
    LFGListFrame.SearchPanel.FilterButton:SetPoint("LEFT", LFGListFrame.SearchPanel.SearchBox, "RIGHT", 5, 0)
    LFGListFrame.SearchPanel.FilterButton.Icon:SetDesaturated(true)
    LFGListFrame.SearchPanel.RefreshButton:SkinButton(false, true)
    LFGListFrame.SearchPanel.BackToGroupButton:SkinButton(false, true)
    LFGListFrame.SearchPanel.RefreshButton:SetSize(24, 24)
    LFGListFrame.SearchPanel.RefreshButton.Icon:SetDesaturated(true)
    LFGListFrame.SearchPanel.RefreshButton.Icon:SetPoint("CENTER")

    hooksecurefunc("LFGListApplicationViewer_UpdateApplicant", function(button)
        if not button.DeclineButton.template then
            button.DeclineButton:SkinButton(false, true)
        end
        if not button.InviteButton.template then
            button.InviteButton:SkinButton(false, true)
        end
        if not button.InviteButtonSmall.template then
            button.InviteButtonSmall:SkinButton(false, true)
        end
    end)

    hooksecurefunc("LFGListSearchEntry_Update", function(button)
        if not button.CancelButton.template then
            button.CancelButton:SkinButton(true)
            button.CancelButton:SetSize(18, 18)
        end
    end)

    hooksecurefunc("LFGListSearchPanel_UpdateAutoComplete", function(panel)
        for i = 1, LFGListFrame.SearchPanel.AutoCompleteFrame:GetNumChildren() do
            local child = select(i, LFGListFrame.SearchPanel.AutoCompleteFrame:GetChildren())
            if child and not child.isSkinned and child:IsObjectType("Button") then
                child:SkinButton(false, true)
                child.isSkinned = true
            end
        end

        local matchingActivities = C_LFGList.GetAvailableActivities(panel.categoryID, nil, panel.filters, panel.SearchBox:GetText())
        local numResults = min(#matchingActivities, MAX_LFG_LIST_SEARCH_AUTOCOMPLETE_ENTRIES)

        for i = 2, numResults do
            local button = panel.AutoCompleteFrame.Results[i]
            if button and not button.moved then
                button:SetPoint("TOPLEFT", panel.AutoCompleteFrame.Results[i-1], "BOTTOMLEFT", 0, -2)
                button:SetPoint("TOPRIGHT", panel.AutoCompleteFrame.Results[i-1], "BOTTOMRIGHT", 0, -2)
                button.moved = true
            end
        end
        panel.AutoCompleteFrame:SetHeight(numResults * (panel.AutoCompleteFrame.Results[1]:GetHeight() + 3.5) + 8)
    end)

    LFGListFrame.SearchPanel.AutoCompleteFrame:StripTextures()
    LFGListFrame.SearchPanel.AutoCompleteFrame:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
    LFGListFrame.SearchPanel.AutoCompleteFrame.backdrop:SetPoint("TOPLEFT", LFGListFrame.SearchPanel.AutoCompleteFrame, "TOPLEFT", 0, 3)
    LFGListFrame.SearchPanel.AutoCompleteFrame.backdrop:SetPoint("BOTTOMRIGHT", LFGListFrame.SearchPanel.AutoCompleteFrame, "BOTTOMRIGHT", 6, 3)

    LFGListFrame.SearchPanel.AutoCompleteFrame:SetPoint("TOPLEFT", LFGListFrame.SearchPanel.SearchBox, "BOTTOMLEFT", -2, -8)
    LFGListFrame.SearchPanel.AutoCompleteFrame:SetPoint("TOPRIGHT", LFGListFrame.SearchPanel.SearchBox, "BOTTOMRIGHT", -4, -8)

    --ApplicationViewer (Custom Groups)
    LFGListFrame.ApplicationViewer.InfoBackground:Hide()
    LFGListFrame.ApplicationViewer.InfoBackground:CreateBackdrop("Transparent")
    LFGListFrame.ApplicationViewer.AutoAcceptButton:SkinCheckButton()

    LFGListFrame.ApplicationViewer.Inset:StripTextures()
    if not LFGListFrame.ApplicationViewer.Inset.SetBackdrop then
        _G.Mixin(LFGListFrame.ApplicationViewer.Inset, _G.BackdropTemplateMixin)
        LFGListFrame.ApplicationViewer.Inset:HookScript("OnSizeChanged", LFGListFrame.ApplicationViewer.Inset.OnBackdropSizeChanged)
    end
    LFGListFrame.ApplicationViewer.Inset:SetBackdrop(GW.constBackdropFrameColorBorder)
    LFGListFrame.ApplicationViewer.Inset:SetBackdropBorderColor(0, 0, 0, 1)

    LFGListFrame.ApplicationViewer.NameColumnHeader:SkinButton(false, true)
    LFGListFrame.ApplicationViewer.RoleColumnHeader:SkinButton(false, true)
    LFGListFrame.ApplicationViewer.ItemLevelColumnHeader:SkinButton(false, true)
    LFGListFrame.ApplicationViewer.RatingColumnHeader:SkinButton(false, true)
    LFGListFrame.ApplicationViewer.NameColumnHeader:ClearAllPoints()
    LFGListFrame.ApplicationViewer.NameColumnHeader:SetPoint("BOTTOMLEFT", LFGListFrame.ApplicationViewer.Inset, "TOPLEFT", 0, 1)
    LFGListFrame.ApplicationViewer.RoleColumnHeader:ClearAllPoints()
    LFGListFrame.ApplicationViewer.RoleColumnHeader:SetPoint("LEFT", LFGListFrame.ApplicationViewer.NameColumnHeader, "RIGHT", 1, 0)
    LFGListFrame.ApplicationViewer.ItemLevelColumnHeader:ClearAllPoints()
    LFGListFrame.ApplicationViewer.ItemLevelColumnHeader:SetPoint("LEFT", LFGListFrame.ApplicationViewer.RoleColumnHeader, "RIGHT", 1, 0)
    LFGListFrame.ApplicationViewer.RatingColumnHeader:ClearAllPoints()
    LFGListFrame.ApplicationViewer.RatingColumnHeader:SetPoint("LEFT", LFGListFrame.ApplicationViewer.ItemLevelColumnHeader, "RIGHT", 1, 0)

    LFGListFrame.ApplicationViewer.RefreshButton:SkinButton(false, true)
    LFGListFrame.ApplicationViewer.RefreshButton:SetSize(24, 24)
    LFGListFrame.ApplicationViewer.RefreshButton:ClearAllPoints()
    LFGListFrame.ApplicationViewer.RefreshButton:SetPoint("BOTTOMRIGHT", LFGListFrame.ApplicationViewer.Inset, "TOPRIGHT", 16, 4)
    LFGListFrame.ApplicationViewer.RefreshButton.Icon:SetDesaturated(true)

    LFGListFrame.ApplicationViewer.RemoveEntryButton:SkinButton(false, true)
    LFGListFrame.ApplicationViewer.EditButton:SkinButton(false, true)
    LFGListFrame.ApplicationViewer.BrowseGroupsButton:SkinButton(false, true)
    LFGListFrame.ApplicationViewer.EditButton:ClearAllPoints()
    LFGListFrame.ApplicationViewer.EditButton:SetPoint("BOTTOMRIGHT", -6, 3)
    LFGListFrame.ApplicationViewer.BrowseGroupsButton:ClearAllPoints()
    LFGListFrame.ApplicationViewer.BrowseGroupsButton:SetPoint("BOTTOMLEFT", -1, 3)
    LFGListFrame.ApplicationViewer.BrowseGroupsButton:SetSize(120, 22)

    LFGListApplicationViewerScrollFrameScrollBar:SkinScrollBar()
    LFGListApplicationViewerScrollFrame:SkinScrollFrame()
    LFGListApplicationViewerScrollFrameScrollBar:ClearAllPoints()
    LFGListApplicationViewerScrollFrameScrollBar:SetPoint("TOPLEFT", LFGListFrame.ApplicationViewer.Inset, "TOPRIGHT", 0, -16)
    LFGListApplicationViewerScrollFrameScrollBar:SetPoint("BOTTOMLEFT", LFGListFrame.ApplicationViewer.Inset, "BOTTOMRIGHT", 0, 16)

    hooksecurefunc("LFGListApplicationViewer_UpdateInfo", function(frame)
        frame.RemoveEntryButton:ClearAllPoints()

        if UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) then
            frame.RemoveEntryButton:SetPoint("RIGHT", frame.EditButton, "LEFT", -2, 0)
        else
            frame.RemoveEntryButton:SetPoint("BOTTOMLEFT", -1, 3)
        end
    end)

    hooksecurefunc("LFGListCategorySelection_AddButton", function(btn, btnIndex, categoryID, filters)
        local button = btn.CategoryButtons[btnIndex]
        if button then
            if not button.isSkinned then
                if not button.SetBackdrop then
                    _G.Mixin(button, _G.BackdropTemplateMixin)
                    button:HookScript("OnSizeChanged", button.OnBackdropSizeChanged)
                end
                button:SetBackdrop(GW.constBackdropFrameColorBorder)

                button.Icon:SetDrawLayer("BACKGROUND", 2)
                button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                button.Icon:SetInside()
                button.Cover:Hide()
                button.HighlightTexture:SetColorTexture(1, 1, 1, 0.1)
                button.HighlightTexture:SetInside()

                button.Label:SetFontObject("GameFontNormal")
                button.isSkinned = true
            end

            button.SelectedTexture:Hide()
            local selected = btn.selectedCategory == categoryID and btn.selectedFilters == filters
            if selected then
                button:SetBackdropBorderColor(1, 1, 0)
            else
                button:SetBackdropBorderColor(0, 0, 0)
            end
        end
    end)
end

local function ApplyPvPUISkin()
    if not GW.GetSetting("LFG_SKIN_ENABLED") then return end

    PVPUIFrame:StripTextures()

    for i = 1, 3 do
        local bu = _G["PVPQueueFrameCategoryButton" .. i]
        bu.Ring:Kill()
        bu.Background:Kill()
        bu:SkinButton(false, true)

        bu.Icon:SetSize(45, 45)
        bu.Icon:ClearAllPoints()
        bu.Icon:SetPoint("LEFT", 10, 0)
        GW.HandleIcon(bu.Icon)
        bu.Icon:SetDrawLayer("OVERLAY")
    end
    hooksecurefunc("PVPQueueFrame_SelectButton", function(idx)
        for i = 1, 3 do
            local bu = _G["PVPQueueFrameCategoryButton" .. i]
            if i == idx then
                bu.hover.skipHover = true
                bu.hover:SetAlpha(1)
                bu.hover:SetPoint("RIGHT", bu, "LEFT", bu:GetWidth(), 0)
            else
                bu.hover.skipHover = false
                bu.hover:SetAlpha(1)
                bu.hover:SetPoint("RIGHT", bu, "LEFT", 0, 0)
            end
        end
    end)

    PVPQueueFrame.HonorInset:StripTextures()

    PVPQueueFrame.CategoryButton1.Icon:SetTexture(236396) -- interface/icons/achievement_bg_winwsg.blp
    PVPQueueFrame.CategoryButton2.Icon:SetTexture(236368) -- interface/icons/achievement_bg_killxenemies_generalsroom.blp
    PVPQueueFrame.CategoryButton3.Icon:SetTexture(464820) -- interface/icons/achievement_general_stayclassy.blp

    local SeasonReward = PVPQueueFrame.HonorInset.RatedPanel.SeasonRewardFrame
    SeasonReward:CreateBackdrop()
    SeasonReward.Icon:SetInside(SeasonReward.backdrop)
    SeasonReward.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    SeasonReward.CircleMask:Hide()
    SeasonReward.Ring:Hide()

    -- Honor Frame
    local HonorFrame = _G.HonorFrame
    HonorFrame:StripTextures()

    HonorFrameSpecificFrameScrollBar:SkinScrollBar()
    HonorFrameSpecificFrame:SkinScrollFrame()
    HonorFrameTypeDropDown:SkinDropDownMenu()
    HonorFrameQueueButton:SkinButton(false, true)

    local BonusFrame = HonorFrame.BonusFrame
    BonusFrame:StripTextures()
    BonusFrame.ShadowOverlay:Hide()
    BonusFrame.WorldBattlesTexture:Hide()

    for _, bonusButton in pairs({"RandomBGButton", "Arena1Button", "RandomEpicBGButton", "BrawlButton"}) do
        local bu = BonusFrame[bonusButton]
        local reward = bu.Reward

        reward.Border:Hide()
        reward.CircleMask:Hide()
        GW.HandleIcon(reward.Icon)
        reward.Icon:CreateBackdrop(GW.constBackdropFrameColorBorder , true)

        reward.EnlistmentBonus:StripTextures()
        reward.EnlistmentBonus:SetSize(20, 20)
        reward.EnlistmentBonus:SetPoint("TOPRIGHT", 2, 2)

        local EnlistmentBonusIcon = reward.EnlistmentBonus:CreateTexture()
        EnlistmentBonusIcon:SetPoint("TOPLEFT", reward.EnlistmentBonus, "TOPLEFT", 2, -2)
        EnlistmentBonusIcon:SetPoint("BOTTOMRIGHT", reward.EnlistmentBonus, "BOTTOMRIGHT", -2, 2)
        EnlistmentBonusIcon:SetTexture([[Interface\Icons\achievement_guildperk_honorablemention_rank2]])
        EnlistmentBonusIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end

    -- Honor Frame Specific Buttons
    for _, bu in pairs(HonorFrame.SpecificFrame.buttons) do
        bu.Border:Hide()
        bu.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        bu.Icon:SetPoint("TOPLEFT", 5, -3)
    end

    hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(s)
        if s.bg then s.bg:SetDesaturated(true) end
    end)

    HonorFrame.TankIcon.checkButton:SkinCheckButton()
    HonorFrame.HealerIcon.checkButton:SkinCheckButton()
    HonorFrame.DPSIcon.checkButton:SkinCheckButton()
    HonorFrame.TankIcon.checkButton:SetSize(15, 15)
    HonorFrame.HealerIcon.checkButton:SetSize(15, 15)
    HonorFrame.DPSIcon.checkButton:SetSize(15, 15)

    -- Conquest Frame
    ConquestFrame:StripTextures()
    ConquestFrame.ShadowOverlay:Hide()

    ConquestJoinButton:SkinButton(false, true)

    ConquestFrame.TankIcon.checkButton:SkinCheckButton()
    ConquestFrame.HealerIcon.checkButton:SkinCheckButton()
    ConquestFrame.DPSIcon.checkButton:SkinCheckButton()
    ConquestFrame.TankIcon.checkButton:SetSize(15, 15)
    ConquestFrame.HealerIcon.checkButton:SetSize(15, 15)
    ConquestFrame.DPSIcon.checkButton:SetSize(15, 15)

    for _, bu in pairs({ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.RatedBG}) do
        local reward = bu.Reward
        reward.Border:Hide()
        reward.CircleMask:Hide()
        GW.HandleIcon(reward.Icon)
        reward.Icon:CreateBackdrop(GW.constBackdropFrameColorBorder , true)
    end

    -- Item Borders for HonorFrame & ConquestFrame
    hooksecurefunc("PVPUIFrame_ConfigureRewardFrame", function(rewardFrame, _, _, itemRewards, currencyRewards)
        local rewardTexture, rewardQuaility = nil, 1

        if currencyRewards then
            for _, reward in ipairs(currencyRewards) do
                local info = C_CurrencyInfo.GetCurrencyInfo(reward.id)
                if info and info.quality == ITEMQUALITY_ARTIFACT then
                    _, rewardTexture, _, rewardQuaility = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.id, reward.quantity, info.name, info.iconFileID, info.quality)
                end
            end
        end

        if not rewardTexture and itemRewards then
            local reward = itemRewards[1]
            if reward then
                _, _, rewardQuaility, _, _, _, _, _, _, rewardTexture = GetItemInfo(reward.id)
            end
        end

        if rewardTexture then
            rewardFrame.Icon:SetTexture(rewardTexture)
            rewardFrame.Icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(rewardQuaility))
        end
    end)

    if GW.GetSetting("TOOLTIPS_ENABLED") then
        ConquestTooltip.NineSlice:Hide()
        ConquestTooltip:CreateBackdrop({
            bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background",
            edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
            edgeSize = GW.Scale(32),
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        })
    end

    -- PvP StatusBars
    for _, Frame in pairs({ HonorFrame, ConquestFrame }) do
        Frame.ConquestBar.Border:Hide()
        Frame.ConquestBar.Background:Hide()
        Frame.ConquestBar.Reward.Ring:Hide()
        Frame.ConquestBar.Reward.CircleMask:Hide()
        if not Frame.ConquestBar.SetBackdrop then
            _G.Mixin(Frame.ConquestBar, _G.BackdropTemplateMixin)
            Frame.ConquestBar:HookScript("OnSizeChanged", Frame.ConquestBar.OnBackdropSizeChanged)
        end
        Frame.ConquestBar:SetBackdrop(GW.constBackdropFrameColorBorder)

        Frame.ConquestBar.Reward:ClearAllPoints()
        Frame.ConquestBar.Reward:SetPoint("LEFT", Frame.ConquestBar, "RIGHT", 0, 0)
        GW.HandleIcon(Frame.ConquestBar.Reward.Icon, true)
    end

    -- New Season Frame
    local NewSeasonPopup = _G.PVPQueueFrame.NewSeasonPopup
    NewSeasonPopup.Leave:SkinButton(false, true)
    NewSeasonPopup:StripTextures()
    if not NewSeasonPopup.SetBackdrop then
        _G.Mixin(NewSeasonPopup, _G.BackdropTemplateMixin)
        NewSeasonPopup:HookScript("OnSizeChanged", NewSeasonPopup.OnBackdropSizeChanged)
    end
    NewSeasonPopup:SetBackdrop(GW.constBackdropFrameColorBorder)
    NewSeasonPopup:SetFrameLevel(5)

    local RewardFrame = NewSeasonPopup.SeasonRewardFrame
    RewardFrame:CreateBackdrop()
    RewardFrame.CircleMask:Hide()
    RewardFrame.Ring:Hide()
    RewardFrame.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    RewardFrame.backdrop:SetOutside(RewardFrame.Icon)

    if NewSeasonPopup.NewSeason then
        NewSeasonPopup.NewSeason:SetTextColor(1, 0.8, 0)
        NewSeasonPopup.NewSeason:SetShadowOffset(1, -1)
    end

    if NewSeasonPopup.SeasonRewardText then
        NewSeasonPopup.SeasonRewardText:SetTextColor(1, 0.8, 0)
        NewSeasonPopup.SeasonRewardText:SetShadowOffset(1, -1)
    end

    if NewSeasonPopup.SeasonDescriptionHeader then
        NewSeasonPopup.SeasonDescriptionHeader:SetTextColor(0, 0, 0)
        NewSeasonPopup.SeasonDescriptionHeader:SetShadowOffset(1, -1)
    end

    NewSeasonPopup:HookScript("OnShow", function(popup)
        if popup.SeasonDescriptions then
            for _, text in next, popup.SeasonDescriptions do
                text:SetTextColor(1, 1, 1)
                text:SetShadowOffset(1, -1)
            end
        end
    end)
end

local function ApplyChallengesUISkin()
    if not GW.GetSetting("LFG_SKIN_ENABLED") then return end

    ChallengesFrame:DisableDrawLayer("BACKGROUND")
    ChallengesFrameInset:StripTextures()

    -- Mythic+ KeyStoneFrame
    local tex = ChallengesKeystoneFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", ChallengesKeystoneFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = ChallengesKeystoneFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    ChallengesKeystoneFrame.tex = tex

    ChallengesKeystoneFrame.CloseButton:SkinButton(true)
    ChallengesKeystoneFrame.CloseButton:SetSize(20, 20)
    ChallengesKeystoneFrame.StartButton:SkinButton(false, true)
    GW.HandleIcon(ChallengesKeystoneFrame.KeystoneSlot.Texture, true)

    ChallengesKeystoneFrame.DungeonName:SetFont(DAMAGE_TEXT_FONT, 26, "OUTLINE")
    ChallengesKeystoneFrame.TimeLimit:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    hooksecurefunc("ChallengesFrame_Update", function(frame)
        for _, child in ipairs(frame.DungeonIcons) do
            if not child.template then
                child:GetRegions():SetAlpha(0)
                if not child.SetBackdrop then
                    _G.Mixin(child, _G.BackdropTemplateMixin)
                    child:HookScript("OnSizeChanged", child.OnBackdropSizeChanged)
                end
                child:SetBackdrop(GW.constBackdropFrameColorBorder)
                child:SetBackdropBorderColor(1, 0.99, 0.85)


                GW.HandleIcon(child.Icon, true)
                child.Icon:SetDrawLayer("ARTWORK")
                child.HighestLevel:SetDrawLayer("OVERLAY")
                child.Icon:SetInside()
            end
        end
    end)

    hooksecurefunc(ChallengesFrame.WeeklyInfo, "SetUp", function(info)
        local affixes = C_MythicPlus.GetCurrentAffixes()
        if affixes then
            HandleAffixIcons(info.Child)
        end
    end)

    hooksecurefunc(ChallengesKeystoneFrame, "Reset", function(frame)
        frame:GetRegions():SetAlpha(0)
        frame.InstructionBackground:SetAlpha(0)
        frame.KeystoneSlotGlow:Hide()
        frame.SlotBG:Hide()
        frame.KeystoneFrame:Hide()
        frame.Divider:Hide()
    end)

    hooksecurefunc(ChallengesKeystoneFrame, "OnKeystoneSlotted", HandleAffixIcons)

    -- New Season Frame
    local NoticeFrame = ChallengesFrame.SeasonChangeNoticeFrame
    NoticeFrame.Leave:SkinButton(false, true)
    NoticeFrame:StripTextures()

    if not NoticeFrame.SetBackdrop then
        _G.Mixin(NoticeFrame, _G.BackdropTemplateMixin)
        NoticeFrame:HookScript("OnSizeChanged", NoticeFrame.OnBackdropSizeChanged)
    end
    NoticeFrame:SetBackdrop(GW.constBackdropFrameColorBorder)
    NoticeFrame:SetBackdropBorderColor(1, 1, 1)

    NoticeFrame:SetFrameLevel(5)
    NoticeFrame.NewSeason:SetTextColor(1, 0.8, 0)
    NoticeFrame.NewSeason:SetShadowOffset(1, -1)
    NoticeFrame.SeasonDescription:SetTextColor(1, 1, 1)
    NoticeFrame.SeasonDescription:SetShadowOffset(1, -1)
    NoticeFrame.SeasonDescription2:SetTextColor(1, 1, 1)
    NoticeFrame.SeasonDescription2:SetShadowOffset(1, -1)
    NoticeFrame.SeasonDescription3:SetTextColor(1, 0.8, 0)
    NoticeFrame.SeasonDescription3:SetShadowOffset(1, -1)

    local affix = NoticeFrame.Affix
    affix.AffixBorder:Hide()
    affix.Portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    hooksecurefunc(affix, "SetUp", function(_, affixID)
        local _, _, texture = C_ChallengeMode.GetAffixInfo(affixID)
        if texture then
            affix.Portrait:SetTexture(texture)
        end
    end)
end

local function LoadLFGSkin()
    GW.RegisterSkin("Blizzard_ChallengesUI", function() ApplyChallengesUISkin() end)
    GW.RegisterSkin("Blizzard_PVPUI", function() ApplyPvPUISkin() end)
    SkinLookingForGroupFrames()
end
GW.LoadLFGSkin = LoadLFGSkin