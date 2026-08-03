---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- DRUID (combo/mana per form, eclipse on Mists)
if GW.myClassID ~= GW.Enum.ClassIndex.Druid then return end

local function powerEclipsOnUpdate(self)
    local pwrMax = UnitPowerMax(self.unit, Enum.PowerType.Balance)
    local pwr = UnitPower(self.unit, Enum.PowerType.Balance)
    if self.oldEclipsPower == pwr then
        return
    end

    GW.AddToAnimation(
        "ECLIPS_BAR",
        self.oldEclipsPower,
        pwr,
        GetTime(),
        0.2,
        function(p)
            local pwrP = p / pwrMax
            local pwrAbs = math.abs(p) / pwrMax
            local segmentSize = self.eclips:GetWidth() / 2
            local arrowPosition = segmentSize * pwrP

            local clampedArrowPosition = math.max(math.min(arrowPosition, segmentSize - 9), -segmentSize + 9)
            self.eclips.arrow:SetPoint("CENTER", self.background, "CENTER", clampedArrowPosition, 0)
            self.eclips.fill:ClearAllPoints()
            if p > 0 then
                self.eclips.fill:SetPoint("LEFT", self.background, "CENTER", 0, 0)
                self.eclips.fill:SetPoint("RIGHT", self.background, "CENTER", arrowPosition, 0)
                self.eclips.fill:SetTexCoord(0, math.max(0, math.min(pwrAbs, 1)), 0, 1)
            else
                self.eclips.fill:SetPoint("LEFT", self.background, "CENTER", arrowPosition, 0)
                self.eclips.fill:SetPoint("RIGHT", self.background, "CENTER", 0, 0)
                self.eclips.fill:SetTexCoord(0, math.max(0, math.min(pwrAbs, 1)), 0, 1)
            end
            self.oldEclipsPower = p
        end
    )
end

local function eclipsUnitAura()
    local hasLunarEclipse = CP.GetAuraData("player", nil, "HELPFUL", ECLIPSE_BAR_LUNAR_BUFF_ID) ~= nil
    local hasSolarEclipse = CP.GetAuraData("player", nil, "HELPFUL", ECLIPSE_BAR_SOLAR_BUFF_ID) ~= nil
    if hasLunarEclipse then
        CP.frame.eclips.lunar:Show()
        CP.frame.eclips.solar:Hide()
    elseif hasSolarEclipse then
        CP.frame.eclips.lunar:Hide()
        CP.frame.eclips.solar:Show()
    else
        CP.frame.eclips.lunar:Hide()
        CP.frame.eclips.solar:Hide()
    end
end

local function powerEclips(self, event, ...)
    if event == "ECLIPSE_DIRECTION_CHANGE" then
        local direction = ...
        if direction == "sun" then
            self.eclips.arrow:SetTexCoord(0, 1, 0, 1)
        elseif direction == "moon" then
            self.eclips.arrow:SetTexCoord(1, 0, 0, 1)
        else
            self.eclips.lunar:Hide()
            self.eclips.solar:Hide()
        end
    elseif event == "UNIT_AURA" then
        CP.HandleUnitAuraEvent(...)
    elseif event == "CLASS_POWER_INIT" then
        eclipsUnitAura()
        powerEclipsOnUpdate(self)
    end
end

local function setEclips(f)
    f.barType = "eclips"
    f.eclips:Show()
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)

    f:SetScript("OnUpdate", powerEclipsOnUpdate)
    f:SetScript("OnEvent", powerEclips)
    powerEclips(f, "CLASS_POWER_INIT")

    f:RegisterUnitEvent("UNIT_AURA", "player")
    f:RegisterEvent("ECLIPSE_DIRECTION_CHANGE")
    EventRegistry:RegisterCallback("GW2_UI.ClasspowerPlayerUnitAura", eclipsUnitAura, "GW2_UI")
end

-- DRUID
local function setDruid(f)
    local form = f.gwPlayerForm
    local barType = "none"

    if GW.Retail then
        if GW.myspec == 1 then -- balance
            if form == 1 then
                -- if in cat form, show combo points
                barType = "combo|little_mana"
            elseif form ~= 4 and form ~= 29 and form ~= 27 and form ~= 3 then
                -- show mana bar by default except in travel forms
                barType = "mana"
            end
        elseif GW.myspec == 2 then -- feral
            if form == 1 then
                -- show combo points and little mana bar in cat form
                barType = "combo|little_mana"
            --elseif form == 5 then
                -- show mana bar in bear form
                --barType = "mana"
            end
        elseif GW.myspec == 3 then -- guardian
            if form == 1 then
                -- show combo points in cat form
                barType = "combo|little_mana"
            --elseif form == 5 then
                -- show mana in bear form
                --barType = "mana"
            end
        elseif GW.myspec == 4 then -- resto
            if form == 1 then
                -- show combo points in cat form
                barType = "combo|little_mana"
            elseif form == 5 then
                -- show mana in bear form
                barType = "mana"
            end
        end
    elseif GW.Mists then
        if GW.myspec == 1 and form == nil then
            barType = "eclips"
        end
        if form == CAT_FORM then                   -- cat
            barType = "combo|little_mana"
        elseif form == BEAR_FORM or form == 8 then --bear
            barType = "little_mana"
        elseif form == MOONKIN_FORM then           --Moonkin
            barType = "eclips"
        end
    elseif GW.Classic or GW.TBC or GW.Wrath then
        if form == CAT_FORM then                   -- cat
            barType = "combo|little_mana"
        elseif form == BEAR_FORM or form == 8 then --bear
            barType = "little_mana"
        end
    end

    if barType == "combo" then
        CP.setComboBar(f)
        return true
    elseif barType == "mana" then
        CP.setManaBar(f)
        return true
    elseif barType == "little_mana" and GW.settings.POWERBAR_ENABLED then -- classic
        CP.setLittleManaBar(f, "combo")
        return true
    elseif barType == "combo|little_mana" then
        CP.setComboBar(f)
        if GW.settings.POWERBAR_ENABLED then
            CP.setLittleManaBar(f, "combo")
        end
        return true
    elseif barType == "eclips" then
        setEclips(f)
        return true
    else
        return false
    end
end

CP.setups[GW.Enum.ClassIndex.Druid] = setDruid
