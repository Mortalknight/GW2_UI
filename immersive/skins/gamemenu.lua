local _, GW = ...
local L = GW.L

local BUTTONS = {
    {button = _G.GameMenuButtonHelp         , sprite = {1, 1}},
    {button = _G.GameMenuButtonOptions      , sprite = {4, 1}},
    {button = _G.GameMenuButtonUIOptions    , sprite = {1, 2}},
    {button = _G.GameMenuButtonKeybindings  , sprite = {2, 2}},
    {button = _G.GameMenuButtonMacros       , sprite = {3, 2}},
    {button = _G.GameMenuButtonAddons       , sprite = {4, 2}},
    {button = _G.GameMenuButtonLogout       , sprite = {1, 3}},
    {button = _G.GameMenuButtonQuit         , sprite = {2, 3}},
    {button = _G.GameMenuButtonContinue     , sprite = {3, 3}},
    {button = _G.GameMenuButtonRatings      , sprite = {3, 1}},
    {button = _G.GameMenuButtonMoveAnything , sprite = {4, 1}} -- Quick Fix for MoveAnything Menu Button -- hatdragon 15 June 2020
}

local ICON_SPRITES = {
    width = 128,
    height = 128,
    colums = 4,
    rows = 4
}

local function PositionGameMenuButton()
    GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() - 4)
    local _, relTo, _, _, offY = GameMenuButtonKeybindings:GetPoint()
    if relTo ~= GameMenuFrame[GW.addonName] then
        GameMenuFrame[GW.addonName]:ClearAllPoints()
        GameMenuFrame[GW.addonName]:SetPoint("TOPLEFT", relTo, "BOTTOMLEFT", 0, -1)
        GameMenuButtonKeybindings:ClearAllPoints()
        GameMenuButtonKeybindings:SetPoint("TOPLEFT", GameMenuFrame[GW.addonName], "BOTTOMLEFT", 0, offY)
    end
end
GW.PositionGameMenuButton = PositionGameMenuButton

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
            b.Text:SetPoint("LEFT", b, "LEFT", 32, 0)
            b:SetSize(150, 25)

            local tex = b:CreateTexture("bg", "OVERLAY")
            tex:SetPoint("LEFT",b ,"LEFT" , 0, 0)
            tex:SetSize(32, 32)
            tex:SetTexture("Interface/AddOns/GW2_UI/textures/mainmenuicons")
            tex:SetTexCoord(GW.getSprite(ICON_SPRITES, f.sprite[1], f.sprite[2]))

            local r = {b:GetRegions()}
            for _, c in pairs(r) do
                if c:GetObjectType() == "Texture" and c:GetName() == nil then
                    c:SetTexCoord(unpack(GW.TexCoords))
                    c:SetSize(155, 30)
                end
            end
        end
    end
end

local function SkinMainMenu()
    local GameMenuFrame = _G.GameMenuFrame

    local GwMainMenuFrame = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate")
    GwMainMenuFrame:SetText(format(("*%s|r"):gsub("*", GW.Gw2Color), GW.addonName))
    GwMainMenuFrame:SetScript(
        "OnClick",
        function()
            if InCombatLockdown() then
                DEFAULT_CHAT_FRAME:AddMessage(("*GW2 UI:|r " .. L["Settings are not available in combat!"]):gsub("*", GW.Gw2Color))
                return
            end
            ShowUIPanel(GwSettingsWindow)
            UIFrameFadeIn(GwSettingsWindow, 0.2, 0, 1)
            HideUIPanel(GameMenuFrame)
        end
    )
    GameMenuFrame[GW.addonName] = GwMainMenuFrame
    BUTTONS[#BUTTONS + 1] = {button = GwMainMenuFrame, sprite = {4, 3}}

    if not IsAddOnLoaded("ConsolePortUI_Menu") then
        GwMainMenuFrame:SetSize(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
        GwMainMenuFrame:SetPoint("TOPLEFT", GameMenuButtonAddons, "BOTTOMLEFT", 0, -1)
        hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", PositionGameMenuButton)
    end

    local r = {GameMenuFrame:GetRegions()}
    for _, c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:Hide()
        end
    end
    GameMenuFrame:SetBackdrop(nil)

    local tex = GameMenuFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", GameMenuFrame, "TOP", 0, -10)
    tex:SetSize(256, 464)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/mainmenubg")

    GameMenuFrameHeader:Hide()

    applyButtonStyle()

    -- remove elvui transparent bg if ours is enabled
    if IsAddOnLoaded("ElvUI") and GameMenuFrame.backdrop then
        GameMenuFrame.backdrop:Hide()
    end
end
GW.SkinMainMenu = SkinMainMenu