---@class GW2
local GW = select(2, ...)
local Tooltip = GW.Tooltip

-- spells and macros: the typed data knows the id, the old clients ask the tooltip
local function AddSpellID(tooltip, data)
    if tooltip ~= GameTooltip or tooltip:IsForbidden() or not Tooltip.IsModifierDown() then
        return
    end
    local spellID
    if data and data.type == Enum.TooltipDataType.Macro then
        local info = tooltip:GetTooltipData()
        spellID = info and info.lines[1] and info.lines[1].tooltipID
    elseif data then
        spellID = data.id
    else
        spellID = select(2, tooltip:GetSpell())
    end
    if GW.NotSecretValue(spellID) and spellID then
        Tooltip.AddID(tooltip, spellID)
    end
end

-- npcs, pets and vehicles: the id is the second to last part of their guid
local function AddNpcID(tooltip, data)
    if tooltip ~= GameTooltip or tooltip:IsForbidden() or not Tooltip.IsModifierDown() or (C_PetBattles and C_PetBattles.IsInBattle()) then
        return
    end
    local guid
    if data then
        guid = data.guid
    else
        local unit = select(2, tooltip:GetUnit())
        guid = GW.NotSecretValue(unit) and unit and UnitGUID(unit)
    end
    local npcID = GW.NotSecretValue(guid) and guid and not strfind(guid, "^Player") and strmatch(guid, "%-(%d+)%-%x+$")
    if npcID then
        Tooltip.AddID(tooltip, npcID)
    end
end

-- the tooltip hooks that are handed the id right away
local function AddGivenID(tooltip, id, spaced)
    if not tooltip:IsForbidden() and id and Tooltip.IsModifierDown() then
        Tooltip.AddID(tooltip, id, spaced)
    end
end

local function AddQuestID(frame)
    if GameTooltip:IsForbidden() or not Tooltip.IsModifierDown() then
        return
    end
    local questID = frame.questLogIndex and C_QuestLog.GetQuestIDForLogIndex(frame.questLogIndex) or frame.questID
    if questID then
        Tooltip.AddID(GameTooltip, questID)
    end
end

-- embedded item tooltips of quest rewards and the like
local function AddEmbeddedID(embedded, id)
    if not embedded:IsForbidden() and embedded.Tooltip:IsShown() then
        AddGivenID(embedded.Tooltip, id or embedded.itemID or embedded.spellID)
    end
end

-- not every client has every tooltip function
local function HookGlobal(name, func)
    if _G[name] then
        hooksecurefunc(name, func)
    end
end

local function HookMethod(object, name, func)
    if object[name] then
        hooksecurefunc(object, name, func)
    end
end

-- the secure aura tooltips take no lines from addons, blizzard shows their ids through this cvar;
-- the settings panel calls it too
function GW.UpdateAuraTooltipIDCVar()
    if GW.isModern then
        C_CVar.SetCVar("tooltipShowAuraSpellIDs", Tooltip.IsModifierDown() and "1" or "0")
    end
end

GW.RegisterTooltipModule({
    onLoad = function()
        GW.UpdateAuraTooltipIDCVar()
        local watcher = CreateFrame("Frame")
        watcher:RegisterEvent("MODIFIER_STATE_CHANGED")
        watcher:SetScript("OnEvent", GW.UpdateAuraTooltipIDCVar)

        Tooltip.OnTooltipData("Spell", AddSpellID)
        Tooltip.OnTooltipData("Macro", AddSpellID)
        Tooltip.OnTooltipData("Unit", AddNpcID)

        HookMethod(GameTooltip, "SetToyByItemID", function(tooltip, id) AddGivenID(tooltip, id, true) end)
        HookMethod(GameTooltip, "SetCurrencyByID", function(tooltip, id) AddGivenID(tooltip, id, true) end)
        HookMethod(GameTooltip, "SetCurrencyToken", function(tooltip, index)
            local link = index and C_CurrencyInfo.GetCurrencyListLink(index)
            AddGivenID(tooltip, link and strmatch(link, "currency:(%d+)"), true)
        end)
        HookMethod(GameTooltip, "SetBackpackToken", function(tooltip, index)
            local info = index and C_CurrencyInfo.GetBackpackCurrencyInfo(index)
            AddGivenID(tooltip, info and info.currencyTypesID)
        end)
        HookGlobal("TaskPOI_OnEnter", AddQuestID)
        HookGlobal("QuestMapLogTitleButton_OnEnter", AddQuestID)
        HookGlobal("BattlePetToolTip_Show", function()
            AddGivenID(BattlePetTooltip, BattlePetTooltip.speciesID, true)
        end)
        for _, name in ipairs({"EmbeddedItemTooltip_SetItemByID", "EmbeddedItemTooltip_SetCurrencyByID", "EmbeddedItemTooltip_SetSpellWithTextureByID"}) do
            HookGlobal(name, AddEmbeddedID)
        end
        for _, name in ipairs({"EmbeddedItemTooltip_SetItemByQuestReward", "EmbeddedItemTooltip_SetSpellByQuestReward"}) do
            HookGlobal(name, function(embedded) AddEmbeddedID(embedded) end)
        end

        -- a clicked spell link opens the item ref tooltip, shift and co. are for chat links
        hooksecurefunc("SetItemRef", function(link)
            if not IsModifierKeyDown() and link and strfind(link, "^spell:") then
                Tooltip.AddID(ItemRefTooltip, strmatch(link, ":(%d+)"))
            end
        end)
    end,
})
