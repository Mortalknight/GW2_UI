local _, GW = ...
local comma_value = GW.comma_value
local round = GW.round

local gender = UnitSex("player")

local STATS_ICONS = {
    STRENGTH = {l = 0.75, r = 1, t = 0.75, b = 1},
    AGILITY = {l = 0.75, r = 1, t = 0.75, b = 1},
    INTELLECT = {l = 0.75, r = 1, t = 0.75, b = 1},
    STAMINA = {l = 0, r = 0.25, t = 0.25, b = 0.5},
    ARMOR = {l = 0.5, r = 0.75, t = 0, b = 0.25},
    CRITCHANCE = {l = 0.25, r = 0.5, t = 0.25, b = 0.5},
    HASTE = {l = 0, r = 0.25, t = 0.5, b = 0.75},
    MASTERY = {l = 0.75, r = 1, t = 0.25, b = 0.5},
    --Needs icon
    MANAREGEN = {l = 0.75, r = 1, t = 0.25, b = 0.5},
    VERSATILITY = {l = 0.25, r = 0.5, t = 0.5, b = 0.75},
    LIFESTEAL = {l = 0.25, r = 0.5, t = 0.75, b = 1},
    --Needs icon
    AVOIDANCE = {l = 0, r = 0.25, t = 0.75, b = 1},
    --DODGE needs icon
    DODGE = {l = 0.5, r = 0.75, t = 0.5, b = 0.75},
    BLOCK = {l = 0.75, r = 1, t = 0.5, b = 0.75},
    PARRY = {l = 0, r = 0.25, t = 0, b = 0.25},
    MOVESPEED = {l = 0.5, r = 0.75, t = 0.75, b = 1}
}

local savedItemSlots = {}
local savedPlayerTitles = {}

local savedReputation = {}

local selectedReputationCat = 1
local reputationLastUpdateMethod = function()
end
local reputationLastUpdateMethodParams = nil

local expandedFactions = {}

local PAPERDOLL_STATCATEGORIES = {
    [1] = {
        categoryFrame = "AttributesCategory",
        stats = {
            [1] = {stat = "STRENGTH", primary = LE_UNIT_STAT_STRENGTH},
            [2] = {stat = "AGILITY", primary = LE_UNIT_STAT_AGILITY},
            [3] = {stat = "INTELLECT", primary = LE_UNIT_STAT_INTELLECT},
            [4] = {stat = "STAMINA"},
            [5] = {stat = "ARMOR"},
            [6] = {stat = "MANAREGEN", roles = {"HEALER"}}
        }
    },
    [2] = {
        categoryFrame = "EnhancementsCategory",
        stats = {
            [1] = {stat = "CRITCHANCE", hideAt = 0},
            [2] = {stat = "HASTE", hideAt = 0},
            [3] = {stat = "MASTERY", hideAt = 0},
            [4] = {stat = "VERSATILITY", hideAt = 0},
            [5] = {stat = "DODGE"},
            [6] = {stat = "PARRY", hideAt = 0},
            [7] = {stat = "BLOCK", hideAt = 0},
            [8] = {stat = "AVOIDANCE", hideAt = 0},
            [9] = {stat = "LIFESTEAL", hideAt = 0},
            [10] = {stat = "MOVESPEED", hideAt = 0}
        }
    }
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
--]]
local EquipSlotList = {}
local bagItemList = {}
local numBagSlotFrames = 0
local selectedInventorySlot = nil

local function gwCharacterMenuBlank_OnLoad(self)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self:SetNormalTexture(nil)
    local fontString = self:GetFontString()
    fontString:SetTextColor(1, 1, 1, 1)
    fontString:SetShadowColor(0, 0, 0, 0)
    fontString:SetShadowOffset(1, -1)
    fontString:SetFont(DAMAGE_TEXT_FONT, 14)
end

local function gwCharacterMenuButtonBack_OnLoad(self)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self:SetNormalTexture(nil)
    local fontString = self:GetFontString()
    fontString:SetTextColor(1, 1, 1, 1)
    fontString:SetShadowColor(0, 0, 0, 0)
    fontString:SetShadowOffset(1, -1)
    fontString:SetFont(DAMAGE_TEXT_FONT, 14)
end

local function gwCharacterMenuButtonBack_OnClick(self, button)
    gwCharacterPanelToggle(GwCharacterMenu)
end

local function gwPaperDollSlotButton_OnClickRouter(self, button)
    if (IsModifiedClick()) then
        gwPaperDollSlotButton_OnModifiedClick(self, button)
    else
        gwPaperDollSlotButton_OnClick(self, button)
    end
end
local function gwPaperDollSlotButton_OnDragStart(self)
    gwPaperDollSlotButton_OnClick(self, "LeftButton", true)
end
local function gwPaperDollSlotButton_OnReceiveDrag(self)
    gwPaperDollSlotButton_OnClick(self, "LeftButton", true)
end
local function gwPaperDollBagItem_OnEnter(self)
    self:SetScript("OnUpdate", self.UpdateTooltip)
    GameTooltip:Show()
end
local function gwPaperDollBagItem_OnLeave(self)
    self:SetScript("OnUpdate", nil)
    GameTooltip:Hide()
end
local function getBagSlotFrame(i)
    if _G["gwPaperDollBagSlotButton" .. i] ~= nil then
        return _G["gwPaperDollBagSlotButton" .. i]
    end

    local f = CreateFrame("Button", "gwPaperDollBagSlotButton" .. i, GwPaperDollBagItemList, "GwPaperDollBagItem")
    --f:SetScript("OnShow", gwPaperDollSlotButton_OnShow)
    --f:SetScript("OnHide", gwPaperDollSlotButton_OnHide)
    f:SetScript("OnEvent", gwPaperDollSlotButton_OnEvent)
    --f:SetScript("OnClick", gwPaperDollSlotButton_OnClickRouter)
    f:SetScript("OnClick", GwPaperDollBagItem_OnClick)
    f:SetScript("OnDragStart", gwPaperDollSlotButton_OnDragStart)
    f:SetScript("OnReceiveDrag", gwPaperDollSlotButton_OnReceiveDrag)
    --f:SetScript("OnEnter", gwPaperDollSlotButton_OnEnter)
    f:SetScript("OnEnter", gwPaperDollBagItem_OnEnter)
    --f:SetScript("OnLeave", gwPaperDollSlotButton_OnLeave)
    f:SetScript("OnLeave", gwPaperDollBagItem_OnLeave)
    gwActionButtonGlobalStyle(f)

    numBagSlotFrames = numBagSlotFrames + 1

    return f
end

function GwupdateBagItemListAll()
    if selectedInventorySlot ~= nil then
        return
    end

    local gridIndex = 1
    local itemIndex = 1
    local x = 10
    local y = 15

    for k, v in pairs(EquipSlotList) do
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
                if itemIndex > 36 then
                    break
                end
            end
        end
    end
    for i = itemIndex, numBagSlotFrames do
        if _G["gwPaperDollBagSlotButton" .. i] ~= nil then
            _G["gwPaperDollBagSlotButton" .. i]:Hide()
        end
    end
end

local function updateBagItemList(itemButton)
    local id = itemButton.id or itemButton:GetID()
    if selectedInventorySlot ~= id then
        return
    end

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
        if itemIndex > 36 then
            break
        end
    end
    for i = itemIndex, numBagSlotFrames do
        if _G["gwPaperDollBagSlotButton" .. i] ~= nil then
            _G["gwPaperDollBagSlotButton" .. i]:Hide()
        end
    end
end

function updateBagItemButton(button)
    local location = button.location
    if (not location) then
        return
    end
    local id, _, textureName, count, durability, maxDurability, _, _, _, _, _, setTooltip, quality =
        EquipmentManager_GetItemInfoByLocation(location)
    button.ItemId = id
    local broken = (maxDurability and durability == 0)
    if (textureName) then
        SetItemButtonTexture(button, textureName)
        SetItemButtonCount(button, count)
        if broken then
            SetItemButtonTextureVertexColor(button, 0.9, 0, 0)
        else
            SetItemButtonTextureVertexColor(button, 1.0, 1.0, 1.0)
        end

        if durability ~= nil and (durability / maxDurability) < 0.5 then
            button.repairIcon:Show()
            if (durability / maxDurability) == 0 then
                button.repairIcon:SetTexCoord(0, 1, 0.5, 1)
            else
                button.repairIcon:SetTexCoord(0, 1, 0, 0.5)
            end
        else
            button.repairIcon:Hide()
        end

        button.UpdateTooltip = function()
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT", 6, -EquipmentFlyoutFrame.buttonFrame:GetHeight() - 6)
            setTooltip()
        end

        GwSetItemButtonQuality(button, quality, id)
    end
