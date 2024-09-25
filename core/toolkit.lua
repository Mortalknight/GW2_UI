local _, GW = ...

----- Added API to Frames -----
local STRIP_TEX = "Texture"
local STRIP_FONT = "FontString"

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

local function GrabScrollBarElement(frame, element)
    local FrameName = frame:GetDebugName()
    return frame[element] or FrameName and (_G[FrameName..element] or strfind(FrameName, element)) or nil
end

local function StripRegion(which, object, kill, alpha)
    if kill then
        object:Kill()
    elseif alpha then
        object:SetAlpha(0)
    elseif which == STRIP_TEX then
        object:SetTexture()
    elseif which == STRIP_FONT then
        object:SetText("")
    end
end

local function StripType(which, object, kill, alpha)
    if object:IsObjectType(which) then
        StripRegion(which, object, kill, alpha)
    else
        if which == STRIP_TEX then
            local FrameName = object.GetName and object:GetName()
            for _, Blizzard in pairs(StripTexturesBlizzFrames) do
                local BlizzFrame = object[Blizzard] or (FrameName and _G[FrameName..Blizzard])
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
    StripType(STRIP_TEX, object, kill, alpha)
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

local function AddHover(self)
    if not self.hover then
        local hover = self:CreateTexture(nil, "ARTWORK")
        hover:SetPoint("LEFT", self, "LEFT")
        hover:SetPoint("TOP", self, "TOP")
        hover:SetPoint("BOTTOM", self, "BOTTOM")
        hover:SetPoint("RIGHT", self, "RIGHT")
        hover:SetTexture("Interface/AddOns/GW2_UI/textures/button_hover")
        self.hover = hover
        self.hover:SetAlpha(0)

        self:HookScript("OnEnter", GwStandardButton_OnEnter)
        self:HookScript("OnLeave", GwStandardButton_OnLeave)
    end
end

local function SkinCheckButton(button)
    if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/checkbox") end
    if button.SetCheckedTexture then button:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/checkboxchecked") end
    if button.SetDisabledCheckedTexture then button:SetDisabledCheckedTexture("Interface/AddOns/GW2_UI/textures/checkboxchecked") end
    if button.SetPushedTexture then button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/checkbox") end
    if button.SetDisabledTexture then button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal") end
end

function SkinSliderFrame(frame)
    local orientation = frame:GetOrientation()
    local SIZE = 12

    if not frame.SetBackdrop then
        _G.Mixin(frame, _G.BackdropTemplateMixin)
        frame:HookScript("OnSizeChanged", frame.OnBackdropSizeChanged)
    end
    frame:SetBackdrop(nil)
    if not frame.backdrop then
        frame:CreateBackdrop()
    end
    frame:SetThumbTexture("Interface/AddOns/GW2_UI/textures/sliderhandle")

    local thumb = frame:GetThumbTexture()
    thumb:SetSize(SIZE - 2, SIZE - 2)

    local tex = frame:CreateTexture("bg", "BACKGROUND")
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/sliderbg")
    frame.tex = tex

    if orientation == "VERTICAL" then
        frame:SetWidth(SIZE)
        frame.tex:SetPoint("TOPLEFT", frame, "TOPLEFT")
        frame.tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    else
        frame:SetHeight(SIZE)
        frame.tex:SetPoint("TOPLEFT", frame, "TOPLEFT")
        frame.tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")

        for _, region in next, { frame:GetRegions() } do
			if region:IsObjectType('FontString') then
				local point, anchor, anchorPoint, x, y = region:GetPoint()
				if strfind(anchorPoint, 'BOTTOM') then
					region:SetPoint(point, anchor, anchorPoint, x, y - 4)
				end
			end
		end
    end
end

local function BackdropFrameLevel(frame, level)
    frame:SetFrameLevel(level)

    if frame.oborder then frame.oborder:SetFrameLevel(level) end
    if frame.iborder then frame.iborder:SetFrameLevel(level) end
end

local function BackdropFrameLower(backdrop, parent)
    local level = parent:GetFrameLevel()
    local minus = level and (level - 1)
    if minus and (minus >= 0) then
        BackdropFrameLevel(backdrop, minus)
    else
        BackdropFrameLevel(backdrop, 0)
    end
