local _, GW = ...
local L = GW.L
local CommaValue = GW.CommaValue

local guildTable = {}

local menuList = {
    {text = OPTIONS, isTitle = true, notCheckable=true},
    {text = INVITE, hasArrow = true, notCheckable=true,},
    {text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable=true,}
}

local onlinestatusstring = "|cffFFFFFF[|r|cffFF0000%s|r|cffFFFFFF]|r"
local onlinestatus = {
    [0] = "",
    [1] = format(onlinestatusstring, AFK),
    [2] = format(onlinestatusstring, DND),
}
local mobilestatus = {
    [0] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat:14:14:0:0:16:16:0:16:0:16:73:177:73|t]],
    [1] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t]],
    [2] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t]],
}

local tthead, ttsubh, ttoff = {r = 1, g = 0.93, b = 0.73}, {r = 1, g = 0.93, b = 0.73}, {r = 0.3, g = 1, b = 0.3}
local activezone, inactivezone = {r = 0.3, g = 1.0, b = 0.3}, {r = 0.65, g = 0.65, b = 0.65}
local displayString = ""
local noGuildString = ""
local guildInfoString = "%s"
local guildInfoString2 = GUILD .. ": %d/%d"
local guildMotDString = "%s |cffaaaaaa- |cffffffff%s"
local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r"
local levelNameStatusString = "|cff%02x%02x%02x%d|r %s%s %s"
local nameRankString = "%s |cff999999-|cffffffff %s"
local standingString = GW.RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b) .. "%s:|r |cFFFFFFFF%s/%s (%s%%)"
local moreMembersOnlineString = strjoin("", "+ %d ", FRIENDS_LIST_ONLINE, "...")
local noteString = strjoin("", "|cff999999   ", LABEL_NOTE, ":|r %s")
local officerNoteString = strjoin("", "|cff999999   ", GUILD_RANK1_DESC, ":|r %s")

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

