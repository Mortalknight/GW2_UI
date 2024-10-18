local _, GW = ...

local savedPlayerTitles = {}

local function title_OnClick(self)
    if not self.titleId then
        return
    end
    SetCurrentTitle(self.titleId)
end
GW.AddForProfiling("paperdoll_titles", "title_OnClick", title_OnClick)

local function UpdateScrollBox(self)
    local dataProvider = CreateDataProvider();
    for index, playerTitle in ipairs(savedPlayerTitles) do
        dataProvider:Insert({index = index, playerTitle = playerTitle})
    end
    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
end

local function Titles_InitButton(button, elementData)
    local playerTitle = elementData.playerTitle

    if not button.isSkinned then
        button.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        button.name:SetTextColor(1, 1, 1)
        button:HookScript("OnClick", title_OnClick)
        GW.AddListItemChildHoverTexture(button)

        button.isSkinned = true
    end

    button.name:SetText(playerTitle.name)
    button.titleId = playerTitle.id

    -- set zebra color by idx or watch status
    if (GetCurrentTitle() == button.titleId) or ((elementData.index % 2) == 1) then
        button.zebra:SetVertexColor(1, 1, 1, 1)
    else
        button.zebra:SetVertexColor(0, 0, 0, 0)
    end

    button.gwSelected:SetShown(GetCurrentTitle() == button.titleId)
end

local function saveKnowenTitles()
    savedPlayerTitles[1] = {}
    savedPlayerTitles[1].name = "       "
    savedPlayerTitles[1].id = -1

    local tableIndex = 1

    for i = 1, GetNumTitles() do
        if IsTitleKnown(i) then
            local tempName, playerTitle = GetTitleName(i)
            if (tempName and playerTitle) then
                tableIndex = tableIndex + 1
                savedPlayerTitles[tableIndex] = savedPlayerTitles[tableIndex] or {}
                savedPlayerTitles[tableIndex].name = strtrim(tempName)
                savedPlayerTitles[tableIndex].id = i
            end
        end
    end

    table.sort(
        savedPlayerTitles,
        function(a, b)
            return a.name < b.name
        end
    )
    savedPlayerTitles[1].name = PLAYER_TITLE_NONE
end
GW.AddForProfiling("paperdoll_titles", "saveKnowenTitles", saveKnowenTitles)

local function LoadPDTitles(fmMenu)
    local titlewin_outer = CreateFrame("Frame", "GwTitleWindow", GwPaperDoll, "GwTitleWindow")

    saveKnowenTitles()

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("GwTitleButtonTemplate", function(button, elementData)
        Titles_InitButton(button, elementData);
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(titlewin_outer.ScrollBox, titlewin_outer.ScrollBar, view)
    GW.HandleTrimScrollBar(titlewin_outer.ScrollBar)
    GW.HandleScrollControls(titlewin_outer)
    titlewin_outer.ScrollBar:SetHideIfUnscrollable(true)

    UpdateScrollBox(titlewin_outer)

    -- update title window when a title update event occurs
    titlewin_outer:SetScript(
        "OnEvent",
        function(self)
            if GW.inWorld and self:IsShown() then
                saveKnowenTitles()
                UpdateScrollBox(titlewin_outer)
            end
        end
    )
    titlewin_outer:RegisterEvent("KNOWN_TITLES_UPDATE")
    titlewin_outer:RegisterEvent("UNIT_NAME_UPDATE")

    fmMenu:SetupBackButton(titlewin_outer.backButton, CHARACTER .. ": " .. PAPERDOLL_SIDEBAR_TITLES)
end
GW.LoadPDTitles = LoadPDTitles