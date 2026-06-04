---@class GW2
local GW = select(2, ...)
local GWGetClassColor = GW.GWGetClassColor

local hideCharframe = true

local PlayerSlots = {
    ["CharacterHeadSlot"] = {0, 0.25, 0, 0.125},
    ["CharacterNeckSlot"] = {0.25, 0.5, 0, 0.125},
    ["CharacterShoulderSlot"] = {0.5, 0.75, 0.25, 0.375},
    ["CharacterBackSlot"] = {0.75, 1, 0, 0.125},
    ["CharacterChestSlot"] = {0.75, 1, 0.25, 0.375},
    ["CharacterShirtSlot"] = {0.75, 1, 0.25, 0.375},
    ["CharacterTabardSlot"] = {0.25, 0.5, 0.375, 0.5},
    ["CharacterWristSlot"] = {0.75, 1, 0.125, 0.25},
    ["CharacterHandsSlot"] = {0, 0.25, 0.375, 0.5},
    ["CharacterWaistSlot"] = {0.25, 0.5, 0.25, 0.375},
    ["CharacterLegsSlot"] = {0, 0.25, 0.25, 0.375},
    ["CharacterFeetSlot"] = {0.5, 0.75, 0.125, 0.25},
    ["CharacterFinger0Slot"] = {0.5, 0.75, 0, 0.125},
    ["CharacterFinger1Slot"] = {0.5, 0.75, 0, 0.125},
    ["CharacterTrinket0Slot"] = {0.5, 0.75, 0.375, 0.5},
    ["CharacterTrinket1Slot"] = {0.5, 0.75, 0.375, 0.5},
    ["CharacterMainHandSlot"] = {0.25, 0.5, 0.125, 0.25},
    ["CharacterSecondaryHandSlot"] = {0, 0.25, 0.125, 0.25},
    ["CharacterRangedSlot"] = {0.25, 0.5, 0.5, 0.625},
    ["CharacterAmmoSlot"] = {0.75, 1, 0.375, 0.5},
}

local  statsIconsSprite = {
    width = 256,
    height = 512,
    colums = 4,
    rows = 8
}

local  petStateSprite = {
    width = 512,
    height = 128,
    colums = 4,
    rows = 1
}

local STATS_ICONS ={
    STRENGTH = {x = 1, y = 5},
    AGILITY = {x = 2, y = 5},
    INTELLECT = {x = 3, y = 5},
    SPIRIT= {x = 4, y = 2},
    STAMINA = {x = 1, y = 2},
    ARMOR = {x = 3, y = 1},
    CRITCHANCE = {x = 2, y = 2},
    HASTE = {x = 1, y = 3},
    MASTERY = {x = 1, y = 1},
    --Needs icon
    MANAREGEN = {x = 4, y = 2},
    VERSATILITY = {x = 2, y = 3},
    LIFESTEAL = {x = 2, y = 4},
    --Needs icon
    AVOIDANCE = {x =4 , y = 1},
    --DODGE needs icon
    DODGE = {x = 3, y = 3},
    DEFENSE = {x = 4, y = 3},
    PARRY = {x = 1, y = 1},
    MOVESPEED = {x = 3, y = 2},
    ATTACKRATING = {x = 4, y = 5},
    DAMAGE = {x = 4, y = 4},
    ATTACKPOWER = {x = 1, y = 6},
    RANGEDATTACK = {x = 2, y = 6},
    RANGEDDAMAGE = {x = 3, y = 6},
    RANGEDATTACKPOWER = {x = 4, y = 6},
    Holy = {x = 1, y = 7},
    Fire = {x = 2, y = 7},
    Nature = {x = 3, y = 7},
    Frost = {x = 4, y = 7},
    Shadow = {x = 1, y = 8},
    Arcane = {x = 2, y = 8},
}


local function PaperDollStats_QueuedUpdate(self)
    self:SetScript("OnUpdate", nil)
    GW.PaperDollUpdateStats(self:GetParent())
end

