local addonName, GW = ...
local L = GW.L
local RoundInt = GW.RoundInt
local bloodSpark = GW.BLOOD_SPARK
local CLASS_ICONS = GW.CLASS_ICONS
local IsFrameModified = GW.IsFrameModified
local IsIncompatibleAddonLoadedOrOverride = GW.IsIncompatibleAddonLoadedOrOverride
local Debug = GW.Debug
local AFP = GW.AddProfiling

local animations = GW.animations

local l = CreateFrame("Frame") -- Main event frame

GW.VERSION_STRING = "GW2_UI @project-version@"

-- Make a global GW variable , so others cann access out functions
GW2_ADDON = GW

if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
    GW.Notice("You have installed GW2_UI retail version. Please install the classic version to use GW2_UI.")
    return
end

if GW.CheckForPasteAddon() and GW.settings.ACTIONBARS_ENABLED and not IsIncompatibleAddonLoadedOrOverride("Actionbars", true) then
    GW.Notice("|cffff0000You have installed the Addon 'Paste'. This can cause, that our actionbars are empty. Deactive 'Paste' to use our actionbars.|r")
end

local loaded = false
local forcedMABags = false

local swimAnimation = 0
local lastSwimState = true
local hudArtFrame


function GW2_ADDON_AddonCompartmentOnClickFunc()
    GW.ToggleGw2Settings()
end

function GW2_ADDON_OnAddonCompartmentEnter(_, menuButtonFrame)
    GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_NONE");
    GameTooltip:SetPoint("TOPRIGHT", menuButtonFrame, "BOTTOMRIGHT", 0, 0);
    GameTooltip:ClearLines()
    GameTooltip:AddDoubleLine(addonName, C_AddOns.GetAddOnMetadata(addonName, "Version"))
    GameTooltip:Show()
end

function GW2_ADDON_OnAddonCompartmentLeave(addonName, button)
    GameTooltip:Hide();
end

local function disableMABags()
    local bags = GW.settings.BAGS_ENABLED and not IsIncompatibleAddonLoadedOrOverride("Inventory", true)
    if not bags or not MovAny or not MADB then
        return
    end
    MADB.noBags = true
    MAOptNoBags:SetEnabled(false)
    forcedMABags = true
end
AFP("disableMABags", disableMABags)

-- https://us.battle.net/forums/en/wow/topic/6036615884
if AchievementMicroButton_Update == nil then
    function AchievementMicroButton_Update()
        return
    end
end

local function AddToAnimation(name, from, to, start, duration, method, easeing, onCompleteCallback, doCompleteOnOverider)
    local newAnimation = true
    if animations[name] then
        newAnimation = (animations[name].start + animations[name].duration) > GetTime()
    end
    if not doCompleteOnOverider then
        newAnimation = true
    end

    if not newAnimation then
        animations[name].duration = duration
        animations[name].to = to
        animations[name].progress = 0
        animations[name].method = method
        animations[name].completed = false
        animations[name].easeing = easeing
        animations[name].onCompleteCallback = onCompleteCallback
    else
        animations[name] = {}
        animations[name].start = start
        animations[name].duration = duration
        animations[name].from = from
        animations[name].to = to
        animations[name].progress = 0
        animations[name].method = method
        animations[name].completed = false
        animations[name].easeing = easeing
        animations[name].onCompleteCallback = onCompleteCallback
    end
end
GW.AddToAnimation = AddToAnimation

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
    --local tilesPerRow = map.height / tileHeight

    local left = tileWidth * (index % tilesPerColums)
    local top =  tileHeight * math.floor(index / tilesPerColums)

    local bottom = top + tileHeight
    local right = left + tileWidth

    return left / map.width, right / map.width, top / map.height,bottom / map.height
end
GW.getSpriteByIndex = getSpriteByIndex

