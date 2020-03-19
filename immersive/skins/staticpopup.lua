local _, GW = ...
local addHoverToButton = GW.skins.addHoverToButton

local function gwSetStaticPopupSize()
    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]
        StaticPopup.tex:SetSize(StaticPopup:GetSize())
        _G["StaticPopup" .. i .. "AlertIcon"]:SetTexture("Interface/AddOns/GW2_UI/textures/warning-icon") 
        for ii = 1, 5 do
            if ii < 5 then
                addHoverToButton(_G["StaticPopup" .. i .. "Button" .. ii])
            else
                addHoverToButton(_G["StaticPopup" .. i .. "ExtraButton"])
            end
        end
        _G["StaticPopup" .. i .. "ItemFrameNameFrame"]:SetTexture(nil)
        _G["StaticPopup" .. i .. "ItemFrame"].IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        _G["StaticPopup" .. i .. "ItemFrameIconTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        _G["StaticPopup" .. i .. "ItemFrameNormalTexture"]:SetTexture(nil)
    end
end

local function SkinStaticPopup()
    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]

        StaticPopup:SetBackdrop(nil)
        StaticPopup.CoverFrame:Hide()
        StaticPopup.Separator:Hide()

        local tex = StaticPopup:CreateTexture("bg", "BACKGROUND")
        tex:SetPoint("TOP", StaticPopup, "TOP", 0, 0)
        tex:SetSize(StaticPopup:GetSize())
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
        StaticPopup.tex = tex

        --Style Buttons (upto 5)
        for ii = 1, 5 do
            if ii < 5 then
                _G["StaticPopup" .. i .. "Button" .. ii]:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
                _G["StaticPopup" .. i .. "Button" .. ii]:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
                _G["StaticPopup" .. i .. "Button" .. ii]:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
                _G["StaticPopup" .. i .. "Button" .. ii]:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/button_disable")
                _G["StaticPopup" .. i .. "Button" .. ii]:GetHighlightTexture():SetVertexColor(0, 0, 0)
                _G["StaticPopup" .. i .. "Button" .. ii .. "Text"]:SetTextColor(0, 0, 0, 1)
                _G["StaticPopup" .. i .. "Button" .. ii .. "Text"]:SetShadowOffset(0, 0)
            else
                _G["StaticPopup" .. i .. "ExtraButton"]:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
                _G["StaticPopup" .. i .. "ExtraButton"]:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
                _G["StaticPopup" .. i .. "ExtraButton"]:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
                _G["StaticPopup" .. i .. "ExtraButton"]:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/button_disable")
                _G["StaticPopup" .. i .. "ExtraButton"]:GetHighlightTexture():SetVertexColor(0, 0, 0)
                _G["StaticPopup" .. i .. "ExtraButtonText"]:SetTextColor(0, 0, 0, 1)
                _G["StaticPopup" .. i .. "ExtraButtonText"]:SetShadowOffset(0, 0)
            end
        end

        --Change EditBox
        _G["StaticPopup" .. i .. "EditBoxLeft"]:Hide()
        _G["StaticPopup" .. i .. "EditBoxRight"]:Hide()
        _G["StaticPopup" .. i .. "EditBoxMid"]:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")
        _G["StaticPopup" .. i .. "EditBoxMid"]:ClearAllPoints()
        _G["StaticPopup" .. i .. "EditBoxMid"]:SetPoint("TOPLEFT", _G["StaticPopup" .. i .. "EditBoxLeft"], "BOTTOMRIGHT", -25, 3)
        _G["StaticPopup" .. i .. "EditBoxMid"]:SetPoint("BOTTOMRIGHT", _G["StaticPopup" .. i .. "EditBoxRight"], "TOPLEFT", 25, -3)

        hooksecurefunc("StaticPopup_OnUpdate", gwSetStaticPopupSize)
    end
end
GW.SkinStaticPopup = SkinStaticPopup