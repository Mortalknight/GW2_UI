local _, GW = ...
local createCat = GW.CreateCat

local GetActiveProfile = GW.GetActiveProfile
local SetProfileSettings = GW.SetProfileSettings
local SetSetting = GW.SetSetting
local ResetToDefault = GW.ResetToDefault
local GetSettingsProfiles = GW.GetSettingsProfiles

local GW_PROFILE_ICONS_PRESET = {}
GW_PROFILE_ICONS_PRESET[0] = 538514  -- Interface/icons/spell_druid_displacement
GW_PROFILE_ICONS_PRESET[1] = 1041232 -- Interface/icons/ability_socererking_arcanemines
GW_PROFILE_ICONS_PRESET[2] = 236304  -- Interface/icons/ability_warrior_bloodbath
GW_PROFILE_ICONS_PRESET[3] = 1060892 -- Interface/icons/ability_priest_ascendance
GW_PROFILE_ICONS_PRESET[4] = 1033914 -- Interface/icons/spell_mage_overpowered
GW_PROFILE_ICONS_PRESET[5] = 298660  -- Interface/icons/achievement_boss_kingymiron
GW_PROFILE_ICONS_PRESET[6] = 135791  -- Interface/icons/spell_fire_elementaldevastation

-- local forward function defs
local updateProfiles = nil

local function deleteProfile(index)
    GW2UI_SETTINGS_PROFILES[index] = nil
    if GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] ~= nil and GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] == index then
        SetSetting("ACTIVE_PROFILE", nil)
    end
end

local function setProfile(index)
    GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] = index
    C_UI.Reload()
end

local function gwProfileItem_delete_OnEnter(self)
    if self:GetParent().deleteable ~= nil and self:GetParent().deleteable == true then
        self:GetParent().deleteButton:Show()
    end
    if self:GetParent().activateAble ~= nil and self:GetParent().activateAble == true then
        self:GetParent().activateButton:Show()
    end
end

local function gwProfileItem_delete_OnClick(self, button)
    GW.WarningPrompt(
        GwLocalization["PROFILES_DELETE"],
        function()
            deleteProfile(self:GetParent().profileID)
            updateProfiles()
        end
    )
end

local function gwProfileItem_activate_OnEnter(self)
    if self:GetParent().activateAble ~= nil and self:GetParent().activateAble == true then
        self:GetParent().activateButton:Show()
    end
    if self:GetParent().deleteable ~= nil and self:GetParent().deleteable == true then
        self:GetParent().deleteButton:Show()
    end
end

local function gwProfileItem_activate_OnClick(self, button)
    setProfile(self:GetParent().profileID)
    updateProfiles()
    self:Hide()
end

local function gwProfileItem_OnLoad(self)
    self.name:SetFont(UNIT_NAME_FONT, 14)
    self.name:SetTextColor(1, 1, 1)
    self.desc:SetFont(UNIT_NAME_FONT, 12)
    self.desc:SetTextColor(125 / 255, 125 / 255, 125 / 255)
    self.desc:SetText(GwLocalization["PROFILES_MISSING_LOAD"])

    self.deleteButton.string:SetFont(UNIT_NAME_FONT, 12)
    self.deleteButton.string:SetTextColor(255 / 255, 255 / 255, 255 / 255)
    self.deleteButton.string:SetText(DELETE)

    self.activateButton:SetText(ACTIVATE)

    self.deleteButton:SetScript("OnEnter", gwProfileItem_delete_OnEnter)
    self.deleteButton:SetScript("OnClick", gwProfileItem_delete_OnClick)
    self.activateButton:SetScript("OnEnter", gwProfileItem_activate_OnEnter)
    self.activateButton:SetScript("OnClick", gwProfileItem_activate_OnClick)
end

local function gwProfileItem_OnEnter(self)
    if self.deleteable ~= nil and self.deleteable == true then
        self.deleteButton:Show()
    end
    if self.activateAble ~= nil and self.activateAble == true then
        self.activateButton:Show()
    end
    self.background:SetBlendMode("ADD")
