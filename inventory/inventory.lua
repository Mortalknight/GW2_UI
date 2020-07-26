local _, GW = ...
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local setItemLevel = GW.setItemLevel


-- global for this deprecated in 8.3; from ContainerFrame.lua
local MAX_CONTAINER_ITEMS = 36

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
        b.IconQuestTexture = qtex
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

    if not b.scrapIcon then
        b.scrapIcon = b:CreateTexture(nil, "OVERLAY", nil, 2)
        b.scrapIcon:SetAtlas("bags-icon-scrappable")
        b.scrapIcon:SetSize(14, 12)
        b.scrapIcon:SetPoint("TOPLEFT", 0, 0)
        b.scrapIcon:Hide()
    end

    if not b.itemlevel then
        b.itemlevel = b:CreateFontString(nil, "OVERLAY")
        b.itemlevel:SetFont(UNIT_NAME_FONT, 12)
        b.itemlevel:SetPoint("BOTTOMRIGHT", 0, 0)
        b.itemlevel:SetText("")
    end
end
GW.AddForProfiling("inventory", "reskinItemButton", reskinItemButton)

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

local function CheckUpdateIcon_OnUpdate(self, elapsed)
    self.timeSinceUpgradeCheck = (self.timeSinceUpgradeCheck or 0) + elapsed
    if self.timeSinceUpgradeCheck >= 0.5 then
        GW.CheckUpdateIcon(self)
        self.timeSinceUpgradeCheck = 0
    end
end

local function CheckUpdateIcon(button)
    local itemIsUpgrade = IsContainerItemAnUpgrade(button:GetParent():GetID(), button:GetID())
    if itemIsUpgrade == nil then -- nil means not all the data was available to determine if this is an upgrade.
        button.UpgradeIcon:SetShown(false)
        button:SetScript("OnUpdate", CheckUpdateIcon_OnUpdate)
    else
        button.UpgradeIcon:SetShown(itemIsUpgrade)
        button:SetScript("OnUpdate", nil)
    end
end
GW.CheckUpdateIcon = CheckUpdateIcon

local function hookItemQuality(button, quality, itemIDOrLink, suppressOverlays)
    if not button.gwBackdrop then
        return
    end
    local t = button.IconBorder
    t:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
    t:SetAlpha(0.9)

    if not GetSetting("BAG_ITEM_QUALITY_BORDER_SHOW") then
        t:SetVertexColor(BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_COMMON].r, BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_COMMON].g, BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_COMMON].b)
    end

    local professionColors = GW.professionBagColor[select(2, GetContainerNumFreeSlots(button:GetParent():GetID()))]
    if GetSetting("BAG_PROFESSION_BAG_COLOR") and professionColors then
        t:SetVertexColor(professionColors.r, professionColors.g, professionColors.b)
        t:Show()
    end

    if itemIDOrLink then
        if not suppressOverlays then
            if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemIDOrLink) then
                button.IconOverlay:SetAtlas("AzeriteIconFrame")
                button.IconOverlay:Show()
            elseif IsCorruptedItem(itemIDOrLink) then
                button.IconOverlay:SetAtlas("Nzoth-inventory-icon")
                button.IconOverlay:Show()
            end
        end
        -- Show junk icon if active
        local texture, count, locked, rarity, readable, _, itemLink, _, noValue = GetContainerItemInfo(button:GetParent():GetID(), button:GetID())
        button.isJunk = (rarity and rarity == LE_ITEM_QUALITY_POOR) and not noValue

        if button.junkIcon then
            if button.isJunk and GetSetting("BAG_ITEM_JUNK_ICON_SHOW") then
                button.junkIcon:Show()
            else
                button.junkIcon:Hide()
            end
        end
        -- Show scrap icon if active
        if button.scrapIcon then
            if GetSetting("BAG_ITEM_SCRAP_ICON_SHOW") then
                local itemLoc = ItemLocation:CreateFromBagAndSlot(button:GetParent():GetID(), button:GetID())
                if itemLoc and itemLoc ~= "" then
                    if (C_Item.DoesItemExist(itemLoc) and C_Item.CanScrapItem(itemLoc)) then
                        button.scrapIcon:SetShown(itemLoc)
                    else
                        button.scrapIcon:SetShown(false)
                    end
                end
            else
                button.scrapIcon:SetShown(false)
            end
        end
        -- Show upgrade icon if active
        if GetSetting("BAG_ITEM_UPGRADE_ICON_SHOW") and button.UpgradeIcon then
            CheckUpdateIcon(button)
        end

        -- Show ilvl if active
        if button.itemlevel and GetSetting("BAG_SHOW_ILVL") then
            setItemLevel(button, quality, itemIDOrLink)
        elseif button.itemlevel then
            button.itemlevel:SetText("")
        end
    else
        if button.junkIcon then button.junkIcon:Hide() end
        if button.scrapIcon then button.scrapIcon:Hide() end
        if button.UpgradeIcon then
            button.UpgradeIcon:Hide()
            button:SetScript("OnUpdate", nil)
        end
        if button.itemlevel then button.itemlevel:SetText("") end
    end
end
GW.AddForProfiling("inventory", "hookItemQuality", hookItemQuality)

local function hookQuestItemBorder(self)
    local id = self:GetID()
    local name = self:GetName()
    
    for i=1, self.size, 1 do
        local itemButton = _G[name .. "Item" .. i]
        local isQuestItem, questId, isActive = GetContainerItemQuestInfo(id, itemButton:GetID())
        if itemButton.IconQuestTexture then
            if questId or isQuestItem then
                itemButton.IconQuestTexture:SetTexture("Interface/AddOns/GW2_UI/textures/bag/stancebar-border")
            end
        end
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

