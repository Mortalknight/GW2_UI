---@class GW2
local GW = select(2, ...)
local L = GW.L

local function ForEachPrivateLayout(callback)
    for key, entry in pairs(GW.GetAllPrivateLayouts()) do
        if type(key) == "number" and type(entry) == "table" then
            local result = callback(entry, key)
            if result ~= nil then
                return result
            end
        end
    end
end

local function GetFreePrivateLayoutIndex()
    local free = 1
    for key in pairs(GW.GetAllPrivateLayouts()) do
        if type(key) == "number" and key >= free then
            free = key + 1
        end
    end
    return free
end

local function IsLayoutLocked(layout)
    if not layout or not layout.profileLayout then return false end
    return layout.profileName ~= nil and GW.globalSettings.profiles[layout.profileName] ~= nil
end

local function RefreshSpecsDropdown()
    local view = GwSmallSettingsContainer and GwSmallSettingsContainer.layoutView
    if not view then return end

    view.specsDropDown:GenerateMenu()
end

local function UpdateMatchingLayout(self, new_point)
    if GW.IsApplyingMoverPositions then return end

    local selectedLayoutName = GW.private.Layouts.currentSelected
    local layout = selectedLayoutName and GW.GetLayoutByName(selectedLayoutName)
    if not layout then return end

    for _, frame in pairs(layout.frames) do
        if frame.settingName == self.setting then
            frame.point = GW.CopyTable(new_point)
            return
        end
    end

    layout.frames[#layout.frames + 1] = {settingName = self.setting, point = GW.CopyTable(new_point)}
end
GW.UpdateMatchingLayout = UpdateMatchingLayout

local function GetUsablePoint(point)
    if point and point.point and point.relativePoint and point.xOfs and point.yOfs then
        return point
    end
end

local function StoreLayoutPoint(layout, settingName, point)
    for _, frame in pairs(layout.frames) do
        if frame.settingName == settingName then
            frame.point = GW.CopyTable(point)
            return
        end
    end

    layout.frames[#layout.frames + 1] = {settingName = settingName, point = GW.CopyTable(point)}
end

local function UpdateFramePositionForLayout(layout, layoutManager, updateDropdown, startUp)
    if not layout then return end
    if updateDropdown then
        GW.private.Layouts.currentSelected = layout.name
        GwSmallSettingsContainer.layoutView.savedLayoutDropDown:GenerateMenu()
        RefreshSpecsDropdown()

        GwSmallSettingsContainer.layoutView.savedLayoutDropDown.setByUpdateFramePositionForLayout = true

        GwSmallSettingsContainer.layoutView.delete:SetEnabled(not IsLayoutLocked(layout))
        GwSmallSettingsContainer.layoutView.rename:SetEnabled(not IsLayoutLocked(layout))
    end

    local points = {}
    for _, frame in pairs(layout.frames) do
        if frame.settingName then
            points[frame.settingName] = GetUsablePoint(frame.point)
        end
    end

    for _, mover in ipairs(GW.MOVABLE_FRAMES) do
        local point = points[mover.setting]

        -- A layout that says nothing about a frame must never move it: older layouts lost the entries of every
        -- frame that sat at its default position, and moving those back to the default would throw away the
        -- positions of the profile. The layout adopts the current position instead, so nothing jumps and the
        -- next switch has a value to restore.
        if not point then
            point = GetUsablePoint(GW.GetSetting(mover.setting).pos)
            if point then
                StoreLayoutPoint(layout, mover.setting, point)
            end
        end

        if point then
            mover:ClearAllPoints()
            mover:SetPoint(point.point, UIParent, point.relativePoint, point.xOfs, point.yOfs)
            if not startUp then
                mover:GetScript("OnDragStop")(mover)
            end
        end
    end

    if layoutManager then
        layoutManager:GetScript("OnEvent")(layoutManager)
    end
end

local function AssignLayoutToSpec(specId, layoutName, toSet)
    if toSet then
        local takenBy = ForEachPrivateLayout(function(entry)
            if entry.layoutName ~= layoutName and entry.assignedSpecs and entry.assignedSpecs[specId] then
                return entry.layoutName
            end
        end)
        if takenBy then
            GW.Notice(format(L["Spec is already assigned to the layout %s!"], GW.Gw2Color .. takenBy .. "|r"))
            RefreshSpecsDropdown()
            return
        end
    end

    local privateLayoutSettings = GW.GetPrivateLayoutByLayoutName(layoutName)
    if not privateLayoutSettings then
        local newIdx = GetFreePrivateLayoutIndex()
        GW.private.Layouts[newIdx] = {assignedSpecs = {}}
        privateLayoutSettings = GW.private.Layouts[newIdx]
    end

    privateLayoutSettings.layoutName = layoutName
    privateLayoutSettings.assignedSpecs = privateLayoutSettings.assignedSpecs or {}
    privateLayoutSettings.assignedSpecs[specId] = toSet
end

-- The positions are copied, otherwise the layout would share its tables with the profile settings and follow
-- every move of a frame until the next reload. Only real positions are stored; what a profile never moved is
-- not in its settings either and falls back to the default of the frame when the layout is applied.
local function BuildLayout(name, profileName, settings)
    settings = settings or GW.settings
    local layout = {
        name = name,
        frames = {},
        profileLayout = profileName ~= nil,
        profileName = profileName,
    }

    for _, moveableFrame in pairs(GW.MOVABLE_FRAMES) do
        local point = GetUsablePoint(GW.GetSettingFromTable(settings, moveableFrame.setting .. ".pos"))
        if point then
            layout.frames[#layout.frames + 1] = {settingName = moveableFrame.setting, point = GW.CopyTable(point)}
        end
    end

    GW.global.layouts[name] = layout
    return layout
end

local function EnsureProfileLayout(profileName, settings)
    if not profileName then return end

    local name = L["Profiles"] .. " - " .. profileName
    local existing = GW.GetAllLayouts()[name]
    if existing and existing.profileLayout then return existing end

    return BuildLayout(name, profileName, settings)
end

local function CreateProfileLayout()
    EnsureProfileLayout(GW.globalSettings:GetCurrentProfile())
end
GW.CreateProfileLayout = CreateProfileLayout

local function CreateProfileLayouts()
    for profileName, settings in pairs(GW.globalSettings.profiles) do
        EnsureProfileLayout(profileName, settings)
    end
end
GW.CreateProfileLayouts = CreateProfileLayouts

local function GetNewLayoutName(popup)
    local name = strtrim(popup.input:GetText() or "")
    if name == "" then
        GW.Notice(L["Please enter a name."])
        return
    end
    if GW.global.layouts[name] then
        GW.Notice(L["Layout with that name already exists"])
        GW.ShowPopup({text = L["Layout with that name already exists"]})
        return
    end
    return name
end

local function CreateNewLayout(self)
    GW.ShowPopup({text = L["New layout name:"],
        OnAccept = function(popup)
            local newName = GetNewLayoutName(popup)
            if not newName then return end

            BuildLayout(newName)
            self:GetParent().savedLayoutDropDown:GenerateMenu()
            popup:Hide()
        end,
        hasEditBox = true,
        notHideOnAccept = true
    })
end

local function DeleteSelectedLayout(self)
    GW.ShowPopup({text = L["Are you sure you want to delete the selected layout?"],
        OnAccept = function()
            local layoutName = GW.private.Layouts.currentSelected
            if not layoutName then return end

            GW.global.layouts[layoutName] = nil
            --also delete the assing settings
            GW.DeletePrivateLayoutByLayoutName(layoutName)

            local view = self:GetParent()
            GW.private.Layouts.currentSelected = nil
            view.savedLayoutDropDown:GenerateMenu()
            RefreshSpecsDropdown()
            view.delete:Disable()
            view.rename:Disable()
        end}
    )
end

local function RenameSelectedLayout(self)
    GW.ShowPopup({text = L["Rename layout:"],
        OnAccept = function(popup)
            local oldName = GW.private.Layouts.currentSelected
            local layout = oldName and GW.global.layouts[oldName]
            if not layout then return end

            local newName = GetNewLayoutName(popup)
            if not newName then return end

            layout.name = newName
            GW.global.layouts[newName] = layout
            GW.global.layouts[oldName] = nil

            local privateLayoutSettings = GW.GetPrivateLayoutByLayoutName(oldName)
            if privateLayoutSettings then
                privateLayoutSettings.layoutName = newName
            end

            GW.private.Layouts.currentSelected = newName
            self:GetParent().savedLayoutDropDown:GenerateMenu()

            popup:Hide()
        end,
        hasEditBox = true,
        notHideOnAccept = true,
        inputText = self:GetParent().savedLayoutDropDown:GetText()
    })
end

local PROFILE_LAYOUT_RETRIES = 10

local function specSwitchHandlerOnEvent(self, event)
    local currentSpecIdx = C_SpecializationInfo.GetSpecialization()

    if (event == "PLAYER_SPECIALIZATION_CHANGED" or event == "ACTIVE_TALENT_GROUP_CHANGED") and self.currentSpecIdx == currentSpecIdx then
        return
    end

    self.currentSpecIdx = currentSpecIdx

    if not self.profileLayoutRetryPending then
        self.profileLayoutRetries = 0
    end
    self.profileLayoutRetryPending = nil

    local layoutNameToUse = ForEachPrivateLayout(function(entry)
        if entry.assignedSpecs and entry.assignedSpecs[currentSpecIdx] == true then
            return entry.layoutName
        end
    end)

    local layoutToUse = layoutNameToUse and GW.GetLayoutByName(layoutNameToUse)
    if layoutToUse then
        GW.Debug("Spec switch detected!", "Switch to Layout ", layoutNameToUse)
    else
        local profileName = GW.globalSettings:GetCurrentProfile()

        if profileName then
            local name = L["Profiles"] .. " - " .. profileName
            local allLayouts = GW.GetAllLayouts()
            if allLayouts[name] and allLayouts[name].profileLayout == true then
                layoutToUse = allLayouts[name]
            end

            if not layoutToUse then
                self.profileLayoutRetries = self.profileLayoutRetries + 1
                if self.profileLayoutRetries <= PROFILE_LAYOUT_RETRIES then
                    self.profileLayoutRetryPending = true
                    C_Timer.After(1, function() specSwitchHandlerOnEvent(self, event) end)
                end
                return
            end

            GW.Debug("Spec switch detected!", "No assinged layout found! Switch to profile layout with name:", layoutToUse.name)
        else
            GW.Debug("Spec switch detected!", "No assinged layout found! No profile Layout found! Do nothing!")
        end
    end

    if layoutToUse and (GW.private.Layouts.currentSelected ~= layoutToUse.name or event == "PLAYER_ENTERING_WORLD") then
        UpdateFramePositionForLayout(layoutToUse, self.layoutManager, true, event == "PLAYER_ENTERING_WORLD")
    end

    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent(event)
    end
end

local function GetSpecializations()
    local specs = {}
    local endIdx
    if GW.Retail or GW.Mists then
        endIdx = GetNumSpecializations()
    else
        endIdx = GetNumTalentGroups(false, false) > 1 and 2 or 1
    end

    for index = 1, endIdx do
        local id, name, _, icon, role = C_SpecializationInfo.GetSpecializationInfo(index)
        if id then
            local iconMarkup = icon and format("|T%s:14:14:0:0:64:64:4:60:4:60|t", icon) or ""
            local specName = name or UNKNOWN
            local roleName = role and _G[role]

            specs[#specs + 1] = {
                idx = index,
                icon = iconMarkup,
                buttonText = strtrim(iconMarkup .. " " .. specName),
                menuText = strtrim(iconMarkup .. " " .. specName .. (roleName and " |cFF888888(" .. roleName .. ")|r" or "")),
            }
        end
    end

    return specs
end

local function LoadLayoutsFrame(smallSettingsFrame, layoutManager)
    smallSettingsFrame.layoutView = CreateFrame("Frame", nil, smallSettingsFrame, "GwLayoutView")
    smallSettingsFrame.layoutView.desc:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    smallSettingsFrame.layoutView.desc:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    smallSettingsFrame.layoutView.desc:SetText(L["Assign layouts to a spec. The layout will be automatically changed on a spec switch.\n\nLayouts has always priority for profile settings."])

    smallSettingsFrame.layoutView.savedLayoutDropDown.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small)
    smallSettingsFrame.layoutView.savedLayoutDropDown.title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    smallSettingsFrame.layoutView.savedLayoutDropDown.title:SetText(L["Layouts"])

    smallSettingsFrame.layoutView.specsDropDown.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small)
    smallSettingsFrame.layoutView.specsDropDown.title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    smallSettingsFrame.layoutView.specsDropDown.title:SetText(SPECIALIZATION)

    --create or get profile layout
    C_Timer.After(3, function()
        CreateProfileLayouts()
        smallSettingsFrame.layoutView.savedLayoutDropDown:GenerateMenu()
        if not smallSettingsFrame.layoutView.savedLayoutDropDown.setByUpdateFramePositionForLayout then
            -- get the current profile layout
            local allLayouts = GW.GetAllLayouts()
            local currentProfileName = GW.globalSettings:GetCurrentProfile()

            local name = L["Profiles"] .. " - " .. (currentProfileName or "")
            if allLayouts[name] then
                GW.private.Layouts.currentSelected = allLayouts[name].name
                smallSettingsFrame.layoutView.savedLayoutDropDown:GenerateMenu()
                UpdateFramePositionForLayout(GW.GetLayoutByName(GW.private.Layouts.currentSelected))

                GwSmallSettingsContainer.layoutView.delete:Disable()
                GwSmallSettingsContainer.layoutView.rename:Disable()
            end
        end
    end)

    --load layout dropdown
    local layoutsScrollFrame = smallSettingsFrame.layoutView.savedLayoutDropDown
    layoutsScrollFrame:SetWidth(125)
    layoutsScrollFrame:GwHandleDropDownBox(nil, nil, 125)
    layoutsScrollFrame:SetDefaultText("No Layout selected")

    local function IsLayoutSelected(layoutName)
        return GW.private.Layouts.currentSelected == layoutName
    end

    local function SetLayoutSelected(layoutName)
        GW.private.Layouts.currentSelected = layoutName

        RefreshSpecsDropdown()
        -- prevent profile layouts from deletion
        local layout = GW.GetLayoutByName(layoutName)
        local canEdit = not IsLayoutLocked(layout)
        GwSmallSettingsContainer.layoutView.delete:SetEnabled(canEdit)
        GwSmallSettingsContainer.layoutView.rename:SetEnabled(canEdit)

        -- load layout
        UpdateFramePositionForLayout(layout)
    end

    layoutsScrollFrame:SetupMenu(function(dropdown, rootDescription)
        local buttonSize = 20
		local maxButtons = 7
		rootDescription:SetScrollMode(buttonSize * maxButtons)

        local savedLayouts = GW.GetAllLayouts()
        local layouts = {}

        for key, layout in pairs(savedLayouts) do
            if layout then
                layouts[#layouts + 1] = {name = layout.name or key, isProfileLayout = layout.profileLayout == true}
            end
        end

        table.sort(layouts, function(a, b)
            if a.isProfileLayout ~= b.isProfileLayout then
                return a.isProfileLayout
            end
            return a.name < b.name
        end)

        for _, layout in ipairs(layouts) do
            local radio = rootDescription:CreateRadio(layout.name, IsLayoutSelected, SetLayoutSelected, layout.name)
            radio:AddInitializer(function(button, description, menu)
                GW.BlizzardDropdownRadioButtonInitializer(button, description, menu, IsLayoutSelected, layout.name)
            end)
        end
	end)

    --load spec dropdown
    local specScrollFrame = smallSettingsFrame.layoutView.specsDropDown
    specScrollFrame:SetDefaultText(L["<Assign specializations>"])
    specScrollFrame:SetWidth(150)
    specScrollFrame:GwHandleDropDownBox(nil, nil, 150)

    local function IsSpecSelected(specIdx)
        local currentLayout = GW.private.Layouts.currentSelected
        local privateLayoutSettings = currentLayout and GW.GetPrivateLayoutByLayoutName(currentLayout)
        return (privateLayoutSettings and privateLayoutSettings.assignedSpecs and privateLayoutSettings.assignedSpecs[specIdx]) or false
    end

    local function SetSpecSelected(specIdx)
        local currentLayout = GW.private.Layouts.currentSelected
        if not currentLayout then return end

        AssignLayoutToSpec(specIdx, currentLayout, not IsSpecSelected(specIdx))
    end

    specScrollFrame:SetSelectionText(function()
        local assigned = {}
        for _, data in ipairs(GetSpecializations()) do
            if IsSpecSelected(data.idx) then
                assigned[#assigned + 1] = data
            end
        end

        if #assigned == 0 then
            return L["<Assign specializations>"]
        end
        local specs = {}
        for _, data in ipairs(assigned) do
            specs[#specs + 1] = data.buttonText
        end
        return table.concat(specs, ", ")
    end)

    specScrollFrame:SetupMenu(function(drowpdown, rootDescription)
        for _, data in pairs(GetSpecializations()) do
            local check = rootDescription:CreateCheckbox(data.menuText, IsSpecSelected, SetSpecSelected, data.idx)
            check:AddInitializer(function(button, description, menu)
                GW.BlizzardDropdownCheckButtonInitializer(button, description, menu, IsSpecSelected, data.idx)
            end)
        end
    end)

    -- new, delete layout
    smallSettingsFrame.layoutView.new:SetScript("OnClick", CreateNewLayout)
    smallSettingsFrame.layoutView.delete:SetScript("OnClick", DeleteSelectedLayout)
    smallSettingsFrame.layoutView.delete:GwSkinNegativeButton()
    smallSettingsFrame.layoutView.rename:SetScript("OnClick", RenameSelectedLayout)

    -- specswitch detaction things
    local specSwitchHandler = CreateFrame("Frame")
    specSwitchHandler.currentSpecIdx = C_SpecializationInfo.GetSpecialization() -- sometimes PLAYER_SPECIALIZATION_CHANGED fired twice, so we prevent a double call

    specSwitchHandler:RegisterEvent("PLAYER_ENTERING_WORLD") -- for start up
    if GW.Retail then
        specSwitchHandler:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    else
        -- dual spec: wrath and mists have it themselves, classic through LibDualSpec
        specSwitchHandler:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    end

    specSwitchHandler:SetScript("OnEvent", specSwitchHandlerOnEvent)
    specSwitchHandler.layoutManager = layoutManager
    specSwitchHandler.smallSettingsFrame = smallSettingsFrame
end
GW.LoadLayoutsFrame = LoadLayoutsFrame
