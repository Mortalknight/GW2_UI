local _, GW = ...
GW.skins = {}

local function addHoverToButton(self)
    if not self.hover then
        local hover = self:CreateTexture("hover", "ARTWORK")
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
GW.skins.addHoverToButton = addHoverToButton

local constBackdropFrame = {
    bgFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Background",
    edgeFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.skins.constBackdropFrame = constBackdropFrame

local constBackdropFrameBorder = {
    bgFile = "",
    edgeFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.skins.constBackdropFrameBorder = constBackdropFrameBorder

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
        end

        if setTextColor then
            --button:SetTextColor(0, 0, 0, 1)
            --button:SetShadowOffset(0, 0)
            if button.Text then
                button.Text:SetTextColor(0, 0, 0, 1)
                button.Text:SetShadowOffset(0, 0)
            end

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
        addHoverToButton(button)
    end

    button.isSkinned = true
end
GW.skins.SkinButton = SkinButton

local function SkinCheckButton(button)
    if button.SetNormalTexture then button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/checkbox") end
    if button.SetCheckedTexture then button:SetCheckedTexture("Interface/AddOns/GW2_UI/textures/checkboxchecked") end
    if button.SetDisabledCheckedTexture then button:SetDisabledCheckedTexture("Interface/AddOns/GW2_UI/textures/checkboxchecked") end
    if button.SetPushedTexture then button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/checkbox") end
    if button.SetDisabledTexture then button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal") end
end
GW.skins.SkinCheckButton = SkinCheckButton

local tabs = {
    "LeftDisabled",
    "MiddleDisabled",
    "RightDisabled",
    "Left",
    "Middle",
    "Right"
}

local function SkinTab(tabButton)
    tabButton:SetBackdrop(nil)

    if tabButton.SetNormalTexture then tabButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/unittab") end
    if tabButton.SetHighlightTexture then 
        tabButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/unittab")
        tabButton:GetHighlightTexture():SetVertexColor(0, 0, 0)
    end
    if tabButton.SetPushedTexture then tabButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/unittab") end
    if tabButton.SetDisabledTexture then tabButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/unittab") end

    if tabButton.Text then
        --tabButton.Text:SetTextColor(0, 0, 0, 1)
        tabButton.Text:SetShadowOffset(0, 0)
    end

    local r = {tabButton:GetRegions()}
    for _,c in pairs(r) do
        if c:GetObjectType() == "FontString" then
            --c:SetTextColor(0, 0, 0, 1)
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
GW.skins.SkinTab = SkinTab

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
GW.skins.SkinSliderFrame = SkinSliderFrame

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
GW.skins.SkinScrollFrame = SkinScrollFrame

local function GrabScrollBarElement(frame, element)
    local FrameName = frame:GetDebugName()
    return frame[element] or FrameName and (_G[FrameName..element] or strfind(FrameName, element)) or nil
end

local function SkinScrollBar(frame)
    local parent = frame:GetParent()
    local ScrollUpButton = GrabScrollBarElement(frame, 'ScrollUpButton') or GrabScrollBarElement(frame, 'UpButton') or GrabScrollBarElement(frame, 'ScrollUp') or GrabScrollBarElement(parent, 'scrollUp')
    local ScrollDownButton = GrabScrollBarElement(frame, 'ScrollDownButton') or GrabScrollBarElement(frame, 'DownButton') or GrabScrollBarElement(frame, 'ScrollDown') or GrabScrollBarElement(parent, 'scrollDown')
    local Thumb = GrabScrollBarElement(frame, 'ThumbTexture') or GrabScrollBarElement(frame, 'thumbTexture') or frame.GetThumbTexture and frame:GetThumbTexture()

    ScrollUpButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")
    ScrollUpButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowup_down")
    ScrollUpButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowup_down")
    ScrollUpButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowup_up")

    ScrollDownButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrowdown_up")
    ScrollDownButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    ScrollDownButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    ScrollDownButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowdown_up")

    if Thumb then
        Thumb:SetTexture("Interface/AddOns/GW2_UI/textures/scrollbarmiddle")
        Thumb:SetSize(12, Thumb:GetSize())
    end
end
GW.skins.SkinScrollBar = SkinScrollBar

local function  SkinDropDownMenu(self)
    if self.Left then self.Left:Hide() end
    if self.Middle then self.Middle:Hide() end
    if self.Right then self.Right:Hide() end

    if self.Button then
        self.Button.NormalTexture:SetTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
        self.Button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
        self.Button:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
        self.Button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/arrowdown_down")
    end

    if self.Left and self.Right then
        local tex = self:CreateTexture("bg", "BACKGROUND")
        tex:SetPoint("TOP", self, "TOP", 0, 0)
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar")
        tex:SetPoint("TOPLEFT", self.Left, "BOTTOMRIGHT", 0, 23)
        tex:SetPoint("BOTTOMRIGHT", self.Right, "TOPLEFT", 10, -20)
        tex:SetVertexColor(0, 0, 0)
        self.tex = tex
    end
end
GW.skins.SkinDropDownMenu = SkinDropDownMenu

local function SkinUIDropDownMenu()
    hooksecurefunc("UIDropDownMenu_Initialize", SkinDropDownMenu)
end

local function SkinDropDownList()
    local SkinDropDownList_OnShow = function(self)
        _G[self:GetName() .. "Backdrop"]:Hide()
        _G[self:GetName() .. "MenuBackdrop"]:Hide()
        self:SetBackdrop(constBackdropFrame)
        for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
            if _G[self:GetName() .. "Button" .. i .. "ExpandArrow"] then
                _G[self:GetName() .. "Button" .. i .. "ExpandArrow"]:SetNormalTexture("Interface/AddOns/GW2_UI/textures/arrow_right")
            end
        end
        --Check if Raider.IO Entry is added
        if IsAddOnLoaded("RaiderIO") and RaiderIO_CustomDropDownList then
            _G["RaiderIO_CustomDropDownListMenuBackdrop"]:Hide()
            _G["RaiderIO_CustomDropDownList"]:SetBackdrop(constBackdropFrame)
        end
    end
    hooksecurefunc("UIDropDownMenu_OnShow", SkinDropDownList_OnShow)
end

local function SkinDropDown()
    SkinDropDownList()
    SkinUIDropDownMenu()
end
GW.SkinDropDown = SkinDropDown