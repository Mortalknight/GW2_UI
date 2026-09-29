---@class GW2
local GW = select(2, ...)

local BetterDate = TimeUtil and TimeUtil.BetterDate or BetterDate

local function IsEnabled()
    return GW.settings.chat.timeStampFormat and GW.settings.chat.timeStampFormat ~= "NONE"
end

-- "03:27 PM" instead of "03:27PM ", the formats of the dropdown end with a space
local function FormatStamp(when)
    local stamp = gsub(BetterDate(GW.settings.chat.timeStampFormat, when), " ", "")
    stamp = gsub(gsub(stamp, "AM", " AM"), "PM", " PM")
    if GW.settings.chat.gw2Style then
        return "|cff888888[" .. stamp .. "]|r "
    end
    return "[" .. stamp .. "] "
end

-- chat messages always, system lines and prints only with "Add timestamp to all messages"
GW.RegisterChatModule({
    setting = IsEnabled,
    -- blizzards own timestamps would come on top of ours
    onLoad = function()
        if IsEnabled() and C_CVar.GetCVar("showTimestamps") ~= "none" then
            C_CVar.SetCVar("showTimestamps", "none")
        end
    end,
    onLine = function(_, text, _, _, _, _, accessID)
        if GW.IsSecretValue(accessID) or not (accessID or GW.settings.chat.timestampAll) or strmatch(text, "^%s*$") then
            return
        end
        return FormatStamp(time()) .. text
    end,
})
