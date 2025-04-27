local _, GW = ...
local f = CreateFrame("Frame")

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

    CharacterNeckSlot = {id = 11, slotId = 2},
    CharacterFinger0Slot = {id = 12, slotId = 11},
    CharacterTrinket0Slot = {id = 13, slotId = 13},

    CharacterFinger1Slot = {id = 14, slotId = 12},
    CharacterTrinket1Slot = {id = 15, slotId = 14},
    CharacterBackSlot = {id = 16, slotId = 15},
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

    if id <= 10 then
        return 47, 18, "BOTTOMLEFT"
    elseif id <= 13 then
        return 0, 25, "TOP"
    else
        return 0, -25, "BOTTOM"
    end
end

local function CreateSlotStrings()
    for name, tbl in pairs(InspectItems) do
        local slot = _G[name]
        local x, y, justify = GetInspectPoints(tbl.id)

        slot.enchantText = slot:CreateFontString(nil, "OVERLAY")
        slot.enchantText:SetSize(tbl.id >= 12 and 40 or 100, 30)
        slot.enchantText:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, tbl.id >= 12 and -4 or -2)
        slot.enchantText:SetJustifyH(tbl.id >= 12 and "CENTER" or "LEFT")
        slot.enchantText:SetPoint(justify, slot, x + (justify == "BOTTOMLEFT" and 5 or 0), y)

        slot.itemlevel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, "THINOUTLINE")

        for u = 1, 10 do
            local offsetX = u == 1 and 2 or -((u - 1) * 13)
            local offsetY = -2
            if u >= 4 then offsetY = offsetY + (math.floor((u - 1) / 3) * 13) end
            slot["textureSlot" .. u], slot["textureSlotBackdrop" .. u] = CreateInspectTexture(slot, offsetX, offsetY)
        end
    end
end

local function UpdatePageStrings(inspectItem, slotInfo)
    inspectItem.enchantText:SetText(GW.RoundInt(inspectItem.enchantText:GetWidth()) == 40 and slotInfo.enchantTextShort2 or slotInfo.enchantText or "")

    if slotInfo.enchantColors and next(slotInfo.enchantColors) then
        inspectItem.enchantText:SetTextColor(unpack(slotInfo.enchantColors))
    end

    local gemStep = 1
    for i = 1, 10 do
        local texture, backdrop = inspectItem["textureSlot" .. i], inspectItem["textureSlotBackdrop" .. i]
        local gem = slotInfo.gems and slotInfo.gems[gemStep]
        if gem then
            texture:SetTexture(gem)
            backdrop:SetBackdropBorderColor(unpack(slotInfo.itemLevelColors))
            backdrop:Show()

            gemStep = gemStep + 1
        else
            texture:SetTexture()
            backdrop:Hide()
        end
    end

    inspectItem.itemlevel:SetText(slotInfo.iLvl or "")
    if slotInfo.itemLevelColors then
        inspectItem.itemlevel:SetTextColor(unpack(slotInfo.itemLevelColors))
    end

    --set item idicator
    inspectItem.isSetItem = slotInfo.isSetItem
end

local function TryGearAgain(i, deepScan, inspectItem)
    C_Timer.After(0.05, function()
        local slotInfo = GW.GetGearSlotInfo("player", i, nil, deepScan)
        if slotInfo ~= "tooSoon" then
            UpdatePageStrings(inspectItem, slotInfo)
        end
    end)
end

do
    local function UpdatePageInfo()
        for name, tbl in pairs(InspectItems) do
            local inspectItem = _G[name]
            inspectItem.enchantText:SetText("")

            local slotInfo = GW.GetGearSlotInfo("player", tbl.slotId, nil, true)
            if slotInfo == "tooSoon" then
                TryGearAgain(tbl.slotId, true, inspectItem)
            else
                UpdatePageStrings(inspectItem, slotInfo)
            end
        end
    end
    GW.UpdatePageInfo = UpdatePageInfo
end

local function UpdateCharacterInfo(self, event)
    if not GW.settings.SHOW_CHARACTER_ITEM_INFO then return end
    -- set the values for the next time the char window gets open
    if event == "PLAYER_EQUIPMENT_CHANGED" or (event == "UPDATE_INVENTORY_DURABILITY" and GwCharacterWindow:IsShown()) then
        local timeNow = GetTime()
        if event == "PLAYER_EQUIPMENT_CHANGED" or (timeNow - (self.lastUpdateTime or 0)) >= 3 then
            self.needsUpdate = true
            self.lastUpdateTime = timeNow
        end
    end

    if GwCharacterWindow:IsShown() and self.needsUpdate then
        GW.UpdatePageInfo()
        --update itemborder
        for name, _ in pairs(InspectItems) do
            GW.UpdateCharacterPanelItemSlot(_G[name])
        end
        self.needsUpdate = false
    end
end

local function ToggleCharacterItemInfo(setup)
    if setup then
        CreateSlotStrings()
    end

    if GW.settings.SHOW_CHARACTER_ITEM_INFO then
        f.needsUpdate = true
        f.lastUpdateTime = GetTime()
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
        f.lastUpdateTime = 0
        for name, _ in pairs(InspectItems) do
            local inspectItem = _G[name]
            inspectItem.enchantText:SetText("")
            inspectItem.itemlevel:SetText("")
            inspectItem.setBorder:Hide()

            for y = 1, 10 do
                inspectItem["textureSlot" .. y]:SetTexture()
                inspectItem["textureSlotBackdrop" .. y]:Hide()
            end
        end
    end
end
GW.ToggleCharacterItemInfo = ToggleCharacterItemInfo
