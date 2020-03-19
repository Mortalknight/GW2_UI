local _, GW = ...
local addHoverToButton = GW.skins.addHoverToButton
local constBackdropFrame = GW.skins.constBackdropFrame

local function SkinReadyCheckListenerFrame()
    _G.ReadyCheckListenerFrame:SetBackdrop(nil)

    _G.ReadyCheckFrameYesButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
    _G.ReadyCheckFrameYesButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
    _G.ReadyCheckFrameYesButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
    _G.ReadyCheckFrameYesButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    _G.ReadyCheckFrameYesButton.Text:SetTextColor(0, 0, 0, 1)
    _G.ReadyCheckFrameYesButton.Text:SetShadowOffset(0, 0)
    addHoverToButton(_G.ReadyCheckFrameYesButton)

    _G.ReadyCheckFrameNoButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button")
    _G.ReadyCheckFrameNoButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button")
    _G.ReadyCheckFrameNoButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button")
    _G.ReadyCheckFrameNoButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    _G.ReadyCheckFrameNoButton.Text:SetTextColor(0, 0, 0, 1)
    _G.ReadyCheckFrameNoButton.Text:SetShadowOffset(0, 0)
    addHoverToButton(_G.ReadyCheckFrameNoButton)

    local r = {_G.ReadyCheckListenerFrame:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" then
            c:Hide()
        end
    end

    _G.ReadyCheckListenerFrame:SetBackdrop(constBackdropFrame)
    _G.ReadyCheckPortrait:Show()
    _G.ReadyCheckPortrait:SetDrawLayer("OVERLAY", 2)
end
GW.SkinReadyCheckListenerFrame = SkinReadyCheckListenerFrame