end

function GwPaperDollBagItem_OnClick(self)
    if (self.location) then
        if (UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[self.itemSlot]) then
            UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
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
    local spec = GetSpecialization()
    local localizedClass, _, _ = UnitClass("player")
    local _, name, _, _, _, _ = GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player"))

    if name ~= nil then
        local data =
            GwLocalization["CHARACTER_LEVEL"] .. " " .. UnitLevel("player") .. " " .. name .. " " .. localizedClass
        GwDressingRoom.characterData:SetText(data)
    end
end

function gwPaperDollStats_OnEvent(self, event, ...)
    local unit = ...
    if
        (event == "PLAYER_ENTERING_WORLD" or event == "UNIT_MODEL_CHANGED" or
            event == "UNIT_NAME_UPDATE" and unit == "player")
     then
        GwDressingRoom.model:SetUnit("player", false)
        gwPaperDollUpdateUnitData()
        return
    end

    if (unit == "player") then
        if (event == "UNIT_LEVEL") then
            gwPaperDollUpdateUnitData()
        elseif
            (event == "UNIT_DAMAGE" or event == "UNIT_ATTACK_SPEED" or event == "UNIT_RANGEDDAMAGE" or
                event == "UNIT_ATTACK" or
                event == "UNIT_STATS" or
                event == "UNIT_RANGED_ATTACK_POWER" or
                event == "UNIT_SPELL_HASTE" or
                event == "UNIT_MAXHEALTH" or
                event == "UNIT_AURA" or
                event == "UNIT_RESISTANCES" or
                IsMounted())
         then
            self:SetScript("OnUpdate", gwPaperDollStats_QueuedUpdate)
        end
    end

    if
        (event == "COMBAT_RATING_UPDATE" or event == "MASTERY_UPDATE" or event == "SPEED_UPDATE" or
            event == "LIFESTEAL_UPDATE" or
            event == "AVOIDANCE_UPDATE" or
            event == "BAG_UPDATE" or
            event == "PLAYER_EQUIPMENT_CHANGED" or
            event == "PLAYERBANKSLOTS_CHANGED" or
            event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" or
            event == "PLAYER_DAMAGE_DONE_MODS" or
            IsMounted())
     then
        self:SetScript("OnUpdate", gwPaperDollStats_QueuedUpdate)
    elseif (event == "PLAYER_TALENT_UPDATE") then
        gwPaperDollUpdateUnitData()
        self:SetScript("OnUpdate", gwPaperDollStats_QueuedUpdate)
    elseif (event == "ACTIVE_TALENT_GROUP_CHANGED") then
        gwPaperDollUpdateStats()
    elseif (event == "SPELL_POWER_CHANGED") then
        self:SetScript("OnUpdate", gwPaperDollStats_QueuedUpdate)
    end
end

