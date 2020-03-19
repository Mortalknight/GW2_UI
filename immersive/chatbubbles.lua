local _, GW = ...

--Message caches
local messageToSender = {}

local constBackdropFrame = {
	bgFile = "Interface/AddOns/GW2_UI/textures/ChatBubble-Background",
	edgeFile = "", --"Interface/AddOns/GW2_UI/textures/chatbubbles/corner-bottom-right",
	tile = false,
	tileSize = 64,
	edgeSize = 32,
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local function UpdateFontColor(frame)
    frame.text:SetFont(UNIT_NAME_FONT, 12)
    frame.text:SetTextColor(0, 0, 0, 1)
end

local function AddChatBubbleName(chatBubble, name)
	if not name then return end

	chatBubble.Name:SetFormattedText("|c%s%s|r", RAID_CLASS_COLORS.PRIEST.colorStr, name)
end

local function UpdateBubbleBorder(self)
    UpdateFontColor(self)

	if not self.text then return end

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
			frame.text = region
		end
    end

    local name = frame:CreateFontString(nil, "BORDER")
	name:SetPoint("TOPLEFT", 5, 5)
	name:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -5, -5)
    name:SetFont(UNIT_NAME_FONT, 12 * 0.85, "OUTLINED")
    name:SetTextColor(0, 0, 0, 1)
	name:SetJustifyH("LEFT")
	frame.Name = name

    frame:SetBackdrop(constBackdropFrame)

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

	for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
		if not chatBubble.isSkinnedGW2_UI then
			SkinBubble(chatBubble)
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