local function TriggerButtonHoverAnimation(self, hover, to, duration)
    local name = tostring(self)
    hover:SetAlpha(1)
    duration = duration or math.min(1, self:GetWidth() * 0.002)
    AddToAnimation(
        name,
        self.animationValue,
        (to or 1),
        GetTime(),
        duration,
        function(p)
            local w = self:GetWidth()

            local lerp = GW.lerp(0, w + (w * 0.5), p)
            local lerp2 = math.min(1, math.max(0.4, math.min(1, GW.lerp(0.4, 1, p))))
            local stripAmount = 1 - math.max(0, (lerp / w) - 1)
            if self.limitHoverStripAmount then
                stripAmount = math.max(self.limitHoverStripAmount, stripAmount)
            end

            hover:SetPoint("RIGHT", self, "LEFT", math.min(w, lerp) , 0)
            hover:SetVertexColor(hover.r or 1, hover.g or 1, hover.b or 1, lerp2)
            hover:SetTexCoord(0, stripAmount, 0, 1)
        end
    )
end
GW.TriggerButtonHoverAnimation = TriggerButtonHoverAnimation

function GwStandardButton_OnEnter(self)
    if not self.hover or (self.IsEnabled and not self:IsEnabled()) then
        return
    end
    self.animationValue = self.hover.skipHover and 1 or 0

    TriggerButtonHoverAnimation(self, self.hover)
end

function GwStandardButton_OnLeave(self)
    if not self.hover or (self.IsEnabled and not self:IsEnabled()) then
        return
    end
    if self.hover.skipHover then return end
    self.hover:SetAlpha(1)
    self.animationValue = 1

    TriggerButtonHoverAnimation(self, self.hover, 0, 0.1)
end

local function barAnimation(self, barWidth, sparkWidth)
    local snap = (animations[self.animationName].progress * 100) / 5

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
AFP("barAnimation", barAnimation)

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

local function StopAnimation(name)
    if animations[name] then
        animations[name].completed = true
        return true
    end

    return false
end
GW.StopAnimation = StopAnimation

local function swimAnim()
    local r, g, b = hudArtFrame.actionBarHud.RightSwim:GetVertexColor()
    hudArtFrame.actionBarHud.RightSwim:SetVertexColor(r, g, b, animations.swimAnimation.progress)
    hudArtFrame.actionBarHud.LeftSwim:SetVertexColor(r, g, b, animations.swimAnimation.progress)
end
AFP("swimAnim", swimAnim)

local updateCB = {}
local function AddUpdateCB(func, payload)
    if type(func) ~= "function" then
        return
    end

    tinsert(updateCB,{func = func, payload = payload})
end
GW.AddUpdateCB = AddUpdateCB

local function gw_OnUpdate(_, elapsed)
    local foundAnimation = false
    local count = 0
    local time = GetTime()
    for _, v in pairs(animations) do
        count = count + 1
        if v.completed == false and time >= (v.start + v.duration) then
            if v.easeing == nil then
                v.progress = GW.lerp(v.from, v.to, math.sin(1 * math.pi * 0.5))
            else
                v.progress = GW.lerp(v.from, v.to, 1)
            end
            if v.method then
                v.method(v.progress)
            end

            if v.onCompleteCallback then
                v.onCompleteCallback()
            end

            v.completed = true
            foundAnimation = true
        end
        if v.completed == false then
            if v.easeing == nil then
                v.progress = GW.lerp(v.from, v.to, math.sin((time - v.start) / v.duration * math.pi * 0.5))
            else
                v.progress = GW.lerp(v.from, v.to, (time - v.start) / v.duration)
            end
            v.method(v.progress)
            foundAnimation = true
        end
    end

    if not foundAnimation and count > 0 then
        table.wipe(animations)
    end

    --Swim hud
    if lastSwimState ~= IsSwimming() then
        if IsSwimming() then
            AddToAnimation("swimAnimation", swimAnimation, 1, time, 0.1, swimAnim)
            swimAnimation = 1
        else
            AddToAnimation("swimAnimation", swimAnimation, 0, time, 3.0, swimAnim)
            swimAnimation = 0
        end
        lastSwimState = IsSwimming()
    end

    for _, cb in ipairs(updateCB) do
        cb.func(cb.payload, elapsed)
    end