local function PaperDollUpdateUnitData(dressingRoom)
    dressingRoom.characterName:SetText(UnitPVPName("player"))
    local _, name = C_SpecializationInfo.GetSpecializationInfo(GW.myspec)
    local color = GWGetClassColor(GW.myclass, true)
    GW.SetClassIcon(dressingRoom.classIcon, GW.myclass)

    dressingRoom.classIcon:SetVertexColor(color.r, color.g, color.b, color.a)

    if name ~= nil then
        local data = GUILD_RECRUITMENT_LEVEL .. " " .. GW.mylevel .. " " .. name .. " " .. GW.myLocalizedClass
        dressingRoom.characterData:SetText(data)
    else
        dressingRoom.characterData:SetFormattedText(PLAYER_LEVEL, GW.mylevel, GW.myLocalizedRace, GW.myLocalizedClass)
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
    GW.PaperDollUpdatePetStats(self:GetParent())
end

local function PaperDollStats_OnEvent(self, event, ...)
    local unit = ...
    local parent = self:GetParent()
    if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_MODEL_CHANGED" or event=="UNIT_NAME_UPDATE" or event=="PLAYER_PVP_RANK_CHANGED" and unit == "player" then
        parent.model:SetUnit("player", false)
        PaperDollUpdateUnitData(parent)
        return
    end

    if unit == "player" then
        if event == "UNIT_LEVEL" then
            PaperDollUpdateUnitData(parent)
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
            self:SetScript("OnUpdate", PaperDollStats_QueuedUpdate)
        end
    end

    if event == "COMBAT_RATING_UPDATE" or
            event == "SPEED_UPDATE" or
            event == "LIFESTEAL_UPDATE" or
            event == "AVOIDANCE_UPDATE" or
            event == "BAG_UPDATE" or
            event == "PLAYER_EQUIPMENT_CHANGED" or
            event == "PLAYERBANKSLOTS_CHANGED" or
            event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" or
            event == "PLAYER_DAMAGE_DONE_MODS" or
            IsMounted() then
        self:SetScript("OnUpdate", PaperDollStats_QueuedUpdate)
    elseif event == "PLAYER_TALENT_UPDATE" then
        PaperDollUpdateUnitData(parent)
        self:SetScript("OnUpdate", PaperDollStats_QueuedUpdate)
    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
        GW.PaperDollUpdateStats(parent)
    elseif event == "SPELL_POWER_CHANGED" then
        self:SetScript("OnUpdate", PaperDollStats_QueuedUpdate)
    end
end

local function statGridPos(grid, x, y)
    grid = grid + 1
    x = x + 92
    if grid > 2 then
        grid = 1
        x = 0
        y = y + 30
    end
    return grid, x, y
end

local function StatOnEnter(self)
    if not self.tooltip then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltip)
    if self.tooltip2 then
        GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
    end
    GameTooltip:Show()
end

local function PaperDollGetStatListFrame(self, i, isPet, stat)
    local frameName = isPet and ("GwPaperDollPetStat" .. i) or ("GwPaperDollStat" .. i)
    local frame = _G[frameName]
    if frame then
        return frame
    end
    frame = CreateFrame("Frame", frameName, self, "GwPaperDollStat")

    if stat == "DURABILITY" then
        frame:SetScript("OnEnter", GW.DurabilityTooltip)
        frame:SetScript("OnEvent", GW.DurabilityOnEvent)
        frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        frame:RegisterEvent("MERCHANT_SHOW")
    else
        frame:SetScript("OnEnter", StatOnEnter)
    end
    frame:SetScript("OnLeave", GameTooltip_Hide)
    frame.Value:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    frame.Label:SetFont(UNIT_NAME_FONT, 1, "")
    frame.Label:SetTextColor(0, 0, 0, 0)
    frame.Value:SetText("")
    frame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/statsicon-classic.png")

    return frame
end

local function setStatFrame(stat, index, statText, tooltip, tooltip2, grid, x, y)
    local statFrame = PaperDollGetStatListFrame(GwDressingRoom.stats, index, false, stat)
    statFrame.tooltip = tooltip
    statFrame.tooltip2 = tooltip2
    statFrame.stat = stat
    statFrame.Value:SetText(statText)
    GW.PaperDollSetStatIcon(statFrame, stat)

    statFrame:ClearAllPoints()
    if stat == "DURABILITY" then
        statFrame:SetPoint("TOPRIGHT", GwDressingRoom.stats, "TOPRIGHT", 22, -1)
        statFrame.icon:SetSize(25, 25)
        GW.DurabilityOnEvent(statFrame, "ForceUpdate")
    else
        statFrame:SetPoint("TOPLEFT", 5 + x, -35 + -y)
    end
    grid, x, y = statGridPos(grid, x, y)
    return grid, x, y, index + 1
