local _, GW = ...

local IncompatibleAddons = {
    Actionbars = {
        "Bartender4",
        "Dominos",
    },
    ImmersiveQuesting = {
        "Storyline",
        "Immersive",
        "Immersion",
        "Tofu",
        "Queso",
    },
    DynamicCam = {
        "DynamicCam",
        "Queso",
    },
    Inventory = {
        "AdiBags",
        "ArkInventory",
        "Bagnon",
        "Sorted",
    },
    Minimap = {
        "SexyMap",
    },
    FloatingCombatText = {
        "ClassicFCT",
        "xCT+",
        "NameplateSCT",
    },
    Objectives = {
        "!KalielsTracker",
    },
    Raidframes = {
        "Grid2",
        "VuhDo",
    },
    Groupframes = {
        "Grid2",
    },
    RaidAndGroupFrames = {
        "Grid2",
        "VuhDo",
    }
}

local function CheckForIncompatibleAddonModule(addon, module) -- works only for ace3 addons
    local loaded = false
    if addon == "Bartender4" then
        loaded = LibStub("AceAddon-3.0", true):GetAddon(addon, true):GetModule(module).db.profile.enabled
    end
    return loaded, loaded and module or nil
end

local function CheckForIncompatibleAddons(setting, checkAce3Module, ace3AddonName, ace3AddonModule)
    local isIncompatibleAddonLoaded = false
    local whichAddonsIsLoaded = ""
    for settings, addons in pairs(IncompatibleAddons) do
        if settings == setting then
            for _, addon in ipairs(addons) do
                if IsAddOnLoaded(addon) then
                    isIncompatibleAddonLoaded = true
                    local moduleLoadedText
                    if checkAce3Module then
                        isIncompatibleAddonLoaded, moduleLoadedText = CheckForIncompatibleAddonModule(ace3AddonName, ace3AddonModule)
                    end
                    whichAddonsIsLoaded =  select(2, GetAddOnInfo(addon)) .. (checkAce3Module and moduleLoadedText and " (" .. ace3AddonModule .. ")" or "") .. ", " .. whichAddonsIsLoaded
                end
            end
        end
    end

    if strlen(whichAddonsIsLoaded) > 0 then whichAddonsIsLoaded = strsub(whichAddonsIsLoaded, 0 , strlen(whichAddonsIsLoaded) - 2) end
    return isIncompatibleAddonLoaded, whichAddonsIsLoaded
end
GW.CheckForIncompatibleAddons = CheckForIncompatibleAddons
