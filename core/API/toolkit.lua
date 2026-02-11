local _, GW = ...

----- Added API to Frames -----
local BlizzardRegions = {
    "Left",
    "Middle",
    "Right",
    "Mid",
    "LeftDisabled",
    "MiddleDisabled",
    "RightDisabled",
    "TopLeft",
    "TopRight",
    "BottomLeft",
    "BottomRight",
    "TopMiddle",
    "MiddleLeft",
    "MiddleRight",
    "BottomMiddle",
    "MiddleMiddle",
    "TabSpacer",
    "TabSpacer1",
    "TabSpacer2",
    "_RightSeparator",
    "_LeftSeparator",
    "Cover",
    "Border",
    "Background",
    "TopTex",
    "TopLeftTex",
    "TopRightTex",
    "LeftTex",
    "BottomTex",
    "BottomLeftTex",
    "BottomRightTex",
    "RightTex",
    "MiddleTex",
    "Center",
}

local ArrowRotation = {
    up = 0,
    down = 3.14,
    left = 1.57,
    right = -1.57,
}

local tabs = {
    "LeftDisabled",
    "MiddleDisabled",
    "RightDisabled",
    "Left",
    "Middle",
    "Right"
}

local StripTexturesBlizzFrames = {
    "Inset",
    "inset",
    "InsetFrame",
    "LeftInset",
    "RightInset",
    "NineSlice",
    "BG",
    "border",
    "Border",
    "BorderFrame",
    "bottomInset",
    "BottomInset",
    "bgLeft",
    "bgRight",
    "FilligreeOverlay",
    "PortraitOverlay",
    "ArtOverlayFrame",
    "Portrait",
    "portrait",
    "ScrollFrameBorder",
}

local function HandleBlizzardRegions(frame)
    local name = frame.GetName and frame:GetName()
    for _, area in pairs(BlizzardRegions) do
        local object = (name and _G[name .. area]) or frame[area]
        if object then
            object:SetAlpha(0)
        end
    end
end
GW.HandleBlizzardRegions = HandleBlizzardRegions

-- 12.0 secret restrictions break SetBackdrop (width is secret...)
function GW.NotSizeRestricted(frame)
    if not frame or not frame.GetSize then return true end

    local width, height = frame:GetSize()
    return GW.NotSecretValue(width) and GW.NotSecretValue(height)
end

function GW.SetupTextureCoordinates(self)
    if GW.NotSizeRestricted(self) then
        _G.BackdropTemplateMixin.SetupTextureCoordinates(self)
    end
end

-- temp until blizzard fixes the backdrop mixin from this error
function GW.ReplaceSetupTextureCoordinates(frame)
    if GW.Retail and frame.SetupTextureCoordinates ~= GW.SetupTextureCoordinates then
        frame.SetupTextureCoordinates = GW.SetupTextureCoordinates
    end
end

local upButtons = {"ScrollUpButton", "UpButton", "ScrollUp", {"scrollUp", true}, "Back"}
local downButtons = {"ScrollDownButton", "DownButton", "ScrollDown", {"scrollDown", true}, "Forward"}
local thumbButtons = {"ThumbTexture", "thumbTexture", "Thumb"}

local function GetElement(frame, element, useParent)
    if useParent then frame = frame:GetParent() end
    if not frame then return end

    local child = frame[element]
    if child then return child end

    local name = frame.GetName and frame:GetName()
    if name then return _G[name..element] end
end

local function GetButton(frame, buttons)
    for _, data in ipairs(buttons) do
        if type(data) == "string" then
            local found = GetElement(frame, data)
            if found then return found end
        else
            local found = GetElement(frame, data[1], data[2])
            if found then return found end
        end
    end
end

local function StripRegion(which, object, kill, alpha)
    if kill then
        object:GwKill()
    elseif alpha then
        object:SetAlpha(0)
    elseif which == "Texture" then
        object:SetTexture()
    elseif which == "FontString" then
        object:SetText("")
    end
end

