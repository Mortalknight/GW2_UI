local _, GW = ...
local CommaValue = GW.CommaValue
local PowerBarColorCustom = GW.PowerBarColorCustom
local bloodSpark = GW.BLOOD_SPARK
local DODGEBAR_SPELLS = GW.DODGEBAR_SPELLS
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local AddToClique = GW.AddToClique
local Self_Hide = GW.Self_Hide
local TimeParts = GW.TimeParts
local GWPlayerFrame = nil
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
        GwHudArtFrameRepairTexture:SetTexCoord(0, 1, 0.5, 1)
    else
        GwHudArtFrameRepairTexture:SetTexCoord(0, 1, 0, 0.5)
    end

    if needRepair then
        GwHudArtFrameRepair:Show()
    else
        GwHudArtFrameRepair:Hide()
    end
end
GW.AddForProfiling("playerhud", "repair_OnEvent", repair_OnEvent)

local function globeFlashComplete()
    GwPlayerHealthGlobe.animating = true
    local lerpTo = 0

    if GwPlayerHealthGlobe.animationPrecentage == nil then
        GwPlayerHealthGlobe.animationPrecentage = 0
    end

    if GwPlayerHealthGlobe.animationPrecentage <= 0 then
        lerpTo = 0.4
    end

    AddToAnimation(
        "healthGlobeFlash",
        GwPlayerHealthGlobe.animationPrecentage,
        lerpTo,
        GetTime(),
        0.8,
        function()
            local l = animations["healthGlobeFlash"]["progress"]

            GwPlayerHealthGlobe.background:SetVertexColor(l, l, l)
        end,
        nil,
        function()
            local health = UnitHealth("Player")
            local healthMax = UnitHealthMax("Player")
            local healthPrec = 0.00001
            if health > 0 and healthMax > 0 then
                healthPrec = health / healthMax
            end
            if healthPrec < 0.5 then
                GwPlayerHealthGlobe.animationPrecentage = lerpTo
                globeFlashComplete()
            else
                GwPlayerHealthGlobe.background:SetVertexColor(0, 0, 0)
                GwPlayerHealthGlobe.animating = false
            end
        end
    )
end
GW.AddForProfiling("playerhud", "globeFlashComplete", globeFlashComplete)

local function updateHealthText(text)
    local v = CommaValue(text)
    _G["GwPlayerHealthGlobeTextValue"]:SetText(v)
    for i = 1, 8 do
        _G["GwPlayerHealthGlobeTextShadow" .. i]:SetText(v)
    end
end
GW.AddForProfiling("playerhud", "updateHealthText", updateHealthText)

local healtGlobaFlareColors = {}

healtGlobaFlareColors[0] = {r = 79, g = 10, b = 5}
healtGlobaFlareColors[1] = {r = 212, g = 32, b = 4}

local function lerpFlareColors(step)
    local r = Lerp(healtGlobaFlareColors[0].r, healtGlobaFlareColors[1].r, step)
    local g = Lerp(healtGlobaFlareColors[0].g, healtGlobaFlareColors[1].g, step)
    local b = Lerp(healtGlobaFlareColors[0].b, healtGlobaFlareColors[1].b, step)

    return r / 255, g / 255, b / 255
end
GW.AddForProfiling("playerhud", "lerpFlareColors", lerpFlareColors)

