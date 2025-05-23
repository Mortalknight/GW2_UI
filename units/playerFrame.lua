local _, GW = ...
local RegisterMovableFrame = GW.RegisterMovableFrame
local AddToClique = GW.AddToClique
local IsIn = GW.IsIn

GwPlayerUnitFrameMixin = {}

function GwPlayerUnitFrameMixin:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnitFrameData()
        self:UpdateHealthBar()
        self:UpdatePowerBar()
    elseif IsIn(event, "PLAYER_LEVEL_UP", "GROUP_ROSTER_UPDATE", "UNIT_PORTRAIT_UPDATE") then
        self:UnitFrameData()
    elseif event == "PLAYER_LEVEL_UP" then
        local level = ...
        self:UnitFrameData(level)
    elseif IsIn(event, "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_PREDICTION") then
        self:UpdateHealthBar()
    elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT", "UPDATE_SHAPESHIFT_FORM", "ACTIVE_TALENT_GROUP_CHANGED") then
        self:UpdatePowerBar()
    elseif IsIn(event, "WAR_MODE_STATUS_UPDATE", "PLAYER_FLAGS_CHANGED", "UNIT_FACTION") then
        self:SelectPvp()
    elseif event == "RESURRECT_REQUEST" then
        PlaySound(SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING_SMALLER, "Master")
    end
end

function GwPlayerUnitFrameMixin:ToggleSettings()
    self.altBg:SetShown(GW.settings.PLAYER_AS_TARGET_FRAME_ALT_BACKGROUND)

    self.shortendHealthValues = GW.settings.PLAYER_UNIT_HEALTH_SHORT_VALUES
    self.showHealthValue = GW.settings.PLAYER_UNIT_HEALTH == "VALUE" or GW.settings.PLAYER_UNIT_HEALTH == "BOTH"
    self.showHealthPrecentage = GW.settings.PLAYER_UNIT_HEALTH == "PREC" or GW.settings.PLAYER_UNIT_HEALTH == "BOTH"
    self.classColor = GW.settings.player_CLASS_COLOR

    local frameFaderSettings = GW.settings.playerFrameFader
    if frameFaderSettings.hover or frameFaderSettings.combat or frameFaderSettings.casting or frameFaderSettings.dynamicflight or frameFaderSettings.health then
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

        self.Fader:ClearTimers()
        self.Fader.configTimer = C_Timer.NewTimer(0.25, function() self.Fader:ForceUpdate() end)
    elseif self.Fader then
        GW.FrameFadeDisable(self)
    end

    self:UpdateHealthBar()
    self:UnitFrameData()
end

local function LoadPlayerFrame()
    local frame = GW.CreateUnitFrame("GwPlayerUnitFrame")
    frame.unit = "player"
    frame.type = "NormalTarget"

    Mixin(frame, GwPlayerUnitFrameMixin)

    RegisterMovableFrame(frame, PLAYER, "player_pos",  ALL .. ",Unitframe", nil, {"default", "scaleable"})

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", frame.gwMover)

    frame:SetAttribute("*type1", "target")
    frame:SetAttribute("*type2", "togglemenu")
    frame:SetAttribute("unit", "player")
    RegisterUnitWatch(frame)
    frame:EnableMouse(true)
    frame:RegisterForClicks("AnyDown")

    frame.altBg = CreateFrame("Frame", nil, frame, "GwAlternativeUnitFrameBackground")
    frame.altBg:SetAllPoints(frame)
    frame.altBg:SetFrameLevel(0)

    frame.mask = UIParent:CreateMaskTexture()
    frame.mask:SetPoint("CENTER", frame.portrait, "CENTER", 0, 0)

    frame.mask:SetTexture(186178, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    frame.mask:SetSize(58, 58)
    frame.portrait:AddMaskTexture(frame.mask)

    AddToClique(frame)

    -- add pvp marker
    frame.pvp = CreateFrame("Frame", nil, frame)
    frame.pvp:SetSize(128, 128)
    frame.pvp:SetFrameLevel(2)
    frame.pvp:SetAlpha(0.44)
    frame.pvp:SetFrameStrata("BACKGROUND")
    frame.pvp:SetPoint("CENTER", frame.portrait, "CENTER", 0, 0)
    frame.pvp.ally = frame.pvp:CreateTexture(nil, "BACKGROUND")
    frame.pvp.ally:SetTexture("Interface/AddOns/GW2_UI/textures/globe/pvpmode")
    frame.pvp.ally:SetSize(72, 68)
    frame.pvp.ally:SetTexCoord(0, 1, 0, 0.5)
    frame.pvp.ally:SetPoint("CENTER", frame.pvp, "CENTER", 0, 5)
    frame.pvp.ally:Hide()

    frame.pvp.horde = frame.pvp:CreateTexture(nil, "BACKGROUND")
    frame.pvp.horde:SetTexture("Interface/AddOns/GW2_UI/textures/globe/pvpmode")
    frame.pvp.horde:SetSize(78, 78)
    frame.pvp.horde:SetTexCoord(0, 1, 0.51, 1)
    frame.pvp.horde:SetPoint("CENTER", frame.portrait, "CENTER", 0, 5)
    frame.pvp.horde:Hide()

    frame:SetScript("OnEvent", frame.OnEvent)

    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("WAR_MODE_STATUS_UPDATE")
    frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
    frame:RegisterEvent("RESURRECT_REQUEST")
    frame:RegisterEvent("PLAYER_LEVEL_UP")
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    frame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "player")
    frame:RegisterUnitEvent("UNIT_HEALTH", "player")
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    frame:RegisterUnitEvent("UNIT_FACTION", "player")
    frame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
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

    if not GW.settings.PLAYER_SHOW_PVP_INDICATOR then pvp:Hide() end

    --hide unsed things from default target frame
    frame.castingbarBackground:Hide()
    frame.castingString:Hide()
    frame.castingTimeString:Hide()
    frame.castingbar:Hide()
    frame.castingbarSpark:Hide()
    frame.castingbarNormal:Hide()
    frame.raidmarker:Hide()
    frame.prestigebg:Hide()
    frame.prestigeString:Hide()

    frame:ToggleSettings()

    return frame
end
GW.LoadPlayerFrame = LoadPlayerFrame
