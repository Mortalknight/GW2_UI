local _, GW = ...


local friendsFrameTabsAdded = 0
local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
local WOW_PROJECT_CLASSIC = 2
local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE
local WOW_PROJECT_WRATH_CLASSIC = 11
local WOW_PROJECT_CATACLYSM_CLASSIC = 14
local WOW_PROJECT_MISTS_CLASSIC = 19


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
        maxLevel = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion() or GetMaxPlayerLevel()),
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


local function ReskinWhoFrameButton(button)
    if not button.isSkinned then
        button.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        button.Variable:SetFont(UNIT_NAME_FONT, 11)
        button.Level:SetFont(UNIT_NAME_FONT, 11)
        button.Class:SetFont(UNIT_NAME_FONT, 11)
        GW.AddListItemChildHoverTexture(button)
        button.isSkinned = true
    end
end

local function ReskinRecentAllyButton(button)
    if not button.isSkinned then
        local normal = button.PartyButton:GetNormalTexture()
        normal:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-down.png")
        normal:SetTexCoord(0, 1, 0, 1)
        normal:SetSize(18, 18)
        normal:ClearAllPoints()
        normal:SetPoint("CENTER")
        normal:SetVertexColor(1, 1, 1, 1)

        local disabled = button.PartyButton:GetDisabledTexture()
        disabled:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-down.png")
        disabled:SetTexCoord(0, 1, 0, 1)
        disabled:SetSize(18, 18)
        disabled:ClearAllPoints()
        disabled:SetPoint("CENTER")
        disabled:SetVertexColor(0.4, 0.4, 0.4, 1)
        disabled:SetDesaturated(true)

        local highlight = button.PartyButton:GetHighlightTexture()
        highlight:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-up.png")
        highlight:SetTexCoord(0, 1, 0, 1)
        highlight:SetSize(18, 18)
        highlight:ClearAllPoints()
        highlight:SetPoint("CENTER")
        highlight:SetVertexColor(1, 1, 1, 1)

        button.isSkinned = true
    end

    local data = button.elementData
    if not data then
        return
    end

    local status
    local stateData = data.stateData
    if stateData.isOnline then
        if stateData.isAFK then
            status = "AFK"
        elseif stateData.isDND then
            status = "DND"
        else
            status = "Online"
        end
    else
        status = "Offline"
    end

    if status then
        if GW.friendsList.statusIcons.default[status] then
            button.OnlineStatusIcon:SetTexture(GW.friendsList.statusIcons.square[status])
        end
    end

    local CharacterData = button.CharacterData
    if not CharacterData then
        return
    end
    local characterData = data.characterData

    if CharacterData.Name then
        for _, key in pairs({ "NameDivider", "Level", "LevelDivider", "Class" }) do
            if CharacterData[key] then
                CharacterData[key]:Hide()
            end
        end

        local classFile = characterData and characterData.classID and select(2, GetClassInfo(characterData.classID))
        local nameString
        if stateData.isOnline and characterData.name then
            local classcolor = GW.GWGetClassColor(classFile, true, true, true)
            nameString = WrapTextInColorCode(characterData.name, classcolor.colorStr)
        else
            nameString = format("|cff%s%s|r", "979fad", characterData.name)
        end

        local level = characterData.level
        if level then
            if stateData.isOnline then
                nameString = nameString .. GW.StringWithRGB(delimiter .. level, GetQuestDifficultyColor(level))
            else
                nameString = nameString .. delimiter ..  format("|cff%s%s|r", "979fad", level)
            end
        end

        if nameString then
            CharacterData.Name:SetText(nameString)
        end

        CharacterData.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        CharacterData.Name.maxWidth = button:GetWidth() - 60
        CharacterData.Name:SetWidth(CharacterData.Name.maxWidth)
    end

    if CharacterData.MostRecentInteraction then
        CharacterData.MostRecentInteraction:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    end

    if CharacterData.Location then
        if stateData.currentLocation then
            local realmName = characterData.realmName or ""

            local locationText
            if stateData.currentLocation and stateData.currentLocation ~= "" and realmName and realmName ~= "" and realmName ~= GW.myrealm then
                locationText = stateData.currentLocation .. " - " .. realmName
            elseif stateData.currentLocation and stateData.currentLocation ~= "" then
                locationText = stateData.currentLocation
            else
                locationText = realmName or ""
            end

            if not stateData.isOnline then
                locationText = GW.StringWithRGB(characterData.name, {r = 0.49, g = 0.52, b = 0.54})
            else
                locationText = GW.StringWithRGB(locationText, {r = 0.49, g = 0.52, b = 0.54})
            end

            CharacterData.Location:SetText(locationText)
        end

        CharacterData.Location:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    end
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

