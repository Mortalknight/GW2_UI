local _, GW = ...

local onlinestatus = {
    [0] = "",
    [1] = format(" |cffFFFFFF[|r|cffFF9900%s|r|cffFFFFFF]|r", AFK),
    [2] = format(" |cffFFFFFF[|r|cffFF3333%s|r|cffFFFFFF]|r", DND),
}
local mobilestatus = {
    [0] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat:14:14:0:0:16:16:0:16:0:16:73:177:73|t]],
    [1] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t]],
    [2] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t]],
}

local TIMERUNNING_ATLAS = "|A:timerunning-glues-icon-small:%s:%s:0:0|a"
local TIMERUNNING_SMALL = format(TIMERUNNING_ATLAS, 12, 10)

local FACTION_ALLIANCE = "|TInterface/AddOns/GW2_UI/Textures/social/GameIcons/Launcher/alliance.png:13:13|t"
local FACTION_HORDE = "|TInterface/AddOns/GW2_UI/Textures/social/GameIcons/Launcher/horde.png:13:13|t"

local tthead = GW.myfaction == "Alliance" and GW.FACTION_COLOR[2] or GW.FACTION_COLOR[1]
local ttsubh = {r = 1, g = 0.93, b = 0.73}
local ttoff = {r = 0.3, g = 1, b = 0.3}
local activezone = {r = 0.3, g = 1.0, b = 0.3}
local inactivezone = {r = 0.65, g = 0.65, b = 0.65}
local guildInfoString = "%s"
local guildInfoString2 = GUILD .. ": %d/%d"
local guildMotDString = "%s |cffaaaaaa- |cffffffff%s"
local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r"
local levelNameStatusString = "%s |cff%02x%02x%02x%d|r %s%s%s %s"
local nameRankString = "%s %s |cff999999-|cffffffff %s"
local standingString = GW.RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b) .. "%s:|r |cFFFFFFFF%s/%s (%s%%)"
local moreMembersOnlineString = strjoin("", "+%d ", FRIENDS_LIST_ONLINE, "...")
local noteString = strjoin("", "|cff999999   ", LABEL_NOTE, ":|r %s")
local officerNoteString = strjoin("", "|cff999999   ", GUILD_RANK1_DESC, ":|r %s")
local clubTable, guildTable = {}, {}
local isFetchingGuild = false
local fetchingGuildWaitQueued = false
local lastGuildFetch = 0
local GUILD_FETCH_INTERVAL = 3

local function sortByRank(a, b)
    if a and b then
        if a.rankIndex == b.rankIndex then
            return a.name < b.name
        end
        return a.rankIndex < b.rankIndex
    end
end

local function sortByName(a, b)
    if a and b then
        return a.name < b.name
    end
end

local function SortGuildTable(shift)
    if shift then
        sort(guildTable, sortByRank)
    else
        sort(guildTable, sortByName)
    end
end

local function inGroup(name)
    return (UnitInParty(name) or UnitInRaid(name)) and "|cffaaaaaa*|r" or ""
end