local function updateHealthData(self)
    local health = UnitHealth("Player")
    local healthMax = UnitHealthMax("Player")
    local healthPrec = 0.00001
    local predictionPrec = 0.00001
    local prediction = self.healPredictionAmount

    if health > 0 and healthMax > 0 then
        healthPrec = math.max(0.0001, health / healthMax)
    end

    if prediction > 0 and healthMax > 0 and health < healthMax then
        predictionPrec = math.min(math.max(0.001, prediction / healthMax), 1)
        _G["GwPlayerHealthGlobePredictionBackdropBar"]:Show()
        GwPlayerHealthGlobePredictionBackdrop.spark:Show()
    else
        _G["GwPlayerHealthGlobePredictionBackdropBar"]:Hide()
        GwPlayerHealthGlobePredictionBackdrop.spark:Hide()
    end

    if healthPrec < 0.5 and (self.animating == false or self.animating == nil) then
        globeFlashComplete()
    end

    self.stringUpdateTime = 0

    local startTime = GetTime()
    AddToAnimation(
        "healthGlobeAnimation",
        self.animationCurrent,
        healthPrec,
        GetTime(),
        0.2,
        function()
            local healthPrecCandy = math.min(1, animations["healthGlobeAnimation"]["progress"] + 0.02)

            if self.stringUpdateTime < GetTime() then
                updateHealthText(healthMax * animations["healthGlobeAnimation"]["progress"])
                self.stringUpdateTime = GetTime() + 0.05
            end

            local predictionPrecentage = (animations["healthGlobeAnimation"]["progress"] + predictionPrec) - 0.05
            if predictionPrec <= 0.001 then
                predictionPrecentage = 0.01
            end

            local healthAnimationReduction =
                math.max(0, math.min(1, animations["healthGlobeAnimation"]["progress"] - 0.05))
            if animations["healthGlobeAnimation"]["progress"] >= 0.95 then
                healthAnimationReduction = animations["healthGlobeAnimation"]["progress"]
            end

            _G["GwPlayerHealthGlobePredictionBackdrop"]:SetHeight(
                math.min(1, predictionPrecentage) * _G["GwPlayerHealthGlobeHealthBar"]:GetWidth()
            )
            _G["GwPlayerHealthGlobePredictionBackdropBar"]:SetTexCoord(0, 1, math.abs(math.min(1, predictionPrecentage) - 1), 1)

            _G["GwPlayerHealthGlobeHealth"]:SetHeight(
                healthAnimationReduction * _G["GwPlayerHealthGlobeHealthBar"]:GetWidth()
            )
            _G["GwPlayerHealthGlobeHealthBar"]:SetTexCoord(0, 1, math.abs(healthAnimationReduction - 1), 1)
            if healthPrec < animations["healthGlobeAnimation"]["progress"] then
                GwPlayerHealthGlobeHealth.spark:SetAlpha(Lerp(1, 0.5, (GetTime() - startTime) / 0.2))
            end

            local bit = _G["GwPlayerHealthGlobeHealthBar"]:GetWidth() / 20
            local spark = bit * math.floor(4 * (animations["healthGlobeAnimation"]["progress"]))

            local spark_current = (bit * (4 * (animations["healthGlobeAnimation"]["progress"])) - spark) / bit
            local sprite = math.min(4, math.max(1, math.floor(5 - (6 * spark_current))))
            GwPlayerHealthGlobeHealth.spark:SetTexCoord(0, 1, (0.25 * sprite) - 0.25, 0.25 * sprite)
            GwPlayerHealthGlobeHealth.spark2:SetTexCoord(0, 1, (0.25 * sprite) - 0.25, 0.25 * sprite)
            local r, g, b = lerpFlareColors(healthAnimationReduction)
            GwPlayerHealthGlobeHealth.spark2:SetVertexColor(r, g, b, 1)

            GwPlayerHealthGlobePredictionBackdrop.spark:SetTexCoord(0, 1, (0.25 * sprite) - 0.25, 0.25 * sprite)
        end,
        nil,
        function()
            updateHealthText(health)
        end
    )
    self.animationCurrent = healthPrec
end
GW.AddForProfiling("playerhud", "updateHealthData", updateHealthData)

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
            AddToAnimation(
                "pvpMarkerFlash",
                1,
                0.33,
                GetTime(),
                3,
                function()
                    self.pvp.ally:SetAlpha(animations["pvpMarkerFlash"]["progress"])
                    self.pvp.horde:SetAlpha(animations["pvpMarkerFlash"]["progress"])
                end
            )
        end
    else
        self.pvp.pvpFlag = false
        self.pvp.ally:Hide()
        self.pvp.horde:Hide()
    end
end
GW.AddForProfiling("playerhud", "selectPvp", selectPvp)

