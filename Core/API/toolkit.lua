---@class GW2
local GW = select(2, ...)

----- Added API to Frames -----

-- the art pieces of blizzards button, tab and border templates, by key or global name suffix
local TEMPLATE_ART = {
    "Left", "Middle", "Mid", "Right", "LeftDisabled", "MiddleDisabled", "RightDisabled",
    "TopLeft", "TopMiddle", "TopRight", "MiddleLeft", "MiddleMiddle", "MiddleRight", "BottomLeft", "BottomMiddle", "BottomRight",
    "TopLeftTex", "TopTex", "TopRightTex", "LeftTex", "MiddleTex", "RightTex", "BottomLeftTex", "BottomTex", "BottomRightTex",
    "TabSpacer", "TabSpacer1", "TabSpacer2", "_LeftSeparator", "_RightSeparator",
    "Background", "Border", "Center", "Cover",
}

-- child frames of blizzard templates that carry nothing but art, stripping a frame strips them too
local ART_FRAMES = {
    "Inset", "inset", "InsetFrame", "LeftInset", "RightInset", "bottomInset", "BottomInset",
    "NineSlice", "BG", "border", "Border", "BorderFrame", "ScrollFrameBorder", "bgLeft", "bgRight",
    "Portrait", "portrait", "PortraitOverlay", "ArtOverlayFrame", "FilligreeOverlay",
}

local tabs = {"Left", "Middle", "Right", "LeftDisabled", "MiddleDisabled", "RightDisabled"}

-- our arrow textures point up
local ArrowRotation = {up = 0, down = math.pi, left = math.pi / 2, right = -math.pi / 2}

local function GetPart(frame, key, name)
    return frame[key] or name and _G[name .. key]
end

local function HandleBlizzardRegions(frame)
    local name = frame.GetName and frame:GetName()
    for _, key in ipairs(TEMPLATE_ART) do
        local art = GetPart(frame, key, name)
        if art then
            art:SetAlpha(0)
        end
    end
end
GW.HandleBlizzardRegions = HandleBlizzardRegions

-- 12.x: the backdrop mixin fails on a secret frame size, such frames keep their texture coordinates
local function SetupTextureCoordinates(frame)
    local width, height = frame:GetSize()
    if GW.NotSecretValue(width) and GW.NotSecretValue(height) then
        BackdropTemplateMixin.SetupTextureCoordinates(frame)
    end
end

function GW.ReplaceSetupTextureCoordinates(frame)
    if issecretvalue then
        frame.SetupTextureCoordinates = SetupTextureCoordinates
    end
end

-- the parts of old style scroll bars; some templates keep the arrows on the parent
local SCROLL_UP_KEYS = {"ScrollUpButton", "UpButton", "ScrollUp", "Back"}
local SCROLL_DOWN_KEYS = {"ScrollDownButton", "DownButton", "ScrollDown", "Forward"}
local SCROLL_THUMB_KEYS = {"ThumbTexture", "thumbTexture", "Thumb"}

local function FindScrollPart(frame, keys, parentKey)
    local name = frame:GetName()
    for _, key in ipairs(keys) do
        local part = GetPart(frame, key, name)
        if part then
            return part
        end
    end
    local parent = parentKey and frame:GetParent()
    return parent and parent[parentKey]
end

local killedRegions = {}

local function StayHidden(region)
    region:Hide()
end

-- gone for good: frames leave for the hidden parent, regions hide again whenever they are shown;
-- secure hooks instead of replacing Show, writing into blizzards regions would taint
local function GwKill(object)
    if object.UnregisterAllEvents then
        object:UnregisterAllEvents()
        object:SetParent(GW.HiddenFrame)
    elseif not killedRegions[object] then
        killedRegions[object] = true
        hooksecurefunc(object, "Show", StayHidden)
        hooksecurefunc(object, "SetShown", StayHidden)
    end
    object:Hide()
end

-- kill hides the textures for good, alpha only fades them, otherwise they lose their file
local function StripTexture(texture, kill, alpha)
    if kill then
        texture:GwKill()
    elseif alpha then
        texture:SetAlpha(0)
    else
        texture:SetTexture()
    end
end

