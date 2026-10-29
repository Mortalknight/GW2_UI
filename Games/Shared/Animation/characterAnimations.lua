---@class GW2
local GW = select(2, ...)

local PANEL_SWITCH_DURATION = 0.12
local PANEL_SWITCH_GLOW_ALPHA = 0.04
local PANEL_SWITCH_ICON_SCALE = 0.012
local PANEL_SWITCH_ICON_ALPHA = 0.02
local PANEL_SWITCH_HEADER_ALPHA = 0.04
local TAB_PULSE_DURATION = 0.1
local TAB_PULSE_SCALE = 0.01

function GW.ResetCharacterPanelSwitchAnimation(frame)
    if not frame then
        return
    end

    frame.currentPanel = nil

    if frame.panelTransition then
        frame.panelTransition:SetAlpha(0)
    end
    if frame.windowIcon then
        frame.windowIcon:SetScale(1)
        frame.windowIcon:SetAlpha(1)
    end
    if frame.WindowHeader then
        frame.WindowHeader:SetAlpha(1)
    end
end

function GW.SetupCharacterPanelSwitchAnimation(frame)
    if not frame or frame.GwCharacterPanelSwitchAnimationReady then
        return
    end

    frame.GwCharacterPanelSwitchAnimationReady = true

    frame.panelTransition = frame:CreateTexture(nil, "ARTWORK", nil, 3)
    frame.panelTransition:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.panelTransition:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    frame.panelTransition:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/glow.png")
    frame.panelTransition:SetBlendMode("ADD")
    frame.panelTransition:SetVertexColor(1, 0.91, 0.72, 1)
    frame.panelTransition:SetAlpha(0)

    frame.AnimatePanelSwitch = function(self, selected)
        if not selected or self.currentPanel == selected then
            self.currentPanel = selected
            return
        end

        self.currentPanel = selected

        local animationName = self:GetDebugName() .. "_PanelSwitch"
        local icon = self.windowIcon
        local header = self.WindowHeader

        icon:SetScale(1)
        icon:SetAlpha(1)
        header:SetAlpha(1)
        self.panelTransition:SetAlpha(0)

        GW.AddToAnimation(animationName, 0, 1, GetTime(), PANEL_SWITCH_DURATION, function(step)
            local pulse = math.sin(step * math.pi)
            self.panelTransition:SetAlpha(pulse * PANEL_SWITCH_GLOW_ALPHA)
            icon:SetScale(1 + (pulse * PANEL_SWITCH_ICON_SCALE))
            icon:SetAlpha((1 - PANEL_SWITCH_ICON_ALPHA) + (pulse * PANEL_SWITCH_ICON_ALPHA))
            header:SetAlpha((1 - PANEL_SWITCH_HEADER_ALPHA) + (pulse * PANEL_SWITCH_HEADER_ALPHA))
        end, nil, function()
            self.panelTransition:SetAlpha(0)
            icon:SetScale(1)
            icon:SetAlpha(1)
            header:SetAlpha(1)
        end)
    end

    frame.SetCurrentPanel = function(self, selected)
        self.currentPanel = selected
    end

    frame:HookScript("OnHide", GW.ResetCharacterPanelSwitchAnimation)
end

function GW.SetupCharacterWindowRevealAnimation(frame)
    if not frame or frame.GwCharacterWindowRevealAnimationReady or not frame.backgroundMask or not frame.background then
        return
    end

    frame.GwCharacterWindowRevealAnimationReady = true

    frame:HookScript("OnShow", function(self)
        GW.AddToAnimation("HERO_PANEL_ONSHOW", 0, 1, GetTime(), GW.WINDOW_FADE_DURATION, function(p)
            self:SetAlpha(p)

            if self.dressingRoom and self.dressingRoom.model then
                self.dressingRoom.model:SetAlpha(math.max(0, (p - 0.5) / 0.5))
            end

            self.backgroundMask:SetPoint("BOTTOMRIGHT", self.background, "BOTTOMLEFT", GW.lerp(-64, self.background:GetWidth(), p), 0)
        end, 1, function()
            self.backgroundMask:SetPoint("TOPLEFT", self.background, "TOPLEFT", -64, 64)
            self.backgroundMask:SetPoint("BOTTOMRIGHT", self.background, "BOTTOMLEFT", -64, 0)
        end)
    end)
end

function GW.PlayCharacterTabSwitchPulse(tabFrame)
    if not tabFrame or InCombatLockdown() then
        return
    end

    GW.AddToAnimation(tabFrame:GetDebugName() .. "_TabPulse", 0, 1, GetTime(), TAB_PULSE_DURATION, function(step)
        if InCombatLockdown() then
            return
        end
        local pulse = math.sin(step * math.pi)
        tabFrame:SetScale(1 + (pulse * TAB_PULSE_SCALE))
    end, nil, function()
        if InCombatLockdown() then
            return
        end
        tabFrame:SetScale(1)
    end)
end

function GW.ResetCharacterTabSwitchPulse(tabFrame)
    if tabFrame and not InCombatLockdown() then
        tabFrame:SetScale(1)
    end
end
