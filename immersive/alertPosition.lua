local _, GW = ...
local GetSetting = GW.GetSetting

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -5

local function UpdateGroupLootContainer(self)
    local lastIdx = nil

    for i = 1, self.maxIndex do
        local frame = self.rollFrames[i]
        if frame then
            frame:ClearAllPoints()

            local prevFrame = self.rollFrames[i - 1]
            if prevFrame and prevFrame ~= frame then
                frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -5)
            else
                frame:SetPoint("TOP", GwAlertFrameOffsetter, "TOP", 0, -5)
            end
            lastIdx = i
        end
    end

    if lastIdx then
        self:SetHeight(self.reservedSize * lastIdx)
        self:Show()
    else
        self:Hide()
    end
end
-- /run BonusRollFrame_StartBonusRoll(242969,'test',10,1220,1273,14)

local function RePostAlertFrame()
    local _, y = GW.AlertContainerFrame:GetCenter()
    local screenHeight = UIParent:GetTop()
    if y > (screenHeight / 2) then
        POSITION = "TOP"
        ANCHOR_POINT = "BOTTOM"
        YOFFSET = -5
    else
        POSITION = "BOTTOM"
        ANCHOR_POINT = "TOP"
        YOFFSET = 5
    end

    AlertFrame:ClearAllPoints()
    GroupLootContainer:ClearAllPoints()

    AlertFrame:SetAllPoints(GW.AlertContainerFrame)

    GroupLootContainer:SetPoint("TOP", GwAlertFrameOffsetter, "BOTTOM", 0, -5)
    if GroupLootContainer:IsShown() then
        UpdateGroupLootContainer(GroupLootContainer)
    end
end

local function AdjustQueuedAnchors(self, relativeAlert)
    for alertFrame in self.alertFramePool:EnumerateActive() do
        alertFrame:ClearAllPoints()
        alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
        relativeAlert = alertFrame
    end
    return relativeAlert
end

local function AdjustAnchors(self, relativeAlert)
    if self.alertFrame:IsShown() then
        self.alertFrame:ClearAllPoints()
        self.alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
        return self.alertFrame
    end
    return relativeAlert
end

local function AdjustAnchorsNonAlert(self, relativeAlert)
    if self.anchorFrame:IsShown() then
        self.anchorFrame:ClearAllPoints()
        self.anchorFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
        return self.anchorFrame
    end
    return relativeAlert
end

local function resetAlertSubSystemAdjustPositions(subSystem)
    if subSystem.alertFramePool then --queued alert system
        subSystem.AdjustAnchors = AdjustQueuedAnchors
    elseif not subSystem.anchorFrame then --simple alert system
        subSystem.AdjustAnchors = AdjustAnchors
    elseif subSystem.anchorFrame then --anchor frame system
        subSystem.AdjustAnchors = AdjustAnchorsNonAlert
    end
end

local function SetupAlertFramePosition()
    if not GetSetting("ALERTFRAME_ENABLED") then return end

    GwAlertFrameOffsetter:SetHeight(205)
    hooksecurefunc("GroupLootContainer_Update", UpdateGroupLootContainer)

    -- override anchor function
    for _, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
        resetAlertSubSystemAdjustPositions(alertFrameSubSystem)
    end

    -- Catch all added alert System by other addins
    hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(_, alertFrameSubSystem)
        resetAlertSubSystemAdjustPositions(alertFrameSubSystem)
    end)
    -- setup AlertFrame and Bonus Roll Frame
    hooksecurefunc(AlertFrame, "UpdateAnchors", RePostAlertFrame)
end
GW.SetupAlertFramePosition = SetupAlertFramePosition