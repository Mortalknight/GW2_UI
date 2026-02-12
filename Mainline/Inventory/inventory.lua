local _, GW = ...

-- global for this deprecated in 8.3; from ContainerFrame.lua
local MAX_CONTAINER_ITEMS = 36
local BORDER_TEXTURE = "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png"
local BACKDROP_TEXTURE = "Interface/AddOns/GW2_UI/textures/bag/bagitembackdrop.png"

-- reskins an ItemButton to use GW2_UI styling
local function ReskinItemButton(b, overrideIconSize)
    if not b then return end

    local iconSize = overrideIconSize or GW.settings.BAG_ITEM_SIZE
    b:SetSize(iconSize, iconSize)

    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b.icon:SetAllPoints(b)
    b.icon:SetAlpha(0.9)

    b.IconBorder:SetAllPoints(b)
    b.IconBorder:SetTexture(BORDER_TEXTURE)

    b:ClearNormalTexture()

    if b.NormalTexture then
        b.NormalTexture:SetTexture()
    end

    if not b.ItemSlotBackground then
        b.ItemSlotBackground = b:CreateTexture(nil, "BACKGROUND", "ItemSlotBackgroundCombinedBagsTemplate", -6);
		b.ItemSlotBackground:SetAllPoints(b)
    end

    if b.Background then
        b.Background:Hide()
    end

    if b.PushedTexture then
        b.PushedTexture:SetTexture()
    end

    b.ItemSlotBackground:SetAlpha(0)

    local high = b:GetHighlightTexture()
    high:SetAllPoints(b)
    high:SetTexture(BORDER_TEXTURE)
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)

    if not b.gwBackdrop then
        local bd = b:CreateTexture(nil, "BACKGROUND")
        bd:SetTexture(BACKDROP_TEXTURE)
        bd:SetAllPoints(b)
        b.gwBackdrop = bd
    end

    b.Count:ClearAllPoints()
    b.Count:SetPoint("TOPRIGHT", b, "TOPRIGHT", 0, -3)
    b.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "THINOUTLINE")
    b.Count:SetJustifyH("RIGHT")

    if b.IconQuestTexture then
        b.IconQuestTexture:ClearAllPoints()
        b.IconQuestTexture:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-quest.png")
        b.IconQuestTexture:SetSize(25, 25)
        b.IconQuestTexture:SetPoint("TOPLEFT", -7, 1)
        b.IconQuestTexture:SetVertexColor(221 / 255, 198 / 255, 68 / 255)
        if b.UpdateQuestItem then
            hooksecurefunc(b, "UpdateQuestItem", function()
                b.IconQuestTexture:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-quest.png")
            end)
        else --bank_slots
            hooksecurefunc(b, "Refresh", function()
                b.IconQuestTexture:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-quest.png")
            end)
        end
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
        b.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "THINOUTLINE")
        b.itemlevel:SetPoint("BOTTOMRIGHT", 0, 0)
        b.itemlevel:SetText("")
    end

    if b.cooldown then
        GW.RegisterCooldown(b.cooldown)
    elseif b.Cooldown then
        GW.RegisterCooldown(b.Cooldown)
    end
end
GW.SkinBagItemButton = ReskinItemButton

local function AssignItemData(slot)
    if not slot then return end
    local bagID, slotID = slot:GetBagID(), slot:GetID()
    if not bagID or not slotID then
        return
    end
    local info = C_Container.GetContainerItemInfo(bagID, slotID)
    if slot.SetHasItem then
        slot:SetHasItem(info and info.iconFileID)
        slot:SetItemButtonTexture(info and info.iconFileID)
    end
    GW.SetBagItemButtonQualitySkin(slot, info and info.quality, info and info.hyperlink, false)
end

