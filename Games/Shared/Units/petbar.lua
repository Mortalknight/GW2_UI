---@class GW2
local GW = select(2, ...)
local LoadAuras = GW.LoadAuras
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetPetHappinessInfo = not GW.Retail and (C_PetInfo and C_PetInfo.GetPetHappiness or GetPetHappiness) or nil

local HEALTH_COLOR = GW.globalDefault.profile.unitframes.reactionColors.Hostile
local MEND_PET, REVIVE_PET, CALL_PET = 136, 982, 883

-- 1 below half health and 0 above, so the secret health of the modern clients never reaches lua
local lowHealthCurve
if C_CurveUtil and UnitHealthPercent then
    lowHealthCurve = C_CurveUtil.CreateCurve()
    lowHealthCurve:SetType(Enum.LuaCurveType.Step)
    lowHealthCurve:AddPoint(0, 1)
    lowHealthCurve:AddPoint(0.5, 0)
    lowHealthCurve:AddPoint(1, 0)
end

local petStateSprite = {
    width = 512,
    height = 128,
    colums = 4,
    rows = 1
}

local function UpdatePetButtonHotkey(button)
    button.gw_HasAction = GetPetActionInfo(button:GetID()) ~= nil
    GW.UpdateHotkey(button)
    GW.FixHotKeyPosition(button, false, true)
end

GwPlayerPetFrameMixin = {}

function GwPlayerPetFrameMixin:SetActionButtonPositionAndStyle()
    local BUTTON_SIZE = 28
    local BUTTON_MARGIN = 3

    for i, button in ipairs(self.buttons) do
        local autoCast = button.AutoCastOverlay
        local point, relativeFrame, relativePoint, x, y

        if i == 1 then
            point, relativeFrame, relativePoint, x, y = "BOTTOMLEFT", self, "BOTTOMLEFT", self:GetFirstButtonOffset(), 30
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

        if button.SetHotkeys and not button.gwPetHotkeyHooked then
            button.gwPetHotkeyHooked = true
            hooksecurefunc(button, "SetHotkeys", UpdatePetButtonHotkey)
        end
        UpdatePetButtonHotkey(button)
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

        button.gw_ShowMacroName = GW.settings.actionbars.showMacroNames

        GW.setActionButtonStyle("PetActionButton" .. i, nil, nil, true)
        GW.RegisterCooldown(button.cooldown)
    end
end

function GwPlayerPetFrameMixin:UpdatePetBarButtons()
    for _, button in ipairs(self.buttons) do
        if button then
            button.gw_ShowMacroName = GW.settings.actionbars.showMacroNames
            GW.UpdateMacroName(button)
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
        elseif name == "PET_ACTION_MOVE_TO" or name == "PET_ACTION_WAIT" then
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
    local happiness, damagePercentage, loyaltyRate = GetPetHappinessInfo()
    local _, isHunterPet = HasPetUI()
    local display = GW.settings.unitframes.pet.happinessDisplay
    if not isHunterPet or display == "HIDE" then
        happiness = nil
    end

    local color = happiness and display == "HEALTHCOLOR" and GW.Colors.PetHappinessColors[happiness] or HEALTH_COLOR
    self.health:SetStatusBarColor(color.r, color.g, color.b)
    -- the notification shows the icon only while the pet is not happy, pulsing
    self.happiness:SetShown(happiness and (display == "ICON" or (display == "NOTIFY" and happiness < 3)))
    if display == "NOTIFY" and self.happiness:IsShown() then
        if not self.happiness.pulse then
            local pulse = self.happiness:CreateAnimationGroup()
            pulse:SetLooping("BOUNCE")
            local fade = pulse:CreateAnimation("Alpha")
            fade:SetFromAlpha(1)
            fade:SetToAlpha(0.4)
            fade:SetDuration(0.6)
            self.happiness.pulse = pulse
        end
        if not self.happiness.pulse:IsPlaying() then
            self.happiness.pulse:Play()
        end
    elseif self.happiness.pulse then
        self.happiness.pulse:Stop()
    end
    self.happiness.tooltip = happiness and _G["PET_HAPPINESS" .. happiness]
    if not happiness then return end

    self.happiness.icon:SetTexCoord(GW.getSprite(petStateSprite, happiness, 1))

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
        if unit == self.gwUnit then
            GW.CombatFeedbackOnEvent(self, arg1, arg2, arg3, arg4)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        SetPortraitTexture(self.portrait, "pet")
        self:UpdateTextTags()
        self:UpdateHealthBar()
        self:UpdatePowerBar(true)
        if GetPetHappinessInfo then
            C_Timer.After(0.1, function() self:UpdateHappiness() end)
        end
    elseif event == "UNIT_AURA" then
        GW.UpdateBuffLayout(self, event, unit, ...)
    elseif event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" or event == "PORTRAITS_UPDATED" then
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
            self:UpdateTextTags()
            self:UpdateHealthBar()
            self:UpdatePowerBar(true)
            if self.auras.ForceUpdate then -- Classic path; on Retail the container refreshes itself
                self.auras:ForceUpdate()
            end
            if GetPetHappinessInfo then
                self:UpdateHappiness()
            end
            self:UpdateHints()
        end
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH_FREQUENT" then
        self:UpdateHealthBar()
        self:UpdateHints()
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        self:UpdatePowerBar()
    elseif event == "UNIT_HAPPINESS" then
        self:UpdateHappiness()
        self:UpdateHints()
    end
