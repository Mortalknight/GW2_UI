local _, GW = ...

local dataValid = false
local friendTable, BNTable, tableList, clientSorted = {}, {}, {}, {}
local totalOnlineString = strjoin("", FRIENDS_LIST_ONLINE, ": %s/%s")
local tthead = GW.myfaction == "Alliance" and GW.FACTION_COLOR[2] or GW.FACTION_COLOR[1]
local activezone, inactivezone = {r = 0.3, g = 1.0, b = 0.3}, {r = 0.65, g = 0.65, b = 0.65}
local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r"
local levelNameClassString = "|cff%02x%02x%02x%d|r %s%s%s"
local retailID, classicID, tbcID, wrathID = WOW_PROJECT_MAINLINE, WOW_PROJECT_CLASSIC, WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5, WOW_PROJECT_WRATH_CLASSIC or 11

local menuList = {
    {text = OPTIONS_MENU, isTitle = true, notCheckable = true},
    {text = INVITE, hasArrow = true, notCheckable = true},
    {text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable = true},
    {text = PLAYER_STATUS, hasArrow = true, notCheckable = true,
        menuList = {
            {text = "|cff2BC226" .. AVAILABLE .. "|r", notCheckable = true, func = function() if IsChatAFK() then SendChatMessage("", "AFK") elseif IsChatDND() then SendChatMessage("", "DND") end end},
            {text = "|cffE7E716" .. DND .. "|r", notCheckable = true, func = function() if not IsChatDND() then SendChatMessage("", "DND") end end},
            {text = "|cffFF0000" .. AFK .. "|r", notCheckable = true, func = function() if not IsChatAFK() then SendChatMessage("", "AFK") end end},
        },
    },
    {text = BN_BROADCAST_TOOLTIP, notCheckable = true, func = function() StaticPopup_Show("SET_BN_BROADCAST") end},
}

local function inviteClick(_, name, guid)
    GW.EasyMenu:Hide()

    if not (name and name ~= "") then return end
    local isBNet = type(name) == "number"

    if guid then
        local inviteType = GetDisplayedInviteType(guid)
        if inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" then
            if isBNet then
                BNInviteFriend(name)
            else
                C_PartyInfo.InviteUnit(name)
            end
        elseif inviteType == "REQUEST_INVITE" then
            if isBNet then
                BNRequestInviteFriend(name)
            else
                C_PartyInfo.RequestInviteFromUnit(name)
            end
        end
    else
        if isBNet then
            BNInviteFriend(name)
        else
            C_PartyInfo.InviteUnit(name)
        end
    end
end

local function whisperClick(_, name, battleNet)
    GW.EasyMenu:Hide()

    if battleNet then
        ChatFrame_SendBNetTell(name)
    else
        SetItemRef("player:" .. name, format("|Hplayer:%1$s|h[%1$s]|h", name), "LeftButton")
    end
end


local statusTable = {
    AFK = " |cffFFFFFF[|r|cffFF9900" .. AFK .. "|r|cffFFFFFF]|r",
    DND = " |cffFFFFFF[|r|cffFF3333" .. DND .. "|r|cffFFFFFF]|r"
}

