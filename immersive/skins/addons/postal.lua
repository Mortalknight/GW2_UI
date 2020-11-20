local _, GW = ...

local function SkinPostalAddonFrame()
    if PostalOpenAllButton then
        PostalOpenAllButton:SkinButton(false, true)
        
        PostalSelectOpenButton:SkinButton(false, true)
        PostalSelectOpenButton:SetPoint("TOPRIGHT", MailFrameTab2, "TOPRIGHT", -85, -35)
        PostalSelectOpenButton:SetSize(SendMailCancelButton:GetSize())

        PostalSelectReturnButton:SkinButton(false, true)
        PostalSelectReturnButton:SetPoint("TOPLEFT", PostalSelectOpenButton, "TOPRIGHT", 2, 0)
        PostalSelectReturnButton:SetSize(PostalSelectOpenButton:GetSize())

        Postal_ModuleMenuButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
        Postal_ModuleMenuButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
        Postal_ModuleMenuButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
        Postal_ModuleMenuButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
        Postal_ModuleMenuButton:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", -30, 33)

        Postal_OpenAllMenuButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
        Postal_OpenAllMenuButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
        Postal_OpenAllMenuButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
        Postal_OpenAllMenuButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    end
end
GW.SkinPostalAddonFrame = SkinPostalAddonFrame

