---@class GW2
local GW = select(2, ...)
local L = GW.L

-- the text designer, a row in the settings: blocks from the list on the left are dragged into the lines of a frame,
-- the lines are saved right away. A caller passes its target: {lines = {{key, label, presets}}, get(line), set(line, blocks),
-- getDefault(line)}, presets names a list of GW.TagTextPresets offered as templates above the designer;
-- player = true offers the blocks with the player's own values, createPreview(parent, lines) returns a picture of
-- the frame with a font string per line in .texts[line key] and a Refresh() that takes the current settings; without
-- it the preview looks like a grid frame; height is the height of the designer for more lines, categories =
-- {key = true} limits the block list to those categories
local CHIP_HEIGHT = 20
local CHIP_SPACING = 4
local WIDTH, HEIGHT = 550, 460
local TOP = 30 -- the row of the hint and the reset button
local PALETTE_WIDTH = 180
-- the scroll bar of the block list sits in the gap
local PALETTE_GAP = 18
-- the right side sits inset on its background
local PADDING = 8
local RIGHT_WIDTH = WIDTH - PALETTE_WIDTH - PALETTE_GAP - 2 * PADDING
-- minus the padding inside a line
local LINE_WIDTH = RIGHT_WIDTH - 12
local PREVIEW_WIDTH = 160
-- a template dropdown with the name of its line above it
local PRESET_ROW = 44
-- the options of the block with the most controls: title, description, mode, three checkboxes and the remove button
local OPTIONS_HEIGHT = 190

local CATEGORIES = {
    {key = "name", label = NAME},
    {key = "health", label = HEALTH},
    {key = "power", label = L["Power"]},
    {key = "icon", label = L["Icons"]},
    {key = "status", label = STATUS},
    {key = "color", label = COLORS},
    {key = "text", label = LOCALE_TEXT_LABEL},
}

-- create(unit) returns a frame of the same build as the real one for the text preview of a unit frame, apply(frame)
-- gives it the current settings and runs again when a setting changes; here, as the settings load before the frames
GW.UnitFrameTextPreviewBuilders = {}
function GW.SetUnitFrameTextPreviewBuilder(unit, create, apply)
    GW.UnitFrameTextPreviewBuilders[unit] = {create = create, apply = apply}
end

local ghost
local designers = {}
-- one drag at a time: {designer, key} from the list or {designer, line, index} from a line
local drag

local Refresh, UpdateLines, UpdateOptions, Height

-- the settings load before the block list
local function Blocks()
    return GW.TagTextBlocks
end

local function Save(designer, lineKey)
    designer.target.set(lineKey, CopyTable(designer.lines[lineKey]))
end

-- chips -----------------------------------------------------------------------------------------------------------

local function CreateChip(parent)
    local chip = CreateFrame("Button", nil, parent)
    chip:SetHeight(CHIP_HEIGHT)
    chip:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true, 1, 1)
    chip.backdrop:SetBackdropBorderColor(GW.Colors.SkinColors.HeaderBorder:GetRGBA())
    chip.text = chip:CreateFontString(nil, "OVERLAY")
    chip.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    chip.text:SetPoint("LEFT", 6, 0)
    chip:RegisterForDrag("LeftButton")
    chip:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    return chip
end

local function SetChipText(chip, text)
    chip.text:SetText(text)
    chip:SetWidth(math.ceil(chip.text:GetStringWidth()) + 12)
end

-- lays the chips out in rows inside the width of the parent, returns the used height
local function FlowChips(chips, parent, width, y)
    local x = 0
    for _, chip in ipairs(chips) do
        if x > 0 and x + chip:GetWidth() > width then
            x = 0
            y = y - CHIP_HEIGHT - CHIP_SPACING
        end
        chip:ClearAllPoints()
        chip:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        x = x + chip:GetWidth() + CHIP_SPACING
    end
    return y - CHIP_HEIGHT
end

-- drag and drop -----------------------------------------------------------------------------------------------------

local function FollowCursor(self)
    local x, y = GetCursorPosition()
    local scale = self:GetEffectiveScale()
    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
end

local function StartDrag(data, label)
    if not ghost then
        ghost = CreateChip(UIParent)
        ghost:SetFrameStrata("TOOLTIP")
        ghost:EnableMouse(false)
        ghost:SetScript("OnUpdate", FollowCursor)
    end
    drag = data
    SetChipText(ghost, label)
    ghost:Show()
