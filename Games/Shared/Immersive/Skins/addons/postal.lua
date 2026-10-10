---@class GW2
local GW = select(2, ...)

local DELETE_ICON = "Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal.png"
local RETURN_ICON = "Interface/AddOns/GW2_UI/textures/uistuff/arrow_right.png" -- postal mirrors it to the left

-- the delete / return icon of an inbox row, postal sets its texture on every inbox update
local function SetPostalRowIcon(texture, file)
    if texture.gwSetting then return end
    texture.gwSetting = true
    local isDelete = type(file) == "string" and file:find("ReadyCheck", 1, true) ~= nil
    texture:SetTexture(isDelete and DELETE_ICON or RETURN_ICON)
    texture.gwSetting = nil
end

-- postal enables its modules after our skin ran, their buttons get skinned when the mail opens
local function SkinPostalModuleButtons()
    if OpenMailForwardButton and not OpenMailForwardButton.gwSkinned then
        OpenMailForwardButton:GwSkinButton(false, true)
    end
    for i = 1, 7 do
        local expire = _G["MailItem" .. i .. "ExpireTime"]
        local icon = expire and expire.returnicon
        if icon and not icon.gwSkinned then
            icon.gwSkinned = true
            icon:ClearAllPoints()
            icon:SetPoint("TOPRIGHT", expire, "BOTTOMRIGHT", -15, -1)
            hooksecurefunc(icon.texture, "SetTexture", SetPostalRowIcon)
            SetPostalRowIcon(icon.texture, icon.texture:GetTexture())
        end
    end
end

local function LoadPostalAddonSkin()
    SkinPostalModuleButtons()
    MailFrame:HookScript("OnShow", SkinPostalModuleButtons)

    if PostalOpenAllButton then
        PostalOpenAllButton:GwSkinButton(false, true)
        PostalOpenAllButton:ClearAllPoints()
        PostalOpenAllButton:SetPoint("CENTER", InboxFrame, "BOTTOM", -14, 114)
    end

    if PostalSelectOpenButton and PostalSelectReturnButton then
        local height = MailFrameTab2:GetHeight()
        PostalSelectReturnButton:GwSkinButton(false, true)
        PostalSelectReturnButton:SetSize(80, height)
        PostalSelectReturnButton:ClearAllPoints()
        PostalSelectReturnButton:SetPoint("BOTTOMRIGHT", MailItem1, "TOPRIGHT", 0, 10)
        PostalSelectOpenButton:GwSkinButton(false, true)
        PostalSelectOpenButton:SetSize(80, height)
        PostalSelectOpenButton:ClearAllPoints()
        PostalSelectOpenButton:SetPoint("RIGHT", PostalSelectReturnButton, "LEFT", -4, 0)
        -- the same text size as our compose button
        local font, size, flags = MailFrameTab2:GetFontString():GetFont()
        PostalSelectOpenButton:GetFontString():SetFont(font, size, flags)
        PostalSelectReturnButton:GetFontString():SetFont(font, size, flags)
        GW.AnchorMailComposeButton()
    end

    local index = 1
    while _G["Postal_QuickAttachButton" .. index] do
        local button = _G["Postal_QuickAttachButton" .. index]
        if button.IconMask then
            button.icon:RemoveMaskTexture(button.IconMask)
        end
        GW.HandleItemButton(button, true)
        index = index + 1
    end

    for i = 1, 7 do
        local checkBox = _G["PostalInboxCB" .. i]
        if checkBox then
            checkBox:GwSkinCheckButton(false, 20)
        end
    end

    if Postal_ModuleMenuButton then
        Postal_ModuleMenuButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up.png")
        Postal_ModuleMenuButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
        Postal_ModuleMenuButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
        Postal_ModuleMenuButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up.png")
        Postal_ModuleMenuButton:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", -30, 33)
    end

    if Postal_OpenAllMenuButton then
        Postal_OpenAllMenuButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up.png")
        Postal_OpenAllMenuButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
        Postal_OpenAllMenuButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
        Postal_OpenAllMenuButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up.png")
    end

    if Postal_BlackBookButton then
        Postal_BlackBookButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up.png")
        Postal_BlackBookButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
        Postal_BlackBookButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
        Postal_BlackBookButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up.png")
    end
end
GW.LoadPostalAddonSkin = LoadPostalAddonSkin

