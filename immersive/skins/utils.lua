local _, GW = ...

--middle left right
local function SkinTextBox(middleTex, leftTex, rightTex, topTex, bottomTex, leftOffset, rightOffset, noTop)
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
        elseif not noTop then
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
            bottomTex:SetPoint("TOPLEFT",pframe,"BOTTOMLEFT", -(leftOffset or 0), 0)
            bottomTex:SetPoint("TOPRIGHT",pframe,"BOTTOMRIGHT",( rightOffset or 0), 0)
            bottomTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbarBorderPixel")
            bottomTex:SetTexCoord(0, 1, 1, 0)
            bottomTex:SetAlpha(1)
        elseif not noTop then
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
    local iconColors = {
        ['auctionhouse-itemicon-border-gray']		= {r = .61, g = .61, b = .61},
        ['auctionhouse-itemicon-border-white']		= BAG_ITEM_QUALITY_COLORS[Enum.ItemQuality.Common],
        ['auctionhouse-itemicon-border-green']		= BAG_ITEM_QUALITY_COLORS[Enum.ItemQuality.Uncommon],
        ['auctionhouse-itemicon-border-blue']		= BAG_ITEM_QUALITY_COLORS[Enum.ItemQuality.Rare],
        ['auctionhouse-itemicon-border-purple']		= BAG_ITEM_QUALITY_COLORS[Enum.ItemQuality.Epic],
        ['auctionhouse-itemicon-border-orange']		= BAG_ITEM_QUALITY_COLORS[Enum.ItemQuality.Legendary],
        ['auctionhouse-itemicon-border-artifact']	= BAG_ITEM_QUALITY_COLORS[Enum.ItemQuality.Artifact],
        ['auctionhouse-itemicon-border-account']	= BAG_ITEM_QUALITY_COLORS[Enum.ItemQuality.Heirloom]
    }

    local function iconBorderColorAtlas(border, atlas)
        local color = iconColors[atlas]
        if not color then return end

        if border.customFunc then
            local br, bg, bb = 1, 1, 1
            border.customFunc(border, color.r, color.g, color.b, 1, br, bg, bb)
        elseif border.customBackdrop then
            border.customBackdrop:SetBackdropBorderColor(color.r, color.g, color.b)
        end
    end

    local function iconBorderColorVertex(border, r, g, b, a)
        if border.customFunc then
            local br, bg, bb = 1, 1, 1
            border.customFunc(border, r, g, b, a, br, bg, bb)
        elseif border.customBackdrop then
            border.customBackdrop:SetBackdropBorderColor(r, g, b)
        end
    end

    local function iconBorderHide(border, value)
        if value == 0 then return end -- hiding blizz border

        local br, bg, bb = 1, 1, 1
        if border.customFunc then
            local r, g, b, a = border:GetVertexColor()
            border.customFunc(border, r, g, b, a, br, bg, bb)
        elseif border.customBackdrop then
            border.customBackdrop:SetBackdropBorderColor(br, bg, bb)
        end
    end

    local function iconBorderShown(border, show)
        if show then
            border:Hide(0)
        else
            iconBorderHide(border)
        end
    end

    local function HandleIconBorder(border, backdrop, customFunc)
        if not backdrop then
            local parent = border:GetParent()
            backdrop = parent.backdrop or parent
        end

        if border.customBackdrop ~= backdrop then
            border.customBackdrop = backdrop
        end

        local r, g, b, a = border:GetVertexColor()
        local atlas = iconColors[border.GetAtlas and border:GetAtlas()]
        if customFunc then
            border.customFunc = customFunc
            local br, bg, bb = 1, 1, 1
            customFunc(border, r, g, b, a, br, bg, bb)
        elseif atlas then
            backdrop:SetBackdropBorderColor(atlas.r, atlas.g, atlas.b, 1)
        elseif r then
            backdrop:SetBackdropBorderColor(r, g, b, a)
        else
            local br, bg, bb = 1, 1, 1
            backdrop:SetBackdropBorderColor(br, bg, bb)
        end

        if not border.IconBorderHooked then
            border.IconBorderHooked = true
            border:Hide()

            hooksecurefunc(border, 'SetAtlas', iconBorderColorAtlas)
            hooksecurefunc(border, "SetVertexColor", iconBorderColorVertex)
            hooksecurefunc(border, "Hide", iconBorderHide)
            hooksecurefunc(border, 'SetShown', iconBorderShown)
            hooksecurefunc(border, 'Show', iconBorderShown)

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
        thumb.Begin:Hide()
        thumb.End:Hide()
        thumb.Middle:Hide()
        thumb:DisableDrawLayer("BACKGROUND")
        thumb.gwTex = thumb:CreateTexture(nil, "ARTWORK")
        thumb.gwTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbarmiddle")
        thumb.gwTex:SetAllPoints(thumb)
        thumb:SetWidth(12)
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
        local icon, texture = button.Icon or _G[buttonNameTemplate..i.."Icon"]
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
        frame:EnableMouse(true)

        if borderBox then
            borderBox:GwStripTextures()

            local dropdown = borderBox.IconTypeDropdown
            if dropdown then
                dropdown:GwHandleDropDownBox()
            end

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

        GW.HandleTrimScrollBar(frame.IconSelector.ScrollBar)
        GW.HandleScrollControls(frame.IconSelector)

        for _, button in next, {frame.IconSelector.ScrollBox.ScrollTarget:GetChildren()} do
            handleButton(button)
        end

        frame.isSkinned = true
    end
    GW.HandleIconSelectionFrame = HandleIconSelectionFrame
