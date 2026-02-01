local _, GW = ...
local L = GW.L

local function LoadModulesPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")
    p.panelId = "modules_general"
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p.header:SetText(L["Modules"])
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Enable or disable the modules you need and don't need."])

    p:AddOption(XPBAR_LABEL, nil, {getterSetter = "XPBAR_ENABLED", callback = function() GW.ShowRlPopup = true end})
    p:AddOption(L["Health Globe"], L["Enable the health bar replacement."], {getterSetter = "HEALTHGLOBE_ENABLED", callback = function() GW.ShowRlPopup = true end})
    p:AddOption(DISPLAY_POWER_BARS, L["Replace the default mana/power bar."], {getterSetter = "POWERBAR_ENABLED", callback = function() GwPlayerPowerBar:ToggleBar(); GW.UpdateClassPowerExtraManabar() end})
    p:AddOption(FOCUS, L["Enable the focus target frame replacement."], {getterSetter = "FOCUS_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = GW.Classic})
    p:AddOption(TARGET, L["Enable the target frame replacement."], {getterSetter = "TARGET_ENABLED", callback = function() GW.ShowRlPopup = true end})
    p:AddOption(MINIMAP_LABEL, L["Use the GW2 UI Minimap frame."], {getterSetter = "MINIMAP_ENABLED", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "Minimap"})
    p:AddOption(OBJECTIVES_TRACKER_LABEL, L["Enable the revamped and improved quest tracker."], {getterSetter = "QUESTTRACKER_ENABLED", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "Objectives"})
    p:AddOption(L["Tooltips"], L["Replace the default UI tooltips."], {getterSetter = "TOOLTIPS_ENABLED", callback = function() GW.ShowRlPopup = true end})
    p:AddOption(COMMUNITIES_ADD_TO_CHAT_DROP_DOWN_TITLE, L["Enable the improved chat window."], {getterSetter = "CHATFRAME_ENABLED", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "Chat"})
    p:AddOption(L["Immersive Questing"], L["Enable the immersive questing view."], {getterSetter = "QUESTVIEW_ENABLED", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "ImmersiveQuesting"})
    p:AddOption(BUFFOPTIONS_LABEL, L["Move and resize the player auras."], {getterSetter = "PLAYER_BUFFS_ENABLED", callback = function() GW.ShowRlPopup = true end})
    p:AddOption(BINDING_HEADER_ACTIONBAR, L["Use the GW2 UI improved action bars."], {getterSetter = "ACTIONBARS_ENABLED", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "Actionbars"})
    p:AddOption(BINDING_NAME_TOGGLECHARACTER3, L["Use the GW2 UI improved Pet bar."], {getterSetter = "PETBAR_ENABLED", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "PetFrame"})
    p:AddOption(INVENTORY_TOOLTIP, L["Enable the unified inventory interface."], {getterSetter = "BAGS_ENABLED", callback = function() GW.ShowRlPopup = true end, incompatibleAddons = "Inventory"})
    p:AddOption(SHOW_ENEMY_CAST, L["Enable the GW2 style casting bar."], {getterSetter = "CASTINGBAR_ENABLED", callback = function() GW.ShowRlPopup = true end})
    p:AddOption(L["Class Power"], L["Enable the alternate class powers."], {getterSetter = "CLASS_POWER", callback = function() GW.ShowRlPopup = true end})
    p:AddOption(RAID_FRAMES_LABEL, RAID_FRAMES_SUBTEXT, {getterSetter = "RAID_FRAMES", callback = function() GW.ShowRlPopup = true end})
    p:AddOption(L["Group Frames"], L["Replace the default UI group frames."], {getterSetter = "PARTY_FRAMES", callback = function() GW.ShowRlPopup = true end})
    p:AddOption(BINDING_NAME_TOGGLECHARACTER0, L["Replace the default character window."], {getterSetter = "USE_CHARACTER_WINDOW", callback = function() GW.ShowRlPopup = true end})
    p:AddOption(TALENTS, L["Enable the talents, specialization, and spellbook replacement."], {getterSetter = "USE_TALENT_WINDOW", callback = function() GW.ShowRlPopup = true end, hidden = GW.Retail})
    p:AddOption(SPELLBOOK_ABILITIES_BUTTON, SPELLBOOK_ABILITIES_BUTTON, {getterSetter = "USE_SPELLBOOK_WINDOW", callback = function() GW.ShowRlPopup = true end, hidden = GW.Retail})
    p:AddOption(TRADE_SKILLS, L["Enable the profession replacement."], {getterSetter = "USE_PROFESSION_WINDOW", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    p:AddOption(BATTLEGROUND, nil, {getterSetter = "USE_BATTLEGROUND_HUD", callback = function() GW.ShowRlPopup = true end, hidden = not GW.Retail})
    p:AddOption(CAMERA_FOLLOWING_STYLE .. ": " .. DYNAMIC, nil, {getterSetter = "DYNAMIC_CAM",
        callback = function(value)
            C_CVar.SetCVar("test_cameraDynamicPitch", value and "1" or "0")
            C_CVar.SetCVar("cameraKeepCharacterCentered", value and "0" or "1")
            C_CVar.SetCVar("cameraReduceUnexpectedMovement", value and "0" or "1")
        end, incompatibleAddons = "DynamicCam"})
    p:AddOption(CHAT_BUBBLES_TEXT, L["Replace the default UI chat bubbles. (Only in not protected areas)"], {getterSetter = "CHATBUBBLES_ENABLED", callback = function() GW.ShowRlPopup = true end})
    p:AddOption(L["Alert Frames"], nil, {getterSetter = "ALERTFRAME_ENABLED", callback = function() GW.ShowRlPopup = true end, hidden = GW.Classic or GW.TBC})
    p:AddOption(FRIENDS, nil, {getterSetter = "USE_SOCIAL_WINDOW", callback = function() GW.ShowRlPopup = true end, hidden = not (GW.Retail or GW.TBC)})

    p:AddOption(L["Micro Bar"], nil, {getterSetter = "micromenu.enabled", callback = function() GW.ShowRlPopup = true end})


    sWindow:AddSettingsPanel(p, L["Modules"], L["Enable or disable the modules you need and don't need."])
end
GW.LoadModulesPanel = LoadModulesPanel
