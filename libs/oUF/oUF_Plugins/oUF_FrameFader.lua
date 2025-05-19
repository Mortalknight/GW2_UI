local _, ns = ...
local oUF = ns.oUF

local MIN_ALPHA, MAX_ALPHA = 0.35, 1

local function GetMouseFocus(self)
    return DoesAncestryIncludeAny(self, GetMouseFoci())
end

local function ClearTimers(element)
    if element.configTimer then
        element.configTimer:Cancel()
        element.configTimer = nil
    end
end

local function UpdateRange(self, unit)
    local element = self.Fader
    local inRange, checkedRange
    local connected = UnitIsConnected(unit)
    if connected then
        inRange, checkedRange = UnitInRange(unit)
        if(checkedRange and not inRange) or UnitPhaseReason(unit) then
            element.RangeAlpha = element.MinAlpha
        else
            element.RangeAlpha = element.MaxAlpha
        end
    else
        element.RangeAlpha = element.MaxAlpha
    end
end

local function ToggleAlpha(self, element, endAlpha)
    element:ClearTimers()

    if element.Smooth then
        ns.AddToAnimation(self:GetName(), self:GetAlpha(), endAlpha, GetTime(), element.Smooth, function(p) self:SetAlpha(p) end, 1)
    else
        self:SetAlpha(endAlpha)
    end
end

local isGliding = false
local function Update(self, event, unit)
    --print(self:GetName(), self.unit, unit)
    if not self:IsVisible() then return end
    local element = self.Fader
    if self.isForced or (not element or not element.count or element.count <= 0) then
        self:SetAlpha(1)
        return
    end

    -- stuff for Skyriding
    if event == "ForceUpdate" then
        isGliding = C_PlayerInfo.GetGlidingInfo()
    elseif event == "PLAYER_IS_GLIDING_CHANGED" then
        isGliding = unit -- unit is true/false with the event being PLAYER_IS_GLIDING_CHANGED
    end

    -- try to get the unit from the parent
    if not unit or type(unit) ~= "string" then
        unit = self.unit
    end

    -- range fader
    if element.Range then
        UpdateRange(self, unit)
        if element.RangeAlpha then
            ToggleAlpha(element.rangeFaderObject or self, element, element.RangeAlpha)
        end

        return
    end

    -- normal fader
    if (element.Casting and (UnitCastingInfo(unit) or UnitChannelInfo(unit))) or
        (element.Combat and UnitAffectingCombat(unit)) or
        (element.DynamicFlight and not isGliding) or
        (element.Health and UnitHealth(unit) < UnitHealthMax(unit)) or
        (element.Hover and GetMouseFocus(self))
    then
        ToggleAlpha(element.rangeFaderObject or self, element, element.MaxAlpha)
    else
        ToggleAlpha(element.rangeFaderObject or self, element, element.MinAlpha)
    end
end

local function ForceUpdate(element, event)
    return Update(element.__owner, event or "ForceUpdate", element.__owner.unit)
end

local function HoverScript(self)
    local Fader = self.Fader
    if Fader and Fader.HoverHooked == 1 then
        Fader:ForceUpdate("HoverScript")
    end
end

local options = {
    Range = {
        enable = function(self)
            self:RegisterEvent("UNIT_IN_RANGE_UPDATE", Update)
        end,
        events = {"UNIT_IN_RANGE_UPDATE"},
    },
    Hover = {
        enable = function(self)
        if not self.Fader.HoverHooked then
                self:HookScript("OnEnter", HoverScript)
                self:HookScript("OnLeave", HoverScript)
            end

            self.Fader.HoverHooked = 1 -- on state
        end,
        disable = function(self)
            if self.Fader.HoverHooked == 1 then
                self.Fader.HoverHooked = 0 -- off state
            end
        end
    },
    Combat = {
        enable = function(self)
            self:RegisterEvent("PLAYER_REGEN_ENABLED", Update, true)
            self:RegisterEvent("PLAYER_REGEN_DISABLED", Update, true)
            self:RegisterEvent("UNIT_FLAGS", Update)
        end,
        events = {"PLAYER_REGEN_ENABLED","PLAYER_REGEN_DISABLED","UNIT_FLAGS"}
    },
    Casting = {
        enable = function(self)
            self:RegisterEvent("UNIT_SPELLCAST_START", Update)
            self:RegisterEvent("UNIT_SPELLCAST_FAILED", Update)
            self:RegisterEvent("UNIT_SPELLCAST_STOP", Update)
            self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", Update)
            self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", Update)
            self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", Update)
            self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START", Update)
            self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP", Update)
        end,
        events = {"UNIT_SPELLCAST_START","UNIT_SPELLCAST_FAILED","UNIT_SPELLCAST_STOP","UNIT_SPELLCAST_INTERRUPTED","UNIT_SPELLCAST_CHANNEL_START","UNIT_SPELLCAST_CHANNEL_STOP","UNIT_SPELLCAST_EMPOWER_START","UNIT_SPELLCAST_EMPOWER_STOP"}
    },
    DynamicFlight = {
        enable = function(self)
            self:RegisterEvent("PLAYER_IS_GLIDING_CHANGED", Update, true)
        end,
        events = {"PLAYER_IS_GLIDING_CHANGED"}
    },
    Health = {
        enable = function(self)
            self:RegisterEvent("UNIT_HEALTH", Update)
            self:RegisterEvent("UNIT_MAXHEALTH", Update)
        end,
        events = {"UNIT_HEALTH","UNIT_MAXHEALTH"}
    },
    MinAlpha = {
        countIgnored = true,
        enable = function(self, state)
            self.Fader.MinAlpha = state or MIN_ALPHA
        end
    },
    MaxAlpha = {
        countIgnored = true,
        enable = function(self, state)
            self.Fader.MaxAlpha = state or MAX_ALPHA
        end
    },
    Smooth = {countIgnored = true},
}

local function CountOption(element, state, oldState)
    if state and not oldState then
        element.count = (element.count or 0) + 1
    elseif oldState and element.count and not state then
        element.count = element.count - 1
    end
end

local function SetOption(element, opt, state)
    local option = opt
    local oldState = element[opt]

    if option and options[option] and (oldState ~= state) then
        element[opt] = state

        if state then
            if options[option].enable then
                options[option].enable(element.__owner, state)
            end
        else
            if options[option].events and next(options[option].events) then
                for _, event in ipairs(options[option].events) do
                    element.__owner:UnregisterEvent(event, Update)
                end
            end

            if options[option].disable then
                options[option].disable(element.__owner)
            end
        end

        if not options[option].countIgnored then
            CountOption(element, state, oldState)
        end
    end
end

local function Enable(self)
    if self.Fader then
        self.Fader.__owner = self
        self.Fader.ForceUpdate = ForceUpdate
        self.Fader.SetOption = SetOption
        self.Fader.ClearTimers = ClearTimers

        self.Fader.MinAlpha = MIN_ALPHA
        self.Fader.MaxAlpha = MAX_ALPHA

        return true
    end
end

local function Disable(self)
    if self.Fader then
        for opt in pairs(options) do
            self.Fader:SetOption(opt)
        end

        self.Fader.count = nil
        self.Fader:ClearTimers()
        local faderObject = self.Fader.rangeFaderObject or self
        ns.AddToAnimation(faderObject:GetName(), faderObject:GetAlpha(), 1, GetTime(), 0.33, function(p) faderObject:SetAlpha(p) end, 1)
    end
end
oUF:AddElement("Fader", nil, Enable, Disable)