end

-- the buttons start above the bars; protected frames only anchor to frames, so they sit on the pet frame itself
function GwPlayerPetFrameMixin:GetFirstButtonOffset()
    return GW.settings.unitframes.pet.portraitPosition == "LEFT" and self.portraitBackground:GetWidth() + 3 or 3
end

-- a small icon on the portrait of a hunter pet: mend it while it is low; it only hints, a button would
-- have to show and hide in combat. The alpha of the icon carries the visibility, so it pulses in size,
-- an alpha animation would set the alpha back to 1
local function CreatePetHint(frame, spellID)
    local hint = CreateFrame("Frame", nil, frame)
    hint:SetSize(20, 20)
    hint:SetFrameLevel(frame.health:GetFrameLevel() + 5)

    local icon = hint:CreateTexture(nil, "OVERLAY")
    hint.icon = icon
    icon:SetAllPoints()
    icon:SetTexture(C_Spell.GetSpellTexture(spellID))
    local mask = hint:CreateMaskTexture()
    mask:SetTexture("Interface/AddOns/GW2_UI/textures/globe/mask.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(icon)
    icon:AddMaskTexture(mask)

    local pulse = hint:CreateAnimationGroup()
    pulse:SetLooping("BOUNCE")
    local grow = pulse:CreateAnimation("Scale")
    grow:SetScaleFrom(1, 1)
    grow:SetScaleTo(1.25, 1.25)
    grow:SetDuration(0.6)
    hint:SetScript("OnShow", function() pulse:Play() end)
    hint:SetScript("OnHide", function() pulse:Stop() end)
    hint:Hide()
    return hint
end

function GwPlayerPetFrameMixin:UpdateHints()
    if not self.mendHint then return end
    local canMend = C_SpellBook.IsSpellKnown(MEND_PET) and not UnitIsDead("pet")
    self.mendHint:SetShown(canMend)
    if canMend then
        local visible
        if lowHealthCurve then
            visible = UnitHealthPercent("pet", false, lowHealthCurve)
        else
            local healthMax = UnitHealthMax("pet")
            visible = healthMax > 0 and UnitHealth("pet") / healthMax < 0.5 and 1 or 0
        end
        self.mendHint.icon:SetAlpha(visible)
    end
end

function GwPlayerPetFrameMixin:TogglePortraitSide()
    local firstButton = self.buttons[1]
    if firstButton and firstButton.point then
        firstButton.gwX = self:GetFirstButtonOffset()
        firstButton:ClearAllPoints()
        firstButton:SetPoint(firstButton.point, firstButton.relativeFrame, firstButton.relativePoint, firstButton.gwX, firstButton.gwY)
    end

    local position = GW.settings.unitframes.pet.portraitPosition
    self.portrait:SetShown(position ~= "HIDE")
    self.portraitBackground:SetShown(position ~= "HIDE")

    -- next to the bars without a portrait, so it has to match their height instead of the portraits corner
    self.happiness:SetSize(position == "HIDE" and 24 or 30, position == "HIDE" and 24 or 30)
    self.happiness:SetFrameLevel(self.health:GetFrameLevel() + 2)

    self.Background:ClearAllPoints()
    self.portraitBackground:ClearAllPoints()
    self.happiness:ClearAllPoints()
    if position == "LEFT" then
        self.portraitBackground:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 1)
        self.Background:SetPoint("BOTTOMLEFT", self.portraitBackground, "BOTTOMRIGHT", 0, 3)
        self.happiness:SetPoint("CENTER", self.portraitBackground, "BOTTOMLEFT", 7, 8)
        self.portrait:SetTexCoord(0, 1, 0, 1)
    else
        self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 4)
        self.portraitBackground:SetPoint("BOTTOMLEFT", self.Background, "BOTTOMRIGHT", 0, -3)
        self.portrait:SetTexCoord(1, 0, 0, 1)
        if position == "HIDE" then
            self.happiness:SetPoint("LEFT", self.Background, "RIGHT", 3, -2)
        else
            self.happiness:SetPoint("CENTER", self.portraitBackground, "BOTTOMRIGHT", -7, 8)
        end
    end

    self:SetWidth(self.Background:GetWidth() + (position ~= "HIDE" and self.portraitBackground:GetWidth() or GetPetHappinessInfo and 27 or 0))

    -- the call pet button and the hints lie on the portrait; a protected frame only anchors to frames, so the
    -- spots are worked out from the frame, the portrait sits on its bottom edge
    local portraitSize = self.portraitBackground:GetWidth()
    local portraitLeft = position == "LEFT" and 0 or self.Background:GetWidth()
    if self.mendHint then
        self.mendHint:ClearAllPoints()
        self.mendHint:SetPoint("CENTER", self, "BOTTOMLEFT", portraitLeft + portraitSize - 8, portraitSize - 7)
    end
    -- its name goes to the side of the bars
    local callButton = self.callButton
    if callButton then
        callButton:ClearAllPoints()
        callButton:SetPoint("CENTER", self, "BOTTOMLEFT", portraitLeft + portraitSize / 2, 1 + portraitSize / 2)
        callButton.label:ClearAllPoints()
        if position == "LEFT" then
            callButton.label:SetPoint("LEFT", callButton, "RIGHT", 10, 0)
        else
            callButton.label:SetPoint("RIGHT", callButton, "LEFT", -10, 0)
        end
    end
