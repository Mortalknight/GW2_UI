local _, GW = ...

local constBackdropFrame = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background",
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.skins.constBackdropFrame = constBackdropFrame

local constBackdropFrameBorder = {
    bgFile = "",
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.skins.constBackdropFrameBorder = constBackdropFrameBorder

local constBackdropFrameSmallerBorder = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background",
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 18,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.skins.constBackdropFrameSmallerBorder = constBackdropFrameSmallerBorder

local function SkinUIDropDownMenu()
    hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
        local listFrame = _G["DropDownList" .. level]
        local listFrameName = listFrame:GetName()
        local expandArrow = _G[listFrameName .. "Button" .. index .. "ExpandArrow"];
        if expandArrow then
            expandArrow:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
            expandArrow:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
            expandArrow:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
            expandArrow:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
        end

        local Backdrop = _G[listFrameName .. "Backdrop"]
        Backdrop:StripTextures()
        Backdrop:CreateBackdrop(constBackdropFrame)

        local menuBackdrop = _G[listFrameName .. "MenuBackdrop"]
        menuBackdrop:StripTextures()
        menuBackdrop:CreateBackdrop(constBackdropFrame)
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

            check:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked")
            check:SetTexCoord(unpack(GW.TexCoords))
            check:SetSize(13, 13)
            uncheck:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox")
            uncheck:SetTexCoord(unpack(GW.TexCoords))
            uncheck:SetSize(13, 13)
            if not button.backdrop then
                button:CreateBackdrop()
            end

            button.backdrop:Hide()

            if button.hasArrow then
                arrow:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right")
            end

            if not button.notCheckable then
                button.backdrop:Show()
            end
        end
        --Check if Raider.IO Entry is added
        if IsAddOnLoaded("RaiderIO") and _G.RaiderIO_CustomDropDownList then
            _G["RaiderIO_CustomDropDownListMenuBackdrop"]:Hide()
            _G["RaiderIO_CustomDropDownList"]:CreateBackdrop(constBackdropFrame)
        end
    end)

    hooksecurefunc("UIDropDownMenu_SetIconImage", function(icon, texture)
        if texture:find("Divider") then
            icon:SetColorTexture(1, 0.93, 0.73, 0.45)
            icon:SetHeight(1)
        end
    end)
end

local function LoadDropDownSkin()
    if not GW.GetSetting("DROPDOWN_SKIN_ENABLED") then return end

    SkinDropDownList()
    SkinUIDropDownMenu()
end
GW.LoadDropDownSkin = LoadDropDownSkin

local function SkinTextBox(seg1, seg2, seg3)
    if seg1 ~= nil then
        seg1:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg")
        seg1:SetAlpha(1)
    end

    if seg2 ~= nil then
        seg2:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg")
        seg2:SetAlpha(1)
    end

    if seg3 ~= nil then
        seg3:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar-bg")
        seg3:SetAlpha(1)
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

