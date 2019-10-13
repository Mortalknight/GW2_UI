local _, GW = ...
local BUTTONS = {
    {button = GameMenuButtonHelp, sprite={1,1} },
    {button = GameMenuButtonStore, sprite={2,1} },
    {button = GameMenuButtonWhatsNew, sprite={3,1} },
    {button = GameMenuButtonOptions, sprite={4,1} },
    {button = GameMenuButtonUIOptions, sprite={1,2} },
    {button = GameMenuButtonKeybindings, sprite={2,2} },
    {button = GameMenuButtonMacros, sprite={3,2} },
    {button = GameMenuButtonAddons, sprite={4,2} },
    {button = GameMenuButtonLogout, sprite={1,3} },
    {button = GameMenuButtonQuit, sprite={2,3} },
    {button = GameMenuButtonContinue, sprite={3,3} },

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
        if b~=nil then

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

local function gwSetStaticPopupSize()
    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]
        StaticPopup.tex:SetSize(StaticPopup:GetSize())
    end
end

local function StaticPopup()
    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]

        StaticPopup:SetBackdrop(nil)
        StaticPopup.CoverFrame:Hide()
        StaticPopup.Separator:Hide()
        StaticPopup.Border:Hide()

        local tex = StaticPopup:CreateTexture("bg", "BACKGROUND")
        tex:SetPoint("TOP", StaticPopup,"TOP",0,0)
        tex:SetSize(StaticPopup:GetSize())
        tex:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\party\\manage-group-bg")
        StaticPopup.tex = tex

        --Style Buttons (upto 5)
        for ii = 1, 5 do
            if ii < 5 then
                _G["StaticPopup" .. i .. "Button" .. ii]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "Button" .. ii]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "Button" .. ii]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "Button" .. ii .. "Text"]:SetTextColor(0, 0, 0, 1)
                --local a = _G["StaticPopup" .. i .. "Button" .. ii .. "Text"]:GetHighlightFontObject()
                --a = _G["StaticPopup" .. i .. "Button" .. ii .. "Text"]:SetTextColor(0, 0, 0, 1)
                _G["StaticPopup" .. i .. "Button" .. ii .. "Text"]:SetShadowOffset(0, 0)
                _G["StaticPopup" .. i .. "Button" .. ii .. "Text"]:SetDrawLayer("OVERLAY")

                 
            else
                _G["StaticPopup" .. i .. "ExtraButton"]:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "ExtraButton"]:SetHighlightTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "ExtraButton"]:SetPushedTexture("Interface\\AddOns\\GW2_UI\\textures\\button")
                _G["StaticPopup" .. i .. "ExtraButtonText"]:SetTextColor(0, 0, 0, 1)
                _G["StaticPopup" .. i .. "ExtraButtonText"]:SetShadowOffset(0, 0)
            end
        end

        --Change EditBox
        _G["StaticPopup" .. i .. "EditBoxLeft"]:Hide()
        _G["StaticPopup" .. i .. "EditBoxRight"]:Hide()
        _G["StaticPopup" .. i .. "EditBoxMid"]:Hide()

        local texEB = _G["StaticPopup" .. i .. "EditBox"]:CreateTexture("bg", "BACKGROUND")
        texEB:SetPoint("TOPLEFT", _G["StaticPopup" .. i .. "EditBox"],"TOP", -5, 3)
        texEB:SetPoint("BOTTOMRIGHT", _G["StaticPopup" .. i .. "EditBox"],"TOP", 5, -3)
        texEB:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\gwstatusbar-bg")
        
        _G["StaticPopup" .. i .. "AlertIcon"]:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\warning-icon")
    end

    hooksecurefunc("StaticPopup_Resize", gwSetStaticPopupSize)
end
GW.StaticPopup = StaticPopup
