---@class GW2
local GW = select(2, ...)

local APP_CLIENTS = {App = true, BSAp = true}
local Social = GW.Social
local ACCOUNT_COLOR = CreateColor(0.93, 0.93, 0.93)
local OTHER_PLACE_COLOR = Social.OTHER_PLACE_COLOR

-- friends lists name the class localized
local function FormatCharacter(level, name, className)
    return Social.FormatCharacter(level, name, GW.UnlocalizedClassName(className))
end

local function GetOnlineFriends()
    local friends = {}
    for i = 1, C_FriendList.GetNumFriends() do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and info.connected and info.name then
            tinsert(friends, info)
        end
    end
    table.sort(friends, function(a, b) return a.name < b.name end)
    return friends
end

local function GetCharacterName(game)
    local name = game.clientProgram == BNET_CLIENT_WOW and game.characterName
    return GW.NotSecretValue(name) and name ~= "" and name or nil
end

-- own wow project first, then other wow projects, other games, and friends who only have the app open
local function GetClientOrder(game)
    if game.clientProgram == BNET_CLIENT_WOW then
        return game.wowProjectID == WOW_PROJECT_ID and 1 or 2
    end
    return APP_CLIENTS[game.clientProgram] and 4 or 3
end

local function GetEntryName(entry)
    return GetCharacterName(entry.game) or entry.account.accountName or ""
end

local function SortEntries(a, b)
    if a.order ~= b.order then
        return a.order < b.order
    elseif a.game.clientProgram ~= b.game.clientProgram then
        return (a.game.clientProgram or "") < (b.game.clientProgram or "")
    end
    return GetEntryName(a) < GetEntryName(b)
end

-- one entry per game a friend is in; a friend in no game shows up once with the app
local function GetOnlineBNetEntries()
    local entries = {}
    if not BNConnected() then
        return entries
    end

    for i = 1, BNGetNumFriends() do
        local account = C_BattleNet.GetFriendAccountInfo(i)
        local app = account and account.gameAccountInfo
        if app and app.isOnline then
            local games = {}
            for j = 1, C_BattleNet.GetFriendNumGameAccounts(i) do
                local game = C_BattleNet.GetFriendGameAccountInfo(i, j)
                if game and game.isOnline then
                    if not APP_CLIENTS[game.clientProgram] then
                        tinsert(games, game)
                    elseif game.hasFocus then
                        app = game
                    end
                end
            end
            if #games == 0 then
                games[1] = app
            end
            for _, game in ipairs(games) do
                tinsert(entries, {account = account, game = game, order = GetClientOrder(game)})
            end
        end
    end

    table.sort(entries, SortEntries)
    return entries
end

local function AddSectionTitle(title)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(title)
end

local function AddFriendLines(friends, myZone)
    AddSectionTitle(CHARACTER_FRIEND)
    for _, info in ipairs(friends) do
        local name = FormatCharacter(info.level, info.name, info.className)
            .. (Social.IsGroupMember(info.name) and Social.IN_GROUP_MARK or "") .. Social.GetStatusTag(info.afk, info.dnd)
        local zoneColor = Social.GetPlaceColor(info.area == myZone)
        GameTooltip:AddDoubleLine(name, info.area, 1, 1, 1, zoneColor.r, zoneColor.g, zoneColor.b)
    end
end

-- shift adds the zone and realm of wow friends and what everybody else is doing
local function AddBNetLines(entries, myZone, showDetails)
    AddSectionTitle(BATTLENET_OPTIONS_LABEL)
    for _, entry in ipairs(entries) do
        local account, game = entry.account, entry.game
        local icon = BNet_GetClientEmbeddedAtlas(game.clientProgram, 14) .. " "
        local status = Social.GetStatusTag(account.isAFK or game.isGameAFK, account.isDND or game.isGameBusy)

        local characterName = GetCharacterName(game)
        if characterName then
            local name = icon .. FormatCharacter(game.characterLevel, characterName, game.className)
                .. (Social.IsGroupMember(characterName, game.realmName) and Social.IN_GROUP_MARK or "") .. status
                .. (game.timerunningSeasonID and Social.TIMERUNNING_ICON or "")
            GameTooltip:AddDoubleLine(name, account.accountName, 1, 1, 1, ACCOUNT_COLOR.r, ACCOUNT_COLOR.g, ACCOUNT_COLOR.b)
            if showDetails then
                local zoneColor = Social.GetPlaceColor(game.areaName == myZone)
                local realmColor = Social.GetPlaceColor(game.realmName == GW.myrealm)
                GameTooltip:AddDoubleLine(game.areaName or game.richPresence, game.realmName, zoneColor.r, zoneColor.g, zoneColor.b, realmColor.r, realmColor.g, realmColor.b)
            end
        else
            local activity = showDetails and not APP_CLIENTS[game.clientProgram] and game.richPresence or ""
            GameTooltip:AddDoubleLine(icon .. account.accountName .. status, activity, ACCOUNT_COLOR.r, ACCOUNT_COLOR.g, ACCOUNT_COLOR.b, OTHER_PLACE_COLOR.r, OTHER_PLACE_COLOR.g, OTHER_PLACE_COLOR.b)
        end
    end
