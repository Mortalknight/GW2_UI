local _, GW = ...
local L = GW.L

local savedPlayerTitles = {}
local showEarned = true
local showUnearned = false

local function title_OnClick(self)
    if not self.titleId then
        return
    end
    SetCurrentTitle(self.titleId)

    self:GetParent():GetParent():GetParent().input:SetText("")
    self:GetParent():GetParent():GetParent().input.clearButton:Hide()
end


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

    if playerTitle.isKnown then
        button:Enable()
        button.name:SetTextColor(1, 1, 1)
    else
        button:Disable();
        button.name:SetTextColor(0.60, 0.60, 0.60)
    end

    button.gwSelected:SetShown(GetCurrentTitle() == button.titleId)
end

local function saveKnowenTitles(titlewin, searchString)
    wipe(savedPlayerTitles)
    if not (showEarned or showUnearned) then
        UpdateScrollBox(titlewin)
        return
    end

    local query = searchString and searchString:lower() or nil

    for i = 1, GetNumTitles() do
        local isKnown = IsTitleKnown(i)
        if (isKnown and showEarned) or (not isKnown and showUnearned) then
            local tempName, playerTitle = GetTitleName(i)
            if tempName and playerTitle then
                tempName = strtrim(tempName)
                if (not query) or (tempName:lower():find(query, 1, true)) then
                    tinsert(savedPlayerTitles, {name = tempName, id = i, isKnown = isKnown})
                end
            end
        end
    end

    table.sort(savedPlayerTitles,
        function(a, b)
            return a.name < b.name
        end
    )
    if showEarned then
        tinsert(savedPlayerTitles, 1, {name = PLAYER_TITLE_NONE, id = -1, isKnown = true})
    end

    UpdateScrollBox(titlewin)
end


local function SetSearchboxInstructions(editbox, text)
    editbox.Instructions:SetTextColor(0.5, 0.5, 0.5)
    editbox.Instructions:SetText(text)
end

local function ResetFilter()
    showEarned = true
    showUnearned = false

    GwTitleWindow.input:SetText("")
    GwTitleWindow.input.clearButton:Hide()
    saveKnowenTitles(GwTitleWindow)
end

local function ShowFiterDropDown(self)
    local menu = MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
        rootDescription:SetMinimumWidth(1)
        local check = rootDescription:CreateCheckbox(ACHIEVEMENTFRAME_FILTER_COMPLETED,function() return showEarned end, function() showEarned = not showEarned; GwTitleWindow.input:SetText(""); GwTitleWindow.input.clearButton:Hide(); saveKnowenTitles(GwTitleWindow) end)
        check:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)

        check = rootDescription:CreateCheckbox(L["Unearned"],function() return showUnearned end, function() showUnearned = not showUnearned; GwTitleWindow.input:SetText(""); GwTitleWindow.input.clearButton:Hide(); saveKnowenTitles(GwTitleWindow) end)
        check:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)

        check:SetTooltip(function(tooltip, elementDescription)
            tooltip:SetText(MenuUtil.GetElementText(elementDescription), 1, 1, 1)
            tooltip:AddLine(L["You may see duplicated titles that are unavailable to your faction"], 1, 1, 1)
        end);
    end)

    menu:SetClosedCallback(function()
        if not showEarned and not showUnearned then
            ResetFilter()
        end
    end)
end

local function LoadPDTitles(fmMenu, parent)
    local titlewin = CreateFrame("Frame", "GwTitleWindow", parent, "GwTitleWindow")

    SetSearchboxInstructions(titlewin.input, SEARCH .. "...")
    titlewin.input:SetText("")
    titlewin.input:SetScript("OnEnterPressed", nil)
    titlewin.input:HookScript("OnTextChanged", function(self)
        local text = self:GetText()
        if text == "" then
            saveKnowenTitles(titlewin)
            self.clearButton:Hide()
            return
        end
        saveKnowenTitles(titlewin, text)
        self.clearButton:Show()
    end)

    titlewin.input:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        self:SetText("")
        saveKnowenTitles(titlewin)
    end)

    titlewin.input:SetScript("OnEditFocusGained", function(self)
        self.clearButton:Show()
        saveKnowenTitles(titlewin)
    end)

    titlewin.input:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self.clearButton:Hide()
        end
    end)
    titlewin.input.clearButton:SetScript("OnClick", function(self)
        self:GetParent():ClearFocus()
        self:GetParent():SetText("")
        saveKnowenTitles(titlewin)
    end)

    titlewin.filter:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(FILTER, 1, 1, 1)
        if showUnearned == true then
            GameTooltip:AddLine(L["Right Click To Reset Filter"], 1, 0.82, 0, true)
        end
        GameTooltip:Show()
    end)
    titlewin.filter:SetScript("OnLeave", GameTooltip_Hide)
    titlewin.filter:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            GameTooltip:Hide()
            ShowFiterDropDown(self)
        elseif button == "RightButton" then
            -- reset filter
            ResetFilter()
            if self:IsMouseMotionFocus() then
                GameTooltip:Hide()
                self:OnEnter()
            end
        end
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

    return titlewin
end
GW.LoadPDTitles = LoadPDTitles