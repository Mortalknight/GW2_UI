local _, GW = ...





local moveDistance, socialFrameX, socialFrameY, socialFrameLeft, socialFrameTop, socialFrameNormalScale, socialFrameEffectiveScale = 0, 0, 0, 0, 0, 1, 0
local friendsFrameTabsAdded = 0

local function GetScaleDistance()
    local left, top = socialFrameLeft, socialFrameTop
    local scale = socialFrameEffectiveScale
    local x, y = GetCursorPosition()
    x = x / scale - left
    y = top - y / scale
    return sqrt(x * x + y * y)
end

local function HandleTabs()
    for idx, tab in ipairs({FriendsFrameTab1, FriendsFrameTab2, FriendsFrameTab3, FriendsFrameTab4}) do
        if not tab.isSkinned then
            local iconName
            if GW.Retail then
                iconName = idx == 1 and "tabicon_friends" or idx == 2 and "tabicon_who" or idx == 3 and "tabicon_raid" or "tabicon_quickjoin"
            else
                iconName = idx == 1 and "tabicon_friends" or idx == 2 and "tabicon_who" or idx == 3 and "tabicon_friends" or "tabicon_raid"
            end

            local iconTexture = "Interface/AddOns/GW2_UI/textures/social/" .. iconName .. ".png"
            GW.SkinSideTabButton(tab, iconTexture, tab:GetText())
        end

        tab:ClearAllPoints()
        tab:SetPoint("TOPRIGHT", FriendsFrame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * friendsFrameTabsAdded))
        tab:SetParent(FriendsFrame.LeftSidePanel)
        tab:SetSize(64, 40)
        friendsFrameTabsAdded = friendsFrameTabsAdded + 1

        if GW.TBC then
            hooksecurefunc("FriendsFrame_UpdateGuildTabVisibility", function()
                FriendsFrameTab4:ClearAllPoints()
                if FriendsFrameTab3:IsShown() then
                    FriendsFrameTab4:SetPoint("TOPRIGHT", FriendsFrame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * 3))
                else
                    FriendsFrameTab4:SetPoint("TOPRIGHT", FriendsFrame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * 2))
                end
            end)
        end

        if idx == 4 and GW.Retail then
            tab.GwNotifyRed = tab:CreateTexture(nil, "ARTWORK", nil, 7)
            tab.GwNotifyText = tab:CreateFontString(nil, "OVERLAY")

            tab.GwNotifyRed:SetSize(18, 18)
            tab.GwNotifyRed:SetPoint("CENTER", tab, "BOTTOM", 23, 7)
            tab.GwNotifyRed:SetTexture("Interface/AddOns/GW2_UI/textures/hud/notification-backdrop.png")
            tab.GwNotifyRed:SetVertexColor(0.7, 0, 0, 0.7)
            tab.GwNotifyRed:Hide()

            tab.GwNotifyText:SetSize(24, 24)
            tab.GwNotifyText:SetPoint("CENTER", tab, "BOTTOM", 23, 7)
            tab.GwNotifyText:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            tab.GwNotifyText:SetTextColor(1, 1, 1, 1)
            tab.GwNotifyText:SetShadowColor(0, 0, 0, 0)
            tab.GwNotifyText:Hide()
        end
    end
end