local function UpdateItemVisuals(b, overrideIconSize)
   if not b or not b:IsShown() then return end

    local iconSize = overrideIconSize or GW.settings.BAG_ITEM_SIZE

    if b:GetWidth() ~= iconSize or b:GetHeight() ~= iconSize then
        b:SetSize(iconSize, iconSize)
    end

    local L, R, T, B = b.icon:GetTexCoord()
    if L ~= 0.07 or R ~= 0.93 or T ~= 0.07 or B ~= 0.93 then
        b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end
    if b.icon:GetAlpha() ~= 0.9 then
        b.icon:SetAlpha(0.9)
    end

    if b:GetHighlightTexture() then
        local high = b:GetHighlightTexture()
        if high ~= BORDER_TEXTURE then
            high:SetTexture(BORDER_TEXTURE)
        end
        if high:GetBlendMode() ~= "ADD" then
            high:SetBlendMode("ADD")
        end
        if high:GetAlpha() ~= 0.33 then
            high:SetAlpha(0.33)
        end
    end

    local point, _, relativePoint, x, y = b.Count:GetPoint()
    if point ~= "TOPRIGHT" or relativePoint ~= "TOPRIGHT" or x ~= 0 or y ~= -3 then
        b.Count:ClearAllPoints()
        b.Count:SetPoint("TOPRIGHT", b, "TOPRIGHT", 0, -3)
    end
    if b.Count:GetJustifyH() ~= "RIGHT" then
        b.Count:SetJustifyH("RIGHT")
    end

    if b.IconQuestTexture then
        local w, h = b.IconQuestTexture:GetSize()
        if w ~= 25 or h ~= 25 then
            b.IconQuestTexture:SetSize(25, 25)
        end
        point, _, _, x, y = b.IconQuestTexture:GetPoint()
        if point ~= "TOPLEFT" or x ~= -7 or y ~= 1 then
            b.IconQuestTexture:ClearAllPoints()
             b.IconQuestTexture:SetPoint("TOPLEFT", -7, 1)
        end
        if b.IconQuestTexture:GetTexture() ~= "Interface/AddOns/GW2_UI/textures/icons/icon-quest.png" then
            b.IconQuestTexture:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-quest.png")
        end
    end

    if b.flash then
        b.flash:SetAllPoints(b)
    end
end

local function reskinItemButtons()
    for i = 1, NUM_CONTAINER_FRAMES do
        local container = _G["ContainerFrame" .. i]
        for _, slot in next, container.Items do
            if slot then
                if not slot.__gwSkinned then
                    ReskinItemButton(slot) -- will only be trigger on first init
                    AssignItemData(slot)
                    slot.__gwSkinned = true
                end
                UpdateItemVisuals(slot)
            end
        end
    end
end

