local _, GW = ...
local L = GW.L
local ResetToDefault = GW.ResetToDefault
local AddForProfiling = GW.AddForProfiling

local ICONS = {}
local ImportExportFrame
local ProfileWin
local IconSelectionFrame

------------------------------------------------------------
-- Data / ScrollBox
------------------------------------------------------------
local function UpdateScrollBox(scrollBox)
    if not scrollBox then return end

    local dataProvider = CreateDataProvider()
    local profiles = GW.globalSettings:GetProfiles() or {}
    local currentProfile = GW.globalSettings:GetCurrentProfile()

    sort(profiles, function(a, b) return a < b end)

    for index, profile in ipairs(profiles) do
        dataProvider:Insert({ index = index, data = profile, currentProfile = currentProfile })
    end

    scrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end
GW.RefreshProfileScrollBox = UpdateScrollBox

------------------------------------------------------------
-- Import / Export UI
------------------------------------------------------------
local function createImportExportFrame()
    local frame = CreateFrame("Frame", "GW_ImportExportFrame", UIParent)
    frame:SetSize(700, 600)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:Hide()
    tinsert(UISpecialFrames, frame:GetName())

    frame.bg = frame:CreateTexture(nil, "ARTWORK")
    frame.bg:SetAllPoints()
    frame.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/welcome-bg.png")

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
    frame.scrollArea:SetPoint("TOPLEFT", 15, -170)
    frame.scrollArea:SetPoint("BOTTOMRIGHT", -30, 40)
    frame.scrollArea.ScrollBar:GwSkinScrollBar()
    frame.scrollArea.bg = frame.scrollArea:CreateTexture(nil, "ARTWORK")
    frame.scrollArea.bg:SetAllPoints()
    frame.scrollArea.bg:SetTexture("Interface/AddOns/GW2_UI/textures/chat/chatframebackground.png")

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

    frame.scrollArea:SetScrollChild(frame.editBox)
    frame.scrollArea:SetScript("OnSizeChanged", function(scroll)
        frame.editBox:SetSize(scroll:GetWidth(), scroll:GetHeight())
    end)
    frame.scrollArea:HookScript("OnVerticalScroll", function(scroll, offset)
        frame.editBox:SetHitRectInsets(0, 0, offset, (frame.editBox:GetHeight() - offset - scroll:GetHeight()))
    end)
    frame.editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.editBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then return end
        local _, max = frame.scrollArea.ScrollBar:GetMinMaxValues()
        for _ = 1, max do ScrollFrameTemplate_OnMouseWheel(frame.scrollArea, -1) end
    end)

    frame.close = CreateFrame("Button", nil, frame, "GwStandardButton")
    frame.close:SetPoint("BOTTOMRIGHT")
    frame.close:SetSize(128, 28)
    frame.close:SetText(CLOSE)
    frame.close:SetScript("OnClick", function() frame:Hide() end)

    frame.import = CreateFrame("Button", nil, frame, "GwStandardButton")
    frame.import:SetPoint("BOTTOM")
    frame.import:SetSize(128, 28)
    frame.import:SetText(L["Import"])
    frame.import:SetScript("OnClick", function()
        local text = frame.editBox:GetText() or ""
        local profileName, profilePlayer = GW.ImportProfile(text)
        frame.result:SetText("")
        if profileName and profilePlayer then
            frame.subheader:SetText(("%s - %s"):format(profileName, profilePlayer))
            frame.result:SetFormattedText("|cff4beb2c%s|r", L["Import string successfully imported!"])
            frame.editBox:SetText("")
        else
            frame.subheader:SetText("")
            frame.result:SetFormattedText("|cffff0000%s|r", L["Error importing profile: Invalid or corrupt string!"])
        end
    end)

    frame.decode = CreateFrame("Button", nil, frame, "GwStandardButton")
    frame.decode:SetPoint("BOTTOMLEFT")
    frame.decode:SetSize(128, 28)
    frame.decode:SetScript("OnClick", function()
        local txt = frame.editBox:GetText() or ""
        frame.result:SetText("")

        if frame.mode == "convert" then
            local ok, msgOrData = GW.ConvertOldProfileString(txt)
            if ok then
                frame.result:SetFormattedText("|cff4beb2c%s|r", L["Import string successfully converted!"])
                frame.editBox:SetText(msgOrData)
            else
                frame.result:SetFormattedText("|cffff0000%s|r", msgOrData or L["Error"])
            end
            return
        end

        -- decode only (preview)
        if GW.GetImportStringType(txt) == "Deflate" then --TODO
            local profileName, profilePlayer = GW.DecodeProfile(txt)
            if not profileName or not profilePlayer then
                frame.subheader:SetText("")
                frame.result:SetFormattedText("|cffff0000%s|r", L["Error decoding profile: Invalid or corrupt string!"])
            else
                frame.subheader:SetText(("%s - %s"):format(profileName, profilePlayer))
                frame.result:SetFormattedText("|cff4beb2c%s|r", L["Import string successfully decoded!"])
            end
        else
            frame.result:SetFormattedText("|cffff0000%s|r", L["Error decoding profile: Invalid or corrupt string!"])
        end
    end)

    return frame
