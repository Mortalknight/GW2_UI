local _, GW = ...
GW.char_equipset_SavedItems = {}
local SavedItemSlots = GW.char_equipset_SavedItems
local CLASS_COLORS_RAIDFRAME = GW.CLASS_COLORS_RAIDFRAME
local SetClassIcon = GW.SetClassIcon
local AddToAnimation = GW.AddToAnimation

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

-- forward function defs
local getBagSlotFrame

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

local EquipSlotList = {}
local bagItemList = {}
local numBagSlotFrames = 0
local selectedInventorySlot = nil

local function setItemButtonQuality(button, quality, itemIDOrLink)
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
GW.AddForProfiling("paperdoll_equipment", "setItemButtonQuality", setItemButtonQuality)

local function setItemLevel(button, quality, itemLink)
    button.itemlevel:SetFont(UNIT_NAME_FONT, 12, "THINOUTLINED")
    if quality then
        if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
            button.itemlevel:SetTextColor(
                BAG_ITEM_QUALITY_COLORS[quality].r,
                BAG_ITEM_QUALITY_COLORS[quality].g,
                BAG_ITEM_QUALITY_COLORS[quality].b,
                1
            )
        end
        local lvl = GW.GetRealItemLevel(itemLink)
        button.itemlevel:SetText(lvl)
    else
        button.itemlevel:SetText("")
    end
end
GW.AddForProfiling("paperdoll_equipment", "setItemLevel", setItemLevel)

local function updateBagItemButton(button)
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

        --setItemButtonQuality(button, quality, id)
    end
    
end
GW.AddForProfiling("paperdoll_equipment", "updateBagItemButton", updateBagItemButton)

local function updateBagItemList(itemButton)
    local id = itemButton.id or itemButton:GetID()
    if selectedInventorySlot ~= id then
        return
    end

    wipe(bagItemList)

    GetInventoryItemsForSlot(id, bagItemList)

    local gridIndex = 1
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
GW.AddForProfiling("paperdoll_equipment", "updateBagItemList", updateBagItemList)

