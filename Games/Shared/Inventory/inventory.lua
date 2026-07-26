---@class GW2
local GW = select(2, ...)

local BORDER_TEXTURE = "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png"

-- the keyring only exists up to wrath, the reagent bag only on retail
local HAS_KEYRING = GW.Classic or GW.TBC or GW.Wrath
local HAS_REAGENT_BAG = GW.Retail

-- retail provides this table natively (keyed by Enum.BagSlotFlags), the classic flavors dont
if LE_BAG_FILTER_FLAG_EQUIPMENT then
    BAG_FILTER_LABELS = {
        [LE_BAG_FILTER_FLAG_EQUIPMENT] = BAG_FILTER_EQUIPMENT,
        [LE_BAG_FILTER_FLAG_CONSUMABLES] = BAG_FILTER_CONSUMABLES,
        [LE_BAG_FILTER_FLAG_TRADE_GOODS] = BAG_FILTER_TRADE_GOODS,
        [LE_BAG_FILTER_FLAG_JUNK] = BAG_FILTER_JUNK,
    }
end
local BAG_ITEM_SIZE_CONFIG = {
    defaultValue = GW.globalDefault.profile.BAG_ITEM_SIZE,
    minValue = 26,
    maxValue = 48,
    step = 1
}
local BAG_ITEM_SPACING_X_CONFIG = {
    defaultValue = GW.globalDefault.profile.BAG_ITEM_SPACING_X,
    minValue = 0,
    maxValue = 20,
    step = 1
}
local BAG_ITEM_SPACING_Y_CONFIG = {
    defaultValue = GW.globalDefault.profile.BAG_ITEM_SPACING_Y,
    minValue = 0,
    maxValue = 20,
    step = 1
}
local BANK_ITEM_SIZE_CONFIG = {
    defaultValue = GW.globalDefault.profile.BANK_ITEM_SIZE,
    minValue = 26,
    maxValue = 48,
    step = 1
}
local BANK_ITEM_SPACING_X_CONFIG = {
    defaultValue = GW.globalDefault.profile.BANK_ITEM_SPACING_X,
    minValue = 0,
    maxValue = 20,
    step = 1
}
local BANK_ITEM_SPACING_Y_CONFIG = {
    defaultValue = GW.globalDefault.profile.BANK_ITEM_SPACING_Y,
    minValue = 0,
    maxValue = 20,
    step = 1
}
local CONTAINER_FRAME_SIDE_PADDING = 5
local CONTAINER_FRAME_RIGHT_PADDING = 5