end
local function setPetStatFrame(stat, index, statText, tooltip, tooltip2, grid, x, y)
    local statFrame = PaperDollGetStatListFrame(GwDressingRoomPet.stats, index, true)
    statFrame.tooltip = tooltip
    statFrame.tooltip2 = tooltip2
    statFrame.stat = stat
    statFrame.Value:SetText(statText)
    GW.PaperDollSetStatIcon(statFrame, stat)

    statFrame:SetPoint("TOPLEFT", 5 + x, -35 + -y)
    grid, x, y = statGridPos(grid, x, y)
    return grid, x, y, index + 1
end

local function PaperDollUpdateStats(dressingRoom)
    local avgItemLevel, avgItemLevelEquipped = GW.GetAverageItemLevel()
    local r, g,b = GW.GetItemLevelColor(avgItemLevel)
    local statText, tooltip1, tooltip2

    avgItemLevelEquipped = avgItemLevelEquipped and avgItemLevelEquipped or 0
    avgItemLevel = avgItemLevel and avgItemLevel or 0
    avgItemLevelEquipped = math.floor(avgItemLevelEquipped)
    avgItemLevel = math.floor(avgItemLevel)
    if avgItemLevelEquipped < avgItemLevel then
        avgItemLevelEquipped = math.floor(avgItemLevel) .. " (" .. math.floor(avgItemLevelEquipped) .. ")"
    end
    avgItemLevelEquipped = avgItemLevelEquipped == 0 and "" or avgItemLevelEquipped
    dressingRoom.itemLevel:SetText(avgItemLevelEquipped)
    dressingRoom.itemLevel:SetTextColor(r, g,b)

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

    -- Defense only for Tanksclasses
    if GW.myClassID == 1 or GW.myClassID == 2 or GW.myClassID == 11 then
        statText, tooltip1, tooltip2 = GW.stats.getDefense()
        grid, x, y, numShownStats = setStatFrame("DEFENSE", numShownStats, statText, tooltip1, tooltip2, grid, x, y)
    end

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
    grid, x, y, numShownStats = setStatFrame("DURABILITY", numShownStats, "DURABILITY", nil, nil, grid, x, y)
end
GW.PaperDollUpdateStats = PaperDollUpdateStats

local function PaperDollUpdatePetStats(dressingRoomPet)
    local hasUI, isHunterPet = HasPetUI()
    local statText, tooltip1, tooltip2
    if not hasUI then return end

    local numShownStats = 1
    local grid = 1
    local x = 0
    local y = 0

    dressingRoomPet.model:SetUnit("pet")
    if UnitCreatureFamily("pet") then
		dressingRoomPet.characterName:SetText((UnitName("pet") or "") .. " - " .. format(UNIT_LEVEL_TEMPLATE, (UnitLevel("pet") or ""), "") .. " " .. (UnitCreatureFamily("pet") or ""))
	else
        dressingRoomPet.characterName:SetText((UnitName("pet") or "") .. " - " .. format(UNIT_LEVEL_TEMPLATE, (UnitLevel("pet") or ""), ""))
    end

    if isHunterPet then
        local happiness = GetPetHappiness()
        local totalPoints, spent = GetPetTrainingPoints()
        local currXP, nextXP = GetPetExperience()

        dressingRoomPet.model.expBar:SetMinMaxValues(min(0, currXP), nextXP)
        dressingRoomPet.model.expBar:SetValue(currXP)
        dressingRoomPet.model.expBar.value:SetText(GW.CommaValue(currXP) .. " / " .. GW.CommaValue(nextXP) .. " - " .. math.floor(currXP / nextXP * 100) .. "%")
        dressingRoomPet.classIcon:SetTexCoord(GW.getSprite(petStateSprite, happiness, 1))
        dressingRoomPet.itemLevel:SetText(totalPoints - spent)
        dressingRoomPet.characterData:SetText(GetPetLoyalty())
        dressingRoomPet.characterData:Show()
        dressingRoomPet.itemLevel:Show()
        dressingRoomPet.itemLevelLabel:Show()
        dressingRoomPet.classIcon:Show()
        dressingRoomPet.model.expBar:Show()
        dressingRoomPet.model:SetPosition(-2,0,-0.5)
        dressingRoomPet.model:SetRotation(-0.15)

        dressingRoomPet.happiness:Show()
    else
        dressingRoomPet.model.expBar:Hide()
        dressingRoomPet.characterData:Hide()
        dressingRoomPet.itemLevel:Hide()
        dressingRoomPet.itemLevelLabel:Hide()
        dressingRoomPet.classIcon:Hide()
        dressingRoomPet.model:SetPortraitZoom(-0.8)
        dressingRoomPet.model.zoomLevel = -0.8
        dressingRoomPet.model:SetRotation(0.5)
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

