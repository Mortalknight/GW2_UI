local _, GW = ...
local L = GW.L
local CommaValue = GW.CommaValue
local lerp = GW.lerp
local GetSetting = GW.GetSetting
local Diff = GW.Diff
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local FACTION_BAR_COLORS = GW.FACTION_BAR_COLORS

-- forward function defs
local experiencebarAnimation = 0
local gw_reputation_vals = nil

local function xpbar_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()

    local valCurrent = UnitXP("Player")
    local valMax = UnitXPMax("Player")
    local rested = GetXPExhaustion()
    local isRestingString = IsResting() and L[" (Resting)"] or ""

    GameTooltip:AddLine(COMBAT_XP_GAIN .. isRestingString, 1, 1, 1)

    if GW.mylevel < GetMaxPlayerLevel() then
        GameTooltip:AddLine(COMBAT_XP_GAIN .. " " .. CommaValue(valCurrent) .. " / " .. CommaValue(valMax) .. " |cffa6a6a6 (" .. math.floor((valCurrent / valMax) * 100) .. "%)|r", 1, 1, 1)
    end

    if rested ~= nil and rested ~= 0 then
        GameTooltip:AddLine(L["Rested "] .. CommaValue(rested) .. " |cffa6a6a6 (" .. math.floor((rested / valMax) * 100) .. "%) |r", 1, 1, 1)
    end

    UIFrameFadeOut(self.ExpBar, 0.2, self.ExpBar:GetAlpha(), 0)
    UIFrameFadeOut(self.RepuBar, 0.2, self.RepuBar:GetAlpha(), 0)
    UIFrameFadeOut(self.PetBar, 0.2, self.PetBar:GetAlpha(), 0)

    if gw_reputation_vals ~= nil then
        GameTooltip:AddLine(gw_reputation_vals, 1, 1, 1)
    end

    GameTooltip:Show()
end
GW.AddForProfiling("hud", "xpbar_OnEnter", xpbar_OnEnter)

local function flareAnim(self)
    self.barOverlay.flare:Show()

    AddToAnimation(
        "GwXpFlare",
        0,
        1,
        GetTime(),
        1,
        function(prog)
            self.barOverlay.flare.texture:SetAlpha(1)
            self.barOverlay.flare.texture:SetRotation(lerp(0, 3, prog))
            if prog > 0.75 then
                self.barOverlay.flare.texture:SetAlpha(lerp(1, 0, math.sin(((prog - 0.75) / 0.25) * math.pi * 0.5)))
            end
        end,
        nil,
        function()
            self.barOverlay.flare:Hide()
        end
    )
end
GW.AddForProfiling("hud", "flareAnim", flareAnim)

