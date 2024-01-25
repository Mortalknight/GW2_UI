local _, GW = ...
local addChange = GW.addChange

local ct = {
  bug=1,
  feature=2,
  change=3,
}

GW.CHANGELOGS_TYPES = ct

addChange("3.0.0",{
    {ct.change,[=[Update settings widows]=]},
})