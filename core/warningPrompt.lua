local _, GW = ...

local warningPrompt
local function WarningPrompt(text, method, point, button1Name, button2Name)
    warningPrompt.string:SetText(text)
    warningPrompt.method = method
    warningPrompt:ClearAllPoints()
    if point then
        warningPrompt:SetPoint(unpack(point))
    else
        warningPrompt:SetPoint("CENTER")
    end
    warningPrompt.acceptButton:SetText(button1Name or ACCEPT)
    warningPrompt.cancelButton:SetText(button2Name or CANCEL)
    warningPrompt:Show()
    warningPrompt.input:Hide()
end
GW.WarningPrompt = WarningPrompt

local function InputPrompt(text, method, input, point)
    warningPrompt.string:SetText(text)
    warningPrompt.method = method
    warningPrompt:Show()
    warningPrompt:ClearAllPoints()
    if point then
        warningPrompt:SetPoint(unpack(point))
    else
        warningPrompt:SetPoint("CENTER")
    end
    warningPrompt.input:Show()
    warningPrompt.input:SetText(input or "")
end
GW.InputPrompt = InputPrompt

local function CreateWarningPrompt()
    warningPrompt= CreateFrame("Frame", "GwWarningPrompt", UIParent, "GwWarningPrompt")
    warningPrompt.string:SetFont(UNIT_NAME_FONT, 14)
    warningPrompt.string:SetTextColor(1, 1, 1)

    warningPrompt.input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    warningPrompt.input:SetScript("OnEditFocusGained", nil)
    warningPrompt.input:SetScript("OnEditFocusLost", nil)
    warningPrompt.input:SetScript("OnEnterPressed", function(self)
        if self:GetParent().method then
            self:GetParent().method()
        end
        self:GetParent():Hide()
    end)
    warningPrompt.acceptButton:SetScript("OnClick", function(self)
        if self:GetParent().method then
            self:GetParent().method()
        end
        self:GetParent():Hide()
    end)
    warningPrompt.cancelButton:SetScript("OnClick", function(self) self:GetParent():Hide() end)

    tinsert(UISpecialFrames, "GwWarningPrompt")

end
GW.CreateWarningPrompt = CreateWarningPrompt