function GW.LoadSocialFrame()
    if not GW.settings.USE_SOCIAL_WINDOW then return end

    GW.HandlePortraitFrame(FriendsFrame)
    if FriendsFrameIcon then
        FriendsFrameIcon:SetAlpha(0)
    end
    FriendsFrameCloseButton:SetPoint("TOPRIGHT", -5, -2)

    GW.CreateFrameHeaderWithBody(FriendsFrame, FriendsFrameTitleText, "Interface/AddOns/GW2_UI/textures/social/social-windowheader.png", {
        FriendsListFrame.ScrollBox,
        FriendsFrameFriendsScrollFrame,
        FriendsFrameIgnoreScrollFrame,
        RecentAlliesFrame and RecentAlliesFrame.List,
        RecruitAFriendFrame and RecruitAFriendFrame.RecruitList.ScrollBox,
        WhoFrame.ScrollBox,
        WhoListScrollFrame,
        QuickJoinFrame and QuickJoinFrame.ScrollBox
        }
        , nil, true, true)

    HandleTabs()
    FriendsFrame.gwHeader.windowIcon:ClearAllPoints()
    FriendsFrame.gwHeader.windowIcon:SetPoint("CENTER", FriendsFrame.gwHeader, "BOTTOMLEFT", -26, 35)
    FriendsFrameTitleText:ClearAllPoints()
    FriendsFrameTitleText:SetPoint("BOTTOMLEFT", FriendsFrame.gwHeader, "BOTTOMLEFT", 25, 10)
    FriendsFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)
    FriendsFrame:SetClampedToScreen(true)
    FriendsFrame:SetClampRectInsets(-40, 0, FriendsFrame.gwHeader:GetHeight() - 30, 0)
    FriendsFrame:SetSize(500, 627)

    FriendsFrame:SetScale(GW.settings.SOCIAL_POSITION_SCALE)
    FriendsFrame:SetMovable(true)
    FriendsFrame:RegisterForDrag("LeftButton")
    FriendsFrame:SetScript("OnDragStart", function()
        FriendsFrame:StartMoving()
    end)
    FriendsFrame:SetScript("OnDragStop", function()
        FriendsFrame:StopMovingOrSizing()
        FriendsFrame:SetUserPlaced(false)
        -- Save map frame position
        local pos = GW.settings.SOCIAL_POSITION
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = FriendsFrame:GetPoint()
        GW.settings.SOCIAL_POSITION = pos
    end)
    FriendsFrame:HookScript("OnShow", function()
        local pos = GW.settings.SOCIAL_POSITION
        FriendsFrame:ClearAllPoints()
        FriendsFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    end)

    FriendsFrame.sizer = CreateFrame("Frame", nil, FriendsFrame)
    FriendsFrame.sizer:EnableMouse(true)
    FriendsFrame.sizer:SetSize(32, 32)
    FriendsFrame.sizer:SetPoint("BOTTOMRIGHT", FriendsFrame, "BOTTOMRIGHT", 2, -2)
    FriendsFrame.sizer.texture = FriendsFrame.sizer:CreateTexture(nil, "OVERLAY")
    FriendsFrame.sizer.texture:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/resize.png")
    FriendsFrame.sizer.texture:SetSize(32, 32)
    FriendsFrame.sizer.texture:SetPoint("BOTTOMRIGHT", FriendsFrame.sizer, "BOTTOMRIGHT", 0, 0)
    FriendsFrame.sizer.texture:SetDesaturated(true)
    FriendsFrame.sizer:SetScript("OnEnter", function(self)
        self.texture:SetDesaturated(false)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 30)
        GameTooltip:ClearLines()
        GameTooltip_SetTitle(GameTooltip, GW.L["Scale with Right Click"])
        GameTooltip:Show()
    end)
    FriendsFrame.sizer:SetScript("OnLeave", function(self)
        self.texture:SetDesaturated(true)
        GameTooltip_Hide()
    end)
    FriendsFrame.sizer:SetFrameStrata(FriendsFrame:GetFrameStrata())
    FriendsFrame.sizer:SetFrameLevel(FriendsFrame:GetFrameLevel() + 15)
    FriendsFrame.sizer:SetScript("OnMouseDown", function(self, btn)
        if btn ~= "RightButton" then
            return
        end
        socialFrameLeft, socialFrameTop = FriendsFrame:GetLeft(), FriendsFrame:GetTop()
        socialFrameNormalScale = FriendsFrame:GetScale()
        socialFrameX, socialFrameY = socialFrameLeft, socialFrameTop - (UIParent:GetHeight() / socialFrameNormalScale)
        socialFrameEffectiveScale = FriendsFrame:GetEffectiveScale()
        moveDistance = GetScaleDistance()
        self:SetScript("OnUpdate", function()
            local scale = GetScaleDistance() / moveDistance * socialFrameNormalScale
            if scale < 0.2 then scale = 0.2 elseif scale > 3.0 then scale = 3.0 end
            FriendsFrame:SetScale(scale)
            local s = socialFrameNormalScale / FriendsFrame:GetScale()
            local x = socialFrameX * s
            local y = socialFrameY * s
            FriendsFrame:ClearAllPoints()
            FriendsFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
        end)
    end)
    FriendsFrame.sizer:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
        GW.settings.SOCIAL_POSITION_SCALE = FriendsFrame:GetScale()
        -- Save hero frame position
        local pos = GW.settings.SOCIAL_POSITION
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = FriendsFrame:GetPoint()
        GW.settings.SOCIAL_POSITION = pos
    end)

    GW.SkinFriendList()
    GW.SkinIgnoreList()
    GW.SkinRecentAlliesList()
    GW.SkinRecruitAFriendList()
    GW.SkinWhoList()
    GW.SkinRaidList()
    GW.SkinQuickJoinList()
    GW.SkinGuildList()
end