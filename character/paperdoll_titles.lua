local _, GW = ...
local CharacterMenuBlank_OnLoad = GW.CharacterMenuBlank_OnLoad

local savedPlayerTitles = {}

local function getNewTitlesButton(i)
    if _G["GwPaperDollTitleButton" .. i] ~= nil then
        return _G["GwPaperDollTitleButton" .. i]
    end

    local f = CreateFrame("Button", "GwPaperDollTitleButton" .. i, GwPaperTitles, "GwCharacterMenuBlank")
    CharacterMenuBlank_OnLoad(f)

    if i > 1 then
        _G["GwPaperDollTitleButton" .. i]:SetPoint("TOPLEFT", _G["GwPaperDollTitleButton" .. (i - 1)], "BOTTOMLEFT")
    else
        _G["GwPaperDollTitleButton" .. i]:SetPoint("TOPLEFT", GwPaperTitles, "TOPLEFT")
    end
    f:SetWidth(231)
    f:GetFontString():SetPoint("LEFT", 5, 0)
    GwPaperTitles.buttons = GwPaperTitles.buttons + 1

    --   f:GetFontString():ClearAllPoints()
    --    f:GetFontString():SetPoint('TOP',f,'TOP',0,-20)

    return f
end

local function updateTitles()
    savedPlayerTitles[1] = {}
    savedPlayerTitles[1].name = "       "
    savedPlayerTitles[1].id = -1

    local tableIndex = 1

    for i = 1, GetNumTitles() do
        if (IsTitleKnown(i)) then
            tempName, playerTitle = GetTitleName(i)
            if (tempName and playerTitle) then
                tableIndex = tableIndex + 1
                local tempName, playerTitle = GetTitleName(i)
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

local function updateLayout()
    local currentTitle = GetCurrentTitle()
    local textureC = 1
    local buttonId = 1

    for i = GwPaperTitles.scroll, #savedPlayerTitles do
        if savedPlayerTitles[i] ~= nil then
            local button = getNewTitlesButton(buttonId)
            button:Show()
            buttonId = buttonId + 1
            button:SetText(savedPlayerTitles[i].name)
            button:SetScript(
                "OnClick",
                function()
                    SetCurrentTitle(savedPlayerTitles[i].id)
                end
            )

            if textureC == 1 then
                button:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
                textureC = 2
            else
                button:SetNormalTexture(nil)
                textureC = 1
            end

            if currentTitle == savedPlayerTitles[i].id then
                button:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
            end
            if buttonId > 21 then
                break
            end
        end
    end

    for i = buttonId, GwPaperTitles.buttons do
        _G["GwPaperDollTitleButton" .. i]:Hide()
    end
end

local function titles_OnEvent()
    updateTitles()
    updateLayout()
end

local function LoadPDTitles(fmMenu)
    local fmGPT = CreateFrame("Frame", "GwPaperTitles", GwPaperDoll, "GwPaperTitles")
    fmGPT.buttons = 0
    fmGPT.scroll = 1
    fmGPT:EnableMouseWheel(true)
    fmGPT:RegisterEvent("KNOWN_TITLES_UPDATE")
    fmGPT:RegisterEvent("UNIT_NAME_UPDATE")
    fmGPT:SetScript("OnEvent", titles_OnEvent)
    local fnGPT_OnMouseWheel = function(self, delta)
        self.scroll = math.max(1, self.scroll + -delta)
        updateLayout()
    end
    fmGPT:SetScript("OnMouseWheel", fnGPT_OnMouseWheel)
    fmMenu:SetupBackButton(fmGPT.backButton, "CHARACTER_MENU_TITLES_RETURN")

    updateTitles()
    updateLayout()

    GwPaperTitles:HookScript(
        "OnShow",
        function()
            updateTitles()
            updateLayout()
        end
    )
end
GW.LoadPDTitles = LoadPDTitles
