---@class GW2
local GW = select(2, ...)

local menuItems = {}
local menuItemSelectionBehavior
local settingsWindowFrame
local settingsMenuFrame
local currentPanelIndex
local searchPanel
local searchEdit
local DEFAULT_SETTINGS_PANEL_ID = "interface_features"

local ROW_PAD_X = 8
local ROW_PAD_Y = 8
local COL_GAP   = 8
local CONTENT_W = 550
local DEFAULT_ROW_EXTENT = 40
local MASTER_TOGGLE_SEPARATOR_EXTENT = 5
local GROUP_GAP_EXTENT = 12 -- empty spacer row between different option groups (proximity grouping)
local SEARCH_HIGHLIGHT_ALPHA = 0.08

local MENU_MAIN_ROW_HEIGHT = 32
local MENU_SUB_ROW_HEIGHT = 26
local MENU_MAIN_FONT_SIZE = 14
local MENU_SUB_FONT_SIZE = 12

local SEARCH_ACTIVE = false


-- Globale Registry
GW.SettingsWidgetRegistry = GW.SettingsWidgetRegistry or {
    list = {},
    byPanel = setmetatable({}, {__mode = "k"}),
    panelCounter = 0,
    byOptionName = {},
}

local optionTypes = {
    boolean     = {template = "GwOptionBoxTmpl", frame = "Button", newLine = false},
    slider      = {template = "GwOptionBoxSliderTmpl", frame = "Button", newLine = true},
    dropdown    = {template = "GwOptionBoxDropDownTmpl", frame = "Button", newLine = true},
    list        = {template = "GwOptionBoxListTmpl", frame = "Button", newLine = true},
    spellList   = {template = "GwOptionBoxSpellListTmpl", frame = "Button", newLine = true},
    spellInput  = {template = "GwOptionBoxSpellInputTmpl", frame = "Button", newLine = true},
    text        = {template = "GwOptionBoxTextTmpl", frame = "Button", newLine = true},
    button      = {template = "GwButtonTextTmpl", frame = "Button", newLine = false},
    colorPicker = {template = "GwOptionBoxColorPickerTmpl", frame = "Button", newLine = true},
    header      = {template = "GwOptionBoxHeader", frame = "Frame", newLine = true},
    subHeader   = {template = "GwOptionBoxSubHeader", frame = "Frame", newLine = true},
    note        = {template = "GwOptionBoxNote", frame = "Frame", newLine = true},
}

GwSettingsWindowSettingsTabMixin = {}

-- =========================
-- Utils
-- =========================
local function Norm(s)
    if not s or s == "" then return "" end
    s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r","")
    s = s:lower():gsub("ä","ae"):gsub("ö","oe"):gsub("ü","ue"):gsub("ß","ss")
    return s
end

local function ResolveForceNewLine(opt)
    local conf = optionTypes[opt.optionType] or {}
    local fnl = (opt.forceNewLine ~= nil) and opt.forceNewLine or (conf.newLine == true)
    if opt.optionType == "dropdown" and opt.noNewLine ~= nil then
        fnl = not opt.noNewLine
    end
    return fnl and true or false
end

local function IsMasterToggle(opt)
    return opt and opt.isMasterToggle == true
end

local function NeedsFullRowWidth(opt)
    local conf = optionTypes[opt.optionType] or {}
    if opt.optionType == "dropdown" and opt.noNewLine then
        return false
    end
    return conf.newLine == true
end