local function HandleTabs()
    for idx, tab in ipairs({FriendsFrameTab1, FriendsFrameTab2, FriendsFrameTab3, FriendsFrameTab4}) do
        if not tab.isSkinned then
            local iconName = idx == 1 and "tabicon_friends" or idx == 2 and "tabicon_who" or idx == 3 and "tabicon_raid" or "tabicon_quickjoin"

            local iconTexture = "Interface/AddOns/GW2_UI/textures/social/" .. iconName .. ".png"
            GW.SkinSideTabButton(tab, iconTexture, tab:GetText())
        end

        tab:ClearAllPoints()
        tab:SetPoint("TOPRIGHT", FriendsFrame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * friendsFrameTabsAdded))
        tab:SetParent(FriendsFrame.LeftSidePanel)
        tab:SetSize(64, 40)

        if idx == 4 then
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

        friendsFrameTabsAdded = friendsFrameTabsAdded + 1
    end
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

    button.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    button.info:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -1)

    if button.Favorite and button.Favorite:IsShown() then
        button.Favorite:ClearAllPoints()
        button.Favorite:SetPoint("LEFT", button.name, "LEFT", button.name:GetStringWidth(), 0)
    end

    button:SetSize(460, 34)
    button.name:SetWidth(400)
end

local function RAFRewardQuality(button)
    local color = button.item and button.item:GetItemQualityColor()
    if color and button.Icon then
        button.Icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
    end
end

