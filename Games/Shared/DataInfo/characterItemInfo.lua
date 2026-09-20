---@class GW2
local GW = select(2, ...)
local f = CreateFrame("Frame")

-- slots that should carry an enchant, only known for Retail
local MISSING_ENCHANT_SLOTS = (GW.Retail and {
    [1] = true, [3] = true, [5] = true, [7] = true, [8] = true, [11] = true, [12] = true, [16] = true,
}) or (GW.Forever and {
    -- classic era enchants: no rings, head and shoulder come from reputation
    [1] = true, [3] = true, [5] = true, [7] = true, [8] = true, [9] = true, [10] = true, [15] = true,
    [16] = true, [17] = true, [18] = true,
}) or {}
-- an off hand only takes an enchant as a shield, a ranged slot only as a scoped weapon
local SHIELD_SUBCLASS = 6
local SCOPED_WEAPONS = {[2] = true, [3] = true, [18] = true}
local MISSING_COLOR = {1, 0.3, 0.3}

local function SlotTakesEnchant(slotId)
    if not MISSING_ENCHANT_SLOTS[slotId] then
        return false
    end
    if slotId ~= 17 and slotId ~= 18 then
        return true
    end

    local itemID = GetInventoryItemID("player", slotId)
    if not itemID then
        return false
    end
    local _, _, _, _, _, classID, subClassID = C_Item.GetItemInfoInstant(itemID)
    if slotId == 17 then
        return classID == Enum.ItemClass.Armor and subClassID == SHIELD_SUBCLASS
    end
    return classID == Enum.ItemClass.Weapon and SCOPED_WEAPONS[subClassID] == true
end
-- equipped average, refreshed per page update for the relative item level color
local equippedItemLevel

local InspectItems = {
    CharacterHeadSlot = {id = 1, slotId = 1},
    CharacterShoulderSlot = {id = 2, slotId = 3},
    CharacterChestSlot = {id = 3, slotId = 5},
    CharacterWaistSlot = {id = 4, slotId = 6},
    CharacterLegsSlot = {id = 5, slotId = 7},
    CharacterFeetSlot = {id = 6, slotId = 8},
    CharacterWristSlot = {id = 7, slotId = 9},
    CharacterHandsSlot = {id = 8, slotId = 10},
    CharacterMainHandSlot = {id = 9, slotId = 16},
    CharacterSecondaryHandSlot = {id = 10, slotId = 17},
    CharacterRangedSlot = {id = 11, slotId = 18},

    CharacterNeckSlot = {id = 12, slotId = 2},
    CharacterFinger0Slot = {id = 13, slotId = 11},
    CharacterTrinket0Slot = {id = 14, slotId = 13},

    CharacterFinger1Slot = {id = 15, slotId = 12},
    CharacterTrinket1Slot = {id = 16, slotId = 14},
    CharacterBackSlot = {id = 17, slotId = 15},
}

local function CreateInspectTexture(slot, x, y)
    local texture = slot:CreateTexture()
    texture:SetPoint("TOPLEFT", x, y)
    texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    texture:SetSize(12, 12)

    local backdrop = CreateFrame("Frame", nil, slot)
    if not backdrop.SetBackdrop then
        Mixin(backdrop, _G.BackdropTemplateMixin)
        backdrop:HookScript("OnSizeChanged", backdrop.OnBackdropSizeChanged)
        backdrop:SetBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
    end
    backdrop:SetBackdropColor(0, 0, 0, 0)
    backdrop:GwSetOutside(texture)
    backdrop:Hide()

    return texture, backdrop
end

local function GetInspectPoints(id)
    if not id then return end

    if id <= 11 then
        return 3, 0, "LEFT", "RIGHT"
    elseif id <= 14 then
        return 0, 26, "TOP", "TOP"
    else
        return 0, -26, "BOTTOM", "BOTTOM"
    end
end

