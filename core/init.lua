local _, GW = ...

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
GW.HiddenFrame = CreateFrame("Frame")
GW.HiddenFrame:Hide()

--register libs
do
    GW.Libs = {}
    local function AddLib(name, libname, silent)
        if not name then return end
        GW.Libs[name] = _G.LibStub(libname, silent)
    end

    AddLib("LCD", "LibClassicDurations", true)
    AddLib("LCC", "LibClassicCasterino", true)
    AddLib("LHC", "LibHealComm-4.0", true)
    if GW.Libs.LCD then
        GW.Libs.LCD:Register("GW2_UI")
    end
end