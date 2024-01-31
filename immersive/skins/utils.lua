local _, GW = ...

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
        if Backdrop and not Backdrop.template then
            Backdrop:GwStripTextures()
            Backdrop:GwCreateBackdrop(GW.BackdropTemplates.Default)
        end

        local menuBackdrop = _G[listFrameName .. "MenuBackdrop"]
        if menuBackdrop and not menuBackdrop.template then
            menuBackdrop:GwStripTextures()
            menuBackdrop:GwCreateBackdrop(GW.BackdropTemplates.Default)
        end
    end)

    --Same for LibDropDown
    hooksecurefunc(GW.Libs.LibDD, "UIDropDownMenu_CreateFrames", function(self, level, index)
        local listFrame = _G["L_DropDownList" .. level]
        local listFrameName = listFrame:GetName()
        local expandArrow = _G[listFrameName .. "Button" .. index .. "ExpandArrow"];
        if expandArrow then
            expandArrow:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
            expandArrow:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
            expandArrow:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
            expandArrow:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
        end

        local Backdrop = _G[listFrameName .. "Backdrop"]
        if Backdrop and not Backdrop.template then
            Backdrop:GwStripTextures()
            Backdrop:GwCreateBackdrop(GW.BackdropTemplates.Default)
        end

        local menuBackdrop = _G[listFrameName .. "MenuBackdrop"]
        if menuBackdrop and not menuBackdrop.template then
            menuBackdrop:GwStripTextures()
            menuBackdrop:GwCreateBackdrop(GW.BackdropTemplates.Default)
        end
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
            local highlight = _G["DropDownList" .. level .. "Button" .. i .. "Highlight"]

            highlight:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover")
            highlight:SetBlendMode("BLEND")
            highlight:SetDrawLayer("BACKGROUND")
            highlight:SetAlpha(0.5)
            highlight:GwSetOutside(button, 8)

            check:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked")
            check:SetTexCoord(unpack(GW.TexCoords))
            check:SetSize(13, 13)
            uncheck:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox")
            uncheck:SetTexCoord(unpack(GW.TexCoords))
            uncheck:SetSize(13, 13)
            if not button.backdrop then
                button:GwCreateBackdrop()
            end

            if button.hasArrow then
                arrow:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right")
            end

            if not button.notCheckable then
                button.backdrop:Show()
            else
                button.backdrop:Hide()
            end
        end
        --Check if Raider.IO Entry is added
        if C_AddOns.IsAddOnLoaded("RaiderIO") and _G.RaiderIO_CustomDropDownList then
            _G["RaiderIO_CustomDropDownListMenuBackdrop"]:Hide()
            _G["RaiderIO_CustomDropDownList"]:GwCreateBackdrop(GW.BackdropTemplates.Default)
        end
    end)

    hooksecurefunc("UIDropDownMenu_SetIconImage", function(icon, texture)
        if texture:find("Divider") then
            icon:SetColorTexture(1, 0.93, 0.73, 0.45)
            icon:SetHeight(1)
        end
    end)

    -- Same for LibUIDropDownMenu
    hooksecurefunc(GW.Libs.LibDD, "ToggleDropDownMenu", function(self, level)
        if not level then
            level = 1
        end

        for i = 1, L_UIDROPDOWNMENU_MAXBUTTONS do
            local button = _G["L_DropDownList" .. level .. "Button" .. i]
            local check = _G["L_DropDownList" .. level .. "Button" .. i .. "Check"]
            local uncheck = _G["L_DropDownList" .. level .. "Button" .. i .. "UnCheck"]
            local arrow = _G["L_DropDownList" .. level .. "Button" .. i .. "ExpandArrow"]
            local highlight = _G["L_DropDownList" .. level .. "Button" .. i .. "Highlight"]

            highlight:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover")
            highlight:SetBlendMode("BLEND")
            highlight:SetDrawLayer("BACKGROUND")
            highlight:SetAlpha(0.5)
            highlight:GwSetOutside(button, 8)

            check:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked")
            check:SetTexCoord(unpack(GW.TexCoords))
            check:SetSize(13, 13)
            uncheck:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox")
            uncheck:SetTexCoord(unpack(GW.TexCoords))
            uncheck:SetSize(13, 13)
            if not button.backdrop then
                button:GwCreateBackdrop()
            end

            if button.hasArrow then
                arrow:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right")
            end

            if not button.notCheckable then
                button.backdrop:Show()
            else
                button.backdrop:Hide()
            end
        end
    end)

    hooksecurefunc(GW.Libs.LibDD, "UIDropDownMenu_SetIconImage", function(self, icon, texture)
        if texture:find("Divider") then
            icon:SetColorTexture(1, 0.93, 0.73, 0.45)
            icon:SetHeight(1)
        end
    end)