local function PaperDollSetStatIcon(self, stat)
    local newTexture = "Interface/AddOns/GW2_UI/textures/character/statsicon-classic.png"

    if stat == "DURABILITY" then
        newTexture = "Interface/AddOns/GW2_UI/textures/globe/repair.png"
    elseif STATS_ICONS[stat] then
        self.icon:SetTexCoord(GW.getSprite(statsIconsSprite,STATS_ICONS[stat].x,STATS_ICONS[stat].y))
    end

    if newTexture ~= self.icon:GetTexture() then
        self.icon:SetTexture(newTexture)
        if stat == "DURABILITY" then
            self.icon:SetTexCoord(0, 1, 0, 0.5)
            self.icon:SetDesaturated(true)
        end
    end
end
GW.PaperDollSetStatIcon = PaperDollSetStatIcon

local function GwSetItemButtonQuality(button, quality)
    if quality then
        if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
            button.IconBorder:Show();
            button.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
        else
            button.IconBorder:Hide();
        end
    else
        button.IconBorder:Hide();
    end
end

local function PaperDollSlotButton_Update(self)
    local slot = self:GetID()
    local textureName = GetInventoryItemTexture("player", slot)
    local cooldown = _G[self:GetName() .. "Cooldown"]

    if textureName then
        if (GetInventoryItemBroken("player", slot) or GetInventoryItemEquippedUnusable("player", slot)) then
            SetItemButtonTextureVertexColor(self, 0.9, 0, 0)
        else
            SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0)
        end

        if self.repairIcon then
            local current, maximum = GetInventoryItemDurability(slot)
            if current ~= nil and (current / maximum) < 0.5 then
                self.repairIcon:Show()
                if (current / maximum) == 0 then
                    self.repairIcon:SetTexCoord(0, 1, 0.5, 1)
                else
                    self.repairIcon:SetTexCoord(0, 1, 0, 0.5)
                end
            else
                self.repairIcon:Hide()
            end
        end

        if cooldown then
            local start, duration, enable = GetInventoryItemCooldown("player", slot)
            CooldownFrame_Set(cooldown, start, duration, enable)
        end
        self.hasItem = 1
    else
        if self.repairIcon then self.repairIcon:Hide() end
    end

    if GW.settings.SHOW_CHARACTER_ITEM_INFO and self.itemlevel then
        local itemLink = GetInventoryItemLink("player", slot)
        if itemLink then
            local iLvl = C_Item.GetDetailedItemLevelInfo(itemLink)
            if iLvl then
                local quality = GetInventoryItemQuality("player", slot)
                if quality >= Enum.ItemQuality.Common then
                    local r, g, b = C_Item.GetItemQualityColor(quality)
                    self.itemlevel:SetTextColor(r or 1, g or 1, b or 1, 1)
                end
                self.itemlevel:SetText(iLvl)
            else
                self.itemlevel:SetText("")
            end
        else
            self.itemlevel:SetText("")
        end
    elseif self.itemlevel then
        self.itemlevel:SetText("")
    end

    if self.IconBorder then
        local quality = GetInventoryItemQuality("player", slot)
        GwSetItemButtonQuality(self, quality)
    end
end

