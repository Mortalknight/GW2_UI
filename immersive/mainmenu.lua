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

-------------------------------------------------------Skin GameMenuFrame-------------------------------------------------------
local BUTTONS = {
    {button = GameMenuButtonHelp, sprite={1,1}},
    {button = GameMenuButtonStore, sprite={2,1}},
    {button = GameMenuButtonWhatsNew, sprite={3,1}},
    {button = GameMenuButtonOptions, sprite={4,1}},
    {button = GameMenuButtonUIOptions, sprite={1,2}},
    {button = GameMenuButtonKeybindings, sprite={2,2}},
    {button = GameMenuButtonMacros, sprite={3,2}},
    {button = GameMenuButtonAddons, sprite={4,2}},
    {button = GameMenuButtonLogout, sprite={1,3}},
    {button = GameMenuButtonQuit, sprite={2,3}},
    {button = GameMenuButtonContinue, sprite={3,3}},
    {button = GameMenuButtonRatings, sprite={3,1}}
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
            b.Text:SetPoint("LEFT",b,"LEFT", 32,0)
            b:SetSize(150,25)

            local tex = b:CreateTexture("bg", "OVERLAY")
            tex:SetPoint("LEFT",b,"LEFT",0,0)
            tex:SetSize(32,32)
            tex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\mainmenuicons")
            tex:SetTexCoord(GW.getSprite(ICON_SPRITES, f.sprite[1], f.sprite[2]))

            local r = {b:GetRegions()}
            for _,c in pairs(r) do
                if c:GetObjectType()=="Texture" and c:GetName()==nil then
                    c:SetTexCoord(0,1,0,1)
                    c:SetSize(155,30)
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
    BUTTONS[#BUTTONS + 1] = {button = GwMainMenuFrame, sprite={4,3} }
    GwMainMenuFrame:SetPoint("TOP",GameMenuButtonContinue,"BOTTOM",0,-1)

    local r = {GameMenuFrame:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType()=="FontString" then
            c:Hide()
        end
    end
    GameMenuFrame:SetBackdrop(nil)

    local tex = GameMenuFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP",GameMenuFrame,"TOP",0,-10)
    tex:SetSize(256,512)
    tex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\mainmenubg")

    GameMenuFrame.Border:Hide()
    GameMenuFrameHeader:Hide()

    applyButtonStyle()
end
GW.SkinMainMenu = SkinMainMenu

-------------------------------------------------------Skin Staticpopup-------------------------------------------------------
local function gwSetStaticPopupSize()
    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]
        StaticPopup.tex:SetSize(StaticPopup:GetSize())
        _G["StaticPopup" .. i .. "AlertIcon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\warning-icon") 
        for ii = 1, 5 do
            if ii < 5 then
                addHoverToButton(_G["StaticPopup" .. i .. "Button" .. ii])
            else
                addHoverToButton(_G["StaticPopup" .. i .. "ExtraButton"])
            end
        end
    end
end

local function SkinStaticPopup()
    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]

        StaticPopup:SetBackdrop(nil)
        StaticPopup.CoverFrame:Hide()
        StaticPopup.Separator:Hide()
        StaticPopup.Border:Hide()

        local tex = StaticPopup:CreateTexture("bg", "BACKGROUND")
        tex:SetPoint("TOP", StaticPopup, "TOP", 0, 0)
        tex:SetSize(StaticPopup:GetSize())
        tex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\manage-group-bg")
        StaticPopup.tex = tex

        --Style Buttons (upto 5)
        for ii = 1, 5 do
            if ii < 5 then
                _G["StaticPopup" .. i .. "Button" .. ii]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "Button" .. ii]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "Button" .. ii]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "Button" .. ii]:SetDisabledTexture("Interface\\AddOns\\GW2_UI\\textures\\button_disable")
                _G["StaticPopup" .. i .. "Button" .. ii]:GetHighlightTexture():SetVertexColor(0, 0, 0)
                _G["StaticPopup" .. i .. "Button" .. ii .. "Text"]:SetTextColor(0, 0, 0, 1)
                _G["StaticPopup" .. i .. "Button" .. ii .. "Text"]:SetShadowOffset(0, 0)
            else
                _G["StaticPopup" .. i .. "ExtraButton"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "ExtraButton"]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
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
    end

    hooksecurefunc("StaticPopup_OnUpdate", gwSetStaticPopupSize)
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

