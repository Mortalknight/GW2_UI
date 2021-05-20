local _, GW = ...

----- Added API to Frames -----
local STRIP_TEX = "Texture"
local STRIP_FONT = "FontString"

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
    bgFile = "Interface/AddOns/GW2_UI/textures/gwstatusbar",
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

        self:SetScript("OnEnter", GwStandardButton_OnEnter)
        self:SetScript("OnLeave", GwStandardButton_OnLeave)
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

    frame:SetBackdrop(nil)
    frame:SetThumbTexture("Interface/AddOns/GW2_UI/textures/sliderhandle")

    local thumb = frame:GetThumbTexture()
    thumb:SetSize(SIZE - 2, SIZE - 2)

    local tex = frame:CreateTexture("bg", "BACKGROUND")
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/sliderbg")
    frame.tex = tex

    if orientation == "VERTICAL" then
        frame:SetWidth(SIZE)
        frame.tex:SetPoint("TOP", frame, "TOP")
        frame.tex:SetPoint("BOTTOM", frame, "BOTTOM")
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

local function CreateBackdrop(frame, backdropTexture, isBorder, setOffset)
    local parent = (frame.IsObjectType and frame:IsObjectType("Texture") and frame:GetParent()) or frame
    local backdrop = frame.backdrop or CreateFrame("Frame", nil, parent, "BackdropTemplate")
    if not frame.backdrop then frame.backdrop = backdrop end

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
        local x = setOffset and setOffset or ((GW.mult == 1 or 2 == 0) and 2 or ((GW.mult < 1 and trunc(2 / GW.mult) or round(2 / GW.mult)) * GW.mult))
        local y = setOffset and setOffset or ((GW.mult == 1 or 2 == 0) and 2 or ((GW.mult < 1 and trunc(2 / GW.mult) or round(2 / GW.mult)) * GW.mult))

        backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -x, y)
        backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", x, -y)

    else
        backdrop:SetAllPoints()
    end

    if backdropTexture then
        backdrop:SetBackdrop(backdropTexture)
    else
        backdrop:SetBackdrop(nil)
    end
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

    button.NormalTexture:SetTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")

    if text then
        text:ClearAllPoints()
        text:SetPoint("RIGHT", button, "LEFT", 4, 0)
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