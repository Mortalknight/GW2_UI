local _, GW = ...
local L = GW.L

local BUTTONS = {
    [GAMEMENU_SUPPORT] = {sprite = {1, 1}},
    [BLIZZARD_STORE] = {sprite = {2, 1}},
    [GAMEMENU_NEW_BUTTON] = {sprite = {3, 1}},
    [GAMEMENU_OPTIONS] = {sprite = {4, 1}},
    [HUD_EDIT_MODE_MENU ]= {sprite = {1, 2}},
    [MACROS] = {sprite = {3, 2}},
    [ADDONS] = {sprite = {4, 2}},
    [LOG_OUT] = {sprite = {1, 3}},
    [EXIT_GAME] = {sprite = {2, 3}},
    [RETURN_TO_GAME] = {sprite = {3, 3}},
    [RATINGS_MENU] = {sprite = {3, 1}},
    ["MOVEANYTING"] = {sprite = {4, 1}}, -- Quick Fix for MoveAnything Menu Button -- hatdragon 15 June 2020
    [format(("*%s|r"):gsub("*", GW.Gw2Color), GW.addonName)] = {sprite = {4, 3}}
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

local function applyButtonStyle(b)
    if b.Right then
        b.Right:Hide()
    end
    if b.Left then
        b.Left:Hide()
    end
    if b.Center then
        b.Center:Hide()
    end
    b:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/mainmenubutton")
    b:ClearHighlightTexture()
    if b.GetFontString and b:GetFontString() then
        b:GetFontString():ClearAllPoints()
        b:GetFontString():SetPoint("LEFT", b, "LEFT", 32,0)
    end
    b:SetSize(180, 25)
    b:HookScript("OnEnter", function()
        b:GetNormalTexture():SetBlendMode("ADD")
    end)
    b:HookScript("OnLeave", function()
        b:GetNormalTexture():SetBlendMode("BLEND")
    end)
    if not b.gw2IconTex then
        local tex = b:CreateTexture(nil, "OVERLAY")
        tex:SetPoint("LEFT", b, "LEFT", 0, 0)
        tex:SetSize(32, 32)
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/icons/mainmenuicons")
        b.gw2IconTex = tex
    end
    local buttonSprint = BUTTONS[b:GetText()]
    if buttonSprint then
        b.gw2IconTex:SetTexCoord(GW.getSprite(ICON_SPRITES, buttonSprint.sprite[1], buttonSprint.sprite[2]))
    end
    --TODO: MAYBE Remove PushedTextOffset:  current -2, -1
end

local function SkinMainMenu()
    local GameMenuFrame = _G.GameMenuFrame

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
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/mainmenubg")

    GameMenuFrame.Border:Hide()
    GameMenuFrame.Header:Hide()

    GameMenuFrame:SetScale(0.9)

    for _, Button in next, { _G.GameMenuFrame:GetChildren() } do
        if Button.IsObjectType and Button:IsObjectType('Button') then
            applyButtonStyle(Button)
        end
    end

    hooksecurefunc(GameMenuFrame, 'InitButtons', function(self)
        if not self.buttonPool then return end

        self:AddSection()
        self:AddButton(format(("*%s|r"):gsub("*", GW.Gw2Color), GW.addonName), ToggleGw2Settings)

        for btn in self.buttonPool:EnumerateActive() do
            applyButtonStyle(btn)
        end
    end)

    -- remove elvui transparent bg if ours is enabled
    if C_AddOns.IsAddOnLoaded("ElvUI") then
        _G.GameMenuFrame.backdrop:Hide()
    end
end
GW.SkinMainMenu = SkinMainMenu
