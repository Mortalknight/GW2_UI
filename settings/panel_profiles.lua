local _, GW = ...
local L = GW.L
local createCat = GW.CreateCat
local GetActiveProfile = GW.GetActiveProfile
local SetProfileSettings = GW.SetProfileSettings
local SetSetting = GW.SetSetting
local ResetToDefault = GW.ResetToDefault
local GetSettingsProfiles = GW.GetSettingsProfiles
local AddForProfiling = GW.AddForProfiling

local GW_PROFILE_ICONS_PRESET = {}
GW_PROFILE_ICONS_PRESET[0] = 538514 -- Interface/icons/spell_druid_displacement
GW_PROFILE_ICONS_PRESET[1] = 1041232 -- Interface/icons/ability_socererking_arcanemines
GW_PROFILE_ICONS_PRESET[2] = 236304 -- Interface/icons/ability_warrior_bloodbath
GW_PROFILE_ICONS_PRESET[3] = 1060892 -- Interface/icons/ability_priest_ascendance
GW_PROFILE_ICONS_PRESET[4] = 1033914 -- Interface/icons/spell_mage_overpowered
GW_PROFILE_ICONS_PRESET[5] = 298660 -- Interface/icons/achievement_boss_kingymiron
GW_PROFILE_ICONS_PRESET[6] = 135791 -- Interface/icons/spell_fire_elementaldevastation

-- local forward function defs
local updateProfiles = nil

local function deleteProfile(index)
    GW2UI_SETTINGS_PROFILES[index] = nil
    if GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] ~= nil and GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] == index then
        SetSetting("ACTIVE_PROFILE", nil)
    end
end
AddForProfiling("panel_profiles", "deleteProfile", deleteProfile)

local function setProfile(index)
    GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] = index
    C_UI.Reload()
end
AddForProfiling("panel_profiles", "setProfile", setProfile)

local function delete_OnEnter(self)
    if self:GetParent().deleteable ~= nil and self:GetParent().deleteable == true then
        self:GetParent().deleteButton:Show()
    end
    if self:GetParent().activateAble ~= nil and self:GetParent().activateAble == true then
        self:GetParent().activateButton:Show()
    end
end
AddForProfiling("panel_profiles", "delete_OnEnter", delete_OnEnter)

local function delete_OnClick(self, button)
    local p = self:GetParent()
    GW.WarningPrompt(
        L["PROFILES_DELETE"],
        function()
            deleteProfile(p.profileID)
            updateProfiles(p:GetParent():GetParent():GetParent())
        end
    )
end
AddForProfiling("panel_profiles", "delete_OnClick", delete_OnClick)

local function activate_OnEnter(self)
    if self:GetParent().activateAble ~= nil and self:GetParent().activateAble == true then
        self:GetParent().activateButton:Show()
    end
    if self:GetParent().deleteable ~= nil and self:GetParent().deleteable == true then
        self:GetParent().deleteButton:Show()
    end
end
AddForProfiling("panel_profiles", "activate_OnEnter", activate_OnEnter)

local function activate_OnClick(self, button)
    local p = self:GetParent()
    setProfile(p.profileID)
    updateProfiles(p:GetParent():GetParent():GetParent())
end
AddForProfiling("panel_profiles", "activate_OnClick", activate_OnClick)

local function item_OnLoad(self)
    self.name:SetFont(UNIT_NAME_FONT, 14)
    self.name:SetTextColor(1, 1, 1)
    self.desc:SetFont(UNIT_NAME_FONT, 12)
    self.desc:SetTextColor(125 / 255, 125 / 255, 125 / 255)
    self.desc:SetText(L["PROFILES_MISSING_LOAD"])

    self.deleteButton.string:SetFont(UNIT_NAME_FONT, 12)
    self.deleteButton.string:SetTextColor(255 / 255, 255 / 255, 255 / 255)
    self.deleteButton.string:SetText(DELETE)

    self.activateButton:SetText(ACTIVATE)

    self.deleteButton:SetScript("OnEnter", delete_OnEnter)
    self.deleteButton:SetScript("OnClick", delete_OnClick)
    self.activateButton:SetScript("OnEnter", activate_OnEnter)
    self.activateButton:SetScript("OnClick", activate_OnClick)
end
AddForProfiling("panel_profiles", "item_OnLoad", item_OnLoad)

local function item_OnEnter(self)
    if self.deleteable ~= nil and self.deleteable == true then
        self.deleteButton:Show()
    end
    if self.activateAble ~= nil and self.activateAble == true then
        self.activateButton:Show()
    end
    self.background:SetBlendMode("ADD")
end
AddForProfiling("panel_profiles", "item_OnEnter", item_OnEnter)

local function item_OnLeave(self)
    if self.deleteable ~= nil and self.deleteable == true then
        self.deleteButton:Hide()
    end
    self.activateButton:Hide()
    self.background:SetBlendMode("BLEND")
end
AddForProfiling("panel_profiles", "item_OnLeave", item_OnLeave)