local function SetItemButtonData(button, quality, itemIDOrLink, suppressOverlays)
    if not button.gwBackdrop then
        return
    end

    local bag_id = button:GetParent():GetID()
    local isReagentBag = bag_id == 5

    local t = button.IconBorder
    local colorCommon = GW.GetBagItemQualityColor(Enum.ItemQuality.Common)
    t:SetTexture(BORDER_TEXTURE)
    t:SetAlpha(0.9)
    t:SetVertexColor(colorCommon.r, colorCommon.g, colorCommon.b)

    if not GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW then
        t:SetVertexColor(colorCommon.r, colorCommon.g, colorCommon.b)
    end

    local professionColors = isReagentBag and GW.GetBagItemQualityColor(Enum.ItemQuality.Artifact) or GW.professionBagColor[select(2, C_Container.GetContainerNumFreeSlots(bag_id))]
    if (GW.settings.BAG_PROFESSION_BAG_COLOR or isReagentBag) and professionColors then
        t:SetVertexColor(professionColors.r, professionColors.g, professionColors.b)
        t:Show()
    end

    if itemIDOrLink then
        if not suppressOverlays then
            if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemIDOrLink) then
                button.IconOverlay:SetAtlas("AzeriteIconFrame")
                button.IconOverlay:Show()
            elseif C_Item.IsCorruptedItem(itemIDOrLink) then
                button.IconOverlay:SetAtlas("Nzoth-inventory-icon")
                button.IconOverlay:Show()
            end
        end
        -- Show junk icon if active
        local itemInfo = C_Container.GetContainerItemInfo(bag_id, button:GetID())
        button.isJunk = itemInfo and ((itemInfo.quality and itemInfo.quality == Enum.ItemQuality.Poor) and not itemInfo.hasNoValue) or false

        if button.junkIcon then
            if button.isJunk and GW.settings.BAG_ITEM_JUNK_ICON_SHOW then
                button.junkIcon:Show()
            else
                button.junkIcon:Hide()
            end
        end
        -- Show scrap icon if active
        if button.scrapIcon then
            if GW.settings.BAG_ITEM_SCRAP_ICON_SHOW then
                local itemLoc = ItemLocation:CreateFromBagAndSlot(bag_id, button:GetID())
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
        if itemInfo and GW.settings.BAG_ITEM_UPGRADE_ICON_SHOW and button.UpgradeIcon then
            GW.RegisterPawnUpgradeIcon(button, itemInfo.hyperlink)
        elseif button.UpgradeIcon then
            button.UpgradeIcon:Hide()
        end

        -- Show ilvl if active
        if button.itemlevel and GW.settings.BAG_SHOW_ILVL then
            local canShowItemLevel = GW.IsItemEligibleForItemLevelDisplay(itemIDOrLink)
            if canShowItemLevel then
                GW.SetItemLevel(button, quality, itemIDOrLink)
            else
                button.itemlevel:SetText("")
                button.__gwLastItemLink = nil
            end
        elseif button.itemlevel then
            button.itemlevel:SetText("")
            button.__gwLastItemLink = nil
        end

        if GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW and quality and quality > 0 then
            local color = GW.GetBagItemQualityColor(quality)
            t:SetVertexColor(color.r, color.g, color.b)
        end

        t:Show()
        GetItemButtonIconTexture(button):Show()
    else
        if button.junkIcon then button.junkIcon:Hide() end
        if button.scrapIcon then button.scrapIcon:Hide() end
        if button.UpgradeIcon then button.UpgradeIcon:Hide() end
        if button.itemlevel then
            button.itemlevel:SetText("")
            button.__gwLastItemLink = nil
        end
        GetItemButtonIconTexture(button):Hide()
    end
end
GW.SetBagItemButtonQualitySkin = SetItemButtonData

local bag_resize
local bank_resize
local function resizeInventory()
    if GW.settings.BAG_ITEM_SIZE > 40 then
        GW.settings.BAG_ITEM_SIZE = 40
    end
    reskinItemButtons()
    if bag_resize then
        bag_resize()
    end
    if bank_resize then
        bank_resize()
    end
end


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


local function freeItemButtons(cf, p)
    -- return all of the ItemButtons we previously took before taking new ones, as long as
    -- we are still the frame that took them to start with (bank/bag might have grabbed
    -- them from each other in the mean-time)
    if cf and cf.gw_source ~= nil then
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

    freeItemButtons(cf, p)

    local iname
    local useItemsTable = true
    if bag_id == BANK_CONTAINER then
        useItemsTable = false
        iname = "BankFrameItem"
        cf.gw_source = nil -- we never have to give back the bank ItemButtons
    elseif bag_id == REAGENTBANK_CONTAINER then
        useItemsTable = false
        iname = "ReagentBankFrameItem"
        cf.gw_source = nil -- we never have to give back reagentbank ItemButtons
        --TODO new Bank
    else
        local b = getContainerFrame(bag_id)
        if not b then
            return
        end
        cf.gw_source = b
        iname = b:GetName()
    end
    cf.gw_owner = p

    local num_slots = ContainerFrame_GetContainerNumSlots(bag_id)
    cf.gw_num_slots = num_slots

    if useItemsTable then
        local container = _G[iname]
        local idx = 1
        for _, item in next, container.Items do
            if item then
                item:SetParent(cf)
                item.gw_owner = p
                cf.gw_items[idx] = item
                idx = idx + 1
            end
        end
    else
        for i = 1, max(MAX_CONTAINER_ITEMS, num_slots) do
            local item = _G[iname .. i]
            if item then
                item:SetParent(cf)
                item.gw_owner = p
                cf.gw_items[i] = item
            end
        end
    end
