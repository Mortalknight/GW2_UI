local _, GW = ...
local comma_value = GW.comma_value
local round = GW.round
local RT = GW.REP_TEXTURES
local REPBG_T = 0
local REPBG_B = 0.464

local gender = UnitSex("player")

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
    BLOCK = {x = 4, y = 3},
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

local savedItemSlots = {}
local savedPlayerTitles = {}
local savedReputation = {}
local selectedReputationCat = 1
local reputationLastUpdateMethod = function() end
local reputationLastUpdateMethodParams = nil
local expandedFactions = {}
local PAPERDOLL_STATCATEGORIES= {
	[1] = {
		categoryFrame = "AttributesCategory",
		stats = {
			[1] = { stat = "STRENGTH", primary = LE_UNIT_STAT_STRENGTH },
			[2] = { stat = "AGILITY", primary = LE_UNIT_STAT_AGILITY },
			[3] = { stat = "INTELLECT", primary = LE_UNIT_STAT_INTELLECT },
			[4] = { stat = "STAMINA" },
			[5] = { stat = "ARMOR" },
			[6] = { stat = "MANAREGEN", roles =  { "HEALER" } },
		},
	},
	[2] = {
		categoryFrame = "EnhancementsCategory",
		stats = {
			[1] = { stat = "CRITCHANCE", hideAt = 0 },
			[2] = { stat = "HASTE", hideAt = 0 },
			[3] = { stat = "MASTERY", hideAt = 0 },
			[4] = { stat = "VERSATILITY", hideAt = 0 },


			[5] = { stat = "DODGE",  },
			[6] = { stat = "PARRY", hideAt = 0,  },
			[7] = { stat = "BLOCK", hideAt = 0,  },
            [8] = { stat = "AVOIDANCE", hideAt = 0 },
            [9] = { stat = "LIFESTEAL", hideAt = 0 },
			[10] = { stat = "MOVESPEED", hideAt = 0,  },
		},
	},
}
--[[
			[1] = { stat = "CRITCHANCE", hideAt = 0 },
			[2] = { stat = "HASTE", hideAt = 0 },
			[3] = { stat = "MASTERY", hideAt = 0 },
			[4] = { stat = "VERSATILITY", hideAt = 0 },
			[5] = { stat = "LIFESTEAL", hideAt = 0 },
			[6] = { stat = "AVOIDANCE", hideAt = 0 },
			[7] = { stat = "DODGE", roles =  { "TANK" } },
			[8] = { stat = "PARRY", hideAt = 0, roles =  { "TANK" } },
			[9] = { stat = "BLOCK", hideAt = 0, roles =  { "TANK" } },
]]--
local EquipSlotList = {}
local bagItemList = {}
local numBagSlotFrames = 0
local selectedInventorySlot = nil

local function getBagSlotFrame(i)
    if _G["gwPaperDollBagSlotButton" .. i] ~= nil then return _G["gwPaperDollBagSlotButton" .. i] end
    local f = CreateFrame("Button", "gwPaperDollBagSlotButton" .. i, GwPaperDollBagItemList, "GwPaperDollBagItem")
    numBagSlotFrames = numBagSlotFrames + 1
    return f
end

function GwupdateBagItemListAll()
    if selectedInventorySlot ~= nil then return end

    local gridIndex = 1
    local itemIndex = 1
    local x = 10
    local y = 15

    for k,v in pairs(EquipSlotList) do
        local id = v
        wipe(bagItemList)
        GetInventoryItemsForSlot(id, bagItemList)

        for location, itemID in next, bagItemList do
            if not (location - id == ITEM_INVENTORY_LOCATION_PLAYER) then -- Remove the currently equipped item from the list
                local itemFrame = getBagSlotFrame(itemIndex)
                itemFrame.location = location

                updateBagItemButton(itemFrame)

                itemFrame:SetPoint("TOPLEFT", x, -y)
                itemFrame:Show()
                itemFrame.itemSlot = id
                gridIndex = gridIndex + 1

                x = x + 49 + 3

                if gridIndex > 4 then
                    gridIndex = 1
                    x = 10
                    y = y + 49 + 3
                end
                itemIndex = itemIndex + 1
                if itemIndex > 36 then break end
            end
        end
    end
    for i = itemIndex, numBagSlotFrames do
        if _G["gwPaperDollBagSlotButton" .. i] ~= nil then _G["gwPaperDollBagSlotButton" .. i]:Hide() end
    end
end

local function updateBagItemList(itemButton)
    local id = itemButton.id or itemButton:GetID()
    if selectedInventorySlot~=id then return end

    wipe(bagItemList)
    GetInventoryItemsForSlot(id, bagItemList)

    local gridIndex = 0
    local itemIndex = 1
    local x = 10
    local y = 15

    for location, itemID in next, bagItemList do
        if not (location - id == ITEM_INVENTORY_LOCATION_PLAYER) then -- Remove the currently equipped item from the list
            local itemFrame = getBagSlotFrame(itemIndex)
            itemFrame.location = location

            updateBagItemButton(itemFrame)

            itemFrame:SetPoint("TOPLEFT", x, -y)
            itemFrame:Show()
            itemFrame.itemSlot = id
            gridIndex = gridIndex + 1

            x = x + 49 + 3

            if gridIndex > 4 then
                gridIndex = 1
                x = 10
                y = y + 49 + 3
            end
            itemIndex = itemIndex + 1
		end
       if itemIndex > 36 then break end
    end
    for i = itemIndex, numBagSlotFrames do
        if _G["gwPaperDollBagSlotButton" .. i] ~= nil then _G["gwPaperDollBagSlotButton" .. i]:Hide() end
    end
end

function updateBagItemButton(button)
    --[[ NYI
    local location = button.location;
	if ( not location ) then
		return
	end
   local id, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip, quality = EquipmentManager_GetItemInfoByLocation(location);
    button.ItemId = id
	local broken = ( maxDurability and durability == 0 );
	if ( textureName ) then
		SetItemButtonTexture(button, textureName);
		SetItemButtonCount(button, count);
        if broken then
			SetItemButtonTextureVertexColor(button, 0.9, 0, 0);
		else
			SetItemButtonTextureVertexColor(button, 1.0, 1.0, 1.0);
		end

        if durability~=nil and(durability/maxDurability)<0.5 then
            button.repairIcon:Show()
            if (durability/maxDurability)==0 then
                button.repairIcon:SetTexCoord(0,1,0.5,1)
            else
                button.repairIcon:SetTexCoord(0,1,0,0.5)
            end

        else
            button.repairIcon:Hide()
        end

        button.UpdateTooltip = function () GameTooltip:SetOwner(button, "ANCHOR_RIGHT", 6, -EquipmentFlyoutFrame.buttonFrame:GetHeight() - 6); setTooltip(); end

		GwSetItemButtonQuality(button, quality, id)
    end
    ]]--
end

function GwPaperDollBagItem_OnClick (self)
	local action = function() end
    if self.location then
        if UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[self.itemSlot] then
            UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1, 0.1, 0.1, 1)
            return
        end
        local action = EquipmentManager_EquipItemByLocation(self.location, self.itemSlot)
        EquipmentManager_RunAction(action)
    end
