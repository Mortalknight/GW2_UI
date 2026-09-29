---@class GW2
local GW = select(2, ...)

-- a word is linked when it looks like one of these: scheme://host, www.host.tld, mail address, ip with optional port
local URL_PATTERNS = {
    "^%a[%w+.-]*://%S+$",
    "^www%.[%w-]+%.%S+$",
    "^[%w._%%+-]+@[%w-]+%.[%w.-]+$",
    "^%d+%.%d+%.%d+%.%d+:?%d*$",
}

local function IsURL(word)
    if strfind(word, "|", 1, true) then
        return false
    end
    for _, pattern in ipairs(URL_PATTERNS) do
        if strmatch(word, pattern) then
            return true
        end
    end
    return false
end

local function LinkWords(text)
    return (gsub(text, "%S+", function(word)
        if IsURL(word) then
            return GW.CreateChatLink("url", word, "|cffffffff[" .. word .. "]|r")
        end
    end))
end

GW.RegisterChatModule({
    setting = "findUrl",
    events = GW.CHAT_MESSAGE_EVENTS,
    onMessage = function(_, _, msg, ...)
        local linked = GW.MapChatText(msg, LinkWords)
        if linked ~= msg then
            return false, linked, ...
        end
    end,
    links = {url = function(url) GW.PutIntoChatEditBox(url, true) end},
})