end
--/run ContainerFrameItemButton_SetForceExtended(_G["ContainerFrame1Item4"], true)


local function reskinBagBar(b, ha)
    local bag_size = 28
    local highlightAlpha = ha and ha or 0

    b:SetSize(bag_size, bag_size)
    b.tooltipText = BANK_BAG

    b.Count:ClearAllPoints()
    b.Count:SetPoint("TOPRIGHT", b, "TOPRIGHT", 0, -3)
    b.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "THINOUTLINE")
    b.Count:SetJustifyH("RIGHT")

    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b.icon:SetAlpha(0.75)
    b.icon:Show()

    local norm = b:GetNormalTexture()
    norm:SetTexture(nil)

    b.IconBorder:SetAllPoints(b)
    b.IconBorder:SetTexture(BORDER_TEXTURE)
    hooksecurefunc(b.IconBorder, "SetTexture", function()
        local t = b.IconBorder:GetTexture()
        if t and t > 0 and t ~= BORDER_TEXTURE then
            b.IconBorder:SetTexture(BORDER_TEXTURE)
        end
    end)

    local high = b:GetHighlightTexture()
    high:SetTexture(BORDER_TEXTURE)
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)
    high:SetSize(bag_size, bag_size)
    high:ClearAllPoints()
    high:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)

    if b.SlotHighlightTexture then
        b.SlotHighlightTexture:SetAlpha(highlightAlpha)
        b.SlotHighlightTexture:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png")
    end
end


-- reskins the default search boxes
local function reskinSearchBox(sb)
    if not sb then
        return
    end

    sb:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    sb.Instructions:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    sb.Instructions:SetTextColor(178 / 255, 178 / 255, 178 / 255)

    sb.Left:SetPoint("LEFT", 0, 0)

    sb.Left:SetTexture(nil)
    sb.Right:SetTexture(nil)
    sb.Middle:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagsearchbg.png")

    sb.Middle:SetPoint("RIGHT", sb, "RIGHT", 0, 0)

    sb.Middle:SetHeight(24)
    sb.Middle:SetTexCoord(unpack(GW.TexCoords))

    sb.searchIcon:Hide()
end
GW.SkinBagSearchBox = reskinSearchBox


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


-- on right click, open the bag filter dropdown (if valid) for this bag slot
local function ContainerFrame_IsBankBag(id)
    return id > NUM_TOTAL_BAG_FRAMES;
end

local function ContainerFrame_IsHeldBag(id)
    return id >= Enum.BagIndex.Backpack and id <= NUM_TOTAL_BAG_FRAMES;
end

local function ContainerFrame_IsMainBank(id)
    return id == Enum.BagIndex.Bank;
end

local function ContainerFrame_IsBackpack(id)
    return id == Enum.BagIndex.Backpack;
end

local function AddButtons_BagFilters(description, bagID)
    if not ContainerFrame_CanContainerUseFilterMenu(bagID) then
        return
    end

    description:CreateTitle(BAG_FILTER_ASSIGN_TO)

    local function IsSelected(flag)
        return C_Container.GetBagSlotFlag(bagID, flag)
    end

    local function SetSelected(flag)
        local value = not IsSelected(flag)
        C_Container.SetBagSlotFlag(bagID, flag, value)
        ContainerFrameSettingsManager:SetFilterFlag(bagID, flag, value)
    end

    for i, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
        local checkbox = description:CreateCheckbox(BAG_FILTER_LABELS[flag], IsSelected, SetSelected, flag)
        checkbox:SetResponse(MenuResponse.Close)
        checkbox:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)
    end
end

