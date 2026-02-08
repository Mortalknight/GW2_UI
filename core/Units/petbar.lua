local _, GW = ...
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local LoadAuras = GW.LoadAuras
local RegisterMovableFrame = GW.RegisterMovableFrame

local petStateSprite = {
    width = 512,
    height = 128,
    colums = 4,
    rows = 1
}

GwPlayerPetFrameMixin = {}

function GwPlayerPetFrameMixin:SetActionButtonPositionAndStyle()
    local BUTTON_SIZE = 28
    local BUTTON_MARGIN = 3

    for i, button in ipairs(self.buttons) do
        local autoCast = button.AutoCastOverlay
        local point, relativeFrame, relativePoint, x, y

        if i == 1 then
            point, relativeFrame, relativePoint, x, y = "BOTTOMLEFT", self, "BOTTOMLEFT", 3, 30
        elseif i == 8 then
            point, relativeFrame, relativePoint, x, y = "BOTTOM", PetActionButton5, "TOP", 0, BUTTON_MARGIN
        else
            point, relativeFrame, relativePoint, x, y = "BOTTOMLEFT", _G["PetActionButton" .. (i - 1)], "BOTTOMRIGHT", BUTTON_MARGIN, 0
        end

        local size = (i < 4) and 32 or BUTTON_SIZE
        button:SetScale(1)
        button:SetParent(self)
        button:ClearAllPoints()
        button:SetAttribute("showgrid", 0)
        button:EnableMouse(true)
        button:SetSize(size, size)
        button:SetPoint(point, relativeFrame, relativePoint, x, y)
        if button.SlotBackground then
            button.SlotBackground:SetAlpha(0)
        end

        GW.updateHotkey(button)
        button.noGrid = nil

        button.relativeFrame = relativeFrame
        button.point = point
        button.relativePoint = relativePoint
        button.gwX = x
        button.gwY = y
        hooksecurefunc(button, "SetPoint", function(btn, _, parent)
            if parent ~= btn.relativeFrame then
                if not InCombatLockdown() then
                    btn:ClearAllPoints()
                    btn:SetPoint(btn.point, btn.relativeFrame, btn.relativePoint, btn.gwX, btn.gwY)
                else
                    if not btn:GetParent():IsEventRegistered("PLAYER_REGEN_ENABLED") then
                        btn:GetParent():RegisterEvent("PLAYER_REGEN_ENABLED")
                    end
                end
            end
        end)

        if button.Shine then
            button.Shine:SetSize(size, size)
            autoCast:SetTexture("Interface/AddOns/GW2_UI/Textures/talents/autocast.png")
            autoCast.size = size + 5
            hooksecurefunc(autoCast, "SetSize", function()
                local w = autoCast:GetSize()
                if autoCast.size ~= w then
                    autoCast:SetHeight(autoCast.size)
                    autoCast:SetWidth(autoCast.size)
                end
            end)
        end

        button.showMacroName = GW.settings.SHOWACTIONBAR_MACRO_NAME_ENABLED

        GW.setActionButtonStyle("PetActionButton" .. i, nil, nil, true)
        if not GW.Retail then
            GW.RegisterCooldown(button.cooldown)
        end
    end
end

function GwPlayerPetFrameMixin:UpdatePetBarButtons()
    for _, button in ipairs(self.buttons) do
        if button then
            button.showMacroName = GW.settings.SHOWACTIONBAR_MACRO_NAME_ENABLED
            GW.updateMacroName(button)
        end
    end
end

function GwPlayerPetFrameMixin:Update()
    for i, button in ipairs(self.buttons) do
        local name, texture = GetPetActionInfo(i)

        if name == "PET_ACTION_ATTACK" then
            button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-attack.png")
        elseif name == "PET_ACTION_FOLLOW" then
            button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-follow.png")
        elseif name == "PET_ACTION_MOVE_TO"then
            button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-place.png")
        elseif name == "PET_MODE_ASSIST" or name == "PET_MODE_AGGRESSIVE" then
            button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-assist.png")
        elseif name == "PET_MODE_DEFENSIVEASSIST" or name == "PET_MODE_DEFENSIVE" then
            button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-defense.png")
        elseif name == "PET_MODE_PASSIVE" then
            button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-passive.png")
        else
            button.icon:SetTexture(texture)
        end
    end