local clientList = {
    WoW =	{ index = 1, tag = "WoW",	name = "World of Warcraft"},
    WTCG =	{ index = 2, tag = "HS",	name = "Hearthstone"},
    Hero =	{ index = 3, tag = "HotS",	name = "Heroes of the Storm"},
    Pro =	{ index = 4, tag = "OW",	name = "Overwatch"},
    OSI =	{ index = 5, tag = "D2",	name = "Diablo 2: Resurrected"},
    D3 =	{ index = 6, tag = "D3",	name = "Diablo 3"},
    ANBS =	{ index = 7, tag = "DI",	name = "Diablo Immortal"},
    S1 =	{ index = 8, tag = "SC",	name = "Starcraft"},
    S2 =	{ index = 9, tag = "SC2",	name = "Starcraft 2"},
    W3 =	{ index = 10, tag = "WC3",	name = "Warcraft 3: Reforged"},
    RTRO =	{ index = 11, tag = "AC",	name = "Arcade Collection"},
    WLBY =	{ index = 12, tag = "CB4",	name = "Crash Bandicoot 4"},
    VIPR =	{ index = 13, tag = "BO4",	name = "COD: Black Ops 4"},
    ODIN =	{ index = 14, tag = "WZ",	name = "COD: Warzone"},
    AUKS =	{ index = 15, tag = "WZ2",	name = "COD: Warzone 2"},
    LAZR =	{ index = 16, tag = "MW2",	name = "COD: Modern Warfare 2"},
    ZEUS =	{ index = 17, tag = "CW",	name = "COD: Cold War"},
    FORE =	{ index = 18, tag = "VG",	name = "COD: Vanguard"},
    GRY = 	{ index = 19, tag = "AR",	name = "Warcraft Arclight Rumble"},
    App =	{ index = 20, tag = "App",	name = "App"},
    BSAp =	{ index = 21, tag = COMMUNITIES_PRESENCE_MOBILE_CHAT, name = COMMUNITIES_PRESENCE_MOBILE_CHAT}
}

local function inGroup(name, realmName)
    if realmName and realmName ~= "" and realmName ~= GW.myrealm then
        name = name.."-"..realmName
    end

    return (UnitInParty(name) or UnitInRaid(name)) and "|cffaaaaaa*|r" or ""
end

local function BuildFriendTable(total)
    wipe(friendTable)
    for i = 1, total do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and info.connected then
            local className = GW.UnlocalizedClassName(info.className) or ""
            local status = (info.afk and statusTable.AFK) or (info.dnd and statusTable.DND) or ""
            friendTable[i] = {
                name = info.name,			--1
                level = info.level,			--2
                class = className,			--3
                zone = info.area,			--4
                online = info.connected,	--5
                status = status,			--6
                notes = info.notes,			--7
                guid = info.guid			--8
            }
        end
    end
    if next(friendTable) then
        sort(friendTable, function(a, b)
            if a.name and b.name then
                return a.name < b.name
            end
            return a < b
        end)
    end
end

local function Sort(a, b)
    if a.client and b.client then
        if (a.client == b.client) then
            if (a.client == BNET_CLIENT_WOW) and a.wowProjectID and b.wowProjectID then
                if (a.wowProjectID == b.wowProjectID) and a.faction and b.faction then
                    if (a.faction == b.faction) and a.characterName and b.characterName then
                        return a.characterName < b.characterName
                    end
                    return a.faction < b.faction
                end
                return a.wowProjectID < b.wowProjectID
            elseif (a.battleTag and b.battleTag) then
                return a.battleTag < b.battleTag
            end
        end
        return a.client < b.client
    end
end

local function clientSort(a, b)
    if a and b then
        local A, B = clientList[a], clientList[b]
        if A and B then
            return A.index < B.index
        end
        return a < b
    end
end