end

function gwPaperDollStats_QueuedUpdate(self)
	self:SetScript("OnUpdate", nil)
	gwPaperDollUpdateStats()
end

function gwPaperDollUpdateUnitData()
    GwDressingRoom.characterName:SetText(UnitPVPName("player"))
    local spec = GW.api.GetSpecialization()
    local localizedClass, englishClass, classIndex = UnitClass("player")
    local id, name, description, icon, background, role = GW.api.GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player"))
    local unitLevel = UnitLevel("player")
    GW.SetClassIcon(GwDressingRoom.classIcon, classIndex)
    GwDressingRoom.classIcon:SetVertexColor(GW.CLASS_COLORS_RAIDFRAME[classIndex].r,GW.CLASS_COLORS_RAIDFRAME[classIndex].g,GW.CLASS_COLORS_RAIDFRAME[classIndex].b)

	if name ~= nil then
		local data = GUILD_RECRUITMENT_LEVEL .. " " .. unitLevel .. " " .. name .. " " .. localizedClass
        GwDressingRoom.characterData:SetText(data)
    else
        GwDressingRoom.characterData:SetText(GUILD_RECRUITMENT_LEVEL .. " " .. unitLevel .. " " ..localizedClass)
	end
end

function gwPaperDollPetStats_OnEvent(self, event, ...)
    local unit = ...
    hasUI, isHunterPet = HasPetUI()
    if event == "PET_UI_UPDATE" or event == "PET_BAR_UPDATE" or (event == "UNIT_PET" and arg1 == "player") then
        if GwPetContainer:IsVisible() and not hasUI then
            gwCharacterPanelToggle()
            GwCharacterMenu.petMenu:Hide()
            return
        end
    elseif event == "PET_UI_CLOSE" then
		if GwPetContainer:IsVisible() then
            gwCharacterPanelToggle()
            GwCharacterMenu.petMenu:Hide()
            return
        end
    end
    gwPaperDollUpdatePetStats()
end

function gwPaperDollStats_OnEvent(self, event, ...)
    local unit = ...
	if event == "PLAYER_ENTERING_WORLD" or event == "UNIT_MODEL_CHANGED" or event=="UNIT_NAME_UPDATE" or event=="PLAYER_PVP_RANK_CHANGED" and unit == "player" then
		GwDressingRoom.model:SetUnit("player", false)
        gwPaperDollUpdateUnitData()
		return
    end

	--if ( not self:IsVisible() ) then
		--return;
	--end

	if unit == "player" then
		if event == "UNIT_LEVEL" then
			gwPaperDollUpdateUnitData()
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
				IsMounted() then
			self:SetScript("OnUpdate", gwPaperDollStats_QueuedUpdate)
		end
	end

	if event == "COMBAT_RATING_UPDATE" or
			event == "MASTERY_UPDATE" or
			event == "SPEED_UPDATE" or
			event == "LIFESTEAL_UPDATE" or
			event == "AVOIDANCE_UPDATE" or
			event == "BAG_UPDATE" or
			event == "PLAYER_EQUIPMENT_CHANGED" or
			event == "PLAYERBANKSLOTS_CHANGED" or
			event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" or
			event == "PLAYER_DAMAGE_DONE_MODS" or
			IsMounted() then
		self:SetScript("OnUpdate", gwPaperDollStats_QueuedUpdate)
	elseif event == "PLAYER_TALENT_UPDATE" then
		gwPaperDollUpdateUnitData()
		self:SetScript("OnUpdate", gwPaperDollStats_QueuedUpdate)
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		gwPaperDollUpdateStats()
	elseif event == "SPELL_POWER_CHANGED" then
		self:SetScript("OnUpdate", gwPaperDollStats_QueuedUpdate)
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

local function setStatFrame(stat, index, statText, tooltip, tooltip2, grid, x, y)
    statFrame = gwPaperDollGetStatListFrame(GwPapaerDollStats,index)
    statFrame.tooltip = tooltip
    statFrame.tooltip2 = tooltip2
    statFrame.stat = stat
    statFrame.Value:SetText(statText)
    gwPaperDollSetStatIcon(statFrame, stat)

    statFrame:SetPoint("TOPLEFT", 5 + x, -35 + -y)
    grid, x, y =statGridPos(grid, x, y)
    return grid, x, y, index + 1
end
local function setPetStatFrame(stat, index, statText, tooltip, tooltip2, grid, x, y)
    statFrame = gwPaperDollPetGetStatListFrame(GwPapaerDollStatsPet, index)
    statFrame.tooltip = tooltip
    statFrame.tooltip2 = tooltip2
    statFrame.stat = stat
    statFrame.Value:SetText(statText)
    gwPaperDollSetStatIcon(statFrame, stat)

    statFrame:SetPoint("TOPLEFT", 5 + x, -35 + -y)
    grid, x, y =statGridPos(grid, x, y)
    return grid, x, y, index + 1
end

