local _, GW = ...
local addChange = GW.addChange

local ct = {
  bug=1,
  feature=2,
  change=3,
}
GW.CHANGELOGS_TYPES = ct

addChange("1.4.1",{
    {ct.feature,[=[Quest tracker fixes]=]},
})

addChange("1.4.0",{
    {ct.feature,[=[Added option to show equipment set name on bag items (Thanks to Gaboros)]=]},
    {ct.change,[=[Update bag sorting (Thanks to Gaboros)]=]},
})

addChange("1.3.3",{
    {ct.bug,[=[ Fix quest tracker actionbutton]=]},
})

addChange("1.3.2",{
    {ct.change,[=[Update objectives tracker]=]},
})

addChange("1.3.1",{
    {ct.change,[=[Update advanced char stats]=]},
})

addChange("1.3.0",{
    {ct.feature,[=[Added warlock soulshards]=]},
    {ct.bug,[=[Fix inspection frame skin error]=]},
    {ct.change,[=[Update aura watch]=]},
    {ct.change,[=[Update ignored auras]=]},
})

addChange("1.2.0",{
    {ct.feature,[=[Added worldmarker keybindsr]=]},
    {ct.feature,[=[Added GW2 alert system]=]},
    {ct.feature,[=[Added back unitframe level coloring]=]},
    {ct.feature,[=[Added Inspect skin]=]},
    {ct.feature,[=[Added helper frame skin]=]},
    {ct.feature,[=[Added role icons back to grids]=]},
    {ct.bug,[=[Fix raidcontrol]=]},
    {ct.bug,[=[Fix raidcontrol]=]},
    {ct.bug,[=[Fix currency values]=]},
    {ct.bug,[=[Fix game menu settings button if game menu skin is disabled]=]},
    {ct.change,[=[Update tooltips]=]},
})

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
