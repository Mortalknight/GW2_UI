local _, GW = ...
GW.char_equipset_SavedItems = {}
local SavedItemSlots = GW.char_equipset_SavedItems
local GWGetClassColor = GW.GWGetClassColor
local SetClassIcon = GW.SetClassIcon
local AddToAnimation = GW.AddToAnimation
local IsIn = GW.IsIn
local getContainerItemLinkByNameOrId = GW.getContainerItemLinkByNameOrId
local setItemLevel = GW.setItemLevel

local PlayerSlots = {
    ["CharacterHeadSlot"] = {0, 0.25, 0, 0.25},
    ["CharacterNeckSlot"] = {0.25, 0.5, 0, 0.25},
    ["CharacterShoulderSlot"] = {0.5, 0.75, 0.5, 0.75},
    ["CharacterBackSlot"] = {0.75, 1, 0, 0.25},
    ["CharacterChestSlot"] = {0.75, 1, 0.5, 0.75},
    ["CharacterShirtSlot"] = {0.75, 1, 0.5, 0.75},
    ["CharacterTabardSlot"] = {0.25, 0.5, 0.75, 1},
    ["CharacterWristSlot"] = {0.75, 1, 0.25, 0.5},
    ["CharacterHandsSlot"] = {0, 0.25, 0.75, 1},
    ["CharacterWaistSlot"] = {0.25, 0.5, 0.5, 0.75},
    ["CharacterLegsSlot"] = {0, 0.25, 0.5, 0.75},
    ["CharacterFeetSlot"] = {0.5, 0.75, 0.25, 0.5},
    ["CharacterFinger0Slot"] = {0.5, 0.75, 0, 0.25},
    ["CharacterFinger1Slot"] = {0.5, 0.75, 0, 0.25},
    ["CharacterTrinket0Slot"] = {0.5, 0.75, 0.75, 1},
    ["CharacterTrinket1Slot"] = {0.5, 0.75, 0.75, 1},
    ["CharacterMainHandSlot"] = {0.25, 0.5, 0.25, 0.5},
    ["CharacterSecondaryHandSlot"] = {0, 0.25, 0.25, 0.5},
}
local slotButtons = {}

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
local durabilityFrame = nil

local function UpdateAzeriteItem(self)
    if not self.styled then
        self.styled = true

        self.AzeriteTexture:SetAlpha(0)
        self.RankFrame.Texture:SetTexture()
        self.RankFrame.Label:SetFont(UNIT_NAME_FONT, 12, "THINOUTLINED")
    end
end

local function UpdateAzeriteEmpoweredItem(self)
    self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
    self.AzeriteTexture:ClearAllPoints()
    self.AzeriteTexture:SetPoint("TOPLEFT", self.AzeriteTexture:GetParent(), "TOPLEFT", 2, -2)
    self.AzeriteTexture:SetPoint("BOTTOMRIGHT", self.AzeriteTexture:GetParent(), "BOTTOMRIGHT", -2, 2)
    self.AzeriteTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.AzeriteTexture:SetDrawLayer("BORDER", 1)
end

local function CorruptionIcon(self)
    local itemLink = GetInventoryItemLink("player", self:GetID())
    self.IconOverlay:SetShown(itemLink and C_Item.IsCorruptedItem(itemLink))
end

local function setItemButtonQuality(button, quality)
    if quality then
        if quality >= Enum.ItemQuality.Common and GetItemQualityColor(quality) then
            local r, g, b = GetItemQualityColor(quality)
            button.IconBorder:Show()
            button.IconBorder:SetVertexColor(r, g, b)
        else
            button.IconBorder:Hide()
        end
    else
        button.IconBorder:Hide()
    end
end
GW.AddForProfiling("paperdoll_equipment", "setItemButtonQuality", setItemButtonQuality)

