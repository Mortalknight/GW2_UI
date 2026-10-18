---@class GW2
local GW = select(2, ...)

local function FitHotKeyText(button)
    local hotkey = button.HotKey
    hotkey:SetTextScale(1)

    local maxWidth = button:GetWidth() - 2
    if maxWidth <= 0 then
        return
    end

    local textWidth = hotkey:GetUnboundedStringWidth()
    if textWidth and textWidth > maxWidth then
        hotkey:SetTextScale(math.max(0.6, maxWidth / textWidth))
    end
end

function GW.UpdateHotkey(self)
    local hotkey = self.HotKey
    local text = hotkey:GetText()
    local shouldShow = GW.settings.actionbars.buttonAssignments
    local hasText = text and text ~= RANGE_INDICATOR

    if shouldShow then
        if GW.settings.actionbars.buttonAssignmentsUsedOnly then
            shouldShow = self.gw_HasAction and hasText
        end
    end

    if shouldShow then
        hotkey:Show()
        if self.gw_HkBg then
            self.gw_HkBg.texture:Show()
        end
    else
        hotkey:Hide()
        if self.gw_HkBg then
            self.gw_HkBg.texture:Hide()
        end
    end

    if hasText then
        text = gsub(text, "(s%-)", "S")
        text = gsub(text, "(a%-)", "A")
        text = gsub(text, "(c%-)", "C")
        text = gsub(text, "SHIFT%-", "S")
		text = gsub(text, "ALT%-", "A")
		text = gsub(text, "CTRL%-", "C")
        text = gsub(text, KEY_BUTTON3, "M3") --middle mouse Button
        text = gsub(text, gsub(KEY_BUTTON4, "4", ""), "M") -- mouse button
        text = gsub(text, gsub(KEY_BUTTON5, "5", ""), "M") -- mouse button
        text = gsub(text, KEY_PAGEUP, "PU")
        text = gsub(text, KEY_PAGEDOWN, "PD")
        text = gsub(text, KEY_SPACE, "SpB")
        text = gsub(text, KEY_INSERT, "Ins")
        text = gsub(text, KEY_HOME, "Hm")
        text = gsub(text, KEY_DELETE, "Del")
        text = gsub(text, "NDIVIDE", "N/")
        text = gsub(text, "NMULTIPLY", "N*")
        text = gsub(text, "NMINUS", "N-")
        text = gsub(text, "NPLUS", "N+")
        text = gsub(text, "NEQUALS", "N=")
        text = gsub(text, KEY_LEFT, "LT")
        text = gsub(text, KEY_RIGHT, "RT")
        text = gsub(text, KEY_UP, "UP")
        text = gsub(text, KEY_DOWN, "DN")
        text = gsub(text, gsub(KEY_NUMPADPLUS, "%+", ""), "N") -- for all numpad keys
        text = gsub(text, KEY_MOUSEWHEELDOWN, "MwD")
        text = gsub(text, KEY_MOUSEWHEELUP, "MwU")

        hotkey:SetText(text)
    else
        hotkey:SetText("")
    end

    FitHotKeyText(self)
end

-- per position: the point on the button, the direction of the pet and stance offset, the two points of the main bar
local HOTKEY_POINTS = {
    TOP = {"TOP", -1, "TOPLEFT", "TOPRIGHT"},
    CENTER = {"CENTER", 0, "LEFT", "RIGHT"},
    BOTTOM = {"BOTTOM", 1, "BOTTOMLEFT", "BOTTOMRIGHT"},
}
local MACRO_NAME_POINTS = {TOP = "TOPLEFT", CENTER = "LEFT", BOTTOM = "BOTTOMLEFT"}
local hotkeyButtons = {}

-- the extra bars have their own text settings, main bar, pet, stance and extra buttons use the main bar ones
local function GetTextSettings(button)
    local parent = button:GetParent()
    local key = parent and (parent.originalBarName or parent:GetName())
    return key and GW.settings.actionbars.bars[key] or GW.settings.actionbars.mainBar
end

function GW.FixHotKeyPosition(button, isStanceButton, isPetButton, isMainBar)
    button.gwHotKeyIsStance, button.gwHotKeyIsPet, button.gwHotKeyIsMainBar = isStanceButton, isPetButton, isMainBar
    hotkeyButtons[button] = true
    local settings = GetTextSettings(button)
    local anchor = HOTKEY_POINTS[settings.hotkeyPosition] or HOTKEY_POINTS.BOTTOM
    local x, y = settings.hotkeyX, settings.hotkeyY
    if not button.gwHotKeyHooked and button.UpdateHotkeys then
        button.gwHotKeyHooked = true
        hooksecurefunc(button, "UpdateHotkeys", function(btn)
            GW.FixHotKeyPosition(btn, btn.gwHotKeyIsStance, btn.gwHotKeyIsPet, btn.gwHotKeyIsMainBar)
            GW.UpdateHotkey(btn)
        end)
    end

    button.HotKey:ClearAllPoints()
    if isPetButton or isStanceButton then
        button.HotKey:SetSize(0, 0)
        button.HotKey:SetPoint("CENTER", button, anchor[1], x, y + 5 * anchor[2])
        button.HotKey:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE")
        button.HotKey:SetTextColor(1, 1, 1)
    elseif isMainBar then
        button.HotKey:SetHeight(1)
        button.HotKey:SetPoint(anchor[3], button, anchor[3], x, y)
        button.HotKey:SetPoint(anchor[4], button, anchor[4], x, y)
        button.HotKey:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header, "OUTLINE")
        button.HotKey:SetTextColor(1, 1, 1)
    else
        button.HotKey:SetSize(0, 0)
        button.HotKey:SetPoint("CENTER", button, anchor[1], x, y)
        button.HotKey:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE")
        button.HotKey:SetTextColor(1, 1, 1)
    end
    button.HotKey:SetJustifyH("CENTER")
end

function GW.UpdateHotkeyPositions()
    for button in pairs(hotkeyButtons) do
        GW.FixHotKeyPosition(button, button.gwHotKeyIsStance, button.gwHotKeyIsPet, button.gwHotKeyIsMainBar)
    end
end

function GW.UpdateMacroName(self)
    if self.Name then
        if self.gw_ShowMacroName then
            local settings = GetTextSettings(self)
            local point = MACRO_NAME_POINTS[settings.macroNamePosition] or MACRO_NAME_POINTS.TOP
            self.Name:ClearAllPoints()
            self.Name:SetPoint(point, self, point, settings.macroNameX, settings.macroNameY)
            self.Name:SetJustifyH("LEFT")
            self.Name:SetWidth(self:GetWidth())
            local font, fontHeight = self.Name:GetFont()
            self.Name:SetFont(font, fontHeight, "OUTLINE")
            self.Name:SetAlpha(1)
        else
            self.Name:SetAlpha(0)
        end
    end
end
