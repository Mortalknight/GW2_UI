local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local MapTable = GW.MapTable
local StrUpper = GW.StrUpper
local StrLower = GW.StrLower
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel

local function LoadRaidPanel(sWindow)
    local p = CreateFrame("Frame", "GwSettingsRaidPanel", sWindow.panels, "GwSettingsRaidPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(RAID)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the party and raid options to suit your needs."])

    createCat(RAID, L["Edit the group settings."], p, 4)

    addOption(p, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], "RAID_CLASS_COLOR", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], "RAID_POWER_BARS", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "RAID_SHOW_DEBUFFS", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], "RAID_ONLY_DISPELL_DEBUFFS", nil, nil, {["RAID_FRAMES"] = true, ["RAID_SHOW_DEBUFFS"] = true})
    addOption(p, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], "RAID_UNIT_MARKERS", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, L["Show Aura Tooltips in Combat"], L["Show tooltips of buffs and debuffs even when you are in combat."], "RAID_AURA_TOOLTIP_IN_COMBAT", nil, nil, {["RAID_FRAMES"] = true})
    addOptionDropdown(
        p,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "RAID_UNIT_HEALTH",
        nil,
        {"NONE", "PREC", "HEALTH", "LOSTHEALTH"},
        {
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH,
            COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH
        },
        nil,
        {["RAID_FRAMES"] = true}
    )

    local dirs, grow = {"DOWN", "UP", "RIGHT", "LEFT"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, dirs[i] .. "+" .. dirs[j])
        end
    end

    addOptionDropdown(
        p,
        L["Set Raid Growth Direction"],
        L["Set Raid Growth Direction"],
        "RAID_GROW",
        function()
            if GetSetting("RAID_FRAMES") == true then
                GW.UpdateRaidFramesAnchor()
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        grow,
        MapTable(
            grow,
            function(dir)
                local g1, g2 = strsplit("+", dir)
                return L["%s and then %s"]:format(L[StrLower(g1, 2)], L[StrLower(g2, 2)])
            end
        ),
        nil,
        {["RAID_FRAMES"] = true}
    )

    local pos = {"POSITION", "GROWTH"}
    for i, v in pairs({"TOP", "", "BOTTOM"}) do
        for j, h in pairs({"LEFT", "", "RIGHT"}) do
            tinsert(pos, (v .. h) == "" and "CENTER" or v .. h)
        end
    end

    addOptionDropdown(
        p,
        L["Set Raid Anchor"],
        L["Set where the raid frame container should be anchored.\n\nBy position: Always the same as the container's position on screen.\nBy growth: Always opposite to the growth direction."],
        "RAID_ANCHOR",
        function()
            if GetSetting("RAID_FRAMES") then
                GW.UpdateRaidFramesAnchor()
            end
        end,
        {"POSITION", "GROWTH", "TOP", "LEFT", "BOTTOM", "CENTER", "TOPLEFT", "BOTTOMLEFT", "BOTTOMRIGHT", "RIGHT", "TOPRIGHT"},
        {L["By position on screen"], L["By growth direction"], "TOP", "LEFT", "BOTTOM", "CENTER", "TOPLEFT", "BOTTOMLEFT", "BOTTOMRIGHT", "RIGHT", "TOPRIGHT"},
        nil,
        {["RAID_FRAMES"] = true},
        nil
    )

    addOptionSlider(
        p,
        L["Set Raid Units per Column"],
        L["Set the number of raid unit frames per column or row, depending on grow directions."],
        "RAID_UNITS_PER_COLUMN",
        function()
            if GetSetting("RAID_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        40,
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        p,
        L["Set Raid Unit Width"],
        L["Set the width of the raid units."],
        "RAID_WIDTH",
        function()
            if GetSetting("RAID_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        45,
        300,
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        p,
        L["Set Raid Unit Height"],
        L["Set the height of the raid units."],
        "RAID_HEIGHT",
        function()
            if GetSetting("RAID_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        15,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        p,
        L["Set Raid Frame Container Width"],
        L["Set the maximum width that the raid frames can be displayed.\n\nThis will cause unit frames to shrink or move to the next row."],
        "RAID_CONT_WIDTH",
        function()
            if GetSetting("RAID_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        GetScreenWidth(),
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        p,
        L["Set Raid Frame Container Height"],
        L["Set the maximum height that the raid frames can be displayed.\n\nThis will cause unit frames to shrink or move to the next column."],
        "RAID_CONT_HEIGHT",
        function()
            if GetSetting("RAID_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        GetScreenHeight(),
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    InitPanel(p)
end
GW.LoadRaidPanel = LoadRaidPanel