local function xpbar_OnEvent(self, event)
    if event == "UPDATE_FACTION" and not GW.inWorld then
        return
    end

    local level = GW.mylevel
    local Nextlevel = math.min(GetMaxPlayerLevel(), GW.mylevel + 1)
    local lockLevelTextUnderMaxLevel = level < Nextlevel

    local valCurrent = UnitXP("Player")
    local valMax = UnitXPMax("Player")
    local valPrec = level < Nextlevel and valCurrent / valMax or 0
    local valPrecRepu = 0

    local rested = GetXPExhaustion()
    local showBar1 = level < Nextlevel -- Player
    local showBar2 = select(2, HasPetUI()) and UnitLevel("pet") < level -- Pet
    local showBar3 = false -- Repu

    local restingIconString = IsResting() and " |TInterface\\AddOns\\GW2_UI\\textures\\resting-icon:16:16:0:0|t " or ""

    if rested == nil or (rested / valMax) == 0 then
        rested = 0
    else
        rested = math.min((rested / (valMax - valCurrent)), 1)
    end

    local animationSpeed = 15

    self.ExpBar:SetStatusBarColor(0.83, 0.57, 0)
    self.PetBar:SetStatusBarColor(240/255, 240/255, 155/255)

    gw_reputation_vals = nil
    local name, reaction, _, _, _, factionID = GetWatchedFactionInfo()
    if factionID and factionID > 0 then
        local _, _, standingId, bottomValue, topValue, earnedValue = GetFactionInfoByID(factionID)
        local currentRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId)), GW.mysex)
        local nextRank = GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId + 1)), GW.mysex)

        if currentRank == nextRank and earnedValue - bottomValue == 0 then
            valPrecRepu = 1
            gw_reputation_vals = name .. " " .. REPUTATION .. " " .. "21,000 / 21,000 |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"
        else
            valPrecRepu = (earnedValue - bottomValue) / (topValue - bottomValue)
            gw_reputation_vals = name .. " " .. REPUTATION .. " " .. CommaValue((earnedValue - bottomValue)) .. " / " .. CommaValue((topValue - bottomValue)) .. " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r"
        end
        self.RepuBar:SetStatusBarColor(FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b)

        local nextId = standingId and standingId + 1 or standingId
        if not lockLevelTextUnderMaxLevel then
            level = getglobal("FACTION_STANDING_LABEL" .. standingId)
            Nextlevel = getglobal("FACTION_STANDING_LABEL" .. nextId)
        end

        showBar3 = true
    end

    if showBar2 then
        local currXP, nextXP = GetPetExperience()
        local valPrecPet = currXP / nextXP

        if gw_reputation_vals then
            gw_reputation_vals = gw_reputation_vals .. "\n" .. PET .. " " .. CommaValue(currXP) .. " / " .. CommaValue(nextXP) .. " |cffa6a6a6 (" .. math.floor(valPrecPet * 100) .. "%)|r"
        else
            gw_reputation_vals = PET .. " " .. CommaValue(currXP) .. " / " .. CommaValue(nextXP) .. " |cffa6a6a6 (" .. math.floor(valPrecPet * 100) .. "%)|r"
        end
        self.PetBarCandy:SetValue(valPrecPet)

        AddToAnimation(
            "petBarAnimation",
            self.PetBar.petBarAnimation,
            valPrecPet,
            GetTime(),
            animationSpeed,
            function()
                self.PetBar.Spark:SetWidth(math.max(8, math.min(9, self.PetBar:GetWidth() * animations["petBarAnimation"].progress)))

                self.PetBar:SetValue(animations["petBarAnimation"].progress)
                self.PetBar.Spark:SetPoint("LEFT", self.PetBar:GetWidth() * animations["petBarAnimation"].progress - 8, 0)
            end
        )
        self.PetBar.petBarAnimation = valPrecPet
    end

    self.NextLevel:SetTextColor(1, 1, 1)
    self.CurrentLevel:SetTextColor(1, 1, 1)
    self.labelRight:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\level-label")
    self.labelLeft:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\level-label")

    local GainBigExp = false
    local FlareBreakPoint = math.max(0.05, 0.15 * (1 - (GW.mylevel / GetMaxPlayerLevel())))
    if (valPrec - experiencebarAnimation) > FlareBreakPoint then
        GainBigExp = true
        flareAnim(self)
    end

    if experiencebarAnimation > valPrec then
        experiencebarAnimation = 0
    end

    self.barOverlay.flare.soundCooldown = 0
    local expSoundCooldown = 0
    local startTime = GetTime()

    animationSpeed = Diff(experiencebarAnimation, valPrec)
    animationSpeed = math.min(15, math.max(5, 10 * animationSpeed))

    --if showBar1 then
        AddToAnimation(
            "experiencebarAnimation",
            experiencebarAnimation,
            valPrec,
            GetTime(),
            animationSpeed,
            function(step)
                self.ExpBar.Spark:SetWidth(math.max(8, math.min(9,self.ExpBar:GetWidth() * animations["experiencebarAnimation"].progress)))

                if not GainBigExp then
                    self.ExpBar:SetValue(animations["experiencebarAnimation"].progress)
                    self.ExpBar.Spark:SetPoint("LEFT", self.ExpBar:GetWidth() * animations["experiencebarAnimation"].progress - 8, 0)

                    local flarePoint = ((UIParent:GetWidth() - 180) * animations["experiencebarAnimation"].progress) + 90
                    self.barOverlay.flare:SetPoint("CENTER", self, "LEFT", flarePoint, 0)
                end
                self.ExpBar.Rested:SetValue(rested)
                self.ExpBar.Rested:SetPoint("LEFT", self.ExpBar, "LEFT", self.ExpBar:GetWidth() * animations["experiencebarAnimation"].progress, 0)

                if GainBigExp and self.barOverlay.flare.soundCooldown < GetTime() then
                    expSoundCooldown = math.max(0.1, lerp(0.1, 2, math.sin((GetTime() - startTime) / animationSpeed) * math.pi * 0.5))

                    self.ExpBar:SetValue(animations["experiencebarAnimation"].progress)
                    self.ExpBar.Spark:SetPoint("LEFT", self.ExpBar:GetWidth() * animations["experiencebarAnimation"].progress - 8, 0)

                    local flarePoint = ((UIParent:GetWidth() - 180) * animations["experiencebarAnimation"].progress) + 90
                    self.barOverlay.flare:SetPoint("CENTER", self, "LEFT", flarePoint, 0)

                    self.barOverlay.flare.soundCooldown = GetTime() + expSoundCooldown
                    PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\exp_gain_ping.ogg", "SFX")

                    animations["experiencebarAnimation"].from = step
                end
            end
        )
        AddToAnimation(
            "GwExperienceBarCandy",
            experiencebarAnimation,
            valPrec,
            GetTime(),
            0.3,
            function()
                local prog = animations["GwExperienceBarCandy"].progress
                self.ExpBarCandy:SetValue(prog)
            end
        )
    --end

    if showBar3 then
        self.RepuBarCandy:SetValue(valPrecRepu)

        AddToAnimation(
            "repuBarAnimation",
            self.RepuBar.repuBarAnimation,
            valPrecRepu,
            GetTime(),
            animationSpeed,
            function()
                self.RepuBar.Spark:SetWidth(math.max(8, math.min(9, self.RepuBar:GetWidth() * animations["repuBarAnimation"].progress)))

                self.RepuBar:SetValue(animations["repuBarAnimation"].progress)
                self.RepuBar.Spark:SetPoint("LEFT", self.RepuBar:GetWidth() * animations["repuBarAnimation"].progress - 8, 0)
            end
        )
        self.RepuBar.repuBarAnimation = valPrecRepu
    end

    experiencebarAnimation = valPrec

    self.NextLevel:SetText(Nextlevel)
    self.CurrentLevel:SetText(restingIconString .. level)
    if showBar1 and showBar2 and showBar3 then
        self.ExpBar:Show()
        self.ExpBarCandy:Show()
        self.ExpBar:SetHeight(2.66)
        self.ExpBarCandy:SetHeight(2.66)
        self.ExpBar.Spark:SetHeight(2.66)
        self.ExpBar.Spark:Show()
        self.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.ExpBar:SetPoint("TOPLEFT", 90, -4)
        self.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        self.PetBar:Show()
        self.PetBarCandy:Show()
        self.PetBar:SetHeight(2.66)
        self.PetBarCandy:SetHeight(2.66)
        self.PetBar.Spark:SetHeight(2.66)
        self.PetBar.Spark:Show()
        self.PetBarCandy:SetPoint("TOPLEFT", 90, -8)
        self.PetBarCandy:SetPoint("TOPRIGHT", -90, -8)
        self.PetBar:SetPoint("TOPLEFT", 90, -8)
        self.PetBar:SetPoint("TOPRIGHT", -90, -8)

        self.RepuBar:Show()
        self.RepuBarCandy:Show()
        self.RepuBar:SetHeight(2.66)
        self.RepuBarCandy:SetHeight(2.66)
        self.RepuBar.Spark:SetHeight(2.66)
        self.RepuBar.Spark:Show()
        self.RepuBarCandy:SetPoint("TOPLEFT", 90, -12)
        self.RepuBarCandy:SetPoint("TOPRIGHT", -90, -12)
        self.RepuBar:SetPoint("TOPLEFT", 90, -12)
        self.RepuBar:SetPoint("TOPRIGHT", -90, -12)
    elseif showBar1 and not showBar2 and showBar3 then
        self.ExpBar:Show()
        self.ExpBarCandy:Show()
        self.ExpBar:SetHeight(4)
        self.ExpBarCandy:SetHeight(4)
        self.ExpBar.Spark:SetHeight(4)
        self.ExpBar.Spark:Show()
        self.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.ExpBar:SetPoint("TOPLEFT", 90, -4)
        self.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        self.PetBar:Hide()
        self.PetBarCandy:Hide()
        self.PetBar:SetValue(0)
        self.PetBarCandy:SetValue(0)
        self.PetBar.Spark:Hide()

        self.RepuBar:Show()
        self.RepuBarCandy:Show()
        self.RepuBar:SetHeight(4)
        self.RepuBarCandy:SetHeight(4)
        self.RepuBar.Spark:SetHeight(4)
        self.RepuBar.Spark:Show()
        self.RepuBarCandy:SetPoint("TOPLEFT", 90, -8)
        self.RepuBarCandy:SetPoint("TOPRIGHT", -90, -8)
        self.RepuBar:SetPoint("TOPLEFT", 90, -8)
        self.RepuBar:SetPoint("TOPRIGHT", -90, -8)
    elseif not showBar1 and showBar2 and showBar3 then
        self.ExpBar:Hide()
        self.ExpBarCandy:Hide()
        self.ExpBar:SetValue(0)
        self.ExpBarCandy:SetValue(0)
        self.ExpBar.Spark:Hide()

        self.PetBar:Show()
        self.PetBarCandy:Show()
        self.PetBar:SetHeight(4)
        self.PetBarCandy:SetHeight(4)
        self.PetBar.Spark:SetHeight(4)
        self.PetBar.Spark:Show()
        self.PetBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.PetBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.PetBar:SetPoint("TOPLEFT", 90, -4)
        self.PetBar:SetPoint("TOPRIGHT", -90, -4)

        self.RepuBar:Show()
        self.RepuBarCandy:Show()
        self.RepuBar:SetHeight(4)
        self.RepuBarCandy:SetHeight(4)
        self.RepuBar.Spark:SetHeight(4)
        self.RepuBar.Spark:Show()
        self.RepuBarCandy:SetPoint("TOPLEFT", 90, -8)
        self.RepuBarCandy:SetPoint("TOPRIGHT", -90, -8)
        self.RepuBar:SetPoint("TOPLEFT", 90, -8)
        self.RepuBar:SetPoint("TOPRIGHT", -90, -8)
    elseif not showBar1 and not showBar2 and showBar3 then
        self.ExpBar:Hide()
        self.ExpBarCandy:Hide()
        self.ExpBar:SetValue(0)
        self.ExpBarCandy:SetValue(0)
        self.ExpBar.Spark:Hide()

        self.PetBar:Hide()
        self.PetBarCandy:Hide()
        self.PetBar:SetValue(0)
        self.PetBarCandy:SetValue(0)
        self.PetBar.Spark:Hide()

        self.RepuBar:Show()
        self.RepuBarCandy:Show()
        self.RepuBar:SetHeight(8)
        self.RepuBarCandy:SetHeight(8)
        self.RepuBar.Spark:SetHeight(8)
        self.RepuBar.Spark:Show()
        self.RepuBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.RepuBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.RepuBar:SetPoint("TOPLEFT", 90, -4)
        self.RepuBar:SetPoint("TOPRIGHT", -90, -4)
    elseif not showBar1 and not showBar2 and not showBar3 then
        self.ExpBar:Hide()
        self.ExpBarCandy:Hide()
        self.ExpBar:SetValue(0)
        self.ExpBarCandy:SetValue(0)
        self.ExpBar.Spark:Hide()

        self.PetBar:Hide()
        self.PetBarCandy:Hide()
        self.PetBar:SetValue(0)
        self.PetBarCandy:SetValue(0)
        self.PetBar.Spark:Hide()

        self.RepuBar:Hide()
        self.RepuBarCandy:Hide()
        self.RepuBar:SetValue(0)
        self.RepuBarCandy:SetValue(0)
        self.RepuBar.Spark:Hide()
    elseif showBar1 and not showBar2 and not showBar3 then
        self.ExpBar:Show()
        self.ExpBarCandy:Show()
        self.ExpBar:SetHeight(8)
        self.ExpBarCandy:SetHeight(8)
        self.ExpBar.Spark:SetHeight(8)
        self.ExpBar.Spark:Show()
        self.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.ExpBar:SetPoint("TOPLEFT", 90, -4)
        self.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        self.PetBar:Hide()
        self.PetBarCandy:Hide()
        self.PetBar:SetValue(0)
        self.PetBarCandy:SetValue(0)
        self.PetBar.Spark:Hide()

        self.RepuBar:Hide()
        self.RepuBarCandy:Hide()
        self.RepuBar:SetValue(0)
        self.RepuBarCandy:SetValue(0)
        self.RepuBar.Spark:Hide()
    elseif showBar1 and showBar2 and not showBar3 then
        self.ExpBar:Show()
        self.ExpBarCandy:Show()
        self.ExpBar:SetHeight(4)
        self.ExpBarCandy:SetHeight(4)
        self.ExpBar.Spark:SetHeight(4)
        self.ExpBar.Spark:Show()
        self.ExpBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.ExpBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.ExpBar:SetPoint("TOPLEFT", 90, -4)
        self.ExpBar:SetPoint("TOPRIGHT", -90, -4)

        self.PetBar:Show()
        self.PetBarCandy:Show()
        self.PetBar:SetHeight(4)
        self.PetBarCandy:SetHeight(4)
        self.PetBar.Spark:SetHeight(4)
        self.PetBar.Spark:Show()
        self.PetBarCandy:SetPoint("TOPLEFT", 90, -8)
        self.PetBarCandy:SetPoint("TOPRIGHT", -90, -8)
        self.PetBar:SetPoint("TOPLEFT", 90, -8)
        self.PetBar:SetPoint("TOPRIGHT", -90, -8)

        self.RepuBar:Hide()
        self.RepuBarCandy:Hide()
        self.RepuBar:SetValue(0)
        self.RepuBarCandy:SetValue(0)
        self.RepuBar.Spark:Hide()
    elseif not showBar1 and showBar2 and not showBar3 then
        self.ExpBar:Hide()
        self.ExpBarCandy:Hide()
        self.ExpBar:SetValue(0)
        self.ExpBarCandy:SetValue(0)
        self.ExpBar.Spark:Hide()

        self.PetBar:Show()
        self.PetBarCandy:Show()
        self.PetBar:SetHeight(8)
        self.PetBarCandy:SetHeight(8)
        self.PetBar.Spark:SetHeight(8)
        self.PetBar.Spark:Show()
        self.PetBarCandy:SetPoint("TOPLEFT", 90, -4)
        self.PetBarCandy:SetPoint("TOPRIGHT", -90, -4)
        self.PetBar:SetPoint("TOPLEFT", 90, -4)
        self.PetBar:SetPoint("TOPRIGHT", -90, -4)

        self.RepuBar:Hide()
        self.RepuBarCandy:Hide()
        self.RepuBar:SetValue(0)
        self.RepuBarCandy:SetValue(0)
        self.RepuBar.Spark:Hide()
    end

    if experiencebarAnimation > valPrec then
        experiencebarAnimation = 0
    end
