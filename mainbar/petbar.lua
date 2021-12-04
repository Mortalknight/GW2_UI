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

local function setActionButtonAutocast(id)
    local btn = _G["PetActionButton" .. id]
    local autoCastEnabled = select(6, GetPetActionInfo(id))

    if btn then
        for _, v in pairs(_G["PetActionButton" .. id .. "Shine"].sparkles) do
            v:SetShown(autoCastEnabled)
        end
        _G["PetActionButton" .. id .. "AutoCastable"]:SetShown(autoCastEnabled)
    end
end

local function petBarUpdate()
    PetActionButton1Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-attack")
    PetActionButton2Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-follow")
    PetActionButton3Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-place")

    PetActionButton8Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-assist")
    PetActionButton9Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-defense")
    PetActionButton10Icon:SetTexture("Interface/AddOns/GW2_UI/textures/icons/pet-passive")
    for i = 1, 12 do
        if _G["PetActionButton" .. i] then
            _G["PetActionButton" .. i .. "NormalTexture2"]:SetTexture(nil)
            setActionButtonAutocast(i)
        end
    end
end
GW.AddForProfiling("petbar", "petBarUpdate", petBarUpdate)

local function setPetBar(fmPet)
    local BUTTON_SIZE = 28
    local BUTTON_MARGIN = 3
    local showName = GetSetting("SHOWACTIONBAR_MACRO_NAME_ENABLED")

    PetActionButton1:ClearAllPoints()
    PetActionButton1:SetPoint("BOTTOMLEFT", fmPet, "BOTTOMLEFT", 3, 30)

    fmPet.gwButton = {}

    for i = 1, 12 do
        local btn = _G["PetActionButton" .. i]
        local btnPrev = _G["PetActionButton" .. (i - 1)]
        local btnShine = _G["PetActionButton" .. i .. "Shine"]

        if btn then
            fmPet.gwButton[i] = btn
            btn:SetParent(fmPet)
            GW.updateHotkey(btn)
            btn.noGrid = nil
            btn:SetSize(i < 4 and 32 or BUTTON_SIZE, i < 4 and 32 or BUTTON_SIZE)

            if i > 1 and i ~= 8 then
                btn:ClearAllPoints()
                btn:SetPoint("BOTTOMLEFT", btnPrev, "BOTTOMRIGHT", BUTTON_MARGIN, 0)
            elseif i == 8 then
                btn:ClearAllPoints()
                btn:SetPoint("BOTTOM", PetActionButton5, "TOP", 0, BUTTON_MARGIN)
            end

            if btnShine then
                btnShine:SetSize(btn:GetSize())
                for _, v in pairs(_G["PetActionButton" .. i .. "Shine"].sparkles) do
                    v:SetTexture("Interface/AddOns/GW2_UI/Textures/talents/autocast")
                    v:SetSize((i < 4 and 32 or BUTTON_SIZE) + 5, (i < 4 and 32 or BUTTON_SIZE) + 5)
                end

                _G["PetActionButton" .. i .. "AutoCastable"]:SetTexture("Interface/AddOns/GW2_UI/Textures/talents/autocast")
                _G["PetActionButton" .. i .. "AutoCastable"]:SetSize((i < 4 and 32 or BUTTON_SIZE) + 5, (i < 4 and 32 or BUTTON_SIZE) + 5)
            end

            if i == 1 then
                hooksecurefunc("PetActionBar_Update", petBarUpdate)
                hooksecurefunc("TogglePetAutocast", setActionButtonAutocast)
            end

            if i <= 3 or i >= 8 then
                btn:SetScript("OnDragStart", nil)
                btn:SetAttribute("_ondragstart", nil)
                btn:SetScript("OnReceiveDrag", nil)
                btn:SetAttribute("_onreceivedrag", nil)
            end

            btn.showMacroName = showName

            GW.setActionButtonStyle("PetActionButton" .. i, nil, nil, nil, true)
            GW.RegisterCooldown(_G["PetActionButton" .. i .. "Cooldown"])
        end
    end
end
GW.AddForProfiling("petbar", "setPetBar", setPetBar)

local function updatePetFrameLocation()
    local fPet = GwPlayerPetFrame
    if not fPet or InCombatLockdown() then
        return
    end
    local fBar = MultiBarBottomLeft
    local xOff = GetSetting("PLAYER_AS_TARGET_FRAME") and 54 or 0
    fPet:ClearAllPoints()
    fPet.gwMover:ClearAllPoints()
    if fBar and fBar.gw_FadeShowing then
        fPet.gwMover:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -53 + xOff, 212)
        fPet:SetPoint("TOPLEFT", fPet.gwMover)
    else
        fPet.gwMover:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -53 + xOff, 120)
        fPet:SetPoint("TOPLEFT", fPet.gwMover)
    end
end
GW.AddForProfiling("petbar", "updatePetFrameLocation", updatePetFrameLocation)

local function updatePetData(self, event, unit)
    if not UnitExists("pet") then
        return
    end

    if event == "UNIT_AURA" then
        UpdateBuffLayout(self, event, unit)
        return
    elseif event == "UNIT_PET" or event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" then
        SetPortraitTexture(self.portrait, "pet")
        if event ~= "UNIT_PET" then
            return
        end
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

local function LoadPetFrame(lm)
    -- disable default PetFrame stuff
    PetFrame:Kill()

    local playerPetFrame = CreateFrame("Button", "GwPlayerPetFrame", UIParent, "GwPlayerPetFrameTmpl")

    playerPetFrame:SetAttribute("playerFrameAsTarget", GetSetting("PLAYER_AS_TARGET_FRAME"))
    playerPetFrame:SetAttribute("*type1", "target")
    playerPetFrame:SetAttribute("*type2", "togglemenu")
    playerPetFrame:SetAttribute("unit", "pet")
    playerPetFrame:EnableMouse(true)
    playerPetFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    RegisterStateDriver(playerPetFrame, "visibility", "[overridebar] hide; [vehicleui] hide; [petbattle] hide; [target=pet,exists] show; hide")

    playerPetFrame.health:SetStatusBarColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
    playerPetFrame.health.text:SetFont(UNIT_NAME_FONT, 11)

    playerPetFrame.auraPositionUnder = GetSetting("PET_AURAS_UNDER")

    if playerPetFrame.auraPositionUnder then
        playerPetFrame.auras:ClearAllPoints()
        playerPetFrame.auras:SetPoint("TOPLEFT", playerPetFrame.resource, "BOTTOMLEFT", 0, -5)
    end

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

    updatePetData(playerPetFrame, "UNIT_PET", "pet")

    RegisterMovableFrame(playerPetFrame, PET, "pet_pos", "GwPetFrameDummy", nil, true, {"default", "scaleable"}, true)

    if not playerPetFrame.isMoved then
        AddActionBarCallback(updatePetFrameLocation)
        updatePetFrameLocation()
    else
        playerPetFrame:ClearAllPoints()
        playerPetFrame:SetPoint("TOPLEFT", playerPetFrame.gwMover)
    end

    lm:RegisterPetFrame(playerPetFrame)

    setPetBar(playerPetFrame)

    -- hook hotkey update calls so we can override styling changes
    local hotkeyEventTrackerFrame = CreateFrame("Frame")
    hotkeyEventTrackerFrame:RegisterEvent("UPDATE_BINDINGS")
    hotkeyEventTrackerFrame:SetScript("OnEvent", function()
        for i = 1, 12 do
            if playerPetFrame.gwButton[i] then
                GW.updateHotkey(playerPetFrame.gwButton[i])
            end
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