end
AFP("gw_OnUpdate", gw_OnUpdate)

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
    local hudScale = tonumber(GW.settings.HUD_SCALE) or 1
    for _, f in ipairs(SCALE_HUD_FRAMES) do
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
        if not mf.parent.isMoved and mf:GetScale() ~= hudScale then
            mf.parent:SetScale(hudScale)
            mf:SetScale(hudScale)
            GW.settings[mf.setting .. "_scale"] = hudScale
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

-- Functions to run when various addons load. Registering these
-- works on the honor system for now; don't blow away a prior hook :)
-- Primarily for on-demand addons; if the addon has already loaded
-- (based on the cond arg), the hook will run immediately.
local function errorhandler(err)
    return geterrorhandler()(err)
end

local addonLoadHooks = {}
local function RegisterLoadHook(func, name, cond)
    if not func or type(func) ~= "function" or not name or type(name) ~= "string" then
        return
    end
    if cond then
        func(l)
    else
        addonLoadHooks[name] = func
    end
end
GW.RegisterLoadHook = RegisterLoadHook

local function hookOmniCDLoad()
    local func = OmniCD and OmniCD.AddUnitFrameData
    if func then
        func("GW2_UI-Party", "GwPartyFrame", "unit", 1)
        func("GW2_UI-Raid40", "GW2_Raid40Group%dUnitButton", "unit", 1, nil, 5)
        func("GW2_UI-Raid40-RWS", "GW2_Raid40Group%dUnitButton", "unit", 1, nil, 40) -- 'Raid Wide Sorting'
        func("GW2_UI-Raid25", "GW2_Raid25Group%dUnitButton", "unit", 1, nil, 5)
        func("GW2_UI-Raid25-RWS", "GW2_Raid25Group%dUnitButton", "unit", 1, nil, 25) -- 'Raid Wide Sorting'
        func("GW2_UI-Raid10", "GW2_Raid10Group%dUnitButton", "unit", 1, nil, 5)
        func("GW2_UI-Raid10-RWS", "GW2_Raid10Group%dUnitButton", "unit", 1, nil, 10) -- 'Raid Wide Sorting'
        func("GW2_UI-Party-Grid", "GW2_RaidPetGroup1UnitButton", "unit", 1, nil, 40)
        func("GW2_UI-RaidPet", "GW2_PartyGroup1UnitButton", "unit", 1, nil, 5)
        func("GW2_UI-Maintank", "GW2_MaintankGroup1UnitButton", "unit", 1, nil, 5)
    end
end
AFP("hookOmniCDLoad", hookOmniCDLoad)
RegisterLoadHook(hookOmniCDLoad, "OmniCD", OmniCD)

local function UpdateDb()
    GW.settings = GW.globalSettings.profile
end

local function evAddonLoaded(self, addonName)
    if addonName ~= "GW2_UI" then
        local loadHook = addonLoadHooks[addonName]
        if loadHook and type(loadHook) == "function" then
            Debug("run load hook for addon", addonName)
            xpcall(loadHook, errorhandler)
            addonLoadHooks[addonName] = nil
        end
        return
    else
        -- init databse
        GW.globalSettings = GW.Libs.AceDB:New('GW2UI_DATABASE', GW.globalDefault, true)
        GW.globalSettings.RegisterCallback(self, 'OnProfileChanged', UpdateDb)
        GW.settings = GW.globalSettings.profile
        GW.global = GW.globalSettings.global

        GW.charSettings = GW.Libs.AceDB:New('GW2UI_PRIVATE_DB', GW.privateDefaults)
        GW.private = GW.charSettings.profile

        -- setup default values on load, which are required for same skins
        if GW.settings.PIXEL_PERFECTION and not GetCVarBool("useUiScale") then
            PixelPerfection()
            GW.Notice("Pixel Perfection-Mode enabled. UIScale down to perfect pixel size. Can be deactivated in HUD settings. |cFF00FF00/gw2|r")
        else
            GW.scale = UIParent:GetScale()
            GW.border = ((1 / GW.scale) - ((1 - (768 / GW.screenHeight)) / GW.scale)) * 2
        end
        GW.mult = (1 / GW.scale) - ((1 - (768 / GW.screenHeight)) / GW.scale)
    end

    Debug("OK~EVENT~In ADDON_LOADED event")

    GW.LoadStorage()
    -- TODO: A lot of what happens in player login should probably happen here instead

    -- check for DeModal
    local _, _, _, enabled, _ = C_AddOns.GetAddOnInfo("DeModal")
    if enabled then
        GW.HasDeModal = true
    else
        GW.HasDeModal = false
    end
    Debug("DeModal status:", GW.HasDeModal)

    -- TODO: moving skinning from player login to here
    -- Skins: BLizzard & Addons
    GW.LoadWorldMapSkin()
    GW.LoadEncounterJournalSkin()
    GW.LoadAchivementSkin()
    GW.LoadAlliedRacesUISkin()
    GW.LoadBarShopUISkin()
    GW.LoadChromieTimerSkin()
    GW.LoadCovenantSanctumSkin()
    GW.LoadDeathRecapSkin()
    GW.LoadFlightMapSkin()
    GW.LoadInspectFrameSkin()
    GW.LoadItemUpgradeSkin()
    GW.LoadLFGSkin()
    GW.LoadMacroOptionsSkin()
    GW.LoadOrderHallTalentFrameSkin()
    GW.LoadSocketUISkin()
    GW.LoadSoulbindsSkin()
    GW.LoadWeeklyRewardsSkin()
    GW.LoadPerksProgramSkin()
    GW.preLoadStatusBarMaskTextures()

  --  GW.LoadStatusbarTest()
