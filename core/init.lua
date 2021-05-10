local addonName, GW = ...

-- init: store API, to reduce the API usage

--Constants
local gameLocale = GetLocale()
GW.addonName = addonName:gsub("_", " ")
GW.mylocal = gameLocale == "enGB" and "enUS" or gameLocale
GW.NoOp = function() end
GW.addonName = addonName:gsub("_", " ")
GW.myfaction, GW.myLocalizedFaction = UnitFactionGroup("player")
GW.myLocalizedClass, GW.myclass, GW.myClassID = UnitClass("player")
GW.myLocalizedRace, GW.myrace = UnitRace("player")
GW.myname = UnitName("player")
GW.myrealm = GetRealmName()
GW.mysex = UnitSex("player")
GW.mylevel = UnitLevel("player")
GW.screenwidth, GW.screenHeight = GetPhysicalScreenSize()
GW.resolution = format("%dx%d", GW.screenwidth, GW.screenHeight)
GW.wowpatch, GW.wowbuild = GetBuildInfo()
GW.wowbuild = tonumber(GW.wowbuild)
GW.Gw2Color = "|cffffedba" -- Color used for chat prints or buttons

--Tables
GW.skins = {}
GW.TexCoords = {0, 1, 0, 1}
GW.locationData = {}
GW.animations = {}
GW.HiddenFrame = CreateFrame("Frame")
GW.HiddenFrame:Hide()

-- Init global function
GW.InitLocationDataHandler()

--register libs
do
    GW.Libs = {}
    local function AddLib(name, libname, silent)
        if not name then return end
        GW.Libs[name] = _G.LibStub(libname, silent)
    end

    AddLib("LHC", "LibHealComm-4.0", true)
    AddLib("Compress", "LibCompress", true)
    AddLib("Serializer", "AceSerializer-3.0", true)
    AddLib("LibBase64", "LibBase64-1.0", true)
end