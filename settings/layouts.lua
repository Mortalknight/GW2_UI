local _, GW = ...
local L = GW.L

local function UpdateMatchingLayout(self, new_point)
    local selectedLayoutName = GW.private.Layouts.currentSelected
    local layout = selectedLayoutName and GW.GetLayoutByName(selectedLayoutName) or nil
    local frameFound = false
    if layout then
        for i = 0, #layout.frames do
            if layout.frames[i] and layout.frames[i].settingName == self.setting then
                layout.frames[i].point = nil
                layout.frames[i].point = GW.copyTable(nil, new_point)

                frameFound = true
                break
            end
        end

        -- could be a new moveable frame which is not at the layout settings, so we need to add it here
        if not frameFound then
            local newIdx = #layout.frames + 1
            layout.frames[newIdx] = {}
            layout.frames[newIdx].settingName = self.setting
            layout.frames[newIdx].point = GW.copyTable(nil, new_point)
        end
    end
end
GW.UpdateMatchingLayout = UpdateMatchingLayout

local function UpdateFramePositionForLayout(layout, layoutManager, updateDropdown, startUp)
    if updateDropdown then
        GW.private.Layouts.currentSelected = layout.name
        GwSmallSettingsContainer.layoutView.savedLayoutDropDown:GenerateMenu()
        GwSmallSettingsContainer.layoutView.specsDropDown:GenerateMenu()

        GwSmallSettingsContainer.layoutView.savedLayoutDropDown.setByUpdateFramePositionForLayout = true

        GwSmallSettingsContainer.layoutView.delete:SetEnabled(not layout.profileLayout)
        GwSmallSettingsContainer.layoutView.rename:SetEnabled(not layout.profileLayout)
    end

    for k, _ in pairs(layout.frames) do
        local frame = layout.frames[k]
        if frame and frame.settingName and _G["Gw_" .. frame.settingName] and frame.point and frame.point.point and frame.point.relativePoint and frame.point.xOfs and frame.point.yOfs then
            _G["Gw_" .. frame.settingName]:ClearAllPoints()
            _G["Gw_" .. frame.settingName]:SetPoint(frame.point.point, UIParent, frame.point.relativePoint, frame.point.xOfs, frame.point.yOfs)
            if not startUp then
                _G["Gw_" .. frame.settingName]:GetScript("OnDragStop")(_G["Gw_" .. frame.settingName])
            end
        end
    end

    if layoutManager then
        layoutManager:GetScript("OnEvent")(layoutManager)
    end
end

local function AssignLayoutToSpec(specId, layoutName, toSet)
    local allPrivateLayouts = GW.GetAllPrivateLayouts()
    local privateLayoutSettings = GW.GetPrivateLayoutByLayoutName(layoutName)
    -- check if that check has already a layout assigned
    if toSet and privateLayoutSettings then
        for j = 0, #allPrivateLayouts do
            if allPrivateLayouts[j] and allPrivateLayouts[j].layoutName ~= privateLayoutSettings.layoutName then
                if allPrivateLayouts[j].assignedSpecs[specId] then
                    GW.Notice(L["Spec is already assigned to a layout!"])
                    GwSmallSettingsContainer.layoutView.specsDropDown:GenerateMenu()
                    return
                end
            end
        end
    end


    if not privateLayoutSettings then
        local newIdx = #GW.GetAllPrivateLayouts() + 1
        GW.private.Layouts[newIdx] = {}
        GW.private.Layouts[newIdx].assignedSpecs = {}
        privateLayoutSettings = GW.private.Layouts[newIdx]
    end

    privateLayoutSettings.layoutName = layoutName
    privateLayoutSettings.assignedSpecs[specId] = toSet
end

