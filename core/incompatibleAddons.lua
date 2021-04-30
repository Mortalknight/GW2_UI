local _, GW = ...

local function IsIncompatibleAddonLoadedOrOverride(setting, LoadedAndOverride)
    local IncompatibleAddonLoaded = false
    local whichAddonsIsLoaded = ""
    local isOverride = false
    for settings, table in pairs(GW.GetSetting("IncompatibleAddons")) do
        if settings == setting then
            isOverride = table.Override
            for _, addon in ipairs(table.Addons) do
                if IsAddOnLoaded(addon) then
                    IncompatibleAddonLoaded = true

                    whichAddonsIsLoaded =  select(2, GetAddOnInfo(addon)) .. ", " .. whichAddonsIsLoaded
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
