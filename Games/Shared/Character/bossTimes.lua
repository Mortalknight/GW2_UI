---@class GW2
local GW = select(2, ...)
local L = GW.L

-- boss times page in the currency tab, filled from GW.private.encounterTimes (Objectives/encounterTimes.lua):
local Colors = GW.Colors.SkinColors
local WHITE = "Interface/Buttons/WHITE8x8"
local LIST_WIDTH = 196
local CARD_HEIGHT, KIND_HEIGHT, ROW_HEIGHT = 48, 22, 32
local BAR_WIDTH = 56
local BEST_MARK = 0.6
local DELVE_ART = {card = "Interface/AddOns/GW2_UI/textures/questview/backgrounds/TWW/ringing_deeps.jpg"}
local DETAIL_WIDTH = 346
local BANNER_HEIGHT = 86
local ART_RIGHT, ART_BOTTOM = 174 / 256, 96 / 128
local KIND_ORDER = {mplus = 1, raid = 2, party = 3, delve = 4}
local DIFFICULTY_ORDER = {[17] = 1, [14] = 2, [15] = 3, [16] = 4, [1] = 1, [2] = 2, [23] = 3}

local page
local selectedInstance
local selectedKey = {}
local instanceArt

local function FormatDate(timestamp)
    local d = date("*t", timestamp)
    return FormatShortDate(d.day, d.month, d.year % 100)
end

local function FormatDelta(delta)
    if delta == 0 then return "" end
    local color = delta > 0 and Colors.Negative or Colors.Positive
    return color:WrapTextInColorCode((delta > 0 and "+" or "-") .. GW.FormatEncounterTime(math.abs(delta)))
end

local function GetKindName(kind)
    if kind == "mplus" then return GW.Retail and PLAYER_DIFFICULTY_MYTHIC_PLUS or CHALLENGES end
    if kind == "raid" then return RAIDS end
    if kind == "party" then return DUNGEONS end
    return L["Delves"]
end

local function GetBossName(id, data)
    if id == "forces" then return L["Enemy Forces"] end
    return data.name or ("#" .. id)
end

local function GetInstanceArt(instanceMapID)
    if not instanceArt then
        instanceArt = {}
        if EJ_GetNumTiers then
            local currentTier = EJ_GetCurrentTier()
            for tier = 1, EJ_GetNumTiers() do
                EJ_SelectTier(tier)
                for _, isRaid in ipairs({false, true}) do
                    local index = 1
                    local journalID = EJ_GetInstanceByIndex(index, isRaid)
                    while journalID do
                        local _, _, _, buttonImage, _, _, _, _, _, mapID = EJ_GetInstanceInfo(journalID)
                        if mapID then
                            instanceArt[mapID] = {card = buttonImage, journal = true}
                        end
                        index = index + 1
                        journalID = EJ_GetInstanceByIndex(index, isRaid)
                    end
                end
            end
            if currentTier then
                EJ_SelectTier(currentTier)
            end
        end
    end
    return instanceArt[instanceMapID]
end

-- forces come after the bosses, the bosses in the order of their first kill
local function SortBosses(a, b)
    if (a.id == "forces") ~= (b.id == "forces") then return b.id == "forces" end
    return (a.data.firstDate or a.data.bestDate or 0) < (b.data.firstDate or b.data.bestDate or 0)
end

local function GetOrder(entry, kind)
    return (kind == "raid" or kind == "party") and (DIFFICULTY_ORDER[entry.value] or entry.value) or entry.value
end

local function CreateInstance(kind, mapID)
    local instance = {id = kind .. ":" .. mapID, kind = kind, entries = {}}
    if kind == "mplus" then
        local name, _, timeLimit, _, background, instanceMapID = C_ChallengeMode.GetMapUIInfo(mapID)
        instance.name, instance.timeLimit = name or UNKNOWN, timeLimit
        instance.art = GetInstanceArt(instanceMapID) or (background and {card = background})
    else
        instance.name = GetRealZoneText(mapID) or UNKNOWN
        instance.art = GetInstanceArt(mapID) or (kind == "delve" and DELVE_ART or nil)
    end
    return instance
end