end

local function LoadDropDownSkin()
    if not GW.settings.DROPDOWN_SKIN_ENABLED then return end

    SkinDropDownList()
    SkinUIDropDownMenu()
end
GW.LoadDropDownSkin = LoadDropDownSkin
--middle left right
local function SkinTextBox(middleTex, leftTex, rightTex, topTex, bottomTex, leftOffset, rightOffset)
    if middleTex then
        middleTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar")
        middleTex:SetAlpha(0.5)
        middleTex:ClearAllPoints()
        middleTex:SetPoint("TOPLEFT", -(leftOffset or 0), 0)
        middleTex:SetPoint("BOTTOMRIGHT", (rightOffset or 0), 0)
        middleTex:SetAlpha(1)
    end
    if leftTex then
        leftTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarBorderPixelVertical")
        leftTex:SetWidth(2)
        leftTex:SetAlpha(1)
        leftTex:ClearAllPoints()
        leftTex:SetPoint("TOPLEFT", -(leftOffset or 0), 0)
        leftTex:SetPoint("BOTTOMLEFT", -(leftOffset or 0), 0)
        leftTex:SetTexCoord(0,1,1,0)
        leftTex:SetAlpha(1)
    end
    if rightTex then
        rightTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarBorderPixelVertical")
        rightTex:SetWidth(1)
        rightTex:SetAlpha(1)
        rightTex:ClearAllPoints()
        rightTex:SetPoint("TOPRIGHT", (rightOffset or 0), 0)
        rightTex:SetPoint("BOTTOMRIGHT", (rightOffset or 0), 0)
        rightTex:SetAlpha(1)
        local pframe = rightTex:GetParent()
        if topTex then
            topTex:ClearAllPoints()
            topTex:SetHeight(2)
            topTex:SetPoint("BOTTOMLEFT", pframe, "TOPLEFT", -(leftOffset or 0), 0)
            topTex:SetPoint("BOTTOMRIGHT", pframe, "TOPRIGHT", (rightOffset or 0), 0)
            topTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarBorderPixel")
            topTex:SetAlpha(1)
        else
            local top = pframe:CreateTexture(nil, "BACKGROUND", nil, 0)
            pframe.top = top
            top:ClearAllPoints()
            top:SetHeight(2)
            top:SetPoint("BOTTOMLEFT", pframe, "TOPLEFT", -(leftOffset or 0), 0)
            top:SetPoint("BOTTOMRIGHT", pframe, "TOPRIGHT", (rightOffset or 0), 0)
            top:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarBorderPixel")
            if middleTex then return end
        end
        if bottomTex then
            bottomTex:ClearAllPoints()
            bottomTex:SetHeight(2)
            bottomTex:SetPoint("TOPLEFT",pframe,"BOTTOMLEFT",-(leftOffset or 0),0)
            bottomTex:SetPoint("TOPRIGHT",pframe,"BOTTOMRIGHT",(rightOffset or 0),0)
            bottomTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarBorderPixel")
            bottomTex:SetTexCoord(0, 1, 1, 0)
            bottomTex:SetAlpha(1)
        else
            local bottom = pframe:CreateTexture(nil, "BACKGROUND", nil, 0)
            pframe.bottom = bottom
            bottom:ClearAllPoints()
            bottom:SetHeight(2)
            bottom:SetPoint("TOPLEFT", pframe, "BOTTOMLEFT", -(leftOffset or 0), 0)
            bottom:SetPoint("TOPRIGHT", pframe, "BOTTOMRIGHT", (rightOffset or 0), 0)
            bottom:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarBorderPixel")
            bottom:SetTexCoord(0, 1, 1, 0)
        end

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
        return GW.settings.ENCOUNTER_JOURNAL_SKIN_ENABLED
    end,
    WorldMapFrame = function()
        return GW.settings.WORLDMAP_SKIN_ENABLED
    end,
}

local function NavButtonXOffset(button, point, anchor, point2, _, yoffset, skip)
    if not skip then
        button:SetPoint(point, anchor, point2, -1, yoffset, true)
    end
end

