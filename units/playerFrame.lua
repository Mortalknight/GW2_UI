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

    self:UpdateHealthBar()
    self:UnitFrameData()
end

local function LoadPlayerFrame()
    local NewUnitFrame = GW.CreateUnitFrame("GwPlayerUnitFrame")
    NewUnitFrame.unit = "player"
    NewUnitFrame.type = "NormalTarget"

    Mixin(NewUnitFrame, GwPlayerUnitFrameMixin)

    RegisterMovableFrame(NewUnitFrame, PLAYER, "player_pos",  ALL .. ",Unitframe", nil, {"default", "scaleable"})

    NewUnitFrame:ClearAllPoints()
    NewUnitFrame:SetPoint("TOPLEFT", NewUnitFrame.gwMover)

    NewUnitFrame:SetAttribute("*type1", "target")
    NewUnitFrame:SetAttribute("*type2", "togglemenu")
    NewUnitFrame:SetAttribute("unit", "player")
    RegisterUnitWatch(NewUnitFrame)
    NewUnitFrame:EnableMouse(true)
    NewUnitFrame:RegisterForClicks("AnyDown")

    NewUnitFrame.altBg = CreateFrame("Frame", nil, NewUnitFrame, "GwAlternativeUnitFrameBackground")
    NewUnitFrame.altBg:SetAllPoints(NewUnitFrame)
    NewUnitFrame.altBg:SetFrameLevel(0)

    NewUnitFrame.mask = UIParent:CreateMaskTexture()
    NewUnitFrame.mask:SetPoint("CENTER", NewUnitFrame.portrait, "CENTER", 0, 0)

    NewUnitFrame.mask:SetTexture(186178, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    NewUnitFrame.mask:SetSize(58, 58)
    NewUnitFrame.portrait:AddMaskTexture(NewUnitFrame.mask)

    AddToClique(NewUnitFrame)

    -- add pvp marker
    NewUnitFrame.pvp = CreateFrame("Frame", nil, NewUnitFrame)
    NewUnitFrame.pvp:SetSize(128, 128)
    NewUnitFrame.pvp:SetFrameLevel(2)
    NewUnitFrame.pvp:SetAlpha(0.44)
    NewUnitFrame.pvp:SetFrameStrata("BACKGROUND")
    NewUnitFrame.pvp:SetPoint("CENTER", NewUnitFrame.portrait, "CENTER", 0, 0)
    NewUnitFrame.pvp.ally = NewUnitFrame.pvp:CreateTexture(nil, "BACKGROUND")
    NewUnitFrame.pvp.ally:SetTexture("Interface/AddOns/GW2_UI/textures/globe/pvpmode")
    NewUnitFrame.pvp.ally:SetSize(72, 68)
    NewUnitFrame.pvp.ally:SetTexCoord(0, 1, 0, 0.5)
    NewUnitFrame.pvp.ally:SetPoint("CENTER", NewUnitFrame.pvp, "CENTER", 0, 5)
    NewUnitFrame.pvp.ally:Hide()

    NewUnitFrame.pvp.horde = NewUnitFrame.pvp:CreateTexture(nil, "BACKGROUND")
    NewUnitFrame.pvp.horde:SetTexture("Interface/AddOns/GW2_UI/textures/globe/pvpmode")
    NewUnitFrame.pvp.horde:SetSize(78, 78)
    NewUnitFrame.pvp.horde:SetTexCoord(0, 1, 0.51, 1)
    NewUnitFrame.pvp.horde:SetPoint("CENTER", NewUnitFrame.portrait, "CENTER", 0, 5)
    NewUnitFrame.pvp.horde:Hide()

    NewUnitFrame:SetScript("OnEvent", NewUnitFrame.OnEvent)

    NewUnitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    NewUnitFrame:RegisterEvent("WAR_MODE_STATUS_UPDATE")
    NewUnitFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
    NewUnitFrame:RegisterEvent("RESURRECT_REQUEST")
    NewUnitFrame:RegisterEvent("PLAYER_LEVEL_UP")
    NewUnitFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    NewUnitFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    NewUnitFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    NewUnitFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    NewUnitFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    NewUnitFrame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "player")
    NewUnitFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    NewUnitFrame:RegisterUnitEvent("UNIT_FACTION", "player")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    NewUnitFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    NewUnitFrame:SetScript("OnEnter", GwHealthglobeMixin.OnEnter)
    NewUnitFrame:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        if self.pvp.pvpFlag then
            self.pvp:fadeOut()
        end
    end)

    -- grab the TotemFramebuttons to our own Totem Frame
    GW.CreateTotemBar()

    -- setup anim to flash the PvP marker
    local pvp = NewUnitFrame.pvp
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
    NewUnitFrame.castingbarBackground:Hide()
    NewUnitFrame.castingString:Hide()
    NewUnitFrame.castingTimeString:Hide()
    NewUnitFrame.castingbar:Hide()
    NewUnitFrame.castingbarSpark:Hide()
    NewUnitFrame.castingbarNormal:Hide()
    NewUnitFrame.raidmarker:Hide()
    NewUnitFrame.prestigebg:Hide()
    NewUnitFrame.prestigeString:Hide()

    NewUnitFrame:ToggleSettings()

    return NewUnitFrame
end
GW.LoadPlayerFrame = LoadPlayerFrame