end

------------------------------------------------------------
-- Profile ops
------------------------------------------------------------
local function deleteProfile(name)
    if not name then return end
    GW.globalSettings:DeleteProfile(name, true)

    -- gekoppelte Layouts entfernen
    local allLayouts = GW.GetAllLayouts()
    local profileName = L["Profiles"] .. " - " .. name
    if allLayouts[profileName] then
        GW.global.layouts[profileName] = nil
    end
end
AddForProfiling("panel_profiles", "deleteProfile", deleteProfile)

local function setProfile(profileName)
    if not profileName then return end
    GW.globalSettings:SetProfile(profileName)
    C_UI.Reload()
end
AddForProfiling("panel_profiles", "setProfile", setProfile)

------------------------------------------------------------
-- Item handlers
------------------------------------------------------------
local function delete_OnClick(self)
    local p = self:GetParent()
    GW.ShowPopup({
        text = L["Are you sure you want to delete this profile?"] .. "\n\n'" .. (p.profileName or UNKNOWN) .. "'",
        OnAccept = function()
            deleteProfile(p.profileName)
            UpdateScrollBox(ProfileWin)
        end
    })
end
AddForProfiling("panel_profiles", "delete_OnClick", delete_OnClick)

local function activate_OnClick(self)
    local p = self:GetParent()
    if not p.canActivate then return end
    GW.ShowPopup({
        text = L["Do you want to activate profile"] .. "\n\n'" .. (p.profileName or UNKNOWN) .. "'?",
        OnAccept = function()
            setProfile(p.profileName)
        end
    })
end
AddForProfiling("panel_profiles", "activate_OnClick", activate_OnClick)

local function export_OnClick(self)
    local p = self:GetParent()
    local exportString = GW.GetExportString(p.profileName)

    ImportExportFrame:Show()
    ImportExportFrame.mode = "export"
    ImportExportFrame.header:SetText(L["Export Profile"])
    ImportExportFrame.subheader:SetText(p.profileName or "")
    ImportExportFrame.description:SetText(L["Profile string to share your settings:"])
    ImportExportFrame.import:Hide()
    ImportExportFrame.decode:Hide()
    ImportExportFrame.editBox:SetText(exportString or "")
    ImportExportFrame.editBox:HighlightText()
    ImportExportFrame.editBox:SetFocus()
end
AddForProfiling("panel_profiles", "export_OnClick", export_OnClick)

