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

local function petBarUpdate()
    _G["PetActionButton1Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-attack")
    _G["PetActionButton2Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-follow")
    _G["PetActionButton3Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-place")

    _G["PetActionButton8Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-assist")
    _G["PetActionButton9Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-defense")
    _G["PetActionButton10Icon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\icons\\pet-passive")
    for i = 1, 12 do
        if _G["PetActionButton" .. i] ~= nil then
            _G["PetActionButton" .. i .. "NormalTexture2"]:SetTexture(nil)
        end
    end
end
GW.AddForProfiling("petbar", "petBarUpdate", petBarUpdate)

local function setActionButtonStyle(buttonName, noBackDrop, hideUnused)
    local btn = _G[buttonName]

    if btn.icon ~= nil then
        btn.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
    if btn.HotKey ~= nil then
        btn.HotKey:ClearAllPoints()
        btn.HotKey:SetPoint("CENTER", btn, "BOTTOM", 0, 0)
        btn.HotKey:SetJustifyH("CENTER")
    end
    if btn.Count ~= nil then
        btn.Count:ClearAllPoints()
        btn.Count:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -3, -3)
        btn.Count:SetJustifyH("RIGHT")
        btn.Count:SetFont(UNIT_NAME_FONT, 14, "OUTLINED")
        btn.Count:SetTextColor(1, 1, 0.6)
    end

    if btn.Border ~= nil then
        btn.Border:SetSize(btn:GetWidth(), btn:GetWidth())
        btn.Border:SetBlendMode("BLEND")
        btn.Border:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagitemborder")
    end
    if btn.NormalTexture ~= nil then
        btn:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\bag\\bagnormal")
    end

    if _G[buttonName .. "FloatingBG"] ~= nil then
        _G[buttonName .. "FloatingBG"]:SetTexture(nil)
    end
    if _G[buttonName .. "NormalTexture2"] ~= nil then
        _G[buttonName .. "NormalTexture2"]:SetTexture(nil)
        _G[buttonName .. "NormalTexture2"]:Hide()
    end
    if btn.AutoCastable ~= nil then
        btn.AutoCastable:SetSize(btn:GetWidth(), btn:GetWidth())
    end

    btn:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\actionbutton-pressed")
    btn:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress")
    btn:SetCheckedTexture("Interface\\AddOns\\GW2_UI\\textures\\UI-Quickslot-Depress")
    btn.Name:SetAlpha(0) --Hide Marco Name on Actionbutton

    if noBackDrop == nil or noBackDrop == false then
        local backDrop = CreateFrame("Frame", nil, btn, "GwActionButtonBackdropTmpl")
        local backDropSize = 1
        if btn:GetWidth() > 40 then
            backDropSize = 2
        end

        backDrop:SetPoint("TOPLEFT", btn, "TOPLEFT", -backDropSize, backDropSize)
        backDrop:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", backDropSize, -backDropSize)

        btn.gwBackdrop = backDrop
    end

    if hideUnused == true then
        btn.gwBackdrop:Hide()
        btn:HookScript("OnHide", hideBackdrop)
        btn:HookScript("OnShow", showBackdrop)
    end
end
GW.AddForProfiling("petbar", "setActionButtonStyle", setActionButtonStyle)

local function updateHotkey(self, actionButtonType)
    local hotkey = self.HotKey
    local text = hotkey:GetText()

    if text == nil then
        return
    end

    text = string.gsub(text, "(s%-)", "S")
    text = string.gsub(text, "(a%-)", "A")
    text = string.gsub(text, "(c%-)", "C")
    text = string.gsub(text, "(Mouse Button )", "M")
    text = string.gsub(text, "(Middle Mouse)", "M3")
    text = string.gsub(text, "(Num Pad )", "N")
    text = string.gsub(text, "(Page Up)", "PU")
    text = string.gsub(text, "(Page Down)", "PD")
    text = string.gsub(text, "(Spacebar)", "SpB")
    text = string.gsub(text, "(Insert)", "Ins")
    text = string.gsub(text, "(Home)", "Hm")
    text = string.gsub(text, "(Delete)", "Del")
    text = string.gsub(text, "(Left Arrow)", "LT")
    text = string.gsub(text, "(Right Arrow)", "RT")
    text = string.gsub(text, "(Up Arrow)", "UP")
    text = string.gsub(text, "(Down Arrow)", "DN")

    if hotkey:GetText() == RANGE_INDICATOR then
        hotkey:SetText("")
    else
        if GetSetting("BUTTON_ASSIGNMENTS") then
            hotkey:SetText(text)
        else
            hotkey:SetText("")
        end
    end
end
GW.AddForProfiling("petbar", "updateHotkey", updateHotkey)

