local _, GW = ...
local L = GW.L
local RoundInt = GW.RoundInt
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local bloodSpark = GW.BLOOD_SPARK
local CLASS_ICONS = GW.CLASS_ICONS
local IsFrameModified = GW.IsFrameModified
local Debug = GW.Debug
local LibSharedMedia = GW.Libs.LSM

GW.VERSION_STRING = "GW2_UI @project-version@"

-- setup Binding Header color
_G.BINDING_HEADER_GW2UI = GetAddOnMetadata(..., "Title")

if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r You have installed GW2_UI retail version. Please install the classic version to use GW2_UI.")
    return
end

if GW.CheckForPasteAddon() and GetSetting("ACTIONBARS_ENABLED") then
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r |cffff0000You have installed the Addon 'Paste'. This can cause, that our actionbars are empty. Deactive 'Paste' to use our actionbars.|r")
end

local loaded = false
local forcedMABags = false

local swimAnimation = 0
local lastSwimState = true

if Profiler then
    _G.GW_Addon_Scope = GW
end

local function disableMABags()
    local bags = GetSetting("BAGS_ENABLED")
    if not bags or not MovAny or not MADB then
        return
    end
    MADB.noBags = true
    MAOptNoBags:SetEnabled(false)
    forcedMABags = true
end
GW.AddForProfiling("index", "disableMABags", disableMABags)

-- https://us.battle.net/forums/en/wow/topic/6036615884
if AchievementMicroButton_Update == nil then
    function AchievementMicroButton_Update()
        return
    end
end

local animations = {}
GW.animations = animations
local function AddToAnimation(name, from, to, start, duration, method, easeing, onCompleteCallback, doCompleteOnOverider)
    local newAnimation = true
    if animations[name] ~= nil then
        if (animations[name]["start"] + animations[name]["duration"]) > GetTime() then
            newAnimation = false
        end
    end
    if doCompleteOnOverider == nil then
        newAnimation = true
    end

    if newAnimation == false then
        animations[name]["duration"] = duration
        animations[name]["to"] = to
        animations[name]["progress"] = 0
        animations[name]["method"] = method
        animations[name]["completed"] = false
        animations[name]["easeing"] = easeing
        animations[name]["onCompleteCallback"] = onCompleteCallback
    else
        animations[name] = {}
        animations[name]["start"] = start
        animations[name]["duration"] = duration
        animations[name]["from"] = from
        animations[name]["to"] = to
        animations[name]["progress"] = 0
        animations[name]["method"] = method
        animations[name]["completed"] = false
        animations[name]["easeing"] = easeing
        animations[name]["onCompleteCallback"] = onCompleteCallback
    end
end
GW.AddToAnimation = AddToAnimation

local function buttonAnim(self, name, w, hover)
    local prog = animations[name]["progress"]
    local l = GW.lerp(0, w, prog)

    hover:SetPoint("RIGHT", self, "LEFT", l, 0)
    hover:SetVertexColor(1, 1, 1, GW.lerp(0, 1, ((prog) - 0.5) / 0.5))
end
GW.AddForProfiling("index", "buttonAnim", buttonAnim)

--[[
 Basic helper function for spritemaps
 mapExample = {
  width = 100,
  height = 10,
  colums = 5,
  rows = 3
}
]]--
local function getSprite(map,x,y)
    local pw = (map.width / map.colums) / map.width
    local ph = (map.height / map.rows) / map.height

    local left = pw * (x - 1)
    local right = pw * x

    local top = ph * (y - 1)
    local bottom = ph * y

    return left, right, top, bottom;
end
GW.getSprite = getSprite

local function getSpriteByIndex(map, index)
    if map == nil then
        return 0, 0, 0, 0
    end

    local tileWidth =  map.width / map.colums
    local tileHeight =  map.height / map.rows

    local tilesPerColums = map.width / tileWidth
    local tilesPerRow = map.height / tileHeight

    local left = tileWidth * (index % tilesPerColums)
    local top =  tileHeight * math.floor(index / tilesPerColums)

    local bottom = top + tileHeight
    local right = left + tileWidth

    return left / map.width, right / map.width, top / map.height,bottom / map.height
end
GW.getSpriteByIndex = getSpriteByIndex

