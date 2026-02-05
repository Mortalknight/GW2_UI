local _, GW = ...

local MIN_ALPHA, MAX_ALPHA = 0.35, 1
local onRangeObjects, onRangeFrame = {}
local pendingFrameHooks = {}
local createFrameHooked = false

local function GetMouseFocus(self, element)
    if GW.DoesAncestryIncludeAny(self, GetMouseFoci()) then
        return true
    end

    if element.correspondingFrames then
        for _, frameName in ipairs(element.correspondingFrames) do
            local frame = _G[frameName]
            if frame then
                if GW.DoesAncestryIncludeAny(frame, GetMouseFoci()) then
                    return true
                end
            end
        end
    end
    return false
end

local function ClearTimers(element)
    if element.configTimer then
        element.configTimer:Cancel()
        element.configTimer = nil
    end
end
local function UpdateRange(self, unit)
    local element = self.Fader
    local isEligible = UnitIsConnected(unit) and UnitInParty(unit)
    local inRange
    if GW.Retail then element.RangeAlpha = nil end
    if isEligible then
        inRange = UnitInRange(unit)
        if GW.Retail then
            self:SetAlphaFromBoolean(inRange, element.MaxAlpha, element.MinAlpha)
            if element.correspondingFrames then
                for _, frameName in ipairs(element.correspondingFrames) do
                    local frame = _G[frameName]
                    if frame and frame.shouldShow then
                        frame:SetAlphaFromBoolean(inRange, element.MaxAlpha, element.MinAlpha)
                    end
                end
            end
        else
            if not inRange then
                element.RangeAlpha = element.MinAlpha
            else
                element.RangeAlpha = element.MaxAlpha
            end
        end
    else
        if GW.Retail then
            self:SetAlphaFromBoolean(isEligible, element.MaxAlpha, element.MaxAlpha)
        else
            element.RangeAlpha = element.MaxAlpha
        end
    end
end

local function ToggleAlpha(self, element, endAlpha)
    element:ClearTimers()

    if element.Smooth then
        GW.AddToAnimation(self:GetDebugName(), self:GetAlpha(), endAlpha, GetTime(), element.Smooth, function(p) self:SetAlpha(p) end, 1)
        if element.correspondingFrames then
            for _, frameName in ipairs(element.correspondingFrames) do
                local frame = _G[frameName]
                if frame and frame.shouldShow then
                    GW.AddToAnimation(frame:GetDebugName(), frame:GetAlpha(), endAlpha, GetTime(), element.Smooth, function(p) frame:SetAlpha(p) end, 1)
                    if frame.UpdateAlphaFader then frame.UpdateAlphaFader(endAlpha) end
                end
            end
        end
    else
        self:SetAlpha(endAlpha)
        if element.correspondingFrames then
            for _, frameName in ipairs(element.correspondingFrames) do
                local frame = _G[frameName]
                if frame and frame.shouldShow then
                    frame:SetAlpha(endAlpha)
                    if frame.UpdateAlphaFader then frame.UpdateAlphaFader(endAlpha) end
                end
            end
        end
    end

    element.currentAlpha = endAlpha
end