updateProfiles = function(self)
    local currentProfile = GetActiveProfile()

    if not self.profile_buttons then
        self.profile_buttons = {}
    end

    local h = 0
    local profiles = GetSettingsProfiles()
    for i = 0, 6 do
        local k = i
        local v = profiles[i]
        local f = self.profile_buttons[k + 1]
        if f == nil then
            f = CreateFrame("Button", nil, self.scrollchild, "GwProfileItemTmpl")
            f:SetScript("OnEnter", item_OnEnter)
            f:SetScript("OnLeave", item_OnLeave)
            item_OnLoad(f)
            self.profile_buttons[k + 1] = f
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
                L["PROFILES_CREATED"] ..
                v["profileCreatedDate"] ..
                    L["PROFILES_CREATED_BY"] ..
                        v["profileCreatedCharacter"] .. L["PROFILES_LAST_UPDATE"] .. v["profileLastUpdated"]

            f.name:SetText(v["profilename"])
            f.desc:SetText(description)
            f:SetPoint("TOPLEFT", 15, (-70 * h) + -120)
            h = h + 1
        else
            f:Hide()
        end
    end

    if h < 7 then
        self.createNew:Enable()
    else
        self.createNew:Disable()
    end

    local scrollM = (120 + (70 * h))
    local scroll = 0
    local thumbheight = 1

    if scrollM > 440 then
        scroll = math.abs(440 - scrollM)
        thumbheight = 100
    end

    self.scrollFrame:SetScrollChild(self.scrollchild)
    self.scrollFrame.maxScroll = scroll

    self.slider.thumb:SetHeight(thumbheight)
    self.slider:SetMinMaxValues(0, scroll)
end
AddForProfiling("panel_profiles", "updateProfiles", updateProfiles)

local function addProfile(self, name)
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
    updateProfiles(self)
end
AddForProfiling("panel_profiles", "addProfile", addProfile)

local function inputPrompt(text, method)
    GwWarningPrompt.string:SetText(text)
    GwWarningPrompt.method = method
    GwWarningPrompt:Show()
    GwWarningPrompt.input:Show()
    GwWarningPrompt.input:SetText("")
end
AddForProfiling("panel_profiles", "inputPrompt", inputPrompt)

local function LoadProfilesPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsProfilesPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 255 / 255, 255 / 255)
    p.header:SetText(L["PROFILES_CAT_1"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(125 / 255, 125 / 255, 125 / 255)
    p.sub:SetText(L["PROFILES_DESC"])

    local fnGSPF_OnShow = function(self)
        sWindow.background:SetTexture("Interface/AddOns/GW2_UI/textures/profiles/profiles-bg")
    end
    local fnGSPF_OnHide = function(self)
        sWindow.background:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagbg")
    end
    p:SetScript("OnShow", fnGSPF_OnShow)
    p:SetScript("OnHide", fnGSPF_OnHide)

    local fnGSPF_slider_OnValueChanged = function(self, value)
        self:GetParent().scrollFrame:SetVerticalScroll(value)
    end
    p.slider:SetScript("OnValueChanged", fnGSPF_slider_OnValueChanged)
    p.slider:SetMinMaxValues(0, 512)

    local fnGSPF_scroll_OnMouseWheel = function(self, delta)
        delta = -delta * 10
        local s = math.max(0, self:GetVerticalScroll() + delta)
        if self.maxScroll ~= nil then
            s = math.min(self.maxScroll, s)
        end
        self:SetVerticalScroll(s)
        self:GetParent().slider:SetValue(s)
    end
    p.scrollFrame:SetScript("OnMouseWheel", fnGSPF_scroll_OnMouseWheel)

    createCat(L["PROFILES_CAT"], L["PROFILES_TOOLTIP"], p, 5, "Interface/AddOns/GW2_UI/textures/settingsiconbg-2")

    p.slider:SetValue(0)

    p.slider.thumb:SetHeight(200)

    local resetTodefault = CreateFrame("Button", nil, p.scrollchild, "GwProfileItemTmpl")
    resetTodefault:SetScript("OnEnter", item_OnEnter)
    resetTodefault:SetScript("OnLeave", item_OnLeave)
    item_OnLoad(resetTodefault)

    resetTodefault.icon:SetTexture("Interface/icons/inv_corgi2")

    resetTodefault.deleteable = false
    resetTodefault.background:SetTexCoord(0, 1, 0, 0.5)
    resetTodefault.activateAble = true

    resetTodefault:SetPoint("TOPLEFT", 15, 0)

    resetTodefault.name:SetText(L["PROFILES_DEFAULT_SETTINGS"])
    resetTodefault.desc:SetText(L["PROFILES_DEFAULT_SETTINGS_DESC"])
    resetTodefault.activateButton:SetScript(
        "OnClick",
        function()
            GW.WarningPrompt(
                L["PROFILES_DEFAULT_SETTINGS_PROMPT"],
                function()
                    ResetToDefault()
                end
            )
        end
    )
    resetTodefault.activateButton:SetText(L["PROFILES_LOAD_BUTTON"])

    local fmGCNP = CreateFrame("Button", nil, p.scrollchild, "GwCreateNewProfileTmpl")
    fmGCNP:SetWidth(fmGCNP:GetTextWidth() + 10)
    fmGCNP:SetText(NEW_COMPACT_UNIT_FRAME_PROFILE)
    local fnGCNP_OnClick = function(self, button)
        local up = self
        inputPrompt(
            NEW_COMPACT_UNIT_FRAME_PROFILE,
            function()
                addProfile(p, GwWarningPrompt.input:GetText())
                GwWarningPrompt:Hide()
            end
        )
    end
    fmGCNP:SetScript("OnClick", fnGCNP_OnClick)
    fmGCNP:SetPoint("TOPLEFT", 15, -80)

    p.createNew = fmGCNP

    updateProfiles(p)
end
GW.LoadProfilesPanel = LoadProfilesPanel
