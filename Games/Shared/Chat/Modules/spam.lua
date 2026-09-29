---@class GW2
local GW = select(2, ...)

local PRUNE_INTERVAL = 60

-- when and in which line a sender last wrote a text; a chat event reaches every chat
-- window with the same line id, so only a new line with the same text is a repeat
local lastTime, lastLine = {}, {}
local nextPrune = 0

local function GetKey(msg, author)
    if GW.IsSecretValue(author) or GW.IsSecretValue(msg) or not author or author == "" or not msg or msg == "" then
        return
    end
    if Ambiguate(author, "none") == GW.myname then
        return
    end
    return strupper(author) .. msg
end

local function Prune(now, interval)
    if now < nextPrune then
        return
    end
    nextPrune = now + PRUNE_INTERVAL
    for key, time in pairs(lastTime) do
        if now - time >= interval then
            lastTime[key], lastLine[key] = nil, nil
        end
    end
end

local function IsRepeat(msg, author, lineID)
    local interval = GW.settings.chat.spamInterval
    local key = interval > 0 and GetKey(msg, author)
    return key and lastLine[key] and lastLine[key] ~= lineID and GetTime() - lastTime[key] < interval or false
end

function GW.DisableChatThrottle()
    wipe(lastTime)
    wipe(lastLine)
end

GW.RegisterChatModule({
    setting = function() return GW.settings.chat.spamInterval > 0 end,
    events = {"CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_CHANNEL"},
    onMessage = function(_, _, msg, author, ...)
        local lineID = select(9, ...) -- ... starts at arg3, so this is arg11
        if GW.IsSecretValue(lineID) then
            return
        end
        if IsRepeat(msg, author, lineID) then
            return true
        end
        local key = GetKey(msg, author)
        if key then
            local now = GetTime()
            lastTime[key], lastLine[key] = now, lineID
            Prune(now, GW.settings.chat.spamInterval)
        end
    end,
})
