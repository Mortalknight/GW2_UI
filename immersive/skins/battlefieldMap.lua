local _, GW = ...


local function SetBackdropAlpha()
	if BattlefieldMapFrame and BattlefieldMapFrame.backdrop then
		local opacity = 1 - (BattlefieldMapOptions and BattlefieldMapOptions.opacity or 1)
		BattlefieldMapFrame.backdrop:SetBackdropColor(0, 0, 0, opacity)
	end
end

local function GetCloseButton(frame)
	if not frame then
		frame = BattlefieldMapFrame
	end

	local border = frame and frame.BorderFrame
	return border and border.CloseButton
end

local function OnLeave()
	local close = GetCloseButton()
	if close then
		close:SetAlpha(0.1)
	end
end

local function OnEnter()
	local close = GetCloseButton()
	if close then
		close:SetAlpha(1)
	end
end

local function ApplyBattlefieldMapFrameSkin()
	if not GW.settings.BattlefieldMapSkinEnabled then return end

	BattlefieldMapFrame:GwStripTextures()
	BattlefieldMapFrame:GwCreateBackdrop()
	BattlefieldMapFrame:SetFrameStrata("LOW")
	BattlefieldMapFrame:HookScript("OnShow", SetBackdropAlpha)
	hooksecurefunc(BattlefieldMapFrame, "SetGlobalAlpha", SetBackdropAlpha)

	if BattlefieldMapFrame.ScrollContainer then
		if BattlefieldMapFrame.backdrop then
			BattlefieldMapFrame.backdrop:GwSetOutside(BattlefieldMapFrame.ScrollContainer)
		end

		BattlefieldMapFrame.ScrollContainer:HookScript("OnLeave", OnLeave)
		BattlefieldMapFrame.ScrollContainer:HookScript("OnEnter", OnEnter)
	end

	if BattlefieldMapTab then
		BattlefieldMapTab:SetHeight(24)
		GW.HandleTabs(BattlefieldMapTab, true)
		BattlefieldMapFrame:SetPoint("TOPLEFT", BattlefieldMapTab, "BOTTOMLEFT", 0, 0)

		if BattlefieldMapTab.Text then
			BattlefieldMapTab.Text:GwSetInside(BattlefieldMapTab)
		end
	end

	local close = GetCloseButton()
	if close then
		close:GwSkinButton(true)

		close:SetAlpha(0.25)
		close:SetIgnoreParentAlpha(1)
		close:SetFrameLevel(close:GetFrameLevel() + 1)
		close:ClearAllPoints()
		close:SetPoint("TOPRIGHT", 3, 5)
		close:HookScript("OnLeave", OnLeave)
		close:HookScript("OnEnter", OnEnter)
	end
end

local function LoadBattlefieldMapSkin()
	GW.RegisterLoadHook(ApplyBattlefieldMapFrameSkin, "Blizzard_BattlefieldMap", BattlefieldMapFrame)
end
GW.LoadBattlefieldMapSkin = LoadBattlefieldMapSkin