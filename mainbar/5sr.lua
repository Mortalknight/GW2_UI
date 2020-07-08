local _, GW = ...

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
    local now = GetTime()

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
            if powerType == Enum.PowerType.Mana and InCombatLockdown() then
                self.TickValue = 5
            else
                self.TickValue = 2
            end
        end

        self.LastTickTime = Time
    end
end

local function fsrHelperFrame_OnEvent(self, event, ...)
    local form = GetShapeshiftForm()

    if form == 1 then
        self:GetParent():Hide()
    elseif form == 3 then
        self:GetParent().statusBar:SetValue(0)
        self:GetParent().allowPowerEvent = true
    else
        self:GetParent():Show()
    end

    self:GetParent().powerType, self:GetParent().powerName = UnitPowerType("player")
end

local function load5SR()
    -- Setup bar
    local fsr = CreateFrame("Frame", nil, _G.GwPlayerPowerBar)
    fsr:SetSize(316, 1)
    fsr:ClearAllPoints()
    fsr:SetPoint("TOPLEFT", "GwPlayerPowerBar", "TOPLEFT", 2, 1)
    fsr:SetFrameStrata("MEDIUM")

    fsr.background = fsr:CreateTexture(nil, "BACKGROUND")
    fsr.background:SetSize(316, 20)
    fsr.background:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")

    fsr.bar = fsr:CreateTexture(nil, "BORDER")
    fsr.bar:SetSize(316, 1)
    fsr.bar:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar")
    fsr.bar:SetPoint("LEFT", 0, 0)
    fsr.bar:SetPoint("RIGHT", fsr, "LEFT", 0, 0)

    fsr.statusBar = CreateFrame("StatusBar", nil, fsr)
    fsr.statusBar:SetSize(315, 1)
    fsr.statusBar:SetPoint("LEFT", fsr, "LEFT", 0, 0)
    fsr.statusBar:SetMinMaxValues(0, 5)
    fsr.statusBar:SetValue(0)
    fsr.statusBar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar")

    fsr.statusBar.label = fsr.statusBar:CreateFontString(nil, "OVERLAY")
    fsr.statusBar.label:SetFont(DAMAGE_TEXT_FONT, 8)
    fsr.statusBar.label:SetText("")
    fsr.statusBar.label:SetPoint("CENTER", fsr.statusBar, "CENTER", 0, 0)
    fsr.statusBar.label:SetTextColor(1, 1, 1)

    fsr.shapeshiftformHelper = CreateFrame("Frame")

    fsr.showTimer = GW.GetSetting("PLAYER_5SR_TIMER")
    fsr.mp5StartTime = 0
    fsr.showTick = GW.GetSetting("PLAYER_5SR_MANA_TICK")

    fsr.LastTickTime = GetTime()
    fsr.CurrentValue = UnitPower("player")
    fsr.LastValue = fsr.CurrentValue
    fsr.TickValue = 2
    fsr.Mp5Delay = 5
    fsr.allowPowerEvent = true
    fsr.powerType, fsr.powerName = UnitPowerType("player")

    fsr:SetScript("OnEvent", fsr_OnEvent)
    fsr:SetScript("OnUpdate", fsr_OnUpdate)
    fsr:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    fsr:RegisterEvent("UNIT_POWER_UPDATE")

    fsr.shapeshiftformHelper:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    fsr.shapeshiftformHelper:SetScript("OnEvent", fsrHelperFrame_OnEvent)
end
GW.load5SR = load5SR