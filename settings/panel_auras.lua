local _, GW = ...
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addOptionText = GW.AddOptionText
local createCat = GW.CreateCat
local StrUpper = GW.StrUpper
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting

local function LoadAurasPanel(sWindow)
    local pnl_frame = CreateFrame("Frame", "GwSettingsAurasframe", sWindow.panels, "GwSettingsPanelTmpl")
    pnl_frame.header:Hide()
    pnl_frame.sub:Hide()

    local pnl_auras = CreateFrame("Frame", "GwSettingsAurasOptions", pnl_frame, "GwSettingsPanelTmpl")
    pnl_auras:SetHeight(140)
    pnl_auras.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pnl_auras.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    pnl_auras.header:SetText(AURAS)
    pnl_auras.sub:SetFont(UNIT_NAME_FONT, 12)
    pnl_auras.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pnl_auras.sub:SetText(GwLocalization["AURAS_DESC"])

    local pnl_indicator = CreateFrame("Frame", "GwSettingsIndicatorsOptions", pnl_frame, "GwSettingsPanelTmpl")
    pnl_indicator:SetHeight(360)
    pnl_indicator:ClearAllPoints()
    pnl_indicator:SetPoint("TOPLEFT", pnl_auras, "BOTTOMLEFT", 0, 0)
    pnl_indicator.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pnl_indicator.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    pnl_indicator.header:SetText(GwLocalization["INDICATORS"])
    pnl_indicator.sub:SetFont(UNIT_NAME_FONT, 12)
    pnl_indicator.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pnl_indicator.sub:SetText(GwLocalization["INDICATORS_DESC"])

    createCat(AURAS, GwLocalization["AURAS_TOOLTIP"], "GwSettingsAurasframe", 2)

    addOptionText(
        GwLocalization["AURAS_IGNORED"],
        GwLocalization["AURAS_IGNORED_DESC"],
        "AURAS_IGNORED",
        "GwSettingsAurasOptions",
        function() end
    )

    addOptionText(
        GwLocalization["AURAS_MISSING"],
        GwLocalization["AURAS_MISSING_DESC"],
        "AURAS_MISSING",
        "GwSettingsAurasOptions",
        function() end
    )

    addOption(
        GwLocalization["INDICATORS_ICON"],
        GwLocalization["INDICATORS_ICON_DESC"],
        "INDICATORS_ICON",
        "GwSettingsIndicatorsOptions",
        function () end
    )

    addOption(
        GwLocalization["INDICATORS_TIME"],
        GwLocalization["INDICATORS_TIME_DESC"],
        "INDICATORS_TIME",
        "GwSettingsIndicatorsOptions",
        function () end
    )

    local auraKeys, auraVals = {0}, {NONE_KEY}
    for spellID,indicator in pairs(GW.AURAS_INDICATORS[select(2, UnitClass("player"))]) do
        if not indicator[4] then
            tinsert(auraKeys, spellID)
            tinsert(auraVals, (GetSpellInfo(spellID)))
        end
    end

    for _,pos in ipairs(GW.INDICATORS) do
        local key = "INDICATOR_" .. pos
        local t = StrUpper(GwLocalization[key] or GwLocalization[pos], 1, 1)
        addOptionDropdown(
            GwLocalization["INDICATOR_TITLE"]:format(t),
            GwLocalization["INDICATOR_DESC"]:format(t),
            key,
            "GwSettingsIndicatorsOptions",
            function () SetSetting(key, tonumber(GetSetting(key, true)), true) end,
            auraKeys,
            auraVals,
            {perSpec = true}
        )
    end
end
GW.LoadAurasPanel = LoadAurasPanel