function gwPaperDollUpdateStats()
    local level = UnitLevel("player")
    local categoryYOffset = -5
    local statYOffset = 0

    local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
    avgItemLevelEquipped = math.floor(avgItemLevelEquipped)
    avgItemLevel = math.floor(avgItemLevel)
    if avgItemLevelEquipped < avgItemLevel then
        avgItemLevelEquipped = math.floor(avgItemLevelEquipped) .. "(" .. math.floor(avgItemLevel) .. ")"
    end

    GwDressingRoom.itemLevel:SetText(avgItemLevelEquipped)
    GwDressingRoom.itemLevel:SetTextColor(GetItemLevelColor())

    local spec = GetSpecialization()
    local role = GetSpecializationRole(spec)

    local statFrame = nil

    local lastAnchor
    local numShownStats = 1
    local grid = 1
    local x = 0
    local y = 0

    for catIndex = 1, #PAPERDOLL_STATCATEGORIES do
        local catFrame = CharacterStatsPane[PAPERDOLL_STATCATEGORIES[catIndex].categoryFrame]
        local numStatInCat = 0
        for statIndex = 1, #PAPERDOLL_STATCATEGORIES[catIndex].stats do
            local stat = PAPERDOLL_STATCATEGORIES[catIndex].stats[statIndex]
            local showStat = true
            if (stat.primary) then
                local primaryStat = select(6, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")))
                if (stat.primary ~= primaryStat) then
                    showStat = false
                end
            end
            if (showStat and stat.roles) then
                local foundRole = false
                for _, statRole in pairs(stat.roles) do
                    if (role == statRole) then
                        foundRole = true
                        break
                    end
                end
                showStat = foundRole
            end

            if stat.stat == "MASTERY" and (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
                showStat = false
            end

            if (showStat) then
                statFrame = gwPaperDollGetStatListFrame(GwPaperDollStats, numShownStats)
                statFrame.stat = stat.stat
                statFrame.onEnterFunc = nil
                PAPERDOLL_STATINFO[stat.stat].updateFunc(statFrame, "player")

                gwPaperDollSetStatIcon(statFrame, stat.stat)

                statFrame:SetPoint("TOPLEFT", 5 + x, -35 + -y)
                grid = grid + 1
                x = x + 92

                if grid > 2 then
                    grid = 1
                    x = 0
                    y = y + 35
                end

                numShownStats = numShownStats + 1
            end
        end
    end
end

function gwPaperDollSetStatIcon(self, stat)
    local newTexture = "Interface\\AddOns\\GW2_UI\\textures\\character\\statsicon"
    if STATS_ICONS[stat] ~= nil then
        -- If mastery we use need to use class icon

        if stat == "MASTERY" then
            local localizedClass, englishClass, classIndex = UnitClass("player")
            gw_setClassIcon(self.icon, classIndex)
            newTexture = "Interface\\AddOns\\GW2_UI\\textures\\party\\classicons"
        else
            self.icon:SetTexCoord(STATS_ICONS[stat].l, STATS_ICONS[stat].r, STATS_ICONS[stat].t, STATS_ICONS[stat].b)
        end
    end

    if newTexture ~= self.icon:GetTexture() then
        self.icon:SetTexture(newTexture)
    end
end

local function gwPaperDollStat_OnEnter(self)
    if self.stat == "MASTERY" then
        Mastery_OnEnter(self)
        return
    end
    if (not self.tooltip) then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltip)
    if (self.tooltip2) then
        GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
    end
    GameTooltip:Show()
end
local function gwPaperDollStat_OnLeave(self)
    GameTooltip:Hide()
end
function gwPaperDollGetStatListFrame(self, i)
    if _G["GwPaperDollStat" .. i] ~= nil then
        return _G["GwPaperDollStat" .. i]
    end

    local fm = CreateFrame("Frame", "GwPaperDollStat" .. i, self, "GwPaperDollStat")
    fm.Value:SetFont(UNIT_NAME_FONT, 14)
    fm.Value:SetText(GwLocalization["CHARACTER_NOT_LOADED"])
    fm.Label:SetFont(UNIT_NAME_FONT, 1)
    fm.Label:SetTextColor(0, 0, 0, 0)

    fm:SetScript("OnEnter", gwPaperDollStat_OnEnter)
    fm:SetScript("OnLeave", gwPaperDollStat_OnLeave)

    return fm
end

function gwActionButtonGlobalStyle(self)
    self.IconBorder:SetSize(self:GetSize(), self:GetSize())
    _G[self:GetName() .. "IconTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    _G[self:GetName() .. "NormalTexture"]:SetSize(self:GetSize(), self:GetSize())
    _G[self:GetName() .. "NormalTexture"]:Hide()
    self.IconBorder:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder")

    _G[self:GetName() .. "NormalTexture"]:SetTexture(nil)
    _G[self:GetName()]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\actionbutton-pressed")
    _G[self:GetName()]:SetHighlightTexture(nil)
end
function gwPaperDollSlotButton_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local slotName = self:GetName()
    local id, _, checkRelic = GetInventorySlotInfo(strsub(slotName, 12))
    self:SetID(id)
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
    if (event == "PLAYER_EQUIPMENT_CHANGED") then
        if (self:GetID() == arg1) then
            gwPaperDollSlotButton_Update(self)
            updateBagItemList(self)
        end
    end
    if (event == "BAG_UPDATE_COOLDOWN") then
        gwPaperDollSlotButton_Update(self)
    end
end

function gwPaperDollSlotButton_OnEnter(self)
    self:RegisterEvent("MODIFIER_STATE_CHANGED")

    if (not EquipmentFlyout_SetTooltipAnchor(self)) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    end
    local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", self:GetID(), nil, true)
    if (not hasItem) then
        local text = _G[strupper(strsub(self:GetName(), 12))]
        if (self.checkRelic and UnitHasRelicSlot("player")) then
            text = RELICSLOT
        end
        GameTooltip:SetText(text)
    end
    if (InRepairMode() and repairCost and (repairCost > 0)) then
        GameTooltip:AddLine(REPAIR_COST, nil, nil, nil, true)
        SetTooltipMoney(GameTooltip, repairCost)
        GameTooltip:Show()
    else
        CursorUpdate(self)
    end
end

function gwPaperDollSlotButton_OnModifiedClick(self, button)
    if (HandleModifiedItemClick(GetInventoryItemLink("player", self:GetID()))) then
        return
    end
    if (IsModifiedClick("SOCKETITEM")) then
        SocketInventoryItem(self:GetID())
        if InCombatLockdown() then
            return
        end
        GwCharacterWindow:SetAttribute("windowPanelOpen", 0)
    end
end
function gwPaperDollSlotButton_OnClick(self, button, drag)
    MerchantFrame_ResetRefundItem()
    if (button == "LeftButton") then
        local infoType, _ = GetCursorInfo()
        if (infoType == "merchant" and MerchantFrame.extendedCost) then
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
                if (CursorHasItem()) then
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

function gwPaperDollSlotButton_Update(self)
    local slot = self:GetID()
    if savedItemSlots[slot] == nil then
        savedItemSlots[slot] = self
        self.ignoreSlotCheck:SetScript(
            "OnClick",
            function()
                if not self.ignoreSlotCheck:GetChecked() then
                    C_EquipmentSet.IgnoreSlotForSave(self:GetID())
                else
                    C_EquipmentSet.UnignoreSlotForSave(self:GetID())
                end
            end
        )
    end

    local textureName = GetInventoryItemTexture("player", slot)
    local cooldown = _G[self:GetName() .. "Cooldown"]
    if (textureName) then
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

        if (cooldown) then
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

    addToAnimation(
        name,
        0,
        1,
        GetTime(),
        1,
        function(step)
            local point, relat, relPoint, xof, yof = self:GetPoint()
            if step < 0.5 then
                step = step / 0.5
                self:SetPoint(point, relat, relPoint, startX + (-8 * step), yof)
            else
                step = (step - 0.5) / 0.5
                self:SetPoint(point, relat, relPoint, (startX - 8) + (8 * step), yof)
            end
        end,
        nil,
        function()
            if self:IsShown() then
                GwPaperDollIndicatorAnimation(self)
            end
        end
    )
end

function GwSetItemButtonQuality(button, quality, itemIDOrLink)
    if quality then
        if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
            button.IconBorder:Show()
            button.IconBorder:SetVertexColor(
                BAG_ITEM_QUALITY_COLORS[quality].r,
                BAG_ITEM_QUALITY_COLORS[quality].g,
                BAG_ITEM_QUALITY_COLORS[quality].b
            )
        else
            button.IconBorder:Hide()
        end
    else
        button.IconBorder:Hide()
    end
end

function gwCharacterPanelToggle(frame)
    GwPaperDollBagItemList:Hide()
    GwCharacterMenu:Hide()
    GwPaperDollOutfits:Hide()
    GwPaperTitles:Hide()

    GwPaperReputation:Hide()

    if frame ~= nil then
        frame:Show()
    else
        GwDressingRoom:Hide()
        return
    end

    if frame:GetName() == "GwPaperReputation" then
        GwDressingRoom:Hide()
    else
        GwDressingRoom:Show()
    end
end
local function gwPaperDollOutFitListButton_OnClick(self, button)
    if not self.saveOutfit:IsShown() then
        GwOutfitsDrawItemSetList()
        GwPaperDollOutfitsToggleIgnoredSlots(true)
        GwPaperDollOutfitsUpdateIngoredSlots(self.setID)
        self:SetHeight(80)
        self.saveOutfit:Show()
        self.deleteOutfit:Show()
        self.equipOutfit:Show()
        self.ddbg:Show()
        self.deleteOutfit:SetText(GwLocalization["CHARACTER_DELETE_OUTFIT"])
        self.saveOutfit:SetText(GwLocalization["CHARACTER_SAVE_OUTFIT"])
        self.equipOutfit:SetText(GwLocalization["CHARCTER_EQUIP_OUTFIT"])

        GwPaperDollOutfits.selectedSetID = self.setID
    else
        self.saveOutfit:Hide()
        self.deleteOutfit:Hide()
        self.equipOutfit:Hide()
        self.ddbg:Hide()
        self:SetHeight(49)
    end
end
local function gwPaperDollOutFitListButton_OnLeave(self)
    GameTooltip:Hide()
end
local function gwPaperDollOutFitListButton_Equip_OnClick(self, button)
    local selectedSetID = GwPaperDollOutfits.selectedSetID
    if (selectedSetID ~= nil) then
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)

        C_EquipmentSet.UseEquipmentSet(selectedSetID)
    end
end
local function gwPaperDollOutFitListButton_Save_OnClick(self, button)
    gwWarningPromt(
        GwLocalization["CHARACTER_OUTFITS_SAVE"] .. self:GetParent().setName .. '"?',
        function()
            C_EquipmentSet.SaveEquipmentSet(self:GetParent().setID)
            GwOutfitsDrawItemSetList()
        end
    )
end
local function gwPaperDollOutFitListButton_Delete_OnClick(self, button)
    gwWarningPromt(
        GwLocalization["CHARACTER_OUTFITS_DELETE"] .. self:GetParent().setName .. '"?',
        function()
            C_EquipmentSet.DeleteEquipmentSet(self:GetParent().setID)

            GwOutfitsDrawItemSetList()
        end
    )
end
local function getNewEquipmentSetButton(i)
    if _G["GwPaperDollOutfitsButton" .. i] ~= nil then
        return _G["GwPaperDollOutfitsButton" .. i]
    end

    local f = CreateFrame("Button", "GwPaperDollOutfitsButton" .. i, GwPaperDollOutfits, "GwPaperDollOutfitsButton")
    f:SetScript("OnClick", gwPaperDollOutFitListButton_OnClick)
    f:SetScript("OnLeave", gwPaperDollOutFitListButton_OnLeave)
    gwCharacterMenuBlank_OnLoad(f)
    f.equipOutfit:SetScript("OnClick", gwPaperDollOutFitListButton_Equip_OnClick)
    f.saveOutfit:SetScript("OnClick", gwPaperDollOutFitListButton_Save_OnClick)
    f.deleteOutfit:SetScript("OnClick", gwPaperDollOutFitListButton_Delete_OnClick)

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
    if GwPaperDollOutfits.buttons == nil then
        GwPaperDollOutfits.buttons = 0
    end

    local numSets = C_EquipmentSet.GetNumEquipmentSets()
    local numButtons = GwPaperDollOutfits.buttons

    if numSets > numButtons then
        numButtons = numSets
    end
    local textureC = 1

    local id_table = C_EquipmentSet.GetEquipmentSetIDs()
    for i = 1, numButtons do
        if numSets >= i then
            local frame = getNewEquipmentSetButton(i)

            local name, texture, setID, isEquipped, _, _, _, numLost, _ =
                C_EquipmentSet.GetEquipmentSetInfo(id_table[i])

            frame:Show()
            frame.saveOutfit:Hide()
            frame.deleteOutfit:Hide()
            frame.equipOutfit:Hide()
            frame.ddbg:Hide()
            frame:SetHeight(49)

            frame:SetScript(
                "OnEnter",
                function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetEquipmentSet(self.setID)
                    self.standardOnClick(self)
                end
            )

            frame:SetText(name)
            frame.setName = name
            frame.setID = setID

            if texture then
                frame.icon:SetTexture(texture)
            else
                frame.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end

            if textureC == 1 then
                frame:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
                textureC = 2
            else
                frame:SetNormalTexture(nil)
                textureC = 1
            end
            if isEquipped then
                frame:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
            end
            if numLost > 0 then
                --  _G[frame:GetName()..'NormalTexture']:SetVertexColor(1,0.3,0.3)
                frame:GetFontString():SetTextColor(1, 0.3, 0.3)
            else
                --_G[frame:GetName()..'NormalTexture']:SetVertexColor(1,1,1)
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
        if (ignored) then
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
    if (event == "EQUIPMENT_SWAP_FINISHED") then
        local completed, setName = ...
        if (completed) then
            PlaySound(1212) -- plays the equip sound for plate mail
            if (self:IsShown()) then
                self.selectedSetID = C_EquipmentSet.GetEquipmentSetID(setName)
                GwOutfitsDrawItemSetList()
            end
        end
    end

    if (self:IsShown()) then
        if (event == "EQUIPMENT_SETS_CHANGED") then
            GwOutfitsDrawItemSetList()
        elseif (event == "PLAYER_EQUIPMENT_CHANGED" or event == "BAG_UPDATE") then
            GwPaperDollOutfits:SetScript(
                "OnUpdate",
                function(self)
                    GwOutfitsDrawItemSetList()
                    GwPaperDollOutfits:SetScript("OnUpdate", nil)
                end
            )
        end
    end
end

local function getNewTitlesButton(i)
    if _G["GwPaperDollTitleButton" .. i] ~= nil then
        return _G["GwPaperDollTitleButton" .. i]
    end

    local f = CreateFrame("Button", "GwPaperDollTitleButton" .. i, GwPaperTitles, "GwCharacterMenuBlank")
    gwCharacterMenuBlank_OnLoad(f)

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

function GwPaperDollUpdateTitlesList()
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

function GwPaperDollTitles_OnEvent()
    GwPaperDollUpdateTitlesList()
    GwPaperDollUpdateTitlesLayout()
end

local function getNewReputationCat(i)
    if _G["GwPaperDollReputationCat" .. i] ~= nil then
        return _G["GwPaperDollReputationCat" .. i]
    end

    local f = CreateFrame("Button", "GwPaperDollReputationCat" .. i, GwPaperReputation, "GwPaperDollReputationCat")
    gwCharacterMenuBlank_OnLoad(f)
    f.StatusBar:SetMinMaxValues(0, 1)
    f.StatusBar:SetStatusBarColor(240 / 255, 240 / 255, 155 / 255)
    local BNAME = f.StatusBar:GetName()
    hooksecurefunc(
        f.StatusBar,
        "SetValue",
        function(self)
            local _, max = self:GetMinMaxValues()
            local v = self:GetValue()
            local width = math.max(1, math.min(10, 10 * ((v / max) / 0.1)))
            _G[BNAME .. "Spark"]:SetPoint("RIGHT", self, "LEFT", 201 * (v / max), 0)
            _G[BNAME .. "Spark"]:SetWidth(width)
        end
    )

    if i > 1 then
        _G["GwPaperDollReputationCat" .. i]:SetPoint("TOPLEFT", _G["GwPaperDollReputationCat" .. (i - 1)], "BOTTOMLEFT")
    else
        _G["GwPaperDollReputationCat" .. i]:SetPoint("TOPLEFT", GwPaperReputation, "TOPLEFT")
    end
    f:SetWidth(231)
    f:GetFontString():SetPoint("TOPLEFT", 10, -10)
    GwPaperReputation.buttons = GwPaperReputation.buttons + 1

    --   f:GetFontString():ClearAllPoints()
    --    f:GetFontString():SetPoint('TOP',f,'TOP',0,-20)

    return f
end

function GwUpdateSavedReputation()
    for factionIndex = GwPaperReputation.scroll, GetNumFactions() do
        savedReputation[factionIndex] = {}
        savedReputation[factionIndex].name,
            savedReputation[factionIndex].description,
            savedReputation[factionIndex].standingId,
            savedReputation[factionIndex].bottomValue,
            savedReputation[factionIndex].topValue,
            savedReputation[factionIndex].earnedValue,
            savedReputation[factionIndex].atWarWith,
            savedReputation[factionIndex].canToggleAtWar,
            savedReputation[factionIndex].isHeader,
            savedReputation[factionIndex].isCollapsed,
            savedReputation[factionIndex].hasRep,
            savedReputation[factionIndex].isWatched,
            savedReputation[factionIndex].isChild,
            savedReputation[factionIndex].factionID,
            savedReputation[factionIndex].hasBonusRepGain,
            savedReputation[factionIndex].canBeLFGBonus = GetFactionInfo(factionIndex)
    end
end

local function returnReputationData(factionIndex)
    if savedReputation[factionIndex] == nil then
        return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
    end
    return savedReputation[factionIndex].name, savedReputation[factionIndex].description, savedReputation[factionIndex].standingId, savedReputation[
        factionIndex
    ].bottomValue, savedReputation[factionIndex].topValue, savedReputation[factionIndex].earnedValue, savedReputation[
        factionIndex
    ].atWarWith, savedReputation[factionIndex].canToggleAtWar, savedReputation[factionIndex].isHeader, savedReputation[
        factionIndex
    ].isCollapsed, savedReputation[factionIndex].hasRep, savedReputation[factionIndex].isWatched, savedReputation[
        factionIndex
    ].isChild, savedReputation[factionIndex].factionID, savedReputation[factionIndex].hasBonusRepGain, savedReputation[
        factionIndex
    ].canBeLFGBonus
end

function GwPaperDollUpdateReputations()
    ExpandAllFactionHeaders()

    local headerIndex = 1
    local CurrentOwner = nil
    local cMax = 0
    local cCur = 0
    local textureC = 1

    for factionIndex = GwPaperReputation.scroll, GetNumFactions() do
        local name, _, standingId, _, _, _, _, _, isHeader, _, _, _, isChild, factionID =
            returnReputationData(factionIndex)
        local friendID = GetFriendshipReputation(factionID)
        if name ~= nil then
            cCur = cCur + standingId
            if friendID ~= nil then
                cMax = cMax + 7
            else
                cMax = cMax + 8
            end

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

                header:SetScript(
                    "OnClick",
                    function()
                        GwReputationShowReputationHeader(factionIndex)
                        GwUpdateReputationDetails()
                    end
                )

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
                    CurrentOwner.StatusBar:SetStatusBarColor(171 / 255, 37 / 255, 240 / 255)
                else
                    CurrentOwner.StatusBar:SetStatusBarColor(240 / 255, 240 / 255, 155 / 255)
                end
            end
        end
    end

    for i = headerIndex, GwPaperReputation.buttons do
        _G["GwPaperDollReputationCat" .. i]:Hide()
    end
end

function GwReputationShowReputationHeader(i)
    selectedReputationCat = i
end

local function gwReputationDetails_controls_atwar_OnEnter(self)
    self.icon:SetTexCoord(0.5, 1, 0, 0.5)
end
local function gwReputationDetails_controls_atwar_OnLeave(self)
    if not self.isActive then
        self.icon:SetTexCoord(0, 0.5, 0, 0.5)
    end
end
local function gwReputationDetails_controls_favorit_OnEnter(self)
    self.icon:SetTexCoord(0, 0.5, 0.5, 1)
end
local function gwReputationDetails_controls_favorit_OnLeave(self)
    if not self.isActive then
        self.icon:SetTexCoord(0.5, 1, 0.5, 1)
    end
end
local function gwReputationDetails_controls_OnShow(self)
    self:GetParent().details:Show()

    if self.atwar.isShowAble then
        self.atwar:Show()
    else
        self.atwar:Hide()
    end
    if self.favorit.isShowAble then
        self.favorit:Show()
    else
        self.favorit:Hide()
    end
end
local function gwReputationDetails_controls_OnHide(self)
    self:GetParent().details:Hide()
end
local function gwReputationDetails_OnClick(self, button)
    if self.details:IsShown() then
        GwDetailFaction(self.factionIndex, false)
        self:SetHeight(80)
        self.controles:Hide()
    else
        GwDetailFaction(self.factionIndex, true)
        self:SetHeight(140)
        self.controles:Show()
    end
end
local function getNewReputationDetail(i)
    if _G["GwReputationDetails" .. i] ~= nil then
        return _G["GwReputationDetails" .. i]
    end

    local f =
        CreateFrame(
        "Button",
        "GwReputationDetails" .. i,
        GwPaperReputationScrollFrame.scrollchild,
        "GwReputationDetails"
    )
    f.controles.atwar:SetScript("OnEnter", gwReputationDetails_controls_atwar_OnEnter)
    f.controles.atwar:SetScript("OnLeave", gwReputationDetails_controls_atwar_OnLeave)
    f.controles.favorit:SetScript("OnEnter", gwReputationDetails_controls_favorit_OnEnter)
    f.controles.favorit:SetScript("OnLeave", gwReputationDetails_controls_favorit_OnLeave)
    f.controles.inactive.string:SetFont(UNIT_NAME_FONT, 12)
    f.controles.inactive.string:SetText(GwLocalization["CHARACTER_REPUTATION_INACTIVE"])
    f.controles.showAsBar.string:SetFont(UNIT_NAME_FONT, 12)
    f.controles.showAsBar.string:SetText(GwLocalization["CHARACTER_REPUTATION_TRACK"])
    f.controles:SetScript("OnShow", gwReputationDetails_controls_OnShow)
    f.controles:SetScript("OnHide", gwReputationDetails_controls_OnHide)
    f.StatusBar.currentValue:SetFont(UNIT_NAME_FONT, 12)
    f.StatusBar.percentage:SetFont(UNIT_NAME_FONT, 12)
    f.StatusBar.nextValue:SetFont(UNIT_NAME_FONT, 12)

    f.StatusBar.currentValue:SetShadowColor(0, 0, 0, 1)
    f.StatusBar.percentage:SetShadowColor(0, 0, 0, 1)
    f.StatusBar.nextValue:SetShadowColor(0, 0, 0, 1)

    f.StatusBar.currentValue:SetShadowOffset(1, -1)
    f.StatusBar.percentage:SetShadowOffset(1, -1)
    f.StatusBar.nextValue:SetShadowOffset(1, -1)

    f.StatusBar:GetParent().currentValue = f.StatusBar.currentValue
    f.StatusBar:GetParent().percentage = f.StatusBar.percentage
    f.StatusBar:GetParent().nextValue = f.StatusBar.nextValue
    f.StatusBar:SetMinMaxValues(0, 1)
    f.StatusBar:SetStatusBarColor(240 / 255, 240 / 255, 155 / 255)
    local BNAME = f.StatusBar:GetName()
    hooksecurefunc(
        f.StatusBar,
        "SetValue",
        function(self)
            local _, max = self:GetMinMaxValues()
            local v = self:GetValue()
            local width = math.max(1, math.min(10, 10 * ((v / max) / 0.1)))
            _G[BNAME .. "Spark"]:SetPoint("RIGHT", self, "LEFT", self:GetWidth() * (v / max), 0)
            _G[BNAME .. "Spark"]:SetWidth(width)
        end
    )

    f.details:SetPoint("TOPLEFT", f.StatusBar, "BOTTOMLEFT", 0, -15)
    f.statusbarbg:SetPoint("TOPLEFT", f.StatusBar, "TOPLEFT", -2, 2)
    f.statusbarbg:SetPoint("BOTTOMRIGHT", f.StatusBar, "BOTTOMRIGHT", 0, -2)
    f.currentRank:SetPoint("TOPLEFT", f.StatusBar, "BOTTOMLEFT", 0, -5)
    f.nextRank:SetPoint("TOPRIGHT", f.StatusBar, "BOTTOMRIGHT", 0, -5)
    f.currentRank:SetFont(DAMAGE_TEXT_FONT, 11)
    f.currentRank:SetTextColor(0.6, 0.6, 0.6)
    f.nextRank:SetFont(DAMAGE_TEXT_FONT, 11)
    f.nextRank:SetTextColor(0.6, 0.6, 0.6)
    f.name:SetFont(DAMAGE_TEXT_FONT, 14)
    f.name:SetTextColor(1, 1, 1, 1)
    f.details:SetFont(UNIT_NAME_FONT, 12)
    f.details:SetTextColor(0.8, 0.8, 0.8, 1)
    f.details:Hide()
    f.currentRank:SetText(GwLocalization["CHARACTER_CURRENT_RANK"])
    f.nextRank:SetText(GwLocalization["CHARACTER_NEXT_RANK"])
    f:SetScript("OnClick", gwReputationDetails_OnClick)

    if i > 1 then
        _G["GwReputationDetails" .. i]:SetPoint("TOPLEFT", _G["GwReputationDetails" .. (i - 1)], "BOTTOMLEFT", 0, -1)
    else
        _G["GwReputationDetails" .. i]:SetPoint("TOPLEFT", GwPaperReputationScrollFrame.scrollchild, "TOPLEFT", 2, -10)
    end

    GwPaperReputation.detailFrames = GwPaperReputation.detailFrames + 1

    return f
end

local function SetReputationDetailFrameData(
    frame,
    factionIndex,
    savedHeaderName,
    name,
    description,
    standingId,
    bottomValue,
    topValue,
    earnedValue,
    atWarWith,
    canToggleAtWar,
    isHeader,
    isCollapsed,
    hasRep,
    isWatched,
    isChild,
    factionID,
    hasBonusRepGain,
    canBeLFGBonus)
    frame:Show()

    frame.factionIndex = factionIndex

    if expandedFactions[factionIndex] == nil then
        frame.controles:Hide()
        frame:SetHeight(80)
    else
        frame:SetHeight(140)
        frame.controles:Show()
    end

    local currentRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId)), gender)
    local nextRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId + 1)), gender)
    local friendID,
        friendRep,
        friendMaxRep,
        friendName,
        friendText,
        friendTexture,
        friendTextLevel,
        friendThreshold,
        nextFriendThreshold = GetFriendshipReputation(factionID)

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

    frame.controles.inactive:SetScript(
        "OnClick",
        function()
            if IsFactionInactive(factionIndex) then
                SetFactionActive(factionIndex)
            else
                SetFactionInactive(factionIndex)
            end
            GwUpdateSavedReputation()
            GwPaperDollUpdateReputations()
            GwUpdateReputationDisplayOldData()
        end
    )

    if canBeLFGBonus then
        frame.controles.favorit.isShowAble = true
        frame.controles.favorit:SetScript(
            "OnClick",
            function()
                ReputationBar_SetLFBonus(factionID)
                GwUpdateSavedReputation()
                GwUpdateReputationDisplayOldData()
            end
        )
    else
        frame.controles.favorit.isShowAble = false
    end

    frame.controles.atwar:SetScript(
        "OnClick",
        function()
            FactionToggleAtWar(factionIndex)
            if canToggleAtWar then
                GwUpdateSavedReputation()
                GwUpdateReputationDisplayOldData()
            end
        end
    )

    frame.controles.showAsBar:SetScript(
        "OnClick",
        function()
            if isWatched then
                SetWatchedFactionIndex(0)
            else
                SetWatchedFactionIndex(factionIndex)
            end
            GwUpdateSavedReputation()
            GwUpdateReputationDisplayOldData()
        end
    )

    SetFactionInactive(GetSelectedFaction())

    if factionID and C_Reputation.IsFactionParagon(factionID) then
        local currentValue, maxValueParagon, _, hasReward = C_Reputation.GetFactionParagonInfo(factionID)

        if currentValue > 10000 then
            repeat
                currentValue = currentValue - 10000
            until (currentValue < 10000)
        end

        frame.currentRank:SetText(currentRank)
        frame.nextRank:SetText(GwLocalization["CHARACTER_PARAGON"])

        frame.currentValue:SetText(comma_value(currentValue))
        frame.nextValue:SetText(comma_value(maxValueParagon))

        local percent = math.floor(round(((currentValue - 0) / (maxValueParagon - 0)) * 100), 0)
        frame.percentage:SetText((math.floor(round(((currentValue - 0) / (maxValueParagon - 0)) * 100), 0)) .. "%")

        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.StatusBar:SetValue((currentValue - 0) / (maxValueParagon - 0))

        frame.background2:SetVertexColor(
            GW_FACTION_BAR_COLORS[9].r,
            GW_FACTION_BAR_COLORS[9].g,
            GW_FACTION_BAR_COLORS[9].b
        )
        frame.StatusBar:SetStatusBarColor(
            GW_FACTION_BAR_COLORS[9].r,
            GW_FACTION_BAR_COLORS[9].g,
            GW_FACTION_BAR_COLORS[9].b
        )
    elseif (friendID ~= nil) then
        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.currentRank:SetText(friendTextLevel)
        frame.nextRank:SetText()

        frame.background2:SetVertexColor(
            GW_FACTION_BAR_COLORS[5].r,
            GW_FACTION_BAR_COLORS[5].g,
            GW_FACTION_BAR_COLORS[5].b
        )
        frame.StatusBar:SetStatusBarColor(
            GW_FACTION_BAR_COLORS[5].r,
            GW_FACTION_BAR_COLORS[5].g,
            GW_FACTION_BAR_COLORS[5].b
        )

        if (nextFriendThreshold) then
            frame.currentValue:SetText(comma_value(friendRep - friendThreshold))
            frame.nextValue:SetText(comma_value(nextFriendThreshold - friendThreshold))

            local percent =
                math.floor(round(((friendRep - friendThreshold) / (nextFriendThreshold - friendThreshold)) * 100), 0)
            if percent == -1 then
                frame.percentage:SetText("0%")
            else
                frame.percentage:SetText(
                    (math.floor(
                        round(((friendRep - friendThreshold) / (nextFriendThreshold - friendThreshold)) * 100),
                        0
                    )) .. "%"
                )
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
        frame.currentValue:SetText(comma_value(earnedValue - bottomValue))
        local percent = math.floor(round(((earnedValue - bottomValue) / (topValue - bottomValue)) * 100), 0)
        if percent == -1 then
            frame.percentage:SetText("0%")
        else
            frame.percentage:SetText(
                (math.floor(round(((earnedValue - bottomValue) / (topValue - bottomValue)) * 100), 0)) .. "%"
            )
        end

        frame.nextValue:SetText(comma_value(topValue - bottomValue))

        frame.StatusBar:SetMinMaxValues(0, 1)
        frame.StatusBar:SetValue((earnedValue - bottomValue) / (topValue - bottomValue))

        if currentRank == nextRank and earnedValue - bottomValue == 0 then
            frame.percentage:SetText("100%")
            frame.StatusBar:SetValue(1)
            frame.nextValue:SetText()
            frame.currentValue:SetText()
        end

        frame.background2:SetVertexColor(
            GW_FACTION_BAR_COLORS[standingId].r,
            GW_FACTION_BAR_COLORS[standingId].g,
            GW_FACTION_BAR_COLORS[standingId].b
        )
        frame.StatusBar:SetStatusBarColor(
            GW_FACTION_BAR_COLORS[standingId].r,
            GW_FACTION_BAR_COLORS[standingId].g,
            GW_FACTION_BAR_COLORS[standingId].b
        )
    end
