
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
GW.myspec = GetSpecialization()
GW.mylocal = GetLocale()
GW.CheckRole()
GW.screenwidth, GW.screenHeight = GetPhysicalScreenSize()
GW.resolution = format("%dx%d", GW.screenwidth, GW.screenHeight)
GW.wowpatch, GW.wowbuild = GetBuildInfo()
GW.wowbuild = tonumber(GW.wowbuild)

GW.ScanTooltip = CreateFrame("GameTooltip", "GW2_UI_ScanTooltip", UIParent, "GameTooltipTemplate")
GW.HiddenFrame = CreateFrame("Frame")
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

-- Init global function
GW.InitLocationDataHandler()

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
    AddLib("LibBase64", "LibBase64-1.0", true)
end


-- remove the NPE, conflicts with customs hero and spell book panel
local NPERemoveFrame = CreateFrame("Frame")
NPERemoveFrame:Hide()

local function RemoveNPE(self, event)
    local NPE = _G.NewPlayerExperience
    if NPE then
        if NPE:GetIsActive() then
            NPE:Shutdown()
        end

        if event then
            NPERemoveFrame:UnregisterEvent(event)
        end
    end
end

if _G.NewPlayerExperience then
    RemoveNPE()
else
    NPERemoveFrame:RegisterEvent("ADDON_LOADED")
    NPERemoveFrame:SetScript("OnEvent",RemoveNPE)
end

local function AcknowledgeTips()
    for frame in _G.HelpTip.framePool:EnumerateActive() do
        frame:Acknowledge()
    end
end

-- disable helper tooltips
hooksecurefunc(_G.HelpTip, "Show", AcknowledgeTips)
C_Timer.After(1, function() AcknowledgeTips() end)