local function AddButtons_BagCleanup(description, bagID)
    description:CreateTitle(BAG_FILTER_IGNORE);

    do
        local function IsSelected()
            if ContainerFrame_IsMainBank(bagID) then
                return C_Container.GetBankAutosortDisabled();
            elseif ContainerFrame_IsBackpack(bagID) then
                return C_Container.GetBackpackAutosortDisabled();
            end
            return C_Container.GetBagSlotFlag(bagID, Enum.BagSlotFlags.DisableAutoSort);
        end

        local function SetSelected()
            local value = not IsSelected();
            if ContainerFrame_IsMainBank(bagID) then
                C_Container.SetBankAutosortDisabled(value);
            elseif ContainerFrame_IsBackpack(bagID) then
                C_Container.SetBackpackAutosortDisabled(value);
            else
                C_Container.SetBagSlotFlag(bagID, Enum.BagSlotFlags.DisableAutoSort, value);
            end
        end

        local checkbox = description:CreateCheckbox(BAG_FILTER_CLEANUP, IsSelected, SetSelected);
        checkbox:SetResponse(MenuResponse.Close)
        checkbox:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)
    end

    -- ignore junk selling from this bag or backpack
    if not ContainerFrame_IsMainBank(bagID) then
        local function IsSelected()
            if ContainerFrame_IsBackpack(bagID) then
                return C_Container.GetBackpackSellJunkDisabled();
            end
            return C_Container.GetBagSlotFlag(bagID, Enum.BagSlotFlags.ExcludeJunkSell);
        end

        local function SetSelected()
            local value = not IsSelected();
            if ContainerFrame_IsBackpack(bagID) then
                C_Container.SetBackpackSellJunkDisabled(value);
            else
                C_Container.SetBagSlotFlag(bagID, Enum.BagSlotFlags.ExcludeJunkSell, value);
            end
        end

        local checkbox = description:CreateCheckbox(SELL_ALL_JUNK_ITEMS_EXCLUDE_FLAG, IsSelected, SetSelected);
        checkbox:SetResponse(MenuResponse.Close);
        checkbox:AddInitializer(GW.BlizzardDropdownCheckButtonInitializer)
    end
end

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
        if cf then
            MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
                rootDescription:SetMinimumWidth(1)
                if not (ContainerFrame_IsHeldBag(bag_id) or ContainerFrame_IsBankBag(bag_id)) then
                    return
                end

                AddButtons_BagFilters(rootDescription, bag_id);
                AddButtons_BagCleanup(rootDescription, bag_id);
            end)
        end
    end
end


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


-- update the number of free bank slots available and set the display for it
local function updateFreeSlots(sp_str, start_idx, end_idx, opt_container)
    if not sp_str or not sp_str.SetText then
        return
    end

    local free = 0
    local full = 0
    if opt_container then
        free = C_Container.GetContainerNumFreeSlots(opt_container)
        full = C_Container.GetContainerNumSlots(opt_container)
    end

    for bag_id = start_idx, end_idx do
        free = free + C_Container.GetContainerNumFreeSlots(bag_id)
        full = full + C_Container.GetContainerNumSlots(bag_id)
    end

    sp_str:SetText((full - free) .. " / " .. full)
    return free, full
end


local function snapFrameSize(f, cfs, size, padding, min_height)
    if not f then
        return
    end

    local cols = f == GwBagFrame and f.gw_bag_cols or f.gw_bank_cols
    local sep = (f == GwBagFrame and GW.settings.BAG_SEPARATE_BAGS) or false

    if not cfs then
        f:SetHeight(min_height)
        return
    end

    local slots = 0

    if f == GwBankFrame then
        slots = slots + cfs.gw_num_slots
    else
        for _, cf in pairs(cfs) do
            if cf.gw_num_slots then
                slots = slots + cf.gw_num_slots
            end
        end
    end

    local rows = 0
    local isize = size + padding
    if sep then
        local bags_equipped = 0
        for i = 1, 5 do
            local slotID = (i <= 4) and GetInventorySlotInfo("Bag" .. (i - 1) .. "Slot") or 35 -- ReagentBag0Slot
            if GetInventoryItemID("player", slotID) then
                bags_equipped = bags_equipped + 1
            end
        end
        f.finishedRow = f.finishedRow or 0
        f.unfinishedRow = f.unfinishedRow or 0
        rows = f.finishedRow + bags_equipped + 1 + f.unfinishedRow
    else
        rows = math.ceil(slots / cols)
    end
    f:SetHeight(max((isize * rows) + 75, min_height))
    f:SetWidth((isize * cols) + padding + 2)
    for i = 0, 6 do
        local header = _G["GwBagFrameGwBagHeader" .. i]
        if header and sep then
            header:SetWidth((isize * cols) + padding + 2 - 5)
            if header.background then
                header.background:SetWidth((isize * cols) + padding + 2 - 5)
            end
        end
    end