local function CreateEntry(key, kind, value, store)
    local label
    if kind == "mplus" then
        label = value > 0 and "+" .. value or GetDifficultyInfo(DifficultyUtil.ID.DungeonChallenge) or ""
    elseif kind == "delve" then
        label = L["Tier %d"]:format(value)
    else
        label = GetDifficultyInfo(value) or ""
    end

    local entry = {key = key, value = value, label = label, bosses = {}}
    for id, data in pairs(store) do
        if type(data) == "table" and data.best and id ~= "total" and not (type(id) == "string" and id:find("^fight:")) then
            tinsert(entry.bosses, {id = id, data = data, fight = store["fight:" .. tostring(id)], precise = kind ~= "mplus"})
        end
    end
    sort(entry.bosses, SortBosses)

    -- raids and dungeons have no run time, their fights add up instead
    entry.summary = type(store.total) == "table" and store.total or nil
    if not entry.summary and #entry.bosses > 0 then
        local summary = {best = 0, last = 0, kills = 0}
        for _, boss in ipairs(entry.bosses) do
            summary.best = summary.best + boss.data.best
            summary.last = summary.last + (boss.data.last or boss.data.best)
            summary.kills = math.max(summary.kills, boss.data.kills or 0)
            summary.lastDate = math.max(summary.lastDate or 0, boss.data.lastDate or 0)
        end
        entry.summary = summary
    end
    return entry
end

local function Matches(text, search)
    return search == "" or text:lower():find(search, 1, true) ~= nil
end

local function InstanceMatches(instance, search)
    if Matches(instance.name, search) then return true end
    for _, entry in ipairs(instance.entries) do
        for _, boss in ipairs(entry.bosses) do
            if Matches(GetBossName(boss.id, boss.data), search) then return true end
        end
    end
    return false
end

local function BuildInstances(search, filter)
    local byID, instances = {}, {}
    for key, store in pairs(GW.private.encounterTimes or {}) do
        local kind, mapID, value = strsplit(":", key)
        mapID, value = tonumber(mapID), tonumber(value) or 0
        if KIND_ORDER[kind] and mapID and (not filter or filter == kind) then
            local entry = CreateEntry(key, kind, value, store)
            if #entry.bosses > 0 then
                local id = kind .. ":" .. mapID
                byID[id] = byID[id] or CreateInstance(kind, mapID)
                tinsert(byID[id].entries, entry)
            end
        end
    end
    for _, instance in pairs(byID) do
        if InstanceMatches(instance, search) then
            sort(instance.entries, function(a, b) return GetOrder(a, instance.kind) > GetOrder(b, instance.kind) end)
            tinsert(instances, instance)
        end
    end
    sort(instances, function(a, b)
        if a.kind ~= b.kind then return KIND_ORDER[a.kind] < KIND_ORDER[b.kind] end
        return a.name < b.name
    end)
    return instances
end

local function GetSelectedEntry(instance)
    for _, entry in ipairs(instance.entries) do
        if entry.key == selectedKey[instance.id] then return entry end
    end
    return instance.entries[1]
end

-- the middle of the art in the shape of the frame; other art than the journal's is taken as 2:1
local function SetArt(texture, art, width, height)
    texture:SetTexture(art and art.card or nil)
    if not art then return end
    local right, bottom, aspect = 1, 1, 2
    if art.journal then
        right, bottom, aspect = ART_RIGHT, ART_BOTTOM, 174 / 96
    end
    local target = width / height
    if target > aspect then
        local cut = bottom * (1 - aspect / target) / 2
        texture:SetTexCoord(0, right, cut, bottom - cut)
    else
        local cut = right * (1 - target / aspect) / 2
        texture:SetTexCoord(cut, right - cut, 0, bottom)
    end
end

local function CreateText(parent, size, justify, font)
    local text = parent:CreateFontString(nil, "OVERLAY")
    text:GwSetFontTemplate(font or UNIT_NAME_FONT, size)
    text:SetJustifyH(justify or "LEFT")
    text:SetWordWrap(false)
    return text
end

local function CreateBorder(frame, color)
    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({edgeFile = WHITE, edgeSize = 1})
    border:SetBackdropBorderColor(color:GetRGBA())
    return border
