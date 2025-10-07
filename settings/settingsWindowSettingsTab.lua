local _, GW = ...

local menuItems = {}
local menuItemSelectionBehavior
local settingsWindowFrame
local settingsMenuFrame
local currentPanelIndex
local searchPanel
local searchEdit

local ROW_PAD_X = 8
local ROW_PAD_Y = 8
local COL_GAP   = 8
local CONTENT_W = 550

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
    text        = {template = "GwOptionBoxTextTmpl", frame = "Button", newLine = true},
    button      = {template = "GwButtonTextTmpl", frame = "Button", newLine = true},
    colorPicker = {template = "GwOptionBoxColorPickerTmpl", frame = "Button", newLine = true},
    header      = {template = "GwOptionBoxHeader", frame = "Frame", newLine = true},
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
    of.title:SetTextColor(1, 1, 1)
    of.title:SetShadowColor(0, 0, 0, 1)
    of.title:SetText(of.displayName or "")

    -- Deine vorhandene Typ-spezifische Logik hier hinein:
    GW.SettingsInitOptionWidget(of, opt, panel)

    opt.__widget = of

    RegisterOptionWidget(of, { panel=panel, title=of.displayName, path=of.settingsPath, type=of.optionType, key=of.optionName, desc=of.desc })

    return of
end

