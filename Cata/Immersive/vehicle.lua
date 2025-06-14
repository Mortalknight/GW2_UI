local _, GW = ...

local function SetPosition(_, _, relativeTo)
    local mover = VehicleSeatIndicator.gwMover
    if mover and relativeTo ~= mover then
        VehicleSeatIndicator:ClearAllPoints()
        VehicleSeatIndicator:SetPoint("TOPLEFT", mover)
    end
end
local function VehicleSetUp(self)
    local size = 128
    VehicleSeatIndicator:SetSize(size, size)

    if not self then return end -- this is vehicleIndicatorID

    local _, numIndicators = GetVehicleUIIndicator(self)
    if numIndicators then
        local fourth = size * 0.25

        for i = 1, numIndicators do
            local button = _G["VehicleSeatIndicatorButton"..i]

            if button then
                local _, x, y = GetVehicleUIIndicatorSeat(self, i)
                button:ClearAllPoints()
                button:SetPoint("CENTER", button:GetParent(), "TOPLEFT", x * size, -y * size)
                button:SetSize(fourth, fourth)
            end
        end
    end
end

local function UpdateVehicleFrame()
    VehicleSetUp(_G.VehicleSeatIndicator.currSkin)
end

local function SetUpVehicleFrameMover()
    if not VehicleSeatIndicator.PositionVehicleFrameHooked then
        hooksecurefunc(VehicleSeatIndicator, "SetPoint", SetPosition)
        hooksecurefunc("VehicleSeatIndicator_SetUpVehicle", VehicleSetUp)

        VehicleSeatIndicator:ClearAllPoints()
        VehicleSeatIndicator:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", 0, 0)

        GW.RegisterMovableFrame(VehicleSeatIndicator, BINDING_HEADER_VEHICLE, "VEHICLE_SEAT_POS", "VerticalActionBarDummy", nil, {"default", "scaleable"})
        VehicleSeatIndicator.PositionVehicleFrameHooked = true
    end

    UpdateVehicleFrame()
end
GW.SetUpVehicleFrameMover = SetUpVehicleFrameMover