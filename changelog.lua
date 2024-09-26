local _, GW = ...
local addChange = GW.addChange

local ct = {
    bug=1,
    feature=2,
    change=3,
}
GW.CHANGELOGS_TYPES = ct

addChange("3.3.9",{
    {ct.change,[=[Update for 1.15.4]=]},
})

addChange("3.3.8",{
    {ct.change,[=[Update for 1.15.4]=]},
})

addChange("3.3.7",{
    {ct.change,[=[Bagnator support]=]},
})

addChange("3.3.6",{
    {ct.change,[=[Fix for Blizzards QuestTimer change]=]},
})
addChange("3.3.5",{
    {ct.change,[=[Bagnator support]=]},
})

addChange("3.3.4",{
    {ct.change,[=[Fix for 1.15.3]=]},
})

addChange("3.3.3",{
    {ct.bug,[=[Added a new spellbook container]=]},
})

addChange("3.3.2",{
    {ct.bug,[=[Fix target frame and tooltip inspection errors]=]},
})

addChange("3.3.1",{
    {ct.bug,[=[Fix lua error on load]=]},
})

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