-- reskins an ItemButton to use GW2_UI styling; one central version for every flavor,
-- retail only parts are capability guarded
local function reskinItemButton(b, overrideIconSize)
    if not b then return end
    local iconSize = overrideIconSize or GW.settings.BAG_ITEM_SIZE
    b:SetSize(iconSize, iconSize)

    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b.icon:SetAllPoints(b)
    b.icon:SetAlpha(0.9)

    b.IconBorder:SetAllPoints(b)
    b.IconBorder:SetTexture(BORDER_TEXTURE)

    if b.ClearNormalTexture then
        b:ClearNormalTexture()
    else
        local norm = b:GetNormalTexture()
        if norm then
            norm:SetTexture(nil)
        end
    end
    if b.NormalTexture then
        b.NormalTexture:SetTexture()
    end

    if GW.Retail then
        -- kill the retail slot background
        if not b.ItemSlotBackground then
            b.ItemSlotBackground = b:CreateTexture(nil, "BACKGROUND", "ItemSlotBackgroundCombinedBagsTemplate", -6)
            b.ItemSlotBackground:SetAllPoints(b)
        end
        b.ItemSlotBackground:SetAlpha(0)
    end
    if b.Background then
        b.Background:Hide()
    end

    local high = b:GetHighlightTexture()
    high:SetAllPoints(b)
    high:SetTexture(BORDER_TEXTURE)
    high:SetBlendMode("ADD")
    high:SetAlpha(0.33)

    local pushed = b:GetPushedTexture()
    if pushed then
        pushed:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png")
        pushed:SetAllPoints(b)
    end

    if not b.gwBackdrop then
        local bd = b:CreateTexture(nil, "BACKGROUND")
        bd:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitembackdrop.png")
        bd:SetAllPoints(b)
        b.gwBackdrop = bd
    end

    b.Count:ClearAllPoints()
    b.Count:SetPoint("TOPRIGHT", b, "TOPRIGHT", 0, -3)
    b.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
    b.Count:SetJustifyH("RIGHT")

    -- the templates quest texture becomes our own quest icon on every flavor,
    -- so quest items are marked the same everywhere (the retail default)
    if b.IconQuestTexture then
        b.IconQuestTexture:ClearAllPoints()
        b.IconQuestTexture:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-quest.png")
        b.IconQuestTexture:SetSize(25, 25)
        b.IconQuestTexture:SetPoint("TOPLEFT", -7, 1)
        b.IconQuestTexture:SetVertexColor(221 / 255, 198 / 255, 68 / 255)
        b.IconQuestTexture:SetAlpha(1)
        if b.UpdateQuestItem then
            hooksecurefunc(b, "UpdateQuestItem", function()
                b.IconQuestTexture:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-quest.png")
            end)
        elseif b.Refresh then --bank_slots
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

    -- scrapping only exists on retail
    if C_Item.CanScrapItem and not b.scrapIcon then
        b.scrapIcon = b:CreateTexture(nil, "OVERLAY", nil, 2)
        b.scrapIcon:SetAtlas("bags-icon-scrappable")
        b.scrapIcon:SetSize(14, 12)
        b.scrapIcon:SetPoint("TOPLEFT", 0, 0)
        b.scrapIcon:Hide()
    end

    if not b.UpgradeIcon then
        b.UpgradeIcon = b:CreateTexture(nil, "OVERLAY", nil, 2)
        b.UpgradeIcon:SetPoint("TOPRIGHT", 7, -1)
        b.UpgradeIcon:Hide()
    end
    b.UpgradeIcon:SetSize(15, 15)

    if not b.itemlevel then
        b.itemlevel = b:CreateFontString(nil, "OVERLAY")
        b.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
        b.itemlevel:SetPoint("BOTTOMRIGHT", 0, 0)
        b.itemlevel:SetText("")
    end

    if b.cooldown then
        GW.RegisterCooldown(b.cooldown)
    elseif b.Cooldown then
        GW.RegisterCooldown(b.Cooldown)
    elseif b.GetName and b:GetName() and _G[b:GetName() .. "Cooldown"] then
        GW.RegisterCooldown(_G[b:GetName() .. "Cooldown"])
    end
end
GW.SkinBagItemButton = reskinItemButton


local function updateItemVisuals(b, overrideIconSize)
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
        if high:GetTexture() ~= BORDER_TEXTURE then
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
    end

    if b.flash then
        b.flash:SetAllPoints(b)
    end
end
GW.UpdateBagItemButtonVisuals = updateItemVisuals

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


local function reskinItemButtons()
    -- our own bag and bank item buttons with their separate size settings; hidden ones only
    -- get the new size, the rest of the visual updates run on the next sweep while shown
    GW.ForEachOwnBagItemButton(function(slot)
        local bagID = slot:GetParent():GetID()
        local isBank = bagID == BANK_CONTAINER or bagID > NUM_BAG_SLOTS
        local iconSize = isBank and GW.settings.BANK_ITEM_SIZE or GW.settings.BAG_ITEM_SIZE

        if not slot.__gwSkinned then
            GW.SkinBagItemButton(slot, iconSize)
            slot.__gwSkinned = true
        elseif slot:IsShown() then
            GW.UpdateBagItemButtonVisuals(slot, iconSize)
        else
            slot:SetSize(iconSize, iconSize)
        end
    end)
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


