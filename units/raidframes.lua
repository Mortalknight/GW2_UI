local _, GW = ...
local GetSetting = GW.GetSetting
local GWGetClassColor = GW.GWGetClassColor
local RegisterMovableFrame = GW.RegisterMovableFrame
local SetClassIcon = GW.SetClassIcon
local IsIn = GW.IsIn

local players
local previewSteps = {40, 20, 10, 5}
local previewStep = 0

local settings = {}

local function UpdateSettings()
    settings.raidAuraTooltipInCombat = GetSetting("RAID_AURA_TOOLTIP_INCOMBAT")
    settings.raidClassColor = GetSetting("RAID_CLASS_COLOR")
    settings.raidUnitMarkers = GetSetting("RAID_UNIT_MARKERS")
    settings.raidGrow = GetSetting("RAID_GROW")
    settings.raidWidth = GetSetting("RAID_WIDTH")
    settings.raidHeight = GetSetting("RAID_HEIGHT")
    settings.raidContainerWidth = GetSetting("RAID_CONT_WIDTH")
    settings.raidContainerHeight = GetSetting("RAID_CONT_HEIGHT")
    settings.raidUnitsPerColumn = ceil(GetSetting("RAID_UNITS_PER_COLUMN"))
    settings.raidByRole = GetSetting("RAID_SORT_BY_ROLE")
    settings.raidAnchor = GetSetting("RAID_ANCHOR")
end
GW.UpdateRaidGridSettings = UpdateSettings

-- functions
local function GetRaidFramesMeasures(Players)
    local m = 2

    -- Determine # of players
    if Players or settings.raidByRole then
        Players = Players or max(1, GetNumGroupMembers())
    else
        Players = 0
        for i = 1, MAX_RAID_MEMBERS do
            local _, _, grp = GetRaidRosterInfo(i)
            if grp >= ceil(Players / MEMBERS_PER_RAID_GROUP) then
                Players = max((grp - 1) * MEMBERS_PER_RAID_GROUP, Players) + 1
            end
        end
        Players = max(1, Players, GetNumGroupMembers())
    end

    -- Directions
    local grow1, grow2 = strsplit("+", settings.raidGrow)
    local isV = grow1 == "DOWN" or grow1 == "UP"

    -- Rows, cols and cell size
    local sizeMax1, sizePer1 = isV and settings.raidContainerHeight or settings.raidContainerWidth, isV and settings.raidHeight or settings.raidWidth
    local sizeMax2, sizePer2 = isV and settings.raidContainerWidth or settings.raidContainerHeight, isV and settings.raidWidth or settings.raidHeight

    local cells1 = Players

    if settings.raidUnitsPerColumn > 0 then
        cells1 = min(cells1, settings.raidUnitsPerColumn)
        if tonumber(sizeMax1) > 0 then
            sizePer1 = min(sizePer1, (sizeMax1 + m) / cells1 - m)
        end
    elseif tonumber(sizeMax1) > 0 then
        cells1 = max(1, min(Players, floor((sizeMax1 + m) / (sizePer1 + m))))
    end

    local cells2 = ceil(Players / cells1)

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
    players = IsInRaid() and max(1, GetNumGroupMembers()) or previewStep == 0 and 40 or previewSteps[previewStep]

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

local function GridSortByRole()
    local sorted = {}
    local roleIndex = {"TANK", "HEALER", "DAMAGER", "NONE"}
    local unitString = "Raid"

    for _, v in pairs(roleIndex) do
        for i = 1, MAX_RAID_MEMBERS do
            if UnitExists(unitString .. i) and UnitGroupRolesAssigned(unitString .. i) == v then
                tinsert(sorted, unitString .. "Frame" .. i)
            end
        end
    end

    return sorted
end

