local _, GW = ...
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local BAG_TYP_COLORS = GW.BAG_TYP_COLORS

BAG_FILTER_LABELS = {
    [LE_BAG_FILTER_FLAG_EQUIPMENT] = BAG_FILTER_EQUIPMENT,
    [LE_BAG_FILTER_FLAG_CONSUMABLES] = BAG_FILTER_CONSUMABLES,
    [LE_BAG_FILTER_FLAG_TRADE_GOODS] = BAG_FILTER_TRADE_GOODS,
    [LE_BAG_FILTER_FLAG_JUNK] = BAG_FILTER_JUNK,
};

-- reskins an ItemButton to use GW2_UI styling
local item_size
local function reskinItemButton(iname, b)
    b:SetSize(item_size, item_size)

    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b.icon:SetAllPoints(b)
    b.icon:SetAlpha(0.9)

    b.IconBorder:SetAllPoints(b)
    b.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")

    local norm = b:GetNormalTexture()
    norm:SetTexture(nil)

    local high = b:GetHighlightTexture()
    high:SetAllPoints(b)
    high:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)

    b:SetPushedTexture(nil)

    if not b.gwBackdrop then
        local bd = b:CreateTexture(nil, "BACKGROUND")
        bd:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitembackdrop")
        bd:SetAllPoints(b)
        b.gwBackdrop = bd
    end

    b.Count:ClearAllPoints()
    b.Count:SetPoint("TOPRIGHT", b, "TOPRIGHT", 0, -3)
    b.Count:SetFont(UNIT_NAME_FONT, 12, "THINOUTLINED")
    b.Count:SetJustifyH("RIGHT")

    local qtex = b.IconQuestTexture or _G[iname .. "IconQuestTexture"]
    if qtex then
        qtex:SetSize(item_size + 2, item_size + 2)
        qtex:ClearAllPoints()
        qtex:SetPoint("CENTER", b, "CENTER", 0, 0)
    end

    if b.flash then
        b.flash:SetAllPoints(b)
    end

    if not b.junkIcon then
        b.junkIcon = b:CreateTexture(nil, "OVERLAY", nil, 2)
        b.junkIcon:SetAtlas("bags-junkcoin", true)
        b.junkIcon:SetPoint("TOPLEFT", -3, 3)
        b.junkIcon:Hide()
    end

    if not b.questIcon then
        b.questIcon = b:CreateTexture(nil, "OVERLAY", nil, 2)
        b.questIcon:SetTexture("Interface/AddOns/GW2_UI/textures/icon-quest")
        b.questIcon:SetSize(25, 25)
        b.questIcon:SetPoint("TOPLEFT", -7, 1)
        b.questIcon:SetVertexColor(221 / 255, 198 / 255, 68 / 255)
        b.questIcon:Hide()
    end

    if not b.itemlevel then
        b.itemlevel = b:CreateFontString(nil, "OVERLAY")
        b.itemlevel:SetFont(UNIT_NAME_FONT, 12, "THINOUTLINED")
        b.itemlevel:SetPoint("BOTTOMRIGHT", 0, 0)
        b.itemlevel:SetText("")
    end

    GW.RegisterCooldown(_G[b:GetName() .. "Cooldown"])
end
GW.AddForProfiling("inventory", "reskinItemButton", reskinItemButton)

local function getContainerFrame(bag_id)
    -- ContainerFrame assignment is not guaranteed; only safe approach is to
    -- search every ContainerFrame and check its ID for a match.
    for i = 1, NUM_CONTAINER_FRAMES do
        local cf = _G["ContainerFrame" .. i] 
        if cf and cf:GetID() == bag_id then
            return cf
        end
    end

    return nil
end
GW.AddForProfiling("inventory", "getContainerFrame", getContainerFrame)


local function reskinItemButtons()
    for i = 1, NUM_CONTAINER_FRAMES do
        for j = 1, MAX_CONTAINER_ITEMS do
            local iname = "ContainerFrame" .. i .. "Item" .. j
            local b = _G[iname]
            if b then
                reskinItemButton(iname, b)
            end
        end
    end
end
GW.AddForProfiling("inventory", "reskinItemButtons", reskinItemButtons)

local function hookUpdateAnchors()
    for i = 1, NUM_CONTAINER_FRAMES do
        local cf = _G["ContainerFrame" .. i]
        if cf then
            cf:ClearAllPoints()
            cf:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2000, 2000)
            cf:SetSize(10, 10)
        end
    end
end
GW.AddForProfiling("inventory", "hookUpdateAnchors", hookUpdateAnchors)