local function StripType(which, object, kill, alpha)
    if object:IsObjectType(which) then
        StripRegion(which, object, kill, alpha)
    else
        if which == "Texture" then
            local FrameName = object.GetName and object:GetName()
            for _, Blizzard in pairs(StripTexturesBlizzFrames) do
                local BlizzFrame = object[Blizzard] or (FrameName and _G[FrameName .. Blizzard])
                if BlizzFrame and BlizzFrame.GwStripTextures then
                    BlizzFrame:GwStripTextures(kill, alpha)
                end
            end
        end

        if object.GetNumRegions then
            for i = 1, object:GetNumRegions() do
                local region = select(i, object:GetRegions())
                if region and region.IsObjectType and region:IsObjectType(which) then
                    StripRegion(which, region, kill, alpha)
                end
            end
        end
    end
end

local function GwStripTextures(object, kill, alpha)
    StripType("Texture", object, kill, alpha)
end

local function GwKill(object)
    if object.UnregisterAllEvents then
        object:UnregisterAllEvents()
        object:SetParent(GW.HiddenFrame)
    else
        object.Show = object.Hide
    end

    object:Hide()
end

local function GwAddHover(self)
    if not self.hover then
        self.hover = self:CreateTexture(nil, "ARTWORK", nil, 6)
        self.hover:SetPoint("LEFT", self, "LEFT")
        self.hover:SetPoint("TOP", self, "TOP")
        self.hover:SetPoint("BOTTOM", self, "BOTTOM")
        self.hover:SetPoint("RIGHT", self, "RIGHT")
        self.hover:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover.png")
        self.hover:SetAlpha(0)

        self:HookScript("OnEnter", GwStandardButton_OnEnter)
        self:HookScript("OnLeave", GwStandardButton_OnLeave)
    end
end

local function buttonHighlightTexture(frame, texture) if texture ~= nil then frame:SetHighlightTexture(nil) end end

local function GwSkinCheckButton(button, isRadio)
    if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png") end
    if button.SetCheckedTexture then button:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png") end
    if button.SetDisabledCheckedTexture then button:SetDisabledCheckedTexture(
        "Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png") end
    if button.SetPushedTexture then button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png") end
    if button.SetDisabledTexture then button:SetDisabledTexture(
        "Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal.png") end

    if isRadio then
        local Check = button:GetCheckedTexture()
        if Check then Check:SetTexCoord(0, 1, 0, 1) end

        local Normal = button:GetNormalTexture()
        if Normal then Normal:SetTexCoord(0, 1, 0, 1) end

        local Disabled = button:GetDisabledTexture()
        if Disabled then Disabled:SetTexCoord(0, 1, 0, 1) end

        hooksecurefunc(button, "SetHighlightTexture", buttonHighlightTexture)
    end

    button.isSkinned = true
end

local function GwSkinSliderFrame(frame)
    local orientation = frame:GetOrientation()
    local SIZE = 12

    if frame.SetBackdrop then
        frame:SetBackdrop()
    end

    frame:GwStripTextures()
    frame:SetThumbTexture("Interface/AddOns/GW2_UI/textures/uistuff/sliderhandle.png")

    if not frame.backdrop then
        frame:GwCreateBackdrop()
    end

    local thumb = frame:GetThumbTexture()
    thumb:SetSize(SIZE - 2, SIZE - 2)

    local tex = frame:CreateTexture(nil, "BACKGROUND")
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/sliderbg.png")
    frame.tex = tex
    frame.tex:SetPoint("TOPLEFT", frame, "TOPLEFT")
    frame.tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

    if frame.Text then
        frame.Text:SetTextColor(1, 1, 1)
    end
    if frame.GetName and frame:GetName() and _G[frame:GetName() .. "Text"] then
        _G[frame:GetName() .. "Text"]:SetTextColor(1, 1, 1)
    end

    if orientation == "VERTICAL" then
        frame:SetWidth(SIZE)
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/sliderbg_vertical.png")
    else
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/sliderbg.png")
        frame:SetHeight(SIZE)

        for _, region in next, { frame:GetRegions() } do
            if region:IsObjectType("FontString") then
                local point, anchor, anchorPoint, x, y = region:GetPoint()
                if strfind(anchorPoint, "BOTTOM") then
                    region:SetPoint(point, anchor, anchorPoint, x, y - 4)
                end
            end
        end
    end
