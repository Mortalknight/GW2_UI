local _, GW = ...

local function MakeAltPowerBarMovable()
    GW.RegisterMovableFrame(PlayerPowerBarAlt, ALTERNATE_RESOURCE_TEXT, "AltPowerBar_pos", "VerticalActionBarDummy", {256, 64}, {"default", "scaleable"})

    --TODO
    PlayerPowerBarAlt:ClearAllPoints()
    PlayerPowerBarAlt:SetPoint("TOPLEFT", PlayerPowerBarAlt.gwMover)
    PlayerPowerBarAlt:SetMovable(true)
    PlayerPowerBarAlt:SetUserPlaced(true)

    hooksecurefunc(PlayerPowerBarAlt, "SetupPlayerPowerBarPosition", function()
        local _, anchorFrame = PlayerPowerBarAlt:GetPoint()
        if anchorFrame ~= PlayerPowerBarAlt.gwMover then
            PlayerPowerBarAlt:ClearAllPoints()
            PlayerPowerBarAlt:SetPoint("TOPLEFT", _G.PlayerPowerBarAlt.gwMover)
        end
    end)

end
GW.MakeAltPowerBarMovable = MakeAltPowerBarMovable
