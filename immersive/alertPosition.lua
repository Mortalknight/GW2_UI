local _, GW = ...

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -5

local function UpdateGroupLootContainer(self)
    local lastIdx = nil
    local pt, _, relPt, _, _ = self:GetPoint()

    for i = 1 , self.maxIndex do
        local frame = self.rollFrames[i]
        local prevFrame = self.rollFrames[i - 1]
        if frame then
            frame:ClearAllPoints()
            if prevFrame and not (prevFrame == frame) then
                frame:SetPoint(pt, prevFrame, relPt, 0, 0)
            else
                frame:SetPoint(pt, UIParent, relPt, 0, _G.GwAlertFrameOffsetter:GetHeight())
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
    AlertFrame:SetAllPoints(GW.AlertContainerFrame)
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

function AdjustAnchors(self, relativeAlert)
    if self.alertFrame:IsShown() then
        self.alertFrame:ClearAllPoints()
        self.alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
        return self.alertFrame
    end
    return relativeAlert
end

function AdjustAnchorsNonAlert(self, relativeAlert)
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
    _G.GwAlertFrameOffsetter:SetHeight(205)
    hooksecurefunc("GroupLootContainer_Update", UpdateGroupLootContainer)

    -- override anchor function
    for _, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
        resetAlertSubSystemAdjustPositions(alertFrameSubSystem)
    end

    -- Catch all added alert System by other addins
	hooksecurefunc(_G.AlertFrame, "AddAlertFrameSubSystem", function(_, alertFrameSubSystem)
		resetAlertSubSystemAdjustPositions(alertFrameSubSystem)
	end)
    -- setup AlertFrame and Bonus Roll Frame
    hooksecurefunc(_G.AlertFrame, "UpdateAnchors", RePostAlertFrame)
end
GW.SetupAlertFramePosition = SetupAlertFramePosition