end
AFP("evAddonLoaded", evAddonLoaded)

local function evNeutralFactionSelectResult()
    GW.myfaction, GW.myLocalizedFaction = UnitFactionGroup("player")
    Debug("OK~EVENT~New faction:", GW.myfaction, GW.myLocalizedFaction)
end
AFP("evNeutralFactionSelectResult", evNeutralFactionSelectResult)

local function evPlayerSpecializationChanged()
    GW.CheckRole()
end
AFP("evPlayerSpecializationChanged", evPlayerSpecializationChanged)

local function evUiScaleChanged()
    if not GetCVarBool("useUiScale") then
        return
    end
    GW.settings.PIXEL_PERFECTION = false
    GW.scale = UIParent:GetScale()
    GW.screenwidth, GW.screenheight = GetPhysicalScreenSize()
    GW.resolution = format("%dx%d", GW.screenwidth, GW.screenheight)
    GW.border = ((1 / GW.scale) - ((1 - (768 / GW.screenHeight)) / GW.scale)) * 2
end
AFP("evUiScaleChanged", evUiScaleChanged)

local function evPlayerLevelUp(_, newLevel)
    GW.mylevel = newLevel
    Debug("OK~EVENT~New level:", newLevel)
end
AFP("evPlayerLevelUp", evPlayerLevelUp)

local function evPlayerLeavingWorld()
    GW.inWorld = false
end
AFP("evPlayerLeavingWorld", evPlayerLeavingWorld)

local function commonEntering()
    GW.inWorld = true
    GW.CheckRole()
    if GW.settings.PIXEL_PERFECTION and not GetCVarBool("useUiScale") and not UnitAffectingCombat("player") then
        PixelPerfection()
    end
    C_Timer.After(0.5, function()
        if UnitInBattleground("player") == nil and not IsActiveBattlefieldArena() then
            GW.RemoveTrackerNotificationOfType("ARENA")
        end
    end)
end

local migrationDone = false
local function evPlayerEnteringWorld()
    commonEntering()

    -- do migration one on first login
    if not migrationDone then
        --migration things
        GW.Migration()
        migrationDone = true
    end

    local dbMigrated = false
    if not GW.private.dbConverted then
        GW.DatabaseMigration(false, true)
        GW.private.dbConverted = true
        dbMigrated = true
    end
    if not GW.global.dbConverted then
        GW.DatabaseMigration(true, false)
        GW.global.dbConverted = true
        dbMigrated = true
    end

    if dbMigrated then
        C_Timer.After(3, function() GW.WarningPrompt(
            L["DB was converted Reload is needed /reload"],
                function() C_UI.Reload() end
            )
        end)
        GW.Notice("DB was converted Reload is needed /reload")
    end
end
AFP("evPlayerEnteringWorld", evPlayerEnteringWorld)

local function evPlayerEnteringBattleground()
    commonEntering()