local function AddToBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, wowProjectID, realmName, faction, race, className, zoneName, level, guid, gameText)
    className = GW.UnlocalizedClassName(className) or ""
    characterName = BNet_GetValidatedCharacterName(characterName, battleTag, client) or ""

    local obj = {
        accountID = bnetIDAccount,		--1
        accountName = accountName,		--2
        battleTag = battleTag,			--3
        characterName = characterName,	--4
        gameID = bnetIDGameAccount,		--5
        client = client,				--6
        isOnline = isOnline,			--7
        isBnetAFK = isBnetAFK,			--8
        isBnetDND = isBnetDND,			--9
        noteText = noteText,			--10
        wowProjectID = wowProjectID,	--11
        realmName = realmName,			--12
        faction = faction,				--13
        race = race,					--14
        className = className,			--15
        zoneName = zoneName,			--16
        level = level,					--17
        guid = guid,					--18
        gameText = gameText				--19
    }

    if wowProjectID == classicID or wowProjectID == tbcID or wowProjectID == wrathID then
        obj.classicText, obj.realmName = strmatch(gameText, "(.-)%s%-%s(.+)")
    end

    BNTable[bnIndex] = obj

    if tableList[client] then
        tableList[client][#tableList[client] + 1] = BNTable[bnIndex]
    else
        tableList[client] = {}
        tableList[client][1] = BNTable[bnIndex]
    end
end

local function PopulateBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, wowProjectID, realmName, faction, race, class, zoneName, level, guid, gameText, hasFocus)
    for i = 1, bnIndex do
        local isAdded, bnInfo = 0, BNTable[i]
        if bnInfo and (bnInfo.accountID == bnetIDAccount) then
            if bnInfo.client == "BSAp" then
                if client == "BSAp" then
                    isAdded = 1
                elseif client == "App" then
                    isAdded = (hasFocus and 2) or 1
                else
                    isAdded = 2
                end
            elseif bnInfo.client == "App" then
                if client == "App" then
                    isAdded = 1
                elseif client == "BSAp" then
                    isAdded = (hasFocus and 2) or 1
                else
                    isAdded = 2
                end
            elseif bnInfo.client then
                if client == "BSAp" or client == "App" then
                    isAdded = 1
                end
            end
        end
        if isAdded == 2 then
            if bnInfo.client and tableList[bnInfo.client] then
                for n, y in ipairs(tableList[bnInfo.client]) do
                    if y == bnInfo then
                        tremove(tableList[bnInfo.client], n)
                        break
                    end
                end
            end
            AddToBNTable(i, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, wowProjectID, realmName, faction, race, class, zoneName, level, guid, gameText)
        end
        if isAdded ~= 0 then
            return bnIndex
        end
    end

    bnIndex = bnIndex + 1
    AddToBNTable(bnIndex, bnetIDAccount, accountName, battleTag, characterName, bnetIDGameAccount, client, isOnline, isBnetAFK, isBnetDND, noteText, wowProjectID, realmName, faction, race, class, zoneName, level, guid, gameText)

    return bnIndex
end

local function BuildBNTable(total)
    for _, v in pairs(tableList) do
        wipe(v)
    end
    wipe(BNTable)
    wipe(clientSorted)

    local bnIndex = 0

    for i = 1, total do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
            local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(i)
            if numGameAccounts and numGameAccounts > 0 then
                for y = 1, numGameAccounts do
                    local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(i, y)
                    if gameAccountInfo then
                        bnIndex = PopulateBNTable(bnIndex, accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, gameAccountInfo.characterName, gameAccountInfo.gameAccountID, gameAccountInfo.clientProgram, gameAccountInfo.isOnline, accountInfo.isAFK or gameAccountInfo.isGameAFK, accountInfo.isDND or gameAccountInfo.isGameBusy, accountInfo.note, accountInfo.gameAccountInfo.wowProjectID, gameAccountInfo.realmName, gameAccountInfo.factionName, gameAccountInfo.raceName, gameAccountInfo.className, gameAccountInfo.areaName, gameAccountInfo.characterLevel, gameAccountInfo.playerGuid, gameAccountInfo.richPresence, gameAccountInfo.hasFocus)
                    end
                end
            else
                bnIndex = PopulateBNTable(bnIndex, accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, accountInfo.gameAccountInfo.characterName, accountInfo.gameAccountInfo.gameAccountID, accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isOnline, accountInfo.isAFK, accountInfo.isDND, accountInfo.note, accountInfo.gameAccountInfo.wowProjectID)
            end
        end
    end

    if next(BNTable) then
        sort(BNTable, Sort)
    end
    for c, v in pairs(tableList) do
        if next(v) then
            sort(v, Sort)
        end
        tinsert(clientSorted, c)
    end
    if next(clientSorted) then
        sort(clientSorted, clientSort)
    end
end

local lastTooltipXLineHeader
local function TooltipAddXLine(X, header, ...)
    X = (X == true and "AddDoubleLine") or "AddLine"
    if lastTooltipXLineHeader ~= header then
        GameTooltip[X](GameTooltip, " ")
        GameTooltip[X](GameTooltip, header)
        lastTooltipXLineHeader = header
    end
    GameTooltip[X](GameTooltip, ...)