local function CreateProfileLayout()
    local savedLayouts = GW.GetAllLayouts()
    local profileName = GW.globalSettings:GetCurrentProfile()
    local name = L["Profiles"] .. " - " .. profileName
    local needToCreate = true

    if profileName then
        if savedLayouts[name] and savedLayouts[name].profileLayout == true and savedLayouts[name].profileName == profileName then
            needToCreate = false
        end
    end

    if needToCreate and profileName then
        local newMoverFrameIndex = 0
        GW.global.layouts[name] = {}
        GW.global.layouts[name].name = L["Profiles"] .. " - " .. profileName
        GW.global.layouts[name].frames = {}
        GW.global.layouts[name].profileLayout = true
        GW.global.layouts[name].profileName = profileName
        for _, moveableFrame in pairs(GW.MOVABLE_FRAMES) do
            GW.global.layouts[name].frames[newMoverFrameIndex] = {}
            GW.global.layouts[name].frames[newMoverFrameIndex].settingName = moveableFrame.setting
            GW.global.layouts[name].frames[newMoverFrameIndex].point = moveableFrame.savedPoint

            newMoverFrameIndex = newMoverFrameIndex + 1
        end
    end
end
GW.CreateProfileLayout = CreateProfileLayout

local function CreateNewLayout(self)
    GW.InputPrompt(
        L["New layout name:"],
        function()
            if GwWarningPrompt.input:GetText() == nil then return end
            local newName = GwWarningPrompt.input:GetText()
            local savedLayouts = GW.GetAllLayouts()
            if savedLayouts[newName] then
                GW.Notice("Layout with that name already exists")
                GW.WarningPrompt("Layout with that name already exists")
                return
            end
            local newMoverFrameIndex = 0
            GW.global.layouts[newName] = {}
            GW.global.layouts[newName].name = newName
            GW.global.layouts[newName].frames = {}
            GW.global.layouts[newName].profileLayout = false
            for _, moveableFrame in pairs(GW.MOVABLE_FRAMES) do
                GW.global.layouts[newName].frames[newMoverFrameIndex] = {}
                GW.global.layouts[newName].frames[newMoverFrameIndex].settingName = moveableFrame.setting
                GW.global.layouts[newName].frames[newMoverFrameIndex].point = moveableFrame.savedPoint

                newMoverFrameIndex = newMoverFrameIndex + 1
            end
            self:GetParent().savedLayoutDropDown:GenerateMenu()
            GwWarningPrompt:Hide()
        end
    )
end

local function DeleteSelectedLayout(self)
    GW.WarningPrompt(
        L["Are you sure you want to delete the selected layout?"],
        function()
            GW.global.layouts[GW.private.Layouts.currentSelected] = nil
            --also delete the assing settings
            GW.DeletePrivateLayoutByLayoutName(GW.private.Layouts.currentSelected)
            self:GetParent().savedLayoutDropDown:GenerateMenu()

            GwWarningPrompt:Hide()
        end
    )
end

local function RenameSelectedLayout(self)
    GW.InputPrompt(
        L["Rename layout:"],
        function()
            if GwWarningPrompt.input:GetText() == nil then return end
            local layoutName = GwWarningPrompt.input:GetText() or UNKNOWN
            if GW.global.layouts[layoutName] then
                GW.Notice("Layout with that name already exists")
                GW.WarningPrompt("Layout with that name already exists")
                return
            end
            GW.global.layouts[GW.private.Layouts.currentSelected].name = layoutName
            GW.global.layouts[layoutName] = GW.copyTable(nil, GW.global.layouts[GW.private.Layouts.currentSelected])
            GW.global.layouts[GW.private.Layouts.currentSelected] = nil
            GW.private.Layouts.currentSelected = layoutName
            self:GetParent().savedLayoutDropDown:GenerateMenu()

            GwWarningPrompt:Hide()
        end,
        self:GetParent().savedLayoutDropDown:GetText()
    )
end

