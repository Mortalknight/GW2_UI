
local addonName, GW = ...

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

local function GetVersionString()
    local version = C_AddOns.GetAddOnMetadata(addonName, "Version")
    if version:find("@project%-version@") then
        local currentVersion = GW.changelog[1].version
        return "GW2_UI " .. currentVersion .. " Development Version"
    else
        return "GW2_UI " .. version
    end
end
GW.GetVersionString = GetVersionString

-- init: store API, to reduce the API usage
local function GetPlayerRole()
    local assignedRole = GW.allowRoles and UnitGroupRolesAssigned("player") or "NONE"
    return (assignedRole ~= "NONE" and assignedRole) or GW.myspecRole or "NONE"
end
GW.GetPlayerRole = GetPlayerRole

local function CheckRole()
    GW.myspec = C_SpecializationInfo.GetSpecialization()
    if GW.myspec then
        GW.myspecID, GW.myspecName, GW.myspecDesc, GW.myspecIcon, GW.myspecRole =  C_SpecializationInfo.GetSpecializationInfo(GW.myspec)
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

function GW.CopyTable(src, preserveMeta, seen)
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

function GW.IsSecretValue(value)
    if issecretvalue and issecretvalue(value) then
        return true
    end
end

function GW.NotSecretValue(value)
    if not issecretvalue or not issecretvalue(value) then
        return true
    end
