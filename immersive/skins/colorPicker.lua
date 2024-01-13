local _, GW = ...

local function alphaValue(num)
    return num and floor(((1 - num) * 100) + .05) or 0
end

local function expandFromThree(r, g, b)
    return strjoin("", r, r, g, g, b, b)
end

local function extendToSix(str)
    for _ = 1, 6 - strlen(str) do
        str = str .. 0
    end
    return str
end

local function UpdateAlphaText(alpha)
    if not alpha then alpha = alphaValue(ColorPickerFrame:GetColorAlpha()) end

    ColorPPBoxA:SetText(alpha)
end

local function GetHexColor(box)
    local rgb, rgbSize = box:GetText(), box:GetNumLetters()
    if rgbSize == 3 then
        rgb = gsub(rgb, "(%x)(%x)(%x)$", expandFromThree)
    elseif rgbSize < 6 then
        rgb = gsub(rgb, "(.+)$", extendToSix)
    end

    local r, g, b = tonumber(strsub(rgb, 0, 2), 16) or 0, tonumber(strsub(rgb, 3, 4), 16) or 0, tonumber(strsub(rgb, 5, 6), 16) or 0

    return r / 255, g / 255, b / 255
end

local function UpdateAlpha(tbox)
    local num = tbox:GetNumber()
    if num > 100 then
        tbox:SetText(100)
        num = 100
    end

    ColorPickerFrame.Content.ColorPicker:SetColorAlpha(1 - (num / 100))
end

local function ColorPPBoxA_SetFocus()
    ColorPPBoxA:SetFocus()
end

local function ColorPPBoxR_SetFocus()
    ColorPPBoxR:SetFocus()
end

local function UpdateColor()
    local r, g, b = GetHexColor(ColorPickerFrame.Content.HexBox)
    ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
    ColorPickerFrame.Content.ColorSwatchCurrent:SetColorTexture(r, g, b)
end

local function UpdateColorTexts(r, g, b, box)
    if not (r and g and b) then
        r, g, b = ColorPickerFrame.Content.ColorPicker:GetColorRGB()

        if box then
            if box == ColorPickerFrame.Content.HexBox then
                r, g, b = GetHexColor(box)
            else
                local num = box:GetNumber()
                if num > 255 then num = 255 end
                local c = num / 255
                if box == ColorPPBoxR then
                    r = c
                elseif box == ColorPPBoxG then
                    g = c
                elseif box == ColorPPBoxB then
                    b = c
                end
            end
        end
    end

    r, g, b = r * 255, g * 255, b * 255

    ColorPickerFrame.Content.HexBox:SetText(("%.2x%.2x%.2x"):format(r, g, b))
    ColorPPBoxR:SetText(r)
    ColorPPBoxG:SetText(g)
    ColorPPBoxB:SetText(b)
end

local delayWait, delayFunc = 0.15, nil
local function delayCall()
    if delayFunc then
        delayFunc()
        delayFunc = nil
    end
end

local function onColorSelect(frame, r, g, b)
    ColorPickerFrame.Content.ColorSwatchCurrent:SetColorTexture(r, g, b)
    UpdateColorTexts(r, g, b)

    if r == 0 and g == 0 and b == 0 then
        return
    end

    if not frame:IsVisible() then
        delayCall()
    elseif not delayFunc then
        delayFunc = ColorPickerFrame.func
        C_Timer.After(delayWait, function() delayCall() end)
    end
end

local function onValueChanged(frame, value)
    local alpha = alphaValue(value)
    if frame.lastAlpha ~= alpha then
        frame.lastAlpha = alpha

        UpdateAlphaText(alpha)

        if not ColorPickerFrame:IsVisible() then
            delayCall()
        else
            local opacityFunc = ColorPickerFrame.opacityFunc
            if delayFunc and (delayFunc ~= opacityFunc) then
                delayFunc = opacityFunc
            elseif not delayFunc then
                delayFunc = opacityFunc
                C_Timer.After(delayWait, function() delayCall() end)
            end
        end
    end
end

