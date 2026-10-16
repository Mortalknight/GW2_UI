---@class GW2
local GW = select(2, ...)

-- a name in front of the own messages in the selected chats, like the addon Name2Chat; blizzard calls
-- OnPreSendText right before it reads the text and sends it, so the message still goes out through blizzard
local CHAT_TYPES = {GUILD = "GUILD", PARTY = "PARTY", RAID = "RAID", INSTANCE_CHAT = "INSTANCE"}

-- the prefix the text gets in this edit box, nil when it gets none
local function GetChatNamePrefix(editBox, text)
    local settings = GW.settings.chat.nameInChat
    local name = strtrim(settings.name or "")
    if not GW.settings.chat.enabled or not settings.enabled or name == "" or GW.IsChatRestricted() then
        return
    end
    if settings.hideOwnName and strlower(name) == strlower(GW.myname) then
        return
    end
    -- slash commands while they are typed, blizzard never sends them as a message
    local first = strsub(text, 1, 1)
    if first == "/" or (settings.ignoreCommands and first == "!") then
        return
    end

    local chatType = editBox:GetAttribute("chatType")
    if chatType == "CHANNEL" then
        local channel = strlower(strtrim(settings.channel or ""))
        local _, channelName = GetChannelName(editBox:GetAttribute("channelTarget") or 0)
        -- the channel name carries the zone for the general channels ("General - Stormwind")
        if channel == "" or not channelName or strfind(strlower(channelName), channel, 1, true) ~= 1 then
            return
        end
    elseif not (CHAT_TYPES[chatType] and settings.channels[CHAT_TYPES[chatType]]) then
        return
    end
    return "(" .. name .. "): "
end
GW.GetChatNamePrefix = GetChatNamePrefix

local function AddName(editBox)
    local text = editBox:GetText()
    local prefix = GetChatNamePrefix(editBox, text)
    -- a line from the history already carries it
    if prefix and strfind(text, "%S") and strsub(text, 1, #prefix) ~= prefix then
        editBox:SetText(prefix .. text)
    end
end

GW.RegisterChatModule({
    onFrame = function(chatFrame)
        local editBox = chatFrame.editBox or _G[chatFrame:GetName() .. "EditBox"]
        if editBox and editBox.OnPreSendText then
            hooksecurefunc(editBox, "OnPreSendText", AddName)
        end
    end,
})