local function RAFRewards()
    for reward in RecruitAFriendRewardsFrame.rewardPool:EnumerateActive() do
        local button = reward.Button
        button.IconOverlay:SetAlpha(0)
        button.IconBorder:SetAlpha(0)

        GW.HandleIcon(button.Icon, true, GW.BackdropTemplates.ColorableBorderOnly, true)
        RAFRewardQuality(button)

        local icon = button.Icon
        icon:SetDesaturation(0)

        local text = reward.Months
        text:SetTextColor(1, 1, 1)
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
        RecentAlliesFrame.List,
        RecruitAFriendFrame.RecruitList.ScrollBox,
        WhoFrame.ScrollBox,
        QuickJoinFrame.ScrollBox
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

    --Friends frame
    for i = 1, 3 do
        local tabId = i == 1 and FriendsTabHeader.friendsTabID or i == 2 and FriendsTabHeader.recentAlliesTabID or FriendsTabHeader.recruitAFriendTabID
        local tab = FriendsTabHeader.TabSystem:GetTabButton(tabId)
        GW.HandleTabs(tab, "top")
    end

    FriendsFrameStatusDropdown:GwHandleDropDownBox()
    FriendsFrameStatusDropdown:SetWidth(55)
    FriendsFrameStatusDropdown:ClearAllPoints()
    FriendsFrameStatusDropdown:SetPoint("TOPLEFT", FriendsFrame.gwHeader, "BOTTOMLEFT", 5, 0)

    if GW.Retail then
        GW.HandleTrimScrollBar(FriendsListFrame.ScrollBar, true)
        GW.HandleScrollControls(FriendsListFrame)
        hooksecurefunc(FriendsListFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
    elseif GW.TBC then
        HybridScrollFrame_CreateButtons(FriendsFrameFriendsScrollFrame, "FriendsFrameButtonTemplate")
        FriendsFrameFriendsScrollFrameScrollBar:GwSkinScrollBar()
        FriendsFrameFriendsScrollFrame:GwSkinScrollFrame()
    end

    FriendsFrameAddFriendButton:GwSkinButton(false, true)
    FriendsFrameSendMessageButton:GwSkinButton(false, true)
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

        FriendsFrameBattlenetFrame.ContactsMenuButton:SetPoint("TOPRIGHT", FriendsFrame.gwHeader, "BOTTOMRIGHT", 5, 0)
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

    local IgnoreWindow = FriendsFrame.IgnoreListWindow
    if IgnoreWindow then
        IgnoreWindow:GwStripTextures()
        IgnoreWindow:GwCreateBackdrop(GW.BackdropTemplates.Default)
        GW.HandleTrimScrollBar(IgnoreWindow.ScrollBar, true)
        GW.HandleScrollControls(IgnoreWindow)
        IgnoreWindow.CloseButton:GwSkinButton(true)
    end

    FriendsFrameBattlenetFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame:SetPoint("TOP", FriendsFrame.gwHeader, "BOTTOM", 0, 0)
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
    FriendsFrameBattlenetFrame.BroadcastFrame:SetPoint("TOPLEFT", FriendsFrame.gwHeader, "BOTTOMRIGHT", 45, 1)
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
    FriendsFrameBattlenetFrame.UnavailableInfoFrame:SetPoint("TOPLEFT", FriendsFrame.gwHeader, "TOPRIGHT", 1, -18)

    if GW.Retail then
        RecruitAFriendRecruitmentFrame:GwStripTextures()
        RecruitAFriendRecruitmentFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
        GW.SkinTextBox(RecruitAFriendRecruitmentFrame.EditBox.Middle, RecruitAFriendRecruitmentFrame.EditBox.Left, RecruitAFriendRecruitmentFrame.EditBox.Right)
        RecruitAFriendRecruitmentFrame.GenerateOrCopyLinkButton:GwSkinButton(false, true)
        RecruitAFriendRecruitmentFrame.CloseButton:GwSkinButton(true)
        RecruitAFriendRecruitmentFrame.CloseButton:SetSize(15, 15)
    end

    -- recentAllies
    if GW.Retail then
        hooksecurefunc(RecentAlliesFrame.List.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
        GW.HandleTrimScrollBar(RecentAlliesFrame.List.ScrollBar, true)
        GW.HandleScrollControls(RecentAlliesFrame.List)
        hooksecurefunc(RecentAlliesFrame.List.ScrollBox, "Update", function(scrollBox)
            scrollBox:ForEachFrame(ReskinRecentAllyButton)
        end)
    end

    --recrute a friend
    if GW.Retail then
        RecruitAFriendFrame.RewardClaiming.Inset:Hide()
        RecruitAFriendFrame.RewardClaiming.Bracket_TopLeft:Hide()
        RecruitAFriendFrame.RewardClaiming.Bracket_TopRight:Hide()
        RecruitAFriendFrame.RewardClaiming.Bracket_BottomRight:Hide()
        RecruitAFriendFrame.RewardClaiming.Bracket_BottomLeft:Hide()

        RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton:GwSkinButton(false, true)

        RecruitAFriendFrame.RewardClaiming.MonthCount:ClearAllPoints()
        RecruitAFriendFrame.RewardClaiming.MonthCount:SetPoint("TOPLEFT", 120, -15)
        RecruitAFriendFrame.RewardClaiming.MonthCount:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

        RecruitAFriendFrame.RewardClaiming.NextRewardButton:ClearAllPoints()
        RecruitAFriendFrame.RewardClaiming.NextRewardButton:SetPoint("CENTER", RecruitAFriendFrame.RewardClaiming, "LEFT", 65, 0)
        RecruitAFriendFrame.RewardClaiming.NextRewardButton.CircleMask:Hide()
        RecruitAFriendFrame.RewardClaiming.NextRewardButton.IconBorder:SetAlpha(0)
        RecruitAFriendFrame.RewardClaiming.NextRewardButton.IconOverlay:SetAlpha(0)
        RecruitAFriendFrame.RewardClaiming.NextRewardButton.Icon:SetDesaturation(0)
        GW.HandleIcon(RecruitAFriendFrame.RewardClaiming.NextRewardButton.Icon, true, GW.BackdropTemplates.ColorableBorderOnly, true)
        RAFRewardQuality(RecruitAFriendFrame.RewardClaiming.NextRewardButton)
        RecruitAFriendFrame.RewardClaiming.Watermark:SetAlpha(0)
        RecruitAFriendFrame.RewardClaiming.Background:SetAlpha(0)
        RecruitAFriendFrame.RewardClaiming:GwCreateBackdrop(GW.BackdropTemplates.Default)
        RecruitAFriendFrame.RewardClaiming.backdrop:SetFrameLevel(RecruitAFriendFrame.RewardClaiming:GetFrameLevel())

        RecruitAFriendFrame.RecruitList.ScrollFrameInset:GwStripTextures()
        GW.HandleTrimScrollBar(RecruitAFriendFrame.RecruitList.ScrollBar, true)
        GW.HandleScrollControls(RecruitAFriendFrame.RecruitList)
        RecruitAFriendFrame.RecruitList.ScrollBox:SetSize(433, 420)

        RecruitAFriendFrame.RecruitList.Header:SetSize(450, 20)
        RecruitAFriendFrame.RecruitList.Header.Background:Hide()
        RecruitAFriendFrame.RecruitList.Header.RecruitedFriends:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
        RecruitAFriendFrame.RecruitList.Header.RecruitedFriends:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

        RecruitAFriendFrame.RecruitmentButton:ClearAllPoints()
        RecruitAFriendFrame.RecruitmentButton:SetPoint("BOTTOMLEFT", RecruitAFriendFrame.RecruitList.ScrollBox,  "BOTTOMLEFT", 4, -20)
        RecruitAFriendFrame.RecruitmentButton:GwSkinButton(false, true)

        RecruitAFriendFrame.SplashFrame.OKButton:GwSkinButton(false, true)

        RecruitAFriendRewardsFrame.CloseButton:GwSkinButton(true)
        RecruitAFriendRewardsFrame.CloseButton:SetSize(20, 20)
        RecruitAFriendRewardsFrame:GwStripTextures()
        RecruitAFriendRewardsFrame:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
        RecruitAFriendRewardsFrame.Background:SetAlpha(0)
        RecruitAFriendRewardsFrame.Watermark:SetAlpha(0)
        RecruitAFriendRewardsFrame.Title:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

        hooksecurefunc(RecruitAFriendRewardsFrame, "UpdateRewards", RAFRewards)
        RAFRewards()
    end

    -- who frame
    WhoFrameTotals:SetTextColor(1, 1, 1)
    WhoFrameListInset:SetAlpha(0)

    GW.HandleTrimScrollBar(WhoFrame.ScrollBar)
    GW.HandleScrollControls(WhoFrame)
    hooksecurefunc(WhoFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
    hooksecurefunc(WhoFrame.ScrollBox, "Update", function(scrollBox)
        scrollBox:ForEachFrame(ReskinWhoFrameButton)
    end)
    WhoFrameEditBox.Backdrop:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagsearchbg.png")
    WhoFrameEditBox:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    WhoFrameEditBox.Instructions:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    WhoFrameEditBox.Instructions:SetTextColor(178 / 255, 178 / 255, 178 / 255)
    GW.SkinBagSearchBox(WhoFrameEditBox)

    for _, frame in ipairs({WhoFrameColumnHeader1, WhoFrameColumnHeader2, WhoFrameColumnHeader3, WhoFrameColumnHeader4}) do
        frame:GwStripTextures()
        local r = {frame:GetRegions()}
        for _,c in pairs(r) do
            if c:GetObjectType() == "FontString" then
                c:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            end
        end
    end

    for _, object in pairs({WhoFrameColumnHeader1, WhoFrameColumnHeader2, WhoFrameColumnHeader3, WhoFrameColumnHeader4}) do
        GW.HandleScrollFrameHeaderButton(object)
    end

    WhoFrameDropdown:GwStripTextures()
    WhoFrameDropdown.Arrow:ClearAllPoints()
    WhoFrameDropdown.Arrow:SetPoint("RIGHT", WhoFrameDropdown, "RIGHT", -5, -3)
    WhoFrameDropdown.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    WhoFrameDropdown.Text:SetShadowOffset(0, 0)
    WhoFrameDropdown.Text:SetTextColor(1, 1, 1)
    WhoFrameDropdown.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
    WhoFrameDropdown:HookScript("OnClick", function(self)
        self.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
    end)
    WhoFrameDropdown:HookScript("OnMouseDown", function(self)
        self.Arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
    end)

    WhoFrameColumnHeader1:SetPoint("BOTTOMLEFT", WhoFrameListInset, "TOPLEFT", 5, 0)
    WhoFrameWhoButton:GwSkinButton(false, true)
    WhoFrameAddFriendButton:GwSkinButton(false, true)
    WhoFrameGroupInviteButton:GwSkinButton(false, true)

    --Raid
    if RaidFrameNotInRaid.ScrollingDescription then
        RaidFrameNotInRaid.ScrollingDescription:ClearAllPoints()
        RaidFrameNotInRaid.ScrollingDescription:SetPoint("TOPLEFT", RaidFrameNotInRaid, "TOPLEFT", 0, -73)
        RaidFrameNotInRaid.ScrollingDescription:SetPoint("BOTTOMRIGHT", RaidFrameNotInRaid, "BOTTOMRIGHT", 0, 0)
        RaidFrameNotInRaid.ScrollingDescription.ScrollBox.FontStringContainer.FontString:SetJustifyH("CENTER")
        RaidFrameNotInRaid.ScrollingDescription.ScrollBox.FontStringContainer.FontString:SetJustifyV("TOP")
        RaidFrameNotInRaid.ScrollingDescription.ScrollBox.FontStringContainer.FontString:SetTextColor(1, 1, 1)
    end

    RaidFrameAllAssistCheckButton:ClearAllPoints()
    RaidFrameAllAssistCheckButton:SetPoint("TOPLEFT", 10, -33)
    RaidFrameAllAssistCheckButton.text:ClearAllPoints()
    RaidFrameAllAssistCheckButton.text:SetPoint("LEFT", RaidFrameAllAssistCheckButton, "RIGHT", 5, -2)
    RaidFrameAllAssistCheckButton.text:SetText(ALL .. " |TInterface/AddOns/GW2_UI/textures/party/icon-assist.png:25:25:0:-3|t")

    if RaidFrame.RoleCount then
        RaidFrame.RoleCount:ClearAllPoints()
        RaidFrame.RoleCount:SetPoint("TOP", -80, -33)

        RaidFrame.RoleCount.TankIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-tank.png")
        RaidFrame.RoleCount.HealerIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-healer.png")
        RaidFrame.RoleCount.DamagerIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-dps.png")
        RaidFrame.RoleCount.DamagerIcon:SetSize(20, 20)
    end

    RaidFrameAllAssistCheckButton:GwSkinCheckButton()
    RaidFrameAllAssistCheckButton:SetSize(18, 18)

    if RaidFrameReadyCheckButton then
        RaidFrameReadyCheckButton:GwSkinButton(false, true)
    end

    RaidFrameConvertToRaidButton:GwSkinButton(false, true)
    RaidFrameRaidInfoButton:GwSkinButton(false, true)
    RaidFrameRaidInfoButton:SetPoint("TOPRIGHT", -7, -33)
    if GW.settings.USE_CHARACTER_WINDOW and (GW.Retail or GW.Mists) then
        RaidFrameRaidInfoButton:SetScript("OnClick", function()
            if InCombatLockdown() then return end
            if GwCharacterCurrencyRaidInfoFrame.RaidLocks:IsVisible() then
                GwCharacterWindow:SetAttribute("windowpanelopen", "nil")
                return
            end
            GwCharacterWindow:SetAttribute("windowpanelopen", "currency")
            GWCurrencyMenu.items.raidinfo:Click()
        end)
    end

    local StripAllTextures = {
        "RaidGroup1",
        "RaidGroup2",
        "RaidGroup3",
        "RaidGroup4",
        "RaidGroup5",
        "RaidGroup6",
        "RaidGroup7",
        "RaidGroup8",
    }

    local raidInit = false
    hooksecurefunc("RaidFrame_LoadUI", function()
        if raidInit then return end
        raidInit = true
        for _, object in pairs(StripAllTextures) do
            local obj = _G[object]
            if obj then
                obj:SetSize(230, 120)
                obj:GwStripTextures()
                _G[object .. "Label"]:SetNormalFontObject("GameFontNormal")
                _G[object .. "Label"]:SetHighlightFontObject("GameFontHighlight")
                for j = 1, 5 do
                    local slot = _G[object .. "Slot" .. j]
                    if slot then
                        slot:GwStripTextures()
                        slot:SetSize(220, 22)
                        slot:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
                    end
                end
            end
        end

        for i = 1, _G.MAX_RAID_GROUPS * 5 do
            _G["RaidGroupButton" .. i]:SetSize(220, 22)
            _G["RaidGroupButton" .. i]:GwSkinButton(false, true, true)
            _G["RaidGroupButton" .. i]:GwStripTextures()
            _G["RaidGroupButton" .. i]:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
            _G["RaidGroupButton" .. i .. "Name"]:SetFont(UNIT_NAME_FONT, 10)
            _G["RaidGroupButton" .. i .. "Level"]:SetFont(UNIT_NAME_FONT, 10)

            if _G["RaidGroupButton" .. i .. "Class"].SetFont then
                _G["RaidGroupButton" .. i .. "Class"]:SetFont(UNIT_NAME_FONT, 10)
            else
                _G["RaidGroupButton" .. i .. "Class"].text:SetFont(UNIT_NAME_FONT, 10)
            end

            _G["RaidGroupButton" .. i .. "Name"]:SetSize(60, 19)
            _G["RaidGroupButton" .. i .. "Level"]:SetSize(37, 19)
            _G["RaidGroupButton" .. i .. "Class"]:SetSize(80, 19)
        end

        hooksecurefunc("RaidGroupFrame_Update", function()
            for i = 1, MAX_RAID_GROUPS * 5 do
                local _, rank, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i)

                if rank == 2 then
                    _G["RaidGroupButton" .. i .. "RankTexture"]:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-groupleader.png")
                elseif rank == 1 then
                    _G["RaidGroupButton" .. i .. "RankTexture"]:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-assist.png")
                else
                    _G["RaidGroupButton" .. i .. "RankTexture"]:SetTexture("")
                end

                if role == "MAINTANK" then
                    _G["RaidGroupButton" .. i .. "RoleTexture"]:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-maintank.png")
                elseif role == "MAINASSIST" then
                    _G["RaidGroupButton" .. i .. "RoleTexture"]:SetTexture("Interface/AddOns/GW2_UI/textures/party/icon-mainassist.png")
                else
                    _G["RaidGroupButton" .. i .. "RoleTexture"]:SetTexture("")
                end
            end
        end)
    end)

    --quickjoin
    if GW.Retail then
        FriendsFrameTab4.GwNotifyText:SetText("0")
        FriendsFrameTab4.GwNotifyText:Show()
        FriendsFrameTab4.GwNotifyRed:Hide()

        local num = #C_SocialQueue.GetAllGroups()
        FriendsFrameTab4.GwNotifyText:SetText(num)
        FriendsFrameTab4.GwNotifyRed:SetShown(num > 0)

        QuickJoinFrame:HookScript("OnShow", function()
            local num = #C_SocialQueue.GetAllGroups()
            FriendsFrameTab4.GwNotifyText:SetText(num)
            FriendsFrameTab4.GwNotifyRed:SetShown(num > 0)
        end)

        local quickJoinQueueEventFrame = CreateFrame("Frame")
        quickJoinQueueEventFrame:RegisterEvent("SOCIAL_QUEUE_UPDATE")
        quickJoinQueueEventFrame:RegisterEvent("GROUP_LEFT")
        quickJoinQueueEventFrame:RegisterEvent("GROUP_JOINED")
        quickJoinQueueEventFrame:SetScript("OnEvent", function()
            if not QuickJoinFrame:IsShown() then return end
            local num = #C_SocialQueue.GetAllGroups()
            FriendsFrameTab4.GwNotifyText:SetText(num)
            FriendsFrameTab4.GwNotifyRed:SetShown(num > 0)
        end)

        hooksecurefunc(QuickJoinFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
        QuickJoinFrame.JoinQueueButton:GwSkinButton(false, true)
        GW.HandleTrimScrollBar(QuickJoinFrame.ScrollBar, true)
        GW.HandleScrollControls(QuickJoinFrame)
    end

    --guild
    if GW.TBC then
        GUILDMEMBERS_TO_DISPLAY = 22
        for i = 14, GUILDMEMBERS_TO_DISPLAY do
            local button = CreateFrame("Button", "GuildFrameButton" .. i, GuildPlayerStatusFrame, "FriendsFrameGuildPlayerStatusButtonTemplate", i)
            button:SetPoint("TOPLEFT", _G["GuildFrameButton" .. i -1], "BOTTOMLEFT", 0, 0)

            button = CreateFrame("Button", "GuildFrameGuildStatusButton" .. i, GuildStatusFrame, "FriendsFrameGuildStatusButtonTemplate", i)
            button:SetPoint("TOPLEFT", _G["GuildFrameButton" .. i -1], "BOTTOMLEFT", 0, 0)
        end

        for i = 1, GUILDMEMBERS_TO_DISPLAY do
            _G["GuildFrameButton" .. i]:SetWidth(420)
            _G["GuildFrameButton" .. i .. "Name"]:SetWidth(130)
            _G["GuildFrameButton" .. i .. "Zone"]:SetWidth(130)

            _G["GuildFrameGuildStatusButton" .. i]:SetWidth(420)
            _G["GuildFrameGuildStatusButton" .. i .. "Name"]:SetWidth(130)
            _G["GuildFrameGuildStatusButton" .. i .. "Note"]:SetWidth(130)

            _G["GuildFrameGuildStatusButton" .. i]:GetHighlightTexture():SetTexture("")
            GW.AddListItemChildHoverTexture(_G["GuildFrameGuildStatusButton" .. i])

            _G["GuildFrameButton" .. i]:GetHighlightTexture():SetTexture("")
            GW.AddListItemChildHoverTexture(_G["GuildFrameButton" .. i])
        end

        GuildFrameColumnHeader1:SetWidth(130)
        GuildFrameColumnHeader2:SetWidth(130)
        GuildFrameGuildStatusColumnHeader1:SetWidth(145)
        GuildFrameGuildStatusColumnHeader3:SetWidth(130)

        GW.HandleNextPrevButton(GuildFrameGuildListToggleButton, "right")
        GuildFrameAddMemberButton:GwSkinButton(false, true)
        GuildFrameGuildInformationButton:GwSkinButton(false, true)
        GuildFrameControlButton:GwSkinButton(false, true)
        GuildFrameNotesText:SetWidth(450)
        GuildMOTDEditButton:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

        GuildFrame:GwStripTextures()
        GuildListScrollFrame:GwStripTextures()
        GuildListScrollFrameScrollBar:GwSkinScrollBar()
        GuildListScrollFrame:GwSkinScrollFrame()
        GuildListScrollFrame.ScrollChildFrame:SetWidth(420)

        GuildListScrollFrame:SetPoint("TOPLEFT", GuildFrame, "TOPLEFT", 10, -50)
        GuildListScrollFrame:SetSize(450, 400)

        GuildFrameNotesLabel:SetPoint("TOPLEFT", GuildListScrollFrame, "BOTTOMLEFT", 0, -10)
        GuildFrameTotals:SetPoint("TOPLEFT", GuildMOTDEditButton, "BOTTOMLEFT", 0, -10)
        GuildFrameGuildListToggleButton:SetPoint("LEFT", GuildFrameTotals, "RIGHT", 335, 0)
        GuildFrameGuildListToggleButton.SetPoint = GW.NoOp

        GuildFrameNotesLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
        GuildFrameNotesLabel:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

        GuildFrameTotals:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        GuildFrameOnlineTotals:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        GuildFrameNotesLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        GuildFrameNotesText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)

        GuildFrameLFGFrame:GwStripTextures()
        GuildFrameLFGButton:GwSkinCheckButton()
        GuildFrameLFGButton:SetSize(15, 15)

        local Headers = {
            "GuildFrameColumnHeader1",
            "GuildFrameColumnHeader2",
            "GuildFrameColumnHeader3",
            "GuildFrameColumnHeader4",
            "GuildFrameGuildStatusColumnHeader1",
            "GuildFrameGuildStatusColumnHeader2",
            "GuildFrameGuildStatusColumnHeader3",
            "GuildFrameGuildStatusColumnHeader4",
        }

        for _, object in pairs(Headers) do
            local frame = _G[object]
            frame:GwStripTextures()
            local r = {frame:GetRegions()}
            for _,c in pairs(r) do
                if c:GetObjectType() == "FontString" then
                    c:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
                end
            end
        end

        for _, object in pairs(Headers) do
            GW.HandleScrollFrameHeaderButton(_G[object])
        end
    end
end