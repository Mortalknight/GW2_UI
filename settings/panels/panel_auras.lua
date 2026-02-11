local _, GW = ...
local L = GW.L

local function LoadAurasPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")

    local p_auras = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_auras.panelId = "auras_general"
    p_auras.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_auras.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_auras.header:SetText(L["Unitframes Auras"])
    p_auras.sub:SetFont(UNIT_NAME_FONT, 12)
    p_auras.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_auras.sub:SetText(L["Edit general unitframe aura settings."])
    p_auras.header:SetWidth(p_auras.header:GetStringWidth())
    p_auras.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_auras.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_auras.breadcrumb:SetText(GENERAL)

    local p_indicator = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_indicator.panelId = "auras_indicators"
    p_indicator.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_indicator.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_indicator.header:SetText(L["Unitframes Auras"])
    p_indicator.sub:SetFont(UNIT_NAME_FONT, 12)
    p_indicator.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_indicator.sub:SetText(L["Edit raid aura indicators."])
    p_indicator.header:SetWidth(p_indicator.header:GetStringWidth())
    p_indicator.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_indicator.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_indicator.breadcrumb:SetText(L["Raid Indicators"])

    local p_missingBuffs = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_missingBuffs.panelId = "auras_missing"
    p_missingBuffs.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_missingBuffs.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_missingBuffs.header:SetText(L["Unitframes Auras"])
    p_missingBuffs.sub:SetFont(UNIT_NAME_FONT, 12)
    p_missingBuffs.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_missingBuffs.sub:SetText(L["Edit raid buff bar."])
    p_missingBuffs.header:SetWidth(p_missingBuffs.header:GetStringWidth())
    p_missingBuffs.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_missingBuffs.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    p_missingBuffs.breadcrumb:SetText(L["Missing Raid Buffs"])

    local panels = {
        {name = GENERAL, frame = p_auras},
    }

    if not GW.Retail then
        table.insert(panels, {name = L["Raid Indicators"], frame = p_indicator})
    end

    p_auras:AddOptionText(L["Ignored Auras"], L["A list of auras that should never be shown."], { getterSetter = "AURAS_IGNORED", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_FRAMES"] = true}, hidden = GW.Retail})
    p_auras:AddOptionText(L["Missing Buffs"], L["A list of buffs that should only be shown when they are missing."], { getterSetter = "AURAS_MISSING", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_FRAMES"] = true}, hidden = GW.Retail})

    local raidDebuffKeys, raidDebuffValues = {}, {}
    local settingstable = GW.settings.RAIDDEBUFFS
    for spellID, _ in pairs(GW.ImportantRaidDebuff) do
        local spellinfo = C_Spell.GetSpellInfo(spellID)
        if spellID and spellinfo then
            local name = format("%s |cFF888888(%d)|r", spellinfo.name, spellID)
            tinsert(raidDebuffKeys, spellID)
            tinsert(raidDebuffValues, name)

            GW.ImportantRaidDebuff[spellID] = settingstable[spellID] == nil and true or settingstable[spellID]
        end
    end
    p_auras:AddOptionDropdown(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], { getterSetter = "RAIDDEBUFFS", callback = function(toSet, id) GW.ImportantRaidDebuff[id] = toSet end, optionsList = raidDebuffKeys, optionNames = raidDebuffValues, tooltipType = "spell", checkbox = true, hidden = GW.Retail})
    p_auras:AddOptionSlider(L["Set important Dungeon & Raid debuff scale"], nil, { getterSetter = "RAIDDEBUFFS_Scale", callback = function() GW.UpdateGridSettings("ALL", false) end, min = 0.5, max = 2, decimalNumbers = 2, step = 0.01})
    p_auras:AddOptionSlider(L["Set dispellable debuff scale"], nil, { getterSetter = "DISPELL_DEBUFFS_Scale", callback = function() GW.UpdateGridSettings("ALL", false) end, min = 0.5, max = 2, decimalNumbers = 2, step = 0.01})
    p_auras:AddOptionDropdown(L["Important & dispellable debuff scale priority"], L["If both scales could apply to a debuff, which one should be used"], { getterSetter = "RAIDDEBUFFS_DISPELLDEBUFF_SCALE_PRIO", optionsList = {"DISPELL", "IMPORTANT", "OFF"}, optionNames = {L["Dispell > Important"], L["Important > Dispell"], OFF}})

    -- indicators
    p_indicator:AddOption(L["Show Spell Icons"], L["Show spell icons instead of monochrome squares."], { getterSetter = "INDICATORS_ICON", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_FRAMES"] = true}})
    p_indicator:AddOption(L["Show Remaining Time"], L["Show the remaining aura time as an animated overlay."], { getterSetter = "INDICATORS_TIME", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_FRAMES"] = true}})

    local auraKeys, auraVals = {0}, {NONE_KEY}
    for spellID, indicator in pairs(GW.AURAS_INDICATORS[GW.myclass]) do
        if not indicator[4] then
            local spellInfo = C_Spell.GetSpellInfo(spellID)
            if spellInfo then
                local name = format("%s |cFF888888(%d)|r", spellInfo.name, spellID)

                if GW.Classic or GW.TBC then
                    local rank = GetSpellSubtext(spellID)
                    rank = rank and string.match(rank, "[%d]") or nil
                    name = name .. (rank and " |cFF888888(" .. RANK .. " " .. rank .. ")|r" or "")
                end
                tinsert(auraKeys, spellID)
                tinsert(auraVals, name)
            end
        end
    end

    local auraNamesUpdateFunction = function()
        local newKey, newNames = {0}, {NONE_KEY}
        for spellID, indicator in pairs(GW.AURAS_INDICATORS[GW.myclass]) do
            if not indicator[4] then
                local spellInfo = C_Spell.GetSpellInfo(spellID)
                if spellInfo then
                    local name = format("%s |cFF888888(%d)|r", spellInfo.name, spellID)

                    if GW.Classic or GW.TBC then
                        local rank = GetSpellSubtext(spellID)
                        rank = rank and string.match(rank, "[%d]") or nil
                        name = name .. (rank and " |cFF888888(" .. RANK .. " " .. rank .. ")|r" or "")
                    end
                    tinsert(newKey, spellID)
                    tinsert(newNames, name)
                end
            end
        end

        for _, pos in ipairs(GW.INDICATORS) do
            local settingsWidget = GW.FindSettingsWidgetByOption("INDICATOR_" .. pos)
            if settingsWidget then
                settingsWidget.optionsList = newKey
                settingsWidget.optionNames = newNames
                settingsWidget.dropDown:GenerateMenu()
            end
        end
    end

    for v, pos in ipairs(GW.INDICATORS) do
        local key = "INDICATOR_" .. pos
        local t = L[GW.indicatorsText[v]]
        p_indicator:AddOptionDropdown(L["%s Indicator"]:format(t), L["Edit %s raid aura indicator."]:format(t), {getterSetter = key, callback = function() GW.settings[key] = tonumber(GW.settings[key]); GW.UpdateGridSettings("ALL", false) end, optionsList = auraKeys, optionNames = auraVals, optionUpdateFunc = auraNamesUpdateFunction, dependence = {["RAID_FRAMES"] = true}, tooltipType = "spell"})
    end

    if GW.Classic or GW.TBC then
        -- Rank info are not there after game start
        C_Timer.After(3, function()
            for _, pos in ipairs(GW.INDICATORS) do
                local settingsWidget = GW.FindSettingsWidgetByOption("INDICATOR_" .. pos)
                if settingsWidget and settingsWidget.optionUpdateFunc then
                   settingsWidget.optionUpdateFunc()
                end
            end
        end)
    end

    p_missingBuffs:AddOptionDropdown(L["Show Missing Raid Buffs Bar"], L["Whether to display a floating bar showing your missing buffs. This can be moved via the 'Move HUD' interface."], { getterSetter = "MISSING_RAID_BUFF", callback = function() if GwRaidBuffReminder then GwRaidBuffReminder:UpdateVisibility() end end, optionsList = {"ALWAYS", "NEVER", "IN_GROUP", "IN_RAID", "IN_RAID_IN_PARTY"}, optionNames = {ALWAYS, NEVER, AGGRO_WARNING_IN_PARTY, L["In raid"], L["In group or in raid"]}, hidden = not GW.Retail})
    p_missingBuffs:AddOption(L["Dimmed"], nil, { getterSetter = "MISSING_RAID_BUFF_dimmed", callback = function() if GwRaidBuffReminder then GwRaidBuffReminder:UpdateButtons() end end, hidden = not GW.Retail})
    p_missingBuffs:AddOption(L["Greyed out"], nil, { getterSetter = "MISSING_RAID_BUFF_grayed_out", callback = function() if GwRaidBuffReminder then GwRaidBuffReminder:UpdateButtons() end end, hidden = not GW.Retail})
    p_missingBuffs:AddOption(L["Animated"], L["If enabled, an animated border will surround the missing raid buffs"], { getterSetter = "MISSING_RAID_BUFF_animated", callback = function() if GwRaidBuffReminder then GwRaidBuffReminder:UpdateButtons() end end, hidden = not GW.Retail})
    p_missingBuffs:AddOption(L["Invert raid buff bar"], L["If enabled, the above settings will apply to buffs you have, instead of buffs you are missing"], { getterSetter = "MISSING_RAID_BUFF_INVERT", callback = function() if GwRaidBuffReminder then GwRaidBuffReminder:UpdateButtons() end end, forceNewLine = true, hidden = not GW.Retail})
    p_missingBuffs:AddOptionText(L["Custom buff"], L["Enter the spell ID of the buff you wish to track. Only one spell ID is supported. To find the spell ID of the buff you want to track, enable IDs in the tooltip settings and mouse over the icon in your aura bar."], { getterSetter = "MISSING_RAID_BUFF_custom_id", callback = function() if GwRaidBuffReminder then GwRaidBuffReminder:UpdateCustomSpell() end end, hidden = not GW.Retail})

    sWindow:AddSettingsPanel(p, L["Unitframes Auras"], L["Edit general unitframe aura settings and special grid settings."], panels)
end
GW.LoadAurasPanel = LoadAurasPanel
