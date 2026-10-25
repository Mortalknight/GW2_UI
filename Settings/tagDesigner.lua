---@class GW2
local GW = select(2, ...)
local L = GW.L

-- the text designer, a row in the settings: blocks from the list on the left are dragged into the lines of a frame,
-- the lines are saved right away. A caller passes its target: {lines = {{key, label}}, get(line), set(line, blocks)},
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
GW.TAG_DESIGNER_HEIGHT = HEIGHT

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

local Refresh, UpdateLines, UpdateOptions

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
    local y = 0
    for _, zone in ipairs(designer.zones) do
        zone:ClearAllPoints()
        zone:SetPoint("TOPLEFT", designer.right, "TOPLEFT", 0, y - 16)
        zone:SetPoint("RIGHT", designer.right, "RIGHT")
        UpdateZone(designer, zone)
        y = y - 16 - zone:GetHeight() - 10
    end
    designer.preview:ClearAllPoints()
    designer.preview:SetPoint("TOPLEFT", designer.right, "TOPLEFT", 0, y - 6)

    for _, line in ipairs(designer.target.lines) do
        designer.preview.texts[line.key]:SetText(GW.BuildTagPreview(lines[line.key]))
    end
end

Refresh = function(designer)
    UpdateLines(designer)
    UpdateOptions(designer)
end

-- reads the lines again each time the row shows, the profile may have changed in between
local function Load(designer)
    designer.selected = nil
    for _, line in ipairs(designer.target.lines) do
        designer.lines[line.key] = CopyTable(designer.target.get(line.key))
    end
    Refresh(designer)
end

-- creation ------------------------------------------------------------------------------------------------------------

local function CreatePalette(designer)
    local frame = designer.frame
    local scrollBox = CreateFrame("Frame", nil, frame, "WowScrollBox")
    scrollBox:SetPoint("TOPLEFT", 0, -TOP)
    scrollBox:SetPoint("BOTTOMLEFT")
    scrollBox:SetWidth(PALETTE_WIDTH)
    local scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
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
    options:SetHeight(140)

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

    -- the checkboxes of a block, two at most; UpdateOptions gives them their key
    options.checks = {}
    for index = 1, 2 do
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
    end)
end

-- builds the designer into frame, a row of the settings; hint is the text in front of the reset button
function GW.CreateTagDesigner(frame, target, hint)
    local designer = {frame = frame, target = target, lines = {}, zones = {}}
    tinsert(designers, designer)

    local reset = CreateFrame("Button", nil, frame, "GwStandardButton")
    reset:SetSize(140, 22)
    reset:SetPoint("TOPRIGHT")
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

    CreatePalette(designer)

    designer.right = CreateFrame("Frame", nil, frame)
    designer.right:SetPoint("TOPLEFT", PALETTE_WIDTH + PALETTE_GAP + PADDING, -TOP - PADDING)
    designer.right:SetPoint("BOTTOMRIGHT", -PADDING, PADDING)
    -- starts right of the scroll bar and below the reset button, it fades out by the middle of the right side
    local background = GW.CreateDetailsBackgroundTexture(frame)
    background:SetPoint("TOPLEFT", designer.right, -PADDING - 4, PADDING + 6)
    background:SetSize((RIGHT_WIDTH + 2 * PADDING + 4) / 1.3, ((target.height or HEIGHT) - TOP + 6) / 1.3)

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

    frame:HookScript("OnShow", function() Load(designer) end)
    frame:HookScript("OnHide", function()
        if drag and drag.designer == designer then
            drag = nil
            ghost:Hide()
        end
    end)
end