function GwStandardButton_OnEnter(self)
    local name = tostring(self)
    local w = self:GetWidth()
    local hover = self.hover
    if not hover then
        return
    end

    hover:SetAlpha(1)
    self.animationValue = 0

    AddToAnimation(
        name,
        self.animationValue,
        1,
        GetTime(),
        0.2,
        function()
            buttonAnim(self, name, w, hover)
        end
    )
end

function GwStandardButton_OnLeave(self)
    local name = tostring(self)
    local w = self:GetWidth()
    local hover = self.hover
    if not hover then
        return
    end

    hover:SetAlpha(1)
    self.animationValue = 1

    AddToAnimation(
        name,
        self.animationValue,
        0,
        GetTime(),
        0.2,
        function()
            buttonAnim(self, name, w, hover)
        end
    )
end


local function barAnimation(self, barWidth, sparkWidth)
    local snap = (animations[self.animationName]["progress"] * 100) / 5

    local round_closest = 0.05 * snap

    local spark_min = math.floor(snap)
    local spark_current = snap

    local spark_prec = spark_current - spark_min

    local spark =
        math.min(barWidth - sparkWidth, math.floor(barWidth * round_closest) - math.floor(sparkWidth * spark_prec))
    local bI = 17 - math.max(1, RoundInt(16 * spark_prec))

    self.spark:SetTexCoord(bloodSpark[bI].left, bloodSpark[bI].right, bloodSpark[bI].top, bloodSpark[bI].bottom)

    self:SetValue(round_closest)
    self.spark:ClearAllPoints()
    self.spark:SetPoint("LEFT", spark, 0)
end
GW.AddForProfiling("index", "barAnimation", barAnimation)

local function Bar(self, value)
    if self == nil then
        return
    end
    local barWidth = self:GetWidth()
    local sparkWidth = self.spark:GetWidth()

    AddToAnimation(
        self.animationName,
        self.animationValue,
        value,
        GetTime(),
        0.2,
        function()
            barAnimation(self, barWidth, sparkWidth)
        end
    )
    self.animationValue = value
end
GW.Bar = Bar

local function SetClassIcon(self, class)
    if class == nil then
        class = 0
    end

    self:SetTexCoord(CLASS_ICONS[class].l, CLASS_ICONS[class].r, CLASS_ICONS[class].t, CLASS_ICONS[class].b)
end
GW.SetClassIcon = SetClassIcon

local function SetDeadIcon(self)
    self:SetTexCoord(CLASS_ICONS["dead"].l, CLASS_ICONS["dead"].r, CLASS_ICONS["dead"].t, CLASS_ICONS["dead"].b)
end
GW.SetDeadIcon = SetDeadIcon

local function StopAnimation(k)
    if animations[k] ~= nil then
        animations[k] = nil
    end
end
GW.StopAnimation = StopAnimation

local l = CreateFrame("Frame", nil, UIParent)

local function swimAnim()
    local r, g, b = GwActionBarHud.RightSwim:GetVertexColor()
    GwActionBarHud.RightSwim:SetVertexColor(r, g, b, animations["swimAnimation"]["progress"])
    GwActionBarHud.LeftSwim:SetVertexColor(r, g, b, animations["swimAnimation"]["progress"])
end
GW.AddForProfiling("index", "swimAnim", swimAnim)

local updateCB = {}
local function AddUpdateCB(func, payload)
    if type(func) ~= "function" then
        return
    end

    tinsert(
        updateCB,
        {
            ["func"] = func,
            ["payload"] = payload
        }
    )
end
GW.AddUpdateCB = AddUpdateCB

local function gw_OnUpdate(self, elapsed)
    local foundAnimation = false
    local count = 0
    for k, v in pairs(animations) do
        count = count + 1
        if v["completed"] == false and GetTime() >= (v["start"] + v["duration"]) then
            if v["easeing"] == nil then
                v["progress"] = GW.lerp(v["from"], v["to"], math.sin(1 * math.pi * 0.5))
            else
                v["progress"] = GW.lerp(v["from"], v["to"], 1)
            end
            if v["method"] ~= nil then
                v["method"](v["progress"])
            end

            if v["onCompleteCallback"] ~= nil then
                v["onCompleteCallback"]()
            end

            v["completed"] = true
            foundAnimation = true
        end
        if v["completed"] == false then
            if v["easeing"] == nil then
                v["progress"] =
                    GW.lerp(v["from"], v["to"], math.sin((GetTime() - v["start"]) / v["duration"] * math.pi * 0.5))
            else
                v["progress"] = GW.lerp(v["from"], v["to"], (GetTime() - v["start"]) / v["duration"])
            end
            v["method"](v["progress"])
            foundAnimation = true
        end
    end

    if foundAnimation == false and count ~= 0 then
        table.wipe(animations)
    end

    --Swim hud
    if lastSwimState ~= IsSwimming() then
        if IsSwimming() then
            AddToAnimation("swimAnimation", swimAnimation, 1, GetTime(), 0.1, swimAnim)
            swimAnimation = 1
        else
            AddToAnimation("swimAnimation", swimAnimation, 0, GetTime(), 3.0, swimAnim)
            swimAnimation = 0
        end
        lastSwimState = IsSwimming()
    end

    for _, cb in ipairs(updateCB) do
        cb.func(cb.payload, elapsed)
    end
