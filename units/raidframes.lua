local _, GW = ...
local GetSetting = GW.GetSetting
local GWGetClassColor = GW.GWGetClassColor
local RegisterMovableFrame = GW.RegisterMovableFrame
local SetClassIcon = GW.SetClassIcon
local IsIn = GW.IsIn

local players
local previewSteps = {40, 20, 10, 5}
local previewStep = 0

-- functions
local function GetRaidFramesMeasures(players)
    -- Get settings
    local grow = GetSetting("RAID_GROW")
    local w = GetSetting("RAID_WIDTH")
    local h = GetSetting("RAID_HEIGHT")
    local cW = GetSetting("RAID_CONT_WIDTH")
    local cH = GetSetting("RAID_CONT_HEIGHT")
    local per = ceil(GetSetting("RAID_UNITS_PER_COLUMN"))
    local byRole = GetSetting("RAID_SORT_BY_ROLE")
    local m = 2

    -- Determine # of players
    if players or byRole or not IsInRaid() then
        players = players or max(1, GetNumGroupMembers())
    else
        players = 0
        for i = 1, MAX_RAID_MEMBERS do
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

local function PositionRaidFrame(frame, parent, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
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

local function GridRaidUpdateFramesPosition()
    players = previewStep == 0 and 40 or previewSteps[previewStep]

    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GetRaidFramesMeasures(players)
    local isV = grow1 == "DOWN" or grow1 == "UP"

    -- Update size
    GwRaidFrameContainer.gwMover:SetSize(isV and size2 or size1, isV and size1 or size2)

    -- Update unit frames
    for i = 1, MAX_RAID_MEMBERS do
        PositionRaidFrame(_G["GwCompactRaidFrame" .. i], GwRaidFrameContainer.gwMover, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
        if i > players then _G["GwCompactRaidFrame" .. i]:Hide() else _G["GwCompactRaidFrame" .. i]:Show() end
    end
end
GW.GridRaidUpdateFramesPosition = GridRaidUpdateFramesPosition

local grpPos, noGrp = {}, {}
local function GridRaidUpdateFramesLayout()
    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GetRaidFramesMeasures()
    local isV = grow1 == "DOWN" or grow1 == "UP"

    if not InCombatLockdown() then
        GwRaidFrameContainer:SetSize(isV and size2 or size1, isV and size1 or size2)
    end

    wipe(grpPos) wipe(noGrp)

    -- Position by group
    for i = 1, MAX_RAID_MEMBERS do
        local name, _, grp = GetRaidRosterInfo(i)
        if name or grp > 1 then
            grpPos[grp] = (grpPos[grp] or 0) + 1
            PositionRaidFrame(_G["GwCompactRaidFrame" .. i], GwRaidFrameContainer, (grp - 1) * MEMBERS_PER_RAID_GROUP + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
        else
            tinsert(noGrp, i)
        end
    end

    -- Find spots for units with missing group info
    for _,i in ipairs(noGrp) do
        for grp = 1, NUM_RAID_GROUPS do
            if (grpPos[grp] or 0) < MEMBERS_PER_RAID_GROUP then
                grpPos[grp] = (grpPos[grp] or 0) + 1
                PositionRaidFrame(_G["GwCompactRaidFrame" .. i], GwRaidFrameContainer, (grp - 1) * MEMBERS_PER_RAID_GROUP + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
                break
            end
        end
    end
end
GW.GridRaidUpdateFramesLayout = GridRaidUpdateFramesLayout

local function hideBlizzardRaidFrame()
    if InCombatLockdown() then
        return
    end

    if CompactRaidFrameManager then
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:Hide()
    end
    if CompactRaidFrameContainer then
        CompactRaidFrameContainer:UnregisterAllEvents()
    end
    if CompactRaidFrameManager_GetSetting then
        local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
        if compact_raid and compact_raid ~= "0" then
            CompactRaidFrameManager_SetSetting("IsShown", "0")
        end
    end
end
GW.AddForProfiling("raidframes", "hideBlizzardRaidFrame", hideBlizzardRaidFrame)

local function GridOnEvent(self, event, unit)
    if not UnitExists(self.unit) then
        return
    elseif not self.nameNotLoaded then
        GW.GridSetUnitName(self, "RAID")
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
        GW.GridSetPredictionAmount(self, "RAID")
        GW.GridSetHealth(self, "RAID")
        GW.GridUpdateAwayData(self, "RAID")
        GW.GridUpdateAuras(self, "RAID")
        GW.GridUpdatePower(self)
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH_FREQUENT" then
        GW.GridSetHealth(self, "RAID")
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        GW.GridUpdatePower(self)
    elseif event == "UNIT_HEAL_PREDICTION" then
        GW.GridSetPredictionAmount(self, "RAID")
    elseif event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" or event == "UNIT_THREAT_SITUATION_UPDATE" then
        GW.GridUpdateAwayData(self, "RAID")
    elseif event == "PLAYER_TARGET_CHANGED" then
        GW.GridHighlightTargetFrame(self)
    elseif event == "UNIT_NAME_UPDATE" then
        GW.GridSetUnitName(self, "RAID")
    elseif event == "UNIT_AURA" then
        GW.GridUpdateAuras(self, "RAID")
    elseif event == "PLAYER_ENTERING_WORLD" then
        RequestRaidInfo()
    elseif event == "UPDATE_INSTANCE_INFO" then
        GW.GridUpdateAuras(self, "RAID")
        GW.GridUpdateAwayData(self, "RAID")
    elseif (event == "INCOMING_RESURRECT_CHANGED") and unit == self.unit then
        GW.GridUpdateAwayData(self, "RAID")
    elseif event == "RAID_TARGET_UPDATE" and GetSetting("RAID_UNIT_MARKERS") then
        GW.GridUpdateRaidMarkers(self, "RAID")
    elseif event == "READY_CHECK" or (event == "READY_CHECK_CONFIRM" and unit == self.unit) then
        GW.GridUpdateAwayData(self, "RAID")
    elseif event == "READY_CHECK_FINISHED" then
        C_Timer.After(1.5, function()
            if UnitInRaid(self.unit) then
                local _, englishClass, classIndex = UnitClass(self.unit)
                if GetSetting("RAID_CLASS_COLOR") then
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

local function GridOnUpdate(self, elapsed)
    if self.onUpdateDelay ~= nil and self.onUpdateDelay > 0 then
        self.onUpdateDelay = self.onUpdateDelay - elapsed
        return
    end
    self.onUpdateDelay = 0.2
    if UnitExists(self.unit) then
        GW.GridUpdateAwayData(self)
    end
end

local function GridToggleFramesPreviewRaid(_, _, moveHudMode, hudMoving)
    previewStep = max((previewStep + 1) % (#previewSteps + 1), hudMoving and 1 or 0)

    if previewStep == 0 or moveHudMode then
        for i = 1, MAX_RAID_MEMBERS do
            if _G["GwCompactRaidFrame" .. i] then
                _G["GwCompactRaidFrame" .. i].unit = "raid" .. i
                _G["GwCompactRaidFrame" .. i].guid = UnitGUID("raid" .. i)
                _G["GwCompactRaidFrame" .. i]:SetAttribute("unit", "raid" .. i)
                UnregisterStateDriver(_G["GwCompactRaidFrame" .. i], "visibility")
                RegisterStateDriver(_G["GwCompactRaidFrame" .. i], "visibility", ("[group:raid,@%s,exists] show; [group:party] hide; hide"):format(_G["GwCompactRaidFrame" .. i].unit))
                GridOnEvent(_G["GwCompactRaidFrame" .. i], "load")
            end
        end
    else
        for i = 1, MAX_RAID_MEMBERS do
            if _G["GwCompactRaidFrame" .. i] then
                _G["GwCompactRaidFrame" .. i].unit = "player"
                _G["GwCompactRaidFrame" .. i].guid = UnitGUID("player")
                _G["GwCompactRaidFrame" .. i]:SetAttribute("unit", "player")
                UnregisterStateDriver(_G["GwCompactRaidFrame" .. i], "visibility")
                RegisterStateDriver(_G["GwCompactRaidFrame" .. i], "visibility", ("%s"):format((i > previewSteps[previewStep] and "hide" or "show")))
                GridOnEvent(_G["GwCompactRaidFrame" .. i], "load")
            end
        end
        GridRaidUpdateFramesPosition()
    end
    GwSettingsRaidPanel.buttonRaidPreview:SetText((previewStep == 0 or moveHudMode) and "-" or previewSteps[previewStep])
    if previewStep == 0 or moveHudMode then
        GridRaidUpdateFramesLayout()
    end
end
GW.GridToggleFramesPreviewRaid = GridToggleFramesPreviewRaid

local function LoadRaidFrames()
    if not _G.GwManageGroupButton then
        GW.manageButton()
    end

    hideBlizzardRaidFrame()

    if CompactRaidFrameManager_UpdateShown then
        hooksecurefunc("CompactRaidFrameManager_UpdateShown", hideBlizzardRaidFrame)
    end
    if CompactRaidFrameManager then
        CompactRaidFrameManager:HookScript("OnShow", hideBlizzardRaidFrame)
    end

    local container = CreateFrame("Frame", "GwRaidFrameContainer", UIParent, "GwRaidFrameContainer")
    local pos = GetSetting("raid_pos")
    container:ClearAllPoints()
    container:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)

    RegisterMovableFrame(container, RAID_FRAMES_LABEL, "raid_pos", "VerticalActionBarDummy", nil, true, {"default", "default"})

    hooksecurefunc(container.gwMover, "StopMovingOrSizing", function(frame)
        local anchor = GetSetting("RAID_ANCHOR")

        if anchor == "GROWTH" then
            local g1, g2 = strsplit("+", GetSetting("RAID_GROW"))
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

    for i = 1, MAX_RAID_MEMBERS do
        GW.CreateGridFrame(i, false, container, GridOnEvent, GridOnUpdate, "RAID")
    end

    GridRaidUpdateFramesPosition()
    GridRaidUpdateFramesLayout()

    GwSettingsWindowMoveHud:HookScript("OnClick", function ()
        GW.GridToggleFramesPreviewRaid(_, _, true, true)
        GW.GridToggleFramesPreviewParty(_, _, true, true)
    end)
    GwSmallSettingsWindow.lockHud:HookScript("OnClick", function()
        GW.GridToggleFramesPreviewRaid(_, _, true, true)
        GW.GridToggleFramesPreviewParty(_, _, true, true)
    end)

    container:RegisterEvent("RAID_ROSTER_UPDATE")
    container:RegisterEvent("GROUP_ROSTER_UPDATE")
    container:RegisterEvent("PLAYER_ENTERING_WORLD")

    container:SetScript("OnEvent", function(self, event)
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
        if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end

        GridRaidUpdateFramesLayout()

        for i = 1, MAX_RAID_MEMBERS do
            GW.GridUpdateFrameData(_G["GwCompactRaidFrame" .. i], i)
        end
    end)
end
GW.LoadRaidFrames = LoadRaidFrames
