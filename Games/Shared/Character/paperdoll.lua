---@class GW2
local GW = select(2, ...)

local modelPositions = {
    Human = {0.4, 0, -0.05},
    Worgen = {0.1, 0, -0.1},
    Tauren = {0.6, 0, 0},
    HighmountainTauren = {0.6, 0, 0},
    BloodElf = {0.5, 0, 0},
    VoidElf = {0.5, 0, 0},
    Draenei = {0.3, 0, -0.15},
    LightforgedDraenei = {0.3, 0, -0.15},
    NightElf = {0.3, 0, -0.15},
    Nightborne = {0.3, 0, -0.15},
    Pandaren = {0.3, 0, -0.15},
    KulTiran = {0.3, 0, -0.15},
    Goblin = {0.2, 0, -0.05},
    Vulpera = {0.2, 0, -0.05},
    Troll = {0.2, 0, -0.05},
    ZandalariTroll = {0.2, 0, -0.05},
    Scourge = {0.2, 0, -0.05},
    Dwarf = {0.3, 0, 0},
    DarkIronDwarf = {0.3, 0, 0},
    Gnome = {0.2, 0, -0.05},
    Mechagnome = {0.2, 0, -0.05},
    Orc = {0.1, 0, -0.15},
    MagharOrc = {0.1, 0, -0.15},
    Dracthyr = {0.1, 0, -0.15},
}

local function EquipCursorItem()
    if InCombatLockdown() then return end
    local cursorItem = C_Cursor.GetCursorItem()
    if cursorItem and cursorItem.bagID and cursorItem.slotIndex then
        local itemID = C_Container.GetContainerItemID(cursorItem.bagID, cursorItem.slotIndex)
        if itemID then
            if C_Item.IsEquippableItem(itemID) and not  C_Item.IsEquippedItem(itemID) then
                C_Timer.After(1.1, function() C_Item.EquipItemByName(itemID) end)
            end
        end
        ClearCursor()
    end
end

function GW.SetPaperDollModelPosition(model)
    model:SetUnit("player")
    model:SetPosition(0.8, 0, 0)

    local pos = modelPositions[GW.myrace]
    if pos then
        model:SetPosition(unpack(pos))
    else
        model:SetPosition(0.8, 0, 0) -- fallback
    end

    model:SetRotation(-0.15)
    Model_OnLoad(model, 4, 0, -0.1, CharacterModelFrame_OnMouseUp)

    model:SetScript("OnReceiveDrag", EquipCursorItem)
    model:HookScript("OnMouseDown", EquipCursorItem)
end