end

function GwPlayerPetFrameMixin:UpdateHappiness()
    local happiness, damagePercentage, loyaltyRate = GetPetHappiness()
    local _, isHunterPet = HasPetUI()

    if not happiness or not isHunterPet then
        self.happiness:Hide()
        return
    end
    self.happiness:Show()

    self.happiness.icon:SetTexCoord(GW.getSprite(petStateSprite, happiness, 1))

    self.happiness.tooltip = _G["PET_HAPPINESS" .. happiness]
    self.happiness.tooltipDamage = format(PET_DAMAGE_PERCENTAGE, damagePercentage)

    if loyaltyRate < 0 then
        self.happiness.tooltipLoyalty = LOSING_LOYALTY
    elseif loyaltyRate > 0 then
        self.happiness.tooltipLoyalty = GAINING_LOYALTY
    else
        self.happiness.tooltipLoyalty = nil
    end
end

function GwPlayerPetFrameMixin:OnEvent(event, unit, ...)
    if not UnitExists("pet") then
        return
    end
    local arg1, arg2, arg3, arg4 = ...

    if event == "UNIT_COMBAT" then
        if unit == self.unit then
            CombatFeedback_OnCombatEvent(self, arg1, arg2, arg3, arg4)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        SetPortraitTexture(self.portrait, "pet")
        self:UpdateHealthBar()
        self:UpdatePowerBar(true)
        if GW.Classic or GW.TBC then
            C_Timer.After(0.1, function() self:UpdateHappiness() end)
        end
    elseif event == "UNIT_AURA" then
        GW.UpdateBuffLayout(self, event, unit, ...)
    elseif event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" then
        SetPortraitTexture(self.portrait, "pet")
    elseif event == "PLAYER_REGEN_ENABLED" then
        for i = 1, NUM_PET_ACTION_SLOTS do
            local button = self.buttons[i]
            if button then
                button:ClearAllPoints()
                button:SetPoint(button.point, button.relativeFrame, button.relativePoint, button.gwX, button.gwY)
            end
        end
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    elseif GW.IsIn(event, "PLAYER_TARGET_CHANGED", "PET_BAR_UPDATE_USABLE", "PET_UI_UPDATE", "PET_BAR_UPDATE", "PLAYER_CONTROL_GAINED", "PLAYER_CONTROL_LOST", "PLAYER_FARSIGHT_FOCUS_CHANGED", "SPELLS_CHANGED", "UNIT_FLAGS") or (event == "UNIT_PET" and unit == "player") then
        SetPortraitTexture(self.portrait, "pet")
        if event == "UNIT_PET" then
            self:UpdateHealthBar()
            self:UpdatePowerBar(true)
            self.auras:ForceUpdate()
        end
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH_FREQUENT" then
        self:UpdateHealthBar()
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        self:UpdatePowerBar()
    elseif event == "UNIT_HAPPINESS" then
        self:UpdateHappiness()
    end
end

function GwPlayerPetFrameMixin:ToggleAuraPosition()
    self.auraPositionUnder = GW.settings.PET_AURAS_UNDER

    self.auras:ClearAllPoints()
    if self.auraPositionUnder then
        self.auras:SetPoint("TOPLEFT", self.powerbar, "BOTTOMLEFT", 0, -5)
    else
        self.auras:SetPoint("TOPRIGHT", self.Background, "BOTTOMRIGHT", -3, 100)
    end

    self.auras:ForceUpdate()
end