local grpPos, noGrp = {}, {}
local function GridRaidUpdateFramesLayout()
    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GetRaidFramesMeasures(IsInRaid() and max(1, GetNumGroupMembers()) or previewStep == 0 and 40 or previewSteps[previewStep])
    local isV = grow1 == "DOWN" or grow1 == "UP"

    if not InCombatLockdown() then
        GwRaidFrameContainer:SetSize(isV and size2 or size1, isV and size1 or size2)
    end

    local unitString = "Raid"
    local sorted = settings.raidByRole and GridSortByRole() or {}

    -- Position by role
    for i, v in ipairs(sorted) do
        PositionRaidFrame(_G["GwCompact" .. v], GwRaidFrameContainer, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
    end

    wipe(grpPos) wipe(noGrp)

    -- Position by group
    for i = 1, MAX_RAID_MEMBERS do
        if not tContains(sorted, unitString .. "Frame" .. i) then
            local name, _, grp = GetRaidRosterInfo(i)
            if name or grp > 1 then
                grpPos[grp] = (grpPos[grp] or 0) + 1
                PositionRaidFrame(_G["GwCompactRaidFrame" .. i], GwRaidFrameContainer, (grp - 1) * MEMBERS_PER_RAID_GROUP + grpPos[grp], grow1, grow2, cells1, sizePer1, sizePer2, m)
            else
                tinsert(noGrp, i)
            end
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

local function RaidGridOnEvent(self, event, unit)
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
                    if settings.raidAuraTooltipInCombat == "NEVER" then
                        frame:EnableMouse(false)
                    elseif settings.raidAuraTooltipInCombat == "ALWAYS" then
                        frame:EnableMouse(true)
                    elseif settings.raidAuraTooltipInCombat == "IN_COMBAT" and event == "PLAYER_REGEN_ENABLED" then
                        frame:EnableMouse(false)
                    elseif settings.raidAuraTooltipInCombat == "IN_COMBAT" and event == "PLAYER_REGEN_DISABLED" then
                        frame:EnableMouse(true)
                    elseif settings.raidAuraTooltipInCombat == "OUT_COMBAT" and event == "PLAYER_REGEN_ENABLED" then
                        frame:EnableMouse(true)
                    elseif settings.raidAuraTooltipInCombat == "OUT_COMBAT" and event == "PLAYER_REGEN_DISABLED" then
                        frame:EnableMouse(false)
                    end
                end
                i = i + 1
            until not frame
        end
    end

    if event == "load" then
        GW.GridSetAbsorbAmount(self)
        GW.GridSetPredictionAmount(self, "RAID")
        GW.GridSetHealth(self, "RAID")
        GW.GridUpdateAwayData(self, "RAID", true)
        GW.GripToggleSummonOrResurrection(self, "RAID")
        GW.GridUpdateAuras(self, "RAID")
        GW.GridUpdatePower(self)
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        GW.GridSetHealth(self, "RAID")
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        GW.GridUpdatePower(self)
    elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        GW.GridSetAbsorbAmount(self)
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
    elseif (event == "INCOMING_RESURRECT_CHANGED" or event == "INCOMING_SUMMON_CHANGED") and unit == self.unit then
        GW.GripToggleSummonOrResurrection(self, "RAID")
    elseif event == "RAID_TARGET_UPDATE" and settings.raidUnitMarkers then
        GW.GridUpdateRaidMarkers(self, "RAID")
    elseif event == "READY_CHECK" or (event == "READY_CHECK_CONFIRM" and unit == self.unit) then
        GW.GridUpdateAwayData(self, "RAID", true)
    elseif event == "READY_CHECK_FINISHED" then
        C_Timer.After(1.5, function()
            if UnitInRaid(self.unit) then
                local _, englishClass, classIndex = UnitClass(self.unit)
                if settings.raidClassColor then
                    local color = GWGetClassColor(englishClass, true)
                    self.healthbar:SetStatusBarColor(color.r, color.g, color.b, color.a)
                    self.classicon:SetShown(false)
                else
                    self.classicon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons")
                    self.healthbar:SetStatusBarColor(0.207, 0.392, 0.168)
                    self.classicon:SetShown(true)
                    SetClassIcon(self.classicon, classIndex)
                end
                self.readyCheckInProgress = false
            end
        end)
    end
end
GW.RaidGridOnEvent = RaidGridOnEvent

local function GridOnUpdate(self, elapsed)
    if self.onUpdateDelay ~= nil and self.onUpdateDelay > 0 then
        self.onUpdateDelay = self.onUpdateDelay - elapsed
        return
    end
    self.onUpdateDelay = 0.4
    if UnitExists(self.unit) then
        GW.GridUpdateAwayData(self, "RAID")
    end
end

local function GridToggleFramesPreviewRaid(moveHudMode, hudMoving)
    previewStep = max((previewStep + 1) % (#previewSteps + 1), hudMoving and 1 or 0)

    if previewStep == 0 or moveHudMode then
        for i = 1, MAX_RAID_MEMBERS do
            if _G["GwCompactRaidFrame" .. i] then
                _G["GwCompactRaidFrame" .. i].unit = "raid" .. i
                _G["GwCompactRaidFrame" .. i].guid = UnitGUID("raid" .. i)
                _G["GwCompactRaidFrame" .. i]:SetAttribute("unit", "raid" .. i)
                UnregisterStateDriver(_G["GwCompactRaidFrame" .. i], "visibility")
                RegisterStateDriver(_G["GwCompactRaidFrame" .. i], "visibility", ("[group:raid,@%s,exists] show; [group:party] hide; hide"):format(_G["GwCompactRaidFrame" .. i].unit))
                RaidGridOnEvent(_G["GwCompactRaidFrame" .. i], "load")
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
                RaidGridOnEvent(_G["GwCompactRaidFrame" .. i], "load")
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
    if not GwManageGroupButton then
        GW.manageButton()

        -- load missing and ignored auras, do it here because this code is only triggered from one of the 3 grids
        GW.UpdateGridSettings()
    end

    UpdateSettings()

    local container = CreateFrame("Frame", "GwRaidFrameContainer", UIParent, "GwRaidFrameContainer")
    local pos = GetSetting("raid_pos")
    container:ClearAllPoints()
    container:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)

    RegisterMovableFrame(container, RAID_FRAMES_LABEL, "raid_pos",  ALL .. ",Unitframe,Raid", nil, {"default", "default"})

    hooksecurefunc(container.gwMover, "StopMovingOrSizing", function(frame)
        if settings.raidAnchor == "GROWTH" then
            local g1, g2 = strsplit("+", settings.raidGrow)
            settings.raidAnchor = (IsIn("DOWN", g1, g2) and "TOP" or "BOTTOM") .. (IsIn("RIGHT", g1, g2) and "LEFT" or "RIGHT")
        end

        if settings.raidAnchor ~= "POSITION" then
            local x = settings.raidAnchor:sub(-5) == "RIGHT" and frame:GetRight() - GetScreenWidth() or settings.raidAnchor:sub(-4) == "LEFT" and frame:GetLeft() or frame:GetLeft() + (frame:GetWidth() - GetScreenWidth()) / 2
            local y = settings.raidAnchor:sub(1, 3) == "TOP" and frame:GetTop() - GetScreenHeight() or settings.raidAnchor:sub(1, 6) == "BOTTOM" and frame:GetBottom() or frame:GetBottom() + (frame:GetHeight() - GetScreenHeight()) / 2

            frame:ClearAllPoints()
            frame:SetPoint(settings.raidAnchor, x, y)
        end

        if not InCombatLockdown() then
            container:ClearAllPoints()
            container:SetPoint(frame:GetPoint())
        end
    end)

    for i = 1, MAX_RAID_MEMBERS do
        GW.CreateGridFrame(i, container, RaidGridOnEvent, GridOnUpdate, "RAID")
    end

    GridRaidUpdateFramesPosition()
    GridRaidUpdateFramesLayout()

    GwSettingsWindowMoveHud:HookScript("OnClick", function ()
        GW.GridToggleFramesPreviewRaid(true, true)
        GW.GridToggleFramesPreviewParty(true, true)
    end)
    GwSmallSettingsContainer.moverSettingsFrame.defaultButtons.lockHud:HookScript("OnClick", function()
        GW.GridToggleFramesPreviewRaid(true, true)
        GW.GridToggleFramesPreviewParty(true, true)
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
            GW.GridUpdateFrameData(_G["GwCompactRaidFrame" .. i], i, "RAID")
        end
    end)
end
GW.LoadRaidFrames = LoadRaidFrames