end


local function onMoved(self, setting, snap_size)
    if not self then
        return
    end

    self:StopMovingOrSizing()

    local x = self:GetLeft()
    local y = self:GetTop()

    -- re-anchor to UIParent after the move
    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)

    -- store the updated position
    if setting then
        local pos = GW.settings[setting]
        if pos then
            wipe(pos)
        else
            pos = {}
        end
        pos.point = "TOPLEFT"
        pos.relativePoint = "BOTTOMLEFT"
        pos.xOfs = x
        pos.yOfs = y
        GW.settings[setting] = pos
    end

    -- apply our snap sizing, if necessary
    if snap_size then
        snap_size(self)
    end
end


local function colCount(size, padding, width)
    local isize = size + padding
    return math.floor((width - padding - 1) / isize)
end


local function onSizerMouseDown(self, btn)
    if btn ~= "LeftButton" then
        return
    end
    local bfm = self:GetParent()
    bfm:StartSizing("BOTTOMRIGHT")
end


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


local function onMoverDragStart(self)
    self:GetParent():StartMoving()
end


local function onMoverDragStop(self)
    onMoved(self:GetParent(), self.onMoveSetting)
end


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


local function LoadInventory()
    BagsBar:GwKillEditMode()

    if BagBarExpandToggle then
        BagBarExpandToggle:SetParent(GW.HiddenFrame)
        SetCVar("expandBagBar", "1")
    end

    -- anytime a ContainerFrame has its anchors set, we re-hide it
    hooksecurefunc("UpdateContainerFrameAnchors", hookUpdateAnchors)
    for i = 1, NUM_CONTAINER_FRAMES do
        local cf = _G["ContainerFrame" .. i]
        if cf then
            -- un-hook ContainerFrame open event; this event isn't used anymore but just in case
            cf:UnregisterEvent("BAG_OPEN")
        end
    end

    -- whenever an ItemButton sets its quality ensure our custom border is being used
    hooksecurefunc("SetItemButtonQuality", SetItemButtonData)

    local helpers = {}
    helpers.reskinItemButton = ReskinItemButton
    helpers.reskinItemButtons = reskinItemButtons
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
    StackSplitFrame:GwStripTextures()
    StackSplitFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)

    StackSplitFrame.OkayButton:GwSkinButton(false, true)
    StackSplitFrame.CancelButton:GwSkinButton(false, true)

    GW.HandleNextPrevButton(StackSplitFrame.RightButton, "right")
    GW.HandleNextPrevButton(StackSplitFrame.LeftButton, "left")

    StackSplitFrame.RightButton:SetSize(25, 25)
    StackSplitFrame.RightButton:SetPoint("LEFT", StackSplitFrame, "CENTER", 51, 18)

    StackSplitFrame.LeftButton:SetSize(25, 25)
    StackSplitFrame.LeftButton:SetPoint("RIGHT", StackSplitFrame, "CENTER", -50, 18)

    StackSplitFrame.textboxbg = StackSplitFrame:CreateTexture(nil, "BACKGROUND")
    StackSplitFrame.textboxbg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg.png")
    StackSplitFrame.textboxbg:SetPoint("TOPLEFT", 35, -20)
    StackSplitFrame.textboxbg:SetPoint("BOTTOMRIGHT", -35, 55)
end
GW.LoadInventory = LoadInventory
