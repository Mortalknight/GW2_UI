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
GW_PROFILE_ICONS_PRESET[0] = 132150 -- Interface/icons/spell_druid_displacement
GW_PROFILE_ICONS_PRESET[1] = 136113 -- Interface/icons/ability_socererking_arcanemines
GW_PROFILE_ICONS_PRESET[2] = 136012 -- Interface/icons/ability_warrior_bloodbath
GW_PROFILE_ICONS_PRESET[3] = 135990 -- Interface/icons/ability_priest_ascendance
GW_PROFILE_ICONS_PRESET[4] = 135275 -- Interface/icons/spell_mage_overpowered
GW_PROFILE_ICONS_PRESET[5] = 135861 -- Interface/icons/achievement_boss_kingymiron
GW_PROFILE_ICONS_PRESET[6] = 135814 -- Interface/icons/spell_fire_elementaldevastation

-- local forward function defs
local updateProfiles = nil
local ImportExportFrame = nil

local function createImportExportFrame(settingsWindow)
    local frame = CreateFrame("Frame", "GW_ImportExportFrame", UIParent)

    frame:SetSize(700, 600)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:Hide()
    frame:SetFrameStrata("DIALOG")

    tinsert(UISpecialFrames, "GW_ImportExportFrame")

    frame.bg = frame:CreateTexture(nil, "ARTWORK")
    frame.bg:SetAllPoints()
    frame.bg:SetTexture("Interface/AddOns/GW2_UI/textures/welcome-bg")

    frame.header = frame:CreateFontString(nil, "OVERLAY")
    frame.header:SetFont(DAMAGE_TEXT_FONT, 30, "OUTLINE")
    frame.header:SetTextColor(1, 0.95, 0.8, 1)
    frame.header:SetPoint("TOP", 0, -20)

    frame.subheader = frame:CreateFontString(nil, "OVERLAY")
    frame.subheader:SetFont(DAMAGE_TEXT_FONT, 16, "OUTLINE")
    frame.subheader:SetTextColor(0.9, 0.85, 0.7, 1)
    frame.subheader:SetPoint("TOP", frame.header, "BOTTOM", 0, 0)

    frame.result = frame:CreateFontString(nil, "OVERLAY")
    frame.result:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
    frame.result:SetTextColor(0.9, 0.85, 0.7, 1)
    frame.result:SetPoint("TOP", frame.subheader, "BOTTOM", 0, -40)

    frame.scrollArea = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -170)
    frame.scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 40)
    frame.scrollArea.ScrollBar:SkinScrollBar()
    frame.scrollArea:SetScript("OnSizeChanged", function(scroll)
        frame.editBox:SetWidth(scroll:GetWidth())
        frame.editBox:SetHeight(scroll:GetHeight())
    end)
    frame.scrollArea:HookScript("OnVerticalScroll", function(scroll, offset)
        frame.editBox:SetHitRectInsets(0, 0, offset, (frame.editBox:GetHeight() - offset - scroll:GetHeight()))
    end)
    frame.scrollArea.bg = frame.scrollArea:CreateTexture(nil, "ARTWORK")
    frame.scrollArea.bg:SetAllPoints()
    frame.scrollArea.bg:SetTexture("Interface/AddOns/GW2_UI/textures/chatframebackground")

    -- added description here
    frame.description = frame:CreateFontString(nil, "OVERLAY")
    frame.description:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
    frame.description:SetTextColor(0.8, 0.75, 0.6, 1)
    frame.description:SetJustifyH("LEFT")
    frame.description:SetJustifyV("MIDDLE")
    frame.description:SetPoint("TOPLEFT", frame.scrollArea, "TOPLEFT", 0, 25)

    frame.editBox = CreateFrame("EditBox", nil, frame)
    frame.editBox:SetMultiLine(true)
    frame.editBox:EnableMouse(true)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:SetFontObject(ChatFontNormal)
    frame.editBox:SetWidth(frame.scrollArea:GetWidth())
    frame.editBox:SetHeight(500)

    frame.editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.scrollArea:SetScrollChild(frame.editBox)
    frame.editBox:SetScript("OnTextChanged", function(_, userInput)
        if userInput then return end
        local _, max = frame.scrollArea.ScrollBar:GetMinMaxValues()
        for _ = 1, max do
            ScrollFrameTemplate_OnMouseWheel(frame.scrollArea, -1)
        end
    end)

    frame.close = CreateFrame("Button", nil, frame, "GwStandardButton")
    frame.close:SetPoint("BOTTOMRIGHT")
    frame.close:SetFrameLevel(frame.close:GetFrameLevel() + 1)
    frame.close:EnableMouse(true)
    frame.close:SetSize(128, 28)
    frame.close:SetText(CLOSE)
    frame.close:SetScript("OnClick", function() frame:Hide() end)

    frame.import = CreateFrame("Button", nil, frame, "GwStandardButton")
    frame.import:SetPoint("BOTTOM")
    frame.import:SetFrameLevel(frame.import:GetFrameLevel() + 1)
    frame.import:EnableMouse(true)
    frame.import:SetSize(128, 28)
    frame.import:SetText(L["Import"])
    frame.import:SetScript("OnClick", function()
        local profileName, profilePlayer, version = GW.ImportProfile(frame.editBox:GetText(), settingsWindow)

        frame.result:SetText("")
        if profileName and profilePlayer and version == "Classic" then
            frame.subheader:SetText(profileName .. " - " .. profilePlayer .. " - " .. version)
            frame.result:SetFormattedText("|cff4beb2c%s|r", L["Import string successfully imported!"])
            frame.editBox:SetText("")
        else
            frame.subheader:SetText("")
            frame.result:SetFormattedText("|cffff0000%s|r", L["Error importing profile: Invalid or corrupt string!"])
        end
    end)

    frame.decode = CreateFrame("Button", nil, frame, "GwStandardButton")
    frame.decode:SetPoint("BOTTOMLEFT")
    frame.decode:SetFrameLevel(frame.decode:GetFrameLevel() + 1)
    frame.decode:EnableMouse(true)
    frame.decode:SetSize(128, 28)
    frame.decode:SetText(L["Decode"])
    frame.decode:SetScript("OnClick", function()
        local profileName, profilePlayer, version, profileData = GW.DecodeProfile(frame.editBox:GetText())

        frame.result:SetText("")
        if not profileName or not profilePlayer or version ~= "Classic" then
            frame.subheader:SetText("")
            frame.result:SetFormattedText("|cffff0000%s|r", L["Error decoding profile: Invalid or corrupt string!"] )
        else
            frame.subheader:SetText(profileName .. " - " .. profilePlayer .. " - " .. version)

            local decodedString = (profileData and GW.TableToLuaString(profileData)) or nil
            local importString = format("%s::%s::%s::%s", decodedString, profileName, profilePlayer, version)
            frame.editBox:SetText(importString)
            frame.result:SetFormattedText("|cff4beb2c%s|r", L["Import string successfully decoded!"])
        end
    end)

    return frame
