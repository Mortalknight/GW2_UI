local _, GW = ...

local function SetPosition(_ ,_, anchor)
    if anchor == "MinimapCluster" or anchor == MinimapCluster then
        _G.VehicleSeatIndicator:ClearAllPoints()
        _G.VehicleSeatIndicator:SetPoint("TOPLEFT", VehicleSeatIndicator.gwMover)
    end
end

local function LoadVehicleButton()
    if not VehicleSeatIndicator.PositionVehicleFrameHooked then
        hooksecurefunc(VehicleSeatIndicator, "SetPoint", SetPosition)

        VehicleSeatIndicator:ClearAllPoints()
 		VehicleSeatIndicator:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", 0, 0)

        GW.RegisterMovableFrame(VehicleSeatIndicator, BINDING_HEADER_VEHICLE, "VEHICLE_SEAT_POS", "VerticalActionBarDummy", nil, {"default", "scaleable"})
        VehicleSeatIndicator.PositionVehicleFrameHooked = true
    end
end
GW.LoadVehicleButton = LoadVehicleButton