function GwPlayerPetFrameMixin:ToggleFaderOptions()
    local frameFaderSettings = GW.settings.petFrameFader
    if frameFaderSettings.hover or frameFaderSettings.combat or frameFaderSettings.casting or frameFaderSettings.dynamicflight or frameFaderSettings.health or frameFaderSettings.vehicle or frameFaderSettings.playertarget or frameFaderSettings.unittarget then
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
        self.Fader:SetOption("UnitTarget", frameFaderSettings.unittarget)
        self.Fader:SetOption("PlayerTarget", frameFaderSettings.playertarget)

        self.Fader:ClearTimers()
        self.Fader.configTimer = C_Timer.NewTimer(0.25, function() self.Fader:ForceUpdate() end)
    elseif self.Fader then
        GW.FrameFadeDisable(self)
    end
end

function GwPlayerPetFrameMixin:ToggleCombatFeedback()
    if GW.settings.PET_FLOATING_COMBAT_TEXT then
        self:RegisterEvent("UNIT_COMBAT")
        self:SetScript("OnUpdate", CombatFeedback_OnUpdate)
    else
        self:UnregisterEvent("UNIT_COMBAT")
        self:SetScript("OnUpdate", nil)
    end
end

function GwPlayerPetFrameMixin:UpdateSettings()
    self.showAbsorbBar = GW.settings.PET_SHOW_ABSORB_BAR
    self.shortendHealthValues = GW.settings.PET_UNIT_HEALTH_SHORT_VALUES
    self.showHealthValue = GW.settings.PET_HEALTH_VALUE_RAW
    self.showHealthPrecentage = GW.settings.PET_HEALTH_VALUE_PERCENT

    self:SetScale(GW.settings.pet_pos_scale)
    self:OnEvent("UNIT_PET", "player")
end

