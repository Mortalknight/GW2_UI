local _, GW = ...
local GetSetting = GW.GetSetting
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local LoadAuras = GW.LoadAuras
local PowerBarColorCustom = GW.PowerBarColorCustom
local CommaValue = GW.CommaValue
local UpdateBuffLayout = GW.UpdateBuffLayout
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local RegisterMovableFrame = GW.RegisterMovableFrame
local AddActionBarCallback = GW.AddActionBarCallback

local function UpdatePetActionBarIcons()
    PetActionButton1Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-attack")
    PetActionButton2Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-follow")
    PetActionButton3Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-place")

    PetActionButton8Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-assist")
    PetActionButton9Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-defense")
    PetActionButton10Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-passive")
end
GW.AddForProfiling("petbar", "UpdatePetActionBarIcons", UpdatePetActionBarIcons)

local function SetPetActionButtonPositionAndStyle(self)
    local BUTTON_SIZE = 28
    local BUTTON_MARGIN = 3
    local showName = GetSetting("SHOWACTIONBAR_MACRO_NAME_ENABLED")

    for i, button in ipairs(self.buttons) do
        local lastButton = _G["PetActionButton" .. (i - 1)]
        local lastColumnButton = _G["PetActionButton5"]
        local buttonShine = _G["PetActionButton" .. i .. "Shine"]
        local autoCast = button.AutoCastable
        local point, relativeFrame, relativePoint, x, y

        button:SetScale(1)
        button:SetAlpha(1)

        if i == 1 then
            point, relativeFrame, relativePoint, x, y = "BOTTOMLEFT", self, "BOTTOMLEFT", 3, 30
        elseif i == 8 then
            point, relativeFrame, relativePoint, x, y = "BOTTOM", lastColumnButton, "TOP", 0, BUTTON_MARGIN
        else
            point, relativeFrame, relativePoint, x, y = "BOTTOMLEFT", lastButton, "BOTTOMRIGHT", BUTTON_MARGIN, 0
        end

        button:SetParent(self)
        button:ClearAllPoints()
        button:SetAttribute("showgrid", 0)
        button:EnableMouse(true)
        button:SetSize(i < 4 and 32 or BUTTON_SIZE, i < 4 and 32 or BUTTON_SIZE)
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
                    btn:GetParent():RegisterEvent("PLAYER_REGEN_ENABLED")
                end
            end
        end)

        if buttonShine then
            buttonShine:SetSize(button:GetSize())
            for _, v in pairs(_G["PetActionButton" .. i .. "Shine"].sparkles) do
                v:SetTexture("Interface/AddOns/GW2_UI/Textures/talents/autocast")
                v:SetSize((i < 4 and 32 or BUTTON_SIZE) + 5, (i < 4 and 32 or BUTTON_SIZE) + 5)
            end

            autoCast:SetTexture("Interface/AddOns/GW2_UI/Textures/talents/autocast")
            autoCast.size = (i < 4 and 32 or BUTTON_SIZE) + 5
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

        button.showMacroName = showName

        GW.setActionButtonStyle("PetActionButton" .. i, nil, nil, nil, true)
        GW.RegisterCooldown(_G["PetActionButton" .. i .. "Cooldown"])
    end
end
GW.AddForProfiling("petbar", "setPetBar", setPetBar)

local function UpdatePetBarButtonsHot()
    for i = 1, 12 do
        local btn = _G["PetActionButton" .. i]

        if btn then
            btn.showMacroName = GetSetting("SHOWACTIONBAR_MACRO_NAME_ENABLED")
            GW.updateMacroName(btn)
        end
    end
end
GW.UpdatePetBarButtonsHot = UpdatePetBarButtonsHot

