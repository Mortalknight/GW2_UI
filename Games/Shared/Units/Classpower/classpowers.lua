---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- Loader/dispatcher for the class power bar: spec selection, event wiring and
-- frame construction. The per-class setups live in the class files of this folder.

local function selectType(f)
    f:SetScript("OnEvent", nil)
    EventRegistry:UnregisterCallback("GW2_UI.ClasspowerPlayerUnitAura", "GW2_UI")
    f:UnregisterAllEvents()

    -- hide all class power sub-pieces and reset anything needed
    f.defaultResourceBar:SetValue(0)
    f.defaultResourceBar:Hide()
    f.customResourceBar:ForceFillAmount(0)
    f.customResourceBar:ResetPowerBarVisuals()
    f.customResourceBar:SetMinMaxValues(0, 1)
    f.customResourceBar:Hide()
    f.customResourceBar:SetWidth(313)
    f.runeBar:Hide()
    f.decayCounter:Hide()
    f.maelstrom:Hide()
    f.priest:Hide()
    f.paladin:Hide()
    f.brewmaster:Hide()
    f.disc:Hide()
    f.decay:Hide()
    f.exbar:Hide()
    f.exbarSecret:Hide()
    f.exbar.decay:Hide()
    f.warlock:Hide()
    f.combopoints:Hide()
    f.evoker:Hide()
    f.eclips:Hide()

    if GW.settings.POWERBAR_ENABLED then
        f.lmb:Hide()
        f.lmb.decay:Hide()
        f.lmbSecret:Hide()
    end
    CP.DisableAuraTrackers(f)
    f.gwPower = -1
    local showBar = false

    if f.unit ~= "vehicle" then
        -- class setups register themselves in CP.setups (one file per class in this
        -- folder); a missing entry means the class/client combination has no bar
        local setup = CP.setups[GW.myClassID]
        if setup then
            showBar = setup(f) or false
        end
    end

    f.shouldShowBar = showBar

    CP.UpdateVisibility(f, InCombatLockdown())
end


local function barChange_OnEvent(self, event)
    if not self then return end
    local f = self:GetParent()
    if event == "UPDATE_SHAPESHIFT_FORM" then
        -- this event fires often when form hasn't changed; check old form against current form
        -- to prevent touching the bar unnecessarily (which causes annoying anim flickering)
        local s = GetShapeshiftFormID()
        if f.gwPlayerForm == s then
            return
        end
        f.gwPlayerForm = s
        selectType(f)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" or event == "CHARACTER_POINTS_CHANGED" or event == "FORCE_UPDATE" then
        f.gwPlayerForm = GetShapeshiftFormID()
        GW.CheckRole()
        selectType(f)
    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        CP.UpdateVisibility(f, event == "PLAYER_REGEN_DISABLED")
    elseif event == "UNIT_ENTERED_VEHICLE" then
        f.unit = "vehicle"
        selectType(f)
    elseif event == "UNIT_EXITED_VEHICLE" then
        f.unit = "player"
        selectType(f)
    end
end

local function UpdateSettings(self, skipEvent)
    self.exbarSecret.showBarValues = GW.settings.CLASSPOWER_SHOW_VALUE
    self.exbar.showBarValues = GW.settings.CLASSPOWER_SHOW_VALUE
    self.lmb.showBarValues = GW.settings.CLASSPOWER_SHOW_VALUE
    self.lmbSecret.showBarValues = GW.settings.CLASSPOWER_SHOW_VALUE
    if skipEvent then return end
    barChange_OnEvent(self.decay, "FORCE_UPDATE")
end
CP.UpdateSettings = UpdateSettings

