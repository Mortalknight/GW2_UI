---@class GW2
local GW = select(2, ...)

-- chat types by the setting group they belong to
local HISTORY_GROUPS = {
    WHISPER = "WHISPER", WHISPER_INFORM = "WHISPER", BN_WHISPER = "WHISPER", BN_WHISPER_INFORM = "WHISPER",
    GUILD = "GUILD", GUILD_ACHIEVEMENT = "GUILD", OFFICER = "OFFICER",
    PARTY = "PARTY", PARTY_LEADER = "PARTY",
    RAID = "RAID", RAID_LEADER = "RAID", RAID_WARNING = "RAID",
    INSTANCE_CHAT = "INSTANCE", INSTANCE_CHAT_LEADER = "INSTANCE",
    SAY = "SAY", YELL = "YELL", EMOTE = "EMOTE",
}

local function GetHistoryGroup(infoID)
    local chatType = infoID and C_ChatInfo.GetChatTypeName(infoID)
    if chatType and strmatch(chatType, "^CHANNEL") then
        return "CHANNEL"
    end
    return chatType and HISTORY_GROUPS[chatType]
end

-- the finished lines per chat window: {text, r, g, b, infoID}
local function GetStore()
    local log = GW.private.ChatHistoryLog
    if type(log.frames) ~= "table" then
        wipe(log) -- the old format kept raw event args, those lines are gone
        log.frames = {}
    end
    return log.frames
end

local function IsEnabled()
    return GW.settings.chat.history.enabled
end

-- the last module on the line stage, so it keeps what the player saw
local function StoreLine(chatFrame, text, r, g, b, infoID, accessID)
    if GW.IsSecretValue(infoID) or GW.IsSecretValue(accessID) then
        return
    end
    local frameName = chatFrame.GetName and chatFrame:GetName()
    local group = accessID and frameName and GetHistoryGroup(infoID)
    -- battle.net names are tokens of the running session, next time they would show nothing
    if not group or not GW.settings.chat.history.types[group] or strfind(text, "|K", 1, true) then
        return
    end

    local frames = GetStore()
    local lines = frames[frameName] or {}
    frames[frameName] = lines
    tinsert(lines, {text, r, g, b, infoID})
    while #lines > GW.settings.chat.history.size do
        tremove(lines, 1)
    end
end

-- backfilled lines go behind what the window already has, so the history always ends up
-- above the messages of this session, however early other addons printed theirs
local function RestoreHistory()
    if not IsEnabled() then
        return
    end
    for frameName, lines in pairs(GetStore()) do
        local chatFrame = _G[frameName]
        if chatFrame and chatFrame.BackFillMessage then
            for i = #lines, 1, -1 do
                local line = lines[i]
                chatFrame:BackFillMessage(line[1], line[2], line[3], line[4], line[5])
            end
        end
    end
end

GW.RegisterChatModule({
    setting = IsEnabled,
    onLoad = RestoreHistory,
    onLine = StoreLine,
})