local function FetchGuildMembers_Internal()
    isFetchingGuild = true
    lastGuildFetch = GetTime()
    wipe(guildTable)
    wipe(clubTable)

    local clubs = C_Club.GetSubscribedClubs()
    if clubs then -- use this to get the timerunning flag (and other info?)
        local guildClubID
        for _, data in next, clubs do
            if data.clubType == Enum.ClubType.Guild then
                guildClubID = data.clubId
                break
            end
        end

        local members = guildClubID and CommunitiesUtil.GetAndSortMemberInfo(guildClubID)
        if members then
            for _, data in next, members do
                if data.guid then
                    clubTable[data.guid] = data
                end
            end
        end
    end

    local totalMembers = GetNumGuildMembers() or 0
    for i = 1, totalMembers do
        local name, rank, rankIndex, level, _, zone, note, officerNote, connected, memberstatus, className, _, _, isMobile, _, _, guid = GetGuildRosterInfo(i)
        if not name then break end

        local statusInfo = isMobile and mobilestatus[memberstatus] or onlinestatus[memberstatus]
        zone = (isMobile and not connected) and REMOTE_CHAT or zone

        if connected or isMobile then
            local clubMember = clubTable[guid]
            local data = {
                name = gsub(name, format("%%-%s", gsub(GW.myrealm, "[%s%-]", "")), ""),
                rank = rank,
                level = level,
                zone = zone,
                note = note,
                officerNote = officerNote,
                online = connected,
                status = statusInfo,
                class = className,
                rankIndex = rankIndex,
                isMobile = isMobile,
                guid = guid
            }

            if clubMember then
                data.timerunningID = clubMember.timerunningSeasonID
                data.faction = clubMember.faction
            end

            guildTable[#guildTable + 1] = data
        end
    end

    isFetchingGuild = false
end

local function FetchGuildMembersRun()
    if isFetchingGuild then
        GW.Wait(0.5, FetchGuildMembersRun)
        return
    end

    local now = GetTime()
    local elapsed = now - lastGuildFetch
    if elapsed < GUILD_FETCH_INTERVAL then
        GW.Wait(GUILD_FETCH_INTERVAL - elapsed, FetchGuildMembersRun)
        return
    end

    FetchGuildMembers_Internal()
    fetchingGuildWaitQueued = false
end

local function FetchGuildMembers()
    if not fetchingGuildWaitQueued then
        fetchingGuildWaitQueued = true
        GW.Wait(0.1, FetchGuildMembersRun)
    end
end
GW.FetchGuildMembers = FetchGuildMembers

local function Guild_OnEnter(self)
    if not IsInGuild() then return end

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

    local shiftDown = IsShiftKeyDown()
    local total, online = GetNumGuildMembers()
    if #guildTable == 0 then FetchGuildMembers() end

    if not total then total = 0 end
    if not online then online = 0 end

    SortGuildTable(shiftDown)

    local guildName, guildRank = GetGuildInfo("player")

    if guildName and guildRank then
        GameTooltip:AddDoubleLine(format(guildInfoString, guildName), format(guildInfoString2, online, total), tthead.r, tthead.g, tthead.b, tthead.r, tthead.g, tthead.b)
        GameTooltip:AddLine(guildRank, 1, 1, 1, 1)
    end

    if GetGuildRosterMOTD() ~= "" then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(format(guildMotDString, GUILD_MOTD, GetGuildRosterMOTD()), tthead.r, tthead.g, tthead.b, 1)
    end

    local guildFactionData = C_Reputation.GetGuildFactionData()
    -- Show only if not on max rep
    if guildFactionData and guildFactionData.reaction ~= 8 then
        local nextReactionThreshold = guildFactionData.nextReactionThreshold - guildFactionData.currentReactionThreshold
        local currentStanding = guildFactionData.currentStanding - guildFactionData.currentReactionThreshold
        GameTooltip:AddLine(format(standingString, COMBAT_FACTION_CHANGE, GW.GetLocalizedNumber(currentStanding), GW.GetLocalizedNumber(nextReactionThreshold), ceil((currentStanding / nextReactionThreshold) * 100)))
    end

    local zonec

    GameTooltip:AddLine(" ")
    local limit = 20
    for i, info in ipairs(guildTable) do
        if i > limit then
            local count = online - limit
            if count > 1 then
                GameTooltip:AddLine(format(moreMembersOnlineString, count), ttsubh.r, ttsubh.g, ttsubh.b)
            end

            break
        end

        local zoneText = GW.Libs.GW2Lib:GetPlayerLocationZoneText()
        if zoneText and (zoneText == info.zone) then
            zonec = activezone
        else
            zonec = inactivezone
        end

        local faction = info.faction == 1 and FACTION_ALLIANCE or info.faction == 0 and FACTION_HORDE or ""

        local classc, levelc = GW.GWGetClassColor(info.class, true, true), GetQuestDifficultyColor(info.level)
        if not classc then classc = levelc end

        if shiftDown then
            GameTooltip:AddDoubleLine(format(nameRankString, faction, info.name, info.rank), info.zone, classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
            if info.note ~= "" then
                GameTooltip:AddLine(format(noteString, info.note), ttsubh.r, ttsubh.g, ttsubh.b, 1)
            end
            if info.officerNote ~= "" then
                GameTooltip:AddLine(format(officerNoteString, info.officerNote), ttoff.r, ttoff.g, ttoff.b, 1)
            end
        else
            GameTooltip:AddDoubleLine(format(levelNameStatusString, faction, levelc.r*255, levelc.g*255, levelc.b*255, info.level, strmatch(info.name,"([^%-]+).*"), inGroup(info.name), info.status, info.timerunningID and TIMERUNNING_SMALL or ""), info.zone, classc.r,classc.g,classc.b, zonec.r,zonec.g,zonec.b)
        end
    end

    GameTooltip:Show()
end
GW.Guild_OnEnter = Guild_OnEnter

local function inviteClick(name, guid)
    if not (name and name ~= "") then return end

    if guid then
        local inviteType = GetDisplayedInviteType(guid)
        if inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" then
            C_PartyInfo.InviteUnit(name)
        elseif inviteType == "REQUEST_INVITE" then
            C_PartyInfo.RequestInviteFromUnit(name)
        end
    end
end

local function whisperClick(playerName)
    SetItemRef("player:" .. playerName, format("|Hplayer:%1$s|h[%1$s]|h", playerName), "LeftButton")
end

local function Guild_OnClick(self, button)
    if button == "LeftButton" then
        self:OnClick()
    elseif button == "RightButton" and IsInGuild() then
        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
            rootDescription:SetMinimumWidth(1)
            rootDescription:CreateTitle(OPTIONS)
            local submenuInvite = rootDescription:CreateButton(INVITE)
            local submenuWisper = rootDescription:CreateButton(CHAT_MSG_WHISPER_INFORM)

            for _, info in ipairs(guildTable) do
                if (info.online or info.isMobile) and strmatch(info.name, "([^%-]+).*") ~= GW.myname then
                    local classc, levelc = GW.GWGetClassColor(info.class, true, true), GetQuestDifficultyColor(info.level)
                    if not classc then classc = levelc end

                    local name = format(levelNameString, levelc.r * 255, levelc.g * 255, levelc.b * 255, info.level, classc.r * 255, classc.g * 255, classc.b * 255, strmatch(info.name, "([^%-]+).*"))
                    if inGroup(strmatch(info.name, "([^%-]+).*")) ~= "" then
                        name = name .. " |cffaaaaaa*|r"
                    elseif not (info.isMobile and info.zone == REMOTE_CHAT) then
                        submenuInvite:CreateButton(name, function()
                            inviteClick(strmatch(info.name, "([^%-]+).*"), info.guid)
                        end)
                    end

                    submenuWisper:CreateButton(name, function()
                        whisperClick(strmatch(info.name, "([^%-]+).*"))
                    end)
                end
            end
        end)
    end
end
GW.Guild_OnClick = Guild_OnClick
