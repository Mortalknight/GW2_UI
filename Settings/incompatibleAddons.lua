---@class GW2
local GW = select(2, ...)

local function ApplyMissingIncompatibleAddonsDefaults()
    for category, defaultData in pairs(GW.globalDefault.profile.incompatibleAddons) do

        if not GW.settings.incompatibleAddons[category] then
            GW.settings.incompatibleAddons[category] = GW.CopyTable(defaultData)
        else
            GW.settings.incompatibleAddons[category].Addons = GW.CopyTable(defaultData.Addons)
        end
    end
end
GW.ApplyMissingIncompatibleAddonsDefaults = ApplyMissingIncompatibleAddonsDefaults

local function GetIncompatibleAddonInfo(incompatibleAddonCategory)
    local incompatibleAddonLoaded = false
    local isOverride = false
    local loadedAddonNames = {}
    local loadedAddonName = ""

    local addonCategoryTable = GW.settings.incompatibleAddons[incompatibleAddonCategory]
    if addonCategoryTable then
        isOverride = addonCategoryTable.Override
        for _, addon in ipairs(addonCategoryTable.Addons) do
            if C_AddOns.IsAddOnLoaded(addon) then
                incompatibleAddonLoaded = true
                local addonName = select(2, C_AddOns.GetAddOnInfo(addon))
                table.insert(loadedAddonNames, addonName)
            end
        end
    end

    if #loadedAddonNames > 0 then
        loadedAddonName = table.concat(loadedAddonNames, LIST_DELIMITER)
    end

    return incompatibleAddonLoaded, loadedAddonName, isOverride
end
GW.GetIncompatibleAddonInfo = GetIncompatibleAddonInfo

local function ShouldBlockIncompatibleAddon(incompatibleAddonCategory)
    local isLoaded, _, isOverride = GetIncompatibleAddonInfo(incompatibleAddonCategory)
    return isLoaded and not isOverride
end
GW.ShouldBlockIncompatibleAddon = ShouldBlockIncompatibleAddon
