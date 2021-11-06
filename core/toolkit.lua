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

local constBackdropDropDown = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar",
    edgeFile = "",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local function GrabScrollBarElement(frame, element)
    local FrameName = frame:GetDebugName()
    return frame[element] or FrameName and (_G[FrameName..element] or strfind(FrameName, element)) or nil
end

local function StripRegion(which, object, kill, alpha)
    if kill then
        object:Kill()
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
                if BlizzFrame and BlizzFrame.StripTextures then
                    BlizzFrame:StripTextures(kill, alpha)
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

local function StripTextures(object, kill, alpha)
    StripType("Texture", object, kill, alpha)
end

local function Kill(object)
    if object.UnregisterAllEvents then
        object:UnregisterAllEvents()
        object:SetParent(GW.HiddenFrame)
    else
        object.Show = object.Hide
    end

    object:Hide()
end

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

local function AddHover(self)
    if not self.hover then
        local hover = self:CreateTexture(nil, "ARTWORK", nil, 7)
        hover:SetPoint("LEFT", self, "LEFT")
        hover:SetPoint("TOP", self, "TOP")
        hover:SetPoint("BOTTOM", self, "BOTTOM")
        hover:SetPoint("RIGHT", self, "RIGHT")
        hover:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover")
        self.hover = hover
        self.hover:SetAlpha(0)

        --if self.OnEnter then
            self:HookScript("OnEnter", GwStandardButton_OnEnter)
        --else
        --    self:SetScript("OnEnter", GwStandardButton_OnEnter)
        --end
        --if self.OnLeave then
            self:HookScript("OnLeave", GwStandardButton_OnLeave)
        --else
        --    self:SetScript("OnLeave", GwStandardButton_OnLeave)
        --end
    end
end

local function SkinCheckButton(button)
    if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox") end
    if button.SetCheckedTexture then button:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked") end
    if button.SetDisabledCheckedTexture then button:SetDisabledCheckedTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked") end
    if button.SetPushedTexture then button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox") end
    if button.SetDisabledTexture then button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal") end
end

local function SkinSliderFrame(frame)
    local orientation = frame:GetOrientation()
    local SIZE = 12

    frame:SetBackdrop(nil)
    if not frame.backdrop then
        frame:CreateBackdrop()
    end

    frame:SetThumbTexture("Interface/AddOns/GW2_UI/textures/uistuff/sliderhandle")

    local thumb = frame:GetThumbTexture()
    thumb:SetSize(SIZE - 2, SIZE - 2)

    local tex = frame:CreateTexture("bg", "BACKGROUND")
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/sliderbg")
    frame.tex = tex

    if orientation == "VERTICAL" then
        frame:SetWidth(SIZE)
        --frame.tex:SetPoint("TOP", frame, "TOP")
        --frame.tex:SetPoint("BOTTOM", frame, "BOTTOM")
    else
        frame:SetHeight(SIZE)
        frame.tex:SetPoint("TOPLEFT", frame, "TOPLEFT")
        frame.tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

        for i = 1, frame:GetNumRegions() do
            local region = select(i, frame:GetRegions())
            if region and region:IsObjectType("FontString") then
                local point, anchor, anchorPoint, x, y = region:GetPoint()
                if strfind(anchorPoint, "BOTTOM") then
                    region:SetPoint(point, anchor, anchorPoint, x, y - 4)
                end
            end
        end
    end
end

local function CreateBackdrop(frame, template, isBorder, xOffset, yOffset, xShift, yShift)
    local parent = (frame.IsObjectType and frame:IsObjectType("Texture") and frame:GetParent()) or frame
    local backdrop = frame.backdrop or CreateFrame("Frame", nil, parent, "BackdropTemplate")
    if not frame.backdrop then frame.backdrop = backdrop end

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
        local trunc = function(s) return s >= 0 and s-s%01 or s-s%-1 end
        local round = function(s) return s >= 0 and s-s%-1 or s-s%01 end
        local x = (GW.mult == 1 or (xOffset or 2) == 0) and (xOffset or 2) or ((GW.mult < 1 and trunc((xOffset or 2) / GW.mult) or round((xOffset or 2) / GW.mult)) * GW.mult)
        local y = (GW.mult == 1 or (yOffset or 2) == 0) and (yOffset or 2) or ((GW.mult < 1 and trunc((yOffset or 2) / GW.mult) or round((yOffset or 2) / GW.mult)) * GW.mult)

        xShift = xShift or 0
        yShift = yShift or 0
        backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -(x + xShift), (y - yShift))
        backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", (x - xShift), -(y + yShift))

    else
        backdrop:SetAllPoints()
    end

    if template then
        backdrop:SetBackdrop(template)
    elseif template == "Transparent" then
        backdrop:SetBackdrop({
			edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white",
			bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background",
			edgeSize = GW.Scale(1)
		})
    else
        backdrop:SetBackdrop()
    end
