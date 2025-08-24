
local addonName, GW = ...

GW.VERSION_STRING = "GW2_UI @project-version@"

-- Make a global GW variable , so others cann access our functions
GW2_ADDON = GW

assert(GW.oUF, "GW2_UI was unable to locate oUF.")

do -- Expansions
    GW.Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
    GW.TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
    GW.Wrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
    GW.Cata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
    GW.Mists = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC
    GW.Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

    local season = C_Seasons and C_Seasons.GetActiveSeason()
    GW.ClassicHC = season == 3 -- Hardcore
    GW.ClassicSOD = season == 2 -- Season of Discovery
    GW.ClassicAnniv = season == 11 -- Anniversary
    GW.ClassicAnnivHC = season == 12 -- Anniversary Hardcore

    local IsHardcoreActive = C_GameRules and C_GameRules.IsHardcoreActive
    GW.IsHardcoreActive = IsHardcoreActive and IsHardcoreActive()

    local IsEngravingEnabled = C_Engraving and C_Engraving.IsEngravingEnabled
    GW.IsEngravingEnabled = IsEngravingEnabled and IsEngravingEnabled()
end

-- init: store API, to reduce the API usage
local function GetPlayerRole()
    local assignedRole = GW.allowRoles and UnitGroupRolesAssigned("player") or "NONE"
    return (assignedRole ~= "NONE" and assignedRole) or GW.myspecRole or "NONE"
end
GW.GetPlayerRole = GetPlayerRole

local function CheckRole()
    local GetSpecialization = (GW.Libs.LCS and GW.Libs.LCS.GetSpecialization) or C_SpecializationInfo.GetSpecialization or GetSpecialization
    local GetSpecializationInfo = (GW.Libs.LCS and GW.Libs.LCS.GetSpecializationInfo) or C_SpecializationInfo.GetSpecializationInfo or GetSpecializationInfo

    GW.myspec = GetSpecialization()
    if GW.myspec then
        GW.myspecID, GW.myspecName, GW.myspecDesc, GW.myspecIcon, GW.myspecRole = GetSpecializationInfo(GW.myspec)
    end
    GW.myrole = GetPlayerRole()

    -- myrole = group role; TANK, HEALER, DAMAGER
end
GW.CheckRole = CheckRole

--Constants
local gameLocale = GetLocale()
GW.myguid = UnitGUID("player")
GW.addonName = addonName:gsub("_", " ")
GW.mylocal = gameLocale == "enGB" and "enUS" or gameLocale
GW.NoOp = function() end
GW.myfaction, GW.myLocalizedFaction = UnitFactionGroup("player")
GW.myLocalizedClass, GW.myclass, GW.myClassID = UnitClass("player")
GW.myLocalizedRace, GW.myrace = UnitRace("player")
GW.myname = UnitName("player")
GW.myrealm = GetRealmName()
GW.mysex = UnitSex("player")
GW.mylevel = UnitLevel("player")
GW.screenwidth, GW.screenHeight = GetPhysicalScreenSize()
GW.resolution = format("%dx%d", GW.screenwidth, GW.screenHeight)
GW.wowpatch, GW.wowbuild, _ , GW.wowToc = GetBuildInfo()
GW.allowRoles = GW.Retail or GW.Mists or GW.ClassicAnniv or GW.ClassicAnnivHC or GW.ClassicSOD

GW.wowbuild = tonumber(GW.wowbuild)
GW.Gw2Color = "|cffffedba" -- Color used for chat prints or buttons
GW.NewSign = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:14:14|t]]

GW.HiddenFrame = CreateFrame("Frame")
GW.HiddenFrame.HiddenString = GW.HiddenFrame:CreateFontString(nil, "OVERLAY")
GW.HiddenFrame:Hide()
GW.ScanTooltip = CreateFrame("GameTooltip", "GW2_UIScanTooltip", UIParent, "GameTooltipTemplate")
GW.BorderSize = 1
GW.SpacingSize = 1

GW.ShowRlPopup = false
GW.InMoveHudMode = false

--Tables
GW.unitIlvlsCache = {}
GW.TexCoords = {0, 1, 0, 1}
GW.gwMocks = {}
GW.MOVABLE_FRAMES = {}
GW.scaleableFrames = {}
GW.scaleableMainHudFrames = {}
GW.animations = {}
GW.BackdropTemplates = {}
GW.AchievementFrameSkinFunction = {}
GW.CreditsList = {}
GW.texts = {}
GW.instanceIconByName = {}
GW.changelog = {}

-- money
GW.earnedMoney = 0
GW.spentMoney = 0

-- Init error handler
GW.CreateErrorHandler()

GW.AlertContainerFrame = nil

if not GW.Retail then
    Enum.ItemQuality.Common = Enum.ItemQuality.Standard
end

-- Init Libs
do
    GW.Libs = {}
    local function AddLib(name, libname, silent)
        if not name then return end
        GW.Libs[name] = _G.LibStub(libname, silent)
    end

    AddLib("AceDB", "AceDB-3.0", true)
    AddLib("LRI", "LibRealmInfo", true)
    AddLib("LSM", "LibSharedMedia-3.0", true)
    AddLib("Compress", "LibCompress", true)
    AddLib("Serializer", "AceSerializer-3.0", true)
    AddLib("Deflate", "LibDeflate", true)
    AddLib("LibBase64", "LibBase64-1.0_GW2", true)
    AddLib("AceLocale", "AceLocale-3.0", true)
    AddLib("CustomGlows", "LibCustomGlow-1.0-Gw2", true)
    AddLib("LEMO", "LibEditModeOverride-1.0-GW2", true)
    AddLib("Dispel", "LibDispel-1.0-GW", true)
    AddLib("GW2Lib", "LibGW2-1.0", true)

    if GW.Classic then
        AddLib("LibDetours", "LibDetours-1.0", true)
        AddLib("CI", "LibClassicInspector", true)
    end

    if not (GW.Retail or GW.Mists) then
        AddLib("LCS", "LibClassicSpecs-GW2", true)
    end
