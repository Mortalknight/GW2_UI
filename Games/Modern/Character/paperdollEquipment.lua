---@class GW2
local GW = select(2, ...)
GW.char_equipset_SavedItems = {}

-- everything the hero panel's equipment view shares between Retail and Forever: bag item list,
-- slot takeover, set glow, set bonus tile, stat tile pool. The flavors add slot layout, stat
-- source and their client specific extras through the options of CreateBagList
local PDE = {}
GW.PaperDollEquipment = PDE

local EquipSlotList = {}
local slotButtons = {}
local bagItemList = {}
local selectedInventorySlot = nil
local bagSlotFramePool
local bagItemListWaitScheduled = false
local bagItemListQueued = false
local options = {}

local function SetupTexture(tex, parent, point, file, coord, size)
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
PDE.SetupTexture = SetupTexture

local function SetItemButtonQuality(button, quality)
    local color = quality and GW.GetQualityColor(quality)
    if color and quality >= Enum.ItemQuality.Common then
        button.IconBorder:Show()
        button.IconBorder:SetVertexColor(color.r, color.g, color.b)
        if button.itemSetBorderIndicator then
            button.itemSetBorderIndicator.Glow:SetVertexColor(color.r, color.g, color.b)
            button.itemSetBorderShimmer.Lightning:SetVertexColor(color.r, color.g, color.b)
        end
    else
        button.IconBorder:Hide()
    end
end
PDE.SetItemButtonQuality = SetItemButtonQuality

---------- bag item list ----------

local function UpdateBagItemButton(button)
    local location = button.location
    if not location then
        return
    end
    local id, _, textureName, count, durability, maxDurability, _, _, _, _, _, setTooltip, quality = EquipmentManager_GetItemInfoByLocation(location)

    button.itemId = id
    button.quality = quality

    if textureName then
        SetItemButtonTexture(button, textureName)
        SetItemButtonCount(button, count)

        if maxDurability and durability == 0 then
            SetItemButtonTextureVertexColor(button, 0.9, 0, 0)
        else
            SetItemButtonTextureVertexColor(button, 1, 1, 1)
        end

        if durability and (durability / maxDurability) < 0.5 then
            button.repairIcon:Show()
            button.repairIcon:SetTexCoord(0, 1, durability == 0 and 0.5 or 0, durability == 0 and 1 or 0.5)
        else
            button.repairIcon:Hide()
        end

        button.UpdateTooltip = function()
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT", 6, -EquipmentFlyoutFrame.buttonFrame:GetHeight() - 6)
            setTooltip()
        end

        SetItemButtonQuality(button, quality)
    end

    if options.onBagItemUpdated then
        options.onBagItemUpdated(button)
    end
end

local GetBagSlotFrame

local function PlaceBagItems(slotIDs)
    bagSlotFramePool:ReleaseAll()

    local gridIndex, itemIndex = 1, 1
    local x, y = 10, 15

    for _, id in ipairs(slotIDs) do
        wipe(bagItemList)
        GetInventoryItemsForSlot(id, bagItemList)
        for location, itemLink in pairs(bagItemList) do
            if not (location - id == ITEM_INVENTORY_LOCATION_PLAYER) then
                local itemFrame = GetBagSlotFrame()
                itemFrame.location = location
                itemFrame.itemLink = itemLink
                itemFrame.itemSlot = id

                UpdateBagItemButton(itemFrame)

                itemFrame:ClearAllPoints()
                itemFrame:SetPoint("TOPLEFT", x, -y)
                itemFrame:Show()

                itemFrame.fadeInAnim:Stop()
                local row = math.floor((itemIndex - 1) / 4)
                itemFrame.fadeIn:SetStartDelay(row * 0.05 + ((itemIndex - 1) % 4) * 0.015)
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
                    return
                end
            end
        end
    end
end

local function UpdateBagItemList(itemButton)
    local id = itemButton.id or itemButton:GetID()
    if selectedInventorySlot ~= id or InCombatLockdown() then
        return
    end
    PlaceBagItems({id})
end

local function UpdateBagItemListAll()
    if selectedInventorySlot ~= nil or InCombatLockdown() then
        return
    end
    PlaceBagItems(EquipSlotList)
end
PDE.UpdateBagItemListAll = UpdateBagItemListAll

local function ActionButtonGlobalStyle(self)
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

    self.itemlevel:SetPoint("BOTTOMLEFT", 1, 2)
    self.itemlevel:SetTextColor(1, 1, 1)
    self.itemlevel:SetJustifyH("LEFT")
    self.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")

    if options.styleBagItem then
        options.styleBagItem(self)
    end