local function UpdatePetActionBar(self, event, unit)
    if (event == "UNIT_FLAGS" and unit ~= "pet") or (event == "UNIT_PET" and unit ~= "player") then return end

    for i, button in ipairs(self.buttons) do
        local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i)
        local autoCast = button.AutoCastable
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

        if isActive and name ~= "PET_ACTION_FOLLOW" then
            button:SetChecked(true)

            if IsPetAttackAction(i) then
                if PetActionButton_StartFlash then
                    PetActionButton_StartFlash(button)
                else
                    button:StartFlash()
                end
            end
        else
            button:SetChecked(false)

            if IsPetAttackAction(i) then
                if PetActionButton_StopFlash then
                    PetActionButton_StopFlash(button)
                else
                    button:StopFlash()
                end
            end
        end

        if autoCastEnabled then
            autoCast:Show()
        else
            autoCast:Hide()
        end

        if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
            if PetActionButton_StopFlash then
                PetActionButton_StopFlash(button)
            else
                button:StopFlash()
            end

            button.icon:SetDesaturation(1)
            button:SetChecked(false)
        end
    end
end

local function UpdatePetCooldown(self)
    if PetActionBar_UpdateCooldowns then
        PetActionBar_UpdateCooldowns()
    else
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
end

local function updatePetData(self, event, unit)
    if not UnitExists("pet") then
        return
    end

    if event == "UNIT_AURA" then
        UpdateBuffLayout(self, event, unit)
        return
    elseif event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" then
        SetPortraitTexture(self.portrait, "pet")
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        for i = 1, NUM_PET_ACTION_SLOTS do
            local button = self.buttons[i]
            if button then
                button:ClearAllPoints()
                button:SetPoint(button.point, button.relativeFrame, button.relativePoint, button.gwX, button.gwY)
            end
        end
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        return
    elseif GW.IsIn(event, "PET_UI_UPDATE", "PET_BAR_UPDATE", "PLAYER_CONTROL_GAINED", "PLAYER_CONTROL_LOST", "PLAYER_ENTERING_WORLD", "PLAYER_FARSIGHT_FOCUS_CHANGED", "SPELLS_CHANGED", "UNIT_FLAGS", "UNIT_PET") then
        SetPortraitTexture(self.portrait, "pet")
        UpdatePetActionBar(self, event, unit)

        if event  ~= "UNIT_PET" then return end
    elseif event == "PET_BAR_UPDATE_COOLDOWN" then
        UpdatePetCooldown(self)
    end

    local health = UnitHealth("pet")
    local healthMax = UnitHealthMax("pet")
    local healthprec = 0

    local powerType, powerToken, _ = UnitPowerType("pet")
    local resource = UnitPower("pet", powerType)
    local resourceMax = UnitPowerMax("pet", powerType)
    local resourcePrec = 0

    if health > 0 and healthMax > 0 then
        healthprec = health / healthMax
    end

    if resource ~= nil and resource > 0 and resourceMax > 0 then
        resourcePrec = resource / resourceMax
    end

    if PowerBarColorCustom[powerToken] then
        local pwcolor = PowerBarColorCustom[powerToken]
        self.resource:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
    end

    self.resource:SetValue(resourcePrec)

    if self.health.animationCurrent == nil then
        self.health.animationCurrent = 0
    end
    AddToAnimation(
        "petBarAnimation",
        self.health.animationCurrent,
        healthprec,
        GetTime(),
        0.2,
        function()
            self.health:SetValue(animations["petBarAnimation"].progress)
        end
    )
    self.health.animationCurrent = healthprec
    self.health.text:SetText(CommaValue(health))
end
GW.AddForProfiling("petbar", "updatePetData", updatePetData)

local function TogglePetAuraPosition()
    GwPlayerPetFrame.auraPositionUnder = GetSetting("PET_AURAS_UNDER")

    if GwPlayerPetFrame.auraPositionUnder then
        GwPlayerPetFrame.auras:ClearAllPoints()
        GwPlayerPetFrame.auras:SetPoint("TOPLEFT", GwPlayerPetFrame.resource, "BOTTOMLEFT", 0, -5)
    end