end
GW.AddForProfiling("index", "gw_OnUpdate", gw_OnUpdate)

local function getBestPixelScale()
    return max(0.4, min(1.15, 768 / GW.screenHeight))
end
GW.getBestPixelScale = getBestPixelScale

local function PixelPerfection()
    GW.scale = getBestPixelScale()
    GW.border = ((1 / GW.scale) - ((1 - (768 / GW.screenHeight)) / GW.scale)) * 2
    UIParent:SetScale(GW.scale)
end
GW.PixelPerfection = PixelPerfection

local SCALE_HUD_FRAMES = {}
local function UpdateHudScale()
    local hudScale = GetSetting("HUD_SCALE")
    for i, f in ipairs(SCALE_HUD_FRAMES) do
        if f then
            local fm = f.gwMover
            local sf = 1.0
            if f.gwScaleMulti then
                sf = f.gwScaleMulti
            end
            f:SetScale(hudScale * sf)
            if fm then
                fm:SetScale(hudScale * sf)
            end
        end
    end
    -- let all mainhub frames scale with the HUD scaler, but only if they are not moved and not individual scaled
    for _, mf in pairs(GW.scaleableMainHudFrames) do
        if not mf.gw_frame.isMoved and mf:GetScale() ~= hudScale then
            mf.gw_frame:SetScale(hudScale)
            mf:SetScale(hudScale)
            GW.SetSetting(mf.gw_Settings .."_scale", hudScale)
        end
    end
end
GW.UpdateHudScale = UpdateHudScale

local function RegisterScaleFrame(f, modifier)
    if not f then
        return
    end
    if modifier and modifier > 0 then
        f.gwScaleMulti = modifier
    end
    local num = #SCALE_HUD_FRAMES
    SCALE_HUD_FRAMES[num + 1] = f
end
GW.RegisterScaleFrame = RegisterScaleFrame

