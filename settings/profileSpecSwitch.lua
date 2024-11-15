local _, GW = ...
local L = GW.L

local eventFrame = CreateFrame("Frame")
local numSpecs = 0
local specNames = {}
local currentSpec = 0
local settingsPanel
local mixin = {}
local databaseEnhanced = false

local _, classId = UnitClassBase("player")
numSpecs = C_SpecializationInfo.GetNumSpecializationsForClassID(classId)
for i = 1, numSpecs do
    local _, name = GetSpecializationInfoForClassID(classId, i)
    specNames[i] = name
end

function mixin:IsDualSpecEnabled()
    return currentSpec > 0 and GW.globalSettings.db.char.enabled
end

function mixin:SetDualSpecEnabled(enabled)
    local db = GW.globalSettings.db.char
    db.enabled = not not enabled

    local currentProfile = self:GetCurrentProfile()
    for i = 1, numSpecs do
        -- nil out entries on disable, set nil entries to the current profile on enable
        db[i] = enabled and (db[i] or currentProfile) or nil
    end

    self:CheckDualSpecState()
end

function mixin:GetDualSpecProfile(spec)
    return GW.globalSettings.db.char[spec or currentSpec] or self:GetCurrentProfile()
end

function mixin:SetDualSpecProfile(profileName, spec)
    spec = spec or currentSpec
    if spec < 1 or spec > numSpecs then return end

    GW.globalSettings.db.char[spec] = profileName
    self:CheckDualSpecState()
end

function mixin:CheckDualSpecState()
    if not GW.globalSettings.db.char.enabled then return end
    if currentSpec == 0 then return end

    local profileName = self:GetDualSpecProfile()
    if profileName ~= self:GetCurrentProfile() then
        self:SetProfile(profileName) --TODO
        GW.RefreshSettingsAfterProfileSwitch()
        GW.RefreshProfileScrollBox(GW2ProfileSettingsView.ScrollBox)
        GW.Debug("Profile Switch detected - Switch from profile " .. self:GetCurrentProfile() .. " to " .. profileName)
    end
end

local function EmbedMixin()
    for k,v in next, mixin do
        rawset(GW.globalSettings, k, v)
    end
end

local function OnProfileDeleted(event, target, profileName)
    local db = GW.globalSettings.db.char
    if not db.enabled then return end

    for i = 1, numSpecs do
        if db[i] == profileName then
            db[i] = target:GetCurrentProfile()
        end
    end
end

local function EnhanceDatabase()
    GW.globalSettings.db = GW.globalSettings:GetNamespace("ProfileSpecSwitch", true) or GW.globalSettings:RegisterNamespace("ProfileSpecSwitch")
    EmbedMixin()
    GW.globalSettings:CheckDualSpecState()
end

local function SetUpDatabaseForProfileSpecSwitch()
    EnhanceDatabase()
    GW.globalSettings.RegisterCallback(eventFrame, "OnDatabaseReset", EnhanceDatabase)
    GW.globalSettings.RegisterCallback(eventFrame, "OnProfileDeleted", OnProfileDeleted)
    databaseEnhanced = true
end
GW.SetUpDatabaseForProfileSpecSwitch = SetUpDatabaseForProfileSpecSwitch

local function ToggleButtons(panel, isActive, deactivate)
    if deactivate then
        panel.profileSpec.enabled:SetEnabled(isActive)
        panel.profileSpec.enabled.checkbutton:SetEnabled(isActive)
    end
    panel.profileSpec.enabled.checkbutton:SetChecked(isActive)
    panel.profileSpec.enabled.title:SetTextColor(isActive and 1 or 0.49, isActive and 1 or 0.49, isActive and 1 or 0.49)
    for _, dd in pairs(panel.profileSpec.dropdown) do
        dd:SetEnabled(isActive)
        dd.title:SetTextColor(isActive and 1 or 0.49, isActive and 1 or 0.49, isActive and 1 or 0.49)
    end
end

