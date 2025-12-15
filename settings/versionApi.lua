local _, GW = ...
GW.api = {}

local function GetAverageItemLevel()
    if GearScore_GetScore then
        return GearScore_GetScore(UnitName("player"), "player")
    end
    return nil, nil
end
GW.api.GetAverageItemLevel = GetAverageItemLevel

local function GetItemLevelColor(gearScore)
    if GearScore_GetQuality then
	    local r, b, g = GearScore_GetQuality(gearScore)
        return r, g, b
    end
    return 0, 0, 0
end
GW.api.GetItemLevelColor = GetItemLevelColor