end

local function CreateBackdrop(frame, template, isBorder, xOffset, yOffset, xShift, yShift)
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

    if template == "Transparent" then
        backdrop:SetBackdrop({
            edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white",
            bgFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Background",
            edgeSize = GW.Scale(1)
        })
    elseif template == "Transparent White" then
        backdrop:SetBackdrop({
            edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white",
            bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/white",
            edgeSize = GW.Scale(1)
        })

        backdrop:SetBackdropColor(1, 1, 1, 0.4)
    elseif template == "ScrollBar" then
        backdrop:SetBackdrop({
            bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/scrollbarmiddle",
            edgeSize = GW.Scale(1)
        })
    elseif template then
        backdrop:SetBackdrop(template)
    else
        backdrop:SetBackdrop(nil)
    end

    BackdropFrameLower(backdrop, parent)
end

local function SkinButton(button, isXButton, setTextColor, onlyHover)
    if not button or button.isSkinned then return end

    if not onlyHover then
        if isXButton then
            if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal") end
            if button.SetHighlightTexture then button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover") end
            if button.SetPushedTexture then button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover") end
            if button.SetDisabledTexture then button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal") end
        else
            if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/button") end
            if button.SetHighlightTexture then 
                button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/button_hover")
                button:GetHighlightTexture():SetVertexColor(0, 0, 0)
            end
            if button.SetPushedTexture then button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/button") end
            if button.SetDisabledTexture then button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/button_disable") end
            button:DisableDrawLayer("BACKGROUND")

            if button.LeftSeparator then button.LeftSeparator:Hide() end
            if button.RightSeparator then button.RightSeparator:Hide() end
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

    if not isXButton or onlyHover then
        button:AddHover()
    end

    button.isSkinned = true
end

