local _, GW = ...

--Message caches
local messageToSender = {}

local function UpdateBubbleBorder(self)
    local backdrop = self.backdrop
    local text = backdrop and backdrop.String

    if not text then
        return 
    end

    text:SetFont(UNIT_NAME_FONT, 12)
    text:SetTextColor(0, 0, 0, 1)
    text:SetParent(self)

    local name = self.Name and self.Name:GetText()
    if name then self.Name:SetText() end

    local text = text:GetText()
    if text and messageToSender[text]then
        self.Name:SetFormattedText("|c%s%s|r", RAID_CLASS_COLORS.PRIEST.colorStr, messageToSender[text])
    end
end

local function SkinBubble(frame, backdrop)
    if not frame.namen then
        local name = frame:CreateFontString(nil, "BORDER")
        name:SetPoint("TOPLEFT", 5, 10)
        name:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -5, 5)
        name:SetFont(UNIT_NAME_FONT, 12 * 0.85, "OUTLINED")
        name:SetTextColor(0, 0, 0, 1)
        name:SetJustifyH("LEFT")
        frame.Name = name
    end

    frame.background = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.background:SetTexture("Interface/AddOns/GW2_UI/textures/ChatBubble-Background")
    frame.background:SetPoint("TOPLEFT", frame, "TOPLEFT")
    frame.background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    frame.background:SetAlpha(0.8)

    frame.bordertop = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.bordertop:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/border-top")
    frame.bordertop:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -10, 0)
    frame.bordertop:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -25, 0)
    frame.bordertop:SetAlpha(0.8)

    frame.borderbottom = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderbottom:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/border-bottom")
    frame.borderbottom:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", -10)
    frame.borderbottom:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    frame.borderbottom:SetAlpha(0.8)

    frame.borderright = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderright:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/border-right")
    frame.borderright:SetPoint("TOPLEFT", frame, "TOPRIGHT")
    frame.borderright:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT")
    frame.borderright:SetAlpha(0.8)

    frame.borderleft = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderleft:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/border-left")
    frame.borderleft:SetPoint("TOPRIGHT", frame, "TOPLEFT")
    frame.borderleft:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT")
    frame.borderleft:SetAlpha(0.8)

    frame.bordertopright = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.bordertopright:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/corner-top-right")
    frame.bordertopright:SetPoint("BOTTOMLEFT", frame, "TOPRIGHT", -25, 0)
    frame.bordertopright:SetAlpha(0.8)

    frame.borderbottomright = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderbottomright:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/corner-bottom-right")
    frame.borderbottomright:SetPoint("TOPLEFT", frame, "BOTTOMRIGHT")
    frame.borderbottomright:SetAlpha(0.8)

    if not frame.backdrop then
        frame.backdrop = backdrop
        backdrop:Hide()

        frame:HookScript("OnShow", UpdateBubbleBorder)
        frame:SetFrameStrata("DIALOG")
        frame:SetClampedToScreen(false)

        UpdateBubbleBorder(frame)
    end

    frame.isSkinnedGW2_UI = true
end

local function ChatBubble_OnEvent(_, event, msg, sender)
    if event == "PLAYER_ENTERING_WORLD" then --Clear caches
        wipe(messageToSender)
    else
        messageToSender[msg] = Ambiguate(sender, "none")
    end
end

local function ChatBubble_OnUpdate(self, elapsed)
    self.lastUpdate = (self.lastUpdate or -2) + elapsed
    if self.lastUpdate < 0.1 then
        return
    end
    self.lastUpdate = 0

    for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
        local backdrop = chatBubble:GetChildren(1)
        if backdrop and not backdrop:IsForbidden() and not chatBubble.isSkinnedGW2_UI then
            SkinBubble(chatBubble, backdrop)
        end
    end
end

local function ToggleChatBubbleScript(self)
    local _, instanceType = GetInstanceInfo()
    if instanceType == "none" then
        self.BubbleFrame:SetScript("OnEvent", ChatBubble_OnEvent)
        self.BubbleFrame:SetScript("OnUpdate", ChatBubble_OnUpdate)
    else
        self.BubbleFrame:SetScript("OnEvent", nil)
        self.BubbleFrame:SetScript("OnUpdate", nil)

        --Clear caches
        wipe(messageToSender)
    end
end

local function LoadChatBubbles()
    local f = CreateFrame("Frame")

    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", ToggleChatBubbleScript)

    f.BubbleFrame = CreateFrame("Frame")
    f.BubbleFrame:RegisterEvent("CHAT_MSG_SAY")
    f.BubbleFrame:RegisterEvent("CHAT_MSG_YELL")
    f.BubbleFrame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
    f.BubbleFrame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    f.BubbleFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end
GW.LoadChatBubbles = LoadChatBubbles
