---@class GW2
local GW = select(2, ...)
local L = GW.L

local BUTTONS = {
    [GAMEMENU_SUPPORT] = {sprite = {1, 1}},
    [BLIZZARD_STORE] = {sprite = {2, 1}},
    [GAMEMENU_NEW_BUTTON] = {sprite = {3, 1}},
    [GAMEMENU_OPTIONS] = {sprite = {4, 1}},
    [HUD_EDIT_MODE_MENU ]= {sprite = {1, 2}},
    [MACROS] = {sprite = {3, 2}},
    [ADDONS] = {sprite = {4, 2}},
    [EXIT_GAME] = {sprite = {2, 3}},
    [RETURN_TO_GAME] = {sprite = {3, 3}},
    [RATINGS_MENU] = {sprite = {3, 1}},
    ["MOVEANYTING"] = {sprite = {4, 1}}, -- Quick Fix for MoveAnything Menu Button -- hatdragon 15 June 2020
    [format(("*%s|r"):gsub("*", GW.Gw2Color), GW.addonName)] = {sprite = {4, 3}}
}
if LOGOUT then
    BUTTONS[LOGOUT] = {sprite = {1, 3}}
end
if LOG_OUT then
    BUTTONS[LOG_OUT] = {sprite = {1, 3}}
end

local ICON_SPRITES = {
    width = 128,
    height = 128,
    colums = 4,
    rows = 4
}

local function ToggleGw2Settings()
    if InCombatLockdown() then
        GW.Notice(L["Settings are not available in combat!"])
        return
    end
    if not GW.InMoveHudMode then
        ShowUIPanel(GwSettingsWindow)
        HideUIPanel(GameMenuFrame)
    end
end
GW.ToggleGw2Settings = ToggleGw2Settings

-- one time per frame: pool buttons are reused across InitButtons runs, everything
-- here survives the pool reset (textures, fonts, anchors)
local function styleButtonOnce(b)
    if b.gw2Styled then
        return
    end
    b.gw2Styled = true

    if b.Right then
        b.Right:Hide()
    end
    if b.Left then
        b.Left:Hide()
    end
    if b.Center then
        b.Center:Hide()
    end
    if b.Middle then
        b.Middle:Hide()
    end
    b:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/mainmenubutton.png")
    b:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/mainmenubutton.png")
    b:GetHighlightTexture():SetBlendMode("ADD")

    if b.GetFontString and b:GetFontString() then
        local fontString = b:GetFontString()
        fontString:ClearAllPoints()
        fontString:SetPoint("LEFT", b, "LEFT", 32, 0)
        fontString:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)

        local gwFontObject = fontString.GetFontObject and fontString:GetFontObject()
        if gwFontObject then
            b:SetNormalFontObject(gwFontObject)
            b:SetHighlightFontObject(gwFontObject)
            b:SetDisabledFontObject(gwFontObject)
        end
    end

    local tex = b:CreateTexture(nil, "OVERLAY")
    tex:SetPoint("LEFT", b, "LEFT", 0, 0)
    tex:SetSize(32, 32)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/icons/mainmenuicons.png")
    b.gw2IconTex = tex
end

local function applyButtonStyle(b)
    styleButtonOnce(b)

    if not InCombatLockdown() then
        b:SetSize(180, 25)
    end

    local buttonSprint = BUTTONS[b:GetText()]
    if buttonSprint then
        b.gw2IconTex:SetTexCoord(GW.getSprite(ICON_SPRITES, buttonSprint.sprite[1], buttonSprint.sprite[2]))
        b.gw2IconTex:Show()
    else
        b.gw2IconTex:Hide()
    end
end

local function SkinMainMenu()
    local r = {GameMenuFrame:GetRegions()}
    for _, c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:Hide()
        end
    end
    GameMenuFrame:GwCreateBackdrop(nil)

    local tex = GameMenuFrame:CreateTexture(nil, "BACKGROUND")
    tex:SetPoint("TOP", GameMenuFrame, "TOP", 0, -30)
    tex:SetSize(286, 525)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/mainmenubg.png")

    GameMenuFrame.Border:Hide()
    GameMenuFrame.Header:Hide()

    GameMenuFrame:SetScale(0.9)

    for _, Button in next, { _G.GameMenuFrame:GetChildren() } do
        if Button.IsObjectType and Button:IsObjectType('Button') then
            applyButtonStyle(Button)
        end
    end

    local settingsButton
    hooksecurefunc(GameMenuFrame, 'InitButtons', function(self)
        if not self.buttonPool then return end

        if not settingsButton then
            settingsButton = CreateFrame("Button", "GW2_UI_SettingsButton", self, self.buttonTemplate)
            settingsButton:SetText(format(("*%s|r"):gsub("*", GW.Gw2Color), GW.addonName))
            settingsButton:SetScript("OnClick", ToggleGw2Settings)
            applyButtonStyle(settingsButton)
        end

        local lastLayoutIndex = 0
        for btn in self.buttonPool:EnumerateActive() do
            if btn.layoutIndex and btn.layoutIndex > lastLayoutIndex then
                lastLayoutIndex = btn.layoutIndex
            end
            applyButtonStyle(btn)
        end

        settingsButton.layoutIndex = lastLayoutIndex + 1
        settingsButton.topPadding = 20
    end)

    -- re-apply the button sizes that were skipped while in combat
    local regenWatcher = CreateFrame("Frame")
    regenWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
    regenWatcher:SetScript("OnEvent", function()
        if GameMenuFrame:IsShown() and GameMenuFrame.buttonPool then
            for btn in GameMenuFrame.buttonPool:EnumerateActive() do
                applyButtonStyle(btn)
            end
            if settingsButton then
                applyButtonStyle(settingsButton)
            end
        end
    end)

    -- remove elvui transparent bg if ours is enabled
    if C_AddOns.IsAddOnLoaded("ElvUI") then
        _G.GameMenuFrame.backdrop:Hide()
    end
end
GW.SkinMainMenu = SkinMainMenu