end

function GwUpdateReputationDetails()
    local buttonIndex = 1
    local gender = UnitSex("player")
    local savedHeaderName = ""
    local savedHeight = 0
    local textureC = 1

    for factionIndex = selectedReputationCat + 1, GetNumFactions() do
        local name,
            description,
            standingId,
            bottomValue,
            topValue,
            earnedValue,
            atWarWith,
            canToggleAtWar,
            isHeader,
            isCollapsed,
            hasRep,
            isWatched,
            isChild,
            factionID,
            hasBonusRepGain,
            canBeLFGBonus = returnReputationData(factionIndex)
        if name ~= nil then
            if isHeader and not isChild then
                break
            end

            if isHeader and isChild then
                savedHeaderName = " |cFFa0a0a0" .. name .. "|r"
            end

            if not isChild then
                savedHeaderName = ""
            end

            local frame = getNewReputationDetail(buttonIndex)

            SetReputationDetailFrameData(
                frame,
                factionIndex,
                savedHeaderName,
                name,
                description,
                standingId,
                bottomValue,
                topValue,
                earnedValue,
                atWarWith,
                canToggleAtWar,
                isHeader,
                isCollapsed,
                hasRep,
                isWatched,
                isChild,
                factionID,
                hasBonusRepGain,
                canBeLFGBonus
            )

            savedHeight = savedHeight + frame:GetHeight()

            buttonIndex = buttonIndex + 1
        end
    end

    for i = buttonIndex, GwPaperReputation.detailFrames do
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
        local name,
            description,
            standingId,
            bottomValue,
            topValue,
            earnedValue,
            atWarWith,
            canToggleAtWar,
            isHeader,
            isCollapsed,
            hasRep,
            isWatched,
            isChild,
            factionID,
            hasBonusRepGain,
            canBeLFGBonus = returnReputationData(factionIndex)

        local lower1 = string.lower(name)
        local lower2 = string.lower(s)

        local show = true

        if isHeader then
            if not isChild then
                show = false
            end
        end

        if (name ~= nil and GwReputationSearch(lower1, lower2) ~= nil) and show then
            local frame = getNewReputationDetail(buttonIndex)

            SetReputationDetailFrameData(
                frame,
                factionIndex,
                savedHeaderName,
                name,
                description,
                standingId,
                bottomValue,
                topValue,
                earnedValue,
                atWarWith,
                canToggleAtWar,
                isHeader,
                isCollapsed,
                hasRep,
                isWatched,
                isChild,
                factionID,
                hasBonusRepGain,
                canBeLFGBonus
            )

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

