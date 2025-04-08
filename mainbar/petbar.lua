local _, GW = ...
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local LoadAuras = GW.LoadAuras
local RegisterMovableFrame = GW.RegisterMovableFrame

GwPlayerPetFrameMixin = {}

local function UpdatePetActionBarIcons()
    PetActionButton1Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-attack")
    PetActionButton2Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-follow")
    PetActionButton3Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-place")

    PetActionButton8Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-assist")
    PetActionButton9Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-defense")
    PetActionButton10Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-passive")
end
GW.AddForProfiling("petbar", "UpdatePetActionBarIcons", UpdatePetActionBarIcons)

function GwPlayerPetFrameMixin:SetActionButtonPositionAndStyle()
    local BUTTON_SIZE = 28
    local BUTTON_MARGIN = 3

    for i, button in ipairs(self.buttons) do
        local autoCast = button.AutoCastOverlay
        local point, relativeFrame, relativePoint, x, y

        if i == 1 then
            point, relativeFrame, relativePoint, x, y = "BOTTOMLEFT", self, "BOTTOMLEFT", 3, 30
        elseif i == 8 then
            point, relativeFrame, relativePoint, x, y = "BOTTOM", _G["PetActionButton5"], "TOP", 0, BUTTON_MARGIN
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
            autoCast:SetTexture("Interface/AddOns/GW2_UI/Textures/talents/autocast")
            autoCast.size = size + 5
            hooksecurefunc(autoCast, "SetSize", function()
                local w = autoCast:GetSize()
                if autoCast.size ~= w then
                    autoCast:SetHeight(autoCast.size)
                    autoCast:SetWidth(autoCast.size)
                end
            end)
        end

        if i <= 3 or i >= 8 then
            button:SetScript("OnDragStart", nil)
            button:SetAttribute("_ondragstart", nil)
            button:SetScript("OnReceiveDrag", nil)
            button:SetAttribute("_onreceivedrag", nil)
        end

        button.showMacroName = GW.settings.SHOWACTIONBAR_MACRO_NAME_ENABLED

        GW.setActionButtonStyle("PetActionButton" .. i, nil, nil, true)
        GW.RegisterCooldown(button.cooldown)
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

function GwPlayerPetFrameMixin:UpdateAutoCast()
    for i, button in ipairs(self.buttons) do
        local _, _, _, _, _, autoCastEnabled = GetPetActionInfo(i)
        button.AutoCastOverlay:SetShown(autoCastEnabled)
    end
end

function GwPlayerPetFrameMixin:Update(event, unit)
    if (event == "UNIT_FLAGS" and unit ~= "pet") or (event == "UNIT_PET" and unit ~= "player") then return end

    for i, button in ipairs(self.buttons) do
        local name, texture, isToken, isActive, _, _, spellID = GetPetActionInfo(i)
        button:SetAlpha(1)
        button.isToken = isToken
        button.icon:Show()

        if i > 3 and i < 8 then
            if not isToken then
                button.icon:SetTexture(texture)
                button.tooltipName = name
            else
                button.icon:SetTexture(_G[texture])
                button.tooltipName = _G[name]
            end
        end

        if spellID then
            local spell = Spell:CreateFromSpellID(spellID)
            button.spellDataLoadedCancelFunc = spell:ContinueWithCancelOnSpellLoad(function()
                button.tooltipSubtext = spell:GetSpellSubtext()
            end)
        end

        button:SetChecked(isActive and name ~= "PET_ACTION_FOLLOW")
        if isActive then
            if IsPetAttackAction(i) then
                button:StartFlash()
            else
                button:StopFlash()
            end
        else
            button:StopFlash()
        end

        if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
            button:StopFlash()
            button.icon:SetDesaturation(1)
            button:SetChecked(false)
        end
    end

    self:UpdateAutoCast()
end