end

local function BagSlot_OnEnter(self)
    self:SetScript("OnUpdate", self.UpdateTooltip)
    GameTooltip:Show()
end

local function BagSlot_OnLeave(self)
    self:SetScript("OnUpdate", nil)
    GameTooltip_Hide()
end

local function BagSlot_OnClick(self)
    if not self.location then
        return
    end
    if UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[self.itemSlot] then
        UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0)
        return
    end
    EquipmentManager_RunAction(EquipmentManager_EquipItemByLocation(self.location, self.itemSlot))
end

---------- equipment slots ----------

local function UpdateItemSlot(self)
    local slot = self:GetID()
    if GW.char_equipset_SavedItems[slot] == nil then
        GW.char_equipset_SavedItems[slot] = self
        self.ignoreSlotCheck:SetScript("OnClick", function()
            if not self.ignoreSlotCheck:GetChecked() then
                C_EquipmentSet.IgnoreSlotForSave(slot)
            else
                C_EquipmentSet.UnignoreSlotForSave(slot)
            end
        end)
    end

    local textureName = GetInventoryItemTexture("player", slot)
    if textureName then
        if GetInventoryItemBroken("player", slot) or GetInventoryItemEquippedUnusable("player", slot) then
            SetItemButtonTextureVertexColor(self, 0.9, 0, 0)
        else
            SetItemButtonTextureVertexColor(self, 1, 1, 1)
        end

        local current, maximum = GetInventoryItemDurability(slot)
        if current ~= nil and (current / maximum) < 0.5 then
            self.repairIcon:Show()
            self.repairIcon:SetTexCoord(0, 1, current == 0 and 0.5 or 0, current == 0 and 1 or 0.5)
        else
            self.repairIcon:Hide()
        end
        self.hasItem = 1
    else
        self.repairIcon:Hide()
        self.hasItem = false
    end

    SetItemButtonQuality(self, GetInventoryItemQuality("player", slot))

    if self.isSetItem then
        self:StartSetIndicatorAnimation()
    else
        self:StopSetIndicatorAnimation()
    end
end
PDE.UpdateItemSlot = UpdateItemSlot
GW.UpdateCharacterPanelItemSlot = UpdateItemSlot

local function ItemSlot_OnEvent(self, event, ...)
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        if self:GetID() == ... then
            UpdateItemSlot(self)
            UpdateBagItemList(self)
        end
    elseif event == "BAG_UPDATE_COOLDOWN" then
        UpdateItemSlot(self)
    end
end

GetBagSlotFrame = function()
    local f = bagSlotFramePool:Acquire()

    if not f.initialized then
        f:SetScript("OnEvent", ItemSlot_OnEvent)
        f:SetScript("OnClick", BagSlot_OnClick)
        f:SetScript("OnEnter", BagSlot_OnEnter)
        f:SetScript("OnLeave", BagSlot_OnLeave)
        ActionButtonGlobalStyle(f)

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
            GW.SetItemLevel(f, f.quality, f.itemLink)
        end)

        f.initialized = true
    end

    return f
end

local function BagItemListRun()
    bagItemListWaitScheduled = false
    if bagItemListQueued then
        bagItemListQueued = false
        UpdateBagItemListAll()
    end
end

local function BagItemList_OnEvent()
    bagItemListQueued = true
    if not bagItemListWaitScheduled then
        bagItemListWaitScheduled = true
        GW.Wait(1, BagItemListRun)
    end
end

local function ResetBagInventory()
    GwPaperDollSelectedIndicator:Hide()
    selectedInventorySlot = nil
    UpdateBagItemListAll()
    for _, slot in pairs(slotButtons) do
        slot.overlayButton:Hide()
    end
end

local function IndicatorAnimation(self)
    local _, _, _, startX = self:GetPoint()
    GW.AddToAnimation(self:GetDebugName(), 0, 1, GetTime(), 1, function(step)
        local point, relat, relPoint, _, yof = self:GetPoint()
        if step < 0.5 then
            self:SetPoint(point, relat, relPoint, startX + (-8 * step / 0.5), yof)
        else
            self:SetPoint(point, relat, relPoint, (startX - 8) + (8 * (step - 0.5) / 0.5), yof)
        end
    end, nil, function()
        if self:IsShown() then
            IndicatorAnimation(self)
        end
    end)
