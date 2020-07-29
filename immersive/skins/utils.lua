local _, GW = ...

local constBackdropFrame = {
    bgFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Background",
    edgeFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.skins.constBackdropFrame = constBackdropFrame

local constBackdropFrameBorder = {
    bgFile = "",
    edgeFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.skins.constBackdropFrameBorder = constBackdropFrameBorder

local function SkinUIDropDownMenu()
    hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
        local listFrame = _G["DropDownList" .. level]
        local listFrameName = listFrame:GetName()
        local expandArrow = _G[listFrameName .. "Button" .. index .. "ExpandArrow"];
        if expandArrow then
            expandArrow:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
            expandArrow:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
            expandArrow:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
            expandArrow:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
        end
    
        local Backdrop = _G[listFrameName .. "Backdrop"]
        Backdrop:StripTextures()
        Backdrop:SetBackdrop(constBackdropFrame)
    
        local menuBackdrop = _G[listFrameName .. "MenuBackdrop"]
        menuBackdrop:StripTextures()
        menuBackdrop:SetBackdrop(constBackdropFrame)
    end)
end

local function SkinDropDownList()
    hooksecurefunc("ToggleDropDownMenu", function(level)
        if not level then
            level = 1
        end

        for i = 1, _G.UIDROPDOWNMENU_MAXBUTTONS do
            local button = _G["DropDownList" .. level .. "Button" .. i]
            local check = _G["DropDownList" .. level .. "Button" .. i .. "Check"]
            local uncheck = _G["DropDownList" .. level .. "Button" .. i .. "UnCheck"]
            local arrow = _G["DropDownList" .. level .. "Button" .. i .. "ExpandArrow"]

            if not button.backdrop then
                button:CreateBackdrop()
            end

            button.backdrop:Hide()

            if button.hasArrow then
                arrow:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrow_right")
            end

            if not button.notCheckable then
                local _, co = check:GetTexCoord()
                if co == 0 then
                    check:SetTexture("Interface/AddOns/GW2_UI/textures/checkboxchecked")
                    check:SetTexCoord(unpack(GW.TexCoords))
                    check:SetSize(13, 13)
                    uncheck:SetTexture("Interface/AddOns/GW2_UI/textures/checkbox")
                    uncheck:SetTexCoord(unpack(GW.TexCoords))
                    uncheck:SetSize(13, 13)
                end

            end
        end
        --Check if Raider.IO Entry is added
        if IsAddOnLoaded("RaiderIO") and _G.RaiderIO_CustomDropDownList then
            _G["RaiderIO_CustomDropDownListMenuBackdrop"]:Hide()
            _G["RaiderIO_CustomDropDownList"]:SetBackdrop(constBackdropFrame)
        end
    end)

    hooksecurefunc("UIDropDownMenu_SetIconImage", function(icon, texture)
        if texture:find("Divider") then
            icon:SetColorTexture(1, 0.93, 0.73, 0.45)
            icon:SetHeight(1)
        end
    end)
end

local function SkinDropDown()
    SkinDropDownList()
    SkinUIDropDownMenu()
end
GW.SkinDropDown = SkinDropDown

local function SkinTextBox(seg1, seg2, seg3)
    if seg1 ~= nil then
        seg1:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")
    end

    if seg2 ~= nil then
        seg2:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")
    end 

    if seg3 ~= nil then
        seg3:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")
    end
end
GW.SkinTextBox = SkinTextBox

local function MutateInaccessableObject(frame, objType, func)
    local r = {frame:GetRegions()}

    if frame == nil or objType == nil or func == nil then
        return
    end

    for _, c in pairs(r) do
        if c:GetObjectType() == objType then
            func(c)
        end
    end
end
GW.MutateInaccessableObject = MutateInaccessableObject