function gwPaperDollUpdateStats()
    local level = UnitLevel("player")
	local categoryYOffset = -5
	local statYOffset = 0
    local avgItemLevel, avgItemLevelEquipped = GW.api.GetAverageItemLevel()

    avgItemLevel = nil or 0
    avgItemLevelEquipped = nil or 0
    avgItemLevelEquipped = math.floor(avgItemLevelEquipped)
    avgItemLevel = math.floor(avgItemLevel)
    if avgItemLevelEquipped < avgItemLevel then
        avgItemLevelEquipped = math.floor(avgItemLevelEquipped) .. "(" .. math.floor(avgItemLevel) .. ")"
    end
    avgItemLevelEquipped = nil or ""
    GwDressingRoom.itemLevel:SetText(avgItemLevelEquipped)
    GwDressingRoom.itemLevel:SetTextColor(GW.api.GetItemLevelColor())

	local spec = GW.api.GetSpecialization()
	local role = GW.api.GetSpecializationRole(spec)
	local statFrame = nil
	local lastAnchor
    local numShownStats = 1
    local grid = 1
    local x = 0
    local y = 0

	for primaryStatIndex = 1, 5 do
        statName, statText, tooltip1, tooltip2 = GW.stats.getPrimary(primaryStatIndex)
        grid, x, y, numShownStats = setStatFrame(GW.stats.PRIMARY_STATS[primaryStatIndex], numShownStats, statText, tooltip1, tooltip2, grid, x, y)
	end

    -- Armor
    statText, tooltip1, tooltip2 = GW.stats.getArmor()
    grid, x, y, numShownStats = setStatFrame("ARMOR", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

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
    grid, x, y, numShownStats = setStatFrame("RANGEDATTACK", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    --ranged damage
    statText, tooltip1, tooltip2 = GW.stats.getRangedDamage()
    grid, x, y, numShownStats = setStatFrame("RANGEDDAMAGE", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    --ranged attack power
    statText, tooltip1, tooltip2 = GW.stats.getRangedAttackPower()
    grid, x, y, numShownStats = setStatFrame("RANGEDATTACKPOWER", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    --resitance
    for resistanceIndex = 1, 5 do
        statName, statText, tooltip1, tooltip2 = GW.stats.getResitance(resistanceIndex)
        grid, x, y, numShownStats = setStatFrame(GW.stats.RESITANCE_STATS[resistanceIndex], numShownStats, statText, tooltip1, tooltip2, grid, x, y)
    end
end
function gwPaperDollUpdatePetStats()
    local hasUI, isHunterPet = HasPetUI()
    if not hasUI then return end

    local numShownStats = 1
    local grid = 1
    local x = 0
    local y = 0

    GwCharacterMenu.petMenu:Show()
    GwDressingRoomPet.model:SetUnit("pet")
    GwDressingRoomPet.characterName:SetText(UnitPVPName("pet"))

    if isHunterPet then
        local happiness, damagePercentage, loyaltyRate = GetPetHappiness()
        local totalPoints, spent = GetPetTrainingPoints()
        local currXP, nextXP = GetPetExperience()

        GwDressingRoomPet.model.expBar:SetValue(currXP / nextXP)
        GwDressingRoomPet.classIcon:SetTexCoord(GW.getSprite(petStateSprite, happiness, 1))
        GwDressingRoomPet.itemLevel:SetText(totalPoints - spent)
        GwDressingRoomPet.characterData:SetText(GetPetLoyalty())
        GwDressingRoomPet.characterData:Show()
        GwDressingRoomPet.itemLevel:Show()
        GwDressingRoomPet.itemLevelLabel:Show()
        GwDressingRoomPet.classIcon:Show()
        GwDressingRoomPet.model.expBar:Show()
    else
        GwDressingRoomPet.model.expBar:Hide()
        GwDressingRoomPet.characterData:Hide()
        GwDressingRoomPet.itemLevel:Hide()
        GwDressingRoomPet.itemLevelLabel:Hide()
        GwDressingRoomPet.classIcon:Hide()
    end

    for primaryStatIndex = 1, 5 do
        statName, statText, tooltip1, tooltip2 = GW.stats.getPrimary(primaryStatIndex, "pet")
        grid, x, y, numShownStats = setPetStatFrame(GW.stats.PRIMARY_STATS[primaryStatIndex], numShownStats, statText, tooltip1, tooltip2, grid, x, y)

	end
    statText, tooltip1, tooltip2 = GW.stats.getAttackPower("pet")
    grid, x, y, numShownStats = setPetStatFrame("ATTACKPOWER", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    statText, tooltip1, tooltip2 = GW.stats.getDamage("pet")
    grid, x, y, numShownStats = setPetStatFrame("DAMAGE", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    statText, tooltip1, tooltip2 = GW.stats.getArmor("pet")
    grid, x, y, numShownStats = setPetStatFrame("ARMOR", numShownStats, statText, tooltip1, tooltip2, grid, x, y)

    for resistanceIndex = 1, 5 do
        statName, statText, tooltip1, tooltip2 = GW.stats.getResitance(resistanceIndex, "pet")
        grid, x, y, numShownStats = setPetStatFrame(GW.stats.RESITANCE_STATS[resistanceIndex], numShownStats, statText, tooltip1, tooltip2, grid, x, y)
    end
end

function gwPaperDollSetStatIcon(self, stat)
    local newTexture = "Interface\\AddOns\\GW2_UI\\textures\\character\\statsicon"
    if STATS_ICONS[stat] ~= il then
        -- If mastery we use need to use class icon
        if stat == "MASTERY" then
			local localizedClass, englishClass, classIndex = UnitClass("player")
            gw_setClassIcon(self.icon, classIndex)
            newTexture = "Interface\\AddOns\\GW2_UI\\textures\\party\\classicons"
        else
            self.icon:SetTexCoord(GW.getSprite(statsIconsSprite,STATS_ICONS[stat].x,STATS_ICONS[stat].y))
        end
    end

    if newTexture ~= self.icon:GetTexture() then
        self.icon:SetTexture(newTexture)
    end
end

function gwPaperDollGetStatListFrame(self, i)
    if _G["GwPaperDollStat" .. i] ~= nil then return _G["GwPaperDollStat" .. i] end
    return CreateFrame("Frame", "GwPaperDollStat" .. i, self, "GwPaperDollStat")
end

function gwPaperDollPetGetStatListFrame(self, i)
    if _G["GwPaperDollPetStat" .. i] ~= nil then return _G["GwPaperDollPetStat" .. i] end
    return CreateFrame("Frame", "GwPaperDollPetStat" .. i, self, "GwPaperDollStat")
end

function gwActionButtonGlobalStyle(self)
    self.IconBorder:SetSize(self:GetSize(), self:GetSize())
    _G[self:GetName() .. "IconTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    _G[self:GetName() .. "NormalTexture"]:SetSize(self:GetSize(), self:GetSize())
    _G[self:GetName() .. "NormalTexture"]:Hide()
    self.IconBorder:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\itemborder")

    _G[self:GetName() .. "NormalTexture"]:SetTexture(nil)
    _G[self:GetName()]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\actionbutton-pressed")
    _G[self:GetName()]:SetHighlightTexture(nil)
end

function gwPaperDollSlotButton_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local slotName = self:GetName()
	local id, textureName, checkRelic = GetInventorySlotInfo(strsub(slotName, 12))
	self:SetID(id);
    EquipSlotList[#EquipSlotList + 1] = id
	self.checkRelic = checkRelic

    gwActionButtonGlobalStyle(self)
end

function gwPaperDollSlotButton_OnShow(self)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("MERCHANT_UPDATE")
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	self:RegisterEvent("ITEM_LOCK_CHANGED")
	self:RegisterEvent("CURSOR_UPDATE")
	self:RegisterEvent("UPDATE_INVENTORY_ALERTS")
    gwPaperDollSlotButton_Update(self)
end

function gwPaperDollSlotButton_OnHide(self)
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("MERCHANT_UPDATE")
	self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED")
	self:UnregisterEvent("ITEM_LOCK_CHANGED")
	self:UnregisterEvent("CURSOR_UPDATE")
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
	self:UnregisterEvent("UPDATE_INVENTORY_ALERTS")
end

function gwPaperDollSlotButton_OnEvent(self, event, ...)
	local arg1, arg2 = ...
	if event == "PLAYER_EQUIPMENT_CHANGED" then
		if self:GetID() == arg1 then
			gwPaperDollSlotButton_Update(self)
            updateBagItemList(self)
		end
	end
    if event == "BAG_UPDATE_COOLDOWN" then
		gwPaperDollSlotButton_Update(self)
	end
end

function gwPaperDollSlotButton_OnEnter(self)
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
    --[[
    if not EquipmentFlyout_SetTooltipAnchor(self) then

    end
    ]]--
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", self:GetID(), nil, true)
	if not hasItem then
		local text = _G[strupper(strsub(self:GetName(), 12))]
		if self.checkRelic and UnitHasRelicSlot("player") then
			text = RELICSLOT
		end
		GameTooltip:SetText(text)
	end
	if InRepairMode() and repairCost and (repairCost > 0) then
		GameTooltip:AddLine(REPAIR_COST, nil, nil, nil, true)
		SetTooltipMoney(GameTooltip, repairCost)
		GameTooltip:Show()
	else
		CursorUpdate(self)
	end
end

function gwPaperDollSlotButton_OnModifiedClick(self, button)
	if HandleModifiedItemClick(GetInventoryItemLink("player", self:GetID())) then
		return
	end
	if IsModifiedClick("SOCKETITEM") then
		SocketInventoryItem(self:GetID())
        if InCombatLockdown() then return end
        GwCharacterWindow:SetAttribute("windowPanelOpen", 0)
	end
end

function gwPaperDollSlotButton_OnClick(self, button, drag)
    MerchantFrame_ResetRefundItem()
    if button == "LeftButton" then
        local infoType, _ = GetCursorInfo()
        if infoType == "merchant" and MerchantFrame.extendedCost then
            MerchantFrame_ConfirmExtendedItemCost(MerchantFrame.extendedCost)
        else
            if not SpellIsTargeting() and (drag == nil and GwPaperDollBagItemList:IsShown()) then
                GwPaperDollSelectedIndicator:SetPoint("LEFT", self, "LEFT", -16, 0)
                GwPaperDollSelectedIndicator:Show()
                selectedInventorySlot = self:GetID()
                updateBagItemList(self)
            else
                if SpellCanTargetItem() then
                    local castingItem = nil
                    for bag = 0, NUM_BAG_SLOTS do
                        for slot = 1, GetContainerNumSlots(bag) do
                            local id = GetContainerItemID(bag, slot)
                            if id then
                                local name, _ = GetItemInfo(id)
                                if IsCurrentItem(id) then
                                    castingItem = id
                                    break
                                end
                            end
                        end
                        if castingItem then
                            break
                        end
                    end
                    if castingItem and castingItem == 154879 then
                        -- Awoken Titan Essence causes PickupInventoryItem to behave as protected; no idea why
                        -- So we display a nice message instead of a UI error
                        local itemid = GetInventoryItemID("player", self:GetID())
                        if itemid then
                            local name, link, quality, _ = GetItemInfo(itemid)
                            if quality == 5 then
                                StaticPopup_Show("GW_UNEQUIP_LEGENDARY")
                            else
                                StaticPopup_Show("GW_NOT_A_LEGENDARY")
                            end
                            return
                        end
                    end
                end
                PickupInventoryItem(self:GetID())
                if CursorHasItem() then
                    MerchantFrame_SetRefundItem(self, 1)
                end
            end
	   	end
	end
end

function gwPaperDollSlotButton_OnLeave(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	GameTooltip:Hide()
	ResetCursor()
end

function gwPaperDollSlotButton_Update (self)
    local slot = self:GetID()
    if savedItemSlots[slot] == nil then
        savedItemSlots[slot] = self
        self.ignoreSlotCheck:SetScript("OnClick", function()
            if not self.ignoreSlotCheck:GetChecked() then
                C_EquipmentSet.IgnoreSlotForSave(self:GetID())
            else
                C_EquipmentSet.UnignoreSlotForSave(self:GetID())
            end
        end)
    end

    local textureName = GetInventoryItemTexture("player", slot)
	local cooldown = _G[self:GetName() .. "Cooldown"]
	if textureName then
		SetItemButtonTexture(self, textureName)
		SetItemButtonCount(self, GetInventoryItemCount("player", slot))
		if (GetInventoryItemBroken("player", slot) or GetInventoryItemEquippedUnusable("player", slot)) then
			SetItemButtonTextureVertexColor(self, 0.9, 0, 0)
		else
			SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0)
		end

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

		if cooldown then
			local start, duration, enable = GetInventoryItemCooldown("player", slot)
			CooldownFrame_Set(cooldown, start, duration, enable)
		end
		self.hasItem = 1
	else
        SetItemButtonTexture(self, nil)
        self.repairIcon:Hide()
    end

	local quality = GetInventoryItemQuality("player", slot)
	GwSetItemButtonQuality(self, quality, GetInventoryItemID("player", slot))
end

function GwPaperDollResetBagInventory()
    GwPaperDollSelectedIndicator:Hide()
    selectedInventorySlot = nil
    GwupdateBagItemListAll()
end

function GwPaperDollIndicatorAnimation(self)
    local name = self:GetName()
    local point, relat, relPoint, startX, yof = self:GetPoint()

    addToAnimation(name,0,1,GetTime(),1,function(step)
        local point, relat, relPoint, xof, yof = self:GetPoint()
        if step < 0.5 then
            step = step / 0.5
            self:SetPoint(point, relat, relPoint, startX + (-8 * step), yof)
        else
             step = (step - 0.5) / 0.5
            self:SetPoint(point, relat, relPoint, (startX - 8) + (8 * step), yof)
        end
    end, nil, function()
        if self:IsShown() then
            GwPaperDollIndicatorAnimation(self)
        end
    end)
end

function GwSetItemButtonQuality(button, quality, itemIDOrLink)
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

function gwCharacterPanelToggle(frame)
    GwPaperDollBagItemList:Hide()
    GwCharacterMenu:Hide()
    GwPaperDollOutfits:Hide()
    GwPaperTitles:Hide()

    GwPaperReputation:Hide()
    GwPaperSkills:Hide()
    GwPetContainer:Hide()

    if frame ~= nil then
        frame:Show()
    else
        GwDressingRoom:Show()
        return
    end

    if frame:GetName() == "GwPaperReputation" or frame:GetName() == "GwPetContainer" then
        GwDressingRoom:Hide()
    else
        GwDressingRoom:Show()
    end
end

local function getNewEquipmentSetButton(i)
    if _G["GwPaperDollOutfitsButton" .. i] ~= nil then return _G["GwPaperDollOutfitsButton" .. i] end

    local f = CreateFrame("Button", "GwPaperDollOutfitsButton" .. i, GwPaperDollOutfits, "GwPaperDollOutfitsButton")

    if i > 1 then
        _G["GwPaperDollOutfitsButton" .. i]:SetPoint("TOPLEFT", _G["GwPaperDollOutfitsButton" .. (i - 1)], "BOTTOMLEFT")
    end
    GwPaperDollOutfits.buttons = GwPaperDollOutfits.buttons + 1
    f.standardOnClick = f:GetScript("OnEnter")
    f:GetFontString():ClearAllPoints()
    f:GetFontString():SetPoint("TOP", f, "TOP", 0, -20)

    return f
end

function GwOutfitsDrawItemSetList()
    if GwPaperDollOutfits.buttons ==nil then GwPaperDollOutfits.buttons = 0 end

    local numSets = C_EquipmentSet.GetNumEquipmentSets()
    local numButtons = GwPaperDollOutfits.buttons

    if numSets > numButtons then
        numButtons = numSets
    end
    local textureC = 1
    local id_table = C_EquipmentSet.GetEquipmentSetIDs()

    for i = 1,numButtons do
        if numSets >= i then
            local frame = getNewEquipmentSetButton(i)
            local name, texture, setID, isEquipped, _, _, _, numLost, _ = C_EquipmentSet.GetEquipmentSetInfo(id_table[i])

            frame:Show()
            frame.saveOutfit:Hide()
            frame.deleteOutfit:Hide()
            frame.equipOutfit:Hide()
            frame.ddbg:Hide()
            frame:SetHeight(49)
            frame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetEquipmentSet(self.setID)
                self.standardOnClick(self)
            end)
            frame:SetText(name)
            frame.setName = name
            frame.setID = setID

            if texture then
                frame.icon:SetTexture(texture)
            else
                frame.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
            if textureC==1 then frame:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
                textureC = 2
            else
                frame:SetNormalTexture(nil)
                textureC = 1
            end
            if isEquipped then
                frame:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
            end
            if numLost > 0 then
              --  _G[frame:GetName().."NormalTexture"]:SetVertexColor(1,0.3,0.3)
                frame:GetFontString():SetTextColor(1, 0.3, 0.3)
            else
                --_G[frame:GetName().."NormalTexture"]:SetVertexColor(1,1,1)
                frame:GetFontString():SetTextColor(1, 1, 1)
            end
        else
            if _G["GwPaperDollOutfitsButton" .. i] ~= nil then
                _G["GwPaperDollOutfitsButton" .. i]:Hide()
            end
        end
    end
end

function GwPaperDollOutfitsUpdateIngoredSlots(id)
   local ignoredSlots = C_EquipmentSet.GetIgnoredSlots(id)
    for slot, ignored in pairs(ignoredSlots) do
        if ignored then
            C_EquipmentSet.IgnoreSlotForSave(slot)
            savedItemSlots[slot].ignoreSlotCheck:SetChecked(false)
        else
            C_EquipmentSet.UnignoreSlotForSave(slot)
            savedItemSlots[slot].ignoreSlotCheck:SetChecked(true)
        end
    end
end

function GwPaperDollOutfitsToggleIgnoredSlots(show)
    for k, v in pairs(savedItemSlots) do
        if show then
            v.ignoreSlotCheck:Show()
        else
            v.ignoreSlotCheck:Hide()
        end
    end
end

function GwPaperDollOutfits_OnEvent(self, event, ...)
	if event == "EQUIPMENT_SWAP_FINISHED" then
		local completed, setName = ...
		if completed then
			PlaySound(1212) -- plays the equip sound for plate mail
			if self:IsShown() then
				self.selectedSetID = C_EquipmentSet.GetEquipmentSetID(setName)
				GwOutfitsDrawItemSetList()
			end
		end
	end

	if self:IsShown() then
		if event == "EQUIPMENT_SETS_CHANGED" then
			GwOutfitsDrawItemSetList()
		elseif event == "PLAYER_EQUIPMENT_CHANGED" or event == "BAG_UPDATE" then
            GwPaperDollOutfits:SetScript("OnUpdate", function(self)
                GwOutfitsDrawItemSetList()
                GwPaperDollOutfits:SetScript("OnUpdate", nil)
            end)
		end
	end
end

local function getNewTitlesButton(i)
    if _G["GwPaperDollTitleButton" .. i] ~= nil then return _G["GwPaperDollTitleButton" .. i] end

    local f = CreateFrame("Button", "GwPaperDollTitleButton" .. i, GwPaperTitles, "GwCharacterMenuBlank")
    if i > 1 then
        _G["GwPaperDollTitleButton" .. i]:SetPoint("TOPLEFT", _G["GwPaperDollTitleButton" .. (i - 1)], "BOTTOMLEFT")
    else
        _G["GwPaperDollTitleButton" .. i]:SetPoint("TOPLEFT", GwPaperTitles, "TOPLEFT")
    end
    f:SetWidth(231)
    f:GetFontString():SetPoint("LEFT", 5, 0)
    GwPaperTitles.buttons = GwPaperTitles.buttons + 1

 --   f:GetFontString():ClearAllPoints()
--    f:GetFontString():SetPoint("TOP",f,"TOP",0,-20)
    return f
end

function GwPaperDollUpdateTitlesList()
    savedPlayerTitles[1] = {}
    savedPlayerTitles[1].name ="       "
    savedPlayerTitles[1].id =-1

    local tableIndex = 1

    for i = 1, GetNumTitles() do
		if IsTitleKnown(i) then
			tempName, playerTitle = GetTitleName(i);
            if tempName and playerTitle then
                tableIndex = tableIndex  + 1
                local tempName, playerTitle = GetTitleName(i)
                savedPlayerTitles[tableIndex]= {}
                savedPlayerTitles[tableIndex].name = strtrim(tempName)
                savedPlayerTitles[tableIndex].id = i
            end
        end
    end

    table.sort(savedPlayerTitles,function(a, b) return a.name < b.name end)
    savedPlayerTitles[1].name = PLAYER_TITLE_NONE
end

function GwPaperDollUpdateTitlesLayout()
    local currentTitle = GetCurrentTitle()
    local textureC = 1
    local buttonId = 1

    for i = GwPaperTitles.scroll, #savedPlayerTitles do
        if savedPlayerTitles[i] ~= nil then
            local button = getNewTitlesButton(buttonId)
            button:Show()
            buttonId = buttonId + 1
            button:SetText(savedPlayerTitles[i].name)
            button:SetScript("OnClick", function() SetCurrentTitle(savedPlayerTitles[i].id) end)

            if textureC==1 then
                button:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
                textureC = 2
            else
                button:SetNormalTexture(nil)
                textureC = 1
            end

            if currentTitle == savedPlayerTitles[i].id then
                button:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
            end
            if buttonId > 21 then break end
        end
    end

    for i=buttonId,GwPaperTitles.buttons do
         _G["GwPaperDollTitleButton" .. i]:Hide()
    end
end

function GwPaperDollTitles_OnEvent()
    --GwPaperDollUpdateTitlesList()
    --GwPaperDollUpdateTitlesLayout()
end

local function getNewReputationCat(i)
    if _G["GwPaperDollReputationCat" .. i] ~= nil then return _G["GwPaperDollReputationCat" .. i] end

    local f = CreateFrame("Button","GwPaperDollReputationCat"..i,GwPaperReputation,"GwPaperDollReputationCat")

    if i > 1 then
        _G["GwPaperDollReputationCat" .. i]:SetPoint("TOPLEFT", _G["GwPaperDollReputationCat" .. (i - 1)], "BOTTOMLEFT")
    else
        _G["GwPaperDollReputationCat" .. i]:SetPoint("TOPLEFT", GwPaperReputation, "TOPLEFT")
    end
    f:SetWidth(231)
    f:GetFontString():SetPoint("TOPLEFT",10 ,-10)
    GwPaperReputation.buttons = GwPaperReputation.buttons + 1

 --   f:GetFontString():ClearAllPoints()
--    f:GetFontString():SetPoint("TOP",f,"TOP",0,-20)
    return f
end

function GwUpdateSavedReputation()
     for factionIndex = GwPaperReputation.scroll, GetNumFactions() do
        savedReputation[factionIndex] = {}
        savedReputation[factionIndex].name, savedReputation[factionIndex].description, savedReputation[factionIndex].standingId, savedReputation[factionIndex].bottomValue, savedReputation[factionIndex].topValue,savedReputation[factionIndex].earnedValue, savedReputation[factionIndex].atWarWith, savedReputation[factionIndex].canToggleAtWar, savedReputation[factionIndex].isHeader, savedReputation[factionIndex].isCollapsed, savedReputation[factionIndex].hasRep, savedReputation[factionIndex].isWatched, savedReputation[factionIndex].isChild,  savedReputation[factionIndex].factionID, savedReputation[factionIndex].hasBonusRepGain, savedReputation[factionIndex].canBeLFGBonus = GetFactionInfo(factionIndex)
    end
end

local function returnReputationData(factionIndex)
    if savedReputation[factionIndex] == nil then return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil end
    return savedReputation[factionIndex].name, savedReputation[factionIndex].description, savedReputation[factionIndex].standingId, savedReputation[factionIndex].bottomValue, savedReputation[factionIndex].topValue,savedReputation[factionIndex].earnedValue, savedReputation[factionIndex].atWarWith, savedReputation[factionIndex].canToggleAtWar, savedReputation[factionIndex].isHeader, savedReputation[factionIndex].isCollapsed, savedReputation[factionIndex].hasRep, savedReputation[factionIndex].isWatched, savedReputation[factionIndex].isChild, savedReputation[factionIndex].factionID, savedReputation[factionIndex].hasBonusRepGain, savedReputation[factionIndex].canBeLFGBonus
end

function GwPaperDollUpdateReputations()
    ExpandAllFactionHeaders()
    local headerIndex = 1
    local CurrentOwner =nil
    local cMax = 0
    local cCur = 0
    local textureC = 1

    for factionIndex = GwPaperReputation.scroll, GetNumFactions() do
        local  name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID = returnReputationData(factionIndex)
		if name ~= nil then
            cCur = cCur + standingId
			cMax = cMax + 8
            if isHeader and not isChild then
				local header = getNewReputationCat(headerIndex)
                header:Show()
                CurrentOwner = header
                header:SetText(name)

                if CurrentOwner ~= nil then
                    CurrentOwner.StatusBar:SetValue(cCur / cMax)
                end

                cCur = 0
                cMax = 0
                headerIndex = headerIndex + 1

                header:SetScript("OnClick", function() GwReputationShowReputationHeader(factionIndex ) GwUpdateReputationDetails() end)

                if textureC == 1 then
                    header:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
                    textureC = 2
                else
                    header:SetNormalTexture(nil)
                    textureC = 1
                end
            end
        end

        if CurrentOwner ~= nil then
            if cMax ~= 0 and cMax ~= nil then
                CurrentOwner.StatusBar:SetValue(cCur / cMax)
				if cCur / cMax >= 1 and cMax ~= 0 then
					CurrentOwner.StatusBar:SetStatusBarColor(171/255, 37/255, 240/255)
				else
					CurrentOwner.StatusBar:SetStatusBarColor(240/255, 240/255, 155/255)
				end
            end
        end
    end

    for i=headerIndex,GwPaperReputation.buttons do
         _G["GwPaperDollReputationCat" .. i]:Hide()
    end
end

function GwReputationShowReputationHeader(i)
    selectedReputationCat = i
end

local function getNewReputationDetail(i)
    if _G["GwReputationDetails" .. i] ~= nil then return _G["GwReputationDetails" .. i] end

    local f = CreateFrame("Button", "GwReputationDetails" .. i, GwPaperReputationScrollFrame.scrollchild, "GwReputationDetails")

    if i > 1 then
        _G["GwReputationDetails" .. i]:SetPoint("TOPLEFT", _G["GwReputationDetails" .. (i - 1)],"BOTTOMLEFT", 0, -1)
    else
        _G["GwReputationDetails" .. i]:SetPoint("TOPLEFT", GwPaperReputationScrollFrame.scrollchild, "TOPLEFT", 2, -10)
    end
    GwPaperReputation.detailFrames =  GwPaperReputation.detailFrames + 1

    return f
end

local function SetReputationDetailFrameData(frame, factionIndex, savedHeaderName, name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus)
    frame:Show()
    frame.factionIndex = factionIndex

    if factionID and RT[factionID] then
        frame.repbg:SetTexture("Interface/AddOns/GW2_UI/textures/rep/" .. RT[factionID])
        if isExpanded then
            frame.repbg:SetTexCoord(0, 1, 0, 1)
            frame.repbg:SetAlpha(0.85)
            frame.repbg:SetDesaturated(false)
        else
            frame.repbg:SetTexCoord(0, 1, REPBG_T, REPBG_B)
            frame.repbg:SetAlpha(0.33)
            frame.repbg:SetDesaturated(true)
        end
    end

    if expandedFactions[factionIndex] == nil then
        frame.controles:Hide()
        frame:SetHeight(80)
    else
        frame:SetHeight(140)
        frame.controles:Show()
    end

    local currentRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId)), gender)
    local nextRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId + 1)), gender)
    local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GW.api.GetFriendshipReputation(factionID)

    if textureC == 1 then
        frame.background:SetTexture(nil)
        textureC = 2
    else
        frame.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
        textureC = 1
    end

    frame.name:SetText(name .. savedHeaderName)
    frame.details:SetText(description)

    if atWarWith then
        frame.controles.atwar.isActive = true
        frame.controles.atwar.icon:SetTexCoord(0.5, 1, 0, 0.5)
    else
        frame.controles.atwar.isActive = false
        frame.controles.atwar.icon:SetTexCoord(0, 0.5, 0, 0.5)
    end

    if canToggleAtWar then
        frame.controles.atwar.isShowAble = true
    else
        frame.controles.atwar.isShowAble = false
    end

    if isWatched then
        frame.controles.showAsBar:SetChecked(true)
    else
        frame.controles.showAsBar:SetChecked(false)
    end

    if IsFactionInactive(factionIndex) then
        frame.controles.inactive:SetChecked(true)
    else
        frame.controles.inactive:SetChecked(false)
    end

    frame.controles.inactive:SetScript("OnClick", function()
        if IsFactionInactive(factionIndex) then
            SetFactionActive(factionIndex)
        else
            SetFactionInactive(factionIndex)
        end
        GwUpdateSavedReputation()
        GwPaperDollUpdateReputations()
        GwUpdateReputationDisplayOldData()
    end)

    if canBeLFGBonus then
        frame.controles.favorit.isShowAble = true
        frame.controles.favorit:SetScript("OnClick", function()
            ReputationBar_SetLFBonus(factionID)
            GwUpdateSavedReputation()
            GwUpdateReputationDisplayOldData()
        end)
    else
        frame.controles.favorit.isShowAble = false
    end

    frame.controles.atwar:SetScript("OnClick", function()
        FactionToggleAtWar(factionIndex)
        if canToggleAtWar then
            GwUpdateSavedReputation()
            GwUpdateReputationDisplayOldData()
        end
    end)

    frame.controles.showAsBar:SetScript("OnClick", function()
        if isWatched then
            SetWatchedFactionIndex(0)
        else
            SetWatchedFactionIndex(factionIndex)
        end
        GwUpdateSavedReputation()
        GwUpdateReputationDisplayOldData()
    end)

    SetFactionInactive(GetSelectedFaction())

        --[[
    if factionID and C_Reputation.IsFactionParagon(factionID) then
        local currentValue, maxValueParagon, _, hasReward  = C_Reputation.GetFactionParagonInfo(factionID)

        if currentValue > 10000 then
            repeat
                currentValue = currentValue - 10000
            until( currentValue < 10000 )
        end


        frame.currentRank:SetText(currentRank)
        frame.nextRank:SetText(GwLocalization["CHARACTER_PARAGON"])

        frame.currentValue:SetText(comma_value(currentValue))
        frame.nextValue:SetText(comma_value(maxValueParagon))

        local percent = math.floor(round(((currentValue - 0) / (maxValueParagon - 0))*100),0)
        frame.percentage:SetText((math.floor( round(((currentValue - 0) / (maxValueParagon - 0))*100),0) ).."%")

        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.StatusBar:SetValue((currentValue - 0) / (maxValueParagon - 0))

        frame.background2:SetVertexColor(GW.FACTION_BAR_COLORS[9].r,GW.FACTION_BAR_COLORS[9].g,GW.FACTION_BAR_COLORS[9].b)
        frame.StatusBar:SetStatusBarColor(GW.FACTION_BAR_COLORS[9].r,GW.FACTION_BAR_COLORS[9].g,GW.FACTION_BAR_COLORS[9].b)
    ]]
    if friendID ~= nil then
        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.currentRank:SetText(friendTextLevel)
        frame.nextRank:SetText()

        frame.background2:SetVertexColor(GW.FACTION_BAR_COLORS[5].r,GW.FACTION_BAR_COLORS[5].g,GW.FACTION_BAR_COLORS[5].b)
        frame.StatusBar:SetStatusBarColor(GW.FACTION_BAR_COLORS[5].r,GW.FACTION_BAR_COLORS[5].g,GW.FACTION_BAR_COLORS[5].b)

        if nextFriendThreshold then
            frame.currentValue:SetText(comma_value(friendRep - friendThreshold))
            frame.nextValue:SetText(comma_value(nextFriendThreshold - friendThreshold))

            local percent = math.floor(round(((friendRep - friendThreshold) / (nextFriendThreshold - friendThreshold)) * 100), 0)
            if percent == -1 then
                frame.percentage:SetText("0%")
            else
                frame.percentage:SetText((math.floor( round(((friendRep - friendThreshold) / (nextFriendThreshold - friendThreshold)) * 100), 0)) .. "%")
            end
            frame.StatusBar:SetValue((friendRep - friendThreshold) / (nextFriendThreshold - friendThreshold))
        else
            --max rank
            frame.StatusBar:SetValue(1)
            frame.nextValue:SetText()
            frame.currentValue:SetText()
            frame.percentage:SetText("100%")
        end
    else
        frame.currentRank:SetText(currentRank)
        frame.nextRank:SetText(nextRank)
        frame.currentValue:SetText(GW.CommaValue(earnedValue - bottomValue))
        local percent = math.floor(GW.RoundInt(((earnedValue - bottomValue) / (topValue - bottomValue)) * 100), 0)
        if percent == -1 then
            frame.percentage:SetText("0%")
        else
            frame.percentage:SetText((math.floor( GW.RoundInt(((earnedValue - bottomValue) / (topValue - bottomValue)) * 100), 0)) .. "%")
        end

        frame.nextValue:SetText(GW.CommaValue(topValue - bottomValue))
        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.StatusBar:SetValue((earnedValue - bottomValue) / (topValue - bottomValue))

        if currentRank == nextRank and earnedValue - bottomValue == 0 then
            frame.percentage:SetText("100%")
            frame.StatusBar:SetValue(1)
            frame.nextValue:SetText()
            frame.currentValue:SetText()
        end

        frame.background2:SetVertexColor(GW.FACTION_BAR_COLORS[standingId].r, GW.FACTION_BAR_COLORS[standingId].g, GW.FACTION_BAR_COLORS[standingId].b)
        frame.StatusBar:SetStatusBarColor(GW.FACTION_BAR_COLORS[standingId].r, GW.FACTION_BAR_COLORS[standingId].g, GW.FACTION_BAR_COLORS[standingId].b)
    end
end

function GwUpdateReputationDetails()
    local buttonIndex = 1
    local gender = UnitSex("player")
    local savedHeaderName = ""
    local savedHeight = 0
    local textureC = 1

    for factionIndex = selectedReputationCat + 1, GetNumFactions() do
        local  name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = returnReputationData(factionIndex)
        if name ~= nil then
            if isHeader and not isChild then break end
            if isHeader and isChild then
               savedHeaderName = " |cFFa0a0a0" .. name .. "|r"
            end

            if not isChild then
                savedHeaderName = ""
            end

            local frame = getNewReputationDetail(buttonIndex)

            SetReputationDetailFrameData(frame, factionIndex, savedHeaderName, name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus)
            savedHeight = savedHeight + frame:GetHeight()
            buttonIndex = buttonIndex + 1
        end
    end

    for i=buttonIndex, GwPaperReputation.detailFrames do
         _G["GwReputationDetails" .. i]:Hide()
    end

    GwPaperReputationScrollFrame:SetVerticalScroll(0)
    GwPaperReputationScrollFrame:SetVerticalScroll(0)

    GwPaperReputationScrollFrame.slider.thumb:SetHeight(100)
    GwPaperReputationScrollFrame.slider:SetValue(1)
    GwPaperReputationScrollFrame:SetVerticalScroll(0)
    GwPaperReputationScrollFrame.savedHeight = savedHeight - 590

    reputationLastUpdateMethod = GwUpdateReputationDetails
end

function GwReputationSearch(a, b)
    return string.find(a, b)
end

function GwDetailFaction(factionIndex, boolean)
    if boolean then
        expandedFactions[factionIndex] = true
        return
    end
    expandedFactions[factionIndex] = nil
end

function GwUpdateReputationDetailsSearch(s)
    local buttonIndex = 1
    local savedHeaderName = ""
    local savedHeight = 0
    local textureC = 1

    for factionIndex = 1, GetNumFactions() do
        local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = returnReputationData(factionIndex)
        local lower1 = string.lower(name)
        local lower2 = string.lower(s)
        local show = true

        if isHeader then
           if not isChild then
                show = false
            end
        end

        if  (name ~= nil and GwReputationSearch(lower1, lower2) ~= nil) and show then
            local frame = getNewReputationDetail(buttonIndex)

            SetReputationDetailFrameData(frame, factionIndex, savedHeaderName, name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus)
            savedHeight = savedHeight + frame:GetHeight()
            buttonIndex = buttonIndex + 1
        end
    end

    for i = buttonIndex, GwPaperReputation.detailFrames do
         _G["GwReputationDetails" .. i]:Hide()
    end

    GwPaperReputationScrollFrame:SetVerticalScroll(0)
    GwPaperReputationScrollFrame.slider.thumb:SetHeight(100)
    GwPaperReputationScrollFrame.slider:SetValue(1)
    GwPaperReputationScrollFrame:SetVerticalScroll(0)
    GwPaperReputationScrollFrame.savedHeight = savedHeight - 590

    reputationLastUpdateMethod = GwUpdateReputationDetailsSearch
    reputationLastUpdateMethodParams = s
end

function GwUpdateReputationDisplayOldData()
    if reputationLastUpdateMethod ~= nil then
    reputationLastUpdateMethod(reputationLastUpdateMethodParams)
    end
end

local function getSkillElement(index)
    if _G["GwPaperSkillsItem" .. index] ~= nil then return _G["GwPaperSkillsItem" .. index] end
    local f = CreateFrame("Button", "GwPaperSkillsItem" .. index, GwPaperSkills.scroll.scrollchild, "GwPaperSkillsItem")
    f.name:SetFont(DAMAGE_TEXT_FONT, 12)
    f.name:SetText(UNKNOWN)
    f.val:SetFont(DAMAGE_TEXT_FONT, 12)
    f.val:SetText(UNKNOWN)
    f:SetText("")
    return f
end

local function updateSkillItem(self)
    if self.isHeader then
        self:SetHeight(30)
        self.val:Hide()
        self.StatusBar:Hide()
        self.name:SetFont(DAMAGE_TEXT_FONT, 14)
        self.arrow:Show()
        self.arrow:SetRotation(-1.5708)
        self.bgheader:Show()
        self.bg:Hide()
        self.bgstatic:Hide()
    else
        self:SetHeight(50)
        self.val:Show()
        self.StatusBar:Show()
        self.name:SetFont(DAMAGE_TEXT_FONT, 12)
        self.arrow:Hide()
        self.bgheader:Hide()
        self.bg:Show()
        self.bgstatic:Show()
    end
end

local function updateSkills()
    local height = 50
    local y = 0
    local LastElement = nil

    for skillIndex = 1, GetNumSkillLines() do
        local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier,
        skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType,
        skillDescription = GetSkillLineInfo(skillIndex)

        local f = getSkillElement(skillIndex)
        local zebra = skillIndex % 2

        if LastElement==nil then
            f:SetPoint("TOPLEFT", 0, -y)
        else
            f:SetPoint("TOPLEFT", LastElement, "BOTTOMLEFT", 0, 0)
        end
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
    end
    GwPaperSkills.scroll.scrollchild:SetHeight(y)
end

function gw_register_character_window()
    CreateFrame("Frame", "GwCharacterWindowContainer", GwCharacterWindow, "GwCharacterWindowContainer")
    CreateFrame("Button", "GwDressingRoom", GwCharacterWindowContainer, "GwDressingRoom")
    CreateFrame("Frame", "GwCharacterMenu", GwCharacterWindowContainer, "GwCharacterMenu")
    CreateFrame("Frame", "GwPaperDollBagItemList", GwCharacterWindowContainer, "GwPaperDollBagItemList")
    CreateFrame("Frame", "GwPaperDollOutfits", GwCharacterWindowContainer, "GwPaperDollOutfits")
    CreateFrame("Frame", "GwPaperTitles", GwCharacterWindowContainer, "GwPaperTitles")
    CreateFrame("Frame", "GwPaperReputation", GwCharacterWindowContainer, "GwPaperReputation")
    CreateFrame("Frame", "GwPaperSkills", GwCharacterWindowContainer, "GwPaperSkills")
    CreateFrame("Frame", "GwPaperDollSelectedIndicator", GwCharacterWindowContainer, "GwPaperDollSelectedIndicator")

    --Legacy pet window
    CreateFrame("Frame", "GwPetContainer", GwCharacterWindowContainer, "GwPetContainer")
    CreateFrame("Button", "GwDressingRoomPet", GwPetContainer, "GwPetPaperdoll")

    GwPaperTitles:HookScript("OnShow", function()
        GwPaperDollUpdateTitlesList()
        GwPaperDollUpdateTitlesLayout()
    end)

    GwUpdateSavedReputation()
    GwPaperReputationScrollFrame:SetScrollChild(GwPaperReputationScrollFrame.scrollchild)
    GwPaperDollUpdateReputations()
    GwPaperSkills.scroll:SetScrollChild(GwPaperSkills.scroll.scrollchild)
    updateSkills()

    CharacterFrame:SetScript("OnShow", function()
          HideUIPanel(CharacterFrame)
    end)

    CharacterFrame:UnregisterAllEvents()
    hooksecurefunc("ToggleCharacter", GwToggleCharacter)

    gwPaperDollUpdateStats()
    gwPaperDollUpdatePetStats()
    GwUpdateReputationDetails()

    GwCharacterWindowContainer:HookScript("OnHide" ,function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    end)

    GwCharacterWindowContainer:HookScript("OnShow", function()
        GwCharacterWindow.windowIcon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\character-window-icon")
        GwCharacterWindow.WindowHeader:SetText(CHARACTER)
        if CHARACTER_PANEL_OPEN == nil then
            gwCharacterPanelToggle(GwCharacterMenu)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
        end
    end)

    StaticPopupDialogs["GW_UNEQUIP_LEGENDARY"] = {
        text = GwLocalization["UNEQUIP_LEGENDARY"],
        button1 = GwLocalization["SETTINGS_CANCEL"],
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
    StaticPopupDialogs["GW_NOT_A_LEGENDARY"] = {
        text = GwLocalization["NOT_A_LEGENDARY"],
        button1 = GwLocalization["SETTINGS_CANCEL"],
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
    return GwCharacterWindowContainer
end

local CHARACTER_PANEL_OPEN = ""

function GwToggleCharacter(tab, onlyShow)
    local HARACTERFRAME_DEFAULTFRAMES= {}

    CHARACTERFRAME_DEFAULTFRAMES["PaperDollFrame"] = GwCharacterMenu
    CHARACTERFRAME_DEFAULTFRAMES["ReputationFrame"] = GwPaperReputation
    CHARACTERFRAME_DEFAULTFRAMES["SkillFrame"] = GwPaperSkills
    CHARACTERFRAME_DEFAULTFRAMES["PetPaperDollFrame"] = GwPaperSkills

    if CHARACTERFRAME_DEFAULTFRAMES[tab] ~= nil and CHARACTER_PANEL_OPEN ~= tab  then
        gwCharacterPanelToggle(CHARACTERFRAME_DEFAULTFRAMES[tab])
        CHARACTER_PANEL_OPEN = tab
        return
    end

    if GwCharacterWindow:IsShown() then
        if not InCombatLockdown() then
            GwCharacterWindow:SetAttribute("windowPanelOpen",   0)
        end
        CHARACTER_PANEL_OPEN = nil
        return
    end
end
