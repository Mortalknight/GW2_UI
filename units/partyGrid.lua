local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local IsIn = GW.IsIn
local GWGetClassColor = GW.GWGetClassColor
local RegisterMovableFrame = GW.RegisterMovableFrame
local SetClassIcon = GW.SetClassIcon

local players
local previewSteps = {5, 4, 3, 2, 1}
local previewStep = 0
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS + 1


local function GetPartyFramesMeasures(players)
    -- Get settings
    local grow = GetSetting("RAID_GROW_PARTY")
    local w = GetSetting("RAID_WIDTH_PARTY")
    local h = GetSetting("RAID_HEIGHT_PARTY")
    local cW = GetSetting("RAID_CONT_WIDTH_PARTY")
    local cH = GetSetting("RAID_CONT_HEIGHT_PARTY")
    local per = ceil(GetSetting("RAID_UNITS_PER_COLUMN_PARTY"))
    local byRole = GetSetting("RAID_SORT_BY_ROLE_PARTY")
    local m = 2

    -- Determine # of players
    if players or byRole then
        players = players or max(1, GetNumGroupMembers())
    else
        players = 0
        for i = 1, MAX_PARTY_MEMBERS do
            local _, _, grp = GetRaidRosterInfo(i)
            if grp >= ceil(players / MEMBERS_PER_RAID_GROUP) then
                players = max((grp - 1) * MEMBERS_PER_RAID_GROUP, players) + 1
            end
        end
        players = max(1, players, GetNumGroupMembers())
    end

    -- Directions
    local grow1, grow2 = strsplit("+", grow)
    local isV = grow1 == "DOWN" or grow1 == "UP"

    -- Rows, cols and cell size
    local sizeMax1, sizePer1 = isV and cH or cW, isV and h or w
    local sizeMax2, sizePer2 = isV and cW or cH, isV and w or h

    local cells1 = players

    if per > 0 then
        cells1 = min(cells1, per)
        if tonumber(sizeMax1) > 0 then
            sizePer1 = min(sizePer1, (sizeMax1 + m) / cells1 - m)
        end
    elseif tonumber(sizeMax1) > 0 then
        cells1 = max(1, min(players, floor((sizeMax1 + m) / (sizePer1 + m))))
    end

    local cells2 = ceil(players / cells1)

    if tonumber(sizeMax2) > 0 then
        sizePer2 = min(sizePer2, (sizeMax2 + m) / cells2 - m)
    end

    -- Container size
    local size1, size2 = cells1 * (sizePer1 + m) - m, cells2 * (sizePer2 + m) - m
    sizeMax1, sizeMax2 = max(size1, sizeMax1), max(size2, sizeMax2)

    return grow1, grow2, cells1, cells2, size1, size2, sizeMax1, sizeMax2, sizePer1, sizePer2, m
end

