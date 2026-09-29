---@class GW2
local GW = select(2, ...)

local APP_CLIENTS = {App = true, BSAp = true}
local Social = GW.Social

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

local WOW_NAME = "World of Warcraft"
local ACCOUNT_COLOR = CreateColor(0.93, 0.93, 0.93)

-- the name of a game: wow versions by their project, other games by their client
local function GetGameName(game)
    local client = game.clientProgram
    -- the desktop and the mobile app share one heading
    local code = APP_CLIENTS[client] and "APP" or strupper(client or "")
    local title = GW.friendsList.projectCodes[code] or client or ""
    if client == BNET_CLIENT_WOW then
        local expansion = GW.friendsList.expansionData[game.wowProjectID]
        title = WOW_NAME .. (expansion and expansion.suffix and " " .. expansion.suffix or "")
    end
    return title
end

local function GetSection(sections, key, game, order)
    local section = sections[key]
    if not section then
        local name = GetGameName(game)
        section = {name = name, title = BNet_GetClientEmbeddedAtlas(game.clientProgram, 14) .. " " .. name, order = order, lines = {}}
        sections[key] = section
        tinsert(sections, section)
    end
    return section
end

-- "Character | Level" with afk or dnd behind it, the account name on the right; the place below only
-- while shift is held
local function AddEntry(section, isAFK, isDND, title, account, place, sortName, inMyZone)
    tinsert(section.lines, {
        text = title .. Social.GetStatusTag(isAFK, isDND),
        account = account or "",
        place = place,
        placeColor = Social.GetPlaceColor(inMyZone),
        sortName = sortName or "",
    })
end

local function SortLines(a, b)
    return a.sortName < b.sortName
end

local function SortSections(a, b)
    if a.order ~= b.order then
        return a.order < b.order
    end
    return a.name < b.name
end

-- all online friends by game: our own wow first, then other wow versions, other games and the app
local function CollectSections(showDetails)
    local sections = {}
    local myZone = GW.Libs.GW2Lib:GetPlayerLocationZoneText()

    local ownWow = GetSection(sections, "WoW" .. WOW_PROJECT_ID, {clientProgram = BNET_CLIENT_WOW, wowProjectID = WOW_PROJECT_ID}, 1)
    for _, info in ipairs(GetOnlineFriends()) do
        local name, realm = strsplit("-", info.name)
        local title = GW.friendsList.FormatTitle(nil, WOW_NAME, name, info.className, info.level, WOW_PROJECT_ID)
            .. (Social.IsGroupMember(info.name) and " " .. Social.IN_GROUP_MARK or "")
        AddEntry(ownWow, info.afk, info.dnd, title, nil, showDetails and GW.friendsList.FormatPlace(info.area, realm), name, info.area == myZone)
    end

    for _, entry in ipairs(GetOnlineBNetEntries()) do
        local account, game = entry.account, entry.game
        local key = game.clientProgram == BNET_CLIENT_WOW and "WoW" .. (game.wowProjectID or "") or APP_CLIENTS[game.clientProgram] and "App" or game.clientProgram
        local section = GetSection(sections, key, game, entry.order)
        local isAFK, isDND = account.isAFK or game.isGameAFK, account.isDND or game.isGameBusy

        local characterName = GetCharacterName(game)
        if characterName then
            local realm = game.realmDisplayName or game.realmName
            local title = GW.friendsList.FormatTitle(nil, WOW_NAME, characterName, game.className, game.characterLevel,
                game.wowProjectID, game.timerunningSeasonID)
                .. (Social.IsGroupMember(characterName, game.realmName) and " " .. Social.IN_GROUP_MARK or "")
            local place = showDetails and GW.friendsList.FormatPlace(game.areaName, realm)
            AddEntry(section, isAFK, isDND, title, account.accountName, place ~= "" and place or showDetails and game.richPresence, characterName, game.areaName == myZone)
        else
            local gameName = GW.friendsList.projectCodes[strupper(game.clientProgram or "")]
            local activity = showDetails and not APP_CLIENTS[game.clientProgram] and game.richPresence or nil
            AddEntry(section, isAFK, isDND, GW.friendsList.FormatTitle(account.accountName, gameName), nil, activity, account.accountName)
        end
    end

    table.sort(sections, SortSections)
    return sections
end

-- the micro button tooltip first, the online friends below it; shift adds what the others are doing
local function Friends_OnEnter(self)
    Social.StartMicroButtonTooltip(self)

    local numBNet, numBNetOnline = BNGetNumFriends()
    local numOnline = C_FriendList.GetNumOnlineFriends() + numBNetOnline
    if numOnline > 0 then
        local r, g, b = GW.Colors.TextColors.LightHeader:GetRGB()
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(FRIENDS_LIST, format("%s: %d/%d", FRIENDS_LIST_ONLINE, numOnline, C_FriendList.GetNumFriends() + numBNet), r, g, b, r, g, b)

        for _, section in ipairs(CollectSections(IsShiftKeyDown())) do
            if #section.lines > 0 then
                table.sort(section.lines, SortLines)
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(section.title, r, g, b)
                for _, line in ipairs(section.lines) do
                    GameTooltip:AddDoubleLine(line.text, line.account, 1, 1, 1, ACCOUNT_COLOR:GetRGB())
                    if line.place and line.place ~= "" then
                        GameTooltip:AddLine("   " .. line.place, line.placeColor:GetRGB())
                    end
                end
            end
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
