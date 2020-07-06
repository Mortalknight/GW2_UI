local _, GW = ...
local IsIn = GW.IsIn

local function fsr_OnUpdate(self)
    local now = GetTime()
    local power = UnitPower("player")

    if self.mp5StartTime > 0 then
        local remaining = (self.mp5StartTime - now - 5) * -1

        if remaining <= 5 then
            self.statusBar:SetValue(remaining)

            if self.showTimer then
                self.statusBar.label:SetText(string.format("%.1f", remaining).."s")
            end
        else
            self:SetScript("OnUpdate", nil)
            self.statusBar.label:SetText("")
        end
    end
end

local function fsr_OnEvent(self, event, ...)
    if IsIn(event, "PLAYER_ENTERING_WORLD", "PLAYER_EQUIPMENT_CHANGED") then
        self.previousPower = UnitPower("player")
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- Only reset the timer if we used ressource and we have mana
        if UnitPower("player") < self.previousPower and UnitPowerType("player") == 0 then
            -- save new mana value
            self.previousPower = UnitPower("player")
            -- save mp5 startTimer
            self.mp5StartTime = GetTime() + 5

            -- reset Tickerbar and start ticker
            self.statusBar:SetValue(0)
            self:SetScript("OnUpdate", fsr_OnUpdate)
        else
            self:SetScript("OnUpdate", nil)
        end
    elseif event == "UPDATE_SHAPESHIFT_FORM" then
        if UnitPowerType("player") == 0 then
            self:Show()
        else
            self:Hide()
        end
    end
end

local function load5SR()
    local fsr = CreateFrame("Frame", nil, GwPlayerPowerBar, "GwPlayerPowerBar")
    fsr:SetSize(GwPlayerPowerBar:GetWidth(), 5)
    fsr.bar:SetHeight(1)
    fsr.candy:Hide()
    fsr.statusBar:SetHeight(1)
    fsr.statusBar:SetMinMaxValues(0, 5)
    fsr:ClearAllPoints()
    fsr:SetPoint("TOPLEFT", "GwPlayerPowerBar", "TOPLEFT", 2, 5)
    fsr:SetWidth(316)
    fsr:SetFrameStrata("MEDIUM")
    fsr.statusBar.label:SetFont(DAMAGE_TEXT_FONT, 8)

    fsr.statusBar:SetValue(0)
    fsr.statusBar.label:SetText("")
    fsr.showTimer = GW.GetSetting("PLAYER_5SR_TIMER")
    fsr.mp5StartTime = 0
    fsr.previousPower = 0

    fsr:SetScript("OnEvent", fsr_OnEvent)
    fsr:RegisterEvent("PLAYER_ENTERING_WORLD")
    fsr:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    fsr:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    fsr:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    fsr.checkPowerValue = C_Timer.NewTicker(0.3, function()
        fsr.previousPower = UnitPower("player")
    end)
end
GW.load5SR = load5SR