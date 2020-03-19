local _, GW = ...
local L = GW.L
local CommaValue = GW.CommaValue
local AddToClique = GW.AddToClique
local Self_Hide = GW.Self_Hide
local TimeParts = GW.TimeParts
local IsIn = GW.IsIn
local GetSetting = GW.GetSetting
local IncHeal = {}
local HealComm = LibStub("LibHealComm-4.0", true)

local function repair_OnEvent(self, event, ...)
    if event ~= "PLAYER_ENTERING_WORLD" and not GW.inWorld then
        return
    end
    local needRepair = false
    local gearBroken = false
    for i = 1, 23 do
        local current, maximum = GetInventoryItemDurability(i)
        if current ~= nil then
            local dur = current / maximum
            if dur < 0.5 then
                needRepair = true
            end
            if dur == 0 then
                gearBroken = true
            end
        end
    end

    if gearBroken then
        self.icon:SetTexCoord(0, 1, 0.5, 1)
    else
        self.icon:SetTexCoord(0, 1, 0, 0.5)
    end

    if needRepair then
        self:Show()
    else
        self:Hide()
    end
end
GW.AddForProfiling("healthglobe", "repair_OnEvent", repair_OnEvent)

local Y_FULL = 47
local Y_EMPTY = -42
local Y_RANGE = Y_FULL - Y_EMPTY
local X_MAX = 20
local X_MIN = -20
local function updateHealthData(self, anims)
    local health = UnitHealth("Player")
    local healthMax = UnitHealthMax("Player")
    local prediction = self.healPredictionAmount

    local health_def = healthMax - health

    -- determine how much black (anti) area to mask off
    local hp = health / healthMax
    local hpy_off = Y_FULL - Y_RANGE * (1 - hp)
    local hpx_off = ((X_MAX - X_MIN) * (math.random())) + X_MIN

    -- determine how much light (absorb) area to mask off
    local aup = health / healthMax

    -- determine how much predicted health to overlay
    if prediction + health > healthMax then
        prediction = healthMax - health
    end
    local pp = prediction / healthMax
    local ppy_off = Y_FULL - Y_RANGE * (1 - aup)

    -- set the mask positions for health; prettily if animating,
    -- otherwise just force them
    local anti = self.fill.anti
    if anims then
        -- animate health transition
        local ag = anti.gwAnimGroup
        ag:Stop()
        local _, _, _, _, y = anti:GetPoint()
        anti:ClearAllPoints()
        anti:SetPoint("CENTER", self.fill, "CENTER", hpx_off, y)
        local aa = anti.gwAnim
        aa.gwXoff = hpx_off
        aa.gwYoff = hpy_off
        aa:SetOffset(0, hpy_off - y)
        ag:Play()
    else
        -- hard-set positions
        anti:ClearAllPoints()
        anti:SetPoint("CENTER", self.fill, "CENTER", hpx_off, hpy_off)
    end

    local flash = anti.gwFlashGroup
    if aup < 0.5 and not UnitIsDeadOrGhost("PLAYER") then
        flash:Play()
    else
        flash:Finish()
    end

    -- hard-set heal prediction amount; no animation setup for this yet
    local pred = self.fill.pred
    if prediction > 0 then
        local h = (Y_RANGE * pp) - 2
        pred:ClearAllPoints()
        GW.Debug("ppy", ppy_off + h - 3)
        pred:SetPoint("CENTER", self.fill, "CENTER", -hpx_off, math.min(ppy_off + h, 41))
        pred:Show()
    else
        pred:Hide()
    end

    -- hard-set the text values for health based on the user settings (%, value or both)
    local hv = ""

    if self.healthTextSetting == "PREC" then
        hv = CommaValue(health / healthMax * 100) .. "%"
    elseif self.healthTextSetting == "VALUE" then
        hv = CommaValue(health)
    elseif self.healthTextSetting == "BOTH" then
        hv = CommaValue(health) .. "\n" .. CommaValue(health / healthMax * 100) .. "%"
    end

    self.text_h.value:SetText(hv)

    for i, v in ipairs(self.text_h.shadow) do
        v:SetText(hv)
    end

end
GW.AddForProfiling("healthglobe", "updateHealthData", updateHealthData)

local function selectPvp(self)
    local prevFlag = self.pvp.pvpFlag
    if GetPVPDesired("player") or UnitIsPVP("player") or UnitIsPVPFreeForAll("player") then
        self.pvp.pvpFlag = true
        if prevFlag ~= true then
            local fac, _ = UnitFactionGroup("player")
            if fac == "Horde" then
                self.pvp.ally:Hide()
                self.pvp.horde:Show()
            else
                self.pvp.ally:Show()
                self.pvp.horde:Hide()
            end
        end
    else
        self.pvp.pvpFlag = false
        self.pvp.ally:Hide()
        self.pvp.horde:Hide()
    end
