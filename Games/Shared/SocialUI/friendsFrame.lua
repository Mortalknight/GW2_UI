---@class GW2
local GW = select(2, ...)

local function HandleTabs(self)
    local sortedTabs = {}
    for tab in self:EnumerateTabs() do
        sortedTabs[#sortedTabs + 1] = tab
    end
    table.sort(sortedTabs, function(a, b)
        return (a.tabData and a.tabData.tabOrder or 0) < (b.tabData and b.tabData.tabOrder or 0)
    end)

    local friendsFrameTabsAdded = 0
    for _, tab in ipairs(sortedTabs) do
        if not tab.gwSkinned then
            local iconName
            if tab.tabData.tabType == SocialUITabType.Friends then
                iconName = "tabicon_friends"
            elseif tab.tabData.tabType == SocialUITabType.RecentAllies then
                iconName = "tabicon_recentallies"
            elseif tab.tabData.tabType == SocialUITabType.FriendRequests then
                iconName = "tabicon_friendrequests"
            elseif tab.tabData.tabType == SocialUITabType.RecruitAFriend then
                iconName = "tabicon_reqruit"
            elseif tab.tabData.tabType == SocialUITabType.RaidList then
                iconName = "tabicon_raid"
            elseif tab.tabData.tabType == SocialUITabType.QuickJoin then
                iconName = "tabicon_quickjoin"
            end
            tab.gwSkinned = true

            local iconTexture = "Interface/AddOns/GW2_UI/textures/social/" .. iconName .. ".png"
            GW.SkinSideTabButton(tab, iconTexture, tab:GetText())
            tab.Icon:Hide()
        end

        tab:ClearAllPoints()
        tab:SetPoint("TOPRIGHT", SocialUIFrame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * friendsFrameTabsAdded))
        tab:SetParent(SocialUIFrame.LeftSidePanel)
        tab:SetSize(64, 40)
        friendsFrameTabsAdded = friendsFrameTabsAdded + 1

        if tab.tabData.tabType == SocialUITabType.QuickJoin and not tab.GwNotifyRed then
            tab.GwNotifyRed = tab:CreateTexture(nil, "ARTWORK", nil, 7)
            tab.GwNotifyText = tab:CreateFontString(nil, "OVERLAY")

            tab.GwNotifyRed:SetSize(18, 18)
            tab.GwNotifyRed:SetPoint("CENTER", tab, "BOTTOM", 23, 7)
            tab.GwNotifyRed:SetTexture("Interface/AddOns/GW2_UI/textures/hud/notification-backdrop.png")
            tab.GwNotifyRed:SetVertexColor(0.7, 0, 0, 0.7)
            tab.GwNotifyRed:Hide()

            tab.GwNotifyText:SetSize(24, 24)
            tab.GwNotifyText:SetPoint("CENTER", tab, "BOTTOM", 23, 7)
            tab.GwNotifyText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
            tab.GwNotifyText:SetTextColor(1, 1, 1, 1)
            tab.GwNotifyText:SetShadowColor(0, 0, 0, 0)
            tab.GwNotifyText:Hide()
        end
    end
end

function GW.LoadSocialUIFrame()
    if not GW.settings.windows.social.enabled then return end

    GW.HandlePortraitFrame(SocialUIFrame)
    SocialUIFrameCloseButton:SetPoint("TOPRIGHT", -5, -2)

    -- not every client has every list, Forever for example has no quick join
    local detailBackgrounds = {}
    for _, key in ipairs({"FriendsList", "IgnoreListFrame", "RecentAlliesList", "QuickJoinFrame", "FriendRequestsList", "RecruitList"}) do
        local list = SocialUIFrame[key]
        if list and list.ScrollBox then
            tinsert(detailBackgrounds, list.ScrollBox)
        end
    end
    if SocialUIFrame.RaidFrame then
        tinsert(detailBackgrounds, SocialUIFrame.RaidFrame)
    end
    GW.CreateFrameHeaderWithBody(SocialUIFrame, SocialUIFrameTitleText, "Interface/AddOns/GW2_UI/textures/social/social-windowheader.png", detailBackgrounds, nil, true, true)

    HandleTabs(SocialUIFrame)
    hooksecurefunc(SocialUIFrame, "RefreshTabs", HandleTabs)
    SocialUIFrame.gwHeader.windowIcon:ClearAllPoints()
    SocialUIFrame.gwHeader.windowIcon:SetPoint("CENTER", SocialUIFrame.gwHeader, "BOTTOMLEFT", -26, 35)
    SocialUIFrameTitleText:ClearAllPoints()
    SocialUIFrameTitleText:SetPoint("BOTTOMLEFT", SocialUIFrame.gwHeader, "BOTTOMLEFT", 25, 10)
    SocialUIFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    SocialUIFrame:SetClampedToScreen(true)
    SocialUIFrame:SetClampRectInsets(-40, 0, SocialUIFrame.gwHeader:GetHeight() - 30, 0)
    SocialUIFrame:SetSize(500, 627)

    SocialUIFrame:SetScale(GW.settings.windows.social.scale)
    SocialUIFrame:SetMovable(true)
    SocialUIFrame:RegisterForDrag("LeftButton")
    SocialUIFrame:SetScript("OnDragStart", function()
        SocialUIFrame:StartMoving()
    end)
    SocialUIFrame:SetScript("OnDragStop", function()
        SocialUIFrame:StopMovingOrSizing()
        SocialUIFrame:SetUserPlaced(false)
        -- Save map frame position
        local pos = GW.settings.windows.social.pos
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = SocialUIFrame:GetPoint()
        GW.settings.windows.social.pos = pos
    end)
    SocialUIFrame:HookScript("OnShow", function()
        local pos = GW.settings.windows.social.pos
        SocialUIFrame:ClearAllPoints()
        SocialUIFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    end)

    GW.AddScaleHandle(SocialUIFrame, GW.settings.windows.social)

    GW.SkinSocialUIFriendList()
    GW.SkinSocialContactsView(SocialUIFrame.FriendRequestsList)
    GW.SkinSocialUIIgnoreList()
    GW.SkinSocialUIRecentAlliesList()
    GW.SkinSocialUIRecruitAFriendList()
    GW.SkinSocialUIWhoList()
    GW.SkinSocialUIRaidList()
    GW.SkinSocialUIQuickJoinList()
end