end

local function OffsetFrameLevel(frame, offset, referenceFrame)
    if not referenceFrame then
        referenceFrame = frame
    end

    local frameLevel = referenceFrame.GetFrameLevel and referenceFrame:GetFrameLevel()
    if frameLevel then
        frame:SetFrameLevel(math.max(0, frameLevel + (offset or 0)))
    end
end

local function GwCreateBackdrop(frame, template, isBorder, xOffset, yOffset, xShift, yShift)
    local parent = (frame.IsObjectType and frame:IsObjectType("Texture") and frame:GetParent()) or frame
    local backdrop = frame.backdrop or CreateFrame("Frame", nil, parent)
    if not frame.backdrop then frame.backdrop = backdrop end

    frame.template = template or "Default"

    if not backdrop.SetBackdrop then
        _G.Mixin(backdrop, _G.BackdropTemplateMixin)
        backdrop:HookScript("OnSizeChanged", backdrop.OnBackdropSizeChanged)
    end

    local frameLevel = parent.GetFrameLevel and parent:GetFrameLevel()
    local frameLevelMinusOne = frameLevel and (frameLevel - 1)

    if frameLevelMinusOne and (frameLevelMinusOne >= 0) then
        backdrop:SetFrameLevel(frameLevelMinusOne)
    else
        backdrop:SetFrameLevel(0)
    end

    if isBorder then
        local trunc = function(s) return s >= 0 and s - s % 01 or s - s % -1 end
        local round = function(s) return s >= 0 and s - s % -1 or s - s % 01 end
        local x = (GW.mult == 1 or (xOffset or 2) == 0) and (xOffset or 2) or
        ((GW.mult < 1 and trunc((xOffset or 2) / GW.mult) or round((xOffset or 2) / GW.mult)) * GW.mult)
        local y = (GW.mult == 1 or (yOffset or 2) == 0) and (yOffset or 2) or
        ((GW.mult < 1 and trunc((yOffset or 2) / GW.mult) or round((yOffset or 2) / GW.mult)) * GW.mult)

        xShift = xShift or 0
        yShift = yShift or 0
        backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -(x + xShift), (y - yShift))
        backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", (x - xShift), -(y + yShift))
    else
        backdrop:SetAllPoints()
    end

    GW.ReplaceSetupTextureCoordinates(backdrop)


    if template == "Transparent" then
        backdrop:SetBackdrop({
            edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white.png",
            bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png",
            edgeSize = GW.Scale(1)
        })
    elseif template == "Transparent White" then
        backdrop:SetBackdrop({
            edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white.png",
            bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/white.png",
            edgeSize = GW.Scale(1)
        })
        backdrop:SetBackdropColor(1, 1, 1, 0.4)
    elseif template == "ScrollBar" then
        backdrop:SetBackdrop({
            bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/scrollbarmiddle.png",
            edgeSize = GW.Scale(1)
        })
    elseif template then
        backdrop:SetBackdrop(template)
    else
        backdrop:SetBackdrop(nil)
    end
end