local function SkinTab(tabButton)
    tabButton:CreateBackdrop()

    if tabButton.SetNormalTexture then tabButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/unittab") end
    if tabButton.SetHighlightTexture then 
        tabButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/unittab")
        tabButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    end
    if tabButton.SetPushedTexture then tabButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/unittab") end
    if tabButton.SetDisabledTexture then tabButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/unittab") end

    if tabButton.Text then
        tabButton.Text:SetShadowOffset(0, 0)
    end

    local r = {tabButton:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            c:SetShadowOffset(0, 0)
        end
    end

    for _, object in pairs(tabs) do
        local tex = _G[tabButton:GetName() .. object]
        if tex then
            tex:SetTexture()
        end
    end
end

local function SkinScrollFrame(frame)
    if frame.scrollBorderTop then frame.scrollBorderTop:Hide() end
    if frame.scrollBorderBottom then frame.scrollBorderBottom:Hide() end
    if frame.scrollFrameScrollBarBackground then frame.scrollFrameScrollBarBackground:Hide() end
    if frame.scrollBorderMiddle then
        frame.scrollBorderMiddle:SetTexture("Interface/AddOns/GW2_UI/textures/scrollbg")
        frame.scrollBorderMiddle:SetSize(3, frame.scrollBorderMiddle:GetSize())
        frame.scrollBorderMiddle:ClearAllPoints()
        frame.scrollBorderMiddle:SetPoint("TOPLEFT", frame, "TOPRIGHT", 12, -10)
        frame.scrollBorderMiddle:SetPoint("BOTTOMLEFT", frame,"BOTTOMRIGHT", 12, 10)
    end

    if _G[frame:GetName() .. "ScrollBarTop"] then _G[frame:GetName() .. "ScrollBarTop"]:Hide() end
    if _G[frame:GetName() .. "ScrollBarBottom"] then _G[frame:GetName() .. "ScrollBarBottom"]:Hide() end
    if _G[frame:GetName() .. "ScrollBarMiddle"] then
        _G[frame:GetName() .. "ScrollBarMiddle"]:SetTexture("Interface/AddOns/GW2_UI/textures/scrollbg")
        _G[frame:GetName() .. "ScrollBarMiddle"]:SetSize(3, _G[frame:GetName() .. "ScrollBarMiddle"]:GetSize())
        _G[frame:GetName() .. "ScrollBarMiddle"]:ClearAllPoints()
        _G[frame:GetName() .. "ScrollBarMiddle"]:SetPoint("TOPLEFT", frame, "TOPRIGHT", 12, -10)
        _G[frame:GetName() .. "ScrollBarMiddle"]:SetPoint("BOTTOMLEFT", frame,"BOTTOMRIGHT", 12, 10)
    end

    if _G[frame:GetName() .. "Top"] then _G[frame:GetName() .. "Top"]:Hide() end
    if _G[frame:GetName() .. "Bottom"] then _G[frame:GetName() .. "Bottom"]:Hide() end
    if _G[frame:GetName() .. "Middle"] then
        _G[frame:GetName() .. "Middle"]:SetTexture("Interface/AddOns/GW2_UI/textures/scrollbg")
        _G[frame:GetName() .. "Middle"]:SetSize(3, _G[frame:GetName() .. "Middle"]:GetSize())
        _G[frame:GetName() .. "Middle"]:ClearAllPoints()
        _G[frame:GetName() .. "Middle"]:SetPoint("TOPLEFT", frame, "TOPRIGHT", 12, -10)
        _G[frame:GetName() .. "Middle"]:SetPoint("BOTTOMLEFT", frame,"BOTTOMRIGHT", 12, 10)
    end
end

local function SkinScrollBar(frame)
    local parent = frame:GetParent()
    local ScrollUpButton = GrabScrollBarElement(frame, "ScrollUpButton") or GrabScrollBarElement(frame, "UpButton") or GrabScrollBarElement(frame, "ScrollUp") or GrabScrollBarElement(parent, "scrollUp")
    local ScrollDownButton = GrabScrollBarElement(frame, "ScrollDownButton") or GrabScrollBarElement(frame, "DownButton") or GrabScrollBarElement(frame, "ScrollDown") or GrabScrollBarElement(parent, "scrollDown")
    local Thumb = GrabScrollBarElement(frame, "ThumbTexture") or GrabScrollBarElement(frame, "thumbTexture") or frame.GetThumbTexture and frame:GetThumbTexture()

    if ScrollUpButton then
        ScrollUpButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
        ScrollUpButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowup_down")
        ScrollUpButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowup_down")
        ScrollUpButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    end

    if ScrollDownButton then
        ScrollDownButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowdown_up")
        ScrollDownButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
        ScrollDownButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
        ScrollDownButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowdown_up")
    end

    if Thumb then
        Thumb:SetTexture("Interface/AddOns/GW2_UI/textures/scrollbarmiddle")
        Thumb:SetSize(12, Thumb:GetSize())
    end
end

local function GwHandleDropDownBox(frame, backdropTemplate, width)
    local text = frame.Text
    if frame.Arrow then frame.Arrow:SetAlpha(0) end

    if not width or width == nil then
        width = 155
    end

    frame:SetWidth(width)
    frame:StripTextures()

    if backdropTemplate then
        frame:CreateBackdrop(backdropTemplate, true)
        frame.backdrop:SetBackdropColor(0, 0, 0)
    else
        frame:CreateBackdrop(GW.skins.constBackdropStatusBar)
    end
    frame:SetFrameLevel(frame:GetFrameLevel() + 2)
    frame.backdrop:SetPoint("TOPLEFT", 5, -2)
    frame.backdrop:SetPoint("BOTTOMRIGHT", -2, -2)

    local tex = frame:CreateTexture(nil, 'ARTWORK')
    tex:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowup_down")
    tex:SetPoint('RIGHT', frame.backdrop, -3, 0)
    tex:SetRotation(3.14)
    tex:SetSize(14, 14)

    if text then
        text:ClearAllPoints()
        text:SetPoint("LEFT", frame, "LEFT", 8, 0)
        text:SetFont(UNIT_NAME_FONT, 12)
        text:SetTextColor(178 / 255, 178 / 255, 178 / 255)
        text:SetHeight(frame:GetHeight())
        text:SetJustifyH("LEFT")
        text:SetJustifyV("MIDDLE")
    end

    HandleBlizzardRegions(frame)
end

local function SkinDropDownMenu(frame, buttonPaddindX, backdropTemplate, textBoxRightOffset)
    local frameName = frame.GetName and frame:GetName()
    local button = frame.Button or frameName and (_G[frameName .. "Button"] or _G[frameName .. "_Button"])
    local text = frameName and _G[frameName .. "Text"] or frame.Text
    local middle = frameName and _G[frameName .. "Middle"] or frame.Middle
    local left = frameName and _G[frameName .. "Left"] or frame.Left
    local right = frameName and _G[frameName .. "Right"] or frame.Right
    local icon = frame.Icon

    frame:StripTextures()
    frame:SetWidth(155)

    if backdropTemplate then
        frame:CreateBackdrop(backdropTemplate, true)
        frame.backdrop:SetBackdropColor(0, 0, 0)
    else
        frame:CreateBackdrop()
        GW.SkinTextBox(middle, left, right, nil, nil, -5, textBoxRightOffset or -10)
    end

    frame:SetFrameLevel(frame:GetFrameLevel() + 2)
    frame.backdrop:SetPoint("TOPLEFT", 20, -2)
    frame.backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)

    button:ClearAllPoints()
    button:SetPoint("RIGHT", frame, "RIGHT", buttonPaddindX or -10, 3)

    button.SetPoint = GW.NoOp
    button:StripTextures()

    GW.HandleNextPrevButton(button, "down")

    if text then
        text:ClearAllPoints()
        text:SetPoint("RIGHT", button, "LEFT", -2, 0)
        text:SetFont(UNIT_NAME_FONT, 12, "")
        text:SetTextColor(178 / 255, 178 / 255, 178 / 255)
        text:SetHeight(frame:GetHeight())
        text:SetJustifyV("MIDDLE")
    end

    if icon then
        icon:SetPoint("LEFT", 23, 0)
    end
