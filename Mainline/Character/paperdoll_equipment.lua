local _, GW = ...
GW.char_equipset_SavedItems = {}
local GWGetClassColor = GW.GWGetClassColor
local SetClassIcon = GW.SetClassIcon

local IsIn = GW.IsIn

local bagItemListWaitScheduled = false
local bagItemListQueued = false

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
local selectedInventorySlot = nil
local bagSlotFramePool

local function UpdateAzeriteItem(self)
    if not self.styled then
        self.styled = true

        self.AzeriteTexture:SetAlpha(0)
        self.RankFrame.Texture:SetTexture()
        self.RankFrame.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "THINOUTLINE")
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
        local color = GW.GetQualityColor(quality)
        if quality >= Enum.ItemQuality.Common and color then
            button.IconBorder:Show()
            button.IconBorder:SetVertexColor(color.r, color.g, color.b)
            if button.itemSetBorderIndicator then
                button.itemSetBorderIndicator.Glow:SetVertexColor(color.r, color.g, color.b)
                button.itemSetBorderShimmer.Lightning:SetVertexColor(color.r, color.g, color.b)
            end
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
    local id, _, textureName, count, durability, maxDurability, _, _, _, _, _, setTooltip, quality = EquipmentManager_GetItemInfoByLocation(location)
    local broken = (maxDurability and durability == 0)

    button.itemId = id
    button.quality = quality
    button:ResetAzeriteItem()

    if textureName then
        SetItemButtonTexture(button, textureName)
        SetItemButtonCount(button, count)

        if broken then
            SetItemButtonTextureVertexColor(button, 0.9, 0, 0)
        else
            SetItemButtonTextureVertexColor(button, 1, 1, 1)
        end

        if durability and (durability / maxDurability) < 0.5 then
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

        setItemButtonQuality(button, quality)

        button.IconOverlay:SetShown(button.itemId and C_Item.IsCorruptedItem(button.itemId))
    end
end
GW.AddForProfiling("paperdoll_equipment", "updateBagItemButton", updateBagItemButton)

local function updateBagItemList(itemButton)
    local id = itemButton.id or itemButton:GetID()
    if selectedInventorySlot ~= id or InCombatLockdown() then
        return
    end

    bagSlotFramePool:ReleaseAll()

    wipe(bagItemList)
    GetInventoryItemsForSlot(id, bagItemList)

    local gridIndex, itemIndex = 1, 1
    local x, y = 10, 15

    for location in pairs(bagItemList) do
        if not (location - id == ITEM_INVENTORY_LOCATION_PLAYER) then -- Remove the currently equipped item from the list
            local itemFrame = getBagSlotFrame()
            itemFrame.location = location
            itemFrame.itemSlot = id

            updateBagItemButton(itemFrame)

            itemFrame:ClearAllPoints()
            itemFrame:SetPoint("TOPLEFT", x, -y)
            itemFrame:Show()

            itemFrame.fadeInAnim:Stop()
            local row = math.floor((itemIndex - 1) / 4)
            local delay = row * 0.05 + ((itemIndex - 1) % 4) * 0.015
            itemFrame.fadeIn:SetStartDelay(delay)
            itemFrame.fadeInAnim:Play()

            gridIndex = gridIndex + 1
            x = x + 52

            if gridIndex > 4 then
                gridIndex = 1
                x = 10
                y = y + 52
            end

            itemIndex = itemIndex + 1
            if itemIndex > 36 then
                break
            end
        end
    end
end
GW.AddForProfiling("paperdoll_equipment", "updateBagItemList", updateBagItemList)

local function actionButtonGlobalStyle(self)
    self.IconBorder:SetSize(self:GetSize())
    self.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    self:GetNormalTexture():SetSize(self:GetSize())
    self:GetNormalTexture():Hide()
    self:GetNormalTexture():SetTexture(nil)
    self.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")

    self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed.png")
    self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
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

    self.itemlevel:SetPoint("BOTTOMLEFT", 1, 2)
    self.itemlevel:SetTextColor(1, 1, 1)
    self.itemlevel:SetJustifyH("LEFT")
    self.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "THINOUTLINE")

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
    if GW.char_equipset_SavedItems[slot] == nil then
        GW.char_equipset_SavedItems[slot] = self
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

    if self.isSetItem then
        self:StartSetIndicatorAnimation()
    else
        self:StopSetIndicatorAnimation()
    end