end

local function CreateItemSetGlow(slot, size, parent)
    slot.itemSetBorderIndicator = CreateFrame("Frame", nil, slot)
    slot.itemSetBorderIndicator:SetPoint("TOPLEFT", slot, "TOPLEFT", -size * .25, size * .25)
    slot.itemSetBorderIndicator:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", size * .25, -size * .25)
    slot.itemSetBorderIndicator:SetFrameLevel(slot:GetFrameLevel() - 1)

    slot.itemSetBorderIndicator.Glow = slot.itemSetBorderIndicator:CreateTexture(nil, "OVERLAY")
    SetupTexture(slot.itemSetBorderIndicator.Glow, slot.itemSetBorderIndicator, nil, "Interface/SpellActivationOverlay/IconAlert", {0.00781250, 0.50781250, 0.53515625, 0.78515625})
    slot.itemSetBorderIndicator.Glow:SetBlendMode("ADD")

    slot.itemSetBorderShimmer = CreateFrame("Frame", nil, slot)
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
    for _, shimmer in ipairs({shimmerA, shimmerB}) do
        local trans = ag:CreateAnimation("Translation")
        trans:SetTarget(shimmer)
        trans:SetOffset(-size, 0)
        trans:SetDuration(10.0)
        trans:SetSmoothing("NONE")
        trans:SetOrder(1)
    end
    ag:SetLooping("REPEAT")

    local ag2 = slot:CreateAnimationGroup()
    local inA = ag2:CreateAnimation("Alpha")
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

    function slot:StartSetIndicatorAnimation()
        if self.itemSetAnimationRunning then return end
        self.itemSetAnimationRunning = true
        self.itemSetBorderShimmer:Show()
        self.itemSetBorderIndicator:Show()
        ag:Play()
        ag2:Play()

        local function StartBlitzLoop()
            if not self.itemSetAnimationRunning then return end
            self.itemSetTimer = C_Timer.NewTimer(math.random(8, 15), function()
                if not self.itemSetAnimationRunning then return end
                ag2:Play()
                StartBlitzLoop()
            end)
        end
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

