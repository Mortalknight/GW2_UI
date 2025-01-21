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

local constBackdropFrameStatusBar = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/StatusBar",
    --edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.skins.constBackdropStatusBar = constBackdropFrameStatusBar

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

local function HandleItemButton(b, setInside)
    if b.isSkinned then return end

    local name = b:GetName()
    local icon = b.icon or b.Icon or b.IconTexture or b.iconTexture or (name and (_G[name .. "IconTexture"] or _G[name .. "Icon"]))
    local texture = icon and icon.GetTexture and icon:GetTexture()

    b:GwStripTextures()
    b:GwCreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)
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

local function HandleAchivementsScrollControls(self, specifiedScrollBar)
    local scrollBar = specifiedScrollBar and self[specifiedScrollBar] or self.ScrollBar
    scrollBar:SetWidth(20)

    scrollBar.Track:ClearAllPoints()
    scrollBar.Track:SetPoint("TOPLEFT", scrollBar, "TOPLEFT", 0, -12)
    scrollBar.Track:SetPoint("BOTTOMRIGHT", scrollBar, "BOTTOMRIGHT", 0, 12)
    scrollBar.Track.Thumb.backdrop:SetWidth(12)

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
GW.HandleAchivementsScrollControls = HandleAchivementsScrollControls

local function HandleScrollControls(self, specifiedScrollBar)
    local scrollBar = specifiedScrollBar and self[specifiedScrollBar] or self.ScrollBar
    if not scrollBar then return end
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
    if not frame then return end
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
        Backdrop:GwStripTextures()
        Backdrop:GwCreateBackdrop(constBackdropFrame)

        local menuBackdrop = _G[listFrameName .. "MenuBackdrop"]
        menuBackdrop:GwStripTextures()
        menuBackdrop:GwCreateBackdrop(constBackdropFrame)
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
                button:GwCreateBackdrop()
            end

            button.backdrop:Hide()

            if button.hasArrow then
                arrow:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right")
            end

            if not button.notCheckable then
                button.backdrop:Show()
            end
        end
    end)

    hooksecurefunc("UIDropDownMenu_SetIconImage", function(icon, texture)
        if texture:find("Divider") then
            icon:SetColorTexture(1, 0.93, 0.73, 0.45)
            icon:SetHeight(1)
        end
    end)
end

local backdrops = {}
local function SkinFrame(frame)
    frame:GwStripTextures()

    if backdrops[frame] then
        frame.backdrop = backdrops[frame] -- relink it back
    else
        frame:GwCreateBackdrop(constBackdropFrame)
        backdrops[frame] = frame.backdrop

        if frame.ScrollBar then
            GW.HandleTrimScrollBar(frame.ScrollBar)
        end
    end
end

local function OpenMenu(manager, region, menuDescription)
    local menu = manager:GetOpenMenu()
    if menu then
        SkinFrame(menu)
        menuDescription:AddMenuAcquiredCallback(SkinFrame)
    end
end

local function SkinDropDown()
    if not GW.settings.DROPDOWN_SKIN_ENABLED then return end
    SkinDropDownList()
    SkinUIDropDownMenu()

    local manager = Menu.GetManager()
    hooksecurefunc(manager, "OpenMenu", OpenMenu)
    hooksecurefunc(manager, "OpenContextMenu", OpenMenu)
end
GW.SkinDropDown = SkinDropDown

local function HandleIcon(icon, backdrop, backdropTexture)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    if backdrop and not icon.backdrop then
        icon:GwCreateBackdrop(backdropTexture)
    end
end
GW.HandleIcon = HandleIcon

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
        --local tex = frame:CreateTexture("bg", "BACKGROUND", -7)
        --tex:SetPoint("TOP", frame, "TOP", 0, 25)
        --tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
        --local w, h = frame:GetSize()
        --tex:SetSize(w + 50, h + 50)
        --frame.tex = tex
        frame:GwCreateBackdrop({
            edgeFile = "",
            bgFile = "Interface/AddOns/GW2_UI/textures/party/manage-group-bg",
            edgeSize = 1
        }, true, 50, 50, nil, 25)
    end

end
GW.HandlePortraitFrame = HandlePortraitFrame