end

-- the insert position in a line: before the first chip whose middle is right of the cursor in the cursor's row
local function DropIndex(zone)
    local x, y = GetCursorPosition()
    local scale = zone:GetEffectiveScale()
    x, y = x / scale, y / scale
    for index, chip in ipairs(zone.activeChips) do
        local left, bottom, width, height = chip:GetRect()
        if y >= bottom and y <= bottom + height and x < left + width / 2 then
            return index
        elseif y > bottom + height then
            return index
        end
    end
    return #zone.activeChips + 1
end

local function StopDrag()
    if not drag then return end
    ghost:Hide()
    local data = drag
    local designer = data.designer
    drag = nil

    local targetZone
    for _, zone in ipairs(designer.zones) do
        if zone:IsMouseOver() then
            targetZone = zone
        end
    end

    local block
    if data.line then
        block = tremove(designer.lines[data.line], data.index)
        Save(designer, data.line)
    else
        block = {k = data.key}
    end

    designer.selected = nil
    if targetZone and block then
        local blocks = designer.lines[targetZone.lineKey]
        local index = DropIndex(targetZone)
        if data.line == targetZone.lineKey and index > data.index then
            index = index - 1
        end
        index = math.min(index, #blocks + 1)
        tinsert(blocks, index, block)
        designer.selected = {line = targetZone.lineKey, index = index}
        Save(designer, targetZone.lineKey)
    end
    Refresh(designer)
end

-- lines ---------------------------------------------------------------------------------------------------------------

local function RemoveBlock(designer, lineKey, index)
    tremove(designer.lines[lineKey], index)
    designer.selected = nil
    Save(designer, lineKey)
    Refresh(designer)
end

local function LineChip_OnClick(chip, mouseButton)
    if mouseButton == "RightButton" then
        RemoveBlock(chip.designer, chip.lineKey, chip.index)
    else
        chip.designer.selected = {line = chip.lineKey, index = chip.index}
        Refresh(chip.designer)
    end
end

local function LineChip_OnDragStart(chip)
    StartDrag({designer = chip.designer, line = chip.lineKey, index = chip.index}, chip.text:GetText())
end

local function LineChip_OnEnter(chip)
    local def = Blocks()[chip.designer.lines[chip.lineKey][chip.index].k]
    GameTooltip:SetOwner(chip, "ANCHOR_TOP")
    GameTooltip:SetText(chip.text:GetText(), 1, 1, 1)
    if def then
        GameTooltip:AddLine(def.desc, nil, nil, nil, true)
    end
    GameTooltip:AddLine(L["Drag to move, right-click to remove."], nil, nil, nil, true)
    GameTooltip:Show()
end

local function ModeLabel(def, block)
    local mode = GW.GetTagTextBlockMode(def, block)
    for _, entry in ipairs(def.modes) do
        if entry[1] == mode then return entry[2] end
    end
end

-- a block in a line names its mode, two health blocks are told apart that way
local function BlockLabel(block)
    local def = Blocks()[block.k]
    if not def then
        return block.k
    elseif def.textInput and block.text and block.text ~= "" then
        return '"' .. block.text .. '"'
    elseif def.modes then
        return def.label .. ": " .. ModeLabel(def, block)
    end
    return def.label
end

local function UpdateZone(designer, zone)
    local blocks = designer.lines[zone.lineKey]
    local selected = designer.selected
    wipe(zone.activeChips)
    for index, block in ipairs(blocks) do
        local chip = zone.chips[index]
        if not chip then
            chip = CreateChip(zone)
            chip.designer = designer
            chip:SetScript("OnClick", LineChip_OnClick)
            chip:SetScript("OnDragStart", LineChip_OnDragStart)
            chip:SetScript("OnDragStop", StopDrag)
            chip:SetScript("OnEnter", LineChip_OnEnter)
            chip:SetScript("OnLeave", GameTooltip_Hide)
            zone.chips[index] = chip
        end
        chip.lineKey, chip.index = zone.lineKey, index
        SetChipText(chip, BlockLabel(block))
        local isSelected = selected and selected.line == zone.lineKey and selected.index == index
        local border = isSelected and GW.Colors.SkinColors.QuestGold or GW.Colors.SkinColors.HeaderBorder
        chip.backdrop:SetBackdropBorderColor(border:GetRGBA())
        chip:Show()
        tinsert(zone.activeChips, chip)
    end
    for index = #blocks + 1, #zone.chips do
        zone.chips[index]:Hide()
    end
    local height = -FlowChips(zone.activeChips, zone.inner, LINE_WIDTH, 0)
    zone:SetHeight(math.max(CHIP_HEIGHT, height) + 12)
    zone.empty:SetShown(#blocks == 0)
end

-- options of the selected block -------------------------------------------------------------------------------------

local function SelectedBlock(designer)
    local selected = designer.selected
    return selected and designer.lines[selected.line][selected.index]
end

-- the options stay as they are unless asked, rebuilding them would take the focus from the text field
local function ChangeSelected(designer, func, updateOptions)
    local block = SelectedBlock(designer)
    if not block then return end
    func(block)
    Save(designer, designer.selected.line)
    UpdateLines(designer)
    if updateOptions then
        UpdateOptions(designer)
    end
end

local function SetupModeDropdown(designer, def)
    designer.options.mode:SetupMenu(function(_, rootDescription)
        for _, mode in ipairs(def.modes) do
            if not mode.hidden then
                rootDescription:CreateRadio(mode[2], function()
                    local block = SelectedBlock(designer)
                    return block and GW.GetTagTextBlockMode(def, block) == mode[1]
                end, function()
                    -- a mode can hide or show a checkbox
                    ChangeSelected(designer, function(block) block.mode = mode[1] end, true)
                end)
            end
        end
    end)
end

UpdateOptions = function(designer)
    local options = designer.options
    local block = SelectedBlock(designer)
    local def = block and Blocks()[block.k]
    options.mode:Hide()
    for _, check in ipairs(options.checks) do
        check:Hide()
    end
    options.text:Hide()
    options.remove:SetShown(block ~= nil)

    if not def then
        options.title:SetText(L["Click a block in a line to change it."])
        options.desc:SetText("")
        return
    end
    options.title:SetText(def.label)
    options.desc:SetText(def.desc)

    -- every control goes below the one before, the remove button last
    local last, x = options.desc, 0
    if def.modes then
        SetupModeDropdown(designer, def)
        options.mode:Show()
        last = options.mode
    end
    local mode = GW.GetTagTextBlockMode(def, block)
    local index = 0
    for _, checkDef in ipairs(def.checks or {}) do
        if not checkDef.hidden and (not checkDef.hideInMode or checkDef.hideInMode ~= mode) then
            index = index + 1
            local check = options.checks[index]
            check.key = checkDef.key
            check.label:SetText(checkDef.label)
            check:SetChecked(block[checkDef.key] == true)
            check:ClearAllPoints()
            check:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 2 + x, -8)
            check:Show()
            last, x = check, -2
        end
    end
    if def.textInput then
        options.text.input:SetText(block.text or "")
        options.text:Show()
        last = options.text
    end
    options.remove:ClearAllPoints()
    options.remove:SetPoint("TOPLEFT", last, "BOTTOMLEFT", x, -10)
end

-- refresh -------------------------------------------------------------------------------------------------------------

UpdateLines = function(designer)
    local lines = designer.lines
    if designer.preview.Refresh then
        designer.preview:Refresh()
    end
    -- without the designer the preview sits at the top, next to the templates
    local y = 0
    if GW.global.tagDesignerExpanded then
        for _, zone in ipairs(designer.zones) do
            zone:ClearAllPoints()
            zone:SetPoint("TOPLEFT", designer.right, "TOPLEFT", 0, y - 16)
            zone:SetPoint("RIGHT", designer.right, "RIGHT")
            UpdateZone(designer, zone)
            y = y - 16 - zone:GetHeight() - 10
        end
        y = y - 6
    end
    designer.previewOffset = -y
    designer.preview:ClearAllPoints()
    designer.preview:SetPoint("TOPLEFT", designer.right, "TOPLEFT", 0, y)

    for _, line in ipairs(designer.target.lines) do
        designer.preview.texts[line.key]:SetText(GW.BuildTagPreview(lines[line.key]))
    end
    for _, dropdown in ipairs(designer.presets) do
        dropdown:GenerateMenu()
    end
    -- more blocks make the lines higher, the settings row follows
    local height = Height(designer.target, designer)
    designer.background:SetHeight((height - TOP + 6) / 1.3)
    if height ~= designer.height then
        designer.height = height
        C_Timer.After(0, GW.RefreshConditionalOptions)
    end
end

Refresh = function(designer)
    UpdateLines(designer)
    UpdateOptions(designer)
end

-- reads the lines again each time the row shows, the profile may have changed in between; the row height of the
-- settings follows the preview. A row that grows shows again, the selected block stays if it is still there
local function Load(designer)
    for _, line in ipairs(designer.target.lines) do
        designer.lines[line.key] = CopyTable(designer.target.get(line.key))
    end
    if not SelectedBlock(designer) then
        designer.selected = nil
    end
    Refresh(designer)
    C_Timer.After(0, GW.RefreshConditionalOptions)
end

-- without the designer only the templates and the preview are left; with it the lines, the preview and the options
-- below or next to it, at least the height of the target
Height = function(target, designer)
    if GW.global.tagDesignerExpanded then
        local height = target.height or HEIGHT
        if designer and designer.previewOffset then
            local preview = designer.preview
            local below = preview:GetWidth() > PREVIEW_WIDTH and preview:GetHeight() + 12 + OPTIONS_HEIGHT
                or math.max(preview:GetHeight(), OPTIONS_HEIGHT)
            height = math.max(height, TOP + 2 * PADDING + designer.previewOffset + below)
        end
        return height
    end
    local preview = designer and designer.preview:GetHeight() or 0
    return TOP + 2 * PADDING + math.max(#target.lines * PRESET_ROW, preview)
end

-- the height of the row in the settings, frame is the row once it is built
function GW.GetTagDesignerHeight(target, frame)
    return Height(target, frame and frame.tagDesigner)
end

local function ApplyLayout(designer)
    local expanded = GW.global.tagDesignerExpanded == true
    designer.advanced:SetChecked(expanded)
    designer.reset:SetShown(expanded)
    designer.palette:SetShown(expanded)
    designer.options:SetShown(expanded)
    for _, zone in ipairs(designer.zones) do
        zone:SetShown(expanded)
    end
end

-- creation ------------------------------------------------------------------------------------------------------------

local function CreatePalette(designer)
    local frame = designer.frame
    local scrollBox = CreateFrame("Frame", nil, designer.palette, "WowScrollBox")
    scrollBox:SetPoint("TOPLEFT")
    scrollBox:SetPoint("BOTTOMLEFT")
    scrollBox:SetWidth(PALETTE_WIDTH)
    local scrollBar = CreateFrame("EventFrame", nil, designer.palette, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 6, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 6, 0)

    local palette = CreateFrame("Frame", nil, scrollBox)
    palette.scrollable = true
    palette:SetWidth(PALETTE_WIDTH)

    local y = 0
    for _, category in ipairs(CATEGORIES) do
        if not designer.target.categories or designer.target.categories[category.key] then
            local header = palette:CreateFontString(nil, "OVERLAY")
            header:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
            header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
            header:SetPoint("TOPLEFT", 0, y)
            header:SetText(category.label)
            y = y - 16

            local chips = {}
            for _, key in ipairs(GW.TagTextBlockOrder) do
                local def = Blocks()[key]
                if def.category == category.key and not def.hidden and (not def.playerOnly or designer.target.player) then
                    local chip = CreateChip(palette)
                    SetChipText(chip, def.label)
                    chip:SetScript("OnDragStart", function() StartDrag({designer = designer, key = key}, def.label) end)
                    chip:SetScript("OnDragStop", StopDrag)
                    chip:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(def.label, 1, 1, 1)
                        GameTooltip:AddLine(def.desc, nil, nil, nil, true)
                        GameTooltip:AddLine(L["Drag into a line."], nil, nil, nil, true)
                        GameTooltip:Show()
                    end)
                    chip:SetScript("OnLeave", GameTooltip_Hide)
                    tinsert(chips, chip)
                end
            end
            y = FlowChips(chips, palette, PALETTE_WIDTH, y) - 10
        end
    end
    palette:SetHeight(-y)

    ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, CreateScrollBoxLinearView())
    scrollBar:SetHideIfUnscrollable(true)
    GW.SkinSlimScrollBar(scrollBar)

    -- the wheel over the list or its bar scrolls the list, at its end the settings around it
    local function OnMouseWheel(self, delta)
        if self:HasScrollableExtent() and not (delta > 0 and self:IsAtBegin() or delta < 0 and self:IsAtEnd()) then
            self:OnMouseWheel(delta)
            return
        end
        local list = frame:GetParent()
        while list and not list.ScrollInDirection do
            list = list:GetParent()
        end
        if list then
            list:OnMouseWheel(delta)
        end
    end
    scrollBox:SetScript("OnMouseWheel", OnMouseWheel)
    scrollBar:SetScript("OnMouseWheel", function(_, delta) OnMouseWheel(scrollBox, delta) end)
