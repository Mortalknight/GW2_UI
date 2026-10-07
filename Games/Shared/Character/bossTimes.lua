---@class GW2
local GW = select(2, ...)
local L = GW.L

-- boss times page in the currency tab, filled from GW.private.encounterTimes (Objectives/encounterTimes.lua)
local ARROW_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png"
local HEADER_HEIGHT, ROW_HEIGHT = 32, 24
local KIND_ORDER = {mplus = 1, raid = 2, party = 3}
local expanded = {}
local page

local function FormatDate(timestamp)
    local d = date("*t", timestamp)
    return FormatShortDate(d.day, d.month, d.year % 100)
end

local function GetGroupInfo(key)
    local kind, mapID, value = strsplit(":", key)
    mapID, value = tonumber(mapID), tonumber(value)
    if kind == "mplus" then
        local difficulty = value > 0 and "+" .. value or GetDifficultyInfo(DifficultyUtil.ID.DungeonChallenge) or ""
        return kind, C_ChallengeMode.GetMapUIInfo(mapID) or UNKNOWN, difficulty, value
    end
    return kind, GetRealZoneText(mapID) or UNKNOWN, GetDifficultyInfo(value) or "", value
end

local function GetBossName(id, data)
    if id == "forces" then return L["Enemy Forces"] end
    if id == "total" then return L["Total"] end
    return data.name or ("#" .. id)
end

-- forces and total come last, the bosses in the order of their first kill
local function SortBosses(a, b)
    local aLast, bLast = type(a.id) ~= "number", type(b.id) ~= "number"
    if aLast ~= bLast then return bLast end
    if aLast then return a.id == "forces" end
    return (a.data.firstDate or a.data.bestDate or 0) < (b.data.firstDate or b.data.bestDate or 0)
end

local function SortGroups(a, b)
    if a.kind ~= b.kind then return KIND_ORDER[a.kind] < KIND_ORDER[b.kind] end
    if a.name ~= b.name then return a.name < b.name end
    return a.value > b.value
end

local function Matches(text, search)
    return search == "" or text:lower():find(search, 1, true) ~= nil
end

local function BuildDataProvider(search, filter)
    local groups = {}
    for key, store in pairs(GW.private.encounterTimes or {}) do
        local kind, name, difficulty, value = GetGroupInfo(key)
        if KIND_ORDER[kind] and (not filter or filter == kind) then
            local group = {key = key, kind = kind, name = name, difficulty = difficulty, value = value or 0, bosses = {}}
            local groupMatches = Matches(name .. " " .. difficulty, search)
            for id, data in pairs(store) do
                if type(data) == "table" and data.best and not (type(id) == "string" and id:find("^fight:"))
                    and (groupMatches or Matches(GetBossName(id, data), search)) then
                    tinsert(group.bosses, {id = id, data = data, fight = store["fight:" .. tostring(id)], precise = kind ~= "mplus" or id == "total"})
                end
            end
            if #group.bosses > 0 then
                sort(group.bosses, SortBosses)
                tinsert(groups, group)
            end
        end
    end
    sort(groups, SortGroups)

    local dataProvider = CreateDataProvider()
    for _, group in ipairs(groups) do
        dataProvider:Insert({header = true, group = group})
        if expanded[group.key] or search ~= "" then
            for index, boss in ipairs(group.bosses) do
                dataProvider:Insert({boss = boss, index = index})
            end
        end
    end
    return dataProvider, #groups
end

local function Row_OnClick(self)
    if self.elementData.header and page.searchText == "" then
        local key = self.elementData.group.key
        expanded[key] = not expanded[key]
        GW.UpdateBossTimesPage()
    end
end

