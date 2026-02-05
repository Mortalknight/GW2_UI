local _, GW = ...

--Message caches
local messageToSender = {}
local messageOrder = {}
local MESSAGE_CAP = 200

local bgTexture         = "Interface/AddOns/GW2_UI/textures/chat/chatbubbles/background.png"
local bgInvTexture      = "Interface/AddOns/GW2_UI/textures/chat/chatbubbles/background-inverted.png"
local borderHoriTexture = "Interface/AddOns/GW2_UI/textures/chat/chatbubbles/borderhori.png"
local borderHoriInvTex  = "Interface/AddOns/GW2_UI/textures/chat/chatbubbles/borderhori-inverted.png"
local borderTexture     = "Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border.png"
local borderInvTexture  = "Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border-inverted.png"

local function UpdateBubbleBorder(self)
    local backdrop = self.backdrop
    local messageText = backdrop and backdrop.String
    if not messageText then
        return
    end

    messageText:SetFont(UNIT_NAME_FONT, 11)
    messageText:SetTextColor(0, 0, 0, 1)
    messageText:SetParent(self)

    self.background:SetPoint("TOPLEFT", messageText, "TOPLEFT",-8,8)
    self.background:SetPoint("BOTTOMRIGHT", messageText, "BOTTOMRIGHT",8,-8)
    messageText:SetWidth(math.min(200,messageText:GetWidth()))
    self:SetScale(GW.settings.ChatBubbleScale)

    if self.Name and self.Name:GetText() then
        self.Name:SetText("")
    end

    local text = messageText:GetText()
    if not text then return end

    local senderInfo = messageToSender[text]
    if senderInfo then
        self.Name:SetFormattedText("|c%s%s|r", RAID_CLASS_COLORS.PRIEST.colorStr, senderInfo.senderName)
        if senderInfo.unitType == 1 then
            messageText:SetTextColor(1, 1, 1, 1)
            self.background:SetTexture(bgInvTexture)
            self.bordertop:SetTexture(borderHoriInvTex)
            self.borderbottom:SetTexture(borderHoriInvTex)
            self.borderright:SetTexture(borderInvTexture)
            self.borderleft:SetTexture(borderInvTexture)
            self.bordertopright:SetTexture(borderInvTexture)
            self.bordertopleft:SetTexture(borderInvTexture)
            self.borderbottomleft:SetTexture(borderInvTexture)
            self.borderbottomright:SetTexture(borderInvTexture)
            return
        end
    end

    messageText:SetTextColor(0, 0, 0, 1)
    self.background:SetTexture(bgTexture)
    self.bordertop:SetTexture(borderHoriTexture)
    self.borderbottom:SetTexture(borderHoriTexture)
    self.borderright:SetTexture(borderTexture)
    self.borderleft:SetTexture(borderTexture)
    self.bordertopright:SetTexture(borderTexture)
    self.bordertopleft:SetTexture(borderTexture)
    self.borderbottomleft:SetTexture(borderTexture)
    self.borderbottomright:SetTexture(borderTexture)
end

