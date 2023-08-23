local _, GW = ...
local L = GW.L
local GWGetClassColor = GW.GWGetClassColor


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

local durabilityFrame = nil

local function collectDurability(self)
    local completeDurability = 0
    local completeDurabilityNumItems = 0
    for i = 1, 23 do
        local current, maximum = GetInventoryItemDurability(i)

        if current ~= nil then
            completeDurability = completeDurability + (current / maximum)
            completeDurabilityNumItems = completeDurabilityNumItems + 1
        end
    end
    if completeDurabilityNumItems > 0 then
        self.Value:SetText(GW.RoundDec(completeDurability / completeDurabilityNumItems * 100) .. "%")
    else
        self.Value:SetText(NOT_APPLICABLE)
    end
end
GW.AddForProfiling("paperdoll_equipment", "collectDurability", collectDurability)

local function PaperDollStats_QueuedUpdate(self)
    self:SetScript("OnUpdate", nil)
    GW.PaperDollUpdateStats()
    collectDurability(durabilityFrame)
end

local function PaperDollUpdateUnitData()
    GwDressingRoom.characterName:SetText(UnitPVPName("player"))
    local spec = GW.api.GetSpecialization()
    local _, name = GW.api.GetSpecializationInfo(spec, nil, nil, nil, GW.mysex)
    local color = GWGetClassColor(GW.myclass, true)
    GW.SetClassIcon(GwDressingRoom.classIcon, GW.myclass)

    GwDressingRoom.classIcon:SetVertexColor(color.r, color.g, color.b, color.a)

    if name ~= nil then
        local data = GUILD_RECRUITMENT_LEVEL .. " " .. unitGW.mylevelLevel .. " " .. name .. " " .. GW.myLocalizedClass
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
            GwCharacterMenu.petMenu:Disable()
            return
        end
    elseif event == "PET_UI_CLOSE" then
        if GwPetContainer:IsVisible() then
            GwCharacterWindow:SetAttribute("windowpanelopen", "paperdoll")
            GwCharacterMenu.petMenu:Disable()
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
        collectDurability(durabilityFrame)
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

local function PaperDollGetStatListFrame(self, i)
    if _G["GwPaperDollStat" .. i] ~= nil then return _G["GwPaperDollStat" .. i] end
    return CreateFrame("Frame", "GwPaperDollStat" .. i, self, "GwPaperDollStat")
end

local function PaperDollPetGetStatListFrame(self, i)
    if _G["GwPaperDollPetStat" .. i] ~= nil then return _G["GwPaperDollPetStat" .. i] end
    return CreateFrame("Frame", "GwPaperDollPetStat" .. i, self, "GwPaperDollStat")
end

local function setStatFrame(stat, index, statText, tooltip, tooltip2, grid, x, y)
    local statFrame = PaperDollGetStatListFrame(GwDressingRoom.stats, index)
    statFrame.tooltip = tooltip
    statFrame.tooltip2 = tooltip2
    statFrame.stat = stat
    statFrame.Value:SetText(statText)
    GW.PaperDollSetStatIcon(statFrame, stat)

    statFrame:ClearAllPoints()
    if stat == "DURABILITY" then
        statFrame:SetPoint("TOPRIGHT", GwDressingRoom.stats, "TOPRIGHT", 22, -1)
        statFrame.icon:SetSize(25, 25)
    else
        statFrame:SetPoint("TOPLEFT", 5 + x, -35 + -y)
    end
    grid, x, y = statGridPos(grid, x, y)
    return grid, x, y, index + 1
end
local function setPetStatFrame(stat, index, statText, tooltip, tooltip2, grid, x, y)
    local statFrame = PaperDollPetGetStatListFrame(GwDressingRoomPet.stats, index)
    statFrame.tooltip = tooltip
    statFrame.tooltip2 = tooltip2
    statFrame.stat = stat
    statFrame.Value:SetText(statText)
    GW.PaperDollSetStatIcon(statFrame, stat)

    statFrame:SetPoint("TOPLEFT", 5 + x, -35 + -y)
    grid, x, y = statGridPos(grid, x, y)
    return grid, x, y, index + 1
end

local Slots = {"HeadSlot", "ShoulderSlot", "ChestSlot", "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot"}
local SlotsFriendly = {INVTYPE_HEAD, INVTYPE_SHOULDER, INVTYPE_CHEST, INVTYPE_WRIST, INVTYPE_HAND, INVTYPE_WAIST, INVTYPE_LEGS, INVTYPE_FEET, INVTYPE_WEAPONMAINHAND, INVTYPE_WEAPONOFFHAND, L["INVTYPE_RANGED"]}