function gw_register_character_window()
    CreateFrame("Frame", "GwCharacterWindowContainer", GwCharacterWindow, "GwCharacterWindowContainer")

    local fmGDR = CreateFrame("Button", "GwDressingRoom", GwCharacterWindowContainer, "GwDressingRoom")
    local fmGDRG = GwDressingRoomGear
    local fmPD3M = PaperDoll3dModel
    local fmGPDS = GwPaperDollStats
    for i, gear in ipairs(
        {
            "head",
            "shoulder",
            "wrists",
            "hands",
            "chest",
            "waist",
            "legs",
            "feet",
            "weapon",
            "offhand",
            "tabard",
            "shirt",
            "trinket1",
            "trinket2",
            "finger1",
            "finger2",
            "neck",
            "back"
        }
    ) do
        local fm = fmGDRG[gear]
        fm:SetScript("OnShow", gwPaperDollSlotButton_OnShow)
        fm:SetScript("OnHide", gwPaperDollSlotButton_OnHide)
        fm:SetScript("OnEvent", gwPaperDollSlotButton_OnEvent)
        fm:SetScript("OnClick", gwPaperDollSlotButton_OnClickRouter)
        fm:SetScript("OnDragStart", gwPaperDollSlotButton_OnDragStart)
        fm:SetScript("OnReceiveDrag", gwPaperDollSlotButton_OnReceiveDrag)
        fm:SetScript("OnEnter", gwPaperDollSlotButton_OnEnter)
        fm:SetScript("OnLeave", gwPaperDollSlotButton_OnLeave)
        gwPaperDollSlotButton_OnLoad(fm)
    end
    fmGDRG.head.BACKGROUND:SetTexCoord(0, 0.25, 0, 0.25)
    fmGDRG.shoulder.BACKGROUND:SetTexCoord(0.5, 0.75, 0.5, 0.75)
    fmGDRG.back.BACKGROUND:SetTexCoord(0.75, 1, 0, 0.25)
    fmGDRG.wrists.BACKGROUND:SetTexCoord(0.75, 1, 0.25, 0.5)
    fmGDRG.hands.BACKGROUND:SetTexCoord(0, 0.25, 0.75, 1)
    fmGDRG.chest.BACKGROUND:SetTexCoord(0.75, 1, 0.5, 0.75)
    fmGDRG.waist.BACKGROUND:SetTexCoord(0.25, 0.5, 0.5, 0.75)
    fmGDRG.legs.BACKGROUND:SetTexCoord(0, 0.25, 0.5, 0.75)
    fmGDRG.feet.BACKGROUND:SetTexCoord(0.5, 0.75, 0.25, 0.5)
    fmGDRG.weapon.BACKGROUND:SetTexCoord(0.25, 0.5, 0.25, 0.5)
    fmGDRG.offhand.BACKGROUND:SetTexCoord(0, 0.25, 0.25, 0.5)
    fmGDRG.finger1.BACKGROUND:SetTexCoord(0.5, 0.75, 0, 0.25)
    fmGDRG.finger2.BACKGROUND:SetTexCoord(0.5, 0.75, 0, 0.25)
    fmGDRG.neck.BACKGROUND:SetTexCoord(0.25, 0.5, 0, 0.25)
    fmGDRG.trinket1.BACKGROUND:SetTexCoord(0.5, 0.75, 0.75, 1)
    fmGDRG.trinket2.BACKGROUND:SetTexCoord(0.5, 0.75, 0.75, 1)
    fmGDRG.shirt.BACKGROUND:SetTexCoord(0.75, 1, 0.5, 0.75)
    fmGDRG.tabard.BACKGROUND:SetTexCoord(0.25, 0.5, 0.75, 1)

    fmPD3M:SetUnit("player")
    fmPD3M:SetPosition(0.8, 0, 0)

    local _, raceEn = UnitRace("Player")
    if raceEn == "Human" then
        fmPD3M:SetPosition(0.4, 0, -0.05)
    elseif raceEn == "Worgen" then
        fmPD3M:SetPosition(0.1, 0, -0.1)
    elseif raceEn == "Tauren" then
        fmPD3M:SetPosition(0.6, 0, 0)
    elseif raceEn == "BloodElf" then
        fmPD3M:SetPosition(0.6, 0, -0.1)
    elseif raceEn == "Draenei" then
        fmPD3M:SetPosition(0.3, 0, -0.15)
    elseif raceEn == "NightElf" then
        fmPD3M:SetPosition(0.3, 0, -0.15)
    elseif raceEn == "Pandaren" then
        fmPD3M:SetPosition(0.3, 0, -0.15)
    elseif raceEn == "Goblin" then
        fmPD3M:SetPosition(0.2, 0, -0.05)
    elseif raceEn == "Troll" then
        fmPD3M:SetPosition(0.2, 0, -0.05)
    elseif raceEn == "Scourge" then
        fmPD3M:SetPosition(0.2, 0, -0.05)
    elseif raceEn == "Dwarf" then
        fmPD3M:SetPosition(0.3, 0, 0)
    elseif raceEn == "Gnome" then
        fmPD3M:SetPosition(0.2, 0, -0.05)
    elseif raceEn == "Orc" then
        fmPD3M:SetPosition(0.1, 0, -0.15)
    end
    fmPD3M:SetRotation(-0.15)
    Model_OnLoad(fmPD3M, 4, 0, -0.1, CharacterModelFrame_OnMouseUp)
    fmPD3M:HookScript("OnMouseDown", GwPaperDollResetBagInventory)

    fmGPDS.header:SetFont(DAMAGE_TEXT_FONT, 14)
    fmGPDS.header:SetText(GwLocalization["CHARACTER_ATTRIBUTES"])
    fmGPDS:SetScript("OnEvent", gwPaperDollStats_OnEvent)
    fmGPDS:RegisterEvent("PLAYER_ENTERING_WORLD")
    fmGPDS:RegisterEvent("CHARACTER_POINTS_CHANGED")
    fmGPDS:RegisterEvent("UNIT_MODEL_CHANGED")
    fmGPDS:RegisterEvent("UNIT_LEVEL")
    fmGPDS:RegisterEvent("UNIT_STATS")
    fmGPDS:RegisterEvent("UNIT_RANGEDDAMAGE")
    fmGPDS:RegisterEvent("UNIT_ATTACK_POWER")
    fmGPDS:RegisterEvent("UNIT_RANGED_ATTACK_POWER")
    fmGPDS:RegisterEvent("UNIT_ATTACK")
    fmGPDS:RegisterEvent("UNIT_SPELL_HASTE")
    fmGPDS:RegisterEvent("UNIT_RESISTANCES")
    fmGPDS:RegisterEvent("PLAYER_GUILD_UPDATE")
    fmGPDS:RegisterEvent("SKILL_LINES_CHANGED")
    fmGPDS:RegisterEvent("COMBAT_RATING_UPDATE")
    fmGPDS:RegisterEvent("MASTERY_UPDATE")
    fmGPDS:RegisterEvent("SPEED_UPDATE")
    fmGPDS:RegisterEvent("LIFESTEAL_UPDATE")
    fmGPDS:RegisterEvent("AVOIDANCE_UPDATE")
    fmGPDS:RegisterEvent("KNOWN_TITLES_UPDATE")
    fmGPDS:RegisterEvent("UNIT_NAME_UPDATE")
    fmGPDS:RegisterEvent("PLAYER_TALENT_UPDATE")
    fmGPDS:RegisterEvent("BAG_UPDATE")
    fmGPDS:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    fmGPDS:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    fmGPDS:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
    fmGPDS:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
    fmGPDS:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    fmGPDS:RegisterUnitEvent("UNIT_DAMAGE", "player")
    fmGPDS:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player")
    fmGPDS:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    fmGPDS:RegisterUnitEvent("UNIT_AURA", "player")
    fmGPDS:RegisterEvent("SPELL_POWER_CHANGED")
    fmGPDS:RegisterEvent("CHARACTER_ITEM_FIXUP_NOTIFICATION")
    fmGPDS:RegisterEvent("UNIT_NAME_UPDATE")

    fmGDR.characterName:SetFont(UNIT_NAME_FONT, 14)
    fmGDR.characterData:SetFont(UNIT_NAME_FONT, 12)
    fmGDR.itemLevel:SetFont(UNIT_NAME_FONT, 24)
    local _, _, classIndex = UnitClass("player")
    gw_setClassIcon(fmGDR.classIcon, classIndex)
    fmGDR.classIcon:SetVertexColor(
        GW_CLASS_COLORS_RAIDFRAME[classIndex].r,
        GW_CLASS_COLORS_RAIDFRAME[classIndex].g,
        GW_CLASS_COLORS_RAIDFRAME[classIndex].b,
        1
    )
    fmGDR:SetScript("OnClick", GwPaperDollResetBagInventory)

    local fmGCM = CreateFrame("Frame", "GwCharacterMenu", GwCharacterWindowContainer, "GwCharacterMenu")
    local fnGCM_ToggleEquipment = function()
        gwCharacterPanelToggle(GwPaperDollBagItemList)
    end
    local fnGCM_ToggleOutfits = function()
        gwCharacterPanelToggle(GwPaperDollOutfits)
    end
    local fnGCM_ToggleTitles = function()
        gwCharacterPanelToggle(GwPaperTitles)
    end
    local fnGCM_ToggleReputation = function()
        gwCharacterPanelToggle(GwPaperReputation)
    end
    fmGCM.equipmentMenu:SetScript("OnClick", fnGCM_ToggleEquipment)
    fmGCM.equipmentMenu:SetText(GwLocalization["CHARACTER_MENU_EQUIPMENT"])
    fmGCM.outfitsMenu:SetScript("OnClick", fnGCM_ToggleOutfits)
    fmGCM.outfitsMenu:SetText(GwLocalization["CHARACTER_MENU_OUTFITS"])
    fmGCM.titlesMenu:SetScript("OnClick", fnGCM_ToggleTitles)
    fmGCM.titlesMenu:SetText(GwLocalization["CHARACTER_MENU_TITLES"])
    fmGCM.reputationMenu:SetScript("OnClick", fnGCM_ToggleReputation)
    fmGCM.reputationMenu:SetText(GwLocalization["CHARACTER_MENU_REPS"])
    local fnGCMMenu_OnLoad1 = function(self)
        self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
        self:GetFontString():SetTextColor(1, 1, 1, 1)
        self:GetFontString():SetShadowColor(0, 0, 0, 0)
        self:GetFontString():SetShadowOffset(1, -1)
        self:GetFontString():SetFont(DAMAGE_TEXT_FONT, 14)
        self:GetFontString():SetJustifyH("LEFT")
        self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
    end
    local fnGCMMenu_OnLoad2 = function(self)
        self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
        self:SetNormalTexture(nil)
        self:GetFontString():SetTextColor(1, 1, 1, 1)
        self:GetFontString():SetShadowColor(0, 0, 0, 0)
        self:GetFontString():SetShadowOffset(1, -1)
        self:GetFontString():SetFont(DAMAGE_TEXT_FONT, 14)
        self:GetFontString():SetJustifyH("LEFT")
        self:GetFontString():SetPoint("LEFT", self, "LEFT", 5, 0)
    end
    fnGCMMenu_OnLoad1(fmGCM.equipmentMenu)
    fnGCMMenu_OnLoad1(fmGCM.titlesMenu)
    fnGCMMenu_OnLoad2(fmGCM.outfitsMenu)
    fnGCMMenu_OnLoad2(fmGCM.reputationMenu)

    local fmGPDBIL =
        CreateFrame("Frame", "GwPaperDollBagItemList", GwCharacterWindowContainer, "GwPaperDollBagItemList")
    fmGPDBIL:SetScript("OnEvent", GwupdateBagItemListAll)
    fmGPDBIL:SetScript("OnHide", GwPaperDollResetBagInventory)
    fmGPDBIL:SetScript("OnShow", GwupdateBagItemListAll)
    fmGPDBIL:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    GwupdateBagItemListAll()
    fmGPDBIL.backButton:SetText(GwLocalization["CHARACTER_MENU_EQUIPMENT_RETURN"])
    gwCharacterMenuButtonBack_OnLoad(fmGPDBIL.backButton)
    fmGPDBIL.backButton:SetScript("OnClick", gwCharacterMenuButtonBack_OnClick)

    local fmGPDO = CreateFrame("Frame", "GwPaperDollOutfits", GwCharacterWindowContainer, "GwPaperDollOutfits")
    local fnGPDO_newOutfit_OnClick = function(self, button)
        self.oldParent = GearManagerDialogPopup:GetParent()
        GearManagerDialogPopup:Show()
        GearManagerDialogPopup:SetParent(GwDressingRoom)
        GearManagerDialogPopup:SetPoint("TOPLEFT", GwDressingRoom, "TOPRIGHT")
        PaperDollEquipmentManagerPane.selectedSetID = nil
        PaperDollFrame_ClearIgnoredSlots()
        PaperDollFrame_IgnoreSlot(4)
        PaperDollFrame_IgnoreSlot(19)
    end
    fmGPDO.newOutfit:SetText(GwLocalization["CHARACTER_OUTFIT_NEW"])
    fmGPDO.newOutfit:SetScript("OnClick", fnGPDO_newOutfit_OnClick)
    fmGPDO.backButton:SetText(GwLocalization["CHARACTER_MENU_OUTFITS_RETURN"])
    gwCharacterMenuButtonBack_OnLoad(fmGPDO.backButton)
    fmGPDO.backButton:SetScript("OnClick", gwCharacterMenuButtonBack_OnClick)

    local fmGPT = CreateFrame("Frame", "GwPaperTitles", GwCharacterWindowContainer, "GwPaperTitles")
    fmGPT.buttons = 0
    fmGPT.scroll = 1
    fmGPT:EnableMouseWheel(true)
    fmGPT:RegisterEvent("KNOWN_TITLES_UPDATE")
    fmGPT:RegisterEvent("UNIT_NAME_UPDATE")
    fmGPT:SetScript("OnEvent", GwPaperDollTitles_OnEvent)
    local fnGPT_OnMouseWheel = function(self, delta)
        self.scroll = math.max(1, self.scroll + -delta)
        GwPaperDollUpdateTitlesLayout()
    end
    fmGPT:SetScript("OnMouseWheel", fnGPT_OnMouseWheel)
    fmGPT.backButton:SetText(GwLocalization["CHARACTER_MENU_TITLES_RETURN"])
    gwCharacterMenuButtonBack_OnLoad(fmGPT.backButton)
    fmGPT.backButton:SetScript("OnClick", gwCharacterMenuButtonBack_OnClick)

    local fmGPR = CreateFrame("Frame", "GwPaperReputation", GwCharacterWindowContainer, "GwPaperReputation")
    fmGPR.detailFrames = 0
    fmGPR.buttons = 0
    fmGPR.scroll = 1
    fmGPR:EnableMouseWheel(true)
    fmGPR:RegisterEvent("UPDATE_FACTION")
    local fnGPR_OnEvent = function(self, event)
        GwUpdateSavedReputation()
        if GwPaperReputation:IsShown() then
            GwUpdateReputationDisplayOldData()
        end
    end
    fmGPR:SetScript("OnEvent", fnGPR_OnEvent)
    local fnGPR_OnMouseWheel = function(self, delta)
        self.scroll = math.max(1, self.scroll + -delta)
        GwPaperDollUpdateReputations()
    end
    fmGPR:SetScript("OnMouseWheel", fnGPR_OnMouseWheel)
    fmGPR.backButton:SetText(GwLocalization["CHARACTER_MENU_REPS_RETURN"])
    gwCharacterMenuButtonBack_OnLoad(fmGPR.backButton)
    fmGPR.backButton:SetScript("OnClick", gwCharacterMenuButtonBack_OnClick)
    fmGPR.input:SetText(GwLocalization["CHARACTER_REP_SEARCH"])
    fmGPR.input:SetScript("OnEnterPressed", nil)
    local fnGPR_input_OnTextChanged = function(self)
        local text = self:GetText()
        if text == GwLocalization["CHARACTER_REP_SEARCH"] or text == "" then
            GwUpdateReputationDetails()
            return
        end
        GwUpdateReputationDetailsSearch(text)
    end
    fmGPR.input:SetScript("OnTextChanged", fnGPR_input_OnTextChanged)
    local fnGPR_input_OnEscapePressed = function(self)
        self:ClearFocus()
        self:SetText(GwLocalization["CHARACTER_REP_SEARCH"])
    end
    fmGPR.input:SetScript("OnEscapePressed", fnGPR_input_OnEscapePressed)
    local fnGPR_input_OnEditFocusGained = function(self)
        if self:GetText() == GwLocalization["CHARACTER_REP_SEARCH"] then
            self:SetText("")
        end
    end
    fmGPR.input:SetScript("OnEditFocusGained", fnGPR_input_OnEditFocusGained)
    local fnGPR_input_OnEditFocusLost = function(self)
        if self:GetText() == "" then
            self:SetText(GwLocalization["CHARACTER_REP_SEARCH"])
        end
    end
    fmGPR.input:SetScript("OnEditFocusLost", fnGPR_input_OnEditFocusLost)
    local fnGPRSF_OnMouseWheel = function(self, delta)
        delta = -delta * 15
        local s = math.max(0, self:GetVerticalScroll() + delta)
        self.slider:SetValue(s)
        self:SetVerticalScroll(s)
    end
    GwPaperReputationScrollFrame:SetScript("OnMouseWheel", fnGPRSF_OnMouseWheel)
    GwPaperReputationScrollFrame.slider:SetMinMaxValues(0, 608)
    local fnGPRSF_slider_OnValueChanged = function(self, value)
        self:GetParent():SetVerticalScroll(value)
    end
    GwPaperReputationScrollFrame.slider:SetScript("OnValueChanged", fnGPRSF_slider_OnValueChanged)
    GwPaperReputationScrollFrame.slider:SetValue(1)

    local fmGPDSI =
        CreateFrame("Frame", "GwPaperDollSelectedIndicator", GwCharacterWindowContainer, "GwPaperDollSelectedIndicator")
    fmGPDSI:SetScript("OnShow", GwPaperDollIndicatorAnimation)

    GwPaperDollOutfits:SetScript("OnShow", GwOutfitsDrawItemSetList)
    GwPaperDollOutfits:SetScript(
        "OnHide",
        function()
            GwPaperDollOutfitsToggleIgnoredSlots(false)
        end
    )
    GwOutfitsDrawItemSetList()

    GwPaperDollUpdateTitlesList()
    GwPaperDollUpdateTitlesLayout()

    GwPaperTitles:HookScript(
        "OnShow",
        function()
            GwPaperDollUpdateTitlesList()
            GwPaperDollUpdateTitlesLayout()
        end
    )

    hooksecurefunc("GearManagerDialogPopupOkay_OnClick", GwOutfitsDrawItemSetList)
    GearManagerDialogPopup:SetScript(
        "OnShow",
        function(self)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
            self.name = nil
            self.isEdit = false
            RecalculateGearManagerDialogPopup()
            RefreshEquipmentSetIconInfo()
        end
    )

    GwUpdateSavedReputation()
    GwPaperReputationScrollFrame:SetScrollChild(GwPaperReputationScrollFrame.scrollchild)
    GwPaperDollUpdateReputations()

    CharacterFrame:SetScript(
        "OnShow",
        function()
            HideUIPanel(CharacterFrame)
        end
    )

    CharacterFrame:UnregisterAllEvents()

    hooksecurefunc("ToggleCharacter", GwToggleCharacter)

    gwPaperDollUpdateStats()

    GwUpdateReputationDetails()

    GwCharacterWindowContainer:HookScript(
        "OnHide",
        function()
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
        end
    )
    GwCharacterWindowContainer:HookScript(
        "OnShow",
        function()
            GwCharacterWindow.windowIcon:SetTexture(
                "Interface\\AddOns\\GW2_UI\\textures\\character\\character-window-icon"
            )
            GwCharacterWindow.WindowHeader:SetText(GwLocalization["CHARACTER_HEADER"])
            if CHARACTER_PANEL_OPEN == nil then
                gwCharacterPanelToggle(GwCharacterMenu)
                PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
            end
        end
    )

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
    local CHARACTERFRAME_DEFAULTFRAMES = {}

    CHARACTERFRAME_DEFAULTFRAMES["PaperDollFrame"] = GwCharacterMenu
    CHARACTERFRAME_DEFAULTFRAMES["ReputationFrame"] = GwPaperReputation
    CHARACTERFRAME_DEFAULTFRAMES["TokenFrame"] = GwCharacterMenu

    if CHARACTERFRAME_DEFAULTFRAMES[tab] ~= nil and CHARACTER_PANEL_OPEN ~= tab then
        gwCharacterPanelToggle(CHARACTERFRAME_DEFAULTFRAMES[tab])
        CHARACTER_PANEL_OPEN = tab
        return
    end

    if GwCharacterWindow:IsShown() then
        if not InCombatLockdown() then
            GwCharacterWindow:SetAttribute("windowPanelOpen", 0)
        end

        CHARACTER_PANEL_OPEN = nil
        return
    end
end
