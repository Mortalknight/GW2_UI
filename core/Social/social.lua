local _, GW = ...
local L = GW.L

local hasBeenLoaded = false
local moveDistance, socialFrameX, socialFrameY, socialFrameLeft, socialFrameTop, socialFrameNormalScale, socialFrameEffectiveScale = 0, 0, 0, 0, 0, 1, 0

local windowsConfiguration = {
    {
        OnLoad = "LoadFriendList",
        SettingName = "USE_SOCIAL_WINDOW",
        RefName = "GwFriendList",
        TabIcon = "tabicon_friends",
        HeaderText = FRIENDS_LIST,
        HeaderTipText = FRIENDS,
        Bindings = {
            TOGGLEFRIENDSTAB = "FriendList",
            TOGGLESOCIAL = "FriendList"
        },
        OnClick = [=[
            self:GetFrameRef("GwSocialWindow"):SetAttribute("windowpanelopen", "friendlist")
        ]=],
        load = true
    },
    {
        OnLoad = "LoadRecentAlliesFrame",
        SettingName = "USE_SOCIAL_WINDOW",
        RefName = "GwRecentList",
        TabIcon = "tabicon_friends",
        HeaderText = CONTACTS_RECENT_ALLIES_TITLE,
        HeaderTipText = CONTACTS_RECENT_ALLIES_TITLE,
        Bindings = {},
        OnClick = [=[
            self:GetFrameRef("GwSocialWindow"):SetAttribute("windowpanelopen", "recentList")
        ]=],
        load = GW.Retail
    },
    {
        OnLoad = "LoadIgnoreList",
        SettingName = "USE_SOCIAL_WINDOW",
        RefName = "GwIgnoreList",
        TabIcon = "tabicon_ignore",
        HeaderText = IGNORE_LIST,
        HeaderTipText = IGNORE,
        Bindings = {},
        OnClick = [=[
            self:GetFrameRef("GwSocialWindow"):SetAttribute("windowpanelopen", "ignorelist")
        ]=],
        load = true
    },
    {
        OnLoad = "LoadRecruitAFriendList",
        SettingName = "USE_SOCIAL_WINDOW",
        RefName = "GwRecruitAFriendList",
        TabIcon = "tabicon_reqruit",
        HeaderText = RECRUIT_A_FRIEND,
        HeaderTipText = RECRUIT_A_FRIEND,
        Bindings = {},
        OnClick = [=[
            self:GetFrameRef("GwSocialWindow"):SetAttribute("windowpanelopen", "recruitafriendlist")
        ]=],
        load = GW.Retail
    },
    {
        OnLoad = "LoadWhoList",
        SettingName = "USE_SOCIAL_WINDOW",
        RefName = "GwWhoList",
        TabIcon = "tabicon_who",
        HeaderText = WHO_LIST,
        HeaderTipText = WHO,
        Bindings = {
            TOGGLEWHOTAB = "WhoList"
        },
        OnClick = [=[
            self:GetFrameRef("GwSocialWindow"):SetAttribute("windowpanelopen", "wholist")
        ]=],
        load = true
    },
    {
        OnLoad = "LoadGuildList",
        SettingName = "USE_SOCIAL_WINDOW",
        RefName = "GwGuildList",
        TabIcon = "tabicon_friends",
        HeaderText = GUILD,
        HeaderTipText = GUILD,
        Bindings = {
        },
        OnClick = [=[
            self:GetFrameRef("GwSocialWindow"):SetAttribute("windowpanelopen", "guildlist")
        ]=],
        load = GW.TBC
    },
    {
        OnLoad = "LoadQuickJoinList",
        SettingName = "USE_SOCIAL_WINDOW",
        RefName = "GwQuickList",
        TabIcon = "tabicon_quickjoin",
        HeaderText = QUICK_JOIN,
        HeaderTipText = QUICK_JOIN,
        Bindings = {
            TOGGLEQUICKJOINTAB = "QuickJoin"
        },
        OnClick = [=[
            self:GetFrameRef("GwSocialWindow"):SetAttribute("windowpanelopen", "quicklist")
        ]=],
        load = GW.Retail
    },
    {
        OnLoad = "LoadRaidList",
        SettingName = "USE_SOCIAL_WINDOW",
        RefName = "GwRaidList",
        TabIcon = "tabicon_raid",
        HeaderText = RAID,
        HeaderTipText = RAID,
        Bindings = {
            TOGGLERAIDTAB = "RaidList"
        },
        OnClick = [=[
            self:GetFrameRef("GwSocialWindow"):SetAttribute("windowpanelopen", "raidlist")
        ]=],
        load = true
    }
}