local function changeIcon_OnClick(btn)
    if not IconSelectionFrame then return end
    IconSelectionFrame.OkayButton_OnClick = function()
        local iconTexture = IconSelectionFrame.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture()
        if iconTexture then
            local name = btn:GetParent().profileName
            if name and GW.globalSettings.profiles[name] then
                GW.globalSettings.profiles[name].profileIcon = iconTexture
                UpdateScrollBox(ProfileWin)
            end
            IconSelectionFrame:Hide()
        end
    end

    if IconSelectionFrame:IsShown() then
        IconSelectionFrame:Hide()
    else
        local name = btn:GetParent().profileName
        local ic = name and GW.globalSettings.profiles[name] and GW.globalSettings.profiles[name].profileIcon
        IconSelectionFrame:Show()
        IconSelectionFrame:Update(ic)
    end
end

local function rename_OnClick(self)
    local oldName = self:GetParent().profileName
    GW.ShowPopup({
        text = GARRISON_SHIP_RENAME_LABEL,
        hasEditBox = true,
        inputText = oldName,
        notHideOnAccept = true,
        OnAccept = function(popup)
            local newName = popup.input:GetText()
            if not newName or newName == "" then return end
            if GW.globalSettings.profiles[newName] then
                GW.Notice("Profile with that name already exists")
                GW.ShowPopup({ text = "Profile with that name already exists" })
                return
            end

            local currentProfile = GW.globalSettings:GetCurrentProfile()
            GW.globalSettings:SetProfile(newName)
            GW.globalSettings:CopyProfile(oldName, true)
            GW.globalSettings:DeleteProfile(oldName, true)
            GW.globalSettings:SetProfile(currentProfile)

            local oldLayoutName = L["Profiles"] .. " - " .. oldName
            if GW.global.layouts[oldLayoutName] then
                GW.global.layouts[oldLayoutName].name = L["Profiles"] .. " - " .. newName
                GW.global.layouts[oldLayoutName].profileName = newName
                GW.global.layouts[newName] = GW.CopyTable(GW.global.layouts[oldLayoutName])
                GW.global.layouts[oldLayoutName] = nil

                -- private Layouts aktualisieren
                local privateLayouts = GW.GetAllPrivateLayouts()
                for i = 0, #privateLayouts do
                    if privateLayouts[i] and privateLayouts[i].layoutName == oldLayoutName then
                        GW.private.Layouts[i].layoutName = L["Profiles"] .. " - " .. newName
                    end
                end
            end

            UpdateScrollBox(ProfileWin)
            popup:Hide()
            GW.RefreshSettingsAfterProfileSwitch()
        end
    })
end

local function copy_OnClick(self)
    -- create a new profile, activate that and copydata into that profile
    local profileNameToCopy = self:GetParent().profileName
    if not profileNameToCopy then return end

    local currentProfile = GW.globalSettings:GetCurrentProfile()
    GW.globalSettings:SetProfile(L["Copy of"] .. " " .. profileNameToCopy)
    GW.globalSettings:CopyProfile(profileNameToCopy, true)
    GW.CreateProfileLayout()
    GW.globalSettings:SetProfile(currentProfile)

    UpdateScrollBox(ProfileWin)
    GW.RefreshSettingsAfterProfileSwitch()
end

local function item_OnLoad(self)
    self.name:SetFont(UNIT_NAME_FONT, 14)
    self.desc:SetFont(UNIT_NAME_FONT, 10)
    self.activateButton.hint:SetFont(DAMAGE_TEXT_FONT, 10)
    self.activateButton.hint:SetShadowColor(0, 0, 0, 1)
    self.activateButton.hint:SetShadowOffset(1, -1)
    self.desc:SetTextColor(0.49, 0.49, 0.49)
    self.export:GetFontString():SetText(L["Export"])
    self.changeIcon:GetFontString():SetText(L["Edit Icon"])

    self.delete:SetScript("OnClick", delete_OnClick)
    self.export:SetScript("OnClick", export_OnClick)
    self.rename:SetScript("OnClick", rename_OnClick)
    self.changeIcon:SetScript("OnClick", changeIcon_OnClick)
    self.copy:SetScript("OnClick", copy_OnClick)