end

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
    if self:GetParent().exportable ~= nil and self:GetParent().exportable == true then
        self:GetParent().exportButton:Show()
    end
end
AddForProfiling("panel_profiles", "delete_OnEnter", delete_OnEnter)

local function buttons_OnLeave(self)
    if self:GetParent().deleteable ~= nil and self:GetParent().deleteable == true then
        self:GetParent().deleteButton:Hide()
    end
    if self:GetParent().exportable ~= nil and self:GetParent().exportable == true then
        self:GetParent().exportButton:Hide()
    end
    if self:GetParent().activateAble ~= nil and self:GetParent().activateAble == true then
        self:GetParent().activateButton:Hide()
    end
    self:GetParent().background:SetBlendMode("BLEND")
end
AddForProfiling("panel_profiles", "buttons_OnLeave", buttons_OnLeave)

local function delete_OnClick(self, button)
    local p = self:GetParent()
    GW.WarningPrompt(
        L["Are you sure you want to delete this profile?"],
        function()
            deleteProfile(p.profileID)
            updateProfiles(p:GetParent():GetParent():GetParent())
        end
    )
end
AddForProfiling("panel_profiles", "delete_OnClick", delete_OnClick)

local function buttons_OnEnter(self)
    if self:GetParent().activateAble ~= nil and self:GetParent().activateAble == true then
        self:GetParent().activateButton:Show()
    end
    if self:GetParent().deleteable ~= nil and self:GetParent().deleteable == true then
        self:GetParent().deleteButton:Show()
    end
    if self:GetParent().renameable ~= nil and self:GetParent().renameable == true then
        self:GetParent().renameButton:Show()
    end
    if self:GetParent().exportable ~= nil and self:GetParent().exportable == true then
        self:GetParent().exportButton:Show()
    end
    if self:GetParent().copyable ~= nil and self:GetParent().copyable == true then
        self:GetParent().copyButton:Show()
    end
