---@class GW2
local GW = select(2, ...)
local L = GW.L

local function LoadAurasPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow, "GwSettingsPanelTmpl")

    local p_auras = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_auras.panelId = "auras_general"
    p_auras.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_auras.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p_auras.header:SetText(L["Unitframes Auras"])
    p_auras.sub:SetFont(UNIT_NAME_FONT, 12)
    p_auras.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_auras.sub:SetText(L["Edit general unitframe aura settings."])
    p_auras.header:SetWidth(p_auras.header:GetStringWidth())
    p_auras.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_auras.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p_auras.breadcrumb:SetText(GENERAL)

    local p_indicator = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_indicator.panelId = "auras_indicators"
    p_indicator.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_indicator.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p_indicator.header:SetText(L["Unitframes Auras"])
    p_indicator.sub:SetFont(UNIT_NAME_FONT, 12)
    p_indicator.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_indicator.sub:SetText(L["Edit raid aura indicators."])
    p_indicator.header:SetWidth(p_indicator.header:GetStringWidth())
    p_indicator.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    p_indicator.breadcrumb:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    p_indicator.breadcrumb:SetText(L["Raid Indicators"])

    local panels = {
        {name = GENERAL, frame = p_auras},
        {name = L["Raid Indicators"], frame = p_indicator}
    }

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
    p_auras:AddOptionSlider(L["Set important Dungeon & Raid debuff scale"], nil, { getterSetter = "RAIDDEBUFFS_Scale", callback = function() GW.UpdateGridSettings("ALL", false) end, min = 0.5, max = 2, decimalNumbers = 2, step = 0.01, hidden = GW.Retail})
    p_auras:AddOptionSlider(L["Set dispellable debuff scale"], nil, { getterSetter = "DISPELL_DEBUFFS_Scale", callback = function() GW.UpdateGridSettings("ALL", false) end, min = 0.5, max = 2, decimalNumbers = 2, step = 0.01})
    p_auras:AddOptionDropdown(L["Important & dispellable debuff scale priority"], L["If both scales could apply to a debuff, which one should be used"], { getterSetter = "RAIDDEBUFFS_DISPELLDEBUFF_SCALE_PRIO", optionsList = {"DISPELL", "IMPORTANT", "OFF"}, optionNames = {L["Dispell > Important"], L["Important > Dispell"], OFF}})

    -- indicators
    p_indicator:AddOption(L["Show Spell Icons"], L["Show spell icons instead of monochrome squares."], { getterSetter = "INDICATORS_ICON", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_FRAMES"] = true}})
    p_indicator:AddOption(L["Show Remaining Time"], L["Show the remaining aura time as an animated overlay."], { getterSetter = "INDICATORS_TIME", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_FRAMES"] = true}})
    p_indicator:AddOption(L["Show Stack Count"], L["Show stack count text on raid aura indicators."], { getterSetter = "INDICATORS_STACKS", callback = function() GW.UpdateGridSettings("ALL", false) end, dependence = {["RAID_FRAMES"] = true}})
    p_indicator:AddOptionSlider(L["Indicator Size"], nil, { getterSetter = "INDICATORS_SIZE", callback = function() GW.UpdateGridSettings("ALL", false) end, min = 8, max = 20, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true}})
    p_indicator:AddOptionSlider(L["Indicator Bar Width"], nil, { getterSetter = "INDICATORS_BAR_WIDTH", callback = function() GW.UpdateGridSettings("ALL", false) end, min = 1, max = 5, decimalNumbers = 0, step = 1, dependence = {["RAID_FRAMES"] = true}})

    local function BuildIndicatorAuraOptions()
        local auraKeys, auraVals = {0}, {NONE_KEY}
        for spellID, _ in pairs(GW.AURAS_INDICATORS[GW.myclass]) do
            local spellInfo = C_Spell.GetSpellInfo(spellID)
            if spellInfo then
                local name = format("%s |cFF888888(%d)|r", spellInfo.name, spellID)

                if GW.Classic or GW.TBC or GW.Wrath then
                    local rank = GetSpellSubtext(spellID)
                    rank = rank and string.match(rank, "[%d]") or nil
                    name = name .. (rank and " |cFF888888(" .. RANK .. " " .. rank .. ")|r" or "")
                end
                tinsert(auraKeys, spellID)
                tinsert(auraVals, name)
            end
        end

        return auraKeys, auraVals
    end

    local auraKeys, auraVals = BuildIndicatorAuraOptions()
    local auraNamesUpdateFunction = function()
        local newKey, newNames = BuildIndicatorAuraOptions()

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

    if GW.Classic or GW.TBC or GW.Wrath then
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

    sWindow:AddSettingsPanel(p, L["Unitframes Auras"], L["Edit general unitframe aura settings and special grid settings."], panels)
end
GW.LoadAurasPanel = LoadAurasPanel
