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

tooltipsFrame = CreateFrame('frame',nil,UIParent)
local intervalCd = 0
tooltipsFrame:SetScript('OnUpdate',function()
 if GW2UI_SETTINGS['SETTINGS_LOADED'] == false then
        return
    end
    if GW2UI_SETTINGS['DISABLE_TOOLTIPS'] == true then
        return
        tooltipsFrame:SetScript('OnUpdate',nil)
    end
        
    getTooltips()
    tooltipsFrame:SetScript('OnUpdate',nil)
end)
function getTooltips()
    
        for _, toStyle in ipairs(UNSTYLED) do
            if _G[toStyle] then
            
            _G[toStyle]:SetScript('OnShow',function()
                    _G[toStyle]:SetBackdrop({bgFile = "Interface\\AddOns\\GW2_UI\\textures\\UI-Tooltip-Background", 
                                            edgeFile = "Interface\\AddOns\\GW2_UI\\textures\\UI-Tooltip-Border", 
                                            tile = false, tileSize = 16, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }})
                    end)
            end
        end
end