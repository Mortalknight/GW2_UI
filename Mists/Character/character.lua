local _, GW = ...
local GWGetClassColor = GW.GWGetClassColor

local modelPositions = {
    Human = {0.4, 0, -0.05},
    Worgen = {0.1, 0, -0.1},
    Tauren = {0.6, 0, 0},
    HighmountainTauren = {0.6, 0, 0},
    BloodElf = {0.5, 0, 0},
    VoidElf = {0.5, 0, 0},
    Draenei = {0.3, 0, -0.15},
    LightforgedDraenei = {0.3, 0, -0.15},
    NightElf = {0.3, 0, -0.15},
    Nightborne = {0.3, 0, -0.15},
    Pandaren = {0.3, 0, -0.15},
    KulTiran = {0.3, 0, -0.15},
    Goblin = {0.2, 0, -0.05},
    Vulpera = {0.2, 0, -0.05},
    Troll = {0.2, 0, -0.05},
    ZandalariTroll = {0.2, 0, -0.05},
    Scourge = {0.2, 0, -0.05},
    Dwarf = {0.3, 0, 0},
    DarkIronDwarf = {0.3, 0, 0},
    Gnome = {0.2, 0, -0.05},
    Mechagnome = {0.2, 0, -0.05},
    Orc = {0.1, 0, -0.15},
    MagharOrc = {0.1, 0, -0.15},
    Dracthyr = {0.1, 0, -0.15},
}

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
}

PaperDollItemSlotButton_GetSlotName(CharacterSecondaryHandSlot)

