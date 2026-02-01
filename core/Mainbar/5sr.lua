local _, GW = ...

local fsrMana
local fsrEnergy
local loaded = false

local Mp5IgnoredSpells = {
    [11689] = true, -- life tap 6
    [11688] = true, -- life tap 5
    [11687] = true, -- life tap 4
    [1456] = true, -- life tap 3
    [1455] = true, -- life tap 2
    [1454] = true, -- life tap 1
    [18182] = true, -- improved life tap 1
    [18183] = true, -- improved life tap 2
}

local function fsr_OnUpdate(self, elapsed)
    self.sinceLastUpdate = (self.sinceLastUpdate or 0) + (tonumber(elapsed) or 0)
    if self.sinceLastUpdate > 0.01 then
        if self.powerType ~= Enum.PowerType.Energy and self.powerType ~= Enum.PowerType.Mana then
            return
        end

        self.CurrentValue = UnitPower("player", self.powerType)

        if self.powerType == Enum.PowerType.Mana and (not self.CurrentValue or self.CurrentValue >= UnitPowerMax("player", Enum.PowerType.Mana)) then
            self.statusBar:SetValue(0)
            return
        end

        local Now = GetTime() or 0
        if not (Now == nil) then
            local Timer = Now - self.LastTickTime

            if (self.CurrentValue > self.LastValue) or self.powerType == Enum.PowerType.Energy and (Now >= self.LastTickTime + 2) then
                self.LastTickTime = Now
            end

            if Timer > 0 then
                self.statusBar.label:SetText("")
                self.statusBar:SetMinMaxValues(0, 2)
                self.statusBar:SetValue(Timer)
                local pwcolor = GW.PowerBarColorCustom[self.powerName]
                self.statusBar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
                self.allowPowerEvent = true

                self.LastValue = self.CurrentValue
            elseif Timer < 0 then
                -- if negative, it's mp5delay
                self.statusBar:SetMinMaxValues(0, self.Mp5Delay)
                self.statusBar:SetValue(math.abs(Timer))
                self.statusBar:SetStatusBarColor(1, 1, 1)
                if self.showTimer then self.statusBar.label:SetText(string.format("%.1f", Timer * -1) .. "s") end
            end
        end
    end
end

local function fsr_OnEvent(self, event, ...)
    if event == "UPDATE_SHAPESHIFT_FORM" then
        self.form = GetShapeshiftForm()

        if self.form == 1 then --bear (Hide all bars)
            fsrMana:Hide()
            self:Hide()
        elseif self.form == 3 then  --cat (hide mana, show energy)
            -- SHow Energybar, Hide Manabar
            fsrMana:Hide()
            self:Show()
        else --human  (hide energy)
            self:Hide()
            fsrMana:Show()
        end
        self.powerType, self.powerName = UnitPowerType("player")
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:Hide()
    elseif event == "PLAYER_REGEN_DISABLED" then
        self:Show()
    end
    self.shouldShow = self:IsShown()

    if self.powerType ~= Enum.PowerType.Mana then
        return
    end

    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- Only reset the timer if we used ressource and we have mana
        local spellID = select(3, ...)
        local spellCost = false
        local costTable = GetSpellPowerCost(spellID)

        for _, costInfo in next, costTable do
            if costInfo.cost then
                spellCost = true
            end
        end

        if (self.CurrentValue < self.LastValue) and (not spellCost or Mp5IgnoredSpells[spellID]) then
            return
        end

        if spellCost and self.powerType == Enum.PowerType.Mana then
            -- reset Tickerbar and start ticker
            self.statusBar:SetValue(0)
            self.statusBar:SetMinMaxValues(0, 5)
            self.statusBar:SetStatusBarColor(1, 1, 1)

            self.LastTickTime = GetTime() + 5
            self.allowPowerEvent = false
        end
    elseif event == "UNIT_POWER_UPDATE" and self.allowPowerEvent then
        local Time = GetTime()

        self.TickValue = Time - self.LastTickTime

        if self.TickValue > 5 then
            if self.powerType == Enum.PowerType.Mana and InCombatLockdown() then
                self.TickValue = 5
            else
                self.TickValue = 2
            end
        end

        self.LastTickTime = Time
    end
end

