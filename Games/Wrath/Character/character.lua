---@class GW2
local GW = select(2, ...)
local GWGetClassColor = GW.GWGetClassColor
local HeroPanel = GW.HeroPanel
local PlayerSlots = HeroPanel.PlayerSlots
local petStateSprite = HeroPanel.petStateSprite
local statTiles = HeroPanel.statTiles
local setStatFrame = HeroPanel.SetStatFrame
local setPetStatFrame = HeroPanel.SetPetStatFrame
local grabDefaultSlots = HeroPanel.GrabDefaultSlot
local PaperDollSlotButton_Update = HeroPanel.SlotButton_Update

local hideCharframe = true

local TOGGLE_PANELS = {
    PaperDollFrame = {"GwHeroPanelMenu", "paperdoll"},
    ReputationFrame = {"GwPaperReputation", "reputation"},
    SkillFrame = {"GwPaperSkills", "paperdollskills"},
    PetPaperDollFrame = {"GwPetContainer", "paperdollpet"},
    TokenFrame = {"GwCurrencyDetailsFrame", "currency"},
    PvpFrame = {"GwPvpDetailsFrame", "pvp"},
}

local function SchedulePaperDollStatsUpdate(self, delay)
    delay = delay or 0.05

    if not GwCharacterWindow:IsShown() then
        self.pendingStatsRefresh = true
        return
    end

    if self.pendingStatsTimer then
        return
    end

    self.pendingStatsTimer = true
    C_Timer.After(delay, function()
        self.pendingStatsTimer = nil
        self.pendingStatsRefresh = nil
        GW.PaperDollUpdateStats()
    end)
end

local function PaperDollUpdateUnitData()
    GwDressingRoom.characterName:SetText(UnitPVPName("player"))
    local _, name = C_SpecializationInfo.GetSpecializationInfo(GW.myspec)
    local color = GWGetClassColor(GW.myclass, true)
    GW.SetClassIcon(GwDressingRoom.classIcon, GW.myclass)

   GwDressingRoom.classIcon:SetVertexColor(color.r, color.g, color.b, color.a)

    if name ~= nil then
        local data = GUILD_RECRUITMENT_LEVEL .. " " .. GW.mylevel .. " " .. name .. " " .. GW.myLocalizedClass
        GwDressingRoom.characterData:SetText(data)
    else
        GwDressingRoom.characterData:SetFormattedText(PLAYER_LEVEL, GW.mylevel, GW.myLocalizedRace, GW.myLocalizedClass)
    end
end

local function PaperDollPetStats_OnEvent(self, event, ...)
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
    if event == "PET_UI_UPDATE" or event == "PET_BAR_UPDATE" or (event == "UNIT_PET" and unit == "player") then
        if GwPetContainer:IsVisible() and not HasPetUI() then
            GwCharacterWindow:SetAttribute("windowpanelopen", "paperdoll")
            GwHeroPanelMenu.petMenu:Disable()
            return
        end
    elseif event == "PET_UI_CLOSE" then
        if GwPetContainer:IsVisible() then
            GwCharacterWindow:SetAttribute("windowpanelopen", "paperdoll")
            GwHeroPanelMenu.petMenu:Disable()
            return
        end
    end
    GW.PaperDollUpdatePetStats()
end

local function PaperDollStats_OnEvent(self, event, ...)
    local unit = ...
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_PVP_RANK_CHANGED" or ((event == "UNIT_MODEL_CHANGED" or event == "UNIT_NAME_UPDATE") and unit == "player") then
        GwDressingRoom.model:SetUnit("player", false)
        PaperDollUpdateUnitData()
        return
    end

    if unit == "player" then
        if event == "UNIT_LEVEL" then
            PaperDollUpdateUnitData()
        elseif event == "UNIT_DAMAGE" or
                event == "UNIT_ATTACK_SPEED" or
                event == "UNIT_RANGEDDAMAGE" or
                event == "UNIT_ATTACK" or
                event == "UNIT_STATS" or
                event == "UNIT_RANGED_ATTACK_POWER" or
                event == "UNIT_SPELL_HASTE" or
                event == "UNIT_MAXHEALTH" or
                event == "UNIT_AURA" or
                event == "UNIT_RESISTANCES" or
                event == "UPDATE_INVENTORY_ALERTS" or
                IsMounted() then
            SchedulePaperDollStatsUpdate(self)
        end
    end

    if event == "COMBAT_RATING_UPDATE" or
            event == "SPEED_UPDATE" or
            event == "LIFESTEAL_UPDATE" or
            event == "AVOIDANCE_UPDATE" or
            event == "BAG_UPDATE_DELAYED" or
            event == "PLAYER_EQUIPMENT_CHANGED" or
            event == "PLAYERBANKSLOTS_CHANGED" or
            event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" or
            event == "PLAYER_DAMAGE_DONE_MODS" or
            IsMounted() then
        SchedulePaperDollStatsUpdate(self)
    elseif event == "PLAYER_TALENT_UPDATE" then
        PaperDollUpdateUnitData()
        SchedulePaperDollStatsUpdate(self)
    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
        GW.PaperDollUpdateStats()
    elseif event == "SPELL_POWER_CHANGED" then
        SchedulePaperDollStatsUpdate(self)
    end
