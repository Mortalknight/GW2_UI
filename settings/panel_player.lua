local _, GW = ...
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling
local L = GwLocalization

local function LoadPlayerPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(PLAYER)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["PLAYER_DESC"])

    createCat(PLAYER, L["PLAYER_DESC"], p, 9)

    addOptionDropdown(
        p,
        "Aura Style",
        nil,
        "PLAYER_AURA_STYLE",
        nil,
        {"LEGACY", "SECURE"},
        {
            "Legacy",
            "Secure"
        }
    )
    addOptionSlider(
        p,
        "Auras per Row",
        nil,
        "PLAYER_AURA_WRAP_NUM",
        nil,
        1,
        20,
        nil,
        0
    )
    addOptionDropdown(
        p,
        L["PLAYER_AURA_GROW"],
        nil,
        "PlayerBuffFrame_GrowDirection",
        GW.UpdateHudScale(),
        {"UP", "DOWN", "UPR", "DOWNR"},
        {
            L["UP"],
            L["DOWN"],
            "Up and Right",
            "Down and Right"
        }
    )
    addOptionDropdown(
        p,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "PLAYER_UNIT_HEALTH",
        nil,
        {"NONE", "PREC", "VALUE", "BOTH"},
        {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH}
    )
    addOptionDropdown(
        p,
        L["PLAYER_ABSORB_VALUE_TEXT"],
        nil,
        "PLAYER_UNIT_ABSORB",
        nil,
        {"NONE", "PREC", "VALUE", "BOTH"},
        {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH}
    )

    InitPanel(p)
end
GW.LoadPlayerPanel = LoadPlayerPanel
