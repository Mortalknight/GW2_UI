local _, GW = ...
local Debug = GW.Debug

    -- init: store API, to reduce the API usage
    GW.myfaction, GW.myLocalizedFaction = UnitFactionGroup("player")
    GW.myLocalizedClass, GW.myclass, GW.myClassID = UnitClass("player")
    GW.myLocalizedRace, GW.myrace = UnitRace("player")
    GW.myname = UnitName("player")
    GW.myrealm = GetRealmName()
    GW.mysex = UnitSex("player")
    GW.mylevel = UnitLevel("player")
    GW.mylocal = GetLocale()
    