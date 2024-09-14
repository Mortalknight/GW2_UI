local _, GW = ...

local atlasToTex = {
    ["friendslist-invitebutton-horde-normal"] = [[Interface\FriendsFrame\PlusManz-Horde]],
    ["friendslist-invitebutton-alliance-normal"] = [[Interface\FriendsFrame\PlusManz-Alliance]],
    ["friendslist-invitebutton-default-normal"] = [[Interface\FriendsFrame\PlusManz-PlusManz]],
}

local MediaPath = 'Interface/AddOns/GW2_UI/Textures/social/'
local ONE_MINUTE = 60;
local ONE_HOUR = 60 * ONE_MINUTE;
local ONE_DAY = 24 * ONE_HOUR;
local ONE_MONTH = 30 * ONE_DAY;
local ONE_YEAR = 12 * ONE_MONTH;
local icons = {
    Game = {
        Alliance = { Name = _G.FACTION_ALLIANCE, Order = 1, Launcher = MediaPath..'GameIcons/Launcher/Alliance' },
        Horde = { Name = _G.FACTION_HORDE, Order = 2,  Launcher = MediaPath..'GameIcons/Launcher/Horde' },
        Neutral = { Name = _G.FACTION_STANDING_LABEL4, Order = 3, Launcher = MediaPath..'GameIcons/Launcher/WoW' },
        App = { Name = GW.L['App'], Order = 4, Color = '82C5FF', Launcher = MediaPath..'GameIcons/Launcher/BattleNet' },
        BSAp = { Name = GW.L['Mobile'], Order = 5, Color = '82C5FF', Launcher = MediaPath..'GameIcons/Launcher/Mobile' },
        D3 = { Name = GW.L['Diablo 3'], Color = 'C41F3B', Launcher = MediaPath..'GameIcons/Launcher/D3' },
        Fen = { Name = GW.L['Diablo 4'], Color = 'C41F3B', Launcher = MediaPath..'GameIcons/Launcher/D4' },
        WTCG = { Name = GW.L['Hearthstone'], Color = 'FFB100', Launcher = MediaPath..'GameIcons/Launcher/Hearthstone' },
        S1 = { Name = GW.L['Starcraft'], Color = 'C495DD', Launcher = MediaPath..'GameIcons/Launcher/SC' },
        S2 = { Name = GW.L['Starcraft 2'], Color = 'C495DD', Launcher = MediaPath..'GameIcons/Launcher/SC2' },
        Hero = { Name = GW.L['Hero of the Storm'], Color = '00CCFF', Launcher = MediaPath..'GameIcons/Launcher/Heroes' },
        Pro = { Name = GW.L['Overwatch'], Color = 'FFFFFF', Launcher = MediaPath..'GameIcons/Launcher/Overwatch' },
        VIPR = { Name = GW.L['Call of Duty 4'], Color = 'FFFFFF', Launcher = MediaPath..'GameIcons/Launcher/COD4' },
        ODIN = { Name = GW.L['Call of Duty Modern Warfare'], Color = 'FFFFFF', Launcher = MediaPath..'GameIcons/Launcher/CODMW' },
        W3 = { Name = GW.L['Warcraft 3 Reforged'], Color = 'FFFFFF', Launcher = MediaPath..'GameIcons/Launcher/WC3R' },
        LAZR = { Name = GW.L['Call of Duty Modern Warfare 2'], Color = 'FFFFFF', Launcher = MediaPath..'GameIcons/Launcher/CODMW2' },
        ZEUS = { Name = GW.L['Call of Duty Cold War'], Color = 'FFFFFF', Launcher = MediaPath..'GameIcons/Launcher/CODCW' },
        WLBY = { Name = GW.L['Crash Bandicoot 4'], Color = 'FFFFFF', Launcher = MediaPath..'GameIcons/Launcher/CB4' },
        OSI = { Name = GW.L['Diablo II Resurrected'], Color = 'FFFFFF', Launcher = MediaPath..'GameIcons/Launcher/D2' },
        FORE = { Name = GW.L['Call of Duty Vanguard'], Color = 'FFFFFF', Launcher = MediaPath..'GameIcons/Launcher/CODVanguard' },
        RTRO = { Name = GW.L['Arcade Collection'], Color = 'FFFFFF', Launcher = MediaPath..'GameIcons/Launcher/Arcade' },
        ANBS = { Name = GW.L['Diablo Immortal'], Color = 'C41F3B', Launcher = MediaPath..'GameIcons/Launcher/DI' },
        GRY = { Name = GW.L['Warcraft Arclight Rumble'], Color = 'FFFFFF', Launcher = MediaPath..'GameIcons/Launcher/Arclight' },
    },
    Status = {
        Online = { Name = _G.FRIENDS_LIST_ONLINE, Order = 1, Default = _G.FRIENDS_TEXTURE_ONLINE, Square = MediaPath..'StatusIcons/Square/Online', D3 = MediaPath..'StatusIcons/D3/Online', Color = {.243, .57, 1} },
        Offline = { Name = _G.FRIENDS_LIST_OFFLINE, Order = 2, Default = _G.FRIENDS_TEXTURE_OFFLINE, Square = MediaPath..'StatusIcons/Square/Offline', D3 = MediaPath..'StatusIcons/D3/Offline', Color = {.486, .518, .541} },
        DND = { Name = _G.DEFAULT_DND_MESSAGE, Order = 3, Default = _G.FRIENDS_TEXTURE_DND, Square = MediaPath..'StatusIcons/Square/DND', D3 = MediaPath..'StatusIcons/D3/DND', Color = {1, 0, 0} },
        AFK = { Name = _G.DEFAULT_AFK_MESSAGE, Order = 4, Default = _G.FRIENDS_TEXTURE_AFK, Square = MediaPath..'StatusIcons/Square/AFK', D3 = MediaPath..'StatusIcons/D3/AFK', Color = {1, 1, 0} },
    }
}

