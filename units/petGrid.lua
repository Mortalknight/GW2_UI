local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local IsIn = GW.IsIn
local RegisterMovableFrame = GW.RegisterMovableFrame

local players
local previewSteps = {40, 20, 10, 5}
local previewStep = 0

local function GetRaidPetFramesMeasures(players)
    -- Get settings
    local grow = GetSetting("RAID_GROW_PET")
    local w = GetSetting("RAID_WIDTH_PET")
    local h = GetSetting("RAID_HEIGHT_PET")
    local cW = GetSetting("RAID_CONT_WIDTH_PET")
    local cH = GetSetting("RAID_CONT_HEIGHT_PET")
    local per = ceil(GetSetting("RAID_UNITS_PER_COLUMN_PET"))
    local m = 2

    -- Determine # of players
    if players then
        players = players or max(1, GetNumGroupMembers())
    else
        players = 0
        for i = 1, MAX_RAID_MEMBERS do
            local _, _, grp = GetRaidRosterInfo(i)
            if grp >= ceil(players / MEMBERS_PER_RAID_GROUP) and UnitExists(_G["GwCompactRaidPetFrame" .. i].unit) then
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

local function PositionRaidPetFrame(frame, parent, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
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

local function GridRaidPetUpdateFramesPosition()
    if not GwRaidFramePetContainer then return end
    players = previewStep == 0 and 40 or previewSteps[previewStep]

    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GetRaidPetFramesMeasures(players)
    local isV = grow1 == "DOWN" or grow1 == "UP"

    -- Update size
    GwRaidFramePetContainer.gwMover:SetSize(isV and size2 or size1, isV and size1 or size2)

    -- Update unit frames
    local counter = 1
    for i = 1, MAX_RAID_MEMBERS do
        if UnitExists(_G["GwCompactRaidPetFrame" .. i].unit) then
            PositionRaidPetFrame(_G["GwCompactRaidPetFrame" .. i], GwRaidFramePetContainer.gwMover, counter, grow1, grow2, cells1, sizePer1, sizePer2, m)
            counter = counter + 1
        end
        if i > players then _G["GwCompactRaidPetFrame" .. i]:Hide() else _G["GwCompactRaidPetFrame" .. i]:Show() end
    end
end
GW.GridRaidPetUpdateFramesPosition = GridRaidPetUpdateFramesPosition

local function GridRaidPetUpdateFramesLayout()
    if not GwRaidFramePetContainer then return end
    -- Get directions, rows, cols and sizing
    local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GetRaidPetFramesMeasures(IsInRaid() and max(1, GetNumGroupMembers()) or previewStep == 0 and 40 or previewSteps[previewStep])
    local isV = grow1 == "DOWN" or grow1 == "UP"

    if not InCombatLockdown() then
        GwRaidFramePetContainer:SetSize(isV and size2 or size1, isV and size1 or size2)
    end

    -- Position
    local  counter = 1
    for i = 1, MAX_RAID_MEMBERS do
        if UnitExists(_G["GwCompactRaidPetFrame" .. i].unit) then
            PositionRaidPetFrame(_G["GwCompactRaidPetFrame" .. i], GwRaidFramePetContainer, counter, grow1, grow2, cells1, sizePer1, sizePer2, m)
            counter = counter + 1
        end
    end
end
GW.GridRaidPetUpdateFramesLayout = GridRaidPetUpdateFramesLayout

local function PetGridOnEvent(self, event, unit)
    if not UnitExists(self.unit) then
        return
    elseif not self.nameNotLoaded then
        GW.GridSetUnitName(self, "RAID_PET")
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

    if event == "load" or event == "UNIT_PET" then
        GW.GridSetAbsorbAmount(self)
        GW.GridSetPredictionAmount(self, "RAID_PET")
        GW.GridSetHealth(self, "RAID_PET")
        GW.GridUpdateAwayData(self, "RAID_PET")
        GW.GridUpdateAuras(self, "RAID_PET")
        GW.GridUpdatePower(self)
        if event == "UNIT_PET" then
            if InCombatLockdown() then
                self:RegisterEvent("PLAYER_REGEN_ENABLED")
            end
            GW.GridRaidPetUpdateFramesLayout()
            for i = 1, MAX_RAID_MEMBERS do
                GW.GridUpdateFrameData(_G["GwCompactRaidPetFrame" .. i], i, "RAID_PET")
            end
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
        GW.GridRaidPetUpdateFramesLayout()
        for i = 1, MAX_RAID_MEMBERS do
            GW.GridUpdateFrameData(_G["GwCompactRaidPetFrame" .. i], i, "RAID_PET")
        end
    elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
        GW.GridSetHealth(self, "RAID_PET")
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        --GW.GridUpdatePower(self)
    elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        GW.GridSetAbsorbAmount(self)
    elseif event == "UNIT_HEAL_PREDICTION" then
        GW.GridSetPredictionAmount(self, "RAID_PET")
    elseif event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" or event == "UNIT_THREAT_SITUATION_UPDATE" then
        GW.GridUpdateAwayData(self, "RAID_PET")
    elseif event == "PLAYER_TARGET_CHANGED" then
        GW.GridHighlightTargetFrame(self)
    elseif event == "UNIT_NAME_UPDATE" then
        GW.GridSetUnitName(self, "RAID_PET")
    elseif event == "UNIT_AURA" then
        GW.GridUpdateAuras(self, "RAID_PET")
    elseif event == "PLAYER_ENTERING_WORLD" then
        RequestRaidInfo()
    elseif event == "UPDATE_INSTANCE_INFO" then
        GW.GridUpdateAuras(self, "RAID_PET")
        GW.GridUpdateAwayData(self, "RAID_PET")
    elseif (event == "INCOMING_RESURRECT_CHANGED" or event == "INCOMING_SUMMON_CHANGED") and unit == self.unit then
        GW.GridUpdateAwayData(self, "RAID_PET")
    elseif event == "RAID_TARGET_UPDATE" and GetSetting("RAID_UNIT_MARKERS_PET") then
        GW.GridUpdateRaidMarkers(self, "RAID_PET")
    end
end
GW.PetGridOnEvent = PetGridOnEvent

local function GridOnUpdate(self, elapsed)
    if self.onUpdateDelay ~= nil and self.onUpdateDelay > 0 then
        self.onUpdateDelay = self.onUpdateDelay - elapsed
        return
    end
    self.onUpdateDelay = 0.2
    if UnitExists(self.unit) then
        GW.GridUpdateAwayData(self, "RAID_PET")
    end
end

local function GridToggleFramesPreviewRaidPet(_, _, moveHudMode, hudMoving)
    previewStep = max((previewStep + 1) % (#previewSteps + 1), hudMoving and 1 or 0)

    if previewStep == 0 or moveHudMode then
        for i = 1, MAX_RAID_MEMBERS do
            if _G["GwCompactRaidPetFrame" .. i] then
                _G["GwCompactRaidPetFrame" .. i].unit = "raidpet" .. i
                _G["GwCompactRaidPetFrame" .. i].guid = UnitGUID("raidpet" .. i)
                _G["GwCompactRaidPetFrame" .. i]:SetAttribute("unit",  "raidpet" .. i)
                UnregisterStateDriver(_G["GwCompactRaidPetFrame" .. i], "visibility")
                RegisterStateDriver(_G["GwCompactRaidPetFrame" .. i], "visibility", ("[group:raid,@%s,exists] show; [group:GetRaidPetFramesMeasures] hide; hide"):format(_G["GwCompactRaidPetFrame" .. i].unit))
                GW.PetGridOnEvent(_G["GwCompactRaidPetFrame" .. i], "load")
            end
        end
    else
        for i = 1, MAX_RAID_MEMBERS do
            if _G["GwCompactRaidPetFrame" .. i] then
                _G["GwCompactRaidPetFrame" .. i].unit = "player"
                _G["GwCompactRaidPetFrame" .. i].guid = UnitGUID("player")
                _G["GwCompactRaidPetFrame" .. i]:SetAttribute("unit", "player")
                UnregisterStateDriver(_G["GwCompactRaidPetFrame" .. i], "visibility")
                RegisterStateDriver(_G["GwCompactRaidPetFrame" .. i], "visibility", ("%s"):format((i > previewSteps[previewStep] and "hide" or "show")))
                GW.PetGridOnEvent(_G["GwCompactRaidPetFrame" .. i], "load")
            end
        end
        GridRaidPetUpdateFramesPosition()
    end
    GwSettingsRaidPetPanel.buttonRaidPreview:SetText((previewStep == 0 or moveHudMode) and "-" or previewSteps[previewStep])
    if previewStep == 0 or moveHudMode then
        GridRaidPetUpdateFramesLayout()
    end
end
GW.GridToggleFramesPreviewRaidPet = GridToggleFramesPreviewRaidPet

local function LoadPetGrid()
    if not GetSetting("RAID_PET_FRAMES") then
        return
    end

    if not _G.GwManageGroupButton then
        GW.manageButton()
    end

    local container = CreateFrame("Frame", "GwRaidFramePetContainer", UIParent, "GwRaidFrameContainer")

    local pos = GetSetting("raid_pet_pos")
    container:ClearAllPoints()
    container:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)

    RegisterMovableFrame(container, L["Raid pet's Grid"], "raid_pet_pos", "VerticalActionBarDummy", nil, true, {"default", "default"})

    hooksecurefunc(container.gwMover, "StopMovingOrSizing", function(frame)
        local anchor = GetSetting("RAID_ANCHOR_PET")

        if anchor == "GROWTH" then
            local g1, g2 = strsplit("+", GetSetting("RAID_GROW_PET"))
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

    -- create and position frame at start
    local grow1, grow2, cells1, _, size1, size2, _, _, sizePer1, sizePer2, m = GetRaidPetFramesMeasures(40)
    local isV = grow1 == "DOWN" or grow1 == "UP"

    container:SetSize(isV and size2 or size1, isV and size1 or size2)
    container.gwMover:SetSize(isV and size2 or size1, isV and size1 or size2)
    for i = 1, MAX_RAID_MEMBERS do
        GW.CreateGridFrame(i, container, PetGridOnEvent, GridOnUpdate, "RAID_PET")
        PositionRaidPetFrame(_G["GwCompactRaidPetFrame" .. i], container, i, grow1, grow2, cells1, sizePer1, sizePer2, m)
    end

    GridRaidPetUpdateFramesPosition()
    GridRaidPetUpdateFramesLayout()

    container:RegisterEvent("RAID_ROSTER_UPDATE")
    container:RegisterEvent("GROUP_ROSTER_UPDATE")
    container:RegisterEvent("PLAYER_ENTERING_WORLD")

    container:SetScript("OnEvent", function(self, event)
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
        if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end

        GridRaidPetUpdateFramesLayout()

        for i = 1, MAX_RAID_MEMBERS do
            GW.GridUpdateFrameData(_G["GwCompactRaidPetFrame" .. i], i, "RAID_PET")
        end
    end)
end
GW.LoadPetGrid = LoadPetGrid