local function SkinBubble(frame, backdrop)
    frame.background = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.background:SetTexture(bgTexture)
    frame.background:SetPoint("TOPLEFT", frame, "TOPLEFT")
    frame.background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    frame.background:SetTexCoord(0, 0.8515625, 0, 0.58203125)

    frame.bordertop = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.bordertop:SetTexture(borderHoriTexture)
    frame.bordertop:ClearAllPoints()
    frame.bordertop:SetPoint("BOTTOMLEFT", frame.background, "TOPLEFT", 0, 0)
    frame.bordertop:SetPoint("BOTTOMRIGHT", frame.background, "TOPRIGHT", 0, 0)
    frame.bordertop:SetHeight(11 / 2)
    frame.bordertop:SetTexCoord(0, 0.8515625, 0, 0.34375)

    frame.borderbottom = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderbottom:SetTexture(borderHoriTexture)
    frame.borderbottom:SetPoint("TOPLEFT", frame.background, "BOTTOMLEFT", 0, 0)
    frame.borderbottom:SetPoint("TOPRIGHT", frame.background, "BOTTOMRIGHT", 0, 0)
    frame.borderbottom:SetHeight(10 / 2)
    frame.borderbottom:SetTexCoord(0, 0.8515625, 0.6875, 1)

    frame.borderright = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderright:SetTexture(borderTexture)
    frame.borderright:SetPoint("TOPLEFT", frame.background, "TOPRIGHT")
    frame.borderright:SetPoint("BOTTOMLEFT", frame.background, "BOTTOMRIGHT")
    frame.borderright:SetWidth(26 / 2)
    frame.borderright:SetTexCoord(0.1484375, 0.3515625, 0, 0.58203125)

    frame.borderleft = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderleft:SetTexture(borderTexture)
    frame.borderleft:SetPoint("TOPRIGHT", frame.background, "TOPLEFT")
    frame.borderleft:SetPoint("BOTTOMRIGHT", frame.background, "BOTTOMLEFT")
    frame.borderleft:SetWidth(15 / 2)
    frame.borderleft:SetTexCoord(0, 0.1171875, 0, 0.58203125)

    frame.bordertopright = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.bordertopright:SetTexture(borderTexture)
    frame.bordertopright:SetPoint("BOTTOMLEFT", frame.background, "TOPRIGHT", 0, 0)
    frame.bordertopright:SetSize(16 / 2, 11 / 2)
    frame.bordertopright:SetTexCoord(0.484375, 0.609375, 0, 0.021484375)

    frame.bordertopleft = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.bordertopleft:SetTexture(borderTexture)
    frame.bordertopleft:SetPoint("BOTTOMRIGHT", frame.background, "TOPLEFT", 0, 0)
    frame.bordertopleft:SetSize(15 / 2, 11 / 2)
    frame.bordertopleft:SetTexCoord(0.328125, 0.4453125, 0, 0.021484375)

    frame.borderbottomleft = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderbottomleft:SetTexture(borderTexture)
    frame.borderbottomleft:SetPoint("TOPRIGHT", frame.background, "BOTTOMLEFT", 0, 0)
    frame.borderbottomleft:SetSize(15 / 2, 10 / 2)
    frame.borderbottomleft:SetTexCoord(0.671875, 0.7890625, 0, 0.01953125)

    frame.borderbottomright = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderbottomright:SetTexture(borderTexture)
    frame.borderbottomright:SetPoint("TOPLEFT", frame.background, "BOTTOMRIGHT", 0, 0)
    frame.borderbottomright:SetSize(22 / 2, 10 / 2)
    frame.borderbottomright:SetTexCoord(0.828125, 1, 0, 0.01953125)

    if not frame.Name then
        frame.Name = frame:CreateFontString(nil, "OVERLAY")
        frame.Name:SetPoint("BOTTOMLEFT", frame.background, "TOPLEFT", 0, 0)
        frame.Name:SetFont(UNIT_NAME_FONT, 10, "OUTLINE")
        frame.Name:SetTextColor(0, 0, 0, 1)
        frame.Name:SetJustifyH("LEFT")
    end

    if not frame.backdrop then
        frame.backdrop = backdrop
        backdrop:Hide()

        frame:HookScript("OnShow", UpdateBubbleBorder)
        frame:SetFrameStrata("DIALOG")
        frame:SetClampedToScreen(false)

        UpdateBubbleBorder(frame)
    end

    frame.isSkinned = true
end

local function ChatBubble_OnEvent(_, event, msg, sender)
    if event == "PLAYER_ENTERING_WORLD" then
        wipe(messageToSender)
        wipe(messageOrder)
    elseif GW.NotSecretValue(msg) then
        local unit = (event == "CHAT_MSG_MONSTER_SAY" or event == "CHAT_MSG_MONSTER_YELL") and 1 or 0
        local senderName = TRP3_API and TRP3_API.register.getUnitRPNameWithID(sender) or Ambiguate(sender, "none")
        messageToSender[msg] = { unitType = unit, senderName = senderName }
        tinsert(messageOrder, msg)
        -- keep table bounded; always retain newest entry for the next OnUpdate pass
        while #messageOrder > MESSAGE_CAP do
            local oldMsg = table.remove(messageOrder, 1)
            if oldMsg ~= msg then
                messageToSender[oldMsg] = nil
            end
        end
    end
end

local function ChatBubble_OnUpdate(self, elapsed)
    self.lastUpdate = (self.lastUpdate or -2) + elapsed
    if self.lastUpdate < 0.1 then
        return
    end
    self.lastUpdate = 0

    local chatBubbles = C_ChatBubbles.GetAllChatBubbles()
    for _, chatBubble in pairs(chatBubbles) do
        local backdrop = chatBubble:GetChildren()
        if backdrop and not backdrop:IsForbidden() and not chatBubble.isSkinned then
            SkinBubble(chatBubble, backdrop)
        end
    end
end

local function LoadChatBubbles()
    local f = CreateFrame("Frame")

    f:SetScript("OnEvent", ChatBubble_OnEvent)
    f:SetScript("OnUpdate", ChatBubble_OnUpdate)

    f:RegisterEvent("CHAT_MSG_SAY")
    f:RegisterEvent("CHAT_MSG_YELL")
    f:RegisterEvent("CHAT_MSG_MONSTER_SAY")
    f:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
end
GW.LoadChatBubbles = LoadChatBubbles