local function freeItemButtons(cf, p, bag_id)
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
    elseif bag_id == REAGENTBANK_CONTAINER then
        iname = "ReagentBankFrameItem"
        cf.gw_source = nil -- we never have to give back reagentbank ItemButtons
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

local function reskinBagBar(b, ha)
    local bag_size = 28
    local highlightAlpha = ha and ha or 0

    b:SetSize(bag_size, bag_size)
    b.tooltipText = BANK_BAG
    
    b.Count:ClearAllPoints()
    b.Count:SetPoint("TOPRIGHT", b, "TOPRIGHT", 0, -3)
    b.Count:SetFont(UNIT_NAME_FONT, 12, "THINOUTLINED")
    b.Count:SetJustifyH("RIGHT")

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
        b.SlotHighlightTexture:SetAlpha(highlightAlpha)
        b.SlotHighlightTexture:SetTexture("Interface/AddOns/GW2_UI/textures/UI-Quickslot-Depress")
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
    if button ~= "RightButton" then
        return
    end
    if not self.GetBagID then
        return
    end

    local bag_id = self:GetBagID()
    if self.gwHasBag or bag_id == BACKPACK_CONTAINER then
        local cf = getContainerFrame(bag_id)
        if cf and cf.FilterDropDown then
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            ToggleDropDownMenu(1, nil, cf.FilterDropDown, self, 32, 32)
        end
    end
end
GW.AddForProfiling("inventory", "bag_OnMouseDown", bag_OnMouseDown)

-- positions ItemButtons fluidly for this container
local function layoutContainerFrame(cf, max_col, row, col, rev, item_off)
    if not cf or not cf.gw_num_slots or cf.gw_num_slots <= 0 then
        return col, row
    end

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
            end
        end
    end

    return col, row
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

    local cols = f.gw_bag_cols

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

    local rows = math.ceil(slots / cols)
    local isize = size + padding
    f:SetHeight(max((isize * rows) + 75, min_height))
    f:SetWidth((isize * cols) + padding + 2)
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

local function LoadDefaultBagBar()
    -- if not our bags, we need to cut the bagbar frame out of the micromenu
    reskinBagBar(MainMenuBarBackpackButton, 1)
    reskinBagBar(CharacterBag0Slot, 1)
    reskinBagBar(CharacterBag1Slot, 1)
    reskinBagBar(CharacterBag2Slot, 1)
    reskinBagBar(CharacterBag3Slot, 1)

    SetItemButtonQuality(MainMenuBarBackpackButton, 1, nil)

    MainMenuBarBackpackButton:ClearAllPoints()
    CharacterBag0Slot:ClearAllPoints()
    CharacterBag1Slot:ClearAllPoints()
    CharacterBag2Slot:ClearAllPoints()
    CharacterBag3Slot:ClearAllPoints()

    MainMenuBarBackpackButton:SetParent(UIParent)
    CharacterBag0Slot:SetParent(UIParent)
    CharacterBag1Slot:SetParent(UIParent)
    CharacterBag2Slot:SetParent(UIParent)
    CharacterBag3Slot:SetParent(UIParent)

    CharacterBag3Slot:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -500, 20)
    CharacterBag2Slot:SetPoint("LEFT", CharacterBag3Slot, "RIGHT", 0, 0)
    CharacterBag1Slot:SetPoint("LEFT", CharacterBag2Slot, "RIGHT", 0, 0)
    CharacterBag0Slot:SetPoint("LEFT", CharacterBag1Slot, "RIGHT", 0, 0)
    MainMenuBarBackpackButton:SetPoint("LEFT", CharacterBag0Slot, "RIGHT", 0, 0)
end
GW.LoadDefaultBagBar = LoadDefaultBagBar

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
    hooksecurefunc("SetItemButtonQuality", hookItemQuality)

    hooksecurefunc("ContainerFrame_Update", hookQuestItemBorder)

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

    -- Skin StackSplit
    local StackSplitFrame = _G.StackSplitFrame
    StackSplitFrame:StripTextures()
    StackSplitFrame:SetBackdrop(GW.skins.constBackdropFrame)

    StackSplitFrame.OkayButton:SkinButton(false, true)
    StackSplitFrame.CancelButton:SkinButton(false, true)

    StackSplitFrame.RightButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrow_right")
    StackSplitFrame.RightButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrow_right")
    StackSplitFrame.RightButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrow_right")
    StackSplitFrame.RightButton:SetSize(25, 25)
    StackSplitFrame.RightButton:SetPoint("LEFT", StackSplitFrame, "CENTER", 51, 18)

    StackSplitFrame.LeftButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrow_right")
    StackSplitFrame.LeftButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrow_right")
    StackSplitFrame.LeftButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrow_right")
    StackSplitFrame.LeftButton:SetSize(25, 25)
    StackSplitFrame.LeftButton:GetNormalTexture():SetTexCoord(1, 0, 1, 0)
    StackSplitFrame.LeftButton:GetPushedTexture():SetTexCoord(1, 0, 1, 0)
    StackSplitFrame.LeftButton:GetDisabledTexture():SetTexCoord(1, 0, 1, 0)
    StackSplitFrame.LeftButton:SetPoint("RIGHT", StackSplitFrame, "CENTER", -50, 18)
end
GW.LoadInventory = LoadInventory
