local _, GW = ...

local function MakeAltPowerBarMovable()
    GW.RegisterMovableFrame(PlayerPowerBarAlt, ALTERNATE_RESOURCE_TEXT, "AltPowerBar_pos", ALL .. ",Blizzard,Widgets", {256, 64}, {"default", "scaleable"})

    PlayerPowerBarAlt:ClearAllPoints()
    PlayerPowerBarAlt:SetPoint("TOPLEFT", PlayerPowerBarAlt.gwMover)
    PlayerPowerBarAlt:SetMovable(true)
    PlayerPowerBarAlt:SetUserPlaced(true)

    hooksecurefunc(PlayerPowerBarAlt, "SetPoint", function(self, _, anchor)
        if self.gwMover and anchor ~= self.gwMover then
            PlayerPowerBarAlt:ClearAllPoints()
            PlayerPowerBarAlt:SetPoint("TOPLEFT", self.gwMover)
        end
    end)

end
GW.MakeAltPowerBarMovable = MakeAltPowerBarMovable