-- every texture of the frame and of its art child frames
local function GwStripTextures(object, kill, alpha)
    if object:IsObjectType("Texture") then
        StripTexture(object, kill, alpha)
        return
    end

    local name = object.GetName and object:GetName()
    for _, key in ipairs(ART_FRAMES) do
        local child = GetPart(object, key, name)
        if child and child.GwStripTextures then
            child:GwStripTextures(kill, alpha)
        end
    end
    if object.GetRegions then
        for _, region in ipairs({object:GetRegions()}) do
            if region:IsObjectType("Texture") then
                StripTexture(region, kill, alpha)
            end
        end
    end
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

local function GwSkinCheckButton(button, isRadio, size, artOnly)
    if button.gwSkinned then return end
    if size and not artOnly then
        button:SetSize(size, size)
    end
    if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png") end
    if button.SetCheckedTexture then button:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png") end
    if button.SetDisabledCheckedTexture then button:SetDisabledCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png") end
    if button.SetPushedTexture then button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png") end
    if button.SetDisabledTexture then button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal.png") end

    if isRadio then
        local Check = button:GetCheckedTexture()
        if Check then Check:SetTexCoord(0, 1, 0, 1) end

        local Normal = button:GetNormalTexture()
        if Normal then Normal:SetTexCoord(0, 1, 0, 1) end

        local Disabled = button:GetDisabledTexture()
        if Disabled then Disabled:SetTexCoord(0, 1, 0, 1) end

        hooksecurefunc(button, "SetHighlightTexture", buttonHighlightTexture)
    end

    for _, getter in ipairs({"GetNormalTexture", "GetPushedTexture", "GetCheckedTexture", "GetDisabledTexture", "GetDisabledCheckedTexture", "GetHighlightTexture"}) do
        local texture = button[getter] and button[getter](button)
        if texture then
            texture:ClearAllPoints()
            if artOnly then
                texture:SetPoint("CENTER")
                texture:SetSize(size, size)
            else
                texture:SetAllPoints(button)
            end
        end
    end

    button.gwSkinned = true
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

        for _, region in ipairs({frame:GetRegions()}) do
            if region and region:IsObjectType("FontString") then
                local point, anchor, anchorPoint, x, y = region:GetPoint()
                if strfind(anchorPoint, "BOTTOM") then
                    region:SetPoint(point, anchor, anchorPoint, x, y - 4)
                end
            end
        end
    end
end

local function GwOffsetFrameLevel(frame, offset, referenceFrame)
    if not referenceFrame then
        referenceFrame = frame
    end

    local frameLevel = referenceFrame.GetFrameLevel and referenceFrame:GetFrameLevel()
    if frameLevel then
        frame:SetFrameLevel(math.max(0, frameLevel + (offset or 0)))
    end
end

local function GwSetFrameTemplate(frame, style)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)

        if frame.OnSizeChanged then
            frame:HookScript("OnSizeChanged", frame.OnBackdropSizeChanged)
        end
    end

    GW.ReplaceSetupTextureCoordinates(frame)
    frame:SetBackdrop({
        edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white.png",
        bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png",
        edgeSize = GW.Scale(1)
    })

    if style == "Dark" then
        frame:SetBackdropBorderColor(0, 0, 0, 1)
    end

    local backdrop = {
        edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white.png",
        edgeSize = GW.Scale(1)
    }

    local level = frame:GetFrameLevel()
    if not frame.iborder then
        local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        GW.ReplaceSetupTextureCoordinates(border)
        border:SetBackdrop(backdrop)
        border:SetBackdropBorderColor(0, 0, 0, 1)
        border:SetFrameLevel(level)
        border:GwSetInside(frame, 1, 1)
        frame.iborder = border
    end

    if not frame.oborder then
        local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        GW.ReplaceSetupTextureCoordinates(border)
        border:SetBackdrop(backdrop)
        border:SetBackdropBorderColor(0, 0, 0, 1)
        border:SetFrameLevel(level)
        border:GwSetOutside(frame, 1, 1)
        frame.oborder = border
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
    if button.gwSkinned then return end

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

    button.gwSkinned = true
end

