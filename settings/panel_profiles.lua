local _, GW = ...
local L = GW.L
local createCat = GW.CreateCat
local ResetToDefault = GW.ResetToDefault
local AddForProfiling = GW.AddForProfiling
local settingMenuToggle = GW.settingMenuToggle

local ICONS = {}
local ImportExportFrame = nil
local ProfileWin = nil

local function UpdateScrollBox(self)
    local dataProvider = CreateDataProvider()
    local profiles = GW.globalSettings:GetProfiles()
    local currentProfile = GW.globalSettings:GetCurrentProfile()

    table.sort(
        profiles,
        function(a, b)
            return a < b
        end
    )

    for index, profile in pairs( profiles ) do
        dataProvider:Insert({index = index, data = profile, currentProfile = currentProfile})
    end

    self:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end

local function createImportExportFrame()
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
    frame.scrollArea.ScrollBar:GwSkinScrollBar()
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
        local profileName, profilePlayer, version = GW.ImportProfile(frame.editBox:GetText())

        frame.result:SetText("")
        if profileName and profilePlayer and version == "Retail" then
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
    frame.decode:SetScript("OnClick", function()
        -- if the frame header is L["Convert old profile String to new one"] then try to convert the string to the new format
        if frame.header:GetText() == L["Convert old profile String to new one"] then
            local result, dataString = GW.ConvertOldProfileString(frame.editBox:GetText())

            if result then
                frame.result:SetFormattedText("|cff4beb2c%s|r", L["Import string successfully converted!"])
                frame.editBox:SetText(dataString)
            else
                frame.result:SetFormattedText("|cffff0000%s|r", dataString)
            end
        else
            if GW.GetImportStringType(frame.editBox:GetText()) == "Deflate" then
                local profileName, profilePlayer, version, profileData = GW.DecodeProfile(frame.editBox:GetText())

                frame.result:SetText("")
                if not profileName or not profilePlayer or version ~= "Retail" then
                    frame.subheader:SetText("")
                    frame.result:SetFormattedText("|cffff0000%s|r", L["Error decoding profile: Invalid or corrupt string!"] )
                else
                    frame.subheader:SetText(profileName .. " - " .. profilePlayer .. " - " .. version)

                    frame.result:SetFormattedText("|cff4beb2c%s|r", L["Import string successfully decoded!"])
                end
            end
        end
    end)

    return frame
end

local function deleteProfile(name)
    GW.globalSettings:DeleteProfile(name, true)

    -- delete also all "attached" layouts
    local allLayouts = GW.GetAllLayouts()
    local profileName = L["Profiles"] .. " - " .. name
    if allLayouts[profileName] then
        GW.global.layouts[profileName] = nil
    end
end
AddForProfiling("panel_profiles", "deleteProfile", deleteProfile)

local function setProfile(profileName)
    GW.globalSettings:SetProfile(profileName)
    C_UI.Reload()
end
AddForProfiling("panel_profiles", "setProfile", setProfile)

local function delete_OnClick(self)
    local p = self:GetParent()
    GW.WarningPrompt(
        L["Are you sure you want to delete this profile?"] .. "\n\n'" .. (p.profileName or UNKNOWN) .. "'",
        function()
            deleteProfile(p.profileName)
            UpdateScrollBox(ProfileWin)
            GwSmallSettingsContainer.layoutView.savedLayoutDropDown.container.contentScroll.update(GwSmallSettingsContainer.layoutView.savedLayoutDropDown.container.contentScroll)

            UpdateScrollBox(ProfileWin)
        end,
        nil,
        nil,
        nil,
        true
    )
end
AddForProfiling("panel_profiles", "delete_OnClick", delete_OnClick)

local function activate_OnClick(self)
    local p = self:GetParent()
    if not p.canActivate then return end
    GW.WarningPrompt(
        L["Do you want to activate profile"] .. "\n\n'" .. (p.profileName or UNKNOWN) .."'?",
        function()
            setProfile(p.profileName) -- triggers a reload
        end
    )
end
AddForProfiling("panel_profiles", "activate_OnClick", activate_OnClick)

local function export_OnClick(self)
    local p = self:GetParent()
    local exportString = GW.GetExportString(p.profileName)

    ImportExportFrame:Show()
    ImportExportFrame.header:SetText(L["Export Profile"])
    ImportExportFrame.subheader:SetText(p.profileName)
    ImportExportFrame.description:SetText(L["Profile string to share your settings:"])
    ImportExportFrame.import:Hide()
    ImportExportFrame.decode:Hide()
    ImportExportFrame.editBox:SetText(exportString)
    ImportExportFrame.editBox:HighlightText()
    ImportExportFrame.editBox:SetFocus()
