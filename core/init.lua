
local addonName, GW = ...

-- init: store API, to reduce the API usage
local function GetPlayerRole()
    local assignedRole = UnitGroupRolesAssigned("player")
    if assignedRole == "NONE" then
        return GW.myspec and GetSpecializationRole(GW.myspec)
    end

    return assignedRole
end
GW.GetPlayerRole = GetPlayerRole

local function CheckRole()
    GW.myspec = GetSpecialization()
    GW.myrole = GetPlayerRole()

    -- myrole = group role; TANK, HEALER, DAMAGER
end
GW.CheckRole = CheckRole

assert(GW.oUF, 'GW2_UI was unable to locate oUF.')

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
GW.myspec = GetSpecialization()
GW.CheckRole()
GW.screenwidth, GW.screenHeight = GetPhysicalScreenSize()
GW.resolution = format("%dx%d", GW.screenwidth, GW.screenHeight)
GW.wowpatch, GW.wowbuild, _ , GW.wowToc = GetBuildInfo()

GW.wowbuild = tonumber(GW.wowbuild)
GW.Gw2Color = "|cffffedba" -- Color used for chat prints or buttons
GW.NewSign = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:14:14|t]]

GW.HiddenFrame = CreateFrame("Frame")
GW.HiddenFrame.HiddenString = GW.HiddenFrame:CreateFontString(nil, "OVERLAY")
GW.HiddenFrame:Hide()
GW.BorderSize = 1
GW.SpacingSize = 1

GW.ShowRlPopup = false
GW.InMoveHudMode = false

--Tables
GW.unitIlvlsCache = {}
GW.skins = {}
GW.TexCoords = {0, 1, 0, 1}
GW.gwMocks = {}
GW.MOVABLE_FRAMES = {}
GW.scaleableFrames = {}
GW.scaleableMainHudFrames = {}
GW.animations = {}
GW.BackdropTemplates = {}
GW.AchievementFrameSkinFunction = {}
GW.CreditsList = {}

-- money
GW.earnedMoney = 0
GW.spentMoney = 0

-- Init error handler
GW.RegisterErrorHandler()

GW.AlertContainerFrame = nil

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
    AddLib("CustomGlows", "LibCustomGlow-1.0", true)
    AddLib("LEMO", "LibEditModeOverride-1.0", true)
    AddLib("Dispel", "LibDispel-1.0-GW", true)
    AddLib("GW2Lib", "LibGW2-1.0", true)
    AddLib("LibDD", "LibUIDropDownMenu-4.0", true)
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

-- remove the NPE, conflicts with customs hero and spell book panel
local NPERemoveFrame = CreateFrame("Frame")
NPERemoveFrame:Hide()

local function RemoveNPE(_, event)
    if NewPlayerExperience then
        if NewPlayerExperience:GetIsActive() then
            NewPlayerExperience:Shutdown()
            C_CVar.SetCVar("showNPETutorials", "0")
        end

        if event then
            NPERemoveFrame:UnregisterEvent(event)
        end
    end
end

if NewPlayerExperience then
    RemoveNPE()
else
    NPERemoveFrame:RegisterEvent("ADDON_LOADED")
    NPERemoveFrame:SetScript("OnEvent", RemoveNPE)
end

local function AcknowledgeTips()
    for frame in HelpTip.framePool:EnumerateActive() do
        frame:Acknowledge()
    end
end

-- disable helper tooltips
hooksecurefunc(HelpTip, "Show", AcknowledgeTips)
C_Timer.After(1, function() AcknowledgeTips() end)


local function copyTable(newTable, tableToCopy)
    if type(newTable) ~= "table" then newTable = {} end

    if type(tableToCopy) == "table" then
        for option, value in pairs(tableToCopy) do
            if type(value) == "table" then
                value = copyTable(newTable[option], value)
            end

            newTable[option] = value
        end
    end

    return newTable
end
GW.copyTable = copyTable

-- Create Warning Prompt
GW.CreateWarningPrompt()

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
GW.Libs.LSM:Register("background", "GW2_UI", "Interface/AddOns/GW2_UI/textures/uistuff/windowborder")
GW.Libs.LSM:Register("background", "GW2_UI_2", "Interface/Addons/GW2_UI/textures/uistuff/UI-Tooltip-Background")
GW.Libs.LSM:Register("statusbar", "GW2_UI_Yellow", "Interface/Addons/GW2_UI/textures/hud/castingbar")
GW.Libs.LSM:Register("statusbar", "GW2_UI_Blue", "Interface/Addons/GW2_UI/textures/hud/breathmeter")
GW.Libs.LSM:Register("statusbar", "GW2_UI", "Interface/Addons/GW2_UI/textures/hud/castinbar-white")
GW.Libs.LSM:Register("statusbar", "GW2_UI_2", "Interface/Addons/GW2_UI/textures/uistuff/gwstatusbar")
GW.Libs.LSM:Register("statusbar", "GW2_UI_Details", "Interface/Addons/GW2_UI/textures/addonSkins/details_statusbar")
GW.Libs.LSM:Register("border", "GW2_UI", "Interface/Addons/GW2_UI/textures/uistuff/UI-Tooltip-Border")

--Sound
GW.Libs.LSM:Register("sound", "GW2_UI: Close", "Interface/AddOns/GW2_UI/sounds/dialog_close.ogg")
GW.Libs.LSM:Register("sound", "GW2_UI: Open", "Interface/AddOns/GW2_UI/sounds/dialog_open.ogg")
GW.Libs.LSM:Register("sound", "GW2_UI: Ping", "Interface/AddOns/GW2_UI/sounds/exp_gain_ping.ogg")
