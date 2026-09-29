---@class GW2
local GW = select(2, ...)

local ALERT_COOLDOWN = 5

local keywords = {}
local alertTimer

-- a comma separated list, %MYNAME% stands for the current character
local function UpdateKeywords()
    wipe(keywords)
    for keyword in gmatch(GW.settings.chat.keywords.list or "", "[^,]+") do
        keyword = strtrim(keyword)
        if keyword == "%MYNAME%" then
            keyword = GW.myname
        end
        if keyword ~= "" then
            keywords[strlower(keyword)] = true
        end
    end
end
GW.UpdateChatKeywords = UpdateKeywords

local function PlayAlert()
    local sound = GW.settings.chat.keywords.alertNew
    if alertTimer or not sound or sound == "None" then
        return
    end
    alertTimer = C_Timer.NewTimer(ALERT_COOLDOWN, function() alertTimer = nil end)
    PlaySoundFile(GW.Libs.LSM:Fetch("sound", sound), "Master")
end

local function HighlightKeywords(msg)
    local color = GW.private.CHAT_KEYWORDS_ALERT_COLOR
    local colorCode = GW.RGBToHex(color.r, color.g, color.b)
    local found = false
    local text = GW.MapChatText(msg, function(plain)
        return (gsub(plain, "[^%s%p]+", function(word)
            if keywords[strlower(word)] then
                found = true
                return colorCode .. word .. "|r"
            end
        end))
    end)
    return text, found
end

GW.RegisterChatModule({
    events = GW.CHAT_MESSAGE_EVENTS,
    onLoad = UpdateKeywords,
    onMessage = function(_, _, msg, author, ...)
        if not next(keywords) then
            return
        end
        local text, found = HighlightKeywords(msg)
        if not found then
            return
        end
        -- no alert for what the player wrote
        if not author or Ambiguate(author, "none") ~= GW.myname then
            PlayAlert()
        end
        return false, text, author, ...
    end,
})
