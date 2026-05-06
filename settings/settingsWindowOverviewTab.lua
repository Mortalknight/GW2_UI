---@class GW2
local GW = select(2, ...)

local L = GW.L

local CreditsSection = {
    GW.Gw2Color .. L["Created by: "]:gsub(":", "")  .. "|r",
    GW.Gw2Color .. L["Developed by"] .. "|r",
    GW.Gw2Color .. L["With Contributions by"] .. "|r",
    GW.Gw2Color .. L["Localised by"] .. "|r",
    GW.Gw2Color .. L["QA Testing by"] .. "|r",
}

local CREDITS = {
    OWNER = {"Aethelwulf"},
    DEVELOPER = {"Glow", "Nezroy", "Shrugal", "Shoodox"},
    CONTRIBUTION = {"Hatdragon"},
    LOCALIZATION = {"aSlightDrizzle", "Calcifer", "Murak", "AxelVader", "Crisll", "Dololo", "Kitto", "Pyrefox", "RickCiotti", "Throli", "Zelrog"},
    TESTING = {"Crohnleuchter", "KYZ", "Ultrachocobo", "Belazor", "Zerid"}
}

local function SortAndInsertCredits()
    local creditKeys = {"OWNER", "DEVELOPER", "CONTRIBUTION", "LOCALIZATION", "TESTING"}
    for _, key in ipairs(creditKeys) do
        local category = CREDITS[key]
        if category then
            sort(category)
            for _, name in ipairs(category) do
                tinsert(GW.CreditsList, name)
            end
        end
    end
end

SortAndInsertCredits()
local welcome_OnClick = function()
    HideUIPanel(GwSettingsWindow)
    GW.ShowWelcomePanel()
end

local statusReport_OnClick = function()
    HideUIPanel(GwSettingsWindow)
    GW.ShowStatusReport()
end

local function getChangeLogIcon(self, tag)
    self:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/changelogicons.png")
    if tonumber(tag) == GW.Enum.ChangelogType.bug then
        self:SetTexCoord(0, 0.5, 0, 0.5)
    elseif tonumber(tag) == GW.Enum.ChangelogType.feature then
        self:SetTexCoord(0.5, 1, 0, 0.5)
    else
        self:SetTexCoord(0, 0.5, 0.5, 1)
    end
end
local function getCreditsIcon(self, type)
    self:SetTexCoord(0, 1, 0, 1)
    self:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/credits_" .. (type and type:lower() or "") .. ".png")
end

local CHANGELOG_GROUP_ORDER = {
    GW.Enum.ChangelogType.feature,
    GW.Enum.ChangelogType.change,
    GW.Enum.ChangelogType.bug
}

local CREDITS_NAME_COLOR = {0.70, 0.64, 0.54, 1}
local CHANGELOG_COLLAPSED_VERSIONS = {}
local CHANGELOG_COLLAPSED_GROUPS = {}
local CHANGELOG_COLLAPSE_INIT = false
local OVERVIEW_SCROLL_RELEASE_ANIM_DURATION = 0.18
local OVERVIEW_SCROLL_RELEASE_ANIM_NAME = "SETTINGS_OVERVIEW_SCROLL_RELEASE"

local function GetChangeLogGroupLabel(changeType)
    if changeType == GW.Enum.ChangelogType.feature then
        return L["New Features"]
    elseif changeType == GW.Enum.ChangelogType.change then
        return L["Changes"]
    end

    return L["Fixes"]
end

local function GetGroupCollapseKey(version, changeType)
    return (version or "") .. "|" .. tostring(changeType or "")
end

local function EnsureChangelogCollapseDefaults()
    if CHANGELOG_COLLAPSE_INIT then
        return
    end

    for index, line in ipairs(GW.changelog) do
        if line and line.version ~= nil and CHANGELOG_COLLAPSED_VERSIONS[line.version] == nil then
            CHANGELOG_COLLAPSED_VERSIONS[line.version] = index ~= 1
        end
    end

    CHANGELOG_COLLAPSE_INIT = true
end

