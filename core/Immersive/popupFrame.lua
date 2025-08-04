local _, GW = ...

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
    local spacingTextToInput = 10
    local spacingToButtons = 15
    local bottomPadding = 20

    local currentY = -topPadding

    currentY = currentY - popup.string:GetHeight()

    if popup.info.hasEditBox then
        currentY = currentY - spacingTextToInput
        currentY = currentY - popup.input:GetHeight()
    end

    currentY = currentY - spacingToButtons

    -- Buttons
    popup.acceptButton:ClearAllPoints()
    popup.acceptButton:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -110, currentY)

    popup.cancelButton:ClearAllPoints()
    popup.cancelButton:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -15, currentY)

    currentY = currentY - popup.acceptButton:GetHeight()

    popup:SetHeight(-currentY + bottomPadding)
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

    popup.isInUse = true
    popup.string:SetText(info.text)
    popup.OnAccept = info.OnAccept
    popup.OnCancel = info.OnCancel
    popup.EditBoxOnEnterPressed = info.EditBoxOnEnterPressed
    popup.EditBoxOnEscapePressed = info.EditBoxOnEscapePressed
    popup.OnShow = info.OnShow
    popup.OnHide = info.OnHide
    popup.notHideOnAccept = info.notHideOnAccept
    popup.hideOnEscape = info.hideOnEscape
    popup.data = data
    popup.info = info
    popup.acceptButton:SetText(info.button1 or ACCEPT)
    popup.cancelButton:SetText(info.button2 or CANCEL)
    if info.hasEditBox then
        popup.input:Show()
        popup.input:SetText(info.inputText or "")
        if info.maxLetters then
            popup.input:SetMaxLetters(info.maxLetters)
        else
            popup.input:SetMaxLetters(256)
        end
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
    Resize(popup)
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
        popup.string:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        popup.string:SetTextColor(1, 1, 1)

        popup:SetScript("OnShow", OnShow)
        popup:SetScript("OnHide", OnHide)
        popup.input:SetScript("OnEscapePressed", EditBoxOnEscapePressed)
        popup.input:SetScript("OnEnterPressed", EditBoxOnEnterPressed)
        popup.input:SetScript("OnEditFocusGained", nil)
        popup.input:SetScript("OnEditFocusLost", nil)
        popup.acceptButton:SetScript("OnClick", OnAccept)
        popup.cancelButton:SetScript("OnClick", OnCancel)

        tinsert(frames, popup)
    end
end
GW.CreatePopupFrame = CreatePopupFrame