end

local function SkinButton(button, isXButton, setTextColor, onlyHover, noHover, strip)
    if not button then return end

    if strip then button:StripTextures(nil, true) end

    local name = button.GetName and button:GetName()
    for _, area in pairs(BlizzardRegions) do
        local object = (name and _G[name .. area]) or button[area]
        if object then
            object:SetAlpha(0)
        end
    end

    if not onlyHover then
        if isXButton then
            if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal") end
            if button.SetHighlightTexture then button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover") end
            if button.SetPushedTexture then button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover") end
            if button.SetDisabledTexture then button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal") end
        else
            if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/button") end
            if button.SetHighlightTexture then
                button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover")
                button:GetHighlightTexture():SetVertexColor(0, 0, 0)
            end
            if button.SetPushedTexture then button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover") end
            if button.SetDisabledTexture then button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_disable") end

            if strip then
                if button.SetNormalTexture then button:GetNormalTexture():Show() end
                if button.SetHighlightTexture then button:GetHighlightTexture():Show() end
                if button.SetPushedTexture then button:GetPushedTexture():Show() end
                if button.SetDisabledTexture then button:GetDisabledTexture():Show() end
            end
            button:DisableDrawLayer("BACKGROUND")
        end

        if setTextColor then
            local r = {button:GetRegions()}
            for _,c in pairs(r) do
                if c:GetObjectType() == "FontString" then
                    c:SetTextColor(0, 0, 0, 1)
                    c:SetShadowOffset(0, 0)
                end
            end
        end
    end

    if (not isXButton or onlyHover) and not noHover then
        button:AddHover()
    end
end