local function actionButtonGlobalStyle(self)
    self.IconBorder:SetSize(self:GetSize(), self:GetSize())
    _G[self:GetName() .. "IconTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    _G[self:GetName() .. "NormalTexture"]:SetSize(self:GetSize(), self:GetSize())
    _G[self:GetName() .. "NormalTexture"]:Hide()
    self.IconBorder:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder")

    _G[self:GetName() .. "NormalTexture"]:SetTexture(nil)
    _G[self:GetName()]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\actionbutton-pressed")
    _G[self:GetName()]:SetHighlightTexture(nil)
end
GW.AddForProfiling("paperdoll_equipment", "actionButtonGlobalStyle", actionButtonGlobalStyle)

local function itemSlot_OnModifiedClick(self, button)
    if (IsModifiedClick("EXPANDITEM")) then
        local itemLocation = ItemLocation:CreateFromEquipmentSlot(self:GetID())
        if C_Item.DoesItemExist(itemLocation) then
            if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
                if C_Item.CanViewItemPowers(itemLocation) then
                    OpenAzeriteEmpoweredItemUIFromItemLocation(itemLocation)
                    GwCharacterWindow:SetAttribute("windowpanelopen", nil)
                else
                    UIErrorsFrame:AddExternalErrorMessage(AZERITE_PREVIEW_UNAVAILABLE_FOR_CLASS)
                end
                return
            end

            local heartItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
			if heartItemLocation and heartItemLocation:IsEqualTo(itemLocation) then
                OpenAzeriteEssenceUIFromItemLocation(itemLocation)
                GwCharacterWindow:SetAttribute("windowpanelopen", nil)
				return
			end

            SocketInventoryItem(self:GetID())
        end
        GwCharacterWindow:SetAttribute("windowpanelopen", nil)
        return
    end
    if (HandleModifiedItemClick(GetInventoryItemLink("player", self:GetID()))) then
        GwCharacterWindow:SetAttribute("windowpanelopen", nil)
        return
    end
end
GW.AddForProfiling("paperdoll_equipment", "itemSlot_OnModifiedClick", itemSlot_OnModifiedClick)

local function itemSlot_OnClick(self, button, drag)
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
                                local _, _ = GetItemInfo(id)
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
                            local _, _, quality, _ = GetItemInfo(itemid)
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
GW.AddForProfiling("paperdoll_equipment", "itemSlot_OnClick", itemSlot_OnClick)

local function itemSlot_OnClickRouter(self, button)
    if (IsModifiedClick()) then
        itemSlot_OnModifiedClick(self, button)
    else
        itemSlot_OnClick(self, button)
    end
end
GW.AddForProfiling("paperdoll_equipment", "itemSlot_OnClickRouter", itemSlot_OnClickRouter)

local function itemSlot_OnDragStart(self)
    itemSlot_OnClick(self, "LeftButton", true)
end
GW.AddForProfiling("paperdoll_equipment", "itemSlot_OnDragStart", itemSlot_OnDragStart)

local function itemSlot_OnReceiveDrag(self)
    itemSlot_OnClick(self, "LeftButton", true)
end
GW.AddForProfiling("paperdoll_equipment", "itemSlot_OnReceiveDrag", itemSlot_OnReceiveDrag)

local function bagSlot_OnEnter(self)
    self:SetScript("OnUpdate", self.UpdateTooltip)
    GameTooltip:Show()
end
GW.AddForProfiling("paperdoll_equipment", "bagSlot_OnEnter", bagSlot_OnEnter)

local function bagSlot_OnLeave(self)
    self:SetScript("OnUpdate", nil)
    GameTooltip_Hide()
end
GW.AddForProfiling("paperdoll_equipment", "bagSlot_OnLeave", bagSlot_OnLeave)

local function bagSlot_OnClick(self)
    if (self.location) then
        if (UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[self.itemSlot]) then
            UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
            return
        end
        local action = EquipmentManager_EquipItemByLocation(self.location, self.itemSlot)
        EquipmentManager_RunAction(action)
    end
end
GW.AddForProfiling("paperdoll_equipment", "bagSlot_OnClick", bagSlot_OnClick)

local function itemSlot_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local slotName = self:GetName()
    local id, _, checkRelic = GetInventorySlotInfo(strsub(slotName, 12))
    self:SetID(id)
    EquipSlotList[#EquipSlotList + 1] = id
    self.checkRelic = checkRelic

    actionButtonGlobalStyle(self)
end
GW.AddForProfiling("paperdoll_equipment", "itemSlot_OnLoad", itemSlot_OnLoad)

local function updateItemSlot(self)
    local slot = self:GetID()
    if SavedItemSlots[slot] == nil then
        SavedItemSlots[slot] = self
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
        self.hasItem = false
    end

    local quality = GetInventoryItemQuality("player", slot)
    setItemButtonQuality(self, quality, GetInventoryItemID("player", slot))
    setItemLevel(self, quality, GetInventoryItemLink("player", slot))

    if self.HasPaperDollAzeriteItemOverlay then
        self:SetAzeriteItem(self.hasItem and ItemLocation:CreateFromEquipmentSlot(slot) or nil)
        if slot ~= 2 then
            self.AzeriteTexture:SetSize(68, 56) -- equip slot; default is 57,46
        else
            self.AzeriteTexture:SetSize(50, 48) -- neck slot; default is 50,44
        end
    end
end
GW.AddForProfiling("paperdoll_equipment", "updateItemSlot", updateItemSlot)

local function itemSlot_OnShow(self)
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self:RegisterEvent("MERCHANT_UPDATE")
    self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    self:RegisterEvent("ITEM_LOCK_CHANGED")
    self:RegisterEvent("CURSOR_UPDATE")
    self:RegisterEvent("UPDATE_INVENTORY_ALERTS")
    updateItemSlot(self)
end
GW.AddForProfiling("paperdoll_equipment", "itemSlot_OnShow", itemSlot_OnShow)

local function itemSlot_OnHide(self)
    self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self:UnregisterEvent("MERCHANT_UPDATE")
    self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED")
    self:UnregisterEvent("ITEM_LOCK_CHANGED")
    self:UnregisterEvent("CURSOR_UPDATE")
    self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
    self:UnregisterEvent("UPDATE_INVENTORY_ALERTS")
end
GW.AddForProfiling("paperdoll_equipment", "itemSlot_OnHide", itemSlot_OnHide)

local function itemSlot_OnEvent(self, event, ...)
    local arg1, _ = ...
    if (event == "PLAYER_EQUIPMENT_CHANGED") then
        if (self:GetID() == arg1) then
            updateItemSlot(self)
            updateBagItemList(self)
        end
    end
    if (event == "BAG_UPDATE_COOLDOWN") then
        updateItemSlot(self)
    end
end
GW.AddForProfiling("paperdoll_equipment", "itemSlot_OnEvent", itemSlot_OnEvent)

local function itemSlot_OnEnter(self)
    self:RegisterEvent("MODIFIER_STATE_CHANGED")

    if (not EquipmentFlyout_SetTooltipAnchor(self)) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    end
    local hasItem, _, repairCost = GameTooltip:SetInventoryItem("player", self:GetID(), nil, true)
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
GW.AddForProfiling("paperdoll_equipment", "itemSlot_OnEnter", itemSlot_OnEnter)

local function itemSlot_OnLeave(self)
    self:UnregisterEvent("MODIFIER_STATE_CHANGED")
    GameTooltip_Hide()
    ResetCursor()
end
GW.AddForProfiling("paperdoll_equipment", "itemSlot_OnLeave", itemSlot_OnLeave)

local function stat_OnEnter(self)
    if self.stat == "MASTERY" then
        Mastery_OnEnter(self)
        return
    elseif self.stat == "MOVESPEED" then
        MovementSpeed_OnEnter(self)
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
GW.AddForProfiling("paperdoll_equipment", "stat_OnEnter", stat_OnEnter)

getBagSlotFrame = function(i)
    if _G["gwPaperDollBagSlotButton" .. i] ~= nil then
        return _G["gwPaperDollBagSlotButton" .. i]
    end

    local f = CreateFrame("ItemButton", "gwPaperDollBagSlotButton" .. i, GwPaperDollBagItemList, "GwPaperDollBagItem")
    --f:SetScript("OnShow", itemSlot_OnShow)
    --f:SetScript("OnHide", itemSlot_OnHide)
    f:SetScript("OnEvent", itemSlot_OnEvent)
    --f:SetScript("OnClick", itemSlot_OnClickRouter)
    f:SetScript("OnClick", bagSlot_OnClick)
    f:SetScript("OnDragStart", itemSlot_OnDragStart)
    f:SetScript("OnReceiveDrag", itemSlot_OnReceiveDrag)
    --f:SetScript("OnEnter", itemSlot_OnEnter)
    f:SetScript("OnEnter", bagSlot_OnEnter)
    --f:SetScript("OnLeave", itemSlot_OnLeave)
    f:SetScript("OnLeave", bagSlot_OnLeave)
    actionButtonGlobalStyle(f)

    numBagSlotFrames = numBagSlotFrames + 1

    return f
end
GW.AddForProfiling("paperdoll_equipment", "getBagSlotFrame", getBagSlotFrame)

local function updateBagItemListAll()
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
GW.AddForProfiling("paperdoll_equipment", "updateBagItemListAll", updateBagItemListAll)

local function setStatIcon(self, stat)
    local newTexture = "Interface\\AddOns\\GW2_UI\\textures\\character\\statsicon"
    if STATS_ICONS[stat] ~= nil then
        -- If mastery we use need to use class icon

        if stat == "MASTERY" then
            local _, _, classIndex = UnitClass("player")
            SetClassIcon(self.icon, classIndex)
            newTexture = "Interface\\AddOns\\GW2_UI\\textures\\party\\classicons"
        else
            self.icon:SetTexCoord(STATS_ICONS[stat].l, STATS_ICONS[stat].r, STATS_ICONS[stat].t, STATS_ICONS[stat].b)
        end
    end

    if newTexture ~= self.icon:GetTexture() then
        self.icon:SetTexture(newTexture)
    end
end
GW.AddForProfiling("paperdoll_equipment", "setStatIcon", setStatIcon)

local function getStatListFrame(self, i)
    if _G["GwPaperDollStat" .. i] ~= nil then
        return _G["GwPaperDollStat" .. i]
    end

    local fm = CreateFrame("Frame", "GwPaperDollStat" .. i, self, "GwPaperDollStat")
    fm.Value:SetFont(UNIT_NAME_FONT, 14)
    fm.Value:SetText(GwLocalization["CHARACTER_NOT_LOADED"])
    fm.Label:SetFont(UNIT_NAME_FONT, 1)
    fm.Label:SetTextColor(0, 0, 0, 0)

    fm:SetScript("OnEnter", stat_OnEnter)
    fm:SetScript("OnLeave", GameTooltip_Hide)

    return fm
end
GW.AddForProfiling("paperdoll_equipment", "getStatListFrame", getStatListFrame)

local function updateStats()
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

    local statFrame

    local numShownStats = 1
    local grid = 1
    local x = 0
    local y = 0

    for catIndex = 1, #PAPERDOLL_STATCATEGORIES do
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
                statFrame = getStatListFrame(GwPaperDollStats, numShownStats)
                statFrame.stat = stat.stat
                statFrame.onEnterFunc = nil
                PAPERDOLL_STATINFO[stat.stat].updateFunc(statFrame, "player")

                setStatIcon(statFrame, stat.stat)

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
GW.AddForProfiling("paperdoll_equipment", "updateStats", updateStats)

local function stats_QueuedUpdate(self)
    self:SetScript("OnUpdate", nil)
    updateStats()
end
GW.AddForProfiling("paperdoll_equipment", "stats_QueuedUpdate", stats_QueuedUpdate)

local function updateUnitData()
    GwDressingRoom.characterName:SetText(UnitPVPName("player"))
    local spec = GetSpecialization()
    local localizedClass, _, _ = UnitClass("player")
    local _, name, _, _, _, _ = GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player"))

    if name ~= nil then
        local data = LEVEL .. " " .. UnitLevel("player") .. " " .. name .. " " .. localizedClass
        GwDressingRoom.characterData:SetWidth(180)
        GwDressingRoom.characterData:SetText(data)
    end
end
GW.AddForProfiling("paperdoll_equipment", "updateUnitData", updateUnitData)

local function stats_OnEvent(self, event, ...)
    local unit = ...
    if
        (event == "PLAYER_ENTERING_WORLD" or event == "UNIT_MODEL_CHANGED" or
            (event == "UNIT_NAME_UPDATE" and unit == "player"))
     then
        GwDressingRoom.model:SetUnit("player", false)
        updateUnitData()
        return
    end

    if not GW.inWorld then
        return
    end

    if (unit == "player") then
        if (event == "UNIT_LEVEL") then
            updateUnitData()
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
            self:SetScript("OnUpdate", stats_QueuedUpdate)
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
        self:SetScript("OnUpdate", stats_QueuedUpdate)
    elseif (event == "PLAYER_TALENT_UPDATE") then
        updateUnitData()
        self:SetScript("OnUpdate", stats_QueuedUpdate)
    elseif (event == "ACTIVE_TALENT_GROUP_CHANGED") then
        updateStats()
    elseif (event == "SPELL_POWER_CHANGED") then
        self:SetScript("OnUpdate", stats_QueuedUpdate)
    end
end
GW.AddForProfiling("paperdoll_equipment", "stats_OnEvent", stats_OnEvent)

local function resetBagInventory()
    GwPaperDollSelectedIndicator:Hide()
    selectedInventorySlot = nil
    updateBagItemListAll()
end
GW.AddForProfiling("paperdoll_equipment", "resetBagInventory", resetBagInventory)

local function indicatorAnimation(self)
    local name = self:GetName()
    local _, _, _, startX, _ = self:GetPoint()

    AddToAnimation(
        name,
        0,
        1,
        GetTime(),
        1,
        function(step)
            local point, relat, relPoint, _, yof = self:GetPoint()
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
                indicatorAnimation(self)
            end
        end
    )
end
GW.AddForProfiling("paperdoll_equipment", "indicatorAnimation", indicatorAnimation)

local function LoadPDBagList(fmMenu)
    local fmGDR = CreateFrame("Button", "GwDressingRoom", GwPaperDoll, "GwDressingRoom")
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
        fm:SetScript("OnShow", itemSlot_OnShow)
        fm:SetScript("OnHide", itemSlot_OnHide)
        fm:SetScript("OnEvent", itemSlot_OnEvent)
        fm:SetScript("OnClick", itemSlot_OnClickRouter)
        fm:SetScript("OnDragStart", itemSlot_OnDragStart)
        fm:SetScript("OnReceiveDrag", itemSlot_OnReceiveDrag)
        fm:SetScript("OnEnter", itemSlot_OnEnter)
        fm:SetScript("OnLeave", itemSlot_OnLeave)
        itemSlot_OnLoad(fm)
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
    elseif raceEn == "Tauren" or raceEn == "HighmountainTauren" then
        fmPD3M:SetPosition(0.6, 0, 0)
    elseif raceEn == "BloodElf" or raceEn == "VoidElf" then
        fmPD3M:SetPosition(0.5, 0, 0)
    elseif raceEn == "Draenei" or raceEn == "LightforgedDraenei" then
        fmPD3M:SetPosition(0.3, 0, -0.15)
    elseif raceEn == "NightElf" or raceEn == "Nightborne" then
        fmPD3M:SetPosition(0.3, 0, -0.15)
    elseif raceEn == "Pandaren" or raceEn == "KulTiran" then
        fmPD3M:SetPosition(0.3, 0, -0.15)
    elseif raceEn == "Goblin" then
        fmPD3M:SetPosition(0.2, 0, -0.05)
    elseif raceEn == "Troll" or raceEn == "ZandalariTroll" then
        fmPD3M:SetPosition(0.2, 0, -0.05)
    elseif raceEn == "Scourge" then
        fmPD3M:SetPosition(0.2, 0, -0.05)
    elseif raceEn == "Dwarf" or raceEn == "DarkIronDwarf" then
        fmPD3M:SetPosition(0.3, 0, 0)
    elseif raceEn == "Gnome" then
        fmPD3M:SetPosition(0.2, 0, -0.05)
    elseif raceEn == "Orc" or raceEn == "MagharOrc" then
        fmPD3M:SetPosition(0.1, 0, -0.15)
    end
    fmPD3M:SetRotation(-0.15)
    Model_OnLoad(fmPD3M, 4, 0, -0.1, CharacterModelFrame_OnMouseUp)
    fmPD3M:HookScript("OnMouseDown", resetBagInventory)

    fmGPDS.header:SetFont(DAMAGE_TEXT_FONT, 14)
    fmGPDS.header:SetText(STAT_CATEGORY_ATTRIBUTES)
    fmGPDS:SetScript("OnEvent", stats_OnEvent)
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
    SetClassIcon(fmGDR.classIcon, classIndex)
    fmGDR.classIcon:SetVertexColor(
        CLASS_COLORS_RAIDFRAME[classIndex].r,
        CLASS_COLORS_RAIDFRAME[classIndex].g,
        CLASS_COLORS_RAIDFRAME[classIndex].b,
        1
    )
    fmGDR:SetScript("OnClick", resetBagInventory)

    local fmGPDBIL = CreateFrame("Frame", "GwPaperDollBagItemList", GwPaperDoll, "GwPaperDollBagItemList")
    fmGPDBIL:SetScript("OnEvent", updateBagItemListAll)
    fmGPDBIL:SetScript("OnHide", resetBagInventory)
    fmGPDBIL:SetScript("OnShow", updateBagItemListAll)
    fmGPDBIL:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    updateBagItemListAll()
    fmMenu:SetupBackButton(fmGPDBIL.backButton, CHARACTER .. ": " .. BAG_FILTER_EQUIPMENT)

    local fmGPDSI = CreateFrame("Frame", "GwPaperDollSelectedIndicator", GwPaperDoll, "GwPaperDollSelectedIndicator")
    fmGPDSI:SetScript("OnShow", indicatorAnimation)

    updateStats()

    StaticPopupDialogs["GW_UNEQUIP_LEGENDARY"] = {
        text = GwLocalization["UNEQUIP_LEGENDARY"],
        button1 = CANCEL,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
    StaticPopupDialogs["GW_NOT_A_LEGENDARY"] = {
        text = GwLocalization["NOT_A_LEGENDARY"],
        button1 = CANCEL,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
end
GW.LoadPDBagList = LoadPDBagList
