local _, GW = ...


local function LoadFriendList(tabContainer)
    local GWFriendFrame = CreateFrame("Frame", "GWFriendFrame", tabContainer, "GWFriendFrame")
    GWFriendFrame.Container = tabContainer

    GWFriendFrame:SetScript("OnShow", function()
        FriendsList_Update(true)
        UpdateMicroButtons()
        FriendsFrame_CheckQuickJoinHelpTip();
        FriendsFrame_UpdateQuickJoinTab(#C_SocialQueue.GetAllGroups())
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        GuildRoster()

        FriendsFrame_Update()
    end)

    FriendsFrameBattlenetFrame:SetParent(GWFriendFrame.headerBN)
    FriendsFrameBattlenetFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame:SetAllPoints(GWFriendFrame.headerBN)

    FriendsFrameStatusDropDown:GwSkinDropDownMenu(5)
    FriendsFrameStatusDropDown:SetParent(GWFriendFrame.headerDD)
    FriendsFrameStatusDropDown:ClearAllPoints()
    FriendsFrameStatusDropDown:SetAllPoints(GWFriendFrame.headerDD)

    FriendsFrameFriendsScrollFrame:SetParent(GWFriendFrame.list)
    FriendsFrameFriendsScrollFrame:ClearAllPoints()
    FriendsFrameFriendsScrollFrame:SetAllPoints(GWFriendFrame.list)

    FriendsFrameFriendsScrollFrame.SetParent = GW.NoOp
    FriendsFrameFriendsScrollFrame.ClearAllPoints = GW.NoOp
    FriendsFrameFriendsScrollFrame.SetAllPoints = GW.NoOp
    FriendsFrameFriendsScrollFrame.SetPoint = GW.NoOp

    FriendsListFrame.RIDWarning:SetParent(GWFriendFrame.list)
    FriendsListFrame.RIDWarning:ClearAllPoints()
    FriendsListFrame.RIDWarning:SetAllPoints(GWFriendFrame.list)

    FriendsListFrame:SetParent(GWFriendFrame.list)
    FriendsListFrame:ClearAllPoints()
    FriendsListFrame:SetAllPoints(GWFriendFrame.list)

    FriendsFrameAddFriendButton:SetParent(GWFriendFrame.list)
    FriendsFrameAddFriendButton:ClearAllPoints()
    FriendsFrameAddFriendButton:SetPoint("BOTTOMLEFT", GWFriendFrame.list,  "BOTTOMLEFT", 4, -40)
    FriendsFrameAddFriendButton:GwSkinButton(false, true)

    FriendsFrameSendMessageButton:SetParent(GWFriendFrame.list)
    FriendsFrameSendMessageButton:ClearAllPoints()
    FriendsFrameSendMessageButton:SetPoint("BOTTOMRIGHT", GWFriendFrame.list,  "BOTTOMRIGHT", -4, -40)
    FriendsFrameSendMessageButton:GwSkinButton(false, true)

    FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton:SetSize(460, 30)
    FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton:GwSkinButton(false, true)

    hooksecurefunc(FriendsFrameFriendsScrollFrame.invitePool, "Acquire", function()
        for object in pairs(_G.FriendsListFrameScrollFrame.invitePool.activeObjects) do
            if object.isSkinned then return end
            object.DeclineButton:GwSkinButton(false, true)
            object.AcceptButton:GwSkinButton(false, true)
            object.isSkinned = true
        end
    end)

    FriendsFrameFriendsScrollFrame.scrollBar:GwSkinScrollBar()
    FriendsFrameFriendsScrollFrame.scrollBar:SetWidth(3)
    FriendsFrameFriendsScrollFrame:GwSkinScrollFrame()
    FriendsFrameFriendsScrollFrameMiddle:Hide()
    FriendsFrameFriendsScrollFrameScrollChild:ClearAllPoints()
    FriendsFrameFriendsScrollFrameScrollChild:SetAllPoints(GWFriendFrame.list)

    HybridScrollFrame_CreateButtons(FriendsFrameFriendsScrollFrame, "FriendsFrameButtonTemplate")

    FriendsTooltip:SetParent(GWFriendFrame.list)

    local buttons = FriendsFrameFriendsScrollFrame.buttons
    for i = 1, #buttons do
        local button = buttons[i]
        local icon = _G["FriendsFrameFriendsScrollFrameButton" .. i .. "GameIcon"]
        local name = _G["FriendsFrameFriendsScrollFrameButton" .. i .. "Name"]
        local info = _G["FriendsFrameFriendsScrollFrameButton" .. i .. "Info"]

        button:SetSize(460, 34)

        icon:SetSize(22, 22)
        icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)

        name:SetFont(UNIT_NAME_FONT, 14)
        info:SetFont(UNIT_NAME_FONT, 13)

        icon:ClearAllPoints()
        icon:SetPoint("RIGHT", button, "RIGHT", -24, 0)
        icon.SetPoint = GW.NoOp
    end

    hooksecurefunc("HybridScrollFrame_Update", function(self)
        if self == FriendsFrameFriendsScrollFrame then
            self.scrollChild:SetHeight(490)
            self:UpdateScrollChildRect()
        end
    end)

    --View Friends BN Frame
    FriendsFriendsFrame:GwStripTextures()
  --LEGION  FriendsFriendsFrame.ScrollFrameBorder:Hide()
    FriendsFriendsFrame:GwCreateBackdrop(GW.skins.constBackdropFrame)
    FriendsFriendsFrameDropDown:GwSkinDropDownMenu()
    FriendsFrameAddFriendButton:GwSkinButton(false, true)
    FriendsFrameCloseButton:GwSkinButton(false, true)
    FriendsFrameFriendsScrollFrame.scrollBar:GwSkinScrollBar()
    FriendsFrameFriendsScrollFrame.scrollBar:SetWidth(3)
    FriendsFrameFriendsScrollFrameMiddle:Hide()
    FriendsFrameFriendsScrollFrame:GwSkinScrollFrame()

    FriendsFrameBattlenetFrame.BroadcastButton:GwKill()
    FriendsFrameBattlenetFrame:GwStripTextures()
    FriendsFrameBattlenetFrame:GwCreateBackdrop(GW.skins.constBackdropFrame, true)
    FriendsFrameBattlenetFrame.Tag:GwKill()

    local button = CreateFrame("Button", nil, FriendsFrameBattlenetFrame)
    button:SetPoint("TOPLEFT", FriendsFrameBattlenetFrame, "TOPLEFT")
    button:SetPoint("BOTTOMRIGHT", FriendsFrameBattlenetFrame, "BOTTOMRIGHT")
    button:SetSize(FriendsFrameBattlenetFrame:GetSize())
    button:GwCreateBackdrop(nil, true)
    button:GwSkinButton(false, false, true)

    button.Tag = button:CreateFontString(nil, "OVERLAY")
    button.Tag:SetPoint("CENTER", button, "CENTER")
    button.Tag:SetTextColor(0.345, 0.667, 0.867)
    button.Tag:SetFont(UNIT_NAME_FONT, 15)
    button.hover.r = FRIENDS_BNET_BACKGROUND_COLOR.r
    button.hover.g = FRIENDS_BNET_BACKGROUND_COLOR.g
    button.hover.b = FRIENDS_BNET_BACKGROUND_COLOR.b

    button:SetScript("OnClick", function() FriendsFrameBattlenetFrame.BroadcastFrame:ToggleFrame() end)
    button:HookScript("OnEnter", function(self) self.Tag:SetTextColor(1, 1, 1) end)
    button:HookScript("OnLeave", function(self) self.Tag:SetTextColor(0.345, 0.667, 0.867) end)

    hooksecurefunc("FriendsFrame_CheckBattlenetStatus", function()
        button.Tag:Hide()
        if BNFeaturesEnabled() and BNConnected() then
            local _, battleTag = BNGetInfo()
            if battleTag then
                button.Tag:SetText(battleTag)
                button.Tag:Show()
            end
        end
    end)

    FriendsFrameBattlenetFrame.BroadcastFrame:GwStripTextures()
    FriendsFrameBattlenetFrame.BroadcastFrame:GwCreateBackdrop(GW.skins.constBackdropFrame)
    --LEGION FriendsFrameBattlenetFrame.BroadcastFrame.EditBox:GwStripTextures()
    FriendsFrameBattlenetFrame.BroadcastFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame.BroadcastFrame:SetPoint("TOPLEFT", GWFriendFrame.headerBN, "TOPRIGHT", 45, 1)
    --LEGION GW.HandleBlizzardRegions(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox)
    --LEGION GW.SkinTextBox(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.LeftBorder, FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.RightBorder, FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.MiddleBorder)
  --LEGION  FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton:GwSkinButton(false, true)
  --LEGION  FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton:GwSkinButton(false, true)

    AddFriendFrame:GwStripTextures()
    AddFriendFrame:GwCreateBackdrop(GW.skins.constBackdropFrame)
    AddFriendEntryFrameAcceptButton:GwSkinButton(false, true)
    AddFriendEntryFrameCancelButton:GwSkinButton(false, true)
    AddFriendInfoFrameContinueButton:GwSkinButton(false, true)
    GW.SkinTextBox(_G["AddFriendNameEditBoxLeft"], _G["AddFriendNameEditBoxRight"], _G["AddFriendNameEditBoxMiddle"])

    FriendsFrameBattlenetFrame.UnavailableInfoFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame.UnavailableInfoFrame:SetPoint("TOPLEFT", GWFriendFrame.headerBN, "TOPRIGHT", 1, -18)

  --LEGION   RecruitAFriendRecruitmentFrame:GwStripTextures()
  --LEGION   RecruitAFriendRecruitmentFrame:GwCreateBackdrop(GW.skins.constBackdropFrame)
  --LEGION   GW.SkinTextBox(RecruitAFriendRecruitmentFrame.EditBox.Left, RecruitAFriendRecruitmentFrame.EditBox.Middle, RecruitAFriendRecruitmentFrame.EditBox.Right)
  --LEGION   RecruitAFriendRecruitmentFrame.GenerateOrCopyLinkButton:SkinButton(false, true)
  --LEGION   RecruitAFriendRecruitmentFrame.CloseButton:SkinButton(true)
  --LEGION   RecruitAFriendRecruitmentFrame.CloseButton:SetSize(15, 15)

    SlashCmdList["FRIENDS"] = function(msg)
        if InCombatLockdown() then return end

        if msg == "" and UnitIsPlayer("target") then
            msg = GetUnitName("target", true)
        end
        if not msg or msg == "" then
            GwSocialWindow:SetAttribute("windowpanelopen", "friendlist")
        else
            local player, note = strmatch(msg, "%s*([^%s]+)%s*(.*)");
            if player then
                C_FriendList.AddOrRemoveFriend(player, note);
            end
        end
    end
end
GW.LoadFriendList = LoadFriendList
