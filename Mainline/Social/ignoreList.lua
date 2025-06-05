local _, GW = ...

local removeIgnore_OnEnter = function(self)
    self.icon:SetBlendMode("ADD")
end

local removeIgnore_OnLeave = function(self)
    self.icon:SetBlendMode("BLEND")
end

local function removeFromeIgnore(self)
    if not self:GetParent().type then
        return
    end

    if self:GetParent().type == SQUELCH_TYPE_IGNORE  then
        C_FriendList.DelIgnoreByIndex(self:GetParent().index)
    elseif ( self:GetParent().type == SQUELCH_TYPE_BLOCK_INVITE ) then
        local blockID = BNGetBlockedInfo(self:GetParent().index)
        BNSetBlocked(blockID, false)
    end
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

local function IgnoreList_Update(self)
    local dataProvider = CreateDataProvider()

    local numIgnores = C_FriendList.GetNumIgnores();
    if numIgnores and numIgnores > 0 then
        for index = 1, numIgnores do
            dataProvider:Insert({squelchType=SQUELCH_TYPE_IGNORE, index=index});
        end
    end

    local numBlocks = BNGetNumBlocked();
    if numBlocks and numBlocks > 0 then
        for index = 1, numBlocks do
            dataProvider:Insert({squelchType=SQUELCH_TYPE_BLOCK_INVITE, index=index});
        end
    end
    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

local function IgnoreList_InitButton(button, elementData)
    button.index = elementData.index;

    if not button.isSkinned then
        button.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        button.name:SetTextColor(1, 1, 1)
        button.remove:HookScript("OnEnter", removeIgnore_OnEnter)
        button.remove:HookScript("OnLeave", removeIgnore_OnLeave)
        button.remove:SetScript("OnClick", removeFromeIgnore)
        GW.AddListItemChildHoverTexture(button)

        button.isSkinned = true
    end

    if elementData.squelchType == SQUELCH_TYPE_IGNORE then
        local name = C_FriendList.GetIgnoreName(button.index)
        if not name then
            button.name:SetText(UNKNOWN)
        else
            button.name:SetText(name)
            button.type = SQUELCH_TYPE_IGNORE
        end
    elseif elementData.squelchType == SQUELCH_TYPE_BLOCK_INVITE then
        local _, blockName = BNGetBlockedInfo(button.index)
        button.name:SetText(blockName)
        button.type = SQUELCH_TYPE_BLOCK_INVITE
    end

    if (button.index % 2) == 1 then
        button.zebra:SetVertexColor(1, 1, 1, 1)
    else
        button.zebra:SetVertexColor(0, 0, 0, 0)
    end
end

local function LoadIgnoreList(tabContainer)
    local ignorewin_outer = CreateFrame("Frame", "GwIgnoreWindow", tabContainer, "GwIgnoreWindow")

    local view = CreateScrollBoxListLinearView()
    view:SetElementFactory(function(factory, elementData)
        factory("GwIgnoreListButtonTemplate", IgnoreList_InitButton)
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(ignorewin_outer.ScrollBox, ignorewin_outer.ScrollBar, view)
    GW.HandleTrimScrollBar(ignorewin_outer.ScrollBar)
    GW.HandleScrollControls(ignorewin_outer)
    ignorewin_outer.ScrollBar:SetHideIfUnscrollable(true)

    IgnoreList_Update(ignorewin_outer)

    ignorewin_outer.ignoreHeader:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER)
    ignorewin_outer.ignoreHeader:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

    -- update ignore window when a ignore update event occurs
    ignorewin_outer:SetScript(
        "OnEvent",
        function(self)
            if GW.inWorld and self:IsShown() then
                IgnoreList_Update(ignorewin_outer)
            end
        end
    )
    ignorewin_outer:RegisterEvent("IGNORELIST_UPDATE")

    ignorewin_outer.ignore:SetScript("OnClick", function()
        if UnitCanCooperate("player", "target") and UnitIsPlayer("target") then
            local name, server = UnitName("target")
            local fullname = name;
            if server and UnitRealmRelationship("target") ~= LE_REALM_RELATION_SAME then
                fullname = name .. "-" .. server
            end
            C_FriendList.AddIgnore(fullname)
            PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
        else
            StaticPopup_Show("ADD_IGNORE")
        end
    end)


    SlashCmdList["IGNORE"] = function(msg)
        if InCombatLockdown() then return end

        if ( msg ~= "" or UnitIsPlayer("target") ) then
            local bNetIDAccount = BNet_GetBNetIDAccount(msg);
            if ( bNetIDAccount ) then
                if ( BNIsFriend(bNetIDAccount) ) then
                    SendSystemMessage(ERR_CANNOT_IGNORE_BN_FRIEND);
                else
                    BNSetBlocked(bNetIDAccount, not BNIsBlocked(bNetIDAccount));
                end
            else
                C_FriendList.AddOrDelIgnore(msg);
            end
        else
            GwSocialWindow:SetAttribute("windowpanelopen", "ignorelist")
        end
    end

    SlashCmdList["UNIGNORE"] = function(msg)
        if InCombatLockdown() then return end

        if ( msg ~= "" or UnitIsPlayer("target") ) then
            C_FriendList.DelIgnore(msg);
        else
            GwSocialWindow:SetAttribute("windowpanelopen", "ignorelist")
        end
    end
end
GW.LoadIgnoreList = LoadIgnoreList