end

---------- instance list ----------
local function Card_OnClick(self)
    if self.elementData.instance then
        selectedInstance = self.elementData.instance.id
        GW.UpdateBossTimesPage()
    end
end

local function InitCard(card, elementData)
    if not card.name then
        card.art = card:CreateTexture(nil, "BACKGROUND")
        card.art:SetPoint("TOPLEFT", 0, 0)
        card.art:SetPoint("BOTTOMRIGHT", 0, 0)
        card.shade = card:CreateTexture(nil, "BORDER")
        card.shade:SetAllPoints(card.art)
        card.shade:SetColorTexture(Colors.Chip:GetRGBA())
        card.name = CreateText(card, GW.Enum.TextSizeType.Normal)
        card.name:SetPoint("TOPLEFT", 8, -7)
        card.name:SetPoint("RIGHT", -8, 0)
        card.sub = CreateText(card, GW.Enum.TextSizeType.Small)
        card.sub:SetPoint("BOTTOMLEFT", 8, 7)
        card.best = CreateText(card, GW.Enum.TextSizeType.Small, "RIGHT")
        card.best:SetPoint("BOTTOMRIGHT", -8, 7)
        card.selected = CreateBorder(card, Colors.QuestGold)
        card:SetScript("OnClick", Card_OnClick)
        GW.AddListItemChildHoverTexture(card)
        card.Background:SetAlpha(0)
    end
    card.elementData = elementData

    local isKind = elementData.kind ~= nil
    card.art:SetShown(not isKind)
    card.shade:SetShown(not isKind)
    card.sub:SetShown(not isKind)
    card.best:SetShown(not isKind)
    card:EnableMouse(not isKind)

    if isKind then
        card.selected:Hide()
        card.name:ClearAllPoints()
        card.name:SetPoint("BOTTOMLEFT", 4, 4)
        card.name:SetText(Colors.SubText:WrapTextInColorCode(GetKindName(elementData.kind)))
        return
    end

    local instance = elementData.instance
    local top = instance.entries[1]
    card.name:ClearAllPoints()
    card.name:SetPoint("TOPLEFT", 8, -7)
    card.name:SetPoint("RIGHT", -8, 0)
    card.name:SetText(instance.name)
    card.sub:SetText(Colors.SubText:WrapTextInColorCode(top.label))
    card.best:SetText(GW.FormatEncounterTime(top.summary.best, true))
    SetArt(card.art, instance.art, LIST_WIDTH, CARD_HEIGHT)
    card.art:SetAlpha(0.6)
    card.selected:SetShown(instance.id == selectedInstance)
end

---------- details ----------
local function Level_OnClick(self)
    selectedKey[self.instanceID] = self.key
    GW.UpdateBossTimesPage()
end

local function UpdateLevels(instance, selected)
    local detail = page.detail
    for _, tab in ipairs(detail.levels) do
        tab:Hide()
    end
    for index, entry in ipairs(instance.entries) do
        local tab = detail.levels[index]
        if not tab then
            tab = CreateFrame("Button", nil, detail.banner)
            tab:SetHeight(20)
            GW.AddTextTabArt(tab)
            tab:SetScript("OnClick", Level_OnClick)
            tab:SetPoint("BOTTOMLEFT", index == 1 and detail.banner or detail.levels[index - 1], index == 1 and "BOTTOMLEFT" or "BOTTOMRIGHT", index == 1 and 10 or 4, index == 1 and 6 or 0)
            detail.levels[index] = tab
        end
        tab.instanceID, tab.key = instance.id, entry.key
        GW.SetTextTab(tab, entry.label, entry == selected)
        tab:Show()
    end
end

local function SetTile(tile, label, value, sub)
    tile.label:SetText(Colors.SubText:WrapTextInColorCode(label))
    tile.value:SetText(value)
    tile.sub:SetText(sub or "")
end