end
AFP("evPlayerEnteringBattleground", evPlayerEnteringBattleground)

local function evPlayerLogin(self)
    Debug("OK~EVENT~PLAYER_LOGIN; loaded:", loaded)
    if loaded then
        GW.UpdateCharData()
        return
    end

    -- Remove old debuffs from db
    GW.RemoveOldRaidDebuffsFormProfiles()
    GW.DisableBlizzardFrames()

    loaded = true
    GW.CheckRole() -- some API's deliver a nil value on init.lua load, we we fill this values also here

    if GW.inDebug then
        GW.AlertTestsSetup()
    end
    GW.CombatQueue_Initialize()

    --Create the mainbar layout manager
    local lm = GW.LoadMainbarLayout()

    --Create Settings window
    GW.LoadMovers(lm.layoutFrame)
    GW.LoadSettings()

    -- load alert settings
    GW.LoadAlertSystem()
    GW.SetupAlertFramePosition()
    GW.LoadOurAlertSubSystem()

    -- disable Move Anything bag handling
    disableMABags()

    -- Load Slash commands
    GW.LoadSlashCommands()

    -- Misc
    GW.InitializeMiscFunctions()
    GW.LoadRaidMarkerCircle()

    --Create general skins
    if GW.settings.MAINMENU_SKIN_ENABLED then
        GW.SkinMainMenu()
    else
        --Setup addon button
        local GwMainMenuFrame = CreateFrame("Button", "GW2_UI_SettingsButton", _G.GameMenuFrame, "GameMenuButtonTemplate") -- add a button name to you that for other Addons
        GwMainMenuFrame:SetText(format(("*%s|r"):gsub("*", GW.Gw2Color), GW.addonName))
        GwMainMenuFrame:SetScript( "OnClick", GW.ToggleGw2Settings)
        GameMenuFrame[GW.addonName] = GwMainMenuFrame

        if not C_AddOns.IsAddOnLoaded("ConsolePortUI_Menu") then
            GwMainMenuFrame:SetSize(GameMenuButtonMacros:GetWidth(), GameMenuButtonMacros:GetHeight())
            GwMainMenuFrame:SetPoint("TOPLEFT", GameMenuButtonUIOptions, "BOTTOMLEFT", 0, -1)
            hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", GW.PositionGameMenuButton)
        end
    end

    -- Skins: BLizzard & Addons
    GW.LoadStaticPopupSkin()
    GW.LoadBNToastSkin()
    GW.LoadDropDownSkin()
    GW.LoadLFGSkins()
    GW.LoadReadyCheckSkin()
    GW.LoadTalkingHeadSkin()
    GW.LoadMiscBlizzardFrameSkins()
    GW.LoadAddonListSkin()
    GW.LoadMailSkin()
    GW.LoadDressUpFrameSkin()
    GW.LoadHelperFrameSkin()
    GW.LoadGossipSkin()
    GW.LoadTimeManagerSkin()
    GW.LoadMerchantFrameSkin()
    GW.LoadLootFrameSkin()
    GW.LoadExpansionLadningPageSkin()
    GW.LoadGenericTraitFrameSkin()

    GW.LoadDetailsSkin()
    GW.LoadImmersionAddonSkin()
    GW.AddMasqueSkin()

    GW.SkinAndEnhanceColorPicker()
    GW.AddCoordsToWorldMap()
    GW.MakeAltPowerBarMovable()
    GW.WidgetUISetup()

    --Create hud art
    hudArtFrame = GW.LoadHudArt()

    --Create experiencebar
    if GW.settings.XPBAR_ENABLED then
        GW.LoadXPBar()
    else
        hudArtFrame.actionBarHud:ClearAllPoints()
        hudArtFrame.actionBarHud:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)

        hudArtFrame.edgeTintBottomCornerLeft:ClearAllPoints()
        hudArtFrame.edgeTintBottomCornerLeft:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
        hudArtFrame.edgeTintBottomCornerRight:ClearAllPoints()
        hudArtFrame.edgeTintBottomCornerRight:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    end

    if GW.settings.FONTS_ENABLED then
        GW.LoadFonts()
    end

    if not IsIncompatibleAddonLoadedOrOverride("FloatingCombatText", true) then -- Only touch this setting if no other addon for this is loaded
        if GW.settings.GW_COMBAT_TEXT_MODE == "GW2" then
            C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
            if GW.settings.GW_COMBAT_TEXT_SHOW_HEALING_NUMBERS then
                C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
            else
                C_CVar.SetCVar("floatingCombatTextCombatHealing", "1")
            end
            GW.LoadDamageText(true)
        elseif GW.settings.GW_COMBAT_TEXT_MODE == "BLIZZARD" then
            C_CVar.SetCVar("floatingCombatTextCombatDamage", "1")
            C_CVar.SetCVar("floatingCombatTextCombatHealing", "1")
        else
            C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
            C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
        end
    end

    if GW.settings.CASTINGBAR_ENABLED then
        GW.LoadCastingBar("GwCastingBarPlayer", "player", true)
        GW.LoadCastingBar("GwCastingBarPet", "pet", false)
    end

    if GW.settings.MINIMAP_ENABLED and not IsIncompatibleAddonLoadedOrOverride("Minimap", true) then
        GW.LoadMinimap()
    else
        QueueStatusButton:ClearAllPoints()
        QueueStatusButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)
        QueueStatusButton:SetSize(26, 26)
        QueueStatusButton:SetParent(UIParent)
    end

    if GW.settings.QUESTTRACKER_ENABLED and not IsIncompatibleAddonLoadedOrOverride("Objectives", true) then
        GW.LoadQuestTracker()
    end

    if GW.settings.TOOLTIPS_ENABLED then
        GW.LoadTooltips()
    end

    if GW.settings.QUESTVIEW_ENABLED and not IsIncompatibleAddonLoadedOrOverride("ImmersiveQuesting", true) then
        GW.LoadQuestview()
    end

    if GW.settings.CHATFRAME_ENABLED then
        GW.LoadChat()
    end

    --Create player hud
    if GW.settings.HEALTHGLOBE_ENABLED and not GW.settings.PLAYER_AS_TARGET_FRAME then
        local hg = GW.LoadHealthGlobe()
        GW.LoadDodgeBar(hg, false)
        GW.LoadDragonBar(hg, false)
    elseif GW.settings.HEALTHGLOBE_ENABLED and GW.settings.PLAYER_AS_TARGET_FRAME then
        local hg = GW.LoadPlayerFrame()
        GW.LoadDodgeBar(hg, true)
        GW.LoadDragonBar(hg, true)
    end

    if GW.settings.POWERBAR_ENABLED and (GW.settings.PLAYER_AS_TARGET_FRAME and GW.settings.PLAYER_AS_TARGET_FRAME_SHOW_RESSOURCEBAR or not GW.settings.PLAYER_AS_TARGET_FRAME) then
        GW.LoadPowerBar()
    end

    if not IsIncompatibleAddonLoadedOrOverride("Inventory", true) then -- Only touch this setting if no other addon for this is loaded
        if GW.settings.BAGS_ENABLED then
            GW.LoadInventory()
        end
    end

    GW.SetUpExtendedVendor()

    if GW.settings.USE_BATTLEGROUND_HUD then
        GW.LoadBattlegrounds()
    end

    GW.LoadCharacter()

    GW.LoadSocialFrame()

    GW.Create_Raid_Counter()
    GW.LoadRaidbuffReminder()

    GW.LoadMirrorTimers()
    GW.LoadAutoRepair()
    GW.LoadDragonFlightWorldEvents()

    --Create unitframes
    if GW.settings.FOCUS_ENABLED then
        GW.LoadFocus()
        if GW.settings.focus_TARGET_ENABLED then
            GW.LoadTargetOfUnit("Focus")
        end
    end
    if GW.settings.TARGET_ENABLED then
        GW.LoadTarget()
        if GW.settings.target_TARGET_ENABLED then
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
            UIErrorsFrame:SetFont(STANDARD_TEXT_FONT, 14, "")
        end
    end

    GW.LoadMarkers()

    if GW.settings.CLASS_POWER then
        GW.LoadClassPowers()
    end

    -- create action bars
    if GW.settings.ACTIONBARS_ENABLED and not IsIncompatibleAddonLoadedOrOverride("Actionbars", true) then
        GW.LoadActionBars(lm)
        GW.ExtraAB_BossAB_Setup()
    end

    -- create pet frame
    if GW.settings.PETBAR_ENABLED then
        GW.LoadPetFrame(lm)
    end

    -- create buff frame
    if GW.settings.PLAYER_BUFFS_ENABLED then
        GW.LoadPlayerAuras(lm)
    end

    if not IsIncompatibleAddonLoadedOrOverride("DynamicCam", true) then -- Only touch this setting if no other addon for this is loaded
        if GW.settings.DYNAMIC_CAM then
            C_CVar.SetCVar("test_cameraDynamicPitch", "1")
            C_CVar.SetCVar("cameraKeepCharacterCentered", "0")
            C_CVar.SetCVar("cameraReduceUnexpectedMovement", "0")
        end
        hooksecurefunc("StaticPopup_Show", function(which)
            if which == "EXPERIMENTAL_CVAR_WARNING" then
                StaticPopup_Hide("EXPERIMENTAL_CVAR_WARNING")
            end
        end)
    end

    GW.loadAFKAnimation()

    if GW.settings.CHATBUBBLES_ENABLED then
        GW.LoadChatBubbles()
    end
    -- create new microbuttons
    GW.LoadMicroMenu()
    GW.LoadOrderBar()

    if GW.settings.PARTY_FRAMES then
        GW.LoadPartyFrames()
    end

    if GW.settings.RAID_FRAMES then
        GW.InitializeRaidFrames()
    end

    GW.UpdateHudScale()

    if (forcedMABags) then
        GW.Notice(L["MoveAnything bag handling disabled."])
    end

    --Check if we should show Welcomepage or Changelog
    if GW.private.GW2_UI_VERSION == "WELCOME" then
        GW.ShowWelcomePanel()
        GW.private.GW2_UI_VERSION = GW.VERSION_STRING
    elseif GW.private.GW2_UI_VERSION ~= GW.VERSION_STRING then
        ShowUIPanel(GwSettingsWindow)
        --UIFrameFadeIn(GwSettingsWindow, 0.2, 0, 1)
        HideUIPanel(GameMenuFrame)
        GW.private.GW2_UI_VERSION = GW.VERSION_STRING
    end

    self:SetScript("OnUpdate", gw_OnUpdate)
    GW.UpdateCharData()

    GW.HandleBlizzardEditMode()