local function loadAddon(self)
    --Create Settings window
    GW.LoadMovers()
    GW.LoadSettings()

    if GetSetting("PIXEL_PERFECTION") and not GetCVarBool("useUiScale") then
        PixelPerfection()
        DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r Pixel Perfection-Mode enabled. UIScale down to perfect pixel size. Can be deactivated in HUD settings. |cFF00FF00/gw2|r")
    else
        GW.scale = UIParent:GetScale()
        GW.border = ((1 / GW.scale) - ((1 - (768 / GW.screenHeight)) / GW.scale)) * 2
    end
    GW.mult = (1 / GW.scale) - ((1 - (768 / GW.screenHeight)) / GW.scale)

    if GetSetting("ALERTFRAME_ENABLED") then
        GW.LoadAlertSystemFrameSkins()
        GW.SetupAlertFramePosition()
    end
    GW.LoadOurAlertSubSystem()

    -- disable Move Anything bag handling
    disableMABags()

    -- hook debug output if relevant
    --@debug@
    local dev_dbg_tab = GetSetting("DEV_DBG_CHAT_TAB")
    if dev_dbg_tab and dev_dbg_tab > 0 and _G["ChatFrame" .. dev_dbg_tab] then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r hooking Debug to chat tab #" .. dev_dbg_tab)
        GW.dbgTab = dev_dbg_tab
        GW.AlertTestsSetup()
        SetCVar("fstack_preferParentKeys", 0) --Add back the frame names via fstack!
        GW.inDebug = true
    else
        GW.inDebug = false
    end
    --@end-debug@
    --[===[@non-debug@
    GW.inDebug = false
    --@end-non-debug@]===]

    -- Load Slash commands
    GW.LoadSlashCommands()

    --Create the mainbar layout manager
    local lm = GW.LoadMainbarLayout()

    --Create general skins
    if GetSetting("MAINMENU_SKIN_ENABLED") then
        GW.SkinMainMenu()
    else
        --Setup addon button
        local GwMainMenuFrame = CreateFrame("Button", "GW2_UI_SettingsButton", _G.GameMenuFrame, "GameMenuButtonTemplate") -- add a button name to you that for other Addons
        GwMainMenuFrame:SetText(format("|cffffedba%s|r", L["SETTINGS_BUTTON"]))
        GwMainMenuFrame:SetScript(
            "OnClick",
            function()
                if InCombatLockdown() then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r " .. L["HIDE_SETTING_IN_COMBAT"])
                    return
                end
                ShowUIPanel(GwSettingsWindow)
                UIFrameFadeIn(GwSettingsWindow, 0.2, 0, 1)
                HideUIPanel(GameMenuFrame)
            end
        )
        GameMenuFrame[L["SETTINGS_BUTTON"]] = GwMainMenuFrame

        if not IsAddOnLoaded("ConsolePortUI_Menu") then
            GwMainMenuFrame:SetSize(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
            GwMainMenuFrame:SetPoint("TOPLEFT", IsAddOnLoaded("ElvUI") and GameMenuButtonContinue or GameMenuButtonAddons, "BOTTOMLEFT", 0, -1)
            if not IsAddOnLoaded("ElvUI") then
                hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", GW.PositionGameMenuButton)
            end
        end
    end
    if GetSetting("STATICPOPUP_SKIN_ENABLED") then
        GW.SkinStaticPopup()
    end
    if GetSetting("BNTOASTFRAME_SKIN_ENABLED") then
        GW.SkinBNToastFrame()
    end
    if GetSetting("GHOSTFRAME_SKIN_ENABLED") then
        GW.SkinGhostFrame()
    end
    if GetSetting("DEATHRECAPFRAME_SKIN_ENABLED") then
        GW.SkinDeathRecapFrame()
    end
    if GetSetting("DROPDOWN_SKIN_ENABLED") then
        GW.SkinDropDown()
    end
    if GetSetting("LFG_FRAMES_SKIN_ENABLED") then
        GW.SkinLFGFrames()
    end
    if GetSetting("READYCHECK_SKIN_ENABLED") then
        GW.SkinReadyCheck()
    end
    if GetSetting("TALKINGHEAD_SKIN_ENABLED") then
        GW.SkinAndPositionTalkingHeadFrame()
    end
    if GetSetting("TIMERTRACKER_SKIN_ENABLED") then
        GW.SkinTimerTrackerFrame()
    end
    if GetSetting("IMMERSIONADDON_SKIN_ENABLED") then
        GW.SkinImmersionAddonFrame()
    end
    if GetSetting("FLIGHTMAP_SKIN_ENABLED") then
        GW.SkinFlightMap()
    end
    if GetSetting("ADDONLIST_SKIN_ENABLED") then
        GW.SkinAddonList()
    end
    if GetSetting("BINDINGS_SKIN_ENABLED") then
        GW.SkinBindingsUI()
    end
    if GetSetting("BLIZZARD_OPTIONS_SKIN_ENABLED") then
        GW.SkinBlizzardOptions()
    end
    if GetSetting("MACRO_SKIN_ENABLED") then
        GW.SkinMacroOptions()
    end
    if GetSetting("MAIL_SKIN_ENABLED") then
        GW.SkinMail()
        GW.SkinPostalAddonFrame()
    end
    if GetSetting("BARBERSHOP_SKIN_ENABLED") then
        GW.SkinBarShopUI()
    end
    if GetSetting("INSPECTION_SKIN_ENABLED") then
        GW.SkinInspectFrame()
    end
    if GetSetting("INSPECTION_SKIN_ENABLED") then
        GW.SkinDressUpFrame()
    end

    if GetSetting("HELPFRAME_SKIN_ENABLED") then
        GW.skinHelpFrameOnEvent()
    end


    if GetSetting("WORLDMAP_COORDS_TOGGLE") then
        GW.AddCoordsToWorldMap()
    end

    GW.LoadVehicleButton()
    GW.MakeAltPowerBarMovable()

    --Create hud art
    GW.LoadHudArt()

    --Create experiencebar
    if GetSetting("XPBAR_ENABLED") then
        GW.LoadXPBar()
    else
        GwActionBarHud:ClearAllPoints()
        GwActionBarHud:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
        GwHudArtFrame.edgeTintBottom1:ClearAllPoints()
        GwHudArtFrame.edgeTintBottom1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
        GwHudArtFrame.edgeTintBottom1:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 0, 0)
        GwHudArtFrame.edgeTintBottom2:ClearAllPoints()
        GwHudArtFrame.edgeTintBottom2:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
        GwHudArtFrame.edgeTintBottom2:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 0, 0)
    end

    if GetSetting("FONTS_ENABLED") then
        GW.LoadFonts()
    end

    if GetSetting("GW_COMBAT_TEXT_MODE") == "GW2" then
        SetCVar("floatingCombatTextCombatDamage", 0)
        GW.LoadDamageText()
    elseif GetSetting("GW_COMBAT_TEXT_MODE") == "BLIZZARD" then
        SetCVar("floatingCombatTextCombatDamage", 1)
    else
        SetCVar("floatingCombatTextCombatDamage", 0)
    end

    if GetSetting("CASTINGBAR_ENABLED") then
        GW.LoadCastingBar()
    end

    if GetSetting("MINIMAP_ENABLED") then
        GW.LoadMinimap()
    end

    if GetSetting("QUESTTRACKER_ENABLED") then
        GW.LoadQuestTracker()
    end

    if GetSetting("TOOLTIPS_ENABLED") then
        GW.LoadTooltips()
    end

    if GetSetting("QUESTVIEW_ENABLED") then
        GW.LoadQuestview()
    end

    if GetSetting("CHATFRAME_ENABLED") then
        GW.LoadChat()
    end

    --Create player hud
    if GetSetting("HEALTHGLOBE_ENABLED") then
        local hg = GW.LoadHealthGlobe()
        GW.LoadDodgeBar(hg)
    end

    if GetSetting("POWERBAR_ENABLED") then
        GW.LoadPowerBar()
    end

    if GetSetting("BAGS_ENABLED") then
        GW.LoadInventory()
        GW.SkinLooTFrame()
    else
        -- if not our bags, we need to cut the bagbar frame out of the micromenu
        GW.LoadDefaultBagBar()
    end

    if GetSetting("USE_BATTLEGROUND_HUD") then
        GW.LoadBattlegrounds()
    end

    GW.LoadCharacter()

    GW.LoadBreathMeter()
    GW.LoadAutoRepair()

    --Create unitframes
    if GetSetting("FOCUS_ENABLED") then
        GW.LoadFocus()
        if GetSetting("focus_TARGET_ENABLED") then
            GW.LoadTargetOfUnit("Focus")
        end
    end
    if GetSetting("TARGET_ENABLED") then
        GW.LoadTarget()
        if GetSetting("target_TARGET_ENABLED") then
            GW.LoadTargetOfUnit("Target")
        end

        -- move zone text frame
        if not IsFrameModified("ZoneTextFrame") then
            ZoneTextFrame:ClearAllPoints()
            ZoneTextFrame:SetPoint("TOP", UIParent, "TOP", 0, -175)
        end

        -- move error frame
        if not IsFrameModified("UIErrorsFrame") then
            UIErrorsFrame:ClearAllPoints()
            UIErrorsFrame:SetPoint("TOP", UIParent, "TOP", 0, -190)
            UIErrorsFrame:SetFont(STANDARD_TEXT_FONT, 14)
        end
    end

    GW.LoadMarkers()

    if GetSetting("CLASS_POWER") then
        GW.LoadClassPowers()
    end

    -- create action bars
    if GetSetting("ACTIONBARS_ENABLED") then
        GW.LoadActionBars(lm)
        GW.ExtraAB_BossAB_Setup()
    end

    -- create pet frame
    if GetSetting("PETBAR_ENABLED") then
        GW.LoadPetFrame(lm)
    end

    -- create buff frame
    if GetSetting("PLAYER_BUFFS_ENABLED") then
        GW.LoadPlayerAuras(lm)
    end

    if GetSetting("DYNAMIC_CAM") then
        SetCVar("test_cameraDynamicPitch", true)
        SetCVar("cameraKeepCharacterCentered", false)
        SetCVar("cameraReduceUnexpectedMovement", false)
        hooksecurefunc("StaticPopup_Show", function(which, text_arg1, text_arg2, data, insertedFrame)
            if which == "EXPERIMENTAL_CVAR_WARNING" then
                StaticPopup_Hide("EXPERIMENTAL_CVAR_WARNING")
            end
        end)
    else
        SetCVar("test_cameraDynamicPitch", false)
        SetCVar("cameraKeepCharacterCentered", true)
        SetCVar("cameraReduceUnexpectedMovement", true)
    end

    if GetSetting("AFK_MODE") then
        GW.loadAFKAnimation()
    end

    if GetSetting("CHATBUBBLES_ENABLED") then
        GW.LoadChatBubbles()
    end
    -- create new microbuttons
    GW.LoadMicroMenu()
    GW.LoadOrderBar()

    if GetSetting("PARTY_FRAMES") then
        GW.LoadPartyFrames()
    end

    if GetSetting("RAID_FRAMES") then
        GW.LoadRaidFrames()
    end

    GW.UpdateHudScale()

    if (forcedMABags) then
        GW.Notice(L["DISABLED_MA_BAGS"])
    end

    --Add Shared Media
    --Font
    LibSharedMedia:Register(LibSharedMedia.MediaType.FONT, "GW2_UI", "Interface/AddOns/GW2_UI/fonts/menomonia.ttf", LibSharedMedia.LOCALE_BIT_western + LibSharedMedia.LOCALE_BIT_ruRU)
    LibSharedMedia:Register(LibSharedMedia.MediaType.FONT, "GW2_UI Light", "Interface/AddOns/GW2_UI/fonts/menomonia-italic.ttf", LibSharedMedia.LOCALE_BIT_western + LibSharedMedia.LOCALE_BIT_ruRU)
    LibSharedMedia:Register(LibSharedMedia.MediaType.FONT, "GW2_UI Headlines", "Interface/AddOns/GW2_UI/fonts/headlines.ttf", LibSharedMedia.LOCALE_BIT_western + LibSharedMedia.LOCALE_BIT_ruRU)
    LibSharedMedia:Register(LibSharedMedia.MediaType.FONT, "GW2_UI", "Interface/AddOns/GW2_UI/fonts/chinese.ttf", LibSharedMedia.LOCALE_BIT_zhCN + LibSharedMedia.LOCALE_BIT_zhTW)
    LibSharedMedia:Register(LibSharedMedia.MediaType.FONT, "GW2_UI", "Interface/AddOns/GW2_UI/fonts/korean.ttf", LibSharedMedia.LOCALE_BIT_koKR)

    --Texture
    LibSharedMedia:Register(LibSharedMedia.MediaType.BACKGROUND, "GW2_UI", "Interface/AddOns/GW2_UI/Textures/windowborder.tga")
    LibSharedMedia:Register(LibSharedMedia.MediaType.BACKGROUND, "GW2_UI_2", "Interface/Addons/GW2_UI/Textures/UI-Tooltip-Background.tga")
    LibSharedMedia:Register(LibSharedMedia.MediaType.STATUSBAR, "GW2_UI_Yellow", "Interface/Addons/GW2_UI/Textures/castingbar.tga")
    LibSharedMedia:Register(LibSharedMedia.MediaType.STATUSBAR, "GW2_UI_Blue", "Interface/Addons/GW2_UI/Textures/breathmeter.tga")
    LibSharedMedia:Register(LibSharedMedia.MediaType.STATUSBAR, "GW2_UI", "Interface/Addons/GW2_UI/Textures/castinbar-white.tga")
    LibSharedMedia:Register(LibSharedMedia.MediaType.STATUSBAR, "GW2_UI_2", "Interface/Addons/GW2_UI/Textures/gwstatusbar.tga")
    LibSharedMedia:Register(LibSharedMedia.MediaType.BORDER, "GW2_UI", "Interface/Addons/GW2_UI/Textures/UI-Tooltip-Border.tga")

    --Check if we should show Welcomepage or Changelog
    if GetSetting("GW2_UI_VERSION") == "WELCOME" then
        GW.ShowWelcomePanel()
        SetSetting("GW2_UI_VERSION", GW.VERSION_STRING)
    elseif GetSetting("GW2_UI_VERSION") ~= GW.VERSION_STRING then
        GW.ShowChangelogPanel()
        SetSetting("GW2_UI_VERSION", GW.VERSION_STRING)
    end

    self:SetScript("OnUpdate", gw_OnUpdate)
