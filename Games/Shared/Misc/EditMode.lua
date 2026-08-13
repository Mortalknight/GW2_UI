---@class GW2
local GW = select(2, ...)

local CheckActionBar = function() return (GW.settings.ACTIONBARS_ENABLED and GW.settings.BAR_LAYOUT_ENABLED) end
local eventFrame = CreateFrame("Frame")
local hideFrames = {}
eventFrame.hideFrames = hideFrames

local hasAppliedChanges = false

local function getGameMenuEditModeButton() -- MenuButton get saved while adding gw2 setting button
    local menu = GameMenuFrame
    return menu and menu.GwMenuButtons and GameMenuFrame.GwMenuButtons[HUD_EDIT_MODE_MENU]
end

local function SetEnabled(self, enabled)
    if InCombatLockdown() and enabled then
        self:Disable()
    end
end

local function ApplyBlizzardEditModeChanges()
    if InCombatLockdown() then
        return
    end
    GW.AddGw2Layout(true)

    if MirrorTimerContainer then
        MirrorTimerContainer:Show()
    end

    hasAppliedChanges = true
end

local function OnEvent(self, event)
    if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        local combatLeave = event == "PLAYER_REGEN_ENABLED"

        local button = getGameMenuEditModeButton()
        if button then
            button:SetEnabled(combatLeave)
        end

        if combatLeave then
            if next(hideFrames) then
                for frame in next, hideFrames do
                    HideUIPanel(frame)
                    frame:SetScale(1)

                    hideFrames[frame] = nil
                end
            end
        end
    end
    if event == "PLAYER_ENTERING_WORLD" or event == "EDIT_MODE_LAYOUTS_UPDATED" or (event == "PLAYER_REGEN_ENABLED" and not hasAppliedChanges) then
        if CheckActionBar() then
            C_Timer.After(0, ApplyBlizzardEditModeChanges)
            -- only tigger that code once
            self:UnregisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end
    end
end

local function HandleHide(frame)
    local combat = InCombatLockdown()
    if combat then
        hideFrames[frame] = true

        for _, child in next, frame.registeredSystemFrames do
            child:ClearHighlight()
        end
    end

    HideUIPanel(frame, not combat)
    frame:SetScale(combat and 0.00001 or 1)
end

local function OnProceed()
    local editMode = EditModeManagerFrame
    local dialog = EditModeUnsavedChangesDialog
    if dialog.selectedLayoutIndex then
        editMode:SelectLayout(dialog.selectedLayoutIndex)
    else
        HandleHide(editMode)
    end

    StaticPopupSpecial_Hide(dialog)
end

local function OnSaveProceed()
    -- SaveLayoutChanges is asynchronous when the active layout is a preset: it only opens
    -- the "New Layout" dialog and saves after that gets confirmed. Proceeding immediately
    -- exits the edit mode, which REVERTS all changes before they were ever saved (hit by
    -- skin-only users on the "Modern" preset — their bar changes always got discarded).
    -- The unsaved-changes dialog registers EditMode.SavedLayouts -> OnProceed on show, so
    -- Blizzard proceeds on its own once the new layout is actually saved.
    EditModeManagerFrame:SaveLayoutChanges()
    if not EditModeManagerFrame.IsActiveLayoutPreset or not EditModeManagerFrame:IsActiveLayoutPreset() then
        OnProceed()
    end
end

local function OnClose()
    local editMode = EditModeManagerFrame
    if editMode:HasActiveChanges() then
        editMode:ShowRevertWarningDialog()
    else
        HandleHide(editMode)
    end
end

-- since 1.15.9 ClearTarget()/TargetUnit() are hard protected on classic clients, but blizzards
-- edit mode enter/exit calls them unconditionally via (Refresh/Reset)TargetAndFocus, which fires
-- ADDON_ACTION_FORBIDDEN whenever the edit mode is driven from our code path (layout apply on login,
-- our close callbacks), so skip the target juggling and keep only the frame cleanup
local function FixTargetAndFocusReset()
    local accountSettings = EditModeManagerFrame.AccountSettings

    accountSettings.ResetTargetAndFocus = function(self)
        self:UnregisterEvent("PLAYER_TARGET_CHANGED")
        self:UnregisterEvent("PLAYER_FOCUS_CHANGED")

        self.oldTargetName = nil
        self.oldFocusName = nil

        if TargetFrame and TargetFrame.ClearHighlight then
            TargetFrame:ClearHighlight()
        end
        if FocusFrame and FocusFrame.ClearHighlight then
            FocusFrame:ClearHighlight()
        end
    end

    accountSettings.RefreshTargetAndFocus = function(self)
        local checkButton = self.settingsCheckButtons and self.settingsCheckButtons.TargetAndFocus
        if checkButton and checkButton:IsControlChecked() then
            if TargetFrame and TargetFrame.HighlightSystem then
                TargetFrame:HighlightSystem()
            end
            if FocusFrame and FocusFrame.HighlightSystem then
                FocusFrame:HighlightSystem()
            end
        else
            self:ResetTargetAndFocus()
        end
    end
end

local function HandleBlizzardEditMode()
    if not GW.Retail then
        FixTargetAndFocusReset()
    end

    local dialog = EditModeUnsavedChangesDialog
    dialog.ProceedButton:SetScript("OnClick", OnProceed)
    dialog.SaveAndProceedButton:SetScript("OnClick", OnSaveProceed)

    EditModeManagerFrame.onCloseCallback = OnClose

    hooksecurefunc(GameMenuFrame, "Layout", function()
        for button in GameMenuFrame.buttonPool:EnumerateActive() do
            local text = button:GetText()
            if text == HUD_EDIT_MODE_MENU then
                SetEnabled(button, InCombatLockdown())
            end
        end
    end)

    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD") -- needed for Lib EditMode
    eventFrame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED") -- needed for Lib EditMode
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:SetScript("OnEvent", OnEvent)

    OnEvent(eventFrame, "PLAYER_ENTERING_WORLD")
end
GW.HandleBlizzardEditMode = HandleBlizzardEditMode