-- turn click events (generated from key bind overrides) into the correct tab show/hide calls
local socialSecure_OnClick =
    [=[
    --print("secure click handler button: " .. button)
    local f = self:GetFrameRef("GwSocialWindow")
    if button == "Close" then
        f:SetAttribute("windowpanelopen", nil)
    elseif button == "FriendList" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "friendlist")
    elseif button == "WhoList" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "wholist")
    elseif button == "GuildList" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "guildlist")
    elseif button == "QuickJoin" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "quicklist")
    elseif button == "RaidList" then
        f:SetAttribute("keytoggle", true)
        f:SetAttribute("windowpanelopen", "raidlist")
    end
    ]=]

local function SocialWindowToggleTab(tabKey)
    if not InCombatLockdown() then
        GwSocialWindow:SetAttribute("keytoggle", true)
        GwSocialWindow:SetAttribute("windowpanelopen", tabKey)
    end
end
GW.SocialWindowToggleTab = SocialWindowToggleTab

-- use the windowpanelopen attr to show/hide the social frame with correct tab open
local socialSecure_OnAttributeChanged =
    [=[
    if name ~= "windowpanelopen" then
        return
    end

    local fmFriend = self:GetFrameRef("GwFriendList")
    local showFriend = false
    local fmIgnore = self:GetFrameRef("GwIgnoreList")
    local showIgnore = false
    local fmRecent = self:GetFrameRef("GwRecentList")
    local showRecent = false
    local fmRecruitAFriend = self:GetFrameRef("GwRecruitAFriendList")
    local showRecruitAFriend = false
    local fmWho = self:GetFrameRef("GwWhoList")
    local showWho = false
    local fmQuick = self:GetFrameRef("GwQuickList")
    local showQuick = false
    local fmRaid = self:GetFrameRef("GwRaidList")
    local showRaid = false
    local fmGuild = self:GetFrameRef("GwGuildList")
    local showGuild = false

    local close = false
    local keytoggle = self:GetAttribute("keytoggle")

    if fmFriend ~= nil and value == "friendlist" then
        if keytoggle and fmFriend:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showFriend = true
        end
    elseif fmGuild ~= nil and value == "guildlist" then
        if keytoggle and fmFriend:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showGuild = true
        end
    elseif fmIgnore ~= nil and value == "ignorelist" then
        if keytoggle and fmIgnore:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showIgnore = true
        end
    elseif fmRecent ~= nil and value == "recentList" then
        if keytoggle and fmRecent:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showRecent = true
        end
    elseif fmRecruitAFriend ~= nil and value == "recruitafriendlist" then
        if keytoggle and fmRecruitAFriend:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showRecruitAFriend = true
        end
    elseif fmWho ~= nil and value == "wholist" then
        if keytoggle and fmWho:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showWho = true
        end
    elseif fmQuick ~= nil and value == "quicklist" then
        if keytoggle and fmQuick:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showQuick = true
        end
    elseif fmRaid ~= nil and value == "raidlist" then
        if keytoggle and fmRaid:IsVisible() then
            self:SetAttribute("keytoggle", nil)
            self:SetAttribute("windowpanelopen", nil)
            return
        else
            showRaid = true
        end
    else
        close = true
    end

    if keytoggle then
        self:SetAttribute("keytoggle", nil)
    end

    if fmFriend then
        if showFriend and not close then
            fmFriend:Show()
        else
            fmFriend:Hide()
        end
    end
    if fmGuild then
        if showGuild and not close then
            fmGuild:Show()
        else
            fmGuild:Hide()
        end
    end
    if fmRecent then
        if showRecent and not close then
            fmRecent:Show()
        else
            fmRecent:Hide()
        end
    end
    if fmIgnore then
        if showIgnore and not close then
            fmIgnore:Show()
        else
            fmIgnore:Hide()
        end
    end
    if fmRecruitAFriend then
        if showRecruitAFriend and not close then
            fmRecruitAFriend:Show()
        else
            fmRecruitAFriend:Hide()
        end
    end
    if fmWho then
        if showWho and not close then
            fmWho:Show()
        else
            fmWho:Hide()
        end
    end
    if fmQuick then
        if showQuick and not close then
            fmQuick:Show()
        else
            fmQuick:Hide()
        end
    end
    if fmRaid then
        if showRaid and not close then
            fmRaid:Show()
        else
            fmRaid:Hide()
        end
    end

    if close then
        self:Hide()
        self:CallMethod("SoundExit")
    elseif not self:IsVisible() then
        self:Show()
        self:CallMethod("SoundOpen")
    else
        self:CallMethod("SoundSwap")
    end
    ]=]