local function SetButtonFontStringColor(button, r, g, b, a)
    if button.GetFontString then
        local fontString = button:GetFontString()
        if fontString then
            fontString:SetTextColor(r, g, b, a or 1)
        end
    end

    if button.Text and button.Text.SetTextColor then
        button.Text:SetTextColor(r, g, b, a or 1)
    end

    if button.ButtonText and button.ButtonText.SetTextColor then
        button.ButtonText:SetTextColor(r, g, b, a or 1)
    end

    if button.GetRegions then
        for _, region in pairs({button:GetRegions()}) do
            if region.GetObjectType and region:GetObjectType() == "FontString" then
                region:SetTextColor(r, g, b, a or 1)
            end
        end
    end
end

local function GwSkinNegativeButton(button)
    if not button then return end

    if button.CreateTexture and button.HookScript then
        GwAddHover(button)
    end

    SetButtonFontStringColor(button, 0.55, 0.05, 0.05)

    if button.GetNormalTexture then
        local normalTexture = button:GetNormalTexture()
        if normalTexture and normalTexture.SetVertexColor then
            normalTexture:SetVertexColor(1, 0.84, 0.84)
        end
    end

    if button.hover then
        button.hover.r, button.hover.g, button.hover.b = 1, 0.2, 0.2
    end

    if not button.HookScript or button.isGwNegativeButton then return end
    button.isGwNegativeButton = true

    button:HookScript("OnEnter", function(self)
        if self.IsEnabled and not self:IsEnabled() then return end
        SetButtonFontStringColor(self, 1, 0.96, 0.96)
    end)
    button:HookScript("OnLeave", function(self)
        SetButtonFontStringColor(self, 0.55, 0.05, 0.05)
    end)
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
    local ScrollUpButton = FindScrollPart(frame, SCROLL_UP_KEYS, "scrollUp")
    local ScrollDownButton = FindScrollPart(frame, SCROLL_DOWN_KEYS, "scrollDown")
    local Thumb = FindScrollPart(frame, SCROLL_THUMB_KEYS) or (frame.GetThumbTexture and frame:GetThumbTexture())

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
    if frame.gwSkinned then return end
    frame.gwSkinned = true
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
        text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
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
        text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        text:SetTextColor(178 / 255, 178 / 255, 178 / 255)
        text:SetHeight(frame:GetHeight())
        text:SetJustifyV("MIDDLE")
    end

    if icon then
        icon:SetPoint("LEFT", 23, 0)
    end
end

local ARROW_TEXTURE = "Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down.png"

local function SkinMaxMinButton(button, direction)
    button:SetSize(20, 20)
    button:ClearAllPoints()
    button:SetPoint("CENTER")
    button:SetHitRectInsets(1, 1, 1, 1)
    button:GetHighlightTexture():GwKill()
    for _, state in ipairs({"Normal", "Pushed"}) do
        button["Set" .. state .. "Texture"](button, ARROW_TEXTURE)
        button["Get" .. state .. "Texture"](button):SetRotation(ArrowRotation[direction])
    end
end

-- the maximize and minimize arrows of the world map and co.
local function GwHandleMaxMinFrame(frame)
    if frame.gwSkinned then return end
    frame.gwSkinned = true

    frame:GwStripTextures(true)
    if frame.MaximizeButton then
        SkinMaxMinButton(frame.MaximizeButton, "up")
    end
    if frame.MinimizeButton then
        SkinMaxMinButton(frame.MinimizeButton, "down")
    end
end

-- words in a button name that tell where its arrow points, checked in this order; down if none fits
local ARROW_NAME_WORDS = {
    {"left", {"left", "prev", "back", "decrement"}},
    {"right", {"right", "next", "forward", "increment"}},
    {"up", {"scrollup", "upbutton", "top", "asc", "home", "maximize"}},
}

local function GuessArrowDirection(button)
    local name = strlower(button:GetDebugName() or "")
    for _, entry in ipairs(ARROW_NAME_WORDS) do
        for _, word in ipairs(entry[2]) do
            if strfind(name, word, 1, true) then
                return entry[1]
            end
        end
    end
    return "down"
end

local function HandleNextPrevButton(button, arrowDir, noBackdrop)
    if button.gwSkinned then return end
    button.gwSkinned = true

    button:GwStripTextures()
    button:SetSize(20, 20)
    local rotation = ArrowRotation[arrowDir or GuessArrowDirection(button)]
    for _, state in ipairs({"Normal", "Pushed", "Disabled", "Highlight"}) do
        button["Set" .. state .. "Texture"](button, ARROW_TEXTURE)
        local texture = button["Get" .. state .. "Texture"](button)
        if texture then
            texture:SetTexCoord(0, 1, 0, 1)
            if rotation then
                texture:SetRotation(rotation)
            end
        end
    end

    local shade = noBackdrop and 0.5 or 0.3
    button:GetDisabledTexture():SetVertexColor(shade, shade, shade)
    if noBackdrop then
        button.Texture = button:GetNormalTexture()
    end
