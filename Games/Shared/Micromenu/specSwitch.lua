---@class GW2
local GW = select(2, ...)
local L = GW.L

-- right click on the talent micro button: specialization, loot specialization and loadout
local button = PlayerSpellsMicroButton
if not (button and C_ClassTalents and C_SpecializationInfo.SetSpecialization) then return end

local STARTER_ID = Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID
local ICON = "|T%s:14:14:0:0:64:64:4:60:4:60|t %s"

local function IsStarterActive()
    return C_ClassTalents.GetHasStarterBuild() and C_ClassTalents.GetStarterBuildActive()
end

local function GetActiveLoadout(specID)
    return IsStarterActive() and STARTER_ID or C_ClassTalents.GetLastSelectedSavedConfigID(specID)
end

local function LoadLoadout(specID, configID)
    if configID == STARTER_ID then
        C_ClassTalents.SetStarterBuildActive(true)
        return
    end
    if IsStarterActive() then
        C_ClassTalents.SetStarterBuildActive(false)
    end
    if C_ClassTalents.LoadConfig(configID, true) ~= Enum.LoadConfigResult.Error then
        C_ClassTalents.UpdateLastSelectedSavedConfigID(specID, configID)
    end
end

local function GenerateMenu(_, root)
    local currentSpec = C_SpecializationInfo.GetSpecialization()
    local specID, specName = C_SpecializationInfo.GetSpecializationInfo(currentSpec)
    local numSpecs = C_SpecializationInfo.GetNumSpecializationsForClassID(GW.myClassID)

    root:CreateTitle(SPECIALIZATION)
    for index = 1, numSpecs do
        local _, name, _, icon = C_SpecializationInfo.GetSpecializationInfo(index)
        root:CreateRadio(ICON:format(icon, name), function() return index == currentSpec end, function() C_SpecializationInfo.SetSpecialization(index) end)
    end

    root:CreateTitle(SELECT_LOOT_SPECIALIZATION)
    root:CreateRadio(LOOT_SPECIALIZATION_DEFAULT:format(specName), function() return GetLootSpecialization() == 0 end, function() SetLootSpecialization(0) end)
    for index = 1, numSpecs do
        local id, name, _, icon = C_SpecializationInfo.GetSpecializationInfo(index)
        root:CreateRadio(ICON:format(icon, name), function() return GetLootSpecialization() == id end, function() SetLootSpecialization(id) end)
    end

    local loadouts = C_ClassTalents.GetConfigIDsBySpecID(specID) or {}
    if C_ClassTalents.GetHasStarterBuild() then
        tinsert(loadouts, STARTER_ID)
    end
    if #loadouts > 0 then
        local active = GetActiveLoadout(specID)
        root:CreateTitle(L["Loadouts"])
        for _, configID in ipairs(loadouts) do
            local info = configID ~= STARTER_ID and C_Traits.GetConfigInfo(configID)
            local name = configID == STARTER_ID and BLUE_FONT_COLOR:WrapTextInColorCode(TALENT_FRAME_DROP_DOWN_STARTER_BUILD) or (info and info.name or UNKNOWN)
            root:CreateRadio(name, function() return configID == active end, function() LoadLoadout(specID, configID) end)
        end
    end
end

button:HookScript("OnMouseUp", function(self, mouseButton)
    if mouseButton == "RightButton" and not InCombatLockdown() and C_SpecializationInfo.GetSpecialization() then
        MenuUtil.CreateContextMenu(self, GenerateMenu)
    end
end)

button:HookScript("OnEnter", function()
    if GameTooltip:IsOwned(button) then
        GameTooltip:AddLine(L["Right click: switch specialization or loadout"], 1, 1, 1)
        GameTooltip:Show()
    end
end)
