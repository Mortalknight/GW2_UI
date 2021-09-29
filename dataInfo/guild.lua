local _, GW = ...
local CommaValue = GW.CommaValue

local guildTable = {}

local menuList = {
    {text = OPTIONS, isTitle = true, notCheckable=true},
    {text = INVITE, hasArrow = true, notCheckable=true,},
    {text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable=true,}
}

local onlinestatus = {
    [0] = "",
    [1] = "|cffFFFFFF[|r|cffFF0000" .. AFK .. "|r|cffFFFFFF]|r",
    [2] = "|cffFFFFFF[|r|cffFF0000" .. DND .. "|r|cffFFFFFF]|r",
}
local mobilestatus = {
    [0] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat:14:14:0:0:16:16:0:16:0:16:73:177:73|t]],
    [1] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t]],
    [2] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t]],
}

local tthead = GW.myfaction == "Alliance" and GW.FACTION_COLOR[2] or GW.FACTION_COLOR[1]
local ttsubh = {r = 1, g = 0.93, b = 0.73}
local ttoff = {r = 0.3, g = 1, b = 0.3}
local activezone = {r = 0.3, g = 1.0, b = 0.3}
local inactivezone = {r = 0.65, g = 0.65, b = 0.65}

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
        if self.minLevel then
            GameTooltip:AddLine(format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, self.minLevel), RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        elseif self.disabledTooltip then
            local disabledTooltipText = GetValueOrCallFunction(self, "disabledTooltip")
            GameTooltip:AddLine(disabledTooltipText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true)
        end
    end
    GameTooltip:AddLine(" ")

    local shiftDown = IsShiftKeyDown()
    local total, _, online = GetNumGuildMembers()
    if #guildTable == 0 then FetchGuildMembers() end

    SortGuildTable(shiftDown)

    local guildName, guildRank = GetGuildInfo("player")

    if guildName and guildRank then
        GameTooltip:AddDoubleLine(guildName, GUILD .. ": " .. online .. "/" .. total, tthead.r, tthead.g, tthead.b, tthead.r, tthead.g, tthead.b)
        GameTooltip:AddLine(guildRank, 1, 1, 1, 1)
    end

    if GetGuildRosterMOTD() ~= "" then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(GUILD_MOTD .. " |cffaaaaaa- |cffffffff" .. GetGuildRosterMOTD(), tthead.r, tthead.g, tthead.b, 1)
    end

    --local _, _, standingID, barMin, barMax, barValue = GetGuildFactionInfo()
    -- Show only if not on max rep
    --if standingID ~= 8 then
    --    barMax = barMax - barMin
    --    barValue = barValue - barMin
    --    GameTooltip:AddLine(GW.RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b) .. COMBAT_FACTION_CHANGE .. ":|r |cFFFFFFFF" .. CommaValue(barValue) .. "/" .. CommaValue(barMax) .. "(" .. ceil((barValue / barMax) * 100) .. "%)")
    --end

    local zonec

    GameTooltip:AddLine(" ")
    for i, info in ipairs(guildTable) do
        if i > 20 then
            GameTooltip:AddLine("+ " .. (online - 20) .. " " .. BINDING_HEADER_OTHER, ttsubh.r, ttsubh.g, ttsubh.b)
            break
        end

        if GW.locationData.ZoneText and (GW.locationData.ZoneText == info.zone) then
            zonec = activezone
        else
            zonec = inactivezone
        end

        local classc, levelc = GW.GWGetClassColor(info.class, true, true), GetQuestDifficultyColor(info.level)
        if not classc then classc = levelc end

        if shiftDown then
            GameTooltip:AddDoubleLine(strmatch(info.name, "([^%-]+).*") .. " |cff999999-|cffffffff " .. info.rank, info.zone, classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
            if info.note ~= "" then
                GameTooltip:AddLine("|cff999999   " .. LABEL_NOTE .. ":|r " .. info.note, ttsubh.r, ttsubh.g, ttsubh.b, 1)
            end
            if info.officerNote ~= "" then
                GameTooltip:AddLine("|cff999999   " .. GUILD_RANK1_DESC .. ":|r " .. info.officerNote, ttoff.r, ttoff.g, ttoff.b, 1)
            end
        else
            GameTooltip:AddDoubleLine(format("|cff%02x%02x%02x%d|r %s%s %s", levelc.r * 255, levelc.g * 255, levelc.b * 255, info.level, strmatch(info.name, "([^%-]+).*"), inGroup(info.name), info.status), info.zone, classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
        end
    end

    GameTooltip:Show()
end
GW.Guild_OnEnter = Guild_OnEnter

local function inviteClick(_, name, guid)
    GW.EasyMenu:Hide()

    if not (name and name ~= "") then return end

    if guid then
        local inviteType = GetDisplayedInviteType(guid)
        if inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" then
            InviteUnit(name)
        elseif inviteType == "REQUEST_INVITE" then
            RequestInviteFromUnit(name)
        end
    end
end

local function whisperClick(_, playerName)
    GW.EasyMenu:Hide()
    SetItemRef("player:" .. playerName, format("|Hplayer:%1$s|h[%1$s]|h", playerName), "LeftButton")
end

local function Guild_OnClick(self, button)
    if button == "RightButton" and IsInGuild() then
        local menuCountWhispers = 0
        local menuCountInvites = 0

        menuList[2].menuList = {}
        menuList[3].menuList = {}

        for _, info in ipairs(guildTable) do
            if (info.online or info.isMobile) and strmatch(info.name, "([^%-]+).*") ~= GW.myname then
                local classc, levelc = GW.GWGetClassColor(info.class, true, true), GetQuestDifficultyColor(info.level)
                if not classc then classc = levelc end

                local name = format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r", levelc.r * 255, levelc.g * 255, levelc.b * 255, info.level, classc.r * 255, classc.g * 255, classc.b * 255, strmatch(info.name, "([^%-]+).*"))
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
        EasyMenu(menuList, GW.EasyMenu, nil, nil, nil, "MENU")
    elseif InCombatLockdown() then
        UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT)
    else
        --Workaround until blizz fixes ToggleGuildFrame correctly
        if IsInGuild() then
            ToggleFriendsFrame(3)
        else
            ToggleFriendsFrame()
        end
    end
end
GW.Guild_OnClick = Guild_OnClick
