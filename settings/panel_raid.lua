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

local function CreateProfileSwitcher(panel, profiles, panels)
    local valuePrev = "container"
    for key, value in pairs(profiles) do
        panel.selectProfile[value] = CreateFrame("Button", nil, panel.selectProfile.container, "GwDropDownItemTmpl")
        panel.selectProfile[value]:SetWidth(120)
        panel.selectProfile[value]:SetPoint("TOPRIGHT", panel.selectProfile[valuePrev], "BOTTOMRIGHT")
        panel.selectProfile[value].string:SetFont(UNIT_NAME_FONT, 12)
        panel.selectProfile[value].string:SetText(getglobal(value))
        panel.selectProfile[value].checkbutton:Hide()
        --panel.selectProfile[value].soundButton:Hide()
        panel.selectProfile[value].string:ClearAllPoints()
        panel.selectProfile[value].string:SetPoint("LEFT", 5, 0)
        panel.selectProfile[value].type = value
        panel.selectProfile[value].panel = panels[key]
        panel.selectProfile[value]:SetScript("OnClick", function(self)
            for _, p in pairs(panels) do
                p.selectProfile.string:SetText(self.string:GetText())
                p.selectProfile.container:Hide()
                p.selectProfile.active = self.panel
                p:Hide()
            end
            self.panel:Show()
        end)

        valuePrev = value
    end

    panel.selectProfile.active = panels[1]
    panel.selectProfile:SetScript("OnClick", function(self)
        if self.container:IsShown() then
            self.container:Hide()
        else
            self.container:Show()
        end
    end)
end

