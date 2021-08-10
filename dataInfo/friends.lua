local _, GW = ...

local dataValid = false
local friendTable, BNTable, tableList, clientSorted = {}, {}, {}, {}
local totalOnlineString = strjoin("", FRIENDS_LIST_ONLINE, ": %s/%s")
local tthead = GW.myfaction == "Alliance" and GW.FACTION_COLOR[2] or GW.FACTION_COLOR[1]
local activezone, inactivezone = {r = 0.3, g = 1.0, b = 0.3}, {r = 0.65, g = 0.65, b = 0.65}
local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r"
local levelNameClassString = "|cff%02x%02x%02x%d|r %s%s%s"

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

StaticPopupDialogs["SET_BN_BROADCAST"] = {
    text = BN_BROADCAST_TOOLTIP,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    editBoxWidth = 350,
    maxLetters = 127,
    OnAccept = function(self) BNSetCustomMessage(self.editBox:GetText()) end,
    OnShow = function(self) self.editBox:SetText(select(4, BNGetInfo()) ) self.editBox:SetFocus() end,
    OnHide = ChatEdit_FocusActiveWindow,
    EditBoxOnEnterPressed = function(self) BNSetCustomMessage(self:GetText()) self:GetParent():Hide() end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3
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

local clientTags = {
    [BNET_CLIENT_WOW] = "WoW",
    [BNET_CLIENT_WTCG] = "HS",
    [BNET_CLIENT_HEROES] = "HotS",
    [BNET_CLIENT_OVERWATCH] = "OW",
    [BNET_CLIENT_D2] = "D2",
    [BNET_CLIENT_D3] = "D3",
    [BNET_CLIENT_SC] = "SC",
    [BNET_CLIENT_SC2] = "SC2",
    [BNET_CLIENT_WC3] = "WC3",
    [BNET_CLIENT_ARCADE] = "AC",
    [BNET_CLIENT_CRASH4] = "CB4",
    [BNET_CLIENT_COD] = "BO4",
    [BNET_CLIENT_COD_MW] = "MW",
    [BNET_CLIENT_COD_MW2] = "MW2",
    [BNET_CLIENT_COD_BOCW] = "CW",
    BSAp = COMMUNITIES_PRESENCE_MOBILE_CHAT,
}


local clientIndex = {
    [BNET_CLIENT_WOW] = 1,
    [BNET_CLIENT_WTCG] = 2,
    [BNET_CLIENT_HEROES] = 3,
    [BNET_CLIENT_OVERWATCH] = 4,
    [BNET_CLIENT_D2] = 5,
    [BNET_CLIENT_D3] = 6,
    [BNET_CLIENT_SC] = 7,
    [BNET_CLIENT_SC2] = 8,
    [BNET_CLIENT_WC3] = 9,
    [BNET_CLIENT_ARCADE] = 10,
    [BNET_CLIENT_CRASH4] = 11,
    [BNET_CLIENT_COD] = 12,
    [BNET_CLIENT_COD_MW] = 13,
    [BNET_CLIENT_COD_MW2] = 14,
    [BNET_CLIENT_COD_BOCW] = 15,
    App = 16,
    BSAp = 17,
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
        if clientIndex[a] and clientIndex[b] then
            return clientIndex[a] < clientIndex[b]
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

    if strmatch(gameText, BNET_FRIEND_TOOLTIP_WOW_CLASSIC) then
        obj.classicText, obj.realmName = strmatch(gameText, "(.-)%s%-%s(.+)")
    end

    BNTable[bnIndex] = obj

    if tableList[client] then
        tableList[client][#tableList[client]+1] = BNTable[bnIndex]
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
    for _, v in pairs(tableList) do wipe(v) end
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
                    bnIndex = PopulateBNTable(bnIndex, accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, gameAccountInfo.characterName, gameAccountInfo.gameAccountID, gameAccountInfo.clientProgram, gameAccountInfo.isOnline, accountInfo.isAFK or gameAccountInfo.isGameAFK, accountInfo.isDND or gameAccountInfo.isGameBusy, accountInfo.note, accountInfo.gameAccountInfo.wowProjectID, gameAccountInfo.realmName, gameAccountInfo.factionName, gameAccountInfo.raceName, gameAccountInfo.className, gameAccountInfo.areaName, gameAccountInfo.characterLevel, gameAccountInfo.playerGuid, gameAccountInfo.richPresence, gameAccountInfo.hasFocus)
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
    local totalonline = onlineFriends + numBNetOnline

    if totalonline == 0 then return end

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
    GameTooltip:AddLine(" ")


    lastTooltipXLineHeader = nil

    if not dataValid then
        if numberOfFriends > 0 then BuildFriendTable(numberOfFriends) end
        if totalBNet > 0 then BuildBNTable(totalBNet) end
        dataValid = true
    end

    local totalfriends = numberOfFriends + totalBNet
    local zonec, classc, levelc, realmc
    local shiftDown = IsShiftKeyDown()

    GameTooltip:AddDoubleLine(FRIENDS_LIST, format(totalOnlineString, totalonline, totalfriends), tthead.r, tthead.g, tthead.b, tthead.r, tthead.g, tthead.b)
    if onlineFriends > 0 then
        for _, info in ipairs(friendTable) do
            if info.online then
                if GW.locationData.ZoneText and (GW.locationData.ZoneText == info.zone) then zonec = activezone else zonec = inactivezone end
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

                    local header = format("%s (%s)", BATTLENET_OPTIONS_LABEL, info.classicText or clientTags[client] or client)
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
                            if GW.locationData.ZoneText and (GW.locationData.ZoneText == info.zoneName) then zonec = activezone else zonec = inactivezone end
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
        if not (strfind(message, gsub(ERR_FRIEND_ONLINE_SS, "\124Hplayer:%%s\124h%[%%s%]\124h", "")) or strfind(message, gsub(ERR_FRIEND_OFFLINE_S, "%%s", ""))) then return end
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

                if (info.client and info.client == BNET_CLIENT_WOW) and (GW.myfaction == info.faction) and inGroup(info.characterName, info.realmName) == "" then
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