end
AddForProfiling("panel_profiles", "item_OnLoad", item_OnLoad)

local function ItemActivateButtonOnEnter(self, triggeredFromParent)
    if self:GetParent().canActivate then
        self.icon:SetAlpha(0.5)
        self.hint:Show()
        if not triggeredFromParent then
            self:GetParent():GetScript("OnEnter")(self:GetParent())
        end
    end
end

local function ItemActivateButtonOnLeave(self, triggeredFromParent)
    self.icon:SetAlpha(1)
    self.hint:Hide()
    if not triggeredFromParent then
        self:GetParent():GetScript("OnLeave")(self:GetParent())
    end
end


local function item_OnEnter(self)
    if self.canActivate then
        self.activateButton:GetScript("OnEnter")(self.activateButton, true)
    end

    self.delete:SetShown(self.canDelete)
    self.rename:SetShown(self.canRename)
    self.export:SetShown(self.canExport)
    self.changeIcon:SetShown(self.canChangeIcon)
    self.copy:SetShown(self.canCopy)

    self.delete:SetEnabled(self.canDelete)
    self.rename:SetEnabled(self.canRename)
    self.export:SetEnabled(self.canExport)
    self.copy:SetEnabled(self.canCopy)
end
AddForProfiling("panel_profiles", "item_OnEnter", item_OnEnter)

local function item_OnLeave(self)
    if MouseIsOver(self) then return end
    if self.canActivate then
        self.activateButton:GetScript("OnLeave")(self.activateButton, true)
    end
    if self.canDelete then self.delete:Hide() end
    if self.canRename then self.rename:Hide() end
    if self.canExport then self.export:Hide() end
    if self.canCopy then self.copy:Hide() end
    if self.canChangeIcon then self.changeIcon:Hide() end
end
AddForProfiling("panel_profiles", "item_OnLeave", item_OnLeave)

------------------------------------------------------------
-- Add Profile (API)
------------------------------------------------------------
local function AddProfile(name, addNewProfile, importProfileString)
    if not name or name == "" then name = UNKNOWN end

    local profileList = GW.globalSettings:GetProfiles() or {}
    local importCounter = 1
    for _, v in pairs(profileList) do
        if name == v then
            if importProfileString then
                name = name .. "-" .. importCounter
                importCounter = importCounter + 1
            else
                GW.Notice("Profile with that name already exists")
                GW.ShowPopup({ text = "Profile with that name already exists" })
                return
            end
        end
    end

    if importProfileString then
        GW.globalSettings.profiles[name] = GW.ConvertDbStringToInteger(importProfileString)
    elseif addNewProfile then
        local currentProfile = GW.globalSettings:GetCurrentProfile()
        GW.globalSettings:SetProfile(name)
        GW.globalSettings:ResetProfile(nil, true)
        GW.CreateProfileLayout()
        GW.globalSettings:SetProfile(currentProfile)
    end

    UpdateScrollBox(ProfileWin)
end
GW.AddProfile = AddProfile