local function Row_OnEnter(self)
    local boss = self.elementData.boss
    if not boss then return end
    local data = boss.data
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:AddLine(GetBossName(boss.id, data), 1, 1, 1)
    GameTooltip:AddDoubleLine(L["Best"], GW.FormatEncounterTime(data.best, boss.precise) .. (data.bestDate and " (" .. FormatDate(data.bestDate) .. ")" or ""), nil, nil, nil, 1, 1, 1)
    if data.last then
        GameTooltip:AddDoubleLine(L["Last"], GW.FormatEncounterTime(data.last, boss.precise), nil, nil, nil, 1, 1, 1)
    end
    if boss.fight and boss.fight.best then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Fight duration"], 1, 1, 1)
        GameTooltip:AddDoubleLine(L["Best"], GW.FormatEncounterTime(boss.fight.best, true), nil, nil, nil, 1, 1, 1)
        GameTooltip:AddDoubleLine(L["Last"], GW.FormatEncounterTime(boss.fight.last, true), nil, nil, nil, 1, 1, 1)
    end
    GameTooltip:Show()
end

local function CreateText(row, size, justify)
    local text = row:CreateFontString(nil, "OVERLAY")
    text:GwSetFontTemplate(UNIT_NAME_FONT, size)
    text:SetJustifyH(justify)
    text:SetWordWrap(false)
    return text
end

local function InitRow(row, elementData)
    if not row.name then
        row.arrow = row:CreateTexture(nil, "ARTWORK")
        row.arrow:SetTexture(ARROW_TEXTURE)
        row.arrow:SetSize(20, 20)
        row.arrow:SetPoint("LEFT", 6, 0)
        row.name = CreateText(row, GW.Enum.TextSizeType.Normal, "LEFT")
        row.kills = CreateText(row, GW.Enum.TextSizeType.Normal, "RIGHT")
        row.kills:SetPoint("RIGHT", -24, 0)
        row.kills:SetWidth(50)
        row.last = CreateText(row, GW.Enum.TextSizeType.Normal, "RIGHT")
        row.last:SetPoint("RIGHT", row.kills, "LEFT", -10, 0)
        row.last:SetWidth(70)
        row.best = CreateText(row, GW.Enum.TextSizeType.Normal, "RIGHT")
        row.best:SetPoint("RIGHT", row.last, "LEFT", -10, 0)
        row.best:SetWidth(70)
        row:SetScript("OnClick", Row_OnClick)
        row:SetScript("OnEnter", Row_OnEnter)
        row:SetScript("OnLeave", GameTooltip_Hide)
        GW.AddListItemChildHoverTexture(row)
    end
    row.elementData = elementData

    local isHeader = elementData.header == true
    row.arrow:SetShown(isHeader)
    row.name:ClearAllPoints()
    row.name:SetPoint("LEFT", isHeader and 30 or 12, 0)
    row.name:SetPoint("RIGHT", row.best, "LEFT", -10, 0)

    if isHeader then
        local group = elementData.group
        row.arrow:SetRotation((expanded[group.key] or page.searchText ~= "") and 0 or math.pi / 2)
        row.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        row.name:SetText(group.name .. " " .. GW.Colors.SkinColors.SubText:WrapTextInColorCode(group.difficulty))
        row.best:SetText(GW.Colors.SkinColors.SubText:WrapTextInColorCode(L["Best"]))
        row.last:SetText(GW.Colors.SkinColors.SubText:WrapTextInColorCode(L["Last"]))
        row.kills:SetText(GW.Colors.SkinColors.SubText:WrapTextInColorCode(L["Kills"]))
        row.Background:SetAlpha(1)
    else
        local boss, data = elementData.boss, elementData.boss.data
        row.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        row.name:SetText(GetBossName(boss.id, data))
        row.best:SetText(GW.Colors.SkinColors.QuestGold:WrapTextInColorCode(GW.FormatEncounterTime(data.best, boss.precise)))
        row.last:SetText(data.last and GW.FormatEncounterTime(data.last, boss.precise) or "")
        row.kills:SetText(data.kills and data.kills > 0 and data.kills .. "x" or "")
        row.Background:SetAlpha(elementData.index % 2 == 1 and 0.3 or 0)
    end
end

function GW.UpdateBossTimesPage()
    if not (page and page:IsShown()) then return end
    page.searchText = strtrim(page.search:GetText()):lower()
    local dataProvider, numGroups = BuildDataProvider(page.searchText, page.filter)
    page.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
    local hasTimes = next(GW.private.encounterTimes or {}) ~= nil
    page.empty:SetText(hasTimes and L["No matching boss times."] or L["No boss times yet."])
    page.empty:SetShown(numGroups == 0)