local function UpdateTiles(instance, entry)
    local detail, summary = page.detail, entry.summary
    local bestSub = summary.bestDate and Colors.SubText:WrapTextInColorCode(FormatDate(summary.bestDate))
    if instance.timeLimit and instance.timeLimit > 0 then
        local left = instance.timeLimit - summary.best
        local color = left >= 0 and Colors.Positive or Colors.Negative
        bestSub = color:WrapTextInColorCode((left >= 0 and L["%s under the timer"] or L["%s over the timer"]):format(GW.FormatEncounterTime(math.abs(left))))
    end
    SetTile(detail.tiles[1], L["Best"], Colors.QuestGold:WrapTextInColorCode(GW.FormatEncounterTime(summary.best, true)), bestSub)
    SetTile(detail.tiles[2], L["Last"], GW.FormatEncounterTime(summary.last or summary.best, true), FormatDelta((summary.last or summary.best) - summary.best))
    SetTile(detail.tiles[3], L["Kills"], summary.kills or 0, summary.lastDate and summary.lastDate > 0 and Colors.SubText:WrapTextInColorCode(FormatDate(summary.lastDate)))
end

-- mythic+ only: the key from start to timer with a mark for every best split
local function UpdateTimeline(instance, entry)
    local timeline = page.detail.timeline
    local length = math.max(instance.timeLimit or 0, entry.summary.best, 1)
    local width = timeline:GetWidth()
    timeline.fill:SetWidth(math.max(1, width * math.min(1, entry.summary.best / length)))
    timeline.limit:SetText(instance.timeLimit and Colors.SubText:WrapTextInColorCode(GW.FormatEncounterTime(instance.timeLimit)) or "")

    for _, mark in ipairs(timeline.marks) do
        mark:Hide()
        mark.text:Hide()
    end
    local index = 0
    for _, boss in ipairs(entry.bosses) do
        if boss.id ~= "forces" then
            index = index + 1
            local mark = timeline.marks[index]
            if not mark then
                mark = timeline:CreateTexture(nil, "OVERLAY")
                mark:SetSize(2, 14)
                mark:SetColorTexture(Colors.CreamBorder:GetRGB())
                mark.text = CreateText(timeline, GW.Enum.TextSizeType.Small, "CENTER")
                mark.text:SetPoint("TOP", mark, "BOTTOM", 0, -2)
                timeline.marks[index] = mark
            end
            mark:SetPoint("CENTER", timeline.track, "LEFT", width * math.min(1, boss.data.best / length), 0)
            mark.text:SetText(Colors.SubText:WrapTextInColorCode(GW.FormatEncounterTime(boss.data.best)))
            mark:Show()
            mark.text:Show()
        end
    end
end

local function Row_OnEnter(self)
    local boss = self.boss
    local data = boss.data
    local sr, sg, sb = Colors.SubText:GetRGB()
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:AddLine(GetBossName(boss.id, data), 1, 1, 1)
    GameTooltip:AddDoubleLine(L["Best"], GW.FormatEncounterTime(data.best, boss.precise) .. (data.bestDate and " (" .. FormatDate(data.bestDate) .. ")" or ""), sr, sg, sb, 1, 1, 1)
    if data.last then
        GameTooltip:AddDoubleLine(L["Last"], GW.FormatEncounterTime(data.last, boss.precise), sr, sg, sb, 1, 1, 1)
    end
    if boss.fight and boss.fight.best then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Fight duration"], 1, 1, 1)
        GameTooltip:AddDoubleLine(L["Best"], GW.FormatEncounterTime(boss.fight.best, true), sr, sg, sb, 1, 1, 1)
        GameTooltip:AddDoubleLine(L["Last"], GW.FormatEncounterTime(boss.fight.last, true), sr, sg, sb, 1, 1, 1)
    end
    GameTooltip:Show()
end