end
AddForProfiling("panel_profiles", "activate_OnEnter", activate_OnEnter)

local function buttons_OnLeave(self)
    if self:GetParent().deleteable ~= nil and self:GetParent().deleteable == true then
        self:GetParent().deleteButton:Hide()
    end
    if self:GetParent().exportable ~= nil and self:GetParent().exportable == true then
        self:GetParent().exportButton:Hide()
    end
    if self:GetParent().renameable ~= nil and self:GetParent().renameable == true then
        self:GetParent().renameButton:Hide()
    end
    if self:GetParent().activateAble ~= nil and self:GetParent().activateAble == true then
        self:GetParent().activateButton:Hide()
    end
    if self:GetParent().copyable ~= nil and self:GetParent().copyable == true then
        self:GetParent().copyButton:Hide()
    end
    self:GetParent().background:SetBlendMode("BLEND")
end
AddForProfiling("panel_profiles", "buttons_OnLeave", buttons_OnLeave)

local function activate_OnClick(self)
    local p = self:GetParent()
    setProfile(p.profileID)
    updateProfiles(p:GetParent():GetParent():GetParent())
end
AddForProfiling("panel_profiles", "activate_OnClick", activate_OnClick)

local function export_OnClick(self)
    local p = self:GetParent()
    local exportString = GW.GetExportString(p.profileID, GW2UI_SETTINGS_PROFILES[p.profileID]["profilename"])

    ImportExportFrame:Show()
    ImportExportFrame.header:SetText(L["Export Profile"])
    ImportExportFrame.subheader:SetText(GW2UI_SETTINGS_PROFILES[p.profileID]["profilename"])
    ImportExportFrame.description:SetText(L["Profile string to share your settings:"])
    ImportExportFrame.import:Hide()
    ImportExportFrame.decode:Hide()
    ImportExportFrame.editBox:SetText(exportString)
    ImportExportFrame.editBox:HighlightText()
    ImportExportFrame.editBox:SetFocus()
end
AddForProfiling("panel_profiles", "export_OnClick", export_OnClick)

local function rename_OnClick(self)
    StaticPopup_Show("GW_CHANGE_PROFILE_NAME", nil, nil, self:GetParent())
end

local function copyTable(newTable, tableToCopy)
    if type(newTable) ~= "table" then newTable = {} end

    if type(tableToCopy) == "table" then
        for option, value in pairs(tableToCopy) do
            if type(value) == "table" then
                value = copyTable(newTable[option], value)
            end

            newTable[option] = value
        end
    end

    return newTable
end
GW.copyTable = copyTable

local function copy_OnClick(self)
    local newProfil = copyTable(nil, GW2UI_SETTINGS_PROFILES[self:GetParent().profileID])
    GW.addProfile(self:GetParent():GetParent():GetParent():GetParent(), L["Copy of"] .. " " .. GW2UI_SETTINGS_PROFILES[self:GetParent().profileID]["profilename"], newProfil, true)
