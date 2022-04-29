local _, GW = ...

local function MakeAltPowerBarMovable()
    GW.RegisterMovableFrame(PlayerPowerBarAlt, ALTERNATE_RESOURCE_TEXT, "AltPowerBar_pos", "VerticalActionBarDummy", {256, 64}, {"default", "scaleable"})

    _G.PlayerPowerBarAlt:ClearAllPoints()
    _G.PlayerPowerBarAlt:SetPoint("TOPLEFT", _G.PlayerPowerBarAlt.gwMover)
    _G.PlayerPowerBarAlt:SetMovable(true)
    _G.PlayerPowerBarAlt:SetUserPlaced(true)
    _G.UIPARENT_MANAGED_FRAME_POSITIONS.PlayerPowerBarAlt = nil

end
GW.MakeAltPowerBarMovable = MakeAltPowerBarMovable