local function CreateFrameHeaderWithBody(frame, titleText, icon, detailBackgrounds, yOffset)
    local header = CreateFrame("Frame", frame:GetName() .. "Header", frame, "GwFrameHeader")
    header.windowIcon:SetTexture(icon)
    frame.gwHeader = header

    header:SetWidth(frame:GetWidth() - 20)
    header.BGLEFT:SetWidth(frame:GetWidth() - 20)
    header.BGRIGHT:SetWidth(frame:GetWidth() - 20)


    if titleText then
        if type(titleText) ~= "string" then
            titleText:ClearAllPoints()
            titleText:SetParent(header)
            titleText:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 64, 10)
            titleText:SetFont(DAMAGE_TEXT_FONT, 20)
            titleText:SetTextColor(255 / 255, 241 / 255, 209 / 255)
        else
            header.headerText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            header.headerText:ClearAllPoints()
            header.headerText:SetParent(header)
            header.headerText:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 64, 10)
            header.headerText:SetFont(DAMAGE_TEXT_FONT, 20)
            header.headerText:SetTextColor(255 / 255, 241 / 255, 209 / 255)
            header.headerText:SetText(titleText)
        end
    end

    local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
    tex:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, yOffset or 0)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-background")
    frame.tex = tex

    if detailBackgrounds then
        for _, v in pairs(detailBackgrounds) do
            local detailBg = v:CreateTexture("bg", "BACKGROUND", nil, 0)
            detailBg:SetPoint("TOPLEFT", v, "TOPLEFT", 0,0)
            detailBg:SetPoint("BOTTOMRIGHT", v, "BOTTOMRIGHT", 0, 0)
            detailBg:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background")
            detailBg:SetTexCoord(0, 0.70703125, 0, 0.580078125)
            v.tex = detailBg
        end
    end
end
GW.CreateFrameHeaderWithBody = CreateFrameHeaderWithBody

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

local function HandleTabs(self, isTop)
    if self and not self.isSkinned then
        self:GwStripTextures()
        self:GetFontString():SetTextColor(1, 1, 1, 1)
        self:GetFontString():SetShadowOffset(0, 0)

        local tex = self:CreateTexture(nil, "BACKGROUND")
        tex:SetPoint("LEFT", self, "LEFT")
        tex:SetPoint("TOP", self, "TOP")
        tex:SetPoint("BOTTOM", self, "BOTTOM")
        tex:SetPoint("RIGHT", self, "RIGHT")
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/buttonlightInner")
        self.tex = tex
        self.tex:SetAlpha(1)

        self.borderFrame = CreateFrame("Frame", nil, self, "GwLightButtonBorder")

        self.background = self:CreateTexture(nil, "BACKGROUND", nil, -7)
        self.background:SetAllPoints(self)
        self.background:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-header")
        if not isTop then
            self.background:SetTexCoord(0, 1, 1, 0)
            self.borderFrame.bottom:Show()
            self.borderFrame.top:Hide()
        else
            self.borderFrame.bottom:Hide()
            self.borderFrame.top:Show()
        end

        local text = self.Text or _G[self:GetName() .. "Text"]
        if text then
            text:SetPoint("CENTER", self, "CENTER", 0, 0)
        end

        if self.SetTabSelected then
            hooksecurefunc(self, "SetTabSelected", function(tab)
                if tab.isSelected then
                    tab.background:SetBlendMode("MOD")
                else
                    tab.background:SetBlendMode("BLEND")
                end
                text:SetPoint("CENTER", self, "CENTER", 0, 0)
            end)
            if self.isSelected then
                self.background:SetBlendMode("MOD")
            else
                self.background:SetBlendMode("BLEND")
            end
        else
            hooksecurefunc("PanelTemplates_DeselectTab", function(tab)
                if self == tab then
                    tab.background:SetBlendMode("BLEND")
                    text:SetPoint("CENTER", tab, "CENTER", 0, 0)
                end
            end)
            hooksecurefunc("PanelTemplates_SelectTab", function(tab)
                if self == tab then
                    tab.background:SetBlendMode("MOD")
                    text:SetPoint("CENTER", tab, "CENTER", 0, 0)
                end
            end)
            if self.LeftActive and self.LeftActive:IsShown() then -- selected
                self.background:SetBlendMode("MOD")
            else
                self.background:SetBlendMode("BLEND")
            end
        end

        self.isSkinned = true
    end
end
GW.HandleTabs = HandleTabs

local function HandleRotateButton(btn)
    if btn.isSkinned then return end

    btn:GwSkinButton(false, true)
    btn:SetSize(btn:GetWidth() - 14, btn:GetHeight() - 14)

    local normTex = btn:GetNormalTexture()
    local pushTex = btn:GetPushedTexture()
    local highlightTex = btn:GetHighlightTexture()

    normTex:GwSetInside()
    normTex:SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

    pushTex:SetAllPoints(normTex)
    pushTex:SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

    highlightTex:SetAllPoints(normTex)
    highlightTex:SetColorTexture(1, 1, 1, 0.3)

    btn.isSkinned = true
end
GW.HandleRotateButton = HandleRotateButton