GW.socialSecure_OnAttributeChanged = socialSecure_OnAttributeChanged

local socialSecure_OnShow =
    [=[
    local keyEsc = GetBindingKey("TOGGLEGAMEMENU")
    if keyEsc ~= nil then
        self:SetBinding(false, keyEsc, "CLICK GwSocialWindowClick:Close")
    end
    ]=]

local socialSecure_OnHide = [=[
    self:ClearBindings()
    ]=]

local socialCloseSecure_OnClick = [=[
    self:GetParent():SetAttribute("windowpanelopen", nil)
    ]=]

local mover_OnDragStart = [=[
    if button ~= "LeftButton" then
        return
    end
    local f = self:GetParent()
    if self:GetAttribute("isMoving") then
        f:CallMethod("StopMovingOrSizing")
    end
    self:SetAttribute("isMoving", true)
    f:CallMethod("StartMoving")
]=]

local mover_OnDragStop = [=[
    if button ~= "LeftButton" then
        return
    end
    if not self:GetAttribute("isMoving") then
        return
    end
    self:SetAttribute("isMoving", false)
    local f = self:GetParent()
    f:CallMethod("StopMovingOrSizing")
    local x, y, _ = f:GetRect()

    -- re-anchor to UIParent after the move
    f:ClearAllPoints()
    f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)

    -- store the updated position
    self:CallMethod("savePosition", x, y)
]=]

local function mover_SavePosition(self, x, y)
    local setting = self.onMoveSetting
    if setting then
        local pos = GW.settings[setting]
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point = "BOTTOMLEFT"
        pos.relativePoint = "BOTTOMLEFT"
        pos.xOfs = x
        pos.yOfs = y
        GW.settings[setting] = pos
    end
end
GW.AddForProfiling("social", "mover_SavePosition", mover_SavePosition)

local function click_OnEvent(self, event)
    if event ~= "UPDATE_BINDINGS" then
        return
    end
    if InCombatLockdown() then
        GW.CombatQueue_Queue("social_update_keybind", click_OnEvent, {self, event})
        return
    end
    ClearOverrideBindings(self)

    for _, win in pairs(windowsConfiguration) do
        if win.TabFrame and win.Bindings then
            for key, click in pairs(win.Bindings) do
                local keyBind, keyBind2 = GetBindingKey(key)
                if keyBind then
                    SetOverrideBinding(self, false, keyBind, "CLICK GwSocialWindowClick:" .. click)
                end
                if keyBind2 then
                    SetOverrideBinding(self, false, keyBind2, "CLICK GwSocialWindowClick:" .. click)
                end
            end
        end
    end