local function globe_OnEvent(self, event, ...)
    if event == "UNIT_HEALTH_FREQUENT" or event == "UNIT_MAXHEALTH" or event == "PLAYER_ENTERING_WORLD" then
        updateHealthData(self)
    elseif event == "PLAYER_FLAGS_CHANGED" or event == "UNIT_FACTION" then
        selectPvp(self)
    end
end
GW.AddForProfiling("playerhud", "globe_OnEvent", globe_OnEvent)

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
    AddToAnimation(
        "pvpMarkerFlash",
        0.33,
        1,
        GetTime(),
        0.5,
        function()
            self.pvp.ally:SetAlpha(animations["pvpMarkerFlash"]["progress"])
            self.pvp.horde:SetAlpha(animations["pvpMarkerFlash"]["progress"])
        end
    )
end
GW.AddForProfiling("playerhud", "globe_OnEnter", globe_OnEnter)

local function globe_OnLeave(self)
    GameTooltip_Hide()
    AddToAnimation(
        "pvpMarkerFlash",
        1,
        0.33,
        GetTime(),
        0.5,
        function()
            self.pvp.ally:SetAlpha(animations["pvpMarkerFlash"]["progress"])
            self.pvp.horde:SetAlpha(animations["pvpMarkerFlash"]["progress"])
        end
    )
end
GW.AddForProfiling("playerhud", "globe_OnLeave", globe_OnLeave)

local function UpdateIncomingPredictionAmount(...)
    for i = 1, select("#", ...) do
        if (select(i, ...) == GWPlayerFrame.guid) and (UnitPlayerOrPetInParty(GWPlayerFrame.unit) or UnitPlayerOrPetInRaid(GWPlayerFrame.unit) or UnitIsUnit("player", GWPlayerFrame.unit) or UnitIsUnit("pet", GWPlayerFrame.unit)) then
            local amount = (HealComm:GetHealAmount(GWPlayerFrame.guid, HealComm.ALL_HEALS) or 0) * (HealComm:GetHealModifier(GWPlayerFrame.guid) or 1)
            GWPlayerFrame.healPredictionAmount = amount
            updateHealthData(GWPlayerFrame)
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

