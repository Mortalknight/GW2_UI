local addonName, GW = ...
local L = GW.L
local IsFrameModified = GW.IsFrameModified
local Debug = GW.Debug
local AFP = GW.AddProfiling

local sin = math.sin
local pi = math.pi
local GetTime = GetTime
local min = math.min
local max = math.max

local animations = GW.animations

local l = CreateFrame("Frame") -- Main event frame

if GW.CheckForPasteAddon() and GW.settings.ACTIONBARS_ENABLED and not GW.ShouldBlockIncompatibleAddon("Actionbars") then
    GW.Notice("|cffff0000You have installed the Addon 'Paste'. This can cause, that our actionbars are empty. Deactive 'Paste' to use our actionbars.|r")
end

local loaded = false
local forcedMABags = false

local swimAnimation = 0
local lastSwimState = true
local hudArtFrame


if GW.Retail then
    function GW2_ADDON_AddonCompartmentOnClickFunc()
        GW.ToggleGw2Settings()
    end
    function GW2_ADDON_OnAddonCompartmentEnter(_, menuButtonFrame)
        GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_NONE");
        GameTooltip:SetPoint("TOPRIGHT", menuButtonFrame, "BOTTOMRIGHT", 0, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(addonName, C_AddOns.GetAddOnMetadata(addonName, "Version"))
        GameTooltip:Show()
    end

    function GW2_ADDON_OnAddonCompartmentLeave(addonName, button)
        GameTooltip:Hide()
    end
end

local function disableMABags()
    local bags = GW.settings.BAGS_ENABLED and not GW.ShouldBlockIncompatibleAddon("Inventory")
    if not bags or not MovAny or not MADB then
        return
    end
    MADB.noBags = true
    MAOptNoBags:SetEnabled(false)
    forcedMABags = true
end

local function disableTitanPanelBarAdjusting()
    local ourBars = GW.settings.ACTIONBARS_ENABLED
    if ourBars and C_AddOns.IsAddOnLoaded("TitanClassic") then
        TitanMovable_AddonAdjust("MultiBarRight", true)
        TitanMovable_AddonAdjust("ExtraActionBarFrame", true)
        TitanMovable_AddonAdjust("MinimapCluster", true)
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

        if not v.completed then
            if time >= (v.start + v.duration) then
                local t = v.easeing and 1 or sin(pi * 0.5)
                v.progress = GW.lerp(v.from, v.to, t)

                if v.method then
                    v.method(v.progress)
                end

                if v.onCompleteCallback then
                    v.onCompleteCallback()
                end

                v.completed = true
                foundAnimation = true
            else
                local t = v.easeing and ((time - v.start) / v.duration) or sin((time - v.start) / v.duration * pi * 0.5)
                v.progress = GW.lerp(v.from, v.to, t)

                if v.method then
                    v.method(v.progress)
                end
                foundAnimation = true
            end
        end
    end

    if not foundAnimation and count > 0 then
        table.wipe(animations)
    end

    --Swim hud
    local swimming = IsSwimming()
    if lastSwimState ~= swimming then
        if swimming then
            AddToAnimation("swimAnimation", swimAnimation, 1, time, 0.1, swimAnim)
            swimAnimation = 1
        else
            AddToAnimation("swimAnimation", swimAnimation, 0, time, 3.0, swimAnim)
            swimAnimation = 0
        end
        lastSwimState = swimming
    end

    for _, cb in ipairs(updateCB) do
        cb.func(cb.payload, elapsed)
    end

    if GW.Classic and PetActionBarFrame:IsShown() and GW.settings.PETBAR_ENABLED and loaded and not GW.ShouldBlockIncompatibleAddon("Actionbars") then
        PetActionBarFrame:Hide()
    end
end
AFP("gw_OnUpdate", gw_OnUpdate)

local function getBestPixelScale()
    return max(0.4, min(1.15, 768 / GW.screenHeight))
end
GW.getBestPixelScale = getBestPixelScale

local function PixelPerfection()
    if GW.settings.PIXEL_PERFECTION and not GetCVarBool("useUiScale") then
        GW.scale = getBestPixelScale()
        GW.border = ((1 / GW.scale) - ((1 - (768 / GW.screenHeight)) / GW.scale)) * 2
        UIParent:SetScale(GW.scale)
    end
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

local function UpdateDb()
    GW.settings = GW.globalSettings.profile
    GW.Migration()
    GW.DatabaseValueMigration()
end

local function evAddonLoaded(self, loadedAddonName)
    if loadedAddonName ~= "GW2_UI" then
        local loadHook = addonLoadHooks[loadedAddonName]
        if loadHook and type(loadHook) == "function" then
            Debug("run load hook for addon", loadedAddonName)
            xpcall(loadHook, errorhandler)
            addonLoadHooks[loadedAddonName] = nil
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

        local dbMigrated = false
        if not GW.private.dbConverted and GW.private.GW2_UI_VERSION ~= "WELCOME" then
            GW.DatabaseMigration(false, true)
            GW.private.dbConverted = true
            dbMigrated = true
        end
        if not GW.global.dbConverted and GW.private.GW2_UI_VERSION ~= "WELCOME" then
            GW.DatabaseMigration(true, false)
            GW.global.dbConverted = true
            dbMigrated = true
        end

        if dbMigrated then
            C_Timer.After(3, function() GW.WarningPrompt(L["DB was converted Reload is needed /reload"], function() C_UI.Reload() end) end)
            GW.Notice("DB was converted Reload is needed /reload")
        end

        GW.DatabaseValueMigration()
        GW.ApplyMissingIncompatibleAddonsDefaults()
        GW.UpdateGw2ClassColors()

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
    local _, _, _, enabled = C_AddOns.GetAddOnInfo("DeModal")
    GW.HasDeModal = enabled
    Debug("DeModal status:", GW.HasDeModal)

    -- TODO: moving skinning from player login to here
    -- Skins: BLizzard & Addons
    GW.PreloadStatusBarMaskTextures()
    GW.LoadWorldMapSkin()
    GW.LoadFlightMapSkin()
    GW.LoadMacroOptionsSkin()

    if GW.Retail then
        GW.LoadEncounterJournalSkin()
        GW.LoadAchivementSkin()
        GW.LoadAlliedRacesUISkin()
        GW.LoadBarShopUISkin()
        GW.LoadChromieTimerSkin()
        GW.LoadCovenantSanctumSkin()
        GW.LoadDeathRecapSkin()
        GW.LoadInspectFrameSkin()
        GW.LoadItemUpgradeSkin()
        GW.LoadLFGSkin()
        GW.LoadOrderHallTalentFrameSkin()
        GW.LoadSoulbindsSkin()
        GW.LoadWeeklyRewardsSkin()
        GW.LoadPerksProgramSkin()
        GW.LoadAdventureMapSkin()
        GW.LoadPlayerSpellsSkin()
        GW.LoadAuctionHouseSkin()
        GW.LoadBattlefieldMapSkin()
        GW.LoadMajorFactionsFrameSkin()
    end

    if not GW.Classic then
        GW.LoadSocketUISkin()
    end

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
        if UnitInBattleground("player") == nil and not IsActiveBattlefieldArena() and GwObjectivesNotification then
            GwObjectivesNotification:RemoveNotificationOfType(GW.TRACKER_TYPE.ARENA)
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

    GW:FixBlizzardIssues()

    C_Timer.After(1, function() collectgarbage("collect") end)
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
    GW.LoadFonts()

    if GW.Retail then
        -- fetch data
        -- Loop through the expansions to collect the textures
        local numTiers = (EJ_GetNumTiers() or 0)
        if numTiers > 0 then
            local currentTier = EJ_GetCurrentTier()

            for i = 1, numTiers do
                EJ_SelectTier(i)
                GW.GetInstanceImages(1, false)
                GW.GetInstanceImages(1, true)
            end

            -- Set it back to the previous tier
            if currentTier then
                EJ_SelectTier(currentTier)
            end
        end
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
    GW.SetUpDatabaseForProfileSpecSwitch()
    if GW.Retail then
        GW.BuildPrefixValues()
    end
    GW.LoadMovers(lm.layoutFrame)
    GW.LoadSettings()
    if not GW.Retail then
        GW.LoadHoverBinds()
    end

    -- Create Warning Prompt
    GW.CreateWarningPrompt()

    -- disable Move Anything bag handling
    disableMABags()
    if GW.Classic then
        disableTitanPanelBarAdjusting()
    end

    -- Load Slash commands
    GW.LoadSlashCommands()

    -- Misc
    GW.InitializeMiscFunctions()
    GW.LoadRaidMarkerCircle()

    --Create general skins
    if GW.Retail then
        GW.StoreGameMenuButton()
    end
    if GW.settings.MAINMENU_SKIN_ENABLED then
        GW.SkinMainMenu()
    else
        if GW.Retail then
            hooksecurefunc(GameMenuFrame, 'InitButtons', function(self)
                self:AddSection()
                self:AddButton(format(("*%s|r"):gsub("*", GW.Gw2Color), GW.addonName), GW.ToggleGw2Settings)
            end)
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
    end

    -- Skins: BLizzard & Addons
    GW.LoadStaticPopupSkin()
    GW.LoadBNToastSkin()
    GW.LoadDropDownSkin()
    GW.LoadReadyCheckSkin()
    GW.LoadMiscBlizzardFrameSkins()
    GW.LoadAddonListSkin()
    GW.LoadHelperFrameSkin()
    GW.LoadGossipSkin()
    GW.LoadTimeManagerSkin()
    GW.LoadMerchantFrameSkin()
    GW.LoadLootFrameSkin()
    GW.LoadDetailsSkin()
    GW.AddMasqueSkin()
    GW.SkinAndEnhanceColorPicker()
    GW.AddCoordsToWorldMap()

    if GW.Retail then
        GW.LoadTalkingHeadSkin()
        GW.LoadDressUpFrameSkin()
        GW.LoadExpansionLadningPageSkin()
        GW.LoadGenericTraitFrameSkin()
        GW.LoadCooldownManagerSkin()
        GW.LoadImmersionAddonSkin()
        GW.WidgetUISetup()
        GW.LoadAuctionatorAddonSkin()
        GW.LoadTSMAddonSkin()
    else
        GW.LoadQuestLogFrameSkin()
        GW.LoadQuestTimersSkin()
    end

    if not GW.Classic then
        GW.MakeAltPowerBarMovable()
        GW.LoadLFGSkins()
        GW.LoadMailSkin()
    end

    if GW.Mists then
        GW.SetUpVehicleFrameMover()
    end

    -- make sure to load the objetives tracker before we load the altert system prevent some errors with other addons
    if GW.settings.QUESTTRACKER_ENABLED and not GW.ShouldBlockIncompatibleAddon("Objectives") then
        GW.LoadObjectivesTracker()
    end

    -- load alert settings
    if not GW.Classic then
        GW.LoadAlertSystem()
        GW.SetupAlertFramePosition()
        GW.LoadOurAlertSubSystem()
    end

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

    if not GW.ShouldBlockIncompatibleAddon("FloatingCombatText") then -- Only touch this setting if no other addon for this is loaded
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
            GW.LoadDamageText(false)
        else
            C_CVar.SetCVar("floatingCombatTextCombatDamage", "0")
            C_CVar.SetCVar("floatingCombatTextCombatHealing", "0")
            GW.LoadDamageText(false)
        end
    else
        GW.LoadDamageText(false)
    end

    if GW.settings.CASTINGBAR_ENABLED then
        GW.LoadCastingBar("GwCastingBarPlayer", "player", true)
        GW.LoadCastingBar("GwCastingBarPet", "pet", false)
    end

    if GW.settings.MINIMAP_ENABLED and not GW.ShouldBlockIncompatibleAddon("Minimap") then
        GW.LoadMinimap()
    elseif QueueStatusButton then
        QueueStatusButton:ClearAllPoints()
        QueueStatusButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)
        QueueStatusButton:SetSize(26, 26)
        QueueStatusButton:SetParent(UIParent)
    end

    if GW.settings.TOOLTIPS_ENABLED then
        GW.LoadTooltips()
    end

    if GW.settings.QUESTVIEW_ENABLED and not GW.ShouldBlockIncompatibleAddon("ImmersiveQuesting") then
        GW.LoadQuestview()
    end

    GW.LoadChat()

    --Create player hud
    if GW.settings.HEALTHGLOBE_ENABLED and not GW.settings.PLAYER_AS_TARGET_FRAME then
        local hg = GW.LoadHealthGlobe()
        GW.LoadDodgeBar(hg, false)
    elseif GW.settings.HEALTHGLOBE_ENABLED and GW.settings.PLAYER_AS_TARGET_FRAME then
        local hg = GW.LoadPlayerFrame()
        GW.LoadDodgeBar(hg, true)
        if not GW.Retail then
            if GW.settings.PLAYER_ENERGY_MANA_TICK then
                GW.Load5SR(hg)
            end
        end
    end

    GW.LoadPowerBar()

    if not GW.ShouldBlockIncompatibleAddon("Inventory") then -- Only touch this setting if no other addon for this is loaded
        if GW.settings.BAGS_ENABLED then
            GW.LoadInventory()
        end
    elseif not GW.Retail and not C_AddOns.IsAddOnLoaded("Bartender4") then
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

    GW.SetUpExtendedVendor()

    if GW.Retail and GW.settings.USE_BATTLEGROUND_HUD then
        GW.LoadBattlegrounds()
    end

    GW.LoadCharacter()

    if GW.Retail then
        GW.LoadSocialFrame()
        GW.LoadRaidbuffReminder()
        GW.LoadWorldEventTimer()
    end

    GW.Create_Raid_Counter()
    GW.LoadMirrorTimers()
    GW.LoadAutoRepair()
    GW.ToggleInterruptAnncouncement()

    --Create unitframes
    if not GW.Classic and GW.settings.FOCUS_ENABLED then
        local unitFrame = GW.LoadUnitFrame("Focus", GW.settings.focus_FRAME_INVERT)
        GW.LoadTargetOfUnit("Focus", unitFrame)
    end

    if GW.settings.TARGET_ENABLED then
        local unitFrame = GW.LoadUnitFrame("Target", GW.settings.target_FRAME_INVERT)
        GW.LoadTargetOfUnit("Target", unitFrame)

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
    if GW.settings.ACTIONBARS_ENABLED and not GW.ShouldBlockIncompatibleAddon("Actionbars") then
        if GW.Retail then
            if GW.settings.BAR_LAYOUT_ENABLED then
                GW.LoadActionBars(lm, false)
                GW.ExtraAB_BossAB_Setup()
            else
                GW.LoadActionBars(lm, true)
            end
        else
            GW.LoadActionBars(lm)
            -- to update our bars
            MultiActionBar_Update()

            if GW.Mists then
                GW.ExtraAB_BossAB_Setup()
            end
        end
    end

    -- create pet frame
    if GW.settings.PETBAR_ENABLED and not GW.ShouldBlockIncompatibleAddon("Actionbars") then
        GW.LoadPetFrame(lm)
    end

    -- create buff frame
    if GW.settings.PLAYER_BUFFS_ENABLED then
        GW.LoadPlayerAuras(lm)
    end

    GW.LoadAFKAnimation()

    if not GW.ShouldBlockIncompatibleAddon("DynamicCam") then -- Only touch this setting if no other addon for this is loaded
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

    if GW.settings.CHATBUBBLES_ENABLED then
        GW.LoadChatBubbles()
    end

    -- create new microbuttons
    GW.LoadMicroMenu()

    if GW.Retail then
        GW.LoadOrderBar()
    end

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
    elseif GW.private.GW2_UI_VERSION ~= GW.VERSION_STRING then
        ShowUIPanel(GwSettingsWindow)
        HideUIPanel(GameMenuFrame)
    end
    GW.private.GW2_UI_VERSION = GW.VERSION_STRING

    self:SetScript("OnUpdate", gw_OnUpdate)
    GW.UpdateCharData()

    if GW.Retail then
        GW.SetupSingingSockets()
        GW.HandleBlizzardEditMode()
    end
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