end
GW.HandleNextPrevButton = HandleNextPrevButton

-- lays obj over the anchor, by default its parent: grown by the offsets on every side, or shrunk
local function Span(obj, anchor, xOffset, yOffset, grow)
    anchor = anchor or obj:GetParent()
    local x, y = GW.Scale(xOffset or GW.BorderSize), GW.Scale(yOffset or GW.BorderSize)
    if grow then
        x, y = -x, -y
    end
    obj:ClearAllPoints()
    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", x, -y)
    obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -x, y)
end

local function GwSetOutside(obj, anchor, xOffset, yOffset)
    Span(obj, anchor, xOffset, yOffset, true)
end

local function GwSetInside(obj, anchor, xOffset, yOffset)
    Span(obj, anchor, xOffset, yOffset, false)
end

-- flat overlays for hover, pushed and checked; the no* flags keep what the button has
local STYLE_OVERLAYS = {
    {key = "hover", texture = "HighlightTexture", color = {1, 1, 1, 0.3}},
    {key = "pushed", texture = "PushedTexture", color = {0.9, 0.8, 0.1, 0.3}},
    {key = "checked", texture = "CheckedTexture", color = {1, 1, 1, 0.3}},
}

local function GwStyleButton(button, noHover, noPushed, noChecked)
    local skip = {noHover, noPushed, noChecked}
    for i, overlay in ipairs(STYLE_OVERLAYS) do
        local setter = button["Set" .. overlay.texture]
        if setter and not skip[i] and not button[overlay.key] then
            setter(button, "Interface/AddOns/GW2_UI/textures/uistuff/white.png")
            local texture = button["Get" .. overlay.texture](button)
            texture:GwSetInside()
            texture:SetBlendMode("ADD")
            texture:SetColorTexture(unpack(overlay.color))
            button[overlay.key] = texture
        end
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

-- 12.0.7: font strings lost their own shadow, only font objects still draw one; so every font, size,
-- style and shadow combination gets a font family of its own, the same font for every alphabet
local FONT_ALPHABETS = {"roman", "korean", "simplifiedchinese", "traditionalchinese", "russian"}
local fontFamilies, fontFamilyCount = {}, 0

local function GetFontFamily(prefix, font, size, style, shadow)
    local key = font .. "|" .. size .. "|" .. style .. (shadow and "|shadow" or "")
    local family = fontFamilies[key]
    if family then
        return family
    end

    local members = {}
    for i, alphabet in ipairs(FONT_ALPHABETS) do
        members[i] = {alphabet = alphabet, file = font, height = size, flags = style}
    end
    fontFamilyCount = fontFamilyCount + 1
    family = CreateFontFamily(prefix .. fontFamilyCount, members)

    -- outlined text needs a lighter shadow
    for _, alphabet in ipairs(FONT_ALPHABETS) do
        local fontObject = family:GetFontObjectForAlphabet(alphabet)
        fontObject:SetShadowColor(0, 0, 0, shadow and (style == "" and 1 or 0.6) or 0)
        fontObject:SetShadowOffset(shadow and 1 or 0, shadow and -1 or 0)
    end
    fontFamilies[key] = family
    return family
end

-- Gold value fill between track start and thumb; the anchors follow the thumb, so
-- no update code is needed
local function AddSliderValueFill(slider)
    local fill = slider:CreateTexture(nil, "BORDER")
    fill:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    fill:SetVertexColor(1, 1, 1)
    fill:SetAlpha(0.9)
    fill:SetHeight(4)
    fill:SetPoint("LEFT", slider, "LEFT", 3, 0)
    fill:SetPoint("RIGHT", slider:GetThumbTexture(), "CENTER", 0, 0)
    return fill
end
GW.AddSliderValueFill = AddSliderValueFill