------------------------------------------------------------
-- Row initializer
------------------------------------------------------------
local function InitButton(button, elementData)
    if not button.isSkinned then
        button:SetScript("OnEnter", item_OnEnter)
        button:SetScript("OnLeave", item_OnLeave)
        item_OnLoad(button)

        button.activateButton:SetScript("OnEnter", ItemActivateButtonOnEnter)
        button.activateButton:SetScript("OnLeave", ItemActivateButtonOnLeave)
        button.activateButton:SetScript("OnMouseUp", activate_OnClick)

        GW.AddListItemChildHoverTexture(button)

        button.isSkinned = true
    end

    local profileName = elementData.data
    button.profileName = profileName
    button.name:SetText(profileName or UNKNOWN)

    button.hasOptions   = true
    button.canDelete    = true
    button.canExport    = true
    button.canChangeIcon= true
    button.canRename    = true
    button.canCopy      = true
    button.canActivate  = true
    button.activeProfile:Hide()

    if elementData.currentProfile == profileName then
        button.canActivate = false
        button.canDelete = false
        button.activeProfile:Show()
    end

    local prof = GW.globalSettings.profiles[profileName] or {}
    prof.profileCreatedDate = prof.profileCreatedDate or UNKNOWN
    prof.profileCreatedCharacter = prof.profileCreatedCharacter or UNKNOWN
    prof.profileIcon = prof.profileIcon or ICONS[random(1, #ICONS > 0 and #ICONS or 1)]
    GW.globalSettings.profiles[profileName] = prof -- ensure back

    if type(prof.profileIcon) == "number" then
        button.activateButton.icon:SetTexture(prof.profileIcon)
    else
        button.activateButton.icon:SetTexture("INTERFACE/ICONS/" .. tostring(prof.profileIcon))
    end

    local lastUpdate = prof.profileChangedDate and (L["Last updated: "] .. prof.profileChangedDate) or ""
    button.desc:SetText(
        L["Created: "] .. prof.profileCreatedDate .. "\n" ..
        L["Created by: "] .. prof.profileCreatedCharacter .. "\n" ..
        lastUpdate
    )
end

------------------------------------------------------------
-- Icons
------------------------------------------------------------
local function collectAllIcons()
    wipe(ICONS)
    local activeIcons = {}

    local function addIcon(fileID)
        if fileID then activeIcons[fileID] = true end
    end

    if GW.Retail then
        local lines = C_SpellBook.GetNumSpellBookSkillLines() or 0
        for i = 1, lines do
            local info = C_SpellBook.GetSpellBookSkillLineInfo(i)
            if info then
                local startIndex = (info.itemIndexOffset or 0) + 1
                local endIndex = startIndex + (info.numSpellBookItems or 0) - 1
                for j = startIndex, endIndex do
                    local itemInfo = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
                    if itemInfo and itemInfo.itemType ~= "FUTURESPELL" then
                        addIcon(C_SpellBook.GetSpellBookItemTexture(j, Enum.SpellBookSpellBank.Player))
                    end
                    if itemInfo and itemInfo.itemType == "FLYOUT" then
                        local _, _, numSlots, isKnown = GetFlyoutInfo(itemInfo.actionID)
                        if isKnown and numSlots and numSlots > 0 then
                            for k = 1, numSlots do
                                local spellID, _, isKnownSlot = GetFlyoutSlotInfo(itemInfo.actionID, k)
                                if isKnownSlot and spellID then
                                    addIcon(C_Spell.GetSpellTexture(spellID))
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        local numTabs = GetNumSpellTabs()
        for i = 1, numTabs do
            local _, _, offset, numSpells = GetSpellTabInfo(i)
            local startIndex = (offset or 0) + 1
            local endIndex = startIndex + (numSpells or 0) - 1
            for j = startIndex, endIndex do
                local itemType, actionID = GetSpellBookItemInfo(j, "player")
                if itemType ~= "FUTURESPELL" then
                    addIcon(GetSpellBookItemTexture(j, "player"))
                end
                if itemType == "FLYOUT" then
                    local _, _, numSlots, isKnown = GetFlyoutInfo(actionID)
                    if isKnown and numSlots and numSlots > 0 then
                        for k = 1, numSlots do
                            local spellID, _, isKnownSlot = GetFlyoutSlotInfo(actionID, k)
                            if isKnownSlot and spellID then
                                addIcon(GetSpellTexture(spellID))
                            end
                        end
                    end
                end
            end
        end
    end

    for fileDataID in pairs(activeIcons) do
        ICONS[#ICONS + 1] = fileDataID
    end

    GetLooseMacroIcons(ICONS)
    GetLooseMacroItemIcons(ICONS)
    GetMacroIcons(ICONS)
    GetMacroItemIcons(ICONS)

    if #ICONS == 0 then
        ICONS[1] = 134400 -- fallback icon fileID
    end
end

------------------------------------------------------------
-- Entry point
------------------------------------------------------------
local function LoadSettingsProfileTab(container)
    local settingsProfile = CreateFrame("Frame", "GW2ProfileSettingsView", container, "GwSettingsProfilePanelTmpl")

    settingsProfile.name = "GwSettingsProfilePanel"
    settingsProfile.headerBreadcrumbText = L["Profiles"]
    settingsProfile.hasSearch = false
    container:AddTab("Interface/AddOns/GW2_UI/textures/uistuff/tabicon_profiles.png", settingsProfile)

    collectAllIcons()

    GW.SettingsMenuButtonSetUp(settingsProfile.menu.newProfile, true)
    GW.SettingsMenuButtonSetUp(settingsProfile.menu.importProfile, false)
    GW.SettingsMenuButtonSetUp(settingsProfile.menu.convertOldProfileString, true)

    -- List
    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("GwProfileItemTmpl", function(button, elementData)
        InitButton(button, elementData)
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(settingsProfile.ScrollBox, settingsProfile.ScrollBar, view)
    GW.HandleTrimScrollBar(settingsProfile.ScrollBar)
    GW.HandleScrollControls(settingsProfile)
    settingsProfile.ScrollBar:SetHideIfUnscrollable(true)
    ProfileWin = settingsProfile.ScrollBox
    UpdateScrollBox(ProfileWin)

   -- Header/sub
    settingsProfile.header:SetFont(DAMAGE_TEXT_FONT, 20)
    settingsProfile.header:SetText(L["Profiles"])
    settingsProfile.sub:SetFont(UNIT_NAME_FONT, 12)
    settingsProfile.sub:SetText(L["Profiles are an easy way to share your settings across characters and realms."])

    -- Spec switch block
    GW.InititateProfileSpecSwitchSettings(settingsProfile)

    -- Reset to default card
    settingsProfile.resetToDefaultFrame:SetScript("OnEnter", item_OnEnter)
    settingsProfile.resetToDefaultFrame:SetScript("OnLeave", item_OnLeave)
    item_OnLoad(settingsProfile.resetToDefaultFrame)

    settingsProfile.resetToDefaultFrame.activateButton.icon:SetTexture("Interface/AddOns/GW2_UI/textures/gwlogo.png")
    settingsProfile.resetToDefaultFrame.activateButton.icon:SetTexCoord(0, 1, 0, 1)

    settingsProfile.resetToDefaultFrame.hasOptions = false
    settingsProfile.resetToDefaultFrame.canDelete = false
    settingsProfile.resetToDefaultFrame.canExport = false
    settingsProfile.resetToDefaultFrame.canChangeIcon = false
    settingsProfile.resetToDefaultFrame.canRename = false
    settingsProfile.resetToDefaultFrame.canCopy = false
    settingsProfile.resetToDefaultFrame.canActivate = false
    settingsProfile.resetToDefaultFrame.background:SetTexCoord(0, 1, 0, 0.5)

    settingsProfile.resetToDefaultFrame.name:SetText(L["Default Settings"])
    settingsProfile.resetToDefaultFrame.desc:SetText(L["Load the default addon settings to the current profile."])
    settingsProfile.resetToDefaultFrame.defaultSettings:Show()
    settingsProfile.resetToDefaultFrame.defaultSettings:SetText(L["Load"])
    settingsProfile.resetToDefaultFrame.defaultSettings:SetScript("OnClick", function()
        GW.ShowPopup({
            text = L["Are you sure you want to load the default settings?\n\nAll previous settings will be lost."],
            OnAccept = function()
                ResetToDefault()
                C_UI.Reload()
            end
        })
    end)
    settingsProfile.resetToDefaultFrame:Show()

    -- Menu buttons
    settingsProfile.menu.newProfile:SetText(NEW_COMPACT_UNIT_FRAME_PROFILE)
    settingsProfile.menu.newProfile:SetScript("OnClick", function()
        GW.ShowPopup({
            text = NEW_COMPACT_UNIT_FRAME_PROFILE,
            hasEditBox = true,
            OnAccept = function(popup)
                local txt = popup.input:GetText()
                AddProfile((txt and txt ~= "" and txt) or UNKNOWN, true)
            end
        })
    end)

    settingsProfile.menu.importProfile:SetText(L["Import Profile"])
    settingsProfile.menu.importProfile:SetScript("OnClick", function()
        ImportExportFrame:Show()
        ImportExportFrame.mode = "import"
        ImportExportFrame.header:SetText(L["Import Profile"])
        ImportExportFrame.subheader:SetText("")
        ImportExportFrame.description:SetText(L["Paste your profile string here to import the profile."])
        ImportExportFrame.editBox:SetText("")
        ImportExportFrame.import:Show()
        ImportExportFrame.decode:Show()
        ImportExportFrame.decode:SetText(L["Decode"])
        ImportExportFrame.result:SetText("")
        ImportExportFrame.editBox:SetFocus()
    end)

    settingsProfile.menu.convertOldProfileString:SetText(L["Convert old profile String"])
    settingsProfile.menu.convertOldProfileString:SetScript("OnClick", function()
        ImportExportFrame:Show()
        ImportExportFrame.mode = "convert"
        ImportExportFrame.header:SetText(L["Convert old profile String to new one"])
        ImportExportFrame.subheader:SetText("")
        ImportExportFrame.description:SetText(L["Paste your profile string here to convert to the new format."])
        ImportExportFrame.editBox:SetText("")
        ImportExportFrame.import:Hide()
        ImportExportFrame.decode:Show()
        ImportExportFrame.decode:SetText(CONVERT)
        ImportExportFrame.result:SetText("")
        ImportExportFrame.editBox:SetFocus()
    end)

    IconSelectionFrame = CreateFrame("Frame", nil, settingsProfile, "IconSelectorPopupFrameTemplate")
    IconSelectionFrame:Hide()
    IconSelectionFrame:OnLoad()
    IconSelectionFrame:EnableMouse(true)
    IconSelectionFrame:SetScript("OnShow", function(self)
        self:OnShow()
        self.iconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.Equipment)
        self:SetIconFilter(IconSelectorPopupFrameIconFilterTypes.All)
        self:Update()

        self.IconSelector:SetSelectedCallback(function(selectionIndex, icon)
            self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon)
            self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_CLICK)
            self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetFontObject(GameFontHighlightSmall)
        end)

        if not self.isSkinned then
            GW.HandleIconSelectionFrame(self)
        end
    end)
    IconSelectionFrame:SetScript("OnHide", IconSelectionFrame.OnHide)
    IconSelectionFrame:SetScript("OnEvent", IconSelectionFrame.OnEvent)
    IconSelectionFrame.BorderBox.IconSelectorEditBox:Hide()
    IconSelectionFrame.Update = function(self, texture)
        self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(texture))
        self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(texture)
        local getSelection = GenerateClosure(self.GetIconByIndex, self)
        local getNumSelections = GenerateClosure(self.GetNumIcons, self)
        self.IconSelector:SetSelectionsDataProvider(getSelection, getNumSelections)
        self.IconSelector:ScrollToSelectedIndex()
        self:SetSelectedIconText()
        self.BorderBox.OkayButton:Enable()
    end

    -- Build import/export frame last (needs fonts/colors already loaded)
    ImportExportFrame = createImportExportFrame()

    return settingsProfile
end
GW.LoadSettingsProfileTab = LoadSettingsProfileTab