local function LoadPetFrame(lm)
    local playerPetFrame = CreateFrame("Button", "GwPlayerPetFrame", UIParent,
        GW.Retail and "GwPlayerPetFramePingableTemplate" or "GwPlayerPetFrameTemplate")

    if GW.Retail then
        playerPetFrame.hpValues = CreateUnitHealPredictionCalculator()
        playerPetFrame.hpValues:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)
        playerPetFrame.hpValues:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.CurrentHealth)
        playerPetFrame.hpValues:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MissingHealth)
        playerPetFrame.hpValues:SetHealAbsorbMode(Enum.UnitHealAbsorbMode.ReducedByIncomingHeals)
        playerPetFrame.hpValues:SetIncomingHealOverflowPercent(1)
    else
        GW.AddStatusbarAnimation(playerPetFrame.health, true)
        GW.AddStatusbarAnimation(playerPetFrame.powerbar, true)
    end

    playerPetFrame.healthString = playerPetFrame.health.text
    playerPetFrame.health.customMaskSize = 64
    playerPetFrame.powerbar.customMaskSize = 64

    playerPetFrame.buttons = {}
    playerPetFrame.unit = "pet"

    playerPetFrame:SetAttribute("*type1", "target")
    playerPetFrame:SetAttribute("*type2", "togglemenu")
    playerPetFrame:SetAttribute("unit", playerPetFrame.unit)
    playerPetFrame:EnableMouse(true)
    playerPetFrame:RegisterForClicks("AnyDown")
    GW.AddToClique(playerPetFrame)
    RegisterStateDriver(playerPetFrame, "visibility",
        "[overridebar] hide; [vehicleui] hide; [petbattle] hide; [target=pet,exists] show; hide")

    playerPetFrame.health:SetStatusBarColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
    playerPetFrame.health.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -1)

    playerPetFrame:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(self.unit)
        GameTooltip:Show()
    end)

    playerPetFrame.debuffFilter = "PLAYER|HARMFUL"
    playerPetFrame.displayBuffs = 32
    playerPetFrame.displayDebuffs = 40
    playerPetFrame.auras.smallSize = 20
    playerPetFrame.auras.bigSize = 24

    playerPetFrame.happiness:SetScript("OnEnter", function(self)
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.tooltip)
            if self.tooltipDamage then
                GameTooltip:AddLine(self.tooltipDamage, 1, 1, 1, true)
            end
            if self.tooltipLoyalty then
                GameTooltip:AddLine(self.tooltipLoyalty, 1, 1, 1, true)
            end
            GameTooltip:Show()
        end
    end)
    playerPetFrame.happiness:SetScript("OnLeave", GameTooltip_Hide)

    LoadAuras(playerPetFrame)

    playerPetFrame:ToggleAuraPosition()

    playerPetFrame:SetScript("OnLeave", GameTooltip_Hide)
    playerPetFrame:SetScript("OnEvent", playerPetFrame.OnEvent)
    playerPetFrame:HookScript("OnShow",
        function(self)
            self:OnEvent("UNIT_PET", "player")
        end)

    playerPetFrame:RegisterUnitEvent("UNIT_PET", "player")
    playerPetFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_MAXPOWER", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_HEALTH", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_AURA", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_MODEL_CHANGED", "pet")
    playerPetFrame:RegisterEvent("PET_UI_UPDATE")
    playerPetFrame:RegisterEvent("PET_BAR_UPDATE")
    playerPetFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
    playerPetFrame:RegisterEvent("PLAYER_CONTROL_LOST")
    playerPetFrame:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
    playerPetFrame:RegisterEvent("SPELLS_CHANGED")
    playerPetFrame:RegisterEvent("UNIT_FLAGS")
    playerPetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    playerPetFrame:RegisterEvent("PET_BAR_UPDATE_USABLE")
    playerPetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    playerPetFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    if GW.Classic or GW.TBC then
        playerPetFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "pet")
        playerPetFrame:RegisterEvent("UNIT_HAPPINESS")
    end

    RegisterMovableFrame(playerPetFrame, PET, "pet_pos", ALL .. ",Unitframe", nil, { "default" }, true)
    lm:RegisterPetFrame(playerPetFrame)

    playerPetFrame:ClearAllPoints()
    playerPetFrame:SetPoint("TOPLEFT", playerPetFrame.gwMover)

    -- Pet Actionbuttons here
    for i = 1, NUM_PET_ACTION_SLOTS do
        local button = _G["PetActionButton" .. i]
        button:Show()
        playerPetFrame.buttons[i] = button
    end
    playerPetFrame:SetActionButtonPositionAndStyle()

    if GW.Retail or GW.TBC then
        PetActionBar.ignoreFramePositionManager = true
        PetActionBar:GwKillEditMode()
        PetActionBar:SetParent(GW.HiddenFrame)

        hooksecurefunc(PetActionBar, "Update", function() playerPetFrame:Update() end)
    else
        hooksecurefunc("PetActionBar_Update", function() playerPetFrame:Update() end)
    end

    -- hook hotkey update calls so we can override styling changes
    local hotkeyEventTrackerFrame = CreateFrame("Frame")
    hotkeyEventTrackerFrame:RegisterEvent("UPDATE_BINDINGS")
    hotkeyEventTrackerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    hotkeyEventTrackerFrame:SetScript("OnEvent", function()
        for _, button in ipairs(playerPetFrame.buttons) do
            GW.updateHotkey(button)
            GW.FixHotKeyPosition(button, false, true)
        end
    end)

    -- create floating combat text
    playerPetFrame.feedbackText = playerPetFrame:CreateFontString(nil, "OVERLAY")
    playerPetFrame.feedbackText:SetFont(DAMAGE_TEXT_FONT, 30, "")
    playerPetFrame.feedbackText:SetPoint("CENTER", playerPetFrame.portrait, "CENTER")
    playerPetFrame.feedbackText:Hide()
    playerPetFrame.feedbackFontHeight = 30
    playerPetFrame:ToggleCombatFeedback()

    --frame fader init
    playerPetFrame:ToggleFaderOptions()
    playerPetFrame:UpdateSettings()
end
GW.LoadPetFrame = LoadPetFrame