end

function GwPlayerPetFrameMixin:ToggleAuraPosition()
    self.auraPositionUnder = GW.settings.unitframes.pet.aurasUnder

    self.auras:ClearAllPoints()
    if self.auraPositionUnder then
        self.auras:SetPoint("TOPLEFT", self.powerbar, "BOTTOMLEFT", 0, -5)
    else
        self.auras:SetPoint("TOPRIGHT", self.Background, "BOTTOMRIGHT", -3, GW.Gamepad.IsInterface() and 24 or 100)
    end

    if GW.isModern and self.aurasContainer then
        -- above the frame (default) the rows have to grow UPWARD, away from the
        -- action buttons — below the powerbar they grow downward (old auraPositon logic)
        local cfg = self.aurasContainer.gwConfig
        local debuffCfg = self.debuffsContainer.gwConfig
        local growUp = not self.auraPositionUnder
        local anchorPoint = self.auraPositionUnder and "TOPRIGHT" or "BOTTOMRIGHT"
        cfg.anchorPoint, debuffCfg.anchorPoint = anchorPoint, anchorPoint
        cfg.growUp, debuffCfg.growUp = growUp, growUp

        self.aurasContainer:ClearAllPoints()
        -- the auras frame extends DOWNWARD from its anchor — the old engine grew the
        -- buttons upward from the frame's TOPRIGHT, so the container's bottom sits there
        self.aurasContainer:SetPoint(anchorPoint, self.auras, "TOPRIGHT")

        -- the debuff block stacks onto the buff container (below when growing down,
        -- above when growing up); with buffs disabled it takes their place
        self.debuffsContainer:ClearAllPoints()
        if GW.settings.unitframes.pet.buffFilter == "none" then
            self.debuffsContainer:SetPoint(anchorPoint, self.auras, "TOPRIGHT")
        elseif growUp then
            self.debuffsContainer:SetPoint("BOTTOMRIGHT", self.aurasContainer, "TOPRIGHT", 0, 4)
        else
            self.debuffsContainer:SetPoint("TOPRIGHT", self.aurasContainer, "BOTTOMRIGHT", 0, -4)
        end

        self.aurasContainer:GwUpdateLayout()
        self.debuffsContainer:GwUpdateLayout()
    elseif self.auras.ForceUpdate then -- Classic path
        self.auras:ForceUpdate()
    end
