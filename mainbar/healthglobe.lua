local _, GW = ...
local L = GW.L
local CommaValue = GW.CommaValue
local AddToClique = GW.AddToClique
local Self_Hide = GW.Self_Hide
local TimeParts = GW.TimeParts
local IsIn = GW.IsIn
local GetSetting = GW.GetSetting
local IncHeal = {}

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
    local prediction_over = prediction - health_def
    if prediction_over < 0 then
        prediction_over = 0
    end
    local prediction_under = prediction - prediction_over

    -- determine how much black (anti) area to mask off
    local hp = (health + prediction_under) / healthMax
    local hpy_off = Y_FULL - Y_RANGE * (1 - hp)
    local hpx_off = ((X_MAX - X_MIN) * (math.random())) + X_MIN

    -- determine how much light (prediction) area to mask off
    local pup = health / healthMax
    local puy_off = Y_FULL - Y_RANGE * (1 - pup)

    -- set the mask positions for health; prettily if animating,
    -- otherwise just force them
    local anti = self.fill.anti
    local au = self.fill.prediction_under
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

        -- animate absorb under transition
        local ag2 = au.gwAnimGroup
        ag2:Stop()
        local _, _, _, _, y2 = au:GetPoint()
        au:ClearAllPoints()
        au:SetPoint("CENTER", self.fill, "CENTER", hpx_off, y2)
        local aa2 = au.gwAnim
        aa2.gwXoff = hpx_off
        aa2.gwYoff = puy_off
        aa2:SetOffset(0, puy_off - y2)
        ag2:Play()
    else
        -- hard-set positions
        anti:ClearAllPoints()
        anti:SetPoint("CENTER", self.fill, "CENTER", hpx_off, hpy_off)
        au:ClearAllPoints()
        au:SetPoint("CENTER", self.fill, "CENTER", hpx_off, puy_off)
    end

    local flash = anti.gwFlashGroup
    if pup < 0.5 and not UnitIsDeadOrGhost("PLAYER") then
        flash:Play()
    else
        flash:Finish()
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
            if GW.myfaction == "Horde" then
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
    elseif event == "RESURRECT_REQUEST" then
        PlaySound(SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING_SMALLER, "Master")
    end
end
GW.AddForProfiling("healthglobe", "globe_OnEvent", globe_OnEvent)

local function globe_OnEnter(self)
    local pvpdesired = GetPVPDesired()
    local pvpactive = UnitIsPVP("player") or UnitIsPVPFreeForAll("player")

    GameTooltip_SetDefaultAnchor(GameTooltip, self)
    GameTooltip:SetUnit("player")
    GameTooltip:AddLine(" ")
    if pvpdesired or pvpactive then
        GameTooltip_AddColoredLine(GameTooltip, PVP .. " - " .. VIDEO_OPTIONS_ENABLED, HIGHLIGHT_FONT_COLOR)
    else
        GameTooltip_AddColoredLine(GameTooltip, PVP .. " - " .. VIDEO_OPTIONS_DISABLED, HIGHLIGHT_FONT_COLOR)
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
            GameTooltip_AddNormalLine(GameTooltip, ERR_PVP_TOGGLE_OFF, true)
        end
    end
    GameTooltip:Show()

    if self.pvp.pvpFlag then
        self.pvp:fadeIn()
    end
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

local function setPredictionAmount(self)
    local prediction = (GW.HealComm:GetHealAmount(self.guid, GW.HealComm.ALL_HEALS) or 0) * (GW.HealComm:GetHealModifier(self.guid) or 1)

    self.healPredictionAmount = prediction
    updateHealthData(self)
end
GW.AddForProfiling("healthglobe", "setPredictionAmount", setPredictionAmount)

local function LoadHealthGlobe()
    local hg = CreateFrame("Button", nil, UIParent, "GwHealthGlobeTmpl")
    GW.RegisterScaleFrame(hg, 1.1)

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
    
    hg.fill.prediction_under:AddMaskTexture(hg.fill.maskb)
    hg.fill.anti:AddMaskTexture(hg.fill.maskb)

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

    -- marks off the light absorb/shield space
    local aag2 = hg.fill.prediction_under:CreateAnimationGroup()
    local aa2 = aag2:CreateAnimation("translation")
    aa2:SetDuration(0.2)
    aa2:SetScript("OnFinished", fill_OnFinish)
    hg.fill.prediction_under.gwAnimGroup = aag2
    hg.fill.prediction_under.gwAnim = aa2

    -- set text/font stuff
    hg.hSize = 14
    hg.text_h.value:SetFont(DAMAGE_TEXT_FONT, hg.hSize)
    hg.text_h.value:SetShadowColor(1, 1, 1, 0)

    for i, v in ipairs(hg.text_h.shadow) do
        v:SetFont(DAMAGE_TEXT_FONT, hg.hSize)
        v:SetShadowColor(1, 1, 1, 0)
        v:SetTextColor(0, 0, 0, 1 / i)
    end

    -- set handlers for health globe and disable default player frame
    PlayerFrame:SetScript("OnEvent", nil)
    PlayerFrame:Hide()
    hg:SetScript("OnEvent", globe_OnEvent)
    hg:SetScript("OnEnter", globe_OnEnter)
    hg:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        if self.pvp.pvpFlag then
            self.pvp:fadeOut()
        end
    end)
    hg:RegisterEvent("PLAYER_ENTERING_WORLD")
    hg:RegisterEvent("PLAYER_FLAGS_CHANGED")
    hg:RegisterEvent("RESURRECT_REQUEST")
    hg:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "player")
    hg:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    hg:RegisterUnitEvent("UNIT_FACTION", "player")

    -- Handle callbacks from HealComm
    local HealCommEventHandler = function (event, casterGUID, spellID, healType, endTime, ...)
        local self = hg
        return setPredictionAmount(self)
    end
    --libHealComm setup
    GW.HealComm.RegisterCallback(hg, "HealComm_HealStarted", HealCommEventHandler)
    GW.HealComm.RegisterCallback(hg, "HealComm_HealUpdated", HealCommEventHandler)
    GW.HealComm.RegisterCallback(hg, "HealComm_HealStopped", HealCommEventHandler)
    GW.HealComm.RegisterCallback(hg, "HealComm_HealDelayed", HealCommEventHandler)
    GW.HealComm.RegisterCallback(hg, "HealComm_ModifierChanged", HealCommEventHandler)
    GW.HealComm.RegisterCallback(hg, "HealComm_GUIDDisappeared", HealCommEventHandler)
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
    local pagIn = pvp:CreateAnimationGroup("fadeIn")
    local pagOut = pvp:CreateAnimationGroup("fadeOut")
    local fadeOut = pagOut:CreateAnimation("Alpha")
    local fadeIn = pagIn:CreateAnimation("Alpha")

    pagOut:SetScript("OnFinished", function(self)
        self:GetParent():SetAlpha(0.33)
    end)

    fadeOut:SetFromAlpha(1.0)
    fadeOut:SetToAlpha(0.33)
    fadeOut:SetDuration(0.1)
    fadeIn:SetFromAlpha(0.33)
    fadeIn:SetToAlpha(1.0)
    fadeIn:SetDuration(0.1)

    pvp.fadeOut = function(self)
        pagIn:Stop()
        pagOut:Stop()
        pagOut:Play()
    end
    pvp.fadeIn = function(self)
        self:SetAlpha(1)
        pagIn:Stop()
        pagOut:Stop()
        pagIn:Play()
    end

    return hg
end
GW.LoadHealthGlobe = LoadHealthGlobe
