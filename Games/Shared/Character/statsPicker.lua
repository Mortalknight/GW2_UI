---@class GW2
local GW = select(2, ...)
local L = GW.L

-- Stats picker for the attribute box of the hero panel, used by every game version:
-- * the cog button toggles an edit mode in which every tile of the spec is shown, hidden ones dimmed
-- * a click on a tile toggles its visibility, drag and drop changes the order
-- * a right click on the cog (in edit mode) resets both
-- Visibility and order live in the private settings (GW.private.heroPanel.stats.visibility / GW.private.heroPanel.stats.order).
-- Tiles are children of the stats box; the box carries the edit state and the registered tiles.
local TILE_WIDTH = 92
local HEADER_HEIGHT = 35

local function IsEditMode(stats)
    return stats.gwEditMode == true
end

-- user choice (true / false) wins, otherwise the automatic rule of the caller
local function IsStatVisible(key, autoVisible)
    local forced = GW.private.heroPanel.stats.visibility[key]
    if forced ~= nil then
        return forced
    end
    return autoVisible
end

---------- drag and drop ----------

local dragState = {}
local dragGhost

local function ShowDragGhost(source)
    if not dragGhost then
        dragGhost = CreateFrame("Frame", "GwPaperDollStatDragGhost", UIParent)
        dragGhost:SetSize(TILE_WIDTH, 30)
        dragGhost:SetFrameStrata("TOOLTIP")
        dragGhost:SetAlpha(0.85)
        dragGhost.icon = dragGhost:CreateTexture(nil, "OVERLAY")
        dragGhost.icon:SetSize(30, 30)
        dragGhost.icon:SetPoint("LEFT")
        dragGhost.glyph = dragGhost:CreateFontString(nil, "OVERLAY")
        dragGhost.glyph:SetPoint("CENTER", dragGhost.icon, "CENTER")
        dragGhost.glyph:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        dragGhost.Value = dragGhost:CreateFontString(nil, "OVERLAY")
        dragGhost.Value:SetSize(72, 30)
        dragGhost.Value:SetPoint("LEFT", 35, 0)
        dragGhost.Value:SetJustifyH("LEFT")
        dragGhost.Value:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    end

    if source.glyph and source.glyph:IsShown() then
        dragGhost.icon:Hide()
        dragGhost.glyph:SetText(source.glyph:GetText())
        dragGhost.glyph:Show()
    else
        dragGhost.glyph:Hide()
        dragGhost.icon:SetTexture(source.icon:GetTexture())
        dragGhost.icon:SetTexCoord(source.icon:GetTexCoord())
        dragGhost.icon:SetDesaturated(source.icon:IsDesaturated())
        dragGhost.icon:Show()
    end
    dragGhost.Value:SetText(source.Value:GetText())
    dragGhost.Value:SetTextColor(source.Value:GetTextColor())
    dragGhost:SetScale(source:GetEffectiveScale() / UIParent:GetEffectiveScale())
    dragGhost:Show()
end

local function FindTileUnderCursor(stats)
    for _, frame in ipairs(stats.gwTiles) do
        if frame:IsShown() and frame:IsMouseOver() then
            return frame
        end
    end
end

-- the displayed sequence is the truth, the moved tile is inserted before (moving up) or after
-- (moving down) the drop target and the whole sequence is stored
local function ReorderStat(stats, fromKey, toKey)
    local sequence = {}
    local fromIndex, toIndex
    for _, frame in ipairs(stats.gwSequence or {}) do
        tinsert(sequence, frame.stat)
        if frame.stat == fromKey then fromIndex = #sequence end
        if frame.stat == toKey then toIndex = #sequence end
    end
    if not (fromIndex and toIndex) or fromIndex == toIndex then return end

    -- after the removal the same index means "after the target" when moving down and "before" when moving up
    tremove(sequence, fromIndex)
    tinsert(sequence, toIndex, fromKey)

    local order = GW.private.heroPanel.stats.order
    wipe(order)
    for _, key in ipairs(sequence) do
        tinsert(order, key)
    end
    stats.gwRefresh()