end
GW.AddForProfiling("hud", "xpbar_OnEvent", xpbar_OnEvent)

local function updateBarSize(self)
    local m = (UIParent:GetWidth() - 180) / 10
    local i = 1
    for _, v in ipairs(self.barOverlay.barSep) do
        local rm = (m * i) + 90
        v:ClearAllPoints()
        v:SetPoint("LEFT", self, "LEFT", rm, 0)
        i = i + 1
    end

    m = (UIParent:GetWidth() - 180)
    self.barOverlay.dubbleBarSep:SetWidth(m)
    self.barOverlay.dubbleBarSep:ClearAllPoints()
    self.barOverlay.dubbleBarSep:SetPoint("LEFT", self, "LEFT", 90, 0)
end
GW.AddForProfiling("hud", "updateBarSize", updateBarSize)

local action_hud_auras = {}

local function registerActionHudAura(auraID, left, right, unit)
    action_hud_auras[auraID] = {}
    action_hud_auras[auraID].auraID = auraID
    action_hud_auras[auraID].left = left
    action_hud_auras[auraID].right = right
    action_hud_auras[auraID].unit = unit
end
local currentTexture = nil
GW.AddForProfiling("hud", "registerActionHudAura", registerActionHudAura)

local function selectBg(self)
    if not GetSetting("HUD_BACKGROUND") or not GetSetting("HUD_SPELL_SWAP") then
        return
    end
    local right = "Interface\\AddOns\\GW2_UI\\textures\\rightshadow"
    local left = "Interface\\AddOns\\GW2_UI\\textures\\leftshadow"

    if UnitIsDeadOrGhost("player") then
        right = "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_dead"
        left = "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_dead"
    end

    if UnitAffectingCombat("player") then
        right = "Interface\\AddOns\\GW2_UI\\textures\\rightshadowcombat"
        left = "Interface\\AddOns\\GW2_UI\\textures\\leftshadowcombat"

        local bolFound = false
        for i = 1, 40 do
            local _, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
            if spellID ~= nil and action_hud_auras[spellID] ~= nil and action_hud_auras[spellID].unit == "player" then
                right = action_hud_auras[spellID].right
                left = action_hud_auras[spellID].left
                break
            end
        end
        if not bolFound then
            for i = 1, 40 do
                local _, _, _, _, _, _, _, _, _, spellID = UnitBuff("pet", i)
                if spellID ~= nil and action_hud_auras[spellID] ~= nil and action_hud_auras[spellID].unit == "pet" then
                    right = action_hud_auras[spellID].right
                    left = action_hud_auras[spellID].left
                    break
                end
            end
        end
    end

    if currentTexture ~= left then
        currentTexture = left
        self.actionBarHud.Right:SetTexture(right)
        self.actionBarHud.Left:SetTexture(left)
    end