end

local function UpdateItemLevelAndGearScore()
    local avgItemLevel, avgItemLevelEquipped = GW.GetAverageItemLevel()
    local r, g, b = GW.GetItemLevelColor(avgItemLevel)

    avgItemLevelEquipped = avgItemLevelEquipped and avgItemLevelEquipped or 0
    avgItemLevel = avgItemLevel and avgItemLevel or 0
    avgItemLevelEquipped = math.floor(avgItemLevelEquipped)
    avgItemLevel = math.floor(avgItemLevel)
    if avgItemLevelEquipped < avgItemLevel then
        avgItemLevelEquipped = math.floor(avgItemLevel) .. " (" .. math.floor(avgItemLevelEquipped) .. ")"
    end
    avgItemLevelEquipped = avgItemLevelEquipped == 0 and "" or avgItemLevelEquipped
    GwDressingRoom.itemLevel:SetText(avgItemLevelEquipped)
    GwDressingRoom.itemLevel:SetTextColor(r, g,b)
end

local function PaperDollUpdateStats()
    wipe(statTiles)
    local statText, tooltip1, tooltip2
    local numShownStats = 1
    local grid = 1
    local x = 0
    local y = 0

    for primaryStatIndex = 1, 5 do
        _, statText, tooltip1, tooltip2 = GW.stats.getPrimary(primaryStatIndex)
        grid, x, y, numShownStats = setStatFrame(GW.stats.PRIMARY_STATS[primaryStatIndex], numShownStats, statText, tooltip1, tooltip2, grid, x, y)
    end

    -- Armor
    statText, tooltip1, tooltip2 = GW.stats.getArmor()
    grid, x, y, numShownStats = setStatFrame("ARMOR", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    -- Defense
    statText, tooltip1, tooltip2 = GW.stats.getDefense()
    grid, x, y, numShownStats = setStatFrame("DEFENSE", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    --damage
    statText, tooltip1, tooltip2 = GW.stats.getDamage()
    grid, x, y, numShownStats = setStatFrame("DAMAGE", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    --attack power
    statText, tooltip1, tooltip2 = GW.stats.getAttackPower()
    grid, x, y, numShownStats = setStatFrame("ATTACKPOWER", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    --ranged damage
    statText, tooltip1, tooltip2 = GW.stats.getRangedDamage()
    if statText then
        grid, x, y, numShownStats = setStatFrame("RANGEDDAMAGE", numShownStats, statText, tooltip1, tooltip2, grid, x, y)
    end

    --ranged attack power
    if statText then
        statText, tooltip1, tooltip2 = GW.stats.getRangedAttackPower()
        grid, x, y, numShownStats = setStatFrame("RANGEDATTACKPOWER", numShownStats, statText, tooltip1, tooltip2, grid, x, y)
    end

    --resitance
    for resistanceIndex = 2, 6 do
        _, statText, tooltip1, tooltip2 = GW.stats.getResitance(resistanceIndex)
        grid, x, y, numShownStats = setStatFrame(GW.stats.RESITANCE_STATS[resistanceIndex], numShownStats, statText, tooltip1, tooltip2, grid, x, y)
    end

    --durability
    grid, x, y, numShownStats = setStatFrame("DURABILITY", numShownStats, DURABILITY, nil, nil, grid, x, y)

    GW.StatsPicker.Layout(GwDressingRoom.stats, statTiles, 30)
end
GW.PaperDollUpdateStats = PaperDollUpdateStats

local function PaperDollUpdatePetStats()
    local hasUI, isHunterPet = HasPetUI()
    local statText, tooltip1, tooltip2
    GwHeroPanelMenu.petMenu:SetShown(GW.myClassID == 3 or GW.myClassID == 9 or GW.myClassID == 6)
    if not hasUI then return end

    local numShownStats = 1
    local grid = 1
    local x = 0
    local y = 0

    GwHeroPanelMenu.petMenu:Enable()
    GwDressingRoomPet.model:SetUnit("pet")
    if UnitCreatureFamily("pet") then
		GwDressingRoomPet.characterName:SetText((UnitName("pet") or "") .. " - " .. format(UNIT_LEVEL_TEMPLATE, (UnitLevel("pet") or ""), "") .. " " .. (UnitCreatureFamily("pet") or ""))
	else
        GwDressingRoomPet.characterName:SetText((UnitName("pet") or "") .. " - " .. format(UNIT_LEVEL_TEMPLATE, (UnitLevel("pet") or ""), ""))
    end

    GwCharacterWindow:SetAttribute("HasPetUI", hasUI)
    if isHunterPet then
        local happiness = GetPetHappiness()
        local currXP, nextXP = GetPetExperience()

        GwDressingRoomPet.model.expBar:SetValue(currXP / nextXP)
        GwDressingRoomPet.model.expBar.value:SetText(GW.CommaValue(currXP) .. " / " .. GW.CommaValue(nextXP) .. " - " .. math.floor(currXP / nextXP * 100) .. "%")
        GwDressingRoomPet.classIcon:SetTexCoord(GW.getSprite(petStateSprite, happiness, 1))
        GwDressingRoomPet.characterData:SetText(GetPetLoyalty())
        GwDressingRoomPet.characterData:Show()
        GwDressingRoomPet.itemLevel:Hide()
        GwDressingRoomPet.itemLevelLabel:Hide()
        GwDressingRoomPet.classIcon:Show()
        GwDressingRoomPet.model.expBar:Show()
        GwDressingRoomPet.model:SetPosition(-2,0,-0.5)
        GwDressingRoomPet.model:SetRotation(-0.15)

        GwDressingRoomPet.happiness:Show()
    else
        GwDressingRoomPet.model.expBar:Hide()
        GwDressingRoomPet.characterData:Hide()
        GwDressingRoomPet.itemLevel:Hide()
        GwDressingRoomPet.itemLevelLabel:Hide()
        GwDressingRoomPet.classIcon:Hide()
        GwDressingRoomPet.model:SetPortraitZoom(-0.8)
        GwDressingRoomPet.model.zoomLevel = -0.8
        GwDressingRoomPet.model:SetRotation(0.5)
    end

    for primaryStatIndex = 1, 5 do
        _, statText, tooltip1, tooltip2 = GW.stats.getPrimary(primaryStatIndex, "pet")
        grid, x, y, numShownStats = setPetStatFrame(GW.stats.PRIMARY_STATS[primaryStatIndex], numShownStats, statText, tooltip1, tooltip2, grid, x, y)
    end

    statText, tooltip1, tooltip2 = GW.stats.getAttackPower("pet")
    grid, x, y, numShownStats = setPetStatFrame("ATTACKPOWER", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    statText, tooltip1, tooltip2 = GW.stats.getDamage("pet")
    grid, x, y, numShownStats = setPetStatFrame("DAMAGE", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    statText, tooltip1, tooltip2 = GW.stats.getArmor("pet")
    grid, x, y, numShownStats = setPetStatFrame("ARMOR", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    for resistanceIndex = 2, 6 do
        _, statText, tooltip1, tooltip2 = GW.stats.getResitance(resistanceIndex, "pet")
        grid, x, y, numShownStats = setPetStatFrame(GW.stats.RESITANCE_STATS[resistanceIndex], numShownStats, statText, tooltip1, tooltip2, grid, x, y)
    end
end
GW.PaperDollUpdatePetStats = PaperDollUpdatePetStats

local function LoadPaperDoll(tabContainer)
    local dressingRoom = CreateFrame("Button", "GwDressingRoom", tabContainer, "GwDressingRoom")
    GW.HandleModelControlFrame(dressingRoom.model.controlFrame)
    local heroPanelMenu = CreateFrame("Frame", "GwHeroPanelMenu", tabContainer, "GwCharacterMenuFilledTemplate")

    --Legacy pet window
    local petContainer = CreateFrame("Frame", "GwPetContainer", tabContainer, "GwPetContainer")
    local dressingRoomPet = CreateFrame("Button", "GwDressingRoomPet", petContainer, "GwPetPaperdoll")

    GwCharacterWindow:SetHeroPanelMenu(heroPanelMenu)

    dressingRoom.stats:SetScript("OnEvent", PaperDollStats_OnEvent)
    for _, event in ipairs({"PLAYER_TALENT_UPDATE", "ACTIVE_TALENT_GROUP_CHANGED"}) do
        if C_EventUtils.IsEventValid(event) then
            dressingRoom.stats:RegisterEvent(event)
        end
    end
    dressingRoomPet.stats:SetScript("OnEvent", PaperDollPetStats_OnEvent)

    heroPanelMenu.SetupBackButton = HeroPanel.SetupBackButton

    dressingRoom.stats:SetScript("OnEvent", PaperDollStats_OnEvent)
    dressingRoom.stats:HookScript("OnShow", function(self)
        if self.pendingStatsRefresh then
            SchedulePaperDollStatsUpdate(self, 0)
        end
    end)
    dressingRoomPet.stats:SetScript("OnEvent", PaperDollPetStats_OnEvent)

    grabDefaultSlots(CharacterHeadSlot, {"TOPLEFT", dressingRoom.gear, "TOPLEFT", 0, 0}, dressingRoom, 50)
    grabDefaultSlots(CharacterShoulderSlot, {"TOPLEFT", CharacterHeadSlot, "BOTTOMLEFT", 0, -5}, dressingRoom, 50)
    grabDefaultSlots(CharacterChestSlot, {"TOPLEFT", CharacterShoulderSlot, "BOTTOMLEFT", 0, -5}, dressingRoom, 50)
    grabDefaultSlots(CharacterWristSlot, {"TOPLEFT", CharacterChestSlot, "BOTTOMLEFT", 0, -5}, dressingRoom, 50)
    grabDefaultSlots(CharacterHandsSlot, {"TOPLEFT", CharacterWristSlot, "BOTTOMLEFT", 0, -5}, dressingRoom, 50)
    grabDefaultSlots(CharacterWaistSlot, {"TOPLEFT", CharacterHandsSlot, "BOTTOMLEFT", 0, -5}, dressingRoom, 50)
    grabDefaultSlots(CharacterLegsSlot, {"TOPLEFT", CharacterWaistSlot, "BOTTOMLEFT", 0, -5}, dressingRoom, 50)
    grabDefaultSlots(CharacterFeetSlot, {"TOPLEFT", CharacterLegsSlot, "BOTTOMLEFT", 0, -5}, dressingRoom, 50)
    grabDefaultSlots(CharacterMainHandSlot, {"TOPLEFT", CharacterFeetSlot, "BOTTOMLEFT", 0, -20}, dressingRoom, 50)
    grabDefaultSlots(CharacterSecondaryHandSlot, {"TOPLEFT", CharacterMainHandSlot, "TOPRIGHT", 5, 0}, dressingRoom, 50)
    grabDefaultSlots(CharacterRangedSlot, {"TOPLEFT", CharacterMainHandSlot, "BOTTOMLEFT", 0, -5}, dressingRoom, 50)
    grabDefaultSlots(CharacterAmmoSlot, {"TOPLEFT", CharacterRangedSlot, "TOPRIGHT", 5, 0}, dressingRoom, 50)

    grabDefaultSlots(CharacterTabardSlot, {"TOPRIGHT", dressingRoom.stats, "BOTTOMRIGHT", -5, -20}, dressingRoom, 40)
    grabDefaultSlots(CharacterShirtSlot, {"TOPRIGHT", CharacterTabardSlot, "BOTTOMRIGHT", 0, -5}, dressingRoom, 40)
    grabDefaultSlots(CharacterTrinket0Slot, {"TOPRIGHT", CharacterTabardSlot, "TOPLEFT", -5, 0}, dressingRoom, 40)
    grabDefaultSlots(CharacterTrinket1Slot, {"TOPRIGHT", CharacterTrinket0Slot, "BOTTOMRIGHT", 0, -5}, dressingRoom, 40)
    grabDefaultSlots(CharacterFinger0Slot, {"TOPRIGHT", CharacterTrinket0Slot, "TOPLEFT", -5, 0}, dressingRoom, 40)
    grabDefaultSlots(CharacterFinger1Slot, {"TOPRIGHT", CharacterFinger0Slot, "BOTTOMRIGHT", 0, -5}, dressingRoom, 40)
    grabDefaultSlots(CharacterNeckSlot, {"TOPRIGHT", CharacterFinger0Slot, "TOPLEFT", -5, 0}, dressingRoom, 40)
    grabDefaultSlots(CharacterBackSlot, {"TOPRIGHT", CharacterNeckSlot, "BOTTOMRIGHT", 0, -5}, dressingRoom, 40)

    if UnitHasRelicSlot("player") then
        CharacterRangedSlot.icon:SetTexCoord(0.25, 0.5, 0.5, 0.625)
        CharacterAmmoSlot:Hide()
    else
        CharacterRangedSlot.icon:SetTexCoord(0, 0.25, 0.5, 0.625)
        CharacterAmmoSlot:Show()
    end

    hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
        if not button.IsGW2Hooked then return end
        local textureName = GetInventoryItemTexture("player", button:GetID())
        if not textureName then
            button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/slot-bg-classic.png")
            button.icon:SetTexCoord(unpack(PlayerSlots[button:GetName()]))
            if button == CharacterRangedSlot then
                if UnitHasRelicSlot("player") then
                    CharacterRangedSlot.icon:SetTexCoord(0.25, 0.5, 0.5, 0.625)
                else
                    CharacterRangedSlot.icon:SetTexCoord(0, 0.25, 0.5, 0.625)
                end
            end
            PaperDollSlotButton_Update(button)
        else
            button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            PaperDollSlotButton_Update(button)
        end
    end)

    GW.SetPaperDollModelPosition(dressingRoom.model)

    CharacterFrame:UnregisterAllEvents()
    HeroPanel.HookToggleCharacter(TOGGLE_PANELS)

    dressingRoom.characterName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    dressingRoom.characterData:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    dressingRoom.itemLevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)

    dressingRoomPet.characterName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    dressingRoomPet.characterData:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    dressingRoomPet.itemLevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)

    GW.StatsPicker.Setup(dressingRoom.stats, dressingRoom, PaperDollUpdateStats)
    PaperDollUpdateStats()
    PaperDollUpdatePetStats()
    C_Timer.After(1, function()
        PaperDollUpdateStats()
        PaperDollUpdatePetStats()
    end)

    -- setup gearscore
    UpdateItemLevelAndGearScore()

    local skillsFrame = GW.LoadPDSkills(tabContainer, heroPanelMenu)
    local titleFrame = GW.LoadPDTitles(tabContainer, heroPanelMenu)
    local gearSetsFrame = GW.LoadGearSets(tabContainer, heroPanelMenu)
    heroPanelMenu:SetupBackButton(dressingRoomPet.backButton, CHARACTER .. ": " .. PET)


    dressingRoomPet.model.expBar:SetScript("OnEnter", function(self)
        self.value:Show()
    end)
    dressingRoomPet.model.expBar:SetScript("OnLeave", function(self)
        self.value:Hide()
    end)

    dressingRoom.stats.advancedCharStatsFrame = CreateFrame("Frame", nil, dressingRoom.stats)
    dressingRoom.stats.advancedCharStatsFrame:SetPoint("TOPLEFT", dressingRoom.stats, "TOPLEFT", 0, -1)
    dressingRoom.stats.advancedCharStatsFrame:SetSize(180, 40)
    dressingRoom.stats.advancedCharStatsFrame:SetScript("OnMouseUp", function(self)
        GW.ShowAdvancedCharStats(self:GetParent())
    end)
    dressingRoom.stats.advancedCharStatsFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetText(ADVANCED_LABEL .. " " .. STAT_CATEGORY_ATTRIBUTES, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    dressingRoom.stats.advancedCharStatsFrame:SetScript("OnLeave", GameTooltip_Hide)
    if GW.settings.windows.character.advancedStats then
        GW.ShowAdvancedCharStats(dressingRoom.stats, true)
    end

    -- Secure stuff
    GW.CharacterMenuButton_OnLoad(heroPanelMenu.skillsMenu, true, true)
    GW.CharacterMenuButton_OnLoad(heroPanelMenu.titleMenu, false, true)
    GW.CharacterMenuButton_OnLoad(heroPanelMenu.gearMenu, true, true)
    GW.CharacterMenuButton_OnLoad(heroPanelMenu.petMenu, false, true)
    GW.SetCharacterWindowOpenAttribute(heroPanelMenu.skillsMenu, "paperdollskills")
    GW.SetCharacterWindowOpenAttribute(heroPanelMenu.titleMenu, "titles")
    GW.SetCharacterWindowOpenAttribute(heroPanelMenu.gearMenu, "gearset")
    GW.SetCharacterWindowOpenAttribute(heroPanelMenu.petMenu, "paperdollpet")

    GwCharacterWindow:SetFrameRef("GwDressingRoom", dressingRoom)
    GwCharacterWindow:SetFrameRef("GwHeroPanelMenu", heroPanelMenu)
    GwCharacterWindow:SetFrameRef("GwPaperSkills", skillsFrame)
    GwCharacterWindow:SetFrameRef("GwPaperDollTitles", titleFrame)
    GwCharacterWindow:SetFrameRef("GwPaperDollDressingRoom", dressingRoom)
    GwCharacterWindow:SetFrameRef("GwPaperDollOutfits", gearSetsFrame)
    GwCharacterWindow:SetFrameRef("GwPetContainer", petContainer)

    -- add addon buttons here
    GwCharacterWindow:SetAttribute("myClassId", GW.myClassID)
    if GW.myClassID == 3 or GW.myClassID == 9 or GW.myClassID == 6 then
        GwCharacterWindow:SetNextAddonMenuButtonShadowState(false)
    else
        GwCharacterWindow:SetNextAddonMenuButtonShadowState(true)
    end
    GwCharacterWindow:SetNextAddonMenuButtonAnchor((GW.myClassID == 3 or GW.myClassID == 9 or GW.myClassID == 6) and heroPanelMenu.petMenu or heroPanelMenu.gearMenu)
    heroPanelMenu.Outfitter = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "Outfitter",
        setting = GW.settings.windows.character.enabled,
        showFunction = function() hideCharframe = false Outfitter:OpenUI() end,
        hideOurFrame = true,
    })

    heroPanelMenu["GearQuipper-TBC"] = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "GearQuipper-TBC",
        setting = GW.settings.windows.character.enabled,
        showFunction = function() gearquipper:ToggleUI() end,
        hideOurFrame = false,
        onCreated = function(createdButton)
            createdButton:SetText("GearQuipper")
            GqUiFrame:ClearAllPoints()
            GqUiFrame:SetParent(GwCharacterWindow)
            GqUiFrame:SetPoint("TOPRIGHT", GwCharacterWindow, "TOPRIGHT", 350, -12)
        end,
    })
    heroPanelMenu.Clique = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "Clique",
        setting = GW.settings.windows.spellbook.enabled,
        showFunction = function() ShowUIPanel(CliqueConfig) end,
        hideOurFrame = true,
    })

    heroPanelMenu.Pawn = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "Pawn",
        setting = GW.settings.windows.character.enabled,
        showFunction = function() PawnUIShow() end,
        onEnter = function(self) PawnUI_InventoryPawnButton_OnEnter(self) end,
        hideOurFrame = false,
    })

    -- pet GwDressingRoom
    heroPanelMenu.petMenu:SetAttribute("_onstate-petstate", [=[
        if newstate == "nopet" then
            self:Disable()
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("HasPetUI", false)
        elseif newstate == "hasPet" then
            self:Enable()
            self:GetFrameRef("GwCharacterWindow"):SetAttribute("HasPetUI", true)
        end
    ]=])
    RegisterAttributeDriver(heroPanelMenu.petMenu, "state-petstate", "[@pet,noexists] nopet; [@pet,help] hasPet; [@pet,harm] nopet")

    CharacterFrame:SetScript("OnShow", function()
        if hideCharframe then
            HideUIPanel(CharacterFrame)
        end
        hideCharframe = true
    end)

end
GW.LoadPaperDoll = LoadPaperDoll