end

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
    self.exportButton:SetText(L["Export"])

    self.deleteButton:SetScript("OnEnter", buttons_OnEnter)
    self.deleteButton:SetScript("OnLeave", buttons_OnLeave)
    self.deleteButton:SetScript("OnClick", delete_OnClick)
    self.activateButton:SetScript("OnEnter", buttons_OnEnter)
    self.activateButton:SetScript("OnLeave", buttons_OnLeave)
    self.activateButton:SetScript("OnClick", activate_OnClick)
    self.exportButton:SetScript("OnEnter", buttons_OnEnter)
    self.exportButton:SetScript("OnLeave", buttons_OnLeave)
    self.exportButton:SetScript("OnClick", export_OnClick)
    self.renameButton:SetScript("OnEnter", buttons_OnEnter)
    self.renameButton:SetScript("OnLeave", buttons_OnLeave)
    self.renameButton:SetScript("OnClick", rename_OnClick)
    self.copyButton:SetScript("OnEnter", buttons_OnEnter)
    self.copyButton:SetScript("OnLeave", buttons_OnLeave)
    self.copyButton:SetScript("OnClick", copy_OnClick)
end
AddForProfiling("panel_profiles", "item_OnLoad", item_OnLoad)

local function item_OnEnter(self)
    if self.deleteable ~= nil and self.deleteable == true then
        self.deleteButton:Show()
    end
    if self.activateAble ~= nil and self.activateAble == true then
        self.activateButton:Show()
    end
    if self.exportable ~= nil and self.exportable == true then
        self.exportButton:Show()
    end
    if self.renameable ~= nil and self.renameable == true then
        self.renameButton:Show()
    end
    if self.copyable ~= nil and self.copyable == true then
        self.copyButton:Show()
    end
    self.background:SetBlendMode("ADD")
end
AddForProfiling("panel_profiles", "item_OnEnter", item_OnEnter)

local function item_OnLeave(self)
    if self.deleteable ~= nil and self.deleteable == true then
        self.deleteButton:Hide()
    end
    if self.exportable ~= nil and self.exportable == true then
        self.exportButton:Hide()
    end
    if self.renameable ~= nil and self.renameable == true then
        self.renameButton:Hide()
    end
    if self.copyable ~= nil and self.copyable == true then
        self.copyButton:Hide()
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
            f.exportable = true
            f.renameable = true
            f.copyable = true
            f.background:SetTexCoord(0, 1, 0, 0.5)
            f.activateAble = true
            if currentProfile == k then
                f.background:SetTexCoord(0, 1, 0.5, 1)
                f.activateAble = false
            end

            local description =
                L["Created: "] ..
                v["profileCreatedDate"] ..
                    L["\nCreated by: "] ..
                        v["profileCreatedCharacter"] .. L["\nLast updated: "] .. v["profileLastUpdated"]

            f.name:SetText(v["profilename"])
            f.name:SetWidth(min(f.name:GetStringWidth(), 250))
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

local function addProfile(self, name, profileData)
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

    GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] = index

    if profileData then
        GW2UI_SETTINGS_PROFILES[index] = profileData
    else
        GW2UI_SETTINGS_PROFILES[index] = {}
        GW2UI_SETTINGS_PROFILES[index]["profilename"] = name
        GW2UI_SETTINGS_PROFILES[index]["profileCreatedDate"] = date("%m/%d/%y %H:%M:%S")
        GW2UI_SETTINGS_PROFILES[index]["profileCreatedCharacter"] = GetUnitName("player", true)
        GW2UI_SETTINGS_PROFILES[index]["profileLastUpdated"] = date("%m/%d/%y %H:%M:%S")
        SetProfileSettings()
    end

    updateProfiles(self)