end
GW.AddForProfiling("index", "loadAddon", loadAddon)

-- handles addon loading
local function gw_OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        if not loaded then
            loaded = true
            GW.CheckRole() -- some API's deliver a nil value on init.lua load, we we fill this values also here
            loadAddon(self)
        end
        GW.LoadStorage()
    elseif event == "UI_SCALE_CHANGED" and GetCVarBool("useUiScale") then
        SetSetting("PIXEL_PERFECTION", false)
        GW.scale = UIParent:GetScale()
        GW.screenwidth, GW.screenheight = GetPhysicalScreenSize()
        GW.resolution = format("%dx%d", GW.screenwidth, GW.screenheight)
        GW.border = ((1 / GW.scale) - ((1 - (768 / GW.screenHeight)) / GW.scale)) * 2
    elseif event == "PLAYER_LEAVING_WORLD" then
        GW.inWorld = false
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_ENTERING_BATTLEGROUND" then
        GW.inWorld = true
        GW.myeffectivelevel = UnitEffectiveLevel("player")
        GW.CheckRole()
        if GetSetting("PIXEL_PERFECTION") and not GetCVarBool("useUiScale") and not UnitAffectingCombat("player") then
            PixelPerfection()
        end
        C_Timer.After(0.5, function()
            if UnitInBattleground("player") == nil and not IsActiveBattlefieldArena() then
                GW.RemoveTrackerNotificationOfType("ARENA")
            end
        end)
    elseif event == "PLAYER_LEVEL_UP" then
        GW.mylevel = ...
        Debug("New level:", GW.mylevel)
    elseif event == "NEUTRAL_FACTION_SELECT_RESULT" then
        GW.myfaction, GW.myLocalizedFaction = UnitFactionGroup("player")
        Debug("New faction:", GW.myfaction, GW.myLocalizedFaction)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        GW.CheckRole()
    elseif event == "PLAYER_LEVEL_CHANGED" then
        GW.myeffectivelevel = UnitEffectiveLevel("player")
    end
