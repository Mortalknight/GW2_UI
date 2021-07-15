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
local RoundDec = GW.RoundDec

local function switchProfile(profile)
    local settingProfils = GW.settingProfils

    if profile == "RAID" then
        for _, tbl in pairs(settingProfils.GROUPS) do
            _G[tbl.buttonName].optionName = tbl.optionName
            if tbl.optionType == "boolean" then
                _G[tbl.buttonName].checkbutton:SetChecked(GetSetting(tbl.optionName, tbl.perSpec))
            elseif tbl.optionType == "slider" then
                _G[tbl.buttonName].slider:SetValue(GetSetting(tbl.optionName, tbl.perSpec))
                _G[tbl.buttonName].input:SetNumber(RoundDec(GetSetting(tbl.optionName), tbl.decimalNumbers))
            elseif tbl.optionType == "dropdown" then
                for key, val in pairs(_G[tbl.buttonName].options) do
                    if GetSetting(tbl.optionName, tbl.perSpec) == val then
                        _G[tbl.buttonName].button.string:SetText(_G[tbl.buttonName].options_names[key])
                        break
                    end
                end
            end
        end
    elseif profile == "PARTY" then
        for _, tbl in pairs(settingProfils.GROUPS) do
            _G[tbl.buttonName].optionName = tbl.optionName .. "_PARTY"
            if tbl.optionType == "boolean" then
                _G[tbl.buttonName].checkbutton:SetChecked(GetSetting(tbl.optionName .. "_PARTY", tbl.perSpec))
            elseif tbl.optionType == "slider" then
                _G[tbl.buttonName].slider:SetValue(GetSetting(tbl.optionName .. "_PARTY", tbl.perSpec))
                _G[tbl.buttonName].input:SetNumber(RoundDec(GetSetting(tbl.optionName .. "_PARTY"), tbl.decimalNumbers))
            elseif tbl.optionType == "dropdown" then
                for key, val in pairs(_G[tbl.buttonName].options) do
                    if GetSetting(tbl.optionName  .. "_PARTY", tbl.perSpec) == val then
                        _G[tbl.buttonName].button.string:SetText(_G[tbl.buttonName].options_names[key])
                        break
                    end
                end
            end
        end
    end
end

local function CreateRaidProfiles(panel)
    panel.selectProfile.string:SetFont(UNIT_NAME_FONT, 12)
    panel.selectProfile.string:SetText(RAID)
    panel.selectProfile.container:SetParent(panel)
    panel.selectProfile.type = "RAID"

    panel.selectProfile.raid = CreateFrame("Button", "b", panel.selectProfile.container, "GwDropDownItemTmpl")
    panel.selectProfile.raid:SetWidth(120)
    panel.selectProfile.raid:SetPoint("TOPRIGHT", panel.selectProfile.container, "BOTTOMRIGHT")
    panel.selectProfile.raid.string:SetFont(UNIT_NAME_FONT, 12)
    panel.selectProfile.raid.string:SetText(RAID)
    panel.selectProfile.raid.checkbutton:Hide()
    panel.selectProfile.raid.string:ClearAllPoints()
    panel.selectProfile.raid.string:SetPoint("LEFT", 5, 0)
    panel.selectProfile.raid.type = "RAID"
    panel.selectProfile.raid:SetScript("OnClick", function(self)
        panel.selectProfile.type = self.type
        GW.GROUPD_TYPE = self.type

        panel.selectProfile.string:SetText(self.string:GetText())
        if panel.selectProfile.container:IsShown() then
            panel.selectProfile.container:Hide()
        else
            panel.selectProfile.container:Show()
        end

        switchProfile(panel.selectProfile.type)
    end)

    panel.selectProfile.party = CreateFrame("Button", "ff", panel.selectProfile.container, "GwDropDownItemTmpl")
    panel.selectProfile.party:SetWidth(120)
    panel.selectProfile.party:SetPoint("TOPRIGHT", panel.selectProfile.raid, "BOTTOMRIGHT")
    panel.selectProfile.party.string:SetFont(UNIT_NAME_FONT, 12)
    panel.selectProfile.party.string:SetText(PARTY)
    panel.selectProfile.party.checkbutton:Hide()
    panel.selectProfile.party.string:ClearAllPoints()
    panel.selectProfile.party.string:SetPoint("LEFT", 5, 0)
    panel.selectProfile.party.type = "PARTY"
    panel.selectProfile.party:SetScript("OnClick", function(self)
        panel.selectProfile.type = self.type
        GW.GROUPD_TYPE = self.type

        panel.selectProfile.string:SetText(self.string:GetText())
        if panel.selectProfile.container:IsShown() then
            panel.selectProfile.container:Hide()
        else
            panel.selectProfile.container:Show()
        end

        switchProfile(panel.selectProfile.type)
    end)

    panel.selectProfile:SetScript("OnClick", function(self)
        if self.container:IsShown() then
            self.container:Hide()
        else
            self.container:Show()
        end

        switchProfile(panel.selectProfile.type)
    end)

