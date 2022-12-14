local _, GW = ...
local addChange = GW.addChange

local ct = {
  bug=1,
  feature=2,
}
GW.CHANGELOGS_TYPES = ct
--[[
AddChange(string addonVersion, table changeList)
  {
   GW_CHANGELOGS_TYPES fixType // bugfix, feature
   string description
  }
]]

addChange("6.0.8",{
  {ct.bug,[=[Fix for memory leak]=]},
})
addChange("6.0.7",{
  {ct.bug,[=[Error on start]=]},
})
addChange("6.0.6",{
  {ct.bug,[=[Bank issues]=]},
  {ct.bug,[=[Error on start]=]}
})
addChange("6.0.5",{
  {ct.bug,[=[Minimap lua error]=]},
  {ct.bug,[=[Bag taint]=]}
})
addChange("6.0.4",{
  {ct.bug,[=[Fix some more taint issues]=]}
})
addChange("6.0.3",{
  {ct.bug,[=[Wrong GW2 moverframe value]=]}
})
addChange("6.0.2",{
  {ct.bug,[=[Set actionbar 1 to always have 12 buttons]=]},
  {ct.bug,[=[Actionbar taint on shapshift forms]=]}
})
addChange("6.0.1",{
  {ct.bug,[=[Fix lua error on login]=]}
})
addChange("6.0.0",{
  {ct.feature,[=[Update for 10.0.2]=]}
})
