local _, GW = ...

local function SetPosition(_ ,_, anchor)
    if anchor == "MinimapCluster" or anchor == _G.MinimapCluster then
        _G.VehicleSeatIndicator:ClearAllPoints()
        _G.VehicleSeatIndicator:SetPoint("TOPLEFT", _G.VehicleSeatIndicator.gwMover)
    end
end

local function LoadVehicleButton()
    if not _G.VehicleSeatIndicator.PositionVehicleFrameHooked then
        hooksecurefunc(VehicleSeatIndicator, "SetPoint", SetPosition)
        GW.RegisterMovableFrame(_G.VehicleSeatIndicator, BINDING_HEADER_VEHICLE, "VEHICLE_SEAT_POS", "VerticalActionBarDummy", nil, nil, {"default", "scaleable"})
        _G.VehicleSeatIndicator.PositionVehicleFrameHooked = true
    end
end
GW.LoadVehicleButton = LoadVehicleButton