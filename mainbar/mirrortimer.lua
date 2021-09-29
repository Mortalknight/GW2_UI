local _, GW = ...

local function MirrorTimer_Show(timer, value, maxvalue, scale, paused, label)
    -- Pick a free dialog to use
    local dialog = nil
    -- Find an open dialog of the requested type
    for index = 1, _G.MIRRORTIMER_NUMTIMERS, 1 do
        local frame = _G["GwMirrorTimer" .. index]
        if frame:IsShown() and frame.timer == timer then
            dialog = frame
            break
        end
    end
    if not dialog then
        -- Find a free dialog
        for index = 1, _G.MIRRORTIMER_NUMTIMERS, 1 do
            local frame = _G["GwMirrorTimer" .. index]
            if not frame:IsShown() then
                dialog = frame
                break
            end
        end
    end
    if not dialog then
        return
    end

    dialog.timer = timer
    dialog.value = (value / 1000)
    dialog.scale = scale
    if paused > 0 then
        dialog.paused = 1
    else
        dialog.paused = nil
    end

    -- Set the text of the dialog
    dialog.bar.name:SetText(label)

    -- Set the status bar of the dialog
    local color = MirrorTimerColors[timer]
    dialog.bar:SetMinMaxValues(0, (maxvalue / 1000))
    dialog.bar:SetValue(dialog.value)
    dialog.bar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/castinbar-white")
    dialog.bar:SetStatusBarColor(color.r, color.g, color.b)
    dialog:Show()
end
GW.MirrorTimer_Show = MirrorTimer_Show

local function mirrorTimerFrame_OnEvent(self, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" then
        for index = 1, MIRRORTIMER_NUMTIMERS do
            local timer, value, maxvalue, scale, paused, label = GetMirrorTimerInfo(index)
            if timer == "UNKNOWN" then
                self:Hide()
                self.timer = nil
            else
                MirrorTimer_Show(timer, value, maxvalue, scale, paused, label)
            end
        end
    end

    if not self:IsShown() or arg1 ~= self.timer then
        return
    end

    if event == "MIRROR_TIMER_PAUSE" then
        if arg1 > 0 then
            self.paused = 1
        else
            self.paused = nil
        end
    elseif event == "MIRROR_TIMER_STOP" then
        self:Hide()
        self.timer = nil
    end
end

local function mirrorTimerFrame_OnUpdate(self)
    if self.paused then
        return
    end
    self.value = GetMirrorTimerProgress(self.timer) / 1000
    self.bar:SetValue(self.value)
end

local function LoadMirrorTimers()
    for i = 1, _G.MIRRORTIMER_NUMTIMERS do
        _G["MirrorTimer" .. i]:Kill()

        local mirrorTimer = CreateFrame("Frame", "GwMirrorTimer" .. i, UIParent, "GwMirrorTimer")
        if i > 1 then
            mirrorTimer:ClearAllPoints()
            mirrorTimer:SetPoint("TOP", _G["GwMirrorTimer" .. i - 1], "BOTTOM")
        end
        mirrorTimer.bar.name:SetFont(UNIT_NAME_FONT, 12, "OUTLINED")
        mirrorTimer.timer = nil
        mirrorTimer:RegisterEvent("MIRROR_TIMER_START")
        mirrorTimer:RegisterEvent("MIRROR_TIMER_PAUSE")
        mirrorTimer:RegisterEvent("MIRROR_TIMER_STOP")
        mirrorTimer:RegisterEvent("PLAYER_ENTERING_WORLD")
        mirrorTimer:SetScript("OnEvent", mirrorTimerFrame_OnEvent)
        mirrorTimer:SetScript("OnUpdate", mirrorTimerFrame_OnUpdate)
        mirrorTimer:SetScript("OnShow", function() UIFrameFadeIn(mirrorTimer, 0.2, mirrorTimer:GetAlpha(), 1) end)
    end
end
GW.LoadMirrorTimers = LoadMirrorTimers