local isGliding = false
local function Update(self, event, unit)
    if not self:IsVisible() then return end
    if (event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_ENTERED_VEHICLE") and self.unit ~= unit then return end

    local element = self.Fader
    if self.isForced or (not element or not element.count or element.count <= 0) then
        self:SetAlpha(1)
        if element.correspondingFrames then
            for _, frameName in ipairs(element.correspondingFrames) do
                local frame = _G[frameName]
                if frame and frame.shouldShow then
                    frame:SetAlpha(1)
                    if frame.UpdateAlphaFader then frame.UpdateAlphaFader(1) end
                end
            end
        end
        return
    elseif element.Range and (event ~= "OnRangeUpdate" and event ~= "UNIT_IN_RANGE_UPDATE") then
        return
    end

    -- stuff for Skyriding
    if GW.Retail then
        if event == "ForceUpdate" then
            isGliding = C_PlayerInfo.GetGlidingInfo()
        elseif event == "PLAYER_IS_GLIDING_CHANGED" then
            isGliding = unit -- unit is true/false with the event being PLAYER_IS_GLIDING_CHANGED
        end
    end

    -- try to get the unit from the parent
    if not unit or type(unit) ~= "string" then
        unit = self.unit
    end

    -- range fader
    if element.Range then
        UpdateRange(self, unit)
        if element.RangeAlpha then
            ToggleAlpha(self, element, element.RangeAlpha)
        end

        return
    end

    local currentHealth = UnitHealth(unit)
    -- normal fader
    if (element.Casting and (UnitCastingInfo(unit) or UnitChannelInfo(unit))) or
        (element.Combat and UnitAffectingCombat(unit)) or
        (element.PlayerTarget and GW.UnitExists("target")) or
        (element.UnitTarget and GW.UnitExists(unit .. "target")) or
        (element.DynamicFlight and GW.Retail and not isGliding) or
        (element.Health and GW.NotSecretValue(currentHealth) and (currentHealth < UnitHealthMax(unit))) or
        (element.Vehicle and (GW.Retail or GW.Mists) and UnitHasVehicleUI(unit)) or
        (element.Hover and GetMouseFocus(self, element))
    then
        ToggleAlpha(self, element, element.MaxAlpha)
    else
        ToggleAlpha(self, element, element.MinAlpha)
    end
end

local function ForceUpdate(element, event)
    return Update(element.__owner, event or "ForceUpdate", element.__owner.unit)
end

local function OnRangeUpdate(frame, elapsed)
    frame.timer = (frame.timer or 0) + elapsed

    if (frame.timer >= .20) then
        for _, object in next, onRangeObjects do
            if object:IsVisible() then
                object.Fader:ForceUpdate('OnRangeUpdate')
            end
        end

        frame.timer = 0
    end
end

local function HoverScript(self)
    local fader = self.Fader
    if fader and fader.HoverHooked == 1 then
        fader:ForceUpdate("HoverScript")
    end
end

local function TargetScript(self)
    local fader = self.Fader
    if fader and fader.TargetHooked == 1 then
        if self:IsShown() then
            fader:ForceUpdate("TargetScript")
        else
            self:SetAlpha(0)
            for _, frameName in ipairs(fader.correspondingFrames) do
                local frame = _G[frameName]
                if frame and frame.shouldShow then
                    frame:SetAlpha(0)
                    if frame.UpdateAlphaFader then frame.UpdateAlphaFader(0) end
                end
            end
        end
    end
end

local options = {
    Range = {
        enable = function(self)
            --if GW.Retail then
            --    self:RegisterEvent("UNIT_IN_RANGE_UPDATE", Update)
            --else
                if not onRangeFrame then
                    onRangeFrame = CreateFrame('Frame')
                    onRangeFrame:SetScript('OnUpdate', OnRangeUpdate)
                end

                onRangeFrame:Show()
                tinsert(onRangeObjects, self)
            --end
        end,
        disable = function(self)
            --if GW.Retail then
            --    self:UnregisterEvent('UNIT_IN_RANGE_UPDATE', Update)
            --else
                if onRangeFrame then
                    for idx, obj in next, onRangeObjects do
                        if obj == self then
                            self.Fader.RangeAlpha = nil
                            tremove(onRangeObjects, idx)
                            break
                        end
                    end

                    if #onRangeObjects == 0 then
                        onRangeFrame:Hide()
                    end
                end
            --end
        end,
    },
    Hover = {
        enable = function(self)
            if not self.HoverHooked then
                local Frame = self.__owner
                Frame:HookScript("OnEnter", HoverScript)
                Frame:HookScript("OnLeave", HoverScript)
            end

            self.HoverHooked = 1 -- on state
        end,
        disable = function(self)
            if self.HoverHooked == 1 then
                self.HoverHooked = 0 -- off state
            end
        end
    },
    Target = { --[[UnitTarget, PlayerTarget]]
        enable = function(self)
            if not self.TargetHooked then
                self:HookScript("OnShow", TargetScript)
                self:HookScript("OnHide", TargetScript)
            end

            self.TargetHooked = 1 -- on state

            if not self:IsShown() then
                self:SetAlpha(0)
            end

            self:RegisterUnitEvent("UNIT_TARGET", self.__owner.unit)
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:RegisterEvent("PLAYER_FOCUS_CHANGED")
        end,
        events = {"UNIT_TARGET","PLAYER_TARGET_CHANGED","PLAYER_FOCUS_CHANGED"},
        disable = function(self)
            if self.TargetHooked == 1 then
                self.TargetHooked = 0 -- off state
            end
        end
    },
    Combat = {
        enable = function(self)
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
            self:RegisterEvent("PLAYER_REGEN_DISABLED")
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:RegisterEvent("UNIT_FLAGS")
        end,
        events = {"PLAYER_REGEN_ENABLED","PLAYER_REGEN_DISABLED","UNIT_FLAGS","PLAYER_TARGET_CHANGED"}
    },
    Casting = {
        enable = function(self)
            self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.__owner.unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.__owner.unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.__owner.unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.__owner.unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.__owner.unit)
            self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.__owner.unit)

            if GW.Retail then
                self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", self.__owner.unit)
                self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", self.__owner.unit)
            end
        end,
        events = {"UNIT_SPELLCAST_START","UNIT_SPELLCAST_FAILED","UNIT_SPELLCAST_STOP","UNIT_SPELLCAST_INTERRUPTED","UNIT_SPELLCAST_CHANNEL_START","UNIT_SPELLCAST_CHANNEL_STOP"}
    },
    Health = {
        enable = function(self)
            if GW.Classic then
                self:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", self.__owner.unit)
            end

            self:RegisterUnitEvent("UNIT_HEALTH", self.__owner.unit)
            self:RegisterUnitEvent("UNIT_MAXHEALTH", self.__owner.unit)
        end,
        events = GW.Classic and {'UNIT_HEALTH_FREQUENT','UNIT_HEALTH','UNIT_MAXHEALTH'} or {'UNIT_HEALTH','UNIT_MAXHEALTH'}
    },
    MinAlpha = {
        countIgnored = true,
        enable = function(self, state)
            self.MinAlpha = state or MIN_ALPHA
        end
    },
    MaxAlpha = {
        countIgnored = true,
        enable = function(self, state)
            self.MaxAlpha = state or MAX_ALPHA
        end
    },
    Smooth = {countIgnored = true},
}