local function GwSkinButton(button, isXButton, setTextColor, onlyHover, noHover, strip, transparent, desaturatedIcon)
    if not button then return end
    if button.isSkinned then return end

    if strip then button:GwStripTextures(nil, true) end

    HandleBlizzardRegions(button)

    if isXButton then
        button:GwStripTextures()
    end

    if button.Texture then button.Texture:SetAlpha(0) end

    if not onlyHover then
        if isXButton then
            if button.SetNormalTexture then button:SetNormalTexture(
                "Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal.png") end
            if button.SetHighlightTexture then button:SetHighlightTexture(
                "Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover.png") end
            if button.SetPushedTexture then button:SetPushedTexture(
                "Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover.png") end
            if button.SetDisabledTexture then button:SetDisabledTexture(
                "Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal.png") end
        elseif transparent then
            if button.SetNormalTexture then button:SetNormalTexture("") end
            if button.SetHighlightTexture then button:SetHighlightTexture("") end
            if button.SetPushedTexture then button:SetPushedTexture("") end
            if button.SetDisabledTexture then button:SetDisabledTexture("") end
            if button.NormalTexture then button.NormalTexture:SetTexture("") end
            if button.HighlightTexture then button.HighlightTexture:SetTexture("") end
            if button.PushedTexture then button.PushedTexture:SetTexture("") end
            if button.DisabledTexture then button.DisabledTexture:SetTexture("") end
        else
            if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/button.png") end
            if button.SetHighlightTexture then
                button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover.png")
                button:GetHighlightTexture():SetVertexColor(0, 0, 0)
            end
            if button.SetPushedTexture then button:SetPushedTexture(
                "Interface/AddOns/GW2_UI/textures/uistuff/button_hover.png") end
            if button.SetDisabledTexture then button:SetDisabledTexture(
                "Interface/AddOns/GW2_UI/textures/uistuff/button_disable.png") end

            if strip then
                if button.SetNormalTexture then button:GetNormalTexture():Show() end
                if button.SetHighlightTexture then button:GetHighlightTexture():Show() end
                if button.SetPushedTexture then button:GetPushedTexture():Show() end
                if button.SetDisabledTexture then button:GetDisabledTexture():Show() end
            end
            local borderFrame = CreateFrame("Frame", nil, button, "GwButtonBorder")
            borderFrame:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
            borderFrame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
            button.gwBorderFrame = borderFrame
        end

        if setTextColor then
            if button.Text then
                button.Text:SetTextColor(0, 0, 0, 1)
                button.Text:SetShadowOffset(0, 0)
            else
                local r = { button:GetRegions() }
                for _, c in pairs(r) do
                    if c:GetObjectType() == "FontString" then
                        c:SetTextColor(0, 0, 0, 1)
                        c:SetShadowOffset(0, 0)
                    end
                end
            end

            if button.ButtonText then
                button.ButtonText:SetTextColor(0, 0, 0, 1)
                button.ButtonText:SetShadowOffset(0, 0)
            end
        end
    end


    if desaturatedIcon and button.Icon then
        button.Icon:SetDesaturated(true)
    end

    if (not isXButton or onlyHover) and not noHover then
        GwAddHover(button)
    end

    button.isSkinned = true
end

local function GwSkinTab(tabButton, direction)
    tabButton:GwCreateBackdrop()
    direction = direction and direction == "down" and "_down" or ""

    tabButton:GwStripTextures()

    if tabButton.SetNormalTexture then tabButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/units/unittab" .. direction .. ".png") end
    if tabButton.SetHighlightTexture then
        tabButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/units/unittab" .. direction .. ".png")
        tabButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    end
    if tabButton.SetPushedTexture then tabButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/units/unittab" .. direction .. ".png") end
    if tabButton.SetDisabledTexture then tabButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/units/unittab" .. direction .. ".png") end

    if tabButton.Text then
        tabButton.Text:SetShadowOffset(0, 0)
    end

    local r = { tabButton:GetRegions() }
    for _, c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:SetShadowOffset(0, 0)
        end
    end

    local highlightTex = tabButton.GetHighlightTexture and tabButton:GetHighlightTexture()
    if highlightTex then
        highlightTex:SetTexture()
    else
        tabButton:GwStripTextures()
    end

    if tabButton:GetName() then
        for _, object in pairs(tabs) do
            local textureName = _G[tabButton:GetName() .. object]
            if textureName then
                textureName:SetTexture()
            elseif tabButton[object] then
                tabButton[object]:SetTexture()
            end
        end
    end
end

