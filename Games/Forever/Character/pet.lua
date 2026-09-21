---@class GW2
local GW = select(2, ...)

local PET_CLASSES = {[3] = true, [9] = true}
local TILE_WIDTH, ROW_HEIGHT, TOP_OFFSET = 92, 30, 35

local petStateSprite = {width = 512, height = 128, colums = 4, rows = 1}

local function stat_OnEnter(self)
    if not self.tooltip then
        if self.onEnterFunc then
            pcall(self.onEnterFunc, self)
        end
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltip, 1, 1, 1, 1, true)
    if self.tooltip2 then
        GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
    end
    GameTooltip:Show()
end

local function happiness_OnEnter(self)
    local diet = C_PetInfo.GetPetFoodTypes()

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(_G["PET_HAPPINESS" .. (C_PetInfo.GetPetHappiness() or 1)], 1, 1, 1)
    GameTooltip:AddLine(format(PET_DIET_TEMPLATE, #diet > 0 and table.concat(diet, PET_FOOD_DELIMIT) or NONE), 1, 1, 1, true)
    GameTooltip:Show()
end

local function GetPetStatTile(stats, index)
    stats.tiles = stats.tiles or {}
    local tile = stats.tiles[index]
    if not tile then
        tile = CreateFrame("Frame", nil, stats, "GwPaperDollStat")
        tile:SetScript("OnEnter", stat_OnEnter)
        tile:SetScript("OnLeave", GameTooltip_Hide)
        tile.Value:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        tile.Label:SetFont(UNIT_NAME_FONT, 1, "")
        tile.Label:SetTextColor(0, 0, 0, 0)
        tile.icon:SetSize(30, 30)
        tile.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/statsicon-classic.png")
        tile.icon:SetTexCoord(0, 0.25, 0, 0.125)
        local column, row = (index - 1) % 2, math.floor((index - 1) / 2)
        tile:SetPoint("TOPLEFT", stats, "TOPLEFT", 5 + column * TILE_WIDTH, -TOP_OFFSET - row * ROW_HEIGHT)
        stats.tiles[index] = tile
    end
    tile:Show()
    return tile
end

local function UpdatePetStats(stats)
    local index = 0
    for _, category in ipairs(PAPERDOLL_STATCATEGORIES) do
        if category.unit == "pet" then
            for _, stat in ipairs(category.stats) do
                local info = PAPERDOLL_STATINFO[stat.stat]
                if info and (not stat.showFunc or stat.showFunc()) then
                    local tile = GetPetStatTile(stats, index + 1)
                    tile.unit = "pet"
                    tile.tooltip, tile.tooltip2, tile.onEnterFunc = nil, nil, nil
                    info.updateFunc(tile, "pet")
                    if stat.hideAt ~= nil and stat.hideAt == tile.numericValue then
                        tile:Hide()
                    else
                        index = index + 1
                    end
                end
            end
        end
    end
    for i = index + 1, #(stats.tiles or {}) do
        stats.tiles[i]:Hide()
    end
end

local function UpdatePetPanel(dressingRoom)
    local hasUI, isHunterPet = HasPetUI()
    if not hasUI then return end

    dressingRoom.model:SetUnit("pet")
    local name = UnitName("pet") or ""
    local level = format(UNIT_LEVEL_TEMPLATE, UnitLevel("pet") or "", "")
    local family = UnitCreatureFamily("pet")
    dressingRoom.characterName:SetText(family and (name .. " - " .. level .. " " .. family) or (name .. " - " .. level))

    if isHunterPet then
        local currXP, nextXP = GetPetExperience()
        local expBar = dressingRoom.model.expBar
        expBar:SetMinMaxValues(0, math.max(nextXP or 1, 1))
        expBar:SetValue(currXP or 0)
        expBar.value:SetText(GW.CommaValue(currXP or 0) .. " / " .. GW.CommaValue(nextXP or 0) .. " - " .. math.floor((currXP or 0) / math.max(nextXP or 1, 1) * 100) .. "%")
        expBar:Show()

        dressingRoom.classIcon:SetTexCoord(GW.getSprite(petStateSprite, C_PetInfo.GetPetHappiness() or 1, 1))
        dressingRoom.classIcon:Show()
        dressingRoom.happiness:Show()

        local totalPoints, spentPoints = C_PetInfo.GetPetTrainingPoints()
        dressingRoom.itemLevel:SetText((totalPoints or 0) - (spentPoints or 0))
        dressingRoom.itemLevel:Show()
        dressingRoom.itemLevelLabel:Show()

        dressingRoom.characterData:SetText(C_PetInfo.GetPetLoyalty() or "")
        dressingRoom.characterData:Show()
        dressingRoom.model:SetPosition(-2, 0, -0.5)
        dressingRoom.model:SetRotation(-0.15)
    else
        dressingRoom.model.expBar:Hide()
        dressingRoom.characterData:Hide()
        dressingRoom.itemLevel:Hide()
        dressingRoom.itemLevelLabel:Hide()
        dressingRoom.classIcon:Hide()
        dressingRoom.happiness:Hide()
        dressingRoom.model:SetPortraitZoom(-0.8)
        dressingRoom.model.zoomLevel = -0.8
        dressingRoom.model:SetRotation(0.5)
    end

    UpdatePetStats(dressingRoom.stats)
end
GW.PaperDollUpdatePetStats = function()
    if GwDressingRoomPet then
        UpdatePetPanel(GwDressingRoomPet)
    end
end

local function UpdatePetMenuState(petMenu)
    local hasUI = HasPetUI()
    petMenu:SetEnabled(hasUI and true or false)
    if not InCombatLockdown() then
        GwCharacterWindow:SetAttribute("HasPetUI", hasUI and true or false)
        if not hasUI and GwPetContainer and GwPetContainer:IsVisible() then
            GwCharacterWindow:SetAttribute("windowpanelopen", "paperdoll")
        end
    end
end

local function petStats_OnEvent(self, event, ...)
    if InCombatLockdown() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self.prevEvent = event
        return
    end
    if event == "PLAYER_REGEN_ENABLED" then
        event = self.prevEvent
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end

    local unit = ...
    if event == "PET_UI_UPDATE" or event == "PET_BAR_UPDATE" or event == "PET_UI_CLOSE" or (event == "UNIT_PET" and unit == "player") then
        UpdatePetMenuState(self.petMenu)
    end
    UpdatePetPanel(self:GetParent())
end

function GW.SetupPetMenuButton(petMenu)
    petMenu:SetShown(PET_CLASSES[GW.myClassID] == true)
    GwCharacterWindow:SetAttribute("myClassId", GW.myClassID)
    petMenu:SetAttribute("_onstate-petstate", [=[
        if newstate == "nopet" then
            self:Disable()
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("HasPetUI", false)
        elseif newstate == "hasPet" then
            self:Enable()
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("HasPetUI", true)
        end
    ]=])
    if GW.SecureSnippetsWork() then -- TEMP-FOREVER-SNIPPETS
        RegisterAttributeDriver(petMenu, "state-petstate", "[@pet,noexists] nopet; [@pet,help] hasPet; [@pet,harm] nopet")
    end
    UpdatePetMenuState(petMenu)
end

function GW.LoadPetPanel(tabContainer, fmMenu)
    local petContainer = CreateFrame("Frame", "GwPetContainer", tabContainer, "GwPetContainer")
    local dressingRoom = CreateFrame("Button", "GwDressingRoomPet", petContainer, "GwPetPaperdoll")

    dressingRoom.characterName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    dressingRoom.characterData:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    dressingRoom.itemLevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    dressingRoom.itemLevelLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    dressingRoom.itemLevelLabel:SetText(PET_TRAINING_POINTS or "")

    dressingRoom.happiness:SetScript("OnEnter", happiness_OnEnter)
    dressingRoom.happiness:SetScript("OnLeave", GameTooltip_Hide)

    dressingRoom.stats.petMenu = fmMenu.petMenu
    dressingRoom.stats:SetScript("OnEvent", petStats_OnEvent)

    fmMenu:SetupBackButton(dressingRoom.backButton, CHARACTER .. ": " .. PET)
    UpdatePetPanel(dressingRoom)

    return petContainer
end
