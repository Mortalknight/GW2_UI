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

    -- the ignored auras moved to per grid spell id lists on the grid settings pages
    -- (panel_raid, CreateAuraFilterSection) — for every game version
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
    p_auras:AddOptionDropdown(L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], { getterSetter = "RAIDDEBUFFS", callback = function(toSet, id)
        GW.ImportantRaidDebuff[id] = toSet
        -- the AuraContainers hold a securecopy of the includeSpellIDs map — the central
        -- refresh re-applies every registered container (party, later grids, ...)
        if GW.RefreshAllAuraContainers then
            GW.RefreshAllAuraContainers()
        end
    end, optionsList = raidDebuffKeys, optionNames = raidDebuffValues, tooltipType = "spell", checkbox = true})
    p_auras:AddOptionSlider(L["Set important Dungeon & Raid debuff scale"], nil, { getterSetter = "RAIDDEBUFFS_Scale", callback = function()
        GW.UpdateGridSettings("ALL", false)
        if GW.RefreshAllAuraContainers then
            GW.RefreshAllAuraContainers()
        end
    end, min = 0.5, max = 2, decimalNumbers = 2, step = 0.01})
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
        for spellID, _ in pairs(GW.AURAS_INDICATORS[GW.myclass] or {}) do
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

        -- custom spell ids currently in use need a labeled entry, otherwise the
        -- dropdown cannot render the selection
        local predefined = GW.AURAS_INDICATORS[GW.myclass]
        for _, pos in ipairs(GW.INDICATORS) do
            local value = tonumber(GW.settings["INDICATOR_" .. pos]) or 0
            if value > 0 and not (predefined and predefined[value]) and not tContains(auraKeys, value) then
                local spellInfo = C_Spell.GetSpellInfo(value)
                tinsert(auraKeys, value)
                tinsert(auraVals, format("%s |cFF888888(%d)|r", spellInfo and spellInfo.name or UNKNOWN, value))
            end
        end

        -- sentinel entry: opens a popup to enter any spell id
        tinsert(auraKeys, -1)
        tinsert(auraVals, "|cff98a7e4" .. L["Custom Spell ID..."] .. "|r")

        return auraKeys, auraVals
    end

    local auraKeys, auraVals = BuildIndicatorAuraOptions()
    local lastIndicatorValue = {}
    for _, pos in ipairs(GW.INDICATORS) do
        lastIndicatorValue["INDICATOR_" .. pos] = tonumber(GW.settings["INDICATOR_" .. pos]) or 0
    end

    local auraNamesUpdateFunction = function()
        -- the dropdown menus read from the SHARED tables captured at creation —
        -- mutate them in place, assigning new tables to the widget never reaches
        -- the menu closures
        local newKeys, newNames = BuildIndicatorAuraOptions()
        wipe(auraKeys)
        wipe(auraVals)
        for i = 1, #newKeys do
            auraKeys[i] = newKeys[i]
            auraVals[i] = newNames[i]
        end

        for _, pos in ipairs(GW.INDICATORS) do
            -- keep the sentinel restore values in sync (profile switch/import)
            lastIndicatorValue["INDICATOR_" .. pos] = tonumber(GW.settings["INDICATOR_" .. pos]) or 0
            local settingsWidget = GW.FindSettingsWidgetByOption("INDICATOR_" .. pos)
            if settingsWidget and settingsWidget.dropDown then
                settingsWidget.dropDown:GenerateMenu()
            end
        end
    end

    for v, pos in ipairs(GW.INDICATORS) do
        local key = "INDICATOR_" .. pos
        local t = L[GW.indicatorsText[v]]
        p_indicator:AddOptionDropdown(L["%s Indicator"]:format(t), L["Edit %s raid aura indicator."]:format(t), {getterSetter = key, callback = function()
            local value = tonumber(GW.settings[key]) or 0

            if value == -1 then
                -- sentinel selected: restore the previous value and ask for a spell id
                GW.settings[key] = lastIndicatorValue[key] or 0
                GW.ShowPopup({
                    text = format(L["Enter a spell ID for the %s indicator:"], t),
                    hasEditBox = true,
                    hideOnEscape = true,
                    maxLetters = 10,
                    notHideOnAccept = true,
                    OnAccept = function(popup)
                        local id = tonumber((popup.input:GetText() or ""):trim())
                        local spellInfo = id and C_Spell.GetSpellInfo(id)
                        if not spellInfo then
                            UIErrorsFrame:AddMessage(L["Invalid spell ID"], 1, 0.2, 0.2)
                            return
                        end
                        GW.settings[key] = id
                        lastIndicatorValue[key] = id
                        auraNamesUpdateFunction()
                        GW.UpdateGridSettings("ALL", false)
                        popup:Hide()
                    end,
                })
                auraNamesUpdateFunction()
                return
            end

            GW.settings[key] = value
            lastIndicatorValue[key] = value
            GW.UpdateGridSettings("ALL", false)
        end, optionsList = auraKeys, optionNames = auraVals, optionUpdateFunc = auraNamesUpdateFunction, dependence = {["RAID_FRAMES"] = true}, tooltipType = "spell"})
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
