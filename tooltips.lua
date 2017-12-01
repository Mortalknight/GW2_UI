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

function move_tooltip_placemtn(self) 
    self:ClearAllPoints()
    self:SetPoint("BOTTOMRIGHT", WorldFrame, "BOTTOMRIGHT", 0, 300)
end

local constBackdropArgs = {
    bgFile = "Interface\\AddOns\\GW2_UI\\textures\\UI-Tooltip-Background",
    edgeFile = "Interface\\AddOns\\GW2_UI\\textures\\UI-Tooltip-Border",
    tile = false, tileSize = 64, edgeSize = 32,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}
function gw_style_tooltip(self)
    if  not self:IsShown() then return end
    self:SetBackdrop(constBackdropArgs)
end

function gw_set_tooltips()
        
    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
       move_tooltip_placemtn(self) 
    end)

    GameTooltip:HookScript("OnTooltipSetQuest", function(self)
       move_tooltip_placemtn(self) 
    end)
   GameTooltip:HookScript("OnTooltipSetSpell", function(self)
       move_tooltip_placemtn(self) 
    end)
    GameTooltip:HookScript("OnTooltipSetDefaultAnchor", function(self)
       move_tooltip_placemtn(self) 
    end)
    for _, toStyle in ipairs(UNSTYLED) do
        if _G[toStyle] then
            _G[toStyle]:HookScript('OnUpdate', gw_style_tooltip)
        end
    end
end