local function NormalizeSearchQuery(query)
    query = strtrim((query or ""):lower())
    if query == "" or query == SEARCH:lower() then
        return ""
    end
    return query
end

local function ConvertChangeLogSearchTable(query)
    local table = {}
    local normalizedQuery = NormalizeSearchQuery(query)

    for _, line in ipairs(GW.changelog) do
        local version = tostring(line.version or "")
        local versionMatch = version:lower():find(normalizedQuery, 1, true) ~= nil

        for _, change in ipairs(line.changes or {}) do
            local changeText = tostring(change[2] or "")
            local textMatch = changeText:lower():find(normalizedQuery, 1, true) ~= nil
            if normalizedQuery == "" or versionMatch or textMatch then
                tinsert(table, {
                    kind = "entry",
                    version = version,
                    changeType = change[1],
                    text = format("[%s] %s", version, changeText)
                })
            end
        end
    end

    if #table == 0 then
        tinsert(table, {
            kind = "typeHeader",
            text = SETTINGS_SEARCH_NOTHING_FOUND or NOT_FOUND or "No results found",
            changeType = GW.Enum.ChangelogType.change
        })
    end

    return table
end

local function ConvertChangeLogTableToOneTable()
    EnsureChangelogCollapseDefaults()

    local table = {}
    for _, line in ipairs(GW.changelog) do
        local version = line.version
        local groupedChanges = {
            [GW.Enum.ChangelogType.feature] = {},
            [GW.Enum.ChangelogType.change] = {},
            [GW.Enum.ChangelogType.bug] = {}
        }

        for _, change in ipairs(line.changes or {}) do
            local changeType = change[1]
            if not groupedChanges[changeType] then
                groupedChanges[changeType] = {}
            end
            tinsert(groupedChanges[changeType], change[2])
        end

        local featureCount = #groupedChanges[GW.Enum.ChangelogType.feature]
        local changeCount = #groupedChanges[GW.Enum.ChangelogType.change]
        local bugCount = #groupedChanges[GW.Enum.ChangelogType.bug]

        tinsert(table, {
            kind = "version",
            version = version,
            text = line.version,
            summaryText = format("• %d %s | %d %s | %d %s", featureCount, L["New Features"], changeCount, L["Changes"] or "Changes", bugCount, L["Fixes"] or "Fixes")
        })

        local isVersionCollapsed = CHANGELOG_COLLAPSED_VERSIONS[version] == true
        if not isVersionCollapsed then
            for _, changeType in ipairs(CHANGELOG_GROUP_ORDER) do
                local entries = groupedChanges[changeType]
                if entries and #entries > 0 then
                    local groupKey = GetGroupCollapseKey(version, changeType)
                    tinsert(table, {
                        kind = "typeHeader",
                        version = version,
                        changeType = changeType,
                        text = format("%s (%d)", GetChangeLogGroupLabel(changeType), #entries)
                    })

                    if not CHANGELOG_COLLAPSED_GROUPS[groupKey] then
                        for _, text in ipairs(entries) do
                            tinsert(table, {kind = "entry", version = version, changeType = changeType, text = text})
                        end
                    end
                end
            end
        end

    end

    return table
end

local function ConvertCreditsTableToOneTable()
    local table = {}
    local creditKeys = {"OWNER", "DEVELOPER", "CONTRIBUTION", "LOCALIZATION", "TESTING"}

    for i = 1, #CreditsSection do
        local contentTable = CREDITS[creditKeys[i]] or {}
        tinsert(table, {
            kind = "creditsHeader",
            name = CreditsSection[i],
            category = creditKeys[i]
        })

        for idx = 1, #contentTable, 2 do
            tinsert(table, {
                kind = "creditsEntry",
                leftName = contentTable[idx],
                rightName = contentTable[idx + 1],
                category = creditKeys[i]
            })
        end
    end

    return table
end

local function UpdateScrollBox(self, type)
    local dataProvider = CreateDataProvider()

    if type == "changelog" then
        self:GetParent().header:SetText(L["Changelog"])

        local sourceData
        local query = NormalizeSearchQuery(self:GetParent().searchQuery)
        if query ~= "" then
            sourceData = ConvertChangeLogSearchTable(query)
        else
            sourceData = ConvertChangeLogTableToOneTable()
        end

        local visibleEntryIndex = 0
        for index, line in ipairs(sourceData) do
            line.index = index
            line.type = type
            line.owner = self
            if line.kind == "entry" then
                visibleEntryIndex = visibleEntryIndex + 1
                line.zebraIndex = visibleEntryIndex
            else
                line.zebraIndex = nil
            end
            dataProvider:Insert(line)
        end
    elseif type == "credits" then
        self:GetParent().header:SetText(L["Credits"])

        for index, line in ipairs(ConvertCreditsTableToOneTable()) do
            line.index = index
            line.type = type
            dataProvider:Insert(line)
        end
    end

    self:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end

local function UpdateOverviewScrollFx(source)
    local settingsOverview
    if source and source.pageblock and source.ScrollBar then
        settingsOverview = source
    elseif source and source.GetParent then
        local p = source:GetParent()
        if p and p.pageblock and p.ScrollBar then
            settingsOverview = p
        elseif p and p.GetParent then
            local pp = p:GetParent()
            if pp and pp.pageblock and pp.ScrollBar then
                settingsOverview = pp
            end
        end
    end

    if not settingsOverview or not settingsOverview.ScrollBar then
        return
    end

    -- Avoid re-anchoring/re-sizing while mouse is held down (especially scrollbar thumb drag).
    -- Defer one update until after mouse release to prevent stuck drag state.
    if IsMouseButtonDown("LeftButton") then
        settingsOverview.pendingOverviewScrollFx = true
        if not settingsOverview:GetScript("OnUpdate") then
            settingsOverview:SetScript("OnUpdate", function(self)
                if self.pendingOverviewScrollFx and not IsMouseButtonDown("LeftButton") then
                    UpdateOverviewScrollFx(self.ScrollBar)
                end
            end)
        end
        return
    end
    local wasDeferredByMouseDown = settingsOverview.pendingOverviewScrollFx == true
    settingsOverview.pendingOverviewScrollFx = false
    if settingsOverview:GetScript("OnUpdate") then
        settingsOverview:SetScript("OnUpdate", nil)
    end

    local maxGrowUp = 200
    local progress = 0


    local firstVisibleIndex
    settingsOverview.ScrollBox:ForEachFrame(function(_, elementData)
        local idx = elementData and elementData.index
        if idx and (not firstVisibleIndex or idx < firstVisibleIndex) then
            firstVisibleIndex = idx
        end
    end)

    local totalItems = 0
    local dataProvider = settingsOverview.ScrollBox:GetDataProvider()
    if dataProvider then
        if dataProvider.GetSize then
            totalItems = dataProvider:GetSize() or 0
        elseif dataProvider.Enumerate then
            for _ in dataProvider:Enumerate() do
                totalItems = totalItems + 1
            end
        end
    end

    if firstVisibleIndex and totalItems > 1 then
        progress = math.max(0, math.min(1, (firstVisibleIndex - 1) / (totalItems - 1)))
    end

    local baseHeight = settingsOverview.basePageBlockHeight or settingsOverview.pageblock:GetHeight()
    local maxByVisibleArea = (baseHeight or 0) * 0.5
    local effectiveMaxGrowUp = maxByVisibleArea > 0 and math.min(maxGrowUp, maxByVisibleArea) or maxGrowUp
    local growBy = math.min(effectiveMaxGrowUp, math.max(0, progress * effectiveMaxGrowUp))
    if settingsOverview.lastScrollGrowAmount == growBy then
        return
    end
    settingsOverview.lastScrollGrowAmount = growBy

    -- Keep splash artwork fixed; grow the page block up so header and scroll area move together.
    local targetHeight = math.min(baseHeight + effectiveMaxGrowUp, baseHeight + growBy)
    if wasDeferredByMouseDown then
        local fromHeight = settingsOverview.pageblock:GetHeight() or baseHeight
        if math.abs(targetHeight - fromHeight) > 0.5 then
            GW.AddToAnimation(
                OVERVIEW_SCROLL_RELEASE_ANIM_NAME,
                fromHeight,
                targetHeight,
                GetTime(),
                OVERVIEW_SCROLL_RELEASE_ANIM_DURATION,
                function(p)
                    settingsOverview.pageblock:SetHeight(p)
                end
            )
            return
        end
    end

    settingsOverview.pageblock:SetHeight(targetHeight)
end

local function ResetChangelogSearch(settingsOverview)
    settingsOverview.searchQuery = ""

    local edit = settingsOverview.search.input
    edit:SetText(SEARCH)
    edit:SetTextColor(178 / 255, 178 / 255, 178 / 255)
    edit:ClearFocus()
    if edit.clearButton then
        edit.clearButton:Hide()
    end

    if settingsOverview.currentOverviewType then
        UpdateScrollBox(settingsOverview.ScrollBox, settingsOverview.currentOverviewType)
        UpdateOverviewScrollFx(settingsOverview.ScrollBar)
    end
end

local function ShowChangelog(frame)
    local settingsOverview = frame:GetParent()
    if NormalizeSearchQuery(settingsOverview.searchQuery) ~= "" then
        ResetChangelogSearch(settingsOverview)
    end
    settingsOverview.currentOverviewType = "changelog"
    settingsOverview.search:Show()
    UpdateScrollBox(frame, "changelog")
    settingsOverview.ScrollBar:ScrollToBegin();
    UpdateOverviewScrollFx(frame)
end

local function ShowCredits(frame)
    local settingsOverview = frame:GetParent()
    if NormalizeSearchQuery(settingsOverview.searchQuery) ~= "" then
        ResetChangelogSearch(settingsOverview)
    end
    settingsOverview.currentOverviewType = "credits"
    settingsOverview.search:Hide()
    UpdateScrollBox(frame, "credits")
    settingsOverview.ScrollBar:ScrollToBegin();
    UpdateOverviewScrollFx(frame)
end

local function SetTitleTextAnchors(button, xOffset, yOffset)
    button.title.text:ClearAllPoints()
    button.title.text:SetPoint("TOPLEFT", button.title, "TOPLEFT", xOffset, yOffset)
    button.title.text:SetPoint("TOPRIGHT", button.title, "TOPRIGHT", -6, yOffset)
end

local function InitButton(button, elementData)
    if not button.isSkinned then
        button.title.text:SetFont(DAMAGE_TEXT_FONT, 14)
        button.title.text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        button.title.text:SetJustifyV("TOP")
        button.title.icon = button.title:CreateTexture(nil, "BORDER")
        button.title.icon:SetSize(16, 16)
        button.title.icon:Hide()

        button.content.text:SetFont(UNIT_NAME_FONT, 12)
        button.content.text:SetTextColor(181 / 255, 160 / 255, 128 / 255)
        button.content.text:SetJustifyV("MIDDLE")
        button.content.textRight = button.content:CreateFontString(nil, "BORDER", "GameFontNormalSmall")
        button.content.textRight:SetFont(UNIT_NAME_FONT, 13)
        button.content.textRight:SetTextColor(unpack(CREDITS_NAME_COLOR))
        button.content.textRight:SetJustifyH("LEFT")
        button.content.textRight:SetJustifyV("MIDDLE")
        button.content.textRight:Hide()

        button.content.iconRight = button.content:CreateTexture(nil, "BORDER")
        button.content.iconRight:SetSize(18, 18)
        button.content.iconRight:Hide()
        GW.AddListItemChildHoverTexture(button)

        button.isSkinned = true
    end

    button:SetScript("OnClick", nil)
    SetTitleTextAnchors(button, 5, -5)
    button.title.icon:Hide()
    button.title.text:SetJustifyV("TOP")
    button.title.text:SetFont(DAMAGE_TEXT_FONT, 14)

    -- Reset shared row layout defaults (changelog template) before applying type-specific layout.
    button.content.textRight:Hide()
    button.content.iconRight:Hide()
    button.content.textRight:SetText("")
    button.content.icon:Show()
    button.content.icon:ClearAllPoints()
    button.content.icon:SetPoint("TOPLEFT", button.content, "TOPLEFT", 10, -10)
    button.content.icon:SetSize(16, 16)
    button.content.text:ClearAllPoints()
    button.content.text:SetPoint("TOPLEFT", button.content, "TOPLEFT", 46, -10)
    button.content.text:SetJustifyH("LEFT")
    button.content.text:SetJustifyV("TOP")
    button.content.text:SetFont(UNIT_NAME_FONT, 12)
    button.content.text:SetTextColor(181 / 255, 160 / 255, 128 / 255)

    if elementData.type == "changelog" and elementData.kind == "version" then
        local versionCollapsed = CHANGELOG_COLLAPSED_VERSIONS[elementData.version] == true
        button.content:Hide()
        button.title.text:SetText((versionCollapsed and "[+] " or "[-] ") .. (elementData.text or "") .. "  |cffbfbfbf" .. (elementData.summaryText or "") .. "|r")
        button.title.text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        button.title:Show()
        elementData.isHeader = true
        button:SetScript("OnClick", function()
            CHANGELOG_COLLAPSED_VERSIONS[elementData.version] = not CHANGELOG_COLLAPSED_VERSIONS[elementData.version]
            UpdateScrollBox(elementData.owner, "changelog")
        end)
    elseif elementData.type == "changelog" and elementData.kind == "typeHeader" then
        local groupKey = GetGroupCollapseKey(elementData.version, elementData.changeType)
        local groupCollapsed = CHANGELOG_COLLAPSED_GROUPS[groupKey] == true
        SetTitleTextAnchors(button, 10, -1)
        button.content:Hide()
        button.title.text:SetText((groupCollapsed and "[+] " or "[-] ") .. elementData.text)
        button.title.text:SetTextColor(1, 0.93, 0.73, 1)
        button.title:Show()
        elementData.isHeader = true
        button:SetScript("OnClick", function()
            CHANGELOG_COLLAPSED_GROUPS[groupKey] = not CHANGELOG_COLLAPSED_GROUPS[groupKey]
            UpdateScrollBox(elementData.owner, "changelog")
        end)
    elseif elementData.type == "credits" and elementData.kind == "creditsHeader" then
        button.content:Hide()
        button.title:Show()
        button.title.icon:Show()
        getCreditsIcon(button.title.icon, elementData.category)
        button.title.icon:ClearAllPoints()
        button.title.icon:SetPoint("LEFT", button.title, "LEFT", 8, 0)
        button.title.icon:SetSize(16, 16)

        button.title.text:ClearAllPoints()
        button.title.text:SetPoint("LEFT", button.title.icon, "RIGHT", 8, 0)
        button.title.text:SetPoint("RIGHT", button.title, "RIGHT", -6, 0)
        button.title.text:SetText(elementData.name or "")
        button.title.text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        button.title.text:SetFont(DAMAGE_TEXT_FONT, 13)
        button.title.text:SetJustifyV("MIDDLE")
        elementData.isHeader = true
    else
        if elementData.type == "changelog" then
            button.content.text:SetText(elementData.text or "")
            getChangeLogIcon(button.content.icon, elementData.changeType)
            if elementData.changeType == GW.Enum.ChangelogType.bug then
                button.content.text:SetTextColor(1, 0.75, 0.75, 1)
            elseif elementData.changeType == GW.Enum.ChangelogType.feature then
                button.content.text:SetTextColor(0.78, 0.96, 0.78, 1)
            else
                button.content.text:SetTextColor(1, 0.93, 0.73, 1)
            end
        elseif elementData.type == "credits" then
            button.content.text:SetText(elementData.leftName or elementData.name or "")
            button.content.text:SetTextColor(unpack(CREDITS_NAME_COLOR))
            button.content.text:SetFont(UNIT_NAME_FONT, 13)
            button.content.text:SetJustifyH("LEFT")

            button.content.icon:Hide()

            button.content.text:ClearAllPoints()
            button.content.text:SetPoint("LEFT", button.content, "LEFT", 12, 0)
            button.content.text:SetPoint("RIGHT", button.content, "CENTER", -14, 0)
            button.content.text:SetJustifyV("MIDDLE")

            if elementData.rightName and elementData.rightName ~= "" then
                button.content.iconRight:Hide()

                button.content.textRight:Show()
                button.content.textRight:SetText(elementData.rightName)
                button.content.textRight:ClearAllPoints()
                button.content.textRight:SetPoint("LEFT", button.content, "CENTER", 8, 0)
                button.content.textRight:SetPoint("RIGHT", button.content, "RIGHT", -12, 0)
            else
                button.content.text:SetPoint("RIGHT", button.content, "RIGHT", -12, 0)
            end
        end

        button.title:Hide()
        button.content:Show()
        elementData.isHeader = false
    end

    if elementData.type == "changelog" and elementData.kind == "typeHeader" then
        elementData.neededHeight = 28
    elseif elementData.type == "credits" and elementData.kind == "creditsHeader" then
        elementData.neededHeight = 30
    elseif elementData.type == "credits" then
        elementData.neededHeight = 32
    else
        elementData.neededHeight = elementData.isHeader and 36 or math.max(34, button.content.text:GetStringHeight() + 16)
    end

    button:SetHeight(elementData.neededHeight)

    -- set zebra color by idx or watch status
    if elementData.type == "changelog" and elementData.kind == "entry" then
        if (elementData.zebraIndex % 2) == 1 then
            button.content.background:SetVertexColor(1, 1, 1, 1)
        else
            button.content.background:SetVertexColor(0, 0, 0, 0)
        end
    elseif elementData.type == "changelog" and (elementData.kind == "version" or elementData.kind == "typeHeader") then
        button.content.background:SetVertexColor(0, 0, 0, 0)
    elseif elementData.type == "credits" and elementData.kind == "creditsHeader" then
        button.content.background:SetVertexColor(0, 0, 0, 0)
    elseif elementData.type == "credits" then
        if (elementData.index % 2) == 1 then
            button.content.background:SetVertexColor(0.20, 0.18, 0.15, 0.48)
        else
            button.content.background:SetVertexColor(0.14, 0.12, 0.10, 0.38)
        end
    elseif (elementData.index % 2) == 1 then
        button.content.background:SetVertexColor(1, 1, 1, 1)
    else
        button.content.background:SetVertexColor(0, 0, 0, 0)
    end
end

function GW.LoadSettingsOverview(container)
    local settingsOverview = CreateFrame("Frame", nil, container, "GwSettingsOverviewTempl")

    settingsOverview.name = "GwSettingsOverview"
    settingsOverview.headerBreadcrumbText = OVERVIEW
    container:AddTab("Interface/AddOns/GW2_UI/textures/uistuff/tabicon_overview.png", settingsOverview)

    settingsOverview.splashart:AddMaskTexture(container.backgroundMask)
    settingsOverview.splashart2:AddMaskTexture(container.backgroundMask)
    settingsOverview.basePageBlockHeight = settingsOverview.pageblock:GetHeight()

    if GW.Retail then
        settingsOverview.splashart:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-retail.png")
        settingsOverview.splashart2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-retail-dark.png")
    elseif GW.Classic or GW.TBC or GW.Wrath then
        settingsOverview.splashart:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-classic.png")
        settingsOverview.splashart2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-classic.png")
    elseif GW.Mists then
        settingsOverview.splashart:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-cata.png")
        settingsOverview.splashart2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/settingartwork-cata.png")
    end

    local buttons = {
        {settingsOverview.menu.welcomebtn, L["Setup"], welcome_OnClick},
        {settingsOverview.menu.reportbtn, L["System info"], statusReport_OnClick},
        {settingsOverview.menu.changelog, L["Changelog"], function() ShowChangelog(settingsOverview.ScrollBox) end},
        {settingsOverview.menu.creditsbtn, L["Credits"], function() ShowCredits(settingsOverview.ScrollBox) end},
        {settingsOverview.menu.movehudbtn, L["Move HUD"], function()
            if InCombatLockdown() then
                GW.Notice(L["You cannot move elements during combat!"])
                return
            end
            GW.moveHudObjects(GW.MoveHudScaleableFrame)
        end},
        {settingsOverview.menu.keybindingsbtn, KEY_BINDING, function() container:Hide() GW.DisplayHoverBinding() end},
        {settingsOverview.menu.discordbtn, L["Join Discord"], function()
            GW.ShowPopup({text = L["Join Discord"],
            hasEditBox = true,
            inputText = "https://discord.gg/MZZtRWt",
            EditBoxOnEscapePressed = function(popup) popup:Hide() end,
            hideOnEscape = true})
        end}
    }

    settingsOverview.header:SetFont(DAMAGE_TEXT_FONT, 30)

    local odd = true
    for _, button in ipairs(buttons) do
        GW.SettingsMenuButtonSetUp(button[1], odd)
        button[1]:SetText(button[2])
        button[1]:SetScript("OnClick", button[3])
        odd = not odd
    end

    -- setup scrollframe
    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("GwSettingsChangeLogCreditsTemplate", function(button, elementData)
        InitButton(button, elementData);
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(settingsOverview.ScrollBox, settingsOverview.ScrollBar, view)
    view:SetElementExtentCalculator(function(dataIndex, elementData)
        if elementData.isHeader ~= nil and elementData.isHeader == true then
            return 36
        else
            return elementData.neededHeight or 36
        end
    end)
    ScrollUtil.AddResizableChildrenBehavior(settingsOverview.ScrollBox)
    GW.HandleTrimScrollBar(settingsOverview.ScrollBar)
    GW.HandleScrollControls(settingsOverview)
    settingsOverview.ScrollBar:SetHideIfUnscrollable(true)
    hooksecurefunc(settingsOverview.ScrollBar, "Update", function(self)
        UpdateOverviewScrollFx(self)
    end)

    settingsOverview.currentOverviewType = "changelog"
    settingsOverview.searchQuery = ""
    settingsOverview.search.background:SetAlpha(1)
    settingsOverview.search.input:SetFont(UNIT_NAME_FONT, 14, "")
    settingsOverview.search.input:SetTextColor(178 / 255, 178 / 255, 178 / 255)
    settingsOverview.search.input:SetText(SEARCH)
    settingsOverview.search.input:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    settingsOverview.search.input:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    settingsOverview.search.input:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == SEARCH then
            self:SetText("")
        end
        self:SetTextColor(1, 1, 1)
        self.clearButton:SetShown((self:GetText() or "") ~= "")
    end)
    settingsOverview.search.input:SetScript("OnEditFocusLost", function(self)
        local txt = NormalizeSearchQuery(self:GetText())
        if txt == "" then
            self:SetText(SEARCH)
            self:SetTextColor(178 / 255, 178 / 255, 178 / 255)
            self.clearButton:Hide()
        end
    end)
    settingsOverview.search.input:SetScript("OnTextChanged", function(self)
        if not self:HasFocus() then return end
        local txt = self:GetText() or ""
        settingsOverview.searchQuery = txt
        self.clearButton:SetShown(NormalizeSearchQuery(txt) ~= "")
        UpdateScrollBox(settingsOverview.ScrollBox, "changelog")
        UpdateOverviewScrollFx(settingsOverview.ScrollBar)
    end)
    settingsOverview.search.input.clearButton:SetScript("OnClick", function(self)
        local edit = self:GetParent()
        settingsOverview.searchQuery = ""
        edit:SetText(SEARCH)
        edit:SetTextColor(178 / 255, 178 / 255, 178 / 255)
        edit:ClearFocus()
        self:Hide()
        UpdateScrollBox(settingsOverview.ScrollBox, "changelog")
        UpdateOverviewScrollFx(settingsOverview.ScrollBar)
    end)

    settingsOverview:SetScript("OnHide", function(self)
        ResetChangelogSearch(self)
    end)

    UpdateScrollBox(settingsOverview.ScrollBox, "changelog")
    UpdateOverviewScrollFx(settingsOverview.ScrollBar)

    if GW.Retail then
        GW.InitBeledarsSplashScreen(settingsOverview)
    end

    return settingsOverview
end