end
GW.AddForProfiling("social", "click_OnEvent", click_OnEvent)

local function GetScaleDistance()
    local left, top = socialFrameLeft, socialFrameTop
    local scale = socialFrameEffectiveScale
    local x, y = GetCursorPosition()
    x = x / scale - left
    y = top - y / scale
    return sqrt(x * x + y * y)
end

local function loadBaseFrame()
    if hasBeenLoaded then
        return
    end
    hasBeenLoaded = true

    -- create the social window and secure bind its tab open/close functions
    local fmGSW = CreateFrame("Frame", "GwSocialWindow", UIParent, "GwSocialWindowTemplate")

    FriendsFrame.Show = FriendsFrame.Hide

    table.insert(UISpecialFrames, fmGSW:GetName())
    fmGSW.WindowHeader:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
    fmGSW.WindowHeader:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    fmGSW:SetAttribute("windowpanelopen", nil)
    fmGSW.secure:SetAttribute("_onclick", socialSecure_OnClick)
    fmGSW.secure:SetFrameRef("GwSocialWindow", fmGSW)
    fmGSW:SetAttribute("_onattributechanged", socialSecure_OnAttributeChanged)

    fmGSW:SetClampedToScreen(true)
    fmGSW:SetClampRectInsets(-fmGSW.Left:GetWidth(), 0, fmGSW.Header:GetHeight() - 10, 0)

    fmGSW.SoundOpen = function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
    end
    fmGSW.SoundSwap = function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    end
    fmGSW.SoundExit = function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    end

    -- secure hook ESC to close social window when it is showing
    fmGSW:WrapScript(fmGSW, "OnShow", socialSecure_OnShow)
    fmGSW:WrapScript(fmGSW, "OnHide", socialSecure_OnHide)

    -- the close button securely closes the social window
    fmGSW.close:SetAttribute("_onclick", socialCloseSecure_OnClick)

    -- setup movable stuff and scale
    local pos = GW.settings.SOCIAL_POSITION
    local scale = GW.settings.SOCIAL_POSITION_SCALE
    fmGSW:SetScale(scale)
    fmGSW:ClearAllPoints()
    fmGSW:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    fmGSW.mover.onMoveSetting = "SOCIAL_POSITION"
    fmGSW.mover.savePosition = mover_SavePosition
    fmGSW.mover:SetAttribute("_onmousedown", mover_OnDragStart)
    fmGSW.mover:SetAttribute("_onmouseup", mover_OnDragStop)
    fmGSW.sizer.texture:SetDesaturated(true)
    fmGSW.sizer:SetScript("OnEnter", function(self)
        self.texture:SetDesaturated(false)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 30)
        GameTooltip:ClearLines()
        GameTooltip_SetTitle(GameTooltip, L["Scale with Right Click"])
        GameTooltip:Show()
    end)
    fmGSW.sizer:SetScript("OnLeave", function(self)
        self.texture:SetDesaturated(true)
        GameTooltip_Hide()
    end)
    fmGSW.sizer:SetFrameStrata(fmGSW:GetFrameStrata())
    fmGSW.sizer:SetFrameLevel(fmGSW:GetFrameLevel() + 15)
    fmGSW.sizer:SetScript("OnMouseDown", function(self, btn)
        if btn ~= "RightButton" then
            return
        end
        socialFrameLeft, socialFrameTop = GwSocialWindow:GetLeft(), GwSocialWindow:GetTop()
        socialFrameNormalScale = GwSocialWindow:GetScale()
        socialFrameX, socialFrameY = socialFrameLeft, socialFrameTop - (UIParent:GetHeight() / socialFrameNormalScale)
        socialFrameEffectiveScale = GwSocialWindow:GetEffectiveScale()
        moveDistance = GetScaleDistance()
        self:SetScript("OnUpdate", function()
            local scale = GetScaleDistance() / moveDistance * socialFrameNormalScale
            if scale < 0.2 then scale = 0.2 elseif scale > 3.0 then scale = 3.0 end
            GwSocialWindow:SetScale(scale)
            local s = socialFrameNormalScale / GwSocialWindow:GetScale()
            local x = socialFrameX * s
            local y = socialFrameY * s
            GwSocialWindow:ClearAllPoints()
            GwSocialWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
        end)
    end)
    fmGSW.sizer:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
        GW.settings.SOCIAL_POSITION_SCALE = GwSocialWindow:GetScale()
        -- Save hero frame position
        local pos = GW.settings.SOCIAL_POSITION
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point, _, pos.relativePoint, pos.xOfs, pos.yOfs = GwSocialWindow:GetPoint()
        GW.settings.SOCIAL_POSITION = pos
    end)

    -- set binding change handlers
    fmGSW.secure:HookScript("OnEvent", click_OnEvent)
    fmGSW.secure:RegisterEvent("UPDATE_BINDINGS")

    fmGSW.backgroundMask = UIParent:CreateMaskTexture()
    fmGSW.backgroundMask:SetPoint("TOPLEFT", fmGSW, "TOPLEFT", -64, 64)
    fmGSW.backgroundMask:SetPoint("BOTTOMRIGHT", fmGSW, "BOTTOMLEFT",-64, 0)
    fmGSW.backgroundMask:SetTexture("Interface/AddOns/GW2_UI/textures/masktest.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    fmGSW.background:AddMaskTexture(fmGSW.backgroundMask)

    fmGSW:HookScript("OnShow", function()
        GW.AddToAnimation("SOCIALPANEL_ONSHOW",
            0,
            1,
            GetTime(),
            GW.WINDOW_FADE_DURATION,
            function(p)
                fmGSW:SetAlpha(p)
                fmGSW.backgroundMask:SetPoint("BOTTOMRIGHT", fmGSW.background, "BOTTOMLEFT", GW.lerp(-64, fmGSW.background:GetWidth(), p) , 0)
            end,
            1,
            function()
                fmGSW.backgroundMask:SetPoint("BOTTOMRIGHT", fmGSW.background, "BOTTOMLEFT", fmGSW.background:GetWidth() + 200, 0)
            end
        )
    end)
end
GW.AddForProfiling("social", "loadBaseFrame", loadBaseFrame)

local function setTabIconState(self, b)
    if b then
        self.icon:SetTexCoord(0, 0.5, 0, 0.625)
    else
        self.icon:SetTexCoord(0.505, 1, 0, 0.625)
    end
end
GW.AddForProfiling("social", "setTabIconState", setTabIconState)

local function createTabIcon(iconName, tabIndex, notify)
    local f = CreateFrame("Button", nil, GwSocialWindow, "GwSocialTabSelect")
    f.icon:SetTexture("Interface/AddOns/GW2_UI/textures/social/" .. iconName .. ".png")
    f:SetPoint("TOP", GwSocialWindow, "TOPLEFT", -32, -25 + -((tabIndex - 1) * 45))
    setTabIconState(f, false)

    if notify then
        f.GwNotifyRed = f:CreateTexture(nil, "ARTWORK", nil, 7)
        f.GwNotifyText = f:CreateFontString(nil, "OVERLAY")

        f.GwNotifyRed:SetSize(18, 18)
        f.GwNotifyRed:SetPoint("CENTER", f, "BOTTOM", 23, 7)
        f.GwNotifyRed:SetTexture("Interface/AddOns/GW2_UI/textures/hud/notification-backdrop.png")
        f.GwNotifyRed:SetVertexColor(0.7, 0, 0, 0.7)
        f.GwNotifyRed:Hide()

        f.GwNotifyText:SetSize(24, 24)
        f.GwNotifyText:SetPoint("CENTER", f, "BOTTOM", 23, 7)
        f.GwNotifyText:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        f.GwNotifyText:SetTextColor(1, 1, 1, 1)
        f.GwNotifyText:SetShadowColor(0, 0, 0, 0)
        f.GwNotifyText:Hide()
    end
    return f
end
GW.AddForProfiling("social", "createTabIcon", createTabIcon)

local function container_OnShow(self)
    setTabIconState(self.TabFrame, true)
    self.SocialWindow.WindowHeader:SetText(self.HeaderText)
end
GW.AddForProfiling("social", "container_OnShow", container_OnShow)

local function container_OnHide(self)
    setTabIconState(self.TabFrame, false)
end
GW.AddForProfiling("social", "container_OnHide", container_OnHide)

local function socialTab_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, 30)
    GameTooltip:ClearLines()
    GameTooltip_SetTitle(GameTooltip, self.gwTipLabel)
    GameTooltip:Show()