local function SetItemButtonQualityForBags(button, quality)
    button.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    button.IconOverlay:Hide()
    button.IconBorder:SetAlpha(0.9)

    if quality then
        if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
            button.IconBorder:Show()
            button.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
        else
            button.IconBorder:Hide()
        end
    else
        button.IconBorder:Hide()
    end
end
GW.SetItemButtonQualityForBags = SetItemButtonQualityForBags

local function IsItemEligibleForItemLevelDisplay(equipLoc, rarity)
    if ((equipLoc ~= nil and equipLoc ~= "" and equipLoc ~= "INVTYPE_BAG"
        and equipLoc ~= "INVTYPE_QUIVER" and equipLoc ~= "INVTYPE_TABARD"))
    and (rarity and rarity >= 1) then
        return true
    end

    return false
end

local function hookSetItemButtonQuality(button, quality, itemIDOrLink)
    if not button.gwBackdrop then
        return
    end
    local t = button.IconBorder
    t:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    t:SetAlpha(0.9)
    button.IconOverlay:Hide()

    local bag_id = button:GetParent():GetID()
    local keyring = (bag_id == KEYRING_CONTAINER)
    local professionColors = keyring and BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_WOW_TOKEN] or BAG_TYP_COLORS[select(2, GetContainerNumFreeSlots(bag_id))]
    local showItemLevel = button.itemlevel and itemIDOrLink and GetSetting("BAG_SHOW_ILVL") and not professionColors

    if itemIDOrLink then
        local isQuestItem = select(12, GetItemInfo(itemIDOrLink))

        if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
            t:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
            t:Show()
        else
            t:Hide()
        end

        if isQuestItem == LE_ITEM_CLASS_QUESTITEM then
            t:SetTexture("Interface/AddOns/GW2_UI/textures/bag/stancebar-border")
            t:Show()
            button.questIcon:Show()
        else
            button.questIcon:Hide()
        end

        -- Show junk icon if active
        local _, _, _, rarity, _, _, _, _, noValue = GetContainerItemInfo(bag_id, button:GetID())
        button.isJunk = (rarity and rarity == LE_ITEM_QUALITY_POOR) and not noValue

        if button.junkIcon then
            if button.isJunk and GetSetting("BAG_ITEM_JUNK_ICON_SHOW") then
                button.junkIcon:Show()
            else
                button.junkIcon:Hide()
            end
        end

        -- Show ilvl if active
        if showItemLevel then
            local canShowItemLevel = IsItemEligibleForItemLevelDisplay(select(9, GetItemInfo(itemIDOrLink)), quality)
            local iLvl = GetDetailedItemLevelInfo(itemIDOrLink)
            if canShowItemLevel and iLvl then
                local r, g, b = GetItemQualityColor(quality or 1)
                if quality >= LE_ITEM_QUALITY_COMMON and GetItemQualityColor(quality) then
                    r, g, b = GetItemQualityColor(quality)
                    button.itemlevel:SetTextColor(r, g, b, 1)
                end
                button.itemlevel:SetText(iLvl)
            else
                button.itemlevel:SetText("")
            end
        elseif button.itemlevel then
            button.itemlevel:SetText("")
        end
    else
        t:Hide()
        if button.junkIcon then button.junkIcon:Hide() end
        if button.questIcon then button.questIcon:Hide() end
        if button.itemlevel then button.itemlevel:SetText("") end
    end

    if not GetSetting("BAG_ITEM_QUALITY_BORDER_SHOW") then
        t:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        t:SetVertexColor(BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_COMMON].r, BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_COMMON].g, BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_COMMON].b)
    end

    if GetSetting("BAG_PROFESSION_BAG_COLOR") and professionColors then
        t:SetVertexColor(professionColors.r, professionColors.g, professionColors.b)
        t:Show()
    end

    --Keyring
    if keyring then
        t:Show()
        t:SetVertexColor(professionColors.r, professionColors.g, professionColors.b)
    end
end

local bag_resize
local bank_resize
local function resizeInventory()
    item_size = GetSetting("BAG_ITEM_SIZE")
    if item_size > 40 then
        item_size = 40
        SetSetting("BAG_ITEM_SIZE", 40)
    end
    reskinItemButtons()
    if bag_resize then
        bag_resize()
    end
    if bank_resize then
        bank_resize()
    end
end
GW.AddForProfiling("inventory", "resizeInventory", resizeInventory)

