---@class GW2
local GW = select(2, ...)
local RegisterMovableFrame = GW.RegisterMovableFrame
local IsIn = GW.IsIn

GwPlayerUnitFrameMixin = {}

function GwPlayerUnitFrameMixin:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnitFrameData()
        self:UpdateHealthBar()
        self.powerbar:UpdatePowerData()
    elseif IsIn(event, "PLAYER_LEVEL_UP", "GROUP_ROSTER_UPDATE", "UNIT_PORTRAIT_UPDATE") then
        self:UnitFrameData()
        if event == "PLAYER_LEVEL_UP" then
            local level = ...
            self:UnitFrameData(level)
        end
    elseif IsIn(event, "UNIT_HEALTH", "UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH", "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_PREDICTION") then
        self:UpdateHealthBar()
    elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT") then
       self.powerbar:UpdatePowerData()
     elseif event == "UPDATE_SHAPESHIFT_FORM" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
        self.powerbar.lastPowerType = nil
        self.powerbar:UpdatePowerData()
    elseif IsIn(event, "WAR_MODE_STATUS_UPDATE", "PLAYER_FLAGS_CHANGED", "UNIT_FACTION") then
        self:SelectPvp()
    elseif event == "RESURRECT_REQUEST" then
        PlaySound(SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING_SMALLER, "Master")
    end
end