local function updateBagItemButton(button)
    local location = button.location
    if not location then
        return
    end
    local id, name, textureName, count, durability, maxDurability, _, _, _, _, _, setTooltip, quality = EquipmentManager_GetItemInfoByLocation(location)
    local broken = (maxDurability and durability == 0)

    button.ItemId = id
    button.ItemLink = getContainerItemLinkByNameOrId(name, id)
    if button.ItemLink == nil then
        button.ItemLink = GW.getInventoryItemLinkByNameAndId(name, id)
    end
    button:ResetAzeriteItem()

    if textureName then
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

        setItemLevel(button, quality, button.ItemLink)
        setItemButtonQuality(button, quality)

        button.IconOverlay:SetShown(button.ItemLink and C_Item.IsCorruptedItem(button.ItemLink))
    end
end
GW.AddForProfiling("paperdoll_equipment", "updateBagItemButton", updateBagItemButton)

local function updateBagItemList(itemButton)
    local id = itemButton.id or itemButton:GetID()
    if selectedInventorySlot ~= id or InCombatLockdown() then
        return
    end

    wipe(bagItemList)

    GetInventoryItemsForSlot(id, bagItemList)

    local gridIndex = 1
    local itemIndex = 1
    local x = 10
    local y = 15

    for location, _ in next, bagItemList do
        if not (location - id == ITEM_INVENTORY_LOCATION_PLAYER) then -- Remove the currently equipped item from the list
            local itemFrame = getBagSlotFrame(itemIndex)
            itemFrame.location = location
            itemFrame.itemSlot = id

            updateBagItemButton(itemFrame)

            itemFrame:ClearAllPoints()
            itemFrame:SetPoint("TOPLEFT", x, -y)
            itemFrame:Show()
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
        if _G["gwPaperDollBagSlotButton" .. i] then
            _G["gwPaperDollBagSlotButton" .. i]:Hide()
        end
    end
end
GW.AddForProfiling("paperdoll_equipment", "updateBagItemList", updateBagItemList)

local function actionButtonGlobalStyle(self)
    local name = self:GetName()
    self.IconBorder:SetSize(self:GetSize())
    _G[name .. "IconTexture"]:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    _G[name .. "NormalTexture"]:SetSize(self:GetSize())
    _G[name .. "NormalTexture"]:Hide()
    self.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")

    _G[name .. "NormalTexture"]:SetTexture(nil)
    self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed")
    self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    self:GetHighlightTexture():SetBlendMode("ADD")
    self:GetHighlightTexture():SetAlpha(0.33)

    self.IconOverlay:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    self.IconOverlay:SetAllPoints(self)
    self.IconOverlay:SetAtlas("Nzoth-inventory-icon")
    self.IconOverlay:ClearAllPoints()
    self.IconOverlay:SetPoint("TOPLEFT", self.IconOverlay:GetParent(), "TOPLEFT", 1, -1)
    self.IconOverlay:SetPoint("BOTTOMRIGHT", self.IconOverlay:GetParent(), "BOTTOMRIGHT", -1, 1)

    self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
    self.AzeriteTexture:ClearAllPoints()
    self.AzeriteTexture:SetPoint("TOPLEFT", self.AzeriteTexture:GetParent(), "TOPLEFT", 2, -2)
    self.AzeriteTexture:SetPoint("BOTTOMRIGHT", self.AzeriteTexture:GetParent(), "BOTTOMRIGHT", -2, 2)
    self.AzeriteTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.AzeriteTexture:SetDrawLayer("BORDER", 1)

    UpdateAzeriteItem(self)
end
GW.AddForProfiling("paperdoll_equipment", "actionButtonGlobalStyle", actionButtonGlobalStyle)

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
    if (textureName) then
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

        self.hasItem = 1
    else
        self.repairIcon:Hide()
        self.hasItem = false
    end

    local quality = GetInventoryItemQuality("player", slot)
    setItemButtonQuality(self, quality)
end
GW.AddForProfiling("paperdoll_equipment", "updateItemSlot", updateItemSlot)

local function itemSlot_OnEvent(self, event, ...)
    local arg1, _ = ...
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        if self:GetID() == arg1 then
            updateItemSlot(self)
            updateBagItemList(self)
        end
    elseif event == "BAG_UPDATE_COOLDOWN" then
        updateItemSlot(self)
    end
end
GW.AddForProfiling("paperdoll_equipment", "itemSlot_OnEvent", itemSlot_OnEvent)

