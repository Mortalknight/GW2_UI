---@class GW2
local GW = select(2, ...)

-- icon per blizzard tab name; the set differs per client: classic has friends/who/guild/raid, retail
-- friends/who/raid/quick join, forever ships without the who tab (FriendsFrameTab2) and numbers the
-- remaining tabs by array position, so every tab is looked up by its global name and may be missing
local TAB_ICONS = {
    [1] = "tabicon_friends",
    [2] = "tabicon_who",
    [3] = GW.isModern and "tabicon_raid" or "tabicon_friends",
    [4] = GW.isModern and "tabicon_quickjoin" or "tabicon_raid",
}

local function GetFriendsFrameTabs()
    local tabs = {}
    for i = 1, 4 do
        local tab = _G["FriendsFrameTab" .. i]
        if tab then
            tabs[#tabs + 1] = {tab = tab, number = i}
        end
    end
    return tabs
end

-- stacks the tabs on the left panel; blizzard hides tabs by game rule (forever: raid and quick join)
-- or guild state (tbc/wrath), hidden ones do not take a slot. Hidden tabs still get the next slot
-- so a tab shown later without a relayout never sits without an anchor
local function LayoutTabs()
    local added = 0
    for _, entry in ipairs(GetFriendsFrameTabs()) do
        local tab = entry.tab
        tab:ClearAllPoints()
        tab:SetPoint("TOPRIGHT", FriendsFrame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * added))
        if tab:IsShown() then
            added = added + 1
        end
    end
end

local function HandleTabs()
    for _, entry in ipairs(GetFriendsFrameTabs()) do
        local tab, number = entry.tab, entry.number
        if not tab.gwSkinned then
            local iconTexture = "Interface/AddOns/GW2_UI/textures/social/" .. TAB_ICONS[number] .. ".png"
            GW.SkinSideTabButton(tab, iconTexture, tab:GetText())
        end
        tab:SetParent(FriendsFrame.LeftSidePanel)
        tab:SetSize(64, 40)

        if number == 4 and GW.isModern then
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

    LayoutTabs()

    -- follow blizzards tab visibility changes
    if FriendsFrame_UpdateGuildTabVisibility then
        hooksecurefunc("FriendsFrame_UpdateGuildTabVisibility", LayoutTabs)
    end
    for _, name in ipairs({"PanelTemplates_SetTabShown", "PanelTemplates_ShowTab", "PanelTemplates_HideTab"}) do
        if _G[name] then
            hooksecurefunc(name, function(frame)
                if frame == FriendsFrame then
                    LayoutTabs()
                end
            end)
        end
    end
end

function GW.LoadSocialFrame()
    if not GW.settings.windows.social.enabled then return end

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
        WhoFrame and WhoFrame.ScrollBox or nil,
        WhoListScrollFrame,
        QuickJoinFrame and QuickJoinFrame.ScrollBox
        }
        , nil, true, true)

    HandleTabs()
    FriendsFrame.gwHeader.windowIcon:ClearAllPoints()
    FriendsFrame.gwHeader.windowIcon:SetPoint("CENTER", FriendsFrame.gwHeader, "BOTTOMLEFT", -26, 35)
    FriendsFrameTitleText:ClearAllPoints()
    FriendsFrameTitleText:SetPoint("BOTTOMLEFT", FriendsFrame.gwHeader, "BOTTOMLEFT", 25, 10)
    FriendsFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 2)
    FriendsFrame:SetClampedToScreen(true)
    FriendsFrame:SetClampRectInsets(-40, 0, FriendsFrame.gwHeader:GetHeight() - 30, 0)
    FriendsFrame:SetSize(500, 627)

    FriendsFrame:SetScale(GW.settings.windows.social.scale)
    FriendsFrame:SetMovable(true)
    FriendsFrame:RegisterForDrag("LeftButton")
    FriendsFrame:SetScript("OnDragStart", function()
        FriendsFrame:StartMoving()
    end)
    FriendsFrame:SetScript("OnDragStop", function()
        FriendsFrame:StopMovingOrSizing()
        FriendsFrame:SetUserPlaced(false)
        -- Save map frame position
        local pos = GW.settings.windows.social.pos
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = FriendsFrame:GetPoint()
        GW.settings.windows.social.pos = pos
    end)
    FriendsFrame:HookScript("OnShow", function()
        local pos = GW.settings.windows.social.pos
        FriendsFrame:ClearAllPoints()
        FriendsFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    end)

    GW.AddScaleHandle(FriendsFrame, GW.settings.windows.social)

    GW.SkinFriendList()
    GW.SkinIgnoreList()
    GW.SkinRecentAlliesList()
    GW.SkinRecruitAFriendList()
    GW.SkinWhoList()
    GW.SkinRaidList()
    GW.SkinQuickJoinList()
    GW.SkinGuildList()
end