local function GetOptionRowExtent(opt)
    if opt and opt.optionType == "note" then
        -- height follows the wrapped text; the FontString has a fixed width from the
        -- template, so it can be measured before the row gets anchored. Callers pass
        -- either the option or the widget itself (the search view does the latter).
        local widget = opt.__widget or opt
        local textHeight = widget.title and widget.title.GetStringHeight and widget.title:GetStringHeight() or 0
        return math.max(DEFAULT_ROW_EXTENT, ROW_PAD_Y * 2 + math.ceil(textHeight) + 8)
    end

    if opt and opt.optionType == "list" then
        local optionsList = type(opt.optionsList) == "table" and opt.optionsList or {}
        local entryCount = math.max(#optionsList, 1)
        local entryHeight = opt.entryHeight or 24
        local maxVisibleRows = tonumber(opt.maxVisibleRows)

        if maxVisibleRows and maxVisibleRows > 0 then
            entryCount = math.min(entryCount, maxVisibleRows)
        end

        return math.max(DEFAULT_ROW_EXTENT, ROW_PAD_Y * 2 + (entryCount * entryHeight))
    end

    if opt and opt.optionType == "spellList" then
        -- entry count is dynamic (user managed) — reserve a fixed window of
        -- maxVisibleRows entries plus the input row, overflow scrolls inside
        local entryHeight = opt.entryHeight or 24
        local visibleRows = tonumber(opt.maxVisibleRows) or 5

        return math.max(DEFAULT_ROW_EXTENT, ROW_PAD_Y * 2 + 30 + (visibleRows * entryHeight))
    end

    return DEFAULT_ROW_EXTENT
end

local function GetPackedRowExtent(row)
    if row and row.kind == "masterToggleSeparator" then
        return MASTER_TOGGLE_SEPARATOR_EXTENT
    end
    if row and row.kind == "groupGap" then
        return GROUP_GAP_EXTENT
    end

    local extent = DEFAULT_ROW_EXTENT
    for _, opt in ipairs((row and row.cols) or {}) do
        extent = math.max(extent, GetOptionRowExtent(opt))
    end

    return extent
end

local function StashWidget(w, panel)
    if not w then return end
    if not panel._stash then
        panel._stash = CreateFrame("Frame", nil, panel)
        panel._stash:Hide()
    end
    w:Hide()
    w:ClearAllPoints()
    w:SetParent(panel._stash)
end

local function AnchorLeftHalf(row, w)
    local half = floor((CONTENT_W - COL_GAP) / 2)
    w:ClearAllPoints()
    w:SetParent(row)
    w:SetPoint("TOPLEFT", ROW_PAD_X, -ROW_PAD_Y)
    w:SetPoint("BOTTOMLEFT", ROW_PAD_X, ROW_PAD_Y)
    w:SetWidth(half)
    w:Show()
end

local function AnchorRightHalf(row, w)
    local half = floor((CONTENT_W - COL_GAP) / 2)
    local startX = ROW_PAD_X + half + COL_GAP
    w:ClearAllPoints()
    w:SetParent(row)
    w:SetPoint("TOPLEFT", startX, -ROW_PAD_Y)
    w:SetPoint("BOTTOMLEFT", startX, ROW_PAD_Y)
    w:SetWidth(half)
    w:Show()
end

local function AnchorFullWidth(row, w)
    w:ClearAllPoints()
    w:SetParent(row)
    w:SetPoint("TOPLEFT", ROW_PAD_X, -ROW_PAD_Y)
    w:SetPoint("BOTTOMLEFT", ROW_PAD_X, ROW_PAD_Y)
    w:SetWidth(CONTENT_W)
    w:Show()
end

local function SetRowSearchHighlightShown(row, show)
    if show then
        if not row.searchHighlight then
            row.searchHighlight = row:CreateTexture(nil, "BACKGROUND")
            row.searchHighlight:SetColorTexture(GW.Colors.TextColors.LightHeader:GetRGB())
        end

        row.searchHighlight:SetAlpha(SEARCH_HIGHLIGHT_ALPHA)
        row.searchHighlight:ClearAllPoints()
        row.searchHighlight:SetPoint("TOPLEFT", ROW_PAD_X, -4)
        row.searchHighlight:SetPoint("BOTTOMRIGHT", row, "BOTTOMLEFT", ROW_PAD_X + CONTENT_W, 4)
        row.searchHighlight:Show()
    elseif row.searchHighlight then
        row.searchHighlight:Hide()
    end
end

local function SetRowMasterToggleSeparatorShown(row, show)
    if show then
        if not row.masterToggleSeparator then
            row.masterToggleSeparator = row:CreateTexture(nil, "ARTWORK")
            row.masterToggleSeparator:SetTexture("Interface/AddOns/GW2_UI/textures/hud/levelreward-sep.png")
            row.masterToggleSeparator:SetTexCoord(0.5, 1, 0, 1)
            row.masterToggleSeparator:SetSize(floor(CONTENT_W / 2), 2)
        end

        row.masterToggleSeparator:ClearAllPoints()
        row.masterToggleSeparator:SetPoint("TOPLEFT", ROW_PAD_X, 5)
        row.masterToggleSeparator:Show()
    elseif row.masterToggleSeparator then
        row.masterToggleSeparator:Hide()
    end
end

local function UpdateMasterToggleStyle(of, hovered)
    if not of or not of.isMasterToggle then return end

    local checked = of.checkbutton and of.checkbutton:GetChecked()
    local r, g, b = GW.Colors.TextColors.LightHeader:GetRGB()

    if of.masterToggleBg then
        local textWidth = of.title:GetStringWidth()
        of.masterToggleBg:SetWidth(math.max(80, math.min(textWidth + 22, of:GetWidth() - 36)))
        of.masterToggleBg:SetColorTexture(r, g, b, hovered and 0.16 or (checked and 0.08 or 0))
    end

    of.masterToggleAccent:SetColorTexture(r, g, b, checked and 0.75 or (hovered and 0.35 or 0))
end

local function SetupMasterToggleStyle(of)
    if not of or not of.isMasterToggle or of.masterToggleStyleHooked then return end

    of.masterToggleStyleHooked = true
    of.masterToggleBg = of:CreateTexture(nil, "BACKGROUND")
    of.masterToggleBg:SetPoint("LEFT", of.title, "LEFT", -9, 0)
    of.masterToggleBg:SetHeight(24)

    of.masterToggleAccent = of:CreateTexture(nil, "ARTWORK")
    of.masterToggleAccent:SetPoint("TOPLEFT", -2, -3)
    of.masterToggleAccent:SetPoint("BOTTOMLEFT", -2, 3)
    of.masterToggleAccent:SetWidth(2)

    of:HookScript("OnEnter", function(self)
        UpdateMasterToggleStyle(self, true)
    end)
    of:HookScript("OnLeave", function(self)
        UpdateMasterToggleStyle(self, false)
    end)
    of:HookScript("OnClick", function(self)
        UpdateMasterToggleStyle(self, self:IsMouseOver())
    end)

    if of.checkbutton then
        of.checkbutton:HookScript("OnEnter", function()
            UpdateMasterToggleStyle(of, true)
        end)
        of.checkbutton:HookScript("OnLeave", function()
            UpdateMasterToggleStyle(of, false)
        end)
        of.checkbutton:HookScript("OnClick", function()
            UpdateMasterToggleStyle(of, of:IsMouseOver())
        end)
        hooksecurefunc(of.checkbutton, "SetChecked", function()
            UpdateMasterToggleStyle(of, of:IsMouseOver())
        end)
    end

    UpdateMasterToggleStyle(of)
end

-- =========================
-- Registry + Search
-- =========================
local function CaptureWidgetAnchors(frame)
    if not frame then return nil end
    local info = { parent = frame:GetParent(), points = {}, size = { frame:GetSize() }, strata = frame:GetFrameStrata(), level = frame:GetFrameLevel() }
    for i = 1, frame:GetNumPoints() do
        local p, rel, rp, x, y = frame:GetPoint(i)
        info.points[i] = { p, rel, rp, x, y }
    end
    return info
end

local function GetOrderedPanelBuckets()
    local R, out = GW.SettingsWidgetRegistry, {}
    for _, bucket in pairs(R.byPanel) do out[#out+1] = bucket end
    table.sort(out, function(a,b) return a.panelIndex < b.panelIndex end)
    return out
end

local function RegisterOptionWidget(widget, meta)
    if not widget or widget.__gwRegEntry then return widget and widget.__gwRegEntry end

    local panel = meta and (meta.panel or meta.parentPanel) or widget:GetParent()
    local header = panel and panel.header and panel.header.GetText and panel.header:GetText() or ""

    local bucket = GW.SettingsWidgetRegistry.byPanel[panel]
    if not bucket then
        GW.SettingsWidgetRegistry.panelCounter = GW.SettingsWidgetRegistry.panelCounter + 1
        bucket = { entries = {}, panelIndex = GW.SettingsWidgetRegistry.panelCounter, header = header, panel = panel }
        GW.SettingsWidgetRegistry.byPanel[panel] = bucket
    end

    local title = meta and meta.title or widget.displayName

    local entry = {
        widget      = widget,
        panel       = panel,
        panelIndex  = bucket.panelIndex,
        panelHeader = bucket.header,
        panelBreadcrumb = panel.breadcrumb and panel.breadcrumb:GetText() or "",
        title      = title,
        titleNorm  = Norm(title),
        path       = meta and meta.path or widget.settingsPath,
        pathNorm   = Norm(widget.settingsPath or ""),
        groupHeaderNorm = Norm(widget.groupHeaderName or ""),
        isNew      = title and title:find(GW.NewSign, 1, true) ~= nil,
        type       = meta and meta.type or widget.optionType,
        optionName = meta and meta.key  or widget.optionName,
        desc       = meta and meta.desc or widget.desc,
        descNorm   = Norm(meta and meta.desc or widget.desc or ""),
        anchors    = CaptureWidgetAnchors(widget),
    }

    widget.__gwRegEntry = entry
    table.insert(GW.SettingsWidgetRegistry.list, entry)
    table.insert(bucket.entries, entry)
    entry.widgetIndex = #bucket.entries

    if entry.optionName then
        local idx = GW.SettingsWidgetRegistry.byOptionName[entry.optionName]
        if not idx then
            idx = {}
            GW.SettingsWidgetRegistry.byOptionName[entry.optionName] = idx
        end
        table.insert(idx, entry)
    end

    return entry
end

local function SearchWidgetsByText(query)
   local q = Norm(query)
    if q == "" then return {}, {} end

    local groups = {}
    local buckets = GetOrderedPanelBuckets()
    local searchNew = q == NEW:lower() or q == "!"

    for _, bucket in ipairs(buckets) do
        local hits = {}
        for _, e in ipairs(bucket.entries) do
            if searchNew then
                if e.isNew then
                    hits[#hits+1] = e
                end
            elseif e.titleNorm:find(q, 1, true) or e.groupHeaderNorm:find(q, 1, true) or e.descNorm:find(q, 1, true) then
                hits[#hits+1] = e
            end
        end
        if #hits > 0 then
            groups[#groups+1] = { panel = bucket.panel, header = bucket.header, entries = hits, panelIndex = bucket.panelIndex }
        end
    end

    local flat = {}
    for _, g in ipairs(groups) do
        for i, e in ipairs(g.entries) do
            e.groupHeader = (i == 1) and g.header or nil
            flat[#flat+1] = e
        end
    end

    return flat, groups
end

local function BorrowEntryToSearch(entry, token)
    entry._borrowed = token
    if entry.widget then entry.widget.__gwBorrowed = token end
end
local function ReleaseEntryFromSearch(entry, token)
    if entry._borrowed == token then entry._borrowed = nil end
    if entry.widget and entry.widget.__gwBorrowed == token then entry.widget.__gwBorrowed = nil end
end
local function IsBorrowed(widget)
    return widget and widget.__gwBorrowed ~= nil
end

-- =========================
-- Panels / Options
-- =========================
local function CreateOrGetOptionWidget(panel, opt)
    if opt.__widget then
        return opt.__widget
    end
    local conf = optionTypes[opt.optionType]
    if not conf then return nil end

    local of = CreateFrame(conf.frame, nil, panel, conf.template)
    of:Hide()

    of.displayName = opt.name
    for k, val in pairs(opt) do of[k] = val end
    of.forceNewLine = ResolveForceNewLine(opt)

    -- Basistitle (falls vorhanden im Template)
    of.title:SetFont(DAMAGE_TEXT_FONT, 12)
    of.title:SetShadowColor(0, 0, 0, 1)
    of.title:SetText(of.displayName or "")
    if of.isMasterToggle then
        of.title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    else
        of.title:SetTextColor(1, 1, 1)
    end
    -- Deine vorhandene Typ-spezifische Logik hier hinein:
    GW.SettingsInitOptionWidget(of, opt, panel)
    SetupMasterToggleStyle(of)

    -- subtle hover feedback on every interactive row (master toggles have their own)
    if not of.isMasterToggle and opt.optionType ~= "header" and opt.optionType ~= "subHeader" and opt.optionType ~= "note" then
        local hover = of:CreateTexture(nil, "BACKGROUND")
        hover:SetColorTexture(GW.Colors.TextColors.LightHeader:GetRGB())
        hover:SetAlpha(0)
        hover:SetAllPoints(of)
        of:HookScript("OnEnter", function() hover:SetAlpha(0.05) end)
        of:HookScript("OnLeave", function() hover:SetAlpha(0) end)
    end

    opt.__widget = of

    RegisterOptionWidget(of, { panel=panel, title=of.displayName, path=of.settingsPath, type=of.optionType, key=of.optionName, desc=of.desc })

    return of
end

-- group key used for the visual proximity grouping: a header starts the group that
-- carries its name, options belong to the group named by their group/groupHeaderName.
-- "group" exists for options that belong together but should not carry a header.
local function GetGroupKey(opt)
    if opt.optionType == "header" or opt.optionType == "subHeader" then
        return Norm(opt.name or "")
    end
    return Norm(opt.group or opt.groupHeaderName or "")
end

-- An empty key means "not specified", NOT "a group of its own" — several panels set
-- groupHeaderName on only some options of a section, and treating the gaps as their own
-- group tore those sections apart. Unspecified options join whatever surrounds them.
local function SameGroup(a, b)
    local ka, kb = GetGroupKey(a), GetGroupKey(b)
    return ka == kb or ka == "" or kb == ""
end

-- Options may carry an isVisible predicate (notes that only apply in a certain state).
-- Unlike "hidden", which is evaluated once at creation, this is re-checked on every
-- rebuild — see RefreshConditionalOptions.
local function IsOptionVisible(opt)
    if not opt.isVisible then return true end
    local ok, visible = pcall(opt.isVisible)
    if not ok then return true end -- a broken predicate must not swallow the option
    return visible == true
end

local function PackOptionsIntoRows(allOptions)
    local options = {}
    for _, opt in ipairs(allOptions) do
        if IsOptionVisible(opt) then
            options[#options + 1] = opt
        end
    end

    local rows, i = {}, 1
    local lastGroupKey

    local function AddMasterToggleSeparatorIfNeeded(lastIndex)
        if IsMasterToggle(options[lastIndex]) and options[lastIndex + 1] and not IsMasterToggle(options[lastIndex + 1]) then
            rows[#rows+1] = { kind = "masterToggleSeparator" }
        end
    end

    -- spacer between two rows whose group differs — proximity does the grouping
    -- without needing a visible header. Skipped right after a header/separator row,
    -- those already separate visually.
    local function AddGroupGapIfNeeded(opt)
        local groupKey = GetGroupKey(opt)
        local wantsGap = opt.startsGroup == true

        if groupKey ~= "" then
            wantsGap = wantsGap or (lastGroupKey ~= nil and groupKey ~= lastGroupKey)
            lastGroupKey = groupKey -- an unspecified key must not reset the current group
        end

        if not wantsGap then return end

        local lastRow = rows[#rows]
        if not (lastRow and lastRow.cols) then return end

        local lastOpt = lastRow.cols[1]
        if lastOpt and lastOpt.optionType ~= "header" and lastOpt.optionType ~= "subHeader" then
            rows[#rows+1] = { kind = "groupGap" }
        end
    end

    while i <= #options do
        local a = options[i]; if not a then break end
        AddGroupGapIfNeeded(a)
        if ResolveForceNewLine(a) then
            rows[#rows+1] = { cols = {a} }
            AddMasterToggleSeparatorIfNeeded(i)
            i = i + 1
        else
            local b = options[i + 1]
            if b and not ResolveForceNewLine(b) and IsMasterToggle(a) == IsMasterToggle(b)
                and SameGroup(a, b) and not b.startsGroup then
                rows[#rows+1] = { cols = {a, b} }
                AddMasterToggleSeparatorIfNeeded(i + 1)
                i = i + 2
            else
                rows[#rows+1] = { cols = {a} }
                AddMasterToggleSeparatorIfNeeded(i)
                i = i + 1
            end
        end
    end
    return rows
end

local function HasConditionalOptions(panel)
    for _, opt in ipairs((panel and panel.gwOptions) or {}) do
        if opt.isVisible then return true end
    end
    return false
end

local function VisibilitySignature(panel)
    local parts = {}
    for _, opt in ipairs((panel and panel.gwOptions) or {}) do
        if opt.isVisible then
            parts[#parts + 1] = IsOptionVisible(opt) and "1" or "0"
        end
    end
    return table.concat(parts)
end

local function BuildOptionsDataProvider(panel)
    local options = (panel and panel.gwOptions) or {}
    local rows = PackOptionsIntoRows(options)

    for _, row in ipairs(rows) do
        for k=1,2 do
            local opt = row.cols and row.cols[k]
            if opt then CreateOrGetOptionWidget(panel, opt) end
        end
    end

    local dp = CreateDataProvider()
    for i, row in ipairs(rows) do
        dp:Insert({ index = i, kind = row.kind, cols = row.cols, panel = panel })
    end
    return dp
end

local function InitRow(row, elementData)
    row.__panel = elementData.panel
    local panel = elementData.panel

    row:SetWidth(ROW_PAD_X * 2 + CONTENT_W)

    if elementData.kind == "masterToggleSeparator" or elementData.kind == "groupGap" then
        if row.leftAssigned  then StashWidget(row.leftAssigned,  panel); row.leftAssigned  = nil end
        if row.rightAssigned then StashWidget(row.rightAssigned, panel); row.rightAssigned = nil end
        SetRowMasterToggleSeparatorShown(row, elementData.kind == "masterToggleSeparator")
        return
    end
    SetRowMasterToggleSeparatorShown(row, false)

    if SEARCH_ACTIVE then
        if row.leftAssigned  then StashWidget(row.leftAssigned,  panel); row.leftAssigned  = nil end
        if row.rightAssigned then StashWidget(row.rightAssigned, panel); row.rightAssigned = nil end
        return
    end

    local leftOpt, rightOpt = elementData.cols[1], elementData.cols[2]
    local leftW  = leftOpt  and CreateOrGetOptionWidget(panel, leftOpt) or nil
    local rightW = (rightOpt and not (leftOpt and leftOpt.forceNewLine)) and CreateOrGetOptionWidget(panel, rightOpt) or nil

    if row.leftAssigned and row.leftAssigned ~= leftW then
        StashWidget(row.leftAssigned, panel); row.leftAssigned = nil
    end
    if row.rightAssigned and row.rightAssigned ~= rightW then
        StashWidget(row.rightAssigned, panel); row.rightAssigned = nil
    end

    local canAttachLeft  = leftW  and not IsBorrowed(leftW)
    local canAttachRight = rightW and not IsBorrowed(rightW)

    if canAttachLeft and canAttachRight then
        AnchorLeftHalf(row,  leftW)
        AnchorRightHalf(row, rightW)
        row.leftAssigned, row.rightAssigned = leftW, rightW
    elseif canAttachLeft then
        if NeedsFullRowWidth(leftW) then
            AnchorFullWidth(row, leftW)
        else
            AnchorLeftHalf(row, leftW)
        end
        row.leftAssigned, row.rightAssigned = leftW, nil
    else
        if row.leftAssigned  then StashWidget(row.leftAssigned,  panel); row.leftAssigned  = nil end
        if row.rightAssigned then StashWidget(row.rightAssigned, panel); row.rightAssigned = nil end
    end
end

local function InitOptionPanel(panel)
    local view = CreateScrollBoxListLinearView()
    panel._stash = panel._stash or CreateFrame("Frame", nil, panel)
    panel._stash:Hide()

    view:SetElementExtentCalculator(function(_, elementData)
        return GetPackedRowExtent(elementData)
    end)
    view:SetElementInitializer("GwFrameTemplate", InitRow)
    view:SetElementResetter(function(row)
        if row.leftAssigned  then StashWidget(row.leftAssigned,  row.__panel); row.leftAssigned  = nil end
        if row.rightAssigned then StashWidget(row.rightAssigned, row.__panel); row.rightAssigned = nil end
        SetRowMasterToggleSeparatorShown(row, false)
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(panel.scroll.ScrollBox, panel.scroll.ScrollBar, view)
    GW.HandleTrimScrollBar(panel.scroll.ScrollBar)
    GW.HandleScrollControls(panel.scroll)
    panel.scroll.ScrollBar:SetHideIfUnscrollable(true)

    panel.scroll.ScrollBox:SetDataProvider(BuildOptionsDataProvider(panel), ScrollBoxConstants.RetainScrollPosition)
    panel.gwConditionalPanel = HasConditionalOptions(panel)
    panel.gwVisibilitySignature = VisibilitySignature(panel)
end

-- Re-evaluates the isVisible predicates and rebuilds only the panels whose visible set
-- actually changed. Called from CheckDependencies, i.e. after every settings change.
local function RefreshConditionalOptions()
    for _, main in ipairs(menuItems) do
        local panels = {main.basePanel}
        if main.hasSubFrames then
            for _, sub in ipairs(main.subFrameData) do
                panels[#panels + 1] = sub.frame
            end
        end

        for _, panel in ipairs(panels) do
            if panel and panel.gwConditionalPanel and panel.scroll then
                local signature = VisibilitySignature(panel)
                if signature ~= panel.gwVisibilitySignature then
                    panel.gwVisibilitySignature = signature
                    panel.scroll.ScrollBox:SetDataProvider(BuildOptionsDataProvider(panel), ScrollBoxConstants.RetainScrollPosition)
                end
            end
        end
    end
end
GW.RefreshConditionalOptions = RefreshConditionalOptions

-- =========================
-- Menu + Panel-Switch
-- =========================
local function BuildFlatMenuData()
    local list, idx, mainOrdinal = {}, 1, 0
    for _, item in ipairs(menuItems) do
        item.isExpanded = false
        mainOrdinal = mainOrdinal + 1
        -- zebra keyed on the category order, not the flat index: collapsed sub rows
        -- keep their index, which would otherwise break the alternation visibly
        tinsert(list, { index = idx, itemData = item, isSubCat = false, parent = nil, zebra = (mainOrdinal % 2 == 1) })
        item.index = idx; idx = idx + 1

        if item.hasSubFrames then
            for _, sub in ipairs(item.subFrameData) do
                if sub == item.generalSub then
                    sub.index = item.index -- shown through the category row, no own menu entry
                else
                    tinsert(list, { index = idx, itemData = sub, isSubCat = true, parent = item })
                    sub.index = idx; idx = idx + 1
                end
            end
        end
    end
    return list
end

-- expandOverride: explicit expansion state for the category the panel belongs to
-- (used by the header toggle); without it, showing a panel expands its category
local function SwitchPanel(panelIndex, expandOverride)
    currentPanelIndex = panelIndex
    for _, main in ipairs(menuItems) do
        if main.hasSubFrames then
            main.basePanel:Hide()
            local belongsHere = false
            for _, sub in ipairs(main.subFrameData) do
                if sub.index == panelIndex then
                    sub.frame:Show()
                    main.basePanel:Show()
                    belongsHere = true
                else
                    sub.frame:Hide()
                end
            end
            if belongsHere and expandOverride ~= nil then
                main.isExpanded = expandOverride
            else
                main.isExpanded = belongsHere
            end
        else
            main.basePanel:SetShown(main.index == panelIndex)
        end
    end
    settingsMenuFrame.ScrollBox:Rebuild(ScrollBoxConstants.RetainScrollPosition)
end

local function FindMenuItemByPanelId(panelId)
    local foundItem
    settingsMenuFrame.ScrollBox:GetDataProvider():ForEach(function(ed)
        if (ed.isSubCat and ed.itemData.frame.panelId == panelId)
            or (not ed.isSubCat and ed.itemData.basePanel.panelId == panelId)
            or (not ed.isSubCat and ed.itemData.generalSub and ed.itemData.generalSub.frame.panelId == panelId) then
            foundItem = ed
            return true
        end
    end)

    return foundItem
end

local function SelectMenuItem(menuItem)
    if not menuItem then return end

    SwitchPanel(menuItem.index)
    settingsMenuFrame.ScrollBox:ScrollToElementDataByPredicate(function(ed) return ed == menuItem end)
    C_Timer.After(0, function()
        local btn = settingsMenuFrame.ScrollBox:FindFrame(menuItem)
        if btn and not menuItemSelectionBehavior:IsSelected(btn) then menuItemSelectionBehavior:Select(btn) end
    end)
end

-- =========================
-- API for adding panels
-- =========================
-- Stacked panel header: small context line (category) on top, the page name as
-- accented title below it, description underneath, hairline towards the options.
-- Runs after the panel code has set its texts/fonts, so it overrides the
-- per-panel styling in one place. Panels without a breadcrumb skip the context
-- line; their header text becomes the title.
local function LayoutPanelHeader(panel)
    local crumb = panel.breadcrumb:GetText()
    local hasCrumb = crumb and crumb ~= ""

    local title = hasCrumb and panel.breadcrumb or panel.header
    local titleY = hasCrumb and -24 or -12

    if hasCrumb then
        panel.header:SetFont(UNIT_NAME_FONT, 11, "")
        panel.header:SetTextColor(181 / 255, 160 / 255, 128 / 255)
        panel.header:SetWidth(500)
        panel.header:SetHeight(12)
        panel.header:ClearAllPoints()
        panel.header:SetPoint("TOPLEFT", 6, -9)
    end

    title:SetFont(DAMAGE_TEXT_FONT, 24, "")
    title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    title:SetWidth(500)
    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", 15, titleY)

    -- accent bar on the title, mirrors the menu selection accent
    panel.gwAccentBar = panel.gwAccentBar or panel:CreateTexture(nil, "OVERLAY")
    panel.gwAccentBar:SetColorTexture(GW.Colors.Accent:GetRGB())
    panel.gwAccentBar:SetSize(3, 18)
    panel.gwAccentBar:ClearAllPoints()
    panel.gwAccentBar:SetPoint("LEFT", title, "LEFT", -9, 0)

    panel.sub:ClearAllPoints()
    panel.sub:SetHeight(14)
    panel.sub:SetPoint("TOPLEFT", 6, titleY - 28)

    -- preview button (GwSettingsPanelPreviewTmpl) joins the title row instead of
    -- floating above the header block
    if panel.preview then
        panel.preview:ClearAllPoints()
        panel.preview:SetPoint("TOPRIGHT", -14, titleY - 2)
    end

    local lineY = titleY - 46
    panel.gwHeaderLine = panel.gwHeaderLine or panel:CreateTexture(nil, "OVERLAY")
    panel.gwHeaderLine:SetColorTexture(1, 1, 1, 0.12)
    panel.gwHeaderLine:SetHeight(1)
    panel.gwHeaderLine:ClearAllPoints()
    panel.gwHeaderLine:SetPoint("TOPLEFT", 6, lineY)
    panel.gwHeaderLine:SetPoint("TOPRIGHT", -14, lineY)

    panel.scroll:SetPoint("TOPLEFT", 0, lineY - 6)
end

function GwSettingsWindowSettingsTabMixin:AddSettingsPanel(basePanel, name, desc, subFrameData, isAddon)
    local item = {
        basePanel = basePanel,
        name = name,
        desc = desc,
        isExpanded = false,
        hasSubFrames = subFrameData and #subFrameData > 0,
        subFrameData = subFrameData,
        -- a leading "General" sub panel is folded into the category row itself:
        -- it gets no own menu entry, clicking the header shows it
        generalSub = subFrameData and subFrameData[1] and subFrameData[1].name == GENERAL and subFrameData[1] or nil,
        isAddon = isAddon,
    }
    tinsert(menuItems, item)

    -- init panel
    if subFrameData and #subFrameData > 0 then
        for _, sub in ipairs(subFrameData) do
            InitOptionPanel(sub.frame)
            if sub == item.generalSub then
                -- opened through the category row itself, so the category name is the
                -- page title - drop the redundant "General" context line
                sub.frame.breadcrumb:SetText("")
            end
            LayoutPanelHeader(sub.frame)
        end
        basePanel.header:Hide()
        basePanel.sub:Hide()
        basePanel.scroll:Hide()
    else
        InitOptionPanel(basePanel)
        LayoutPanelHeader(basePanel)
    end

    if isAddon then
        self.menu.ScrollBox:SetDataProvider(CreateDataProvider(BuildFlatMenuData()), ScrollBoxConstants.RetainScrollPosition)
        SwitchPanel(currentPanelIndex or 1)
    end
end

function GwSettingsWindowSettingsTabMixin:OpenSettingsToPanel(panelId)
    SelectMenuItem(FindMenuItemByPanelId(panelId))
    if not GwSettingsWindow:IsShown() then
        ShowUIPanel(GwSettingsWindow)
    end
    GwSettingsWindow:SwitchTab(settingsWindowFrame.name)
end
--/run GW2_ADDON.GetSettingsTabFrame():OpenSettingsToPanel("raid10")

-- With this also other addons can add panels to the settings
local function GetSettingsTabFrame()
    return settingsWindowFrame
end
GW.GetSettingsTabFrame = GetSettingsTabFrame

-- =========================
-- Search (ScrollBox)
-- =========================
local function EnsureSearchState(sp)
   if not sp._search then
        sp._search = {
            matches = {},
            touchedPanels = {},
        }
    end
    return sp._search
end

local function ResetSearchRow(row)
    if row.headerFS then row.headerFS:SetText("") end
    if row.crumbFS  then row.crumbFS:SetText("") end
    if row.leftAssigned  then row.leftAssigned:Hide();  row.leftAssigned  = nil end
    if row.rightAssigned then row.rightAssigned:Hide(); row.rightAssigned = nil end
    SetRowSearchHighlightShown(row, false)
end

local function WipeKeys(t)
    if not t then return end
    for k in pairs(t) do t[k] = nil end
end

local function BuildRowsFromEntries(entries)
    local rows, open = {}, nil
    for _, e in ipairs(entries) do
        local w = e.widget
        local full = (w and w.forceNewLine) == true
        if full then
            rows[#rows+1] = {kind="pair", left=e, right=nil}
            open = nil
        else
            if open then
                open.right = e
                open = nil
            else
                open = {kind="pair", left=e, right=nil}
                rows[#rows+1] = open
            end
        end
    end
    return rows
end

local function BuildSearchDataProvider(query)
    local dp = CreateDataProvider()
    if not query or query == "" then return dp end

    local _, groups = SearchWidgetsByText(query)

    local idx = 1
    for _, g in ipairs(groups) do
        if #g.entries > 0 then
            dp:Insert({ index = idx, kind = "breadcrumb", header = g.header or "", crumb = (g.panel and g.panel.breadcrumb and g.panel.breadcrumb:GetText()) or "" })
            idx = idx + 1
            local rows = BuildRowsFromEntries(g.entries)
            for _, r in ipairs(rows) do
                r.index = idx; r.kind = "pair"
                dp:Insert(r); idx = idx + 1
            end
        end
    end
    return dp
end

local function InitSearchRow(row, item)
    local sp = row.__searchPanel
    local state = EnsureSearchState(sp)

    row:SetWidth(ROW_PAD_X * 2 + CONTENT_W)

    if item.kind == "breadcrumb" then
        SetRowSearchHighlightShown(row, false)
        if not row.headerFS then
            row.headerFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.headerFS:SetFont(DAMAGE_TEXT_FONT, 20)
            row.headerFS:SetJustifyH("LEFT")
            row.headerFS:SetPoint("TOPLEFT", ROW_PAD_X, -ROW_PAD_Y)
            row.headerFS:SetTextColor(1,1,1)
        end
        if not row.crumbFS then
            row.crumbFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.crumbFS:SetFont(DAMAGE_TEXT_FONT, 12)
            row.crumbFS:SetJustifyH("LEFT")
            row.crumbFS:SetPoint("LEFT", row.headerFS, "RIGHT", 10, 0)
            row.crumbFS:SetTextColor(1,1,1)
        end
        row.headerFS:SetText(item.header or "")
        row.crumbFS:SetText(item.crumb  or "")
        if row.leftAssigned  then row.leftAssigned:Hide();  row.leftAssigned  = nil end
        if row.rightAssigned then row.rightAssigned:Hide(); row.rightAssigned = nil end
        return
    end
    SetRowSearchHighlightShown(row, true)

    local leftE, rightE = item.left, item.right
    local leftW  = leftE  and leftE.widget  or nil
    local rightW = rightE and rightE.widget or nil

    if row.leftAssigned and row.leftAssigned ~= leftW then
        row.leftAssigned:Hide(); row.leftAssigned:ClearAllPoints(); row.leftAssigned = nil
    end
    if row.rightAssigned and row.rightAssigned ~= rightW then
        row.rightAssigned:Hide(); row.rightAssigned:ClearAllPoints(); row.rightAssigned = nil
    end

    if leftW and rightW then
        AnchorLeftHalf(row,  leftW)
        AnchorRightHalf(row, rightW)
        row.leftAssigned, row.rightAssigned = leftW, rightW
        BorrowEntryToSearch(leftE,  sp)
        BorrowEntryToSearch(rightE, sp)
        tinsert(state.matches, leftE); tinsert(state.matches, rightE)
    elseif leftW then
        if NeedsFullRowWidth(leftW) then
            AnchorFullWidth(row, leftW)
        else
            AnchorLeftHalf(row, leftW)
        end
        row.leftAssigned, row.rightAssigned = leftW, nil
        BorrowEntryToSearch(leftE, sp)
        tinsert(state.matches, leftE)
    else
        if row.leftAssigned  then row.leftAssigned:Hide();  row.leftAssigned  = nil end
        if row.rightAssigned then row.rightAssigned:Hide(); row.rightAssigned = nil end
    end
end

local function ReturnMatchesToHome(sp, doRebuild)
    local state = EnsureSearchState(sp)
    local touched = state.touchedPanels

    if state.matches and #state.matches > 0 then
        for i = 1, #state.matches do
            local e = state.matches[i]
            local w, p = e and e.widget, e and e.panel
            if w and p then
                ReleaseEntryFromSearch(e, sp)
                StashWidget(w, p)
                touched[p] = true
            end
        end
        wipe(state.matches)
    end

    if doRebuild then
        for p in pairs(touched) do
            C_Timer.After(0, function()
                p.scroll.ScrollBox:Rebuild(ScrollBoxConstants.RetainScrollPosition)
            end)
        end
        WipeKeys(touched)
    end
end

local function HideAllPanelsForSearch()
    for _, main in ipairs(menuItems) do
        if main.hasSubFrames then
            main.basePanel:Hide()
            for _, sub in ipairs(main.subFrameData) do sub.frame:Hide() end
        end
        main.basePanel:Hide()
        main.isExpanded = false
    end
end

local function SearchClear(edit, sp)
    edit:SetText(SEARCH)
    edit:ClearFocus()
    edit:SetTextColor(178 / 255, 178 / 255, 178 / 255)
    edit:ClearFocus()
    edit.clearButton:Hide()

    SEARCH_ACTIVE = false
    ReturnMatchesToHome(sp, true)

    local empty = CreateDataProvider()
    sp.scroll.ScrollBox:SetDataProvider(empty, ScrollBoxConstants.RetainScrollPosition)
    if sp.sub then sp.sub:Show() end
    sp:Hide()

    if currentPanelIndex then
        SwitchPanel(currentPanelIndex)
        local dp = settingsMenuFrame.ScrollBox:GetDataProvider()
        local edTarget
        dp:ForEach(function(ed) if ed.index == currentPanelIndex then edTarget = ed; return true end end)
        if edTarget then
            settingsMenuFrame.ScrollBox:ScrollToElementDataByPredicate(function(ed) return ed == edTarget end, ScrollBoxConstants.AlignNearest)
            C_Timer.After(0, function()
                local btn = settingsMenuFrame.ScrollBox:FindFrame(edTarget)
                if btn and not menuItemSelectionBehavior:IsSelected(btn) then menuItemSelectionBehavior:Select(btn) end
            end)
        end
    end
end

local function CloseSearch()
    if SEARCH_ACTIVE and searchEdit and searchPanel then
        SearchClear(searchEdit, searchPanel)
    end
end

local function SearchUpdate(sp, query)
    ReturnMatchesToHome(sp, false)

    if not query or query == "" or query == SEARCH then
        local empty = CreateDataProvider()
        sp.scroll.ScrollBox:SetDataProvider(empty, ScrollBoxConstants.RetainScrollPosition)
        if sp.sub then sp.sub:Show() end
        sp:Hide()
        SEARCH_ACTIVE = false
        return
    end

    SEARCH_ACTIVE = true

    local dp = BuildSearchDataProvider(query:lower())
    sp.scroll.ScrollBox:SetDataProvider(dp, ScrollBoxConstants.RetainScrollPosition)
    if sp.sub then sp.sub:SetShown(dp:IsEmpty()) end

    HideAllPanelsForSearch()
    sp:Show()
end

-- =========================
-- Settings Tab Setup
-- =========================
-- selection accent: hover and selection share the same row texture, the red bar
-- and brighter text keep the active entry recognizable while hovering others
local function SetMenuRowActive(button, active)
    button.activeTexture:SetShown(active)
    if button.activeBar then
        button.activeBar:SetShown(active)
    end
    if active then
        button.text:SetTextColor(1, 1, 1)
    else
        button.text:SetTextColor(1, 0.9450, 0.8196)
    end
end

local function InitMenuButton(button, elementData)
    if not button.isGwInit then
        button.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
        button.limitHoverStripAmount = 1
        button.arrow:ClearAllPoints()
        button.arrow:SetPoint("LEFT", 5, 0)
        button.arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right.png")
        button.arrow:SetSize(14, 14)

        -- sub rows: uniform dark block with a guide rail instead of zebra stripes
        button.subBg = button:CreateTexture(nil, "BACKGROUND", nil, 1)
        button.subBg:SetAllPoints()
        button.subBg:SetColorTexture(0, 0, 0, 0.35)
        button.subRail = button:CreateTexture(nil, "BACKGROUND", nil, 2)
        button.subRail:SetPoint("TOPLEFT", 24, 0)
        button.subRail:SetPoint("BOTTOMLEFT", 24, 0)
        button.subRail:SetWidth(1)
        button.subRail:SetColorTexture(1, 1, 1, 0.18)

        button.activeBar = button:CreateTexture(nil, "OVERLAY")
        button.activeBar:SetPoint("TOPLEFT", 0, 0)
        button.activeBar:SetPoint("BOTTOMLEFT", 0, 0)
        button.activeBar:SetWidth(3)
        button.activeBar:SetColorTexture(GW.Colors.Accent:GetRGB())
        button.activeBar:Hide()

        button:HookScript("OnEnter", function(self)
            if self.gwTooltipDesc then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.name, GW.Colors.TextColors.LightHeader:GetRGB())
                GameTooltip:AddLine(self.gwTooltipDesc, 181 / 255, 160 / 255, 128 / 255, true)
                GameTooltip:Show()
            end
        end)
        button:HookScript("OnLeave", GameTooltip_Hide)

        button:SetScript("OnClick", function()
            CloseSearch()
            local ed = button.elementData
            if not ed.isSubCat and ed.itemData.hasSubFrames and ed.itemData.isExpanded then
                SwitchPanel(button.index, false) -- header toggle: collapse, keep its panel
            else
                SwitchPanel(button.index)
            end
            menuItemSelectionBehavior:SelectElementData(ed)
        end)
        button.isGwInit = true
    end

    if elementData.isSubCat then
        button:ClearNormalTexture()
    elseif elementData.zebra then
        button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
    else
        button:ClearNormalTexture()
    end
    button.subBg:SetShown(elementData.isSubCat)
    button.subRail:SetShown(elementData.isSubCat)

    local fontSize = elementData.isSubCat and MENU_SUB_FONT_SIZE or MENU_MAIN_FONT_SIZE
    if button.gwFontSize ~= fontSize then
        local face = button.text:GetFont()
        button.text:SetFont(face, fontSize, "")
        button.gwFontSize = fontSize
    end

    button.arrow:SetShown(elementData.itemData.hasSubFrames)
    button.text:SetPoint("LEFT", button, "LEFT", elementData.isSubCat and 36 or 22, 0)
    button.text:SetText(elementData.itemData.name)
    button.gwTooltipDesc = (not elementData.isSubCat and elementData.itemData.desc) or nil

    button.name = elementData.itemData.name
    button.itemData = elementData.itemData
    button.isSubCat = elementData.isSubCat
    button.hasSubCat = elementData.itemData.hasSubFrames
    button.elementData = elementData

    if not elementData.isSubCat and elementData.itemData.hasSubFrames and not elementData.itemData.generalSub then
        button.index = elementData.index + 1 -- no folded General panel: header selects the first sub
    else
        button.index = elementData.index
    end

    SetMenuRowActive(button, menuItemSelectionBehavior:IsSelected(button))

    local hidden = elementData.isSubCat and elementData.parent and not elementData.parent.isExpanded
    button:EnableMouse(not hidden)
    button:SetAlpha(hidden and 0 or 1)
    button:SetHeight(hidden and 0 or (elementData.isSubCat and MENU_SUB_ROW_HEIGHT or MENU_MAIN_ROW_HEIGHT))

    if not elementData.isSubCat and elementData.itemData.hasSubFrames then
        if elementData.itemData.isExpanded and not button.rotationDone then
            button.arrow:SetRotation(0)
            GW.AddToAnimation(elementData.itemData.name, 0, 1, GetTime(), 0.2, function(p) button.arrow:SetRotation(-1.5707 * p) end, "noease", function() button.rotationDone = true end)
        elseif not elementData.itemData.isExpanded and button.rotationDone then
            GW.AddToAnimation(elementData.itemData.name, 1, 0, GetTime(), 0.2, function(p) button.arrow:SetRotation(-1.5707 * p) end, "noease", function() button.rotationDone = false end)
        end
    end
end

-- =========================
-- Global Search API
-- =========================
local function FindWidgetsByOption(settingName)
    local idx = GW.SettingsWidgetRegistry.byOptionName[settingName]
    if not idx or #idx == 0 then
        return {}
    end
    return idx
end

local function FindWidgetByOption(settingName)
    local matches = FindWidgetsByOption(settingName)
    return (matches[1] and matches[1].widget) or nil
end
GW.FindSettingsWidgetByOption = FindWidgetByOption

local function GetAllSettingsWidgets()
    local out = {}
    for _, bucket in ipairs(GetOrderedPanelBuckets()) do
        for _, e in ipairs(bucket.entries) do
            out[#out + 1] = e.widget
        end
    end
    return out
end
GW.GetAllSettingsWidgets = GetAllSettingsWidgets

local function LoadSettingsTab(container)
    local settingsTab = CreateFrame("Frame", nil, container, "GwSettingsSettingsTabTemplate")
    settingsWindowFrame = settingsTab
    settingsMenuFrame = settingsTab.menu
    searchEdit = settingsTab.menu.search.input

    settingsTab.name = "GwSettingsSettings"
    settingsTab.headerBreadcrumbText = SETTINGS
    settingsTab.callbackOnClose = function()
        CloseSearch()
        GW.CloseActiveSettingsPreview()
    end
    container:AddTab("Interface/AddOns/GW2_UI/textures/uistuff/tabicon_settings.png", settingsTab)

    --load settings panels
    GW.LoadInterfaceFeaturesPanel(settingsTab)
    GW.LoadGeneralPanel(settingsTab)
    GW.LoadHudPanel(settingsTab)
    GW.LoadActionbarPanel(settingsTab)
    GW.LoadObjectivesPanel(settingsTab)
    GW.LoadPlayerPanel(settingsTab)
    GW.LoadTargetPanel(settingsTab)
    GW.LoadRaidPanel(settingsTab)
    GW.LoadAurasPanel(settingsTab)
    GW.LoadChatPanel(settingsTab)
    GW.LoadTooltipPanel(settingsTab)
    GW.LoadNotificationsPanel(settingsTab)
    GW.LoadSkinsPanel(settingsTab)
    GW.LoadFontsPanel(settingsTab)

    -- Menü ScrollBox
    local view = CreateScrollBoxListLinearView()
    view:SetElementExtentCalculator(function(_, ed)
        if ed.isSubCat and ed.parent and not ed.parent.isExpanded then
            return 0.1
        end
        return ed.isSubCat and MENU_SUB_ROW_HEIGHT or MENU_MAIN_ROW_HEIGHT
    end)

    view:SetElementInitializer("GwSettingsSettingsTabMenuButtonTemplate", InitMenuButton)
    ScrollUtil.InitScrollBoxListWithScrollBar(settingsTab.menu.ScrollBox, settingsTab.menu.ScrollBar, view)

    menuItemSelectionBehavior = ScrollUtil.AddSelectionBehavior(settingsTab.menu.ScrollBox, SelectionBehaviorFlags.Deselectable, SelectionBehaviorFlags.Intrusive)
    menuItemSelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, function(_, ed, selected)
        if selected then
            CloseSearch()
        end
        local btn = settingsTab.menu.ScrollBox:FindFrame(ed)
        if btn then SetMenuRowActive(btn, selected) end

        -- category rows without a folded General panel hand the selection to their first sub entry
        if ed.isSubCat or not ed.itemData.hasSubFrames or ed.itemData.generalSub then return end
        local dp = settingsTab.menu.ScrollBox:GetDataProvider()
        local firstSub
        dp:ForEach(function(x) if x.isSubCat and x.index == ed.index + 1 then firstSub = x; return true end end)
        if not firstSub then return end
        settingsTab.menu.ScrollBox:ScrollToElementDataByPredicate(function(x) return x == firstSub end, ScrollBoxConstants.AlignNearest)
        C_Timer.After(0, function()
            local subBtn = settingsTab.menu.ScrollBox:FindFrame(firstSub)
            if subBtn and not menuItemSelectionBehavior:IsSelected(subBtn) then menuItemSelectionBehavior:Select(subBtn) end
        end)
    end)

    settingsTab.menu.ScrollBox:SetDataProvider(CreateDataProvider(BuildFlatMenuData()), ScrollBoxConstants.RetainScrollPosition)
    GW.HandleTrimScrollBar(settingsTab.menu.ScrollBar)
    GW.HandleScrollControls(settingsTab.menu)
    settingsTab.menu.ScrollBar:SetHideIfUnscrollable(true)

    --select default panel
    local defaultMenuItem = FindMenuItemByPanelId(DEFAULT_SETTINGS_PANEL_ID)
    if not defaultMenuItem then
        settingsTab.menu.ScrollBox:GetDataProvider():ForEach(function(ed) if ed.index == 1 then defaultMenuItem = ed; return true end end)
    end
    SelectMenuItem(defaultMenuItem)

    -- Setup search
    searchPanel = CreateFrame("Frame", nil, container, "GwSettingsPanelTmpl")
    searchPanel.header:SetFont(DAMAGE_TEXT_FONT, 26)
    searchPanel.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    searchPanel.header:SetText(SETTINGS_SEARCH_RESULTS)
    searchPanel.sub:SetFont(UNIT_NAME_FONT, 12)
    searchPanel.sub:SetTextColor(181/255, 160/255, 128/255)
    searchPanel.sub:SetText(SETTINGS_SEARCH_NOTHING_FOUND)
    LayoutPanelHeader(searchPanel)
    searchPanel:Hide()
    searchPanel:ClearAllPoints()
    searchPanel:SetPoint("TOPLEFT", settingsTab, "TOPLEFT", 0, 0)
    searchPanel:SetPoint("BOTTOMRIGHT", settingsTab, "BOTTOMRIGHT", 0, 0)

    local searchView = CreateScrollBoxListLinearView()
    searchView:SetElementExtentCalculator(function(_, item)
        if not item or item.kind == "breadcrumb" then
            return DEFAULT_ROW_EXTENT
        end

        local extent = DEFAULT_ROW_EXTENT
        if item.left and item.left.widget then
            extent = math.max(extent, GetOptionRowExtent(item.left.widget))
        end
        if item.right and item.right.widget then
            extent = math.max(extent, GetOptionRowExtent(item.right.widget))
        end

        return extent
    end)
    searchView:SetElementInitializer("GwFrameTemplate", function(row, item)
        row.__searchPanel = searchPanel
        InitSearchRow(row, item)
    end)
    searchView:SetElementResetter(ResetSearchRow)
    ScrollUtil.InitScrollBoxListWithScrollBar(searchPanel.scroll.ScrollBox, searchPanel.scroll.ScrollBar, searchView)
    searchPanel.scroll.ScrollBox:SetDataProvider( CreateDataProvider(), ScrollBoxConstants.RetainScrollPosition)
    GW.HandleTrimScrollBar(searchPanel.scroll.ScrollBar)
    GW.HandleScrollControls(searchPanel.scroll)
    searchPanel.scroll.ScrollBar:SetHideIfUnscrollable(true)

    settingsTab.menu.search.input:SetFont(UNIT_NAME_FONT, 14, "")
    settingsTab.menu.search.input:SetTextColor(178 / 255, 178 / 255, 178 / 255)
    settingsTab.menu.search.input:SetText(SEARCH)
    settingsTab.menu.search.input:SetScript("OnEscapePressed", function(self) SearchClear(self, searchPanel) end)
    settingsTab.menu.search.input:SetScript("OnEditFocusGained", function(self) if self:GetText() == SEARCH then self:SetText("") end self.clearButton:Show() end)
    settingsTab.menu.search.input:SetScript("OnEditFocusLost", function(self) if self:GetText() == nil or self:GetText() == "" then SearchClear(self, searchPanel) end end)
    settingsTab.menu.search.input:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    settingsTab.menu.search.input:SetScript("OnTextChanged", function(self)
        if not self:HasFocus() then return end
        local txt = self:GetText() or ""
        self.clearButton:SetShown(txt ~= "" and txt ~= SEARCH)
        self:SetTextColor(1, 1, 1)
        SearchUpdate(searchPanel, txt)
    end)
    settingsTab.menu.search.input.clearButton:SetScript("OnClick", function(self)
        local edit = self:GetParent()
        SearchClear(edit, searchPanel)
    end)
    settingsTab.menu.search.input:SetScript("OnEnter", function()
        GameTooltip:SetOwner(settingsTab.menu.search.input, "ANCHOR_TOP")
        GameTooltip:SetText(GW.L["Type '%s' or '!' to show all new settings"]:format(NEW), 1, 1, 1)
        GameTooltip:Show()
    end)
    settingsTab.menu.search.input:SetScript("OnLeave", GameTooltip_Hide)

    settingsTab:SetScript("OnShow", function()
        if GetCVarBool("useUiScale") then
            local of = FindWidgetByOption("PIXEL_PERFECTION")
            if of then
                of.checkbutton:SetChecked(false)
                GW.settings.PIXEL_PERFECTION = false
            end
        end
        GW.CheckDependencies()
    end)

    return settingsTab
end
GW.LoadSettingsTab = LoadSettingsTab