local function GwSkinScrollFrame(frame)
    if frame.scrollBorderTop then frame.scrollBorderTop:Hide() end
    if frame.scrollBorderBottom then frame.scrollBorderBottom:Hide() end
    if frame.scrollFrameScrollBarBackground then frame.scrollFrameScrollBarBackground:Hide() end
    if frame.scrollBorderMiddle then
        frame.scrollBorderMiddle:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg.png")
        frame.scrollBorderMiddle:SetSize(3, frame.scrollBorderMiddle:GetSize())
        frame.scrollBorderMiddle:ClearAllPoints()
        frame.scrollBorderMiddle:SetPoint("TOPLEFT", frame, "TOPRIGHT", 12, -10)
        frame.scrollBorderMiddle:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 12, 10)
    end

    if frame:GetName() then
        if _G[frame:GetName() .. "ScrollBarTop"] then _G[frame:GetName() .. "ScrollBarTop"]:Hide() end
        if _G[frame:GetName() .. "ScrollBarBottom"] then _G[frame:GetName() .. "ScrollBarBottom"]:Hide() end
        if _G[frame:GetName() .. "ScrollBarMiddle"] then
            _G[frame:GetName() .. "ScrollBarMiddle"]:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg.png")
            _G[frame:GetName() .. "ScrollBarMiddle"]:SetSize(3, _G[frame:GetName() .. "ScrollBarMiddle"]:GetSize())
            _G[frame:GetName() .. "ScrollBarMiddle"]:ClearAllPoints()
            _G[frame:GetName() .. "ScrollBarMiddle"]:SetPoint("TOPLEFT", frame, "TOPRIGHT", 15, -10)
            _G[frame:GetName() .. "ScrollBarMiddle"]:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 12, 10)
        end

        if _G[frame:GetName() .. "Top"] then _G[frame:GetName() .. "Top"]:Hide() end
        if _G[frame:GetName() .. "Bottom"] then _G[frame:GetName() .. "Bottom"]:Hide() end
        if _G[frame:GetName() .. "Middle"] then
            _G[frame:GetName() .. "Middle"]:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg.png")
            _G[frame:GetName() .. "Middle"]:SetSize(3, _G[frame:GetName() .. "Middle"]:GetSize())
            _G[frame:GetName() .. "Middle"]:ClearAllPoints()
            _G[frame:GetName() .. "Middle"]:SetPoint("TOPLEFT", frame, "TOPRIGHT", 12, -10)
            _G[frame:GetName() .. "Middle"]:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 12, 10)
        end

        if _G[frame:GetName() .. "ScrollBar"] and _G[frame:GetName() .. "ScrollBar"].Top then _G
                [frame:GetName() .. "ScrollBar"].Top:Hide() end
        if _G[frame:GetName() .. "ScrollBar"] and _G[frame:GetName() .. "ScrollBar"].Bottom then _G
                [frame:GetName() .. "ScrollBar"].Bottom:Hide() end
        if _G[frame:GetName() .. "ScrollBar"] and _G[frame:GetName() .. "ScrollBar"].Background then _G
                [frame:GetName() .. "ScrollBar"].Background:Hide() end
        if _G[frame:GetName() .. "ScrollBar"] and _G[frame:GetName() .. "ScrollBar"].Middle then
            _G[frame:GetName() .. "ScrollBar"].Middle:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg.png")
            _G[frame:GetName() .. "ScrollBar"].Middle:SetSize(3, _G[frame:GetName() .. "ScrollBar"].Middle:GetSize())
            _G[frame:GetName() .. "ScrollBar"].Middle:ClearAllPoints()
            _G[frame:GetName() .. "ScrollBar"].Middle:SetPoint("TOPLEFT", frame, "TOPRIGHT", 12, -10)
            _G[frame:GetName() .. "ScrollBar"].Middle:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 12, 10)
        end
    end
end

local function GwSkinScrollBar(frame)
    local ScrollUpButton = GetButton(frame, upButtons)
    local ScrollDownButton = GetButton(frame, downButtons)
    local Thumb = GetButton(frame, thumbButtons) or (frame.GetThumbTexture and frame:GetThumbTexture())

    if ScrollUpButton and ScrollUpButton.SetNormalTexture then
        ScrollUpButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_up.png")
        ScrollUpButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")
        ScrollUpButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")
        ScrollUpButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_up.png")
    end

    if ScrollDownButton and ScrollDownButton.SetNormalTexture then
        ScrollDownButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up.png")
        ScrollDownButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
        ScrollDownButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
        ScrollDownButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up.png")
    end

    if Thumb and Thumb.SetTexture then
        Thumb:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbarmiddle.png")
        Thumb:SetSize(12, Thumb:GetHeight())
    end
end

