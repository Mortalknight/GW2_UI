---@class GW2
local GW = select(2, ...)

local moveDistance, socialFrameX, socialFrameY, socialFrameLeft, socialFrameTop, socialFrameNormalScale, socialFrameEffectiveScale = 0, 0, 0, 0, 0, 1, 0

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
        if not tab.isSkinned then
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
            tab.isSkinned = true

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

function GW.LoadSocialFrame()
    if not GW.settings.USE_SOCIAL_WINDOW then return end

    GW.HandlePortraitFrame(SocialUIFrame)
    SocialUIFrameCloseButton:SetPoint("TOPRIGHT", -5, -2)

    GW.CreateFrameHeaderWithBody(SocialUIFrame, SocialUIFrameTitleText, "Interface/AddOns/GW2_UI/textures/social/social-windowheader.png", {
        SocialUIFrame.FriendsList.ScrollBox,
        SocialUIFrame.IgnoreListFrame.ScrollBox,
        SocialUIFrame.RecentAlliesList.ScrollBox,
        SocialUIFrame.QuickJoinFrame.ScrollBox,
        SocialUIFrame.FriendRequestsList.ScrollBox,
        SocialUIFrame.RecruitList and SocialUIFrame.RecruitList.ScrollBox or nil,
        SocialUIFrame.RaidFrame
        }
        , nil, true, true)

    HandleTabs(SocialUIFrame)
    hooksecurefunc(SocialUIFrame, "RefreshTabs", HandleTabs)
    SocialUIFrame.gwHeader.windowIcon:ClearAllPoints()
    SocialUIFrame.gwHeader.windowIcon:SetPoint("CENTER", SocialUIFrame.gwHeader, "BOTTOMLEFT", -26, 35)
    SocialUIFrameTitleText:ClearAllPoints()
    SocialUIFrameTitleText:SetPoint("BOTTOMLEFT", SocialUIFrame.gwHeader, "BOTTOMLEFT", 25, 10)
    SocialUIFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    SocialUIFrame:SetClampedToScreen(true)
    SocialUIFrame:SetClampRectInsets(-40, 0, SocialUIFrame.gwHeader:GetHeight() - 30, 0)
    SocialUIFrame:SetSize(500, 627)

    SocialUIFrame:SetScale(GW.settings.SOCIAL_POSITION_SCALE)
    SocialUIFrame:SetMovable(true)
    SocialUIFrame:RegisterForDrag("LeftButton")
    SocialUIFrame:SetScript("OnDragStart", function()
        SocialUIFrame:StartMoving()
    end)
    SocialUIFrame:SetScript("OnDragStop", function()
        SocialUIFrame:StopMovingOrSizing()
        SocialUIFrame:SetUserPlaced(false)
        -- Save map frame position
        local pos = GW.settings.SOCIAL_POSITION
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = SocialUIFrame:GetPoint()
        GW.settings.SOCIAL_POSITION = pos
    end)
    SocialUIFrame:HookScript("OnShow", function()
        local pos = GW.settings.SOCIAL_POSITION
        SocialUIFrame:ClearAllPoints()
        SocialUIFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    end)

    SocialUIFrame.sizer = CreateFrame("Frame", nil, SocialUIFrame)
    SocialUIFrame.sizer:EnableMouse(true)
    SocialUIFrame.sizer:SetSize(32, 32)
    SocialUIFrame.sizer:SetPoint("BOTTOMRIGHT", SocialUIFrame, "BOTTOMRIGHT", 2, -2)
    SocialUIFrame.sizer.texture = SocialUIFrame.sizer:CreateTexture(nil, "OVERLAY")
    SocialUIFrame.sizer.texture:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/resize.png")
    SocialUIFrame.sizer.texture:SetSize(32, 32)
    SocialUIFrame.sizer.texture:SetPoint("BOTTOMRIGHT", SocialUIFrame.sizer, "BOTTOMRIGHT", 0, 0)
    SocialUIFrame.sizer.texture:SetDesaturated(true)
    SocialUIFrame.sizer:SetScript("OnEnter", function(self)
        self.texture:SetDesaturated(false)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 30)
        GameTooltip:ClearLines()
        GameTooltip_SetTitle(GameTooltip, GW.L["Scale with Right Click"])
        GameTooltip:Show()
    end)
    SocialUIFrame.sizer:SetScript("OnLeave", function(self)
        self.texture:SetDesaturated(true)
        GameTooltip_Hide()
    end)
    SocialUIFrame.sizer:SetFrameStrata(SocialUIFrame:GetFrameStrata())
    SocialUIFrame.sizer:SetFrameLevel(SocialUIFrame:GetFrameLevel() + 15)
    SocialUIFrame.sizer:SetScript("OnMouseDown", function(self, btn)
        if btn ~= "RightButton" then
            return
        end
        socialFrameLeft, socialFrameTop = SocialUIFrame:GetLeft(), SocialUIFrame:GetTop()
        socialFrameNormalScale = SocialUIFrame:GetScale()
        socialFrameX, socialFrameY = socialFrameLeft, socialFrameTop - (UIParent:GetHeight() / socialFrameNormalScale)
        socialFrameEffectiveScale = SocialUIFrame:GetEffectiveScale()
        moveDistance = GW.GetScaledCursorDistance(socialFrameLeft, socialFrameTop, socialFrameEffectiveScale)
        self:SetScript("OnUpdate", function()
            local scale = GW.GetScaledCursorDistance(socialFrameLeft, socialFrameTop, socialFrameEffectiveScale) / moveDistance * socialFrameNormalScale
            if scale < 0.2 then scale = 0.2 elseif scale > 3.0 then scale = 3.0 end
            SocialUIFrame:SetScale(scale)
            local s = socialFrameNormalScale / SocialUIFrame:GetScale()
            local x = socialFrameX * s
            local y = socialFrameY * s
            SocialUIFrame:ClearAllPoints()
            SocialUIFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
        end)
    end)
    SocialUIFrame.sizer:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
        GW.settings.SOCIAL_POSITION_SCALE = SocialUIFrame:GetScale()
        -- Save hero frame position
        local pos = GW.settings.SOCIAL_POSITION
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = SocialUIFrame:GetPoint()
        GW.settings.SOCIAL_POSITION = pos
    end)

    GW.SkinFriendList()
    GW.SkinSocialContactsView(SocialUIFrame.FriendRequestsList)
    GW.SkinIgnoreList()
    GW.SkinRecentAlliesList()
    GW.SkinRecruitAFriendList()
    GW.SkinWhoList()
    GW.SkinRaidList()
    GW.SkinQuickJoinList()
end