local function SkinNavBarButtons(self)
    local func = NavBarCheck[self:GetParent():GetName()]
    if func and not func() then return end

    local total = #self.navList
    local navButton = self.navList[total]
    if navButton and not navButton.isSkinned then
        navButton:GwStripTextures()
        navButton:GetFontString():SetTextColor(1, 1, 1, 1)
        navButton:GetFontString():SetShadowOffset(0, 0)

        local tex = navButton:CreateTexture(nil, "BACKGROUND")
        tex:SetPoint("LEFT", navButton, "LEFT")
        tex:SetPoint("TOP", navButton, "TOP")
        tex:SetPoint("BOTTOM", navButton, "BOTTOM")
        tex:SetPoint("RIGHT", navButton, "RIGHT")
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/buttonlightInner")
        navButton.tex = tex
        navButton.tex:SetAlpha(1)

        navButton.borderFrame = CreateFrame("Frame", nil, navButton, "GwLightButtonBorder")

        hooksecurefunc(navButton, "SetWidth", function()
            local w = navButton:GetWidth()

            navButton.tex:SetPoint("RIGHT", navButton, "LEFT", w, 0)
        end)

        if navButton.MenuArrowButton then
            navButton.MenuArrowButton:GwStripTextures()
            if navButton.MenuArrowButton.Art then
                navButton.MenuArrowButton.Art:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down")
                navButton.MenuArrowButton.Art:SetTexCoord(0, 1, 0, 1)
                navButton.MenuArrowButton.Art:SetSize(16, 16)
            end
        end

        if total > 1 then
            NavButtonXOffset(navButton, navButton:GetPoint())
            hooksecurefunc(navButton, "SetPoint", NavButtonXOffset)
        end

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

    frame:GwStripTextures()

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
        frame.CloseButton:GwSkinButton(true)
        frame.CloseButton:SetSize(20, 20)
    end

    if createBackdrop and not frame.backdrop then
        frame:GwCreateBackdrop({
            edgeFile = "",
            bgFile = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg",
            edgeSize = 1
        }, true, 50, 50, nil, 25)
    end

end
GW.HandlePortraitFrame = HandlePortraitFrame

local function HandleIcon(icon, backdrop, backdropTexture, isBorder)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    if backdrop and not icon.backdrop then
        icon:GwCreateBackdrop(backdropTexture, isBorder)
    end
end
GW.HandleIcon = HandleIcon

do
    local function iconBorderColor(border, r, g, b, a)
        border:GwStripTextures()

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
            border:GwStripTextures()

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
        frame:GwStripTextures()
    end
end

local function HandleScrollControls(self, specifiedScrollBar)
    local scrollBar = specifiedScrollBar and self[specifiedScrollBar] or self.ScrollBar
    scrollBar:SetWidth(20)

    scrollBar.Track:ClearAllPoints()
    scrollBar.Track:SetPoint("TOPLEFT", scrollBar, "TOPLEFT", 0, -12)
    scrollBar.Track:SetPoint("BOTTOMRIGHT", scrollBar, "BOTTOMRIGHT", 0, 12)

    local bg = scrollBar.Track:CreateTexture(nil, "BACKGROUND", nil, 0)
    bg:ClearAllPoints()
    bg:SetPoint("TOP", 0, 0)
    bg:SetPoint("BOTTOM", 0, 0)
    bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg")

    scrollBar.Back:ClearAllPoints()
    scrollBar.Back:SetPoint("BOTTOM", scrollBar, "TOP", 0, -13)
    scrollBar.Back:SetSize(12,12)
    bg = scrollBar.Back:CreateTexture(nil, "BACKGROUND", nil, 0)
    bg:ClearAllPoints();
    bg:SetPoint("TOPLEFT",0,0)
    bg:SetPoint("BOTTOMRIGHT",0,0)
    bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbutton")

    scrollBar.Forward:ClearAllPoints()
    scrollBar.Forward:SetPoint("TOP", scrollBar, "BOTTOM", 0, 13)
    scrollBar.Forward:SetSize(12,12)
    bg = scrollBar.Forward:CreateTexture(nil, "BACKGROUND", nil, 0)
    bg:ClearAllPoints();
    bg:SetPoint("TOPLEFT",0,0)
    bg:SetPoint("BOTTOMRIGHT",0,0)
    bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbutton")
    bg:SetTexCoord(0,1,1,0)
end
GW.HandleScrollControls = HandleScrollControls

local function HandleTrimScrollBar(frame)
    frame:GwStripTextures()

    ReskinScrollBarArrow(frame.Back, "up")
    ReskinScrollBarArrow(frame.Forward, "down")

    if frame.Background then
        frame.Background:Hide()
    end

    local track = frame.Track
    if track then
        track:DisableDrawLayer("ARTWORK")
    end

    local thumb = frame:GetThumb()
    if thumb then
        thumb:DisableDrawLayer("ARTWORK")
        thumb:DisableDrawLayer("BACKGROUND")
        thumb:GwCreateBackdrop("ScrollBar")
        thumb.backdrop:SetFrameLevel(thumb:GetFrameLevel() + 1)
        local h = thumb:GetHeight()
        thumb:SetSize(12, h)
        --thumb:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbarmiddle")
    end
