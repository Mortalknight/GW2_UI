local _, GW = ...
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local createCat = GW.CreateCat
local MapTable = GW.MapTable
local StrUpper = GW.StrUpper
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel
local AddForProfiling = GW.AddForProfiling
local L = GwLocalization

local function LoadRaidPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsRaidPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(CHAT_MSG_PARTY)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["GROUP_DESC"])

    createCat(CHAT_MSG_PARTY, L["GROUP_TOOLTIP"], p, 4)

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
        )
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
        )
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
        40
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
        300
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
        100
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
        GetScreenWidth()
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
        GetScreenHeight()
    )

    InitPanel(p)
end
GW.LoadRaidPanel = LoadRaidPanel