end
AddForProfiling("panel_profiles", "export_OnClick", export_OnClick)

local function rename_OnClick(self)
    GW.InputPrompt(
        GARRISON_SHIP_RENAME_LABEL,
        function()
            if GwWarningPrompt.input:GetText() == nil then return end
            local profileName = GwWarningPrompt.input:GetText() or UNKNOWN
            local profileOriginalName = self:GetParent().profileName
            if GW.globalSettings.profiles[profileName] then
                GW.Notice("Profile with that name already exists")
                GW.WarningPrompt("Profile with that name already exists")
                return
            end
            GW.globalSettings.profiles[profileOriginalName].profilename = profileName
            GW.globalSettings.profiles[profileName] = GW.copyTable(nil, GW.globalSettings.profiles[profileOriginalName])
            GW.globalSettings.profiles[profileOriginalName] = nil

            -- rename also the profile layout
            if GW.global.layouts[profileOriginalName] then
                GW.global.layouts[profileOriginalName].name = L["Profiles"] .. " - " .. profileName
                GW.global.layouts[profileOriginalName].profileName = profileName

                GW.global.layouts[profileName] = GW.copyTable(nil, GW.global.layouts[profileOriginalName])
                GW.global.layouts[profileOriginalName] = nil
                GwSmallSettingsContainer.layoutView.savedLayoutDropDown.container.contentScroll.update(GwSmallSettingsContainer.layoutView.savedLayoutDropDown.container.contentScroll)

                --rename the assinged layouts
                local privateLayouts = GW.GetAllPrivateLayouts()
                for i = 0, #privateLayouts do
                    if privateLayouts[i] and privateLayouts[i].layoutName == profileOriginalName then
                        GW.private.Layouts[i].layoutName = profileName
                    end
                end
            end

            UpdateScrollBox(ProfileWin)

            GwWarningPrompt:Hide()
        end,
        self:GetParent().profileName,
        nil,
        true
    )
end

local function copy_OnClick(self)
    local newProfil = GW.copyTable(nil, GW.globalSettings.profiles[self:GetParent().profileName])
    GW.addProfile(L["Copy of"] .. " " .. GW.globalSettings.profiles[self:GetParent().profileName].profilename, newProfil, true)
end


local function item_OnLoad(self)
    self.name:SetFont(UNIT_NAME_FONT, 14)
    self.desc:SetFont(UNIT_NAME_FONT, 10)
    self.activateButton.hint:SetFont(DAMAGE_TEXT_FONT, 10)
    self.activateButton.hint:SetShadowColor(0, 0, 0, 1)
    self.activateButton.hint:SetShadowOffset(1, -1)

    self.desc:SetTextColor(0.49, 0.49, 0.49)

    self.export:GetFontString():SetText(L["Export"])

    self.delete:SetScript("OnClick", delete_OnClick)
    self.export:SetScript("OnClick", export_OnClick)
    self.rename:SetScript("OnClick", rename_OnClick)
    self.copy:SetScript("OnClick", copy_OnClick)

end
AddForProfiling("panel_profiles", "item_OnLoad", item_OnLoad)

local function item_OnEnter(self)
    if self.canActivate then
        self.activateButton:GetScript("OnEnter")(self.activateButton, true)
    end

    self.delete:SetEnabled(self.canDelete)
    self.delete:SetShown(self.canDelete)
    self.rename:SetEnabled(self.canRename)
    self.rename:SetShown(self.canRename)
    self.export:SetEnabled(self.canExport)
    self.export:SetShown(self.canExport)
    self.copy:SetEnabled(self.canCopy)
    self.copy:SetShown(self.canCopy)
end
AddForProfiling("panel_profiles", "item_OnEnter", item_OnEnter)

local function item_OnLeave(self)
    if MouseIsOver(self) then return end

    if self.canActivate then
        self.activateButton:GetScript("OnLeave")(self.activateButton, true)
    end

    if self.canDelete then
        self.delete:Hide()
    end
    if self.canRename then
        self.rename:Hide()
    end
    if self.canExport then
        self.export:Hide()
    end
    if self.canCopy then
        self.copy:Hide()
    end
end
AddForProfiling("panel_profiles", "item_OnLeave", item_OnLeave)