end
GW.UpdateCharacterPanelItemSlot = updateItemSlot
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

getBagSlotFrame = function()
    local f = bagSlotFramePool:Acquire()

    if not f.initialized then
        f:SetScript("OnEvent", itemSlot_OnEvent)
        f:SetScript("OnClick", bagSlot_OnClick)
        f:SetScript("OnEnter", bagSlot_OnEnter)
        f:SetScript("OnLeave", bagSlot_OnLeave)
        actionButtonGlobalStyle(f)

        local fadeInAnim = f:CreateAnimationGroup("fadeOut")
        local fadeIn = fadeInAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.1)
        fadeIn:SetSmoothing("OUT")
        fadeIn:SetOrder(1)

        f.fadeInAnim = fadeInAnim
        f.fadeIn = fadeIn
        f:SetAlpha(0)
        f.BACKGROUND:SetAlpha(0)
        f.itemlevel:SetAlpha(0)
        f.repairIcon:SetAlpha(0)

        f.fadeInAnim:HookScript("OnFinished", function()
            f:SetAlpha(1)
            f.BACKGROUND:SetAlpha(1)
            f.itemlevel:SetAlpha(1)
            f.repairIcon:SetAlpha(1)
            GW.SetItemLevel(f, f.quality, f.itemId)
        end)

        f.initialized = true
    end

    return f
end
GW.AddForProfiling("paperdoll_equipment", "getBagSlotFrame", getBagSlotFrame)

local function updateBagItemListAll()
    if selectedInventorySlot ~= nil or InCombatLockdown() then
        return
    end

    bagSlotFramePool:ReleaseAll()

    local gridIndex, itemIndex = 1, 1
    local x, y = 10, 15

    for _, id in ipairs(EquipSlotList) do
        bagItemList = wipe(bagItemList or {})
        GetInventoryItemsForSlot(id, bagItemList)
        for location in pairs(bagItemList) do
            if not (location - id == ITEM_INVENTORY_LOCATION_PLAYER) then -- Remove the currently equipped item from the list
                local itemFrame = getBagSlotFrame()
                itemFrame.location = location
                itemFrame.itemSlot = id

                updateBagItemButton(itemFrame)

                itemFrame:ClearAllPoints()
                itemFrame:SetPoint("TOPLEFT", x, -y)
                itemFrame:Show()

                itemFrame.fadeInAnim:Stop()
                local row = math.floor((itemIndex - 1) / 4)
                local delay = row * 0.05 + ((itemIndex - 1) % 4) * 0.015
                itemFrame.fadeIn:SetStartDelay(delay)
                itemFrame.fadeInAnim:Play()

                gridIndex = gridIndex + 1
                x = x + 52

                if gridIndex > 4 then
                    gridIndex = 1
                    x = 10
                    y = y + 52
                end

                itemIndex = itemIndex + 1
                if itemIndex > 36 then
                    break
                end
            end
        end
    end
end

local function bagItemListRun()
    bagItemListWaitScheduled = false
    if bagItemListQueued then
        bagItemListQueued = false
        updateBagItemListAll()
    end
end

local function bagItemListOnEvent(self)
    bagItemListQueued = true
    if not bagItemListWaitScheduled then
        bagItemListWaitScheduled = true
        GW.Wait(1, bagItemListRun)
    end
end

local function setStatIcon(self, stat)
    local newTexture = "Interface/AddOns/GW2_UI/textures/character/statsicon.png"
    if STATS_ICONS[stat] then
        -- If mastery we use need to use class icon
        if stat == "MASTERY" then
            SetClassIcon(self.icon, GW.myClassID)
            newTexture = "Interface/AddOns/GW2_UI/textures/party/classicons.png"
        else
            self.icon:SetTexCoord(STATS_ICONS[stat].l, STATS_ICONS[stat].r, STATS_ICONS[stat].t, STATS_ICONS[stat].b)
        end
    end

    if newTexture ~= self.icon:GetTexture() then
        self.icon:SetTexture(newTexture)
    end
end
GW.AddForProfiling("paperdoll_equipment", "setStatIcon", setStatIcon)

