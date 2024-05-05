local _, GW = ...
local addChange = GW.addChange

local ct = {
  bug=1,
  feature=2,
  change=3,
}

GW.CHANGELOGS_TYPES = ct


addChange("1.1.0",{
    {ct.feature,[=[Added eclipse bar]=]},
    {ct.feature,[=[Added shadow orbs]=]},
    {ct.bug,[=[Fix Pawn integration]=]},
    {ct.change,[=[Update party and grid frames]=]},
})

addChange("1.0.1",{
    {ct.change,[=[First round of fixes]=]},
})

addChange("1.0.0",{
    {ct.change,[=[Init version]=]},
})
