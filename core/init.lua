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
GW.MOVABLE_FRAMES = {}
GW.scaleableFrames = {}
GW.scaleableMainHudFrames = {}
GW.animations = {}
GW.trackedQuests = {}

GW.HiddenFrame = CreateFrame("Frame")
GW.HiddenFrame.HiddenString = GW.HiddenFrame:CreateFontString(nil, "OVERLAY")
GW.HiddenFrame:Hide()
GW.BorderSize = 1
GW.SpacingSize = 1

-- money
GW.earnedMoney = 0
GW.spentMoney = 0

-- Init global function
GW.InitLocationDataHandler()

-- Init error handler
GW.RegisterErrorHandler()

--register libs
do
    GW.Libs = {}
    local function AddLib(name, libname, silent)
        if not name then return end
        GW.Libs[name] = _G.LibStub(libname, silent)
    end

    AddLib("LSM", "LibSharedMedia-3.0", true)
    AddLib("Compress", "LibCompress", true)
    AddLib("Serializer", "AceSerializer-3.0", true)
    AddLib("LibBase64", "LibBase64-1.0", true)
    AddLib("AceLocale", "AceLocale-3.0", true)
end

-- Locale doesn't exist yet, make it exist
GW.L = GW.Libs.AceLocale:GetLocale("GW2_UI")


--Add Shared Media
--Font
GW.Libs.LSM:Register("font", "GW2_UI", "Interface/AddOns/GW2_UI/fonts/menomonia.ttf", GW.Libs.LSM.LOCALE_BIT_western + GW.Libs.LSM.LOCALE_BIT_ruRU)
GW.Libs.LSM:Register("font", "GW2_UI Light", "Interface/AddOns/GW2_UI/fonts/menomonia-italic.ttf", GW.Libs.LSM.LOCALE_BIT_western + GW.Libs.LSM.LOCALE_BIT_ruRU)
GW.Libs.LSM:Register("font", "GW2_UI Headlines", "Interface/AddOns/GW2_UI/fonts/headlines.ttf", GW.Libs.LSM.LOCALE_BIT_western + GW.Libs.LSM.LOCALE_BIT_ruRU)
GW.Libs.LSM:Register("font", "GW2_UI", "Interface/AddOns/GW2_UI/fonts/chinese-font.ttf", GW.Libs.LSM.LOCALE_BIT_zhCN + GW.Libs.LSM.LOCALE_BIT_zhTW)
GW.Libs.LSM:Register("font", "GW2_UI", "Interface/AddOns/GW2_UI/fonts/korean.ttf", GW.Libs.LSM.LOCALE_BIT_koKR)
GW.Libs.LSM:Register("font", "GW2_UI_Chat", "Interface/AddOns/GW2_UI/fonts/trebuchet_ms.ttf", GW.Libs.LSM.LOCALE_BIT_western + GW.Libs.LSM.LOCALE_BIT_ruRU)
GW.Libs.LSM:Register("font", "GW2_UI_Chat", "Interface/AddOns/GW2_UI/fonts/chinese-font.ttf", GW.Libs.LSM.LOCALE_BIT_zhCN + GW.Libs.LSM.LOCALE_BIT_zhTW)
GW.Libs.LSM:Register("font", "GW2_UI_Chat", "Interface/AddOns/GW2_UI/fonts/korean.ttf", GW.Libs.LSM.LOCALE_BIT_koKR)

--Texture
GW.Libs.LSM:Register("background", "GW2_UI_White", "Interface/AddOns/GW2_UI/Textures/ChatBubble-Background.tga")
GW.Libs.LSM:Register("background", "GW2_UI", "Interface/Addons/GW2_UI/Textures/UI-Tooltip-Background.tga")
GW.Libs.LSM:Register("statusbar", "GW2_UI_Yellow", "Interface/Addons/GW2_UI/Textures/castingbar.tga")
GW.Libs.LSM:Register("statusbar", "GW2_UI_Blue", "Interface/Addons/GW2_UI/Textures/breathmeter.tga")
GW.Libs.LSM:Register("statusbar", "GW2_UI", "Interface/Addons/GW2_UI/Textures/castinbar-white.tga")
GW.Libs.LSM:Register("statusbar", "GW2_UI_Details", "Interface/Addons/GW2_UI/textures/addonSkins/details_statusbar")

--Sound
GW.Libs.LSM:Register("sound", "GW2_UI: Close", "Interface/AddOns/GW2_UI/sounds/dialog_close.ogg")
GW.Libs.LSM:Register("sound", "GW2_UI: Open", "Interface/AddOns/GW2_UI/sounds/dialog_open.ogg")
GW.Libs.LSM:Register("sound", "GW2_UI: Ping", "Interface/AddOns/GW2_UI/sounds/exp_gain_ping.ogg")