-- Profiles
local function LoadRaidProfile(sWindow)
    local p = CreateFrame("Frame", "GwSettingsRaidPanel", sWindow.panels, "GwSettingsRaidPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(RAID)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the party and raid options to suit your needs."])

    p.selectProfile.label:SetText(L["Profiles"])
    p.selectProfile.string:SetFont(UNIT_NAME_FONT, 12)
    p.selectProfile.string:SetText(RAID)
    p.selectProfile.container:SetParent(p)
    p.selectProfile.type = "RAID"

    p.buttonRaidPreview:SetScript("OnClick", function()
        GW.GridToggleFramesPreviewRaid(_, _, false, false)
    end)
    p.buttonRaidPreview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to toggle raid frame preview and cycle through different group sizes."], 1, 1, 1)
        GameTooltip:Show()
    end)
    p.buttonRaidPreview:SetScript("OnLeave", GameTooltip_Hide)

    addOption(p, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], "RAID_CLASS_COLOR", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], "RAID_POWER_BARS", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "RAID_SHOW_DEBUFFS", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], "RAID_ONLY_DISPELL_DEBUFFS", nil, nil, {["RAID_FRAMES"] = true, ["RAID_SHOW_DEBUFFS"] = true})
    addOption(p, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], "RAID_UNIT_MARKERS", nil, nil, {["RAID_FRAMES"] = true})
    addOptionDropdown(
        p,
        L["Show Aura Tooltips"],
        L["Show tooltips of buffs and debuffs."],
        "RAID_AURA_TOOLTIP_INCOMBAT",
        function()
            if "RAID" == "PARTY" then
                for i = 1, 5 do
                    if _G["GwCompactPartyFrame" .. i] then
                        GW.GridOnEvent(_G["GwCompactPartyFrame" .. i], "UNIT_AURA")
                    end
                end
            else
                for i = 1, MAX_RAID_MEMBERS do
                    if _G["GwCompactRaidFrame" .. i] then
                        GW.GridOnEvent(_G["GwCompactRaidFrame" .. i], "UNIT_AURA")
                    end
                end
            end
        end,
        {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"},
        {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]},
        nil,
        {["RAID_FRAMES"] = true}
    )
    addOptionDropdown(
        p,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "RAID_UNIT_HEALTH",
        function()
            if "RAID" == "PARTY" then
                for i = 1, 5 do
                    if _G["GwCompactPartyFrame" .. i] then
                        GW.GridOnEvent(_G["GwCompactPartyFrame" .. i], "load")
                    end
                end
            else
                for i = 1, MAX_RAID_MEMBERS do
                    if _G["GwCompactRaidFrame" .. i] then
                        GW.GridOnEvent(_G["GwCompactRaidFrame" .. i], "load")
                    end
                end
            end
        end,
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
            GW.GridContainerUpdateAnchor("RAID")
            GW.GridUpdateFramesPosition("RAID")
            GW.GridUpdateFramesLayout("RAID")
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

    addOptionDropdown(
        p,
        L["Set Raid Anchor"],
        L["Set where the raid frame container should be anchored.\n\nBy position: Always the same as the container's position on screen.\nBy growth: Always opposite to the growth direction."],
        "RAID_ANCHOR",
        function()
            if GetSetting("RAID_FRAMES") then
                GW.GridContainerUpdateAnchor("RAID")
            end
        end,
        {"POSITION", "GROWTH", "TOP", "LEFT", "BOTTOM", "CENTER", "TOPLEFT", "BOTTOMLEFT", "BOTTOMRIGHT", "RIGHT", "TOPRIGHT"},
        {L["By position on screen"], L["By growth direction"], "TOP", "LEFT", "BOTTOM", "CENTER", "TOPLEFT", "BOTTOMLEFT", "BOTTOMRIGHT", "RIGHT", "TOPRIGHT"},
        nil,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        p,
        L["Set Raid Units per Column"],
        L["Set the number of raid unit frames per column or row, depending on grow directions."],
        "RAID_UNITS_PER_COLUMN",
        function()
            GW.GridUpdateFramesPosition("RAID")
            GW.GridUpdateFramesLayout("RAID")
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
            GW.GridUpdateFramesPosition("RAID")
            GW.GridUpdateFramesLayout("RAID")
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
            GW.GridUpdateFramesPosition("RAID")
            GW.GridUpdateFramesLayout("RAID")
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
            GW.GridUpdateFramesPosition("RAID")
            GW.GridUpdateFramesLayout("RAID")
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
            GW.GridUpdateFramesPosition("RAID")
            GW.GridUpdateFramesLayout("RAID")
        end,
        0,
        GetScreenHeight(),
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    return p
end

local function LoadPartyProfile(sWindow)
    local p = CreateFrame("Frame", "GwSettingsRaidPartyPanel", sWindow.panels, "GwSettingsRaidPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(RAID)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the party and raid options to suit your needs."])

    p.selectProfile.label:SetText(L["Profiles"])
    p.selectProfile.string:SetFont(UNIT_NAME_FONT, 12)
    p.selectProfile.string:SetText(RAID)
    p.selectProfile.container:SetParent(p)
    p.selectProfile.type = "PARTY"

    p.buttonRaidPreview:SetScript("OnClick", function()
        GW.GridToggleFramesPreviewParty(_, _, false, false)
    end)
    p.buttonRaidPreview:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 28, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Preview Raid Frames"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to toggle raid frame preview and cycle through different group sizes."], 1, 1, 1)
        GameTooltip:Show()
    end)
    p.buttonRaidPreview:SetScript("OnLeave", GameTooltip_Hide)

    addOption(p, RAID_USE_CLASS_COLORS, L["Use the class color instead of class icons."], "RAID_CLASS_COLOR_PARTY", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, DISPLAY_POWER_BARS, L["Display the power bars on the raid units."], "RAID_POWER_BARS_PARTY", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, SHOW_DEBUFFS, OPTION_TOOLTIP_SHOW_ALL_ENEMY_DEBUFFS, "RAID_SHOW_DEBUFFS_PARTY", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, L["Only displays the debuffs that you are able to dispell."], "RAID_ONLY_DISPELL_DEBUFFS_PARTY", nil, nil, {["RAID_FRAMES"] = true, ["RAID_SHOW_DEBUFFS"] = true})
    addOption(p, L["Dungeon & Raid Debuffs"], L["Show important Dungeon & Raid debuffs"], "RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PARTY", nil, nil, {["RAID_FRAMES"] = true})
    addOption(p, RAID_TARGET_ICON, L["Displays the Target Markers on the Raid Unit Frames"], "RAID_UNIT_MARKERS_PARTY", nil, nil, {["RAID_FRAMES"] = true})
    addOptionDropdown(
        p,
        L["Show Aura Tooltips"],
        L["Show tooltips of buffs and debuffs."],
        "RAID_AURA_TOOLTIP_INCOMBAT_PARTY",
        function()
            if "PARTY" == "PARTY" then
                for i = 1, 5 do
                    if _G["GwCompactPartyFrame" .. i] then
                        GW.GridOnEvent(_G["GwCompactPartyFrame" .. i], "UNIT_AURA")
                    end
                end
            else
                for i = 1, MAX_RAID_MEMBERS do
                    if _G["GwCompactRaidFrame" .. i] then
                        GW.GridOnEvent(_G["GwCompactRaidFrame" .. i], "UNIT_AURA")
                    end
                end
            end
        end,
        {"ALWAYS", "NEVER", "IN_COMBAT", "OUT_COMBAT"},
        {ALWAYS, NEVER, GARRISON_LANDING_STATUS_MISSION_COMBAT, L["Out of combat"]},
        nil,
        {["RAID_FRAMES"] = true}
    )

    addOptionDropdown(
        p,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "RAID_UNIT_HEALTH_PARTY",
        function()
            if "PARTY" == "PARTY" then
                for i = 1, 5 do
                    if _G["GwCompactPartyFrame" .. i] then
                        GW.GridOnEvent(_G["GwCompactPartyFrame" .. i], "load")
                    end
                end
            else
                for i = 1, MAX_RAID_MEMBERS do
                    if _G["GwCompactRaidFrame" .. i] then
                        GW.GridOnEvent(_G["GwCompactRaidFrame" .. i], "load")
                    end
                end
            end
        end,
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
        "RAID_GROW_PARTY",
        function()
            GW.GridContainerUpdateAnchor("PARTY")
            GW.GridUpdateFramesPosition("PARTY")
            GW.GridUpdateFramesLayout("PARTY")
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

    addOptionDropdown(
        p,
        L["Set Raid Anchor"],
        L["Set where the raid frame container should be anchored.\n\nBy position: Always the same as the container's position on screen.\nBy growth: Always opposite to the growth direction."],
        "RAID_ANCHOR_PARTY",
        function()
            if GetSetting("RAID_FRAMES") then
                GW.GridContainerUpdateAnchor("PARTY")
            end
        end,
        {"POSITION", "GROWTH", "TOP", "LEFT", "BOTTOM", "CENTER", "TOPLEFT", "BOTTOMLEFT", "BOTTOMRIGHT", "RIGHT", "TOPRIGHT"},
        {L["By position on screen"], L["By growth direction"], "TOP", "LEFT", "BOTTOM", "CENTER", "TOPLEFT", "BOTTOMLEFT", "BOTTOMRIGHT", "RIGHT", "TOPRIGHT"},
        nil,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        p,
        L["Set Raid Units per Column"],
        L["Set the number of raid unit frames per column or row, depending on grow directions."],
        "RAID_UNITS_PER_COLUMN_PARTY",
        function()
            GW.GridUpdateFramesPosition("PARTY")
            GW.GridUpdateFramesLayout("PARTY")
        end,
        0,
        5,
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    addOptionSlider(
        p,
        L["Set Raid Unit Width"],
        L["Set the width of the raid units."],
        "RAID_WIDTH_PARTY",
        function()
            GW.GridUpdateFramesPosition("PARTY")
            GW.GridUpdateFramesLayout("PARTY")
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
        "RAID_HEIGHT_PARTY",
        function()
            GW.GridUpdateFramesPosition("PARTY")
            GW.GridUpdateFramesLayout("PARTY")
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
        "RAID_CONT_WIDTH_PARTY",
        function()
            GW.GridUpdateFramesPosition("PARTY")
            GW.GridUpdateFramesLayout("PARTY")
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
        "RAID_CONT_HEIGHT_PARTY",
        function()
            GW.GridUpdateFramesPosition("PARTY")
            GW.GridUpdateFramesLayout("PARTY")
        end,
        0,
        GetScreenHeight(),
        nil,
        0,
        {["RAID_FRAMES"] = true}
    )

    return p
end

local function LoadRaidPanel(sWindow)
    local profileNames = {"RAID", "PARTY"}
    local profilePanles = {LoadRaidProfile(sWindow), LoadPartyProfile(sWindow)}

    createCat(RAID, L["Edit the group settings."], profilePanles[1], 8, nil, nil, nil, profilePanles)

    CreateProfileSwitcher(profilePanles[1], profileNames, profilePanles)
    CreateProfileSwitcher(profilePanles[2], profileNames, profilePanles)

    InitPanel(profilePanles[1], false)
    InitPanel(profilePanles[2], false)

    profilePanles[2]:Hide()
end
GW.LoadRaidPanel = LoadRaidPanel