function GwPlayerUnitFrameMixin:ToggleSettings()
    self.backgroundOverlay:SetShown(GW.settings.unitframes.player.altBackground)

    -- statusbar texture
    local textureKey =  GW.settings.unitframes.player.healthBarTexture
    if textureKey == GW.DEFAULT_UNITFRAME_STATUSBAR_TEXTURE then
        self.antiHeal:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/antiheal.png")
        self.health:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar.png")
        self.absorbbg:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/absorb.png")
        self.healPrediction:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")

        self.absorbbg:SetStatusBarColor(1, 1, 1, 0.66)
    else
        local texture = GW.Libs.LSM:Fetch("statusbar", textureKey)
        self.antiHeal:SetStatusBarTexture(texture)
        self.health:SetStatusBarTexture(texture)
        self.absorbbg:SetStatusBarTexture(texture)
        self.healPrediction:SetStatusBarTexture(texture)

        self.absorbbg:SetStatusBarColor(248/255, 232/255, 159/255, 0.66)
    end

    self.shortendHealthValues = GW.settings.unitframes.healthGlobe.shortHealthValues
    self.showHealthValue = GW.settings.unitframes.healthGlobe.healthValue == "VALUE" or GW.settings.unitframes.healthGlobe.healthValue == "BOTH"
    self.showHealthPrecentage = GW.settings.unitframes.healthGlobe.healthValue == "PREC" or GW.settings.unitframes.healthGlobe.healthValue == "BOTH"
    self.classColor = GW.settings.unitframes.player.classColor
    self.showAbsorbBar = GW.settings.unitframes.player.showAbsorbBar
    self.powerbar.showBarValues = GW.settings.classpower.showValue

    self:SetScale(GW.settings.unitframes.player.scale)
    self.healthContainer:SetSize(GW.settings.unitframes.player.healthBarSize.width, GW.settings.unitframes.player.healthBarSize.height)
    self.powerbarContainer:SetSize(GW.settings.unitframes.player.healthBarSize.width, GW.settings.unitframes.player.powerBarSize.height) -- width is shared
    if self.fsrMana then
        self.fsrMana:UpdateWidth(GW.settings.unitframes.player.healthBarSize.width) -- width is shared
    end
    if self.fsrEnergy then
        self.fsrEnergy:UpdateWidth(GW.settings.unitframes.player.healthBarSize.width) -- width is shared
    end
    self.powerbar.spark:SetHeight(GW.settings.unitframes.player.powerBarSize.height)
    self.powerbar.label:SetShown(GW.settings.unitframes.player.powerBarSize.height >= 10)
    self.healthString:ClearAllPoints()
    self.healthString:SetPoint("LEFT", self.health, "LEFT", GW.settings.unitframes.player.healthBarTextOffset.x, GW.settings.unitframes.player.healthBarTextOffset.y)
    self.powerbar.label:ClearAllPoints()
    self.powerbar.label:SetPoint("LEFT", self.powerbar, "LEFT", GW.settings.unitframes.player.powerBarTextOffset.x, GW.settings.unitframes.player.powerBarTextOffset.y)

    local powerHeight = self.powerbarContainer:GetHeight()
    local yOffset = (powerHeight + 1) / 2

    self.healthContainer:ClearAllPoints()
    self.healthContainer:SetPoint("LEFT", self.portrait, "RIGHT", 4, yOffset)

    self.powerbarContainer:ClearAllPoints()
    self.powerbarContainer:SetPoint("TOPLEFT", self.healthContainer, "BOTTOMLEFT", 0, -1)

    self.healthbarBackground:ClearAllPoints()
    self.healthbarBackground:SetPoint("TOPLEFT", self.healthContainer, "TOPLEFT", 0, 0)
    self.healthbarBackground:SetSize(self.healthContainer:GetWidth(), self.healthContainer:GetHeight())

    self:SetHeight(40 + self.healthContainer:GetHeight() + self.powerbarContainer:GetHeight())
    self:SetWidth(90 + self.healthContainer:GetWidth())

    local frameFaderSettings = GW.settings.unitframes.player.fader
    if frameFaderSettings.hover or frameFaderSettings.combat or frameFaderSettings.casting or frameFaderSettings.dynamicflight or frameFaderSettings.health or frameFaderSettings.vehicle or frameFaderSettings.playertarget then
        GW.FrameFadeEnable(self)
        self.Fader:SetOption("Hover", frameFaderSettings.hover)
        self.Fader:SetOption("Combat", frameFaderSettings.combat)
        self.Fader:SetOption("Casting", frameFaderSettings.casting)
        self.Fader:SetOption("DynamicFlight", frameFaderSettings.dynamicflight)
        self.Fader:SetOption("Smooth", (frameFaderSettings.smooth > 0 and frameFaderSettings.smooth) or nil)
        self.Fader:SetOption("MinAlpha", frameFaderSettings.minAlpha)
        self.Fader:SetOption("MaxAlpha", frameFaderSettings.maxAlpha)
        self.Fader:SetOption("Health", frameFaderSettings.health)
        self.Fader:SetOption("Vehicle", frameFaderSettings.vehicle)
        self.Fader:SetOption("PlayerTarget", frameFaderSettings.playertarget)
        self.Fader:AddCorrespondingFrames("GW2EnergyTicker")
        self.Fader:AddCorrespondingFrames("GwPlayerPowerBar")
        self.Fader:AddCorrespondingFrames("GwPlayerClassPower")

        self.Fader:ClearTimers()
        self.Fader.configTimer = C_Timer.NewTimer(0.25, function() self.Fader:ForceUpdate() end)
    elseif self.Fader then
        GW.FrameFadeDisable(self)
    end

    self:UpdateHealthBar()
    self.powerbar:UpdatePowerData()
    self:UnitFrameData()
end