local function GwHandleDropDownBox(frame, backdropTemplate, hookLayout, dropdownTag, width)
    local text = frame.Text
    if frame.Arrow then frame.Arrow:SetAlpha(0) end

    if not width or width == nil then
        width = 155
    end

    frame:SetWidth(width)
    frame:GwStripTextures()

    if backdropTemplate then
        frame:GwCreateBackdrop(backdropTemplate, true)
        frame.backdrop:SetBackdropColor(0, 0, 0)
    else
        frame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder) -- was StatusBar
    end
    frame:SetFrameLevel(frame:GetFrameLevel() + 2)
    frame.backdrop:SetPoint("TOPLEFT", 3, 0)
    frame.backdrop:SetPoint("BOTTOMRIGHT", -2, 0)

    local tex = frame:CreateTexture(nil, "ARTWORK")
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")
    tex:SetPoint("RIGHT", frame.backdrop, -3, 0)
    tex:SetRotation(3.14)
    tex:SetSize(14, 14)
    frame.gw2Arrow = tex

    if text then
        text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        text:SetTextColor(178 / 255, 178 / 255, 178 / 255)
        text:SetJustifyH("LEFT")
        text:SetJustifyV("MIDDLE")
    end

    if hookLayout or not GW.Retail then
        HandleBlizzardRegions(frame)
    end
end

local function GwSkinDropDownMenu(frame, buttonPaddindX, backdropTemplate, textBoxRightOffset)
    local frameName = frame.GetName and frame:GetName()
    local button = frame.Button or frameName and (_G[frameName .. "Button"] or _G[frameName .. "_Button"])
    local text = frameName and _G[frameName .. "Text"] or frame.Text
    local middle = frameName and _G[frameName .. "Middle"] or frame.Middle
    local left = frameName and _G[frameName .. "Left"] or frame.Left
    local right = frameName and _G[frameName .. "Right"] or frame.Right
    local icon = frame.Icon

    frame:GwStripTextures()
    frame:SetWidth(155)

    if backdropTemplate then
        frame:GwCreateBackdrop(backdropTemplate, true)
        frame.backdrop:SetBackdropColor(0, 0, 0)
    else
        frame:GwCreateBackdrop()
        GW.SkinTextBox(middle, left, right, nil, nil, -5, textBoxRightOffset or -10)
    end

    frame:SetFrameLevel(frame:GetFrameLevel() + 2)
    frame.backdrop:SetPoint("TOPLEFT", 5, -2)
    frame.backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, -2)

    button:ClearAllPoints()
    button:SetPoint("RIGHT", frame, "RIGHT", buttonPaddindX or -10, 0)

    button.SetPoint = GW.NoOp
    button:GwStripTextures()

    GW.HandleNextPrevButton(button, "down")

    if text then
        text:ClearAllPoints()
        text:SetPoint("RIGHT", button, "LEFT", -2, 0)
        text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        text:SetTextColor(178 / 255, 178 / 255, 178 / 255)
        text:SetHeight(frame:GetHeight())
        text:SetJustifyV("MIDDLE")
    end

    if icon then
        icon:SetPoint("LEFT", 23, 0)
    end
end

local btns = { MaximizeButton = "up", MinimizeButton = "down" }
local function GwHandleMaxMinFrame(frame)
    if frame.isSkinned then return end

    frame:GwStripTextures(true)

    for name, direction in pairs(btns) do
        local button = frame[name]
        if button then
            button:SetSize(20, 20)
            button:ClearAllPoints()
            button:SetPoint("CENTER")
            button:SetHitRectInsets(1, 1, 1, 1)
            button:GetHighlightTexture():GwKill()

            button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")
            button:GetNormalTexture():SetRotation(ArrowRotation[direction])

            button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")
            button:GetPushedTexture():SetRotation(ArrowRotation[direction])
        end
    end

    frame.isSkinned = true
end

