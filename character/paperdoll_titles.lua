local _, GW = ...

local savedPlayerTitles = {}
local defaultSearchString = SEARCH .. "..."

local function title_OnClick(self)
    if not self.titleId then
        return
    end
    SetCurrentTitle(self.titleId)

    self:GetParent():GetParent():GetParent().input:SetText(defaultSearchString)
    self:GetParent():GetParent():GetParent().input.clearButton:Hide()
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

local function saveKnowenTitles(titlewin, searchString)
    wipe(savedPlayerTitles)
    savedPlayerTitles[1] = {}
    savedPlayerTitles[1].name = "       "
    savedPlayerTitles[1].id = -1

    local tableIndex = 1

    for i = 1, GetNumTitles() do
        if IsTitleKnown(i) then
            local tempName, playerTitle = GetTitleName(i)
            if tempName and playerTitle and ((searchString and string.find(string.lower(tempName), string.lower(searchString)) or searchString == nil)) then
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

    UpdateScrollBox(titlewin)
end
GW.AddForProfiling("paperdoll_titles", "saveKnowenTitles", saveKnowenTitles)

local function LoadPDTitles(fmMenu)
    local titlewin = CreateFrame("Frame", "GwTitleWindow", GwPaperDoll, "GwTitleWindow")

    titlewin.input:SetText(defaultSearchString)
    titlewin.input:SetScript("OnEnterPressed", nil)
    titlewin.input:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        if text == defaultSearchString or text == "" then
            saveKnowenTitles(titlewin)
            self.clearButton:Hide()
            return
        end
        saveKnowenTitles(titlewin, text)
        self.clearButton:Show()
    end)

    titlewin.input:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        self:SetText(defaultSearchString)
        saveKnowenTitles(titlewin)
    end)

    titlewin.input:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == defaultSearchString then
            self:SetText("")
        end
        self.clearButton:Show()
        saveKnowenTitles(titlewin)
    end)

    titlewin.input:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(defaultSearchString)
            self.clearButton:Hide()
        end
    end)
    titlewin.input.clearButton:SetScript("OnClick", function(self)
        self:GetParent():ClearFocus()
        self:GetParent():SetText(defaultSearchString)
        saveKnowenTitles(titlewin)
    end)

    local view = CreateScrollBoxListLinearView()
    view:SetElementInitializer("GwTitleButtonTemplate", function(button, elementData)
        Titles_InitButton(button, elementData);
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(titlewin.ScrollBox, titlewin.ScrollBar, view)
    GW.HandleTrimScrollBar(titlewin.ScrollBar)
    GW.HandleScrollControls(titlewin)
    titlewin.ScrollBar:SetHideIfUnscrollable(true)

    saveKnowenTitles(titlewin)

    -- update title window when a title update event occurs
    titlewin:SetScript(
        "OnEvent",
        function()
            if GW.inWorld then
                saveKnowenTitles(titlewin)
            end
        end
    )
    titlewin:RegisterEvent("KNOWN_TITLES_UPDATE")
    titlewin:RegisterEvent("UNIT_NAME_UPDATE")

    fmMenu:SetupBackButton(titlewin.backButton, CHARACTER .. ": " .. PAPERDOLL_SIDEBAR_TITLES)
end
GW.LoadPDTitles = LoadPDTitles