local function LoadPlayerFrame()
    local frame = GW.CreateUnitFrame("GwPlayerUnitFrame", false, true)
    frame.gwUnit = "player"
    frame.type = "NormalTarget"

    Mixin(frame, GwPlayerUnitFrameMixin)

    if GW.Retail then
        frame.powerbar.spark:ClearAllPoints()
        frame.powerbar.spark:SetPoint("RIGHT", frame.powerbar:GetStatusBarTexture(), "RIGHT", 0, 0)
    end

    frame.powerbar.label:SetJustifyH("LEFT")

    RegisterMovableFrame(frame, PLAYER, "unitframes.player",  "Unitframe")

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", frame.gwMover)

    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")
    frame:SetAttribute("unit", "player")
    RegisterUnitWatch(frame)
    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyDown")

    frame.mask = UIParent:CreateMaskTexture()
    frame.mask:SetPoint("CENTER", frame.portrait, "CENTER", 0, 0)

    frame.mask:SetTexture(186178, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    frame.mask:SetSize(58, 58)
    frame.portrait:AddMaskTexture(frame.mask)

    GW.AddToClique(frame)

    -- add pvp marker
    frame.pvp = CreateFrame("Frame", nil, frame)
    frame.pvp:SetSize(128, 128)
    frame.pvp:SetFrameLevel(2)
    frame.pvp:SetAlpha(0.44)
    frame.pvp:SetFrameStrata("BACKGROUND")
    frame.pvp:SetPoint("CENTER", frame.portrait, "CENTER", 0, 0)
    frame.pvp.ally = frame.pvp:CreateTexture(nil, "BACKGROUND")
    frame.pvp.ally:SetTexture("Interface/AddOns/GW2_UI/textures/globe/pvpmode.png")
    frame.pvp.ally:SetSize(72, 68)
    frame.pvp.ally:SetTexCoord(0, 1, 0, 0.5)
    frame.pvp.ally:SetPoint("CENTER", frame.pvp, "CENTER", 0, 5)
    frame.pvp.ally:Hide()

    frame.pvp.horde = frame.pvp:CreateTexture(nil, "BACKGROUND")
    frame.pvp.horde:SetTexture("Interface/AddOns/GW2_UI/textures/globe/pvpmode.png")
    frame.pvp.horde:SetSize(78, 78)
    frame.pvp.horde:SetTexCoord(0, 1, 0.51, 1)
    frame.pvp.horde:SetPoint("CENTER", frame.portrait, "CENTER", 0, 5)
    frame.pvp.horde:Hide()

    frame:SetScript("OnEvent", frame.OnEvent)

    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
    frame:RegisterEvent("RESURRECT_REQUEST")
    frame:RegisterEvent("PLAYER_LEVEL_UP")
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "player")
    frame:RegisterUnitEvent("UNIT_HEALTH", "player")
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    frame:RegisterUnitEvent("UNIT_FACTION", "player")
    frame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

    if GW.Retail then
        frame:RegisterEvent("WAR_MODE_STATUS_UPDATE")
    end

    if GW.Retail or GW.Mists then
        frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    elseif GW.Classic then
        frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "player")
    end

    frame:SetScript("OnEnter", GwHealthglobeMixin.OnEnter)
    frame:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        if self.pvp.pvpFlag then
            self.pvp:fadeOut()
        end
    end)

    -- grab the TotemFramebuttons to our own Totem Frame
    GW.CreateTotemBar()


    -- setup anim to flash the PvP marker
    local pvp = frame.pvp
    local pagIn = pvp:CreateAnimationGroup("fadeIn")
    local pagOut = pvp:CreateAnimationGroup("fadeOut")
    local fadeOut = pagOut:CreateAnimation("Alpha")
    local fadeIn = pagIn:CreateAnimation("Alpha")

    pagOut:SetScript("OnFinished", function(self)
        self:GetParent():SetAlpha(0.33)
    end)

    fadeOut:SetFromAlpha(1.0)
    fadeOut:SetToAlpha(0.33)
    fadeOut:SetDuration(0.1)
    fadeIn:SetFromAlpha(0.33)
    fadeIn:SetToAlpha(1.0)
    fadeIn:SetDuration(0.1)

    pvp.fadeOut = function()
        pagIn:Stop()
        pagOut:Stop()
        pagOut:Play()
    end
    pvp.fadeIn = function(self)
        self:SetAlpha(1)
        pagIn:Stop()
        pagOut:Stop()
        pagIn:Play()
    end

    if not GW.settings.unitframes.player.pvpIndicator then pvp:Hide() end

    --hide unsed things from default target frame
    frame.castingbarBackground:Hide()
    frame.castingString:Hide()
    frame.castingTimeString:Hide()
    if frame.castingbar then frame.castingbar:Hide() end
    if frame.castingbarSpark then frame.castingbarSpark:Hide() end
    frame.castingbarNormal:Hide()
    frame.raidmarker:Hide()
    frame.prestigebg:Hide()
    frame.prestigeString:Hide()

    frame:ToggleSettings()

    return frame
end
GW.LoadPlayerFrame = LoadPlayerFrame