end

function GwPlayerPetFrameMixin:ToggleFaderOptions()
    local frameFaderSettings = GW.settings.unitframes.pet.fader
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
    if GW.settings.unitframes.pet.floatingCombatText then
        self:RegisterUnitEvent("UNIT_COMBAT", self.gwUnit)
        self:SetScript("OnUpdate", CombatFeedback_OnUpdate)
    else
        self:UnregisterEvent("UNIT_COMBAT")
        self:SetScript("OnUpdate", nil)
    end
end

-- Aura part of UpdateSettings, split out for onSettingsRefresh — combat safe,
-- unlike the full settings pass (SetScale on the protected pet frame)
function GwPlayerPetFrameMixin:ApplyAuraSettings()
    -- filters/sizes/sort/ignore list via the shared factory helper; the pet bar
    -- uses fixed 20/24 icon sizes (no per-frame size settings)
    GW.ApplyAuraContainerSettings(self.aurasContainer, self.debuffsContainer, {
        smallSize = 20,
        bigSize = 24,
        buffFilter = GW.settings.unitframes.pet.buffFilter,
        debuffFilter = GW.settings.unitframes.pet.debuffFilter,
        buffAdvanced = GW.settings.unitframes.pet.buffFilterAdvanced,
        debuffAdvanced = GW.settings.unitframes.pet.debuffFilterAdvanced,
        sort = GW.settings.unitframes.pet.auraSort,
        excludeSpellIDs = GW.settings.unitframes.pet.ignoredAuras,
    })
    -- re-anchor the debuff container: with buffs disabled it takes the buffs' place
    self:ToggleAuraPosition()
end

function GwPlayerPetFrameMixin:UpdateSettings()
    self.showAbsorbBar = GW.settings.unitframes.pet.showAbsorbBar
    self:ApplyTextTags()

    if GW.isModern and self.aurasContainer then
        self:ApplyAuraSettings()
    else
        self.displayBuffs = GW.settings.unitframes.pet.buffFilter == "none" and 0 or 32
        self.auras.buffFilter = GW.settings.unitframes.pet.buffFilter
        self.auras.buffAdvancedFilters = GW.settings.unitframes.pet.buffFilterAdvanced

        self.displayDebuffs = GW.settings.unitframes.pet.debuffFilter == "none" and 0 or 40
        self.auras.debuffFilter = GW.settings.unitframes.pet.debuffFilter
        self.auras.debuffAdvancedFilters = GW.settings.unitframes.pet.debuffFilterAdvanced
        GW.UpdateFilters(self.auras)

        self.auras.smallSize = 20
        self.auras.bigSize = 24
        self.auras.ignoredAuraSpellIDs = GW.settings.unitframes.pet.ignoredAuras
    end

    -- statusbar texture
    local texture = GW.Libs.LSM:Fetch("statusbar", GW.settings.unitframes.pet.healthBarTexture)
    self.health:SetStatusBarTexture(texture)

    self:SetScale(GW.settings.unitframes.pet.scale)
    if self.callButton then
        self.callButton:SetScale(GW.settings.unitframes.pet.scale)
    end
    self:OnEvent("UNIT_PET", "player")
end

