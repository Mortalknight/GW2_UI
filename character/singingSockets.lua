local _, GW = ...

local singingFrames = {}
local gemCache = {}
local iconSize = 36
local gemsInfo = {
	[1] = { 228638, 228634, 228642, 228648 },
	[2] = { 228647, 228639, 228644, 228636 },
	[3] = { 228640, 228646, 228643, 228635 },
}

local function GetGemLink(gemID)
	local info = gemCache[gemID]
	if not info then
		info = select(2, C_Item.GetItemInfo(gemID))
		gemCache[gemID] = info
	end
	return info
end

local function SocketOnEnter(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 3)
	GameTooltip:SetHyperlink(GetGemLink(self.gemID))
	GameTooltip:Show()
end

local function SocketOnClick(self)
	local BAG_ID, SLOT_ID
	for bagID = 0, 4 do
		for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
			local itemID = C_Container.GetContainerItemID(bagID, slotID)
			if itemID == self.gemID then
				BAG_ID = bagID
				SLOT_ID = slotID
			end
		end
	end
	if BAG_ID and SLOT_ID then
		C_Container.PickupContainerItem(BAG_ID, SLOT_ID)
		ClickSocketButton(self.socketID)
		ClearCursor()
	end
end

local function CreateItemButton(frame, size, texture)
	local button = CreateFrame("Button", nil, frame, "BackdropTemplate")
	local epicColor = BAG_ITEM_QUALITY_COLORS[Enum.ItemQuality.Epic]
	button:SetSize(size, size)
	button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
	button.backdrop:SetAllPoints()
	button.backdrop:SetBackdropBorderColor(epicColor.r, epicColor.g, epicColor.b)
	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:GwSetInside(button.backdrop)
	button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	if texture then
		local atlas = strmatch(texture, "Atlas:(.+)$")
		if atlas then
			button.Icon:SetAtlas(atlas)
		else
			button.Icon:SetTexture(texture)
		end
	end

	return button
end

local function CreateSingingSockets()
	for i = 1, 3 do
		local frame = CreateFrame("Frame", "GW2UISingingSocket" .. i, ItemSocketingFrame)
		frame:SetSize(iconSize * 2, iconSize * 2)
		frame:SetPoint("TOP", _G["ItemSocketingSocket" .. i], "BOTTOM", 0, -40)
		frame:GwCreateBackdrop(nil)
		singingFrames[i] = frame
		local index = 0
		for _, gemID in next, gemsInfo[i] do
			local button = CreateItemButton(frame, iconSize, C_Item.GetItemIconByID(gemID))
			button:SetPoint("TOPLEFT", mod(index, 2) * iconSize, -(index > 1 and iconSize or 0))
			index = index + 1
			button.socketID = i
			button.gemID = gemID
			button:SetScript("OnEnter", SocketOnEnter)
			button:SetScript("OnClick", SocketOnClick)
			button:SetScript("OnLeave", GameTooltip_Hide)
		end
	end
end

local function SetupSingingSockets()
	hooksecurefunc("ItemSocketingFrame_LoadUI", function()
		if not ItemSocketingFrame or not GW.settings.singingSockets then
			for i = 1, 3 do
				if singingFrames[i] then
					singingFrames[i]:Hide()
				end
			end
		else
			if #singingFrames == 0 then CreateSingingSockets() end
			local isSingingSocket = GetSocketTypes(1) == "SingingThunder"

			for i = 1, 3 do
				singingFrames[i]:SetShown(isSingingSocket and not GetExistingSocketInfo(i))
			end
		end
	end)
end
GW.SetupSingingSockets = SetupSingingSockets