end
GW.AddForProfiling("hud", "selectBg", selectBg)

local function combatHealthState(self)
    if not GetSetting("HUD_BACKGROUND") then
        return
    end

    local unitHealthPrecentage = UnitHealth("player") / UnitHealthMax("player")

    if unitHealthPrecentage < 0.5 and not UnitIsDeadOrGhost("player") then
        unitHealthPrecentage = unitHealthPrecentage / 0.5

        self.actionBarHud.Left:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        self.actionBarHud.Right:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        self.actionBarHud.RightSwim:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        self.actionBarHud.LeftSwim:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        self.actionBarHud.LeftBlood:SetVertexColor(1, 1, 1, 1 - (unitHealthPrecentage - 0.2))
        self.actionBarHud.RightBlood:SetVertexColor(1, 1, 1, 1 - (unitHealthPrecentage - 0.2))
    else
        self.actionBarHud.Left:SetVertexColor(1, 1, 1)
        self.actionBarHud.Right:SetVertexColor(1, 1, 1)

        self.actionBarHud.LeftSwim:SetVertexColor(1, 1, 1)
        self.actionBarHud.RightSwim:SetVertexColor(1, 1, 1)

        self.actionBarHud.LeftBlood:SetVertexColor(1, 1, 1, 0)
        self.actionBarHud.RightBlood:SetVertexColor(1, 1, 1, 0)
    end
