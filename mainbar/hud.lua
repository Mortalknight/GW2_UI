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

local function xpbar_OnEnter()
    GameTooltip:SetOwner(_G["GwExperienceFrame"], "ANCHOR_CURSOR")
    GameTooltip:ClearLines()

    local valCurrent = UnitXP("Player")
    local valMax = UnitXPMax("Player")
    local rested = GetXPExhaustion()
    local isRestingString = ""
    if IsResting() then
        isRestingString = L["EXP_BAR_TOOLTIP_EXP_RESTING"]
    end

    GameTooltip:AddLine(COMBAT_XP_GAIN .. isRestingString, 1, 1, 1)

    if UnitLevel("Player") < GetMaxPlayerLevel() then
        GameTooltip:AddLine(
            COMBAT_XP_GAIN ..
                " " ..
                    CommaValue(valCurrent) ..
                        " / " ..
                            CommaValue(valMax) .. " |cffa6a6a6 (" .. math.floor((valCurrent / valMax) * 100) .. "%)|r",
            1,
            1,
            1
        )
    end

    if rested ~= nil and rested ~= 0 then
        GameTooltip:AddLine(
            L["EXP_BAR_TOOLTIP_EXP_RESTED"] ..
                CommaValue(rested) .. " |cffa6a6a6 (" .. math.floor((rested / valMax) * 100) .. "%) |r",
            1,
            1,
            1
        )
    end

    UIFrameFadeOut(GwExperienceFrameBar, 0.2, GwExperienceFrameBar:GetAlpha(), 0)
    UIFrameFadeOut(GwExperienceFrameRepuBar, 0.2, GwExperienceFrameRepuBar:GetAlpha(), 0)

    if gw_reputation_vals ~= nil then
        GameTooltip:AddLine(gw_reputation_vals, 1, 1, 1)
    end

    GameTooltip:Show()
end
GW.AddForProfiling("hud", "xpbar_OnEnter", xpbar_OnEnter)

local function flareAnim()
    GwXpFlare:Show()

    AddToAnimation(
        "GwXpFlare",
        0,
        1,
        GetTime(),
        1,
        function(prog)
            GwXpFlare.texture:SetAlpha(1)
            GwXpFlare.texture:SetRotation(lerp(0, 3, prog))
            if prog > 0.75 then
                GwXpFlare.texture:SetAlpha(lerp(1, 0, math.sin(((prog - 0.75) / 0.25) * math.pi * 0.5)))
            end
        end,
        nil,
        function()
            GwXpFlare:Hide()
        end
    )
end
GW.AddForProfiling("hud", "flareAnim", flareAnim)