local function freeItemButtons(cf, p)
    -- return all of the ItemButtons we previously took before taking new ones, as long as
    -- we are still the frame that took them to start with (bank/bag might have grabbed
    -- them from each other in the mean-time)
    if cf.gw_source ~= nil then
        for i = 1, MAX_CONTAINER_ITEMS do
            local item = cf.gw_items[i]
            if item and item.gw_owner ~= nil and item.gw_owner == p then
                item:SetParent(cf.gw_source)
                item.gw_owner = nil
                item:ClearAllPoints()
                item:SetPoint("TOPLEFT", cf.gw_source, "TOPLEFT", 0, 0)
            end
        end
        cf.gw_num_slots = 0
        cf.gw_source = nil
        wipe(cf.gw_items)
    end
end
GW.AddForProfiling("inventory", "freeItemButtons", freeItemButtons)

local function takeItemButtons(p, bag_id)
    if not p or not bag_id then
        return
    end
    local cf = p.Containers[bag_id]
    if not cf then
        return
    end

    -- NOTE: taking ownership of CF ItemButtons seems to work without causing taint,
    -- amazingly; this is probably brittle in the long-term though and we should
    -- someday re-implemenent all the ItemButton functionality ourselves

    freeItemButtons(cf, p, bag_id)

    local iname
    if bag_id == BANK_CONTAINER then
        iname = "BankFrameItem"
        cf.gw_source = nil -- we never have to give back the bank ItemButtons
    elseif bag_id == KEYRING_CONTAINER then
        if IsBagOpen(bag_id) then
            local b = getContainerFrame(bag_id)
            if not b then
                return
            end

            cf.gw_source = b
            iname = b:GetName() .. "Item"
        else
            cf.gw_source = nil
            cf.gw_num_slots = 0
            return
        end
    else
        local b = getContainerFrame(bag_id)
        if not b then
            return
        end

        cf.gw_source = b
        iname = b:GetName() .. "Item"
    end
    cf.gw_owner = p

    local num_slots = GetContainerNumSlots(bag_id)
    cf.gw_num_slots = num_slots
    for i = 1, max(MAX_CONTAINER_ITEMS, num_slots) do
        local item = _G[iname .. i]
        if item then
            item:SetParent(cf)
            item.gw_owner = p
            cf.gw_items[i] = item
        end
    end
end
GW.AddForProfiling("inventory", "takeItemButtons", takeItemButtons)

local function reskinBagBar(b)
    local bag_size = 28

    b:SetSize(bag_size, bag_size)
    b.tooltipText = BANK_BAG

    if b.Count then
        b.Count:ClearAllPoints()
        b.Count:SetPoint("TOPRIGHT", b, "TOPRIGHT", 0, -3)
        b.Count:SetFont(UNIT_NAME_FONT, 12, "THINOUTLINED")
        b.Count:SetJustifyH("RIGHT")
    end

    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b.icon:SetAlpha(0.75)

    local norm = b:GetNormalTexture()
    norm:SetTexture(nil)

    b.IconBorder:SetAllPoints(b)
    b.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")

    local high = b:GetHighlightTexture()
    high:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)
    high:SetSize(bag_size, bag_size)
    high:ClearAllPoints()
    high:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)

    if b.SlotHighlightTexture then
        b.SlotHighlightTexture:SetAlpha(0)
    end

    b:SetPushedTexture(nil)
end
GW.AddForProfiling("inventory", "reskinBagBar", reskinBagBar)

-- reskins the default search boxes
local function reskinSearchBox(sb)
    if not sb then
        return
    end

    sb:SetFont(UNIT_NAME_FONT, 14)
    sb.Instructions:SetFont(UNIT_NAME_FONT, 14)
    sb.Instructions:SetTextColor(178 / 255, 178 / 255, 178 / 255)

    sb.Left:SetPoint("LEFT", 0, 0)

    sb.Left:SetTexture(nil)
    sb.Right:SetTexture(nil)
    sb.Middle:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagsearchbg")

    sb.Middle:SetPoint("RIGHT", sb, "RIGHT", 0, 0)

    sb.Middle:SetHeight(24)
    sb.Middle:SetTexCoord(unpack(GW.TexCoords))

    sb.searchIcon:Hide()
end
GW.AddForProfiling("inventory", "reskinSearchBox", reskinSearchBox)

-- (re)steals the default search boxes
local function relocateSearchBox(sb, f)
    if not sb or not f then
        return
    end

    sb:SetParent(f)
    sb:ClearAllPoints()
    sb:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -40)
    sb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -40)
    sb:SetHeight(24)
end
GW.AddForProfiling("inventory", "relocateSearchBox", relocateSearchBox)

