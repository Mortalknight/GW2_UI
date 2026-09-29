---@class GW2
local GW = select(2, ...)

local Social = GW.Social
local GetGuildMOTD = C_GuildInfo and C_GuildInfo.GetMOTD or GetGuildRosterMOTD
local MAX_MEMBERS_SHOWN = 20
local CLUB_REFRESH_INTERVAL = 10
local NOTE_COLOR = CreateColor(1, 0.93, 0.73)
local OFFICER_NOTE_COLOR = GW.Colors.SkinColors.Positive
local FACTION_ICONS = {
    [0] = "|TInterface/AddOns/GW2_UI/Textures/social/GameIcons/Launcher/horde.png:13:13|t ",
    [1] = "|TInterface/AddOns/GW2_UI/Textures/social/GameIcons/Launcher/alliance.png:13:13|t ",
}
-- members on the app show the armory icon, its variants mean away and busy
local MOBILE_ICONS = {
    [0] = " |TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:14:14:0:0:16:16:0:16:0:16:73:177:73|t",
    [1] = " |TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t",
    [2] = " |TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t",
}

local function Plain(value)
    return GW.NotSecretValue(value) and value or nil
end

-- faction and timerunning only the guild community knows; a big guild has many members, so the
-- lookup is kept for a few seconds
local clubMembers, clubMembersTime = {}, 0
local function GetClubMembers()
    if not (C_Club and CommunitiesUtil) or GetTime() - clubMembersTime < CLUB_REFRESH_INTERVAL then
        return clubMembers
    end
    clubMembersTime = GetTime()
    wipe(clubMembers)

    local clubs = C_Club.GetSubscribedClubs()
    if GW.IsSecretValue(clubs) or not clubs then
        return clubMembers
    end
    for _, club in ipairs(clubs) do
        if club.clubType == Enum.ClubType.Guild then
            local memberIDs = CommunitiesUtil.GetMemberIdsSortedByName(club.clubId)
            for _, info in ipairs(CommunitiesUtil.GetMemberInfo(club.clubId, memberIDs) or {}) do
                if Plain(info.guid) then
                    clubMembers[info.guid] = info
                end
            end
            break
        end
    end
    return clubMembers
end

local function SortByName(a, b)
    return a.name < b.name
end

local function SortByRank(a, b)
    if a.rankIndex ~= b.rankIndex then
        return a.rankIndex < b.rankIndex
    end
    return a.name < b.name
end

-- everybody online in game or on the app, sorted by name, or by rank for the shift view
local function GetOnlineMembers(byRank)
    local members, club = {}, GetClubMembers()
    for i = 1, GetNumGuildMembers() do
        local name, rank, rankIndex, level, _, zone, note, officerNote, online, status, class, _, _, isMobile, _, _, guid = GetGuildRosterInfo(i)
        name = Plain(name)
        if name and (online or isMobile) then
            local clubInfo = Plain(guid) and club[guid]
            tinsert(members, {
                name = Ambiguate(name, "guild"),
                fullName = name, -- invites and whispers need the realm
                rank = Plain(rank) or "",
                rankIndex = rankIndex or 0,
                level = level,
                class = class,
                zone = (isMobile and not online) and REMOTE_CHAT or Plain(zone),
                note = Plain(note) or "",
                officerNote = Plain(officerNote) or "",
                status = isMobile and MOBILE_ICONS[status] or Social.GetStatusTag(status == 1, status == 2),
                onlyMobile = isMobile and not online,
                guid = Plain(guid),
                faction = clubInfo and FACTION_ICONS[Plain(clubInfo.faction)] or "",
                timerunning = clubInfo and clubInfo.timerunningSeasonID and Social.TIMERUNNING_ICON or "",
            })
        end
    end
    table.sort(members, byRank and SortByRank or SortByName)
    return members
end

local function AddReputation()
    local data = C_Reputation and C_Reputation.GetGuildFactionData and C_Reputation.GetGuildFactionData()
    if not data or data.reaction == (MAX_REPUTATION_REACTION or 8) then
        return
    end
    local current = data.currentStanding - data.currentReactionThreshold
    local needed = data.nextReactionThreshold - data.currentReactionThreshold
    if needed > 0 then
        GameTooltip:AddDoubleLine(COMBAT_FACTION_CHANGE, format("%s/%s (%d%%)", GW.GetLocalizedNumber(current), GW.GetLocalizedNumber(needed), math.floor(current / needed * 100)),
            NOTE_COLOR.r, NOTE_COLOR.g, NOTE_COLOR.b, 1, 1, 1)
    end