end

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

        self.Text:SetPoint("CENTER", self, "CENTER", 0, 0)

        if self.SetTabSelected then
            hooksecurefunc(self, "SetTabSelected", function(tab)
                if tab.isSelected then
                    tab.background:SetBlendMode("MOD")
                else
                    tab.background:SetBlendMode("BLEND")
                end
                tab.Text:SetPoint("CENTER", self, "CENTER", 0, 0)
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
                    tab.Text:SetPoint("CENTER", tab, "CENTER", 0, 0)
                end
            end)
            hooksecurefunc("PanelTemplates_SelectTab", function(tab)
                if self == tab then
                    tab.background:SetBlendMode("MOD")
                    tab.Text:SetPoint("CENTER", tab, "CENTER", 0, 0)
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

local function CreateFrameHeaderWithBody(frame, titleText, icon, detailBackgrounds, detailBackgroundsXOffset, addLeftSidePanel, addFrameOpenAnimation)
    local header = CreateFrame("Frame", frame:GetName() .. "Header", frame, "GwFrameHeader")
    header.windowIcon:SetTexture(icon)
    header:SetClampedToScreen(true)
    header:SetMovable(true)
    frame.gwHeader = header

    if titleText then
        titleText:ClearAllPoints()
        titleText:SetParent(header)
        titleText:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 64, 10)
        titleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 2)
        titleText:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    end

    local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
    tex:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-background")
    frame.tex = tex

    if detailBackgrounds then
        for _, v in pairs(detailBackgrounds) do
            local detailBg = v:CreateTexture(nil, "BACKGROUND", nil, 0)
            detailBg:SetPoint("TOPLEFT", v, "TOPLEFT", detailBackgroundsXOffset or 0, 0)
            detailBg:SetPoint("BOTTOMRIGHT", v, "BOTTOMRIGHT", 0, 0)
            detailBg:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background")
            detailBg:SetTexCoord(0, 0.70703125, 0, 0.580078125)
            v.tex = detailBg
        end
    end


    if addLeftSidePanel then
        frame.LeftSidePanel = CreateFrame("Frame", frame:GetName() .. "LeftPanel", frame, "GwWindowLeftPanel")
    end

    if addFrameOpenAnimation then
        local bgMask = UIParent:CreateMaskTexture()
        bgMask:SetPoint("TOPLEFT", frame, "TOPLEFT", -64, 64)
        bgMask:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -64, 0)
        bgMask:SetTexture(
            "Interface/AddOns/GW2_UI/textures/masktest",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )

        frame.tex:AddMaskTexture(bgMask)
        header.BGLEFT:AddMaskTexture(bgMask)
        header.BGRIGHT:AddMaskTexture(bgMask)
        if frame.LeftSidePanel then
            frame.LeftSidePanel.background:AddMaskTexture(bgMask)
        end
        frame.backgroundMask = bgMask

        frame:HookScript("OnShow",function()
        GW.AddToAnimation((frame.GetName and frame:GetName() or tostring(frame)) .. "_PANEL_ONSHOW", 0, 1, GetTime(), GW.WINDOW_FADE_DURATION,
            function(p)
                frame:SetAlpha(p)
                bgMask:SetPoint("BOTTOMRIGHT", frame.tex, "BOTTOMLEFT", GW.lerp(-64, frame.tex:GetWidth(), p), 0)
            end, 1, function()
                bgMask:SetPoint("BOTTOMRIGHT", frame.tex, "BOTTOMLEFT", frame.tex:GetWidth() + 200 , 0)
            end)
        end)
    end