local function HandleNextPrevButton(button, arrowDir, noBackdrop)
    if button.isSkinned then return end

    if not arrowDir then
        arrowDir = "down"
        local name = button:GetDebugName()
        local ButtonName = name and name:lower()
        if ButtonName then
            if strfind(ButtonName, "left") or strfind(ButtonName, "prev") or strfind(ButtonName, "decrement") or strfind(ButtonName, "backward") or strfind(ButtonName, "back") then
                arrowDir = "left"
            elseif strfind(ButtonName, "right") or strfind(ButtonName, "next") or strfind(ButtonName, "increment") or strfind(ButtonName, "forward") then
                arrowDir = "right"
            elseif strfind(ButtonName, "scrollup") or strfind(ButtonName, "upbutton") or strfind(ButtonName, "top") or strfind(ButtonName, "asc") or strfind(ButtonName, "home") or strfind(ButtonName, "maximize") then
                arrowDir = "up"
            end
        end
    end

    button:GwStripTextures()

    button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")
    button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")
    button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")
    button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png")

    local Normal, Disabled, Pushed, Highlight = button:GetNormalTexture(), button:GetDisabledTexture(),
        button:GetPushedTexture(), button:GetHighlightTexture()

    if noBackdrop then
        button:SetSize(20, 20)
        Disabled:SetVertexColor(.5, .5, .5)
        button.Texture = Normal
    else
        button:SetSize(20, 20)
        Disabled:SetVertexColor(.3, .3, .3)
    end

    Normal:SetTexCoord(0, 1, 0, 1)
    Pushed:SetTexCoord(0, 1, 0, 1)
    Disabled:SetTexCoord(0, 1, 0, 1)
    if Highlight then
        Highlight:SetTexCoord(0, 1, 0, 1)
    end

    local rotation = ArrowRotation[arrowDir]
    if rotation then
        Normal:SetRotation(rotation)
        Pushed:SetRotation(rotation)
        Disabled:SetRotation(rotation)
        if Highlight then
            Highlight:SetRotation(rotation)
        end
    end

    button.isSkinned = true
end
GW.HandleNextPrevButton = HandleNextPrevButton

local function GwSetOutside(obj, anchor, xOffset, yOffset, anchor2, noScale)
    if not anchor then anchor = obj:GetParent() end

    if not xOffset then xOffset = GW.BorderSize end
    if not yOffset then yOffset = GW.BorderSize end
    local x = (noScale and xOffset) or GW.Scale(xOffset)
    local y = (noScale and yOffset) or GW.Scale(yOffset)

    if GW.SetPointsRestricted(obj) or obj:GetPoint() then
        obj:ClearAllPoints()
    end

    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", -x, y)
    obj:SetPoint("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", x, -y)
end

local function GwSetInside(obj, anchor, xOffset, yOffset, anchor2, noScale)
    if not anchor then anchor = obj:GetParent() end

    if not xOffset then xOffset = GW.BorderSize end
    if not yOffset then yOffset = GW.BorderSize end
    local x = (noScale and xOffset) or GW.Scale(xOffset)
    local y = (noScale and yOffset) or GW.Scale(yOffset)

    if GW.SetPointsRestricted(obj) or obj:GetPoint() then
        obj:ClearAllPoints()
    end

    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", x, -y)
    obj:SetPoint("BOTTOMRIGHT", anchor2 or anchor, "BOTTOMRIGHT", -x, y)
end

local function GwStyleButton(button, noHover, noPushed, noChecked)
    if button.SetHighlightTexture and button.CreateTexture and not button.hover and not noHover then
        button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/white.png")

        local hover = button:GetHighlightTexture()
        hover:GwSetInside()
        hover:SetBlendMode("ADD")
        hover:SetColorTexture(1, 1, 1, 0.3)
        button.hover = hover
    end

    if button.SetPushedTexture and button.CreateTexture and not button.pushed and not noPushed then
        button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/white.png")

        local pushed = button:GetPushedTexture()
        pushed:GwSetInside()
        pushed:SetBlendMode("ADD")
        pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
        button.pushed = pushed
    end

    if button.SetCheckedTexture and button.CreateTexture and not button.checked and not noChecked then
        button:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/white.png")

        local checked = button:GetCheckedTexture()
        checked:GwSetInside()
        checked:SetBlendMode("ADD")
        checked:SetColorTexture(1, 1, 1, 0.3)
        button.checked = checked
    end

    if button.cooldown then
        button.cooldown:SetDrawEdge(false)
        button.cooldown:GwSetInside(button, 0, 0)
    end
