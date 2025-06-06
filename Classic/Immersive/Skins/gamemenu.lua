local _, GW = ...
local L = GW.L
local hookDone = false

local BUTTONS = {
    {button = _G.GameMenuButtonHelp         , sprite = {1, 1}},
    {button = _G.GameMenuButtonStore        , sprite = {2, 1}},
    {button = _G.GameMenuButtonOptions      , sprite = {4, 1}},
    {button = _G.GameMenuButtonUIOptions    , sprite = {1, 2}},
    {button = _G.GameMenuButtonKeybindings  , sprite = {2, 2}},
    {button = _G.GameMenuButtonMacros       , sprite = {3, 2}},
    {button = _G.GameMenuButtonAddons       , sprite = {4, 2}},
    {button = _G.GameMenuButtonLogout       , sprite = {1, 3}},
    {button = _G.GameMenuButtonQuit         , sprite = {2, 3}},
    {button = _G.GameMenuButtonContinue     , sprite = {3, 3}},
    {button = _G.GameMenuButtonRatings      , sprite = {3, 1}},
    {button = _G.GameMenuButtonMoveAnything , sprite = {4, 1}}, -- Quick Fix for MoveAnything Menu Button -- hatdragon 15 June 2020
    {button = btn163                        , sprite = {4, 2}, onHook = true, addOn = "!!!EaseAddonController"},
    {button = _G.GameMenuFrame              , sprite = {4, 2}},
}

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

local function PositionGameMenuButton()
    GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() - 4)
    local _, relTo, _, _, offY = GameMenuButtonMacros:GetPoint()
    if relTo ~= GameMenuFrame[GW.addonName] then
        GameMenuFrame[GW.addonName]:ClearAllPoints()
        GameMenuFrame[GW.addonName]:SetPoint("TOPLEFT", relTo, "BOTTOMLEFT", 0, -1)
        GameMenuButtonMacros:ClearAllPoints()
        GameMenuButtonMacros:SetPoint("TOPLEFT", GameMenuFrame[GW.addonName], "BOTTOMLEFT", 0, offY)
    end
end
GW.PositionGameMenuButton = PositionGameMenuButton

local function applyButtonStyle()
    for _, f in pairs(BUTTONS) do
        if f.onHook and not hookDone then
            GameMenuFrame:HookScript("OnShow", function()
                if not hookDone then
                    applyButtonStyle()
                    hookDone= true
                end
            end)
        end
        local b = f.button
        if b == _G.GameMenuFrame then b = b.ElvUI end
        if b == btn163 and f.addOn and C_AddOns.IsAddOnLoaded(f.addOn) then b = GameMenuFrame.btn163 end
        if b then
            if b == GameMenuFrame.btn163 then b.logo:Hide() end
            b.Right:Hide()
            b.Left:Hide()
            b.Middle:Hide()
            b:SetNormalTexture("Interface/AddOns/GW2_UI/textures/mainmenubutton")
            b:ClearHighlightTexture()
            b.Text:ClearAllPoints()
            b.Text:SetPoint("LEFT", b, "LEFT", 32,0)
            b:SetSize(150, 25)
            b:HookScript("OnEnter", function()
                b:GetNormalTexture():SetBlendMode("ADD")
            end)
            b:HookScript("OnLeave", function()
                b:GetNormalTexture():SetBlendMode("BLEND")
            end)
            local tex = b:CreateTexture(nil, "OVERLAY")
            tex:SetPoint("LEFT", b, "LEFT", 0, 0)
            tex:SetSize(32, 32)
            tex:SetTexture("Interface/AddOns/GW2_UI/textures/mainmenuicons")
            tex:SetTexCoord(GW.getSprite(ICON_SPRITES, f.sprite[1], f.sprite[2]))
        end
    end
end

local function SkinMainMenu()
    local GameMenuFrame = _G.GameMenuFrame

    local GwMainMenuFrame = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate")
    GwMainMenuFrame:SetText(format(("*%s|r"):gsub("*", GW.Gw2Color), GW.addonName))
    GwMainMenuFrame:SetScript("OnClick", ToggleGw2Settings)
    GameMenuFrame[GW.addonName] = GwMainMenuFrame
    BUTTONS[#BUTTONS + 1] = {button = GwMainMenuFrame, sprite = {4, 3}}

    if not C_AddOns.IsAddOnLoaded("ConsolePortUI_Menu") then
        GwMainMenuFrame:SetSize(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
        GwMainMenuFrame:SetPoint("TOPLEFT", GameMenuButtonUIOptions, "BOTTOMLEFT", 0, -1)
        hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", PositionGameMenuButton)
    end

    local r = {GameMenuFrame:GetRegions()}
    for _, c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:Hide()
        end
    end
    GameMenuFrame:StripTextures()
    GameMenuFrame:CreateBackdrop(nil)

    local tex = GameMenuFrame:CreateTexture(nil, "BACKGROUND")
    tex:SetPoint("TOP", GameMenuFrame, "TOP", 0, -10)
    tex:SetSize(256, 464)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/mainmenubg")

    GameMenuFrameHeader:Hide()

    applyButtonStyle()

    -- remove elvui transparent bg if ours is enabled
    if C_AddOns.IsAddOnLoaded("ElvUI") then
        _G.GameMenuFrame.backdrop:Hide()
    end
end
GW.SkinMainMenu = SkinMainMenu