function GW_DurabilityTooltip()
    local duravaltotal, duramaxtotal, durapercent = 0, 0, 0
    local valcol, id, duraval, duramax
    local validItems = false

    -- Create layout
    GameTooltip:AddLine("|cffffffff")
    GameTooltip:AddLine("|cffffffff")
    GameTooltip:AddLine("|cffffffff")
    _G["GameTooltipTextLeft1"]:SetText("|cffffffff"); _G["GameTooltipTextRight1"]:SetText("|cffffffff")
    _G["GameTooltipTextLeft2"]:SetText("|cffffffff"); _G["GameTooltipTextRight2"]:SetText("|cffffffff")
    _G["GameTooltipTextLeft3"]:SetText("|cffffffff"); _G["GameTooltipTextRight3"]:SetText("|cffffffff")

    for k, slotName in ipairs(Slots) do
        if GetInventorySlotInfo(slotName) then
            id = GetInventorySlotInfo(slotName)
            duraval, duramax = GetInventoryItemDurability(id)
            if duraval ~= nil then
                -- At least one item has durability stat
                validItems = true
                
                -- Add to tooltip
                durapercent = tonumber(GW.RoundDec(duraval / duramax * 100))
                valcol = (durapercent >= 80 and "|cff00FF00") or (durapercent >= 60 and "|cff99FF00") or (durapercent >= 40 and "|cffFFFF00") or (durapercent >= 20 and "|cffFF9900") or (durapercent >= 0 and "|cffFF2000") or ("|cffFFFFFF")
                _G["GameTooltipTextLeft1"]:SetText(DURABILITY)
                _G["GameTooltipTextLeft2"]:SetText(_G["GameTooltipTextLeft2"]:GetText() .. SlotsFriendly[k] .. "|n")
                _G["GameTooltipTextRight2"]:SetText(_G["GameTooltipTextRight2"]:GetText() ..  valcol .. durapercent .. "%" .. "|n")

                duravaltotal = duravaltotal + duraval
                duramaxtotal = duramaxtotal + duramax
            end
        end
    end
    if duravaltotal > 0 and duramaxtotal > 0 then
        durapercent = duravaltotal / duramaxtotal * 100
    else
        durapercent = 0
    end
    if validItems == true then
        -- Show overall durability in the tooltip
        if durapercent >= 80 then valcol = "|cff00FF00"    elseif durapercent >= 60 then valcol = "|cff99FF00"    elseif durapercent >= 40 then valcol = "|cffFFFF00"    elseif durapercent >= 20 then valcol = "|cffFF9900"    elseif durapercent >= 0 then valcol = "|cffFF2000" else return end
        _G["GameTooltipTextLeft3"]:SetText(TOTAL .. " " .. valcol)
        _G["GameTooltipTextRight3"]:SetText(valcol .. GW.RoundDec(durapercent) .. "%")

        -- Show lines of the tooltip
        GameTooltipTextLeft1:Show(); GameTooltipTextRight1:Show()
        GameTooltipTextLeft2:Show(); GameTooltipTextRight2:Show()
        GameTooltipTextLeft3:Show(); GameTooltipTextRight3:Show()
        GameTooltipTextRight2:SetJustifyH("RIGHT")
        GameTooltipTextRight3:SetJustifyH("RIGHT")
        GameTooltip:Show()
    else
        -- No items have durability stat
        GameTooltip:ClearLines()
        GameTooltip:AddLine("" .. DURABILITY, 1, 0.85, 0)
        GameTooltip:Show()
    end
end
GW.AddForProfiling("paperdoll_equipment", "DurabilityTooltip", DurabilityTooltip)

