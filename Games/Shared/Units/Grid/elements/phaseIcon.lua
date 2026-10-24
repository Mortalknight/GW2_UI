---@class GW2
local GW = select(2, ...)

-- in the middle like blizzards raid frames, the middle icon steps aside while the unit is phased
local function PostUpdate(element, phaseReason)
    local frame = element.__owner
    frame.phaseInProgress = phaseReason ~= nil
    if frame.MiddleIcon and frame:IsElementEnabled("MiddleIcon") then
        frame.MiddleIcon:ForceUpdate()
    end
end

local function Construct_PhaseIcon(frame)
    local phaseIcon = frame.RaisedElementParent.TextureParent:CreateTexture(nil, "ARTWORK")
    phaseIcon:SetSize(25, 25)
    phaseIcon:SetPoint("CENTER", frame, "CENTER")
    phaseIcon.PostUpdate = PostUpdate

    return phaseIcon
end
GW.Construct_PhaseIcon = Construct_PhaseIcon
