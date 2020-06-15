local _, GW = ...
local CharacterMenuBlank_OnLoad = GW.CharacterMenuBlank_OnLoad

local BAG_TITLE_SIZE = 32
local savedPlayerTitles = {}

local function title_OnClick(self)
    if not self.TitleID or not self.TitleIdx then
        return
    end
    SetCurrentTitle(self.TitleID)
end
GW.AddForProfiling("paperdoll_titles", "title_OnClick", title_OnClick)

local function loadTitle(titlewin)
    local USED_TITLE_HEIGHT
    local KNOWEN_TITLE_COUNT = 0
    local zebra
    
    local offset = HybridScrollFrame_GetOffset(titlewin)

    for i = 1, #titlewin.buttons do
        local slot = titlewin.buttons[i]
        
        local idx = i + offset
        if idx > #savedPlayerTitles then
            -- empty row (blank starter row, final row, and any empty entries)
            slot.item:Hide()
            slot.item.TitleID = nil
            slot.item.TitleIdx = nil
        else
            slot.item.TitleID = savedPlayerTitles[idx].id
            slot.item.TitleIdx = idx
            slot.item.name:SetText(savedPlayerTitles[idx].name)
            
            -- set zebra color by idx or watch status
            local currentTitleId = GetCurrentTitle()
            zebra = idx % 2
            if currentTitleId == savedPlayerTitles[idx].id then
                slot.item.zebra:SetVertexColor(1, 1, 0.5, 0.15)
            else
                slot.item.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)
            end

            slot.item:Show()
        end
    end
    
    USED_TITLE_HEIGHT = BAG_TITLE_SIZE * #savedPlayerTitles
    HybridScrollFrame_Update(titlewin, USED_TITLE_HEIGHT, 433)
end
GW.AddForProfiling("paperdoll_titles", "loadTitle", loadTitle)

local function titleSetup(titlewin)
    HybridScrollFrame_CreateButtons(titlewin, "GwTitleRow", 12, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #titlewin.buttons do
        local slot = titlewin.buttons[i]
        slot:SetWidth(titlewin:GetWidth() - 12)
        slot.item.name:SetFont(UNIT_NAME_FONT, 12)
        slot.item.name:SetTextColor(1, 1, 1)
        if not slot.item.ScriptsHooked then
            slot.item:HookScript("OnClick", title_OnClick)
            slot.item.ScriptsHooked = true
        end
    end

    loadTitle(titlewin)
end
GW.AddForProfiling("paperdoll_titles", "titleSetup", titleSetup)

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
                savedPlayerTitles[tableIndex] = {}
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
    local titlewin = titlewin_outer.TitleScroll
    
    saveKnowenTitles()
    titlewin.update = loadTitle
    titlewin.scrollBar.doNotHide = true
    titleSetup(titlewin)
    
    -- update title window when a title update event occurs
    titlewin:SetScript(
        "OnEvent",
        function(self, event, ...)
            if not GW.inWorld then
                return
            end
            if event == "KNOWN_TITLES_UPDATE" or event == "UNIT_NAME_UPDATE" then
                if self:IsShown() then
                    saveKnowenTitles()
                    loadTitle(self)
                end
            end
        end
    )
    titlewin:RegisterEvent("KNOWN_TITLES_UPDATE")
    titlewin:RegisterEvent("UNIT_NAME_UPDATE")
    
    fmMenu:SetupBackButton(titlewin:GetParent().backButton, CHARACTER .. ": " .. PAPERDOLL_SIDEBAR_TITLES)
end
GW.LoadPDTitles = LoadPDTitles