end
GW.AddForProfiling("healthglobe", "selectPvp", selectPvp)

local function globe_OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        updateHealthData(self, false)
        selectPvp(self)
    elseif IsIn(event, "UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH") then
        updateHealthData(self, true)
    elseif IsIn(event, "PLAYER_FLAGS_CHANGED", "UNIT_FACTION") then
        selectPvp(self)
    end
end
GW.AddForProfiling("healthglobe", "globe_OnEvent", globe_OnEvent)

local function globe_OnEnter(self)
    local pvpdesired = GetPVPDesired("player")
    local pvpactive = UnitIsPVP("player") or UnitIsPVPFreeForAll("player")

    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    if pvpdesired or pvpactive then
        GameTooltip_SetTitle(GameTooltip, PVP .. " - " .. VIDEO_OPTIONS_ENABLED)
    else
        GameTooltip_SetTitle(GameTooltip, PVP .. " - " .. VIDEO_OPTIONS_DISABLED)
    end
    if pvpdesired then
        GameTooltip_AddNormalLine(GameTooltip, PVP_TOGGLE_ON_VERBOSE, true)
    else
        if pvpactive then
            local pvpTime = GetPVPTimer()
            if pvpTime > 0 and pvpTime < 301000 then
                local _, nMin, nSec, _ = TimeParts(pvpTime)
                GameTooltip_AddNormalLine(
                    GameTooltip,
                    TIME_REMAINING .. " " .. string.format(TIMER_MINUTES_DISPLAY, nMin, nSec)
                )
            end
            GameTooltip_AddNormalLine(GameTooltip, PVP_TOGGLE_OFF_VERBOSE, true)
        else
            GameTooltip_AddNormalLine(GameTooltip, PVP_WARMODE_TOGGLE_OFF, true)
        end
    end
    GameTooltip:Show()
end
GW.AddForProfiling("healthglobe", "globe_OnEnter", globe_OnEnter)

local function fill_OnFinish(self)
    local f = self:GetParent():GetParent()
    f:ClearAllPoints()
    f:SetPoint("CENTER", f:GetParent(), "CENTER", self.gwXoff, self.gwYoff)
end
GW.AddForProfiling("healthglobe", "fill_OnFinish", fill_OnFinish)

local function repair_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(L["DAMAGED_OR_BROKEN_EQUIPMENT"], 1, 1, 1)
    GameTooltip:Show()
end
GW.AddForProfiling("healthglobe", "repair_OnEnter", repair_OnEnter)

local function UpdateIncomingPredictionAmount(...)
    for i = 1, select("#", ...) do
        if (select(i, ...) == GwHealthGlobe.guid) and (UnitPlayerOrPetInParty(GwHealthGlobe.unit) or UnitPlayerOrPetInRaid(GwHealthGlobe.unit) or UnitIsUnit("player", GwHealthGlobe.unit) or UnitIsUnit("pet", GwHealthGlobe.unit)) then
            local amount = (HealComm:GetHealAmount(GwHealthGlobe.guid, HealComm.ALL_HEALS) or 0) * (HealComm:GetHealModifier(GwHealthGlobe.guid) or 1)
            GwHealthGlobe.healPredictionAmount = amount
            updateHealthData(GwHealthGlobe)
            break
        end
    end
end

-- Handle callbacks from HealComm
function IncHeal:HealComm_HealUpdated(event, casterGUID, spellID, healType, endTime, ...)
	UpdateIncomingPredictionAmount(...)
end
function IncHeal:HealComm_HealStopped(event, casterGUID, spellID, healType, interrupted, ...)
	UpdateIncomingPredictionAmount(...)
end
function IncHeal:HealComm_ModifierChanged(event, guid)
	UpdateIncomingPredictionAmount(guid)
end
function IncHeal:HealComm_GUIDDisappeared(event, guid)
	UpdateIncomingPredictionAmount(guid)
end