end
GW.AddForProfiling("hud", "combatHealthState", combatHealthState)

registerActionHudAura(
    31842,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_holy",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_holy",
    "player"
)
registerActionHudAura(
    31884,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_holy",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_holy",
    "player"
)
registerActionHudAura(
    5487,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_bear",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_bear",
    "player"
)
registerActionHudAura(
    768,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_cat",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_cat",
    "player"
)
registerActionHudAura(
    51271,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_frost",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_frost",
    "player"
)
registerActionHudAura(
    187827,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_metamorph",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_metamorph",
    "player"
)
registerActionHudAura(
    215785,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_shaman_fire",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_shaman_fire",
    "player"
)
registerActionHudAura(
    77762,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_shaman_fire",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_shaman_fire",
    "player"
)
registerActionHudAura(
    201846,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_shaman_storm",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_shaman_storm",
    "player"
)

local function hud_OnEvent(self, event, ...)
    if event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            selectBg(self)
        end
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        selectBg(self)
    elseif event == "UNIT_HEALTH_FREQUENT" or event == "UNIT_MAXHEALTH" then
        local unit = ...
        if unit == "player" then
            combatHealthState(self)
        end
    elseif event == "MIRROR_TIMER_START" then
        local arg1, arg2, arg3, arg4, arg5, arg6 = ...
        GW.MirrorTimer_Show(arg1, arg2, arg3, arg4, arg5, arg6)
    end