function GwPlayerPetFrameMixin:UpdatePetCooldown()
    local forbidden = GameTooltip:IsForbidden()
    local owner = GameTooltip:GetOwner()

    for i, button in ipairs(self.buttons) do
        local start, duration = GetPetActionCooldown(i)
        button.cooldown:SetCooldown(start, duration)

        if not forbidden and owner == button then
            button:OnEnter(button)
        end
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
        self:Update(event, unit)
        self:UpdateHealthBar()
        self:UpdatePowerBar(true)
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
        self:Update(event, unit)
        if event == "UNIT_PET" then
            self:UpdateHealthBar()
            self:UpdatePowerBar(true)
            self.auras:ForceUpdate()
            self:UpdatePetCooldown()
        end
    elseif event == "PET_BAR_UPDATE_COOLDOWN" then
        self:UpdatePetCooldown()
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        self:UpdateHealthBar()
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        self:UpdatePowerBar()
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

function GwPlayerPetFrameMixin:ToggleCombatFeedback()
    if GW.settings.PET_FLOATING_COMBAT_TEXT then
        self:RegisterEvent("UNIT_COMBAT")
        self:SetScript("OnUpdate", CombatFeedback_OnUpdate)
    else
        self:UnregisterEvent("UNIT_COMBAT")
        self:SetScript("OnUpdate", nil)
    end
end

function GwPlayerPetFrameMixin:UpdateHealthTextString(health)
    local formatFunction
    GW.Debug("OVERRIDEN FUNCTION: UpdateHealthTextString")

    if GW.settings.PET_UNIT_HEALTH_SHORT_VALUES then
        formatFunction = GW.ShortValue
    else
        formatFunction = GW.GetLocalizedNumber
    end

    self.health.text:SetText(formatFunction(health))
end

local function LoadPetFrame(lm)
    local playerPetFrame = CreateFrame("Button", "GwPlayerPetFrame", UIParent, "GwPlayerPetFrameTmpl")

    GW.AddStatusbarAnimation(playerPetFrame.health, true)
    GW.AddStatusbarAnimation(playerPetFrame.powerbar, true)

    playerPetFrame.health.customMaskSize = 64
    playerPetFrame.powerbar.customMaskSize = 64

    playerPetFrame.buttons = {}

    PetActionBar:UnregisterEvent("PET_BAR_UPDATE")
    PetActionBar:UnregisterEvent("UNIT_PET")
    PetActionBar:UnregisterEvent("PET_UI_UPDATE")
    PetActionBar:UnregisterEvent("UPDATE_VEHICLE_ACTIONBAR")
    PetActionBar.ignoreFramePositionManager = true
    PetActionBar:GwKillEditMode()

    hooksecurefunc(PetActionBar, "Update", function() playerPetFrame:UpdateAutoCast() end)

    playerPetFrame:SetAttribute("*type1", "target")
    playerPetFrame:SetAttribute("*type2", "togglemenu")
    playerPetFrame:SetAttribute("unit", "pet")
    playerPetFrame:EnableMouse(true)
    playerPetFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    RegisterStateDriver(playerPetFrame, "visibility", "[overridebar] hide; [vehicleui] hide; [petbattle] hide; [target=pet,exists] show; hide")

    playerPetFrame.health:SetStatusBarColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
    playerPetFrame.health.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL, nil, -1)

    playerPetFrame:SetScript("OnEnter", function(self)
        if self.unit then
            GameTooltip:ClearLines()
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnit(self.unit)
            GameTooltip:Show()
        end
    end)

    playerPetFrame.unit = "pet"

    playerPetFrame.debuffFilter = "PLAYER|HARMFUL"
    playerPetFrame.displayBuffs = 32
    playerPetFrame.displayDebuffs = 40
    playerPetFrame.auras.smallSize = 20
    playerPetFrame.auras.bigSize = 24

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
    playerPetFrame:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
    playerPetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    playerPetFrame:RegisterEvent("PET_BAR_UPDATE_USABLE")
    playerPetFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    playerPetFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")

    RegisterMovableFrame(playerPetFrame, PET, "pet_pos", ALL .. ",Unitframe", nil, {"default", "scaleable"}, true)
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
    hooksecurefunc(PetActionBar, "Update", UpdatePetActionBarIcons)
    UpdatePetActionBarIcons()

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
end
GW.LoadPetFrame = LoadPetFrame
