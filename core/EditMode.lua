local _, GW = ...
local GetSetting = GW.GetSetting
local LEMO = GW.Libs.LEMO

local CheckActionBar = function() return GetSetting("ACTIONBARS_ENABLED") end

local eventFrame = CreateFrame("Frame")
local hideFrames = {}
eventFrame.hideFrames = hideFrames

local function OnEvent(self, event)
    if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        local combatLeave = event == "PLAYER_REGEN_ENABLED"
        GameMenuButtonEditMode:SetEnabled(combatLeave)

        if combatLeave then
            if next(hideFrames) then
                for frame in next, hideFrames do
                    HideUIPanel(frame)
                    frame:SetScale(1)

                    hideFrames[frame] = nil
                end
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if CheckActionBar() then
            -- do that in the users profile, if this is not editable we create a gw2 profile with needed actionbar settings
            --/run GW2_ADDON.Libs.LEMO:ReanchorFrame(MainMenuBar, "TOP", UIParent, "BOTTOM", 0, (80 * (tonumber(GetSetting("HUD_SCALE")) or 1))); GW2_ADDON.Libs.LEMO:ApplyChanges()
            LEMO:LoadLayouts()

            if not LEMO:CanEditActiveLayout() or not LEMO:DoesLayoutExist("GW2_Layout") then
                LEMO:AddLayout(Enum.EditModeLayoutType.Account, "GW2_Layout")
                LEMO:SetActiveLayout("GW2_Layout")
            end

            LEMO:SetFrameSetting(MainMenuBar, Enum.EditModeActionBarSetting.IconSize, 5)
            LEMO:SetFrameSetting(MultiBarBottomLeft, Enum.EditModeActionBarSetting.IconSize, 5)
            LEMO:SetFrameSetting(MultiBarBottomRight, Enum.EditModeActionBarSetting.IconSize, 5)
            LEMO:SetFrameSetting(MultiBarRight, Enum.EditModeActionBarSetting.IconSize, 5)
            LEMO:SetFrameSetting(MultiBarLeft, Enum.EditModeActionBarSetting.IconSize, 5)
            LEMO:SetFrameSetting(MultiBar5, Enum.EditModeActionBarSetting.IconSize, 5)
            LEMO:SetFrameSetting(MultiBar6, Enum.EditModeActionBarSetting.IconSize, 5)
            LEMO:SetFrameSetting(MultiBar7, Enum.EditModeActionBarSetting.IconSize, 5)

            -- Main Actionbar
            LEMO:SetFrameSetting(MainMenuBar, Enum.EditModeActionBarSetting.Orientation, Enum.ActionBarOrientation.Horizontal)
            LEMO:SetFrameSetting(MainMenuBar, Enum.EditModeActionBarSetting.NumRows, 1)
            LEMO:SetFrameSetting(MainMenuBar, Enum.EditModeActionBarSetting.NumIcons, 12)
            LEMO:ReanchorFrame(MainMenuBar, "TOP", UIParent, "BOTTOM", 0, (80 * (tonumber(GetSetting("HUD_SCALE")) or 1)))

            -- PossessActionBar
            LEMO:ReanchorFrame(PossessActionBar, "BOTTOM", MainMenuBar, "TOP", -110, 40)

            LEMO:ApplyChanges()
            -- only tigger that code once
            self:UnregisterEvent(event)
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
    EditModeManagerFrame:SaveLayoutChanges()
    OnProceed()
end

local function OnClose()
    local editMode = EditModeManagerFrame
    if editMode:HasActiveChanges() then
        editMode:ShowRevertWarningDialog()
    else
        HandleHide(editMode)
    end
end

local function SetEnabled(self, enabled)
    if InCombatLockdown() and enabled then
        self:Disable()
    end
end
local function HandleBlizzardEditMode()
    local dialog = EditModeUnsavedChangesDialog
    dialog.ProceedButton:SetScript("OnClick", OnProceed)
    dialog.SaveAndProceedButton:SetScript("OnClick", OnSaveProceed)

    EditModeManagerFrame.onCloseCallback = OnClose
    hooksecurefunc(GameMenuButtonEditMode, "SetEnabled", SetEnabled)

    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD") -- needed for Lib EditMode
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:SetScript("OnEvent", OnEvent)
end
GW.HandleBlizzardEditMode = HandleBlizzardEditMode