function LoadPVPTab(container)
    PVPFrame.Hide = PVPFrame.Show
    PVPFrame:Show()
    PVPFrame:SetParent(container)
    PVPFrame:ClearAllPoints()
    PVPFrame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    PVPFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 8)

    PVPFrameBackground:ClearAllPoints()
    PVPFrameBackground:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    PVPFrameBackground:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 8)

    PVPFrame:GwStripTextures(true)

    PVPFrameHonorLabel:ClearAllPoints()
    PVPFrameHonorLabel:SetPoint("TOP", PVPFrameBackground, "TOP", 0, -10)
    PVPFrameHonorLabel:SetFont(UNIT_NAME_FONT, 14)
    PVPFrameHonorPoints:SetFont(UNIT_NAME_FONT, 14)

    PVPFrameArenaLabel:ClearAllPoints()
    PVPFrameArenaLabel:SetPoint("TOP", PVPFrameBackground, "TOP", 0, -130)
    PVPFrameArenaLabel:SetFont(UNIT_NAME_FONT, 14)
    PVPFrameArenaPoints:SetFont(UNIT_NAME_FONT, 14)

    PVPHonor:ClearAllPoints()
    PVPHonor:SetPoint("TOP", PVPFrameBackground, "TOP", 0, -35)

    PVPHonorKillsLabel:SetFont(STANDARD_TEXT_FONT, 14)
    PVPHonorTodayLabel:SetFont(STANDARD_TEXT_FONT, 14)
    PVPHonorTodayKills:SetFont(STANDARD_TEXT_FONT, 14)
    PVPHonorYesterdayLabel:SetFont(STANDARD_TEXT_FONT, 14)
    PVPHonorYesterdayKills:SetFont(STANDARD_TEXT_FONT, 14)
    PVPHonorLifetimeLabel:SetFont(STANDARD_TEXT_FONT, 14)
    PVPHonorLifetimeKills:SetFont(STANDARD_TEXT_FONT, 14)

    PVPTeam1Standard:ClearAllPoints()
    PVPTeam1Standard:SetPoint("LEFT", PVPFrameBackground, "LEFT", 150, 90)

    PVPTeam2Standard:ClearAllPoints()
    PVPTeam2Standard:SetPoint("LEFT", PVPFrameBackground, "LEFT", 150, 0)

    PVPTeam3Standard:ClearAllPoints()
    PVPTeam3Standard:SetPoint("LEFT", PVPFrameBackground, "LEFT", 150, -90)
end

local CHARACTER_PANEL_OPEN = ""
function GwToggleCharacter(tab, onlyShow)
    if InCombatLockdown() then
        return
    end

    local CHARACTERFRAME_DEFAULTFRAMES= {}

    CHARACTERFRAME_DEFAULTFRAMES["PaperDollFrame"] = GwHeroPanelMenu
    CHARACTERFRAME_DEFAULTFRAMES["ReputationFrame"] = GwPaperReputation
    CHARACTERFRAME_DEFAULTFRAMES["SkillFrame"] = GwPaperSkills
    CHARACTERFRAME_DEFAULTFRAMES["PetPaperDollFrame"] = GwPetContainer

    if CHARACTERFRAME_DEFAULTFRAMES[tab] ~= nil and CHARACTER_PANEL_OPEN ~= tab  then
        CHARACTER_PANEL_OPEN = tab
        if tab == "ReputationFrame" then
            if not onlyShow then
                GwCharacterWindow:SetAttribute("keytoggle", true)
            end
            GwCharacterWindow:SetAttribute("windowpanelopen", "reputation")
        elseif tab == "SkillFrame" then
            if not onlyShow then
                GwCharacterWindow:SetAttribute("keytoggle", true)
            end
            GwCharacterWindow:SetAttribute("windowpanelopen", "paperdollskills")
        elseif tab == "HonorFrame" then
            if not onlyShow then
                GwCharacterWindow:SetAttribute("keytoggle", true)
            end
            GwCharacterWindow:SetAttribute("windowpanelopen", "paperdollhonor")
        elseif tab == "PetPaperDollFrame" then
            if not onlyShow then
                GwCharacterWindow:SetAttribute("keytoggle", true)
            end
            GwCharacterWindow:SetAttribute("windowpanelopen", "paperdollpet")
        else
            -- PaperDollFrame or any other value
            if not onlyShow then
                GwCharacterWindow:SetAttribute("keytoggle", true)
            end
            GwCharacterWindow:SetAttribute("windowpanelopen", "paperdoll")
        end

        return
    end

    if GwCharacterWindow:IsShown() then
        if not InCombatLockdown() then
            GwCharacterWindow:SetAttribute("windowPanelOpen", nil)
        end
        CHARACTER_PANEL_OPEN = nil
        return
    end