local  statsIconsSprite = {
    width = 256,
    height = 512,
    colums = 4,
    rows = 8
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
    GW.PaperDollUpdateStats()
end

local function PaperDollUpdateUnitData()
    GwDressingRoom.characterName:SetText(UnitPVPName("player"))
    local _, specName = C_SpecializationInfo.GetSpecializationInfo(GW.myspec)
    local color = GWGetClassColor(GW.myclass, true)
    local classColorString = format("ff%.2x%.2x%.2x", color.r * 255, color.g * 255, color.b * 255);
    GW.SetClassIcon(GwDressingRoom.classIcon, GW.myclass)

    GwDressingRoom.classIcon:SetVertexColor(color.r, color.g, color.b, color.a)

    if specName then
        GwDressingRoom.characterData:SetText(GUILD_RECRUITMENT_LEVEL .. " " .. GW.mylevel.. " " .. specName .. " " .. GW.myLocalizedClass)
    else
        GwDressingRoom.characterData:SetFormattedText(PLAYER_LEVEL, GW.mylevel, classColorString, GW.myLocalizedRace, GW.myLocalizedClass)
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
    if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_MODEL_CHANGED" or event=="UNIT_NAME_UPDATE" or event=="PLAYER_PVP_RANK_CHANGED" and unit == "player" then
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
                event == "MASTERY_UPDATE" or
                event == "UNIT_RANGED_ATTACK_POWER" or
                event == "UNIT_SPELL_HASTE" or
                event == "UNIT_MAXHEALTH" or
                event == "UNIT_AURA" or
                event == "UNIT_RESISTANCES" or
                event == "UPDATE_INVENTORY_ALERTS" then
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
            event == "PLAYER_DAMAGE_DONE_MODS" then
        self:SetScript("OnUpdate", PaperDollStats_QueuedUpdate)
    elseif event == "PLAYER_TALENT_UPDATE" then
        PaperDollUpdateUnitData()
        self:SetScript("OnUpdate", PaperDollStats_QueuedUpdate)
    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
        GW.PaperDollUpdateStats()
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
    if self.stat == "MASTERY" then
        Mastery_OnEnter(self)
        return
    elseif self.stat == "MOVESPEED" then
        MovementSpeed_OnEnter(self)
        return
    elseif self.stat == "DURABILITY" then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GW.DurabilityTooltip()
        return
    end
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
    frame.Value:SetFont(UNIT_NAME_FONT, 14, "")
    frame.Label:SetFont(UNIT_NAME_FONT, 1, "")
    frame.Label:SetTextColor(0, 0, 0, 0)
    frame.Value:SetText("")

    return frame
end

local function setStatFrame(stat, index, statText, tooltip, tooltip2, grid, x, y)
    local statFrame = PaperDollGetStatListFrame(GwDressingRoom.stats, index, false, stat)
    statFrame.tooltip = tooltip
    statFrame.tooltip2 = tooltip2
    statFrame.stat = stat
    GW.PaperDollSetStatIcon(statFrame, stat)

    statFrame:ClearAllPoints()
    if stat == "DURABILITY" then
        statFrame.icon:SetSize(25, 25)
        GW.DurabilityOnEvent(statFrame, "ForceUpdate")
    else
        statFrame.Value:SetText(statText)
    end
    statFrame:SetPoint("TOPLEFT", 5 + x, -35 + -y)
    grid, x, y = statGridPos(grid, x, y)

    if stat == "MOVESPEED" then
        statFrame.wasSwimming = nil;
        statFrame.unit = "player";
        MovementSpeed_OnUpdate(statFrame);
        statFrame:SetScript("OnUpdate", MovementSpeed_OnUpdate)
    end

    return grid, x, y, index + 1
end

local function setPetStatFrame(stat, index, statText, tooltip, tooltip2, grid, x, y)
    local statFrame = PaperDollGetStatListFrame(GwDressingRoomPet.stats, index, true)
    statFrame.tooltip = tooltip
    statFrame.tooltip2 = tooltip2
    statFrame.stat = stat
    statFrame.Value:SetText(statText)
    GW.PaperDollSetStatIcon(statFrame, stat)

    statFrame:ClearAllPoints()
    statFrame:SetPoint("TOPLEFT", 5 + x, -35 + -y)
    grid, x, y = statGridPos(grid, x, y)
    return grid, x, y, index + 1
end

local function UpdateItemLevelAndGearScore()
    local average, equipped = GW.GetPlayerItemLevel()
    local itemLevelText = math.floor(equipped)
    if equipped < average then
        itemLevelText = itemLevelText .. "(" .. math.floor(average) .. ")"
    end
    GwDressingRoom.itemLevel:SetText(itemLevelText)
    GwDressingRoom.itemLevel:SetTextColor(1, 1, 1)
end

local function PaperDollUpdateStats()
    local statText, tooltip1, tooltip2
    local numShownStats = 1
    local grid = 1
    local x = 0
    local y = 0

    for primaryStatIndex = 1, 5 do
        _, statText, tooltip1, tooltip2 = GW.stats.getPrimary(primaryStatIndex)
        grid, x, y, numShownStats = setStatFrame(GW.stats.PRIMARY_STATS[primaryStatIndex], numShownStats, statText, tooltip1, tooltip2, grid, x, y)
    end

    --Mastery
    statText, tooltip1, tooltip2 = GW.stats.getMastery()
    grid, x, y, numShownStats = setStatFrame("MASTERY", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    -- Armor
    statText, tooltip1, tooltip2 = GW.stats.getArmor()
    grid, x, y, numShownStats = setStatFrame("ARMOR", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

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

    --movement speed
    statText, tooltip1, tooltip2 = GW.stats.getMovementSpeed()
    grid, x, y, numShownStats = setStatFrame("MOVESPEED", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    --durability
    grid, x, y, numShownStats = setStatFrame("DURABILITY", numShownStats, "DURABILITY", nil, nil, grid, x, y)

    UpdateItemLevelAndGearScore()
end
GW.PaperDollUpdateStats = PaperDollUpdateStats

local function PaperDollUpdatePetStats()
    local hasUI, isHunterPet = HasPetUI()
    local statText, tooltip1, tooltip2
    if not hasUI then return end

    local numShownStats = 1
    local grid = 1
    local x = 0
    local y = 0

    GwDressingRoomPet.model:SetUnit("pet")
    GwDressingRoomPet.characterName:SetText(UnitPVPName("pet") .. " - " .. GUILD_RECRUITMENT_LEVEL .. " " .. UnitLevel("pet"))
    GwCharacterWindow:SetAttribute("HasPetUI", hasUI)
    if isHunterPet then
        local currXP, nextXP = GetPetExperience()

        GwDressingRoomPet.model.expBar:SetValue(currXP / nextXP)
        GwDressingRoomPet.model.expBar.value:SetText(GW.CommaValue(currXP) .. " / " .. GW.CommaValue(nextXP) .. " - " .. math.floor(currXP / nextXP * 100) .. "%")
        GwDressingRoomPet.classIcon:Hide()
        GwDressingRoomPet.characterData:Hide()
        GwDressingRoomPet.itemLevel:Hide()
        GwDressingRoomPet.itemLevelLabel:Hide()
        GwDressingRoomPet.model.expBar:Show()
        GwDressingRoomPet.model:SetPosition(-2,0,-0.5)
        GwDressingRoomPet.model:SetRotation(-0.15)
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
end
GW.PaperDollUpdatePetStats = PaperDollUpdatePetStats

local function PaperDollSetStatIcon(self, stat)
    local newTexture = "Interface/AddOns/GW2_UI/textures/character/statsicon-cata"

    if stat == "DURABILITY" then
        newTexture = "Interface/AddOns/GW2_UI/textures/globe/repair"
    elseif stat == "MASTERY" then
        GW.SetClassIcon(self.icon, GW.myClassID)
        newTexture = "Interface/AddOns/GW2_UI/textures/party/classicons"
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

    if self.IconBorder then
        local quality = GetInventoryItemQuality("player", slot)
        GW.SetItemButtonBorderQuality(self, quality)
    end
end

local function SetItemButtonBorderQuality(button, quality)
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
GW.SetItemButtonBorderQuality = SetItemButtonBorderQuality

local CHARACTER_PANEL_OPEN = nil
function GwToggleCharacter(tab, onlyShow)
    if InCombatLockdown() then
        return
    end

    local CHARACTERFRAME_DEFAULTFRAMES= {}

    CHARACTERFRAME_DEFAULTFRAMES["PaperDollFrame"] = GwHeroPanelMenu
    CHARACTERFRAME_DEFAULTFRAMES["ReputationFrame"] = GwPaperReputation
    CHARACTERFRAME_DEFAULTFRAMES["PetPaperDollFrame"] = GwPetContainer
    CHARACTERFRAME_DEFAULTFRAMES["TokenFrame"] = GwCurrencyDetailsFrame

    if CHARACTERFRAME_DEFAULTFRAMES[tab] ~= nil and CHARACTER_PANEL_OPEN ~= tab  then
        CHARACTER_PANEL_OPEN = tab
        if tab == "ReputationFrame" then
            if not onlyShow then
                GwCharacterWindow:SetAttribute("keytoggle", true)
            end
            GwCharacterWindow:SetAttribute("windowpanelopen", "reputation")
        elseif tab == "PetPaperDollFrame" then
            if not onlyShow then
                GwCharacterWindow:SetAttribute("keytoggle", true)
            end
            GwCharacterWindow:SetAttribute("windowpanelopen", "paperdollpet")
        elseif tab == "TokenFrame" then
            if not onlyShow then
                GwCharacterWindow:SetAttribute("keytoggle", true)
            end
            GwCharacterWindow:SetAttribute("windowpanelopen", "currency")
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
        slot.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        slot.IconBorder:SetAllPoints(slot)
        slot.IconBorder:SetParent(slot)
    end

    slot:GetNormalTexture():SetTexture(nil)

    GW.RegisterCooldown(_G[slot:GetName() .. "Cooldown"])

    local high = slot:GetHighlightTexture()
    high:SetAllPoints(slot)
    high:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)

    slot.repairIcon = slot:CreateTexture(nil, "OVERLAY")
    slot.repairIcon:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", 0, 0)
    slot.repairIcon:SetTexture("Interface/AddOns/GW2_UI/textures/globe/repair")
    slot.repairIcon:SetTexCoord(0, 1, 0.5, 1)
    slot.repairIcon:SetSize(20, 20)

    slot.itemlevel = slot:CreateFontString(nil, "OVERLAY")
    slot.itemlevel:SetSize(size, 10)
    slot.itemlevel:SetPoint("BOTTOMLEFT", 1, 2)
    slot.itemlevel:SetTextColor(1, 1, 1)
    slot.itemlevel:SetJustifyH("LEFT")

    slot.ignoreSlotCheck = CreateFrame("CheckButton", nil, slot, "GWIgnoreSlotCheck")

    slot.overlayButton = CreateFrame("Button", nil, slot)
    slot.overlayButton:SetAllPoints()
    slot.overlayButton:Hide()
    slot.overlayButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    slot.overlayButton:GetHighlightTexture():SetBlendMode("ADD")
    slot.overlayButton:GetHighlightTexture():SetAlpha(0.33)
    slot.overlayButton.isEquipmentSelected = false
    slot.overlayButton:SetScript("OnClick", function(self)
        if self.isEquipmentSelected and GW.selectedInventorySlot  == self:GetParent():GetID() then
            GwPaperDollSelectedIndicator:Hide()
            GW.selectedInventorySlot = nil
            GW.updateBagItemListAll()
            self.isEquipmentSelected = false
        else
            GwPaperDollSelectedIndicator:ClearAllPoints()
            GwPaperDollSelectedIndicator:SetPoint("LEFT", self:GetParent(), "LEFT", -16, 0)
            GwPaperDollSelectedIndicator:Show()
            GW.selectedInventorySlot = self:GetParent():GetID()
            GW.updateBagItemList(self:GetParent())
            self.isEquipmentSelected = true
        end
    end)
    slot.overlayButton:SetScript("OnEnter", function() slot:GetScript("OnEnter")(slot) end)
    slot.overlayButton:SetScript("OnLeave", function() slot:GetScript("OnLeave")(slot) end)

    GW.equipSlotList[#GW.equipSlotList + 1] = slot:GetID()
    GW.slotButtons[#GW.slotButtons + 1] = slot

    GW.updateItemSlot(slot)

    slot.IsGW2Hooked = true
end

local function SetupCharacterSlots(slots, parent)
    for _, v in ipairs(slots) do
        local slot, anchorParent, point, relativePoint, xOffset, yOffset, size = unpack(v)
        grabDefaultSlots(slot, {point, anchorParent, relativePoint, xOffset, yOffset}, parent, size)
    end
end

local function LoadPaperDoll()
    CreateFrame("Frame", "GwCharacterWindowContainer", GwCharacterWindow, "GwCharacterWindowContainer")
    CreateFrame("Button", "GwDressingRoom", GwCharacterWindowContainer, "GwDressingRoom")
    CreateFrame("Frame", "GwHeroPanelMenu", GwCharacterWindowContainer, "GwCharacterMenuFilledTemplate")
    CreateFrame("Frame", "GwPaperHonor", GwCharacterWindowContainer, "GwPaperHonor")
    CreateFrame("Frame", "GwPaperBattleground", GwCharacterWindowContainer, "GwPaperBattleground")

    --Legacy pet window
    CreateFrame("Frame", "GwPetContainer", GwCharacterWindowContainer, "GwPetContainer")
    CreateFrame("Button", "GwDressingRoomPet", GwPetContainer, "GwPetPaperdoll")

    GwDressingRoom.stats:SetScript("OnEvent", PaperDollStats_OnEvent)
    GwDressingRoomPet.stats:SetScript("OnEvent", PaperDollPetStats_OnEvent)

     -- to prevent ALT click lua error
    GwDressingRoom.flyoutSettings = {
		onClickFunc = PaperDollFrameItemFlyoutButton_OnClick,
		getItemsFunc = PaperDollFrameItemFlyout_GetItems,
		postGetItemsFunc = PaperDollFrameItemFlyout_PostGetItems,
		hasPopouts = true,
		parent = PaperDollFrame,
		anchorX = 0,
		anchorY = -3,
		verticalAnchorX = 0,
		verticalAnchorY = 0,
	};

    local characterSlots = {
        -- Format: {SlotFrame, AnchorParent, AnchorPoint, RelativePoint, XOffset, YOffset, Size}
        {CharacterHeadSlot,      GwDressingRoom.gear,                "TOPLEFT", "TOPLEFT",    0,  0, 50},
        {CharacterShoulderSlot,  CharacterHeadSlot,         "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterChestSlot,     CharacterShoulderSlot,     "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterWristSlot,     CharacterChestSlot,        "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterHandsSlot,     CharacterWristSlot,        "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterWaistSlot,     CharacterHandsSlot,        "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterLegsSlot,      CharacterWaistSlot,        "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterFeetSlot,      CharacterLegsSlot,         "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterMainHandSlot,  CharacterFeetSlot,         "TOPLEFT", "BOTTOMLEFT", 0, -20, 50},
        {CharacterSecondaryHandSlot, CharacterMainHandSlot, "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterRangedSlot, CharacterSecondaryHandSlot,   "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},

        {CharacterTabardSlot,    GwDressingRoom.stats,           "TOPRIGHT", "BOTTOMRIGHT", -5, -20, 40},
        {CharacterShirtSlot,     CharacterTabardSlot,   "TOPRIGHT", "BOTTOMRIGHT",  0, -5, 40},
        {CharacterTrinket0Slot,  CharacterTabardSlot,   "TOPRIGHT", "TOPLEFT",     -5, 0, 40},
        {CharacterTrinket1Slot,  CharacterTrinket0Slot, "TOPRIGHT", "BOTTOMRIGHT",  0, -5, 40},
        {CharacterFinger0Slot,   CharacterTrinket0Slot, "TOPRIGHT", "TOPLEFT",     -5, 0, 40},
        {CharacterFinger1Slot,   CharacterFinger0Slot,  "TOPRIGHT", "BOTTOMRIGHT",  0, -5, 40},
        {CharacterNeckSlot,      CharacterFinger0Slot,  "TOPRIGHT", "TOPLEFT",     -5, 0, 40},
        {CharacterBackSlot,      CharacterNeckSlot,     "TOPRIGHT", "BOTTOMRIGHT",  0, -5, 40},
    }

    SetupCharacterSlots(characterSlots, GwDressingRoom)

    CharacterRangedSlot.icon:SetTexCoord(0, 0.25, 0.5, 0.625)

    hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
        if not button.IsGW2Hooked then return end
        local textureName = GetInventoryItemTexture("player", button:GetID())
        if not textureName then
            button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/slot-bg-cata")
            button.icon:SetTexCoord(unpack(PlayerSlots[button:GetName()]))
            PaperDollSlotButton_Update(button)
        else
            button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            PaperDollSlotButton_Update(button)
        end
    end)

    GW.LoadTitles()
    GW.LoadPDEquipset(GwHeroPanelMenu)
    GW.LoadEquipments()

    GwDressingRoom.model:SetUnit("player")
    GwDressingRoom.model:SetPosition(0.8, 0, 0)

    local pos = modelPositions[GW.myrace]
    if pos then
        GwDressingRoom.model:SetPosition(unpack(pos))
    else
        GwDressingRoom.model:SetPosition(0.8, 0, 0) -- fallback
    end

    GwDressingRoom.model:SetRotation(-0.15)
    Model_OnLoad(GwDressingRoom.model, 4, 0, -0.1, CharacterModelFrame_OnMouseUp)

    hooksecurefunc("ToggleCharacter", GwToggleCharacter)

    GwDressingRoom.characterName:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    GwDressingRoom.characterData:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    GwDressingRoom.itemLevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)

    GwDressingRoomPet.characterName:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    GwDressingRoomPet.characterData:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    GwDressingRoomPet.itemLevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)

    PaperDollUpdateStats()
    PaperDollUpdatePetStats()
    C_Timer.After(1, function()
        PaperDollUpdateStats()
        PaperDollUpdatePetStats()
    end)

    GwDressingRoomPet.model.expBar:SetScript("OnEnter", function(self)
        self.value:Show()
    end)
    GwDressingRoomPet.model.expBar:SetScript("OnLeave", function(self)
        self.value:Hide()
    end)

    GwDressingRoom.stats.advancedChatStatsFrame = CreateFrame("Frame", nil, GwDressingRoom.stats)
    GwDressingRoom.stats.advancedChatStatsFrame:SetPoint("TOPLEFT", GwDressingRoom.stats, "TOPLEFT", 0, -1)
    GwDressingRoom.stats.advancedChatStatsFrame:SetSize(180, 40)
    GwDressingRoom.stats.advancedChatStatsFrame:SetScript("OnMouseUp", function(self)
        GW.ShowAdvancedChatStats(self:GetParent())
    end)
    GwDressingRoom.stats.advancedChatStatsFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetText(ADVANCED_LABEL .. " " .. STAT_CATEGORY_ATTRIBUTES, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    GwDressingRoom.stats.advancedChatStatsFrame:SetScript("OnLeave", GameTooltip_Hide)

    return GwCharacterWindowContainer
end
GW.LoadPaperDoll = LoadPaperDoll
