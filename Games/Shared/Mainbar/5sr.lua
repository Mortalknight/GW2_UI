---@class GW2
local GW = select(2, ...)

local fsrMana
local fsrEnergy
local loaded = false

local TICK_DELAY = 2.025 -- the average tick is slightly over 2 seconds
local MP5_DELAY = 5

-- 1 below full power and 0 at full, so the secret power value never reaches lua
local fullPowerCurve = C_CurveUtil.CreateCurve()
fullPowerCurve:SetType(Enum.LuaCurveType.Step)
fullPowerCurve:AddPoint(0, 1)
fullPowerCurve:AddPoint(1, 0)

-- moves the last tick to the latest point of the tick cycle
local function SyncTickTime(self, now)
    self.lastTickTime = now - ((now - self.lastTickTime) % TICK_DELAY)
end

local function fsr_OnUpdate(self, elapsed)
    self.sinceLastUpdate = self.sinceLastUpdate + elapsed
    if self.sinceLastUpdate < 0.05 then return end
    self.sinceLastUpdate = 0

    local now = GetTime()
    -- a power update is a tick when no cast cost follows within a moment
    if self.pendingTickTime and now - self.pendingTickTime > 0.1 then
        self.lastTickTime = self.pendingTickTime
        self.pendingTickTime = nil
    end

    local alpha = 1
    if self.powerType == Enum.PowerType.Mana then
        alpha = UnitPowerPercent("player", Enum.PowerType.Mana, true, fullPowerCurve)
        if self.mp5DelayEnd and self.mp5DelayEnd < now then
            self.mp5DelayEnd = nil
            SyncTickTime(self, now)
        end
    elseif now >= self.lastTickTime + TICK_DELAY then
        -- full energy fires no power updates, keep the cycle going
        SyncTickTime(self, now)
    end

    local bar = self.statusBar
    local r, g, b
    if self.mp5DelayEnd then
        local remaining = self.mp5DelayEnd - now
        bar:SetMinMaxValues(0, MP5_DELAY)
        bar:SetValue(remaining)
        bar.label:SetText(self.showTimer and format("%.1fs", remaining) or "")
        r, g, b = GW.Colors.FallbackWhite:GetRGB()
    else
        bar:SetMinMaxValues(0, TICK_DELAY)
        bar:SetValue(now - self.lastTickTime)
        bar.label:SetText("")
        local color = GW.Colors.PowerBarCustomColors[self.powerName]
        r, g, b = color.r, color.g, color.b
    end
    bar:GetStatusBarTexture():SetVertexColor(r, g, b, alpha)
end

-- shown while the player uses its power type, the druid bars follow the form
local function UpdateShown(self, inCombat)
    if inCombat == nil then inCombat = InCombatLockdown() end
    local hideOutOfCombat = GW.settings.unitframes.player.energyManaTickHideOutOfCombat
    self:SetShown(UnitPowerType("player") == self.powerType and (inCombat or not hideOutOfCombat))
end

local function fsr_OnEvent(self, event, ...)
    if event == "UNIT_POWER_UPDATE" then
        local _, powerToken = ...
        -- a power update right after a cast cost is not a tick
        local now = GetTime()
        if powerToken == self.powerName and now - self.lastCastTime > 0.1 then
            self.pendingTickTime = now
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local spellID = select(3, ...)
        local costs = GW.NotSecretValue(spellID) and C_Spell.GetSpellPowerCost(spellID)
        if not costs then return end

        for _, costInfo in ipairs(costs) do
            if costInfo.type == self.powerType and costInfo.cost and costInfo.cost > 0 then
                -- the power update of this cost comes just before or right after
                self.lastCastTime = GetTime()
                self.pendingTickTime = nil
                if self.powerType == Enum.PowerType.Mana then
                    self.mp5DelayEnd = self.lastCastTime + MP5_DELAY
                end
            end
        end
    elseif event == "UNIT_DISPLAYPOWER" then
        UpdateShown(self)
    elseif event == "PLAYER_REGEN_DISABLED" then
        UpdateShown(self, true)
    elseif event == "PLAYER_REGEN_ENABLED" then
        UpdateShown(self, false)
    end
end

local function UpdateWidth(self, width)
    self:SetSize(width, 1)
    self.background:SetSize(width, 20)
    self.bar:SetSize(width, 1)
    self.statusBar:SetSize(width - 1, 1)
end

local function createStatusbar(name, playerFrame, powerType, powerName)
    local fsr = CreateFrame("Frame", name, playerFrame or GwPlayerPowerBar)
    local width = playerFrame and GW.settings.unitframes.player.healthBarSize.width or 316

    fsr:SetPoint("TOPLEFT", playerFrame and playerFrame.powerbar or GwPlayerPowerBar, "BOTTOMLEFT", 0, -2)
    fsr:SetSize(width, 1)
    fsr:SetFrameStrata("MEDIUM")

    fsr.background = fsr:CreateTexture(nil, "BACKGROUND")
    fsr.background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg.png")

    fsr.bar = fsr:CreateTexture(nil, "BORDER")
    fsr.bar:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    fsr.bar:SetPoint("LEFT", 0, 0)
    fsr.bar:SetPoint("RIGHT", fsr, "LEFT", 0, 0)

    fsr.statusBar = CreateFrame("StatusBar", nil, fsr)
    fsr.statusBar:SetPoint("LEFT", fsr, "LEFT", 0, 0)
    fsr.statusBar:SetMinMaxValues(0, MP5_DELAY)
    fsr.statusBar:SetValue(0)
    fsr.statusBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")

    fsr.statusBar.label = fsr.statusBar:CreateFontString(nil, "OVERLAY")
    fsr.statusBar.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Small, "", -4)
    fsr.statusBar.label:SetPoint("CENTER", 0, 0)
    fsr.statusBar.label:SetTextColor(1, 1, 1)

    fsr.powerType = powerType
    fsr.powerName = powerName
    fsr.lastTickTime = GetTime()
    fsr.lastCastTime = 0
    fsr.sinceLastUpdate = 0
    fsr.UpdateWidth = UpdateWidth
    fsr:UpdateWidth(width)

    fsr:SetScript("OnEvent", fsr_OnEvent)
    fsr:SetScript("OnUpdate", fsr_OnUpdate)
    fsr:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    fsr:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    fsr:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
    fsr:RegisterEvent("PLAYER_REGEN_DISABLED")
    fsr:RegisterEvent("PLAYER_REGEN_ENABLED")

    return fsr
end

local function Update5SrHot()
    for _, fsr in ipairs({fsrMana, fsrEnergy}) do
        fsr.showTimer = GW.settings.unitframes.player.fiveSecondRuleTimer
        UpdateShown(fsr)
    end
end
GW.Update5SrHot = Update5SrHot

local function Load5SR(playerFrame)
    if loaded then return end
    loaded = true

    local powerType, powerName = UnitPowerType("player")
    if GW.myclass == "DRUID" then
        fsrMana = createStatusbar("Gw2ManaTicker", playerFrame, Enum.PowerType.Mana, "MANA")
        fsrEnergy = createStatusbar("Gw2EnergyTicker", playerFrame, Enum.PowerType.Energy, "ENERGY")
    elseif powerType == Enum.PowerType.Mana or powerType == Enum.PowerType.Energy then
        fsrMana = createStatusbar("Gw2ManaTicker", playerFrame, powerType, powerName)
    else
        return -- rage and runic power have no ticks
    end

    if playerFrame then
        playerFrame.fsrMana = fsrMana
        playerFrame.fsrEnergy = fsrEnergy
    end

    Update5SrHot()
end
GW.Load5SR = Load5SR