end

-- the templates of a line: its default first, then its list, a text that is already there not twice
local function LinePresets(designer, line)
    local list, seen = {}, {}
    local function Add(blocks, note, isDefault)
        local tagString = GW.BuildTagString(blocks)
        if seen[tagString] then return end
        seen[tagString] = true
        local label = GW.BuildTagPreview(blocks):gsub("\n", " / ")
        label = (label == "" and NONE or label) .. (note and " (" .. note .. ")" or "") .. (isDefault and " (" .. DEFAULT .. ")" or "")
        tinsert(list, {blocks = blocks, tagString = tagString, label = label, isDefault = isDefault})
    end
    if designer.target.getDefault then
        Add(designer.target.getDefault(line.key), nil, true)
    end
    for _, preset in ipairs(GW.TagTextPresets[line.presets] or {}) do
        if not preset.hidden then
            Add(preset.blocks, preset.note)
        end
    end
    return list
end

-- a dropdown per line, it shows the template the line matches or custom
local function CreatePresets(designer)
    designer.presets = {}
    for index, line in ipairs(designer.target.lines) do
        local label = designer.frame:CreateFontString(nil, "OVERLAY")
        label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        label:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        label:SetPoint("TOPLEFT", 0, -TOP - (index - 1) * PRESET_ROW)
        label:SetText(line.label)

        local presets = LinePresets(designer, line)
        local dropdown = CreateFrame("DropdownButton", nil, designer.frame, "WowStyle1DropdownTemplate")
        dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
        dropdown:GwHandleDropDownBox(nil, nil, nil, PALETTE_WIDTH)
        dropdown:SetDefaultText(CUSTOM)
        dropdown:SetupMenu(function(_, rootDescription)
            for _, preset in ipairs(presets) do
                rootDescription:CreateRadio(preset.label, function()
                    return GW.BuildTagString(designer.lines[line.key] or {}) == preset.tagString
                end, function()
                    designer.target.set(line.key, not preset.isDefault and CopyTable(preset.blocks) or nil)
                    designer.lines[line.key] = CopyTable(designer.target.get(line.key))
                    designer.selected = nil
                    Refresh(designer)
                end)
            end
        end)
        tinsert(designer.presets, dropdown)
    end
