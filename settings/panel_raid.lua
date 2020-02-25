local _, GW = ...
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local MapTable = GW.MapTable
local StrUpper = GW.StrUpper
local GetSetting = GW.GetSetting

local function LoadRaidPanel(sWindow)
    local pnl_group2 = CreateFrame("Frame", "GwSettingsGroupframe2", sWindow.panels, "GwSettingsRaidPanelTmpl")
    pnl_group2.header:SetFont(DAMAGE_TEXT_FONT, 20)
    pnl_group2.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    pnl_group2.header:SetText(CHAT_MSG_PARTY)
    pnl_group2.sub:SetFont(UNIT_NAME_FONT, 12)
    pnl_group2.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    pnl_group2.sub:SetText(GwLocalization["GROUP_DESC"])

    createCat(CHAT_MSG_PARTY, GwLocalization["GROUP_TOOLTIP"], "GwSettingsGroupframe2", 4)

    local dirs, grow = {"DOWN", "UP", "RIGHT", "LEFT"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, dirs[i] .. "+" .. dirs[j])
        end
    end

        addOptionDropdown(
        GwLocalization["RAID_GROW"],
        GwLocalization["RAID_GROW"],
        "RAID_GROW",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesAnchor()
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        grow,
        MapTable(grow, function (dir)
            local g1, g2 = strsplit("+", dir)
            return StrUpper(GwLocalization["RAID_GROW_DIR"]:format(GwLocalization[g1], GwLocalization[g2]), 1, 1)
        end)
    )

    local pos = {"POSITION", "GROWTH"}
    for i,v in pairs({"TOP", "", "BOTTOM"}) do
        for j,h in pairs({"LEFT", "", "RIGHT"}) do
            tinsert(pos, (v .. h) == "" and "CENTER" or v .. h)
        end
    end

    addOptionDropdown(
        GwLocalization["RAID_ANCHOR"],
        GwLocalization["RAID_ANCHOR_DESC"],
        "RAID_ANCHOR",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesAnchor()
            end
        end,
        pos,
        MapTable(pos, function (pos, i)
            return StrUpper(GwLocalization[i <= 2 and "RAID_ANCHOR_BY_" .. pos or pos], 1, 1)
        end, true)
    )

    addOptionSlider(
        GwLocalization["RAID_UNITS_PER_COLUMN"],
        GwLocalization["RAID_UNITS_PER_COLUMN_DESC"],
        "RAID_UNITS_PER_COLUMN",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        40
    )

    addOptionSlider(
        GwLocalization["RAID_BAR_WIDTH"],
        GwLocalization["RAID_BAR_WIDTH_DESC"],
        "RAID_WIDTH",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        45,
        300
    )

    addOptionSlider(
        GwLocalization["RAID_BAR_HEIGHT"],
        GwLocalization["RAID_BAR_HEIGHT_DESC"],
        "RAID_HEIGHT",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        15,
        100
    )

    addOptionSlider(
        GwLocalization["RAID_CONT_WIDTH"],
        GwLocalization["RAID_CONT_WIDTH_DESC"],
        "RAID_CONT_WIDTH",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        GetScreenWidth()
    )

    addOptionSlider(
        GwLocalization["RAID_CONT_HEIGHT"],
        GwLocalization["RAID_CONT_HEIGHT_DESC"],
        "RAID_CONT_HEIGHT",
        "GwSettingsGroupframe2",
        function()
            if GetSetting("GROUP_FRAMES") == true then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        GetScreenHeight()
    )

end
GW.LoadRaidPanel = LoadRaidPanel
