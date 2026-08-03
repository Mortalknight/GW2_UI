---@class GW2
local GW = select(2, ...)

local MAX_FRAMES = 4
local frames = {}

local function EscapePressed()
    local closed = nil
    for _, popup in pairs(frames) do
        if popup and popup:IsShown() and popup.hideOnEscape then
            if popup.OnCancel then
                popup.OnCancel(popup, popup.data)
            end
            popup:Hide()
            closed = 1
        end
    end
    return closed
end

local function SetUpPosition()
    local lastFrame
    for _, popup in pairs(frames) do
        if popup.isInUse and not popup.hasFixedPosition then
            popup:ClearAllPoints()
            if lastFrame then
                popup:SetPoint("TOP", lastFrame, "BOTTOM", 0, -4)
            else
                popup:SetPoint("TOP", UIParent, "TOP", 0, -100)
            end

            lastFrame = popup
        end
    end
end

local function Resize(popup)
    local topPadding = 15
    local spacingTextToInput = 15 -- matches the input anchor offset in the template
    local spacingToButtons = 15
    local bottomPadding = 20

    -- anchor the buttons below the content instead of at a computed offset, so they
    -- can never overlap the text even when the wrapped string height is measured
    -- too small on the first frame
    local buttonAnchor = popup.info.hasEditBox and popup.input or popup.string
    popup.cancelButton:ClearAllPoints()
    popup.cancelButton:SetPoint("TOPRIGHT", buttonAnchor, "BOTTOMRIGHT", 0, -spacingToButtons)

    popup.acceptButton:ClearAllPoints()
    if popup.info.hideCancel then
        popup.acceptButton:SetPoint("TOPRIGHT", buttonAnchor, "BOTTOMRIGHT", 0, -spacingToButtons)
    else
        popup.acceptButton:SetPoint("TOPRIGHT", popup.cancelButton, "TOPLEFT", -10, 0)
    end

    local height = topPadding + popup.string:GetStringHeight()
    if popup.info.hasEditBox then
        height = height + spacingTextToInput + popup.input:GetHeight()
    end
    height = height + spacingToButtons + popup.acceptButton:GetHeight() + bottomPadding

    popup:SetHeight(height)
end

local function FindVisibleFrame(info)
    for _, popup in pairs(frames) do
        if popup and popup:IsShown() and popup.info.text == info.text then
            return popup
        end
    end
end

local function ShowPopup(info, data)
    local popup = FindVisibleFrame(info)
    if popup then
        popup:Hide()
    else
        for _, frame in pairs(frames) do
            if frame and not frame:IsShown() then
                popup = frame
                break
            end
        end
    end

    if not popup then
        if info.OnCancel then
            info.OnCancel()
        end
        return
    end

    popup:SetFrameStrata("DIALOG")

    popup.isInUse = true
    popup.string:SetText(info.text)
    popup.OnAccept = info.OnAccept
    popup.OnCancel = info.OnCancel
    popup.EditBoxOnEnterPressed = info.EditBoxOnEnterPressed
    popup.EditBoxOnEscapePressed = info.EditBoxOnEscapePressed
    popup.EditBoxOnTextChanged = info.EditBoxOnTextChanged
    popup.OnShow = info.OnShow
    popup.OnHide = info.OnHide
    popup.notHideOnAccept = info.notHideOnAccept
    popup.hideOnEscape = info.hideOnEscape
    popup.data = data
    popup.info = info
    popup.acceptButton:SetText(info.button1 or ACCEPT)
    popup.cancelButton:SetText(info.button2 or CANCEL)
    popup.cancelButton:SetShown(not info.hideCancel)
    -- re-apply the ready check button look for the current label (icon fit is measured)
    GW.SetPopupButtonScheme(popup.acceptButton, "confirm")
    GW.SetPopupButtonScheme(popup.cancelButton, "cancel")
    if info.hasEditBox then
        popup.input:Show()
        -- apply the letter limit BEFORE SetText: the pooled EditBox still carries the
        -- limit of its previous use, which would silently truncate longer texts
        -- (e.g. a profile export string after a 256-limit rename popup)
        if info.maxLetters then
            popup.input:SetMaxLetters(info.maxLetters)
        else
            popup.input:SetMaxLetters(256)
        end
        popup.input:SetText(info.inputText or "")
    else
        popup.input:Hide()
    end
    if info.hasFixedPosition then
        popup:SetPoint(unpack(info.point))
    end

    if not InCombatLockdown() then
        popup:SetPropagateKeyboardInput(not info.hideOnEscape)
    end

    SetUpPosition()
    popup:Show()
    if info.hasEditBox and info.highlightInput then
        popup.input:HighlightText()
    end
    Resize(popup)
    -- re-run once the text layout has settled; wrapped font strings can report a
    -- too small height on the frame they are shown
    C_Timer.After(0, function()
        if popup:IsShown() then
            Resize(popup)
        end
    end)