end

local function gwProfileItem_OnLeave(self)
    if self.deleteable ~= nil and self.deleteable == true then
        self.deleteButton:Hide()
    end
    self.activateButton:Hide()
    self.background:SetBlendMode("BLEND")
end

updateProfiles = function()
    local currentProfile = GetActiveProfile()

    local h = 0
    local profiles = GetSettingsProfiles()
    for i = 0, 6 do
        local k = i
        local v = profiles[i]
        local f = _G["GwProfileItem" .. k]
        if f == nil then
            f = CreateFrame("Button", "GwProfileItem" .. k, GwSettingsProfilesframe.scrollchild, "GwProfileItemTmpl")
            f:SetScript("OnEnter", gwProfileItem_OnEnter)
            f:SetScript("OnLeave", gwProfileItem_OnLeave)
            gwProfileItem_OnLoad(f)
        end

        if v ~= nil then
            f:Show()
            f.profileID = k
            f.icon:SetTexture(GW_PROFILE_ICONS_PRESET[k])

            f.deleteable = true
            f.background:SetTexCoord(0, 1, 0, 0.5)
            f.activateAble = true
            if currentProfile == k then
                f.background:SetTexCoord(0, 1, 0.5, 1)
                f.activateAble = false
            end

            local description =
                GwLocalization["PROFILES_CREATED"] ..
                v["profileCreatedDate"] ..
                    GwLocalization["PROFILES_CREATED_BY"] ..
                        v["profileCreatedCharacter"] ..
                            GwLocalization["PROFILES_LAST_UPDATE"] .. v["profileLastUpdated"]

            f.name:SetText(v["profilename"])
            f.desc:SetText(description)
            f:SetPoint("TOPLEFT", 15, (-70 * h) + -120)
            h = h + 1
        else
            f:Hide()
        end
    end

    if h < 6 then
        GwCreateNewProfile:Enable()
    else
        GwCreateNewProfile:Disable()
    end

    local scrollM = (120 + (70 * h))
    local scroll = 0
    local thumbheight = 1

    if scrollM > 440 then
        scroll = math.abs(440 - scrollM)
        thumbheight = 100
    end

    GwSettingsProfilesframe.scrollFrame:SetScrollChild(GwSettingsProfilesframe.scrollchild)
    GwSettingsProfilesframe.scrollFrame.maxScroll = scroll

    GwSettingsProfilesframe.slider.thumb:SetHeight(thumbheight)
    GwSettingsProfilesframe.slider:SetMinMaxValues(0, scroll)
end

local function addProfile(name)
    local index = 0
    local profileList = GetSettingsProfiles()

    for i = 0, 7 do
        index = i
        if profileList[i] == nil then
            break
        end
    end

    if index > 6 then
        return
    end

    GW2UI_SETTINGS_PROFILES[index] = {}
    GW2UI_SETTINGS_PROFILES[index]["profilename"] = name
    GW2UI_SETTINGS_PROFILES[index]["profileCreatedDate"] = date("%m/%d/%y %H:%M:%S")
    GW2UI_SETTINGS_PROFILES[index]["profileCreatedCharacter"] = GetUnitName("player", true)
    GW2UI_SETTINGS_PROFILES[index]["profileLastUpdated"] = date("%m/%d/%y %H:%M:%S")

    GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] = index
    SetProfileSettings()
    updateProfiles()
end

local function inputPrompt(text, method)
    GwWarningPrompt.string:SetText(text)
    GwWarningPrompt.method = method
    GwWarningPrompt:Show()
    GwWarningPrompt.input:Show()
    GwWarningPrompt.input:SetText("")
end