-- on right click, open the bag filter dropdown (if valid) for this bag slot
local function bag_OnMouseDown(self, button)
    if button ~= "RightButton" or not self.gwHasBag or not ((self:GetID() - CharacterBag0Slot:GetID() + 1) > 0 and (self:GetID() - CharacterBag0Slot:GetID() + 1) < 5) then
        return
    end

    local bag_id = self:GetID() - CharacterBag0Slot:GetID() + 1
    local menuList = {}
    tinsert(menuList, { text = BAG_FILTER_ASSIGN_TO, isTitle = true, notCheckable = true })
    tinsert(menuList, { text = BAG_FILTER_IGNORE, checked = function() return GetBagSlotFlag(bag_id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP) end, func = function() SetBagSlotFlag(bag_id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not GetBagSlotFlag(bag_id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP)) end })
    GW.SetEasyMenuAnchor(GW.EasyMenu, self)
    _G.EasyMenu(menuList, GW.EasyMenu, nil, nil, nil, "MENU")
end
GW.AddForProfiling("inventory", "bag_OnMouseDown", bag_OnMouseDown)

-- positions ItemButtons fluidly for this container
local function layoutContainerFrame(cf, max_col, row, col, rev, item_off)
    if not cf or not cf.gw_num_slots or cf.gw_num_slots <= 0 then
        return col, row, false, 0
    end

    local unfinishedRow = false
    local startNewRow = false
    local finishedRows = 0
    local nS = cf.gw_num_slots
    local nE = 1
    local nD = -1
    if rev then
        nE = nS
        nS = 1
        nD = 1
    end

    for n = nS, nE, nD do
        local item = cf.gw_items[n]
        if item then
            item:ClearAllPoints()
            item:SetPoint("TOPLEFT", cf, "TOPLEFT", col * item_off, -row * item_off)
            col = col + 1
            if col >= max_col then
                col = 0
                row = row + 1
                finishedRows = finishedRows + 1
                startNewRow = true
            end
        end
    end

    if (startNewRow and col > 0 and col < max_col) or (not startNewRow and col < max_col) then
        unfinishedRow = true
    end

    return col, row, unfinishedRow, finishedRows
end
GW.AddForProfiling("inventory", "layoutContainerFrame", layoutContainerFrame)

local function updateFreeSpaceString(free, full)
    local bank_space_string = free .. " / " .. full
    GwBankFrame.spaceString:SetText(bank_space_string)
end
GW.AddForProfiling("inventory", "updateFreeSpaceString", updateFreeSpaceString)

-- update the number of free bank slots available and set the display for it
local function updateFreeSlots(sp_str, start_idx, end_idx, opt_container)
    if not sp_str or not sp_str.SetText then
        return
    end

    local free = 0
    local full = 0
    if opt_container then
        free = GetContainerNumFreeSlots(opt_container)
        full = GetContainerNumSlots(opt_container)
    end

    for bag_id = start_idx, end_idx do
        free = free + GetContainerNumFreeSlots(bag_id)
        full = full + GetContainerNumSlots(bag_id)
    end

    sp_str:SetText((full - free) .. " / " .. full)
    return free, full
end
GW.AddForProfiling("inventory", "updateFreeSlots", updateFreeSlots)

local function snapFrameSize(f, cfs, size, padding, min_height)
    if not f then
        return
    end

    local cols = f == GwBagFrame and f.gw_bag_cols or f.gw_bank_cols
    local sep = f == GwBagFrame and GetSetting("BAG_SEPARATE_BAGS") or false

    if not cfs then
        f:SetHeight(min_height)
        return
    end

    local slots = 0
    for _, cf in pairs(cfs) do
        if cf.gw_num_slots then
            slots = slots + cf.gw_num_slots
        end
    end

    local rows = 0
    local isize = size + padding
    if sep then
        local bags_equipped = 0
        for i = 1, 4 do
            local slotID = GetInventorySlotInfo("Bag" .. i - 1 .. "Slot")
            local itemID = GetInventoryItemID("player", slotID)

            if itemID then
                bags_equipped = bags_equipped + 1
            end
        end
        bags_equipped = bags_equipped + 1 --Keyring
        f.finishedRow = f.finishedRow and f.finishedRow or 0
        f.unfinishedRow = f.unfinishedRow and f.unfinishedRow or 0
        rows = f.finishedRow + bags_equipped + 1 + f.unfinishedRow
    else
        rows = math.ceil(slots / cols)
    end
    f:SetHeight(max((isize * rows) + 75, min_height))
    f:SetWidth((isize * cols) + padding + 2)
    for i = 0, 5 do
        if _G["GwBagFrameGwBagHeader" .. i] and sep then
            _G["GwBagFrameGwBagHeader" .. i]:SetWidth((isize * cols) + padding + 2 - 5)
            _G["GwBagFrameGwBagHeader" .. i].background:SetWidth((isize * cols) + padding + 2 - 5)
        end
    end