end
GW.CreateFrameHeaderWithBody = CreateFrameHeaderWithBody

local function AddDetailsBackground(frame, detailBackgroundsXOffset, detailBackgroundsYOffset)
    local detailBg = frame:CreateTexture(nil, "BACKGROUND", nil, 7)
    detailBg:SetPoint("TOPLEFT", frame, "TOPLEFT", detailBackgroundsXOffset or 0, detailBackgroundsYOffset or 0)
    detailBg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    detailBg:SetTexture("Interface/AddOns/GW2_UI/textures/character/worldmap-questlog-background")
    detailBg:SetTexCoord(0, 0.70703125, 0, 0.580078125)
    frame.tex = detailBg
end
GW.AddDetailsBackground = AddDetailsBackground

local function HandleListIcon(frame)
    if not frame.tableBuilder then return end

    for i = 1, 22 do
        local row = frame.tableBuilder.rows[i]
        if row then
            for j = 1, 4 do
                local cell = row.cells and row.cells[j]
                if cell and cell.Icon then
                    if not cell.IsSkinned then
                        GW.HandleIcon(cell.Icon)

                        if cell.IconBorder then
                            cell.IconBorder:GwKill()
                        end

                        cell.IsSkinned = true
                    end
                end
            end
        end
    end
end

local function HandleHeaders(frame)
    local maxHeaders = frame.HeaderContainer:GetNumChildren()
    for i, header in next, { frame.HeaderContainer:GetChildren() } do
        if not header.IsSkinned then
            header:DisableDrawLayer("BACKGROUND")

            if not header.backdrop then
                header:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
                header.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
            end

            header.IsSkinned = true
        end

        if header.backdrop then
            header.backdrop:SetPoint("BOTTOMRIGHT", i < maxHeaders and -5 or 0, -2)
        end
    end

    HandleListIcon(frame)
end
GW.HandleSrollBoxHeaders = HandleHeaders

local function HandleScrollFrameHeaderButton(button, isLastButton)
    if not button.IsSkinned then
        if button.DisableDrawLayer then
            button:DisableDrawLayer("BACKGROUND")
        end

        if not button.backdrop then
            button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
            button.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
            button.backdrop:SetFrameLevel(button:GetFrameLevel())
        end

        button.IsSkinned = true
    end

    if button.backdrop then
        button.backdrop:SetPoint("BOTTOMRIGHT", isLastButton and 0 or -5, -2)
    end
end
GW.HandleScrollFrameHeaderButton = HandleScrollFrameHeaderButton

local function AddMouseMotionPropagationToChildFrames(self)
    for _, child in next, { self:GetChildren() } do
        if not InCombatLockdown() then
            child:SetPropagateMouseMotion(true)
        end
        AddMouseMotionPropagationToChildFrames(child)
    end
end

local function AddListItemChildHoverTexture(child)
    child.Background = child:CreateTexture(nil, "BACKGROUND", nil, 0)
    child.Background:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg")
    child.Background:ClearAllPoints()
    child.Background:SetPoint("TOPLEFT", child, "TOPLEFT", 0, 0)
    child.Background:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", 0, 0)
    child.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    if child.HighlightTexture then
        child.HighlightTexture:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover")
        child.HighlightTexture:SetVertexColor(0.8, 0.8, 0.8, 0.8)
        child.HighlightTexture:GwSetInside(child.Background)
        child:HookScript("OnEnter", function()
            GW.TriggerButtonHoverAnimation(child, child.HighlightTexture)
        end)
    elseif child.Highlight then
        child.Highlight:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover")
        child.Highlight:SetVertexColor(0.8, 0.8, 0.8, 0.8)
        child.Highlight:GwSetInside(child.Background)
        child:HookScript("OnEnter", function()
            GW.TriggerButtonHoverAnimation(child, child.Highlight)
        end)
    else -- create hover texture
        child.gwHoverTexture = child:CreateTexture(nil, "ARTWORK", nil, 0)
        child.gwHoverTexture:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover")
        child.gwHoverTexture:SetVertexColor(0.8, 0.8, 0.8, 0.8)
        child.gwHoverTexture:SetPoint("TOPLEFT", child, "TOPLEFT", 0, 0)
        child.gwHoverTexture:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", 0, 0)
        child.gwHoverTexture:Hide()
        child:HookScript("OnEnter", function()
            child.gwHoverTexture:Show()
            GW.TriggerButtonHoverAnimation(child, child.gwHoverTexture)
        end)
        child:HookScript("OnLeave", function()
            child.gwHoverTexture:Hide()
        end)

        child.gwSelected = child:CreateTexture(nil, "ARTWORK", nil, 0)
        child.gwSelected:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover")
        child.gwSelected:SetVertexColor(0.8, 0.8, 0.8, 1)
        child.gwSelected:SetPoint("TOPLEFT", child, "TOPLEFT", 0, 0)
        child.gwSelected:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", 0, 0)
        child.gwSelected:Hide()
    end

    AddMouseMotionPropagationToChildFrames(child)
