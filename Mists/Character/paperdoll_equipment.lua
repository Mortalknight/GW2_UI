local _, GW = ...
GW.char_equipset_SavedItems = {}

-- forward function defs
local getBagSlotFrame

GW.slotButtons = {}
GW.equipSlotList = {}
local bagItemList = {}
local numBagSlotFrames = 0
GW.selectedInventorySlot = nil

local function actionButtonGlobalStyle(self)
    local name = self:GetName()
    self.IconBorder:SetSize(self:GetSize())
    _G[name .. "IconTexture"]:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    _G[name .. "NormalTexture"]:SetSize(self:GetSize())
    _G[name .. "NormalTexture"]:Hide()
    self.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")

    _G[name .. "NormalTexture"]:SetTexture(nil)
    self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed.png")
    self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    self:GetHighlightTexture():SetBlendMode("ADD")
    self:GetHighlightTexture():SetAlpha(0.33)

    self.itemlevel:SetPoint("BOTTOMLEFT", 1, 2)
    self.itemlevel:SetTextColor(1, 1, 1)
    self.itemlevel:SetJustifyH("LEFT")
    self.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "THINOUTLINE")
end

local function updateBagItemButton(button)
    local location = button.location
    if not location then
        return
    end

    local id, _, textureName, count, durability, maxDurability, _, _, _, _, _, setTooltip = EquipmentManager_GetItemInfoByLocation(location)
    local broken = (maxDurability and durability == 0)

    button.ItemId = id

    if textureName then
        SetItemButtonTexture(button, textureName)
        SetItemButtonCount(button, count)
        if broken then
            SetItemButtonTextureVertexColor(button, 0.9, 0, 0)
        else
            SetItemButtonTextureVertexColor(button, 1.0, 1.0, 1.0)
        end

        button.UpdateTooltip = function()
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT", 6, -EquipmentFlyoutFrame.buttonFrame:GetHeight() - 6)
            setTooltip()
        end

        local  _, _, quality = C_Item.GetItemInfo(id)
        if quality then
            GW.SetItemLevel(button, quality, button.itemLink)
            GW.SetItemButtonBorderQuality(button, quality)
        end
    end
end

local function updateBagItemListAll()
    if GW.selectedInventorySlot  ~= nil or InCombatLockdown() then
        return
    end

    local gridIndex = 1
    local itemIndex = 1
    local x = 10
    local y = 15

    for _, v in pairs(GW.equipSlotList) do
        local id = v

        wipe(bagItemList)

        GetInventoryItemsForSlot(id, bagItemList)

        for location, itemLink in next, bagItemList do
            if not (location - id == ITEM_INVENTORY_LOCATION_PLAYER) then -- Remove the currently equipped item from the list
                local itemFrame = getBagSlotFrame(itemIndex)
                itemFrame.location = location
                itemFrame.itemSlot = id
                itemFrame.itemLink = itemLink

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
GW.updateBagItemListAll = updateBagItemListAll

local function resetBagInventory()
    GwPaperDollSelectedIndicator:Hide()
    GW.selectedInventorySlot  = nil
    updateBagItemListAll()
    for _, slot in pairs(GW.slotButtons) do
        slot.overlayButton:Hide()
    end
end

local function GwPaperDollBagItemList_OnShow()
    updateBagItemListAll()
    for _, slot in pairs(GW.slotButtons) do
        slot.overlayButton:Show()
    end
end

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
    GW.SetItemButtonBorderQuality(self, quality)
end
GW.UpdateCharacterPanelItemSlot = updateItemSlot
GW.updateItemSlot = updateItemSlot

local function updateBagItemList(itemButton)
    local id = itemButton.id or itemButton:GetID()
    if GW.selectedInventorySlot  ~= id or InCombatLockdown() then
        return
    end

    wipe(bagItemList)

    GetInventoryItemsForSlot(id, bagItemList)

    local gridIndex = 1
    local itemIndex = 1
    local x = 10
    local y = 15

    for location, itemLink in next, bagItemList do
        if not (location - id == ITEM_INVENTORY_LOCATION_PLAYER) then -- Remove the currently equipped item from the list
            local itemFrame = getBagSlotFrame(itemIndex)
            itemFrame.location = location
            itemFrame.itemSlot = id
            itemFrame.itemLink = itemLink

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
GW.updateBagItemList = updateBagItemList

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

local function bagSlot_OnEnter(self)
    self:SetScript("OnUpdate", self.UpdateTooltip)
    GameTooltip:Show()
end

local function bagSlot_OnLeave(self)
    self:SetScript("OnUpdate", nil)
    GameTooltip_Hide()
end

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

getBagSlotFrame = function(i)
    local button = _G["gwPaperDollBagSlotButton" .. i]
    if button then
        button.itemLink = nil
        button.__gwLastItemLink = nil
        return button
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

local function LoadEquipments()
    GwDressingRoom:SetScript("OnClick", resetBagInventory)

    local fmGPDBIL = CreateFrame("Frame", "GwPaperDollBagItemList", GwCharacterWindowContainer, "GwPaperDollBagItemList")
    fmGPDBIL:SetScript("OnEvent", updateBagItemListAll)
    fmGPDBIL:SetScript("OnHide", resetBagInventory)
    fmGPDBIL:SetScript("OnShow", GwPaperDollBagItemList_OnShow)
    fmGPDBIL:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    updateBagItemListAll()

    local fmGPDSI = CreateFrame("Frame", "GwPaperDollSelectedIndicator", GwDressingRoom, "GwPaperDollSelectedIndicator")
    fmGPDSI:SetScript("OnShow", indicatorAnimation)
end
GW.LoadEquipments = LoadEquipments