local function UpdateExtraManabar()
    if not GW.settings.CLASS_POWER then return end

    UpdateSettings(GwPlayerClassPower, true)
    if GW.settings.POWERBAR_ENABLED then
        local anchorFrame = GW.settings.PLAYER_AS_TARGET_FRAME and GwPlayerUnitFrame and GwPlayerUnitFrame or
            GwPlayerPowerBar
        local barWidth = GW.settings.PLAYER_AS_TARGET_FRAME and GwPlayerUnitFrame and
            GwPlayerUnitFrame.powerbar:GetWidth() or GwPlayerPowerBar:GetWidth()

        GwPlayerAltClassLmbSecret:ClearAllPoints()
        GwPlayerAltClassLmb:ClearAllPoints()
        if GW.settings.PLAYER_AS_TARGET_FRAME then
            GwPlayerAltClassLmb:SetPoint("TOPLEFT", anchorFrame.powerbar, "BOTTOMLEFT", 0, -3)
            GwPlayerAltClassLmb:SetPoint("TOPRIGHT", anchorFrame.powerbar, "BOTTOMRIGHT", 0, -3)
            GwPlayerAltClassLmb:SetSize(barWidth + 2, 3)

            GwPlayerAltClassLmbSecret:SetPoint("TOPLEFT", anchorFrame.powerbar, "BOTTOMLEFT", 0, -3)
            GwPlayerAltClassLmbSecret:SetPoint("TOPRIGHT", anchorFrame.powerbar, "BOTTOMRIGHT", 0, -3)
            GwPlayerAltClassLmbSecret:SetSize(barWidth + 2, 3)
        else
            GwPlayerAltClassLmb:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 0)
            GwPlayerAltClassLmb:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 0)
            GwPlayerAltClassLmb:SetSize(barWidth, 5)

            GwPlayerAltClassLmbSecret:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 0)
            GwPlayerAltClassLmbSecret:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 0)
            GwPlayerAltClassLmbSecret:SetSize(barWidth, 5)
        end

        GwPlayerAltClassLmb:SetParent(UIParent)
        GwPlayerAltClassLmbSecret:SetParent(UIParent)

        barChange_OnEvent(GwPlayerClassPower.decay, "FORCE_UPDATE")
    else
        GwPlayerAltClassLmb:SetParent(GW.HiddenFrame)
        GwPlayerAltClassLmbSecret:SetParent(GW.HiddenFrame)
    end
end
CP.UpdateExtraManabar = UpdateExtraManabar

