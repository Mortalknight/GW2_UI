local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local MapTable = GW.MapTable
local StrUpper = GW.StrUpper
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling

local function LoadRaidPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsRaidPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(RAID)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["GROUP_DESC"])

    createCat(RAID, L["GROUP_TOOLTIP"], p, 4)

    addOption(p, RAID_USE_CLASS_COLORS, L["CLASS_COLOR_RAID_DESC"], "RAID_CLASS_COLOR", nil, nil, {["GROUP_FRAMES"] = true})
    addOption(p, DISPLAY_POWER_BARS, L["POWER_BARS_RAID_DESC"], "RAID_POWER_BARS", nil, nil, {["GROUP_FRAMES"] = true})
    addOption(p, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["DEBUFF_DISPELL_DESC"], "RAID_ONLY_DISPELL_DEBUFFS", nil, nil, {["GROUP_FRAMES"] = true})
    addOption(p, RAID_TARGET_ICON, L["RAID_MARKER_DESC"], "RAID_UNIT_MARKERS", nil, nil, {["GROUP_FRAMES"] = true})
    addOption(
        p,
        L["RAID_SORT_BY_ROLE"],
        L["RAID_SORT_BY_ROLE_DESC"],
        "RAID_SORT_BY_ROLE",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        nil,
        {["GROUP_FRAMES"] = true}
    )
    addOption(p, L["RAID_AURA_TOOLTIP_IN_COMBAT"], L["RAID_AURA_TOOLTIP_IN_COMBAT_DESC"], "RAID_AURA_TOOLTIP_IN_COMBAT", nil, nil, {["GROUP_FRAMES"] = true})

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
        {["GROUP_FRAMES"] = true}
    )

    addOptionDropdown(
        p,
        L["RAID_UNIT_FLAGS"],
        L["RAID_UNIT_FLAGS_TOOLTIP"],
        "RAID_UNIT_FLAGS",
        nil,
        {"NONE", "DIFFERENT", "ALL"},
        {NONE_KEY, L["RAID_UNIT_FLAGS_2"], ALL},
        nil,
        {["GROUP_FRAMES"] = true}
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
        L["RAID_GROW"],
        L["RAID_GROW"],
        "RAID_GROW",
        function()
            if GetSetting("GROUP_FRAMES") == true then
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
                return StrUpper(L["RAID_GROW_DIR"]:format(L[g1], L[g2]), 1, 1)
            end
        ),
        nil,
        {["GROUP_FRAMES"] = true}
    )

    local pos = {"POSITION", "GROWTH"}
    for i, v in pairs({"TOP", "", "BOTTOM"}) do
        for j, h in pairs({"LEFT", "", "RIGHT"}) do
            tinsert(pos, (v .. h) == "" and "CENTER" or v .. h)
        end
    end

    addOptionDropdown(
        p,
        L["RAID_ANCHOR"],
        L["RAID_ANCHOR_DESC"],
        "RAID_ANCHOR",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesAnchor()
            end
        end,
        pos,
        MapTable(
            pos,
            function(posi, i)
                return StrUpper(L[i <= 2 and "RAID_ANCHOR_BY_" .. posi or posi], 1, 1)
            end,
            true
        ),
        nil,
        {["GROUP_FRAMES"] = true}
    )

    addOptionSlider(
        p,
        L["RAID_UNITS_PER_COLUMN"],
        L["RAID_UNITS_PER_COLUMN_DESC"],
        "RAID_UNITS_PER_COLUMN",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        40,
        nil,
        0,
        {["GROUP_FRAMES"] = true}
    )

    addOptionSlider(
        p,
        L["RAID_BAR_WIDTH"],
        L["RAID_BAR_WIDTH_DESC"],
        "RAID_WIDTH",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        45,
        300,
        nil,
        0,
        {["GROUP_FRAMES"] = true}
    )

    addOptionSlider(
        p,
        L["RAID_BAR_HEIGHT"],
        L["RAID_BAR_HEIGHT_DESC"],
        "RAID_HEIGHT",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        15,
        100,
        nil,
        0,
        {["GROUP_FRAMES"] = true}
    )

    addOptionSlider(
        p,
        L["RAID_CONT_WIDTH"],
        L["RAID_CONT_WIDTH_DESC"],
        "RAID_CONT_WIDTH",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        GetScreenWidth(),
        nil,
        0,
        {["GROUP_FRAMES"] = true}
    )

    addOptionSlider(
        p,
        L["RAID_CONT_HEIGHT"],
        L["RAID_CONT_HEIGHT_DESC"],
        "RAID_CONT_HEIGHT",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        GetScreenHeight(),
        nil,
        0,
        {["GROUP_FRAMES"] = true}
    )

    InitPanel(p)
end
GW.LoadRaidPanel = LoadRaidPanel
