local _, GW = ...

local GetSetting = GW.GetSetting

local UNSTYLED = {
	"GameTooltip",
	"ShoppingTooltip1",
	"ShoppingTooltip2",
	"ShoppingTooltip3",
	"ItemRefTooltip",
	"ItemRefShoppingTooltip1",
	"ItemRefShoppingTooltip2",
	"ItemRefShoppingTooltip3",
	"WorldMapTooltip",
	"WorldMapCompareTooltip1",
	"WorldMapCompareTooltip2",
	"WorldMapCompareTooltip3",
	"AtlasLootTooltip",
	"QuestHelperTooltip",
	"QuestGuru_QuestWatchTooltip",
	"TRP2_MainTooltip",
	"TRP2_ObjetTooltip",
	"TRP2_StaticPopupPersoTooltip",
	"TRP2_PersoTooltip",
	"TRP2_MountTooltip",
	"AltoTooltip",
	"AltoScanningTooltip",
	"ArkScanTooltipTemplate",
	"NxTooltipItem",
	"NxTooltipD",
	"DBMInfoFrame",
	"DBMRangeCheck",
	"DatatextTooltip",
	"VengeanceTooltip",
	"FishingBuddyTooltip",
	"FishLibTooltip",
	"HealBot_ScanTooltip",
	"hbGameTooltip",
	"PlateBuffsTooltip",
	"LibGroupInSpecTScanTip",
	"RecountTempTooltip",
	"VuhDoScanTooltip",
	"XPerl_BottomTip",
	"EventTraceTooltip",
	"FrameStackTooltip",
	"PetBattlePrimaryUnitTooltip",
	"PetBattlePrimaryAbilityTooltip"
}

local function movePlacement(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMRIGHT", WorldFrame, "BOTTOMRIGHT", 0, 300)
end
GW.AddForProfiling("tooltips", "movePlacement", movePlacement)

local constBackdropArgs = {
	bgFile = "Interface\\AddOns\\GW2_UI\\textures\\UI-Tooltip-Background",
	edgeFile = "Interface\\AddOns\\GW2_UI\\textures\\UI-Tooltip-Border",
	tile = false,
	tileSize = 64,
	edgeSize = 32,
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}
local function styleTooltip(self)
	if not self:IsShown() then
		return
	end
	self:SetBackdrop(constBackdropArgs)
end
GW.AddForProfiling("tooltips", "styleTooltip", styleTooltip)

local function anchorTooltip(self, p)
	self:SetOwner(p, "ANCHOR_CURSOR")
end
GW.AddForProfiling("tooltips", "anchorTooltip", anchorTooltip)

local function LoadTooltips()
	if GetSetting("TOOLTIP_MOUSE") then
		hooksecurefunc("GameTooltip_SetDefaultAnchor", anchorTooltip)
	else
		GameTooltip:HookScript("OnTooltipSetUnit", movePlacement)
		GameTooltip:HookScript("OnTooltipSetQuest", movePlacement)
		GameTooltip:HookScript("OnTooltipSetSpell", movePlacement)
		GameTooltip:HookScript("OnTooltipSetDefaultAnchor", movePlacement)
	end

	hooksecurefunc("GameTooltip_SetBackdropStyle", styleTooltip)
	for _, toStyle in ipairs(UNSTYLED) do
		local f = _G[toStyle]
		if f then
			f:HookScript("OnUpdate", styleTooltip)
		end
	end
end
GW.LoadTooltips = LoadTooltips
