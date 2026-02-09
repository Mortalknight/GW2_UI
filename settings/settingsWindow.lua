local _, GW = ...
local L = GW.L

GwSettingsWindowMixin = {}

function GwSettingsWindowMixin:AddTab(icon, panel)
    local tabButton = CreateFrame("Button", nil, self.tabBar, "GwSettingsTabButtonTemplate")
    tabButton.icon:SetTexture(icon)
    tabButton.panelName = panel.name
    tabButton.headerBreadcrumbText = panel.headerBreadcrumbText
    tabButton.hasSearch = panel.hasSearch
    tabButton:SetScript("OnClick", function()
        self:SwitchTab(panel.name)
    end)

    tabButton:SetPoint("TOPRIGHT", self.tabBar, "TOPRIGHT", 1, -32 + (-40 * #self.tabButtons))

    tinsert(self.tabButtons, tabButton)
end

function GwSettingsWindowMixin:SwitchTab(panelName)
    for _, tab in ipairs(self.tabs) do
        if tab.name == panelName then
            tab:Show()
            UIFrameFadeIn(tab, 0.2, 0, 1)
        else
            if tab:IsShown() and tab.callbackOnClose then
                tab.callbackOnClose()
            end
            tab:Hide()
        end
    end

    for _, button in ipairs(self.tabButtons) do
        if button.panelName == panelName then
            button.icon:SetTexCoord(0, 0.5, 0, 0.625)
            self.headerBreadcrumb:SetText(button.headerBreadcrumbText)
            self.hasSearch = button.hasSearch
        else
            button.icon:SetTexCoord(0.505, 1, 0, 0.625)
        end
    end
end

local function BuildSettingsWindow()
    local settingsContainer = CreateFrame("Frame", "GwSettingsWindow", UIParent, "GwSettingsWindowTmpl")
    settingsContainer:SetClampedToScreen(true)
    settingsContainer:SetClampRectInsets(-40, 0, 40, 0)
    tinsert(UISpecialFrames, "GwSettingsWindow")

    settingsContainer.headerBreadcrumb:SetFont(DAMAGE_TEXT_FONT, 14)
    settingsContainer.headerBreadcrumb:SetText(CHAT_CONFIGURATION)
    settingsContainer.headerString:SetFont(DAMAGE_TEXT_FONT, 24)
    settingsContainer.versionString:SetFont(UNIT_NAME_FONT, 12)
    settingsContainer.versionString:SetText(GW.GetVersionString())
    settingsContainer.headerString:SetText(CHAT_CONFIGURATION)

    settingsContainer.close:SetScript("OnClick", function() settingsContainer:Hide() end)

    settingsContainer:SetScript("OnHide", function()
        if not GW.InMoveHudMode and GW.ShowRlPopup then
            GW.ShowRlPopup = false
            GW.ShowPopup({text = L["One or more of the changes you have made require a UI reload."],
                OnAccept = function() C_UI.Reload() end,
                button1 = ACCEPT,
                button2 = CANCEL}
            )
        end
    end)
    settingsContainer:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" and self:IsShown() then
            self:Hide()
            GW.Notice(L["Settings are not available in combat!"])
            settingsContainer.wasOpen = true
        elseif event == "PLAYER_REGEN_ENABLED" and self.wasOpen then
            self:Show()
            settingsContainer.wasOpen = false
        end
    end)
    settingsContainer:RegisterEvent("PLAYER_REGEN_DISABLED")
    settingsContainer:RegisterEvent("PLAYER_REGEN_ENABLED")

    settingsContainer.backgroundMask = UIParent:CreateMaskTexture()
    settingsContainer.backgroundMask:SetPoint("TOPLEFT", settingsContainer, "TOPLEFT", -64, 64)
    settingsContainer.backgroundMask:SetPoint("BOTTOMRIGHT", settingsContainer, "BOTTOMLEFT",-64, 0)
    settingsContainer.backgroundMask:SetTexture("Interface/AddOns/GW2_UI/textures/masktest.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    settingsContainer.background:AddMaskTexture(settingsContainer.backgroundMask)

    settingsContainer:HookScript("OnShow", function()
        GW.AddToAnimation("SETTINGSFRAME_PANEL_ONSHOW1", 0, 1, GetTime(),
            GW.WINDOW_FADE_DURATION,
            function(p)
                settingsContainer:SetAlpha(p)
                settingsContainer.backgroundMask:SetPoint("BOTTOMRIGHT", settingsContainer.background, "BOTTOMLEFT", GW.lerp(-64, settingsContainer.background:GetWidth(), p) , 0)
            end,
            1,
            function()
                settingsContainer.backgroundMask:SetPoint("BOTTOMRIGHT", settingsContainer.background, "BOTTOMLEFT", settingsContainer.background:GetWidth() + 200, 0)
            end
        )
    end)

    settingsContainer.tabs = {}
    settingsContainer.tabButtons = {}
    local overviewPanel = GW.LoadSettingsOverview(settingsContainer)
    tinsert(settingsContainer.tabs, overviewPanel)
    local settingsTab = GW.LoadSettingsTab(settingsContainer)
    tinsert(settingsContainer.tabs, settingsTab)
    local profileTab = GW.LoadSettingsProfileTab(settingsContainer)
    tinsert(settingsContainer.tabs, profileTab)

    settingsContainer:SetMovable(true)
    settingsContainer:EnableMouse(true)
    settingsContainer:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            settingsContainer:StartMoving()
        end
    end)
    settingsContainer:SetScript("OnMouseUp", function()
        settingsContainer:StopMovingOrSizing()
    end)

    settingsContainer:SwitchTab("GwSettingsOverview")
end
GW.BuildSettingsWindow = BuildSettingsWindow