local function specSwitchHandlerOnEvent(self, event)
    local currentSpecIdx = GetSpecialization()

    if event == "PLAYER_SPECIALIZATION_CHANGED" and self.currentSpecIdx == currentSpecIdx then
        return
    end

    local privateLayoutSettings = GW.GetAllPrivateLayouts()
    local layoutNameToUse
    local layoutToUse

    self.currentSpecIdx = currentSpecIdx

    for i = 0, #privateLayoutSettings do
        if privateLayoutSettings[i] then
            if privateLayoutSettings[i].assignedSpecs[currentSpecIdx] ~= nil and privateLayoutSettings[i].assignedSpecs[currentSpecIdx] == true then
                layoutNameToUse = privateLayoutSettings[i].layoutName
                break
            end
        end
    end

    if layoutNameToUse then
        layoutToUse = GW.GetLayoutByName(layoutNameToUse)
    end
    if layoutToUse then
        GW.Debug("Spec switch detected!", "Switch to Layout ", layoutNameToUse)
    else
        local profileName = GW.globalSettings:GetCurrentProfile()
        local allLayouts = GW.GetAllLayouts()

        if profileName then
            local name = L["Profiles"] .. " - " .. profileName
            if allLayouts[name] and allLayouts[name].profileLayout == true then
                layoutToUse = allLayouts[name]
            end

            if not layoutToUse then
                C_Timer.After(1, function() specSwitchHandlerOnEvent(self, event) end)
                return
            end

            GW.Debug("Spec switch detected!", "No assinged layout found! Switch to profile layout with name:", layoutToUse.name)
        else
            GW.Debug("Spec switch detected!", "No assinged layout found! No profile Layout found! Do nothing!")
        end
    end

    if layoutToUse and (GW.private.Layouts.currentSelected ~= layoutToUse.name or event == "PLAYER_ENTERING_WORLD") then
        UpdateFramePositionForLayout(layoutToUse, self.layoutManager, true, event == "PLAYER_ENTERING_WORLD")

        -- also do the migration here
        GW.Migration()
    end

    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent(event)
    end
end

