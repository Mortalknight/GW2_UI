---@class GW2
local GW = select(2, ...)

local L = GW.L

local welcome_OnClick = function()
    GwSettingsWindow:Hide()
    GW.ShowWelcomePanel()
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

local CHANGELOG_GROUP_ORDER = {
    GW.Enum.ChangelogType.feature,
    GW.Enum.ChangelogType.change,
    GW.Enum.ChangelogType.bug
}

local CHANGELOG_COLLAPSED_VERSIONS = {}
local CHANGELOG_COLLAPSED_GROUPS = {}
local CHANGELOG_COLLAPSE_INIT = false
local OVERVIEW_SCROLL_RELEASE_ANIM_DURATION = 0.18
local OVERVIEW_SCROLL_RELEASE_ANIM_NAME = "SETTINGS_OVERVIEW_SCROLL_RELEASE"
local SETTINGS_SPLASH_ART_PATH = "Interface/AddOns/GW2_UI/textures/uistuff/splashscreen/"
local SETTINGS_SPLASH_ART_FILES = {
    {enabled = "TWW", file = "settingartwork-tww.png", darkFile = "settingartwork-tww-dark.png", init = GW.InitBeledarsSplashScreen},
    {enabled = "Retail", file = "settingartwork-retail.png"},
    {enabled = "Forever", file = "settingartwork-forever.png"},
    {enabled = "Mists", file = "settingartwork-mists.png"},
    {enabled = "Cata", file = "settingartwork-cata.png"},
    {enabled = "Wrath", file = "settingartwork-wrath.png"},
    {enabled = "TBC", file = "settingartwork-tbc.png"},
    {enabled = "Classic", file = "settingartwork-classic.png"},
}

local function GetChangeLogGroupLabel(changeType)
    if changeType == GW.Enum.ChangelogType.feature then
        return L["New Features"]
    elseif changeType == GW.Enum.ChangelogType.change then
        return L["Changes"]
    end

    return L["Fixes"]
end

local function GetSettingsSplashArt()
    for _, splashArt in ipairs(SETTINGS_SPLASH_ART_FILES) do
        if GW[splashArt.enabled] then
            return SETTINGS_SPLASH_ART_PATH .. splashArt.file, SETTINGS_SPLASH_ART_PATH .. (splashArt.darkFile or splashArt.file), splashArt.init
        end
    end

    local fallback = SETTINGS_SPLASH_ART_PATH .. "settingartwork-retail.png"
    return fallback, fallback, nil
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

    -- the credits and the system info set the page block height themselves
    if not settingsOverview or not settingsOverview.ScrollBar or settingsOverview.currentOverviewType ~= "changelog" then
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

    settingsOverview.search:SetText("")
    settingsOverview.search:ClearFocus()

    if settingsOverview.currentOverviewType then
        UpdateScrollBox(settingsOverview.ScrollBox, settingsOverview.currentOverviewType)
        UpdateOverviewScrollFx(settingsOverview.ScrollBar)
    end
end

local function UpdateOverviewMenu(settingsOverview)
    GW.SetSettingsMenuButtonActive(settingsOverview.menu.changelog, settingsOverview.currentOverviewType == "changelog")
    GW.SetSettingsMenuButtonActive(settingsOverview.menu.creditsbtn, settingsOverview.currentOverviewType == "credits")
    GW.SetSettingsMenuButtonActive(settingsOverview.menu.reportbtn, settingsOverview.currentOverviewType == "systemInfo")
end

local function ShowChangelog(frame)
    local settingsOverview = frame:GetParent()
    if NormalizeSearchQuery(settingsOverview.searchQuery) ~= "" then
        ResetChangelogSearch(settingsOverview)
    end
    settingsOverview.currentOverviewType = "changelog"
    UpdateOverviewMenu(settingsOverview)
    settingsOverview.search:Show()
    settingsOverview.credits:Hide()
    settingsOverview.systemInfo:Hide()
    settingsOverview.pageblock:SetHeight(settingsOverview.basePageBlockHeight)
    frame:Show()
    settingsOverview.ScrollBar:Show()
    UpdateScrollBox(frame, "changelog")
    settingsOverview.ScrollBar:ScrollToBegin();
    UpdateOverviewScrollFx(frame)
end

