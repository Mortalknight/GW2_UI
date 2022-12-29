local _, GW = ...
local lerp = GW.lerp

--Message caches
local messageToSender = {}

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

    local name = self.Name and self.Name:GetText()
    if name then self.Name:SetText() end

    local text = messageText:GetText()
    if text and messageToSender[text] then
        self.Name:SetFormattedText("|c%s%s|r", RAID_CLASS_COLORS.PRIEST.colorStr, messageToSender[text].message)

        if messageToSender[text].unitType == 1 then
          messageText:SetTextColor(1,1,1, 1)
          self.background:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/background-inverted")
          self.bordertop:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/borderhori-inverted")
          self.borderbottom:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/borderhori-inverted")
          self.borderright:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border-inverted")
          self.borderleft:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border-inverted")
          self.bordertopright:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border-inverted")
          self.bordertopleft:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border-inverted")
          self.borderbottomleft:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border-inverted")
          self.borderbottomright:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border-inverted")
        else
          messageText:SetTextColor(0, 0, 0, 1)
          self.background:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/background")
          self.bordertop:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/borderhori")
          self.borderbottom:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/borderhori")
          self.borderright:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border")
          self.borderleft:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border")
          self.bordertopright:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border")
          self.bordertopleft:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border")
          self.borderbottomleft:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border")
          self.borderbottomright:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border")
        end
    end
end

local function SkinBubble(frame, backdrop)


    frame.background = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.background:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/background")
    frame.background:SetPoint("TOPLEFT", frame, "TOPLEFT")
    frame.background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    frame.background:SetTexCoord(0,0.8515625,0,0.58203125 )

    frame.bordertop = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.bordertop:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/borderhori")
    frame.bordertop:ClearAllPoints()
    frame.bordertop:SetPoint("BOTTOMLEFT", frame.background, "TOPLEFT", 0, 0)
    frame.bordertop:SetPoint("BOTTOMRIGHT", frame.background, "TOPRIGHT", 0, 0)
    frame.bordertop:SetHeight(11/2)
    frame.bordertop:SetTexCoord(0,0.8515625,0,0.34375 )

    frame.borderbottom = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderbottom:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/borderhori")
    frame.borderbottom:SetPoint("TOPLEFT", frame.background, "BOTTOMLEFT", 0,0)
    frame.borderbottom:SetPoint("TOPRIGHT", frame.background, "BOTTOMRIGHT", 0, 0)
    frame.borderbottom:SetHeight(10/2)
    frame.borderbottom:SetTexCoord(0,0.8515625,0.6875,1)

    frame.borderright = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderright:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border")
    frame.borderright:SetPoint("TOPLEFT", frame.background, "TOPRIGHT")
    frame.borderright:SetPoint("BOTTOMLEFT", frame.background, "BOTTOMRIGHT")
    frame.borderright:SetWidth(26/2)
    frame.borderright:SetTexCoord(0.1484375 ,0.3515625 ,0,0.58203125)

    frame.borderleft = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderleft:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border")
    frame.borderleft:SetPoint("TOPRIGHT", frame.background, "TOPLEFT")
    frame.borderleft:SetPoint("BOTTOMRIGHT", frame.background, "BOTTOMLEFT")
    frame.borderleft:SetWidth(15/2)
    frame.borderleft:SetTexCoord(0,0.1171875,0,0.58203125)

    frame.bordertopright = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.bordertopright:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border")
    frame.bordertopright:SetPoint("BOTTOMLEFT", frame.background, "TOPRIGHT", 0, 0)
    frame.bordertopright:SetSize(16/2,11/2)
    frame.bordertopright:SetTexCoord(0.484375 ,0.609375  ,0,0.021484375 )

    frame.bordertopleft = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.bordertopleft:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border")
    frame.bordertopleft:SetPoint("BOTTOMRIGHT", frame.background, "TOPLEFT", 0, 0)
    frame.bordertopleft:SetSize(15/2,11/2)
    frame.bordertopleft:SetTexCoord(0.328125 ,0.4453125 ,0,0.021484375 )

    frame.borderbottomleft = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderbottomleft:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border")
    frame.borderbottomleft:SetPoint("TOPRIGHT", frame.background, "BOTTOMLEFT", 0, 0)
    frame.borderbottomleft:SetSize(15/2,10/2)
    frame.borderbottomleft:SetTexCoord(0.671875,0.7890625,0,0.01953125 )

    frame.borderbottomright = frame:CreateTexture(nil, "ARTWORK", nil, -8)
    frame.borderbottomright:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/border")
    frame.borderbottomright:SetPoint("TOPLEFT", frame.background, "BOTTOMRIGHT", 0, 0)
    frame.borderbottomright:SetSize(22/2,10/2)
    frame.borderbottomright:SetTexCoord(0.828125,1,0,0.01953125)

    --[[

        frame.borderbottom = frame:CreateTexture(nil, "ARTWORK", nil, -8)
        frame.borderbottom:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatbubbles/borderbottom")
        frame.borderbottom:SetPoint("TOPLEFT", frame.background, "BOTTOMLEFT", 0,0)
        frame.borderbottom:SetPoint("TOPRIGHT", frame.background, "BOTTOMRIGHT", 0, 0)
        frame.borderbottom:SetHeight(5)
        frame.borderbottom:SetTexCoord(0,0.9375,0,0.625)

    ]]

    if not frame.Name then
        local name = frame:CreateFontString(nil, "BORDER")

        name:SetPoint("BOTTOMLEFT", frame.background, "TOPLEFT", 0, 0)
        name:SetFont(UNIT_NAME_FONT, 11, "OUTLINED")
        name:SetTextColor(0, 0, 0, 1)
        name:SetJustifyH("LEFT")
        frame.Name = name
    end


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
        local unit = 0
        if event=="CHAT_MSG_MONSTER_SAY" or event=="CHAT_MSG_MONSTER_YELL" then
          unit = 1
        end
        messageToSender[msg] = {unitType = unit, message =Ambiguate(sender, "none")}
    end
end

local function ChatBubble_OnUpdate(self, elapsed)
    self.lastUpdate = (self.lastUpdate or -2) + elapsed
    if self.lastUpdate < 0.1 then
        return
    end
    self.lastUpdate = 0

    for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
        local backdrop = chatBubble:GetChildren()
        if backdrop and not backdrop:IsForbidden() and not chatBubble.isSkinnedGW2_UI then
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