end

local function UpdateTabs()
    for _, tab in ipairs(page.tabs) do
        GW.SetTextTab(tab, tab.text, tab.kind == page.filter)
    end
end

local function CreateFilterTabs()
    page.tabs = {}
    local filters = {{false, ALL}, {"raid", RAIDS}, {"party", DUNGEONS}}
    -- retail has keystones, mists its challenge modes; the other modern clients know the api without either
    if GW.Retail or GW.Mists then
        tinsert(filters, 2, {"mplus", GW.Retail and PLAYER_DIFFICULTY_MYTHIC_PLUS or CHALLENGES})
    end
    for i = #filters, 1, -1 do
        local tab = CreateFrame("Button", nil, page)
        tab.kind, tab.text = filters[i][1], filters[i][2]
        tab:SetHeight(22)
        GW.AddTextTabArt(tab)
        tab:SetScript("OnClick", function()
            page.filter = tab.kind
            UpdateTabs()
            GW.UpdateBossTimesPage()
        end)
        tab:SetScript("OnEnter", UpdateTabs)
        tab:SetScript("OnLeave", UpdateTabs)
        if i == #filters then
            tab:SetPoint("TOPRIGHT", -22, -10)
        else
            tab:SetPoint("RIGHT", page.tabs[i + 1], "LEFT", -6, 0)
        end
        page.tabs[i] = tab
    end
    page.filter = false
    UpdateTabs()
end

local function CreateSearch()
    local search = CreateFrame("EditBox", nil, page, "GwSearchBoxTemplate")
    search:SetHeight(22)
    search:SetPoint("TOPLEFT", 10, -10)
    search:SetPoint("RIGHT", page.tabs[1], "LEFT", -10, 0)
    search.Instructions:SetTextColor(0.5, 0.5, 0.5)
    search.Instructions:SetText(SEARCH .. "...")
    search:HookScript("OnTextChanged", function(self)
        self.clearButton:SetShown(self:GetText() ~= "")
        GW.UpdateBossTimesPage()
    end)
    search:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)
    search:SetScript("OnEnterPressed", EditBox_ClearFocus)
    search.clearButton:SetScript("OnClick", function(self)
        self:GetParent():SetText("")
        self:GetParent():ClearFocus()
    end)
    page.search = search
end

function GW.CreateBossTimesPage(parent)
    page = CreateFrame("Frame", nil, parent)
    page:SetSize(580, 576)
    page:SetPoint("TOPLEFT", -2, -10)
    page:Hide()
    page.searchText = ""

    CreateFilterTabs()
    CreateSearch()

    page.ScrollBox = CreateFrame("Frame", nil, page, "WowScrollBoxList")
    page.ScrollBox:SetPoint("TOPLEFT", 4, -42)
    page.ScrollBox:SetPoint("BOTTOMRIGHT", -22, 0)
    page.ScrollBar = CreateFrame("EventFrame", nil, page, "MinimalScrollBar")
    page.ScrollBar:SetPoint("TOPLEFT", page.ScrollBox, "TOPRIGHT", 4, 0)
    page.ScrollBar:SetPoint("BOTTOMLEFT", page.ScrollBox, "BOTTOMRIGHT", 4, 0)

    local view = CreateScrollBoxListLinearView()
    view:SetElementExtentCalculator(function(_, elementData)
        return elementData.header and HEADER_HEIGHT or ROW_HEIGHT
    end)
    view:SetElementInitializer("Button", InitRow)
    ScrollUtil.InitScrollBoxListWithScrollBar(page.ScrollBox, page.ScrollBar, view)
    GW.HandleTrimScrollBar(page.ScrollBar)
    GW.HandleScrollControls(page)
    page.ScrollBar:SetHideIfUnscrollable(true)

    page.empty = page:CreateFontString(nil, "OVERLAY")
    page.empty:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    page.empty:SetPoint("TOP", 0, -72)

    page:SetScript("OnShow", GW.UpdateBossTimesPage)
    return page
end