end
GW.AddForProfiling("index", "gw_OnEvent", gw_OnEvent)
l:SetScript("OnEvent", gw_OnEvent)
l:RegisterEvent("PLAYER_LOGIN")
l:RegisterEvent("PLAYER_LEAVING_WORLD")
l:RegisterEvent("PLAYER_ENTERING_WORLD")
l:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
l:RegisterEvent("UI_SCALE_CHANGED")
l:RegisterEvent("PLAYER_LEVEL_UP")
l:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
l:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
l:RegisterEvent("PLAYER_LEVEL_CHANGED")

local function AddToClique(frame)
    if type(frame) == "string" then
        local frameName = frame
        frame = _G[frameName]
    end

    if frame and frame.RegisterForClicks and ClickCastFrames ~= nil then
        ClickCastFrames[frame] = true
    end
end
GW.AddToClique = AddToClique

local waitTable = {}
local waitFrame = nil
local function wait_OnUpdate(self, elapse)
    local count = #waitTable
    local i = 1
    while (i <= count) do
        local waitRecord = tremove(waitTable, i)
        local d = tremove(waitRecord, 1)
        local f = tremove(waitRecord, 1)
        local p = tremove(waitRecord, 1)
        if (d > elapse) then
            tinsert(waitTable, i, {d - elapse, f, p})
            i = i + 1
        else
            count = count - 1
            f(unpack(p))
        end
    end
end
GW.AddForProfiling("index", "wait_OnUpdate", wait_OnUpdate)

local function Wait(delay, func, ...)
    if type(delay) ~= "number" or type(func) ~= "function" then
        return false
    end
    if waitFrame == nil then
        waitFrame = CreateFrame("Frame", "GwWaitFrame", UIParent)
        waitFrame:SetScript("OnUpdate", wait_OnUpdate)
    end
    tinsert(waitTable, {delay, func, {...}})
    return true
end
GW.Wait = Wait

local function Self_Hide(self)
    self:Hide()
end
GW.Self_Hide = Self_Hide

local function Parent_Hide(self)
    self:GetParent():Hide()
end
GW.Parent_Hide = Parent_Hide