-- Brand logo stack: the blue dragon with a gently pulsing black outline and a soft
-- additive glow. Returns the holder frame - anchor it, everything scales with size.
-- The outline lives on an own child frame and the ANIMATION runs on that frame:
-- scale animations directly on textures composite the region above its layer
-- siblings while transforming and snap at the loop turnaround
local function CreateBrandLogo(parent, size)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(size, size)

    local glow = holder:CreateTexture(nil, "BACKGROUND")
    glow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/glow.png")
    glow:SetBlendMode("ADD")
    glow:SetVertexColor(0.25, 0.6, 1)
    glow:SetAlpha(0.35)
    glow:SetSize(size * 2, size * 2)
    glow:SetPoint("CENTER")

    local outlineFrame = CreateFrame("Frame", nil, holder)
    outlineFrame:SetFrameLevel(holder:GetFrameLevel() + 1)
    outlineFrame:SetSize(size * 1.26, size * 1.26)
    outlineFrame:SetPoint("CENTER")

    local outline = outlineFrame:CreateTexture(nil, "ARTWORK")
    outline:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwlogo-outline.png")
    outline:SetAlpha(0.9)
    outline:SetAllPoints(outlineFrame)

    local logoFrame = CreateFrame("Frame", nil, holder)
    logoFrame:SetFrameLevel(holder:GetFrameLevel() + 2)
    logoFrame:SetAllPoints(holder)

    local logo = logoFrame:CreateTexture(nil, "ARTWORK")
    logo:SetTexture("Interface/AddOns/GW2_UI/textures/gwlogo.png")
    logo:SetAllPoints(logoFrame)

    -- endless seamless pulse: a cosine wave has no turnaround point, so unlike a
    -- BOUNCE animation group there is nothing to snap at. Runs only while shown
    local PULSE_PERIOD, PULSE_AMOUNT = 4, 0.08
    local pulseTime = 0
    outlineFrame:SetScript("OnUpdate", function(self, elapsed)
        pulseTime = (pulseTime + elapsed) % PULSE_PERIOD
        self:SetScale(1 + PULSE_AMOUNT * (0.5 - 0.5 * math.cos(pulseTime / PULSE_PERIOD * 2 * math.pi)))
    end)

    holder.logo = logo
    holder.outline = outline
    holder.glow = glow
    return holder
end
GW.CreateBrandLogo = CreateBrandLogo

local function GwSetFontTemplate(object, font, textSizeType, style, textSizeAddition, skip)
    if not object or not font or not object.SetFont or not textSizeType then return end

    if not skip then -- can be used for ignoring setting updates and used for update function
        object.gwFont, object.gwTextSizeType, object.gwStyle, object.gwTextSizeAddition = font, textSizeType, style, textSizeAddition
    end

    local size
    if textSizeType == GW.Enum.TextSizeType.BigHeader then
        size = GW.settings.fonts.size.bigHeader or 18
    elseif textSizeType == GW.Enum.TextSizeType.Header then
        size = GW.settings.fonts.size.header or 16
    elseif textSizeType == GW.Enum.TextSizeType.Normal then
        size = GW.settings.fonts.size.normal or 14
    elseif textSizeType == GW.Enum.TextSizeType.Small then
        size = GW.settings.fonts.size.small or 12
    end
    if not size then return end
    size = size + (textSizeAddition or 0)

    local shadow = style and strsub(style, 0, 6) == "SHADOW"
    if shadow then
        style = strsub(style, 7) -- shadow isnt a real style, fall back to the outline setting
        if style == "" then style = nil end
    end

    style = style or GW.settings.fonts.outline or ""
    if style == "NONE" then style = "" end

    if CreateFontFamily and object.SetFontObject then
        object:SetFontObject(GetFontFamily("GW2_UI_FontTemplate", font, size, style, shadow))
    else
        object:SetFont(font, size, style)
        if shadow then
            object:SetShadowColor(0, 0, 0, style == "" and 1 or 0.6)
            object:SetShadowOffset(1, -1)
        end
    end

    -- register font for size changes
    GW.texts[object] = true
end

