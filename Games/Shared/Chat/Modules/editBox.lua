---@class GW2
local GW = select(2, ...)

local MAX_HISTORY = 20
local CHAT_LIMIT = 255

-- how far back each edit box currently is in the history, 0 is the empty line
local historyPositions = {}

local function GetHistory()
    return GW.private.ChatEditHistory
end

-- what was sent, across sessions; secure commands are not kept
local function RememberLine(editBox, line)
    local text = line and strtrim(line)
    if not text or text == "" then
        return
    end
    local command = strmatch(text, "^/%w+")
    if command and IsSecureCmd(command) then
        return
    end

    local history = GetHistory()
    tDeleteItem(history, text)
    tinsert(history, text)
    while #history > MAX_HISTORY do
        tremove(history, 1)
    end
    historyPositions[editBox] = 0
end

-- up and down walk through the history, alt leaves the arrows to the cursor
local function OnKeyDown(editBox, key)
    if (key ~= "UP" and key ~= "DOWN") or IsAltKeyDown() or GW.IsChatRestricted() then
        return
    end
    local history = GetHistory()
    if #history == 0 then
        return
    end
    local position = (historyPositions[editBox] or 0) + (key == "UP" and 1 or -1)
    position = math.max(0, math.min(position, #history))
    historyPositions[editBox] = position
    editBox:SetText(position == 0 and "" or history[#history - position + 1])
end

-- too many of the same key in combat means the keybinds went into the edit box
local function CloseOnRepeatedKeys(editBox, userInput)
    local limit = GW.settings.chat.inCombatTextRepeat
    if not userInput or limit == 0 or not InCombatLockdown() then
        return
    end
    local text = editBox:GetText()
    if #text > limit and strsub(text, -(limit + 1)) == strrep(strsub(text, -1), limit + 1) then
        editBox:SetText("")
        ChatFrameUtil.DeactivateChat(editBox)
    end
end

-- links count with their visible text only, like the server counts them
local function UpdateCharacterCount(editBox)
    local counter = editBox.characterCount
    if counter then
        local text = editBox:GetText()
        local visible = gsub(text, "|c[^|]*|H.-|h(.-)|h|r", "%1")
        counter:SetText(text ~= "" and (CHAT_LIMIT - strlen(visible)) or "")
    end
end

GW.RegisterChatModule({
    onFrame = function(chatFrame)
        local editBox = chatFrame.editBox or _G[chatFrame:GetName() .. "EditBox"]
        if not editBox then
            return
        end
        editBox:HookScript("OnKeyDown", OnKeyDown)
        editBox:HookScript("OnTextChanged", function(self, userInput)
            CloseOnRepeatedKeys(self, userInput)
            UpdateCharacterCount(self)
        end)
        editBox:HookScript("OnEditFocusLost", function(self) historyPositions[self] = 0 end)
        if editBox.AddHistoryLine then
            hooksecurefunc(editBox, "AddHistoryLine", RememberLine)
        end
    end,
})