local function GrabDefaultSlots(slot, anchor, parent, size)
    slot:ClearAllPoints()
    slot:SetPoint(unpack(anchor))
    slot:SetParent(parent)
    slot:SetSize(size, size)
    slot:GwStripTextures()

    SetupTexture(slot.icon, slot, nil, {0.07, 0.93, 0.07, 0.93})
    slot.icon:SetAlpha(0.9)

    SetupTexture(slot.IconBorder, slot, nil, "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    slot.IconBorder:SetParent(slot)

    local normalTexture = slot:GetNormalTexture()
    if normalTexture then
        normalTexture:SetTexture(nil)
    end

    local cooldown = _G[slot:GetName() .. "Cooldown"]
    if cooldown then
        GW.RegisterCooldown(cooldown)
    end

    local high = slot:GetHighlightTexture()
    SetupTexture(high, slot, nil, "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)

    slot.repairIcon = slot:CreateTexture(nil, "OVERLAY")
    SetupTexture(slot.repairIcon, slot, {"BOTTOMRIGHT", slot, "BOTTOMRIGHT"}, "Interface/AddOns/GW2_UI/textures/globe/repair.png", {0, 1, 0.5, 1}, {20, 20})

    CreateItemSetGlow(slot, size, parent)

    slot.itemlevel = slot:CreateFontString(nil, "OVERLAY")
    slot.itemlevel:SetSize(size, 10)
    slot.itemlevel:SetPoint("BOTTOMLEFT", 1, 2)
    slot.itemlevel:SetTextColor(1, 1, 1)
    slot.itemlevel:SetJustifyH("LEFT")
    slot.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")

    slot.ignoreSlotCheck = CreateFrame("CheckButton", nil, slot, "GWIgnoreSlotCheck")

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
            UpdateBagItemListAll()
            self.isEquipmentSelected = false
        else
            GwPaperDollSelectedIndicator:ClearAllPoints()
            GwPaperDollSelectedIndicator:SetPoint("LEFT", self:GetParent(), "LEFT", -16, 0)
            GwPaperDollSelectedIndicator:Show()
            selectedInventorySlot = self:GetParent():GetID()
            UpdateBagItemList(self:GetParent())
            self.isEquipmentSelected = true
        end
    end)
    slot.overlayButton:SetScript("OnEnter", function() slot:GetScript("OnEnter")(slot) end)
    slot.overlayButton:SetScript("OnLeave", function() slot:GetScript("OnLeave")(slot) end)

    hooksecurefunc(slot.IconBorder, "SetVertexColor", function(self)
        self:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    end)

    if options.onGrabSlot then
        options.onGrabSlot(slot)
    end

    EquipSlotList[#EquipSlotList + 1] = slot:GetID()
    slotButtons[#slotButtons + 1] = slot

    UpdateItemSlot(slot)
    slot.IsGW2Hooked = true
end

---------- stat tiles ----------

local function Stat_OnEnter(self)
    if not self.tooltip then
        if self.onEnterFunc and not InCombatLockdown() then
            pcall(self.onEnterFunc, self)
        end
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltip, 1, 1, 1, 1, true)
    if self.tooltip2 then
        GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, self.lineWrap ~= false)
    end
    GameTooltip:Show()
end

function PDE.GetStatListFrame(dressingRoom)
    local frame = dressingRoom.statsFramePool:Acquire()

    if not frame.initialized then
        frame.Value:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        frame.Value:SetText(ERRORS)
        frame.Label:SetFont(UNIT_NAME_FONT, 1)
        frame.Label:SetTextColor(0, 0, 0, 0)
        frame.icon:SetSize(30, 30)
        frame.icon:SetPoint("TOPLEFT")

        frame:SetScript("OnEnter", Stat_OnEnter)
        frame:SetScript("OnLeave", GameTooltip_Hide)
        GW.StatsPicker.RegisterTile(dressingRoom.stats, frame)

        -- text glyph used instead of the icon by the set and mythic+ tiles
        frame.glyph = frame:CreateFontString(nil, "OVERLAY")
        frame.glyph:SetPoint("CENTER", frame.icon, "CENTER")
        frame.glyph:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        frame.glyph:Hide()
        frame.initialized = true
    end

    return frame
end

-- a tile that is not a character stat (set bonus, mythic+ rating): text glyph instead of an icon
function PDE.AddSpecialTile(dressingRoom, entries, editMode, key, glyphText, valueText, color, onEnter, data)
    local visible = GW.StatsPicker.IsVisible(key, true)
    if not (visible or editMode) then return end

    local frame = PDE.GetStatListFrame(dressingRoom)
    frame.stat = key
    frame.gwStatVisible = visible
    frame.icon:Hide()
    frame.glyph:SetText(glyphText)
    frame.glyph:Show()
    frame.Value:SetText(valueText)
    frame.Value:SetTextColor(color.r, color.g, color.b)
    frame.tooltip = nil
    frame.onEnterFunc = onEnter
    frame.set = data
    tinsert(entries, frame)
end

function PDE.AddDurabilityTile(dressingRoom, entries)
    local durabilityFrame = PDE.GetStatListFrame(dressingRoom)
    durabilityFrame.stat = "DURABILITY"
    durabilityFrame.gwStatVisible = true
    tinsert(entries, durabilityFrame)
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

---------- set bonus ----------

-- "%s (%d/%d)" -> name, worn, total; "(%d) Set: %s" -> inactive bonus; "Set: %s" -> active bonus.
-- Some locales use positional placeholders like "%1$s (%2$d/%3$d)".
local function FormatToPattern(fmt)
    return (fmt:gsub("%(", "%%("):gsub("%)", "%%)"):gsub("%%%d*%$?s", "(.+)"):gsub("%%%d*%$?d", "(%%d+)"))
end
local MATCH_SET_NAME = FormatToPattern(ITEM_SET_NAME)
local MATCH_SET_BONUS_GRAY = FormatToPattern(ITEM_SET_BONUS_GRAY)
local MATCH_SET_BONUS = FormatToPattern(ITEM_SET_BONUS)
local SET_BONUS_SLOTS = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
local equippedSets = {}

local function CollectEquippedSets()
    wipe(equippedSets)
    for _, slot in ipairs(SET_BONUS_SLOTS) do
        local data = C_TooltipInfo.GetInventoryItem("player", slot)
        local set, collectBonuses
        for _, line in ipairs(data and data.lines or {}) do
            local text = line.leftText
            if text and not set then
                local name, worn, total = strmatch(text, MATCH_SET_NAME)
                if name then
                    set = equippedSets[name]
                    if not set then
                        set = {name = name, worn = tonumber(worn), total = tonumber(total), bonuses = {}, maxItemLevel = 0, maxItemID = 0}
                        equippedSets[name] = set
                        collectBonuses = true
                    end
                    -- newest set = highest item level, ties by item id
                    local itemLevel = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(slot)) or 0
                    set.maxItemLevel = max(set.maxItemLevel, itemLevel)
                    set.maxItemID = max(set.maxItemID, data.id or 0)
                end
            elseif text and collectBonuses and strmatch(text, MATCH_SET_BONUS) then
                tinsert(set.bonuses, {text = text, color = line.leftColor, active = not strmatch(text, MATCH_SET_BONUS_GRAY)})
            end
        end
    end