local function InititateProfileSpecSwitchSettings(panel)
    settingsPanel = panel
    local desc = L["When enabled, your profile will be set to the specified profile when you change specialization."]

    settingsPanel.profileSpec.dropdown = {}
    settingsPanel.profileSpec.enabled.title:SetFont(UNIT_NAME_FONT, 14)
    settingsPanel.profileSpec.enabled.desc:SetFont(UNIT_NAME_FONT, 8)
    settingsPanel.profileSpec.enabled.title:SetText(L["Enable spec profiles"])
    settingsPanel.profileSpec.enabled.checkbutton:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        GW.globalSettings:SetDualSpecEnabled(isChecked)
        ToggleButtons(panel, isChecked)
    end)

    -- add spec buttons here
    for i = 1, numSpecs do
        local dropDown = CreateFrame("DropdownButton", nil, settingsPanel.profileSpec, "WowStyle1DropdownTemplate")

        dropDown.title = dropDown:CreateFontString(nil, "OVERLAY")
        dropDown.title:SetPoint("BOTTOMLEFT", dropDown, "TOPLEFT", 8, -2)
        dropDown.title:SetFont(UNIT_NAME_FONT, 10)
        dropDown.title:SetText(i == currentSpec and format(L["%s - Active"], specNames[i]) or specNames[i])

        dropDown:GwHandleDropDownBox(nil, nil, nil, 125)
        dropDown:SetSize(125, 25)
        dropDown:SetPoint("BOTTOMLEFT", settingsPanel.profileSpec, "BOTTOMLEFT", (5 + (i - 1) * 120), 3)

        dropDown:SetupMenu(function(drowpdown, rootDescription)
            local profiles = GW.globalSettings:GetProfiles()
            local buttonSize = 20
            local maxButtons = 7
            rootDescription:SetScrollMode(buttonSize * maxButtons)

            for _, profile in pairs(profiles) do
                local function IsSelected(data)
                    return GW.globalSettings:GetDualSpecProfile(data.specId) == data.profileName
                end
                local function SetSelected(data)
                    GW.globalSettings:SetDualSpecProfile(data.profileName, data.specId)
                end

                local radio = rootDescription:CreateRadio(profile, IsSelected, SetSelected, {specId = i, profileName = profile})
                radio:AddInitializer(GW.BlizzardDropdownRadioButtonInitializer)
            end
        end)

        settingsPanel.profileSpec.dropdown[i - 1] = dropDown
    end
    -- set button state
    if currentSpec == 0 then
        local _, reason = C_SpecializationInfo.CanPlayerUseTalentSpecUI()
        if not reason or reason == "" then
            reason = TALENT_MICRO_BUTTON_NO_SPEC
        end
        desc = desc .. "\n" .. RED_FONT_COLOR:WrapTextInColorCode(reason)
        ToggleButtons(settingsPanel, false, true)
    else
        local isEnabled = GW.globalSettings:IsDualSpecEnabled()
        ToggleButtons(settingsPanel, isEnabled)
        settingsPanel.profileSpec.enabled.checkbutton:SetChecked(isEnabled)
    end
    settingsPanel.profileSpec.enabled.desc:SetText(desc)
end
GW.InititateProfileSpecSwitchSettings = InititateProfileSpecSwitchSettings

local function eventHandler(self, event)
    local spec = GetSpecialization() or 0
    -- Newly created characters start at 5 instead of 1 in 9.0.1.
    if spec == 5 or not C_SpecializationInfo.CanPlayerUseTalentSpecUI() then
        spec = 0
    end
    currentSpec = spec

    if event == "PLAYER_LOGIN" then
        self:UnregisterEvent(event)
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
        self:RegisterEvent("PLAYER_LEVEL_CHANGED")
    end

    if settingsPanel then
        for idx, dd in pairs(settingsPanel.profileSpec.dropdown) do
            dd.title:SetText(idx+ 1 == currentSpec and format(L["%s - Active"], specNames[idx + 1]) or specNames[idx + 1])
        end
    end

    if databaseEnhanced then
        GW.globalSettings:CheckDualSpecState()

        --Update settings Inferface here
    end
end

--startup logic
eventFrame:SetScript("OnEvent", eventHandler)
if IsLoggedIn() then
    eventHandler(eventFrame, "PLAYER_LOGIN")
else
    eventFrame:RegisterEvent("PLAYER_LOGIN")
end