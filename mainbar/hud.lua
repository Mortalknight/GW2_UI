local _, GW = ...
local GetSetting = GW.GetSetting

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
    local right = "Interface\\AddOns\\GW2_UI\\textures\\hud\\rightshadow"
    local left = "Interface\\AddOns\\GW2_UI\\textures\\hud\\leftshadow"

    if UnitIsDeadOrGhost("player") then
        right = "Interface\\AddOns\\GW2_UI\\textures\\hud\\rightshadow_dead"
        left = "Interface\\AddOns\\GW2_UI\\textures\\hud\\leftshadow_dead"
    end

    if UnitAffectingCombat("player") then
        right = "Interface\\AddOns\\GW2_UI\\textures\\hud\\rightshadowcombat"
        left = "Interface\\AddOns\\GW2_UI\\textures\\hud\\leftshadowcombat"

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
    local alpha = 1 - unitHealthPrecentage - 0.2
    if alpha < 0 then alpha = 0 end
    if alpha > 1 then alpha = 1 end

    if unitHealthPrecentage < 0.5 and not UnitIsDeadOrGhost("player") then
        unitHealthPrecentage = unitHealthPrecentage / 0.5

        self.actionBarHud.Left:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        self.actionBarHud.Right:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        self.actionBarHud.RightSwim:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)
        self.actionBarHud.LeftSwim:SetVertexColor(1, unitHealthPrecentage, unitHealthPrecentage)

        self.actionBarHud.LeftBlood:SetVertexColor(1, 1, 1, alpha)
        self.actionBarHud.RightBlood:SetVertexColor(1, 1, 1, alpha)
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
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\leftshadow_holy",
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\rightshadow_holy",
    "player"
)
registerActionHudAura(
    31884,
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\leftshadow_holy",
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\rightshadow_holy",
    "player"
)
registerActionHudAura(
    5487,
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\leftshadow_bear",
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\rightshadow_bear",
    "player"
)
registerActionHudAura(
    768,
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\leftshadow_cat",
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\rightshadow_cat",
    "player"
)
registerActionHudAura(
    51271,
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\leftshadow_frost",
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\rightshadow_frost",
    "player"
)
registerActionHudAura(
    187827,
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\leftshadow_metamorph",
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\rightshadow_metamorph",
    "player"
)
registerActionHudAura(
    215785,
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\leftshadow_shaman_fire",
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\rightshadow_shaman_fire",
    "player"
)
registerActionHudAura(
    77762,
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\leftshadow_shaman_fire",
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\rightshadow_shaman_fire",
    "player"
)
registerActionHudAura(
    201846,
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\leftshadow_shaman_storm",
    "Interface\\AddOns\\GW2_UI\\textures\\hud\\rightshadow_shaman_storm",
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

local function ToggleHudBackground()
    if Gw2_HudBackgroud.actionBarHud.HUDBG then
        for _, f in ipairs(Gw2_HudBackgroud.actionBarHud.HUDBG) do
            if GetSetting("HUD_BACKGROUND") then
                f:Show()
            else
                f:Hide()
            end
        end
    end

    if Gw2_HudBackgroud.edgeTint then
        local showBorder = GetSetting("BORDER_ENABLED")
        for _, f in ipairs(Gw2_HudBackgroud.edgeTint) do
            if showBorder then
                f:Show()
            else
                f:Hide()
            end
        end

        --Gw2MicroBarFrame.cf.bg:SetShown(showBorder)
    end
end
GW.ToggleHudBackground = ToggleHudBackground

local function LoadHudArt()
    local hudArtFrame = CreateFrame("Frame", "Gw2_HudBackgroud", UIParent, "GwHudArtFrame")
    GW.MixinHideDuringPetAndOverride(hudArtFrame)

    ToggleHudBackground()

    GW.RegisterScaleFrame(hudArtFrame.actionBarHud)

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
