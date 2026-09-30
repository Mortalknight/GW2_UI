---@class GW2
local GW = select(2, ...)

-- Alerts stack away from the screen edge their mover is closer to. Blizzard anchors them first,
-- we re-anchor afterwards instead of replacing the AdjustAnchors methods of its alert systems.

local GROW_DOWN = { point = "TOP", relativePoint = "BOTTOM", y = -5 }
local GROW_UP = { point = "BOTTOM", relativePoint = "TOP", y = 5 }
local growth = GROW_DOWN

local function PlaceNext(frame, relative)
    frame:ClearAllPoints()
    frame:SetPoint(growth.point, relative, growth.relativePoint, 0, growth.y)
    return frame
end

-- the three kinds of alert systems: a queue of pooled alerts, one alert frame or an anchor frame
local function StackSubSystem(subSystem, relative)
    if subSystem.alertFramePool then
        for alert in subSystem.alertFramePool:EnumerateActive() do
            relative = PlaceNext(alert, relative)
        end
        return relative
    end

    local frame = subSystem.anchorFrame or subSystem.alertFrame
    if frame and frame:IsShown() then
        return PlaceNext(frame, relative)
    end
    return relative
end

-- loot rolls hang below the offsetter, one under the other
local function StackLootRolls(container)
    local previous, lastIndex
    for index = 1, container.maxIndex do
        local frame = container.rollFrames[index]
        if frame and frame ~= previous then
            frame:ClearAllPoints()
            if previous then
                frame:SetPoint("TOP", previous, "BOTTOM", 0, -5)
            else
                frame:SetPoint("TOP", GwAlertFrameOffsetter, "TOP", 0, -5)
            end
            previous, lastIndex = frame, index
        end
    end

    if lastIndex then
        container:SetHeight(container.reservedSize * lastIndex)
        container:Show()
    else
        container:Hide()
    end
end

local function RestackAlerts()
    local _, centerY = GW.AlertContainerFrame:GetCenter()
    growth = centerY > UIParent:GetTop() / 2 and GROW_DOWN or GROW_UP

    AlertFrame:ClearAllPoints()
    AlertFrame:SetAllPoints(GW.AlertContainerFrame)
    local relative = AlertFrame
    for _, subSystem in ipairs(AlertFrame.alertFrameSubSystems) do
        relative = StackSubSystem(subSystem, relative)
    end

    GroupLootContainer:ClearAllPoints()
    GroupLootContainer:SetPoint("TOP", GwAlertFrameOffsetter, "BOTTOM", 0, -5)
    if GroupLootContainer:IsShown() then
        StackLootRolls(GroupLootContainer)
    end
end

local function SetupAlertFramePosition()
    if not GW.settings.notifications.enabled then return end

    GwAlertFrameOffsetter:SetHeight(205)
    hooksecurefunc("GroupLootContainer_Update", StackLootRolls)
    hooksecurefunc(AlertFrame, "UpdateAnchors", RestackAlerts)
end
GW.SetupAlertFramePosition = SetupAlertFramePosition
-- test a bonus roll: /run BonusRollFrame_StartBonusRoll(242969,'test',10,1220,1273,14)