end
GW.HandleTrimScrollBar = HandleTrimScrollBar

local function HandleItemButton(b, setInside)
    if b.isSkinned then return end

    local name = b:GetName()
    local icon = b.icon or b.Icon or b.IconTexture or b.iconTexture or (name and (_G[name .. "IconTexture"] or _G[name .. "Icon"]))
    local texture = icon and icon.GetTexture and icon:GetTexture()

    b:GwStripTextures()
    b:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    b:GwStyleButton()

    if icon then
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        if setInside then
            icon:GwSetInside(b)
        else
            b.backdrop:GwSetOutside(icon, 1, 1)
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
    local function handleButton(button, i, buttonNameTemplate)
        local icon, texture = button.Icon or _G[buttonNameTemplate..i.."Icon"], ""
        if icon then
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            icon:GwSetInside(button)
            texture = icon:GetTexture()
        end

        button:GwStripTextures()
        button:GwStyleButton(nil, true)

        if texture then
            icon:SetTexture(texture)
        end
    end

    local function HandleIconSelectionFrame(frame)
        if frame.isSkinned then return end

        local borderBox = frame.BorderBox
        local editBox = borderBox.IconSelectorEditBox
        local cancel = frame.CancelButton or (borderBox and borderBox.CancelButton)
        local okay = frame.OkayButton or (borderBox and borderBox.OkayButton)

        frame:GwStripTextures()
        frame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
        frame:SetHeight(frame:GetHeight() + 10)

        if borderBox then
            borderBox:GwStripTextures()

            local button = borderBox.SelectedIconArea and borderBox.SelectedIconArea.SelectedIconButton
            if button then
                button:DisableDrawLayer("BACKGROUND")
                GW.HandleItemButton(button, true)
            end
        end

        cancel:ClearAllPoints()
        cancel:SetPoint("BOTTOMRIGHT", frame, -4, 4)
        cancel:GwSkinButton(false, true)

        okay:ClearAllPoints()
        okay:SetPoint("RIGHT", cancel, "LEFT", -10, 0)
        okay:GwSkinButton(false, true)

        if editBox then
            GW.SkinTextBox(editBox.IconSelectorPopupNameMiddle, editBox.IconSelectorPopupNameLeft, editBox.IconSelectorPopupNameRight, nil, nil, 5, 5)
        end

        GW.HandleTrimScrollBar(frame.IconSelector.ScrollBar, true)
        GW.HandleScrollControls(frame.IconSelector)

        for _, button in next, {frame.IconSelector.ScrollBox.ScrollTarget:GetChildren()} do
            handleButton(button)
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
        tab:GwStripTextures()
    end

    if skinAsButton then
        tab:GwSkinButton(false, true)
    end
    tab:SetHitRectInsets(0, 0, 0, 0)
    tab:GetFontString():SetTextColor(0, 0, 0)
end
GW.HandleTabs = HandleTabs

local function CreateFrameHeaderWithBody(frame, titleText, icon, detailBackgrounds)
    local header = CreateFrame("Frame", frame:GetName() .. "Header", frame, "GwFrameHeader")
    header.windowIcon:SetTexture(icon)
    frame.gwHeader = header

    header:SetWidth(frame:GetWidth() - 20)
    header.BGLEFT:SetWidth(frame:GetWidth() - 20)
    header.BGRIGHT:SetWidth(frame:GetWidth() - 20)

    if titleText then
        titleText:ClearAllPoints()
        titleText:SetParent(header)
        titleText:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 64, 10)
        titleText:SetFont(DAMAGE_TEXT_FONT, 20)
        titleText:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    end

    local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
    tex:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-background")
    frame.tex = tex

    if detailBackgrounds then
        for _, v in pairs(detailBackgrounds) do
            local detailBg = v:CreateTexture(nil, "BACKGROUND", nil, 0)
            detailBg:SetPoint("TOPLEFT", v, "TOPLEFT", 0,0)
            detailBg:SetPoint("BOTTOMRIGHT", v, "BOTTOMRIGHT", 0, 0)
            detailBg:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background")
            detailBg:SetTexCoord(0, 0.70703125, 0, 0.580078125)
            v.tex = detailBg
        end
    end
end
GW.CreateFrameHeaderWithBody = CreateFrameHeaderWithBody