end
GW.TogglePetAuraPosition = TogglePetAuraPosition

local function LoadPetFrame(lm)
    local playerPetFrame = CreateFrame("Button", "GwPlayerPetFrame", UIParent, "GwPlayerPetFrameTmpl")
    playerPetFrame.buttons = {}

    playerPetFrame:SetAttribute("*type1", "target")
    playerPetFrame:SetAttribute("*type2", "togglemenu")
    playerPetFrame:SetAttribute("unit", "pet")
    playerPetFrame:EnableMouse(true)
    playerPetFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    RegisterStateDriver(playerPetFrame, "visibility", "[overridebar] hide; [vehicleui] hide; [petbattle] hide; [target=pet,exists] show; hide")

    playerPetFrame.health:SetStatusBarColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
    playerPetFrame.health.text:SetFont(UNIT_NAME_FONT, 11)

    TogglePetAuraPosition()

    playerPetFrame:SetScript("OnEnter", function(self)
        if self.unit then
            GameTooltip:ClearLines()
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnit(self.unit)
            GameTooltip:Show()
        end
    end)
    playerPetFrame:SetScript("OnLeave", GameTooltip_Hide)
    playerPetFrame:SetScript("OnEvent", updatePetData)
    playerPetFrame:HookScript(
        "OnShow",
        function(self)
            updatePetData(self, "UNIT_PET", "pet")
        end
    )
    playerPetFrame.unit = "pet"

    playerPetFrame.displayBuffs = true
    playerPetFrame.displayDebuffs = true
    playerPetFrame.debuffFilter = "player"

    LoadAuras(playerPetFrame)

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

    RegisterMovableFrame(playerPetFrame, PET, "pet_pos", "GwPetFrameDummy", nil, {"default", "scaleable"}, true)
    lm:RegisterPetFrame(playerPetFrame)

    playerPetFrame:ClearAllPoints()
    playerPetFrame:SetPoint("TOPLEFT", playerPetFrame.gwMover)

    -- Pet Actionbuttons here
    for i = 1, NUM_PET_ACTION_SLOTS do
        local button = _G["PetActionButton" .. i]
        button:Show()
        playerPetFrame.buttons[i] = button
    end
    SetPetActionButtonPositionAndStyle(playerPetFrame)
    hooksecurefunc(PetActionBar, "Update", UpdatePetActionBarIcons)
    UpdatePetActionBarIcons()

    -- hook hotkey update calls so we can override styling changes
    local hotkeyEventTrackerFrame = CreateFrame("Frame")
    hotkeyEventTrackerFrame:RegisterEvent("UPDATE_BINDINGS")
    hotkeyEventTrackerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    hotkeyEventTrackerFrame:SetScript("OnEvent", function()
        for _, button in ipairs(GwPlayerPetFrame.buttons) do
            GW.updateHotkey(button)
            GW.FixHotKeyPosition(button, false, true)
        end
    end)

    -- create floating combat text
    if GetSetting("PET_FLOATING_COMBAT_TEXT") then
        local fctf = CreateFrame("Frame", nil, playerPetFrame)
        fctf:SetFrameLevel(playerPetFrame:GetFrameLevel() + 3)
        fctf:RegisterEvent("UNIT_COMBAT")
        fctf:SetScript("OnEvent", function(self, _, unit, ...)
            if self.unit == unit then
                CombatFeedback_OnCombatEvent(self, ...)
            end
        end)
        fctf:SetScript("OnUpdate", CombatFeedback_OnUpdate)
        fctf.unit = playerPetFrame.unit

        local font = fctf:CreateFontString(nil, "OVERLAY")
        font:SetFont(DAMAGE_TEXT_FONT, 30)
        fctf.fontString = font
        font:SetPoint("CENTER", playerPetFrame.portrait, "CENTER")
        font:Hide()

        CombatFeedback_Initialize(fctf, font, 30)
    end
end
GW.LoadPetFrame = LoadPetFrame