local function stat_OnEnter(self)
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
    if _G["gwPaperDollBagSlotButton" .. i] then
        return _G["gwPaperDollBagSlotButton" .. i]
    end

    local f = CreateFrame("ItemButton", "gwPaperDollBagSlotButton" .. i, GwPaperDollBagItemList, "GwPaperDollBagItem")
    f:SetScript("OnEvent", itemSlot_OnEvent)
    f:SetScript("OnClick", bagSlot_OnClick)
    f:SetScript("OnEnter", bagSlot_OnEnter)
    f:SetScript("OnLeave", bagSlot_OnLeave)
    actionButtonGlobalStyle(f)

    numBagSlotFrames = numBagSlotFrames + 1

    return f
end
GW.AddForProfiling("paperdoll_equipment", "getBagSlotFrame", getBagSlotFrame)

local function updateBagItemListAll()
    if selectedInventorySlot ~= nil or InCombatLockdown() then
        return
    end

    local gridIndex = 1
    local itemIndex = 1
    local x = 10
    local y = 15

    for _, v in pairs(EquipSlotList) do
        local id = v

        wipe(bagItemList)

        GetInventoryItemsForSlot(id, bagItemList)

        for location, _ in next, bagItemList do
            if not (location - id == ITEM_INVENTORY_LOCATION_PLAYER) then -- Remove the currently equipped item from the list
                local itemFrame = getBagSlotFrame(itemIndex)
                itemFrame.location = location
                itemFrame.itemSlot = id

                updateBagItemButton(itemFrame)

                itemFrame:ClearAllPoints()
                itemFrame:SetPoint("TOPLEFT", x, -y)
                itemFrame:Show()
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
        if _G["gwPaperDollBagSlotButton" .. i] then
            _G["gwPaperDollBagSlotButton" .. i]:Hide()
        end
    end
end
GW.AddForProfiling("paperdoll_equipment", "updateBagItemListAll", updateBagItemListAll)

local function setStatIcon(self, stat)
    local newTexture = "Interface/AddOns/GW2_UI/textures/character/statsicon"
    if STATS_ICONS[stat] ~= nil then
        -- If mastery we use need to use class icon
        if stat == "MASTERY" then
            SetClassIcon(self.icon, GW.myClassID)
            newTexture = "Interface/AddOns/GW2_UI/textures/party/classicons"
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
    fm.Value:SetText(ERRORS)
    fm.Label:SetFont(UNIT_NAME_FONT, 1)
    fm.Label:SetTextColor(0, 0, 0, 0)

    fm:SetScript("OnEnter", stat_OnEnter)
    fm:SetScript("OnLeave", GameTooltip_Hide)

    return fm
end
GW.AddForProfiling("paperdoll_equipment", "getStatListFrame", getStatListFrame)

local function getDurabilityListFrame(self)
    if _G["GwPaperDollStatDurability"] then
        return _G["GwPaperDollStatDurability"]
    end

    local fm = CreateFrame("Frame", "GwPaperDollStatDurability", self, "GwPaperDollStat")
    fm.Value:SetFont(UNIT_NAME_FONT, 14)
    fm.Value:SetText(ERRORS)
    fm.Label:SetFont(UNIT_NAME_FONT, 1)
    fm.Label:SetTextColor(0, 0, 0, 0)

    fm.stat = "DURABILITY"
    fm.onEnterFunc = nil

    --Icon setzen
    fm.icon:SetTexture("Interface/AddOns/GW2_UI/textures/globe/repair")
    fm.icon:SetTexCoord(0, 1, 0, 0.5)
    fm.icon:SetDesaturated(true)

    fm:SetScript("OnEnter", stat_OnEnter)
    fm:SetScript("OnLeave", GameTooltip_Hide)

    return fm
end
GW.AddForProfiling("paperdoll_equipment", "getDurabilityListFrame", getDurabilityListFrame)

