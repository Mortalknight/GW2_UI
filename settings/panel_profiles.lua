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
GW_PROFILE_ICONS_PRESET[3] = 135990 -- Interface/icons/ability_priest_ascendance
GW_PROFILE_ICONS_PRESET[4] = 1033914 -- Interface/icons/spell_mage_overpowered
GW_PROFILE_ICONS_PRESET[5] = 298660 -- Interface/icons/achievement_boss_kingymiron
GW_PROFILE_ICONS_PRESET[6] = 135791 -- Interface/icons/spell_fire_elementaldevastation
GW_PROFILE_ICONS_PRESET[7] = 538514 -- Interface/icons/spell_druid_displacement
GW_PROFILE_ICONS_PRESET[8] = 1041232 -- Interface/icons/ability_socererking_arcanemines
GW_PROFILE_ICONS_PRESET[9] = 236304 -- Interface/icons/ability_warrior_bloodbath
GW_PROFILE_ICONS_PRESET[10] = 135990 -- Interface/icons/ability_priest_ascendance
GW_PROFILE_ICONS_PRESET[11] = 1033914 -- Interface/icons/spell_mage_overpowered
GW_PROFILE_ICONS_PRESET[12] = 298660 -- Interface/icons/achievement_boss_kingymiron
GW_PROFILE_ICONS_PRESET[13] = 135791 -- Interface/icons/spell_fire_elementaldevastation

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
    frame.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/welcome-bg")
    
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
    frame.scrollArea.bg:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatframebackground")

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
    frame.editBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then return end
        local _, max = frame.scrollArea.ScrollBar:GetMinMaxValues()
        for _ = 1, max do
            ScrollFrameTemplate_OnMouseWheel(frame.scrollArea, -1)
        end
        if strlen(self:GetText()) > 0 and string.sub(self:GetText(), -1) == "=" then
            frame.decode:Enable()
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
    frame.import:SetText(L["IMPORT"])
    frame.import:SetScript("OnClick", function()
        local profileName, profilePlayer, version = GW.ImportProfile(frame.editBox:GetText(), settingsWindow)

        frame.result:SetText("")
        if profileName and profilePlayer and version == "Retail" then
            frame.subheader:SetText(profileName .. " - " .. profilePlayer .. " - " .. version)
            frame.result:SetFormattedText("|cff4beb2c%s|r", L["IMPORT_SUCCESSFUL"])
            frame.editBox:SetText("")
        else
            frame.subheader:SetText("")
            frame.result:SetFormattedText("|cffff0000%s|r", L["IMPORT_FAILED"])
        end
    end)

    frame.decode = CreateFrame("Button", nil, frame, "GwStandardButton")
    frame.decode:SetPoint("BOTTOMLEFT")
    frame.decode:SetFrameLevel(frame.decode:GetFrameLevel() + 1)
    frame.decode:EnableMouse(true)
    frame.decode:SetSize(128, 28)
    frame.decode:SetText(L["DECODE"])
    frame.decode:SetScript("OnClick", function()
        local profileName, profilePlayer, version, profileData = GW.DecodeProfile(frame.editBox:GetText())

        frame.result:SetText("")
        if not profileName or not profilePlayer or version ~= "Retail" then
            frame.subheader:SetText("")
            frame.result:SetFormattedText("|cffff0000%s|r", L["IMPORT_DECODE_FALIED"] )
        else
            frame.subheader:SetText(profileName .. " - " .. profilePlayer .. " - " .. version)

            local decodedString = (profileData and GW.TableToLuaString(profileData)) or nil
            local importString = format("%s::%s::%s::%s", decodedString, profileName, profilePlayer, version)
            frame.editBox:SetText(importString)
            frame.result:SetFormattedText("|cff4beb2c%s|r", L["IMPORT_DECODE:SUCCESSFUL"])
            frame.decode:Disable()
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

local function activate_OnClick(self, button)
    local p = self:GetParent()
    setProfile(p.profileID)
    updateProfiles(p:GetParent():GetParent():GetParent())
end
AddForProfiling("panel_profiles", "activate_OnClick", activate_OnClick)

local function export_OnClick(self, button)
    local p = self:GetParent()
    local exportString = GW.GetExportString(p.profileID, GW2UI_SETTINGS_PROFILES[p.profileID]["profilename"])

    ImportExportFrame:Show()
    ImportExportFrame.header:SetText(L["EXPORT_PROFILE"])
    ImportExportFrame.subheader:SetText(GW2UI_SETTINGS_PROFILES[p.profileID]["profilename"])
    ImportExportFrame.description:SetText(L["EXPORT_PROFILE_DESC"])
    ImportExportFrame.import:Hide()
    ImportExportFrame.decode:Hide()
    ImportExportFrame.editBox:SetText(exportString)
    ImportExportFrame.editBox:HighlightText()
    ImportExportFrame.editBox:SetFocus()
end
AddForProfiling("panel_profiles", "export_OnClick", export_OnClick)

local function rename_OnClick(self, button)
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

local function copy_OnClick(self, button)
    local newProfil = copyTable(nil, GW2UI_SETTINGS_PROFILES[self:GetParent().profileID])
    GW.addProfile(self:GetParent():GetParent():GetParent():GetParent(), L["COPY_OF"] .. " " .. GW2UI_SETTINGS_PROFILES[self:GetParent().profileID]["profilename"], newProfil, true)
end

local function item_OnLoad(self)
    self.name:SetFont(UNIT_NAME_FONT, 14)
    self.name:SetTextColor(1, 1, 1)
    self.desc:SetFont(UNIT_NAME_FONT, 10)
    self.desc:SetTextColor(125 / 255, 125 / 255, 125 / 255)
    self.desc:SetText(L["PROFILES_MISSING_LOAD"])

    self.deleteButton.string:SetFont(UNIT_NAME_FONT, 12)
    self.deleteButton.string:SetTextColor(255 / 255, 255 / 255, 255 / 255)
    self.deleteButton.string:SetText(DELETE)

    self.activateButton:SetText(ACTIVATE)
    self.exportButton:SetText(L["EXPORT"])

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
    if self.renameable ~= nil and self.renameable == true then
        self.renameButton:Show()
    end
    if self.activateAble ~= nil and self.activateAble == true then
        self.activateButton:Show()
    end
    if self.exportable ~= nil and self.exportable == true then
        self.exportButton:Show()
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
    if self.renameable ~= nil and self.renameable == true then
        self.renameButton:Hide()
    end
    if self.exportable ~= nil and self.exportable == true then
        self.exportButton:Hide()
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
    for i = 0, 13 do
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
                L["PROFILES_CREATED"] ..
                v["profileCreatedDate"] ..
                    L["PROFILES_CREATED_BY"] ..
                        v["profileCreatedCharacter"] .. L["PROFILES_LAST_UPDATE"] .. v["profileLastUpdated"]

            f.name:SetText(v["profilename"])
            f.name:SetWidth(min(f.name:GetStringWidth(), 250))
            f.desc:SetText(description)
            f:SetPoint("TOPLEFT", 15, (-70 * h) + -120)
            h = h + 1
        else
            f:Hide()
        end
    end

    if h < 14 then
        self.createNew:Enable()
        self.importProfile:Enable()
    else
        self.createNew:Disable()
        self.importProfile:Disable()
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

local function addProfile(self, name, profileData, copy)
    local index = 0
    local profileList = GetSettingsProfiles()

    for i = 0, 13 do
        index = i
        if profileList[i] == nil then
            break
        end
    end

    if index > 13 then
        return
    end

    if copy then
        GW2UI_SETTINGS_PROFILES[index] = profileData
        GW2UI_SETTINGS_PROFILES[index]["profilename"] = name
    elseif profileData then
        GW2UI_SETTINGS_PROFILES[index] = profileData
    else
        GW2UI_SETTINGS_DB_03["ACTIVE_PROFILE"] = index
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

    createCat(L["PROFILES_CAT"], L["PROFILES_TOOLTIP"], p, 5, "Interface/AddOns/GW2_UI/textures/icons/settingsiconbg-2")

    p.slider:SetValue(0)

    p.slider.thumb:SetHeight(200)

    local resetTodefault = CreateFrame("Button", nil, p.scrollchild, "GwProfileItemTmpl")
    resetTodefault:SetScript("OnEnter", item_OnEnter)
    resetTodefault:SetScript("OnLeave", item_OnLeave)
    item_OnLoad(resetTodefault)

    resetTodefault.icon:SetTexture("Interface/icons/inv_corgi2")

    resetTodefault.deleteable = false
    resetTodefault.exportable = false
    resetTodefault.renameable = false
    resetTodefault.copyable = false
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
                    C_UI.Reload()
                end
            )
        end
    )
    resetTodefault.activateButton:SetText(L["PROFILES_LOAD_BUTTON"])

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
    fmIP:SetText(L["IMPORT_POFILE_BUTTON"])
    fmIP:SetWidth(fmIP:GetTextWidth() + 10)
    local fnGCNP_OnClick = function(self, button)
        ImportExportFrame:Show()
        ImportExportFrame.header:SetText(L["IMPORT_PROFILE"])
        ImportExportFrame.subheader:SetText("")
        ImportExportFrame.description:SetText(L["IMPORT_PROFILE_DESC"])
        ImportExportFrame.editBox:SetText("")
        ImportExportFrame.import:Show()
        ImportExportFrame.decode:Show()
        ImportExportFrame.decode:Disable()
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
            local changeDate = date("%m/%d/%y %H:%M:%S")
            local description = L["PROFILES_CREATED"] .. profileToRename["profileCreatedDate"] .. L["PROFILES_CREATED_BY"] ..
                profileToRename["profileCreatedCharacter"] .. L["PROFILES_LAST_UPDATE"] .. changeDate

            profileToRename["profilename"] = self.editBox:GetText()
            profileToRename["profileLastUpdated"] = changeDate
            data.name:SetText(self.editBox:GetText())
            data.name:SetWidth(min(self.editBox:GetStringWidth(), 250))
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