-- the look of the pet frame, shared by the frame and its text preview; the texts sit in the middle of the bars
local function CreatePetFrame(name)
    local frame = CreateFrame("Button", name, UIParent,
        GW.isModern and "GwPlayerPetFramePingableTemplate" or "GwPlayerPetFrameTemplate")
    GW.SetFrameRoleset(frame, "unitFrames")
    Mixin(frame, GW.UnitFrameTextMixin)
    frame.gwUnit = "pet"
    frame.buttons = {}
    frame.centeredTexts = true

    if not GW.isModern then
        GW.AddStatusbarAnimation(frame.health, true)
        GW.AddStatusbarAnimation(frame.powerbar, true)
    end

    frame.healthString = frame.health.text
    frame.health.customMaskSize = 64
    frame.powerbar.customMaskSize = 64
    frame.powerbar.label = frame.powerbar:CreateFontString(nil, "OVERLAY")

    frame.health:SetStatusBarColor(HEALTH_COLOR.r, HEALTH_COLOR.g, HEALTH_COLOR.b)
    frame.health.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -1)
    return frame
end

GW.SetUnitFrameTextPreviewBuilder("pet", function() return CreatePetFrame("GwPlayerPetFrameTextPreview") end,
    function(frame) frame:TogglePortraitSide() end)