local function PositionPartyFrame(frame, parent, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
    local isV = grow1 == "DOWN" or grow1 == "UP"
    local isU = grow1 == "UP" or grow2 == "UP"
    local isR = grow1 == "RIGHT" or grow2 == "RIGHT"

    local dir1, dir2 = isU and 1 or -1, isR and 1 or -1
    if not isV then
        dir1, dir2 = dir2, dir1
    end

    local pos1, pos2 = dir1 * ((i - 1) % cells1), dir2 * (ceil(i / cells1) - 1)

    local a = (isU and "BOTTOM" or "TOP") .. (isR and "LEFT" or "RIGHT")
    local w = isV and sizePer2 or sizePer1
    local h = isV and sizePer1 or sizePer2
    local x = (isV and pos2 or pos1) * (w + m)
    local y = (isV and pos1 or pos2) * (h + m)

    if not InCombatLockdown() then
        frame:ClearAllPoints()
        frame:SetPoint(a, parent, a, x, y)
        frame:SetSize(w, h)
    end

    if frame.healthbar then
        frame.healthbar.spark:SetHeight(frame.healthbar:GetHeight())
    end
end

local function GridPartyUpdateFramesPosition()
    if not GwRaidFramePartyContainer then return end
    players = previewStep == 0 and 5 or previewSteps[previewStep]

    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GetPartyFramesMeasures(players)
    local isV = grow1 == "DOWN" or grow1 == "UP"

    -- Update size
    GwRaidFramePartyContainer.gwMover:SetSize(isV and size2 or size1, isV and size1 or size2)

    -- Update unit frames
    for i = 1, MAX_PARTY_MEMBERS do
        PositionPartyFrame(_G["GwCompactPartyFrame" .. i], GwRaidFramePartyContainer.gwMover, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
        if i > players then _G["GwCompactPartyFrame" .. i]:Hide() else _G["GwCompactPartyFrame" .. i]:Show() end
    end
end
GW.GridPartyUpdateFramesPosition = GridPartyUpdateFramesPosition

--[[
local function GridSortByRole()
    local sorted = {}
    local roleIndex = {"TANK", "HEALER", "DAMAGER", "NONE"}
    local unitString = "Party"

    for _, v in pairs(roleIndex) do
        if unitString == "Party" and UnitGroupRolesAssigned("player") == v then
            tinsert(sorted, "PartyFrame1")
        end

        for i = 1, MAX_PARTY_MEMBERS do
            if UnitExists(unitString .. i) and UnitGroupRolesAssigned(unitString .. i) == v then
                tinsert(sorted, unitString .. "Frame" .. i + 1)
            end
        end
    end

    return sorted
end
]]

local grpPos, noGrp = {}, {}
local function GridPartyUpdateFramesLayout()
    if not GwRaidFramePartyContainer then return end
    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GetPartyFramesMeasures()
    local isV = grow1 == "DOWN" or grow1 == "UP"

    if not InCombatLockdown() then
        GwRaidFramePartyContainer:SetSize(isV and size2 or size1, isV and size1 or size2)
    end

    local unitString = "Party"
    local sorted = {} --GetSetting("RAID_SORT_BY_ROLE_PARTY") and GridSortByRole() or {}

    -- Position by role
    for i, v in ipairs(sorted) do
        PositionPartyFrame(_G["GwCompact" .. v], GwRaidFramePartyContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
    end

    wipe(grpPos) wipe(noGrp)

    -- Position by group
    for i = 1, MAX_PARTY_MEMBERS do
        if not tContains(sorted, unitString .. "Frame" .. i) then
            local name, _, grp = GetRaidRosterInfo(i)
            if name or grp > 1 then
                grpPos[grp] = (grpPos[grp] or 0) + 1
                PositionPartyFrame(_G["GwCompactPartyFrame" .. i], GwRaidFramePartyContainer, (grp - 1) * MEMBERS_PER_RAID_GROUP + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
            else
                tinsert(noGrp, i)
            end
        end
    end

    -- Find spots for units with missing group info
    for _,i in ipairs(noGrp) do
        for grp = 1, MAX_PARTY_MEMBERS do
            if (grpPos[grp] or 0) < MEMBERS_PER_RAID_GROUP then
                grpPos[grp] = (grpPos[grp] or 0) + 1
                PositionPartyFrame(_G["GwCompactPartyFrame" .. i], GwRaidFramePartyContainer, (grp - 1) * MEMBERS_PER_RAID_GROUP + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
                break
            end
        end
    end
end
GW.GridPartyUpdateFramesLayout = GridPartyUpdateFramesLayout

local function unhookPlayerFrame()
    if InCombatLockdown() or IsInRaid() then
        return
    end

    if IsInGroup() and (GetSetting("RAID_STYLE_PARTY") or GetSetting("RAID_STYLE_PARTY_AND_FRAMES")) then
        GwCompactPartyFrame1:Show()
        RegisterStateDriver(GwCompactPartyFrame1, "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format(GwCompactPartyFrame1.unit))
    else
        UnregisterStateDriver(GwCompactPartyFrame1, "visibility")
        GwCompactPartyFrame1:Hide()
    end
end
GW.AddForProfiling("raidframes", "unhookPlayerFrame", unhookPlayerFrame)

local function GridOnEvent(self, event, unit)
    if not UnitExists(self.unit) then
        return
    elseif not self.nameNotLoaded then
        GW.GridSetUnitName(self, "PARTY")
    end

    if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        -- Enable or disable mouse handling on aura frames
        local name = self:GetName()
        for j = 1, 2 do
            local i, aura = 1, j == 1 and "Buff" or "DeBuff"
            local frame = nil
            repeat
                frame = _G["Gw" .. name .. aura .. "ItemFrame" .. i]
                if frame then
                    if frame.tooltipSetting == "NEVER" then
                        frame:EnableMouse(false)
                    elseif frame.tooltipSetting == "ALWAYS" then
                        frame:EnableMouse(true)
                    elseif frame.tooltipSetting == "IN_COMBAT" and event == "PLAYER_REGEN_ENABLED" then
                        frame:EnableMouse(false)
                    elseif frame.tooltipSetting == "IN_COMBAT" and event == "PLAYER_REGEN_DISABLED" then
                        frame:EnableMouse(true)
                    elseif frame.tooltipSetting == "OUT_COMBAT" and event == "PLAYER_REGEN_ENABLED" then
                        frame:EnableMouse(true)
                    elseif frame.tooltipSetting == "OUT_COMBAT" and event == "PLAYER_REGEN_DISABLED" then
                        frame:EnableMouse(false)
                    end
                end
                i = i + 1
            until not frame
        end
    end

    if event == "load" then
        GW.GridSetPredictionAmount(self, "PARTY")
        GW.GridSetHealth(self, "PARTY")
        GW.GridUpdateAwayData(self, "PARTY")
        GW.GridUpdateAuras(self, "PARTY")
        GW.GridUpdatePower(self)
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH_FREQUENT" then
        GW.GridSetHealth(self, "PARTY")
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        GW.GridUpdatePower(self)
    elseif event == "UNIT_HEAL_PREDICTION" then
        GW.GridSetPredictionAmount(self, "PARTY")
    elseif event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" or event == "UNIT_THREAT_SITUATION_UPDATE" then
        GW.GridUpdateAwayData(self, "PARTY")
    elseif event == "PLAYER_TARGET_CHANGED" then
        GW.GridHighlightTargetFrame(self)
    elseif event == "UNIT_NAME_UPDATE" then
        GW.GridSetUnitName(self, "PARTY")
    elseif event == "UNIT_AURA" then
        GW.GridUpdateAuras(self, "PARTY")
    elseif event == "PLAYER_ENTERING_WORLD" then
        RequestRaidInfo()
    elseif event == "UPDATE_INSTANCE_INFO" then
        GW.GridUpdateAuras(self, "PARTY")
        GW.GridUpdateAwayData(self, "PARTY")
    elseif (event == "INCOMING_RESURRECT_CHANGED") and unit == self.unit then
        GW.GridUpdateAwayData(self, "PARTY")
    elseif event == "RAID_TARGET_UPDATE" and GetSetting("RAID_UNIT_MARKERS_PARTY") then
        GW.GridUpdateRaidMarkers(self, "PARTY")
    elseif event == "READY_CHECK" or (event == "READY_CHECK_CONFIRM" and unit == self.unit) then
        GW.GridUpdateAwayData(self, "PARTY")
    elseif event == "READY_CHECK_FINISHED" then
        C_Timer.After(1.5, function()
            if UnitInRaid(self.unit) then
                local _, englishClass, classIndex = UnitClass(self.unit)
                if GetSetting("RAID_CLASS_COLOR_PARTY") then
                    local color = GWGetClassColor(englishClass, true)
                    self.healthbar:SetStatusBarColor(color.r, color.g, color.b, color.a)
                    self.classicon:SetShown(false)
                else
                    self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
                    self.healthbar:SetStatusBarColor(0.207, 0.392, 0.168)
                    self.classicon:SetShown(true)
                    SetClassIcon(self.classicon, classIndex)
                end
            end
        end)
    end
end
GW.GridOnEvent = GridOnEvent

local function GridOnUpdate(self, elapsed)
    if self.onUpdateDelay ~= nil and self.onUpdateDelay > 0 then
        self.onUpdateDelay = self.onUpdateDelay - elapsed
        return
    end
    self.onUpdateDelay = 0.2
    if UnitExists(self.unit) then
        GW.GridUpdateAwayData(self, "PARTY")
    end
end

local function GridToggleFramesPreviewParty(_, _, moveHudMode, hudMoving)
    previewStep = max((previewStep + 1) % (#previewSteps + 1), hudMoving and 1 or 0)

    if previewStep == 0 or moveHudMode then
        for i = 1, MAX_PARTY_MEMBERS do
            if _G["GwCompactPartyFrame" .. i] then
                _G["GwCompactPartyFrame" .. i].unit = i == 1 and "player" or "party" .. i - 1
                _G["GwCompactPartyFrame" .. i].guid = UnitGUID(i == 1 and "player" or "party" .. i - 1)
                _G["GwCompactPartyFrame" .. i]:SetAttribute("unit", i == 1 and "player" or "party" .. i - 1)
                UnregisterStateDriver(_G["GwCompactPartyFrame" .. i], "visibility")
                RegisterStateDriver(_G["GwCompactPartyFrame" .. i], "visibility", ("[group:raid] hide; [group:party,@%s,exists] show; hide"):format(_G["GwCompactPartyFrame" .. i].unit))
                GW.GridOnEvent(_G["GwCompactPartyFrame" .. i], "load")
            end
        end
    else
        for i = 1, MAX_PARTY_MEMBERS do
            if _G["GwCompactPartyFrame" .. i] then
                _G["GwCompactPartyFrame" .. i].unit = "player"
                _G["GwCompactPartyFrame" .. i].guid = UnitGUID("player")
                _G["GwCompactPartyFrame" .. i]:SetAttribute("unit", "player")
                UnregisterStateDriver(_G["GwCompactPartyFrame" .. i], "visibility")
                RegisterStateDriver(_G["GwCompactPartyFrame" .. i], "visibility", ("%s"):format((i > previewSteps[previewStep] and "hide" or "show")))
                GW.GridOnEvent(_G["GwCompactPartyFrame" .. i], "load")
            end
        end
        GridPartyUpdateFramesPosition()
    end
    GwSettingsRaidPartyPanel.buttonRaidPreview:SetText((previewStep == 0 or moveHudMode) and "-" or previewSteps[previewStep])
    if previewStep == 0 or moveHudMode then
        GridPartyUpdateFramesLayout()
    end
end
GW.GridToggleFramesPreviewParty = GridToggleFramesPreviewParty

local function LoadPartyGrid()
    if not GetSetting("RAID_STYLE_PARTY") and not GetSetting("RAID_STYLE_PARTY_AND_FRAMES") then
        return
    end

    if not _G.GwManageGroupButton then
        GW.manageButton()
    end

    local container = CreateFrame("Frame", "GwRaidFramePartyContainer", UIParent, "GwRaidFrameContainer")

    local pos = GetSetting("raid_party_pos")
    container:ClearAllPoints()
    container:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)

    RegisterMovableFrame(container, L["Group Frames"], "raid_party_pos", "VerticalActionBarDummy", nil, true, {"default", "default"})

    hooksecurefunc(container.gwMover, "StopMovingOrSizing", function(frame)
        local anchor = GetSetting("RAID_ANCHOR_PARTY")

        if anchor == "GROWTH" then
            local g1, g2 = strsplit("+", GetSetting("RAID_GROW_PARTY"))
            anchor = (IsIn("DOWN", g1, g2) and "TOP" or "BOTTOM") .. (IsIn("RIGHT", g1, g2) and "LEFT" or "RIGHT")
        end

        if anchor ~= "POSITION" then
            local x = anchor:sub(-5) == "RIGHT" and frame:GetRight() - GetScreenWidth() or anchor:sub(-4) == "LEFT" and frame:GetLeft() or frame:GetLeft() + (frame:GetWidth() - GetScreenWidth()) / 2
            local y = anchor:sub(1, 3) == "TOP" and frame:GetTop() - GetScreenHeight() or anchor:sub(1, 6) == "BOTTOM" and frame:GetBottom() or frame:GetBottom() + (frame:GetHeight() - GetScreenHeight()) / 2

            frame:ClearAllPoints()
            frame:SetPoint(anchor, x, y)
        end

        if not InCombatLockdown() then
            container:ClearAllPoints()
            container:SetPoint(frame:GetPoint())
        end
    end)

    for i = 1, 5 do
        GW.CreateGridFrame(i, true, container, GridOnEvent, GridOnUpdate, "PARTY")
    end

    GridPartyUpdateFramesPosition()
    GridPartyUpdateFramesLayout()

    container:RegisterEvent("RAID_ROSTER_UPDATE")
    container:RegisterEvent("GROUP_ROSTER_UPDATE")
    container:RegisterEvent("PLAYER_ENTERING_WORLD")

    container:SetScript("OnEvent", function(self, event)
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
        if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end

        unhookPlayerFrame()

        GridPartyUpdateFramesLayout()

        for i = 1, 5 do
            GW.GridUpdateFrameData(_G["GwCompactPartyFrame" .. i], i)
        end
    end)
end
GW.LoadPartyGrid = LoadPartyGrid