end
GW.AddForProfiling("inventory", "snapFrameSize", snapFrameSize)

local function onMoved(self, setting, snap_size)
    if not self then
        return
    end

    self:StopMovingOrSizing()
    -- check if frame is out of screen, if yes move it back
    ValidateFramePosition(self)

    local x = self:GetLeft()
    local y = self:GetTop()

    -- re-anchor to UIParent after the move
    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)

    -- store the updated position
    if setting then
        local pos = GetSetting(setting)
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point = "TOPLEFT"
        pos.relativePoint = "BOTTOMLEFT"
        pos.xOfs = x
        pos.yOfs = y
        SetSetting(setting, pos)
    end

    -- apply our snap sizing, if necessary
    if snap_size then
        snap_size(self)
    end
end
GW.AddForProfiling("inventory", "onMoved", onMoved)

local function colCount(size, padding, width)
    local isize = size + padding
    return math.floor((width - padding - 1) / isize)
end
GW.AddForProfiling("inventory", "colCount", colCount)

local function onSizerMouseDown(self, btn)
    if btn ~= "LeftButton" then
        return
    end
    local bfm = self:GetParent()
    bfm:StartSizing("BOTTOMRIGHT")
end
GW.AddForProfiling("inventory", "onSizerMouseDown", onSizerMouseDown)

local function onSizerMouseUp(self, btn)
    if btn ~= "LeftButton" then
        return
    end
    local bfm = self:GetParent()
    bfm:StopMovingOrSizing()
    if self.onResizeStop then
        self.onResizeStop(bfm)
    end
end
GW.AddForProfiling("inventory", "onSizerMouseUp", onSizerMouseUp)

local function onMoverDragStart(self)
    self:GetParent():StartMoving()
end
GW.AddForProfiling("inventory", "onMoverDragStart", onMoverDragStart)

local function onMoverDragStop(self)
    onMoved(self:GetParent(), self.onMoveSetting)
end
GW.AddForProfiling("inventory", "onMoverDragStop", onMoverDragStop)

local function LoadInventory()
    _G["BINDING_HEADER_GW2UI_INVENTORY_BINDINGS"] = INVENTORY_TOOLTIP
    _G["BINDING_NAME_GW2UI_BAG_SORT"] = BAG_CLEANUP_BAGS
    _G["BINDING_NAME_GW2UI_BANK_SORT"] = BAG_CLEANUP_BANK

    item_size = GetSetting("BAG_ITEM_SIZE")

    -- anytime a ContainerFrame has its anchors set, we re-hide it
    hooksecurefunc("UpdateContainerFrameAnchors", hookUpdateAnchors)

    -- reskin all the multi-use ContainerFrame ItemButtons
    reskinItemButtons()

    -- whenever an ItemButton sets its quality ensure our custom border is being used
    hooksecurefunc("SetItemButtonQuality", hookSetItemButtonQuality)

    -- un-hook ContainerFrame open event; this event isn't used anymore but just in case
    for i = 1, NUM_CONTAINER_FRAMES do
        local cf = _G["ContainerFrame" .. i]
        if cf then
            cf:UnregisterEvent("BAG_OPEN")
        end
    end

    local helpers = {}
    helpers.reskinItemButton = reskinItemButton
    helpers.resizeInventory = resizeInventory
    helpers.getContainerFrame = getContainerFrame
    helpers.takeItemButtons = takeItemButtons
    helpers.freeItemButtons = freeItemButtons
    helpers.reskinBagBar = reskinBagBar
    helpers.reskinSearchBox = reskinSearchBox
    helpers.relocateSearchBox = relocateSearchBox
    helpers.bag_OnMouseDown = bag_OnMouseDown
    helpers.layoutContainerFrame = layoutContainerFrame
    helpers.updateFreeSlots = updateFreeSlots
    helpers.snapFrameSize = snapFrameSize
    helpers.onMoved = onMoved
    helpers.colCount = colCount
    helpers.onSizerMouseDown = onSizerMouseDown
    helpers.onSizerMouseUp = onSizerMouseUp
    helpers.onMoverDragStart = onMoverDragStart
    helpers.onMoverDragStop = onMoverDragStop

    bag_resize = GW.LoadBag(helpers)
    bank_resize = GW.LoadBank(helpers)
end
GW.LoadInventory = LoadInventory
