local _, GW = ...
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat

local function LoadPlayerPanel(sWindow)
    local pnl_player = CreateFrame("Frame", "GwSettingsPlayerOption", sWindow.panels, "GwSettingsPanelTmpl")
    pnl_player.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pnl_player.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    pnl_player.header:SetText(PLAYER)
    pnl_player.sub:SetFont(UNIT_NAME_FONT, 12)
    pnl_player.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pnl_player.sub:SetText(GwLocalization["PLAYER_DESC"])

    createCat(PLAYER, GwLocalization["PLAYER_DESC"], "GwSettingsPlayerOption", 7)

    addOptionDropdown(
        GwLocalization["PLAYER_AURA_GROW"],
        nil,
        "PlayerBuffFrame_GrowDirection",
        "GwSettingsPlayerOption",
        function()
            GW.UpdateHudScale()
        end,
        {"UP", "DOWN"},
        {
            GwLocalization["UP"],
            GwLocalization["DOWN"]
        }
    )
    addOptionDropdown(
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "PLAYER_UNIT_HEALTH",
        "GwSettingsPlayerOption",
        function()
        end,
        {"NONE", "PREC", "VALUE", "BOTH"},
        {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH}
    )
    addOptionDropdown(
        GwLocalization["PLAYER_ABSORB_VALUE_TEXT"],
        nil,
        "PLAYER_UNIT_ABSORB",
        "GwSettingsPlayerOption",
        function()
        end,
        {"NONE", "PREC", "VALUE", "BOTH"},
        {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH}
    )
end
GW.LoadPlayerPanel = LoadPlayerPanel