local function PackOptionsIntoRows(options)
    local rows, i = {}, 1
    while i <= #options do
        local a = options[i]; if not a then break end
        if ResolveForceNewLine(a) then
            rows[#rows+1] = { cols = {a} }
            i = i + 1
        else
            local b = options[i + 1]
            if b and not ResolveForceNewLine(b) then
                rows[#rows+1] = { cols = {a, b} }
                i = i + 2
            else
                rows[#rows+1] = { cols = {a} }
                i = i + 1
            end
        end
    end
    return rows
end

local function BuildOptionsDataProvider(panel)
    local options = (panel and panel.gwOptions) or {}
    local rows = PackOptionsIntoRows(options)

    for _, row in ipairs(rows) do
        for k=1,2 do
            local opt = row.cols[k]
            if opt then CreateOrGetOptionWidget(panel, opt) end
        end
    end

    local dp = CreateDataProvider()
    for i, row in ipairs(rows) do
        dp:Insert({ index = i, cols = row.cols, panel = panel })
    end
    return dp
end

local function InitRow(row, elementData)
    row.__panel = elementData.panel
    local panel = elementData.panel

    row:SetWidth(ROW_PAD_X * 2 + CONTENT_W)

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
        AnchorFullWidth(row, leftW)
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

    view:SetElementExtent(40)
    view:SetElementInitializer("GwFrameTemplate", InitRow)
    view:SetElementResetter(function(row)
        if row.leftAssigned  then StashWidget(row.leftAssigned,  row.__panel); row.leftAssigned  = nil end
        if row.rightAssigned then StashWidget(row.rightAssigned, row.__panel); row.rightAssigned = nil end
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(panel.scroll.ScrollBox, panel.scroll.ScrollBar, view)
    GW.HandleTrimScrollBar(panel.scroll.ScrollBar)
    GW.HandleScrollControls(panel.scroll)
    panel.scroll.ScrollBar:SetHideIfUnscrollable(true)

    panel.scroll.ScrollBox:SetDataProvider(BuildOptionsDataProvider(panel), ScrollBoxConstants.RetainScrollPosition)
end

-- =========================
-- Menu + Panel-Switch
-- =========================
local function BuildFlatMenuData()
    local list, idx = {}, 1
    for _, item in ipairs(menuItems) do
        item.isExpanded = false
        tinsert(list, { index = idx, itemData = item, isSubCat = false, parent = nil })
        item.index = idx; idx = idx + 1

        if item.hasSubFrames then
            for _, sub in ipairs(item.subFrameData) do
                tinsert(list, { index = idx, itemData = sub, isSubCat = true, parent = item })
                sub.index = idx; idx = idx + 1
            end
        end
    end
    return list
end

local function SwitchPanel(panelIndex)
    currentPanelIndex = panelIndex
    for _, main in ipairs(menuItems) do
        local isSubFrameShown = false
        if main.hasSubFrames then
            main.basePanel:Hide()
            for _, sub in ipairs(main.subFrameData) do
                if sub.index == panelIndex then
                    sub.frame:Show()
                    main.basePanel:Show()
                    isSubFrameShown = true
                else
                    sub.frame:Hide()
                end
            end
        else
            main.basePanel:SetShown(main.index == panelIndex)
        end
        main.isExpanded = isSubFrameShown
    end
    settingsMenuFrame.ScrollBox:Rebuild(ScrollBoxConstants.RetainScrollPosition)
end

-- =========================
-- API for adding panels
-- =========================
function GwSettingsWindowSettingsTabMixin:AddSettingsPanel(basePanel, name, desc, subFrameData, isAddon)
    tinsert(menuItems, {
        basePanel = basePanel,
        name = name,
        desc = desc,
        isExpanded = false,
        hasSubFrames = subFrameData and #subFrameData > 0,
        subFrameData = subFrameData,
        isAddon = isAddon,
    })

    -- init panel
    if subFrameData and #subFrameData > 0 then
        for _, sub in ipairs(subFrameData) do
            InitOptionPanel(sub.frame)
        end
        basePanel.header:Hide()
        basePanel.sub:Hide()
        basePanel.scroll:Hide()
    else
        InitOptionPanel(basePanel)
    end

    if isAddon then
        self.menu.ScrollBox:SetDataProvider(CreateDataProvider(BuildFlatMenuData()), ScrollBoxConstants.RetainScrollPosition)
        SwitchPanel(currentPanelIndex or 1)
    end
end

function GwSettingsWindowSettingsTabMixin:OpenSettingsToPanel(panelId)
    local foundItem
    settingsMenuFrame.ScrollBox:GetDataProvider():ForEach(function(ed)
        if (ed.isSubCat and ed.itemData.frame.panelId == panelId) or (not ed.isSubCat and ed.itemData.basePanel.panelId == panelId) then
            foundItem = ed
            return true
        end
    end)
    if foundItem then
        SwitchPanel(foundItem.index)
        settingsMenuFrame.ScrollBox:ScrollToElementDataByPredicate(function(ed) return ed == foundItem end)
        C_Timer.After(0, function()
            local btn = settingsMenuFrame.ScrollBox:FindFrame(foundItem)
            if btn and not menuItemSelectionBehavior:IsSelected(btn) then menuItemSelectionBehavior:Select(btn) end
        end)
    end
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
        AnchorFullWidth(row, leftW)
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
local function InitMenuButton(button, elementData)
    if not button.isGwInit then
        button.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
        button.limitHoverStripAmount = 1
        button.arrow:ClearAllPoints()
        button.arrow:SetPoint("LEFT", 5, 0)
        button.arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right.png")
        button.arrow:SetSize(16, 16)
        button:SetScript("OnClick", function()
            CloseSearch()
            SwitchPanel(button.index)
            menuItemSelectionBehavior:SelectElementData(button.elementData)
        end)
        button.isGwInit = true
    end

    if elementData.index % 2 == 0 then
        button:ClearNormalTexture()
    else
        button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
    end

    button.arrow:SetShown(elementData.itemData.hasSubFrames)
    button.text:SetPoint("LEFT", button, "LEFT", 20 + (elementData.isSubCat and 10 or 0), 0)
    button.text:SetText(elementData.itemData.name)

    button.name = elementData.itemData.name
    button.itemData = elementData.itemData
    button.isSubCat = elementData.isSubCat
    button.hasSubCat = elementData.itemData.hasSubFrames
    button.elementData = elementData

    if elementData.isSubCat then
        button.index = elementData.index
    elseif elementData.itemData.hasSubFrames then
        button.index = elementData.index + 1
    else
        button.index = elementData.index
    end

    button.activeTexture:SetShown(menuItemSelectionBehavior:IsSelected(button))

    local hidden = elementData.isSubCat and elementData.parent and not elementData.parent.isExpanded
    button:EnableMouse(not hidden)
    button:SetAlpha(hidden and 0 or 1)
    button:SetHeight(hidden and 0 or 36)

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
    settingsTab.hasSearch = false
    container:AddTab("Interface/AddOns/GW2_UI/textures/uistuff/tabicon_settings.png", settingsTab)

    --load settings panels
    GW.LoadModulesPanel(settingsTab)
    GW.LoadGeneralPanel(settingsTab)
    GW.LoadPlayerPanel(settingsTab)
    GW.LoadTargetPanel(settingsTab)
    GW.LoadActionbarPanel(settingsTab)
    GW.LoadHudPanel(settingsTab)
    GW.LoadObjectivesPanel(settingsTab)
    GW.LoadFontsPanel(settingsTab)
    GW.LoadChatPanel(settingsTab)
    GW.LoadTooltipPanel(settingsTab)
    GW.LoadPartyPanel(settingsTab)
    GW.LoadRaidPanel(settingsTab)
    GW.LoadAurasPanel(settingsTab)
    GW.LoadNotificationsPanel(settingsTab)
    GW.LoadSkinsPanel(settingsTab)

    -- Menü ScrollBox
    local view = CreateScrollBoxListLinearView()
    view:SetElementExtentCalculator(function(_, ed)
        if ed.isSubCat and ed.parent and not ed.parent.isExpanded then
            return 0.1
        end
        return 36
    end)

    view:SetElementInitializer("GwSettingsSettingsTabMenuButtonTemplate", InitMenuButton)
    ScrollUtil.InitScrollBoxListWithScrollBar(settingsTab.menu.ScrollBox, settingsTab.menu.ScrollBar, view)

    menuItemSelectionBehavior = ScrollUtil.AddSelectionBehavior(settingsTab.menu.ScrollBox, SelectionBehaviorFlags.Deselectable, SelectionBehaviorFlags.Intrusive)
    menuItemSelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, function(_, ed, selected)
        if selected then
            CloseSearch()
        end
        local btn = settingsTab.menu.ScrollBox:FindFrame(ed)
        if btn then btn.activeTexture:SetShown(selected) end

        if ed.isSubCat or not ed.itemData.hasSubFrames then return end
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

    --select first Panel
    local firstMenuItem
    settingsTab.menu.ScrollBox:GetDataProvider():ForEach(function(ed) if ed.index == 1 then firstMenuItem = ed; return true end end)
    if firstMenuItem then
        SwitchPanel(firstMenuItem.index)
        settingsTab.menu.ScrollBox:ScrollToElementDataByPredicate(function(ed) return ed == firstMenuItem end)
        C_Timer.After(0, function()
            local btn = settingsTab.menu.ScrollBox:FindFrame(firstMenuItem)
            if btn and not menuItemSelectionBehavior:IsSelected(btn) then menuItemSelectionBehavior:Select(btn) end
        end)
    end

    -- Setup search
    searchPanel = CreateFrame("Frame", nil, container, "GwSettingsPanelTmpl")
    searchPanel.header:SetFont(DAMAGE_TEXT_FONT, 26)
    searchPanel.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r, GW.TextColors.LIGHT_HEADER.g, GW.TextColors.LIGHT_HEADER.b)
    searchPanel.header:SetText(SETTINGS_SEARCH_RESULTS)
    searchPanel.sub:SetFont(UNIT_NAME_FONT, 12)
    searchPanel.sub:SetTextColor(181/255, 160/255, 128/255)
    searchPanel.sub:SetText(SETTINGS_SEARCH_NOTHING_FOUND)
    searchPanel:Hide()
    searchPanel:ClearAllPoints()
    searchPanel:SetPoint("TOPLEFT", settingsTab, "TOPLEFT", 0, 0)
    searchPanel:SetPoint("BOTTOMRIGHT", settingsTab, "BOTTOMRIGHT", 0, 0)

    local searchView = CreateScrollBoxListLinearView()
    searchView:SetElementExtent(40)
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