if GW.Retail then
    tinsert(options.Casting.events, "UNIT_SPELLCAST_EMPOWER_START")
    tinsert(options.Casting.events, "UNIT_SPELLCAST_EMPOWER_STOP")
    options.DynamicFlight = {
        enable = function(self)
            self:RegisterEvent("PLAYER_IS_GLIDING_CHANGED", Update, true)
        end,
        events = {"PLAYER_IS_GLIDING_CHANGED"}
    }
end

if GW.Retail or GW.Mists then
    options.Vehicle = {
        enable = function(self)
            self:RegisterEvent("UNIT_ENTERED_VEHICLE", Update, true)
            self:RegisterEvent("UNIT_EXITED_VEHICLE", Update, true)
        end,
        events = {"UNIT_ENTERED_VEHICLE","UNIT_EXITED_VEHICLE"}
    }
end

local function CountOption(element, state, oldState)
    if state and not oldState then
        element.count = (element.count or 0) + 1
    elseif oldState and element.count and not state then
        element.count = element.count - 1
    end
end

local function SetOption(element, opt, state)
    local option = ((opt == "UnitTarget" or opt == "PlayerTarget") and "Target") or opt
    local oldState = element[opt]

    if option and options[option] and (oldState ~= state) then
        element[opt] = state

        if state then
            if options[option].enable then
                options[option].enable(element, state)
            end
        else
            if options[option].events and next(options[option].events) then
                for _, event in ipairs(options[option].events) do
                    element:UnregisterEvent(event)
                end
            end

            if options[option].disable then
                options[option].disable(element)
            end
        end

        if not options[option].countIgnored then
            CountOption(element, state, oldState)
        end
    end
end

local function AddCorrespondingFrames(element, frameName)
    tinsert(element.correspondingFrames, frameName)
    if element.Hover then
        if not element._faderHookedFrames[frameName] then
            local frame = _G[frameName]
            if frame then
                frame:HookScript("OnEnter", function() HoverScript(element.__owner) end)
                frame:HookScript("OnLeave", function() HoverScript(element.__owner) end)
                element._faderHookedFrames[frameName] = true
            else
                pendingFrameHooks[frameName] = pendingFrameHooks[frameName] or {}
                tinsert(pendingFrameHooks[frameName], element)

                if not createFrameHooked then
                    hooksecurefunc("CreateFrame", function(_, name)
                        if not name then return end
                        local list = pendingFrameHooks[name]
                        if not list then return end
                        local created = _G[name]
                        if not created then return end

                        for _, el in ipairs(list) do
                            if not el._faderHookedFrames[name] then
                                created:SetScript("OnEnter", function() HoverScript(el.__owner) end)
                                created:SetScript("OnLeave", function() HoverScript(el.__owner) end)
                                el._faderHookedFrames[name] = true
                            end
                        end
                        pendingFrameHooks[name] = nil
                    end)
                    createFrameHooked = true
                end
            end
        end
    end
end

local function IsEnabled(self)
    return self.enabled
end

local function Enable(self)
    if not self.Fader then
        self.Fader = CreateFrame("Frame")
    end
    self.Fader.__owner = self
    self.Fader.ForceUpdate = ForceUpdate
    self.Fader.SetOption = SetOption
    self.Fader.AddCorrespondingFrames = AddCorrespondingFrames
    self.Fader.ClearTimers = ClearTimers
    self.Fader.IsEnabled = IsEnabled

    self.Fader.MinAlpha = MIN_ALPHA
    self.Fader.MaxAlpha = MAX_ALPHA
    self.Fader.currentAlpha = MIN_ALPHA

    self.Fader.correspondingFrames = self.Fader.correspondingFrames or {}
    self.Fader._faderHookedFrames = self.Fader._faderHookedFrames or {}

    self.Fader:SetScript("OnEvent", function(_, event, ...) Update(self, event, ...) end)
    self.Fader.enabled = true
end

local function Disable(self)
    if self.Fader then
        for opt in pairs(options) do
        if opt == "Target" then
                self.Fader:SetOption("UnitTarget")
                self.Fader:SetOption("PlayerTarget")
            else
                self.Fader:SetOption(opt)
            end
        end

        wipe(self.Fader._faderHookedFrames or {})
        wipe(self.Fader.correspondingFrames or {})
        self.Fader.count = nil
        self.Fader:ClearTimers()
        GW.AddToAnimation(self:GetDebugName(), self:GetAlpha(), 1, GetTime(), 0.33, function(p) self:SetAlpha(p) end, 1)

        self.Fader:SetScript("OnEvent", nil)
        self.Fader.enabled = false
    end
end
GW.FrameFadeEnable = Enable
GW.FrameFadeDisable = Disable
