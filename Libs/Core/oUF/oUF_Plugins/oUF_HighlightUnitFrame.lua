local _, ns = ...
local oUF = ns.oUF

local hooked = {}

local function Update(self, event)
	local element = self.highlightBorder
    local isSameUnit = ns.UnitIsUnit(self.__unit, "target")

    element:SetAlpha(0)

    if self:IsMouseOver() then
        element:SetAlpha(1)
        return
    end

    if ns.isModern then
        element:SetAlphaFromBoolean(isSameUnit, 1, 0)
    else
        if isSameUnit then
            element:SetAlpha(1)
        else
            element:SetAlpha(0)
        end
    end
end

local polling = {}

-- the mouse on a child with its own mouse handling (an aura) gives the frame its leave already,
-- leaving the frame from there sends nothing more: checked again until the mouse is gone
local function CheckMouseLeft(self)
    if self:IsMouseOver() then
        C_Timer.After(0.15, function() CheckMouseLeft(self) end)
    else
        polling[self] = nil
        Update(self)
    end
end

-- the scripts can not be unhooked, a disabled element ignores them
local function OnEnter(self)
    if self:IsElementEnabled('HighlightUnitFrame') then
        Update(self)
    end
end

local function OnLeave(self)
    if not self:IsElementEnabled('HighlightUnitFrame') then return end
    Update(self)
    if self:IsMouseOver() and not polling[self] then
        polling[self] = true
        CheckMouseLeft(self)
    end
end

local function Enable(self)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", Update, true)

    if not hooked[self] then
        hooked[self] = true
        self:HookScript("OnEnter", OnEnter)
        self:HookScript("OnLeave", OnLeave)
    end

    return true
end

local function Disable(self)
    self:UnregisterEvent("PLAYER_TARGET_CHANGED", Update, true)
    self.highlightBorder:SetAlpha(0)
end

oUF:AddElement('HighlightUnitFrame', Update, Enable, Disable)