end

local function CreateZone(parent, line)
    local zone = CreateFrame("Frame", nil, parent)
    GW.AddEditBoxBackground(zone, 0)
    zone.lineKey = line.key
    zone.label = zone:CreateFontString(nil, "OVERLAY")
    zone.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    zone.label:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    zone.label:SetPoint("BOTTOMLEFT", zone, "TOPLEFT", 0, 3)
    zone.label:SetText(line.label)
    zone.inner = CreateFrame("Frame", nil, zone)
    zone.inner:SetPoint("TOPLEFT", 6, -6)
    zone.inner:SetPoint("BOTTOMRIGHT", -6, 6)
    zone.empty = zone:CreateFontString(nil, "OVERLAY")
    zone.empty:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    zone.empty:SetTextColor(GW.Colors.SkinColors.Disabled:GetRGB())
    zone.empty:SetPoint("LEFT", 8, 0)
    zone.empty:SetText(L["Drag blocks here"])
    zone.chips = {}
    zone.activeChips = {}
    return zone
end

local function CreateGridPreview(parent, lines)
    local preview = CreateFrame("Frame", nil, parent)
    preview:SetSize(PREVIEW_WIDTH, 56)
    preview:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

    -- the grid colors: the health of the made up member at 72%, a mana bar below
    local health = preview:CreateTexture(nil, "ARTWORK")
    health:SetTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar.png")
    health:SetVertexColor(GW.oUF.colors.health:GetRGB())
    health:SetPoint("TOPLEFT")
    health:SetPoint("BOTTOMLEFT", 0, 4)
    health:SetWidth(PREVIEW_WIDTH * 0.72)

    local power = preview:CreateTexture(nil, "ARTWORK")
    power:SetTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar.png")
    power:SetVertexColor(GW.oUF.colors.power.MANA:GetRGB())
    power:SetPoint("BOTTOMLEFT")
    power:SetPoint("BOTTOMRIGHT")
    power:SetHeight(4)

    -- the first line on top and the others below it, like the grids
    preview.texts = {}
    local previous
    for _, line in ipairs(lines) do
        local text = preview:CreateFontString(nil, "OVERLAY")
        text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW")
        text:SetJustifyH("LEFT")
        text:SetWordWrap(false)
        if previous then
            text:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 2, 0)
        else
            text:SetPoint("TOPLEFT", 3, -3)
        end
        text:SetPoint("RIGHT", -3, 0)
        preview.texts[line.key] = text
        previous = text
    end
    return preview