end
GW.AddForProfiling("social", "socialTab_OnEnter", socialTab_OnEnter)

-- Change blizzard OnEvent Handler to work with our frame
local function GWFriendsFrame_OnEvent(_, event, ...)
    if ( event == "SPELL_UPDATE_COOLDOWN" ) then
        if ( GwSocialWindow:IsShown() ) then
            if GW.Retail then
                FriendsListFrame.ScrollBox:ForEachFrame(function(button)
                    if button.summonButton and button.summonButton:IsShown() then
                        FriendsFrame_SummonButton_Update(button.summonButton);
                    end
                end)
            elseif GW.TBC then
                local buttons = FriendsFrameFriendsScrollFrame.buttons;
                for _, button in pairs(buttons) do
                    if ( button.summonButton:IsShown() ) then
                        FriendsFrame_SummonButton_Update(button.summonButton);
                    end
                end
            end
        end
    elseif ( event == "FRIENDLIST_UPDATE" or event == "GROUP_ROSTER_UPDATE" ) then
        FriendsList_Update();
    elseif ( event == "BN_FRIEND_LIST_SIZE_CHANGED" or event == "BN_FRIEND_INFO_CHANGED" ) then
        FriendsList_Update();
        -- update Friends of Friends
        local bnetIDAccount = ...;
        if ( event == "BN_FRIEND_LIST_SIZE_CHANGED" and bnetIDAccount ) then
            FriendsFriendsFrame.requested[bnetIDAccount] = nil;
            if ( GwSocialWindow:IsShown() ) then
                FriendsFriendsFrame:Update();
            end
        end
    elseif ( event == "BN_CUSTOM_MESSAGE_CHANGED" ) then
        local arg1 = ...;
        if ( arg1 ) then	--There is no bnetIDAccount given if this is ourself.
            FriendsList_Update();
        else
            FriendsFrameBattlenetFrame.BroadcastFrame:UpdateBroadcast();
        end
    elseif ( event == "BN_CUSTOM_MESSAGE_LOADED" ) then
            FriendsFrameBattlenetFrame.BroadcastFrame:UpdateBroadcast();
    elseif ( event == "NEW_MATCHMAKING_PARTY_INVITE" ) then
        local collapsed = GetCVarBool("partyInvitesCollapsed_Glue");
        if ( collapsed ) then
            FriendsListFrame_SetInviteHeaderAnimPlaying(true, FRIENDS_BUTTON_TYPE_PARTY_INVITE_HEADER);
        end
        FriendsList_Update()
    elseif ( event == "BN_FRIEND_INVITE_ADDED" ) then
        -- flash the invites header if collapsed
        local collapsed = GetCVarBool("friendInvitesCollapsed");
        if ( collapsed ) then
            FriendsListFrame_SetInviteHeaderAnimPlaying(true, FRIENDS_BUTTON_TYPE_INVITE_HEADER);
        end
        FriendsList_Update();
    elseif ( event == "BN_FRIEND_INVITE_LIST_INITIALIZED" ) then
        FriendsList_Update();
    elseif ( event == "BN_FRIEND_INVITE_REMOVED" ) then
        FriendsList_Update();
    elseif ( event == "IGNORELIST_UPDATE" or event == "BN_BLOCK_LIST_UPDATED" ) then
        IgnoreList_Update();
    elseif ( event == "WHO_LIST_UPDATE" ) then
        WhoList_Update()
        FriendsFrame_Update()
    elseif ( event == "PLAYER_FLAGS_CHANGED" or event == "BN_INFO_CHANGED") then
        FriendsFrameStatusDropdown:GenerateMenu()
        FriendsFrame_CheckBattlenetStatus()
    elseif ( event == "PLAYER_ENTERING_WORLD" or event == "BN_CONNECTED" or event == "BN_DISCONNECTED") then
        FriendsFrame_CheckBattlenetStatus();
        -- We want to remove any friends from the frame so they don't linger when it's first re-opened.
        if (event == "BN_DISCONNECTED") then
            FriendsList_Update(true)
        end
    elseif ( event == "BATTLETAG_INVITE_SHOW" ) then
        BattleTagInviteFrame_Show(...);
    elseif ( event == "SOCIAL_QUEUE_UPDATE" or event == "GROUP_LEFT" or event == "GROUP_JOINED" ) then
        if ( GwSocialWindow:IsVisible() ) then
            FriendsFrame_Update(); --TODO - Only update the buttons that need updating
            if GW.Retail then
                FriendsFrame_UpdateQuickJoinTab(#C_SocialQueue.GetAllGroups())
            end
        end
    elseif ( event == "GUILD_ROSTER_UPDATE" ) then
        if ( GwSocialWindow:IsVisible() ) then
            local canRequestGuildRoster = ...;
            if ( canRequestGuildRoster ) then
                C_GuildInfo.GuildRoster();
            end

            if GuildStatus_Update then
                GuildStatus_Update()
            end

        end
    elseif ( event == "PLAYER_GUILD_UPDATE") then
        C_GuildInfo.GuildRoster()
    elseif ( event == "FRAMES_LOADED" ) then
        FriendsFrame_CheckBattlenetStatus()
    end
end

local function LoadSocialFrame()
    local anyThingToLoad = false
    for _, v in pairs(windowsConfiguration) do
        if GW.settings[v.SettingName] and v.load then
            anyThingToLoad = true
        end
    end

    if not anyThingToLoad then
        return
    end

    loadBaseFrame()
    FriendsFrame:SetScript("OnEvent", GWFriendsFrame_OnEvent)

    local tabIndex = 1
    for _, v in pairs(windowsConfiguration) do
        if GW.settings[v.SettingName] and v.load then
            local container = CreateFrame("Frame", nil, GwSocialWindow, "GwSocialTabContainer")
            local tab = createTabIcon(v.TabIcon, tabIndex, v.RefName == "GwQuickList")

            GwSocialWindow:SetFrameRef(v.RefName, container)

            container.TabFrame = tab
            container.SocialWindow = GwSocialWindow
            container.HeaderText = v.HeaderText
            tab.gwTipLabel = v.HeaderTipText

            tab:SetScript("OnEnter", socialTab_OnEnter)
            tab:SetScript("OnLeave", GameTooltip_Hide)

            v.TabFrame = tab
            tab:SetFrameRef("GwSocialWindow", GwSocialWindow)
            tab:SetAttribute("_onclick", v.OnClick)
            container:SetScript("OnShow", container_OnShow)
            container:SetScript("OnHide", container_OnHide)

            GW[v.OnLoad](container)

            tabIndex = tabIndex + 1
        end
    end

    -- set bindings on secure instead of social win to not interfere with secure ESC binding on social win
    click_OnEvent(GwSocialWindow.secure, "UPDATE_BINDINGS")
end
GW.LoadSocialFrame = LoadSocialFrame