end
GW.AddForProfiling("hud", "hud_OnEvent", hud_OnEvent)

local function LoadHudArt()
    local hudArtFrame = CreateFrame("Frame", "GwHudArtFrame", UIParent, "GwHudArtFrame") 

    if not GetSetting("BORDER_ENABLED") and hudArtFrame.edgeTint then
        for _, f in ipairs(hudArtFrame.edgeTint) do
            f:Hide()
        end
    end

    if not GetSetting("HUD_BACKGROUND") and hudArtFrame.actionBarHud.HUDBG then
        for _, f in ipairs(hudArtFrame.actionBarHud.HUDBG) do
            f:Hide()
        end
    else
        GW.RegisterScaleFrame(hudArtFrame.actionBarHud)
    end

    hudArtFrame:SetScript("OnEvent", hud_OnEvent)

    hudArtFrame:RegisterEvent("UNIT_AURA")
    hudArtFrame:RegisterEvent("PLAYER_ALIVE")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hudArtFrame:RegisterEvent("MIRROR_TIMER_START")
    hudArtFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "player")
    hudArtFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    selectBg(hudArtFrame)
    combatHealthState(hudArtFrame)

    return hudArtFrame
end
GW.LoadHudArt = LoadHudArt

local function LoadXPBar()
    local experiencebar = CreateFrame("Frame", "GwExperienceFrame", UIParent, "GwExperienceBar")

    experiencebarAnimation = UnitXP("Player") / UnitXPMax("Player")

    experiencebar.RepuBar.repuBarAnimation = 0
    experiencebar.PetBar.petBarAnimation = 0
    experiencebar.NextLevel:SetFont(UNIT_NAME_FONT, 12)
    experiencebar.CurrentLevel:SetFont(UNIT_NAME_FONT, 12)

    updateBarSize(experiencebar)
    xpbar_OnEvent(experiencebar)

    experiencebar:SetScript("OnEvent", xpbar_OnEvent)

    experiencebar:RegisterEvent("PLAYER_XP_UPDATE")
    experiencebar:RegisterEvent("UPDATE_FACTION")
    experiencebar:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    experiencebar:RegisterEvent("PLAYER_UPDATE_RESTING")
    experiencebar:RegisterEvent("PLAYER_ENTERING_WORLD")
    experiencebar:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    experiencebar:RegisterEvent("UPDATE_EXHAUSTION")
    experiencebar:RegisterEvent("UNIT_PET_EXPERIENCE")
    experiencebar:RegisterEvent("PET_UI_UPDATE")
    experiencebar:RegisterEvent("PET_BAR_UPDATE")

    experiencebar:SetScript("OnEnter", xpbar_OnEnter)
    experiencebar:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        UIFrameFadeIn(self.ExpBar, 0.2, self.ExpBar:GetAlpha(), 1)
        UIFrameFadeIn(self.RepuBar, 0.2, self.RepuBar:GetAlpha(), 1)
        UIFrameFadeIn(self.PetBar, 0.2, self.PetBar:GetAlpha(), 1)
    end)
end
GW.LoadXPBar = LoadXPBar