end

-- the micro button tooltip first, the online friends below it
local function Friends_OnEnter(self)
    Social.StartMicroButtonTooltip(self)

    local friends, entries = GetOnlineFriends(), GetOnlineBNetEntries()
    local numBNet, numBNetOnline = BNGetNumFriends()
    local numOnline = #friends + numBNetOnline
    if numOnline > 0 then
        local headerColor = GW.Colors.FactionColors[GW.myfaction] or GW.Colors.FactionColors.Alliance
        local myZone = GW.Libs.GW2Lib:GetPlayerLocationZoneText()

        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(FRIENDS_LIST, format("%s: %d/%d", FRIENDS_LIST_ONLINE, numOnline, C_FriendList.GetNumFriends() + numBNet),
            headerColor.r, headerColor.g, headerColor.b, headerColor.r, headerColor.g, headerColor.b)
        if #friends > 0 then
            AddFriendLines(friends, myZone)
        end
        if #entries > 0 then
            AddBNetLines(entries, myZone, IsShiftKeyDown())
        end
    end

    GameTooltip:Show()
end
GW.Friends_OnEnter = Friends_OnEnter

local function Friends_OnEvent(self, event, key)
    if event == "MODIFIER_STATE_CHANGED" and key:find("SHIFT") and GW.DoesAncestryIncludeAny(self, GetMouseFoci()) then
        Friends_OnEnter(self)
    end
end
GW.Friends_OnEvent = Friends_OnEvent

-- afk and dnd are toggles: sending the active one again clears it
local function SetChatStatus(status)
    local current = IsChatAFK() and "AFK" or IsChatDND() and "DND" or nil
    if current ~= status then
        C_ChatInfo.SendChatMessage("", status or current)
    end
end

local function ShowBroadcastPopup()
    GW.ShowPopup({
        text = BN_BROADCAST_TOOLTIP,
        button1 = ACCEPT,
        button2 = CANCEL,
        hasEditBox = true,
        maxLetters = 127,
        inputText = select(4, BNGetInfo()),
        EditBoxOnEnterPressed = function(popup) BNSetCustomMessage(popup.input:GetText()) end,
        EditBoxOnEscapePressed = function(popup) popup:Hide() end,
        OnAccept = function(popup) BNSetCustomMessage(popup.input:GetText()) end,
        hideOnEscape = true
    })
end

local function BuildMenu(_, root)
    root:SetMinimumWidth(1)
    root:CreateTitle(OPTIONS_MENU)
    local inviteMenu = root:CreateButton(INVITE)
    local whisperMenu = root:CreateButton(CHAT_MSG_WHISPER_INFORM)
    local statusMenu = root:CreateButton(PLAYER_STATUS)
    statusMenu:CreateButton(GREEN_FONT_COLOR:WrapTextInColorCode(AVAILABLE), SetChatStatus)
    statusMenu:CreateButton(YELLOW_FONT_COLOR:WrapTextInColorCode(DND), SetChatStatus, "DND")
    statusMenu:CreateButton(RED_FONT_COLOR:WrapTextInColorCode(AFK), SetChatStatus, "AFK")
    root:CreateButton(BN_BROADCAST_TOOLTIP, ShowBroadcastPopup)

    for _, info in ipairs(GetOnlineFriends()) do
        local label = FormatCharacter(info.level, info.name, info.className)
        whisperMenu:CreateButton(label, function() ChatFrameUtil.SendTell(info.name) end)
        if not Social.IsGroupMember(info.name) then
            inviteMenu:CreateButton(label, function() Social.Invite(info.name, info.guid) end)
        end
    end

    local whisperAdded = {}
    for _, entry in ipairs(GetOnlineBNetEntries()) do
        local account, game = entry.account, entry.game
        if not whisperAdded[account.bnetAccountID] then
            whisperAdded[account.bnetAccountID] = true
            whisperMenu:CreateButton(account.accountName, function() ChatFrameUtil.SendBNetTell(account.accountName) end)
        end
        local characterName = GetCharacterName(game)
        if characterName and game.wowProjectID == WOW_PROJECT_ID and not Social.IsGroupMember(characterName, game.realmName) then
            inviteMenu:CreateButton(FormatCharacter(game.characterLevel, characterName, game.className), function()
                Social.Invite(game.gameAccountID, game.playerGuid, true)
            end)
        end
    end
end

local function Friends_OnClick(self, button)
    if button == "RightButton" then
        MenuUtil.CreateContextMenu(self, BuildMenu)
    end
end
GW.Friends_OnClick = Friends_OnClick