end

-- shift shows rank and notes instead of level and status
local function AddMemberLines(members, showDetails)
    local myZone = GW.Libs.GW2Lib:GetPlayerLocationZoneText()
    for index, member in ipairs(members) do
        if index > MAX_MEMBERS_SHOWN then
            GameTooltip:AddLine(format("+%d %s ...", #members - MAX_MEMBERS_SHOWN, FRIENDS_LIST_ONLINE), NOTE_COLOR.r, NOTE_COLOR.g, NOTE_COLOR.b)
            break
        end

        local zoneColor = Social.GetPlaceColor(member.zone and member.zone == myZone)
        if showDetails then
            local classColor = GW.GWGetClassColor(member.class, true, true)
            GameTooltip:AddDoubleLine(member.faction .. classColor:WrapTextInColorCode(member.name) .. " |cff999999-|r " .. member.rank, member.zone,
                1, 1, 1, zoneColor.r, zoneColor.g, zoneColor.b)
            if member.note ~= "" then
                GameTooltip:AddLine("   " .. LABEL_NOTE .. ": " .. member.note, NOTE_COLOR.r, NOTE_COLOR.g, NOTE_COLOR.b, true)
            end
            if member.officerNote ~= "" then
                GameTooltip:AddLine("   " .. GUILD_RANK1_DESC .. ": " .. member.officerNote, OFFICER_NOTE_COLOR.r, OFFICER_NOTE_COLOR.g, OFFICER_NOTE_COLOR.b, true)
            end
        else
            local line = member.faction .. Social.FormatCharacter(member.level, member.name, member.class)
                .. (Social.IsGroupMember(member.fullName) and Social.IN_GROUP_MARK or "") .. member.status .. member.timerunning
            GameTooltip:AddDoubleLine(line, member.zone, 1, 1, 1, zoneColor.r, zoneColor.g, zoneColor.b)
        end
    end
end

local function Guild_OnEnter(self)
    if not IsInGuild() then
        return
    end
    Social.StartMicroButtonTooltip(self)

    local headerColor = GW.Colors.FactionColors[GW.myfaction] or GW.Colors.FactionColors.Alliance
    local total, online = GetNumGuildMembers()
    local guildName, rankName = GetGuildInfo("player")
    if guildName then
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(guildName, format("%s: %d/%d", GUILD, online or 0, total or 0),
            headerColor.r, headerColor.g, headerColor.b, headerColor.r, headerColor.g, headerColor.b)
        GameTooltip:AddLine(rankName, 1, 1, 1)
    end

    local motd = not InCombatLockdown() and GetGuildMOTD()
    if GW.NotSecretValue(motd) and motd and motd ~= "" then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(GUILD_MOTD .. " |cffaaaaaa-|r |cffffffff" .. motd, headerColor.r, headerColor.g, headerColor.b, true)
    end
    AddReputation()

    local showDetails = IsShiftKeyDown()
    GameTooltip:AddLine(" ")
    AddMemberLines(GetOnlineMembers(showDetails), showDetails)
    GameTooltip:Show()
end
GW.Guild_OnEnter = Guild_OnEnter

local function BuildMenu(_, root)
    root:SetMinimumWidth(1)
    root:CreateTitle(OPTIONS)
    local inviteMenu = root:CreateButton(INVITE)
    local whisperMenu = root:CreateButton(CHAT_MSG_WHISPER_INFORM)

    for _, member in ipairs(GetOnlineMembers()) do
        if member.name ~= GW.myname then
            local label = Social.FormatCharacter(member.level, member.name, member.class)
            if Social.IsGroupMember(member.fullName) then
                label = label .. " " .. Social.IN_GROUP_MARK
            elseif not member.onlyMobile then
                inviteMenu:CreateButton(label, function() Social.Invite(member.fullName, member.guid) end)
            end
            whisperMenu:CreateButton(label, function() ChatFrameUtil.SendTell(member.fullName) end)
        end
    end
end

local function Guild_OnClick(self, button)
    if button == "LeftButton" then
        self:OnClick()
    elseif button == "RightButton" and IsInGuild() then
        MenuUtil.CreateContextMenu(self, BuildMenu)
    end
end
GW.Guild_OnClick = Guild_OnClick
