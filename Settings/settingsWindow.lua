---@class GW2
local GW = select(2, ...)
local L = GW.L

GwSettingsWindowMixin = {}

function GwSettingsWindowMixin:AddTab(icon, panel)
    local tabButton = CreateFrame("Button", nil, self.tabBar, "GwSettingsTabButtonTemplate")
    tabButton.icon:SetTexture(icon)
    tabButton.panelName = panel.name
    tabButton.headerBreadcrumbText = panel.headerBreadcrumbText
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
    -- Menomonia is the original GW2 typeface — ASCII only here, so the CJK locale
    -- fallbacks of the regular font pipeline are not needed
    settingsContainer.brandTextLeft:SetFont("Interface/AddOns/GW2_UI/Fonts/menomonia.ttf", 30)
    settingsContainer.brandTextLeft:SetText("|cffffffffGW2|r " .. GW.Colors.TextColors.LightHeader:WrapTextInColorCode("UI"))

    local brand = GW.CreateBrandLogo(settingsContainer, 50)
    brand:SetPoint("CENTER", settingsContainer, "TOPLEFT", 59, -29)
    settingsContainer.brandTextLeft:ClearAllPoints()
    settingsContainer.brandTextLeft:SetPoint("LEFT", brand, "RIGHT", 8, 3)
    settingsContainer.versionString:SetFont(UNIT_NAME_FONT, 12)
    settingsContainer.versionString:SetText(GW.GetVersionString() .. " (DB " .. (GW.settings.settingsVersion or 0) .. ")")

    local versionButton = CreateFrame("Button", nil, settingsContainer)
    versionButton:SetPoint("CENTER", settingsContainer.versionString)
    versionButton:SetSize(settingsContainer.versionString:GetStringWidth() + 10, 18)
    versionButton:SetScript("OnEnter", function(self)
        settingsContainer.versionString:SetTextColor(1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText(L["Click to copy the version for bug reports."], 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    versionButton:SetScript("OnLeave", function()
        settingsContainer.versionString:SetTextColor(1, 0.93, 0.73)
        GameTooltip_Hide()
    end)
    versionButton:SetScript("OnClick", function()
        local clientVersion, clientBuild = GetBuildInfo()
        GW.ShowPopup({text = L["Ctrl + C copies the version."],
            hasEditBox = true,
            hideOnEscape = true,
            EditBoxOnEnterPressed = function(popup) popup:Hide() end,
            EditBoxOnEscapePressed = function(popup) popup:Hide() end,
            button2 = CLOSE,
            inputText = format("GW2 UI %s | %s %s.%s | %s", settingsContainer.versionString:GetText(), GW.GetClientFlavorName(), clientVersion, clientBuild, GetLocale()),
        })
    end)

    settingsContainer.brandSeparator:SetVertexColor(GW.Colors.AccentLight:GetRGB())
    settingsContainer.flavorString = settingsContainer:CreateFontString(nil, "OVERLAY")
    settingsContainer.flavorString:SetFont(UNIT_NAME_FONT, 11)
    settingsContainer.flavorString:SetPoint("BOTTOM", settingsContainer.brandSeparator, "TOP", 0, 3)
    settingsContainer.flavorString:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    settingsContainer.flavorString:SetText(GW.GetClientFlavorName())
    settingsContainer.headerString:SetText(CHAT_CONFIGURATION)

    settingsContainer.close:SetScript("OnClick", function() settingsContainer:Hide() end)

    -- wow opens no links, the popup offers the url to copy
    local anchor = settingsContainer.close
    for _, link in ipairs({
        {key = "github", text = "GitHub", url = "https://github.com/Mortalknight/GW2_UI"},
        {key = "discord", text = L["Join Discord"], url = "https://discord.gg/MZZtRWt"},
    }) do
        local button = CreateFrame("Button", nil, settingsContainer)
        button:SetSize(22, 22)
        button:SetPoint("RIGHT", anchor, "LEFT", -6, 0)
        button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/settings-" .. link.key .. "-normal.png")
        button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/settings-" .. link.key .. "-hover.png")
        button:SetScript("OnClick", function()
            GW.ShowPopup({text = link.text,
                hasEditBox = true,
                inputText = link.url,
                EditBoxOnEscapePressed = function(popup) popup:Hide() end,
                hideOnEscape = true})
        end)
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:SetText(link.text, GW.Colors.TextColors.LightHeader:GetRGB())
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", GameTooltip_Hide)
        anchor = button
    end

    -- live "reload required" hint in the header with the pending settings as tooltip
    local reloadIndicator = CreateFrame("Frame", nil, settingsContainer)
    reloadIndicator:SetPoint("LEFT", settingsContainer.headerBreadcrumb, "RIGHT", 14, 2)
    reloadIndicator:SetSize(260, 24)
    reloadIndicator:EnableMouse(true)
    reloadIndicator.text = reloadIndicator:CreateFontString(nil, "OVERLAY")
    reloadIndicator.text:SetFont(UNIT_NAME_FONT, 12)
    reloadIndicator.text:SetAllPoints()
    reloadIndicator.text:SetJustifyH("LEFT")
    reloadIndicator.text:SetTextColor(1, 0.65, 0.1)
    reloadIndicator.text:SetText("|TInterface/DialogFrame/UI-Dialog-Icon-AlertNew:14:14|t " .. L["Reload required to take effect"])
    reloadIndicator:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Reload required to take effect"], 1, 0.65, 0.1)
        for _, entry in pairs(GW.GetPendingReloadSettings()) do
            GameTooltip:AddLine(entry.name, 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    reloadIndicator:SetScript("OnLeave", GameTooltip_Hide)
    reloadIndicator:Hide()
    settingsContainer.reloadIndicator = reloadIndicator

    local reloadPopup, reloadPopupInfo
    settingsContainer:HookScript("OnShow", function()
        GW.UpdateReloadIndicator()
        if reloadPopup and reloadPopup:IsShown() and reloadPopup.info == reloadPopupInfo then
            reloadPopup:Hide()
        end
    end)

    settingsContainer:SetScript("OnHide", function()
        GW.CloseActiveSettingsPreview()
        if not GW.InMoveHudMode and GW.ShowRlPopup then
            -- the pending list is NOT cleared here: if the reload is declined, the
            -- changes still require one - the hint stays and toggling a setting
            -- back to its original state still clears it correctly
            reloadPopupInfo = {text = L["One or more of the changes you have made require a UI reload."],
                OnAccept = function() C_UI.Reload() end,
                button1 = ACCEPT,
                button2 = CANCEL}
            reloadPopup = GW.ShowPopup(reloadPopupInfo)
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