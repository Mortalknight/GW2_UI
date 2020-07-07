local _, GW = ...

local LastTickTime = GetTime()
local CurrentValue = UnitPower("player")
local LastValue = CurrentValue
local TickValue = 2
local Mp5Delay = 5
local allowPowerEvent = true
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
        local powerType, powerName = UnitPowerType("player")

        if powerType ~= Enum.PowerType.Energy and powerType ~= Enum.PowerType.Mana then
            return
        end

        CurrentValue = UnitPower("player", powerType)

        if powerType == Enum.PowerType.Mana and (not CurrentValue or CurrentValue >= UnitPowerMax("player", Enum.PowerType.Mana)) then
            self.statusBar:SetValue(0)
            return
        end

        local Now = GetTime() or 0
        if not (Now == nil) then
            local Timer = Now - LastTickTime

            if (CurrentValue > LastValue) or powerType == Enum.PowerType.Energy and (Now >= LastTickTime + 2) then
                LastTickTime = Now
            end

            if Timer > 0 then
                self.statusBar.label:SetText("")
                self.statusBar:SetMinMaxValues(0, 2)
                self.statusBar:SetValue(Timer)
                local pwcolor = GW.PowerBarColorCustom[powerName]
                self.statusBar:SetStatusBarColor(pwcolor.r, pwcolor.g, pwcolor.b)
                allowPowerEvent = true

                LastValue = CurrentValue
            elseif Timer < 0 then
                -- if negative, it's mp5delay
                self.statusBar:SetMinMaxValues(0, Mp5Delay)
                self.statusBar:SetValue(math.abs(Timer))
                self.statusBar:SetStatusBarColor(1, 1, 1)
                if self.showTimer then self.statusBar.label:SetText(string.format("%.1f", Timer * -1) .. "s") end
            end
        end
    end
end

local function fsr_OnEvent(self, event, ...)
    local powerType = UnitPowerType("player")

    if powerType ~= Enum.PowerType.Mana then
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

        if (CurrentValue < LastValue) and (not spellCost or Mp5IgnoredSpells[spellID]) then
            return
        end
        
        if spellCost and powerType == Enum.PowerType.Mana then
            -- reset Tickerbar and start ticker
            self.statusBar:SetValue(0)
            self.statusBar:SetMinMaxValues(0, 5)
            self.statusBar:SetStatusBarColor(1, 1, 1)

            LastTickTime = GetTime() + 5
            allowPowerEvent = false
        end
    elseif event == "UNIT_POWER_UPDATE" and allowPowerEvent then
        local Time = GetTime()

        TickValue = Time - LastTickTime

        if TickValue > 5 then
            if powerType == Enum.PowerType.Mana and InCombatLockdown() then
                TickValue = 5
            else
                TickValue = 2
            end
        end

        LastTickTime = Time
    end
end

local function fsrHelperFrame_OnEvent(self, event, ...)
    local form = GetShapeshiftForm()

    if form == 1 then
        self:GetParent():Hide()
    elseif form == 3 then
        self:GetParent().statusBar:SetValue(0)
        allowPowerEvent = true
    else
        self:GetParent():Show()
    end
end

local function load5SR()
    local fsr = CreateFrame("Frame", nil, GwPlayerPowerBar, "GW5SRTemp")
    fsr:SetSize(316, 1)
    fsr.statusBar:SetMinMaxValues(0, 5)
    fsr:ClearAllPoints()
    fsr:SetPoint("TOPLEFT", "GwPlayerPowerBar", "TOPLEFT", 2, 1)
    fsr:SetFrameStrata("MEDIUM")
    fsr.statusBar.label:SetFont(DAMAGE_TEXT_FONT, 8)

    fsr.statusBar:SetValue(0)
    fsr.showTimer = GW.GetSetting("PLAYER_5SR_TIMER")
    fsr.mp5StartTime = 0
    fsr.showTick = GW.GetSetting("PLAYER_5SR_MANA_TICK")

    fsr:SetScript("OnEvent", fsr_OnEvent)
    fsr:SetScript("OnUpdate", fsr_OnUpdate)
    fsr:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    fsr:RegisterEvent("UNIT_POWER_UPDATE")

    fsr.shapeshiftformHelper:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    fsr.shapeshiftformHelper:SetScript("OnEvent", fsrHelperFrame_OnEvent)
end
GW.load5SR = load5SR