local function xpbar_OnEvent(self, event)
    if event == "UPDATE_FACTION" and not GW.inWorld then
        return
    end

    local valCurrent = UnitXP("Player")
    local valMax = UnitXPMax("Player")
    local valPrec = valCurrent / valMax
    local valPrecRepu = 0

    local level = UnitLevel("Player")
    local Nextlevel = math.min(GetMaxPlayerLevel(), UnitLevel("Player") + 1)
    local lockLevelTextUnderMaxLevel = false

    local rested = GetXPExhaustion()
    local showBar1 = false
    local showBar2 = false
    local restingIconString = " |TInterface\\AddOns\\GW2_UI\\textures\\resting-icon:16:16:0:0|t "

    if not IsResting() then
        restingIconString = ""
    end
    if rested == nil or (rested / valMax) == 0 then
        rested = 0
    else
        rested = rested / (valMax - valCurrent)
    end
    if rested > 1 then
        rested = 1
    end

    if level < Nextlevel then
        showBar1 = true
        lockLevelTextUnderMaxLevel = true
    end

    local animationSpeed = 15

    _G["GwExperienceFrameBar"]:SetStatusBarColor(0.83, 0.57, 0)

    gw_reputation_vals = nil
    local standingId, bottomValue, topValue, earnedValue, isWatched
    for factionIndex = 1, GetNumFactions() do
        _, _, standingId, bottomValue, topValue, earnedValue, _, _, _, _, _, isWatched, _ = GetFactionInfo(factionIndex)
        if isWatched == true then
            local name, reaction = GetWatchedFactionInfo()
            local currentRank =
                GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId)), UnitSex("player"))
            local nextRank =
                GetText("FACTION_STANDING_LABEL" .. math.min(8, math.max(1, standingId + 1)), UnitSex("player"))

            if currentRank == nextRank and earnedValue - bottomValue == 0 then
                valPrecRepu = 1
                gw_reputation_vals =
                    name ..
                        " " ..
                            REPUTATION ..
                                " " .. "21,000 / 21,000 |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r",
                    1,
                    1,
                    1
            else
                valPrecRepu = (earnedValue - bottomValue) / (topValue - bottomValue)
                gw_reputation_vals =
                    name ..
                        " " ..
                            REPUTATION ..
                                " " ..
                                    CommaValue((earnedValue - bottomValue)) ..
                                        " / " ..
                                            CommaValue((topValue - bottomValue)) ..
                                                " |cffa6a6a6 (" .. math.floor(valPrecRepu * 100) .. "%)|r",
                    1,
                    1,
                    1
            end
            _G["GwExperienceFrameRepuBar"]:SetStatusBarColor(
                FACTION_BAR_COLORS[reaction].r,
                FACTION_BAR_COLORS[reaction].g,
                FACTION_BAR_COLORS[reaction].b
            )

            local nextId = standingId + 1
            if nextId == nil then
                nextId = standingId
            end
            if not lockLevelTextUnderMaxLevel then
                level = getglobal("FACTION_STANDING_LABEL" .. standingId)
                Nextlevel = getglobal("FACTION_STANDING_LABEL" .. nextId)
            end

            showBar2 = true
        end
    end

    _G["GwExperienceFrameNextLevel"]:SetTextColor(1, 1, 1)
    _G["GwExperienceFrameCurrentLevel"]:SetText(1, 1, 1)
    GwExperienceFrame.labelRight:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\level-label")
    GwExperienceFrame.labelLeft:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\level-label")

    local GainBigExp = false
    local FlareBreakPoint = math.max(0.05, 0.15 * (1 - (UnitLevel("Player") / GetMaxPlayerLevel())))
    if (valPrec - experiencebarAnimation) > FlareBreakPoint then
        GainBigExp = true
        flareAnim()
    end

    if experiencebarAnimation > valPrec then
        experiencebarAnimation = 0
    end

    GwXpFlare.soundCooldown = 0
    local expSoundCooldown = 0
    local startTime = GetTime()

    animationSpeed = Diff(experiencebarAnimation, valPrec)
    animationSpeed = math.min(15, math.max(5, 10 * animationSpeed))

    AddToAnimation(
        "experiencebarAnimation",
        experiencebarAnimation,
        valPrec,
        GetTime(),
        animationSpeed,
        function(step)
            ExperienceBarSpark:SetWidth(
                math.max(
                    8,
                    math.min(
                        9,
                        _G["GwExperienceFrameBar"]:GetWidth() * animations["experiencebarAnimation"]["progress"]
                    )
                )
            )

            if not GainBigExp then
                _G["GwExperienceFrameBar"]:SetValue(animations["experiencebarAnimation"]["progress"])
                ExperienceBarSpark:SetPoint(
                    "LEFT",
                    _G["GwExperienceFrameBar"]:GetWidth() * animations["experiencebarAnimation"]["progress"] - 8,
                    0
                )

                local flarePoint = ((UIParent:GetWidth() - 180) * animations["experiencebarAnimation"]["progress"]) + 90
                GwXpFlare:SetPoint("CENTER", GwExperienceFrame, "LEFT", flarePoint, 0)
            end
            _G["GwExperienceFrameBarRested"]:SetValue(rested)
            _G["GwExperienceFrameBarRested"]:SetPoint(
                "LEFT",
                _G["GwExperienceFrameBar"],
                "LEFT",
                _G["GwExperienceFrameBar"]:GetWidth() * animations["experiencebarAnimation"]["progress"],
                0
            )

            if GainBigExp and GwXpFlare.soundCooldown < GetTime() then
                expSoundCooldown =
                    math.max(0.1, lerp(0.1, 2, math.sin((GetTime() - startTime) / animationSpeed) * math.pi * 0.5))

                _G["GwExperienceFrameBar"]:SetValue(animations["experiencebarAnimation"]["progress"])
                ExperienceBarSpark:SetPoint(
                    "LEFT",
                    _G["GwExperienceFrameBar"]:GetWidth() * animations["experiencebarAnimation"]["progress"] - 8,
                    0
                )

                local flarePoint = ((UIParent:GetWidth() - 180) * animations["experiencebarAnimation"]["progress"]) + 90
                GwXpFlare:SetPoint("CENTER", GwExperienceFrame, "LEFT", flarePoint, 0)

                GwXpFlare.soundCooldown = GetTime() + expSoundCooldown
                PlaySoundFile("Interface\\AddOns\\GW2_UI\\sounds\\exp_gain_ping.ogg", "SFX")

                animations["experiencebarAnimation"]["from"] = step
            end
        end
    )
    AddToAnimation(
        "GwExperienceFrameBarCandy",
        experiencebarAnimation,
        valPrec,
        GetTime(),
        0.3,
        function()
            local prog = animations["GwExperienceFrameBarCandy"]["progress"]
            _G["GwExperienceFrameBarCandy"]:SetValue(prog)
        end
    )

    if showBar2 then
        _G["GwExperienceFrameRepuBarCandy"]:SetValue(valPrecRepu)

        AddToAnimation(
            "repuBarAnimation",
            _G["GwExperienceFrameRepuBar"].repuBarAnimation,
            valPrecRepu,
            GetTime(),
            animationSpeed,
            function()
                ExperienceRepuBarSpark:SetWidth(
                    math.max(
                        8,
                        math.min(
                            9,
                            _G["GwExperienceFrameRepuBar"]:GetWidth() * animations["repuBarAnimation"]["progress"]
                        )
                    )
                )

                _G["GwExperienceFrameRepuBar"]:SetValue(animations["repuBarAnimation"]["progress"])
                ExperienceRepuBarSpark:SetPoint(
                    "LEFT",
                    _G["GwExperienceFrameRepuBar"]:GetWidth() * animations["repuBarAnimation"]["progress"] - 8,
                    0
                )
            end
        )
        _G["GwExperienceFrameRepuBar"].repuBarAnimation = valPrecRepu
    end

    experiencebarAnimation = valPrec

    _G["GwExperienceFrameNextLevel"]:SetText(Nextlevel)
    _G["GwExperienceFrameCurrentLevel"]:SetText(restingIconString .. level)
    if showBar1 and showBar2 then
        _G["GwExperienceFrameBar"]:Show()
        _G["GwExperienceFrameBarCandy"]:Show()
        _G["GwExperienceFrameBar"]:SetHeight(4)
        _G["GwExperienceFrameBarCandy"]:SetHeight(4)
        _G["ExperienceBarSpark"]:SetHeight(4)
        ExperienceBarSpark:Show()
        _G["GwExperienceFrameBarCandy"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameBarCandy"]:SetPoint("TOPRIGHT", -90, -4)
        _G["GwExperienceFrameBar"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameBar"]:SetPoint("TOPRIGHT", -90, -4)

        _G["GwExperienceFrameRepuBar"]:Show()
        _G["GwExperienceFrameRepuBarCandy"]:Show()
        _G["GwExperienceFrameRepuBar"]:SetHeight(4)
        _G["GwExperienceFrameRepuBarCandy"]:SetHeight(4)
        _G["ExperienceRepuBarSpark"]:SetHeight(4)
        ExperienceRepuBarSpark:Show()
        _G["GwExperienceFrameRepuBarCandy"]:SetPoint("TOPLEFT", 90, -8)
        _G["GwExperienceFrameRepuBarCandy"]:SetPoint("TOPRIGHT", -90, -8)
        _G["GwExperienceFrameRepuBar"]:SetPoint("TOPLEFT", 90, -8)
        _G["GwExperienceFrameRepuBar"]:SetPoint("TOPRIGHT", -90, -8)
    elseif showBar1 and not showBar2 then
        _G["GwExperienceFrameBar"]:Show()
        _G["GwExperienceFrameBarCandy"]:Show()
        _G["GwExperienceFrameBar"]:SetHeight(8)
        _G["GwExperienceFrameBarCandy"]:SetHeight(8)
        _G["ExperienceBarSpark"]:SetHeight(8)
        ExperienceBarSpark:Show()

        _G["GwExperienceFrameRepuBar"]:Hide()
        _G["GwExperienceFrameRepuBarCandy"]:Hide()
        _G["GwExperienceFrameRepuBar"]:SetValue(0)
        _G["GwExperienceFrameRepuBarCandy"]:SetValue(0)
        ExperienceRepuBarSpark:Hide()
    elseif not showBar1 and showBar2 then
        _G["GwExperienceFrameBar"]:Hide()
        _G["GwExperienceFrameBarCandy"]:Hide()
        _G["GwExperienceFrameBar"]:SetValue(0)
        _G["GwExperienceFrameBarCandy"]:SetValue(0)
        ExperienceBarSpark:Hide()

        _G["GwExperienceFrameRepuBar"]:Show()
        _G["GwExperienceFrameRepuBarCandy"]:Show()
        _G["GwExperienceFrameRepuBar"]:SetHeight(8)
        _G["GwExperienceFrameRepuBarCandy"]:SetHeight(8)
        _G["ExperienceRepuBarSpark"]:SetHeight(8)
        ExperienceRepuBarSpark:Show()
        _G["GwExperienceFrameRepuBarCandy"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameRepuBarCandy"]:SetPoint("TOPRIGHT", -90, -4)
        _G["GwExperienceFrameRepuBar"]:SetPoint("TOPLEFT", 90, -4)
        _G["GwExperienceFrameRepuBar"]:SetPoint("TOPRIGHT", -90, -4)
    elseif not showBar1 and not showBar2 then
        _G["GwExperienceFrameBar"]:Hide()
        _G["GwExperienceFrameBarCandy"]:Hide()
        _G["GwExperienceFrameBar"]:SetValue(0)
        _G["GwExperienceFrameBarCandy"]:SetValue(0)
        ExperienceBarSpark:Hide()

        _G["GwExperienceFrameRepuBar"]:Hide()
        _G["GwExperienceFrameRepuBarCandy"]:Hide()
        _G["GwExperienceFrameRepuBar"]:SetValue(0)
        _G["GwExperienceFrameRepuBarCandy"]:SetValue(0)
        ExperienceRepuBarSpark:Hide()
    end

    if experiencebarAnimation > valPrec then
        experiencebarAnimation = 0
    end
end
GW.AddForProfiling("hud", "xpbar_OnEvent", xpbar_OnEvent)

local function updateBarSize()
    local m = (UIParent:GetWidth() - 180) / 10
    for i = 1, 9 do
        local rm = (m * i) + 90
        _G["barsep" .. i]:ClearAllPoints()
        _G["barsep" .. i]:SetPoint("LEFT", "GwExperienceFrame", "LEFT", rm, 0)
    end

    m = (UIParent:GetWidth() - 180)
    dubbleBarSep:SetWidth(m)
    dubbleBarSep:ClearAllPoints()
    dubbleBarSep:SetPoint("LEFT", "GwExperienceFrame", "LEFT", 90, 0)
end
GW.AddForProfiling("hud", "updateBarSize", updateBarSize)

local action_hud_auras = {}

local function registerActionHudAura(aura, left, right)
    action_hud_auras[aura] = {}
    action_hud_auras[aura]["aura"] = aura
    action_hud_auras[aura]["left"] = left
    action_hud_auras[aura]["right"] = right
end
local currentTexture = nil
GW.AddForProfiling("hud", "registerActionHudAura", registerActionHudAura)

--[[
local function getSpecSpecificHud(left, right)
    --hard coded for now
    local playerClassName, playerClassEng, playerClass = UnitClass("player")
    if playerClass == 6 and GetSpecialization() == 3 then
        right = "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_unholy"
        left = "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_unholy"
    elseif playerClass == 6 and GetSpecialization() == 2 then
        right = "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_frost"
        left = "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_frost"
    end

    return left, right
end
--]]
local function selectBg()
    if not GetSetting("HUD_SPELL_SWAP") then
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

        for i = 1, 40 do
            local _, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
            if spellID ~= nil and action_hud_auras[spellID] ~= nil then
                left = action_hud_auras[spellID]["left"]
                right = action_hud_auras[spellID]["right"]
            end
        end
    end

    if currentTexture ~= left then
        currentTexture = left
        _G["GwActionBarHudLEFT"]:SetTexture(left)
        _G["GwActionBarHudRIGHT"]:SetTexture(right)
    end
end
GW.AddForProfiling("hud", "selectBg", selectBg)

local function combatHealthState()
    local unitHealthPrecentage = UnitHealth("player") / UnitHealthMax("player")

    if unitHealthPrecentage < 0.5 and not UnitIsDeadOrGhost("player") then
        unitHealthPrecentage = unitHealthPrecentage / 0.5

        _G["GwActionBarHudLEFT"]:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        _G["GwActionBarHudRIGHT"]:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        _G["GwActionBarHudRIGHTSWIM"]:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        _G["GwActionBarHudLEFTSWIM"]:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        _G["GwActionBarHudLEFTBLOOD"]:SetVertexColor(1, 1, 1, 1 - (unitHealthPrecentage - 0.2))
        _G["GwActionBarHudRIGHTBLOOD"]:SetVertexColor(1, 1, 1, 1 - (unitHealthPrecentage - 0.2))
    else
        _G["GwActionBarHudLEFT"]:SetVertexColor(1, 1, 1)
        _G["GwActionBarHudRIGHT"]:SetVertexColor(1, 1, 1)

        _G["GwActionBarHudRIGHTSWIM"]:SetVertexColor(1, 1, 1)
        _G["GwActionBarHudLEFTSWIM"]:SetVertexColor(1, 1, 1)

        _G["GwActionBarHudLEFTBLOOD"]:SetVertexColor(1, 1, 1, 0)
        _G["GwActionBarHudRIGHTBLOOD"]:SetVertexColor(1, 1, 1, 0)
    end
end
GW.AddForProfiling("hud", "combatHealthState", combatHealthState)

registerActionHudAura(
    31842,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_holy",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_holy"
)
registerActionHudAura(
    31884,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_holy",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_holy"
)
registerActionHudAura(
    5487,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_bear",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_bear"
)
registerActionHudAura(
    768,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_cat",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_cat"
)
registerActionHudAura(
    51271,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_frost",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_frost"
)
registerActionHudAura(
    187827,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_metamorph",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_metamorph"
)
registerActionHudAura(
    215785,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_shaman_fire",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_shaman_fire"
)
registerActionHudAura(
    77762,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_shaman_fire",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_shaman_fire"
)
registerActionHudAura(
    201846,
    "Interface\\AddOns\\GW2_UI\\textures\\leftshadow_shaman_storm",
    "Interface\\AddOns\\GW2_UI\\textures\\rightshadow_shaman_storm"
)

local function LoadBreathMeter()
    CreateFrame("Frame", "GwBreathMeter", UIParent, "GwBreathMeter")
    GwBreathMeter:Hide()
    GwBreathMeter:SetScript(
        "OnShow",
        function()
            UIFrameFadeIn(GwBreathMeter, 0.2, GwBreathMeter:GetAlpha(), 1)
        end
    )
    MirrorTimer1:SetScript(
        "OnShow",
        function(self)
            self:Hide()
        end
    )
    MirrorTimer1:UnregisterAllEvents()

    GwBreathMeter:RegisterEvent("MIRROR_TIMER_START")
    GwBreathMeter:RegisterEvent("MIRROR_TIMER_STOP")

    GwBreathMeter:SetScript(
        "OnEvent",
        function(self, event, arg1, arg2, arg3, arg4)
            if event == "MIRROR_TIMER_START" then
                local texture = "Interface\\AddOns\\GW2_UI\\textures\\castingbar"
                if arg1 == "BREATH" then
                    texture = "Interface\\AddOns\\GW2_UI\\textures\\breathmeter"
                end
                GwBreathMeterBar:SetStatusBarTexture(texture)
                GwBreathMeterBar:SetMinMaxValues(0, arg3)
                GwBreathMeterBar:SetScript(
                    "OnUpdate",
                    function()
                        GwBreathMeterBar:SetValue(GetMirrorTimerProgress(arg1))
                    end
                )
                GwBreathMeter:Show()
            end
            if event == "MIRROR_TIMER_STOP" then
                GwBreathMeterBar:SetScript("OnUpdate", nil)
                GwBreathMeter:Hide()
            end
        end
    )
end
GW.LoadBreathMeter = LoadBreathMeter

local function hud_OnEvent(self, event, ...)
    if event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            selectBg()
        end
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        selectBg()
    elseif event == "UNIT_HEALTH_FREQUENT" or event == "UNIT_MAXHEALTH" then
        local unit = ...
        if unit == "player" then
            combatHealthState()
        end
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

    hudArtFrame:SetScript("OnEvent", hud_OnEvent)

    hudArtFrame:RegisterEvent("UNIT_AURA")
    hudArtFrame:RegisterEvent("PLAYER_ALIVE")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hudArtFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "player")
    hudArtFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    selectBg()
    combatHealthState()
end
GW.LoadHudArt = LoadHudArt

local function LoadXPBar()
    local experiencebar = CreateFrame("Frame", "GwExperienceFrame", UIParent, "GwExperienceBar")

    experiencebarAnimation = UnitXP("Player") / UnitXPMax("Player")

    _G["GwExperienceFrameRepuBar"].repuBarAnimation = 0
    _G["GwExperienceFrameNextLevel"]:SetFont(UNIT_NAME_FONT, 12)
    _G["GwExperienceFrameCurrentLevel"]:SetFont(UNIT_NAME_FONT, 12)

    updateBarSize()
    xpbar_OnEvent()

    experiencebar:SetScript("OnEvent", xpbar_OnEvent)

    experiencebar:RegisterEvent("PLAYER_XP_UPDATE")
    experiencebar:RegisterEvent("UPDATE_FACTION")
    experiencebar:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    experiencebar:RegisterEvent("PLAYER_UPDATE_RESTING")
    experiencebar:RegisterEvent("PLAYER_ENTERING_WORLD")

    experiencebar:SetScript("OnEnter", xpbar_OnEnter)
    experiencebar:SetScript(
        "OnLeave",
        function()
            GameTooltip_Hide()
            UIFrameFadeIn(GwExperienceFrameBar, 0.2, GwExperienceFrameBar:GetAlpha(), 1)
            UIFrameFadeIn(GwExperienceFrameRepuBar, 0.2, GwExperienceFrameRepuBar:GetAlpha(), 1)
        end
    )
end
GW.LoadXPBar = LoadXPBar