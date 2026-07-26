---@class GW2
local GW = select(2, ...)

--[[
    Retail overrides for the shared inventory skinning: the retail item buttons and
    bag filter menus differ enough from the classic flavors that they keep their own
    implementations here, published over the GW exports the shared code resolves.
]]

local BORDER_TEXTURE = "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png"
local BACKDROP_TEXTURE = "Interface/AddOns/GW2_UI/textures/bag/bagitembackdrop.png"

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
    b.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
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
        b.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
        b.itemlevel:SetPoint("BOTTOMRIGHT", 0, 0)
        b.itemlevel:SetText("")
    end

    if b.cooldown then
        GW.RegisterCooldown(b.cooldown)
    elseif b.Cooldown then
        GW.RegisterCooldown(b.Cooldown)
    end
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

    local professionColors = isReagentBag and GW.GetBagItemQualityColor(Enum.ItemQuality.Artifact) or GW.Colors.ProfessionBagColors[select(2, C_Container.GetContainerNumFreeSlots(bag_id))]
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


GW.SkinBagItemButton = ReskinItemButton
GW.UpdateBagItemButtonVisuals = UpdateItemVisuals
GW.SetBagItemButtonQualitySkin = SetItemButtonData
GW.BagSlotOnMouseDown = bag_OnMouseDown