local function updateStats()
    local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
    avgItemLevelEquipped = math.floor(avgItemLevelEquipped)
    avgItemLevel = math.floor(avgItemLevel)
    if avgItemLevelEquipped < avgItemLevel then
        avgItemLevelEquipped = math.floor(avgItemLevelEquipped) .. "(" .. math.floor(avgItemLevel) .. ")"
    end

    GwDressingRoom.itemLevel:SetText(avgItemLevelEquipped)
    GwDressingRoom.itemLevel:SetTextColor(GetItemLevelColor())

    local statFrame

    local numShownStats = 1
    local grid = 1
    local x = 0
    local y = 0

    -- hide old stats
    for i = 1, 20 do
        statFrame = _G["GwPaperDollStat" .. i]
        if statFrame then
            statFrame.stat = nil
            statFrame:Hide()
        end
    end
    for catIndex = 1, #PAPERDOLL_STATCATEGORIES do
        for statIndex = 1, #PAPERDOLL_STATCATEGORIES[catIndex].stats do
            local stat = PAPERDOLL_STATCATEGORIES[catIndex].stats[statIndex]
            local showStat = true
            if (stat.primary) then
                local primaryStat = select(6, GetSpecializationInfo(GW.myspec, nil, nil, nil, GW.mysex))
                if (stat.primary ~= primaryStat) then
                    showStat = false
                end
            end
            if (showStat and stat.roles) then
                local foundRole = false
                for _, statRole in pairs(stat.roles) do
                    if (GW.myrole == statRole) then
                        foundRole = true
                        break
                    end
                end
                showStat = foundRole
            end
            statFrame = getStatListFrame(GwDressingRoom.stats, numShownStats)
            statFrame.onEnterFunc = nil
            statFrame.UpdateTooltip = nil
            PAPERDOLL_STATINFO[stat.stat].updateFunc(statFrame, "player")

            if (showStat) and (not stat.hideAt or stat.hideAt ~= statFrame.numericValue) then
                statFrame:Show()
                statFrame.stat = stat.stat
                setStatIcon(statFrame, stat.stat)

                statFrame:ClearAllPoints()
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
    -- Add Durability Icon
    statFrame = getDurabilityListFrame(GwDressingRoom.stats)
    statFrame:ClearAllPoints()
    statFrame:SetPoint("TOPLEFT", 5 + x, -35 + -y)
    durabilityFrame = statFrame
end
GW.AddForProfiling("paperdoll_equipment", "updateStats", updateStats)

local function stats_QueuedUpdate(self)
    self:SetScript("OnUpdate", nil)
    updateStats()
end
GW.AddForProfiling("paperdoll_equipment", "stats_QueuedUpdate", stats_QueuedUpdate)

local function updateUnitData()
    GwDressingRoom.characterName:SetText(UnitPVPName("player"))
    local name = select(2, GetSpecializationInfo(GW.myspec, nil, nil, nil, GW.mysex))

    if name ~= nil then
        local data = LEVEL .. " " .. GW.mylevel .. " " .. name .. " " .. GW.myLocalizedClass
        GwDressingRoom.characterData:SetWidth(180)
        GwDressingRoom.characterData:SetText(data)
    end
end
GW.AddForProfiling("paperdoll_equipment", "updateUnitData", updateUnitData)

local function stats_OnEvent(self, event, ...)
    local unit = ...
    if (IsIn(event, "UNIT_MODEL_CHANGED", "UNIT_NAME_UPDATE") and unit == "player") or event == "PLAYER_ENTERING_WORLD" then
        GwDressingRoom.model:SetUnit("player", false)
        updateUnitData()
        GW.collectDurability(durabilityFrame)
        return
    elseif IsIn(event, "UPDATE_INVENTORY_DURABILITY", "MERCHANT_SHOW") then
        GW.collectDurability(durabilityFrame)
        return
    end

    if not GW.inWorld then
        return
    end

    if unit == "player" then
        if event == "UNIT_LEVEL" then
            updateUnitData()
        elseif IsIn(event, "UNIT_DAMAGE", "UNIT_ATTACK_SPEED", "UNIT_RANGEDDAMAGE", "UNIT_ATTACK", "UNIT_STATS", "UNIT_RANGED_ATTACK_POWER", "UNIT_SPELL_HASTE",
                "UNIT_MAXHEALTH", "UNIT_AURA", "UNIT_RESISTANCES", "SPEED_UPDATE") then
            self:SetScript("OnUpdate", stats_QueuedUpdate)
        end
    end
    if IsIn(event,"COMBAT_RATING_UPDATE", "MASTERY_UPDATE", "SPEED_UPDATE", "LIFESTEAL_UPDATE", "AVOIDANCE_UPDATE", "BAG_UPDATE", "PLAYER_EQUIPMENT_CHANGED",
            "PLAYERBANKSLOTS_CHANGED", "PLAYER_AVG_ITEM_LEVEL_UPDATE", "PLAYER_DAMAGE_DONE_MODS") then
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
    for _, slot in pairs(slotButtons) do
        slot.overlayButton:Hide()
    end
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

