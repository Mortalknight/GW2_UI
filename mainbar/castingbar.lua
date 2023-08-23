local _, GW = ...
local lerp = GW.lerp
local GetSetting = GW.GetSetting
local TimeCount = GW.TimeCount
local RegisterMovableFrame = GW.RegisterMovableFrame
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local StopAnimation = GW.StopAnimation
local IsIn = GW.IsIn

local function barValues(self, name, icon)
    self.name:SetText(name)
    self.icon:SetTexture(icon)
    self.latency:Show()
end
GW.AddForProfiling("castingbar", "barValues", barValues)

local function barReset(self)
    if animations[self.animationName] then
        animations[self.animationName].completed = true
        animations[self.animationName].duration = 0
    end
end
GW.AddForProfiling("castingbar", "barReset", barReset)

local function castBar_OnEvent(self, event, unitID, ...)
    local isChannelCast = false
    local spell, icon, startTime, endTime, isTradeSkill, spellID

    if event == "PLAYER_ENTERING_WORLD" then
        local nameChannel = UnitChannelInfo(self.unit)
        local nameSpell = UnitCastingInfo(self.unit)
        if nameChannel then
            event = "UNIT_SPELLCAST_CHANNEL_START"
        elseif nameSpell then
            event = "UNIT_SPELLCAST_START"
        else
            barReset(self)
        end
    end

    if unitID ~= self.unit or not self.showCastbar then
        return
    end

    if IsIn(event, "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_DELAYED") then
        if IsIn(event, "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE") then
            spell, _, icon, startTime, endTime, isTradeSkill, spellID = UnitChannelInfo(self.unit)
            isChannelCast = true
            self.isChanneling = true
            self.bar_r, self.bar_g, self.bar_b, self.bar_a = 0.2, 1, 0.7, 1
            self.bar:SetVertexColor(self.bar_r, self.bar_g, self.bar_b, self.bar_a)
        else
            spell, _, icon, startTime, endTime, isTradeSkill, _, spellID = UnitCastingInfo(self.unit)
            self.bar_r, self.bar_g, self.bar_b, self.bar_a = 1, 1, 1, 1
            self.bar:SetVertexColor(self.bar_r, self.bar_g, self.bar_b, self.bar_a)
            self.isChanneling = false
        end

        if not spell or (not self.showTradeSkills and isTradeSkill) then
            barReset(self)
            return
        end

        if self.showDetails then
            barValues(self, spell, icon)
        end

        self.spellID = spellID
        self.startTime = startTime / 1000
        self.endTime = endTime / 1000
        barReset(self)
        self.spark:Show()
        StopAnimation(self.animationName)
        AddToAnimation(
            self.animationName,
            0,
            1,
            self.startTime,
            self.endTime - self.startTime,
            function()
                if self.showDetails then
                    self.time:SetText(TimeCount(self.endTime - GetTime(), true))
                end

                local p = isChannelCast and (1 - animations[self.animationName].progress) or animations[self.animationName].progress
                self.latency:ClearAllPoints()
                self.latency:SetPoint(isChannelCast and "LEFT" or "RIGHT", self, isChannelCast and "LEFT" or "RIGHT")

                self.bar:SetWidth(math.max(1, p * 176))
                self.bar:SetVertexColor(self.bar_r, self.bar_g, self.bar_b, self.bar_a)
                self.spark:SetWidth(math.min(15, math.max(1, p * 176)))
                self.bar:SetTexCoord(0, p, 0.25, 0.5)

                local lagWorld = select(4, GetNetStats()) / 1000
                self.latency:SetWidth(math.max(0.0001, math.min(1, (lagWorld / (self.endTime - self.startTime)))) * 176)
            end,
            "noease"
        )

        if not self.isCasting then
            UIFrameFadeIn(self, 0.1, 0, 1)
        end
        self.isCasting = true
    elseif IsIn(event, "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP") then
        if self.animating == nil or self.animating == false then
            UIFrameFadeOut(self, 0.2, 1, 0)
        end
        barReset(self)
        self.isCasting = false
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        barReset(self)
        self.isCasting = false
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and self.spellID == select(2, ...) and not self.isChanneling then
        self.animating = true
        self.bar:SetTexCoord(0, 1, 0.5, 0.75)
        self.bar:SetWidth(176)
        self.spark:Hide()
        AddToAnimation(
            self.animationName .. "Complete",
            0,
            1,
            GetTime(),
            0.2,
            function()
                self.bar:SetVertexColor(self.bar_r, self.bar_g, self.bar_b, lerp(1, 0.7, animations[self.animationName .. "Complete"].progress))
            end,
            nil,
            function()
                self.animating = false
                if not self.isCasting then
                    if self:GetAlpha() > 0 then
                        UIFrameFadeOut(self, 0.2, 1, 0)
                    end
                end
            end
        )
    end
end

local function petCastBar_OnEvent(self, event, unit, ...)
    if event == "UNIT_PET" then
        if unit == "player" then
            self.showCastbar = UnitIsPossessed("pet")
        end
        return
    end
    castBar_OnEvent(self, event, unit, ...)
end

local function LoadCastingBar(castingBarType, name, unit, showTradeSkills)
    castingBarType:Kill()

    local GwCastingBar = CreateFrame("Frame", name, UIParent, "GwCastingBar")
    GwCastingBar.latency:Hide()
    GwCastingBar.name:SetFont(UNIT_NAME_FONT, 12, "")
    GwCastingBar.name:SetShadowOffset(1, -1)
    GwCastingBar.time:SetFont(UNIT_NAME_FONT, 12, "")
    GwCastingBar.time:SetShadowOffset(1, -1)
    GwCastingBar.spark:ClearAllPoints()
    GwCastingBar.spark:SetPoint("RIGHT", GwCastingBar.bar, "RIGHT")

    GwCastingBar:SetAlpha(0)

    GwCastingBar.unit = unit
    GwCastingBar.showCastbar = true
    GwCastingBar.spellID = nil
    GwCastingBar.isChanneling = false
    GwCastingBar.isCasting = false
    GwCastingBar.animationName = name
    GwCastingBar.showTradeSkills = showTradeSkills
    GwCastingBar.showDetails = GetSetting("CASTINGBAR_DATA")

    if name == "GwCastingBarPlayer" then
        RegisterMovableFrame(GwCastingBar, SHOW_ARENA_ENEMY_CASTBAR_TEXT, "castingbar_pos", "GwCastFrameDummy", nil, nil, {"default", "scaleable"})
        GwCastingBar:ClearAllPoints()
        GwCastingBar:SetPoint("TOPLEFT", GwCastingBar.gwMover)
    else
        GwCastingBar:ClearAllPoints()
        GwCastingBar:SetPoint("TOPLEFT", GwCastingBarPlayer.gwMover, "TOPLEFT", 0, 35)
    end

    GwCastingBar:SetScript("OnEvent", unit == "pet" and petCastBar_OnEvent or castBar_OnEvent)

    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)
    GwCastingBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    if unit == "pet" then
        GwCastingBar:RegisterEvent("UNIT_PET")
        GwCastingBar.showCastbar = UnitIsPossessed(unit)
    end
end
GW.LoadCastingBar = LoadCastingBar