end

local function CreateOptions(designer)
    local options = CreateFrame("Frame", nil, designer.right)
    options:SetHeight(OPTIONS_HEIGHT)

    options.title = options:CreateFontString(nil, "OVERLAY")
    options.title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    options.title:SetPoint("TOPLEFT")
    options.title:SetPoint("RIGHT")
    options.title:SetJustifyH("LEFT")

    options.desc = options:CreateFontString(nil, "OVERLAY")
    options.desc:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    options.desc:SetTextColor(GW.Colors.SkinColors.Disabled:GetRGB())
    options.desc:SetPoint("TOPLEFT", options.title, "BOTTOMLEFT", 0, -4)
    options.desc:SetPoint("RIGHT")
    options.desc:SetJustifyH("LEFT")

    local width = RIGHT_WIDTH - PREVIEW_WIDTH - 12
    options.mode = CreateFrame("DropdownButton", nil, options, "WowStyle1DropdownTemplate")
    options.mode:SetPoint("TOPLEFT", options.desc, "BOTTOMLEFT", 0, -8)
    options.mode:GwHandleDropDownBox(nil, nil, nil, width)

    -- the checkboxes of a block, three at most; UpdateOptions gives them their key
    options.checks = {}
    for index = 1, 3 do
        local check = CreateFrame("CheckButton", nil, options, "UICheckButtonTemplate")
        check:SetSize(16, 16)
        check:GwSkinCheckButton()
        check.label = check:CreateFontString(nil, "OVERLAY")
        check.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        check.label:SetPoint("LEFT", check, "RIGHT", 6, 0)
        check:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            ChangeSelected(designer, function(block) block[self.key] = checked end)
        end)
        options.checks[index] = check
    end

    options.text = CreateFrame("Frame", nil, options, "GwStandardInputField")
    options.text:SetPoint("TOPLEFT", options.desc, "BOTTOMLEFT", 0, -8)
    options.text:SetWidth(width)
    GW.SkinEditBox(options.text.input)
    options.text.input:SetMaxLetters(10)
    options.text.input:SetScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        local text = self:GetText()
        ChangeSelected(designer, function(block) block.text = text end)
    end)
    options.text.input:SetScript("OnEnterPressed", EditBox_ClearFocus)
    options.text.input:SetScript("OnEscapePressed", EditBox_ClearFocus)

    options.remove = CreateFrame("Button", nil, options, "GwStandardButton")
    options.remove:SetSize(100, 22)
    options.remove:SetText(REMOVE)
    options.remove:SetScript("OnClick", function()
        local selected = designer.selected
        if selected then RemoveBlock(designer, selected.line, selected.index) end
    end)
    return options