local function SetItemButtonQualityForBags(button, quality)
    button.IconBorder:SetTexture(BORDER_TEXTURE)
    button.IconOverlay:Hide()
    button.IconBorder:SetAlpha(0.9)

    if quality then
        if quality >= (LE_ITEM_QUALITY_COMMON or Enum.ItemQuality.Common) and BAG_ITEM_QUALITY_COLORS[quality] then
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

-- flavor extras can decorate every item button after the shared quality skin ran
-- (e.g. the equipment set name on mists), registered at file scope from the flavors
local itemButtonDecorators = {}
local function RegisterItemButtonDecorator(decorator)
    itemButtonDecorators[#itemButtonDecorators + 1] = decorator
end
GW.RegisterItemButtonDecorator = RegisterItemButtonDecorator

local function SetItemButtonData(button, quality, itemIDOrLink, suppressOverlays)
    if not button.gwBackdrop then
        return
    end

    button.IconOverlay:Hide()
    local t = button.IconBorder
    local colorCommon = GW.GetBagItemQualityColor(Enum.ItemQuality.Common)
    t:SetTexture(BORDER_TEXTURE)
    t:SetAlpha(0.9)
    t:SetVertexColor(colorCommon.r, colorCommon.g, colorCommon.b)

    if not GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW then
        t:SetVertexColor(colorCommon.r, colorCommon.g, colorCommon.b)
    end

    local bag_id = button:GetParent():GetID()
    local keyring = HAS_KEYRING and bag_id == KEYRING_CONTAINER
    local isReagentBag = HAS_REAGENT_BAG and bag_id == 5
    local professionBagColors = GW.Colors.ProfessionBagColors or GW.Colors.BagTypeColors
    local professionColors = keyring and BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_WOW_TOKEN]
        or isReagentBag and GW.GetBagItemQualityColor(Enum.ItemQuality.Artifact)
        or professionBagColors[select(2, C_Container.GetContainerNumFreeSlots(bag_id))]
    local showItemLevel = button.itemlevel and itemIDOrLink and GW.settings.BAG_SHOW_ILVL and not professionColors

    button.bagID = bag_id

    -- by default the profession bag tint wins over an items quality color; with the
    -- quality-over-profession option the tint is applied first so the quality color wins
    local qualityWinsOverProfession = GW.settings.BAG_PROFESSION_BAG_QUALITY_COLOR
    if qualityWinsOverProfession and (GW.settings.BAG_PROFESSION_BAG_COLOR or isReagentBag) and professionColors then
        t:SetVertexColor(professionColors.r, professionColors.g, professionColors.b)
        t:Show()
    end

    if itemIDOrLink then
        if quality == nil then quality = 0 end

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

        -- Show upgrade icon if active
        if itemInfo and itemInfo.hyperlink and GW.settings.BAG_ITEM_UPGRADE_ICON_SHOW and button.UpgradeIcon then
            GW.RegisterPawnUpgradeIcon(button, itemInfo.hyperlink)
        elseif button.UpgradeIcon then
            button.UpgradeIcon:Hide()
        end

        -- Show ilvl if active
        if button.itemlevel and showItemLevel then
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

        -- flavor extras (azerite/corruption/scrap on retail, equipment set names on mists)
        for i = 1, #itemButtonDecorators do
            itemButtonDecorators[i](button, quality, itemIDOrLink, suppressOverlays)
        end

        if GW.settings.BAG_ITEM_QUALITY_BORDER_SHOW and quality and quality > 0 then
            local color = GW.GetBagItemQualityColor(quality)
            t:SetVertexColor(color.r, color.g, color.b)
        end

        t:Show()
        if GetItemButtonIconTexture then
            GetItemButtonIconTexture(button):Show()
        end
    else
        if button.junkIcon then button.junkIcon:Hide() end
        if button.scrapIcon then button.scrapIcon:Hide() end
        if button.UpgradeIcon then button.UpgradeIcon:Hide() end
        if button.itemlevel then
            button.itemlevel:SetText("")
            button.__gwLastItemLink = nil
        end
        if GetItemButtonIconTexture then
            GetItemButtonIconTexture(button):Hide()
        end
    end

    if not qualityWinsOverProfession and (GW.settings.BAG_PROFESSION_BAG_COLOR or isReagentBag) and professionColors then
        t:SetVertexColor(professionColors.r, professionColors.g, professionColors.b)
        t:Show()
    end

    --Keyring
    if keyring then
        t:Show()
        t:SetVertexColor(professionColors.r, professionColors.g, professionColors.b)
    end