-- revive or call the pet on its portrait while it is dead or away; the state driver switches the spell, also in combat
local function LoadPetCallButton(frame)
    if not C_SpellBook.IsSpellKnown(REVIVE_PET) and not C_SpellBook.IsSpellKnown(CALL_PET) then
        return false
    end

    local button = CreateFrame("Button", "GwPetCallButton", UIParent, "SecureActionButtonTemplate, SecureHandlerStateTemplate")
    button:SetSize(46, 46)
    button:SetScale(GW.settings.unitframes.pet.scale)
    button:SetFrameStrata(frame:GetFrameStrata())
    button:SetFrameLevel(frame:GetFrameLevel() + 10)
    button:RegisterForClicks("AnyUp", "AnyDown")
    button:SetAttribute("type", "spell")
    button:SetAttribute("gw_revive", REVIVE_PET)
    button:SetAttribute("gw_call", CALL_PET)

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints()
    local mask = button:CreateMaskTexture()
    mask:SetTexture("Interface/AddOns/GW2_UI/textures/globe/mask.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints()
    button.icon:AddMaskTexture(mask)

    -- without a pet the frame is hidden and the spot of the bars is free for the spell name
    button.label = button:CreateFontString(nil, "OVERLAY")
    button.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
    button.label:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    button:HookScript("OnAttributeChanged", function(self, name, value)
        if name == "spell" then
            self.icon:SetTexture(C_Spell.GetSpellTexture(value))
            self.label:SetText(C_Spell.GetSpellName(value))
            self.label:SetShown(value == CALL_PET)
        end
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(self:GetAttribute("spell"))
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)

    button:SetAttribute("_onstate-petstate", [[
        if newstate == "hide" then
            self:Hide()
        else
            self:SetAttribute("spell", self:GetAttribute(newstate == "revive" and "gw_revive" or "gw_call"))
            self:Show()
        end
    ]])
    -- marksmanship hunters on retail play without a pet
    RegisterStateDriver(button, "petstate", "[overridebar] hide; [vehicleui] hide; [petbattle] hide; [mounted] hide; [@pet,dead] revive; "
        .. (GW.Retail and "[spec:2] hide; " or "") .. "[@pet,noexists] call; hide")
    frame.callButton = button
    frame:TogglePortraitSide()
    return true
end

local function LoadPetFrame(lm)
    local playerPetFrame = CreatePetFrame("GwPlayerPetFrame")

    if GW.isModern then
        playerPetFrame.hpValues = CreateUnitHealPredictionCalculator()
        playerPetFrame.hpValues:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth)
        playerPetFrame.hpValues:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.CurrentHealth)
        playerPetFrame.hpValues:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MissingHealth)
        playerPetFrame.hpValues:SetHealAbsorbMode(Enum.UnitHealAbsorbMode.ReducedByIncomingHeals)
        playerPetFrame.hpValues:SetIncomingHealOverflowPercent(1)
    end

    playerPetFrame:SetAttribute("*type1", "target")
    playerPetFrame:SetAttribute("*type2", "togglemenu")
    playerPetFrame:SetAttribute("unit", playerPetFrame.gwUnit)
    playerPetFrame:EnableMouse(true)
    playerPetFrame:RegisterForClicks("AnyDown")
    GW.AddToClique(playerPetFrame)
    RegisterStateDriver(playerPetFrame, "visibility",
        "[overridebar] hide; [vehicleui] hide; [petbattle] hide; [target=pet,exists] show; hide")

    playerPetFrame:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(self.gwUnit)
        local happiness = self.happiness
        if happiness.tooltip then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(happiness.tooltip, 1, 1, 1)
            GameTooltip:AddLine(happiness.tooltipDamage, 1, 1, 1, true)
            if happiness.tooltipLoyalty then
                GameTooltip:AddLine(happiness.tooltipLoyalty, 1, 1, 1, true)
            end
        end
        GameTooltip:Show()
    end)


    if GW.isModern then
        -- 12.1: pet auras run through the AuraContainer system (factory) —
        -- the container is attached to the old auras frame so that ToggleAuraPosition
        -- (position below the power bar vs. to the right) keeps working unchanged
        playerPetFrame.aurasContainer = GW.CreateUnitAuraContainer({
            name = "GwPetAuraContainer",
            unit = "pet",
            pandemicEnabled = function() return GW.settings.unitframes.pet.pandemicHighlight end,
            dispelIconEnabled = function() return GW.settings.unitframes.pet.dispelIcon end,
            newAuraAnimation = true,
            parent = playerPetFrame,
            cancelButtons = "RightButtonDown",
            tooltipAnchor = { "ANCHOR_BOTTOMLEFT", -5, -5 },
            refreshEvents = { "UNIT_PET" },
            refreshUnit = "player",
            anchorPoint = "TOPRIGHT",
            growLeft = true,
            maximumLineSize = playerPetFrame.auras:GetWidth(),
            elementSpacing = 3,
            lineSpacing = 4,
            -- one refresh hook covers both containers; must stay combat safe (never
            -- the full UpdateSettings — its SetScale is blocked in combat)
            onSettingsRefresh = function() playerPetFrame:ApplyAuraSettings() end,
            groups = {
                -- ONE group per aura type — any second group duplicates secret auras
                { key = "buffs", filter = "HELPFUL", size = 20, maxFrameCount = 32, showPandemic = true },
            },
        })
        playerPetFrame.aurasContainer:SetPoint("TOPRIGHT", playerPetFrame.auras, "TOPRIGHT")

        -- Debuffs live in their own container stacked onto the buff container (which
        -- sizes itself to its content): the debuff block always starts on its own line
        -- while own and other debuffs flow together like the buffs do — anchoring is
        -- handled by ToggleAuraPosition
        playerPetFrame.debuffsContainer = GW.CreateUnitAuraContainer({
            name = "GwPetDebuffContainer",
            unit = "pet",
            pandemicEnabled = function() return GW.settings.unitframes.pet.pandemicHighlight end,
            dispelIconEnabled = function() return GW.settings.unitframes.pet.dispelIcon end,
            newAuraAnimation = true,
            parent = playerPetFrame,
            tooltipAnchor = { "ANCHOR_BOTTOMLEFT", -5, -5 },
            refreshEvents = { "UNIT_PET" },
            refreshUnit = "player",
            anchorPoint = "TOPRIGHT",
            growLeft = true,
            maximumLineSize = playerPetFrame.auras:GetWidth(),
            elementSpacing = 3,
            lineSpacing = 4,
            groups = {
                { key = "debuffs", filter = "HARMFUL", size = 24, maxFrameCount = 40, isDebuff = true, showPandemic = true, showDispelIcon = true },
            },
        })
    else
        LoadAuras(playerPetFrame)
    end

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
    if not GW.isModern then -- on Modern the AuraContainer handles the aura updates itself
        playerPetFrame:RegisterUnitEvent("UNIT_AURA", "pet")
    end
    playerPetFrame:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_MODEL_CHANGED", "pet")
    playerPetFrame:RegisterEvent("PORTRAITS_UPDATED")
    playerPetFrame:RegisterEvent("PET_UI_UPDATE")
    playerPetFrame:RegisterEvent("PET_BAR_UPDATE")
    playerPetFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
    playerPetFrame:RegisterEvent("PLAYER_CONTROL_LOST")
    playerPetFrame:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
    playerPetFrame:RegisterEvent("SPELLS_CHANGED")
    playerPetFrame:RegisterUnitEvent("UNIT_FLAGS", "pet")
    playerPetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    playerPetFrame:RegisterEvent("PET_BAR_UPDATE_USABLE")
    playerPetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    playerPetFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    if GW.Classic or GW.TBC or GW.Wrath then
        playerPetFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "pet")
    end

    if GetPetHappinessInfo then
        playerPetFrame:RegisterEvent("UNIT_HAPPINESS")
    end

    RegisterMovableFrame(playerPetFrame, PET, "unitframes.pet", "Unitframe", nil, nil, true)
    lm:RegisterPetFrame(playerPetFrame)

    playerPetFrame:ClearAllPoints()
    playerPetFrame:SetPoint("TOPLEFT", playerPetFrame.gwMover)

    -- pet action buttons; the gamepad interface brings its own, there only portrait and bars are ours
    local ownPetButtons = not GW.Gamepad.IsInterface()
    if ownPetButtons then
        for i = 1, NUM_PET_ACTION_SLOTS do
            local button = _G["PetActionButton" .. i]
            button:Show()
            playerPetFrame.buttons[i] = button
        end
    end
    if GW.myclass == "HUNTER" then
        playerPetFrame.mendHint = CreatePetHint(playerPetFrame, MEND_PET)
    end
    playerPetFrame:TogglePortraitSide()
    playerPetFrame:SetActionButtonPositionAndStyle()

    if ownPetButtons then
        PetActionBar.ignoreFramePositionManager = true
        PetActionBar:GwKillEditMode()
        PetActionBar:SetParent(GW.HiddenFrame)
    end

    hooksecurefunc(PetActionBar, "Update", function()
        playerPetFrame:Update()
        -- the pet abilities change with the pet, the labels of the used slots follow
        if GW.settings.actionbars.buttonAssignmentsUsedOnly then
            for _, button in ipairs(playerPetFrame.buttons) do
                UpdatePetButtonHotkey(button)
            end
        end
    end)

    -- era clients set the pet hotkeys through a global instead of a button method
    if PetActionButton_SetHotkeys then
        hooksecurefunc("PetActionButton_SetHotkeys", UpdatePetButtonHotkey)
    end

    -- hook hotkey update calls so we can override styling changes
    local hotkeyEventTrackerFrame = CreateFrame("Frame")
    hotkeyEventTrackerFrame:RegisterEvent("UPDATE_BINDINGS")
    hotkeyEventTrackerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    hotkeyEventTrackerFrame:SetScript("OnEvent", function()
        for _, button in ipairs(playerPetFrame.buttons) do
            UpdatePetButtonHotkey(button)
        end
    end)

    -- create floating combat text
    playerPetFrame.feedbackText = playerPetFrame:CreateFontString(nil, "OVERLAY")
    playerPetFrame.feedbackText:SetFont(DAMAGE_TEXT_FONT, 20, "")
    playerPetFrame.feedbackText:SetPoint("CENTER", playerPetFrame.portrait, "CENTER")
    playerPetFrame.feedbackText:Hide()
    playerPetFrame.feedbackFontHeight = 20
    playerPetFrame:ToggleCombatFeedback()

    -- the secure button needs the pet spells and no combat, a reload in combat or a low hunter waits for both
    if GW.myclass == "HUNTER" and (InCombatLockdown() or not LoadPetCallButton(playerPetFrame)) then
        local callButtonWatcher = CreateFrame("Frame")
        callButtonWatcher:RegisterEvent("SPELLS_CHANGED")
        callButtonWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
        callButtonWatcher:SetScript("OnEvent", function(self)
            if not InCombatLockdown() and LoadPetCallButton(playerPetFrame) then
                self:UnregisterAllEvents()
            end
        end)
    end

    --frame fader init
    playerPetFrame:ToggleFaderOptions()
    playerPetFrame:UpdateSettings()
end
GW.LoadPetFrame = LoadPetFrame