local function LoadClassPowers()
    local cpf = CreateFrame("Frame", "GwPlayerClassPower", UIParent, "GwPlayerClassPower")
    CP.frame = cpf

    cpf.defaultResourceBar = CreateFrame("StatusBar", "GwCustomResourceBar", cpf, "GwStatusPowerBarRetailTemplate")
    cpf.defaultResourceBar:SetSize(313, 14)
    cpf.defaultResourceBar:ClearAllPoints()
    cpf.defaultResourceBar:SetPoint("LEFT", cpf, "LEFT", 0, -11)
    cpf.defaultResourceBar.spark:SetHeight(3)
    cpf.defaultResourceBar.spark:ClearAllPoints()
    cpf.defaultResourceBar.spark:SetPoint("RIGHT", cpf.defaultResourceBar:GetStatusBarTexture(), "RIGHT", 0, 0)
    cpf.defaultResourceBar.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")

    cpf.customResourceBar = GW.CreateAnimatedStatusBar("GwCustomResourceBar", cpf, "GwStatusPowerBar", true)
    cpf.customResourceBar.customMaskSize = 64
    cpf.customResourceBar.bar = cpf.customResourceBar
    cpf.customResourceBar:AddToBarMask(cpf.customResourceBar.intensity)
    cpf.customResourceBar:AddToBarMask(cpf.customResourceBar.intensity2)
    cpf.customResourceBar:AddToBarMask(cpf.customResourceBar.scrollTexture)
    cpf.customResourceBar:AddToBarMask(cpf.customResourceBar.scrollTexture2)
    cpf.customResourceBar:AddToBarMask(cpf.customResourceBar.runeoverlay)
    cpf.customResourceBar.runicmask:SetSize(cpf.customResourceBar:GetSize())
    cpf.customResourceBar.runeoverlay:AddMaskTexture(cpf.customResourceBar.runicmask)

    cpf.customResourceBar.decay = GW.CreateAnimatedStatusBar("GwPlayerPowerBarDecay", UIParent, nil, true)

    cpf.customResourceBar.decay:SetFillAmount(0)
    cpf.customResourceBar.decay:SetFrameLevel(cpf.customResourceBar.decay:GetFrameLevel() - 1)
    cpf.customResourceBar.decay:ClearAllPoints()
    cpf.customResourceBar.decay:SetPoint("TOPLEFT", cpf.customResourceBar, "TOPLEFT", 0, 0)
    cpf.customResourceBar.decay:SetPoint("BOTTOMRIGHT", cpf.customResourceBar, "BOTTOMRIGHT", 0, 0)

    cpf.customResourceBar:SetScript("OnShow", function() cpf.customResourceBar.decay:Show() end)
    cpf.customResourceBar:SetScript("OnHide", function() cpf.customResourceBar.decay:Hide() end)

    cpf.customResourceBar:ClearAllPoints()
    cpf.customResourceBar:SetPoint("LEFT", cpf, "LEFT", 0, -11)

    cpf.customResourceBar.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")

    GW.RegisterMovableFrame(cpf, GW.L["Class Power"], "ClasspowerBar_pos", "Unitframe,Power", { 312, 32 },
        { "default", "scaleable" }, true)

    -- position mover
    if (not GW.settings.XPBAR_ENABLED or GW.settings.PLAYER_AS_TARGET_FRAME) and not cpf.isMoved then
        local framePoint = GW.settings.ClasspowerBar_pos
        local yOff = not GW.settings.XPBAR_ENABLED and 14 or 0
        local xOff = GW.settings.PLAYER_AS_TARGET_FRAME and 52 or 0
        cpf.gwMover:ClearAllPoints()
        cpf.gwMover:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs + xOff,
            framePoint.yOfs - yOff)
    end
    cpf:ClearAllPoints()
    CP.SetClassPowerAnchor(cpf, cpf.gwMover, "TOPLEFT")

    -- need to pull it out of core because of not existing atlas files on non retail clients
    if GW.Retail then
        for i = 1, 6 do
            cpf.evoker["essence" .. i] = CreateFrame("Frame", nil, cpf.evoker, "GwEssencePointTemplate")
            cpf.evoker["essence" .. i]:SetSize(32, 32)
            cpf.evoker["essence" .. i]:SetPoint("LEFT", cpf.evoker, "LEFT", (i - 1) * 32, 0)
        end
    end

    cpf.auraExpirationTime = nil

    -- create an extra mana power bar that is used sometimes (feral druid in cat form) only if your Powerbar is on
    local lmb = GW.CreateAnimatedStatusBar("GwPlayerAltClassLmb", cpf, "GwStatusPowerBar", true)
    lmb.customMaskSize = 64
    lmb.bar = lmb
    lmb:AddToBarMask(lmb.intensity)
    lmb:AddToBarMask(lmb.intensity2)
    lmb:AddToBarMask(lmb.scrollTexture)
    lmb:AddToBarMask(lmb.scrollTexture2)
    lmb:AddToBarMask(lmb.runeoverlay)
    lmb.runicmask:SetSize(lmb:GetSize())
    lmb.runeoverlay:AddMaskTexture(lmb.runicmask)
    cpf.lmb = lmb

    lmb.decay = GW.CreateAnimatedStatusBar("GwPlayerAltClassLmbBarDecay", lmb, nil, true)
    lmb.decay:SetFillAmount(0)
    lmb.decay:SetFrameLevel(lmb.decay:GetFrameLevel() - 1)
    lmb.decay:ClearAllPoints()
    lmb.decay:SetPoint("TOPLEFT", lmb, "TOPLEFT", 0, 0)
    lmb.decay:SetPoint("BOTTOMRIGHT", lmb, "BOTTOMRIGHT", 0, 0)
    lmb:SetFrameStrata("MEDIUM")
    lmb.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small, "SHADOW")

    --create extra mana power for retail
    cpf.lmbSecret = CreateFrame("StatusBar", "GwPlayerAltClassLmbSecret", cpf, "GwStatusPowerBarRetailTemplate")
    cpf.lmbSecret.bar = cpf.lmbSecret
    cpf.lmbSecret:SetSize(313, 14)
    cpf.lmbSecret:ClearAllPoints()
    cpf.lmbSecret:SetPoint("TOPLEFT", cpf)
    cpf.lmbSecret:SetFrameStrata("MEDIUM")
    cpf.lmbSecret.spark:SetHeight(3)
    cpf.lmbSecret.spark:ClearAllPoints()
    cpf.lmbSecret.spark:SetPoint("RIGHT", cpf.lmbSecret:GetStatusBarTexture(), "RIGHT", 0, 0)
    cpf.lmbSecret.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small, "SHADOW")

    -- create an extra mana power bar that is used sometimes
    local exbar = GW.CreateAnimatedStatusBar("GwPlayerAltClassExBar", cpf, "GwStatusPowerBar", true)
    exbar.customMaskSize = 64
    exbar.bar = exbar
    exbar:AddToBarMask(exbar.intensity)
    exbar:AddToBarMask(exbar.intensity2)
    exbar:AddToBarMask(exbar.scrollTexture)
    exbar:AddToBarMask(exbar.scrollTexture2)
    exbar:AddToBarMask(exbar.runeoverlay)
    exbar.runicmask:SetSize(exbar:GetSize())
    exbar.runeoverlay:AddMaskTexture(exbar.runicmask)

    exbar.decay = GW.CreateAnimatedStatusBar("GwPlayerAltClassExBarDecay", exbar, nil, true)
    exbar.decay:SetFillAmount(0)
    exbar.decay:SetFrameLevel(exbar.decay:GetFrameLevel() - 1)
    exbar.decay:ClearAllPoints()
    exbar.decay:SetPoint("TOPLEFT", exbar, "TOPLEFT", 0, 0)
    exbar.decay:SetPoint("BOTTOMRIGHT", exbar, "BOTTOMRIGHT", 0, 0)

    --create extra mana power for retail
    cpf.exbarSecret = CreateFrame("StatusBar", "GwPlayerAltClassExBarSecret", cpf, "GwStatusPowerBarRetailTemplate")
    cpf.exbarSecret.bar = cpf.exbarSecret
    cpf.exbarSecret:SetSize(313, 14)
    cpf.exbarSecret:ClearAllPoints()
    cpf.exbarSecret:SetPoint("TOPLEFT", cpf)
    cpf.exbarSecret:SetFrameStrata("MEDIUM")
    cpf.exbarSecret.spark:ClearAllPoints()
    cpf.exbarSecret.spark:SetPoint("RIGHT", cpf.exbarSecret:GetStatusBarTexture(), "RIGHT", 0, 0)
    cpf.exbarSecret.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")

    if not (GW.Classic or GW.TBC or GW.Wrath) then
        GW.MixinHideDuringPetAndOverride(cpf)
        GW.MixinHideDuringPetAndOverride(cpf.defaultResourceBar)
        GW.MixinHideDuringPetAndOverride(cpf.customResourceBar)
        GW.MixinHideDuringPetAndOverride(cpf.customResourceBar.decay)
        GW.MixinHideDuringPetAndOverride(lmb)
        GW.MixinHideDuringPetAndOverride(lmb.decay)
        GW.MixinHideDuringPetAndOverride(cpf.lmbSecret)
        GW.MixinHideDuringPetAndOverride(exbar)
        GW.MixinHideDuringPetAndOverride(cpf.exbarSecret)
        GW.MixinHideDuringPetAndOverride(exbar.decay)
    end
    cpf.exbar = exbar

    exbar:SetPoint("TOPLEFT", cpf)

    exbar:SetFrameStrata("MEDIUM")
    exbar.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")

    -- set a bunch of other init styling stuff
    cpf.decayCounter.count:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, "OUTLINE", 6)
    cpf.brewmaster.ironskin.indicatorText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    cpf.brewmaster.ironskin.expires = 0
    cpf.disc.bar.overlay:SetModel(1372783)
    cpf.disc.bar.overlay:SetPosition(0, 0, 2)
    cpf.disc.bar.overlay:SetPosition(0, 0, 0)

    cpf.decay:SetScript("OnEvent", barChange_OnEvent)
    cpf.decay:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    cpf.decay:RegisterEvent("PLAYER_ENTERING_WORLD")
    cpf.decay:RegisterEvent("CHARACTER_POINTS_CHANGED")
    cpf.decay:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    cpf.decay:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
    cpf.decay:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")

    cpf.gwPlayerForm = GetShapeshiftFormID()
    cpf.unit = "player"
    cpf:Show()

    cpf.UpdateAlphaFader = CP.UpdateAlphaFader

    UpdateSettings(cpf)
    CP.UpdateVisibilitySetting(cpf, false)
    selectType(cpf)
    UpdateExtraManabar()
end
GW.LoadClassPowers = LoadClassPowers