end
GW.ShowPopup = ShowPopup

local function EditBoxOnEnterPressed(self)
    local popup = self:GetParent()
    if popup.OnAccept then
        popup.OnAccept(popup, popup.data)
    end
    if popup.EditBoxOnEnterPressed then
        popup.EditBoxOnEnterPressed(popup, popup.data)
    end
    if not popup.notHideOnAccept then
        popup:Hide()
    end
end

local function EditBoxOnEscapePressed(self)
    local popup = self:GetParent()
    self:ClearFocus()
    if popup.EditBoxOnEscapePressed then
        popup.EditBoxOnEscapePressed(popup, popup.data)
    end
end

local function OnAccept(self)
    local popup = self:GetParent()
    if popup.OnAccept then
        popup.OnAccept(popup, popup.data)
    end
    if not popup.notHideOnAccept then
        popup:Hide()
    end
end

local function OnCancel(self)
    local popup = self:GetParent()
    if popup.OnCancel then
        popup.OnCancel(popup, popup.data)
    end
    popup:Hide()
end

local function OnKeyDown(self, key)
    if GetBindingFromClick(key) == "TOGGLEGAMEMENU" then
        return EscapePressed()
    end

    if not InCombatLockdown() then
        self:SetPropagateKeyboardInput(true)
    end
end

local function OnShow(self)
    if self.info and self.info.hasEditBox then
        self.input:SetFocus(true)
    end

    self:SetScript("OnKeyDown", OnKeyDown)
end

local function OnHide(self)
    self.isInUse = false
    self:SetScript("OnKeyDown", nil)
end

local function CreatePopupFrame()
    for i = 1, MAX_FRAMES do
        local popup = CreateFrame("Frame", "GwPopupFrame" .. i, UIParent, "GwPopupFrameTemplate")
        popup.string:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
        popup.string:SetTextColor(0.92, 0.88, 0.78)

        -- ready check style buttons and footer band, like the static popup skin
        GW.StylePopupButton(popup.acceptButton)
        GW.StylePopupButton(popup.cancelButton)
        GW.CreatePopupPanelDecoration(popup, popup.acceptButton)

        popup:SetScript("OnShow", OnShow)
        popup:SetScript("OnHide", OnHide)
        popup.input:SetScript("OnEscapePressed", EditBoxOnEscapePressed)
        popup.input:SetScript("OnEnterPressed", EditBoxOnEnterPressed)
        popup.input:SetScript("OnTextChanged", function(input, userInput)
            local pp = input:GetParent()
            if pp.EditBoxOnTextChanged then
                pp.EditBoxOnTextChanged(pp, userInput)
            end
        end)
        popup.input:SetScript("OnEditFocusGained", nil)
        popup.input:SetScript("OnEditFocusLost", nil)
        popup.acceptButton:SetScript("OnClick", OnAccept)
        popup.cancelButton:SetScript("OnClick", OnCancel)

        tinsert(frames, popup)
    end
end
GW.CreatePopupFrame = CreatePopupFrame
