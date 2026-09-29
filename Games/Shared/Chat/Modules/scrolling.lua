---@class GW2
local GW = select(2, ...)

local returnTimers = {}

-- after scrolling up, back to the newest lines once the set time passed without scrolling
local function ScheduleReturn(chatFrame)
    if returnTimers[chatFrame] then
        returnTimers[chatFrame]:Cancel()
        returnTimers[chatFrame] = nil
    end
    local delay = GW.settings.chat.scrollDownInterval
    if delay > 0 and not chatFrame:AtBottom() then
        returnTimers[chatFrame] = C_Timer.NewTimer(delay, function()
            returnTimers[chatFrame] = nil
            chatFrame:ScrollToBottom()
        end)
    end
end

-- shift jumps to the top or bottom, alt moves one line, otherwise the set number of lines
local function OnMouseWheel(chatFrame, delta)
    if IsShiftKeyDown() then
        if delta > 0 then
            chatFrame:ScrollToTop()
        else
            chatFrame:ScrollToBottom()
        end
    else
        local steps = IsAltKeyDown() and 1 or GW.settings.chat.scrollMessages or 3
        for _ = 1, steps do
            if delta > 0 then
                chatFrame:ScrollUp()
            else
                chatFrame:ScrollDown()
            end
        end
    end
    ScheduleReturn(chatFrame)
end

-- blizzard sets its own wheel script again now and then
local function KeepWheelScript(chatFrame, script, func)
    if script == "OnMouseWheel" and func ~= OnMouseWheel then
        chatFrame:SetScript("OnMouseWheel", OnMouseWheel)
    end
end

GW.RegisterChatModule({
    onFrame = function(chatFrame)
        chatFrame:SetScript("OnMouseWheel", OnMouseWheel)
        hooksecurefunc(chatFrame, "SetScript", KeepWheelScript)
    end,
})