end

-- triger GetCurrentRegion() for LRI to unpack all data on startup
GW.Libs.LRI:GetCurrentRegion()

do
    GW.UnlocalizedClasses = {}
    for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do GW.UnlocalizedClasses[v] = k end
    for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do GW.UnlocalizedClasses[v] = k end

    function GW.UnlocalizedClassName(className)
        return (className and className ~= "") and GW.UnlocalizedClasses[className]
    end
end

-- Locale doesn't exist yet, make it exist
GW.L = GW.Libs.AceLocale:GetLocale("GW2_UI")

local function CopyTable(src, preserveMeta, seen)
    if type(src) ~= "table" then return src end
    seen = seen or {}
    if seen[src] then return seen[src] end

    local dst = {}
    seen[src] = dst

    for k, v in pairs(src) do
        local nk = (type(k) == "table") and CopyTable(k, preserveMeta, seen) or k
        local nv = (type(v) == "table") and CopyTable(v, preserveMeta, seen) or v
        dst[nk] = nv
    end
    if preserveMeta then
        local mt = getmetatable(src)
        if mt then setmetatable(dst, mt) end
    end
    return dst
end
GW.CopyTable = CopyTable


--Add Shared Media
--Font
GW.Libs.LSM:Register("font", "GW2_UI", "Interface/AddOns/GW2_UI/fonts/chinese-font.ttf", GW.Libs.LSM.LOCALE_BIT_zhCN + GW.Libs.LSM.LOCALE_BIT_zhTW)
GW.Libs.LSM:Register("font", "GW2_UI", "Interface/AddOns/GW2_UI/fonts/korean.ttf", GW.Libs.LSM.LOCALE_BIT_koKR)
GW.Libs.LSM:Register("font", "GW2_UI", "Interface/AddOns/GW2_UI/fonts/menomonia.ttf", GW.Libs.LSM.LOCALE_BIT_western + GW.Libs.LSM.LOCALE_BIT_ruRU)
GW.Libs.LSM:Register("font", "GW2_UI Light", "Interface/AddOns/GW2_UI/fonts/menomonia-italic.ttf", GW.Libs.LSM.LOCALE_BIT_western + GW.Libs.LSM.LOCALE_BIT_ruRU)
GW.Libs.LSM:Register("font", "GW2_UI Headlines", "Interface/AddOns/GW2_UI/fonts/headlines.ttf", GW.Libs.LSM.LOCALE_BIT_western + GW.Libs.LSM.LOCALE_BIT_ruRU)
GW.Libs.LSM:Register("font", "GW2_UI_Chat", "Interface/AddOns/GW2_UI/fonts/trebuchet_ms.ttf", GW.Libs.LSM.LOCALE_BIT_western + GW.Libs.LSM.LOCALE_BIT_ruRU)
GW.Libs.LSM:Register("font", "GW2_UI_Chat", "Interface/AddOns/GW2_UI/fonts/chinese-font.ttf", GW.Libs.LSM.LOCALE_BIT_zhCN + GW.Libs.LSM.LOCALE_BIT_zhTW)
GW.Libs.LSM:Register("font", "GW2_UI_Chat", "Interface/AddOns/GW2_UI/fonts/korean.ttf", GW.Libs.LSM.LOCALE_BIT_koKR)

--Texture
GW.Libs.LSM:Register("background", "GW2_UI", "Interface/AddOns/GW2_UI/textures/uistuff/windowborder")
GW.Libs.LSM:Register("background", "GW2_UI_2", "Interface/Addons/GW2_UI/textures/uistuff/UI-Tooltip-Background")
GW.Libs.LSM:Register("statusbar", "GW2_UI_Yellow", "Interface/Addons/GW2_UI/textures/hud/castingbar")
GW.Libs.LSM:Register("statusbar", "GW2_UI_Blue", "Interface/Addons/GW2_UI/textures/hud/breathmeter")
GW.Libs.LSM:Register("statusbar", "GW2_UI", "Interface/Addons/GW2_UI/textures/hud/castinbar-white")
GW.Libs.LSM:Register("statusbar", "GW2_UI_2", "Interface/Addons/GW2_UI/textures/uistuff/gwstatusbar")
GW.Libs.LSM:Register("statusbar", "GW2_UI_2_DEFAULT", "Interface/Addons/GW2_UI/textures/bartextures/statusbar")

GW.Libs.LSM:Register("statusbar", "GW2_UI_Details", "Interface/Addons/GW2_UI/textures/addonSkins/details_statusbar")
GW.Libs.LSM:Register("border", "GW2_UI", "Interface/Addons/GW2_UI/textures/uistuff/UI-Tooltip-Border")

--Sound
GW.Libs.LSM:Register("sound", "GW2_UI: Close", "Interface/AddOns/GW2_UI/Sounds/dialog_close.ogg")
GW.Libs.LSM:Register("sound", "GW2_UI: Open", "Interface/AddOns/GW2_UI/Sounds/dialog_open.ogg")
GW.Libs.LSM:Register("sound", "GW2_UI: Ping", "Interface/AddOns/GW2_UI/Sounds/exp_gain_ping.ogg")