local function InitRow(row, elementData)
    if not row.name then
        -- long boss names take a second line
        row.name = CreateText(row, GW.Enum.TextSizeType.Normal)
        row.name:SetWordWrap(true)
        row.name:SetMaxLines(2)
        row.name:SetHeight(ROW_HEIGHT)
        row.name:SetPoint("LEFT", 10, 0)
        row.kills = CreateText(row, GW.Enum.TextSizeType.Normal, "RIGHT")
        row.kills:SetPoint("RIGHT", -6, 0)
        row.kills:SetWidth(30)
        row.delta = CreateText(row, GW.Enum.TextSizeType.Normal, "RIGHT")
        row.delta:SetPoint("RIGHT", row.kills, "LEFT", -4, 0)
        row.delta:SetWidth(44)
        row.best = CreateText(row, GW.Enum.TextSizeType.Normal, "RIGHT")
        row.best:SetPoint("RIGHT", row.delta, "LEFT", -4, 0)
        row.best:SetWidth(56)
        row.bar = row:CreateTexture(nil, "ARTWORK")
        row.bar:SetHeight(6)
        row.bar:SetPoint("RIGHT", row.best, "LEFT", -8, 0)
        row.bar:SetWidth(BAR_WIDTH)
        row.bar:SetColorTexture(Colors.Chip:GetRGBA())
        row.barFill = row:CreateTexture(nil, "ARTWORK", nil, 1)
        row.barFill:SetHeight(6)
        row.barFill:SetPoint("LEFT", row.bar, "LEFT")
        row.barFill:SetColorTexture(Colors.CardBorder:GetRGB())
        row.barBest = row:CreateTexture(nil, "ARTWORK", nil, 2)
        row.barBest:SetSize(2, 12)
        row.barBest:SetColorTexture(Colors.QuestGold:GetRGB())
        row.name:SetPoint("RIGHT", row.bar, "LEFT", -8, 0)
        row:SetScript("OnEnter", Row_OnEnter)
        row:SetScript("OnLeave", GameTooltip_Hide)
        GW.AddListItemChildHoverTexture(row)
    end
    local boss, data = elementData.boss, elementData.boss.data
    row.boss = boss
    local last = data.last or data.best
    row.name:SetText(GetBossName(boss.id, data))
    row.best:SetText(GW.FormatEncounterTime(data.best, boss.precise))
    row.delta:SetText(FormatDelta(last - data.best))
    row.kills:SetText(data.kills and data.kills > 0 and data.kills .. "x" or "")
    -- one kill has nothing to compare
    local compare = (data.kills or 0) > 1
    row.bar:SetShown(compare)
    row.barFill:SetShown(compare)
    row.barBest:SetShown(compare)
    row.barFill:SetWidth(math.max(1, BAR_WIDTH * math.min(1, BEST_MARK * last / data.best)))
    row.barBest:SetPoint("CENTER", row.bar, "LEFT", BAR_WIDTH * BEST_MARK, 0)
    row.Background:SetAlpha(elementData.index % 2 == 1 and 0.3 or 0)
end

local function UpdateDetail(instance)
    local detail = page.detail
    local entry = GetSelectedEntry(instance)
    detail.instance, detail.entry = instance, entry

    SetArt(detail.art, instance.art, DETAIL_WIDTH, BANNER_HEIGHT)
    detail.title:SetText(instance.name)
    UpdateLevels(instance, entry)
    -- three tiles across the width of the banner; the list hangs below them, so they always need a width
    local tileWidth = math.max(1, (detail.banner:GetWidth() - 16) / 3)
    for _, tile in ipairs(detail.tiles) do
        tile:SetWidth(tileWidth)
    end
    UpdateTiles(instance, entry)

    local isKey = instance.kind == "mplus"
    detail.timeline:SetShown(isKey)
    detail.header:ClearAllPoints()
    detail.header:SetPoint("TOPLEFT", isKey and detail.timeline or detail.tiles[1], "BOTTOMLEFT", 0, isKey and -18 or -10)
    detail.header:SetPoint("RIGHT", detail, "RIGHT", -12, 0)
    if isKey then
        UpdateTimeline(instance, entry)
    end

    local dataProvider = CreateDataProvider()
    for index, boss in ipairs(entry.bosses) do
        dataProvider:Insert({boss = boss, index = index})
    end
    detail.ScrollBox:SetDataProvider(dataProvider)
end