local function getStatListFrame(self)
    local frame = self.statsFramePool:Acquire()

    if not frame.initialized then
        frame.Value:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        frame.Value:SetText(ERRORS)
        frame.Label:SetFont(UNIT_NAME_FONT, 1)
        frame.Label:SetTextColor(0, 0, 0, 0)

        frame:SetScript("OnLeave", GameTooltip_Hide)

        frame.onEnterFunc = nil
        frame.initialized = true
    end

    return frame
end
GW.AddForProfiling("paperdoll_equipment", "getStatListFrame", getStatListFrame)

local function updateStats(self)
    local average, equipped = GW.GetPlayerItemLevel()
    local itemLevelText = math.floor(equipped)
    if equipped < average then
        itemLevelText = itemLevelText .. "(" .. math.floor(average) .. ")"
    end
    self.itemLevel:SetText(itemLevelText)
    self.itemLevel:SetTextColor(GetItemLevelColor())

    local primaryStat = select(6, C_SpecializationInfo.GetSpecializationInfo(GW.myspec, nil, nil, nil, GW.mysex))

    self.statsFramePool:ReleaseAll()

    local grid, x, y = 1, 0, 0

    for _, category in ipairs(PAPERDOLL_STATCATEGORIES) do
        for _, stat in ipairs(category.stats) do
            local showStat = true
            if stat.primary and stat.primary ~= primaryStat then
                showStat = false
            end
            if showStat and stat.roles then
                showStat = tContains(stat.roles, GW.myrole)
            end

            local frame = getStatListFrame(self)
            frame.UpdateTooltip = nil
            PAPERDOLL_STATINFO[stat.stat].updateFunc(frame, "player")

            if showStat and (not stat.hideAt or stat.hideAt ~= frame.numericValue) then
                frame.stat = stat.stat
                setStatIcon(frame, stat.stat)

                frame:ClearAllPoints()
                frame:SetPoint("TOPLEFT", self.stats, "TOPLEFT", 5 + x, -35 - y)
                frame:Show()

                grid = grid + 1
                x = x + 92

                if grid > 2 then
                    grid = 1
                    x = 0
                    y = y + 35
                end
            else
                self.statsFramePool:Release(frame)
            end
        end
    end

    -- Add Durability Icon
    local durabilityFrame = getStatListFrame(self)
    durabilityFrame:ClearAllPoints()
    durabilityFrame:SetPoint("TOPLEFT", self.stats, "TOPLEFT", 5 + x, -35 - y)
    durabilityFrame:Show()
    durabilityFrame.stat = "DURABILITY"
    durabilityFrame.onEnterFunc = nil
    durabilityFrame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/globe/repair.png")
    durabilityFrame.icon:SetTexCoord(0, 1, 0, 0.5)
    durabilityFrame.icon:SetDesaturated(true)
    durabilityFrame:SetScript("OnEnter", GW.DurabilityTooltip)
    durabilityFrame:SetScript("OnEvent", GW.DurabilityOnEvent)
    durabilityFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    durabilityFrame:RegisterEvent("MERCHANT_SHOW")
    GW.DurabilityOnEvent(durabilityFrame, "ForceUpdate")
end
GW.AddForProfiling("paperdoll_equipment", "updateStats", updateStats)

local function stats_QueuedUpdate(self)
    self:SetScript("OnUpdate", nil)
    updateStats(self:GetParent())
end

local function updateUnitData(self)
    self.characterName:SetText(UnitPVPName("player"))
    local name = select(2, C_SpecializationInfo.GetSpecializationInfo(GW.myspec, nil, nil, nil, GW.mysex))

    if name ~= nil then
        local data = LEVEL .. " " .. GW.mylevel .. " " .. name .. " " .. GW.myLocalizedClass
        self.characterData:SetWidth(180)
        self.characterData:SetText(data)
    end
end
GW.AddForProfiling("paperdoll_equipment", "updateUnitData", updateUnitData)

