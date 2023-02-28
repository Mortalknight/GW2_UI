local _, GW = ...
local GetSetting = GW.GetSetting

local function ApplySoulbindsSkin()
	if not GetSetting("SOULBINDS_SKIN_ENABLED") then return end

	SoulbindViewer:GwStripTextures()
	local tex = SoulbindViewer:CreateTexture("bg", "BACKGROUND", nil, -7)
	tex:SetPoint("TOP", SoulbindViewer, "TOP", 0, 25)
	tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
	local w, h = SoulbindViewer:GetSize()
	tex:SetSize(w + 50, h + 50)
	SoulbindViewer.tex = tex

	SoulbindViewer.CloseButton:GwSkinButton(true)
	SoulbindViewer.CloseButton:SetSize(20, 20)
	SoulbindViewer.CommitConduitsButton:GwSkinButton(false, true)
	SoulbindViewer.CommitConduitsButton:SetFrameLevel(10)
	SoulbindViewer.ActivateSoulbindButton:GwSkinButton(false, true)
	SoulbindViewer.ActivateSoulbindButton:SetFrameLevel(10)
end

local function LoadSoulbindsSkin()
	GW.RegisterLoadHook(ApplySoulbindsSkin, "Blizzard_Soulbinds", SoulbindViewer)
end
GW.LoadSoulbindsSkin = LoadSoulbindsSkin

