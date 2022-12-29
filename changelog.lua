local _, GW = ...
local addChange = GW.addChange

local ct = {
  bug=1,
  feature=2,
  change=3,
}
GW.CHANGELOGS_TYPES = ct
--[[
AddChange(string addonVersion, table changeList)
  {
   GW_CHANGELOGS_TYPES fixType // bugfix, feature
   string description
  }
]]
addChange("6.1.1",{
  {ct.change,[=[Aura Indicator updates:

- Evoker:
     Added Dream Breath (echo)
     Added Reversion (echo)
     Added Life Bind]=]},
  {ct.change,[=[Update Talent Micro Button tooltip]=]},

  {ct.bug,[=[Fix game freezes with scenario tracker]=]},
  {ct.bug,[=[Fix actionbar taint on spec switch]=]},
  {ct.bug,[=[Fix HUD background setting]=]},
  {ct.bug,[=[Fix HUD border setting]=]},
  {ct.bug,[=[Fix tooltip hide in combat setting]=]},
  {ct.bug,[=[Fix tooltip healtbar setting]=]},
})
addChange("6.1.0",{
    {ct.feature,[=[Added brand new settings page]=]},
    {ct.feature,[=[Added Community Feast and Siege On Dragonbane Keep timer to worldmap]=]},
    {ct.feature,[=[Added option to set currencies to unused]=]},
    {ct.feature,[=[Added option to collapse all objective trackers in Mythic+]=]},
    {ct.feature,[=[Added evoker buff to raid buff reminder]=]},

    {ct.change,[=[Aura Indicator updates:

- Resto Druid:
       Added Tranquility
       Added Adaptive Swarm

- Priest:
      Added Power Infusion

- Holy Pally:
       Added Barrier of Faith]=]},
    {ct.change,[=[Social panel skin has been fixed has been readded]=]},
    {ct.change,[=[Update Raid Debuff Filter and cleanded up Mythic+ Affixes]=]},
    {ct.change,[=[Update some raid buff reminder spells]=]},

    {ct.bug,[=[Fix for auto sell taint error]=]},
    {ct.bug,[=[Temp fix for extra actionbutton taint]=]},
    {ct.bug,[=[Memory and performance improvements]=]},
})
addChange("6.0.10",{
{ct.bug,[=[Error on start]=]},
})
addChange("6.0.9",{
{ct.bug,[=[Restored mirror timers]=]},
})
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