local function stats_OnEvent(self, event, ...)
    local unit = ...
    local parent = self:GetParent()
    if (IsIn(event, "UNIT_MODEL_CHANGED", "UNIT_NAME_UPDATE") and unit == "player") or event == "PLAYER_ENTERING_WORLD" then
        parent.model:SetUnit("player", false)
        updateUnitData(parent)
        return
    end

    if not GW.inWorld then
        return
    end

    if unit == "player" then
        if event == "UNIT_LEVEL" then
            updateUnitData(parent)
        elseif IsIn(event, "UNIT_DAMAGE", "UNIT_ATTACK_SPEED", "UNIT_RANGEDDAMAGE", "UNIT_ATTACK", "UNIT_STATS", "UNIT_RANGED_ATTACK_POWER", "UNIT_SPELL_HASTE",
                "UNIT_MAXHEALTH", "UNIT_AURA", "UNIT_RESISTANCES", "SPEED_UPDATE") then
            self:SetScript("OnUpdate", stats_QueuedUpdate)
        end
    end
    if IsIn(event,"COMBAT_RATING_UPDATE", "MASTERY_UPDATE", "SPEED_UPDATE", "LIFESTEAL_UPDATE", "AVOIDANCE_UPDATE", "BAG_UPDATE", "PLAYER_EQUIPMENT_CHANGED",
            "PLAYERBANKSLOTS_CHANGED", "PLAYER_AVG_ITEM_LEVEL_UPDATE", "PLAYER_DAMAGE_DONE_MODS") then
        self:SetScript("OnUpdate", stats_QueuedUpdate)
    elseif (event == "PLAYER_TALENT_UPDATE") then
        updateUnitData(parent)
        self:SetScript("OnUpdate", stats_QueuedUpdate)
    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "COLOR_OVERRIDES_RESET" or event == "COLOR_OVERRIDE_UPDATED" then
        updateStats(parent)
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
    local _, _, _, startX, _ = self:GetPoint()

    GW.AddToAnimation(
        self:GetDebugName(),
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

local function setupTexture(tex, parent, point, file, coord, size)
    tex:SetTexture(file)
    if coord ~= nil then
        tex:SetTexCoord(unpack(coord))
    end

    if size then tex:SetSize(unpack(size)) end
    if point ~= nil then
        tex:SetPoint(unpack(point))
    else
        tex:SetAllPoints(parent)
    end
end

local function CreateItemSetGlow(slot, size, parent)
    if not slot then return end

    slot.itemSetBorderIndicator = CreateFrame("Frame", nil, slot)
    slot.itemSetBorderIndicator:SetSize(size * 1.5, size * 1.5)
    slot.itemSetBorderIndicator:SetPoint("TOPLEFT", slot, "TOPLEFT", -size * .25, size * .25)
    slot.itemSetBorderIndicator:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", size * .25, -size * .25)
    slot.itemSetBorderIndicator:SetFrameLevel(slot:GetFrameLevel() - 1)

    slot.itemSetBorderIndicator.Glow = slot.itemSetBorderIndicator:CreateTexture(nil, "OVERLAY")
    setupTexture(slot.itemSetBorderIndicator.Glow, slot.itemSetBorderIndicator, nil, "Interface/SpellActivationOverlay/IconAlert", {0.00781250, 0.50781250, 0.53515625, 0.78515625})
    slot.itemSetBorderIndicator.Glow:SetBlendMode("ADD")

    slot.itemSetBorderShimmer = CreateFrame("Frame", nil, slot)
    slot.itemSetBorderShimmer:SetSize(size * 1.5, size * 1.5)
    slot.itemSetBorderShimmer:SetAllPoints(slot)
    slot.itemSetBorderShimmer:SetFrameLevel(slot:GetFrameLevel() + 2)
    slot.itemSetBorderShimmer:SetClipsChildren(true)

    local shimmerTexPath = "Interface/AddOns/GW2_UI/textures/uistuff/glow.png"
    local shimmerA = slot.itemSetBorderShimmer:CreateTexture(nil, "OVERLAY")
    shimmerA:SetTexture(shimmerTexPath)
    shimmerA:SetSize(size, size)
    shimmerA:SetPoint("LEFT", slot.itemSetBorderShimmer, "LEFT", 0, 0)
    shimmerA:SetBlendMode("ADD")
    shimmerA:SetAlpha(0.05)
    shimmerA:SetScale(4)

    -- Zweite Texture (rechts neben der ersten)
    local shimmerB = slot.itemSetBorderShimmer:CreateTexture(nil, "OVERLAY")
    shimmerB:SetTexture(shimmerTexPath)
    shimmerB:SetSize(size, size)
    shimmerB:SetPoint("LEFT", shimmerA, "RIGHT", 0, 0)
    shimmerB:SetBlendMode("ADD")
    shimmerB:SetAlpha(0.05)
    shimmerB:SetScale(4)

    slot.itemSetBorderShimmer.Lightning = slot.itemSetBorderShimmer:CreateTexture(nil, "OVERLAY")
    slot.itemSetBorderShimmer.Lightning:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/sparks.png")
    slot.itemSetBorderShimmer.Lightning:SetPoint("TOPLEFT", slot.itemSetBorderShimmer, "TOPLEFT", -size, size)
    slot.itemSetBorderShimmer.Lightning:SetPoint("BOTTOMRIGHT", slot.itemSetBorderShimmer, "BOTTOMRIGHT", size, -size)
    slot.itemSetBorderShimmer.Lightning:SetBlendMode("ADD")
    slot.itemSetBorderShimmer.Lightning:SetAlpha(0)
    slot.itemSetBorderShimmer.Lightning:SetScale(1)

    local ag = slot:CreateAnimationGroup()

    local pulseOut = ag:CreateAnimation("Alpha")
    pulseOut:SetTarget(slot.itemSetBorderIndicator.Glow)
    pulseOut:SetFromAlpha(1)
    pulseOut:SetToAlpha(0.7)
    pulseOut:SetDuration(1.0)
    pulseOut:SetOrder(1)

    local pulseIn = ag:CreateAnimation("Alpha")
    pulseIn:SetTarget(slot.itemSetBorderIndicator.Glow)
    pulseIn:SetFromAlpha(0.7)
    pulseIn:SetToAlpha(1)
    pulseIn:SetDuration(1.0)
    pulseIn:SetOrder(2)

    local trans = ag:CreateAnimation("Translation")
    trans:SetTarget(shimmerA)
    trans:SetOffset(-size, 0)
    trans:SetDuration(10.0)
    trans:SetSmoothing("NONE")
    trans:SetOrder(1)

    local transB = ag:CreateAnimation("Translation")
    transB:SetTarget(shimmerB)
    transB:SetOffset(-size, 0)
    transB:SetDuration(10.0)
    transB:SetSmoothing("NONE")
    transB:SetOrder(1)

    -- 5. Animation einstellen
    ag:SetLooping("REPEAT")

    local ag2 = slot:CreateAnimationGroup()
    local inA  = ag2:CreateAnimation("Alpha")
    inA:SetTarget(slot.itemSetBorderShimmer.Lightning)
    inA:SetFromAlpha(0)
    inA:SetToAlpha(0.8)
    inA:SetDuration(0.1)
    inA:SetOrder(1)
    local outA = ag2:CreateAnimation("Alpha")
    outA:SetTarget(slot.itemSetBorderShimmer.Lightning)
    outA:SetFromAlpha(0.8)
    outA:SetToAlpha(0)
    outA:SetDuration(0.2)
    outA:SetOrder(2)

    slot.itemSetAnimationRunning = false
    slot.itemSetTimer = nil

    function slot:StartSetIndicatorAnimation()
        if self.itemSetAnimationRunning then return end
        self.itemSetAnimationRunning = true

        self.itemSetBorderShimmer:Show()
        self.itemSetBorderIndicator:Show()

        ag:Play()
        ag2:Play()

        -- Starte mit zufälliger Verzögerung
        local function StartBlitzLoop()
            if not self.itemSetAnimationRunning then return end
            local nextDelay = math.random(8, 15)
            self.itemSetTimer = C_Timer.NewTimer(nextDelay, function()
                if not self.itemSetAnimationRunning then return end
                ag2:Play()
                StartBlitzLoop()
            end)
        end

        -- Initial leicht zufällig verzögert starten
        C_Timer.After(math.random(0, 2), StartBlitzLoop)
    end

    function slot:StopSetIndicatorAnimation()
        self.itemSetBorderShimmer:Hide()
        self.itemSetBorderIndicator:Hide()

        if not self.itemSetAnimationRunning then return end
        self.itemSetAnimationRunning = false

        ag:Stop()
        ag2:Stop()

        if self.itemSetTimer then
            self.itemSetTimer:Cancel()
            self.itemSetTimer = nil
        end
    end

    parent:HookScript("OnHide", function()
        slot:StopSetIndicatorAnimation()
    end)
end


local function grabDefaultSlots(slot, anchor, parent, size)
    slot:ClearAllPoints()
    slot:SetPoint(unpack(anchor))
    slot:SetParent(parent)
    slot:SetSize(size, size)
    slot:GwStripTextures()

    setupTexture(slot.icon, slot, nil, {0.07, 0.93, 0.07, 0.93})
    slot.icon:SetAlpha(0.9)

    setupTexture(slot.IconBorder, slot, nil, "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    slot.IconBorder:SetParent(slot)

    -- Remove normal texture
    local normalTexture = slot:GetNormalTexture()
    if normalTexture then
        normalTexture:SetTexture(nil)
    end

    GW.RegisterCooldown(_G[slot:GetName()..'Cooldown'])

    local high = slot:GetHighlightTexture()
    setupTexture(high, slot, nil, "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)

    slot.repairIcon = slot:CreateTexture(nil, "OVERLAY")
    setupTexture(slot.repairIcon, slot, {"BOTTOMRIGHT", slot, "BOTTOMRIGHT"}, "Interface/AddOns/GW2_UI/textures/globe/repair.png", {0, 1, 0.5, 1}, {20, 20})

    CreateItemSetGlow(slot, size, parent)

    slot.itemlevel = slot:CreateFontString(nil, "OVERLAY")
    slot.itemlevel:SetSize(size, 10)
    slot.itemlevel:SetPoint("BOTTOMLEFT", 1, 2)
    slot.itemlevel:SetTextColor(1, 1, 1)
    slot.itemlevel:SetJustifyH("LEFT")
    slot.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "THINOUTLINE")

    slot.ignoreSlotCheck = CreateFrame("CheckButton", nil, slot, "GWIgnoreSlotCheck")

    local overlay = slot.IconOverlay
    setupTexture(overlay, slot, nil, nil, {0.07, 0.93, 0.07, 0.93})
    overlay:SetAtlas("Nzoth-inventory-icon")
    overlay:ClearAllPoints()
    overlay:SetPoint("TOPLEFT", overlay:GetParent(), "TOPLEFT", 1, -1)
    overlay:SetPoint("BOTTOMRIGHT", overlay:GetParent(), "BOTTOMRIGHT", -1, 1)

    slot.overlayButton = CreateFrame("Button", nil, slot)
    slot.overlayButton:SetAllPoints()
    slot.overlayButton:Hide()
    slot.overlayButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
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
        self:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    end)

    slot:HookScript("OnShow", CorruptionIcon)
    slot:HookScript("OnEvent", CorruptionIcon)

    EquipSlotList[#EquipSlotList + 1] = slot:GetID()
    slotButtons[#slotButtons + 1] = slot

    updateItemSlot(slot)

    slot.IsGW2Hooked = true
end

local function SetupCharacterSlots(slots, parent)
    for _, v in ipairs(slots) do
        local slot, anchorParent, point, relativePoint, xOffset, yOffset, size = unpack(v)
        grabDefaultSlots(slot, {point, anchorParent, relativePoint, xOffset, yOffset}, parent, size)
    end
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

local function ItemLevelTooltip(self)
    local average, equipped, _, averageLocal, equippedLocal, pvpItemLevelLocal = GW.GetPlayerItemLevel()
    local minItemLevel = C_PaperDollInfo.GetMinItemLevel()
    local displayItemLevel = math.max(minItemLevel or 0, equipped)

    self.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL) .. " " .. averageLocal
    if displayItemLevel ~= average then
        self.tooltip = self.tooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED:gsub("%%d", "%%s"), equippedLocal)
    end
    self.tooltip = self.tooltip .. FONT_COLOR_CODE_CLOSE
    self.tooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP
    self.tooltip2 = self.tooltip2 .. "\n\n" .. STAT_AVERAGE_PVP_ITEM_LEVEL:gsub("%%d", "%%s"):format(pvpItemLevelLocal)
    if not self.tooltip then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(self.tooltip)
    if self.tooltip2 then
        GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
    end
    GameTooltip:Show()
end

local function RegisterStatsEvents(frame)
    local events = {
        "PLAYER_ENTERING_WORLD",
        "CHARACTER_POINTS_CHANGED",
        "UNIT_MODEL_CHANGED",
        "UNIT_LEVEL",
        "UNIT_STATS",
        "UNIT_RANGEDDAMAGE",
        "UNIT_ATTACK_POWER",
        "UNIT_RANGED_ATTACK_POWER",
        "UNIT_ATTACK",
        "UNIT_SPELL_HASTE",
        "UNIT_RESISTANCES",
        "PLAYER_GUILD_UPDATE",
        "SKILL_LINES_CHANGED",
        "COMBAT_RATING_UPDATE",
        "MASTERY_UPDATE",
        "SPEED_UPDATE",
        "LIFESTEAL_UPDATE",
        "AVOIDANCE_UPDATE",
        "KNOWN_TITLES_UPDATE",
        "UNIT_NAME_UPDATE",
        "PLAYER_TALENT_UPDATE",
        "BAG_UPDATE",
        "PLAYER_EQUIPMENT_CHANGED",
        "PLAYERBANKSLOTS_CHANGED",
        "PLAYER_AVG_ITEM_LEVEL_UPDATE",
        "PLAYER_DAMAGE_DONE_MODS",
        "ACTIVE_TALENT_GROUP_CHANGED",
        "COLOR_OVERRIDES_RESET",
        "COLOR_OVERRIDE_UPDATED",
        "SPELL_POWER_CHANGED",
        "CHARACTER_ITEM_FIXUP_NOTIFICATION",
    }

    for _, event in ipairs(events) do
        frame:RegisterEvent(event)
    end
    frame:RegisterUnitEvent("UNIT_DAMAGE", "player")
    frame:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player")
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    frame:RegisterUnitEvent("UNIT_AURA", "player")
end

local function ResetBagSlotFrame(_, f)
    f.location = nil
    f.itemSlot = nil
    f.itemId = nil
    f.quality = nil
    f.__gwLastItemLink = nil
    if f.ResetAzeriteItem then
        f:ResetAzeriteItem()
    end

    if f.repairIcon then
        f.repairIcon:Hide()
        f.repairIcon:SetTexCoord(0, 1, 0, 0.5)
    end

    if f.IconOverlay then
        f.IconOverlay:Hide()
    end

    f.UpdateTooltip = nil

    f:SetAlpha(0)
    f.BACKGROUND:SetAlpha(0)
    f.itemlevel:SetAlpha(0)
    f.repairIcon:SetAlpha(0)

    if f.fadeInAnim then
        f.fadeInAnim:Stop()
    end

    f:ClearAllPoints()
    f:Hide()
end

local function ResetStatsFrame(_, f)
    f:SetScript("OnEvent", nil)
    f:SetScript("OnEnter", stat_OnEnter)
    f:UnregisterAllEvents()
    f:ClearAllPoints()
    f:Hide()
end

local function LoadPDBagList(fmMenu, parent)
    local fmGDR = CreateFrame("Button", "GwDressingRoom", parent, "GwDressingRoom")
    local fmPD3M = fmGDR.model
    local fmGPDS = fmGDR.stats
    local fmGPDBIL = CreateFrame("Frame", "GwPaperDollBagItemList", parent, "GwPaperDollBagItemList")

    --frame pools
    fmGDR.statsFramePool = CreateFramePool("Frame", fmGPDS, "GwPaperDollStat", ResetStatsFrame)
    bagSlotFramePool = CreateFramePool("ItemButton", fmGPDBIL, "GwPaperDollBagItem", ResetBagSlotFrame)

    parent.CharWindow.dressingRoom = fmGDR

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
    }

    local characterSlots = {
        -- Format: {SlotFrame, AnchorParent, AnchorPoint, RelativePoint, XOffset, YOffset, Size}
        {CharacterHeadSlot,      fmGDR.gear,                "TOPLEFT", "TOPLEFT",    0,  0, 50},
        {CharacterShoulderSlot,  CharacterHeadSlot,         "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterChestSlot,     CharacterShoulderSlot,     "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterWristSlot,     CharacterChestSlot,        "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterHandsSlot,     CharacterWristSlot,        "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterWaistSlot,     CharacterHandsSlot,        "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterLegsSlot,      CharacterWaistSlot,        "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterFeetSlot,      CharacterLegsSlot,         "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},
        {CharacterMainHandSlot,  CharacterFeetSlot,         "TOPLEFT", "BOTTOMLEFT", 0, -20, 50},
        {CharacterSecondaryHandSlot, CharacterMainHandSlot, "TOPLEFT", "BOTTOMLEFT", 0, -5, 50},

        {CharacterTabardSlot,    fmGDR.stats,           "TOPRIGHT", "BOTTOMRIGHT", -5, -20, 40},
        {CharacterShirtSlot,     CharacterTabardSlot,   "TOPRIGHT", "BOTTOMRIGHT",  0, -5, 40},
        {CharacterTrinket0Slot,  CharacterTabardSlot,   "TOPRIGHT", "TOPLEFT",     -5, 0, 40},
        {CharacterTrinket1Slot,  CharacterTrinket0Slot, "TOPRIGHT", "BOTTOMRIGHT",  0, -5, 40},
        {CharacterFinger0Slot,   CharacterTrinket0Slot, "TOPRIGHT", "TOPLEFT",     -5, 0, 40},
        {CharacterFinger1Slot,   CharacterFinger0Slot,  "TOPRIGHT", "BOTTOMRIGHT",  0, -5, 40},
        {CharacterNeckSlot,      CharacterFinger0Slot,  "TOPRIGHT", "TOPLEFT",     -5, 0, 40},
        {CharacterBackSlot,      CharacterNeckSlot,     "TOPRIGHT", "BOTTOMRIGHT",  0, -5, 40},
    }

    SetupCharacterSlots(characterSlots, fmGDR)

    hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
        if not button.IsGW2Hooked then return end
        local textureName = GetInventoryItemTexture("player", button:GetID())
        if not textureName then
            button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/slot-bg.png")
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

    local pos = modelPositions[GW.myrace]
    if pos then
        fmPD3M:SetPosition(unpack(pos))
    else
        fmPD3M:SetPosition(0.8, 0, 0) -- fallback
    end

    fmPD3M:SetRotation(-0.15)
    Model_OnLoad(fmPD3M, 4, 0, -0.1, CharacterModelFrame_OnMouseUp)

    fmPD3M:SetScript("OnReceiveDrag", EquipCursorItem)
    fmPD3M:HookScript("OnMouseDown", EquipCursorItem)

    fmGPDS.header:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    fmGPDS.header:SetText(STAT_CATEGORY_ATTRIBUTES)
    fmGPDS:SetScript("OnEvent", stats_OnEvent)
    RegisterStatsEvents(fmGPDS)

    fmGDR.characterName:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    fmGDR.characterData:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    fmGDR.itemLevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)

    local color = GWGetClassColor(GW.myclass, true)
    SetClassIcon(fmGDR.classIcon, GW.myClassID)
    fmGDR.classIcon:SetVertexColor(color.r, color.g, color.b, color.a)
    fmGDR:SetScript("OnClick", resetBagInventory)

    fmGDR.itemLevelFrame:SetScript("OnEnter", ItemLevelTooltip)
    fmGDR.itemLevelFrame:SetScript("OnLeave", GameTooltip_Hide)

    fmGPDBIL:SetScript("OnEvent", bagItemListOnEvent)
    fmGPDBIL:SetScript("OnHide", resetBagInventory)
    fmGPDBIL:SetScript("OnShow", GwPaperDollBagItemList_OnShow)
    fmGPDBIL:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    fmMenu:SetupBackButton(fmGPDBIL.backButton, CHARACTER .. ": " .. BAG_FILTER_EQUIPMENT)

    local fmGPDSI = CreateFrame("Frame", "GwPaperDollSelectedIndicator", fmGDR, "GwPaperDollSelectedIndicator")
    fmGPDSI:SetScript("OnShow", indicatorAnimation)

    updateBagItemListAll()
    updateStats(fmGDR)

    return fmGDR, fmGPDBIL
end
GW.LoadPDBagList = LoadPDBagList