local function SkinNavBarButtons(self)
    if not self:GetParent():GetName() == "WorldMapFrame" then return end

    local navButton = self.navList[#self.navList]
    if navButton and not navButton.isSkinned then

        --[[ Add this later if we have a custom texture for navigationbars
        navButton:StripTextures()
        navButton:SkinButton(false, false, true)

        local r = {navButton:GetRegions()}
        for _,c in pairs(r) do
            if c:GetObjectType() == "FontString" then
                c:SetTextColor(0, 0, 0, 1)
                c:SetShadowOffset(0, 0)
            end
        end

        local tex = navButton:CreateTexture(nil, "BACKGROUND")
        tex:SetPoint("LEFT", navButton, "LEFT")
        tex:SetPoint("TOP", navButton, "TOP")
        tex:SetPoint("BOTTOM", navButton, "BOTTOM")
        tex:SetPoint("RIGHT", navButton, "RIGHT")
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button")
        navButton.tex = tex
        navButton.tex:SetAlpha(1)

        hooksecurefunc(navButton, "SetWidth", function()
            local w = navButton:GetWidth()

            navButton.tex:SetPoint("RIGHT", navButton, "LEFT", w, 0)
        end)
        ]]
        if navButton.MenuArrowButton then
            navButton.MenuArrowButton:StripTextures()
            if navButton.MenuArrowButton.Art then
                navButton.MenuArrowButton.Art:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
                navButton.MenuArrowButton.Art:SetTexCoord(0, 1, 0, 1)
                navButton.MenuArrowButton.Art:SetSize(16, 16)
            end
        end

        navButton.xoffset = 1

        navButton.isSkinned = true
    end
end
GW.SkinNavBarButtons = SkinNavBarButtons

local function HandlePortraitFrame(frame, createBackdrop)
	local name = frame and frame.GetName and frame:GetName()
	local insetFrame = name and _G[name .. "Inset"] or frame.Inset
	local portraitFrame = name and _G[name .. "Portrait"] or frame.Portrait or frame.portrait
	local portraitFrameOverlay = name and _G[name .. "PortraitOverlay"] or frame.PortraitOverlay
	local artFrameOverlay = name and _G[name .. "ArtOverlayFrame"] or frame.ArtOverlayFrame

	frame:StripTextures()

	if portraitFrame then portraitFrame:SetAlpha(0) end
	if portraitFrameOverlay then portraitFrameOverlay:SetAlpha(0) end
	if artFrameOverlay then artFrameOverlay:SetAlpha(0) end

	if insetFrame then
		if insetFrame.InsetBorderTop then insetFrame.InsetBorderTop:Hide() end
        if insetFrame.InsetBorderTopLeft then insetFrame.InsetBorderTopLeft:Hide() end
        if insetFrame.InsetBorderTopRight then insetFrame.InsetBorderTopRight:Hide() end

        if insetFrame.InsetBorderBottom then insetFrame.InsetBorderBottom:Hide() end
        if insetFrame.InsetBorderBottomLeft then insetFrame.InsetBorderBottomLeft:Hide() end
        if insetFrame.InsetBorderBottomRight then insetFrame.InsetBorderBottomRight:Hide() end

        if insetFrame.InsetBorderLeft then insetFrame.InsetBorderLeft:Hide() end
        if insetFrame.InsetBorderRight then insetFrame.InsetBorderRight:Hide() end

        if insetFrame.Bg then insetFrame.Bg:Hide() end
	end

	if frame.CloseButton then
	    frame.CloseButton:SkinButton(true)
        frame.CloseButton:SetSize(20, 20)
	end

	if createBackdrop then
		local tex = frame:CreateTexture("bg", "BACKGROUND")
        tex:SetPoint("TOP", frame, "TOP", 0, 25)
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
        local w, h = frame:GetSize()
        tex:SetSize(w + 50, h + 50)
        frame.tex = tex
	end

end
GW.HandlePortraitFrame = HandlePortraitFrame

local function HandleIcon(icon, backdrop)
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

	if backdrop and not icon.backdrop then
		icon:CreateBackdrop(nil)
	end
end
GW.HandleIcon = HandleIcon

do
	local function iconBorderColor(border, r, g, b, a)
		border:StripTextures()

		if border.customFunc then
			local br, bg, bb = unpack(1, 1, 1)
			border.customFunc(border, r, g, b, a, br, bg, bb)
		elseif border.customBackdrop then
			border.customBackdrop:SetBackdropBorderColor(r, g, b)
		end
	end

	local function iconBorderHide(border)
		local br, bg, bb = unpack(1, 1, 1)
		if border.customFunc then
			local r, g, b, a = border:GetVertexColor()
			border.customFunc(border, r, g, b, a, br, bg, bb)
		elseif border.customBackdrop then
			border.customBackdrop:SetBackdropBorderColor(br, bg, bb)
		end
	end

	local function HandleIconBorder(border, backdrop, customFunc)
		if not backdrop then
			local parent = border:GetParent()
			backdrop = parent.backdrop or parent
		end

		border.customBackdrop = backdrop

		if not border.IconBorderHooked then
			border:StripTextures()

			hooksecurefunc(border, 'SetVertexColor', iconBorderColor)
			hooksecurefunc(border, 'Hide', iconBorderHide)

			border.IconBorderHooked = true
		end

		local r, g, b, a = border:GetVertexColor()
		if customFunc then
			border.customFunc = customFunc
			local br, bg, bb = unpack(1, 1, 1)
			customFunc(border, r, g, b, a, br, bg, bb)
		elseif r then
			backdrop:SetBackdropBorderColor(r, g, b, a)
		else
			local br, bg, bb = unpack(1, 1, 1)
			backdrop:SetBackdropBorderColor(br, bg, bb)
		end
	end
    GW.HandleIconBorder = HandleIconBorder
end

local function SetInside(frame)
    local anchor = frame:GetParent()

	local xOffset = 2
	local yOffset = 2
	local trunc = function(s) return s >= 0 and s-s%01 or s-s%-1 end
    local round = function(s) return s >= 0 and s-s%-1 or s-s%01 end
    local x = (GW.mult == 1 or (xOffset or 2) == 0) and (xOffset or 2) or ((GW.mult < 1 and trunc((xOffset or 2) / GW.mult) or round((xOffset or 2) / GW.mult)) * GW.mult)
    local y = (GW.mult == 1 or (yOffset or 2) == 0) and (yOffset or 2) or ((GW.mult < 1 and trunc((yOffset or 2) / GW.mult) or round((yOffset or 2) / GW.mult)) * GW.mult)

	if frame:GetPoint() then
		frame:ClearAllPoints()
	end

	frame:SetPoint('TOPLEFT', anchor, 'TOPLEFT', x, -y)
	frame:SetPoint('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', -x, y)
end
GW.SetInside = SetInside