end

local function LoadRaidPanel(sWindow)
    local p = CreateFrame("Frame", "GwSettingsRaidPanel", sWindow.panels, "GwSettingsRaidPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(RAID)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the party and raid options to suit your needs."])

    -- profile default
    CreateRaidProfiles(p)

    createCat(RAID, L["Edit the group settings."], p, 8)

    addOption(p, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], "RAID_CLASS_COLOR", nil, nil, {["RAID_FRAMES"] = true}, nil, nil, {"RAID", "PARTY"})
    addOption(p,
        DISPLAY_POWER_BARS,
        L["Display the power bars on the raid units."],
        "RAID_POWER_BARS",
        function(_, SettingName)
            local frame = _G["GwCompactplayer"]
            local settingValue = GetSetting(SettingName)

            if settingValue then
                frame.predictionbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 5)
                frame.manabar:Show()
            else
                frame.predictionbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
                frame.manabar:Hide()
            end
            for i = 1, 4 do
                frame = _G["GwCompactparty" .. i]
                if settingValue then
                    frame.predictionbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 5)
                    frame.manabar:Show()
                else
                    frame.predictionbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
                    frame.manabar:Hide()
                end
            end

            for i = 1, MAX_RAID_MEMBERS do
                frame = _G["GwCompactraid" .. i]
                if settingValue then
                    frame.predictionbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 5)
                    frame.manabar:Show()
                else
                    frame.predictionbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
                    frame.manabar:Hide()
                end
            end
        end,
        nil,
        {["RAID_FRAMES"] = true},
        nil,
        nil,
        {"RAID", "PARTY"}
    )
    addOption(p, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "RAID_SHOW_DEBUFFS", nil, nil, {["RAID_FRAMES"] = true}, nil, nil, {"RAID", "PARTY"})
    addOption(p, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], "RAID_ONLY_DISPELL_DEBUFFS", nil, nil, {["RAID_FRAMES"] = true, ["RAID_SHOW_DEBUFFS"] = true}, nil, nil, {"RAID", "PARTY"})
    addOption(p, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF", nil, nil, {["RAID_FRAMES"] = true}, nil, nil, {"RAID", "PARTY"})
    addOption(p, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], "RAID_UNIT_MARKERS", nil, nil, {["RAID_FRAMES"] = true}, nil, nil, {"RAID", "PARTY"})
    addOption(
        p,
        L["Sort Raid Frames by Role"],
        L["Sort raid unit frames by role (tank, heal, damage) instead of group."],
        "RAID_SORT_BY_ROLE",
        function()
            if GetSetting("RAID_FRAMES") then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        nil,
        {["RAID_FRAMES"] = true},
        nil,
        nil,
        {"RAID", "PARTY"}
    )
    addOptionDropdown(
        p,
        L["Show Aura Tooltips"],
        L["Show tooltips of buffs and debuffs."],
        "RAID_AURA_TOOLTIP_INCOMBAT",
        nil,
        {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"},
        {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]},
        nil,
        {["RAID_FRAMES"] = true},
        nil,
        nil,
        nil,
        {"RAID", "PARTY"}
    )

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
        {["RAID_FRAMES"] = true},
        nil,
        nil,
        nil,
        {"RAID", "PARTY"}
    )

    addOptionDropdown(
        p,
        L["Show Country Flag"],
        L["Display a country flag based on the unit's language"],
        "RAID_UNIT_FLAGS",
        nil,
        {"NONE", "DIFFERENT", "ALL"},
        {NONE_KEY, L["Different Than Own"], ALL},
        nil,
        {["RAID_FRAMES"] = true},
        nil,
        nil,
        nil,
        {"RAID", "PARTY"}
    )

    local dirs, grow = {"Down", "Up", "Right", "Left"}, {}
    for i in pairs(dirs) do
        local k = i <= 2 and 3 or 1
        for j = k, k + 1 do
            tinsert(grow, StrUpper(dirs[i] .. "+" .. dirs[j]))
        end
    end

    addOptionDropdown(
        p,
        L["Set Raid Growth Direction"],
        L["Set the grow direction for raid frames."],
        "RAID_GROW",
        function()
            if GetSetting("RAID_FRAMES") then
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
        {["RAID_FRAMES"] = true},
        nil,
        nil,
        nil,
        {"RAID", "PARTY"}
    )

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
        nil,
        nil,
        nil,
        {"RAID", "PARTY"}
    )

    addOptionSlider(
        p,
        L["Set Raid Units per Column"],
        L["Set the number of raid unit frames per column or row, depending on grow directions."],
        "RAID_UNITS_PER_COLUMN",
        function()
            if GetSetting("RAID_FRAMES") then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        40,
        nil,
        0,
        {["RAID_FRAMES"] = true},
        nil,
        nil,
        {"RAID", "PARTY"}
    )

    addOptionSlider(
        p,
        L["Set Raid Unit Width"],
        L["Set the width of the raid units."],
        "RAID_WIDTH",
        function()
            if GetSetting("RAID_FRAMES") then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        45,
        300,
        nil,
        0,
        {["RAID_FRAMES"] = true},
        nil,
        nil,
        {"RAID", "PARTY"}
    )

    addOptionSlider(
        p,
        L["Set Raid Unit Height"],
        L["Set the height of the raid units."],
        "RAID_HEIGHT",
        function()
            if GetSetting("RAID_FRAMES") then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        15,
        100,
        nil,
        0,
        {["RAID_FRAMES"] = true},
        nil,
        nil,
        {"RAID", "PARTY"}
    )

    addOptionSlider(
        p,
        L["Set Raid Frame Container Width"],
        L["Set the maximum width that the raid frames can be displayed.\n\nThis will cause unit frames to shrink or move to the next row."],
        "RAID_CONT_WIDTH",
        function()
            if GetSetting("RAID_FRAMES")  then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        GetScreenWidth(),
        nil,
        0,
        {["RAID_FRAMES"] = true},
        nil,
        nil,
        {"RAID", "PARTY"}
    )

    addOptionSlider(
        p,
        L["Set Raid Frame Container Height"],
        L["Set the maximum height that the raid frames can be displayed.\n\nThis will cause unit frames to shrink or move to the next column."],
        "RAID_CONT_HEIGHT",
        function()
            if GetSetting("RAID_FRAMES") then
                GW.UpdateRaidFramesLayout()
                GW.UpdateRaidFramesPosition()
            end
        end,
        0,
        GetScreenHeight(),
        nil,
        0,
        {["RAID_FRAMES"] = true},
        nil,
        nil,
        {"RAID", "PARTY"}
    )

    InitPanel(p, false, "GROUPS")
end
GW.LoadRaidPanel = LoadRaidPanel
