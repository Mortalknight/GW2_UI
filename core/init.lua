
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

    local dispel = GW.DispelClasses[GW.myclass]
    if GW.myrole and (GW.myclass ~= "PRIEST" and dispel ~= nil) then
        dispel.Magic = (GW.myrole == "HEALER")
    end
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
GW.myspec = GetSpecialization()
GW.CheckRole()
GW.screenwidth, GW.screenHeight = GetPhysicalScreenSize()
GW.resolution = format("%dx%d", GW.screenwidth, GW.screenHeight)
GW.wowpatch, GW.wowbuild = GetBuildInfo()
GW.wowbuild = tonumber(GW.wowbuild)
GW.Gw2Color = "|cffffedba" -- Color used for chat prints or buttons

GW.ScanTooltip = CreateFrame("GameTooltip", "GW2_UI_ScanTooltip", UIParent, "GameTooltipTemplate")
GW.HiddenFrame = CreateFrame("Frame")
GW.HiddenFrame.HiddenString = GW.HiddenFrame:CreateFontString(nil, "OVERLAY")
GW.HiddenFrame:Hide()

--Tables
GW.unitIlvlsCache = {}
GW.skins = {}
GW.TexCoords = {0, 1, 0, 1}
GW.gwMocks = {}
GW.locationData = {}
GW.MOVABLE_FRAMES = {}
GW.scaleableFrames = {}
GW.scaleableMainHudFrames = {}
GW.animations = {}

-- money
GW.earnedMoney = 0
GW.spentMoney = 0

-- Init global function
GW.InitLocationDataHandler()

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

    AddLib("LRI", "LibRealmInfo", true)
    AddLib("LSM", "LibSharedMedia-3.0", true)
    AddLib("Compress", "LibCompress", true)
    AddLib("Serializer", "AceSerializer-3.0", true)
    AddLib("LibBase64", "LibBase64-1.0_GW2", true)
    AddLib("AceLocale", "AceLocale-3.0", true)
    AddLib("CustomGlows", "LibCustomGlow-1.0", true)
    GW_LIBS = GW.Libs
end

-- Locale doesn't exist yet, make it exist
GW.L = GW.Libs.AceLocale:GetLocale("GW2_UI")

-- remove the NPE, conflicts with customs hero and spell book panel
local NPERemoveFrame = CreateFrame("Frame")
NPERemoveFrame:Hide()

local function RemoveNPE(self, event)
    local NPE = _G.NewPlayerExperience
    if NPE then
        if NPE:GetIsActive() then
            NPE:Shutdown()
            SetCVar("showNPETutorials", 0)
        end

        if event then
            self:UnregisterEvent(event)
        end
    end
end

if _G.NewPlayerExperience then
    RemoveNPE(NPERemoveFrame)
else
    NPERemoveFrame:RegisterEvent("ADDON_LOADED")
    NPERemoveFrame:SetScript("OnEvent", RemoveNPE)
end

local function AcknowledgeTips()
    for frame in _G.HelpTip.framePool:EnumerateActive() do
        frame:Acknowledge()
    end
end

-- disable helper tooltips
hooksecurefunc(_G.HelpTip, "Show", AcknowledgeTips)
C_Timer.After(1, function() AcknowledgeTips() end)
