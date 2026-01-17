local _, GW = ...

local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
local WOW_PROJECT_CLASSIC = 2
local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE
local WOW_PROJECT_WRATH_CLASSIC = 11
local WOW_PROJECT_CATACLYSM_CLASSIC = 14
local WOW_PROJECT_MISTS_CLASSIC = 19

local cache = {}

local MediaPath = "Interface/AddOns/GW2_UI/Textures/social/"

local delimiter = format("|cff%s | |r", "979fad")

GW.friendsList = {}
GW.friendsList.projectCodes = {
    ["ANBS"] = "Diablo Immortal",
    ["Hero"] = "Heroes of the Storm",
    ["OSI"] = "Diablo II",
    ["S2"] = "StarCraft II",
    ["VIPR"] = "Call of Duty: Black Ops 4",
    ["W3"] = "WarCraft III",
    ["APP"] = "Battle.net App",
    ["FORE"] = "Call of Duty: Vanguard",
    ["LAZR"] = "Call of Duty: MW2 Campaign Remastered",
    ["RTRO"] = "Blizzard Arcade Collection",
    ["WLBY"] = "Crash Bandicoot 4: It's About Time",
    ["WTCG"] = "Hearthstone",
    ["ZEUS"] = "Call of Duty: Blac Ops Cold War",
    ["D3"] = "Diablo III",
    ["GRY"] = "Warcraft Arclight Rumble",
    ["ODIN"] = "Call of Duty: Mordern Warfare II",
    ["S1"] = "StarCraft",
    ["WOW"] = "World of Warcraft",
    ["PRO"] = "Overwatch",
    ["PRO-ZHCN"] = "Overwatch",
}

