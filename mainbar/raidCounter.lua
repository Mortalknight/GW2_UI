local _, GW = ...

local function UpdateRaidCounterVisibility()
    local VisibilityStates = {
        ["NEVER"] = "hide",
        ["ALWAYS"] = "[petbattle] hide; show",
        ["IN_GROUP"] = "[petbattle] hide; [group:raid] hide; [group:party] show; hide",
        ["IN_RAID"] = "[petbattle] hide; [group:raid] show; [group:party] hide; hide",
        ["IN_RAID_IN_PARTY"] = "[petbattle] hide; [group] show; hide",
    }

    RegisterStateDriver(GW_RaidCounter_Frame, "visibility", VisibilityStates[GW.settings.ROLE_BAR])
    GW_RaidCounter_Frame:GetScript("OnEvent")(GW_RaidCounter_Frame)
end
GW.UpdateRaidCounterVisibility = UpdateRaidCounterVisibility

local function Create_Raid_Counter()
    local raidCounterFrame = CreateFrame("Button", "GW_RaidCounter_Frame", UIParent, "SecureHandlerClickTemplate")

    if GwSocialWindow then
        raidCounterFrame:SetFrameRef("GwSocialWindow", GwSocialWindow)
    end
    raidCounterFrame:SetAttribute("ourWindow", GW.settings.USE_SOCIAL_WINDOW)
    raidCounterFrame:SetAttribute("ourWindow", false)
    raidCounterFrame.func = function() ToggleRaidFrame() end
    raidCounterFrame:SetAttribute(
        "_onclick",
        [=[
            if self:GetAttribute("ourWindow") then
                local f = self:GetFrameRef("GwSocialWindow")
                f:SetAttribute("keytoggle", true)
                f:SetAttribute("windowpanelopen", "raidlist")
            else
                self:CallMethod("func")
            end
        ]=]
    )
    raidCounterFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

    raidCounterFrame:SetSize(100, 25)

    raidCounterFrame.tank = raidCounterFrame:CreateFontString(nil, "ARTWORK")
    raidCounterFrame.tank:SetFont(UNIT_NAME_FONT, 12)
    raidCounterFrame.tank:SetPoint("LEFT", raidCounterFrame, "LEFT", 5, 0)
    raidCounterFrame.tank:SetTextColor(1, 1, 1)

    raidCounterFrame.heal = raidCounterFrame:CreateFontString(nil, "ARTWORK")
    raidCounterFrame.heal:SetFont(UNIT_NAME_FONT, 12)
    raidCounterFrame.heal:SetPoint("CENTER", raidCounterFrame, "CENTER", 0, 0)
    raidCounterFrame.heal:SetTextColor(1, 1, 1)

    raidCounterFrame.damager = raidCounterFrame:CreateFontString(nil, "ARTWORK")
    raidCounterFrame.damager:SetFont(UNIT_NAME_FONT, 12)
    raidCounterFrame.damager:SetPoint("RIGHT", raidCounterFrame, "RIGHT", -5, 0)
    raidCounterFrame.damager:SetTextColor(1, 1, 1)

    raidCounterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    raidCounterFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    raidCounterFrame:SetScript("OnEvent", function(self)
        if not self:IsShown() then return end

        local unit = (IsInRaid() and "raid" or "party")
        local tank, damage, heal = 0, 0, 0
        for i = 1, GetNumGroupMembers() do
            local role = UnitGroupRolesAssigned(unit .. i)

            if role then
                if role == "TANK" then
                    tank = tank + 1
                elseif role == "HEALER" then
                    heal = heal + 1
                elseif role == "DAMAGER" then
                    damage = damage + 1
                end
            end
        end

        if GetNumGroupMembers() == 0 or unit == "party" then
            local plyerRole = UnitGroupRolesAssigned("player")
            if plyerRole then
                if GW.myrole == "TANK" then
                    tank = tank + 1
                elseif GW.myrole == "HEALER" then
                    heal = heal + 1
                elseif GW.myrole == "DAMAGER" then
                    damage = damage + 1
                end
            end
        end

        raidCounterFrame.tank:SetText("|TInterface/AddOns/GW2_UI/textures/party/roleicon-tank:0:0:0:2:64:64:4:60:4:60|t " .. tank)
        raidCounterFrame.heal:SetText("|TInterface/AddOns/GW2_UI/textures/party/roleicon-healer:0:0:0:1:64:64:4:60:4:60|t " .. heal)
        raidCounterFrame.damager:SetText("|TInterface/AddOns/GW2_UI/textures/party/roleicon-dps:15:15:0:0:64:64:4:60:4:60|t" .. damage)
    end)

    GW.RegisterMovableFrame(raidCounterFrame, GW.L["Role Bar"], "ROLE_BAR_pos", ALL .. ",Group,Raid", nil, {"default", "scaleable"})
    raidCounterFrame:ClearAllPoints()
    raidCounterFrame:SetPoint("TOPLEFT", raidCounterFrame.gwMover)

    UpdateRaidCounterVisibility()
end
GW.Create_Raid_Counter = Create_Raid_Counter