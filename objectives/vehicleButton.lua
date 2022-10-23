local _, GW = ...

local function SetPosition(_ ,_, relativeTo)
    local mover = VehicleSeatIndicator.gwMover
    if mover and relativeTo ~= mover then
        VehicleSeatIndicator:ClearAllPoints()
        VehicleSeatIndicator:SetPoint("TOPLEFT", mover)
    end
end

local function LoadVehicleButton()
    if not VehicleSeatIndicator.PositionVehicleFrameHooked then
        VehicleSeatIndicator:ClearAllPoints()
        VehicleSeatIndicator:SetPoint("TOPRIGHT", nil, "BOTTOMRIGHT", 0, 0)

        hooksecurefunc(VehicleSeatIndicator, "SetPoint", SetPosition)

        GW.RegisterMovableFrame(VehicleSeatIndicator, BINDING_HEADER_VEHICLE, "VEHICLE_SEAT_POS", "VerticalActionBarDummy", nil, {"default", "scaleable"})
        VehicleSeatIndicator.PositionVehicleFrameHooked = true
    end
end
GW.LoadVehicleButton = LoadVehicleButton