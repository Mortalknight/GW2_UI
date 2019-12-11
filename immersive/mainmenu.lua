local _, GW = ...

-------------------------------------------------------Skin functions-------------------------------------------------------
local function addHoverToButton(self)
    if not self.hover then
        local hover = self:CreateTexture("hover", "ARTWORK")
        hover:SetPoint("LEFT", self, "LEFT")
        hover:SetPoint("TOP", self, "TOP")
        hover:SetPoint("BOTTOM", self, "BOTTOM")
        hover:SetPoint("RIGHT", self, "RIGHT")
        hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\button_hover")
        self.hover = hover
        self.hover:SetAlpha(0)

        self:SetScript("OnEnter", GwStandardButton_OnEnter)
        self:SetScript("OnLeave", GwStandardButton_OnLeave)
    end
end

local constBackdropFrame = {
	bgFile = "Interface\\AddOns\\GW2_UI\\textures\\UI-Tooltip-Background",
	edgeFile = "Interface\\AddOns\\GW2_UI\\textures\\UI-Tooltip-Border",
	tile = false,
	tileSize = 64,
	edgeSize = 32,
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local constBackdropFrame2 = {
	bgFile = "Interface\\AddOns\\GW2_UI\\textures\\party\\manage-group-bg",
	tile = false,
	tileSize = 64,
	edgeSize = 32,
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

-------------------------------------------------------Skin GameMenuFrame-------------------------------------------------------
local BUTTONS = {
    {button = GameMenuButtonHelp, sprite={1,1} },
    {button = GameMenuButtonOptions, sprite={4,1} },
    {button = GameMenuButtonUIOptions, sprite={1,2} },
    {button = GameMenuButtonKeybindings, sprite={2,2} },
    {button = GameMenuButtonMacros, sprite={3,2} },
    {button = GameMenuButtonAddons, sprite={4,2} },
    {button = GameMenuButtonLogout, sprite={1,3} },
    {button = GameMenuButtonQuit, sprite={2,3} },
    {button = GameMenuButtonContinue, sprite={3,3} },
    {button = GameMenuButtonRatings, sprite={3,1} }
}

local ICON_SPRITES = {
 width = 128,
 height = 128,
 colums = 4,
 rows = 4
}

local function applyButtonStyle()
    for _,f in pairs(BUTTONS) do
        local b = f.button
        if b ~= nil then

            b.Right:Hide()
            b.Left:Hide()
            b.Middle:Hide()
            b:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\mainmenubutton")
            b:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\mainmenubutton")
            b.Text:ClearAllPoints()
            b.Text:SetPoint("LEFT", b, "LEFT", 32, 0)
            b:SetSize(150,25)

            local tex = b:CreateTexture("bg", "OVERLAY")
            tex:SetPoint("LEFT",b ,"LEFT" , 0, 0)
            tex:SetSize(32, 32)
            tex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\mainmenuicons")
            tex:SetTexCoord(GW.getSprite(ICON_SPRITES, f.sprite[1], f.sprite[2]))

            local r = {b:GetRegions()}
            for _,c in pairs(r) do
                if c:GetObjectType() == "Texture" and c:GetName() == nil then
                    c:SetTexCoord(0, 1, 0, 1)
                    c:SetSize(155, 30)
                end
            end
        end
    end
end

local function SkinMainMenu()
    --Setup addon button
    GwMainMenuFrame = CreateFrame("Button", "GwMainMenuFrame", GameMenuFrame, "GameMenuButtonTemplate")
    GwMainMenuFrame:SetText(GwLocalization["SETTINGS_BUTTON"])
    GwMainMenuFrame:ClearAllPoints()
    GwMainMenuFrame:SetPoint("TOP", GameMenuFrame, "BOTTOM", 0, 0)
    GwMainMenuFrame:SetSize(150, 24)
    GwMainMenuFrame:SetScript(
        "OnClick",
        function()
            GwSettingsWindow:Show()
            if InCombatLockdown() then
                return
            end
            ToggleGameMenu()
        end
    )
    BUTTONS[#BUTTONS + 1] = {button = GwMainMenuFrame, sprite = {4, 3}}
    GwMainMenuFrame:SetPoint("TOP", GameMenuButtonContinue, "BOTTOM", 0, -1)

    local r = {GameMenuFrame:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:Hide()
        end
    end
    GameMenuFrame:SetBackdrop(nil)

    local tex = GameMenuFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", GameMenuFrame, "TOP", 0, -10)
    tex:SetSize(256, 464)
    tex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\mainmenubg")

    GameMenuFrameHeader:Hide()

    applyButtonStyle()
end
GW.SkinMainMenu = SkinMainMenu

-------------------------------------------------------Skin Staticpopup-------------------------------------------------------
local function SkinStaticPopup()
    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]

        StaticPopup:SetBackdrop(constBackdropFrame2)
        StaticPopup.CoverFrame:Hide()
        StaticPopup.Separator:Hide()

        --Style Buttons (upto 5)
        for ii = 1, 5 do
            if ii < 5 then
                _G["StaticPopup" .. i .. "Button" .. ii]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "Button" .. ii]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\button_hover")
                _G["StaticPopup" .. i .. "Button" .. ii]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "Button" .. ii]:SetDisabledTexture("Interface\\AddOns\\GW2_UI\\textures\\button_disable")
                _G["StaticPopup" .. i .. "Button" .. ii]:GetHighlightTexture():SetVertexColor(0, 0, 0)
                _G["StaticPopup" .. i .. "Button" .. ii .. "Text"]:SetTextColor(0, 0, 0, 1)
                _G["StaticPopup" .. i .. "Button" .. ii .. "Text"]:SetShadowOffset(0, 0)
                _G["StaticPopup" .. i .. "Button" .. ii .. "Text"]:SetDrawLayer("OVERLAY")
            else
                _G["StaticPopup" .. i .. "ExtraButton"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "ExtraButton"]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\button_hover")
                _G["StaticPopup" .. i .. "ExtraButton"]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "ExtraButton"]:SetDisabledTexture("Interface\\AddOns\\GW2_UI\\textures\\button_disable")
                _G["StaticPopup" .. i .. "ExtraButton"]:GetHighlightTexture():SetVertexColor(0, 0, 0)
                _G["StaticPopup" .. i .. "ExtraButtonText"]:SetTextColor(0, 0, 0, 1)
                _G["StaticPopup" .. i .. "ExtraButtonText"]:SetShadowOffset(0, 0)
            end
        end

        --Change EditBox
        _G["StaticPopup" .. i .. "EditBoxLeft"]:Hide()
        _G["StaticPopup" .. i .. "EditBoxRight"]:Hide()
        _G["StaticPopup" .. i .. "EditBoxMid"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar-bg")
        _G["StaticPopup" .. i .. "EditBoxMid"]:ClearAllPoints()
        _G["StaticPopup" .. i .. "EditBoxMid"]:SetPoint("TOPLEFT", _G["StaticPopup" .. i .. "EditBoxLeft"],"BOTTOMRIGHT", -25, 3)
        _G["StaticPopup" .. i .. "EditBoxMid"]:SetPoint("BOTTOMRIGHT", _G["StaticPopup" .. i .. "EditBoxRight"],"TOPLEFT", 25, -3)

        _G["StaticPopup" .. i .. "AlertIcon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\warning-icon") 
    end
end
GW.SkinStaticPopup = SkinStaticPopup

-------------------------------------------------------BNToastFrame-------------------------------------------------------
local function resizeBNToastFrame()
    local BNToastFrame = _G["BNToastFrame"]
    BNToastFrame.tex:SetSize(BNToastFrame:GetSize())
end

local function SkinBNToastFrame()
    local BNToastFrame = _G["BNToastFrame"]

    BNToastFrame:SetBackdrop(nil)

    local tex = BNToastFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", BNToastFrame, "TOP", 0, 0)
    tex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\manage-group-bg")
    tex:SetSize(BNToastFrame:GetSize())
    BNToastFrame.tex = tex

    BNToastFrame.CloseButton:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-normal")
    BNToastFrame.CloseButton:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-hover")
    BNToastFrame.CloseButton:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-hover")

    BNToastFrame:HookScript("OnShow", resizeBNToastFrame)
end
GW.SkinBNToastFrame = SkinBNToastFrame

-------------------------------------------------------DropDownList-------------------------------------------------------
local function UIDropDownMenu_OnUpdate(self)
    _G[self:GetName() .. "Backdrop"]:Hide()
    _G[self:GetName() .. "MenuBackdrop"]:Hide()
    self:SetBackdrop(constBackdropFrame)
    for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
        if _G[self:GetName() .. "Button" .. i .. "ExpandArrow"] then
            _G[self:GetName() .. "Button" .. i .. "ExpandArrow"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\arrow_right")
        end
    end
end

local function SkinDropDownList()
    hooksecurefunc("UIDropDownMenu_OnUpdate", UIDropDownMenu_OnUpdate)
end
GW.SkinDropDownList = SkinDropDownList

-------------------------------------------------------UIDropDownMenu-------------------------------------------------------
local function SkinUIDropDownMenu_Initialize(self)
    if self.Left then self.Left:Hide() end
    if self.Middle then self.Middle:Hide() end
    if self.Right then self.Right:Hide() end

    if self.Button then
        self.Button.NormalTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
        self.Button:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
        self.Button:SetDisabledTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
        self.Button:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    end

    if self.Left and self.Right then
        local tex = self:CreateTexture("bg", "BACKGROUND")
        tex:SetPoint("TOP", self, "TOP", 0, 0)
        tex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
        tex:SetPoint("TOPLEFT", self.Left, "BOTTOMRIGHT", 0, 23)
        tex:SetPoint("BOTTOMRIGHT", self.Right, "TOPLEFT", 10, -20)
        tex:SetVertexColor(0, 0, 0)
        self.tex = tex
    end
end

local function SkinUIDropDownMenu()
    hooksecurefunc("UIDropDownMenu_Initialize", SkinUIDropDownMenu_Initialize)
end
GW.SkinUIDropDownMenu = SkinUIDropDownMenu