end


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
GW.Libs.LSM:Register("background", "GW2_UI", "Interface/AddOns/GW2_UI/textures/uistuff/windowborder.png")
GW.Libs.LSM:Register("background", "GW2_UI_2", "Interface/Addons/GW2_UI/textures/uistuff/ui-tooltip-background.png")
GW.Libs.LSM:Register("statusbar", "GW2_UI_Yellow", "Interface/Addons/GW2_UI/textures/hud/castingbar.png")
GW.Libs.LSM:Register("statusbar", "GW2_UI_Blue", "Interface/Addons/GW2_UI/textures/hud/breathmeter.png")
GW.Libs.LSM:Register("statusbar", "GW2_UI", "Interface/Addons/GW2_UI/textures/hud/castinbar-white.png")
GW.Libs.LSM:Register("statusbar", "GW2_UI_2", "Interface/Addons/GW2_UI/textures/uistuff/gwstatusbar.png")
GW.Libs.LSM:Register("statusbar", "GW2_UI_2_DEFAULT", "Interface/Addons/GW2_UI/textures/bartextures/statusbar.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Bag", "Interface/AddOns/GW2_UI/textures/bag/bagicon.png")
GW.Libs.LSM:Register("border", "GW2_UI_Bag_Foot", "Interface/AddOns/GW2_UI/textures/bag/bagfooter.png")
GW.Libs.LSM:Register("border", "GW2_UI_Bag_Left", "Interface/AddOns/GW2_UI/textures/bag/bagleftpanel.png")
GW.Libs.LSM:Register("border", "GW2_UI_Bag_Bottom_Right", "Interface/AddOns/GW2_UI/textures/bag/bottom-right.png")
GW.Libs.LSM:Register("border", "GW2_UI_Bag_Item", "Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Menu_Guild", "Interface/AddOns/GW2_UI/textures/icons/microicons/guildmicrobutton-up.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Menu_LFD", "Interface/AddOns/GW2_UI/textures/icons/microicons/lfdmicrobutton-up.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Menu_Sys", "Interface/AddOns/GW2_UI/textures/icons/microicons/mainmenumicrobutton-up.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Menu_Sys_2_Up", "Interface/AddOns/GW2_UI/textures/icons/mainmenumicrobutton-up.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Menu_Sys_2_Down", "Interface/AddOns/GW2_UI/textures/icons/mainmenumicrobutton-down.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Menu_Bag", "Interface/AddOns/GW2_UI/textures/icons/microicons/bagmicrobutton-up.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Menu_Bag_2", "Interface/AddOns/GW2_UI/textures/icons/bagmicrobutton-up.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Settings", "Interface/AddOns/GW2_UI/textures/character/settings-window-icon.png")
GW.Libs.LSM:Register("background", "GW2_UI_Group", "Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Role_Healer", "Interface/AddOns/GW2_UI/textures/party/roleicon-healer.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Macro", "Interface/AddOns/GW2_UI/textures/character/macro-window-icon.png")
GW.Libs.LSM:Register("border", "GW2_UI_Chat_Left", "Interface/AddOns/GW2_UI/textures/chat/chattabactiveleft.png")
GW.Libs.LSM:Register("border", "GW2_UI_Chat_Right", "Interface/AddOns/GW2_UI/textures/chat/chattabactiveright.png")
GW.Libs.LSM:Register("border", "GW2_UI_Chat_Middle", "Interface/AddOns/GW2_UI/textures/chat/chattabactive.png")
GW.Libs.LSM:Register("background", "GW2_UI_Chat_Edit", "Interface/AddOns/GW2_UI/textures/chat/chateditboxmid.png")
GW.Libs.LSM:Register("background", "GW2_UI_Chat", "Interface/AddOns/GW2_UI/textures/chat/chatframebackground.png")
GW.Libs.LSM:Register("border", "GW2_UI_Chat_Frame", "Interface/AddOns/GW2_UI/textures/chat/chatframeborder.png")
GW.Libs.LSM:Register("background", "GW2_UI_Chat_Dock", "Interface/AddOns/GW2_UI/textures/chat/chatdockbg.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Social", "Interface/AddOns/GW2_UI/textures/chat/socialchatbutton.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Social_Highlight", "Interface/AddOns/GW2_UI/textures/chat/socialchatbutton-highlight.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Channel_Voice", "Interface/AddOns/GW2_UI/textures/chat/channel_button_vc.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Channel_Voice_Highlight", "Interface/AddOns/GW2_UI/textures/chat/channel_button_vc_highlight.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Channel", "Interface/AddOns/GW2_UI/textures/chat/channel_button_normal.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Channel_Highlight", "Interface/AddOns/GW2_UI/textures/chat/channel_button_normal_highlight.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Sound_Off", "Interface/AddOns/GW2_UI/textures/chat/channel_vc_sound_off.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Sound_Off_Highlight", "Interface/AddOns/GW2_UI/textures/chat/channel_vc_sound_off_highlight.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Sound_On", "Interface/AddOns/GW2_UI/textures/chat/channel_vc_sound_on.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Sound_On_Highlight", "Interface/AddOns/GW2_UI/textures/chat/channel_vc_sound_on_highlight.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Mic_On", "Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_on.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Mic_On_Highlight", "Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_on_highlight.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Mic_Off", "Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_off.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Mic_Off_Highlight", "Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_off_highlight.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Mic_Silence_On", "Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_silenced_on.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Mic_Silence_On_Highlight", "Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_silenced_on_highlight.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Mic_Silence_Off", "Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_silenced_off.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Mic_Silence_Off_Highlight", "Interface/AddOns/GW2_UI/textures/chat/channel_vc_mic_silenced_off_highlight.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Bubble_Up", "Interface/AddOns/GW2_UI/textures/chat/bubble_up.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chat_Bubble_Down", "Interface/AddOns/GW2_UI/textures/chat/bubble_down.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Arrow_Down", "Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Arrow_Down_Up", "Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Arrow_Right", "Interface/AddOns/GW2_UI/textures/uistuff/arrow_right.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Scroll_Button", "Interface/AddOns/GW2_UI/textures/uistuff/scrollbutton.png")
GW.Libs.LSM:Register("background", "GW2_UI_Scroll", "Interface/AddOns/GW2_UI/textures/uistuff/scrollbg.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Tab_Achievement", "Interface/AddOns/GW2_UI/textures/uistuff/tabicon_achievement.png")
GW.Libs.LSM:Register("background", "GW2_UI_Char_Menu", "Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
GW.Libs.LSM:Register("background", "GW2_UI_Char_Menu_Highlight", "Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Watch", "Interface/AddOns/GW2_UI/textures/uistuff/watchicon.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Watch_Active", "Interface/AddOns/GW2_UI/textures/uistuff/watchiconactive.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Hamburger", "Interface/AddOns/GW2_UI/textures/uistuff/hamburger.png")
GW.Libs.LSM:Register("border", "GW2_UI_Cheese_Footer", "Interface/AddOns/GW2_UI/textures/uistuff/achievementfooter.png")
GW.Libs.LSM:Register("border", "GW2_UI_Cheese_Footer_2", "Interface/AddOns/GW2_UI/textures/uistuff/achievementfooternotrack.png")
GW.Libs.LSM:Register("background", "GW2_UI_Cheese_Complete", "Interface/AddOns/GW2_UI/textures/uistuff/achievementcompletebg.png")
GW.Libs.LSM:Register("background", "GW2_UI_Cheese_Complete_2", "Interface/AddOns/GW2_UI/textures/uistuff/achievementcomplete.png")
GW.Libs.LSM:Register("background", "GW2_UI_Cheese_Complete_Red", "Interface/AddOns/GW2_UI/textures/uistuff/achievementcompletebgred.png")
GW.Libs.LSM:Register("background", "GW2_UI_Cheese_Hover", "Interface/AddOns/GW2_UI/textures/uistuff/achievementhover.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Chest_Sm", "Interface/AddOns/GW2_UI/textures/uistuff/rewardchestsmall.png")
GW.Libs.LSM:Register("background", "GW2_UI_List", "Interface/AddOns/GW2_UI/textures/uistuff/listbackground.png")
GW.Libs.LSM:Register("statusbar", "GW2_UI_Spark", "Interface/AddOns/GW2_UI/textures/uistuff/statusbar-spark-white.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Talents", "Interface/AddOns/GW2_UI/textures/talents/talents_header.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Calendar", "Interface/AddOns/GW2_UI/textures/icons/calendar.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Close", "Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Close_Hover", "Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover.png")

GW.Libs.LSM:Register("icon", "GW2_UI_Details_Classicons_colored", "Interface/AddOns/GW2_UI/textures/addonSkins/details_class_icons_colored.png")
GW.Libs.LSM:Register("icon", "GW2_UI_Details_Classicons", "Interface/AddOns/GW2_UI/textures/addonSkins/details_class_icons.png")

GW.Libs.LSM:Register("statusbar", "GW2_UI_Details", "Interface/Addons/GW2_UI/textures/addonSkins/details_statusbar.png")
GW.Libs.LSM:Register("border", "GW2_UI", "Interface/Addons/GW2_UI/textures/uistuff/ui-tooltip-border.png")

--Sound
GW.Libs.LSM:Register("sound", "GW2_UI: Close", "Interface/AddOns/GW2_UI/Sounds/dialog_close.ogg")
GW.Libs.LSM:Register("sound", "GW2_UI: Open", "Interface/AddOns/GW2_UI/Sounds/dialog_open.ogg")
GW.Libs.LSM:Register("sound", "GW2_UI: Ping", "Interface/AddOns/GW2_UI/Sounds/exp_gain_ping.ogg")