end
GW.SetBagItemButtonQualitySkin = SetItemButtonData

local bag_resize
local bank_resize
local function NormalizeByConfig(value, config)
    local normalized = math.floor((tonumber(value) or config.defaultValue) + 0.5)
    return math.max(config.minValue, math.min(config.maxValue, normalized))
end

local function NormalizeBagItemSize(value)
    return NormalizeByConfig(value, BAG_ITEM_SIZE_CONFIG)
end

local function NormalizeBagItemSpacingX(value)
    return NormalizeByConfig(value, BAG_ITEM_SPACING_X_CONFIG)
end

local function NormalizeBagItemSpacingY(value)
    return NormalizeByConfig(value, BAG_ITEM_SPACING_Y_CONFIG)
end

local function NormalizeBankItemSize(value)
    return NormalizeByConfig(value, BANK_ITEM_SIZE_CONFIG)
end

local function NormalizeBankItemSpacingX(value)
    return NormalizeByConfig(value, BANK_ITEM_SPACING_X_CONFIG)
end

local function NormalizeBankItemSpacingY(value)
    return NormalizeByConfig(value, BANK_ITEM_SPACING_Y_CONFIG)
end

local function resizeInventory()
    GW.settings.BAG_ITEM_SIZE = NormalizeBagItemSize(GW.settings.BAG_ITEM_SIZE)
    GW.settings.BAG_ITEM_SPACING_X = NormalizeBagItemSpacingX(GW.settings.BAG_ITEM_SPACING_X)
    GW.settings.BAG_ITEM_SPACING_Y = NormalizeBagItemSpacingY(GW.settings.BAG_ITEM_SPACING_Y)
    GW.settings.BANK_ITEM_SIZE = NormalizeBankItemSize(GW.settings.BANK_ITEM_SIZE)
    GW.settings.BANK_ITEM_SPACING_X = NormalizeBankItemSpacingX(GW.settings.BANK_ITEM_SPACING_X)
    GW.settings.BANK_ITEM_SPACING_Y = NormalizeBankItemSpacingY(GW.settings.BANK_ITEM_SPACING_Y)
    reskinItemButtons()
    if bag_resize then
        bag_resize()
    end
    if bank_resize then
        bank_resize()
    end
end


local function reskinBagBar(b, ha)
    local bag_size = 28
    local highlightAlpha = ha and ha or 0

    b:SetSize(bag_size, bag_size)
    b.tooltipText = BANK_BAG

    if b.Count then
        b.Count:ClearAllPoints()
        b.Count:SetPoint("TOPRIGHT", b, "TOPRIGHT", 0, -3)
        b.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
        b.Count:SetJustifyH("RIGHT")
    end

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

    -- blizzard checks the bag slot buttons for every open bag and with us every bag is always
    -- open, so the yellow checked glow carries no information - kill it
    if b.GetCheckedTexture and b:GetCheckedTexture() then
        b:GetCheckedTexture():SetTexture(nil)
    end
end


