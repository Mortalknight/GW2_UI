local _, GW = ...

local GetSetting = GW.GetSetting
local RegisterMovableFrame = GW.RegisterMovableFrame

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
	"LibDBIconTooltip"
}

local function movePlacement(self)
	local settings = GetSetting("GameTooltipPos")
	self:ClearAllPoints()
	self:SetPoint(settings.point, UIParent, settings.relativePoint, settings.xOfs, settings.yOfs)
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
	if _G[self:GetName() .. "StatusBarTexture"] then
		_G[self:GetName() .. "StatusBarTexture"]:SetTexture("Interface\\Addons\\GW2_UI\\Textures\\castinbar-white")
	end
end
GW.AddForProfiling("tooltips", "styleTooltip", styleTooltip)

local function tooltip_SetBackdropStyle(self, args)
	--if args and args == GAME_TOOLTIP_BACKDROP_STYLE_EMBEDDED then
		--return
	--end
	if not self:IsShown() then
		return
	end
	self:SetBackdrop(constBackdropArgs)
end
GW.AddForProfiling("tooltips", "tooltip_SetBackdropStyle", tooltip_SetBackdropStyle)

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
		GameTooltip:HookScript("OnTooltipSetItem", movePlacement)
		GameTooltip:HookScript("OnTooltipSetDefaultAnchor", movePlacement)
		RegisterMovableFrame("GwTooltip", GameTooltip, 'GameTooltipPos', 'VerticalActionBarDummy')
		hooksecurefunc(GwTooltipMoveAble, "StopMovingOrSizing", function (frame)
			local anchor = "BOTTOMRIGHT"
			local x = frame:GetRight() - GetScreenWidth()
			local y = frame:GetBottom()

			frame:ClearAllPoints()
			frame:SetPoint(anchor, x, y)

			if not InCombatLockdown() then
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint(frame:GetPoint())
			end
		end)
	end

	hooksecurefunc("GameTooltip_SetBackdropStyle", tooltip_SetBackdropStyle)
	for _, toStyle in ipairs(UNSTYLED) do
		local f = _G[toStyle]
		if f then
			f:HookScript("OnUpdate", styleTooltip)
		end
	end
end
GW.LoadTooltips = LoadTooltips