end

-- a setting changed the look of a frame, the shown previews follow on the next frame; a slider changes many times
local refreshPending
function GW.RefreshTagDesignerPreviews()
    if refreshPending then return end
    refreshPending = true
    C_Timer.After(0, function()
        refreshPending = nil
        for _, designer in ipairs(designers) do
            if designer.frame:IsVisible() then
                UpdateLines(designer)
            end
        end
        GW.RefreshConditionalOptions()
    end)
end

-- builds the designer into frame, a row of the settings; hint is the text in front of the reset button
function GW.CreateTagDesigner(frame, target, hint)
    local designer = {frame = frame, target = target, lines = {}, zones = {}}
    tinsert(designers, designer)
    frame.tagDesigner = designer

    -- one switch for every designer, new users start with the templates only
    local advancedLabel = frame:CreateFontString(nil, "OVERLAY")
    advancedLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    advancedLabel:SetPoint("RIGHT", frame, "TOPRIGHT", 0, -11)
    advancedLabel:SetText(ADVANCED_LABEL)
    designer.advanced = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    designer.advanced:SetSize(16, 16)
    designer.advanced:GwSkinCheckButton()
    designer.advanced:SetPoint("RIGHT", advancedLabel, "LEFT", -6, 0)
    designer.advanced:SetScript("OnClick", function(self)
        GW.global.tagDesignerExpanded = self:GetChecked() or nil
        for _, other in ipairs(designers) do
            ApplyLayout(other)
            if other.frame:IsVisible() then
                UpdateLines(other)
            end
        end
        GW.RefreshConditionalOptions()
    end)

    local reset = CreateFrame("Button", nil, frame, "GwStandardButton")
    designer.reset = reset
    reset:SetSize(140, 22)
    reset:SetPoint("RIGHT", designer.advanced, "LEFT", -12, 0)
    reset:SetText(RESET_TO_DEFAULT)
    reset:SetScript("OnClick", function()
        for _, line in ipairs(target.lines) do
            target.set(line.key, nil)
        end
        Load(designer)
    end)

    local hintText = frame:CreateFontString(nil, "OVERLAY")
    hintText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    hintText:SetTextColor(GW.Colors.SkinColors.Disabled:GetRGB())
    hintText:SetPoint("LEFT", frame, "TOPLEFT", 0, -11)
    hintText:SetPoint("RIGHT", reset, "LEFT", -10, 0)
    hintText:SetJustifyH("LEFT")
    hintText:SetText(hint)

    CreatePresets(designer)
    designer.palette = CreateFrame("Frame", nil, frame)
    designer.palette:SetPoint("TOPLEFT", 0, -TOP - #target.lines * PRESET_ROW - 6)
    designer.palette:SetPoint("BOTTOMLEFT")
    designer.palette:SetWidth(PALETTE_WIDTH + PALETTE_GAP)
    CreatePalette(designer)

    designer.right = CreateFrame("Frame", nil, frame)
    designer.right:SetPoint("TOPLEFT", PALETTE_WIDTH + PALETTE_GAP + PADDING, -TOP - PADDING)
    designer.right:SetPoint("BOTTOMRIGHT", -PADDING, PADDING)
    -- starts right of the scroll bar and below the reset button, it fades out by the middle of the right side
    designer.background = GW.CreateDetailsBackgroundTexture(frame)
    designer.background:SetPoint("TOPLEFT", designer.right, -PADDING - 4, PADDING + 6)
    designer.background:SetWidth((RIGHT_WIDTH + 2 * PADDING + 4) / 1.3)

    for index, line in ipairs(target.lines) do
        designer.zones[index] = CreateZone(designer.right, line)
    end

    designer.preview = (target.createPreview or CreateGridPreview)(designer.right, target.lines)

    -- the options go next to a small preview, below a wide one
    designer.options = CreateOptions(designer)
    if designer.preview:GetWidth() > PREVIEW_WIDTH then
        designer.options:SetPoint("TOPLEFT", designer.preview, "BOTTOMLEFT", 0, -12)
    else
        designer.options:SetPoint("TOPLEFT", designer.preview, "TOPRIGHT", 12, 0)
    end
    designer.options:SetPoint("RIGHT", designer.right, "RIGHT")

    -- the tag strings the lines turn into, an escaped pipe shown as one and a color code as its text; a tag string
    -- has no spaces to wrap at, so every tag gets its own row
    designer.preview:EnableMouse(true)
    designer.preview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:ClearLines()
        for _, line in ipairs(target.lines) do
            GameTooltip:AddLine(line.label, GW.Colors.TextColors.LightHeader:GetRGB())
            local tagString = GW.BuildTagString(designer.lines[line.key]):gsub("||", "|"):gsub("|", "||"):gsub("%](.)", "]\n%1")
            GameTooltip:AddLine(tagString, 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    designer.preview:SetScript("OnLeave", GameTooltip_Hide)

    ApplyLayout(designer)
    frame:HookScript("OnShow", function() Load(designer) end)
    frame:HookScript("OnHide", function()
        if drag and drag.designer == designer then
            drag = nil
            ghost:Hide()
        end
    end)
end
