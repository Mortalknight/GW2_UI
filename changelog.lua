local _, GW = ...
local addChange = GW.addChange

local ct = {
  bug=1,
  feature=2,
  change=3,
}

addChange("3.3.0",{
  {ct.feature,[=[Added Talent Preview toggle]=]},
})

addChange("3.2.0",{
  {ct.feature,[=[Added SoD dual spec support]=]},
})

addChange("3.1.1",{
  {ct.bug,[=[Fix details profile]=]},
})

addChange("3.1.0",{
  {ct.feature,[=[Added Actionbutton masque skin]=]},
  {ct.change,[=[Portover chatframe changes]=]},
  {ct.bug,[=[Fix some bugs]=]},
})

addChange("3.0.1",{
  {ct.bug,[=[Fix target frame level color]=]},
  {ct.bug,[=[Fix targetframe combopoints]=]},
  {ct.bug,[=[Fix MP5 bar]=]},
})

addChange("3.0.0",{
    {ct.change,[=[Portover from retail]=]},
})