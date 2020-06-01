local _, GW = ...
local Debug = GW.Debug

    -- init: store API, to reduce the API usage

    --Constants
    GW.NoOp = function() end
    GW.myfaction, GW.myLocalizedFaction = UnitFactionGroup("player")
    GW.myLocalizedClass, GW.myclass, GW.myClassID = UnitClass("player")
    GW.myLocalizedRace, GW.myrace = UnitRace("player")
    GW.myname = UnitName("player")
    GW.myrealm = GetRealmName()
    GW.mysex = UnitSex("player")
    GW.mylevel = UnitLevel("player")
    GW.mylocal = GetLocale()
    GW.screenwidth, GW.screenHeight = GetPhysicalScreenSize()
    GW.resolution = format("%dx%d", GW.screenwidth, GW.screenHeight)
    GW.wowpatch, GW.wowbuild = GetBuildInfo()
    GW.wowbuild = tonumber(GW.wowbuild)

    --Tables
    GW.skins = {}
    GW.TexCoords = {0, 1, 0, 1}