---@class GW2
local GW = select(2, ...)

local function UpdateRaidCounterVisibility()
    local VisibilityStates = {
        ["NEVER"] = "hide",
        ["ALWAYS"] = "[petbattle] hide; show",
        ["IN_GROUP"] = "[petbattle] hide; [group:raid] hide; [group:party] show; hide",
        ["IN_RAID"] = "[petbattle] hide; [group:raid] show; [group:party] hide; hide",
        ["IN_RAID_IN_PARTY"] = "[petbattle] hide; [group] show; hide",
    }

    RegisterStateDriver(GW_RaidCounter_Frame, "visibility", VisibilityStates[GW.settings.roleBar.mode])
    GW_RaidCounter_Frame:GetScript("OnEvent")(GW_RaidCounter_Frame)
end
GW.UpdateRaidCounterVisibility = UpdateRaidCounterVisibility

local function GetRaidTabName()
    for i = 1, FRIEND_TAB_COUNT or 4 do
        local tab = _G["FriendsFrameTab" .. i]
        if tab and tab:GetID() == FRIEND_TAB_RAID then
            return tab:GetName()
        end
    end
end

local function CreateRaidCounter()
    local newSocialUI = SocialUIControl and SocialUIControl.IsEnabled()
    local raidTab = not newSocialUI and FriendsMicroButton and GetRaidTabName()
    local raidCounterFrame
    if raidTab then
        local openMacro = "/click FriendsMicroButton\n/click " .. raidTab
        local closeButton = FriendsFrame.CloseButton and FriendsFrame.CloseButton:GetName()
        raidCounterFrame = CreateFrame("Button", "GW_RaidCounter_Frame", UIParent, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")
        raidCounterFrame:RegisterForClicks("LeftButtonUp")
        raidCounterFrame:SetAttribute("type", "macro")
        raidCounterFrame:SetAttribute("macrotext", openMacro)
        if closeButton then
            raidCounterFrame:SetAttribute("gwOpen", openMacro)
            raidCounterFrame:SetAttribute("gwClose", "/click " .. closeButton)
            raidCounterFrame:SetFrameRef("raidFrame", RaidFrame)
            SecureHandlerWrapScript(raidCounterFrame, "OnClick", raidCounterFrame, [[
                local open = not PlayerInCombat() and self:GetFrameRef("raidFrame"):IsVisible()
                self:SetAttribute("macrotext", self:GetAttribute(open and "gwClose" or "gwOpen"))
            ]])
        end
    else
        -- the new social window has no named raid tab to click, in combat only blizzards keybind opens it
        raidCounterFrame = CreateFrame("Button", "GW_RaidCounter_Frame", UIParent)
        raidCounterFrame:SetScript("OnClick", function()
            if InCombatLockdown() then
                UIErrorsFrame:AddExternalErrorMessage(ERR_NOT_IN_COMBAT)
                return
            end
            ToggleRaidFrame()
        end)
    end
    raidCounterFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

    raidCounterFrame:SetSize(100, 25)

    raidCounterFrame.tank = raidCounterFrame:CreateFontString(nil, "ARTWORK")
    raidCounterFrame.tank:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    raidCounterFrame.tank:SetPoint("LEFT", raidCounterFrame, "LEFT", 5, 0)
    raidCounterFrame.tank:SetTextColor(1, 1, 1)

    raidCounterFrame.heal = raidCounterFrame:CreateFontString(nil, "ARTWORK")
    raidCounterFrame.heal:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    raidCounterFrame.heal:SetPoint("CENTER", raidCounterFrame, "CENTER", 0, 0)
    raidCounterFrame.heal:SetTextColor(1, 1, 1)

    raidCounterFrame.damager = raidCounterFrame:CreateFontString(nil, "ARTWORK")
    raidCounterFrame.damager:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    raidCounterFrame.damager:SetPoint("RIGHT", raidCounterFrame, "RIGHT", -5, 0)
    raidCounterFrame.damager:SetTextColor(1, 1, 1)

    raidCounterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    raidCounterFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    raidCounterFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    raidCounterFrame:SetScript("OnEvent", function()
        local unit = (IsInRaid() and "raid" or "party")
        local tank, damage, heal = 0, 0, 0
        for i = 1, GetNumGroupMembers() do
            local role = UnitGroupRolesAssigned(unit .. i)

            if GW.NotSecretValue(role) and role then
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
            local playerRole = GW.GetPlayerRole()
            if playerRole == "TANK" then
                tank = tank + 1
            elseif playerRole == "HEALER" then
                heal = heal + 1
            elseif playerRole == "DAMAGER" then
                damage = damage + 1
            end
        end

        raidCounterFrame.tank:SetText("|TInterface/AddOns/GW2_UI/textures/party/roleicon-tank.png:0:0:0:2:64:64:4:60:4:60|t " .. tank)
        raidCounterFrame.heal:SetText("|TInterface/AddOns/GW2_UI/textures/party/roleicon-healer.png:0:0:0:1:64:64:4:60:4:60|t " .. heal)
        raidCounterFrame.damager:SetText("|TInterface/AddOns/GW2_UI/textures/party/roleicon-dps.png:15:15:0:0:64:64:4:60:4:60|t" .. damage)
    end)

    GW.RegisterMovableFrame(raidCounterFrame, GW.L["Role Bar"], "roleBar", "Group,Raid", nil, {GW.MoverOption.Scale})
    raidCounterFrame:ClearAllPoints()
    raidCounterFrame:SetPoint("TOPLEFT", raidCounterFrame.gwMover)

    UpdateRaidCounterVisibility()
end
GW.CreateRaidCounter = CreateRaidCounter