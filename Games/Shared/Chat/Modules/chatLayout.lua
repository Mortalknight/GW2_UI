---@class GW2
local GW = select(2, ...)
local L = GW.L

-- the chat tabs of a character saved into the profile and built again from it on another character, only on request:
-- blizzard keeps the chat settings per character on the server, a permanent binding would fight with that

local COMBAT_LOG_INDEX = 2

local function IsWindowInUse(index, shown, docked)
    return index <= COMBAT_LOG_INDEX or shown or docked
end

local function SaveWindow(index)
    local name, fontSize, r, g, b, alpha, shown, locked, docked = GetChatWindowInfo(index)
    if not IsWindowInUse(index, shown, docked) then return end

    local window = {index = index, name = name, fontSize = fontSize, color = {r, g, b, alpha}, locked = locked, docked = docked}
    if index ~= COMBAT_LOG_INDEX then
        window.messageGroups = {GetChatWindowMessages(index)}
        -- name and zone alternate, only the names count
        window.channels = {}
        local channels = {GetChatWindowChannels(index)}
        for i = 1, #channels, 2 do
            tinsert(window.channels, channels[i])
        end
    end
    if not docked then
        window.position = {GetChatWindowSavedPosition(index)}
        window.size = {GetChatWindowSavedDimensions(index)}
    end
    return window
end

function GW.SaveChatLayout()
    local layout = {windows = {}, colors = {}, channelColors = {}}

    for index = 1, Constants.ChatFrameConstants.MaxChatWindows do
        local window = SaveWindow(index)
        if window then
            tinsert(layout.windows, window)
            -- channel numbers differ per character, their colors go by the channel name
            for _, channel in ipairs(window.channels or {}) do
                local id = GetChannelName(channel)
                local info = id and id > 0 and ChatTypeInfo["CHANNEL" .. id]
                if info then
                    layout.channelColors[channel] = {info.r, info.g, info.b}
                end
            end
        end
    end
    for chatType, info in pairs(ChatTypeInfo) do
        if not strmatch(chatType, "^CHANNEL%d") and info.r then
            layout.colors[chatType] = {info.r, info.g, info.b}
        end
    end

    GW.settings.chat.savedLayout = layout
    GW.Notice(L["Chat layout saved to the profile."])
end

local function ApplyWindow(frame, window, missingChannels)
    FCF_SetWindowName(frame, window.name)
    FCF_SetChatWindowFontSize(nil, frame, window.fontSize)
    FCF_SetWindowColor(frame, window.color[1], window.color[2], window.color[3])
    FCF_SetWindowAlpha(frame, window.color[4])
    FCF_SetLocked(frame, window.locked)

    if window.messageGroups then
        frame:RemoveAllMessageGroups()
        for _, group in ipairs(window.messageGroups) do
            frame:AddMessageGroup(group)
        end
        frame:RemoveAllChannels()
        for _, channel in ipairs(window.channels) do
            if GetChannelName(channel) > 0 then
                frame:AddChannel(channel)
            else
                missingChannels[channel] = true
            end
        end
    end

    -- new tabs come docked, the combat log may sit elsewhere on this character
    if window.docked then
        if not frame.isDocked then
            FCF_DockFrame(frame, window.docked)
        end
    elseif window.position[1] then
        FCF_UnDockFrame(frame)
        SetChatWindowSavedPosition(frame:GetID(), unpack(window.position))
        SetChatWindowSavedDimensions(frame:GetID(), unpack(window.size))
        FCF_RestorePositionAndDimensions(frame)
        frame:Show()
    end
end

function GW.ApplyChatLayout()
    local layout = GW.settings.chat.savedLayout
    if not (layout and layout.windows) then
        GW.Notice(L["No chat layout saved in this profile."])
        return
    end
    if InCombatLockdown() or GW.IsChatRestricted() then
        GW.Notice(L["The chat layout can't be changed right now."])
        return
    end

    -- the extra tabs are built again in the saved order, which also gives the saved dock order
    for index = Constants.ChatFrameConstants.MaxChatWindows, COMBAT_LOG_INDEX + 1, -1 do
        local _, _, _, _, _, _, shown, _, docked = GetChatWindowInfo(index)
        if shown or docked then
            FCF_Close(_G["ChatFrame" .. index])
        end
    end

    local windows = CopyTable(layout.windows)
    table.sort(windows, function(a, b)
        return (a.docked or math.huge) < (b.docked or math.huge)
    end)

    local missingChannels = {}
    for _, window in ipairs(windows) do
        local frame = window.index <= COMBAT_LOG_INDEX and _G["ChatFrame" .. window.index] or FCF_OpenNewWindow(window.name, true)
        if frame then
            ApplyWindow(frame, window, missingChannels)
        end
    end

    for chatType, color in pairs(layout.colors) do
        if ChatTypeInfo[chatType] then
            ChangeChatColor(chatType, unpack(color))
        end
    end
    for channel, color in pairs(layout.channelColors) do
        local id = GetChannelName(channel)
        if id > 0 then
            ChangeChatColor("CHANNEL" .. id, unpack(color))
        end
    end

    FCF_SelectDockFrame(ChatFrame1)
    local missing = {}
    for channel in pairs(missingChannels) do
        tinsert(missing, channel)
    end
    if #missing > 0 then
        GW.Notice(format(L["Chat layout applied, these channels are not joined on this character: %s"], table.concat(missing, ", ")))
    else
        GW.Notice(L["Chat layout applied."])
    end
end
