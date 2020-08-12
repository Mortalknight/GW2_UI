local _, GW = ...

--Message caches
local messageToSender = {}

local function UpdateFontColor(frame)
    frame.text:SetFont(UNIT_NAME_FONT, 12)
    frame.text:SetTextColor(0, 0, 0, 1)
end

local function AddChatBubbleName(chatBubble, name)
    if not name then return end

    chatBubble.Name:SetFormattedText("|c%s%s|r", RAID_CLASS_COLORS.PRIEST.colorStr, name)
end

local function UpdateBubbleBorder(self)
    if not self.text then return end

    UpdateFontColor(self)

    local name = self.Name and self.Name:GetText()
    if name then self.Name:SetText() end

    local text = self.text:GetText()
    if text  then
        AddChatBubbleName(self, messageToSender[text])
    end
end

local function SkinBubble(frame)
    if frame:IsForbidden() then return end


    for i = 1, frame:GetNumRegions() do
        local region = select(i, frame:GetRegions())
        if region:IsObjectType("Texture") then
            region:SetTexture()
        elseif region:IsObjectType("FontString") then
            print(1)
            frame.text = region
        end
    end

    local name = frame:CreateFontString(nil, "BORDER")
    name:SetPoint("TOPLEFT", 5, 10)
    name:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -5, 5)
    name:SetFont(UNIT_NAME_FONT, 12 * 0.85, "OUTLINED")
    name:SetTextColor(0, 0, 0, 1)
    name:SetJustifyH("LEFT")
    frame.Name = name

    frame.background = frame:CreateTexture(nil, "ARTWORK")
    frame.background:SetTexture("Interface/AddOns/GW2_UI/textures/ChatBubble-Background")
    frame.background:SetPoint("TOPLEFT", frame, "TOPLEFT")
    frame.background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    frame.background:SetDrawLayer("ARTWORK", -8)

    frame.bordertop = frame:CreateTexture(nil, "ARTWORK")
    frame.bordertop:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/border-top")
    frame.bordertop:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -10, 0)
    frame.bordertop:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -25, 0)
    frame.bordertop:SetDrawLayer("ARTWORK", -8)

    frame.borderbottom = frame:CreateTexture(nil, "ARTWORK")
    frame.borderbottom:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/border-bottom")
    frame.borderbottom:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", -10)
    frame.borderbottom:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    frame.borderbottom:SetDrawLayer("ARTWORK", -8)

    frame.borderright = frame:CreateTexture(nil, "ARTWORK")
    frame.borderright:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/border-right")
    frame.borderright:SetPoint("TOPLEFT", frame, "TOPRIGHT")
    frame.borderright:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT")
    frame.borderright:SetDrawLayer("ARTWORK", -8)

    frame.borderleft = frame:CreateTexture(nil, "ARTWORK")
    frame.borderleft:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/border-left")
    frame.borderleft:SetPoint("TOPRIGHT", frame, "TOPLEFT")
    frame.borderleft:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT")
    frame.borderleft:SetDrawLayer("ARTWORK", -8)

    frame.bordertopright = frame:CreateTexture(nil, "ARTWORK")
    frame.bordertopright:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/corner-top-right")
    frame.bordertopright:SetPoint("BOTTOMLEFT", frame, "TOPRIGHT", -25, 0)
    frame.bordertopright:SetDrawLayer("ARTWORK", -8)

    frame.borderbottomright = frame:CreateTexture(nil, "ARTWORK")
    frame.borderbottomright:SetTexture("Interface/AddOns/GW2_UI/textures/chatbubbles/corner-bottom-right")
    frame.borderbottomright:SetPoint("TOPLEFT", frame, "BOTTOMRIGHT")
    frame.borderbottomright:SetDrawLayer("ARTWORK", -8)

    frame:HookScript("OnShow", UpdateBubbleBorder)
    frame:SetFrameStrata("DIALOG") --Doesn't work currently in Legion due to a bug on Blizzards end
    UpdateBubbleBorder(frame)

    frame.isSkinnedGW2_UI = true
end

local function ChatBubble_OnEvent(self, event, msg, sender, _, _, _, _, _, _, _, _, _, guid)
    messageToSender[msg] = Ambiguate(sender, "none")
end

local function ChatBubble_OnUpdate(self, elapsed)
    if not self then return end
    if not self.lastupdate then
        self.lastupdate = -2 -- wait 2 seconds before hooking frames
    end

    self.lastupdate = self.lastupdate + elapsed
    if self.lastupdate < 0.1 then return end
    self.lastupdate = 0

    --for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
    --    local bubble = chatBubble:GetChildren(1)
    --    if not chatBubble.isSkinnedGW2_UI then
    --        SkinBubble(chatBubble)
    --    end
    --end

    for _, frame in pairs(C_ChatBubbles.GetAllChatBubbles()) do
        local bub = frame:GetChildren(1)
		if bub and not bub:IsForbidden() and not bub.isSkinnedGW2_UI then
			SkinBubble(frame)
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
end
GW.LoadChatBubbles = LoadChatBubbles