local StatusColor = {}
for name, info in next, icons.Status do
    local r, g, b = unpack(info.Color)
    StatusColor[name] = { Inside = CreateColor(r, g, b, .15), Outside = CreateColor(r, g, b, .0)}
end

local function SetGradientColor(button, color1, color2)
    button.Left:SetGradient("Horizontal", color1, color2)
    button.Right:SetGradient("Horizontal", color2, color1)
end

local function CreateTexture(button, type, layer)
    if button.efl and button.efl[type] then
        button.efl[type].Left:SetTexture("Interface/Addons/GW2_UI/textures/uistuff/gwstatusbar")
        button.efl[type].Right:SetTexture("Interface/Addons/GW2_UI/textures/uistuff/gwstatusbar")
        return
    end

    button.efl = button.efl or {}
    button.efl[type] = {}

    button.efl[type].Left = button:CreateTexture(nil, layer)
    button.efl[type].Left:SetHeight(32)
    button.efl[type].Left:SetPoint("LEFT", button, "CENTER")
    button.efl[type].Left:SetPoint("TOPLEFT", button, "TOPLEFT")
    button.efl[type].Left:SetTexture('Interface/Buttons/WHITE8X8')

    button.efl[type].Right = button:CreateTexture(nil, layer)
    button.efl[type].Right:SetHeight(32)
    button.efl[type].Right:SetPoint("RIGHT", button, "CENTER")
    button.efl[type].Right:SetPoint("TOPRIGHT", button, "TOPRIGHT")
    button.efl[type].Right:SetTexture('Interface/Buttons/WHITE8X8')