local function FetchGuildMembers()
    wipe(guildTable)

    local totalMembers = GetNumGuildMembers()
    for i = 1, totalMembers do
        local name, rank, rankIndex, level, _, zone, note, officerNote, connected, memberstatus, className, _, _, isMobile, _, _, guid = GetGuildRosterInfo(i)
        if not name then return end

        local statusInfo = isMobile and mobilestatus[memberstatus] or onlinestatus[memberstatus]
        zone = (isMobile and not connected) and REMOTE_CHAT or zone

        if connected or isMobile then
            guildTable[#guildTable + 1] = {
                name = gsub(name, gsub(GW.myrealm, "[%s%-]", ""), ""),
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
        end
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
    GameTooltip_AddBlankLineToTooltip(GameTooltip)

    local shiftDown = IsShiftKeyDown()
    local total, _, online = GetNumGuildMembers()
    if #guildTable == 0 then FetchGuildMembers() end

    SortGuildTable(shiftDown)

    local guildName, guildRank = GetGuildInfo("player")
    local applicants = GetNumGuildApplicants()

    if guildName and guildRank then
        GameTooltip:AddDoubleLine(format(guildInfoString, guildName), format(guildInfoString2 .. (applicants > 0 and " |cFFFFFFFF(|cff33ff33%d|r|cFFFFFFFF)|r" or ""), online, total, applicants), tthead.r, tthead.g, tthead.b, tthead.r, tthead.g, tthead.b)
        GameTooltip:AddLine(guildRank, 1, 1, 1, 1)
    end

    if GetGuildRosterMOTD() ~= "" then
        GameTooltip_AddBlankLineToTooltip(GameTooltip)
        GameTooltip:AddLine(format(guildMotDString, GUILD_MOTD, GetGuildRosterMOTD()), ttsubh.r, ttsubh.g, ttsubh.b, 1)
    end

    local _, _, standingID, barMin, barMax, barValue = GetGuildFactionInfo()
    if standingID ~= 8 then -- Not Max Rep
        barMax = barMax - barMin
        barValue = barValue - barMin
        GameTooltip:AddLine(format(standingString, COMBAT_FACTION_CHANGE, CommaValue(barValue), CommaValue(barMax), ceil((barValue / barMax) * 100)))
    end

    local zonec

    GameTooltip_AddBlankLineToTooltip(GameTooltip)
    for i, info in ipairs(guildTable) do
        if i > 20 then
            GameTooltip:AddLine(format(moreMembersOnlineString, online - 20), ttsubh.r, ttsubh.g, ttsubh.b)
            break
        end

        if GW.locationData.ZoneText and (GW.locationData.ZoneText == info.zone) then zonec = activezone else zonec = inactivezone end

        local classc, levelc = GW.GWGetClassColor(info.class, true, true), GetQuestDifficultyColor(info.level)
        if not classc then classc = levelc end

        if shiftDown then
            GameTooltip:AddDoubleLine(format(nameRankString, strmatch(info.name, "([^%-]+).*"), info.rank), info.zone, classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
            if info.note ~= "" then GameTooltip:AddLine(format(noteString, info.note), ttsubh.r, ttsubh.g, ttsubh.b, 1) end
            if info.officerNote ~= "" then GameTooltip:AddLine(format(officerNoteString, info.officerNote), ttoff.r, ttoff.g, ttoff.b, 1) end
        else
            GameTooltip:AddDoubleLine(format(levelNameStatusString, levelc.r * 255, levelc.g * 255, levelc.b * 255, info.level, strmatch(info.name, "([^%-]+).*"), inGroup(info.name), info.status), info.zone, classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
        end
    end

    GameTooltip:Show()
end
GW.Guild_OnEnter = Guild_OnEnter

local function inviteClick(self, name, guid)
    GW.EasyMenu:Hide()

    if not (name and name ~= "") then return end

    if guid then
        local inviteType = GetDisplayedInviteType(guid)
        if inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" then
            C_PartyInfo.InviteUnit(name)
        elseif inviteType == "REQUEST_INVITE" then
            C_PartyInfo.RequestInviteFromUnit(name)
        end
    else
        C_PartyInfo.InviteUnit(name)
    end
end

local function whisperClick(self, playerName)
    GW.EasyMenu:Hide()
    SetItemRef("player:" .. playerName, format("|Hplayer:%1$s|h[%1$s]|h", playerName), "LeftButton")
end

local function Guild_OnClick(self, button)
    if button == "LeftButton" then
        self:OnClick()
    elseif button == "RightButton" and IsInGuild() then
        local menuCountWhispers = 0
        local menuCountInvites = 0

        menuList[2].menuList = {}
        menuList[3].menuList = {}

        for _, info in ipairs(guildTable) do
            if (info.online or info.isMobile) and strmatch(info.name, "([^%-]+).*") ~= GW.myname then
                local classc, levelc = GW.GWGetClassColor(info.class, true, true), GetQuestDifficultyColor(info.level)
                if not classc then classc = levelc end

                local name = format(levelNameString, levelc.r * 255, levelc.g * 255, levelc.b * 255, info.level, classc.r * 255, classc.g * 255, classc.b * 255, strmatch(info.name, "([^%-]+).*"))
                if inGroup(strmatch(info.name, "([^%-]+).*")) ~= "" then
                    name = name .. " |cffaaaaaa*|r"
                elseif not (info.isMobile and info.zone == REMOTE_CHAT) then
                    menuCountInvites = menuCountInvites + 1
                    menuList[2].menuList[menuCountInvites] = {text = name, arg1 = strmatch(info.name, "([^%-]+).*"), arg2 = info.guid, notCheckable = true, func = inviteClick}
                end

                menuCountWhispers = menuCountWhispers + 1
                menuList[3].menuList[menuCountWhispers] = {text = name, arg1 = strmatch(info.name, "([^%-]+).*"), notCheckable = true, func = whisperClick}
            end
        end
        GW.SetEasyMenuAnchor(GW.EasyMenu, self)
        _G.EasyMenu(menuList, GW.EasyMenu, nil, nil, nil, "MENU")
    end
end
GW.Guild_OnClick = Guild_OnClick