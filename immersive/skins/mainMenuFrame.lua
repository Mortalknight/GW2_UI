local _, GW = ...
local L = GW.L

local BUTTONS = {
    {button = _G.GameMenuButtonHelp, sprite={1,1}},
    {button = _G.GameMenuButtonStore, sprite={2,1}},
    {button = _G.GameMenuButtonWhatsNew, sprite={3,1}},
    {button = _G.GameMenuButtonOptions, sprite={4,1}},
    {button = _G.GameMenuButtonUIOptions, sprite={1,2}},
    {button = _G.GameMenuButtonKeybindings, sprite={2,2}},
    {button = _G.GameMenuButtonMacros, sprite={3,2}},
    {button = _G.GameMenuButtonAddons, sprite={4,2}},
    {button = _G.GameMenuButtonLogout, sprite={1,3}},
    {button = _G.GameMenuButtonQuit, sprite={2,3}},
    {button = _G.GameMenuButtonContinue, sprite={3,3}},
    {button = _G.GameMenuButtonRatings, sprite={3,1}}
}

local ICON_SPRITES = {
    width = 128,
    height = 128,
    colums = 4,
    rows = 4
}

local function applyButtonStyle()
    for _, f in pairs(BUTTONS) do
        local b = f.button
        if b ~= nil then
            b.Right:Hide()
            b.Left:Hide()
            b.Middle:Hide()
            b:SetNormalTexture("Interface/AddOns/GW2_UI/textures/mainmenubutton")
            b:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/mainmenubutton")
            b.Text:ClearAllPoints()
            b.Text:SetPoint("LEFT", b, "LEFT", 32,0)
            b:SetSize(150, 25)

            local tex = b:CreateTexture("bg", "OVERLAY")
            tex:SetPoint("LEFT", b, "LEFT", 0, 0)
            tex:SetSize(32,32)
            tex:SetTexture("Interface/AddOns/GW2_UI/textures/mainmenuicons")
            tex:SetTexCoord(GW.getSprite(ICON_SPRITES, f.sprite[1], f.sprite[2]))

            local r = {b:GetRegions()}
            for _, c in pairs(r) do
                if c:GetObjectType() == "Texture" and c:GetName() == nil then
                    c:SetTexCoord(0, 1, 0, 1)
                    c:SetSize(155, 30)
                end
            end
        end
    end
end

local function SkinMainMenu()
    local GameMenuFrame = _G.GameMenuFrame

    local GwMainMenuFrame = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate")
    GwMainMenuFrame:SetText(L["SETTINGS_BUTTON"])
    GwMainMenuFrame:ClearAllPoints()
    GwMainMenuFrame:SetPoint("TOP", GameMenuFrame, "BOTTOM", 0, 0)
    GwMainMenuFrame:SetSize(150, 24)
    GwMainMenuFrame:SetScript(
        "OnClick",
        function()
            if InCombatLockdown() then
                DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r " .. L["HIDE_SETTING_IN_COMBAT"])
                return
            end
            GwSettingsWindow:Show()
            ToggleGameMenu()
        end
    )
    BUTTONS[#BUTTONS + 1] = {button = GwMainMenuFrame, sprite = {4, 3} }
    GwMainMenuFrame:SetPoint("TOP", _G.GameMenuButtonContinue, "BOTTOM", 0, -1)

    local r = {GameMenuFrame:GetRegions()}
    for _, c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:Hide()
        end
    end
    GameMenuFrame:SetBackdrop(nil)

    local tex = GameMenuFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", GameMenuFrame, "TOP", 0, -10)
    tex:SetSize(256, 512)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/mainmenubg")

    GameMenuFrame.Border:Hide()
    GameMenuFrame.Header:Hide()
    if _G.GameMenuFrameHeader then
        _G.GameMenuFrameHeader:Hide()
    end

    applyButtonStyle()
end
GW.SkinMainMenu = SkinMainMenu