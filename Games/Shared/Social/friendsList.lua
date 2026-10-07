---@class GW2
local GW = select(2, ...)

local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
local WOW_PROJECT_CLASSIC = 2
local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE
local WOW_PROJECT_WRATH_CLASSIC = 11
local WOW_PROJECT_CATACLYSM_CLASSIC = 14
local WOW_PROJECT_MISTS_CLASSIC = 19

local MediaPath = "Interface/AddOns/GW2_UI/Textures/social/"
local delimiter = format("|cff%s | |r", "979fad")

GW.friendsList = {}
GW.friendsList.delimiter = delimiter
GW.friendsList.projectCodes = {
    ["ANBS"] = "Diablo Immortal",
    ["HERO"] = "Heroes of the Storm",
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
        icon = MediaPath .. "GameIcons/di.png",
        color = { r = 0.768, g = 0.121, b = 0.231 },
    },
    ["Heroes of the Storm"] = {
        icon = MediaPath .. "GameIcons/heroes.png",
        color = { r = 0, g = 0.8, b = 1 },
    },
    ["Diablo II"] = {
        icon = MediaPath .. "GameIcons/d2.png",
        color = { r = 0.768, g = 0.121, b = 0.231 },
    },
    ["StarCraft II"] = {
        icon = MediaPath .. "GameIcons/sc2.png",
        color = { r = 0.749, g = 0.501, b = 0.878 },
    },
    ["Call of Duty: Black Ops 4"] = {
        icon = MediaPath .. "GameIcons/cb4.png",
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["WarCraft III"] = {
        icon = MediaPath .. "GameIcons/wc3.png",
        color = { r = 0.796, g = 0.247, b = 0.145 },
    },
    ["Battle.net App"] = {
        icon = MediaPath .. "GameIcons/App",
        color = { r = 0.509, g = 0.772, b = 1 },
    },
    ["Call of Duty: Vanguard"] = {
        icon = MediaPath .. "GameIcons/codvanguard.png",
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["Call of Duty: MW2 Campaign Remastered"] = {
        icon = MediaPath .. "GameIcons/codmw2.png",
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["Blizzard Arcade Collection"] = {
        icon = MediaPath .. "GameIcons/arcade.png",
        color = { r = 0.509, g = 0.772, b = 1 },
    },
    ["Crash Bandicoot 4: It's About Time"] = {
        color = { r = 0.509, g = 0.772, b = 1 },
    },
    ["Hearthstone"] = {
        icon = MediaPath .. "GameIcons/hearthstone.png",
        color = { r = 1, g = 0.694, b = 0 },
    },
    ["Call of Duty: Blac Ops Cold War"] = {
        icon = MediaPath .. "GameIcons/codcw.png",
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["Diablo III"] = {
        icon = MediaPath .. "GameIcons/d3.png",
        color = { r = 0.768, g = 0.121, b = 0.231 },
    },
    ["Warcraft Arclight Rumble"] = {
        icon = MediaPath .. "GameIcons/arclight.png",
        color = { r = 0.945, g = 0.757, b = 0.149 },
    },
    ["Call of Duty: Mordern Warfare II"] = {
        icon = MediaPath .. "GameIcons/codmw.png",
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["StarCraft"] = {
        icon = MediaPath .. "GameIcons/sc.png",
        color = { r = 0.749, g = 0.501, b = 0.878 },
    },
    ["World of Warcraft"] = {
        icon = MediaPath .. "GameIcons/wow.png",
        color = { r = 0.866, g = 0.690, b = 0.180 },
    },
    ["Overwatch"] = {
        icon = MediaPath .. "GameIcons/overwatch.png",
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

-- the look of a friend in the list and in the friends tooltip:
-- "Account | Character | Level" in client, class and difficulty color, below it "Zone - Realm"
function GW.friendsList.GetStatus(isOnline, isAFK, isDND)
    return not isOnline and "Offline" or isAFK and "AFK" or isDND and "DND" or "Online"
end

function GW.friendsList.FormatTitle(realID, gameName, name, className, level, wowID, timerunningSeasonID)
    local clientColor = GW.friendsList.clientData[gameName] and GW.friendsList.clientData[gameName].color
    local realIDString = realID and clientColor and GW.StringWithRGB(realID, clientColor) or realID

    local nameString
    if name and name ~= "" then
        nameString = GW.StringWithRGB(name, GW.GWGetClassColor(GW.UnlocalizedClassName(className), true, true))
        if TimerunningUtil and timerunningSeasonID and timerunningSeasonID ~= "" then
            nameString = TimerunningUtil.AddSmallIcon(nameString) or nameString
        end
        if wowID and GW.friendsList.expansionData[wowID] and level and level ~= 0 then
            nameString = nameString .. GW.StringWithRGB(delimiter .. level, GetQuestDifficultyColor(level))
        end
    end

    if nameString and realIDString and realIDString ~= "" then
        return realIDString .. delimiter .. nameString
    end
    return nameString or realIDString or ""
end

-- the realm only when it is not ours
function GW.friendsList.FormatPlace(area, server)
    if area and area ~= "" then
        if server and server ~= "" and server ~= GW.myrealm then
            return area .. " - " .. server
        end
        return area
    end
    return server or ""
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
    if not button.gwSkinned then
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

        if GW.isModern then
            hooksecurefunc(button.travelPassButton.NormalTexture, "SetAtlas", HandleInviteTexNormal)
            hooksecurefunc(button.travelPassButton.DisabledTexture, "SetAtlas", HandleInviteTexDisabled)
        end

        button.gwSkinned = true
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

        status = GW.friendsList.GetStatus(friendInfo.connected, friendInfo.afk, friendInfo.dnd)
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET and BNConnected() then
        -- Battle.net friends
        local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
        if friendAccountInfo then
            realID = friendAccountInfo.accountName

            local gameAccountInfo = friendAccountInfo.gameAccountInfo
            gameName = GW.friendsList.projectCodes[strupper(gameAccountInfo.clientProgram)]

            status = GW.friendsList.GetStatus(gameAccountInfo.isOnline, friendAccountInfo.isAFK or gameAccountInfo.isGameAFK,
                friendAccountInfo.isDND or gameAccountInfo.isGameBusy)

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
        button.name:SetText(GW.friendsList.FormatTitle(realID, gameName, name, class, level, wowID, timerunningSeasonID))
        if area then
            button.info:SetText(GW.StringWithRGB(GW.friendsList.FormatPlace(area, server), {r = 1, g = 1, b = 1}))
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

    button.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    button.info:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -1)

    if button.Favorite and button.Favorite:IsShown() then
        button.Favorite:ClearAllPoints()
        button.Favorite:SetPoint("LEFT", button.name, "LEFT", button.name:GetStringWidth(), 0)
    end

    button:SetSize(460, 34)
    button.name:SetWidth(400)
end


function GW.SkinFriendList()
    if GW.isModern then
        for i = 1, 3 do
            local tabId = i == 1 and FriendsTabHeader.friendsTabID or i == 2 and FriendsTabHeader.recentAlliesTabID or FriendsTabHeader.recruitAFriendTabID
            local tab = FriendsTabHeader.TabSystem:GetTabButton(tabId)
            GW.HandleTabs(tab, "top")
        end
    else
        GW.HandleTabs(FriendsTabHeaderTab1, "top")
        GW.HandleTabs(FriendsTabHeaderTab2, "top")
        FriendsTabHeaderTab1:SetHeight(25)
        FriendsTabHeaderTab2:SetHeight(25)
        FriendsTabHeaderTab1:SetPoint("TOPLEFT", 18, -63)
    end

    FriendsFrameStatusDropdown:GwHandleDropDownBox()
    FriendsFrameStatusDropdown:SetWidth(55)
    FriendsFrameStatusDropdown:ClearAllPoints()
    FriendsFrameStatusDropdown:SetPoint("TOPLEFT", FriendsFrame.gwHeader, "BOTTOMLEFT", 5, 0)

    if GW.isModern then
        GW.HandleTrimScrollBar(FriendsListFrame.ScrollBar)
        GW.HandleScrollControls(FriendsListFrame)
        hooksecurefunc(FriendsListFrame.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
    elseif GW.TBC or GW.Wrath then
        FriendsFrameFriendsScrollFrame:ClearAllPoints()
        FriendsFrameFriendsScrollFrame:SetPoint("TOPLEFT", FriendsFrame, 8, -87)
        FriendsFrameFriendsScrollFrame:SetPoint("BOTTOMRIGHT", FriendsFrame, -25, 35)
        FriendsFrameFriendsScrollFrame:SetHeight(480)
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

    if GW.isModern then
        FriendsFriendsFrame.ScrollFrameBorder:Hide()
        FriendsFriendsFrame.SendRequestButton:GwSkinButton(false, true)
        FriendsFriendsFrame.CloseButton:GwSkinButton(false, true)

        GW.HandleTrimScrollBar(FriendsFriendsFrame.ScrollBar)
        GW.HandleScrollControls(FriendsFriendsFrame)

        FriendsFrameBattlenetFrame.ContactsMenuButton:SetPoint("TOPRIGHT", FriendsFrame.gwHeader, "BOTTOMRIGHT", 5, 0)
        FriendsFrameBattlenetFrame.ContactsMenuButton:GwHandleDropDownBox(GW.BackdropTemplates.ColorableBorderOnly, nil, nil, 32)
        FriendsFrameBattlenetFrame.ContactsMenuButton.backdrop:SetBackdropBorderColor(0, 0, 0, 0)
        FriendsFrameBattlenetFrame.ContactsMenuButton.gw2Arrow:SetPoint("CENTER")
        FriendsFrameBattlenetFrame.ContactsMenuButton.gw2Arrow:SetSize(28, 28)

        button:SetScript("OnClick", function() FriendsFrameBattlenetFrame.BroadcastFrame:ToggleFrame() end)
    elseif GW.TBC or GW.Wrath then
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
    if GW.isModern then
        FriendsFrameBattlenetFrame.BroadcastFrame.EditBox:GwStripTextures()
        GW.HandleBlizzardRegions(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox)
        GW.SkinTextBox(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.MiddleBorder, FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.LeftBorder, FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.RightBorder, nil, nil, 5, 5)
        FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton:GwSkinButton(false, true)
        FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton:GwSkinButton(false, true)
    elseif GW.TBC or GW.Wrath then
        FriendsFrameBattlenetFrame.BroadcastButton:GwKill()
        FriendsFrameBattlenetFrameScrollFrame:GwStripTextures()
        GW.HandleBlizzardRegions(FriendsFrameBattlenetFrameScrollFrame)
        GW.SkinTextBox(FriendsFrameBattlenetFrameScrollFrame.MiddleBorder, FriendsFrameBattlenetFrameScrollFrame.LeftBorder, FriendsFrameBattlenetFrameScrollFrame.RightBorder, nil, nil, 5, 5)
        FriendsFrameBattlenetFrameScrollFrame.UpdateButton:GwSkinButton(false, true)
        FriendsFrameBattlenetFrameScrollFrame.CancelButton:GwSkinButton(false, true)
    end

    GW.SkinAddFriendFrame()
    FriendsFrameBattlenetFrame.UnavailableInfoFrame:ClearAllPoints()
    FriendsFrameBattlenetFrame.UnavailableInfoFrame:SetPoint("TOPLEFT", FriendsFrame.gwHeader, "TOPRIGHT", 1, -18)
end

local function SkinCloseButton(frame)
    local button = frame.CloseButton
    if not button then return end
    button:GwSkinButton(true)
    button:SetSize(20, 20)
    button:ClearAllPoints()
    button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
end

-- the add friend window of every social skin; the close and info buttons and the info window came with newer clients
function GW.SkinAddFriendFrame()
    AddFriendFrame:GwStripTextures()
    AddFriendFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    SkinCloseButton(AddFriendFrame)
    if AddFriendEntryFrameInfoButton then
        GW.SkinHelpIconButton(AddFriendEntryFrameInfoButton, 24)
    end
    if AddFriendInfoFrame then
        AddFriendInfoFrame:GwStripTextures()
        AddFriendInfoFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
        SkinCloseButton(AddFriendInfoFrame)
        if AddFriendInfoFrame.OkayButton then
            AddFriendInfoFrame.OkayButton:GwSkinButton(false, true)
        end
    end
    AddFriendEntryFrameAcceptButton:GwSkinButton(false, true)
    AddFriendEntryFrameCancelButton:GwSkinButton(false, true)
    AddFriendEntryFrameCancelButton:GwSkinNegativeButton()
    GW.SkinTextBox(_G["AddFriendNameEditBoxMiddle"], _G["AddFriendNameEditBoxLeft"], _G["AddFriendNameEditBoxRight"])
end