local function LoadPlayerHud()
    PlayerFrame:SetScript("OnEvent", nil)
    PlayerFrame:Hide()

    local playerHealthGLobaBg = CreateFrame("Button", "GwPlayerHealthGlobe", UIParent, "GwPlayerHealthGlobe")
    if GW.GetSetting("XPBAR_ENABLED") then
        playerHealthGLobaBg:SetPoint('BOTTOM', 0, 16)
    else
        playerHealthGLobaBg:SetPoint('BOTTOM', 2)
    end

    GwPlayerHealthGlobe.animationCurrent = 0

    playerHealthGLobaBg:EnableMouse(true)
    --  RegisterUnitWatch(playerHealthGLobaBg);

    --DELETE ME AFTER ACTIONBARS REWORK
    playerHealthGLobaBg:SetAttribute("*type1", "target")
    playerHealthGLobaBg:SetAttribute("*type2", "togglemenu")
    playerHealthGLobaBg:SetAttribute("unit", "player")

    AddToClique(playerHealthGLobaBg)

    --  RegisterUnitWatch(playerHealthGLobaBg)
    _G["GwPlayerHealthGlobeTextValue"]:SetFont(DAMAGE_TEXT_FONT, 16)
    _G["GwPlayerHealthGlobeTextValue"]:SetShadowColor(1, 1, 1, 0)

    for i = 1, 8 do
        _G["GwPlayerHealthGlobeTextShadow" .. i]:SetFont(DAMAGE_TEXT_FONT, 16)
        _G["GwPlayerHealthGlobeTextShadow" .. i]:SetShadowColor(1, 1, 1, 0)
        _G["GwPlayerHealthGlobeTextShadow" .. i]:SetTextColor(0, 0, 0, 1 / i)
    end
    _G["GwPlayerHealthGlobeTextShadow1"]:SetPoint("CENTER", -1, 0)
    _G["GwPlayerHealthGlobeTextShadow2"]:SetPoint("CENTER", 0, -1)
    _G["GwPlayerHealthGlobeTextShadow3"]:SetPoint("CENTER", 1, 0)
    _G["GwPlayerHealthGlobeTextShadow4"]:SetPoint("CENTER", 0, 1)
    _G["GwPlayerHealthGlobeTextShadow5"]:SetPoint("CENTER", -2, 0)
    _G["GwPlayerHealthGlobeTextShadow6"]:SetPoint("CENTER", 0, -2)
    _G["GwPlayerHealthGlobeTextShadow7"]:SetPoint("CENTER", 2, 0)
    _G["GwPlayerHealthGlobeTextShadow8"]:SetPoint("CENTER", 0, 2)

    playerHealthGLobaBg:SetScript("OnEvent", globe_OnEvent)
    playerHealthGLobaBg:SetScript("OnEnter", globe_OnEnter)
    playerHealthGLobaBg:SetScript("OnLeave", globe_OnLeave)

    playerHealthGLobaBg:RegisterEvent("PLAYER_ENTERING_WORLD")
    playerHealthGLobaBg:RegisterEvent("PLAYER_FLAGS_CHANGED")
    playerHealthGLobaBg:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "player")
    playerHealthGLobaBg:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    playerHealthGLobaBg:RegisterUnitEvent("UNIT_FACTION", "player")
    playerHealthGLobaBg.unit = "Player"
    playerHealthGLobaBg.guid = UnitGUID("Player")
    playerHealthGLobaBg.healPredictionAmount = 0

    --libHealComm setup
    HealComm.RegisterCallback(IncHeal, "HealComm_HealStarted", "HealComm_HealUpdated")
    HealComm.RegisterCallback(IncHeal, "HealComm_HealStopped")
    HealComm.RegisterCallback(IncHeal, "HealComm_HealDelayed", "HealComm_HealUpdated")
    HealComm.RegisterCallback(IncHeal, "HealComm_HealUpdated")
    HealComm.RegisterCallback(IncHeal, "HealComm_ModifierChanged")
    HealComm.RegisterCallback(IncHeal, "HealComm_GUIDDisappeared")
    GWPlayerFrame = playerHealthGLobaBg

    local mask = GwPlayerHealthGlobe:CreateMaskTexture()
    mask:SetTexture(186178, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetSize(105, 105)
    mask:ClearAllPoints()
    mask:SetPoint("CENTER", GwPlayerHealthGlobe, "CENTER")
    GwPlayerHealthGlobeHealth.spark:AddMaskTexture(mask)
    GwPlayerHealthGlobeHealth.spark2:AddMaskTexture(mask)
    GwPlayerHealthGlobePredictionBackdrop.spark:AddMaskTexture(mask)
    GwPlayerHealthGlobeHealth.spark.mask = mask

    updateHealthData(playerHealthGLobaBg)
    selectPvp(playerHealthGLobaBg)

    -- setup hooks for the repair icon (and disable default repair frame)
    DurabilityFrame:UnregisterAllEvents()
    DurabilityFrame:HookScript("OnShow", Self_Hide)
    DurabilityFrame:Hide()
    GwHudArtFrameRepair:SetScript("OnEvent", repair_OnEvent)
    GwHudArtFrameRepair:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    GwHudArtFrameRepair:RegisterEvent("PLAYER_ENTERING_WORLD")
    GwHudArtFrameRepair:SetScript(
        "OnEnter",
        function()
            GameTooltip:SetOwner(_G["GwHudArtFrameRepair"], "ANCHOR_CURSOR")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(GwLocalization["DAMAGED_OR_BROKEN_EQUIPMENT"], 1, 1, 1)
            GameTooltip:Show()
        end
    )
    GwHudArtFrameRepair:SetScript("OnLeave", GameTooltip_Hide)
    repair_OnEvent()

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
end
GW.LoadPlayerHud = LoadPlayerHud
