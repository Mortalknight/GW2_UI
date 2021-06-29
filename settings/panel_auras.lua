local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addOptionText = GW.AddOptionText
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local InitPanel = GW.InitPanel

local function LoadAurasPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local p_auras = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    p_auras:SetHeight(180)
    p_auras:SetWidth(512)
    p_auras:ClearAllPoints()
    p_auras:SetPoint("TOPLEFT", p, "TOPLEFT", 0, 0)
    p_auras.scroll.scrollchild.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_auras.scroll.scrollchild.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p_auras.scroll.scrollchild.header:SetText(L["Raid Auras"])
    p_auras.scroll.scrollchild.sub:SetFont(UNIT_NAME_FONT, 12)
    p_auras.scroll.scrollchild.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_auras.scroll.scrollchild.sub:SetText(L["Edit which buffs and debuffs are shown."])

    local p_indicator = CreateFrame("Frame", nil, p, "GwSettingsPanelScrollTmpl")
    p_indicator:SetHeight(445)
    p_indicator:SetWidth(512)
    p_indicator:ClearAllPoints()
    p_indicator:SetPoint("TOPLEFT", p_auras, "BOTTOMLEFT", 0, 0)
    p_indicator.scroll.scrollchild.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_indicator.scroll.scrollchild.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p_indicator.scroll.scrollchild.header:SetText(L["Raid Indicators"])
    p_indicator.scroll.scrollchild.sub:SetFont(UNIT_NAME_FONT, 12)
    p_indicator.scroll.scrollchild.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_indicator.scroll.scrollchild.sub:SetText(L["Edit raid aura indicators."])

    createCat(L["Raid Auras"], L["Show or hide auras and edit raid aura indicators."], p, 2, nil, {p_auras, p_indicator})

    addOptionText(p_auras.scroll.scrollchild, L["Ignored Auras"], L["A list of auras that should never be shown."], "AURAS_IGNORED", nil, nil, nil, {["RAID_FRAMES"] = true})
    addOptionText(p_auras.scroll.scrollchild, L["Missing Buffs"], L["A list of buffs that should only be shown when they are missing."], "AURAS_MISSING", nil, nil, nil, {["RAID_FRAMES"] = true})

    local raidDebuffKeys, raidDebuffVales = {}, {}
    local settingstable = GetSetting("RAIDDEBUFFS")
    for spellID, _ in pairs(GW.ImportendRaidDebuff) do
        if spellID and GetSpellInfo(spellID) then
            local name = format("%s |cFF888888(%d)|r", GetSpellInfo(spellID), spellID)
            tinsert(raidDebuffKeys, spellID)
            tinsert(raidDebuffVales, name)

            GW.ImportendRaidDebuff[spellID] = settingstable[spellID]
        end
    end
    addOptionDropdown(
        p_auras.scroll.scrollchild,
        L["Dungeon & Raid Debuffs"],
        L["Show important Dungeon & Raid debuffs"],
        "RAIDDEBUFFS",
        function(toSet, id)
            GW.ImportendRaidDebuff[id] = toSet
        end,
        raidDebuffKeys,
        raidDebuffVales,
        nil,
        nil,
        true,
        nil,
        "spell"
    )

    addOption(p_indicator.scroll.scrollchild, L["Show Spell Icons"], L["Show spell icons instead of monochrome squares."], "INDICATORS_ICON", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p_indicator.scroll.scrollchild, L["Show Remaining Time"], L["Show the remaining aura time as an animated overlay."], "INDICATORS_TIME", nil, nil, {["RAID_FRAMES"] = true})

    local auraKeys, auraVals = {0}, {NONE_KEY}
    for spellID, indicator in pairs(GW.AURAS_INDICATORS[GW.myclass]) do
        if not indicator[4] then
            local name = format("%s |cFF888888(%d)|r", GetSpellInfo(spellID), spellID)
            tinsert(auraKeys, spellID)
            tinsert(auraVals, name)
        end
    end

    for v, pos in ipairs(GW.INDICATORS) do
        local key = "INDICATOR_" .. pos
        local t = L[GW.indicatorsText[v]]
        addOptionDropdown(
            p_indicator.scroll.scrollchild,
            L["%s Indicator"]:format(t),
            L["Edit %s raid aura indicator."]:format(t),
            key,
            function()
                SetSetting(key, tonumber(GetSetting(key, true)), true)
            end,
            auraKeys,
            auraVals,
            {perSpec = true},
            {["RAID_FRAMES"] = true},
            nil
        )
    end

    InitPanel(p_auras, true)
    InitPanel(p_indicator, true)
end
GW.LoadAurasPanel = LoadAurasPanel