local function PaperDollUpdateStats()
    local avgItemLevel, avgItemLevelEquipped = GW.api.GetAverageItemLevel()
    local r, g,b = GW.api.GetItemLevelColor(avgItemLevel)
    local statText, tooltip1, tooltip2

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

    --getAttackBothHands
    statText, tooltip1, tooltip2 = GW.stats.getAttackBothHands()
    grid, x, y, numShownStats = setStatFrame("ATTACKRATING", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    --damage
    statText, tooltip1, tooltip2 = GW.stats.getDamage()
    grid, x, y, numShownStats = setStatFrame("DAMAGE", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    --attack power
    statText, tooltip1, tooltip2 = GW.stats.getAttackPower()
    grid, x, y, numShownStats = setStatFrame("ATTACKPOWER", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    --ranged attack
    statText, tooltip1, tooltip2 = GW.stats.getRangedAttack()
    if statTextthen then
        grid, x, y, numShownStats = setStatFrame("RANGEDATTACK", numShownStats, statText, tooltip1, tooltip2, grid, x, y)
    end

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

local function PaperDollUpdatePetStats()
    local hasUI, isHunterPet = HasPetUI()
    local statText, tooltip1, tooltip2
    GwCharacterMenu.petMenu:SetShown(GW.myClassID == 3 or GW.myClassID == 9)
    if not hasUI then return end

    local numShownStats = 1
    local grid = 1
    local x = 0
    local y = 0

    GwCharacterMenu.petMenu:Enable()
    GwDressingRoomPet.model:SetUnit("pet")
    GwDressingRoomPet.characterName:SetText(UnitPVPName("pet") .. " - " .. GUILD_RECRUITMENT_LEVEL .. " " .. UnitLevel("pet"))
    GwCharacterWindow:SetAttribute("HasPetUI", hasUI)
    if isHunterPet then
        local happiness = GetPetHappiness()
        local totalPoints, spent = GetPetTrainingPoints()
        local currXP, nextXP = GetPetExperience()

        GwDressingRoomPet.model.expBar:SetValue(currXP / nextXP)
        GwDressingRoomPet.model.expBar.value:SetText(GW.CommaValue(currXP) .. " / " .. GW.CommaValue(nextXP) .. " - " .. math.floor(currXP / nextXP * 100) .. "%")
        GwDressingRoomPet.classIcon:SetTexCoord(GW.getSprite(petStateSprite, happiness, 1))
        GwDressingRoomPet.itemLevel:SetText(totalPoints - spent)
        GwDressingRoomPet.characterData:SetText(GetPetLoyalty())
        GwDressingRoomPet.characterData:Show()
        GwDressingRoomPet.itemLevel:Show()
        GwDressingRoomPet.itemLevelLabel:Show()
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

local function PaperDollSetStatIcon(self, stat)
    local newTexture = "Interface\\AddOns\\GW2_UI\\textures\\character\\statsicon"

    if STATS_ICONS[stat] ~= nil then
        self.icon:SetTexCoord(GW.getSprite(statsIconsSprite,STATS_ICONS[stat].x,STATS_ICONS[stat].y))
    end

    if stat == "DURABILITY" then
        newTexture = "Interface\\AddOns\\GW2_UI\\textures\\globe\\repair"
        durabilityFrame = self
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

    --if self.itemlevel then
    --    GW.setItemLevel(self, GetInventoryItemQuality("player", slot), GetInventoryItemLink("player", slot))
    --end

    if self.IconBorder then
        local quality = GetInventoryItemQuality("player", slot)
        GwSetItemButtonQuality(self, quality, GetInventoryItemID("player", slot))
    end
end

function GwSetItemButtonQuality(button, quality)
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

local function getSkillElement(index)
    if _G["GwPaperSkillsItem" .. index] then return _G["GwPaperSkillsItem" .. index] end
    local f = CreateFrame("Button", "GwPaperSkillsItem" .. index, GwPaperSkills.scroll.scrollchild, "GwPaperSkillsItem")
    f.name:SetFont(DAMAGE_TEXT_FONT, 12, "")
    f.name:SetText(UNKNOWN)
    f.val:SetFont(DAMAGE_TEXT_FONT, 12, "")
    f.val:SetText(UNKNOWN)
    f:SetText("")
    return f
end

local function updateSkillItem(self)
    if self.isHeader then
        self:SetHeight(30)
        self.val:Hide()
        self.StatusBar:Hide()
        self.name:SetFont(DAMAGE_TEXT_FONT, 14, "")
        self.arrow:Show()
        self.arrow:SetRotation(-1.5708)
        self.bgheader:Show()
        self.bg:Hide()
        self.bgstatic:Hide()
    else
        self:SetHeight(50)
        self.val:Show()
        self.StatusBar:Show()
        self.name:SetFont(DAMAGE_TEXT_FONT, 12, "")
        self.arrow:Hide()
        self.bgheader:Hide()
        self.bg:Show()
        self.bgstatic:Show()
    end
end

local function abandonProffesionOnClick(self)
    local skillIndex = self:GetParent().skillIndex
    local skillName = self:GetParent().skillName

    GW.WarningPrompt(
        UNLEARN_SKILL:format(skillName),
        function()
            AbandonSkill(skillIndex)
        end
    )
end

local function abandonProffesionOnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(UNLEARN_SKILL_TOOLTIP)
    GameTooltip:Show()
end

function GWupdateSkills()
    local height = 50
    local y = 0
    local LastElement = nil
    local totlaHeight = 0

    GwPaperSkills.scroll.scrollchild:SetSize(GwPaperSkills.scroll:GetSize())
    GwPaperSkills.scroll.scrollchild:SetWidth(GwPaperSkills.scroll:GetWidth() - 20)

    for skillIndex = 1, GetNumSkillLines() do
        local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier,
        skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType,
        skillDescription = GetSkillLineInfo(skillIndex)

        local f = getSkillElement(skillIndex)
        local zebra = skillIndex % 2

        f.skillIndex = skillIndex
        f.skillName = skillName
        if LastElement==nil then
            f:SetPoint("TOPLEFT", 0, -y)
        else
            f:SetPoint("TOPLEFT", LastElement, "BOTTOMLEFT", 0, 0)
        end

        if isAbandonable then
            f.abandon:Show()
            f.abandon:SetScript("OnClick", abandonProffesionOnClick)
            f.abandon:SetScript("OnEnter", abandonProffesionOnEnter)
            f.abandon:SetScript("OnLeave", GameTooltip_Hide)
        else
            f.abandon:Hide()
            f.abandon:SetScript("OnClick", nil)
            f.abandon:SetScript("OnEnter", nil)
            f.abandon:SetScript("OnLeave", nil)
        end

        if skillMaxRank == 0 then skillMaxRank = 1 end

        LastElement = f
        y = y + height
        f.name:SetText(skillName)
        f.tooltip = skillName
        f.tooltip2 = skillDescription
        f.StatusBar:SetValue(skillRank / skillMaxRank)
        f.val:SetText(skillRank .. " / " .. skillMaxRank)
        f.isHeader = isHeader
        f.bg:SetVertexColor(1, 1, 1, zebra)
        updateSkillItem(f)
        totlaHeight = totlaHeight + f:GetHeight()
    end
    GwPaperSkills.scroll.slider.thumb:SetHeight((GwPaperSkills.scroll:GetHeight()/totlaHeight) * GwPaperSkills.scroll.slider:GetHeight() )
    GwPaperSkills.scroll.slider:SetMinMaxValues (0,math.max(0,totlaHeight - GwPaperSkills.scroll:GetHeight()))
end

function LoadHonorTab()
    for i = 1, 6 do
        local slot = CreateFrame("Frame", "GwPaperHonorDetails" .. i, GwPaperHonor, "GwHonorInfoRow")
        slot:SetFrameLevel(3)
        GwPaperHonor.buttons[i] = slot
        if i == 1 then
            slot:SetPoint("TOPLEFT")
        else
            slot:SetPoint("TOPLEFT", GwPaperHonor.buttons[i -1], "BOTTOMLEFT")
        end
        slot:SetWidth(GwPaperHonor:GetWidth() - 12)
        slot.Header:SetFont(DAMAGE_TEXT_FONT, 18, "")
        if i == 1 then
            GWHonorFrameProgressBar:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameProgressBar:Show()
            slot.Header:SetPoint("TOPLEFT", GwPaperHonor, "TOPLEFT" , 22, -15)
        elseif i == 2 then
            slot.Header:SetText(HONOR_THIS_SESSION)
            local HKC = CreateFrame("Frame", "GWHonorFrameCurrentHK", GwPaperHonor, "HonorFrameHKButtonTemplate")
            HKC:SetPoint("TOPLEFT", slot.Header, "TOPLEFT", 15, -25)
            HKC:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameCurrentHKValue:SetPoint("RIGHT")
            GWHonorFrameCurrentHKText:SetFont(GWHonorFrameCurrentHKText:GetFont(), 14, "")
            GWHonorFrameCurrentHKValue:SetFont(GWHonorFrameCurrentHKValue:GetFont(), 14, "")
        
            local DKC = CreateFrame("Frame", "GWHonorFrameCurrentDK", GwPaperHonor, "HonorFrameDKButtonTemplate")
            DKC:SetPoint("TOPLEFT", slot.Header, "TOPLEFT", 15, -45)
            DKC:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameCurrentDKValue:SetPoint("RIGHT")
            GWHonorFrameCurrentDKText:SetFont(GWHonorFrameCurrentDKText:GetFont(), 14, "")
            GWHonorFrameCurrentDKValue:SetFont(GWHonorFrameCurrentHKValue:GetFont(), 14, "")
        elseif i == 3 then
            slot.Header:SetText(HONOR_YESTERDAY)
            local HKY = CreateFrame("Frame", "GWHonorFrameYesterdayHK", GwPaperHonor, "HonorFrameHKButtonTemplate")
            HKY:SetPoint("TOPLEFT", slot.Header, "TOPLEFT", 15, -25)
            HKY:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameYesterdayHKValue:SetPoint("RIGHT")
            GWHonorFrameYesterdayHKText:SetFont(GWHonorFrameYesterdayHKText:GetFont(), 14, "")
            GWHonorFrameYesterdayHKValue:SetFont(GWHonorFrameYesterdayHKValue:GetFont(), 14, "")
            
            local DKY = CreateFrame("Frame", "GWHonorFrameYesterdayContribution", GwPaperHonor, "HonorFrameContributionButtonTemplate")
            DKY:SetPoint("TOPLEFT", slot.Header, "TOPLEFT", 15, -45)
            DKY:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameYesterdayContributionValue:SetPoint("RIGHT")
            GWHonorFrameYesterdayContributionText:SetFont(GWHonorFrameYesterdayContributionText:GetFont(), 14)
            GWHonorFrameYesterdayContributionValue:SetFont(GWHonorFrameYesterdayContributionValue:GetFont(), 14)
        elseif i == 4 then
            slot.Header:SetText(HONOR_THISWEEK)
            local HKTW = CreateFrame("Frame", "GWHonorFrameThisWeekHK", GwPaperHonor, "HonorFrameHKButtonTemplate")
            HKTW:SetPoint("TOPLEFT", slot.Header, "TOPLEFT", 15, -25)
            HKTW:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameThisWeekHKValue:SetPoint("RIGHT")
            GWHonorFrameThisWeekHKText:SetFont(GWHonorFrameThisWeekHKText:GetFont(), 14, "")
            GWHonorFrameThisWeekHKValue:SetFont(GWHonorFrameThisWeekHKValue:GetFont(), 14, "")
            
            local DKTW = CreateFrame("Frame", "GWHonorFrameThisWeekContribution", GwPaperHonor, "HonorFrameContributionButtonTemplate")
            DKTW:SetPoint("TOPLEFT", slot.Header, "TOPLEFT", 15, -45)
            DKTW:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameThisWeekContributionValue:SetPoint("RIGHT")
            GWHonorFrameThisWeekContributionText:SetFont(GWHonorFrameThisWeekContributionText:GetFont(), 14, "")
            GWHonorFrameThisWeekContributionValue:SetFont(GWHonorFrameThisWeekContributionValue:GetFont(), 14, "")
        elseif i == 5 then
            slot.Header:SetText(HONOR_LASTWEEK)
            local HKLW = CreateFrame("Frame", "GWHonorFrameLastWeekHK", GwPaperHonor, "HonorFrameHKButtonTemplate")
            HKLW:SetPoint("TOPLEFT", slot.Header, "TOPLEFT", 15, -25)
            HKLW:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameLastWeekHKValue:SetPoint("RIGHT")
            GWHonorFrameLastWeekHKText:SetFont(GWHonorFrameLastWeekHKText:GetFont(), 14, "")
            GWHonorFrameLastWeekHKValue:SetFont(GWHonorFrameLastWeekHKValue:GetFont(), 14, "")

            local DKLW = CreateFrame("Frame", "GWHonorFrameLastWeekContribution", GwPaperHonor, "HonorFrameContributionButtonTemplate")
            DKLW:SetPoint("TOPLEFT", slot.Header, "TOPLEFT", 15, -45)
            DKLW:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameLastWeekContributionValue:SetPoint("RIGHT")
            GWHonorFrameLastWeekContributionText:SetFont(GWHonorFrameLastWeekContributionText:GetFont(), 14, "")
            GWHonorFrameLastWeekContributionValue:SetFont(GWHonorFrameLastWeekContributionValue:GetFont(), 14, "")

            local DKLWS = CreateFrame("Frame", "GWHonorFrameLastWeekStanding", GwPaperHonor, "HonorFrameStandingButtonTemplate")
            DKLWS:SetPoint("TOPLEFT", slot.Header, "TOPLEFT", 15, -65)
            DKLWS:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameLastWeekStandingValue:SetPoint("RIGHT")
            GWHonorFrameLastWeekStandingText:SetFont(GWHonorFrameLastWeekStandingText:GetFont(), 14, "")
            GWHonorFrameLastWeekStandingValue:SetFont(GWHonorFrameLastWeekStandingValue:GetFont(), 14, "")
        elseif i == 6 then
            slot.Header:SetText(HONOR_LIFETIME)
            local HKLT = CreateFrame("Frame", "GWHonorFrameLifeTimeHK", GwPaperHonor, "HonorFrameHKButtonTemplate")
            HKLT:SetPoint("TOPLEFT", slot.Header, "TOPLEFT", 15, -25)
            HKLT:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameLifeTimeHKValue:SetPoint("RIGHT")
            GWHonorFrameLifeTimeHKText:SetFont(GWHonorFrameLifeTimeHKText:GetFont(), 14, "")
            GWHonorFrameLifeTimeHKValue:SetFont(GWHonorFrameLifeTimeHKValue:GetFont(), 14, "")
            
            local DKLT = CreateFrame("Frame", "GWHonorFrameLifeTimeDK", GwPaperHonor, "HonorFrameDKButtonTemplate")
            DKLT:SetPoint("TOPLEFT", slot.Header, "TOPLEFT", 15, -45)
            DKLT:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameLifeTimeDKValue:SetPoint("RIGHT")
            GWHonorFrameLifeTimeDKText:SetFont(GWHonorFrameLifeTimeDKText:GetFont(), 14, "")
            GWHonorFrameLifeTimeDKValue:SetFont(GWHonorFrameLifeTimeDKValue:GetFont(), 14, "")

            local LTR = CreateFrame("Frame", "GWHonorFrameLifeTimeRank", GwPaperHonor, "HonorFrameRankButtonTemplate")
            LTR:SetPoint("TOPLEFT", slot.Header, "TOPLEFT", 15, -65)
            LTR:SetWidth(slot:GetWidth() - 30)
            GWHonorFrameLifeTimeRankValue:SetPoint("RIGHT")
            GWHonorFrameLifeTimeRankText:SetFont(GWHonorFrameLifeTimeRankText:GetFont(), 14, "")
            GWHonorFrameLifeTimeRankValue:SetFont(GWHonorFrameLifeTimeRankValue:GetFont(), 14, "")
        end
    end
end

local function checkHonorSpy()
    if not LibStub then
        return nil
    end
    local ace = LibStub("AceAddon-3.0", true)
    if not ace then
        return nil
    end
    local HonorSpy = ace:GetAddon("HonorSpy", true)
    if not HonorSpy then
        return nil
    end

    return HonorSpy
end

function UpdateHonorTab(updateAll)
    -- If Honotsyp is installed, display this data in our Honor tab
    local HonorSpy = checkHonorSpy()

    local slot = GwPaperHonor.buttons[1]
    local hk, dk, contribution, rank, highestRank, rankName, rankNumber
    -- This only gets set on player entering the world
    if updateAll then
        -- Yesterday's values
        hk, dk, contribution = GetPVPYesterdayStats()
        GWHonorFrameYesterdayHKValue:SetText(hk)
        GWHonorFrameYesterdayContributionValue:SetText(contribution)
        -- This Week's values
        hk, contribution = GetPVPThisWeekStats()
        GWHonorFrameThisWeekHKValue:SetText(hk)
        if HonorSpy then
            GWHonorFrameThisWeekContributionValue:SetText(format("%d (%d)", contribution, HonorSpy.db.char.estimated_honor))
        else
            GWHonorFrameThisWeekContributionValue:SetText(contribution)
        end
        -- Last Week's values
        hk, dk, contribution, rank = GetPVPLastWeekStats()
        GWHonorFrameLastWeekHKValue:SetText(hk)
        GWHonorFrameLastWeekContributionValue:SetText(contribution)
        GWHonorFrameLastWeekStandingValue:SetText(rank)
    end
    
    -- This session's values (today)
    hk, dk = GetPVPSessionStats()
    if HonorSpy then
        GWHonorFrameCurrentHKValue:SetText(format("%d |cfff2ca45(%s: %s)|r", hk, HONOR, HonorSpy.db.char.estimated_honor - HonorSpy.db.char.original_honor))
    else
        GWHonorFrameCurrentHKValue:SetText(hk)
    end
    GWHonorFrameCurrentDKValue:SetText(dk)
    
    -- Lifetime stats
    hk, dk, highestRank = GetPVPLifetimeStats()
    GWHonorFrameLifeTimeHKValue:SetText(hk)
    GWHonorFrameLifeTimeDKValue:SetText(dk)
    rankName, rankNumber = GetPVPRankInfo(highestRank)
    if not rankName then
        rankName = NONE
    end
    GWHonorFrameLifeTimeRankValue:SetText(rankName)
    
    -- Set rank name and number
    rankName, rankNumber = GetPVPRankInfo(UnitPVPRank("player"))
    if not rankName then
        rankName = NONE
    end
    slot.Header:SetText(rankName)
    slot.Rank:SetText(format("(%s %d) %d%%", RANK, rankNumber, GetPVPRankProgress() * 100))

    -- Set icon
    if rankNumber > 0 then
        GWHonorFramePvPIcon:SetTexture(format("%s%02d","Interface/PvPRankBadges/PvPRank", rankNumber))
        GWHonorFramePvPIcon:Show()
        slot.Header:SetPoint("TOPLEFT", GwPaperHonor, "TOPLEFT" , 50, -15)
    else
        GWHonorFramePvPIcon:Hide()
    end

    -- Set rank progress and bar color
    if GW.myfaction == "Alliance" then
        GWHonorFrameProgressBar:SetStatusBarColor(0.05, 0.15, 0.36)
    else
        GWHonorFrameProgressBar:SetStatusBarColor(0.63, 0.09, 0.09)
    end
    GWHonorFrameProgressBar:SetValue(GetPVPRankProgress())

    -- Recenter rank text
    slot.Header:SetPoint("TOP", "GwPaperHonor", "TOP", - slot.Rank:GetWidth() / 2 + 20, -83)
end

local CHARACTER_PANEL_OPEN = ""
function GwToggleCharacter(tab, onlyShow)
    if InCombatLockdown() then
        return
    end

    local CHARACTERFRAME_DEFAULTFRAMES= {}

    CHARACTERFRAME_DEFAULTFRAMES["PaperDollFrame"] = GwCharacterMenu
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
    slot:StripTextures()
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

    local high = slot:GetHighlightTexture()
    high:SetAllPoints(slot)
    high:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)

    if slot ~= CharacterAmmoSlot then
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
    end

    slot.IsGW2Hooked = true
end

local function LoadPaperDoll()
    CreateFrame("Frame", "GwCharacterWindowContainer", GwCharacterWindow, "GwCharacterWindowContainer")
    CreateFrame("Button", "GwDressingRoom", GwCharacterWindowContainer, "GwDressingRoom")
    CreateFrame("Frame", "GwCharacterMenu", GwCharacterWindowContainer, "GwCharacterMenu")
    CreateFrame("Frame", "GwPaperHonor", GwCharacterWindowContainer, "GwPaperHonor")
    CreateFrame("Frame", "GwPaperSkills", GwCharacterWindowContainer, "GwPaperSkills")

    --Legacy pet window
    CreateFrame("Frame", "GwPetContainer", GwCharacterWindowContainer, "GwPetContainer")
    CreateFrame("Button", "GwDressingRoomPet", GwPetContainer, "GwPetPaperdoll")

    GwDressingRoom.stats:SetScript("OnEvent", PaperDollStats_OnEvent)
    GwDressingRoomPet.stats:SetScript("OnEvent", PaperDollPetStats_OnEvent)

    grabDefaultSlots(CharacterHeadSlot, {"TOPLEFT", GwDressingRoom.gear, "TOPLEFT", 0, 0}, GwDressingRoom, 50)
    grabDefaultSlots(CharacterShoulderSlot, {"TOPLEFT", CharacterHeadSlot, "BOTTOMLEFT", 0, -5}, GwDressingRoom, 50)
    grabDefaultSlots(CharacterChestSlot, {"TOPLEFT", CharacterShoulderSlot, "BOTTOMLEFT", 0, -5}, GwDressingRoom, 50)
    grabDefaultSlots(CharacterWristSlot, {"TOPLEFT", CharacterChestSlot, "BOTTOMLEFT", 0, -5}, GwDressingRoom, 50)
    grabDefaultSlots(CharacterHandsSlot, {"TOPLEFT", CharacterWristSlot, "BOTTOMLEFT", 0, -5}, GwDressingRoom, 50)
    grabDefaultSlots(CharacterWaistSlot, {"TOPLEFT", CharacterHandsSlot, "BOTTOMLEFT", 0, -5}, GwDressingRoom, 50)
    grabDefaultSlots(CharacterLegsSlot, {"TOPLEFT", CharacterWaistSlot, "BOTTOMLEFT", 0, -5}, GwDressingRoom, 50)
    grabDefaultSlots(CharacterFeetSlot, {"TOPLEFT", CharacterLegsSlot, "BOTTOMLEFT", 0, -5}, GwDressingRoom, 50)
    grabDefaultSlots(CharacterMainHandSlot, {"TOPLEFT", CharacterFeetSlot, "BOTTOMLEFT", 0, -20}, GwDressingRoom, 50)
    grabDefaultSlots(CharacterSecondaryHandSlot, {"TOPLEFT", CharacterMainHandSlot, "TOPRIGHT", 5, 0}, GwDressingRoom, 50)
    grabDefaultSlots(CharacterRangedSlot, {"TOPLEFT", CharacterMainHandSlot, "BOTTOMLEFT", 0, -5}, GwDressingRoom, 50)
    grabDefaultSlots(CharacterAmmoSlot, {"TOPLEFT", CharacterRangedSlot, "TOPRIGHT", 5, 0}, GwDressingRoom, 50)

    grabDefaultSlots(CharacterTabardSlot, {"TOPRIGHT", GwDressingRoom.stats, "BOTTOMRIGHT", -5, -20}, GwDressingRoom, 40)
    grabDefaultSlots(CharacterShirtSlot, {"TOPRIGHT", CharacterTabardSlot, "BOTTOMRIGHT", 0, -5}, GwDressingRoom, 40)
    grabDefaultSlots(CharacterTrinket0Slot, {"TOPRIGHT", CharacterTabardSlot, "TOPLEFT", -5, 0}, GwDressingRoom, 40)
    grabDefaultSlots(CharacterTrinket1Slot, {"TOPRIGHT", CharacterTrinket0Slot, "BOTTOMRIGHT", 0, -5}, GwDressingRoom, 40)
    grabDefaultSlots(CharacterFinger0Slot, {"TOPRIGHT", CharacterTrinket0Slot, "TOPLEFT", -5, 0}, GwDressingRoom, 40)
    grabDefaultSlots(CharacterFinger1Slot, {"TOPRIGHT", CharacterFinger0Slot, "BOTTOMRIGHT", 0, -5}, GwDressingRoom, 40)
    grabDefaultSlots(CharacterNeckSlot, {"TOPRIGHT", CharacterFinger0Slot, "TOPLEFT", -5, 0}, GwDressingRoom, 40)
    grabDefaultSlots(CharacterBackSlot, {"TOPRIGHT", CharacterNeckSlot, "BOTTOMRIGHT", 0, -5}, GwDressingRoom, 40)

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
            button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/slot-bg")
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

    GwPaperSkills.scroll:SetScrollChild(GwPaperSkills.scroll.scrollchild)
    GWupdateSkills()
    GwPaperSkills.scroll:SetScript("OnMouseWheel", function(self, arg1)
        arg1 = -arg1 * 15
        local min, max = self.slider:GetMinMaxValues()
        local s = math.min(max,math.max(self:GetVerticalScroll()+arg1,min))
        self.slider:SetValue(s)
        self:SetVerticalScroll(s)

    end)
    GwPaperSkills.scroll.slider:SetValue(1)

    GwDressingRoom.model:SetUnit("player")
    GwDressingRoom.model:SetPosition(0.8, 0, 0)

    if GW.myrace == "Human" then
        GwDressingRoom.model:SetPosition(0.4, 0, -0.05)
    elseif GW.myrace == "Tauren" then
        GwDressingRoom.model:SetPosition(0.6, 0, 0)
    elseif GW.myrace == "BloodElf" then
        GwDressingRoom.model:SetPosition(0.5, 0, 0)
    elseif GW.myrace == "Draenei" then
        GwDressingRoom.model:SetPosition(0.3, 0, -0.15)
    elseif GW.myrace == "NightElf" then
        GwDressingRoom.model:SetPosition(0.3, 0, -0.15)
    elseif GW.myrace == "Troll" then
        GwDressingRoom.model:SetPosition(0.2, 0, -0.05)
    elseif GW.myrace == "Scourge" then
        GwDressingRoom.model:SetPosition(0.2, 0, -0.05)
    elseif GW.myrace == "Dwarf" then
        GwDressingRoom.model:SetPosition(0.3, 0, 0)
    elseif GW.myrace == "Gnome" then
        GwDressingRoom.model:SetPosition(0.2, 0, -0.05)
    elseif GW.myrace == "Orc" then
        GwDressingRoom.model:SetPosition(0.1, 0, -0.15)
    end
    GwDressingRoom.model:SetRotation(-0.15)
    Model_OnLoad(GwDressingRoom.model, 4, 0, -0.1, CharacterModelFrame_OnMouseUp)

    CharacterFrame:UnregisterAllEvents()
    hooksecurefunc("ToggleCharacter", GwToggleCharacter)

    PaperDollUpdateStats()
    PaperDollUpdatePetStats()

    GwPaperHonor.buttons = {}
    LoadHonorTab()

    GwDressingRoomPet.model.expBar:SetScript("OnEnter", function(self)
        self.value:Show()
    end)
    GwDressingRoomPet.model.expBar:SetScript("OnLeave", function(self)
        self.value:Hide()
    end)

    GwDressingRoom.stats.advancedChatStatsFrame = CreateFrame("Frame", nil, GwDressingRoom.stats)
    GwDressingRoom.stats.advancedChatStatsFrame:SetPoint("TOPLEFT", GwDressingRoom.stats, "TOPLEFT", 0, -1)
    GwDressingRoom.stats.advancedChatStatsFrame:SetSize(180, 40)
    GwDressingRoom.stats.advancedChatStatsFrame:SetScript("OnEnter", function(self)
        GW.showAdvancedChatStats(self)
    end)
    GwDressingRoom.stats.advancedChatStatsFrame:SetScript("OnLeave", GameTooltip_Hide)

    return GwCharacterWindowContainer
end
GW.LoadPaperDoll = LoadPaperDoll