local function GwLockTextColor(object, r, g, b, a)
    if not object or not object.SetTextColor then return end

    object.gwLockedTextColorR = r
    object.gwLockedTextColorG = g
    object.gwLockedTextColorB = b
    object.gwLockedTextColorA = a or 1

    if not object.GwTextColorLockedHooked then
        hooksecurefunc(object, "SetTextColor", function(self)
            if not self.gwLockedTextColorR or self.GWUpdatingLockedTextColor then return end

            self.GWUpdatingLockedTextColor = true
            self:SetTextColor(self.gwLockedTextColorR, self.gwLockedTextColorG, self.gwLockedTextColorB, self.gwLockedTextColorA)
            self.GWUpdatingLockedTextColor = nil
        end)

        object.GwTextColorLockedHooked = true
    end

    object:SetTextColor(object.gwLockedTextColorR, object.gwLockedTextColorG, object.gwLockedTextColorB, object.gwLockedTextColorA)
end
GW.LockFontStringColor = GwLockTextColor

-- shifts the frame by x/y from its first anchor; the anchors of blizzard frames can be secret in
-- combat (the damage meter on a combat reload), those stay where they are
local function GwNudgePoint(obj, x, y)
    local point, relativeTo, relativePoint, xOfs, yOfs = obj:GetPoint(1)
    if GW.IsSecretValue(point) or GW.IsSecretValue(relativePoint) or GW.IsSecretValue(xOfs) or GW.IsSecretValue(yOfs) or not point then
        return
    end
    obj:SetPoint(point, relativeTo, relativePoint, xOfs + GW.Scale(x or 0), yOfs + GW.Scale(y or 0))
end

-- all widgets of one type share a method table, so one widget of each type is enough
local API = {
    GwKill = GwKill,
    GwStripTextures = GwStripTextures,
    GwAddHover = GwAddHover,
    GwSkinCheckButton = GwSkinCheckButton,
    GwSkinSliderFrame = GwSkinSliderFrame,
    GwCreateBackdrop = GwCreateBackdrop,
    GwSkinButton = GwSkinButton,
    GwSkinNegativeButton = GwSkinNegativeButton,
    GwSkinTab = GwSkinTab,
    GwSkinScrollFrame = GwSkinScrollFrame,
    GwSkinScrollBar = GwSkinScrollBar,
    GwSkinDropDownMenu = GwSkinDropDownMenu,
    GwHandleMaxMinFrame = GwHandleMaxMinFrame,
    GwSetOutside = GwSetOutside,
    GwSetInside = GwSetInside,
    GwStyleButton = GwStyleButton,
    GwKillEditMode = GwKillEditMode,
    GwHandleDropDownBox = GwHandleDropDownBox,
    GwSetFontTemplate = GwSetFontTemplate,
    GwLockTextColor = GwLockTextColor,
    GwOffsetFrameLevel = GwOffsetFrameLevel,
    GwNudgePoint = GwNudgePoint,
    GwSetFrameTemplate = GwSetFrameTemplate,
}

local methodTables = {}
local function Collect(widget)
    methodTables[getmetatable(widget).__index] = true
end

local sample = CreateFrame("Frame")
Collect(sample)
Collect(sample:CreateTexture())
Collect(sample:CreateFontString())
Collect(sample:CreateMaskTexture())
Collect(GameFontNormal)

-- the widget types that already exist
local frame = EnumerateFrames()
while frame do
    if not frame:IsForbidden() then
        Collect(frame)
    end
    frame = EnumerateFrames(frame)
end

-- and those that may not exist yet: load on demand addons (collections, encounter journal ...)
-- create their models and bars later
for _, frameType in ipairs({"Button", "CheckButton", "EditBox", "StatusBar", "Slider", "Cooldown", "ScrollFrame", "SimpleHTML", "MessageFrame", "ScrollingMessageFrame", "PlayerModel", "DressUpModel", "CinematicModel", "ModelScene", "ColorSelect"}) do
    local ok, widget = pcall(CreateFrame, frameType, nil, GW.HiddenFrame)
    if ok and widget then
        -- the probe frames must never take input: an edit box auto focuses and would swallow the keyboard
        if widget.SetAutoFocus then
            widget:SetAutoFocus(false)
            widget:ClearFocus()
        end
        if widget.EnableKeyboard then
            widget:EnableKeyboard(false)
        end
        widget:EnableMouse(false)
        widget:Hide()
        Collect(widget)
    end
end

for methods in pairs(methodTables) do
    for name, func in pairs(API) do
        if methods[name] == nil then
            methods[name] = func
        end
    end
end