local function addProfile(name, profileData, copy)
    local profileList = GW.globalSettings:GetProfiles()
    for _, v in pairs(profileList) do
        if name == v then
            GW.Notice("Profile with that name already exists")
            GW.WarningPrompt("Profile with that name already exists")
            return
        end
    end

    if copy then
        GW.globalSettings.profiles[name] = profileData
        GW.globalSettings.profiles[name].profilename = name
    elseif profileData then
        GW.globalSettings.profiles[name] = profileData
    else
        local currentProfile = GW.globalSettings:GetCurrentProfile()
        GW.globalSettings:SetProfile(name)
        GW.globalSettings:ResetProfile(nil, true)
        GW.CreateProfileLayout()
        GW.globalSettings:SetProfile(currentProfile)
    end

    UpdateScrollBox(ProfileWin)
end
GW.addProfile = addProfile
AddForProfiling("panel_profiles", "addProfile", addProfile)

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

    button.profileName = elementData.data
    button.name:SetText(elementData.data)

    button.hasOptions = true
    button.canDelete = true
    button.canExport = true
    button.canRename = true
    button.canCopy = true
    button.canActivate = true
    button.activeProfile:Hide()

    if elementData.currentProfile == elementData.data then
        button.canActivate = false
        button.canDelete = false
        button.activeProfile:Show()
    end

    GW.globalSettings.profiles[elementData.data].profileCreatedDate = GW.globalSettings.profiles[elementData.data].profileCreatedDate or UNKNOWN
    GW.globalSettings.profiles[elementData.data].profileCreatedCharacter = GW.globalSettings.profiles[elementData.data].profileCreatedCharacter or UNKNOWN
    GW.globalSettings.profiles[elementData.data].profileIcon = GW.globalSettings.profiles[elementData.data].profileIcon or ICONS[math.random(1, #ICONS)]

    if(type(GW.globalSettings.profiles[elementData.data].profileIcon) == "number") then
        button.activateButton.icon:SetTexture(GW.globalSettings.profiles[elementData.data].profileIcon)
    else
        button.activateButton.icon:SetTexture("INTERFACE\\ICONS\\" .. GW.globalSettings.profiles[elementData.data].profileIcon)
    end

    button.desc:SetText(L["Created: "] ..
        GW.globalSettings.profiles[elementData.data].profileCreatedDate .. "\n" ..
        L["Created by: "] ..
        GW.globalSettings.profiles[elementData.data].profileCreatedCharacter .. "\n"
    )
end

local function collectAllIcons()
    -- We need to avoid adding duplicate spellIDs from the spellbook tabs for your other specs.
    local activeIcons = {}

    for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
        skillLineInfo.itemIndexOffset = skillLineInfo.itemIndexOffset + 1
        local tabEnd = skillLineInfo.itemIndexOffset + skillLineInfo.numSpellBookItems
        for j = skillLineInfo.itemIndexOffset, tabEnd - 1 do
            --to get spell info by slot, you have to pass in a pet argument
            local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
            if spellBookItemInfo.itemType ~= "FUTURESPELL" then
                local fileID = C_SpellBook.GetSpellBookItemTexture(j, Enum.SpellBookSpellBank.Player)
                if fileID then
                    activeIcons[fileID] = true
                end
            end
            if spellBookItemInfo.itemType == "FLYOUT" then
                local _, _, numSlots, isKnown = GetFlyoutInfo(spellBookItemInfo.actionID)
                if (isKnown and numSlots > 0) then
                    for k = 1, numSlots do
                        local spellID, _, isKnownSlot = GetFlyoutSlotInfo(spellBookItemInfo.actionID, k)
                        if isKnownSlot and spellID then
                            local fileID = C_Spell.GetSpellTexture(spellID)
                            if fileID then
                                activeIcons[fileID] = true
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
end

--copied from character.lua needs to be removed later
local function CharacterMenuButton_OnLoad(self, odd)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    if odd then
        self:ClearNormalTexture()
    else
        self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
    end

    self:GetFontString():SetJustifyH("LEFT")
    self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
end

local function LoadProfilesPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsProfilePanelTmpl")

    CharacterMenuButton_OnLoad(p.menu.newProfile, true)
    CharacterMenuButton_OnLoad(p.menu.importProfile, false)
    CharacterMenuButton_OnLoad(p.menu.convertOldProfileString, true)

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("GwProfileItemTmpl", function(button, elementData)
        InitButton(button, elementData);
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(p.ScrollBox, p.ScrollBar, view)
    GW.HandleTrimScrollBar(p.ScrollBar)
    GW.HandleScrollControls(p)
    p.ScrollBar:SetHideIfUnscrollable(true)
    ProfileWin = p.ScrollBox

    UpdateScrollBox(p.ScrollBox)

    collectAllIcons()

    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(1, 1, 1)
    p.header:SetText(L["Profiles"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(125 / 255, 125 / 255, 125 / 255)
    p.sub:SetText(L["Profiles are an easy way to share your settings across characters and realms."])

    p.resetToDefaultFrame = CreateFrame("Button", nil, p, "GwProfileItemTmpl")
    p.resetToDefaultFrame:SetPoint("TOPLEFT", 5, -65)

    p.resetToDefaultFrame:SetScript("OnEnter", item_OnEnter)
    p.resetToDefaultFrame:SetScript("OnLeave", item_OnLeave)
    item_OnLoad(p.resetToDefaultFrame)

    p.resetToDefaultFrame.activateButton.icon:SetTexture("Interface/icons/inv_corgi2")

    p.resetToDefaultFrame.hasOptions = false
    p.resetToDefaultFrame.canDelete = false
    p.resetToDefaultFrame.canExport = false
    p.resetToDefaultFrame.canRename = false
    p.resetToDefaultFrame.canCopy = false
    p.resetToDefaultFrame.background:SetTexCoord(0, 1, 0, 0.5)
    p.resetToDefaultFrame.canActivate = false

    p.resetToDefaultFrame.name:SetText(L["Default Settings"])
    p.resetToDefaultFrame.desc:SetText(L["Load the default addon settings to the current profile."])
    p.resetToDefaultFrame.defaultSettings:SetScript("OnClick",
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
    p.resetToDefaultFrame.defaultSettings:SetText(L["Load"])
    p.resetToDefaultFrame.defaultSettings:Show()
    p.resetToDefaultFrame:Show()

    p.menu.newProfile:SetText(NEW_COMPACT_UNIT_FRAME_PROFILE)
    local fnGCNP_OnClick = function()
        GW.InputPrompt(
            NEW_COMPACT_UNIT_FRAME_PROFILE,
            function()
                addProfile(string.len(GwWarningPrompt.input:GetText()) == 0 and UNKNOWN or GwWarningPrompt.input:GetText())
                GwWarningPrompt:Hide()
            end
        )
    end
    p.menu.newProfile:SetScript("OnClick", fnGCNP_OnClick)

    p.menu.importProfile:SetText(L["Import Profile"])
    p.menu.importProfile:SetScript("OnClick", function()
        ImportExportFrame:Show()
        ImportExportFrame.header:SetText(L["Import Profile"])
        ImportExportFrame.subheader:SetText("")
        ImportExportFrame.description:SetText(L["Paste your profile string here to import the profile."])
        ImportExportFrame.editBox:SetText("")
        ImportExportFrame.import:Show()
        ImportExportFrame.decode:Show()
        ImportExportFrame.result:SetText("")
        ImportExportFrame.editBox:SetFocus()
        ImportExportFrame.decode:SetText(L["Decode"])
    end)

    p.menu.convertOldProfileString:SetText(L["Convert old profile String"])
    p.menu.convertOldProfileString:SetScript("OnClick", function()
        ImportExportFrame:Show()
        ImportExportFrame.header:SetText(L["Convert old profile String to new one"])
        ImportExportFrame.subheader:SetText("")
        ImportExportFrame.description:SetText(L["Paste your profile string here to convert to the new format."])
        ImportExportFrame.editBox:SetText("")
        ImportExportFrame.import:Hide()
        ImportExportFrame.decode:Show()
        ImportExportFrame.result:SetText("")
        ImportExportFrame.editBox:SetFocus()
        ImportExportFrame.decode:SetText(CONVERT)
    end)

    createCat(L["PROFILES"], L["Add and remove profiles."], p, nil, true, "Interface\\AddOns\\GW2_UI\\textures\\uistuff\\tabicon_profiles")

    p:SetScript("OnShow", function()
        settingMenuToggle(false)
        sWindow.headerString:SetWidth(sWindow.headerString:GetStringWidth())
        local s = L["PROFILES"]

        sWindow.headerBreadcrumb:SetText(s:lower():gsub("^%l", string.upper))
    end)

    ImportExportFrame = createImportExportFrame()
end
GW.LoadProfilesPanel = LoadProfilesPanel