local function createStatusbar(playerFrame)
    local fsr = CreateFrame("Frame", "GW2EnergyTicker", playerFrame and playerFrame or GwPlayerPowerBar)
    local width = playerFrame and 215 or 316

    fsr:ClearAllPoints()
    if playerFrame then
        fsr:SetPoint("LEFT", playerFrame.powerbar, "LEFT", 0, -3)
    else
        fsr:SetPoint("TOPLEFT", GwPlayerPowerBar, "TOPLEFT", 0, 2)
    end
    fsr:SetSize(width, 1)

    fsr:SetFrameStrata("MEDIUM")

    fsr.background = fsr:CreateTexture(nil, "BACKGROUND")
    fsr.background:SetSize(width, 20)
    fsr.background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg.png")

    fsr.bar = fsr:CreateTexture(nil, "BORDER")
    fsr.bar:SetSize(width, 1)
    fsr.bar:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    fsr.bar:SetPoint("LEFT", 0, 0)
    fsr.bar:SetPoint("RIGHT", fsr, "LEFT", 0, 0)

    fsr.statusBar = CreateFrame("StatusBar", nil, fsr)
    fsr.statusBar:SetSize(width - 1, 1)
    fsr.statusBar:SetPoint("LEFT", fsr, "LEFT", 0, 0)
    fsr.statusBar:SetMinMaxValues(0, 5)
    fsr.statusBar:SetValue(0)
    fsr.statusBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")

    fsr.statusBar.label = fsr.statusBar:CreateFontString(nil, "OVERLAY")
    fsr.statusBar.label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.SMALL, "", -4)
    fsr.statusBar.label:SetText("")
    fsr.statusBar.label:SetPoint("CENTER", 0, 0)
    fsr.statusBar.label:SetTextColor(1, 1, 1)

    fsr.showTimer = GW.GetSetting("PLAYER_5SR_TIMER")
    fsr.mp5StartTime = 0

    fsr.LastTickTime = GetTime()
    fsr.CurrentValue = UnitPower("player")
    fsr.LastValue = fsr.CurrentValue
    fsr.TickValue = 2
    fsr.Mp5Delay = 5
    fsr.allowPowerEvent = true
    fsr.form = GetShapeshiftForm()

    return fsr
end

local function Update5SrHot()
    local hide_ofc = GW.GetSetting("PLAYER_ENERGY_MANA_TICK_HIDE_OFC")

    if hide_ofc then
        if fsrMana then
            fsrMana:RegisterEvent("PLAYER_REGEN_DISABLED")
            fsrMana:RegisterEvent("PLAYER_REGEN_ENABLED")
        end

        if fsrEnergy then
            fsrEnergy:RegisterEvent("PLAYER_REGEN_DISABLED")
            fsrEnergy:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
    else
        if fsrMana then
            fsrMana:UnregisterEvent("PLAYER_REGEN_DISABLED")
            fsrMana:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end

        if fsrEnergy then
            fsrEnergy:UnregisterEvent("PLAYER_REGEN_DISABLED")
            fsrEnergy:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end

        if fsrMana then fsrMana:Show() end
        if fsrEnergy then fsrEnergy:Show() end
    end

    if not InCombatLockdown() and hide_ofc then
        if fsrMana then fsrMana:Hide() end
        if fsrEnergy then fsrEnergy:Hide() end
    end

    if fsrMana then
        fsrMana.showTimer = GW.GetSetting("PLAYER_5SR_TIMER")
    end

    if fsrEnergy then
        fsrEnergy.showTimer = GW.GetSetting("PLAYER_5SR_TIMER")
    end
end
GW.Update5SrHot = Update5SrHot

local function Load5SR(playerFrame)
    if loaded then return end
    loaded = true
    local powerType, powerName = UnitPowerType("player")
    -- Setup bar
    fsrMana = createStatusbar(playerFrame)

    fsrMana:SetScript("OnEvent", fsr_OnEvent)
    fsrMana:SetScript("OnUpdate", fsr_OnUpdate)
    fsrMana:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    fsrMana:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")

    fsrMana.powerType = GW.myclass == "DRUID" and Enum.PowerType.Mana or powerType
    fsrMana.powerName = GW.myclass == "DRUID" and "MANA" or powerName

    -- if class is DRUID we need a secound statusbar and eventhandler for energybar
    if GW.myclass == "DRUID" then
        fsrEnergy = createStatusbar(playerFrame)
        fsrEnergy:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
        fsrEnergy:SetScript("OnEvent", fsr_OnEvent)
        fsrEnergy:SetScript("OnUpdate", fsr_OnUpdate)
        fsrEnergy:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")

        fsrEnergy.powerType = Enum.PowerType.Energy
        fsrEnergy.powerName = "ENERGY"

        if powerType == Enum.PowerType.Mana then
            fsrEnergy:Hide()
        elseif powerType == Enum.PowerType.Energy then
            fsrMana:Hide()
        else
            fsrEnergy:Hide()
            fsrMana:Hide()
        end
    end

    Update5SrHot()
end
GW.Load5SR = Load5SR