end

local function grabDefaultSlots(slot, anchor, parent, size)
    slot:ClearAllPoints()
    slot:SetPoint(unpack(anchor))
    slot:SetParent(parent)
    slot:SetSize(size, size)
    slot:GwStripTextures()
    slot:SetFrameLevel(parent:GetFrameLevel() + 15)

    if slot.icon then
        slot.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        slot.icon:SetAlpha(0.9)
        slot.icon:SetAllPoints(slot)
    else
        local icon = _G[slot:GetName() .. "IconTexture"]
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        icon:SetAlpha(0.9)
        icon:SetAllPoints(slot)
        slot.icon = icon
    end
    if slot.IconBorder then
        slot.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
        slot.IconBorder:SetAllPoints(slot)
        slot.IconBorder:SetParent(slot)
    end

    slot:GetNormalTexture():SetTexture(nil)

    local high = slot:GetHighlightTexture()
    high:SetAllPoints(slot)
    high:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)

    if slot ~= CharacterAmmoSlot then
        slot.repairIcon = slot:CreateTexture(nil, "OVERLAY")
        slot.repairIcon:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", 0, 0)
        slot.repairIcon:SetTexture("Interface/AddOns/GW2_UI/textures/globe/repair.png")
        slot.repairIcon:SetTexCoord(0, 1, 0.5, 1)
        slot.repairIcon:SetSize(20, 20)

        slot.itemlevel = slot:CreateFontString(nil, "OVERLAY")
        slot.itemlevel:SetSize(size, 10)
        slot.itemlevel:SetPoint("BOTTOMLEFT", 1, 2)
        slot.itemlevel:SetTextColor(1, 1, 1)
        slot.itemlevel:SetJustifyH("LEFT")
        slot.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
    end

    slot.IsGW2Hooked = true
end

local function menu_SetupBackButton(_, fmBtn, key)
    GW.CharacterMenuButtonBack_OnLoad(fmBtn, key, true)
    GW.SetCharacterWindowOpenAttribute(fmBtn, "paperdoll", false)
end

