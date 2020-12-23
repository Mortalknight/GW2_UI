local _, GW = ...
local lerp = GW.lerp
local GetSetting = GW.GetSetting
local TimeCount = GW.TimeCount
local RegisterMovableFrame = GW.RegisterMovableFrame
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local StopAnimation = GW.StopAnimation
local IsIn = GW.IsIn

local function barValues(self, name, icon, spellid)
    self.name:SetText(name)
    self.icon:SetTexture(icon)
    self.latency:Show()
    self.spellId = spellid
end
GW.AddForProfiling("castingbar", "barValues", barValues)

local function barReset(self)
    if animations[self:GetName()] then
        animations[self:GetName()]["completed"] = true
        animations[self:GetName()]["duration"] = 0
    end
end
GW.AddForProfiling("castingbar", "barReset", barReset)

local function castBar_OnEvent(self, event, unitID, spellid)
    local castingType = 1
    local spell, icon, startTime, endTime
    local unit = self.unit

    if event == "PLAYER_ENTERING_WORLD" then
        local nameChannel = UnitChannelInfo(unit)
        local nameSpell = UnitCastingInfo(unit)
        if nameChannel then
            event = "UNIT_SPELLCAST_CHANNEL_START"
            unitID = unit
        elseif nameSpell then
            event = "UNIT_SPELLCAST_START"
            unitID = unit
        else
            barReset(self)
        end
    end

    if unitID ~= unit or not self.showCastbar then
        return
    end
    if IsIn(event, "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_DELAYED") then
        if IsIn(event, "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE") then
            spell, _, icon, startTime, endTime = UnitChannelInfo(unitID)
            castingType = 2
        else
            spell, _, icon, startTime, endTime = UnitCastingInfo(unitID)
        end

        if GetSetting("CASTINGBAR_DATA") then
            barValues(self, spell, icon, spellid)
        end

        startTime = startTime / 1000
        endTime = endTime / 1000
        barReset(self)
        self.spark:Show()
        StopAnimation(self:GetName())
        AddToAnimation(
            self:GetName(),
            0,
            1,
            startTime,
            endTime - startTime,
            function()
                if GetSetting("CASTINGBAR_DATA") then
                    self.time:SetText(TimeCount(endTime - GetTime(), true))
                end

                local p = animations[self:GetName()]["progress"]
                self.latency:ClearAllPoints()
                self.latency:SetPoint("RIGHT", self, "RIGHT")
                if castingType == 2 then
                    p = 1 - animations[self:GetName()]["progress"]
                    self.latency:ClearAllPoints()
                    self.latency:SetPoint("LEFT", self, "LEFT")
                end

                self.bar:SetWidth(math.max(1, p * 176))
                self.bar:SetVertexColor(1, 1, 1, 1)

                self.spark:SetWidth(math.min(15, math.max(1, p * 176)))
                self.bar:SetTexCoord(0, p, 0.25, 0.5)

                local _, _, _, lagWorld = GetNetStats()
                lagWorld = lagWorld / 1000
                self.latency:SetWidth(math.min(1, (lagWorld / (endTime - startTime))) * 176)
            end,
            "noease"
        )

        if self.isCasting ~= 1 then
            UIFrameFadeIn(self, 0.1, 0, 1)
        end
        self.isCasting = 1
    elseif IsIn(event, "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP") then
        if self.animating == nil or self.animating == false then
            UIFrameFadeOut(self, 0.2, 1, 0)
        end
        barReset(self)
        self.isCasting = 0
    elseif IsIn(event, "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED") then
        barReset(self)
        self.isCasting = 0
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and self.spellId == spellid then
        self.animating = true
        self.bar:SetTexCoord(0, 1, 0.5, 0.75)
        self.bar:SetWidth(176)
        self.spark:Hide()
        AddToAnimation(
            self:GetName() .. "Complete",
            0,
            1,
            GetTime(),
            0.2,
            function()
                self.bar:SetVertexColor(
                    1,
                    1,
                    1,
                    lerp(1, 0.7, animations[self:GetName() .. "Complete"]["progress"])
                )
            end,
            nil,
            function()
                self.animating = false
                if self.isCasting == 0 then
                    if self:GetAlpha() > 0 then
                        UIFrameFadeOut(self, 0.2, 1, 0)
                    end
                end
            end
        )
    end
end

local function petCastBar_OnEvent(self, event, unit, spellID)
	if event == "UNIT_PET" then
		if unit == "player" then
			self.showCastbar = UnitIsPossessed("pet")

			if not self.showCastbar then
				self:Hide();
			elseif self.casting or self.channeling then
				self:Show()
			end
		end
		return
	end
	castBar_OnEvent(self, event, unit, spellID)
end

local function LoadCastingBar(castingBarType, name, unit)
    castingBarType:Kill()

    local GwCastingBar = CreateFrame("Frame", name, UIParent, "GwCastingBar")
    GwCastingBar.latency:Hide()
    GwCastingBar.name:SetFont(UNIT_NAME_FONT, 12)
    GwCastingBar.name:SetShadowOffset(1, -1)
    GwCastingBar.time:SetFont(UNIT_NAME_FONT, 12)
    GwCastingBar.time:SetShadowOffset(1, -1)
    GwCastingBar.spark:ClearAllPoints()
    GwCastingBar.spark:SetPoint("RIGHT", GwCastingBar.bar, "RIGHT")

    GwCastingBar:SetAlpha(0)

    GwCastingBar.unit = unit
    GwCastingBar.showCastbar = true
    GwCastingBar.isCasting = 0

    if name == "GwCastingBarPlayer" then
        RegisterMovableFrame(GwCastingBar, SHOW_ARENA_ENEMY_CASTBAR_TEXT, "castingbar_pos", "GwCastFrameDummy", nil, nil, {"scaleable"})
        GwCastingBar:ClearAllPoints()
        GwCastingBar:SetPoint("TOPLEFT", GwCastingBar.gwMover)
    else
        GwCastingBar:ClearAllPoints()
        GwCastingBar:SetPoint("TOPLEFT", GwCastingBarPlayer.gwMover)
    end

    GwCastingBar:SetScript("OnEvent", unit == "pet" and petCastBar_OnEvent or castBar_OnEvent)

    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    GwCastingBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    GwCastingBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
    if unit == "pet" then
        GwCastingBar:RegisterEvent("UNIT_PET")
        GwCastingBar.showCastbar = UnitIsPossessed(unit)
    end
end
GW.LoadCastingBar = LoadCastingBar
