local _, ns = ...
local oUF = ns.oUF

local MIN_ALPHA, MAX_ALPHA = 0.35, 1
local onRangeObjects, onRangeFrame = {}

local function GetMouseFocus(self)
    return ns.DoesAncestryIncludeAny(self, GetMouseFoci())
end

local function ClearTimers(element)
    if element.configTimer then
        element.configTimer:Cancel()
        element.configTimer = nil
    end
end

local function UpdateRange(self, unit)
    local element = self.Fader
    local inRange
    local isEligible = UnitIsConnected(unit) and UnitInParty(unit)
    if ns.Retail then element.RangeAlpha = nil end
    if(isEligible) then
        inRange = UnitInRange(unit)
        if ns.Retail then
            self:SetAlphaFromBoolean(inRange, element.MaxAlpha, element.MinAlpha)
        else
            if not inRange then
                element.RangeAlpha = element.MinAlpha
            else
                element.RangeAlpha = element.MaxAlpha
            end
        end
    else
        if ns.Retail then
            self:SetAlphaFromBoolean(isEligible, element.MaxAlpha, element.MaxAlpha)
        else
            element.RangeAlpha = element.MaxAlpha
        end
    end
end

local function ToggleAlpha(self, element, endAlpha)
    element:ClearTimers()

    if element.Smooth then
        ns.AddToAnimation(self:GetDebugName(), self:GetAlpha(), endAlpha, GetTime(), element.Smooth, function(p) self:SetAlpha(p) end, 1)
    else
        self:SetAlpha(endAlpha)
    end
end

local isGliding = false
local function Update(self, event, unit)
    if not self:IsVisible() then return end
    local element = self.Fader
    if self.isForced or (not element or not element.count or element.count <= 0) then
        self:SetAlpha(1)
        return
    elseif element.Range and (event ~= "OnRangeUpdate" and event ~= "UNIT_IN_RANGE_UPDATE") then
        return
    end

    -- stuff for Skyriding
    if oUF.isRetail then
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
        (element.PlayerTarget and ns.UnitExists("target")) or
        (element.UnitTarget and ns.UnitExists(unit .. "target")) or
        (element.DynamicFlight and oUF.isRetail and not isGliding) or
        (element.Health and ns.NotSecretValue(currentHealth) and (currentHealth < UnitHealthMax(unit))) or
        (element.Vehicle and (oUF.isRetail or oUF.isMists) and UnitHasVehicleUI(unit)) or
        (element.Hover and GetMouseFocus(self))
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
        end
    end
end

local options = {
    Range = {
        enable = function(self)
            --if oUF.isRetail then
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
            --if oUF.isRetail then
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
    Target = { --[[UnitTarget, PlayerTarget]]
        enable = function(self)
            if not self.Fader.TargetHooked then
                self:HookScript("OnShow", TargetScript)
                self:HookScript("OnHide", TargetScript)
            end

            self.Fader.TargetHooked = 1 -- on state

            if not self:IsShown() then
                self:SetAlpha(0)
            end

            self:RegisterEvent("UNIT_TARGET", Update)
            self:RegisterEvent("PLAYER_TARGET_CHANGED", Update, true)
            self:RegisterEvent("PLAYER_FOCUS_CHANGED", Update, true)
        end,
        events = {"UNIT_TARGET","PLAYER_TARGET_CHANGED","PLAYER_FOCUS_CHANGED"},
        disable = function(self)
            if self.Fader.TargetHooked == 1 then
                self.Fader.TargetHooked = 0 -- off state
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

            if oUF.isRetail then
                self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START", Update)
                self:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP", Update)
            end
        end,
        events = {"UNIT_SPELLCAST_START","UNIT_SPELLCAST_FAILED","UNIT_SPELLCAST_STOP","UNIT_SPELLCAST_INTERRUPTED","UNIT_SPELLCAST_CHANNEL_START","UNIT_SPELLCAST_CHANNEL_STOP"}
    },
    Health = {
        enable = function(self)
            if oUF.isClassic then
                self:RegisterEvent("UNIT_HEALTH_FREQUENT", Update)
            end

            self:RegisterEvent("UNIT_HEALTH", Update)
            self:RegisterEvent("UNIT_MAXHEALTH", Update)
        end,
        events = oUF.isClassic and {"UNIT_HEALTH_FREQUENT","UNIT_HEALTH","UNIT_MAXHEALTH"} or {"UNIT_HEALTH","UNIT_MAXHEALTH"}
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

if oUF.isRetail then
    tinsert(options.Casting.events, "UNIT_SPELLCAST_EMPOWER_START")
    tinsert(options.Casting.events, "UNIT_SPELLCAST_EMPOWER_STOP")
    options.DynamicFlight = {
        enable = function(self)
            self:RegisterEvent("PLAYER_IS_GLIDING_CHANGED", Update, true)
        end,
        events = {"PLAYER_IS_GLIDING_CHANGED"}
    }
end

if oUF.isRetail or oUF.isMists then
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
            if opt == "Target" then
                self.Fader:SetOption("UnitTarget")
                self.Fader:SetOption("PlayerTarget")
            else
                self.Fader:SetOption(opt)
            end
        end

        self.Fader.count = nil
        self.Fader:ClearTimers()
        ns.AddToAnimation(self:GetDebugName(), self:GetAlpha(), 1, GetTime(), 0.33, function(p) self:SetAlpha(p) end, 1)
    end
end
oUF:AddElement("Fader", nil, Enable, Disable)