local function LoadPaperDoll(tabContainer)
    local dressingRoom = CreateFrame("Button", "GwDressingRoom", tabContainer, "GwDressingRoom")
    local heroPanelMenu = CreateFrame("Frame", "GwHeroPanelMenu", tabContainer, "GwCharacterMenuFilledTemplate")
    local honorFrame = CreateFrame("Frame", "GwPaperHonor", tabContainer, "GwPaperHonor")

    --Legacy pet window
    local petContainer = CreateFrame("Frame", "GwPetContainer", tabContainer, "GwPetContainer")
    local dressingRoomPet = CreateFrame("Button", "GwDressingRoomPet", petContainer, "GwPetPaperdoll")

    GwCharacterWindow:SetHeroPanelMenu(heroPanelMenu)

    dressingRoom.stats:SetScript("OnEvent", PaperDollStats_OnEvent)
    dressingRoomPet.stats:SetScript("OnEvent", PaperDollPetStats_OnEvent)

    heroPanelMenu.SetupBackButton = menu_SetupBackButton


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
    hooksecurefunc("ToggleCharacter", GwToggleCharacter)

    dressingRoom.characterName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    dressingRoom.characterData:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    dressingRoom.itemLevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)

    dressingRoomPet.characterName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    dressingRoomPet.characterData:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    dressingRoomPet.itemLevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)

    PaperDollUpdateStats(dressingRoom)
    PaperDollUpdatePetStats(dressingRoomPet)

    local titelFrame = GW.LoadPDTitles(tabContainer, heroPanelMenu)
    local skillsFrame = GW.LoadPDSkills(tabContainer, heroPanelMenu)
    LoadPVPTab(honorFrame)
    heroPanelMenu:SetupBackButton(honorFrame.backButton, CHARACTER .. ": " .. HONOR)
    heroPanelMenu:SetupBackButton(dressingRoomPet.backButton, CHARACTER .. ": " .. PET)

    dressingRoom.stats.advancedChatStatsFrame = CreateFrame("Frame", nil, dressingRoom.stats)
    dressingRoom.stats.advancedChatStatsFrame:SetPoint("TOPLEFT", dressingRoom.stats, "TOPLEFT", 0, -1)
    dressingRoom.stats.advancedChatStatsFrame:SetSize(180, 40)
    dressingRoom.stats.advancedChatStatsFrame:SetScript("OnMouseUp", function(self)
        GW.ShowAdvancedChatStats(self:GetParent())
    end)
    dressingRoom.stats.advancedChatStatsFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetText(ADVANCED_LABEL .. " " .. STAT_CATEGORY_ATTRIBUTES, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    dressingRoom.stats.advancedChatStatsFrame:SetScript("OnLeave", GameTooltip_Hide)

    -- Secure stuff
    GW.CharacterMenuButton_OnLoad(heroPanelMenu.skillsMenu, true, true)
    GW.CharacterMenuButton_OnLoad(heroPanelMenu.titleMenu, false, true)
    GW.CharacterMenuButton_OnLoad(heroPanelMenu.honorMenu, true, true)
    GW.CharacterMenuButton_OnLoad(heroPanelMenu.petMenu, false, true)
    GW.SetCharacterWindowOpenAttribute(heroPanelMenu.skillsMenu, "paperdollskills")
    GW.SetCharacterWindowOpenAttribute(heroPanelMenu.titleMenu, "titles")
    GW.SetCharacterWindowOpenAttribute(heroPanelMenu.honorMenu, "paperdollhonor")
    GW.SetCharacterWindowOpenAttribute(heroPanelMenu.petMenu, "paperdollpet")

    GwCharacterWindow:SetFrameRef("GwHeroPanelMenu", heroPanelMenu)
    GwCharacterWindow:SetFrameRef("GwPaperDollTitles", titelFrame)
    GwCharacterWindow:SetFrameRef("GwPaperHonor", honorFrame)
    GwCharacterWindow:SetFrameRef("GwPaperSkills", skillsFrame)
    GwCharacterWindow:SetFrameRef("GwDressingRoom", dressingRoom)
    GwCharacterWindow:SetFrameRef("GwPetContainer", petContainer)

    -- add addon buttons here
    GwCharacterWindow:SetAttribute("myClassId", GW.myClassID)
    GwCharacterWindow:SetNextAddonMenuButtonShadowState(GW.myClassID == 3 or GW.myClassID == 9 or GW.myClassID == 6)
    GwCharacterWindow:SetNextAddonMenuButtonAnchor((GW.myClassID == 3 or GW.myClassID == 9 or GW.myClassID == 6) and heroPanelMenu.petMenu or heroPanelMenu.honorMenu)
    heroPanelMenu.Outfitter = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "Outfitter",
        setting = GW.settings.USE_CHARACTER_WINDOW,
        showFunction = function() hideCharframe = false Outfitter:OpenUI() end,
        hideOurFrame = true,
    })

    heroPanelMenu["GearQuipper-TBC"] = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "GearQuipper-TBC",
        setting = GW.settings.USE_CHARACTER_WINDOW,
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
        setting = GW.settings.USE_SPELLBOOK_WINDOW,
        showFunction = function() ShowUIPanel(CliqueConfig) end,
        hideOurFrame = true,
    })

    heroPanelMenu.Pawn = GW.AddAddonMenuButtonToHeroPanelMenu({
        name = "Pawn",
        setting = GW.settings.USE_CHARACTER_WINDOW,
        showFunction = function() PawnUIShow() end,
        hideOurFrame = false,
    })

    -- pet GwDressingRoom
    heroPanelMenu.petMenu:SetAttribute("_onstate-petstate", [=[
        local f = self:GetFrameRef("GwCharacterWindow")
        local myClassId = f:GetAttribute("myClassId")
        if myClassId == 3 or myClassId == 6 or myClassId == 9 then
            self:Show()
        else
            self:Hide()
        end
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
