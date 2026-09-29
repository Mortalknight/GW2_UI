---@class GW2
local GW = select(2, ...)

-- quick join exists on the modern clients only
if not (C_SocialQueue and SocialQueueUtil_GetHeaderName) then
    return
end

local REPEAT_DELAY = 180

local lastShown = {}

-- the text of blizzards quick join toast: who, and what for
local function GetGroupText(guid)
    local queues = C_SocialQueue.GetGroupQueues(guid)
    local first, extra = nil, 0
    for _, queue in ipairs(queues or {}) do
        if queue.eligible and queue.queueData then
            if first then
                extra = extra + 1
            else
                first = queue
            end
        end
    end
    if not first then
        return
    end

    local queueName = gsub(SocialQueueUtil_GetQueueName(first.queueData), "\n", ", ")
    if extra > 0 then
        queueName = format(QUICK_JOIN_TOAST_EXTRA_QUEUES, queueName, extra)
    end
    local message = first.queueData.queueType == "lfglist" and QUICK_JOIN_TOAST_LFGLIST_MESSAGE or QUICK_JOIN_TOAST_MESSAGE
    return format(message, SocialQueueUtil_GetHeaderName(guid), queueName)
end

local function IsRecent(text, now)
    for shownText, time in pairs(lastShown) do
        if now - time >= REPEAT_DELAY then
            lastShown[shownText] = nil
        end
    end
    return lastShown[text] ~= nil
end

local function OnQueueUpdate(_, _, guid, numAddedItems)
    if GW.IsSecretValue(guid) or GW.IsSecretValue(numAddedItems) or not GW.settings.chat.socialLink or not guid or numAddedItems == 0 then
        return
    end
    local text = GetGroupText(guid)
    if GW.IsSecretValue(text) or not text then
        return
    end
    local now = GetTime()
    if IsRecent(text, now) then
        return
    end
    lastShown[text] = now

    PlaySound(SOUNDKIT.UI_71_SOCIAL_QUEUEING_TOAST)
    GW.Notice(GW.CreateChatLink("socialqueue", guid, text))
end

-- a click opens quick join on that group
local function ShowGroup(guid)
    if not QuickJoinFrame:IsShown() then
        ToggleQuickJoinPanel()
    end
    if guid ~= "" then
        QuickJoinFrame:SelectGroup(guid)
        QuickJoinFrame:ScrollToGroup(guid)
    end
end

GW.RegisterChatModule({
    setting = "socialLink",
    onLoad = function()
        -- the chat line takes the place of the toast
        if GW.settings.chat.socialLink and QuickJoinToastButton then
            QuickJoinToastButton.Toast:GwKill()
            QuickJoinToastButton.Toast2:GwKill()
        end
        local watcher = CreateFrame("Frame")
        watcher:RegisterEvent("SOCIAL_QUEUE_UPDATE")
        watcher:SetScript("OnEvent", OnQueueUpdate)
    end,
    links = {socialqueue = ShowGroup},
})