local function LoadLayoutsFrame(smallSettingsFrame, layoutManager)
    smallSettingsFrame.layoutView = CreateFrame("Frame", nil, smallSettingsFrame, "GwLayoutView")
    smallSettingsFrame.layoutView.desc:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    smallSettingsFrame.layoutView.desc:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    smallSettingsFrame.layoutView.desc:SetText(L["Assign layouts to a spec. The layout will be automatically changed on a spec switch.\n\nLayouts has always priority for profile settings."])

    smallSettingsFrame.layoutView.savedLayoutDropDown.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.SMALL)
    smallSettingsFrame.layoutView.savedLayoutDropDown.title:SetTextColor(GW.TextColors.LIGHT_HEADER.r, GW.TextColors.LIGHT_HEADER.g, GW.TextColors.LIGHT_HEADER.b)
    smallSettingsFrame.layoutView.savedLayoutDropDown.title:SetText("Layouts")

    smallSettingsFrame.layoutView.specsDropDown.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.SMALL)
    smallSettingsFrame.layoutView.specsDropDown.title:SetTextColor(GW.TextColors.LIGHT_HEADER.r, GW.TextColors.LIGHT_HEADER.g, GW.TextColors.LIGHT_HEADER.b)
    smallSettingsFrame.layoutView.specsDropDown.title:SetText(SPECIALIZATION)

    --create or get profile layout
    C_Timer.After(3, function()
        CreateProfileLayout()
        smallSettingsFrame.layoutView.savedLayoutDropDown:GenerateMenu()
        if not smallSettingsFrame.layoutView.savedLayoutDropDown.setByUpdateFramePositionForLayout then
            -- get the current profile layout
            local allLayouts = GW.GetAllLayouts()
            local currentProfileName = GW.globalSettings:GetCurrentProfile()

            local name = L["Profiles"] .. " - " .. currentProfileName
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
    layoutsScrollFrame:SetupMenu(function(dropdown, rootDescription)
        local buttonSize = 20
		local maxButtons = 7
		rootDescription:SetScrollMode(buttonSize * maxButtons)

        local savedLayouts = GW.GetAllLayouts()
        local layouts = {}
        local tableIndex = 1

        for k, _ in pairs(savedLayouts) do
            if savedLayouts[k] then
                layouts[tableIndex] = {}
                layouts[tableIndex].name = savedLayouts[k].name
                layouts[tableIndex].isProfileLayout = savedLayouts[k].profileLayout
                tableIndex = tableIndex + 1
            end
        end

        table.sort(layouts, function(a, b)
            if a.isProfileLayout ~= b.isProfileLayout then
                return a.isProfileLayout
            elseif a.name and b.name then
                return a.name < b.name
            else
                return a.name < b.name
            end
        end)

        for k, _ in pairs(layouts) do
            local function IsSelected(layoutName)
                return GW.private.Layouts.currentSelected == layoutName
            end

            local function SetSelected(layoutName)
                GW.private.Layouts.currentSelected = layoutName

                smallSettingsFrame.layoutView.specsDropDown:GenerateMenu()
                -- prevent profile layouts from deletion
                if layouts[k].name and GW.global.layouts[layouts[k].name] and GW.global.layouts[layouts[k].name].profileLayout then
                    GwSmallSettingsContainer.layoutView.delete:Disable()
                    GwSmallSettingsContainer.layoutView.rename:Disable()
                else
                    GwSmallSettingsContainer.layoutView.delete:Enable()
                    GwSmallSettingsContainer.layoutView.rename:Enable()
                end

                -- load layout
                UpdateFramePositionForLayout(GW.GetLayoutByName(layouts[k].name))
            end

            local radio = rootDescription:CreateRadio(layouts[k].name, IsSelected, SetSelected, layouts[k].name)
            radio:AddInitializer(GW.BlizzardDropdownRadioButtonInitializer)
        end
	end)

    --load spec dropdown
    local specScrollFrame = smallSettingsFrame.layoutView.specsDropDown
    specScrollFrame:SetDefaultText(L["<Assign specializations>"])
    specScrollFrame:OverrideText(L["<Assign specializations>"])
    specScrollFrame:SetWidth(150)
    specScrollFrame:GwHandleDropDownBox(nil, nil, 150)
    specScrollFrame:SetupMenu(function(drowpdown, rootDescription)
        local privateLayoutSettings = GW.GetAllPrivateLayouts()
        local specs = {}
        for index = 1, GetNumSpecializations() do
            local id, name, _, icon, role = GetSpecializationInfo(index)
            if id then
                specs[index] = {}
                specs[index].name = format("|T%s:14:14:0:0:64:64:4:60:4:60|t %s |cFF888888(%s)|r", icon, name, getglobal(role))
                specs[index].id = id
                specs[index].idx = index
            end
        end

        for _, data in pairs(specs) do
            local function IsSelected(specIdx)
                local privateLayoutToUse = nil
                for j = 0, #privateLayoutSettings do
                    if privateLayoutSettings[j] and privateLayoutSettings[j].layoutName == GW.private.Layouts.currentSelected then
                        privateLayoutToUse = privateLayoutSettings[j]
                        break
                    end
                end

                if privateLayoutToUse then
                    return privateLayoutToUse.assignedSpecs[specIdx]
                else
                    return false
                end
            end

            local function SetSelected(specIdx)
                local isSelected = true

                for j = 0, #privateLayoutSettings do
                    if privateLayoutSettings[j] and privateLayoutSettings[j].layoutName == GW.private.Layouts.currentSelected then
                        isSelected = not privateLayoutSettings[j].assignedSpecs[specIdx]
                        break
                    end
                end
                AssignLayoutToSpec(specIdx, GW.private.Layouts.currentSelected, isSelected)
            end

            local check = rootDescription:CreateCheckbox(data.name, IsSelected, SetSelected, data.idx)
            check:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)
        end
    end)

    -- new, delete layout
    smallSettingsFrame.layoutView.new:SetScript("OnClick", CreateNewLayout)
    smallSettingsFrame.layoutView.delete:SetScript("OnClick", DeleteSelectedLayout)
    smallSettingsFrame.layoutView.rename:SetScript("OnClick", RenameSelectedLayout)

    -- specswitch detaction things
    local specSwitchHandler = CreateFrame("Frame")
    specSwitchHandler.currentSpecIdx = GetSpecialization() -- sometimes PLAYER_SPECIALIZATION_CHANGED fired twice, so we prevent a double call

    specSwitchHandler:RegisterEvent("PLAYER_ENTERING_WORLD") -- for start up
    specSwitchHandler:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    specSwitchHandler:SetScript("OnEvent", specSwitchHandlerOnEvent)
    specSwitchHandler.layoutManager = layoutManager
    specSwitchHandler.smallSettingsFrame = smallSettingsFrame
end
GW.LoadLayoutsFrame = LoadLayoutsFrame