end

function PDE.SetBonus_OnEnter(self)
    local set = self.set
    if not set then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(format("%s (%d/%d)", set.name, set.worn, set.total), 1, 1, 1)
    for _, bonus in ipairs(set.bonuses) do
        local color = bonus.color
        GameTooltip:AddLine(bonus.text, color and color.r or 1, color and color.g or 1, color and color.b or 1, true)
    end
    GameTooltip:Show()
end

-- with several sets worn the newest one wins: highest item level, then item id, then worn pieces
local function IsNewerSet(set, other)
    if set.maxItemLevel ~= other.maxItemLevel then
        return set.maxItemLevel > other.maxItemLevel
    end
    if set.maxItemID ~= other.maxItemID then
        return set.maxItemID > other.maxItemID
    end
    return set.worn > other.worn
end

function PDE.GetBestEquippedSet()
    CollectEquippedSets()
    local best
    for _, set in pairs(equippedSets) do
        if not best or IsNewerSet(set, best) then
            best = set
        end
    end
    if not best then return end

    local activeBonuses = 0
    for _, bonus in ipairs(best.bonuses) do
        if bonus.active then
            activeBonuses = activeBonuses + 1
        end
    end
    best.allBonusesActive = activeBonuses == #best.bonuses
    best.anyBonusActive = activeBonuses > 0
    return best
end

function PDE.AddSetBonusTile(dressingRoom, entries, editMode)
    local set = PDE.GetBestEquippedSet()
    if set then
        local color = set.allBonusesActive and GREEN_FONT_COLOR or set.anyBonusActive and YELLOW_FONT_COLOR or GRAY_FONT_COLOR
        PDE.AddSpecialTile(dressingRoom, entries, editMode, "SETBONUS", "Set", set.worn .. "/" .. set.total, color, PDE.SetBonus_OnEnter, set)
    elseif editMode then
        PDE.AddSpecialTile(dressingRoom, entries, editMode, "SETBONUS", "Set", "-", GRAY_FONT_COLOR, PDE.SetBonus_OnEnter)
    end
end

---------- item level ----------

function PDE.UpdateItemLevel(dressingRoom)
    local average, equipped = GW.GetPlayerItemLevel()
    local itemLevelText = math.floor(equipped)
    if equipped < average then
        itemLevelText = itemLevelText .. "(" .. math.floor(average) .. ")"
    end
    dressingRoom.itemLevel:SetText(itemLevelText)
    dressingRoom.itemLevel:SetTextColor(GetItemLevelColor())
end