end

local function CancelStatDrag()
    local source = dragState.source
    if source then
        source:SetScript("OnUpdate", nil)
        source:SetAlpha(source.gwStatVisible == false and 0.35 or 1)
    end
    dragState.source = nil
    dragState.dragging = false
    if dragGhost then
        dragGhost:Hide()
    end
end

local function tile_DragOnUpdate(self)
    local x, y = GetCursorPosition()
    if not dragState.dragging then
        if abs(x - dragState.startX) + abs(y - dragState.startY) < 8 then
            return
        end
        dragState.dragging = true
        ShowDragGhost(self)
        self:SetAlpha(0.3)
    end
    -- keep the grab point: the ghost has the tile's effective scale, so cursor / scale is in tile units
    local scale = dragGhost:GetEffectiveScale()
    dragGhost:ClearAllPoints()
    dragGhost:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / scale - dragState.offsetX, y / scale - dragState.offsetY)
end

local function tile_OnMouseDown(self, button)
    if button ~= "LeftButton" or not IsEditMode(self:GetParent()) or not self.stat then
        return
    end
    dragState.source = self
    dragState.startX, dragState.startY = GetCursorPosition()
    dragState.dragging = false
    -- grab offset from the tile's top left corner, in tile units
    local scale = self:GetEffectiveScale()
    dragState.offsetX = dragState.startX / scale - self:GetLeft()
    dragState.offsetY = dragState.startY / scale - self:GetTop()
    self:SetScript("OnUpdate", tile_DragOnUpdate)
end

local function tile_OnMouseUp(self, button)
    if button ~= "LeftButton" then
        return
    end
    self:SetScript("OnUpdate", nil)
    if dragState.source ~= self then
        return
    end
    dragState.source = nil

    local stats = self:GetParent()
    if dragState.dragging then
        dragState.dragging = false
        dragGhost:Hide()
        self:SetAlpha(self.gwStatVisible == false and 0.35 or 1)
        local target = FindTileUnderCursor(stats)
        if target and target ~= self then
            ReorderStat(stats, self.stat, target.stat)
        end
        return
    end

    -- click: force the stat to the opposite of its current visibility, durability always stays
    if not IsEditMode(stats) or self.stat == "DURABILITY" then
        return
    end
    GW.private.heroPanel.stats.visibility[self.stat] = not self.gwStatVisible
    stats.gwRefresh()
end