end
GW.AddListItemChildHoverTexture = AddListItemChildHoverTexture

local function HandleItemListScrollBoxHover(self)
    for _, child in next, { self.ScrollTarget:GetChildren() } do
        if not child.IsSkinned then
            AddListItemChildHoverTexture(child)

            child.IsSkinned = true
        end
        if not InCombatLockdown() then
            child:SetPropagateMouseMotion(true)
        end

        --zebra
        local zebra = child.GetOrderIndex and (child:GetOrderIndex() % 2) == 1 or false
        if zebra then
            child.Background:SetVertexColor(1, 1, 1, 1)
        else
            child.Background:SetVertexColor(0, 0, 0, 0)
        end

        if child.NormalTexture then
            child.NormalTexture:SetAlpha(0)
        end
        if child.BackgroundHighlight then
            child.BackgroundHighlight:SetAlpha(0)
        end
        if child.SelectedHighlight then
            child.SelectedHighlight:SetColorTexture(0.5, 0.5, 0.5, .25)
        end
        if child.Selected then
            child.Selected:SetColorTexture(0.5, 0.5, 0.5, .25)
        end
    end
end
GW.HandleItemListScrollBoxHover = HandleItemListScrollBoxHover

local function SkinSideTabButton(self, iconTexture, tooltipText)
    self.isSkinned = true
    self:GwStripTextures()
    self:SetSize(64, 40)
    self.Text:Hide()

    self.icon = self:CreateTexture(nil, "BACKGROUND", nil, 0)
    self.icon:SetAllPoints()

    self.icon:SetTexture(iconTexture)

    self.icon:SetTexCoord(0.5, 1, 0, 0.625)

    if tooltipText then
        self:HookScript("OnEnter", function()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(tooltipText, 1, 1, 1)
            GameTooltip:Show()
        end)
        self:HookScript("OnLeave", GameTooltip_Hide)
    end

    if self.SetTabSelected then
        hooksecurefunc(self, "SetTabSelected", function(tab)
            if tab.isSelected then
                tab.icon:SetTexCoord(0, 0.5, 0, 0.625)
            else
                tab.icon:SetTexCoord(0.5, 1, 0, 0.625)
            end
        end)
        if self.isSelected then
            self.icon:SetTexCoord(0, 0.5, 0, 0.625)
        end
    else
        hooksecurefunc("PanelTemplates_DeselectTab", function(tab)
            if self == tab then
                tab.icon:SetTexCoord(0.5, 1, 0, 0.625)
            end
        end)
        hooksecurefunc("PanelTemplates_SelectTab", function(tab)
            if self == tab then
                tab.icon:SetTexCoord(0, 0.5, 0, 0.625)
            end
        end)
        hooksecurefunc("PanelTemplates_TabResize", function(tab)
            if self == tab then
                tab:SetSize(64, 40)
            end
        end)

        if not self:IsEnabled() then -- selected tab
            self.icon:SetTexCoord(0, 0.5, 0, 0.625)
        end
    end
end
GW.SkinSideTabButton = SkinSideTabButton

local function LockBlackButtonColor(button, r, g, b)
    if r ~= 0 or g ~= 0 or b ~= 0 then
        button:SetTextColor(0, 0, 0)
    end
end
GW.LockBlackButtonColor = LockBlackButtonColor

local function LockWhiteButtonColor(button, r, g, b)
    if r ~= 1 or g ~= 1 or b ~= 1 then
        button:SetTextColor(1, 1, 1)
    end
end
GW.LockWhiteButtonColor = LockWhiteButtonColor
