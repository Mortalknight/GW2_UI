local _, GW = ...

local function ApplyMissingIncompatibleAddonsDefaults()
    for category, defaultData in pairs(GW.globalDefault.profile.IncompatibleAddons) do

        if not GW.settings.IncompatibleAddons[category] then
            GW.settings.IncompatibleAddons[category] = GW.CopyTable(defaultData)
        else
            GW.settings.IncompatibleAddons[category].Addons = GW.CopyTable(defaultData.Addons)
        end
    end
end
GW.ApplyMissingIncompatibleAddonsDefaults = ApplyMissingIncompatibleAddonsDefaults

local function GetIncompatibleAddonInfo(incompatibleAddonCategory)
    local incompatibleAddonLoaded = false
    local isOverride = false
    local loadedAddonNames = {}
    local loadedAddonName = ""

    local addonCategoryTable = GW.settings.IncompatibleAddons[incompatibleAddonCategory]
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
