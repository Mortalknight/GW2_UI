local _, GW = ...

local f = CreateFrame("Frame")
local InspectItems = {
    "CharacterHeadSlot",
    "CharacterNeckSlot",
    "CharacterShoulderSlot",
    "",
    "CharacterChestSlot",
    "CharacterWaistSlot",
    "CharacterLegsSlot",
    "CharacterFeetSlot",
    "CharacterWristSlot",
    "CharacterHandsSlot",
    "CharacterFinger0Slot",
    "CharacterFinger1Slot",
    "CharacterTrinket0Slot",
    "CharacterTrinket1Slot",
    "CharacterBackSlot",
    "CharacterMainHandSlot",
    "CharacterSecondaryHandSlot",
}

local whileOpenEvents = {
    UPDATE_INVENTORY_DURABILITY = true,
}

local settings = {}

local function UpdateSettings()
    settings.enabled = GW.GetSetting("SHOW_CHARACTER_ITEM_INFO")
end
GW.UpdateHeroPanelItemInfoSettings = UpdateSettings

local function CreateInspectTexture(slot, x, y)
    local texture = slot:CreateTexture()
    texture:SetPoint("TOPLEFT", x, y)
    texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    texture:SetSize(12, 12)

    local backdrop = CreateFrame("Frame", nil, slot)
    if not backdrop.SetBackdrop then
        _G.Mixin(backdrop, _G.BackdropTemplateMixin)
        backdrop:HookScript("OnSizeChanged", backdrop.OnBackdropSizeChanged)

        backdrop:SetBackdrop(GW.constBackdropFrameColorBorder)
    end

    backdrop:SetBackdropColor(0, 0, 0, 0)
    backdrop:SetOutside(texture)
    backdrop:Hide()

    return texture, backdrop
end

local function GetInspectPoints(id)
    if not id then return end

    if id == 1 or id == 3 or id == 16 or id == 17 or (id >= 5 and id <=10) then
        return 47, 18, "BOTTOMLEFT" -- right sid
    elseif id == 2 or id == 11 or id == 13 then
        return 0, 25, "TOP"
    else
        return 0, -25, "BOTTOM"
    end
end

local function CreateSlotStrings()
    for i, s in pairs(InspectItems) do
        if i ~= 4 then
            local slot = _G[s]
            local x, z, justify = GetInspectPoints(i)

            slot.enchantText = slot:CreateFontString(nil, "OVERLAY")
            slot.enchantText:SetFont(UNIT_NAME_FONT, 10, "OUTLINE")
            if i ~= 1 and i ~= 3 and i ~= 16 and i ~= 17 and (i < 5 or i > 10) then
                slot.enchantText:SetSize(40, 30)
                slot.enchantText:SetFont(UNIT_NAME_FONT, 8, "OUTLINE")
            end
            slot.enchantText:SetPoint(justify, slot, x + (justify == "BOTTOMLEFT" and 5 or 0), z)

            for u = 1, 10 do
                local offset = (u - 1) * 13
                local offsetY = -2
                local newX = u == 1 and 2 or (justify == "BOTTOMLEFT" and -offset) or offset
                local newY = u == 4 and offsetY + 13 or u == 4 and offsetY + 26 or u == 7 and offsetY + 39 or offsetY
                slot["textureSlot" .. u], slot["textureSlotBackdrop" .. u] = CreateInspectTexture(slot, newX, newY)
            end
        end
    end
end

local function UpdatePageStrings(i, iLevelDB, inspectItem, slotInfo)
    iLevelDB[i] = slotInfo.iLvl

    if GW.RoundInt(inspectItem.enchantText:GetWidth()) == 40 then
        inspectItem.enchantText:SetText(slotInfo.enchantTextShort2)
    else
        inspectItem.enchantText:SetText(slotInfo.enchantTextShort)
    end
    if slotInfo.enchantColors and next(slotInfo.enchantColors) then
        inspectItem.enchantText:SetTextColor(unpack(slotInfo.enchantColors))
    end

    local gemStep = 1
    for x = 1, 10 do
        local texture = inspectItem["textureSlot"..x]
        local backdrop = inspectItem["textureSlotBackdrop"..x]

        local gem = slotInfo.gems and slotInfo.gems[gemStep]
        if gem then
            texture:SetTexture(gem)
            backdrop:SetBackdropBorderColor(slotInfo.itemLevelColors[1], slotInfo.itemLevelColors[2], slotInfo.itemLevelColors[3])
            backdrop:Show()

            gemStep = gemStep + 1
        else
            texture:SetTexture()
            backdrop:Hide()
        end
    end
end

local function TryGearAgain(i, deepScan, iLevelDB, inspectItem)
    C_Timer.After(0.05, function()
        local unit = "player"
        local slotInfo = GW.GetGearSlotInfo(unit, i, nil, deepScan)
        if slotInfo == "tooSoon" then return end

        UpdatePageStrings(i, iLevelDB, inspectItem, slotInfo)
    end)
end

do
    local iLevelDB = {}
    local function UpdatePageInfo(event)
        wipe(iLevelDB)

        local waitForItems
        for i = 1, 17 do
            if i ~= 4 then
                local inspectItem = _G[InspectItems[i]]
                inspectItem.enchantText:SetText("")

                local unit = "player"
                local slotInfo = GW.GetGearSlotInfo(unit, i, nil, true)
                if slotInfo == "tooSoon" then
                    if not waitForItems then waitForItems = true end
                    TryGearAgain(i, true, iLevelDB, inspectItem)
                else
                    UpdatePageStrings(i, iLevelDB, inspectItem, slotInfo)
                end
            end
        end

        if event and event == "PLAYER_EQUIPMENT_CHANGED" then
            return
        end
    end
    GW.UpdatePageInfo = UpdatePageInfo
end

local function UpdateCharacterInfo(_, event)
    if whileOpenEvents[event] and not GwCharacterWindow:IsShown() then return end

    GW.UpdatePageInfo(event)
end

local function ToggleCharacterItemInfo(setup)
    if setup then
        CreateSlotStrings()
    end

    if settings.enabled then
        f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        f:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        f:SetScript("OnEvent", UpdateCharacterInfo)
        if not f.CharacterInfoHooked then
            GwCharacterWindow:HookScript("OnShow", UpdateCharacterInfo)
            f.CharacterInfoHooked = true
        end

        if not setup then
            UpdateCharacterInfo()
        end
    else
        f:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
        f:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")

        for i = 1, 17 do
            if i ~= 4 then
                local inspectItem = _G[InspectItems[i]]
                inspectItem.enchantText:SetText("")

                for y = 1, 10 do
                    inspectItem["textureSlot" .. y]:SetTexture()
                    inspectItem["textureSlotBackdrop" .. y]:Hide()
                end
            end
        end
    end
end
GW.ToggleCharacterItemInfo = ToggleCharacterItemInfo