local function ItemLevelTooltip(self)
    local average, equipped, _, averageLocal, equippedLocal, pvpItemLevelLocal = GW.GetPlayerItemLevel()
    local displayItemLevel = math.max(C_PaperDollInfo.GetMinItemLevel() or 0, equipped)

    local tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL) .. " " .. averageLocal
    if displayItemLevel ~= average then
        tooltip = tooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED:gsub("%%d", "%%s"), equippedLocal)
    end
    local tooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP
    if pvpItemLevelLocal and STAT_AVERAGE_PVP_ITEM_LEVEL then
        tooltip2 = tooltip2 .. "\n\n" .. STAT_AVERAGE_PVP_ITEM_LEVEL:gsub("%%d", "%%s"):format(pvpItemLevelLocal)
    end
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(tooltip .. FONT_COLOR_CODE_CLOSE, 1, 1, 1, 1, true)
    GameTooltip:AddLine(tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
    GameTooltip:Show()
end

---------- pools ----------

local function ResetBagSlotFrame(_, f)
    f.location = nil
    f.itemSlot = nil
    f.itemLink = nil
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
    f:SetScript("OnUpdate", nil)
    f:SetAlpha(1)
    f.icon:Show()
    if f.glyph then -- the pool resets new frames before they are initialized
        f.glyph:Hide()
    end
    f.gwStatVisible = nil
    f.set = nil
    f.Value:SetTextColor(1, 1, 1)
    f:SetScript("OnEvent", nil)
    f:UnregisterAllEvents()
    f:ClearAllPoints()
    f:Hide()
    f.UpdateTooltip = nil
    f.onEnterFunc = nil
    f.stat = nil
    f.tooltip = nil
    f.tooltip2 = nil
    f.lineWrap = nil
end

---------- assembly ----------

-- options:
--   characterSlots(dressingRoom) -> {{slot, anchorParent, point, relativePoint, x, y, size}, ...}
--   slotBackground, playerSlots  -> empty slot art and its tex coords per slot name
--   statsTileParent(stats)       -> parent of the stat tiles, defaults to the stats box
--   updateStats(dressingRoom)    -> fills the stat tiles
--   updateUnitData(dressingRoom) -> name and level line
--   onGrabSlot, styleBagItem, onBagItemUpdated -> client specific extras on the buttons
function PDE.CreateBagList(fmMenu, parent, flavorOptions)
    options = flavorOptions

    local fmGDR = CreateFrame("Button", "GwDressingRoom", parent, "GwDressingRoom")
    local fmPD3M = fmGDR.model
    GW.HandleModelControlFrame(fmPD3M.controlFrame)
    local fmGPDS = fmGDR.stats
    local fmGPDBIL = CreateFrame("Frame", "GwPaperDollBagItemList", parent, "GwPaperDollBagItemList")

    local tileParent = options.statsTileParent and options.statsTileParent(fmGPDS) or fmGPDS
    fmGDR.statsFramePool = CreateFramePool("Frame", tileParent, "GwPaperDollStat", ResetStatsFrame)
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

    for _, v in ipairs(options.characterSlots(fmGDR)) do
        local slot, anchorParent, point, relativePoint, xOffset, yOffset, size = unpack(v)
        if slot then
            GrabDefaultSlots(slot, {point, anchorParent, relativePoint, xOffset, yOffset}, fmGDR, size)
        end
    end

    hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
        if not button.IsGW2Hooked then return end
        if not GetInventoryItemTexture("player", button:GetID()) then
            button.icon:SetTexture(options.slotBackground)
            button.icon:SetTexCoord(unpack(options.playerSlots[button:GetName()]))
        else
            button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        end
        UpdateItemSlot(button)
    end)

    EquipmentFlyoutFrame:GwKill()
    EquipmentFlyoutFrame:SetScript("OnUpdate", nil)
    EquipmentFlyoutFrame:SetScript("OnShow", nil)
    EquipmentFlyoutFrame:SetScript("OnLoad", nil)

    GW.SetPaperDollModelPosition(fmPD3M)

    fmGPDS.header:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    fmGPDS.header:SetText(STAT_CATEGORY_ATTRIBUTES)

    fmGDR.characterName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    fmGDR.characterData:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    fmGDR.itemLevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)

    local color = GW.GWGetClassColor(GW.myclass, true)
    GW.SetClassIcon(fmGDR.classIcon, GW.myClassID)
    fmGDR.classIcon:SetVertexColor(color.r, color.g, color.b, color.a)
    fmGDR:SetScript("OnClick", ResetBagInventory)
    fmGDR.itemLevelFrame:SetScript("OnEnter", ItemLevelTooltip)
    fmGDR.itemLevelFrame:SetScript("OnLeave", GameTooltip_Hide)

    GW.StatsPicker.Setup(fmGPDS, fmGDR, function() options.updateStats(fmGDR) end)

    fmGPDBIL:SetScript("OnEvent", BagItemList_OnEvent)
    fmGPDBIL:SetScript("OnHide", ResetBagInventory)
    fmGPDBIL:SetScript("OnShow", function()
        UpdateBagItemListAll()
        for _, slot in pairs(slotButtons) do
            slot.overlayButton:Show()
        end
    end)
    fmGPDBIL:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    fmMenu:SetupBackButton(fmGPDBIL.backButton, CHARACTER .. ": " .. BAG_FILTER_EQUIPMENT)

    local fmGPDSI = CreateFrame("Frame", "GwPaperDollSelectedIndicator", fmGDR, "GwPaperDollSelectedIndicator")
    fmGPDSI:SetScript("OnShow", IndicatorAnimation)

    if options.updateUnitData then
        options.updateUnitData(fmGDR)
    end
    UpdateBagItemListAll()
    options.updateStats(fmGDR)

    return fmGDR, fmGPDBIL
end