local function CreateSlotStrings()
    for name, tbl in pairs(InspectItems) do
        local slot = _G[name]
        if slot then
            local x, y, justify, point = GetInspectPoints(tbl.id)

            slot.enchantText = slot:CreateFontString(nil, "OVERLAY")
            slot.enchantText:SetSize(tbl.id >= 12 and 40 or 100, 30)
            slot.enchantText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, tbl.id >= 12 and -4 or -2)
            slot.enchantText:SetJustifyH(tbl.id >= 12 and "CENTER" or "LEFT")
            slot.enchantText:SetPoint(justify, slot, point, x + (justify == "CENTER" and 5 or 0), y)

            local bg = slot:CreateTexture(nil, "BACKGROUND")
            bg:SetAlpha(0.6)
            bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/achievementhover.png")
            bg:SetPoint("TOPLEFT", slot.enchantText, "TOPLEFT", -2, 2)
            bg:SetPoint("BOTTOMRIGHT", slot.enchantText, "BOTTOMRIGHT", 2, -2)
            bg:Hide()
            if tbl.id >= 12 and tbl.id <= 14 then
                bg:SetRotation(1.5708)
            elseif tbl.id >= 15 then
                bg:SetRotation(4.7124)
            end
            slot.enchantTextBg = bg

            if tbl.id >= 12 then
                local enchantHoverFrame = CreateFrame("Button", nil, slot)
                enchantHoverFrame:SetAllPoints(slot.enchantText)
                enchantHoverFrame:SetFrameLevel(slot:GetFrameLevel() + 1)
                enchantHoverFrame:SetScript("OnEnter", function(self)
                    if not slot.tooltipText then return end
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()

                    if slot.enchantColors then
                        GameTooltip:AddLine(slot.tooltipText, unpack(slot.enchantColors))
                    else
                        GameTooltip:AddLine(slot.tooltipText)
                    end
                    GameTooltip:Show()
                end)
                enchantHoverFrame:SetScript("OnLeave", GameTooltip_Hide)
            end

            slot.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")

            for u = 1, 10 do
                local offset = -((u - 1) * 13)
                local offsetY = -2
                local newX = u == 1 and 2 or -offset
                local newY = u == 4 and offsetY + 13 or u == 4 and offsetY + 26 or u == 7 and offsetY + 39 or offsetY
                slot["textureSlot" .. u], slot["textureSlotBackdrop" .. u] = CreateInspectTexture(slot, newX, newY)
            end
        end
    end
end

local function UpdatePageStrings(inspectItem, slotInfo, slotId)
    local showMissing = GW.settings.windows.character.itemInfoMissing
    local width = GW.RoundInt(inspectItem.enchantText:GetWidth())
    if showMissing and slotInfo.iLvl and not slotInfo.enchantText and SlotTakesEnchant(slotId) then
        -- item without enchant on an enchantable slot
        inspectItem.enchantText:SetText(ADDON_MISSING)
        inspectItem.enchantText:SetTextColor(unpack(MISSING_COLOR))
        inspectItem.tooltipText = nil
        inspectItem.enchantColors = nil
        inspectItem.enchantTextBg:Show()
    else
        inspectItem.enchantText:SetText(width == 40 and slotInfo.enchantTextShort2 or slotInfo.enchantText or "")
        inspectItem.tooltipText = width == 40 and slotInfo.enchantText or nil
        inspectItem.enchantTextBg:SetShown(slotInfo.enchantTextShort2 or slotInfo.enchantText)
        if slotInfo.enchantColors and next(slotInfo.enchantColors) then
            inspectItem.enchantColors = width == 40 and slotInfo.enchantColors or nil
            inspectItem.enchantText:SetTextColor(unpack(slotInfo.enchantColors))
        end
    end

    local gemStep = 1
    for i = 1, 10 do
        local texture, backdrop = inspectItem["textureSlot" .. i], inspectItem["textureSlotBackdrop" .. i]
        local gem = slotInfo.gems and slotInfo.gems[gemStep]
        if gem then
            texture:SetTexture(gem)
            -- the tooltip places the empty socket artwork where a gem would be
            local isEmptySocket = type(gem) == "string" and strfind(gem, "EmptySocket", 1, true)
            if isEmptySocket and showMissing then
                backdrop:SetBackdropBorderColor(unpack(MISSING_COLOR))
            else
                backdrop:SetBackdropBorderColor(unpack(slotInfo.itemLevelColors))
            end
            backdrop:Show()

            gemStep = gemStep + 1
        else
            texture:SetTexture()
            backdrop:Hide()
        end
    end

    inspectItem.itemlevel:SetText(slotInfo.iLvl or "")
    if slotInfo.iLvl and GW.settings.windows.character.itemLevelRelativeColor and equippedItemLevel and equippedItemLevel > 0 then
        local diff = slotInfo.iLvl - equippedItemLevel
        if diff >= 0 then
            inspectItem.itemlevel:SetTextColor(0.4, 1, 0.4)
        elseif diff > -10 then
            inspectItem.itemlevel:SetTextColor(1, 0.85, 0.3)
        else
            inspectItem.itemlevel:SetTextColor(unpack(MISSING_COLOR))
        end
    elseif slotInfo.itemLevelColors and slotInfo.itemLevelColors[1] and slotInfo.itemLevelColors[2] and slotInfo.itemLevelColors[3]  then
        inspectItem.itemlevel:SetTextColor(unpack(slotInfo.itemLevelColors))
    end

    --set item idicator
    inspectItem.isSetItem = slotInfo.isSetItem