function GW.UpdateBossTimesPage()
    if not (page and page:IsShown()) then return end
    page.searchText = strtrim(page.search:GetText()):lower()
    local instances = BuildInstances(page.searchText, page.filter)

    local selected
    for _, instance in ipairs(instances) do
        if instance.id == selectedInstance then selected = instance end
    end
    selected = selected or instances[1]
    selectedInstance = selected and selected.id

    local dataProvider, lastKind = CreateDataProvider(), nil
    for _, instance in ipairs(instances) do
        if instance.kind ~= lastKind then
            dataProvider:Insert({kind = instance.kind})
            lastKind = instance.kind
        end
        dataProvider:Insert({instance = instance})
    end
    page.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)

    page.detail:SetShown(selected ~= nil)
    if selected then
        UpdateDetail(selected)
    end
    local hasTimes = next(GW.private.encounterTimes or {}) ~= nil
    page.empty:SetText(hasTimes and L["No matching Boss Times."] or L["No Boss Times yet."])
    page.empty:SetShown(selected == nil)
end

---------- layout ----------
local function UpdateFilters()
    for _, tab in ipairs(page.filters) do
        GW.SetTextTab(tab, tab.text, tab.kind == page.filter)
    end
end

-- the filters wrap inside the list column
local function CreateFilters()
    local filters = {{false, ALL}, {"raid", RAIDS}, {"party", DUNGEONS}}
    if GW.Retail or GW.Mists then
        tinsert(filters, 2, {"mplus", GW.Retail and PLAYER_DIFFICULTY_MYTHIC_PLUS or CHALLENGES})
    end
    if GW.Retail then
        tinsert(filters, {"delve", L["Delves"]})
    end

    page.filters = {}
    local x, y = 0, 0
    for index, filter in ipairs(filters) do
        local tab = CreateFrame("Button", nil, page)
        tab.kind, tab.text = filter[1], filter[2]
        tab:SetHeight(20)
        GW.AddTextTabArt(tab)
        GW.SetTextTab(tab, tab.text, false)
        tab:SetScript("OnClick", function()
            page.filter = tab.kind
            UpdateFilters()
            GW.UpdateBossTimesPage()
        end)
        tab:SetScript("OnEnter", UpdateFilters)
        tab:SetScript("OnLeave", UpdateFilters)
        if x > 0 and x + tab:GetWidth() > LIST_WIDTH then
            x, y = 0, y + 22
        end
        tab:SetPoint("TOPLEFT", page.search, "BOTTOMLEFT", x - 4, -6 - y)
        x = x + tab:GetWidth() + 4
        page.filters[index] = tab
    end
    page.filter = false
    page.filtersHeight = y + 26
    UpdateFilters()
end

local function CreateList()
    local search = CreateFrame("EditBox", nil, page, "GwEditBoxTemplate")
    search:SetHeight(22)
    search:SetWidth(LIST_WIDTH)
    search:SetPoint("TOPLEFT", 10, -10)
    GW.SkinEditBox(search, {search = true})
    search:SetScript("OnEnterPressed", search.ClearFocus)
    search:HookScript("OnTextChanged", GW.UpdateBossTimesPage)
    page.search = search

    CreateFilters()

    page.ScrollBox = CreateFrame("Frame", nil, page, "WowScrollBoxList")
    page.ScrollBox:SetPoint("TOPLEFT", search, "BOTTOMLEFT", 0, -6 - page.filtersHeight)
    page.ScrollBox:SetPoint("BOTTOM", 0, 0)
    page.ScrollBox:SetWidth(LIST_WIDTH)
    page.ScrollBar = CreateFrame("EventFrame", nil, page, "MinimalScrollBar")
    page.ScrollBar:SetPoint("TOPLEFT", page.ScrollBox, "TOPRIGHT", 3, 0)
    page.ScrollBar:SetPoint("BOTTOMLEFT", page.ScrollBox, "BOTTOMRIGHT", 3, 0)

    local view = CreateScrollBoxListLinearView(0, 0, 0, 0, 4)
    view:SetElementExtentCalculator(function(_, elementData)
        return elementData.kind and KIND_HEIGHT or CARD_HEIGHT
    end)
    view:SetElementInitializer("Button", InitCard)
    ScrollUtil.InitScrollBoxListWithScrollBar(page.ScrollBox, page.ScrollBar, view)
    GW.SkinSlimScrollBar(page.ScrollBar)
end

