---@class GW2
local GW = select(2, ...)

local ARROW = "|TInterface/AddOns/GW2_UI/textures/uistuff/arrow_right.png:14|t"

-- the link carries no line, the click finds the one under the cursor
local function CopyLineUnderCursor(_, _, _, chatFrame)
    if not (chatFrame and chatFrame.FindCharacterAndLineIndexAtCoordinate) then
        return
    end
    local x, y = GetCursorPosition()
    local scale = chatFrame:GetEffectiveScale()
    local _, index = chatFrame:FindCharacterAndLineIndexAtCoordinate(x / scale, y / scale)
    local line = index and chatFrame.visibleLines and chatFrame.visibleLines[index]
    local message = line and line.messageInfo and line.messageInfo.message
    if GW.NotSecretValue(message) and message then
        local text = GW.GetPlainChatLine(message)
        if text ~= "" then
            GW.PutIntoChatEditBox(text, true)
        end
    end
end

GW.RegisterChatModule({
    setting = "copyChatLines",
    onLine = function(_, text)
        if not strmatch(text, "^%s*$") then
            return GW.CreateChatLink("copyline", "", ARROW) .. " " .. text
        end
    end,
    links = {copyline = CopyLineUnderCursor},
})
