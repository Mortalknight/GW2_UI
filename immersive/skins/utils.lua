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

local constBackdropFrameColorBorder = {
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white",
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background",
    edgeSize = 1
}
GW.constBackdropFrameColorBorder = constBackdropFrameColorBorder

local constBackdropFrameColorBorderNoBackground = {
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white",
    bgFile = "",
    edgeSize = 1
}
GW.constBackdropFrameColorBorderNoBackground = constBackdropFrameColorBorderNoBackground

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

local NavBarCheck = {
	EncounterJournal = function()
		return GW.GetSetting("ENCOUNTER_JOURNAL_SKIN_ENABLED")
	end,
	WorldMapFrame = function()
		return GW.GetSetting("WORLDMAP_SKIN_ENABLED")
	end,
}

local function SkinNavBarButtons(self)
    local func = NavBarCheck[self:GetParent():GetName()]
    if func and not func() then return end

    local navButton = self.navList[#self.navList]
    if navButton and not navButton.isSkinned then
        navButton:StripTextures()
        --navButton:SkinButton(false, false, true)

        local r = {navButton:GetRegions()}
        for _,c in pairs(r) do
            if c:GetObjectType() == "FontString" then
                c:SetTextColor(1, 1, 1, 1)
                c:SetShadowOffset(0, 0)
            end
        end

        local tex = navButton:CreateTexture(nil, "BACKGROUND")
        tex:SetPoint("LEFT", navButton, "LEFT")
        tex:SetPoint("TOP", navButton, "TOP")
        tex:SetPoint("BOTTOM", navButton, "BOTTOM")
        tex:SetPoint("RIGHT", navButton, "RIGHT")
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/buttonlightInner")
        navButton.tex = tex
        navButton.tex:SetAlpha(1)

        local homeButtonBorder = CreateFrame("Frame",nil,navButton,"GwLightButtonBorder")
        navButton.borderFrame =homeButtonBorder


        hooksecurefunc(navButton, "SetWidth", function()
            local w = navButton:GetWidth()

            navButton.tex:SetPoint("RIGHT", navButton, "LEFT", w, 0)
        end)

        if navButton.MenuArrowButton then
            navButton.MenuArrowButton:StripTextures()
            if navButton.MenuArrowButton.Art then
                navButton.MenuArrowButton.Art:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
                navButton.MenuArrowButton.Art:SetTexCoord(0, 1, 0, 1)
                navButton.MenuArrowButton.Art:SetSize(16, 16)
            end
        end

        navButton.xoffset = -1

        navButton.isSkinned = true
    end
end
hooksecurefunc("NavBar_AddButton", SkinNavBarButtons)

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

    if createBackdrop and not frame.backdrop then
        --local tex = frame:CreateTexture("bg", "BACKGROUND", -7)
        --tex:SetPoint("TOP", frame, "TOP", 0, 25)
        --tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
        --local w, h = frame:GetSize()
        --tex:SetSize(w + 50, h + 50)
        --frame.tex = tex
        frame:CreateBackdrop({
            edgeFile = "",
            bgFile = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg",
            edgeSize = 1
        }, true, 50, 50, nil, 25)
    end

end
GW.HandlePortraitFrame = HandlePortraitFrame

local function HandleIcon(icon, backdrop, backdropTexture)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    if backdrop and not icon.backdrop then
        icon:CreateBackdrop(backdropTexture)
    end
end
GW.HandleIcon = HandleIcon

do
    local function iconBorderColor(border, r, g, b, a)
        border:StripTextures()

        if border.customFunc then
            local br, bg, bb = 1, 1, 1
            border.customFunc(border, r, g, b, a, br, bg, bb)
        elseif border.customBackdrop then
            border.customBackdrop:SetBackdropBorderColor(r, g, b)
        end
    end

    local function iconBorderHide(border)
        local br, bg, bb = 1, 1, 1
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

            hooksecurefunc(border, "SetVertexColor", iconBorderColor)
            hooksecurefunc(border, "Hide", iconBorderHide)

            border.IconBorderHooked = true
        end

        local r, g, b, a = border:GetVertexColor()
        if customFunc then
            border.customFunc = customFunc
            local br, bg, bb = 1, 1, 1
            customFunc(border, r, g, b, a, br, bg, bb)
        elseif r then
            backdrop:SetBackdropBorderColor(r, g, b, a)
        else
            local br, bg, bb = 1, 1, 1
            backdrop:SetBackdropBorderColor(br, bg, bb)
        end
    end
    GW.HandleIconBorder = HandleIconBorder
end

local function Scale(x)
    local m = GW.mult
    if m == 1 or x == 0 then
        return x
    else
        local y = m > 1 and m or -m
        return x - x % (x < 0 and y or -y)
    end
end
GW.Scale = Scale

local function ReskinScrollBarArrow(frame, direction)
    GW.HandleNextPrevButton(frame, direction)

    if frame.Texture then
        frame.Texture:SetAlpha(0)

        if frame.Overlay then
            frame.Overlay:SetAlpha(0)
        end
    else
        frame:StripTextures()
    end
end

local function HandleTrimScrollBar(frame, small)
    frame:StripTextures()

    ReskinScrollBarArrow(frame.Back, 'up')
    ReskinScrollBarArrow(frame.Forward, 'down')

    if frame.Background then
        frame.Background:Hide()
    end

    local track = frame.Track
    if track then
        track:DisableDrawLayer('ARTWORK')
    end

    local thumb = frame:GetThumb()
    if thumb then
        thumb:DisableDrawLayer('BACKGROUND')

        thumb.bg = thumb:CreateTexture(nil, "ARTWORK")
        thumb.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbarmiddle")
        thumb:SetSize(12, thumb:GetSize())


        if not small then
            thumb.bg:SetPoint('TOP', 4, -1)
            thumb.bg:SetPoint('BOTTOM', -4, 1)
        end

        --thumb:HookScript('OnEnter', ThumbOnEnter)
        --thumb:HookScript('OnLeave', ThumbOnLeave)
        --thumb:HookScript('OnMouseUp', ThumbOnMouseUp)
        --thumb:HookScript('OnMouseDown', ThumbOnMouseDown)
    end
end
GW.HandleTrimScrollBar = HandleTrimScrollBar

local function HandleItemButton(b, setInside)
	if b.isSkinned then return end

	local name = b:GetName()
	local icon = b.icon or b.Icon or b.IconTexture or b.iconTexture or (name and (_G[name .. "IconTexture"] or _G[name .. "Icon"]))
	local texture = icon and icon.GetTexture and icon:GetTexture()

	b:StripTextures()
	b:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
	b:StyleButton()

	if icon then
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		if setInside then
			icon:SetInside(b)
		else
			b.backdrop:SetOutside(icon, 1, 1)
		end

		icon:SetParent(b.backdrop)

		if texture then
			icon:SetTexture(texture)
		end
	end

	b.isSkinned = true
end
GW.HandleItemButton = HandleItemButton

do
	local function selectionOffset(frame)
		local point, anchor, relativePoint, xOffset = frame:GetPoint()
		if xOffset <= 0 then
			local x = frame.BorderBox and 4 or 38
			local y = frame.BorderBox and 0 or -10

			frame:ClearAllPoints()
			frame:SetPoint(point, (frame == MacroPopupFrame and MacroFrame) or anchor, relativePoint, strfind(point, "LEFT") and x or -x, y)
		end
	end

	local function handleButton(button, i, buttonNameTemplate)
		local icon, texture = button.Icon or _G[buttonNameTemplate..i.."Icon"]
		if icon then
			icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			icon:SetInside(button)
			texture = icon:GetTexture()
		end

		button:StripTextures()
		button:StyleButton(nil, true)

		if texture then
			icon:SetTexture(texture)
		end
	end

	local function HandleIconSelectionFrame(frame, numIcons, buttonNameTemplate, nameOverride, dontOffset)
		assert(frame, "HandleIconSelectionFrame: frame argument missing")

		if frame.isSkinned then return end

		if not dontOffset then
			frame:HookScript("OnShow", selectionOffset)
		end

		local borderBox = frame.BorderBox
		local frameName = nameOverride or frame:GetName()
		local scrollFrame = frame.ScrollFrame or _G[frameName  .. "ScrollFrame"]
		local editBox = borderBox.IconSelectorEditBox
		local cancel = frame.CancelButton or (borderBox and borderBox.CancelButton)
		local okay = frame.OkayButton or (borderBox and borderBox.OkayButton)

		frame:StripTextures()
		frame:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
		frame:SetHeight(frame:GetHeight() + 10)

		if borderBox then
			borderBox:StripTextures()

			local button = borderBox.SelectedIconArea and borderBox.SelectedIconArea.SelectedIconButton
			if button then
				button:DisableDrawLayer("BACKGROUND")
				GW.HandleItemButton(button, true)
			end
		end

		cancel:ClearAllPoints()
		cancel:SetPoint("BOTTOMRIGHT", frame, -4, 4)
		cancel:SkinButton(false, true)

		okay:ClearAllPoints()
		okay:SetPoint("RIGHT", cancel, "LEFT", -10, 0)
		okay:SkinButton(false, true)

		if editBox then
			editBox:DisableDrawLayer("BACKGROUND")
            editBox:StripTextures()
            editBox:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
		end

		if numIcons then
			scrollFrame:StripTextures()
			scrollFrame:SetHeight(scrollFrame:GetHeight() + 10)
			scrollFrame.ScrollBar:SkinScrollBar()

			for i = 1, numIcons do
				local button = _G[buttonNameTemplate..i]
				if button then
					handleButton(button, i, buttonNameTemplate)
				end
			end
		else
			GW.HandleTrimScrollBar(frame.IconSelector.ScrollBar)

			for _, button in next, { frame.IconSelector.ScrollBox.ScrollTarget:GetChildren() } do
				handleButton(button)
			end
		end

		frame.isSkinned = true
	end
    GW.HandleIconSelectionFrame = HandleIconSelectionFrame
end

local tabs = {
    "LeftDisabled",
    "MiddleDisabled",
    "RightDisabled",
    "Left",
    "Middle",
    "Right"
}

local function HandleTabs(tab, skinAsButton)
    for _, object in pairs(tabs) do
        local textureName = tab:GetName() and _G[tab:GetName() .. object]
        if textureName then
            textureName:SetTexture()
        elseif tab[object] then
            tab[object]:SetTexture()
        end
    end

    local highlightTex = tab.GetHighlightTexture and tab:GetHighlightTexture()
    if highlightTex then
        highlightTex:SetTexture()
    else
        tab:StripTextures()
    end

    if skinAsButton then
        tab:SkinButton(false, true)
    end
    tab:SetHitRectInsets(0, 0, 0, 0)
    tab:GetFontString():SetTextColor(0, 0, 0)
end
GW.HandleTabs = HandleTabs