local function grabDefaultSlots(slot, anchor, parent, size)
    slot:ClearAllPoints()
    slot:SetPoint(unpack(anchor))
    slot:SetParent(parent)
    slot:SetSize(size, size)
    slot:GwStripTextures()

    slot.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    slot.icon:SetAlpha(0.9)
    slot.icon:SetAllPoints(slot)
    slot.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    slot.IconBorder:SetAllPoints(slot)
    slot.IconBorder:SetParent(slot)

    slot:GetNormalTexture():SetTexture(nil)

    GW.RegisterCooldown(_G[slot:GetName()..'Cooldown'])

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

    slot.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")

    slot.ignoreSlotCheck = CreateFrame("CheckButton", nil, slot, "GWIgnoreSlotCheck")

    slot.IconOverlay:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    slot.IconOverlay:SetAllPoints(slot)
    slot.IconOverlay:SetAtlas("Nzoth-inventory-icon")
    slot.IconOverlay:ClearAllPoints()
    slot.IconOverlay:SetPoint("TOPLEFT", slot.IconOverlay:GetParent(), "TOPLEFT", 1, -1)
    slot.IconOverlay:SetPoint("BOTTOMRIGHT", slot.IconOverlay:GetParent(), "BOTTOMRIGHT", -1, 1)

    slot.overlayButton = CreateFrame("Button", nil, slot)
    slot.overlayButton:SetAllPoints()
    slot.overlayButton:Hide()
    slot.overlayButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    slot.overlayButton:GetHighlightTexture():SetBlendMode("ADD")
    slot.overlayButton:GetHighlightTexture():SetAlpha(0.33)
    slot.overlayButton.isEquipmentSelected = false
    slot.overlayButton:SetScript("OnClick", function(self)
        if self.isEquipmentSelected and selectedInventorySlot == self:GetParent():GetID() then
            GwPaperDollSelectedIndicator:Hide()
            selectedInventorySlot = nil
            updateBagItemListAll()
            self.isEquipmentSelected = false
        else
            GwPaperDollSelectedIndicator:ClearAllPoints()
            GwPaperDollSelectedIndicator:SetPoint("LEFT", self:GetParent(), "LEFT", -16, 0)
            GwPaperDollSelectedIndicator:Show()
            selectedInventorySlot = self:GetParent():GetID()
            updateBagItemList(self:GetParent())
            self.isEquipmentSelected = true
        end
    end)
    slot.overlayButton:SetScript("OnEnter", function() slot:GetScript("OnEnter")(slot) end)
    slot.overlayButton:SetScript("OnLeave", function() slot:GetScript("OnLeave")(slot) end)

    hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
    hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)
    hooksecurefunc(slot.IconBorder, "SetVertexColor", function(self)
        self:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    end)

    slot:HookScript("OnShow", CorruptionIcon)
    slot:HookScript("OnEvent", CorruptionIcon)

    EquipSlotList[#EquipSlotList + 1] = slot:GetID()
    slotButtons[#slotButtons + 1] = slot

    updateItemSlot(slot)

    slot.IsGW2Hooked = true
end

local function GwPaperDollBagItemList_OnShow()
    updateBagItemListAll()
    for _, slot in pairs(slotButtons) do
        slot.overlayButton:Show()
    end
end

local function EquipCursorItem()
    if InCombatLockdown() then return end
    local cursorItem = C_Cursor.GetCursorItem()
    if cursorItem and cursorItem.bagID and cursorItem.slotIndex then
        local itemID = C_Container.GetContainerItemID(cursorItem.bagID, cursorItem.slotIndex)
        if itemID then
            if C_Item.IsEquippableItem(itemID) and not  C_Item.IsEquippedItem(itemID) then
                C_Timer.After(1.1, function() C_Item.EquipItemByName(itemID) end)
            end
        end
        ClearCursor()
    end
end

local function LoadPDBagList(fmMenu)
    local fmGDR = CreateFrame("Button", "GwDressingRoom", GwPaperDoll, "GwDressingRoom")
    local fmPD3M = GwDressingRoom.model
    local fmGPDS = GwDressingRoom.stats

    -- to prevent ALT click lua error
    fmGDR.flyoutSettings = {
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

    grabDefaultSlots(CharacterHeadSlot, {"TOPLEFT", fmGDR.gear, "TOPLEFT", 0, 0}, fmGDR, 50)
    grabDefaultSlots(CharacterShoulderSlot, {"TOPLEFT", CharacterHeadSlot, "BOTTOMLEFT", 0, -5}, fmGDR, 50)
    grabDefaultSlots(CharacterChestSlot, {"TOPLEFT", CharacterShoulderSlot, "BOTTOMLEFT", 0, -5}, fmGDR, 50)
    grabDefaultSlots(CharacterWristSlot, {"TOPLEFT", CharacterChestSlot, "BOTTOMLEFT", 0, -5}, fmGDR, 50)
    grabDefaultSlots(CharacterHandsSlot, {"TOPLEFT", CharacterWristSlot, "BOTTOMLEFT", 0, -5}, fmGDR, 50)
    grabDefaultSlots(CharacterWaistSlot, {"TOPLEFT", CharacterHandsSlot, "BOTTOMLEFT", 0, -5}, fmGDR, 50)
    grabDefaultSlots(CharacterLegsSlot, {"TOPLEFT", CharacterWaistSlot, "BOTTOMLEFT", 0, -5}, fmGDR, 50)
    grabDefaultSlots(CharacterFeetSlot, {"TOPLEFT", CharacterLegsSlot, "BOTTOMLEFT", 0, -5}, fmGDR, 50)
    grabDefaultSlots(CharacterMainHandSlot, {"TOPLEFT", CharacterFeetSlot, "BOTTOMLEFT", 0, -20}, fmGDR, 50)
    grabDefaultSlots(CharacterSecondaryHandSlot, {"TOPLEFT", CharacterMainHandSlot, "BOTTOMLEFT", 0, -5}, fmGDR, 50)

    grabDefaultSlots(CharacterTabardSlot, {"TOPRIGHT", fmGPDS, "BOTTOMRIGHT", -5, -20}, fmGDR, 40)
    grabDefaultSlots(CharacterShirtSlot, {"TOPRIGHT", CharacterTabardSlot, "BOTTOMRIGHT", 0, -5}, fmGDR, 40)
    grabDefaultSlots(CharacterTrinket0Slot, {"TOPRIGHT", CharacterTabardSlot, "TOPLEFT", -5, 0}, fmGDR, 40)
    grabDefaultSlots(CharacterTrinket1Slot, {"TOPRIGHT", CharacterTrinket0Slot, "BOTTOMRIGHT", 0, -5}, fmGDR, 40)
    grabDefaultSlots(CharacterFinger0Slot, {"TOPRIGHT", CharacterTrinket0Slot, "TOPLEFT", -5, 0}, fmGDR, 40)
    grabDefaultSlots(CharacterFinger1Slot, {"TOPRIGHT", CharacterFinger0Slot, "BOTTOMRIGHT", 0, -5}, fmGDR, 40)
    grabDefaultSlots(CharacterNeckSlot, {"TOPRIGHT", CharacterFinger0Slot, "TOPLEFT", -5, 0}, fmGDR, 40)
    grabDefaultSlots(CharacterBackSlot, {"TOPRIGHT", CharacterNeckSlot, "BOTTOMRIGHT", 0, -5}, fmGDR, 40)

    hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
        if not button.IsGW2Hooked then return end
        local textureName = GetInventoryItemTexture("player", button:GetID())
        if not textureName then
            button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/slot-bg")
            button.icon:SetTexCoord(unpack(PlayerSlots[button:GetName()]))
        else
            button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        end
        updateItemSlot(button)
    end)

    EquipmentFlyoutFrame:GwKill()
    EquipmentFlyoutFrame:SetScript("OnUpdate", nil)
    EquipmentFlyoutFrame:SetScript("OnShow", nil)
    EquipmentFlyoutFrame:SetScript("OnLoad", nil)

    fmPD3M:SetUnit("player")
    fmPD3M:SetPosition(0.8, 0, 0)

    if GW.myrace == "Human" then
        fmPD3M:SetPosition(0.4, 0, -0.05)
    elseif GW.myrace == "Worgen" then
        fmPD3M:SetPosition(0.1, 0, -0.1)
    elseif GW.myrace == "Tauren" or GW.myrace == "HighmountainTauren" then
        fmPD3M:SetPosition(0.6, 0, 0)
    elseif GW.myrace == "BloodElf" or GW.myrace == "VoidElf" then
        fmPD3M:SetPosition(0.5, 0, 0)
    elseif GW.myrace == "Draenei" or GW.myrace == "LightforgedDraenei" then
        fmPD3M:SetPosition(0.3, 0, -0.15)
    elseif GW.myrace == "NightElf" or GW.myrace == "Nightborne" then
        fmPD3M:SetPosition(0.3, 0, -0.15)
    elseif GW.myrace == "Pandaren" or GW.myrace == "KulTiran" then
        fmPD3M:SetPosition(0.3, 0, -0.15)
    elseif GW.myrace == "Goblin" or GW.myrace == "Vulpera" then
        fmPD3M:SetPosition(0.2, 0, -0.05)
    elseif GW.myrace == "Troll" or GW.myrace == "ZandalariTroll" then
        fmPD3M:SetPosition(0.2, 0, -0.05)
    elseif GW.myrace == "Scourge" then
        fmPD3M:SetPosition(0.2, 0, -0.05)
    elseif GW.myrace == "Dwarf" or GW.myrace == "DarkIronDwarf" then
        fmPD3M:SetPosition(0.3, 0, 0)
    elseif GW.myrace == "Gnome" or GW.myrace == "Mechagnome"then
        fmPD3M:SetPosition(0.2, 0, -0.05)
    elseif GW.myrace == "Orc" or GW.myrace == "MagharOrc" then
        fmPD3M:SetPosition(0.1, 0, -0.15)
    elseif GW.myrace == "Dracthyr" then
        fmPD3M:SetPosition(0.1, 0, -0.15)
    end

    fmPD3M:SetRotation(-0.15)
    Model_OnLoad(fmPD3M, 4, 0, -0.1, CharacterModelFrame_OnMouseUp)

    fmPD3M:SetScript("OnReceiveDrag", EquipCursorItem)
    fmPD3M:HookScript("OnMouseDown", EquipCursorItem)

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
    fmGPDS:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    fmGPDS:RegisterEvent("MERCHANT_SHOW")
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
    local color = GWGetClassColor(GW.myclass, true)

    SetClassIcon(fmGDR.classIcon, GW.myClassID)

    fmGDR.classIcon:SetVertexColor(color.r, color.g, color.b, color.a)
    fmGDR:SetScript("OnClick", resetBagInventory)

    local fmGPDBIL = CreateFrame("Frame", "GwPaperDollBagItemList", GwPaperDoll, "GwPaperDollBagItemList")
    fmGPDBIL:SetScript("OnEvent", updateBagItemListAll)
    fmGPDBIL:SetScript("OnHide", resetBagInventory)
    fmGPDBIL:SetScript("OnShow", GwPaperDollBagItemList_OnShow)
    fmGPDBIL:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    updateBagItemListAll()
    fmMenu:SetupBackButton(fmGPDBIL.backButton, CHARACTER .. ": " .. BAG_FILTER_EQUIPMENT)

    local fmGPDSI = CreateFrame("Frame", "GwPaperDollSelectedIndicator", fmGDR, "GwPaperDollSelectedIndicator")
    fmGPDSI:SetScript("OnShow", indicatorAnimation)

    updateStats()
end
GW.LoadPDBagList = LoadPDBagList
