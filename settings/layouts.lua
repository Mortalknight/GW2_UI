local _, GW = ...
local L = GW.L

local function AssignLayoutToSpec(specwin, button, specId, layoutId)
    local allLayouts = GW.GetAllLayouts()
    local allPrivateLayouts = GW.GetAllPrivateLayouts()
    local toSet = not button.checkbutton:GetChecked()
    local privateLayoutSettings = GW.GetPrivateLayoutByLayoutId(layoutId)
    -- check if that check has already a layout assigned
    if toSet and privateLayoutSettings then
        for j = 0, #allPrivateLayouts do
            if allPrivateLayouts[j] and allPrivateLayouts[j].layoutId ~= privateLayoutSettings.layoutId then
                if allPrivateLayouts[j].assignedSpecs[specId] then
                    DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["Spec is already assigned to a layout!"]):gsub("*", GW.Gw2Color))
                    return
                end
            end
        end
    end

    button.checkbutton:SetChecked(toSet)

    if not privateLayoutSettings then
        local newIdx = #privateLayoutSettings + 1
        GW2UI_PRIVATE_LAYOUTS[newIdx] = {}
        GW2UI_PRIVATE_LAYOUTS[newIdx].assignedSpecs = {}
        privateLayoutSettings = GW2UI_PRIVATE_LAYOUTS[newIdx]
    end

    privateLayoutSettings.layoutName = allLayouts[layoutId].name
    privateLayoutSettings.layoutId = layoutId
    privateLayoutSettings.assignedSpecs[specId] = toSet

    if specwin.scrollContainer:IsShown() then
        specwin.scrollContainer:Hide()
    else
        specwin.scrollContainer:Show()
    end

end

local function loadSpecDropDown(specwin)
    local USED_DROPDOWN_HEIGHT

    local privateLayoutSettings = GW.GetAllPrivateLayouts()
    local privateLayoutToUse
    local offset = HybridScrollFrame_GetOffset(specwin)
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

    for i = 1, #specwin.buttons do
        local slot = specwin.buttons[i]

        local idx = i + offset
        if idx > #specs then
            -- empty row (blank starter row, final row, and any empty entries)
            slot:Hide()
            slot.specIdx = nil
        else
            privateLayoutToUse = nil
            slot.specIdx = specs[idx].idx

            slot.checkbutton:Show()
            slot.soundButton:Hide()

            slot.string:SetText(specs[idx].name)

            -- set the correct spec values
            for j = 0, #privateLayoutSettings do
                if privateLayoutSettings[j] and privateLayoutSettings[j].layoutId == specwin:GetParent():GetParent().savedLayoutDropDown.container.contentScroll.displayButton.selectedId then
                    privateLayoutToUse = privateLayoutSettings[j]
                    break
                end
            end
            if privateLayoutToUse then
                slot.checkbutton:SetChecked(privateLayoutToUse.assignedSpecs[slot.specIdx])
            else
                slot.checkbutton:SetChecked(false)
            end

            slot:Show()
        end
    end

    USED_DROPDOWN_HEIGHT = 20 * #specs
    HybridScrollFrame_Update(specwin, USED_DROPDOWN_HEIGHT, 120)
end