end

local function GwKillEditMode(object)
    object.Selection:SetScript("OnDragStart", nil)
    object.Selection:SetScript("OnDragStop", nil)
    object.Selection:SetScript("OnMouseDown", nil)
    object.Selection:SetAlpha(0)
    object.Selection:EnableMouse(false)
end

local function GwSetFontTemplate(object, font, textSizeType, style, textSizeAddition, skip)
    if not object or not font or not object.SetFont or not textSizeType then return end

    if not skip then -- can be used for ignoring setting updates and used for update function
        object.gwFont, object.gwTextSizeType, object.gwStyle, object.gwTextSizeAddition = font, textSizeType, style, textSizeAddition
    end

    if textSizeType == GW.TextSizeType.BIG_HEADER then
        object:SetFont(font, (GW.settings.FONTS_BIG_HEADER_SIZE or 18) + (textSizeAddition or 0), style or GW.settings.FONTS_OUTLINE)
    elseif textSizeType == GW.TextSizeType.HEADER then
        object:SetFont(font, (GW.settings.FONTS_HEADER_SIZE or 16) + (textSizeAddition or 0), style or GW.settings.FONTS_OUTLINE)
    elseif textSizeType == GW.TextSizeType.NORMAL then
        object:SetFont(font, (GW.settings.FONTS_NORMAL_SIZE or 14) + (textSizeAddition or 0), style or GW.settings.FONTS_OUTLINE)
    elseif textSizeType == GW.TextSizeType.SMALL then
        object:SetFont(font, (GW.settings.FONTS_SMALL_SIZE or 12) + (textSizeAddition or 0), style or GW.settings.FONTS_OUTLINE)
    end

    -- register font for size changes
    GW.texts[object] = true
end

local function addapi(object)
    local mt = getmetatable(object).__index
    if not object.GwKill then mt.GwKill = GwKill end
    if not object.GwStripTextures then mt.GwStripTextures = GwStripTextures end
    if not object.GwAddHover then mt.GwAddHover = GwAddHover end
    if not object.GwSkinCheckButton then mt.GwSkinCheckButton = GwSkinCheckButton end
    if not object.GwSkinSliderFrame then mt.GwSkinSliderFrame = GwSkinSliderFrame end
    if not object.GwCreateBackdrop then mt.GwCreateBackdrop = GwCreateBackdrop end
    if not object.GwSkinButton then mt.GwSkinButton = GwSkinButton end
    if not object.GwSkinTab then mt.GwSkinTab = GwSkinTab end
    if not object.GwSkinScrollFrame then mt.GwSkinScrollFrame = GwSkinScrollFrame end
    if not object.GwSkinScrollBar then mt.GwSkinScrollBar = GwSkinScrollBar end
    if not object.GwSkinDropDownMenu then mt.GwSkinDropDownMenu = GwSkinDropDownMenu end
    if not object.GwHandleMaxMinFrame then mt.GwHandleMaxMinFrame = GwHandleMaxMinFrame end
    if not object.GwSetOutside then mt.GwSetOutside = GwSetOutside end
    if not object.GwSetInside then mt.GwSetInside = GwSetInside end
    if not object.GwStyleButton then mt.GwStyleButton = GwStyleButton end
    if not object.GwKillEditMode then mt.GwKillEditMode = GwKillEditMode end
    if not object.GwHandleDropDownBox then mt.GwHandleDropDownBox = GwHandleDropDownBox end
    if not object.GwSetFontTemplate then mt.GwSetFontTemplate = GwSetFontTemplate end
    if not object.OffsetFrameLevel then mt.OffsetFrameLevel = OffsetFrameLevel end
end

local handled = { Frame = true }
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())
addapi(object:CreateMaskTexture())

object = EnumerateFrames()
while object do
    local objectType = object:GetObjectType()
    if not object:IsForbidden() and not handled[objectType] then
        addapi(object)
        handled[objectType] = true
    end

    object = EnumerateFrames(object)
end

addapi(GameFontNormal)
addapi(CreateFrame("ScrollFrame"))