-- the credits and the system info replace the changelog list with a page of their own
local function ShowPage(frame, pageType, title)
    local settingsOverview = frame:GetParent()
    if NormalizeSearchQuery(settingsOverview.searchQuery) ~= "" then
        ResetChangelogSearch(settingsOverview)
    end
    settingsOverview.currentOverviewType = pageType
    UpdateOverviewMenu(settingsOverview)
    settingsOverview.search:Hide()
    settingsOverview.header:SetText(title)
    -- an empty list, so the scroll bar of the hidden changelog does not come back with its next update
    frame:SetDataProvider(CreateDataProvider())
    frame:Hide()
    settingsOverview.ScrollBar:Hide()
    local page = settingsOverview[pageType]
    for _, other in ipairs({settingsOverview.credits, settingsOverview.systemInfo}) do
        other:SetShown(other == page)
    end
    -- the page block grows up like on scrolling until the page fits, the page sits 15 inside it
    local base = settingsOverview.basePageBlockHeight
    settingsOverview.pageblock:SetHeight(math.max(base, (page.contentHeight or 0) + 30))
    settingsOverview.lastScrollGrowAmount = nil
end

local function ShowCredits(frame)
    ShowPage(frame, "credits", L["Credits"])
end

local function ShowSystemInfo(frame)
    ShowPage(frame, "systemInfo", L["System info"])
end

local function SetTitleTextAnchors(button, xOffset, yOffset)
    button.title.text:ClearAllPoints()
    button.title.text:SetPoint("TOPLEFT", button.title, "TOPLEFT", xOffset, yOffset)
    button.title.text:SetPoint("TOPRIGHT", button.title, "TOPRIGHT", -6, yOffset)
end