end

local function TryGearAgain(i, deepScan, inspectItem)
    C_Timer.After(0.05, function()
        local slotInfo = GW.GetGearSlotInfo("player", i, nil, deepScan)
        if slotInfo ~= "tooSoon" then
            UpdatePageStrings(inspectItem, slotInfo, i)
        end
    end)
end

do
    local function UpdatePageInfo()
        equippedItemLevel = select(2, GW.GetPlayerItemLevel())
        for name, tbl in pairs(InspectItems) do
            local inspectItem = _G[name]
            if inspectItem then
                inspectItem.enchantText:SetText("")

                local slotInfo = GW.GetGearSlotInfo("player", tbl.slotId, nil, true)
                if slotInfo == "tooSoon" then
                    TryGearAgain(tbl.slotId, true, inspectItem)
                else
                    UpdatePageStrings(inspectItem, slotInfo, tbl.slotId)
                end
            end
        end
    end
    GW.UpdatePageInfo = UpdatePageInfo
end

local characterInfoWaitScheduled = false
local characterInfoQueued = false

local function RunCharacterInfoUpdate(self)
    characterInfoWaitScheduled = false
    if characterInfoQueued then
        characterInfoQueued = false
        if GwCharacterWindow:IsShown() and self.needsUpdate then
            GW.UpdatePageInfo()
            self.needsUpdate = false
        end
    end
end

local function UpdateCharacterInfo(self, event)
    if not GW.settings.windows.character.itemInfo then return end
    -- set the values for the next time the char window gets open
    if event == "PLAYER_EQUIPMENT_CHANGED" or (event == "UPDATE_INVENTORY_DURABILITY" and GwCharacterWindow:IsShown()) then
        self.needsUpdate = true
    end

    characterInfoQueued = true
    if not characterInfoWaitScheduled then
        characterInfoWaitScheduled = true
        GW.Wait(1, RunCharacterInfoUpdate, self)
    end
end

local function ToggleCharacterItemInfo(setup)
    if setup then
        CreateSlotStrings()
    end

    if GW.settings.windows.character.itemInfo then
        f.needsUpdate = true
        f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        f:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        f:SetScript("OnEvent", UpdateCharacterInfo)
        if not f.CharacterInfoHooked then
            GwCharacterWindow:HookScript("OnShow", function()
                if f.needsUpdate then
                    UpdateCharacterInfo(f)
                end
            end)
            f.CharacterInfoHooked = true
        end

        if not setup then
            UpdateCharacterInfo(f)
        end
    else
        f:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
        f:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
        f.needsUpdate = false
        for name, _ in pairs(InspectItems) do
            local inspectItem = _G[name]
            if inspectItem then
                inspectItem.enchantText:SetText("")
                inspectItem.enchantTextBg:Hide()
                inspectItem.itemlevel:SetText("")
                if inspectItem.itemSetBorderIndicator then
                    inspectItem.itemSetBorderIndicator:Hide()
                end

                for y = 1, 10 do
                    inspectItem["textureSlot" .. y]:SetTexture()
                    inspectItem["textureSlotBackdrop" .. y]:Hide()
                end
            end
        end
    end
end
GW.ToggleCharacterItemInfo = ToggleCharacterItemInfo