end
GW.addProfile = addProfile
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
    p.header:SetText(L["Profiles"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(125 / 255, 125 / 255, 125 / 255)
    p.sub:SetText(L["Profiles are an easy way to share your settings across characters and realms."])

    local fnGSPF_OnShow = function()
        sWindow.background:SetTexture("Interface/AddOns/GW2_UI/textures/profiles/profiles-bg")
    end
    local fnGSPF_OnHide = function()
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

    createCat(L["Profiles"], L["Add and remove profiles."], p, 5, "Interface/AddOns/GW2_UI/textures/settingsiconbg-2")

    p.slider:SetValue(0)

    p.slider.thumb:SetHeight(200)

    local resetTodefault = CreateFrame("Button", nil, p.scrollchild, "GwProfileItemTmpl")
    resetTodefault:SetScript("OnEnter", item_OnEnter)
    resetTodefault:SetScript("OnLeave", item_OnLeave)
    item_OnLoad(resetTodefault)

    resetTodefault.icon:SetTexture(135879)

    resetTodefault.deleteable = false
    resetTodefault.exportable = false
    resetTodefault.renameable = false
    resetTodefault.copyable = false
    resetTodefault.background:SetTexCoord(0, 1, 0, 0.5)
    resetTodefault.activateAble = true

    resetTodefault:SetPoint("TOPLEFT", 15, 0)

    resetTodefault.name:SetText(L["Default Settings"])
    resetTodefault.desc:SetText(L["Load the default addon settings to the current profile."])
    resetTodefault.activateButton:SetScript(
        "OnClick",
        function()
            GW.WarningPrompt(
                L["Are you sure you want to load the default settings?\n\nAll previous settings will be lost."],
                function()
                    ResetToDefault()
                    C_UI.Reload()
                end
            )
        end
    )
    resetTodefault.activateButton:SetText(L["Load"])

    local fmGCNP = CreateFrame("Button", nil, p.scrollchild, "GwCreateNewProfileTmpl")
    fmGCNP:SetText(NEW_COMPACT_UNIT_FRAME_PROFILE)
    fmGCNP:SetWidth(fmGCNP:GetTextWidth() + 10)
    local fnGCNP_OnClick = function(self, button)
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

    local fmIP = CreateFrame("Button", nil, p.scrollchild, "GwCreateNewProfileTmpl")
    fmIP:SetText(L["Import Profile"]) 
    fmIP:SetWidth(fmIP:GetTextWidth() + 10)
    local fnGCNP_OnClick = function(self, button)
        ImportExportFrame:Show()
        ImportExportFrame.header:SetText(L["Import Profile"])
        ImportExportFrame.subheader:SetText("")
        ImportExportFrame.description:SetText(L["Paste your profile string here to import the profile."])
        ImportExportFrame.editBox:SetText("")
        ImportExportFrame.import:Show()
        ImportExportFrame.decode:Show()
        ImportExportFrame.result:SetText("")  
        ImportExportFrame.editBox:SetFocus()
    end
    fmIP:SetScript("OnClick", fnGCNP_OnClick)
    fmIP:SetPoint("TOPLEFT", fmGCNP, "TOPLEFT", fmGCNP:GetTextWidth() + 25, 0)

    p.createNew = fmGCNP
    p.importProfile = fmIP

    updateProfiles(p)

    ImportExportFrame = createImportExportFrame(p)

    StaticPopupDialogs["GW_CHANGE_PROFILE_NAME"] = {
        text = GARRISON_SHIP_RENAME_LABEL,
        button1 = SAVE,
        button2 = CANCEL,
        selectCallbackByIndex = true,
        OnButton1 = function(self, data)
            local profileToRename = GW2UI_SETTINGS_PROFILES[data.profileID]
            local text = self.editBox:GetText()
            local changeDate = date("%m/%d/%y %H:%M:%S")
            local description = L["Created: "] .. profileToRename["profileCreatedDate"] .. L["\nCreated by: "] ..
                profileToRename["profileCreatedCharacter"] .. L["\nLast updated: "] .. changeDate

            -- Use hidden frame font object to calculate string width
            GW.HiddenFrame.HiddenString:SetFont(UNIT_NAME_FONT, 14)
            GW.HiddenFrame.HiddenString:SetText(text)
            profileToRename["profilename"] = text
            profileToRename["profileLastUpdated"] = changeDate
            data.name:SetText(text)
            data.name:SetWidth(min(GW.HiddenFrame.HiddenString:GetStringWidth() + 5, 250))
            data.desc:SetText(description)

            return
        end,
        OnButton2 = function() end,
        timeout = 0,
        whileDead = 1,
        hasEditBox = 1,
        maxLetters = 64,
        editBoxWidth = 250,
        closeButton = 0,
    }
end
GW.LoadProfilesPanel = LoadProfilesPanel