-------------------------------------------------------GhostFrame-------------------------------------------------------
local function SkinGhostFrame()
    local GhostFrame = _G["GhostFrame"]

    local tex = GhostFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", GhostFrame, "TOP", 0, 0)
    tex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
    tex:SetSize(_G["GhostFrameContentsFrame"]:GetSize())
    GhostFrame.tex = tex
    addHoverToButton(GhostFrame)

    _G["GhostFrameContentsFrameText"]:SetTextColor(0, 0, 0, 1)
    _G["GhostFrameContentsFrameText"]:SetShadowOffset(0, 0)

    _G["GhostFrameContentsFrameIcon"]:SetTexture("Interface\\Icons\\spell_holy_guardianspirit")
    _G["GhostFrameContentsFrameIcon"]:ClearAllPoints()
    _G["GhostFrameContentsFrameIcon"]:SetPoint("RIGHT", _G["GhostFrameContentsFrameText"], "LEFT", -5, 0)
    _G["GhostFrameContentsFrameIcon"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    GhostFrame:SetScript("OnMouseUp", nil)
    GhostFrame:SetScript("OnMouseDown", nil)

    local r = {_G["GhostFrame"]:GetRegions()}
    local i = 1
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" and i < 7 then
           c:Hide()
        end
        i = i + 1
    end
end
GW.SkinGhostFrame = SkinGhostFrame

-------------------------------------------------------QueueStatusFrame-------------------------------------------------------
local function SkinQueueStatusFrame()
    local QueueStatusFrame = _G["QueueStatusFrame"]

    QueueStatusFrame:SetBackdrop(nil)
    QueueStatusFrame.BorderTopLeft:Hide()
    QueueStatusFrame.BorderTopRight:Hide()
    QueueStatusFrame.BorderBottomRight:Hide()
    QueueStatusFrame.BorderBottomLeft:Hide()
    QueueStatusFrame.BorderTop:Hide()
    QueueStatusFrame.BorderRight:Hide()
    QueueStatusFrame.BorderBottom:Hide()
    QueueStatusFrame.BorderLeft:Hide()
    QueueStatusFrame.Background:Hide()
    QueueStatusFrame:SetBackdrop(constBackdropFrame)
end
GW.SkinQueueStatusFrame = SkinQueueStatusFrame

-------------------------------------------------------DeathRecapFrame-------------------------------------------------------
local function SkinDeathRecapFrame_Loaded()
    local DeathRecapFrame = _G["DeathRecapFrame"]

    DeathRecapFrame.CloseButton:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
    DeathRecapFrame.CloseButton:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
    DeathRecapFrame.CloseButton:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
    DeathRecapFrame.CloseButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    local r = {DeathRecapFrame.CloseButton:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType()=="FontString" then
            c:SetTextColor(0, 0, 0, 1)
            c:SetShadowOffset(0, 0)
        end
    end
    addHoverToButton(DeathRecapFrame.CloseButton)

    DeathRecapFrame.CloseXButton:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-normal")
    DeathRecapFrame.CloseXButton:SetDisabledTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-normal")
    DeathRecapFrame.CloseXButton:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-hover")
    DeathRecapFrame.CloseXButton:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\window-close-button-hover")
    DeathRecapFrame.CloseXButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    DeathRecapFrame.CloseXButton:SetSize(20, 20)
    DeathRecapFrame.CloseXButton:ClearAllPoints()
    DeathRecapFrame.CloseXButton:SetPoint("TOPRIGHT", -3, -3)

    DeathRecapFrame:SetBackdrop(nil)
    DeathRecapFrame:SetBackdrop(constBackdropFrame)
    _G["DeathRecapFrameBorderTopLeft"]:Hide()
    _G["DeathRecapFrameBorderTopRight"]:Hide()
    _G["DeathRecapFrameBorderBottomLeft"]:Hide()
    _G["DeathRecapFrameBorderBottomRight"]:Hide()
    _G["DeathRecapFrameBorderTop"]:Hide()
    _G["DeathRecapFrameBorderBottom"]:Hide()
    _G["DeathRecapFrameBorderLeft"]:Hide()
    _G["DeathRecapFrameBorderRight"]:Hide()
    DeathRecapFrame.BackgroundInnerGlow:Hide()
    DeathRecapFrame.Background:Hide()
    DeathRecapFrame.Divider:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\chatbubbles\\border-bottom")
    DeathRecapFrame.Divider:ClearAllPoints()
    DeathRecapFrame.Divider:SetPoint("TOPLEFT", 4, -25)
    DeathRecapFrame.Divider:SetPoint("TOPRIGHT", -4, -25)

    DeathRecapFrame.Recap1.SpellInfo.IconBorder:Hide()
    DeathRecapFrame.Recap1.SpellInfo.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    DeathRecapFrame.Recap2.SpellInfo.IconBorder:Hide()
    DeathRecapFrame.Recap2.SpellInfo.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    DeathRecapFrame.Recap3.SpellInfo.IconBorder:Hide()
    DeathRecapFrame.Recap3.SpellInfo.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    DeathRecapFrame.Recap4.SpellInfo.IconBorder:Hide()
    DeathRecapFrame.Recap4.SpellInfo.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    DeathRecapFrame.Recap5.SpellInfo.IconBorder:Hide()
    DeathRecapFrame.Recap5.SpellInfo.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    DeathRecapFrame.Recap1.tombstone:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\icon-dead")
    DeathRecapFrame.Recap1.tombstone:SetSize(30, 30)
    DeathRecapFrame.Recap1.tombstone:ClearAllPoints()
    DeathRecapFrame.Recap1.tombstone:SetPoint("RIGHT", DeathRecapFrame.Recap1.DamageInfo.Amount, "LEFT", 0, 0)
end

local function SkinDeathRecapFrame()
    hooksecurefunc("OpenDeathRecapUI", SkinDeathRecapFrame_Loaded)
end
GW.SkinDeathRecapFrame = SkinDeathRecapFrame

-------------------------------------------------------DropDownList-------------------------------------------------------
local function SkinDropDownList_OnShow(self)
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
    hooksecurefunc("UIDropDownMenu_OnShow", SkinDropDownList_OnShow)
end
GW.SkinDropDownList = SkinDropDownList

-------------------------------------------------------UIDropDownMenu-------------------------------------------------------
local function SkinUIDropDownMenu_Initialize(self)
    self.Left:Hide()
    self.Middle:Hide()
    self.Right:Hide()

    self.Button.NormalTexture:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    self.Button:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    self.Button:SetDisabledTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")
    self.Button:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\arrowdown_down")

    local tex = self:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", self, "TOP", 0, 0)
    tex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar")
    tex:SetPoint("TOPLEFT", self.Left, "BOTTOMRIGHT", 0, 23)
    tex:SetPoint("BOTTOMRIGHT", self.Right, "TOPLEFT", 10, -20)
    tex:SetVertexColor(0, 0, 0)
    self.tex = tex
end

local function SkinUIDropDownMenu()
    hooksecurefunc("UIDropDownMenu_Initialize", SkinUIDropDownMenu_Initialize)
end
GW.SkinUIDropDownMenu = SkinUIDropDownMenu