local function SetupSpecs(specwin)
    HybridScrollFrame_CreateButtons(specwin, "GwDropDownItemTmpl", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #specwin.buttons do
        local slot = specwin.buttons[i]
        slot:SetWidth(specwin:GetWidth())
        slot.string:SetFont(UNIT_NAME_FONT, 10)
        slot.hover:SetAlpha(0.5)
        if not slot.ScriptsHooked then
            slot:HookScript("OnClick", function(self)
                AssignLayoutToSpec(specwin, self, self.specIdx, specwin:GetParent():GetParent().savedLayoutDropDown.container.contentScroll.displayButton.selectedId)
            end)
            slot.checkbutton:HookScript("OnClick", function(self)
                AssignLayoutToSpec(specwin, self:GetParent(), self:GetParent().specIdx, specwin:GetParent():GetParent().savedLayoutDropDown.container.contentScroll.displayButton.selectedId)
            end)
            slot:HookScript("OnEnter", function()
                slot.hover:Show()
            end)
            slot.checkbutton:HookScript("OnEnter", function()
                slot.hover:Show()
            end)
            slot:HookScript("OnLeave", function()
                slot.hover:Hide()
            end)
            slot.checkbutton:HookScript("OnLeave", function()
                slot.hover:Hide()
            end)

            slot.ScriptsHooked = true
        end
    end

    loadSpecDropDown(specwin)
end

local function loadLayoutDropDown(layoutwin)
    local USED_DROPDOWN_HEIGHT

    local offset = HybridScrollFrame_GetOffset(layoutwin)
    local savedLayouts = GW.GetAllLayouts()
    local layouts = {}
    local tableIndex = 1

    layouts[1] = {}
    layouts[1].name = L["<Select a Layout>"]
    layouts[1].id = -1

    for k, _ in pairs(savedLayouts) do
        if savedLayouts[k] then
            tableIndex = tableIndex + 1
            layouts[tableIndex] = {}
            layouts[tableIndex].name = savedLayouts[k].name
            layouts[tableIndex].id = k
        end
    end


    for i = 1, #layoutwin.buttons do
        local slot = layoutwin.buttons[i]

        local idx = i + offset
        if idx > #layouts then
            -- empty row (blank starter row, final row, and any empty entries)
            slot:Hide()
            slot.id = nil
            slot.name = nil
        else
            slot.id = layouts[idx].id
            slot.name = layouts[idx].name

            slot.checkbutton:Hide()
            slot.string:ClearAllPoints()
            slot.string:SetPoint("LEFT", 5, 0)
            slot.soundButton:Hide()

            slot.string:SetText(slot.name)

            slot:Show()
        end
    end

    USED_DROPDOWN_HEIGHT = 20 * #layouts
    HybridScrollFrame_Update(layoutwin, USED_DROPDOWN_HEIGHT, 120)
end

local function SetupLayouts(layoutwin)
    HybridScrollFrame_CreateButtons(layoutwin, "GwDropDownItemTmpl", 0, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #layoutwin.buttons do
        local slot = layoutwin.buttons[i]
        slot:SetWidth(layoutwin:GetWidth())
        slot.string:SetFont(UNIT_NAME_FONT, 10)
        slot.hover:SetAlpha(0.5)
        if not slot.ScriptsHooked then
            slot:HookScript("OnClick", function(self)
                layoutwin.displayButton.string:SetText(self.name)
                layoutwin.displayButton.layoutName = self.name
                layoutwin.displayButton.selectedId = self.id

                if layoutwin.scrollContainer:IsShown() then
                    layoutwin.scrollContainer:Hide()
                else
                    layoutwin.scrollContainer:Show()
                end
                loadSpecDropDown(layoutwin:GetParent():GetParent().specsDropDown.container.contentScroll)
            end)
            slot:HookScript("OnEnter", function()
                slot.hover:Show()
            end)
            slot.checkbutton:HookScript("OnEnter", function()
                slot.hover:Show()
            end)
            slot:HookScript("OnLeave", function()
                slot.hover:Hide()
            end)

            slot.ScriptsHooked = true
        end
    end

    loadLayoutDropDown(layoutwin)
end

local function CreateProfileLayout()
    local savedLayouts = GW.GetAllLayouts()
    local profileIndex = GW.GetActiveProfile()
    local needToCreate = true

    if profileIndex then
        for i = 0, #savedLayouts do
            if savedLayouts[i] then
                if savedLayouts[i].name == L["Profiles"] .. " - " .. GW2UI_SETTINGS_PROFILES[profileIndex].profilename then
                    needToCreate = false
                    break
                end
            end
        end
    end

    if needToCreate and profileIndex then
        local newIdx = #savedLayouts + 1
        GW2UI_LAYOUTS[newIdx] = {}
        GW2UI_LAYOUTS[newIdx].name = L["Profiles"] .. " - " .. GW2UI_SETTINGS_PROFILES[profileIndex].profilename
        GW2UI_LAYOUTS[newIdx].frames = {}
        for _, moveableFrame in pairs(GW.MOVABLE_FRAMES) do
            GW2UI_LAYOUTS[newIdx].frames[#GW2UI_LAYOUTS[newIdx].frames + 1] = moveableFrame
        end
    end
end

local function CreateNewLayout(self)
    GW.InputPrompt(
        L["New layout name:"],
        function()
            local savedLayouts = GW.GetAllLayouts()
            local newIdx = #savedLayouts + 1
            GW2UI_LAYOUTS[newIdx] = {}
            GW2UI_LAYOUTS[newIdx].name = (GwWarningPrompt.input:GetText() or UNKNOWN)
            GW2UI_LAYOUTS[newIdx].frames = {}
            GW2UI_LAYOUTS[newIdx].id = newIdx
            for _, moveableFrame in pairs(GW.MOVABLE_FRAMES) do
                GW2UI_LAYOUTS[newIdx].frames[#GW2UI_LAYOUTS[newIdx].frames + 1] = moveableFrame
            end
            loadLayoutDropDown(self:GetParent().savedLayoutDropDown.container.contentScroll)

            GwWarningPrompt:Hide()
        end
    )
end

local function DeleteSelectedLayout(self)
    GW.WarningPrompt(
        L["Are you sure you want to delete the selected layout?"],
        function()
            GW2UI_LAYOUTS[self:GetParent().savedLayoutDropDown.container.contentScroll.displayButton.selectedId] = nil
            --also delete the assing settings
            GW.DeletePrivateLayoutByLayoutId(self:GetParent().savedLayoutDropDown.container.contentScroll.displayButton.selectedId)
            loadLayoutDropDown(self:GetParent().savedLayoutDropDown.container.contentScroll)

            self:GetParent().savedLayoutDropDown.button.string:SetText(L["<Select a Layout>"])
            self:GetParent().savedLayoutDropDown.container.contentScroll.displayButton.selectedId = nil

            GwWarningPrompt:Hide()
        end
    )
end

local function LoadLayoutsFrame(smallSettingsFrame)
    smallSettingsFrame.layoutView = CreateFrame("Frame", nil, smallSettingsFrame, "GwLayoutView")
    smallSettingsFrame.layoutView.headerString:SetFont(UNIT_NAME_FONT, 14)
    smallSettingsFrame.layoutView.desc:SetFont(UNIT_NAME_FONT, 12)
    smallSettingsFrame.layoutView.desc:SetText(L["Assign layouts to a spec. The layout will be automatically changed on a spec switch.\n\nLayouts has always priority for profile settings."])
    smallSettingsFrame.layoutView.isExpanded = false
    smallSettingsFrame.layoutViewToggle:SetScript("OnClick", function()
        if smallSettingsFrame.layoutView.isExpanded then
            smallSettingsFrame.layoutViewToggle.icon:SetTexCoord(1, 0, 1, 0)
            smallSettingsFrame.layoutView.isExpanded = false
            smallSettingsFrame.layoutView:Hide()
        else
            smallSettingsFrame.layoutViewToggle.icon:SetTexCoord(0, 1, 0, 1)
            smallSettingsFrame.layoutView.isExpanded = true
            smallSettingsFrame.layoutView:Show()
        end
    end)

    smallSettingsFrame.layoutView.savedLayoutDropDown.title:SetFont(DAMAGE_TEXT_FONT, 12)
    smallSettingsFrame.layoutView.savedLayoutDropDown.title:SetText("Layouts")

    smallSettingsFrame.layoutView.specsDropDown.title:SetFont(DAMAGE_TEXT_FONT, 12)
    smallSettingsFrame.layoutView.specsDropDown.title:SetText(SPECIALIZATION)

    smallSettingsFrame.layoutView.savedLayoutDropDown.button.string:SetText(L["<Select a Layout>"])
    smallSettingsFrame.layoutView.specsDropDown.button.string:SetText(L["<Select specializations>"])

    --create or get profile layout
    C_Timer.After(1, function()
        CreateProfileLayout()
        loadLayoutDropDown(smallSettingsFrame.layoutView.savedLayoutDropDown.container.contentScroll)
    end)

    --load layout dropdown
    local layoutsScrollFrame = smallSettingsFrame.layoutView.savedLayoutDropDown.container.contentScroll
    layoutsScrollFrame.scrollBar.thumbTexture:SetSize(12, 30)
    layoutsScrollFrame.scrollBar:ClearAllPoints()
    layoutsScrollFrame.scrollBar:SetPoint("TOPRIGHT", -3, -12)
    layoutsScrollFrame.scrollBar:SetPoint("BOTTOMRIGHT", -3, 12)
    layoutsScrollFrame.scrollBar.scrollUp:SetPoint("TOPRIGHT", 0, 12)
    layoutsScrollFrame.scrollBar.scrollDown:SetPoint("BOTTOMRIGHT", 0, -12)
    layoutsScrollFrame.scrollBar:SetFrameLevel(layoutsScrollFrame:GetFrameLevel() + 5)
    layoutsScrollFrame.displayButton = smallSettingsFrame.layoutView.savedLayoutDropDown.button
    layoutsScrollFrame.scrollContainer = smallSettingsFrame.layoutView.savedLayoutDropDown.container
    layoutsScrollFrame:GetParent():SetParent(smallSettingsFrame.layoutView)

    layoutsScrollFrame.update = loadLayoutDropDown
    layoutsScrollFrame.scrollBar.doNotHide = false
    SetupLayouts(layoutsScrollFrame)

    smallSettingsFrame.layoutView.savedLayoutDropDown.button:SetScript("OnClick", function(self)
        local dd = self:GetParent()
        if dd.container:IsShown() then
            dd.container:Hide()
        else
            dd.container:Show()
        end
    end)

    --load spec dropdown
    local specScrollFrame = smallSettingsFrame.layoutView.specsDropDown.container.contentScroll
    specScrollFrame.scrollBar.thumbTexture:SetSize(12, 30)
    specScrollFrame.scrollBar:ClearAllPoints()
    specScrollFrame.scrollBar:SetPoint("TOPRIGHT", -3, -12)
    specScrollFrame.scrollBar:SetPoint("BOTTOMRIGHT", -3, 12)
    specScrollFrame.scrollBar.scrollUp:SetPoint("TOPRIGHT", 0, 12)
    specScrollFrame.scrollBar.scrollDown:SetPoint("BOTTOMRIGHT", 0, -12)
    specScrollFrame.scrollBar:SetFrameLevel(specScrollFrame:GetFrameLevel() + 5)
    specScrollFrame.displayButton = smallSettingsFrame.layoutView.specsDropDown.button
    specScrollFrame.scrollContainer = smallSettingsFrame.layoutView.specsDropDown.container
    specScrollFrame:GetParent():SetParent(smallSettingsFrame.layoutView)

    specScrollFrame.update = loadSpecDropDown
    specScrollFrame.scrollBar.doNotHide = false
    SetupSpecs(specScrollFrame)

    smallSettingsFrame.layoutView.specsDropDown.button:SetScript("OnClick", function(self)
        if smallSettingsFrame.layoutView.savedLayoutDropDown.button.string:GetText() == L["<Select a Layout>"] then return end
        local dd = self:GetParent()
        if dd.container:IsShown() then
            dd.container:Hide()
        else
            dd.container:Show()
        end
    end)

    -- new, delete layout
    smallSettingsFrame.layoutView.new:SetScript("OnClick", CreateNewLayout)
    smallSettingsFrame.layoutView.delete:SetScript("OnClick", DeleteSelectedLayout)

    --GW2UI_PRIVATE_LAYOUTS= nil
end
GW.LoadLayoutsFrame = LoadLayoutsFrame