local function LoadHealthGlobe()
    local hg = CreateFrame("Button", "GwHealthGlobe", UIParent, "GwHealthGlobeTmpl")
    GW.RegisterScaleFrame(playerPowerBar, 1.1)

    -- position based on XP bar space
    if GetSetting("XPBAR_ENABLED") then
        hg:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 17)
    else
        hg:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
    end

    --save settingsvalue for later use
    hg.healthTextSetting = GetSetting("PLAYER_UNIT_HEALTH")

    -- unit frame stuff
    hg:SetAttribute("*type1", "target")
    hg:SetAttribute("*type2", "togglemenu")
    hg:SetAttribute("unit", "player")
    AddToClique(hg)

    -- setup masking textures
    for i, v in ipairs(hg.fill.masked) do
        v:AddMaskTexture(hg.fill.mask)
    end

    -- setting these values in the XML creates animation glitches
    -- so we do it here instead
    hg.fill.maskb:SetPoint("CENTER", hg.fill, "CENTER", 0, 0)

    hg.fill.anti:AddMaskTexture(hg.fill.maskb)
    hg.fill.pred:AddMaskTexture(hg.fill.maskb)

    -- setup fill animations; this marks off the black/empty space
    local aag = hg.fill.anti:CreateAnimationGroup()
    local aa = aag:CreateAnimation("translation")
    aa:SetDuration(0.2)
    aa:SetScript("OnFinished", fill_OnFinish)
    hg.fill.anti.gwAnimGroup = aag
    hg.fill.anti.gwAnim = aa

    -- flashes the black/empty space (for low health warning)
    local afg = hg.fill.anti:CreateAnimationGroup()
    local af = afg:CreateAnimation("alpha")
    af:SetDuration(0.66)
    af:SetFromAlpha(1)
    af:SetToAlpha(0.66)
    afg:SetLooping("BOUNCE")
    hg.fill.anti.gwFlashGroup = afg


    -- set text/font stuff
    hg.text_h.value:SetFont(DAMAGE_TEXT_FONT, 14)
    hg.text_h.value:SetShadowColor(1, 1, 1, 0)

    for i, v in ipairs(hg.text_h.shadow) do
        v:SetFont(DAMAGE_TEXT_FONT, 14)
        v:SetShadowColor(1, 1, 1, 0)
        v:SetTextColor(0, 0, 0, 1 / i)
    end

    -- set handlers for health globe and disable default player frame
    PlayerFrame:SetScript("OnEvent", nil)
    PlayerFrame:Hide()
    hg:SetScript("OnEvent", globe_OnEvent)
    hg:SetScript("OnEnter", globe_OnEnter)
    hg:SetScript("OnLeave", GameTooltip_Hide)
    hg:RegisterEvent("PLAYER_ENTERING_WORLD")
    hg:RegisterEvent("PLAYER_FLAGS_CHANGED")
    hg:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "player")
    hg:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    hg:RegisterUnitEvent("UNIT_FACTION", "player")

    --libHealComm setup
    HealComm.RegisterCallback(IncHeal, "HealComm_HealStarted", "HealComm_HealUpdated")
    HealComm.RegisterCallback(IncHeal, "HealComm_HealStopped")
    HealComm.RegisterCallback(IncHeal, "HealComm_HealDelayed", "HealComm_HealUpdated")
    HealComm.RegisterCallback(IncHeal, "HealComm_HealUpdated")
    HealComm.RegisterCallback(IncHeal, "HealComm_ModifierChanged")
    HealComm.RegisterCallback(IncHeal, "HealComm_GUIDDisappeared")
    hg.healPredictionAmount = 0
    hg.unit = "Player"
    hg.guid = UnitGUID("Player")

    -- setup hooks for the repair icon (and disable default repair frame)
    DurabilityFrame:UnregisterAllEvents()
    DurabilityFrame:HookScript("OnShow", Self_Hide)
    DurabilityFrame:Hide()

    local rep = hg.repair
    rep:SetScript("OnEvent", repair_OnEvent)
    rep:SetScript("OnEnter", repair_OnEnter)
    rep:SetScript("OnLeave", GameTooltip_Hide)
    rep:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    rep:RegisterEvent("PLAYER_ENTERING_WORLD")

    -- grab the TotemFrame so it remains visible
    if PlayerFrame and TotemFrame then
        TotemFrame:SetParent(playerHealthGLobaBg)
        PlayerFrame:ClearAllPoints()
        PlayerFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -500, 50)
        -- TODO: we can't position this directly; it's permanently attached to the PlayerFrame via SetPoints
        -- in the TotemFrame OnUpdate that we can't override because combat lockdowns and whatnot, and simply
        -- moving the PlayerFrame isn't ideal because its layout is highly variable; really we probably just
        -- need to completely re-implement the TotemFrame with a custom version
    end

    -- setup anim to flash the PvP marker
    local pvp = hg.pvp
    local pag = pvp:CreateAnimationGroup()
    local pa1 = pag:CreateAnimation("alpha")
    local pa2 = pag:CreateAnimation("alpha")
    pvp.gwAnimGroup = pag
    pa1:SetOrder(1)
    pa2:SetOrder(2)
    pa1:SetFromAlpha(0.33)
    pa1:SetToAlpha(1.0)
    pa1:SetDuration(0.1)
    pa2:SetFromAlpha(1.0)
    pa2:SetToAlpha(0.33)
    pa2:SetDuration(0.1)

end
GW.LoadHealthGlobe = LoadHealthGlobe