local function setPetBar(fmPet)
    local BUTTON_SIZE = 28
    local BUTTON_MARGIN = 3

    PetActionButton1:ClearAllPoints()
    PetActionButton1:SetPoint("BOTTOMLEFT", fmPet, "BOTTOMLEFT", 3, 30)

    for i = 1, 12 do
        local btn = _G["PetActionButton" .. i]
        local btnPrev = _G["PetActionButton" .. (i - 1)]
        if btn ~= nil then
            btn:SetParent(fmPet)
            updateHotkey(btn)
            btn.noGrid = nil

            btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
            if i < 4 then
                btn:SetSize(32, 32)
            elseif i == 8 then
                btn:ClearAllPoints()
                btn:SetPoint("BOTTOM", _G["PetActionButton5"], "TOP", 0, BUTTON_MARGIN)
            end

            if i > 1 and i ~= 8 then
                btn:ClearAllPoints()

                if i > 3 then
                    btn:SetPoint("BOTTOMLEFT", btnPrev, "BOTTOMRIGHT", BUTTON_MARGIN, 0)
                else
                    btn:SetPoint("BOTTOMLEFT", btnPrev, "BOTTOMRIGHT", BUTTON_MARGIN, 0)
                end
            end
            local btnShine = _G["PetActionButton" .. i .. "Shine"]
            if btnShine then
                btnShine:SetSize(btn:GetSize())

            --for k,v in pairs(_G['PetActionButton'..i..'Shine'].sparkles) do
            --   v:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\autocast')
            --end
            -- _G['PetActionButton'..i..'ShineAutoCastable']:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\talents\\autocast')
            end

            if i == 1 then
                hooksecurefunc("PetActionBar_Update", petBarUpdate)
            end

            if i <= 3 or i >= 8 then
                btn:SetScript("OnDragStart", nil)
                btn:SetAttribute("_ondragstart", nil)
                btn:SetScript("OnReceiveDrag", nil)
                btn:SetAttribute("_onreceivedrag", nil)
            end

            setActionButtonStyle("PetActionButton" .. i)
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
    fPet:ClearAllPoints()
    if fBar and fBar.gw_FadeShowing then
        fPet:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -53, 212)
    else
        fPet:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -53, 120)
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
    end

    if event == "UNIT_PET" or event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" then
        SetPortraitTexture(_G["GwPlayerPetFramePortrait"], "pet")
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

    if GwPlayerPetFrameHealth.animationCurrent == nil then
        GwPlayerPetFrameHealth.animationCurrent = 0
    end
    AddToAnimation(
        "petBarAnimation",
        GwPlayerPetFrameHealth.animationCurrent,
        healthprec,
        GetTime(),
        0.2,
        function()
            _G["GwPlayerPetFrameHealth"]:SetValue(animations["petBarAnimation"]["progress"])
        end
    )
    GwPlayerPetFrameHealth.animationCurrent = healthprec
    _G["GwPlayerPetFrameHealthString"]:SetText(CommaValue(health))
end
GW.AddForProfiling("petbar", "updatePetData", updatePetData)

local function LoadPetFrame(lm)
    -- disable default PetFrame stuff
    PetFrame:UnregisterAllEvents()
    PetFrame:SetScript("OnUpdate", nil)

    local playerPetFrame = CreateFrame("Button", "GwPlayerPetFrame", UIParent, "GwPlayerPetFrameTmpl")
    GW.RegisterScaleFrame(playerPetFrame)

    playerPetFrame:SetAttribute("*type1", "target")
    playerPetFrame:SetAttribute("*type2", "togglemenu")
    playerPetFrame:SetAttribute("unit", "pet")
    playerPetFrame:EnableMouse(true)
    playerPetFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    RegisterStateDriver(
        playerPetFrame,
        "visibility",
        "[overridebar] hide; [vehicleui] hide; [petbattle] hide; [target=pet,exists] show; hide"
    )
    -- TODO: When in override/vehicleui, we should show the pet auras/buffs as this can be important info

    _G["GwPlayerPetFrameHealth"]:SetStatusBarColor(COLOR_FRIENDLY[2].r, COLOR_FRIENDLY[2].g, COLOR_FRIENDLY[2].b)
    _G["GwPlayerPetFrameHealthString"]:SetFont(UNIT_NAME_FONT, 11)

    playerPetFrame:SetScript("OnEvent", updatePetData)
    playerPetFrame:HookScript(
        "OnShow",
        function(self)
            updatePetData(self, "UNIT_PET", "player")
        end
    )
    playerPetFrame.unit = "pet"

    playerPetFrame.displayBuffs = true
    playerPetFrame.displayDebuffs = true
    playerPetFrame.debuffFilter = "player"

    LoadAuras(playerPetFrame, playerPetFrame.auras)

    playerPetFrame:RegisterUnitEvent("UNIT_PET", "player")
    playerPetFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_MAXPOWER", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_AURA", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "pet")
    playerPetFrame:RegisterUnitEvent("UNIT_MODEL_CHANGED", "pet")

    updatePetData(playerPetFrame, "UNIT_PET", "player")

    RegisterMovableFrame(playerPetFrame, PET, "pet_pos", "GwPetFrameDummy", nil, true, true)

    if not playerPetFrame.isMoved then
        AddActionBarCallback(updatePetFrameLocation)
        updatePetFrameLocation()
    else
        playerPetFrame:ClearAllPoints()
        playerPetFrame:SetPoint(
            GetSetting("pet_pos")["point"],
            UIParent,
            GetSetting("pet_pos")["relativePoint"],
            GetSetting("pet_pos")["xOfs"],
            GetSetting("pet_pos")["yOfs"]
        )
    end

    lm:RegisterPetFrame(playerPetFrame)

    setPetBar(playerPetFrame)
end
GW.LoadPetFrame = LoadPetFrame