end

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
        if not InCombatLockdown() then UpdateMicroButtons() end
        FriendsFrame_CheckQuickJoinHelpTip();
        FriendsFrame_UpdateQuickJoinTab(#C_SocialQueue.GetAllGroups())
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        C_GuildInfo.GuildRoster()

        FriendsFrame_Update()
    end)

    FriendsFrameBattlenetFrame:SetParent(GWFriendFrame.headerBN)
    FriendsFrameBattlenetFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame:SetAllPoints(GWFriendFrame.headerBN)

    FriendsFrameStatusDropdown:GwHandleDropDownBox()
    FriendsFrameStatusDropdown:SetWidth(55)
    FriendsFrameStatusDropdown:SetParent(GWFriendFrame.headerDD)
    FriendsFrameStatusDropdown:ClearAllPoints()
    FriendsFrameStatusDropdown:SetPoint("TOPLEFT", GWFriendFrame.headerDD, "TOPLEFT", 5, -2)

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

    GW.HandleTrimScrollBar(FriendsListFrame.ScrollBar, true)
    GW.HandleScrollControls(FriendsListFrame)

    FriendsTooltip:SetParent(GWFriendFrame.list)

    local INVITE_RESTRICTION_NONE = 9
    hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
        if not button.IsSkinned then
            button:SetSize(460, 34)

            button.gameIcon:SetSize(24, 24)
            button.gameIcon:ClearAllPoints()

            button.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
            button.name:SetWidth(400)

            local travelPass = button.travelPassButton
            travelPass:SetSize(22, 22)
            travelPass:SetPoint("TOPRIGHT", -3, -6)
            travelPass:GwCreateBackdrop()
            travelPass.NormalTexture:SetAlpha(0)
            travelPass.PushedTexture:SetAlpha(0)
            travelPass.DisabledTexture:SetAlpha(0)
            travelPass.HighlightTexture:SetColorTexture(1, 1, 1, .25)
            travelPass.HighlightTexture:SetAllPoints()
            button.gameIcon:SetPoint("RIGHT", travelPass, "LEFT", -6, 0)

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

        -- game icon skin
        local nameText, infoText
        local status = 'Offline'
        if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
            local info = C_FriendList.GetFriendInfoByIndex(button.id)
            if info.connected then
                local name, level, class = info.name, info.level, info.className
                local classTag, color = GW.UnlocalizedClassName(class), GW.GWGetClassColor(GW.UnlocalizedClassName(class), true, true, true)
                status = info.dnd and 'DND' or info.afk and 'AFK' or 'Online'
                local diffColor = GetQuestDifficultyColor(level)
                local diff = level ~= 0 and format("FF%02x%02x%02x", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255) or "FFFFFFFF"

                nameText = format('%s |cFFFFFFFF(|r%s - %s %s|cFFFFFFFF)|r', WrapTextInColorCode(name, color), class, LEVEL, WrapTextInColorCode(level, diff))
                infoText = info.area

                if classTag then
                    button.gameIcon:Show()
                    button.gameIcon:SetTexture('Interface/WorldStateFrame/Icons-Classes')
                    button.gameIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classTag]))
                end
            else
                nameText = info.name
            end
            button.status:SetTexture(icons.Status[status].Default)
        elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET and BNConnected() then
            local info = C_BattleNet.GetFriendAccountInfo(button.id)
            if info then
                nameText = info.accountName
                infoText = info.gameAccountInfo.richPresence
                if info.gameAccountInfo.isOnline then
                    local client = info.gameAccountInfo.clientProgram
                    status = info.isDND and 'DND' or info.isAFK and 'AFK' or 'Online'

                    if client == BNET_CLIENT_WOW then
                        local level = info.gameAccountInfo.characterLevel
                        local characterName = info.gameAccountInfo.characterName
                        local classcolor = GW.GWGetClassColor(GW.UnlocalizedClassName(info.gameAccountInfo.className), true, true, true)
                        if characterName then
                            local diffColor = GetQuestDifficultyColor(level)
                            local diff = level ~= 0 and format('FF%02x%02x%02x', diffColor.r * 255, diffColor.g * 255, diffColor.b * 255) or 'FFFFFFFF'
                            nameText = format('%s (%s - %s %s)', nameText, WrapTextInColorCode(characterName, classcolor.colorStr), LEVEL, WrapTextInColorCode(level, diff))
                        end

                        if info.gameAccountInfo.wowProjectID == _G.WOW_PROJECT_CLASSIC and info.gameAccountInfo.realmDisplayName ~= GW.myrealm then
                            infoText = format('%s - %s', info.gameAccountInfo.areaName or _G.UNKNOWN, infoText)
                        elseif info.gameAccountInfo.realmDisplayName == GW.myrealm then
                            infoText = info.gameAccountInfo.areaName
                        end

                        local faction = info.gameAccountInfo.factionName
                        button.gameIcon:SetTexture(faction and icons.Game[faction].Launcher or icons.Game.Neutral.Launcher)
                    else
                        if not icons.Game[client] then client = 'BSAp' end
                        nameText = format('|cFF%s%s|r', icons.Game[client].Color or 'FFFFFF', nameText)
                        button.gameIcon:SetTexture(icons.Game[client].Launcher)
                    end

                    button.gameIcon:SetTexCoord(0, 1, 0, 1)
                    button.gameIcon:SetDrawLayer('ARTWORK')
                    button.gameIcon:SetAlpha(1)
                else
                    local lastOnline = info.lastOnlineTime
                    infoText = (not lastOnline or lastOnline == 0 or time() - lastOnline >= ONE_YEAR) and _G.FRIENDS_LIST_OFFLINE or format(_G.BNET_LAST_ONLINE_TIME, _G.FriendsFrame_GetLastOnline(lastOnline))
                end
                button.status:SetTexture(icons.Status[status].Default)
            end

        end
        if nameText then button.name:SetText(nameText) end
        if infoText then button.info:SetText(infoText) end

        button.background:Hide()

        CreateTexture(button, 'background', 'BACKGROUND')
        SetGradientColor(button.efl.background, StatusColor[status].Inside, StatusColor[status].Outside)

        button.highlight:SetVertexColor(0, 0, 0, 0)

        CreateTexture(button, 'highlight', 'HIGHLIGHT')
        SetGradientColor(button.efl.highlight, StatusColor[status].Inside, StatusColor[status].Outside)

        if button.Favorite and button.Favorite:IsShown() then
            button.Favorite:ClearAllPoints()
            button.Favorite:SetPoint("TOPLEFT", button.name, "TOPLEFT", button.name:GetStringWidth(), 0);
        end

    end)

    --View Friends BN Frame
    FriendsFriendsFrame:GwStripTextures()
    FriendsFriendsFrame.ScrollFrameBorder:Hide()
    FriendsFriendsFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    FriendsFriendsFrameDropdown:GwHandleDropDownBox()
    FriendsFriendsFrame.SendRequestButton:GwSkinButton(false, true)
    FriendsFriendsFrame.CloseButton:GwSkinButton(false, true)
    GW.HandleTrimScrollBar(FriendsFriendsFrame.ScrollBar, true)
    GW.HandleScrollControls(FriendsFriendsFrame)

    FriendsFrameBattlenetFrame.BroadcastButton:GwKill()
    FriendsFrameBattlenetFrame:GwStripTextures()
    FriendsFrameBattlenetFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
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
    FriendsFrameBattlenetFrame.BroadcastFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    FriendsFrameBattlenetFrame.BroadcastFrame.EditBox:GwStripTextures()
    FriendsFrameBattlenetFrame.BroadcastFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame.BroadcastFrame:SetPoint("TOPLEFT", GWFriendFrame.headerBN, "TOPRIGHT", 45, 1)
    GW.HandleBlizzardRegions(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox)
    GW.SkinTextBox(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.MiddleBorder, FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.LeftBorder, FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.RightBorder, nil, nil, 5, 5)
    FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton:GwSkinButton(false, true)
    FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton:GwSkinButton(false, true)

    AddFriendFrame:GwStripTextures()
    AddFriendFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    AddFriendEntryFrameAcceptButton:GwSkinButton(false, true)
    AddFriendEntryFrameCancelButton:GwSkinButton(false, true)
    AddFriendInfoFrameContinueButton:GwSkinButton(false, true)
    GW.SkinTextBox(_G["AddFriendNameEditBoxMiddle"], _G["AddFriendNameEditBoxLeft"], _G["AddFriendNameEditBoxRight"])
    FriendsFrameBattlenetFrame.UnavailableInfoFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame.UnavailableInfoFrame:SetPoint("TOPLEFT", GWFriendFrame.headerBN, "TOPRIGHT", 1, -18)

    RecruitAFriendRecruitmentFrame:GwStripTextures()
    RecruitAFriendRecruitmentFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
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
