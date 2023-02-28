local _, GW = ...

local atlasToTex = {
    ["friendslist-invitebutton-horde-normal"] = [[Interface\FriendsFrame\PlusManz-Horde]],
    ["friendslist-invitebutton-alliance-normal"] = [[Interface\FriendsFrame\PlusManz-Alliance]],
    ["friendslist-invitebutton-default-normal"] = [[Interface\FriendsFrame\PlusManz-PlusManz]],
}

local function HandleInviteTex(self, atlas)
    local tex = atlasToTex[atlas]
    if tex then
        self.ownerIcon:SetTexture(tex)
    end
end

local function LoadFriendList(tabContainer)
    local GWFriendFrame = CreateFrame("Frame", "GWFriendFrame", tabContainer, "GWFriendFrame")
    GWFriendFrame.Container = tabContainer

    GWFriendFrame:SetScript("OnShow", function()
        FriendsList_Update(true)
        UpdateMicroButtons()
        FriendsFrame_CheckQuickJoinHelpTip();
        FriendsFrame_UpdateQuickJoinTab(#C_SocialQueue.GetAllGroups())
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        C_GuildInfo.GuildRoster()

        FriendsFrame_Update()
    end)

    FriendsFrameBattlenetFrame:SetParent(GWFriendFrame.headerBN)
    FriendsFrameBattlenetFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame:SetAllPoints(GWFriendFrame.headerBN)

    FriendsFrameStatusDropDown:GwSkinDropDownMenu(5)
    FriendsFrameStatusDropDown:SetWidth(55)
    FriendsFrameStatusDropDown:SetParent(GWFriendFrame.headerDD)
    FriendsFrameStatusDropDown:ClearAllPoints()
    FriendsFrameStatusDropDown:SetPoint("TOPLEFT", GWFriendFrame.headerDD, "TOPLEFT", 5, 0)

    FriendsListFrame.ScrollBox:SetParent(GWFriendFrame.list)
    FriendsListFrame.ScrollBox:ClearAllPoints()
    FriendsListFrame.ScrollBox:SetAllPoints(GWFriendFrame.list)

    FriendsListFrame.ScrollBox.SetParent = GW.NoOp
    FriendsListFrame.ScrollBox.ClearAllPoints = GW.NoOp
    FriendsListFrame.ScrollBox.SetAllPoints = GW.NoOp
    FriendsListFrame.ScrollBox.SetPoint = GW.NoOp

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

    GW.HandleTrimScrollBar(FriendsListFrame.ScrollBar)
    GW.HandleAchivementsScrollControls(FriendsListFrame)

    FriendsTooltip:SetParent(GWFriendFrame.list)

    local INVITE_RESTRICTION_NONE = 9
    hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
        if not button.IsSkinned then
            button:SetSize(460, 34)

            button.gameIcon:SetSize(22, 22)
            button.gameIcon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
            button.gameIcon:ClearAllPoints()
            button.gameIcon:SetPoint("RIGHT", button, "RIGHT", -24, 0)
            button.gameIcon.SetPoint = GW.NoOp

            button.name:SetFont(UNIT_NAME_FONT, 14)

            local travelPass = button.travelPassButton
            travelPass:SetSize(22, 22)
            travelPass:SetPoint("TOPRIGHT", -3, -6)
            travelPass:GwCreateBackdrop()
            travelPass.NormalTexture:SetAlpha(0)
            travelPass.PushedTexture:SetAlpha(0)
            travelPass.DisabledTexture:SetAlpha(0)
            travelPass.HighlightTexture:SetColorTexture(1, 1, 1, .25)
            travelPass.HighlightTexture:SetAllPoints()
            button.gameIcon:SetPoint("TOPRIGHT", travelPass, "TOPLEFT", -4, 0)

            local icon = travelPass:CreateTexture(nil, "ARTWORK")
            icon:SetTexCoord(.1, .9, .1, .9)
            icon:SetAllPoints()
            button.newIcon = icon
            travelPass.NormalTexture.ownerIcon = icon
            hooksecurefunc(travelPass.NormalTexture, "SetAtlas", HandleInviteTex)

            button.IsSkinned = true
        end

        if button.newIcon and button.buttonType == _G.FRIENDS_BUTTON_TYPE_BNET then
            if FriendsFrame_GetInviteRestriction(button.id) == INVITE_RESTRICTION_NONE then
                button.newIcon:SetVertexColor(1, 1, 1)
            else
                button.newIcon:SetVertexColor(.5, .5, .5)
            end
        end
    end)

    --View Friends BN Frame
    FriendsFriendsFrame:GwStripTextures()
    FriendsFriendsFrame.ScrollFrameBorder:Hide()
    FriendsFriendsFrame:GwCreateBackdrop(GW.skins.constBackdropFrame)
    FriendsFriendsFrameDropDown:GwSkinDropDownMenu()
    FriendsFriendsFrame.SendRequestButton:GwSkinButton(false, true)
    FriendsFriendsFrame.CloseButton:GwSkinButton(false, true)
    GW.HandleTrimScrollBar(FriendsFriendsFrame.ScrollBar)
    GW.HandleAchivementsScrollControls(FriendsFriendsFrame)

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
    FriendsFrameBattlenetFrame.BroadcastFrame.EditBox:GwStripTextures()
    FriendsFrameBattlenetFrame.BroadcastFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame.BroadcastFrame:SetPoint("TOPLEFT", GWFriendFrame.headerBN, "TOPRIGHT", 45, 1)
    GW.HandleBlizzardRegions(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox)
    GW.SkinTextBox(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.MiddleBorder, FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.LeftBorder, FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.RightBorder)
    FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton:GwSkinButton(false, true)
    FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton:GwSkinButton(false, true)

    AddFriendFrame:GwStripTextures()
    AddFriendFrame:GwCreateBackdrop(GW.skins.constBackdropFrame)
    AddFriendEntryFrameAcceptButton:GwSkinButton(false, true)
    AddFriendEntryFrameCancelButton:GwSkinButton(false, true)
    AddFriendInfoFrameContinueButton:GwSkinButton(false, true)
    GW.SkinTextBox(_G["AddFriendNameEditBoxMiddle"], _G["AddFriendNameEditBoxLeft"], _G["AddFriendNameEditBoxRight"])
    FriendsFrameBattlenetFrame.UnavailableInfoFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame.UnavailableInfoFrame:SetPoint("TOPLEFT", GWFriendFrame.headerBN, "TOPRIGHT", 1, -18)

    RecruitAFriendRecruitmentFrame:GwStripTextures()
    RecruitAFriendRecruitmentFrame:GwCreateBackdrop(GW.skins.constBackdropFrame)
    GW.SkinTextBox(RecruitAFriendRecruitmentFrame.EditBox.Middle, RecruitAFriendRecruitmentFrame.EditBox.Left, RecruitAFriendRecruitmentFrame.EditBox.Right)
    RecruitAFriendRecruitmentFrame.GenerateOrCopyLinkButton:GwSkinButton(false, true)
    RecruitAFriendRecruitmentFrame.CloseButton:GwSkinButton(true)
    RecruitAFriendRecruitmentFrame.CloseButton:SetSize(15, 15)

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