end
AFP("evPlayerLogin", evPlayerLogin)

-- generic event router
local function gw_OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        evPlayerLogin(self)
    elseif event == "UI_SCALE_CHANGED" then
        C_Timer.After(0, evUiScaleChanged) -- We need one frame time for setting the cvar values
    elseif event == "PLAYER_LEAVING_WORLD" then
        evPlayerLeavingWorld()
    elseif event == "PLAYER_ENTERING_WORLD" then
        evPlayerEnteringWorld()
    elseif event == "PLAYER_ENTERING_BATTLEGROUND" then
        evPlayerEnteringBattleground()
    elseif event == "PLAYER_LEVEL_UP" then
        evPlayerLevelUp(self, ...)
    elseif event == "NEUTRAL_FACTION_SELECT_RESULT" then
        evNeutralFactionSelectResult()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        evPlayerSpecializationChanged()
    elseif event == "ADDON_LOADED" then
        evAddonLoaded(self, ...)
    end
end
AFP("gw_OnEvent", gw_OnEvent)
l:SetScript("OnEvent", gw_OnEvent)
l:RegisterEvent("PLAYER_LOGIN")
l:RegisterEvent("PLAYER_LEAVING_WORLD")
l:RegisterEvent("PLAYER_ENTERING_WORLD")
l:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
l:RegisterEvent("UI_SCALE_CHANGED")
l:RegisterEvent("PLAYER_LEVEL_UP")
l:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
l:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
l:RegisterEvent("ADDON_LOADED")

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
local function wait_OnUpdate(_, elapse)
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
AFP("wait_OnUpdate", wait_OnUpdate)

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