-- appended to the tooltip the tile itself has opened
local function tile_OnEnterHint(self)
    if IsEditMode(self:GetParent()) and self.stat ~= "DURABILITY" and GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
        GameTooltip:AddLine(L["Click a stat to hide or show it"], 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end
end

---------- api ----------

-- installs the mouse handling once per tile and remembers it for the layout; call after the
-- tile's own OnEnter script is set
local function RegisterTile(stats, frame)
    if frame.gwPickerTile then return end
    frame.gwPickerTile = true
    stats.gwTiles = stats.gwTiles or {}
    tinsert(stats.gwTiles, frame)
    frame:SetScript("OnMouseDown", tile_OnMouseDown)
    frame:SetScript("OnMouseUp", tile_OnMouseUp)
    frame:HookScript("OnEnter", tile_OnEnterHint)
end

-- entries: registered tiles with .stat and .gwStatVisible in default order. Visible tiles (in edit
-- mode all of them) are placed in the user's order in a two column grid, every other registered
-- tile is hidden. minHeight lets the box grow with the rows.
local function Layout(stats, entries, rowHeight, minHeight)
    local editMode = IsEditMode(stats)
    local shown = {}
    for _, frame in ipairs(entries) do
        if frame.gwStatVisible or editMode then
            tinsert(shown, frame)
        end
    end

    -- stored order first; a tile the stored order does not know yet (new stat, first mythic+ rating)
    -- goes right behind its predecessor of the default order instead of to the end
    local orderIndex = {}
    for i, key in ipairs(GW.private.heroPanel.stats.order) do
        orderIndex[key] = i
    end
    local ordered = {}
    for _, frame in ipairs(shown) do
        if orderIndex[frame.stat] then
            tinsert(ordered, frame)
        end
    end
    sort(ordered, function(a, b) return orderIndex[a.stat] < orderIndex[b.stat] end)
    for i, frame in ipairs(shown) do
        if not orderIndex[frame.stat] then
            local insertAt = 1
            local predecessor = shown[i - 1]
            if predecessor then
                insertAt = tIndexOf(ordered, predecessor) + 1
            end
            tinsert(ordered, insertAt, frame)
        end
    end
    shown = ordered

    local placed = {}
    for i, frame in ipairs(shown) do
        local column, row = (i - 1) % 2, math.floor((i - 1) / 2)
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", stats, "TOPLEFT", 5 + column * TILE_WIDTH, -HEADER_HEIGHT - row * rowHeight)
        frame:SetAlpha(frame.gwStatVisible and 1 or 0.35)
        frame:Show()
        placed[frame] = true
    end
    for _, frame in ipairs(stats.gwTiles or {}) do
        if not placed[frame] then
            frame:Hide()
        end
    end
    stats.gwSequence = shown

    if minHeight then
        stats:SetHeight(math.max(minHeight, HEADER_HEIGHT + math.ceil(#shown / 2) * rowHeight + 6))
    end
end

-- cog button, edit mode marker (gold border, header text) and reset; refresh rebuilds the tiles
local function Setup(stats, dressingRoom, refresh)
    stats.gwRefresh = refresh
    stats.gwTiles = stats.gwTiles or {}

    local editButton = CreateFrame("Button", nil, stats)
    editButton:SetSize(16, 16)
    editButton:SetPoint("TOPRIGHT", stats, "TOPRIGHT", -8, -12)
    editButton:SetFrameLevel(stats:GetFrameLevel() + 10)
    editButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/settings-window-icon.png")
    editButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/character/settings-window-icon.png", "ADD")
    editButton:GetHighlightTexture():SetAlpha(0.3)
    editButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    stats:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true, 2, 2)
    stats.backdrop:SetFrameLevel(stats:GetFrameLevel() + 5)
    stats.backdrop:SetBackdropBorderColor(1, 0.82, 0, 0.9)
    stats.backdrop:Hide()

    local headerText = stats.header:GetText()
    local headerColor = {stats.header:GetTextColor()}
    local function SetEditMode(enabled)
        stats.gwEditMode = enabled
        editButton:GetNormalTexture():SetDesaturated(not enabled)
        editButton:SetAlpha(enabled and 1 or 0.6)
        stats.backdrop:SetShown(enabled)
        stats.header:SetText(enabled and HUD_EDIT_MODE_MENU or headerText)
        if enabled then
            stats.header:SetTextColor(1, 0.82, 0)
        else
            stats.header:SetTextColor(unpack(headerColor))
        end
    end
    SetEditMode(false)

    editButton:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            -- back to the defaults: automatic visibility and default order, only while editing
            if not stats.gwEditMode then return end
            wipe(GW.private.heroPanel.stats.visibility)
            wipe(GW.private.heroPanel.stats.order)
        else
            SetEditMode(not stats.gwEditMode)
        end
        refresh()
    end)
    editButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Choose stats"], 1, 1, 1)
        GameTooltip:AddLine(L["Click a stat to hide or show it"], nil, nil, nil, true)
        GameTooltip:AddLine(L["Drag a stat to change the order"], nil, nil, nil, true)
        if stats.gwEditMode then
            GameTooltip:AddLine(L["Right click to reset to the defaults"], nil, nil, nil, true)
        end
        GameTooltip:Show()
    end)
    editButton:SetScript("OnLeave", GameTooltip_Hide)

    dressingRoom:HookScript("OnHide", function()
        if stats.gwEditMode then
            SetEditMode(false)
            CancelStatDrag()
            refresh() -- back to the normal layout for the next open
        end
    end)
end

GW.StatsPicker = {
    Setup = Setup,
    RegisterTile = RegisterTile,
    Layout = Layout,
    IsVisible = IsStatVisible,
    IsEditMode = IsEditMode,
}