local function InitButton(button, elementData)
    if not button.gwSkinned then
        button.title.text:SetFont(DAMAGE_TEXT_FONT, 14)
        button.title.text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        button.title.text:SetJustifyV("TOP")
        button.title.icon = button.title:CreateTexture(nil, "BORDER")
        button.title.icon:SetSize(16, 16)
        button.title.icon:Hide()

        button.content.text:SetFont(UNIT_NAME_FONT, 12)
        button.content.text:SetTextColor(181 / 255, 160 / 255, 128 / 255)
        button.content.text:SetJustifyV("MIDDLE")
        GW.AddListItemChildHoverTexture(button)

        button.gwSkinned = true
    end

    button:SetScript("OnClick", nil)
    SetTitleTextAnchors(button, 5, -5)
    button.title.icon:Hide()
    button.title.text:SetJustifyV("TOP")
    button.title.text:SetFont(DAMAGE_TEXT_FONT, 14)

    -- Reset shared row layout defaults (changelog template) before applying type-specific layout.
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
        end

        button.title:Hide()
        button.content:Show()
        elementData.isHeader = false
    end

    if elementData.type == "changelog" and elementData.kind == "typeHeader" then
        elementData.neededHeight = 28
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

    local splashArt, splashArtDark, initSplashArt = GetSettingsSplashArt()
    settingsOverview.splashart:SetTexture(splashArt)
    settingsOverview.splashart2:SetTexture(splashArtDark)
    if initSplashArt then
        initSplashArt(settingsOverview)
    end

    local buttons = {
        {button = settingsOverview.menu.welcomebtn, text = L["Setup"], onClick = welcome_OnClick},
        {button = settingsOverview.menu.reportbtn, text = L["System info"], onClick = function() ShowSystemInfo(settingsOverview.ScrollBox) end},
        {button = settingsOverview.menu.changelog, text = L["Changelog"], onClick = function() ShowChangelog(settingsOverview.ScrollBox) end},
        {button = settingsOverview.menu.creditsbtn, text = L["Credits"], onClick = function() ShowCredits(settingsOverview.ScrollBox) end},
        {button = settingsOverview.menu.movehudbtn, text = L["Move HUD"], onClick = function()
            if InCombatLockdown() then
                GW.Notice(L["You cannot move elements during combat!"])
                return
            end
            GW.moveHudObjects(GW.MoveHudScaleableFrame)
        end},
        {button = settingsOverview.menu.keybindingsbtn, text = KEY_BINDING, onClick = function() container:Hide() GW.DisplayHoverBinding() end},
    }

    settingsOverview.credits = GW.CreateCreditsPage(settingsOverview)
    settingsOverview.credits:SetPoint("TOPLEFT", settingsOverview.ScrollBox, "TOPLEFT", 10, -10)
    settingsOverview.credits:SetPoint("BOTTOMRIGHT", settingsOverview.ScrollBox, "BOTTOMRIGHT", -10, 10)
    settingsOverview.systemInfo = GW.CreateSystemInfoPage(settingsOverview)
    settingsOverview.systemInfo:SetPoint("TOPLEFT", settingsOverview.ScrollBox, "TOPLEFT", 10, -10)
    settingsOverview.systemInfo:SetPoint("BOTTOMRIGHT", settingsOverview.ScrollBox, "BOTTOMRIGHT", -10, 10)

    settingsOverview.header:SetFont(DAMAGE_TEXT_FONT, 30)

    -- newer version seen in group or guild (see the version check in the micro menu): a banner row at the
    -- top of the dark page block, the list moves down while it is shown
    -- the search box reaches into the top right corner of the page block (207 wide, see the xml), the
    -- banner stops left of it; anchoring to the search box itself would close an anchor cycle via the scroll box
    local updateHint = CreateFrame("Frame", nil, settingsOverview)
    updateHint:SetHeight(26)
    updateHint:SetPoint("TOPLEFT", settingsOverview.pageblock, "TOPLEFT", 0, -5)
    updateHint:SetPoint("TOPRIGHT", settingsOverview.pageblock, "TOPRIGHT", -215, -5)
    updateHint.bg = updateHint:CreateTexture(nil, "BACKGROUND")
    updateHint.bg:SetAllPoints()
    updateHint.bg:SetColorTexture(1, 0.82, 0, 0.08)
    updateHint.icon = updateHint:CreateTexture(nil, "ARTWORK")
    updateHint.icon:SetSize(18, 18)
    updateHint.icon:SetPoint("LEFT", 8, 0)
    updateHint.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/microicons/updatemicrobutton-up.png")
    updateHint.text = updateHint:CreateFontString(nil, "OVERLAY")
    updateHint.text:SetFont(UNIT_NAME_FONT, 13, "")
    updateHint.text:SetShadowColor(0, 0, 0, 1)
    updateHint.text:SetShadowOffset(1, -1)
    updateHint.text:SetTextColor(1, 0.82, 0)
    updateHint.text:SetJustifyH("LEFT")
    updateHint.text:SetWordWrap(true)
    updateHint.text:SetPoint("LEFT", updateHint.icon, "RIGHT", 8, 0)
    settingsOverview.updateHint = updateHint
    local function RefreshUpdateHint()
        local version = GW.GetAvailableAddonUpdate and GW.GetAvailableAddonUpdate()
        settingsOverview.ScrollBox:ClearAllPoints()
        settingsOverview.ScrollBox:SetPoint("BOTTOMRIGHT", settingsOverview.pageblock, "BOTTOMRIGHT", -5, 0)
        if version then
            local text = format(L["Update available: %s (installed: %s)"], version, GW.GetVersionString())
            local summary = GW.GetAddonUpdateSummary and GW.GetAddonUpdateSummary()
            if summary then
                text = text .. "  •  " .. summary
            end
            -- explicit text width so the wrapped height is known right away, two lines when needed
            updateHint.text:SetWidth(settingsOverview.pageblock:GetWidth() - 215 - 42)
            updateHint.text:SetText(text)
            updateHint:SetHeight(math.max(26, updateHint.text:GetStringHeight() + 10))
            updateHint:Show()
            settingsOverview.ScrollBox:SetPoint("TOPLEFT", updateHint, "BOTTOMLEFT", 0, -2)
        else
            updateHint:Hide()
            settingsOverview.ScrollBox:SetPoint("TOPLEFT", settingsOverview.pageblock, "TOPLEFT", 0, -5)
        end
    end
    GW.RefreshSettingsUpdateHint = RefreshUpdateHint
    settingsOverview:HookScript("OnShow", RefreshUpdateHint)
    RefreshUpdateHint()

    -- used by the update micro menu icon
    GW.ShowSettingsChangelog = function()
        if InCombatLockdown() then
            GW.Notice(L["Settings are not available in combat!"])
            return
        end
        GwSettingsWindow:Show()
        GwSettingsWindow:SwitchTab("GwSettingsOverview")
        ShowChangelog(settingsOverview.ScrollBox)
    end

    -- /gw2 status
    GW.ShowStatusReport = function()
        if InCombatLockdown() then
            GW.Notice(L["Settings are not available in combat!"])
            return
        end
        GwSettingsWindow:Show()
        GwSettingsWindow:SwitchTab("GwSettingsOverview")
        ShowSystemInfo(settingsOverview.ScrollBox)
    end

    local odd = true
    for _, button in ipairs(buttons) do
        GW.SettingsMenuButtonSetUp(button.button, odd)
        button.button:SetText(button.text)
        button.button:SetScript("OnClick", button.onClick)
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
    UpdateOverviewMenu(settingsOverview)
    settingsOverview.searchQuery = ""
    local search = settingsOverview.search
    GW.SkinEditBox(search, {search = true})
    search:SetScript("OnEnterPressed", search.ClearFocus)
    search:HookScript("OnTextChanged", function(self)
        local txt = self:GetText()
        -- the reset on hide sets the query itself
        if txt == settingsOverview.searchQuery then return end
        settingsOverview.searchQuery = txt
        UpdateScrollBox(settingsOverview.ScrollBox, "changelog")
        UpdateOverviewScrollFx(settingsOverview.ScrollBar)
    end)

    settingsOverview:SetScript("OnHide", function(self)
        ResetChangelogSearch(self)
    end)

    UpdateScrollBox(settingsOverview.ScrollBox, "changelog")
    UpdateOverviewScrollFx(settingsOverview.ScrollBar)

    return settingsOverview
end
