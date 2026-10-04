---@class GW2
local GW = select(2, ...)
local L = GW.L

local function LoadInterfaceFeaturesPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")
    p.panelId = "windows"
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p.header:SetText(L["UI Windows"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Enable or disable standalone GW2 UI features."])

    p:AddGroupHeader(CHARACTER)
    p:AddOption(L["Character Pane"], L["Replace the default character window."], {getterSetter = "windows.character.enabled", callback = function() GW.ShowRlPopup = true end, groupHeaderName = CHARACTER, isMasterToggle = true})
    p:AddOption(L["Show character item info"], L["Display gems and enchants on the GW2 character panel"], {getterSetter = "windows.character.itemInfo", callback = function() if not (GW.Classic or GW.TBC or GW.Wrath) then GW.ToggleCharacterItemInfo() end end, groupHeaderName = CHARACTER, dependence = {["windows.character.enabled"] = true}})
    p:AddOption(L["Missing enchant and socket warning"], L["Marks enchantable slots without an enchant and empty sockets in red."], {getterSetter = "windows.character.itemInfoMissing", callback = function() GW.ToggleCharacterItemInfo() end, groupHeaderName = CHARACTER, hidden = not (GW.Retail or GW.Forever), dependence = {["windows.character.enabled"] = true, ["windows.character.itemInfo"] = true}})
    p:AddOption(L["Color item level by equipped average"], L["Colors the slot item level green above, yellow slightly below and red well below your equipped average item level."], {getterSetter = "windows.character.itemLevelRelativeColor", callback = function() GW.ToggleCharacterItemInfo() end, groupHeaderName = CHARACTER, hidden = GW.Classic or GW.TBC or GW.Wrath, dependence = {["windows.character.enabled"] = true, ["windows.character.itemInfo"] = true}})

    p:AddGroupHeader(INVENTORY_TOOLTIP)
    p:AddOption(INVENTORY_TOOLTIP, L["Enable the unified inventory interface."], {getterSetter = "bags.enabled", callback = function() GW.ShowRlPopup = true end, groupHeaderName = INVENTORY_TOOLTIP, incompatibleAddons = "Inventory", isMasterToggle = true})

    p:AddGroupHeader(TALENTS, {hidden = GW.Retail})
    p:AddOption(TALENTS, L["Enable the talents, specialization, and spellbook replacement."], {getterSetter = "windows.talent.enabled", callback = function() GW.ShowRlPopup = true end, groupHeaderName = TALENTS, hidden = GW.Retail, isMasterToggle = true})
    p:AddOption(SPELLBOOK_ABILITIES_BUTTON, nil, {getterSetter = "windows.spellbook.enabled", callback = function() GW.ShowRlPopup = true end, groupHeaderName = TALENTS, hidden = GW.Retail, isMasterToggle = true})

    p:AddGroupHeader(TRADE_SKILLS, {hidden = not GW.isModern})
    p:AddOption(TRADE_SKILLS, L["Enable the profession replacement."], {getterSetter = "windows.profession.enabled", callback = function() GW.ShowRlPopup = true end, groupHeaderName = TRADE_SKILLS, hidden = not GW.isModern, isMasterToggle = true})

    sWindow:AddSettingsPanel(p, L["UI Windows"], L["Enable or disable standalone GW2 UI features."])
end
GW.LoadInterfaceFeaturesPanel = LoadInterfaceFeaturesPanel
