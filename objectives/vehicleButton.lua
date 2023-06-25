local _, GW = ...
local GetSetting = GW.GetSetting

local function SetPosition(_ ,_, relativeTo)
    local mover = VehicleSeatIndicator.gwMover
    if mover and relativeTo ~= mover then
        VehicleSeatIndicator:ClearAllPoints()
        VehicleSeatIndicator:SetPoint("TOPLEFT", mover)
    end
end

local function LoadVehicleButton()
    if not VehicleSeatIndicator.PositionVehicleFrameHooked then
        hooksecurefunc(VehicleSeatIndicator, "SetPoint", SetPosition)

        VehicleSeatIndicator:ClearAllPoints()
        VehicleSeatIndicator:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", 0, 0)

        GW.RegisterMovableFrame(VehicleSeatIndicator, BINDING_HEADER_VEHICLE, "VEHICLE_SEAT_POS", ALL .. ",Blizzard", nil, {"default", "scaleable"})
        VehicleSeatIndicator.PositionVehicleFrameHooked = true
    end
--[[
    if GetSetting("ACTIONBARS_ENABLED") then
        VehicleSeatIndicator_UnloadTextures = function()
            VehicleSeatIndicatorBackgroundTexture:SetTexture()
            VehicleSeatIndicator:Hide()
            VehicleSeatIndicator.currSkin = nil

            DurabilityFrame:SetAlerts()
       end
    end
    ]]
end
GW.LoadVehicleButton = LoadVehicleButton