end

local function Friends_OnEnter(self)
    local onlineFriends = C_FriendList.GetNumOnlineFriends()
    local numberOfFriends = C_FriendList.GetNumFriends()
    local totalBNet, numBNetOnline = BNGetNumFriends()
    local totalOnline = onlineFriends + numBNetOnline
    lastTooltipXLineHeader = nil


    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    -- get blizzard tooltip infos:
    GameTooltip_SetTitle(GameTooltip, self.tooltipText)
    if not self:IsEnabled() then
        if self.factionGroup == "Neutral" then
            GameTooltip:AddLine(FEATURE_NOT_AVAILBLE_PANDAREN, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        elseif self.minLevel then
            GameTooltip:AddLine(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, self.minLevel), RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        elseif self.disabledTooltip then
            local disabledTooltipText = GetValueOrCallFunction(self, "disabledTooltip")
            GameTooltip:AddLine(disabledTooltipText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        end
    end

    if totalOnline == 0 then
        GameTooltip:Show()
        return
    end

    GameTooltip:AddLine(" ")

    if not dataValid then
        if numberOfFriends > 0 then BuildFriendTable(numberOfFriends) end
        if totalBNet > 0 then BuildBNTable(totalBNet) end
        dataValid = true
    end

    local totalfriends = numberOfFriends + totalBNet
    local zonec, classc, levelc, realmc, zoneText
    local shiftDown = IsShiftKeyDown()

    if shiftDown then
        zoneText = GW.Libs.GW2Lib:GetPlayerLocationZoneText()
    end

    GameTooltip:AddDoubleLine(FRIENDS_LIST, format(totalOnlineString, totalOnline, totalfriends), tthead.r, tthead.g, tthead.b, tthead.r, tthead.g, tthead.b)
    if onlineFriends > 0 then
        for _, info in ipairs(friendTable) do
            if info.online then
                local zoneText = GW.Libs.GW2Lib:GetPlayerLocationZoneText()
                if zoneText and (zoneText == info.zone) then zonec = activezone else zonec = inactivezone end
                classc, levelc = GW.GWGetClassColor(info.class, true, true), GetQuestDifficultyColor(info.level)
                if not classc then classc = levelc end

                TooltipAddXLine(true, CHARACTER_FRIEND, format(levelNameClassString, levelc.r * 255, levelc.g * 255, levelc.b * 255, info.level, info.name, inGroup(info.name), info.status), info.zone, classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
            end
        end
    end

    if numBNetOnline > 0 then
        local status
        for _, client in ipairs(clientSorted) do
            local Table = tableList[client]
            for _, info in ipairs(Table) do
                if info.isOnline then
                    if info.isBnetAFK == true then
                        status = statusTable.AFK
                    elseif info.isBnetDND == true then
                        status = statusTable.DND
                    else
                        status = ""
                    end

                    local clientInfo = clientList[client]
                    local header = format("%s (%s)", BATTLENET_OPTIONS_LABEL, info.classicText or (clientInfo and clientInfo.tag) or client)
                    if info.client and info.client == BNET_CLIENT_WOW then
                        classc = GW.GWGetClassColor(info.className, true, true)
                        if info.level and info.level ~= "" then
                            levelc = GetQuestDifficultyColor(info.level)
                        else
                            classc, levelc = RAID_CLASS_COLORS.PRIEST, RAID_CLASS_COLORS.PRIEST
                        end

                        if not classc then classc = RAID_CLASS_COLORS.PRIEST end

                        TooltipAddXLine(true, header, format(levelNameString .. "%s%s", levelc.r * 255, levelc.g * 255, levelc.b * 255, info.level, classc.r * 255, classc.g * 255, classc.b * 255, info.characterName, inGroup(info.characterName, info.realmName), status), info.accountName, 238, 238, 238, 238, 238, 238)
                        if shiftDown then
                            if zoneText and (zoneText == info.zoneName) then zonec = activezone else zonec = inactivezone end
                            if GW.myrealm == info.realmName then realmc = activezone else realmc = inactivezone end
                            TooltipAddXLine(true, header, info.zoneName, info.realmName, zonec.r, zonec.g, zonec.b, realmc.r, realmc.g, realmc.b)
                        end
                    else
                        TooltipAddXLine(true, header, info.characterName .. status, info.accountName, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
                        if shiftDown and (info.gameText and info.gameText ~= "") and (info.client and info.client ~= "App" and info.client ~= "BSAp") then
                            TooltipAddXLine(false, header, info.gameText, inactivezone.r, inactivezone.g, inactivezone.b)
                        end
                    end
                end
            end
        end
    end

    GameTooltip:Show()
end
GW.Friends_OnEnter = Friends_OnEnter

local function Friends_OnEvent(self, event, message)
    if event == "CHAT_MSG_SYSTEM" then
        if not (strfind(message, gsub(ERR_FRIEND_ONLINE_SS, "|Hplayer:%%s|h%[%%s%]|h","")) or strfind(message, gsub(ERR_FRIEND_OFFLINE_S, "%%s", ""))) then return end
    end
    dataValid = false

    if not IsAltKeyDown() and event == "MODIFIER_STATE_CHANGED" and GetMouseFocus() == self then
        Friends_OnEnter(self)
    end
end
GW.Friends_OnEvent = Friends_OnEvent

local function Friends_OnClick(self, button)
    if button == "RightButton" then
        local menuCountWhispers = 0
        local menuCountInvites = 0

        menuList[2].menuList = {}
        menuList[3].menuList = {}

        for _, info in ipairs(friendTable) do
            if info.online then
                local classc, levelc = GW.GWGetClassColor(info.class, true, true), GetQuestDifficultyColor(info.level)
                if not classc then classc = levelc end

                menuCountWhispers = menuCountWhispers + 1
                menuList[3].menuList[menuCountWhispers] = {text = format(levelNameString, levelc.r * 255, levelc.g * 255, levelc.b * 255, info.level, classc.r * 255, classc.g * 255, classc.b * 255, info.name), arg1 = info.name, notCheckable = true, func = whisperClick}

                if inGroup(info.name) == "" then
                    menuCountInvites = menuCountInvites + 1
                    menuList[2].menuList[menuCountInvites] = {text = format(levelNameString, levelc.r * 255, levelc.g * 255, levelc.b * 255, info.level, classc.r * 255, classc.g * 255, classc.b * 255, info.name), arg1 = info.name, arg2 = info.guid, notCheckable = true, func = inviteClick}
                end
            end
        end
        for _, info in ipairs(BNTable) do
            if info.isOnline then
                local realID, hasBnet = info.accountName, false

                for _, z in ipairs(menuList[3].menuList) do
                    if z and z.text and (z.text == realID) then
                        hasBnet = true
                        break
                    end
                end

                if not hasBnet then
                    menuCountWhispers = menuCountWhispers + 1
                    menuList[3].menuList[menuCountWhispers] = {text = realID, arg1 = realID, arg2 = true, notCheckable = true, func = whisperClick}
                end

                if (info.client and info.client == retailID) and inGroup(info.characterName, info.realmName) == "" then
                    local classc, levelc = GW.GWGetClassColor(info.className, true, true), GetQuestDifficultyColor(info.level)
                    if not classc then classc = levelc end

                    if info.wowProjectID == WOW_PROJECT_ID then
                        menuCountInvites = menuCountInvites + 1
                        menuList[2].menuList[menuCountInvites] = {text = format(levelNameString, levelc.r * 255, levelc.g * 255, levelc.b * 255, info.level, classc.r * 255, classc.g * 255, classc.b * 255, info.characterName), arg1 = info.gameID, arg2 = info.guid, notCheckable = true, func = inviteClick}
                    end
                end
            end
        end

        GW.SetEasyMenuAnchor(GW.EasyMenu, self)
        EasyMenu(menuList, GW.EasyMenu, nil, nil, nil, "MENU")
    end
end
GW.Friends_OnClick = Friends_OnClick