local function SkinTab(tabButton, direction)
    tabButton:CreateBackdrop()
    local direction = direction and direction == "down" and "_down" or ""

    if tabButton.SetNormalTexture then tabButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/units/unittab" .. direction) end
    if tabButton.SetHighlightTexture then 
        tabButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/units/unittab" .. direction)
        tabButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    end
    if tabButton.SetPushedTexture then tabButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/units/unittab" .. direction) end
    if tabButton.SetDisabledTexture then tabButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/units/unittab" .. direction) end

    if tabButton.Text then
        tabButton.Text:SetShadowOffset(0, 0)
    end

    local r = {tabButton:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:SetShadowOffset(0, 0)
        end
    end

    if tabButton:GetName() then
        for _, object in pairs(tabs) do
            local tex = _G[tabButton:GetName() .. object]
            if tex then
                tex:SetTexture()
            end
        end
    end
end

local function SkinScrollFrame(frame)
    if frame.scrollBorderTop then frame.scrollBorderTop:Hide() end
    if frame.scrollBorderBottom then frame.scrollBorderBottom:Hide() end
    if frame.scrollFrameScrollBarBackground then frame.scrollFrameScrollBarBackground:Hide() end
    if frame.scrollBorderMiddle then
        frame.scrollBorderMiddle:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg")
        frame.scrollBorderMiddle:SetSize(3, frame.scrollBorderMiddle:GetSize())
        frame.scrollBorderMiddle:ClearAllPoints()
        frame.scrollBorderMiddle:SetPoint("TOPLEFT", frame, "TOPRIGHT", 12, -10)
        frame.scrollBorderMiddle:SetPoint("BOTTOMLEFT", frame,"BOTTOMRIGHT", 12, 10)
    end

    if frame:GetName() then
        if _G[frame:GetName() .. "ScrollBarTop"] then _G[frame:GetName() .. "ScrollBarTop"]:Hide() end
        if _G[frame:GetName() .. "ScrollBarBottom"] then _G[frame:GetName() .. "ScrollBarBottom"]:Hide() end
        if _G[frame:GetName() .. "ScrollBarMiddle"] then
            _G[frame:GetName() .. "ScrollBarMiddle"]:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg")
            _G[frame:GetName() .. "ScrollBarMiddle"]:SetSize(3, _G[frame:GetName() .. "ScrollBarMiddle"]:GetSize())
            _G[frame:GetName() .. "ScrollBarMiddle"]:ClearAllPoints()
            _G[frame:GetName() .. "ScrollBarMiddle"]:SetPoint("TOPLEFT", frame, "TOPRIGHT", 15, -10)
            _G[frame:GetName() .. "ScrollBarMiddle"]:SetPoint("BOTTOMLEFT", frame,"BOTTOMRIGHT", 12, 10)
        end

        if _G[frame:GetName() .. "Top"] then _G[frame:GetName() .. "Top"]:Hide() end
        if _G[frame:GetName() .. "Bottom"] then _G[frame:GetName() .. "Bottom"]:Hide() end
        if _G[frame:GetName() .. "Middle"] then
            _G[frame:GetName() .. "Middle"]:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg")
            _G[frame:GetName() .. "Middle"]:SetSize(3, _G[frame:GetName() .. "Middle"]:GetSize())
            _G[frame:GetName() .. "Middle"]:ClearAllPoints()
            _G[frame:GetName() .. "Middle"]:SetPoint("TOPLEFT", frame, "TOPRIGHT", 12, -10)
            _G[frame:GetName() .. "Middle"]:SetPoint("BOTTOMLEFT", frame,"BOTTOMRIGHT", 12, 10)
        end

        if _G[frame:GetName() .. "ScrollBar"] and _G[frame:GetName() .. "ScrollBar"].Top then _G[frame:GetName() .. "ScrollBar"].Top:Hide() end
        if _G[frame:GetName() .. "ScrollBar"] and _G[frame:GetName() .. "ScrollBar"].Bottom then _G[frame:GetName() .. "ScrollBar"].Bottom:Hide()end
        if _G[frame:GetName() .. "ScrollBar"] and _G[frame:GetName() .. "ScrollBar"].Background then _G[frame:GetName() .. "ScrollBar"].Background:Hide() end
        if _G[frame:GetName() .. "ScrollBar"] and _G[frame:GetName() .. "ScrollBar"].Middle then
            _G[frame:GetName() .. "ScrollBar"].Middle:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg")
            _G[frame:GetName() .. "ScrollBar"].Middle:SetSize(3, _G[frame:GetName() .. "ScrollBar"].Middle:GetSize())
            _G[frame:GetName() .. "ScrollBar"].Middle:ClearAllPoints()
            _G[frame:GetName() .. "ScrollBar"].Middle:SetPoint("TOPLEFT", frame, "TOPRIGHT", 12, -10)
            _G[frame:GetName() .. "ScrollBar"].Middle:SetPoint("BOTTOMLEFT", frame,"BOTTOMRIGHT", 12, 10)
        end
    end
end

local function SkinScrollBar(frame)
    local parent = frame:GetParent()
    local ScrollUpButton = GrabScrollBarElement(frame, "ScrollUpButton") or GrabScrollBarElement(frame, "UpButton") or GrabScrollBarElement(frame, "ScrollUp") or GrabScrollBarElement(parent, "scrollUp")
    local ScrollDownButton = GrabScrollBarElement(frame, "ScrollDownButton") or GrabScrollBarElement(frame, "DownButton") or GrabScrollBarElement(frame, "ScrollDown") or GrabScrollBarElement(parent, "scrollDown")
    local Thumb = GrabScrollBarElement(frame, "ThumbTexture") or GrabScrollBarElement(frame, "thumbTexture") or frame.GetThumbTexture and frame:GetThumbTexture()

    if ScrollUpButton then
        ScrollUpButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_up")
        ScrollUpButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down")
        ScrollUpButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_down")
        ScrollUpButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowup_up")
    end

    if ScrollDownButton then
        ScrollDownButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
        ScrollDownButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
        ScrollDownButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
        ScrollDownButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    end

    if Thumb then
        Thumb:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbarmiddle")
        Thumb:SetSize(12, Thumb:GetSize())
    end
end

local function SkinDropDownMenu(frame, buttonPaddindX)
    local frameName = frame.GetName and frame:GetName()
    local button = frame.Button or frameName and (_G[frameName .. "Button"] or _G[frameName .. "_Button"])
    local text = frameName and _G[frameName .. "Text"] or frame.Text
    local icon = frame.Icon

    frame:StripTextures()
    frame:SetWidth(155)

    frame:CreateBackdrop(constBackdropDropDown)
    frame.backdrop:SetBackdropColor(0, 0, 0)

    frame:SetFrameLevel(frame:GetFrameLevel() + 2)
    frame.backdrop:SetPoint("TOPLEFT", 20, -2)
    frame.backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)

    button:ClearAllPoints()
    button:SetPoint("RIGHT", frame, "RIGHT", buttonPaddindX or -10, 3)

    button.SetPoint = GW.NoOp
    button:StripTextures()

    button.NormalTexture:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
    button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")

    if text then
        text:ClearAllPoints()
        text:SetPoint("RIGHT", button, "LEFT", 4, 0)
    end

    if icon then
        icon:SetPoint("LEFT", 23, 0)
    end
