---@class GW2
local GW = select(2, ...)
local addonName = ...
local L = GW.L
local IsFrameModified = GW.IsFrameModified
local Debug = GW.Debug

local sin = math.sin
local pi = math.pi
local GetTime = GetTime
local min = math.min
local max = math.max

local animations = GW.animations

local l = CreateFrame("Frame") -- Main event frame

if GW.CheckForPasteAddon() and GW.settings.actionbars.enabled and not GW.ShouldBlockIncompatibleAddon("Actionbars") then
    GW.Notice("|cffff0000You have installed the Addon 'Paste'. This can cause, that our actionbars are empty. Deactive 'Paste' to use our actionbars.|r")
end

local loaded = false
local forcedMABags = false

local swimAnimation = 0
local lastSwimState = true
local hudArtFrame
local mainbarLM -- mainbar layout manager, created in the first login stage, consumed by the second


if GW.isModern then
    function GW2_ADDON_AddonCompartmentOnClickFunc()
        GW.ToggleGw2Settings()
    end
    function GW2_ADDON_OnAddonCompartmentEnter(_, menuButtonFrame)
        GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_NONE");
        GameTooltip:SetPoint("TOPRIGHT", menuButtonFrame, "BOTTOMRIGHT", 0, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(addonName, GW.GetVersionString())
        GameTooltip:Show()
    end

    function GW2_ADDON_OnAddonCompartmentLeave(_, _)
        GameTooltip:Hide()
    end
end

local function disableMABags()
    local bags = GW.settings.bags.enabled and not GW.ShouldBlockIncompatibleAddon("Inventory")
    if not bags or not MovAny or not MADB then
        return
    end
    MADB.noBags = true
    MAOptNoBags:SetEnabled(false)
    forcedMABags = true
end

local function disableTitanPanelBarAdjusting()
    local ourBars = GW.settings.actionbars.enabled
    if ourBars and C_AddOns.IsAddOnLoaded("TitanClassic") and TitanUtils_AddonAdjust then
        TitanUtils_AddonAdjust("MultiBarRight", true)
        TitanUtils_AddonAdjust("ExtraActionBarFrame", true)
        TitanUtils_AddonAdjust("MinimapCluster", true)
    end
end

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

local function StopAnimation(name)
    if animations[name] then
        animations[name].completed = true
        return true
    end

    return false
end
GW.StopAnimation = StopAnimation

local function TriggerButtonHoverAnimation(self, hover, to, duration)
    local name = self.animationName or (self.GetDebugName and self:GetDebugName()) or tostring(self)
    hover:SetAlpha(1)
    duration = duration or min(1, self:GetWidth() * 0.002)
    AddToAnimation(
        name,
        self.animationValue or 0,
        (to or 1),
        GetTime(),
        duration,
        function(p)
            local w = self:GetWidth()
            local lerp = GW.lerp(0, w + (w * 0.5), p)
            local lerp2 = min(1, max(0.4, GW.lerp(0.4, 1, p)))
            local stripAmount = 1 - max(0, (lerp / w) - 1)
            if self.limitHoverStripAmount then
                stripAmount = max(self.limitHoverStripAmount, stripAmount)
            end

            hover:SetPoint("RIGHT", self, "LEFT", min(w, lerp) , 0)
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


local function swimAnim()
    local r, g, b = hudArtFrame.actionBarHud.RightSwim:GetVertexColor()
    hudArtFrame.actionBarHud.RightSwim:SetVertexColor(r, g, b, animations.swimAnimation.progress)
    hudArtFrame.actionBarHud.LeftSwim:SetVertexColor(r, g, b, animations.swimAnimation.progress)
end

local updateCB = {}
local function AddUpdateCB(func, payload, interval)
    if type(func) ~= "function" then
        return
    end

    tinsert(updateCB, {func = func, payload = payload, interval = interval or 0, elapsed = 0})
end
GW.AddUpdateCB = AddUpdateCB

local completedAnimations = {} -- reused scratch list to avoid per-frame allocation
local swimStateElapsed = 0
local function gw_OnUpdate(_, elapsed)
    if next(animations) then
        local time = GetTime()
        local completedCount = 0

        for name, animation in pairs(animations) do
            if animation.completed then
                completedCount = completedCount + 1
                completedAnimations[completedCount] = name
            elseif time >= (animation.start + animation.duration) then
                local t = animation.easeing and 1 or sin(pi * 0.5)
                animation.progress = GW.lerp(animation.from, animation.to, t)

                if animation.method then
                    animation.method(animation.progress)
                end

                if animation.onCompleteCallback then
                    animation.onCompleteCallback()
                end

                completedCount = completedCount + 1
                completedAnimations[completedCount] = name
            else
                local t = animation.easeing and ((time - animation.start) / animation.duration) or sin((time - animation.start) / animation.duration * pi * 0.5)
                animation.progress = GW.lerp(animation.from, animation.to, t)

                if animation.method then
                    animation.method(animation.progress)
                end
            end
        end

        for i = 1, completedCount do
            animations[completedAnimations[i]] = nil
            completedAnimations[i] = nil
        end
    end

    --Swim hud
    swimStateElapsed = swimStateElapsed + elapsed
    if swimStateElapsed >= 0.2 then
        swimStateElapsed = 0
        local swimming = IsSwimming()
        if lastSwimState ~= swimming then
            local time = GetTime()
            if swimming then
                AddToAnimation("swimAnimation", swimAnimation, 1, time, 0.1, swimAnim)
                swimAnimation = 1
            else
                AddToAnimation("swimAnimation", swimAnimation, 0, time, 3.0, swimAnim)
                swimAnimation = 0
            end
            lastSwimState = swimming
        end
    end

    for _, cb in ipairs(updateCB) do
        if cb.interval > 0 then
            cb.elapsed = cb.elapsed + elapsed
            if cb.elapsed >= cb.interval then
                cb.func(cb.payload, cb.elapsed)
                cb.elapsed = 0
            end
        else
            cb.func(cb.payload, elapsed)
        end
    end
end


local function getBestPixelScale()
    return max(0.4, min(1.15, 768 / GW.screenHeight))
end
GW.getBestPixelScale = getBestPixelScale

local function PixelPerfection()
    if GW.settings.general.pixelPerfection and not GetCVarBool("useUiScale") then
        GW.scale = getBestPixelScale()
        GW.border = ((1 / GW.scale) - ((1 - (768 / GW.screenHeight)) / GW.scale)) * 2
        UIParent:SetScale(GW.scale)
    end
end
GW.PixelPerfection = PixelPerfection

local SCALE_HUD_FRAMES = {}
local function UpdateHudScale()
    local hudScale = tonumber(GW.settings.hud.scale) or 1
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
            GW.GetSetting(mf.setting).scale = hudScale
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
-- keeps all callbacks registered for the same addon name.
-- Primarily for on-demand addons; if the addon has already loaded
-- (based on the cond arg), the hook will run immediately.
-- !BugGrabber keeps ten errors per second and drops everything past that without a word (the
-- chat warning only exists in its standalone mode). Its budget refills with GetTime, which
-- stands still on the loading screen, so a login with many errors keeps exactly ten and loses
-- the rest - the very errors a client port needs to see. BugGrabber flags itself paused when
-- it drops one, then the error is stored through its public api ourselves, with the stack and
-- locals it would have taken, and BugSack is told about it like for any other error
local function storeDroppedError(err)
    if not (BugGrabber and BugGrabber.IsPaused and BugGrabber:IsPaused() and BugGrabber.StoreError) then
        return
    end
    local message = tostring(err)
    local db = BugGrabber:GetDB()
    local errorObject
    for i = #db, 1, -1 do
        if db[i].message == message then
            errorObject = db[i]
            break
        end
    end
    if errorObject then
        errorObject.counter = (errorObject.counter or 0) + 1
        errorObject.time = time()
    else
        errorObject = {
            message = message,
            session = BugGrabber:GetSessionId(),
            time = time(),
            counter = 1,
        }
        BugGrabber:StoreError(errorObject)
        -- the handlers run before the stack unwinds: level 1 is this function, 2 the error
        -- handler, 3 the function that raised the error
        errorObject.stack = debugstack(3, 20, 5)
        if debuglocals then
            local ok, locals = pcall(debuglocals, 3)
            errorObject.locals = ok and locals or nil
        end
    end
    if EventRegistry then
        EventRegistry:TriggerEvent("BugGrabber.BugGrabbed", tostring(errorObject))
    end
end

local function errorhandler(err)
    local result = geterrorhandler()(err)
    storeDroppedError(err)
    return result
end
GW.ErrorHandler = errorhandler

-- runs one login step in its own protected call: an error still goes to the error handler
-- (bugsack, the blizzard error frame) exactly like before, but it no longer aborts the rest of
-- the login. One broken module - or a client bug like the forever beta losing its secure
-- snippet compiler - then only takes that module down, not the whole ui. Returns what the
-- step returned, nil when it failed
local function loadStep(fn, ...)
    if type(fn) ~= "function" then
        -- a module this flavor does not load: name the calling line, xpcall(nil) would not
        errorhandler("login step is not a function (nil on this client): " .. debugstack(2, 1, 0))
        return
    end
    local ok, result = xpcall(fn, errorhandler, ...)
    if ok then
        return result
    end
end

local addonLoadHooks = {}
local function RegisterLoadHook(func, name, cond)
    if not func or type(func) ~= "function" or not name or type(name) ~= "string" then
        return
    end
    if cond then
        func(l)
    else
        if not addonLoadHooks[name] then
            addonLoadHooks[name] = {}
        end
        addonLoadHooks[name][#addonLoadHooks[name] + 1] = func
    end
end
GW.RegisterLoadHook = RegisterLoadHook

local function UpdateDb()
    GW.settings = GW.globalSettings.profile
    GW.DatabaseValueMigration()
    GW.UpdateUnitFrameReactionColors()
end

local function evAddonLoaded(self, loadedAddonName)
    if loadedAddonName ~= "GW2_UI" then
        local loadHooks = addonLoadHooks[loadedAddonName]
        if loadHooks then
            Debug("run load hook for addon", loadedAddonName)
            for _, loadHook in ipairs(loadHooks) do
                xpcall(loadHook, errorhandler)
            end
            addonLoadHooks[loadedAddonName] = nil
        end
        return
    else
        -- init databse
        GW.globalSettings = GW.Libs.AceDB:New('GW2UI_DATABASE', GW.globalDefault, true)
        GW.globalSettings.RegisterCallback(self, 'OnProfileChanged', UpdateDb)
        GW.settings = GW.globalSettings.profile
        GW.global = GW.globalSettings.global
        GW.global.chars = GW.global.chars or {}

        GW.charSettings = GW.Libs.AceDB:New('GW2UI_PRIVATE_DB', GW.privateDefaults)
        GW.private = GW.charSettings.profile

        GW.DatabaseValueMigration()
        GW.LayoutMigration()
        GW.ApplyMissingIncompatibleAddonsDefaults()
        GW.UpdateUnitFrameReactionColors()
        GW.UpdateGw2ClassColors()

        -- setup default values on load, which are required for same skins
        if GW.settings.general.pixelPerfection and not GetCVarBool("useUiScale") then
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
    local _, _, _, enabled = C_AddOns.GetAddOnInfo("DeModal")
    GW.HasDeModal = enabled
    Debug("DeModal status:", GW.HasDeModal)

    -- Skins: BLizzard & Addons
    GW.PreloadStatusBarMaskTextures()
end


local function evNeutralFactionSelectResult()
    GW.myfaction, GW.myLocalizedFaction = UnitFactionGroup("player")
    Debug("OK~EVENT~New faction:", GW.myfaction, GW.myLocalizedFaction)
end


local function evPlayerSpecializationChanged()
    GW.CheckRole()
end


local function evUiScaleChanged()
    if not GetCVarBool("useUiScale") then
        return
    end
    GW.settings.general.pixelPerfection = false
    GW.scale = UIParent:GetScale()
    GW.screenwidth, GW.screenheight = GetPhysicalScreenSize()
    GW.resolution = format("%dx%d", GW.screenwidth, GW.screenheight)
    GW.border = ((1 / GW.scale) - ((1 - (768 / GW.screenHeight)) / GW.scale)) * 2
end


local function evPlayerLevelUp(_, newLevel)
    GW.mylevel = newLevel
    Debug("OK~EVENT~New level:", newLevel)
end


local function evPlayerLeavingWorld()
    GW.inWorld = false
end


local function commonEntering()
    GW.inWorld = true
    GW.CheckRole()
    if GW.settings.general.pixelPerfection and not GetCVarBool("useUiScale") and not UnitAffectingCombat("player") then
        PixelPerfection()
    end
    C_Timer.After(0.5, function()
        if UnitInBattleground("player") == nil and not IsActiveBattlefieldArena() and GwObjectivesNotification then
            GwObjectivesNotification:RemoveNotificationOfType(GW.Enum.ObjectivesNotificationType.Arena)
        end
    end)
end

local function evPlayerEnteringWorld()
    commonEntering()

    GW:FixBlizzardIssues()

    C_Timer.After(1, function() collectgarbage("collect") end)
end


local function evPlayerEnteringBattleground()
    commonEntering()
end


local function evPlayerLogin(self)
    Debug("OK~EVENT~PLAYER_LOGIN; loaded:", loaded)
    if loaded then
        loadStep(GW.UpdateCharData)
        return
    end
    loadStep(GW.LoadFonts)

    if GW.Retail then
        -- fetch data
        -- Loop through the expansions to collect the textures
        local numTiers = (EJ_GetNumTiers() or 0)
        if numTiers > 0 then
            local currentTier = EJ_GetCurrentTier()

            for i = 1, numTiers do
                EJ_SelectTier(i)
                loadStep(GW.GetInstanceImages, 1, false)
                loadStep(GW.GetInstanceImages, 1, true)
            end

            -- Set it back to the previous tier
            if currentTier then
                EJ_SelectTier(currentTier)
            end
        end
    end

    -- Remove old debuffs from db
    loadStep(GW.RemoveOldRaidDebuffsFormProfiles)
    loadStep(GW.DisableBlizzardFrames)

    loaded = true
    loadStep(GW.CheckRole) -- some API's deliver a nil value on init.lua load, we we fill this values also here

    GW.CombatQueue:Initialize()

    --Create the mainbar layout manager
    local lm = loadStep(GW.LoadMainbarLayout)
    mainbarLM = lm

    --Create Settings window
    loadStep(GW.SetUpDatabaseForProfileSpecSwitch)
    loadStep(GW.BuildPrefixValues)
    loadStep(GW.LoadMovers, lm and lm.layoutFrame)
    loadStep(GW.BuildSettingsWindow)
    if not GW.isModern then
        loadStep(GW.LoadHoverBinds)
    end

    -- Create Popup frame
    loadStep(GW.CreatePopupFrame)

    -- disable Move Anything bag handling
    disableMABags()
    if GW.Classic then
        disableTitanPanelBarAdjusting()
    end

    -- Load Slash commands
    loadStep(GW.LoadSlashCommands)

    -- Misc
    loadStep(GW.InitializeMiscFunctions)
    loadStep(GW.SetupVendorJunk, GW.settings.bags.vendorGrays)
    loadStep(GW.LoadRaidMarkerCircle)

    --Create general skins
    if GW.isModern then
        loadStep(GW.StoreGameMenuButton)
    end
    if GW.settings.skins.mainMenu.enabled then
        loadStep(GW.SkinMainMenu)
    else
        -- do not add our button via AddButton/AddSection: acquiring a pool button from addon code taints
        -- the button pool, the next secure InitButtons run then wires blizzards logout/exit callbacks
        -- tainted and the protected Logout()/Quit() fire ADDON_ACTION_FORBIDDEN; use an own button
        -- instead which only takes part in the deferred layout via layoutIndex
        local settingsButton
        hooksecurefunc(GameMenuFrame, 'InitButtons', function(menuFrame)
            if not menuFrame.buttonPool then return end

            if not settingsButton then
                settingsButton = CreateFrame("Button", "GW2_UI_SettingsButton", menuFrame, menuFrame.buttonTemplate)
                settingsButton:SetText(format(("*%s|r"):gsub("*", GW.Gw2Color), GW.addonName))
                settingsButton:SetScript("OnClick", GW.ToggleGw2Settings)
            end

            local lastLayoutIndex = 0
            for button in menuFrame.buttonPool:EnumerateActive() do
                if button.layoutIndex and button.layoutIndex > lastLayoutIndex then
                    lastLayoutIndex = button.layoutIndex
                end
            end

            settingsButton.layoutIndex = lastLayoutIndex + 1
            settingsButton.topPadding = 20
        end)
    end

    if GW.Mists or GW.isModern or GW.TBC or GW.Wrath then
        loadStep(GW.WidgetUISetup)
    end

    -- make sure to load the objetives tracker before we load the altert system prevent some errors with other addons
    if GW.settings.objectives.enabled and not GW.ShouldBlockIncompatibleAddon("Objectives") then
        loadStep(GW.LoadObjectivesTracker)
    end

    -- load alert settings
    if not (GW.Classic or GW.TBC) then
        loadStep(GW.LoadAlertSystem)
        loadStep(GW.SetupAlertFramePosition)
        loadStep(GW.LoadOurAlertSubSystem)
    end

    --Create hud art
    hudArtFrame = GW.LoadHudArt()

    --Create experiencebar
    if GW.settings.hud.xpBar then
        loadStep(GW.LoadXPBar)
    elseif hudArtFrame then
        hudArtFrame.actionBarHud:ClearAllPoints()
        hudArtFrame.actionBarHud:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)

        hudArtFrame.edgeTintBottomCornerLeft:ClearAllPoints()
        hudArtFrame.edgeTintBottomCornerLeft:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
        hudArtFrame.edgeTintBottomCornerRight:ClearAllPoints()
        hudArtFrame.edgeTintBottomCornerRight:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    end

    if not GW.isModern then
        if not GW.ShouldBlockIncompatibleAddon("FloatingCombatText") then -- Only touch this setting if no other addon for this is loaded
            if GW.settings.combatText.mode == "GW2" then
                C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
                if GW.settings.combatText.showHealing then
                    C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
                else
                    C_CVar.SetCVar("floatingCombatTextCombatHealing", "1")
                end
                loadStep(GW.LoadDamageText, true)
            elseif GW.settings.combatText.mode == "BLIZZARD" then
                C_CVar.SetCVar("floatingCombatTextCombatDamage", "1")
                C_CVar.SetCVar("floatingCombatTextCombatHealing", "1")
                loadStep(GW.LoadDamageText, false)
            else
                C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
                C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
                loadStep(GW.LoadDamageText, false)
            end
        else
            loadStep(GW.LoadDamageText, false)
        end
    end

    if GW.settings.castingbar.enabled then
        loadStep(GW.LoadCastingBar, "GwCastingBarPlayer", "player", true)
        loadStep(GW.LoadCastingBar, "GwCastingBarPet", "pet", false)
    end

    if GW.settings.tooltip.enabled then
        loadStep(GW.LoadTooltips)
    end

    loadStep(GW.LoadImmersiveQuesting)

    --Create player hud
    if GW.settings.unitframes.healthGlobe.enabled and not GW.settings.unitframes.player.enabled then
        local hg = loadStep(GW.LoadHealthGlobe)
        loadStep(GW.LoadDodgeBar, hg, false)
    elseif GW.settings.unitframes.healthGlobe.enabled and GW.settings.unitframes.player.enabled then
        local hg = loadStep(GW.LoadPlayerFrame)
        loadStep(GW.LoadDodgeBar, hg, true)
        if (GW.Classic or GW.TBC or GW.Wrath) and GW.settings.unitframes.player.energyManaTick then
            loadStep(GW.Load5SR, hg)
        end
    end

    loadStep(GW.LoadPowerBar)

    if not GW.ShouldBlockIncompatibleAddon("Inventory") then -- Only touch this setting if no other addon for this is loaded
        if GW.settings.bags.enabled then
            loadStep(GW.LoadInventory)
        end
    elseif not GW.isModern and not C_AddOns.IsAddOnLoaded("Bartender4") then
        MainMenuBarBackpackButton:ClearAllPoints()
        CharacterBag0Slot:ClearAllPoints()
        CharacterBag1Slot:ClearAllPoints()
        CharacterBag2Slot:ClearAllPoints()
        CharacterBag3Slot:ClearAllPoints()

        MainMenuBarBackpackButton:SetPoint("RIGHT", ActionButton12, "RIGHT", ActionButton12:GetWidth() + 64, 0)
        CharacterBag0Slot:SetPoint("LEFT", MainMenuBarBackpackButton, "RIGHT", 0, 0)
        CharacterBag1Slot:SetPoint("LEFT", CharacterBag0Slot, "RIGHT", 0, 0)
        CharacterBag2Slot:SetPoint("LEFT", CharacterBag1Slot, "RIGHT", 0, 0)
        CharacterBag3Slot:SetPoint("LEFT", CharacterBag2Slot, "RIGHT", 0, 0)
    end

    if GW.Retail and GW.settings.general.battlegroundHud then
        loadStep(GW.LoadBattlegrounds)
    end

    --GW.LoadCharacter()

    if GW.isModern or GW.TBC then
        loadStep(GW.LoadSocialFrame)
    end

    if GW.Retail then
        loadStep(GW.LoadWorldEventTimer)
    end

    loadStep(GW.Create_Raid_Counter)
    loadStep(GW.LoadMirrorTimers)
    loadStep(GW.LoadAutoRepair)
    if not GW.isModern then
        loadStep(GW.ToggleInterruptAnncouncement)
    end

    --Create unitframes
    if not GW.Classic and GW.settings.unitframes.focus.enabled then
        local unitFrame = loadStep(GW.LoadUnitFrame, "Focus", GW.settings.unitframes.focus.invert)
        loadStep(GW.LoadTargetOfUnit, "Focus", unitFrame)
    end

    if GW.settings.unitframes.target.enabled then
        local unitFrame = loadStep(GW.LoadUnitFrame, "Target", GW.settings.unitframes.target.invert)
        loadStep(GW.LoadTargetOfUnit, "Target", unitFrame)

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

    loadStep(GW.LoadMarkers)

    if GW.settings.classpower.enabled then
        loadStep(GW.LoadClassPowers)
    end

    -- create pet frame
    if GW.settings.unitframes.pet.enabled and not GW.ShouldBlockIncompatibleAddon("PetFrame") then
        loadStep(GW.LoadPetFrame, lm)
    end

    -- create buff frame
    if GW.settings.playerAuras.enabled then
        loadStep(GW.LoadPlayerAuras, lm)
    end

    loadStep(GW.LoadAFKAnimation)

    if not GW.ShouldBlockIncompatibleAddon("DynamicCam") then -- Only touch this setting if no other addon for this is loaded
        if GW.settings.general.dynamicCam then
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

    if GW.settings.chat.bubbles.enabled then
        loadStep(GW.LoadChatBubbles)
    end

    if GW.settings.unitframes.party.enabled then
        loadStep(GW.LoadPartyFrames)
    end

    if GW.settings.groupFrames.enabled then
        loadStep(GW.InitializeRaidFrames) --TODO
    end

    loadStep(GW.UpdateHudScale)

    if (forcedMABags) then
        loadStep(GW.Notice, L["MoveAnything bag handling disabled."])
    end

    --Check if we should show Welcomepage or Changelog
    if GW.private.GW2_UI_VERSION == "WELCOME" then
        loadStep(GW.ShowWelcomePanel)
    elseif GW.private.GW2_UI_VERSION ~= GW.GetVersionString() then
        ShowUIPanel(GwSettingsWindow)
        HideUIPanel(GameMenuFrame)
    end
    GW.private.GW2_UI_VERSION = GW.GetVersionString()

    self:SetScript("OnUpdate", gw_OnUpdate)
    loadStep(GW.UpdateCharData)
end

-- second login stage: everything in here depends on blizzard ui state that is not ready before
-- PLAYER_LOGIN (chat windows, minimap cluster, action bar pages, edit mode). on era the first stage
-- runs on our own ADDON_LOADED to dodge the hardcore script watchdog, splitting the work over two
-- executions, on all other clients both stages run back to back on PLAYER_LOGIN
local lateLoaded = false
local function evPlayerLoginLate()
    if lateLoaded or not loaded then
        return
    end
    lateLoaded = true

    if GW.settings.minimap.enabled and not GW.ShouldBlockIncompatibleAddon("Minimap") then
        loadStep(GW.LoadMinimap)
    elseif QueueStatusButton then
        QueueStatusButton:ClearAllPoints()
        QueueStatusButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)
        QueueStatusButton:SetSize(26, 26)
        QueueStatusButton:SetParent(UIParent)
    end

    loadStep(GW.LoadChat)

    -- create new microbuttons
    loadStep(GW.LoadMicroMenu)

    -- create action bars
    if GW.settings.actionbars.enabled and not GW.ShouldBlockIncompatibleAddon("Actionbars") then
        if GW.isModern then
            if GW.settings.actionbars.barLayout then
                loadStep(GW.LoadActionBars, mainbarLM, false)
                --GW.ExtraAB_BossAB_Setup() -- Test
            else
                loadStep(GW.LoadActionBars, mainbarLM, true)
            end
        else
            loadStep(GW.LoadActionBars, mainbarLM)
            -- to update our bars
            MultiActionBar_Update()

            if GW.Mists then
                loadStep(GW.ExtraAB_BossAB_Setup)
            end
        end
    end

    if not GW.isModern then
        loadStep(GW.SecureGameMenuLogoutButtons)
    end
    loadStep(GW.HandleBlizzardEditMode)

    -- scale the frames created in this stage too
    loadStep(GW.UpdateHudScale)
end

-- third login stage: all blizzard and addon skins load in their own execution one frame after
-- PLAYER_LOGIN via C_Timer, so the skinning gets its own script time budget and can not push the
-- login setup over the hardcore script watchdog
local skinsLoaded = false
local function evLoadSkins()
    if skinsLoaded or not loaded then
        return
    end
    skinsLoaded = true

    loadStep(GW.LoadWorldMapSkin)
    loadStep(GW.LoadFlightMapSkin)
    loadStep(GW.LoadMacroOptionsSkin)

    loadStep(GW.LoadStaticPopupSkin)
    loadStep(GW.LoadBNToastSkin)
    loadStep(GW.LoadDropDownSkin)
    loadStep(GW.LoadReadyCheckSkin)
    loadStep(GW.LoadMiscBlizzardFrameSkins)
    loadStep(GW.LoadAddonListSkin)
    loadStep(GW.LoadHelperFrameSkin)
    loadStep(GW.LoadGossipSkin)
    loadStep(GW.LoadTimeManagerSkin)
    loadStep(GW.LoadSettingsPanelSkin)
    loadStep(GW.LoadMerchantFrameSkin)
    loadStep(GW.SetUpExtendedVendor)
    loadStep(GW.LoadLootFrameSkin)
    loadStep(GW.LoadDetailsSkin)
    loadStep(GW.AddMasqueSkin)
    loadStep(GW.SkinAndEnhanceColorPicker)
    loadStep(GW.AddCoordsToWorldMap)

    loadStep(GW.LoadDressUpFrameSkin)

    if GW.Retail then
        loadStep(GW.LoadTalkingHeadSkin)
        loadStep(GW.LoadExpansionLadningPageSkin)
        loadStep(GW.LoadGenericTraitFrameSkin)
        loadStep(GW.LoadCooldownManagerSkin)
        loadStep(GW.LoadImmersionAddonSkin)
        loadStep(GW.LoadAuctionatorAddonSkin)
        loadStep(GW.LoadExtendedSetsAddonSkin)
        loadStep(GW.LoadTSMAddonSkin)

        loadStep(GW.LoadOrderBar)

        loadStep(GW.LoadEncounterJournalSkin)
        loadStep(GW.LoadCollectionsSkin)
        loadStep(GW.LoadAchivementSkin)
        loadStep(GW.LoadAlliedRacesUISkin)
        loadStep(GW.LoadChromieTimerSkin)
        loadStep(GW.LoadCovenantSanctumSkin)
        loadStep(GW.LoadDeathRecapSkin)
        loadStep(GW.LoadItemUpgradeSkin)
        loadStep(GW.LoadLFGSkin)
        loadStep(GW.LoadOrderHallTalentFrameSkin)
        loadStep(GW.LoadSoulbindsSkin)
        loadStep(GW.LoadWeeklyRewardsSkin)
        loadStep(GW.LoadPerksProgramSkin)
        loadStep(GW.LoadAdventureMapSkin)
        loadStep(GW.LoadPlayerSpellsSkin)
        loadStep(GW.LoadAuctionHouseSkin)
        loadStep(GW.LoadBattlefieldMapSkin)
        loadStep(GW.LoadMajorFactionsFrameSkin)
    elseif not GW.Forever then
        loadStep(GW.LoadQuestLogFrameSkin)
    end

    -- skins of the systems both modern clients share (Games/Modern)
    if GW.isModern then
        loadStep(GW.LoadBarShopUISkin)
        loadStep(GW.LoadDamageMeterSkin)
        loadStep(GW.LoadCalendarSkin)
    end

    if not (GW.Classic or GW.TBC) then
        loadStep(GW.MakeAltPowerBarMovable)
        loadStep(GW.LoadLFGSkins)
        loadStep(GW.LoadMailSkin)
    end

    loadStep(GW.LoadQuestTimersSkin)
    loadStep(GW.LoadInspectFrameSkin)

    if not (GW.Classic or GW.TBC or GW.Wrath) then
        loadStep(GW.LoadSocketUISkin)
    end
end


-- generic event router
local function gw_OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- on era the first stage already ran on our own ADDON_LOADED, the loaded guard then only refreshes the char data here
        evPlayerLogin(self)
        -- the blizzard dependent parts always run here, blizzard is not fully loaded before PLAYER_LOGIN
        evPlayerLoginLate()
        -- skins load one frame later in their own execution with a fresh script time budget
        C_Timer.After(0, evLoadSkins)
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
        local loadedAddonName = ...
        evAddonLoaded(self, loadedAddonName)

        -- on hardcore realms the PLAYER_LOGIN script budget is too small for the full ui setup and
        -- fires "script ran too long" errors, so on the era client run the setup as soon as our own
        -- addon has finished loading; the database setup in evAddonLoaded has to run before it
        if GW.Classic and loadedAddonName == "GW2_UI" then
            evPlayerLogin(self)
        end
    end
end

l:SetScript("OnEvent", gw_OnEvent)
l:RegisterEvent("PLAYER_LOGIN")
l:RegisterEvent("PLAYER_LEAVING_WORLD")
l:RegisterEvent("PLAYER_ENTERING_WORLD")
l:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
l:RegisterEvent("UI_SCALE_CHANGED")
l:RegisterEvent("PLAYER_LEVEL_UP")
l:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
l:RegisterEvent("ADDON_LOADED")
if GW.Retail then
    l:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
end

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