local function CreateDetail()
    local detail = CreateFrame("Frame", nil, page)
    detail:SetPoint("TOPLEFT", page.search, "TOPRIGHT", 16, 0)
    detail:SetPoint("BOTTOMRIGHT", 0, 0)
    page.detail = detail

    detail.banner = CreateFrame("Frame", nil, detail)
    detail.banner:SetPoint("TOPLEFT")
    detail.banner:SetPoint("RIGHT", -12, 0)
    detail.banner:SetHeight(BANNER_HEIGHT)
    detail.art = detail.banner:CreateTexture(nil, "BACKGROUND")
    detail.art:SetAllPoints()
    detail.art:SetAlpha(0.6)
    CreateBorder(detail.banner, Colors.HeaderBorder)
    detail.title = CreateText(detail.banner, GW.Enum.TextSizeType.BigHeader, "LEFT", DAMAGE_TEXT_FONT)
    detail.title:SetPoint("TOPLEFT", 12, -10)
    detail.levels = {}

    -- removes the times of the shown level or difficulty
    detail.delete = CreateFrame("Button", nil, detail.banner)
    detail.delete:SetHeight(20)
    detail.delete:SetPoint("TOPRIGHT", -6, -8)
    GW.AddTextTabArt(detail.delete)
    local function UpdateDelete() GW.SetTextTab(detail.delete, DELETE, false) end
    detail.delete:SetScript("OnEnter", UpdateDelete)
    detail.delete:SetScript("OnLeave", UpdateDelete)
    UpdateDelete()
    detail.delete:SetScript("OnClick", function()
        local instance, entry = detail.instance, detail.entry
        GW.ShowPopup({
            text = L["Delete the boss times of %s?"]:format(instance.name .. " " .. entry.label),
            OnAccept = function()
                GW.private.encounterTimes[entry.key] = nil
                GW.UpdateBossTimesPage()
            end,
            button1 = ACCEPT,
            button2 = CANCEL,
        })
    end)
    detail.title:SetPoint("RIGHT", detail.delete, "LEFT", -8, 0)

    detail.tiles = {}
    for index = 1, 3 do
        local tile = CreateFrame("Frame", nil, detail)
        tile:SetSize(100, 54)
        local background = tile:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints()
        background:SetColorTexture(Colors.Chip:GetRGBA())
        tile.label = CreateText(tile, GW.Enum.TextSizeType.Small)
        tile.label:SetPoint("TOPLEFT", 8, -6)
        tile.value = CreateText(tile, GW.Enum.TextSizeType.Header, "LEFT", DAMAGE_TEXT_FONT)
        tile.value:SetPoint("TOPLEFT", tile.label, "BOTTOMLEFT", 0, -3)
        tile.sub = CreateText(tile, GW.Enum.TextSizeType.Small)
        tile.sub:SetPoint("TOPLEFT", tile.value, "BOTTOMLEFT", 0, -2)
        if index == 1 then
            tile:SetPoint("TOPLEFT", detail.banner, "BOTTOMLEFT", 0, -10)
        else
            tile:SetPoint("TOPLEFT", detail.tiles[index - 1], "TOPRIGHT", 8, 0)
        end
        detail.tiles[index] = tile
    end

    local timeline = CreateFrame("Frame", nil, detail)
    timeline:SetPoint("TOPLEFT", detail.tiles[1], "BOTTOMLEFT", 0, -22)
    timeline:SetPoint("RIGHT", -12, 0)
    timeline:SetHeight(14)
    timeline.track = timeline:CreateTexture(nil, "BACKGROUND")
    timeline.track:SetPoint("LEFT")
    timeline.track:SetPoint("RIGHT")
    timeline.track:SetHeight(6)
    timeline.track:SetColorTexture(Colors.Chip:GetRGBA())
    timeline.fill = timeline:CreateTexture(nil, "ARTWORK")
    timeline.fill:SetPoint("LEFT", timeline.track, "LEFT")
    timeline.fill:SetHeight(6)
    timeline.fill:SetColorTexture(Colors.QuestGold:GetRGB())
    timeline.limit = CreateText(timeline, GW.Enum.TextSizeType.Small, "RIGHT")
    timeline.limit:SetPoint("BOTTOMRIGHT", timeline, "TOPRIGHT", 0, 2)
    timeline.marks = {}
    detail.timeline = timeline

    detail.header = CreateFrame("Frame", nil, detail)
    detail.header:SetHeight(18)
    local columns = {{BOSS, "LEFT", 10}, {L["Kills"], "RIGHT", -6}, {L["Best"], "RIGHT", -84}}
    for _, column in ipairs(columns) do
        local text = CreateText(detail.header, GW.Enum.TextSizeType.Small, column[2])
        text:SetPoint(column[2], column[3], 0)
        text:SetText(Colors.SubText:WrapTextInColorCode(column[1]))
    end

    detail.ScrollBox = CreateFrame("Frame", nil, detail, "WowScrollBoxList")
    detail.ScrollBox:SetPoint("TOPLEFT", detail.header, "BOTTOMLEFT", 0, -2)
    detail.ScrollBox:SetPoint("BOTTOMRIGHT", -12, 24)

    -- what the bars of the list show
    local legend = CreateFrame("Frame", nil, detail)
    legend:SetPoint("BOTTOMLEFT", 10, 6)
    legend:SetPoint("RIGHT", -12, 0)
    legend:SetHeight(14)
    local lastSwatch = legend:CreateTexture(nil, "ARTWORK")
    lastSwatch:SetSize(16, 6)
    lastSwatch:SetPoint("LEFT")
    lastSwatch:SetColorTexture(Colors.CardBorder:GetRGB())
    local lastText = CreateText(legend, GW.Enum.TextSizeType.Small)
    lastText:SetPoint("LEFT", lastSwatch, "RIGHT", 4, 0)
    lastText:SetText(Colors.SubText:WrapTextInColorCode(L["Last"]))
    local bestSwatch = legend:CreateTexture(nil, "ARTWORK")
    bestSwatch:SetSize(2, 12)
    bestSwatch:SetPoint("LEFT", lastText, "RIGHT", 12, 0)
    bestSwatch:SetColorTexture(Colors.QuestGold:GetRGB())
    local bestText = CreateText(legend, GW.Enum.TextSizeType.Small)
    bestText:SetPoint("LEFT", bestSwatch, "RIGHT", 4, 0)
    bestText:SetText(Colors.SubText:WrapTextInColorCode(L["Best"]))
    local scaleText = CreateText(legend, GW.Enum.TextSizeType.Small)
    scaleText:SetPoint("LEFT", bestText, "RIGHT", 12, 0)
    scaleText:SetPoint("RIGHT")
    scaleText:SetText(Colors.SubText:WrapTextInColorCode(L["Bars compared to the own best time"]))

    local listBackground = GW.CreateDetailsBackgroundTexture(detail)
    listBackground:SetPoint("TOPLEFT", detail.header, "TOPLEFT", 0, 0)
    listBackground:SetPoint("BOTTOMRIGHT", detail.ScrollBox, "BOTTOMRIGHT", 0, 0)
    detail.ScrollBar = CreateFrame("EventFrame", nil, detail, "MinimalScrollBar")
    detail.ScrollBar:SetPoint("TOPLEFT", detail.ScrollBox, "TOPRIGHT", 3, 0)
    detail.ScrollBar:SetPoint("BOTTOMLEFT", detail.ScrollBox, "BOTTOMRIGHT", 3, 0)
    local view = CreateScrollBoxListLinearView()
    view:SetElementExtent(ROW_HEIGHT)
    view:SetElementInitializer("Button", InitRow)
    ScrollUtil.InitScrollBoxListWithScrollBar(detail.ScrollBox, detail.ScrollBar, view)
    GW.SkinSlimScrollBar(detail.ScrollBar)
end

function GW.CreateBossTimesPage(parent)
    page = CreateFrame("Frame", nil, parent)
    page:SetSize(580, 576)
    page:SetPoint("TOPLEFT", -2, -10)
    page:Hide()
    page.searchText = ""

    CreateList()
    CreateDetail()

    page.empty = page:CreateFontString(nil, "OVERLAY")
    page.empty:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    page.empty:SetPoint("TOP", page.detail, "TOP", 0, -72)

    page:SetScript("OnShow", GW.UpdateBossTimesPage)
    return page
end