end

local function HandleNextPrevButton(button, arrowDir)
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

    button:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/arrowup_down")
    button:SetPushedTexture("Interface/AddOns/GW2_UI/Textures/arrowup_down")
    button:SetDisabledTexture("Interface/AddOns/GW2_UI/Textures/arrowup_down")

    local Normal, Disabled, Pushed = button:GetNormalTexture(), button:GetDisabledTexture(), button:GetPushedTexture()

    button:SetSize(20, 20)
    Disabled:SetVertexColor(.3, .3, .3)

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

    if GW.SetPointsRestricted(obj) or obj:GetPoint() then
        obj:ClearAllPoints()
    end

    obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', x, -y)
    obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', -x, y)
end

local function StyleButton(button, noHover, noPushed, noChecked)
	if button.SetHighlightTexture and not button.hover and not noHover then
		local hover = button:CreateTexture()
		hover:SetInside()
		hover:SetBlendMode("ADD")
		hover:SetColorTexture(1, 1, 1, 0.3)
		button:SetHighlightTexture(hover)
		button.hover = hover
	end

	if button.SetPushedTexture and not button.pushed and not noPushed then
		local pushed = button:CreateTexture()
		pushed:SetInside()
		pushed:SetBlendMode("ADD")
		pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
		button:SetPushedTexture(pushed)
		button.pushed = pushed
	end

	if button.SetCheckedTexture and not button.checked and not noChecked then
		local checked = button:CreateTexture()
		checked:SetInside()
		checked:SetBlendMode("ADD")
		checked:SetColorTexture(1, 1, 1, 0.3)
		button:SetCheckedTexture(checked)
		button.checked = checked
	end

	if button.cooldown then
		button.cooldown:SetDrawEdge(false)
		button.cooldown:GwSetInside(button, 0, 0)
	end
end

local btns = {MaximizeButton = "up", MinimizeButton = "down"}
local function GwHandleMaxMinFrame(frame)
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
    if not object.SetOutside then mt.SetOutside = SetOutside end
    if not object.SetInside then mt.SetInside = SetInside end
    if not object.StyleButton then mt.StyleButton = StyleButton end
    if not object.GwHandleMaxMinFrame then mt.GwHandleMaxMinFrame = GwHandleMaxMinFrame end
    if not object.GwHandleDropDownBox then mt.GwHandleDropDownBox = GwHandleDropDownBox end
end

local handled = {["Frame"] = true}
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

--Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the 'Frame' widget
local scrollFrame = CreateFrame("ScrollFrame")
addapi(scrollFrame)