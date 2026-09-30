---@class GW2
local GW = select(2, ...)

-- Blizzard registers the channel events on every chat window and only checks the window's
-- channel list after the message went through all filters. Windows without channels
-- therefore drop these events; the lists only change through the methods hooked below.
local CHANNEL_EVENTS = { "CHAT_MSG_CHANNEL", "CHAT_MSG_COMMUNITIES_CHANNEL" }
local CHANNEL_METHODS = { "RegisterForChannels", "AddChannel", "RemoveChannel", "RemoveAllChannels" }

local function UpdateChannelEvents(chatFrame)
    -- the default window gets channels written in directly (/join) and adds regional ones itself
    local wanted = chatFrame == DEFAULT_CHAT_FRAME or next(chatFrame.channelList) ~= nil
    for _, event in ipairs(CHANNEL_EVENTS) do
        if wanted then
            chatFrame:RegisterEvent(event)
        else
            chatFrame:UnregisterEvent(event)
        end
    end
end

GW.RegisterChatModule({
    onFrame = function(chatFrame)
        if not chatFrame.channelList then return end
        for _, method in ipairs(CHANNEL_METHODS) do
            if chatFrame[method] then
                hooksecurefunc(chatFrame, method, UpdateChannelEvents)
            end
        end
        UpdateChannelEvents(chatFrame)
    end,
})