local function SkinAndEnhanceColorPicker()
    if C_AddOns.IsAddOnLoaded("ColorPickerPlus") then return end

    ColorPickerFrame:SetClampedToScreen(true)

    ColorPickerFrame:SetHeight(ColorPickerFrame:GetHeight() + 40)

    local tex = ColorPickerFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
    tex:SetPoint("TOP", ColorPickerFrame, "TOP", 0, 20)
    local w, h = ColorPickerFrame:GetSize()
    tex:SetSize(w + 50, h + 30)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    ColorPickerFrame.tex = tex
    ColorPickerFrame.Border:Hide()

    ColorPickerFrame.Header:GwStripTextures()
    ColorPickerFrame.Header.Text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    ColorPickerFrame.Footer.CancelButton:ClearAllPoints()
    ColorPickerFrame.Footer.OkayButton:ClearAllPoints()
    ColorPickerFrame.Footer.CancelButton:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOMRIGHT", -6, 6)
    ColorPickerFrame.Footer.CancelButton:SetPoint("BOTTOMLEFT", ColorPickerFrame, "BOTTOM", 0, 6)
    ColorPickerFrame.Footer.OkayButton:SetPoint("BOTTOMLEFT", ColorPickerFrame,"BOTTOMLEFT", 6,6)
    ColorPickerFrame.Footer.OkayButton:SetPoint("RIGHT", ColorPickerFrame.Footer.CancelButton,"LEFT", -4,0)
    --OpacitySliderFrame:GwSkinSliderFrame()
    ColorPickerFrame.Footer.OkayButton:GwSkinButton(false, true)
    ColorPickerFrame.Footer.CancelButton:GwSkinButton(false, true)

    ColorPickerFrame:HookScript("OnShow", function(frame)
        if frame.hasOpacity then
            ColorPPBoxA:Show()
            ColorPPBoxLabelA:Show()
            ColorPickerFrame.Content.HexBox:SetScript("OnTabPressed", ColorPPBoxA_SetFocus)
            UpdateAlphaText()
            UpdateColorTexts()
        else
            ColorPPBoxA:Hide()
            ColorPPBoxLabelA:Hide()
            ColorPickerFrame.Content.HexBox:SetScript("OnTabPressed", ColorPPBoxR_SetFocus)
            UpdateColorTexts()
        end

        --frame.Content.ColorPicker:SetScript("OnValueChanged", onValueChanged)
        frame.Content.ColorPicker:SetScript("OnColorSelect", onColorSelect)
    end)

    --class color button
    local b = CreateFrame("Button", "ColorPPClass", ColorPickerFrame, "GwStandardButton")
    b:SetText(CLASS)
    b:SetSize(80, 22)
    b:SetPoint("TOPRIGHT", ColorPickerFrame, "TOPRIGHT", 0, 0)

    b:SetScript("OnClick", function()
        local color = GW.GWGetClassColor(GW.myclass, true, true)
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(color.r, color.g, color.b)
        ColorPickerFrame.Content.ColorSwatchCurrent:SetColorTexture(color.r, color.g, color.b)
        if ColorPickerFrame.hasOpacity then
            ColorPickerFrame.Content.ColorPicker:SetColorAlpha(0)
        end
    end)

    -- set up edit box frames and interior label and text areas
    local boxes = {"R", "G", "B", "A"}
    for i = 1, #boxes do
        local rgb = boxes[i]
        local box = CreateFrame("EditBox", "ColorPPBox" .. rgb, ColorPickerFrame, "InputBoxTemplate")
        box:SetPoint("TOP", ColorPickerFrame.Content.ColorPicker.Wheel, "BOTTOM", 0, -15)
        box:SetFrameStrata("DIALOG")
        box:SetAutoFocus(false)
        box:SetTextInsets(0, 7, 0, 0)
        box:SetJustifyH("RIGHT")
        box:SetHeight(24)
        box:SetID(i)
        GW.SkinTextBox(box.Middle, box.Left, box.Right)

        box:SetMaxLetters(3)
        box:SetWidth(40)
        box:SetNumeric(true)

        -- label
        local label = box:CreateFontString("ColorPPBoxLabel" .. rgb, "ARTWORK", "GameFontNormalSmall")
        label:SetPoint("RIGHT", "ColorPPBox" .. rgb, "LEFT", -5, 0)
        label:SetText(rgb)
        label:SetTextColor(1, 1, 1)

        -- set up scripts to handle event appropriately
        if i == 4 then
            box:SetScript("OnKeyUp", function(eb, key)
                local copyPaste = IsControlKeyDown() and key == "V"
                if key == "BACKSPACE" or copyPaste or (strlen(key) == 1 and not IsModifierKeyDown()) then
                    UpdateAlpha(eb)
                elseif key == "ENTER" or key == "ESCAPE" then
                    eb:ClearFocus()
                    UpdateAlpha(eb)
                end
            end)
        else
            box:SetScript("OnKeyUp", function(eb, key)
                local copyPaste = IsControlKeyDown() and key == "V"
                if key == "BACKSPACE" or copyPaste or (strlen(key) == 1 and not IsModifierKeyDown()) then
                    if i ~= 4 then UpdateColorTexts(nil, nil, nil, eb) end
                    if i == 4 and eb:GetNumLetters() ~= 6 then return end
                    UpdateColor()
                elseif key == "ENTER" or key == "ESCAPE" then
                    eb:ClearFocus()
                    UpdateColorTexts(nil, nil, nil, eb)
                    UpdateColor()
                end
            end)
        end

        box:SetScript("OnEditFocusGained", function(eb) eb:SetCursorPosition(0) eb:HighlightText() end)
        box:SetScript("OnEditFocusLost", function(eb) eb:HighlightText(0,0) end)
        box:Show()
    end

    GW.SkinTextBox(ColorPickerFrame.Content.HexBox.Middle, ColorPickerFrame.Content.HexBox.Left, ColorPickerFrame.Content.HexBox.Right)
    ColorPickerFrame.Content.HexBox:SetMaxLetters(6)
    ColorPickerFrame.Content.HexBox:SetWidth(56)
    ColorPickerFrame.Content.HexBox:SetNumeric(false)

    ColorPPBoxA:SetPoint("RIGHT", ColorPickerFrame.Footer.CancelButton, "RIGHT", 0, 20)
    ColorPickerFrame.Content.HexBox:SetPoint("RIGHT", ColorPPBoxA, "LEFT", -15, 0)
    ColorPPBoxB:SetPoint("RIGHT", ColorPickerFrame.Content.HexBox, "LEFT", -40, 0)
    ColorPPBoxG:SetPoint("RIGHT", ColorPPBoxB, "LEFT", -25, 0)
    ColorPPBoxR:SetPoint("RIGHT", ColorPPBoxG, "LEFT", -25, 0)

    -- make the color picker movable.
    local mover = CreateFrame("Frame", nil, ColorPickerFrame)
    mover:SetPoint("TOPLEFT", ColorPickerFrame, "TOP", -60, 0)
    mover:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "TOP", 60, -15)
    mover:SetScript("OnMouseDown", function() ColorPickerFrame:StartMoving() end)
    mover:SetScript("OnMouseUp", function() ColorPickerFrame:StopMovingOrSizing() end)
    mover:EnableMouse(true)

    ColorPickerFrame:SetUserPlaced(true)
    ColorPickerFrame:EnableKeyboard(false)
end
GW.SkinAndEnhanceColorPicker = SkinAndEnhanceColorPicker