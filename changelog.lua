local _, GW = ...
local addChange = GW.addChange

local ct = {
  bug=1,
  feature=2,
  change=3,
}
GW.CHANGELOGS_TYPES = ct

addChange("1.7.2",{
    {ct.bug ,[=[ Extended Vendor setting is working again]=]},
})

addChange("1.7.1",{
    {ct.bug ,[=[Hover binding settings menu is working again]=]},
    {ct.bug ,[=[Move HUD saves the positions again]=]},
    {ct.change ,[=[Better integration with addon tooltips]=]},
})

addChange("1.7.0",{
    {ct.change ,[=[Update database]=]},
})

addChange("1.6.1",{
    {ct.bug,[=[Pet talents can not be set again]=]},
})

addChange("1.6.0",{
    {ct.feature,[=[Added Gem info to hero panel]=]},
    {ct.feature,[=[Added back ilvl to targetframes and tooltip (hold shift)]=]},
    {ct.feature,[=[Add vehicle mover]=]},
    {ct.feature,[=[Add minimap widget mover]=]},
    {ct.feature,[=[Some lua errors]=]},
})

addChange("1.5.0",{
    {ct.feature, [=[Redo all grids: Party, Raid, Raid Pet]=]},
    {ct.feature, [=[Grids are now secure and can update during combat]=]},
    {ct.feature, [=[Added new grids:
        - Maintank
        - Raid 10
        - Raid 25
        - Raid 40]=]},
    {ct.feature, [=[Raid grids switch automaticly between the 3 raid grids, based on the number of players at the raid]=]},
    {ct.feature, [=[Added new grouping and sorting settings to all grids:
        - Group by: Role, Class, Group, Name, Index
        - Sort direction
        - Sortmethode: Name, Index
        - Raidwaid sorting: If disabled the grouping and sorting settings are applyed per raid group]=]},
    {ct.feature, [=[All grids have there individual settings (Raid 10, Raid 25, Raid 40, Maintank, Raid Pet, Group)]=]},

    {ct.change, [=[Remove Keyring]=]},

    {ct.bug, [=[Combopoints on target works again]=]},
})

addChange("1.4.3",{
    {ct.bug,[=[Only force update quest tracker header if tracker is loaded]=]},
})

addChange("1.4.2",{
    {ct.bug,[=[Fix grid aura indicator frame layer]=]},
    {ct.bug,[=[Fix wrong setting api]=]},
})

addChange("1.4.1",{
    {ct.bug,[=[Quest tracker fixes]=]},
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