-- reskins the default search boxes
local function reskinSearchBox(sb)
    if not sb then
        return
    end

    sb:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    sb.Instructions:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
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
local function AddButtons_BagFilters(description, bagID)

    description:CreateTitle(BAG_FILTER_ASSIGN_TO)

    local function IsSelected(flag)
        return C_Container.GetBagSlotFlag(bagID, flag)
    end

    local function SetSelected(flag)
        local value = not IsSelected(flag)
        C_Container.SetBagSlotFlag(bagID, flag, value)
    end

    local checkbox = description:CreateCheckbox(BAG_FILTER_IGNORE, IsSelected, SetSelected, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP)
    checkbox:SetResponse(MenuResponse.Close)
end

local function bag_OnMouseDown(self, button)
    if button ~= "RightButton" or not self.gwHasBag or not ((self:GetID() - CharacterBag0Slot:GetID() + 1) > 0 and (self:GetID() - CharacterBag0Slot:GetID() + 1) < 5) then
        return
    end

    local bag_id = self:GetID() - CharacterBag0Slot:GetID() + 1
    local cf = getContainerFrame(bag_id)
    if cf then
        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
            AddButtons_BagFilters(rootDescription, bag_id)
        end)
    end
end
GW.BagSlotOnMouseDown = bag_OnMouseDown


-- positions ItemButtons fluidly for this container
local function layoutContainerFrame(cf, max_col, row, col, rev, item_off_x, item_off_y)
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
            item:SetPoint("TOPLEFT", cf, "TOPLEFT", col * item_off_x, -row * item_off_y)
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


-- update the number of free bag slots available and set the display for it
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


local function snapFrameSize(f, cfs, size, paddingX, paddingY, min_height)
    if not f then
        return
    end
    if not size or not paddingX or not paddingY then
        -- acedb can have the profile defaults detached (logout, profile operations)
        return
    end

    local isBag = f == GwBagFrame
    local cols = isBag and f.gw_bag_cols or f.gw_bank_cols
    local sep = isBag and GW.settings.BAG_SEPARATE_BAGS or (not isBag and GW.settings.BANK_SEPARATE_BAGS)

    if not cfs then
        f:SetHeight(min_height)
        return
    end

    local slots = 0
    if cfs.gw_num_slots then
        -- a single container was handed in (the retail bank panel)
        slots = cfs.gw_num_slots
    else
        for _, cf in pairs(cfs) do
            if cf.gw_num_slots then
                slots = slots + cf.gw_num_slots
            end
        end
    end

    local rows
    local isizeX = size + paddingX
    local isizeY = size + paddingY
    if sep then
        -- one row per visible section header: backpack + equipped bags (+ keyring/reagent bag)
        -- on the bag frame, main bank + equipped bank bags on the bank frame
        local headers = 1
        if isBag then
            for i = 1, 4 do
                local slotID = GetInventorySlotInfo("Bag" .. i - 1 .. "Slot")
                if GetInventoryItemID("player", slotID) then
                    headers = headers + 1
                end
            end
            if HAS_KEYRING then
                headers = headers + 1 --Keyring
            elseif HAS_REAGENT_BAG then
                if GetInventoryItemID("player", (GetInventorySlotInfo("ReagentBag0Slot"))) then
                    headers = headers + 1
                end
            end
        else
            for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
                if GetInventoryItemID("player", C_Container.ContainerIDToInventoryID(i)) then
                    headers = headers + 1
                end
            end
        end
        f.finishedRow = f.finishedRow and f.finishedRow or 0
        f.unfinishedRow = f.unfinishedRow and f.unfinishedRow or 0
        rows = f.finishedRow + headers + f.unfinishedRow
    else
        -- the layout stores its actual row usage when it deviates from the plain flow (keyring gap)
        rows = f.gw_combined_rows or math.ceil(slots / cols)
    end
    f:SetHeight(max((isizeY * rows) + 75, min_height))
    local contentWidth = (isizeX * cols) - paddingX
    local frameWidth = contentWidth + CONTAINER_FRAME_SIDE_PADDING + CONTAINER_FRAME_RIGHT_PADDING + 2
    f:SetWidth(frameWidth)
