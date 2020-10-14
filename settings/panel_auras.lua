local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addOptionText = GW.AddOptionText
local createCat = GW.CreateCat
local StrUpper = GW.StrUpper
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local InitPanel = GW.InitPanel

local function LoadAurasPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:Hide()
    p.sub:Hide()

    local p_auras = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_auras:SetHeight(140)
    p_auras:ClearAllPoints()
    p_auras:SetPoint("TOPLEFT", p, "TOPLEFT", 0, 0)
    p_auras.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_auras.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p_auras.header:SetText(L["RAID_AURAS"])
    p_auras.sub:SetFont(UNIT_NAME_FONT, 12)
    p_auras.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_auras.sub:SetText(L["RAID_AURAS_DESC"])

    local p_indicator = CreateFrame("Frame", nil, p, "GwSettingsPanelTmpl")
    p_indicator:SetHeight(360)
    p_indicator:ClearAllPoints()
    p_indicator:SetPoint("TOPLEFT", p_auras, "BOTTOMLEFT", 0, 0)
    p_indicator.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p_indicator.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p_indicator.header:SetText(L["INDICATORS"])
    p_indicator.sub:SetFont(UNIT_NAME_FONT, 12)
    p_indicator.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p_indicator.sub:SetText(L["INDICATORS_DESC"])

    createCat(L["RAID_AURAS"], L["RAID_AURAS_TOOLTIP"], p, 2)

    addOptionText(p_auras, L["RAID_AURAS_IGNORED"], L["RAID_AURAS_IGNORED_DESC"], "AURAS_IGNORED", nil, nil, nil, {["RAID_FRAMES"] = true})
    addOptionText(p_auras, L["RAID_AURAS_MISSING"], L["RAID_AURAS_MISSING_DESC"], "AURAS_MISSING", nil, nil, nil, {["RAID_FRAMES"] = true})
    addOption(p_indicator, L["INDICATORS_ICON"], L["INDICATORS_ICON_DESC"], "INDICATORS_ICON", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p_indicator, L["INDICATORS_TIME"], L["INDICATORS_TIME_DESC"], "INDICATORS_TIME", nil, nil, {["RAID_FRAMES"] = true})

    local auraKeys, auraVals = {0}, {NONE_KEY}
    for spellID, indicator in pairs(GW.AURAS_INDICATORS[GW.myclass]) do
        if not indicator[4] then
            tinsert(auraKeys, spellID)
            tinsert(auraVals, (GetSpellInfo(spellID)))
        end
    end

    for _, pos in ipairs(GW.INDICATORS) do
        local key = "INDICATOR_" .. pos
        local t = StrUpper(L[key] or L[pos], 1, 1)
        addOptionDropdown(
            p_indicator,
            L["INDICATOR_TITLE"]:format(t),
            L["INDICATOR_DESC"]:format(t),
            key,
            function()
                SetSetting(key, tonumber(GetSetting(key, true)), true)
            end,
            auraKeys,
            auraVals,
            {perSpec = true},
            {["RAID_FRAMES"] = true}
        )
    end

    InitPanel(p_auras)
    InitPanel(p_indicator)
end
GW.LoadAurasPanel = LoadAurasPanel