GW.friendsList.clientData = {
    ["Diablo Immortal"] = {
        color = { r = 0.768, g = 0.121, b = 0.231 },
    },
    ["Heroes of the Storm"] = {
        color = { r = 0, g = 0.8, b = 1 },
    },
    ["Diablo II"] = {
        color = { r = 0.768, g = 0.121, b = 0.231 },
    },
    ["StarCraft II"] = {
        color = { r = 0.749, g = 0.501, b = 0.878 },
    },
    ["Call of Duty: Black Ops 4"] = {
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["WarCraft III"] = {
        color = { r = 0.796, g = 0.247, b = 0.145 },
    },
    ["Battle.net App"] = {
        color = { r = 0.509, g = 0.772, b = 1 },
    },
    ["Call of Duty: Vanguard"] = {
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["Call of Duty: MW2 Campaign Remastered"] = {
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["Blizzard Arcade Collection"] = {
        color = { r = 0.509, g = 0.772, b = 1 },
    },
    ["Crash Bandicoot 4: It's About Time"] = {
        color = { r = 0.509, g = 0.772, b = 1 },
    },
    ["Hearthstone"] = {
        color = { r = 1, g = 0.694, b = 0 },
    },
    ["Call of Duty: Blac Ops Cold War"] = {
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["Diablo III"] = {
        color = { r = 0.768, g = 0.121, b = 0.231 },
    },
    ["Warcraft Arclight Rumble"] = {
        color = { r = 0.945, g = 0.757, b = 0.149 },
    },
    ["Call of Duty: Mordern Warfare II"] = {
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["StarCraft"] = {
        color = { r = 0.749, g = 0.501, b = 0.878 },
    },
    ["World of Warcraft"] = {
        color = { r = 0.866, g = 0.690, b = 0.180 },
    },
    ["Overwatch"] = {
        color = { r = 1, g = 1, b = 1 },
    },
}

GW.friendsList.timerunningSeasonIcon = {
    [2] = MediaPath .. "GameIcons/WOW_LEG",
}

GW.friendsList.expansionData = {
    [WOW_PROJECT_MAINLINE] = {
        name = "Retail",
        suffix = nil,
        maxLevel = GetMaxLevelForPlayerExpansion(),
        icon = MediaPath .. "GameIcons/WOW_Retail",
    },
    [WOW_PROJECT_CLASSIC] = {
        name = "Classic",
        suffix = "Classic",
        maxLevel = 60,
        icon = MediaPath .. "GameIcons/WOW_Classic",
    },
    [WOW_PROJECT_BURNING_CRUSADE_CLASSIC] = {
        name = "TBC",
        suffix = "TBC",
        maxLevel = 70,
        icon = MediaPath .. "GameIcons/WOW_TBC",
    },
    [WOW_PROJECT_WRATH_CLASSIC] = {
        name = "WotLK",
        suffix = "WotLK",
        maxLevel = 80,
        icon = MediaPath .. "GameIcons/WOW_WotLK",
    },
    [WOW_PROJECT_CATACLYSM_CLASSIC] = {
        name = "Cata",
        suffix = "Cata",
        maxLevel = 85,
        icon = MediaPath .. "GameIcons/WOW_Cata",
    },
    [WOW_PROJECT_MISTS_CLASSIC] = {
        name = "MoP",
        suffix = "MoP",
        maxLevel = 90,
        icon = MediaPath .. "GameIcons/WOW_MoP",
    },
}

GW.friendsList.factionIcons = {
    ["Alliance"] = MediaPath .. "GameIcons/Alliance",
    ["Horde"] = MediaPath .. "GameIcons/Horde",
}

GW.friendsList.statusIcons = {
    default = {
        Online = FRIENDS_TEXTURE_ONLINE,
        Offline = FRIENDS_TEXTURE_OFFLINE,
        DND = FRIENDS_TEXTURE_DND,
        AFK = FRIENDS_TEXTURE_AFK,
    },
    square = {
        Online = MediaPath .. "StatusIcons/Square/Online",
        Offline = MediaPath .. "StatusIcons/Square/Offline",
        DND = MediaPath .. "StatusIcons/Square/DND",
        AFK = MediaPath .. "StatusIcons/Square/AFK",
    },
    color = {
        Online  = { Color = {0.243, 0.57, 1} },
        Offline = { Color = {0.486, 0.518, 0.541} },
        DND     = { Color = {1, 0, 0} },
        AFK     = { Color = {1, 1, 0} },
    },
}

local StatusColor = {}
for name, info in next, GW.friendsList.statusIcons.color do
    local r, g, b = unpack(info.Color)
    StatusColor[name] = {
        Inside = CreateColor(r, g, b, 0.15),
        Outside = CreateColor(r, g, b, 0)
    }
end

local function SetGradientColor(button, color1, color2)
    button.Left:SetGradient("Horizontal", color1, color2)
    button.Right:SetGradient("Horizontal", color2, color1)
end

local function CreateOrUpdateTexture(button, type, layer)
    if button.efl and button.efl[type] then
        button.efl[type].Left:SetTexture("Interface/Addons/GW2_UI/textures/uistuff/gwstatusbar.png")
        button.efl[type].Right:SetTexture("Interface/Addons/GW2_UI/textures/uistuff/gwstatusbar.png")
        return
    end

    button.efl = button.efl or {}
    button.efl[type] = {}

    button.efl[type].Left = button:CreateTexture(nil, layer)
    button.efl[type].Left:SetHeight(32)
    button.efl[type].Left:SetPoint("LEFT", button, "CENTER")
    button.efl[type].Left:SetPoint("TOPLEFT", button, "TOPLEFT")
    button.efl[type].Left:SetTexture("Interface/Buttons/WHITE8X8")

    button.efl[type].Right = button:CreateTexture(nil, layer)
    button.efl[type].Right:SetHeight(32)
    button.efl[type].Right:SetPoint("RIGHT", button, "CENTER")
    button.efl[type].Right:SetPoint("TOPRIGHT", button, "TOPRIGHT")
    button.efl[type].Right:SetTexture("Interface/Buttons/WHITE8X8")

end
local function HandleInviteTexNormal(self)
    self:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-down.png")
    self:SetTexCoord(0, 1, 0, 1)
    self:SetSize(16, 16)
    self:ClearAllPoints()
    self:SetPoint("CENTER")
    self:SetVertexColor(1, 1, 1, 1)
end

local function HandleInviteTexDisabled(self)
    self:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-down.png")
    self:SetTexCoord(0, 1, 0, 1)
    self:SetSize(18, 18)
    self:ClearAllPoints()
    self:SetPoint("CENTER")
    self:SetVertexColor(0.4, 0.4, 0.4, 1)
    self:SetDesaturated(true)
end

local function UpdateFriendButton(button)
    if not button.isSkinned then
        local normal = button.travelPassButton:GetNormalTexture()
        normal:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-down.png")
        normal:SetTexCoord(0, 1, 0, 1)
        normal:SetSize(18, 18)
        normal:ClearAllPoints()
        normal:SetPoint("CENTER")
        normal:SetVertexColor(1, 1, 1, 1)

        local disabled = button.travelPassButton:GetDisabledTexture()
        disabled:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-down.png")
        disabled:SetTexCoord(0, 1, 0, 1)
        disabled:SetSize(18, 18)
        disabled:ClearAllPoints()
        disabled:SetPoint("CENTER")
        disabled:SetVertexColor(0.4, 0.4, 0.4, 1)
        disabled:SetDesaturated(true)

        local highlight = button.travelPassButton:GetHighlightTexture()
        highlight:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-up.png")
        highlight:SetTexCoord(0, 1, 0, 1)
        highlight:SetSize(18, 18)
        highlight:ClearAllPoints()
        highlight:SetPoint("CENTER")
        highlight:SetVertexColor(1, 1, 1, 1)

        if GW.Retail then
            hooksecurefunc(button.travelPassButton.NormalTexture, "SetAtlas", HandleInviteTexNormal)
            hooksecurefunc(button.travelPassButton.DisabledTexture, "SetAtlas", HandleInviteTexDisabled)
        end

        button.isSkinned = true
    end


    if button.buttonType == FRIENDS_BUTTON_TYPE_DIVIDER then
        return
    end

    local gameName, realID, name, server, class, area, level, faction, status, wowID, timerunningSeasonID

    if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        -- WoW friends
        wowID = WOW_PROJECT_MAINLINE
        gameName = GW.friendsList.projectCodes["WOW"]
        local friendInfo = C_FriendList.GetFriendInfoByIndex(button.id)
        name, server = strsplit("-", friendInfo.name)
        level = friendInfo.level
        class = friendInfo.className
        area = friendInfo.area
        faction = GW.myfaction

        if friendInfo.connected then
            if friendInfo.afk then
                status = "AFK"
            elseif friendInfo.dnd then
                status = "DND"
            else
                status = "Online"
            end
        else
            status = "Offline"
        end
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET and BNConnected() then
        -- Battle.net friends
        local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
        if friendAccountInfo then
            realID = friendAccountInfo.accountName

            local gameAccountInfo = friendAccountInfo.gameAccountInfo
            gameName = GW.friendsList.projectCodes[strupper(gameAccountInfo.clientProgram)]

            if gameAccountInfo.isOnline then
                if friendAccountInfo.isAFK or gameAccountInfo.isGameAFK then
                    status = "AFK"
                elseif friendAccountInfo.isDND or gameAccountInfo.isGameBusy then
                    status = "DND"
                else
                    status = "Online"
                end
            else
                status = "Offline"
            end

            -- Fetch version if friend playing WoW
            if gameName == "World of Warcraft" then
                wowID = gameAccountInfo.wowProjectID
                name = gameAccountInfo.characterName or ""
                level = gameAccountInfo.characterLevel or 0
                faction = gameAccountInfo.factionName or nil
                class = gameAccountInfo.className or ""
                area = gameAccountInfo.areaName or ""
                timerunningSeasonID = gameAccountInfo.timerunningSeasonID or ""

                if wowID and wowID ~= 1 and GW.friendsList.expansionData[wowID] then
                    local suffix = GW.friendsList.expansionData[wowID].suffix and " (" .. GW.friendsList.expansionData[wowID].suffix .. ")" or ""
                    local serverStrings = { strsplit(" - ", gameAccountInfo.richPresence) }
                    server = (serverStrings[#serverStrings] or BNET_FRIEND_TOOLTIP_WOW_CLASSIC) .. suffix .. "*"
                elseif wowID and wowID == 1 and name == "" then
                    server = gameAccountInfo.richPresence -- Plunderstorm
                else
                    server = gameAccountInfo.realmDisplayName or ""
                end
            end
        end
    end

    if status then
        button.status:SetTexture(GW.friendsList.statusIcons.square[status])
    end

    button.gameIcon:SetTexCoord(0, 1, 0, 1)

    if gameName then
        local buttonTitle, buttonText

        -- real ID
        local clientColor = GW.friendsList.clientData[gameName] and GW.friendsList.clientData[gameName].color
        local realIDString = realID and clientColor and GW.StringWithRGB(realID, clientColor) or realID

        -- name
        local classColor = GW.GWGetClassColor(GW.UnlocalizedClassName(class), true, true, true)
        local nameString = name and classColor and GW.StringWithRGB(name, classColor) or name
        if TimerunningUtil and timerunningSeasonID and timerunningSeasonID ~= "" and nameString ~= nil then
            nameString = TimerunningUtil.AddSmallIcon(nameString) or nameString -- add timerunning tag
        end

        if wowID and GW.friendsList.expansionData[wowID] and level and level ~= 0 then
            nameString = nameString .. GW.StringWithRGB(delimiter .. level, GetQuestDifficultyColor(level))
        end

        -- combine Real ID and Name
        if nameString and nameString ~= "" and realIDString and realIDString ~= "" then
            buttonTitle = realIDString .. delimiter .. nameString
        elseif nameString and nameString ~= "" then
            buttonTitle = nameString
        else
            buttonTitle = realIDString or ""
        end

        button.name:SetText(buttonTitle)

        -- area
        if area then
            if area ~= "" and server and server ~= "" and server ~= GW.myrealm then
                buttonText = GW.StringWithRGB(area .. " - " .. server, {r = 1, g = 1, b = 1})
            elseif area ~= "" then
                buttonText = GW.StringWithRGB(area, {r = 1, g = 1, b = 1})
            else
                buttonText = server or ""
            end

            button.info:SetText(buttonText)
        end

        -- game icon
        local texOrAtlas
        if wowID and GW.friendsList.expansionData[wowID] then
            texOrAtlas = GW.friendsList.expansionData[wowID].icon
            if wowID == WOW_PROJECT_MAINLINE and timerunningSeasonID and GW.friendsList.timerunningSeasonIcon[timerunningSeasonID] then
                texOrAtlas = GW.friendsList.timerunningSeasonIcon[timerunningSeasonID]
            end
        end

        if texOrAtlas == nil and faction and GW.friendsList.factionIcons[faction] then
            texOrAtlas = GW.friendsList.factionIcons[faction]
        end

        if texOrAtlas then
            button.gameIcon:SetAlpha(1)
            button.gameIcon:SetTexture(texOrAtlas)
            button.gameIcon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
        end
    end

    if not cache.name then
        local fontName, size, style = button.name:GetFont()
        cache.name = {
            name = fontName,
            size = size,
            style = style,
        }
    end

    if not cache.info then
        local fontName, size, style = button.info:GetFont()
        cache.info = {
            name = fontName,
            size = size,
            style = style,
        }
    end

    button.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)

    button.background:Hide()
    CreateOrUpdateTexture(button, "background", "BACKGROUND")
    SetGradientColor(button.efl.background, StatusColor[status].Inside, StatusColor[status].Outside)

    button.highlight:SetVertexColor(0, 0, 0, 0)
    CreateOrUpdateTexture(button, "highlight", "HIGHLIGHT")
    SetGradientColor(button.efl.highlight, StatusColor[status].Inside, StatusColor[status].Outside)

    if button.Favorite and button.Favorite:IsShown() then
        button.Favorite:ClearAllPoints()
        button.Favorite:SetPoint("LEFT", button.name, "LEFT", button.name:GetStringWidth(), 0)
    end

    button:SetSize(460, 34)
    button.name:SetWidth(400)
end

local function LoadFriendList(tabContainer)
    local GWFriendFrame = CreateFrame("Frame", "GWFriendFrame", tabContainer, "GWFriendFrame")
    GWFriendFrame.Container = tabContainer

    GWFriendFrame:SetScript("OnShow", function()
        local onGlues = C_Glue.IsOnGlueScreen()
        local inPlunderstorm = C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm
        if GW.Retail and not onGlues and not inPlunderstorm then
            FriendsFrame_CheckQuickJoinHelpTip()
            FriendsFrame_UpdateQuickJoinTab(#C_SocialQueue.GetAllGroups())
            C_GuildInfo.GuildRoster()
        end
        FriendsList_Update(true)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
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

    if GW.Retail then
        FriendsListFrame.ScrollBox:SetParent(GWFriendFrame.list)
        FriendsListFrame.ScrollBox:ClearAllPoints()
        FriendsListFrame.ScrollBox:SetAllPoints(GWFriendFrame.list)
        FriendsListFrame.ScrollBox.SetParent = GW.NoOp
        FriendsListFrame.ScrollBox.ClearAllPoints = GW.NoOp
        FriendsListFrame.ScrollBox.SetAllPoints = GW.NoOp
        FriendsListFrame.ScrollBox.SetPoint = GW.NoOp

        GW.HandleTrimScrollBar(FriendsListFrame.ScrollBar, true)
        GW.HandleScrollControls(FriendsListFrame)
        hooksecurefunc(FriendsListFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
    elseif GW.TBC then
        FriendsFrameFriendsScrollFrame:SetParent(GWFriendFrame.list)
        FriendsFrameFriendsScrollFrame:ClearAllPoints()
        FriendsFrameFriendsScrollFrame:SetAllPoints(GWFriendFrame.list)
        FriendsFrameFriendsScrollFrame.SetParent = GW.NoOp
        FriendsFrameFriendsScrollFrame.ClearAllPoints = GW.NoOp
        FriendsFrameFriendsScrollFrame.SetAllPoints = GW.NoOp
        FriendsFrameFriendsScrollFrame.SetPoint = GW.NoOp
        HybridScrollFrame_CreateButtons(FriendsFrameFriendsScrollFrame, "FriendsFrameButtonTemplate")

        FriendsFrameFriendsScrollFrameScrollBar:GwSkinScrollBar()
        FriendsFrameFriendsScrollFrame:GwSkinScrollFrame()

        FriendsFrameFriendsScrollFrameScrollBar:ClearAllPoints()
        FriendsFrameFriendsScrollFrameScrollBar:SetPoint("TOPRIGHT", GWFriendFrame.list, "TOPRIGHT", 24, -10)
        FriendsFrameFriendsScrollFrameScrollBar:SetPoint("BOTTOMRIGHT", GWFriendFrame.list, "BOTTOMRIGHT", 24, 10)
    end

    FriendsListFrame.RIDWarning:SetParent(GWFriendFrame.list)
    FriendsListFrame.RIDWarning:ClearAllPoints()
    FriendsListFrame.RIDWarning:SetAllPoints(GWFriendFrame.list)

    FriendsListFrame:SetParent(GWFriendFrame.list)
    FriendsListFrame:ClearAllPoints()
    FriendsListFrame:SetAllPoints(GWFriendFrame.list)

    FriendsFrameAddFriendButton:SetParent(GWFriendFrame.list)
    FriendsFrameAddFriendButton:ClearAllPoints()
    FriendsFrameAddFriendButton:SetPoint("BOTTOMLEFT", GWFriendFrame.list, "BOTTOMLEFT", 4, -40)
    FriendsFrameAddFriendButton:GwSkinButton(false, true)

    FriendsFrameSendMessageButton:SetParent(GWFriendFrame.list)
    FriendsFrameSendMessageButton:ClearAllPoints()
    FriendsFrameSendMessageButton:SetPoint("BOTTOMRIGHT", GWFriendFrame.list, "BOTTOMRIGHT", -4, -40)
    FriendsFrameSendMessageButton:GwSkinButton(false, true)

    FriendsTooltip:SetParent(GWFriendFrame.list)
    hooksecurefunc("FriendsFrame_UpdateFriendButton", UpdateFriendButton)

    --View Friends BN Frame
    local button = CreateFrame("Button", nil, FriendsFrameBattlenetFrame)
    button:SetAllPoints()
    button:GwCreateBackdrop(nil, true)
    button:GwSkinButton(false, false, true)

    button.Tag = button:CreateFontString(nil, "OVERLAY")
    button.Tag:SetPoint("CENTER", button, "CENTER")
    button.Tag:SetTextColor(0.345, 0.667, 0.867)
    button.Tag:SetFont(UNIT_NAME_FONT, 15)
    button.hover.r = FRIENDS_BNET_BACKGROUND_COLOR.r
    button.hover.g = FRIENDS_BNET_BACKGROUND_COLOR.g
    button.hover.b = FRIENDS_BNET_BACKGROUND_COLOR.b

    FriendsFriendsFrame:GwStripTextures()
    FriendsFriendsFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    FriendsFriendsFrameDropdown:GwHandleDropDownBox()
    if GW.Retail then
        FriendsFriendsFrame.ScrollFrameBorder:Hide()

        FriendsFriendsFrame.SendRequestButton:GwSkinButton(false, true)
        FriendsFriendsFrame.CloseButton:GwSkinButton(false, true)

        GW.HandleTrimScrollBar(FriendsFriendsFrame.ScrollBar, true)
        GW.HandleScrollControls(FriendsFriendsFrame)

        FriendsFrameBattlenetFrame.ContactsMenuButton:GwHandleDropDownBox(GW.BackdropTemplates.ColorableBorderOnly, nil, nil, 32)
        FriendsFrameBattlenetFrame.ContactsMenuButton.backdrop:SetBackdropBorderColor(0, 0, 0, 0)
        FriendsFrameBattlenetFrame.ContactsMenuButton.gw2Arrow:SetPoint("CENTER")
        FriendsFrameBattlenetFrame.ContactsMenuButton.gw2Arrow:SetSize(28, 28)

        button:SetScript("OnClick", function() FriendsFrameBattlenetFrame.BroadcastFrame:ToggleFrame() end)
    elseif GW.TBC then
        FriendsFriendsSendRequestButton:GwSkinButton(false, true)
        FriendsFriendsCloseButton:GwSkinButton(false, true)

        button:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_CHAT_EMOTE_BUTTON)
            if FriendsFrameBattlenetFrame.BroadcastFrame:IsShown() then
                FriendsFrameBattlenetFrame_HideBroadcastFrame()
            else
                FriendsFrameBattlenetFrame_ShowBroadcastFrame()
            end
        end)
    end

    FriendsFrameBattlenetFrame:GwStripTextures()
    FriendsFrameBattlenetFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    FriendsFrameBattlenetFrame.Tag:GwKill()

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
    FriendsFrameBattlenetFrame.BroadcastFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame.BroadcastFrame:SetPoint("TOPLEFT", GWFriendFrame.headerBN, "TOPRIGHT", 45, 1)
    if GW.Retail then
        FriendsFrameBattlenetFrame.BroadcastFrame.EditBox:GwStripTextures()
        GW.HandleBlizzardRegions(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox)
        GW.SkinTextBox(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.MiddleBorder, FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.LeftBorder, FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.RightBorder, nil, nil, 5, 5)
        FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton:GwSkinButton(false, true)
        FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton:GwSkinButton(false, true)
    elseif GW.TBC then
        FriendsFrameBattlenetFrame.BroadcastButton:GwKill()
        FriendsFrameBattlenetFrameScrollFrame:GwStripTextures()
        GW.HandleBlizzardRegions(FriendsFrameBattlenetFrameScrollFrame)
        GW.SkinTextBox(FriendsFrameBattlenetFrameScrollFrame.MiddleBorder, FriendsFrameBattlenetFrameScrollFrame.LeftBorder, FriendsFrameBattlenetFrameScrollFrame.RightBorder, nil, nil, 5, 5)
        FriendsFrameBattlenetFrameScrollFrame.UpdateButton:GwSkinButton(false, true)
        FriendsFrameBattlenetFrameScrollFrame.CancelButton:GwSkinButton(false, true)
    end

    AddFriendFrame:GwStripTextures()
    AddFriendFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    AddFriendEntryFrameAcceptButton:GwSkinButton(false, true)
    AddFriendEntryFrameCancelButton:GwSkinButton(false, true)
    GW.SkinTextBox(_G["AddFriendNameEditBoxMiddle"], _G["AddFriendNameEditBoxLeft"], _G["AddFriendNameEditBoxRight"])
    FriendsFrameBattlenetFrame.UnavailableInfoFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame.UnavailableInfoFrame:SetPoint("TOPLEFT", GWFriendFrame.headerBN, "TOPRIGHT", 1, -18)

    if GW.Retail then
        RecruitAFriendRecruitmentFrame:GwStripTextures()
        RecruitAFriendRecruitmentFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
        GW.SkinTextBox(RecruitAFriendRecruitmentFrame.EditBox.Middle, RecruitAFriendRecruitmentFrame.EditBox.Left, RecruitAFriendRecruitmentFrame.EditBox.Right)
        RecruitAFriendRecruitmentFrame.GenerateOrCopyLinkButton:GwSkinButton(false, true)
        RecruitAFriendRecruitmentFrame.CloseButton:GwSkinButton(true)
        RecruitAFriendRecruitmentFrame.CloseButton:SetSize(15, 15)
    end

    SlashCmdList["FRIENDS"] = function(msg)
        if InCombatLockdown() then return end

        if msg == "" and UnitIsPlayer("target") then
            msg = GetUnitName("target", true)
        end
        if not msg or msg == "" then
            GwSocialWindow:SetAttribute("windowpanelopen", "friendlist")
        else
            local player, note = strmatch(msg, "%s*([^%s]+)%s*(.*)")
            if player then
                C_FriendList.AddOrRemoveFriend(player, note)
            end
        end
    end
end
GW.LoadFriendList = LoadFriendList