end


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


local function colCount(size, paddingX, width)
    local isize = size + paddingX
    return math.floor((width - CONTAINER_FRAME_SIDE_PADDING - CONTAINER_FRAME_RIGHT_PADDING + paddingX - 1) / isize)
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


local function LoadInventory()
    _G["BINDING_HEADER_GW2UI_INVENTORY_BINDINGS"] = INVENTORY_TOOLTIP
    _G["BINDING_NAME_BAG_SORT"] = BAG_CLEANUP_BAGS
    _G["BINDING_NAME_BANK_SORT"] = BAG_CLEANUP_BANK

    BagsBar:GwKillEditMode()

    -- anytime a ContainerFrame has its anchors set, we re-hide it
    hooksecurefunc("UpdateContainerFrameAnchors", hookUpdateAnchors)

    -- apply the current size settings to any already created own item buttons
    reskinItemButtons()

    -- whenever an ItemButton sets its quality ensure our custom border is being used;
    -- resolved through GW so a flavor can override the skin (retail does)
    hooksecurefunc("SetItemButtonQuality", function(...)
        GW.SetBagItemButtonQualitySkin(...)
    end)

    -- un-hook ContainerFrame open event; this event isn't used anymore but just in case
    for i = 1, NUM_CONTAINER_FRAMES do
        local cf = _G["ContainerFrame" .. i]
        if cf then
            cf:UnregisterEvent("BAG_OPEN")
        end
    end

    local helpers = {}
    -- resolved through GW so a flavor can override them (retail does)
    helpers.reskinItemButton = function(...) return GW.SkinBagItemButton(...) end
    helpers.bag_OnMouseDown = function(...) return GW.BagSlotOnMouseDown(...) end
    helpers.resizeInventory = resizeInventory
    helpers.getContainerFrame = getContainerFrame
    helpers.reskinBagBar = reskinBagBar
    helpers.reskinSearchBox = reskinSearchBox
    helpers.relocateSearchBox = relocateSearchBox
    helpers.layoutContainerFrame = layoutContainerFrame
    helpers.updateFreeSlots = updateFreeSlots
    helpers.snapFrameSize = snapFrameSize
    helpers.onMoved = onMoved
    helpers.colCount = colCount
    helpers.onSizerMouseDown = onSizerMouseDown
    helpers.onSizerMouseUp = onSizerMouseUp
    helpers.onMoverDragStart = onMoverDragStart
    helpers.onMoverDragStop = onMoverDragStop
    helpers.bagItemSizeConfig = BAG_ITEM_SIZE_CONFIG
    helpers.bagItemSpacingXConfig = BAG_ITEM_SPACING_X_CONFIG
    helpers.bagItemSpacingYConfig = BAG_ITEM_SPACING_Y_CONFIG
    helpers.normalizeBagItemSize = NormalizeBagItemSize
    helpers.normalizeBagItemSpacingX = NormalizeBagItemSpacingX
    helpers.normalizeBagItemSpacingY = NormalizeBagItemSpacingY
    helpers.bankItemSizeConfig = BANK_ITEM_SIZE_CONFIG
    helpers.bankItemSpacingXConfig = BANK_ITEM_SPACING_X_CONFIG
    helpers.bankItemSpacingYConfig = BANK_ITEM_SPACING_Y_CONFIG
    helpers.normalizeBankItemSize = NormalizeBankItemSize
    helpers.normalizeBankItemSpacingX = NormalizeBankItemSpacingX
    helpers.normalizeBankItemSpacingY = NormalizeBankItemSpacingY

    bag_resize = GW.LoadBag(helpers)
    bank_resize = GW.LoadBank(helpers)
end
GW.LoadInventory = LoadInventory
