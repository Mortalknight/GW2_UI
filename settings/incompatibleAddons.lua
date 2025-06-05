local _, GW = ...

local function CheckIfNewIncompatibleAddonsAreAddedOrOldOnesRemoved(savedOnes)
    local defaultIncompatibleAddons = GW.globalDefault.profile.IncompatibleAddons
    local shouldAddSetting = false
    local needUpdateSavedOnes = false

    for defaultSetting, defaultTable in pairs(defaultIncompatibleAddons) do
        for savedSetting, savedTable in pairs(savedOnes) do
            if defaultSetting == savedSetting then
                savedTable.Addons = GW.copyTable(nil, defaultTable.Addons)

                shouldAddSetting = false
                needUpdateSavedOnes = true
            end
        end
        if not shouldAddSetting and not savedOnes[defaultSetting] then
            savedOnes[defaultSetting] = GW.copyTable(nil, defaultTable)
            needUpdateSavedOnes = true
        end
    end
    if needUpdateSavedOnes then
        GW.settings.IncompatibleAddons = savedOnes
    end

    return savedOnes
end

local function IsIncompatibleAddonLoadedOrOverride(setting, LoadedAndOverride)
    local IncompatibleAddonLoaded = false
    local whichAddonsIsLoaded = ""
    local isOverride = false
    local savedIncompatibleAddons = GW.settings.IncompatibleAddons
    savedIncompatibleAddons = CheckIfNewIncompatibleAddonsAreAddedOrOldOnesRemoved(savedIncompatibleAddons)
    for settings, table in pairs(savedIncompatibleAddons) do
        if settings == setting then
            isOverride = table.Override
            for _, addon in ipairs(table.Addons) do
                if C_AddOns.IsAddOnLoaded(addon) then
                    IncompatibleAddonLoaded = true
                    whichAddonsIsLoaded =  select(2, C_AddOns.GetAddOnInfo(addon)) .. ", " .. whichAddonsIsLoaded
                end
            end
        end
    end

    if strlen(whichAddonsIsLoaded) > 0 then whichAddonsIsLoaded = strsub(whichAddonsIsLoaded, 0 , strlen(whichAddonsIsLoaded) - 2) end
    if LoadedAndOverride then
        return IncompatibleAddonLoaded and isOverride and false or IncompatibleAddonLoaded and not isOverride and true
    else
        return IncompatibleAddonLoaded, whichAddonsIsLoaded, isOverride
    end
end
GW.IsIncompatibleAddonLoadedOrOverride = IsIncompatibleAddonLoadedOrOverride