end

local btns = {MaximizeButton = "up", MinimizeButton = "down"}
local function HandleMaxMinFrame(frame)
    if frame.isSkinned then return end

    frame:StripTextures(true)

    for name, direction in pairs(btns) do
        local button = frame[name]
        if button then
            button:SetSize(20, 20)
            button:ClearAllPoints()
            button:SetPoint("CENTER")
            button:SetHitRectInsets(1, 1, 1, 1)
            button:GetHighlightTexture():Kill()

            button:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowup_down")
            button:GetNormalTexture():SetRotation(ArrowRotation[direction])

            button:SetPushedTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowup_down")
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

    button:StripTextures()

    button:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowup_down")
    button:SetPushedTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowup_down")
    button:SetDisabledTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowup_down")

    local Normal, Disabled, Pushed = button:GetNormalTexture(), button:GetDisabledTexture(), button:GetPushedTexture()

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

    local rotation = ArrowRotation[arrowDir]
    if rotation then
        Normal:SetRotation(rotation)
        Pushed:SetRotation(rotation)
        Disabled:SetRotation(rotation)
    end

    button.isSkinned = true
end
GW.HandleNextPrevButton = HandleNextPrevButton

local function SetOutside(obj, anchor, xOffset, yOffset, anchor2, noScale)
    if not anchor then anchor = obj:GetParent() end

    if not xOffset then xOffset = GW.BorderSize end
    if not yOffset then yOffset = GW.BorderSize end
    local x = (noScale and xOffset) or GW.Scale(xOffset)
    local y = (noScale and yOffset) or GW.Scale(yOffset)

    if GW.SetPointsRestricted (obj) or obj:GetPoint() then
        obj:ClearAllPoints()
    end

    obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', -x, y)
    obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', x, -y)
end

local function SetInside(obj, anchor, xOffset, yOffset, anchor2, noScale)
    if not anchor then anchor = obj:GetParent() end

    if not xOffset then xOffset = GW.BorderSize end
    if not yOffset then yOffset = GW.BorderSize end
    local x = (noScale and xOffset) or GW.Scale(xOffset)
    local y = (noScale and yOffset) or GW.Scale(yOffset)

    if GW.SetPointsRestricted (obj) or obj:GetPoint() then
        obj:ClearAllPoints()
    end

    obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', x, -y)
    obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', -x, y)
end

local function addapi(object)
    local mt = getmetatable(object).__index
    if not object.Kill then mt.Kill = Kill end
    if not object.StripTextures then mt.StripTextures = StripTextures end
    if not object.AddHover then mt.AddHover = AddHover end
    if not object.SkinCheckButton then mt.SkinCheckButton = SkinCheckButton end
    if not object.SkinSliderFrame then mt.SkinSliderFrame = SkinSliderFrame end
    if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
    if not object.SkinButton then mt.SkinButton = SkinButton end
    if not object.SkinTab then mt.SkinTab = SkinTab end
    if not object.SkinScrollFrame then mt.SkinScrollFrame = SkinScrollFrame end
    if not object.SkinScrollBar then mt.SkinScrollBar = SkinScrollBar end
    if not object.SkinDropDownMenu then mt.SkinDropDownMenu = SkinDropDownMenu end
    if not object.HandleMaxMinFrame then mt.HandleMaxMinFrame = HandleMaxMinFrame end
    if not object.SetOutside then mt.SetOutside = SetOutside end
    if not object.SetInside then mt.SetInside = SetInside end
end

local handled = {Frame = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())
addapi(object:CreateMaskTexture())

object = EnumerateFrames()
while object do
    if not object:IsForbidden() and not handled[object:GetObjectType()] then
        addapi(object)
        handled[object:GetObjectType()] = true
    end

    object = EnumerateFrames(object)
end

addapi(GameFontNormal)
addapi(CreateFrame("ScrollFrame"))