local function LoadProfilesPanel(sWindow)
    local pnl_profile = CreateFrame("Frame", "GwSettingsProfilesframe", sWindow.panels, "GwSettingsProfilesPanelTmpl")
    pnl_profile.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pnl_profile.header:SetTextColor(255 / 255, 255 / 255, 255 / 255)
    pnl_profile.header:SetText(GwLocalization["PROFILES_CAT_1"])
    pnl_profile.sub:SetFont(UNIT_NAME_FONT, 12)
    pnl_profile.sub:SetTextColor(125 / 255, 125 / 255, 125 / 255)
    pnl_profile.sub:SetText(GwLocalization["PROFILES_DESC"])

    local fnGSPF_OnShow = function(self)
        GwSettingsWindow.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\profiles\\profiles-bg")
    end
    local fnGSPF_OnHide = function(self)
        GwSettingsWindow.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagbg")
    end
    GwSettingsProfilesframe:SetScript("OnShow", fnGSPF_OnShow)
    GwSettingsProfilesframe:SetScript("OnHide", fnGSPF_OnHide)

    local fnGSPF_slider_OnValueChanged = function(self, value)
        self:GetParent().scrollFrame:SetVerticalScroll(value)
    end
    GwSettingsProfilesframe.slider:SetScript("OnValueChanged", fnGSPF_slider_OnValueChanged)
    GwSettingsProfilesframe.slider:SetMinMaxValues(0, 512)

    local fnGSPF_scroll_OnMouseWheel = function(self, delta)
        delta = -delta * 10
        local s = math.max(0, self:GetVerticalScroll() + delta)
        if self.maxScroll ~= nil then
            s = math.min(self.maxScroll, s)
        end
        self:SetVerticalScroll(s)
        self:GetParent().slider:SetValue(s)
    end
    GwSettingsProfilesframe.scrollFrame:SetScript("OnMouseWheel", fnGSPF_scroll_OnMouseWheel)
    
    createCat(GwLocalization["PROFILES_CAT"], GwLocalization["PROFILES_TOOLTIP"], "GwSettingsProfilesframe", 5)

    GwSettingsProfilesframe.slider:SetValue(0)

    GwSettingsProfilesframe.slider.thumb:SetHeight(200)

    local resetTodefault = CreateFrame("Button", "GwProfileItemDefault", GwSettingsProfilesframe.scrollchild, "GwProfileItemTmpl")
    resetTodefault:SetScript("OnEnter", gwProfileItem_OnEnter)
    resetTodefault:SetScript("OnLeave", gwProfileItem_OnLeave)
    gwProfileItem_OnLoad(resetTodefault)

    resetTodefault.icon:SetTexture("Interface\\icons\\inv_corgi2")

    resetTodefault.deleteable = false
    resetTodefault.background:SetTexCoord(0, 1, 0, 0.5)
    resetTodefault.activateAble = true

    resetTodefault:SetPoint("TOPLEFT", 15, 0)

    resetTodefault.name:SetText(GwLocalization["PROFILES_DEFAULT_SETTINGS"])
    resetTodefault.desc:SetText(GwLocalization["PROFILES_DEFAULT_SETTINGS_DESC"])
    resetTodefault.activateButton:SetScript(
        "OnClick",
        function()
            GW.WarningPrompt(
                GwLocalization["PROFILES_DEFAULT_SETTINGS_PROMPT"],
                function()
                    ResetToDefault()
                end
            )
        end
    )
    resetTodefault.activateButton:SetText(GwLocalization["PROFILES_LOAD_BUTTON"])

    local fmGCNP = CreateFrame("Button", "GwCreateNewProfile", GwSettingsProfilesframe.scrollchild, "GwCreateNewProfileTmpl")
    fmGCNP:SetWidth(fmGCNP:GetTextWidth() + 10)
    fmGCNP:SetText(NEW_COMPACT_UNIT_FRAME_PROFILE)
    local fnGCNP_OnClick = function(self, button)
        inputPrompt(
            NEW_COMPACT_UNIT_FRAME_PROFILE,
            function()
                addProfile(GwWarningPrompt.input:GetText())
                GwWarningPrompt:Hide()
            end
        )
    end
    fmGCNP:SetScript("OnClick", fnGCNP_OnClick)

    GwCreateNewProfile:SetPoint("TOPLEFT", 15, -80)

    updateProfiles()
end
GW.LoadProfilesPanel = LoadProfilesPanel
