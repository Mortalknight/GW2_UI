---@class GW2
local GW = select(2, ...)

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

function GW.SkinAndEnhanceColorPicker()
    if C_AddOns.IsAddOnLoaded("ColorPickerPlus") then return end

    local delayWait, delayFunc = 0.15, nil

    local function UpdateAlphaText(alpha)
        if not alpha then
            alpha = alphaValue(OpacitySliderFrame:GetValue())
        end

        ColorPPBoxA:SetText(alpha)
    end

    local function GetHexColor(box)
        local rgb, rgbSize = box:GetText(), box:GetNumLetters()
        if rgbSize == 3 then
            rgb = gsub(rgb, "(%x)(%x)(%x)$", expandFromThree)
        elseif rgbSize < 6 then
            rgb = gsub(rgb, "(.+)$", extendToSix)
        end

        local r = tonumber(strsub(rgb, 0, 2), 16) or 0
        local g = tonumber(strsub(rgb, 3, 4), 16) or 0
        local b = tonumber(strsub(rgb, 5, 6), 16) or 0

        return r / 255, g / 255, b / 255
    end

    local function UpdateAlpha(tbox)
        local num = tbox:GetNumber()
        if num > 100 then
            tbox:SetText(100)
            num = 100
        end

        OpacitySliderFrame:SetValue(1 - (num / 100))
    end

    local function ColorPPBoxA_SetFocus()
        ColorPPBoxA:SetFocus()
    end

    local function ColorPPBoxR_SetFocus()
        ColorPPBoxR:SetFocus()
    end

    local function UpdateColor()
        local r, g, b = GetHexColor(ColorPPBoxH)
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorSwatch:SetColorTexture(r, g, b)
    end

    local function UpdateColorTexts(r, g, b, box)
        if not (r and g and b) then
            r, g, b = ColorPickerFrame:GetColorRGB()

            if box then
                if box == ColorPPBoxH then
                    r, g, b = GetHexColor(box)
                else
                    local num = box:GetNumber()
                    if num > 255 then
                        num = 255
                    end

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

        ColorPPBoxH:SetText(("%.2x%.2x%.2x"):format(r, g, b))
        ColorPPBoxR:SetText(r)
        ColorPPBoxG:SetText(g)
        ColorPPBoxB:SetText(b)
    end

    local function delayCall()
        if delayFunc then
            delayFunc()
            delayFunc = nil
        end
    end

    local function onColorSelect(frame, r, g, b)
        ColorSwatch:SetColorTexture(r, g, b)
        UpdateColorTexts(r, g, b)

        if r == 0 and g == 0 and b == 0 then
            return
        end

        if not frame:IsVisible() then
            delayCall()
        elseif not delayFunc then
            delayFunc = ColorPickerFrame.func
            C_Timer.After(delayWait, function()
                delayCall()
            end)
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
                if delayFunc and delayFunc ~= opacityFunc then
                    delayFunc = opacityFunc
                elseif not delayFunc then
                    delayFunc = opacityFunc
                    C_Timer.After(delayWait, function()
                        delayCall()
                    end)
                end
            end
        end
    end

    if C_AddOns.IsAddOnLoaded("ColorPickerPlus") then
        return
    end

    if not GW.Mists then
        ColorPickerFrame.swatchFunc = GW.NoOp
    end

    ColorPickerFrame:SetClampedToScreen(true)
    ColorPickerFrame:SetHeight(ColorPickerFrame:GetHeight() + 40)

    local headerText
    local regions = {ColorPickerFrame:GetRegions()}
    for _, region in pairs(regions) do
        if region:GetObjectType() == "FontString" then
            headerText = region
            break
        end
    end

    GW.CreateFrameHeaderWithBody(ColorPickerFrame, headerText, "Interface/AddOns/GW2_UI/textures/character/settings-window-icon.png", nil, nil, nil, true)

    ColorPickerFrame.TopEdge:Hide()
    ColorPickerFrame.RightEdge:Hide()
    ColorPickerFrame.BottomEdge:Hide()
    ColorPickerFrame.LeftEdge:Hide()
    ColorPickerFrame.BottomRightCorner:Hide()
    ColorPickerFrame.BottomLeftCorner:Hide()
    ColorPickerFrame.TopLeftCorner:Hide()
    ColorPickerFrame.TopRightCorner:Hide()

    ColorPickerFrameHeader:GwStripTextures()

    ColorPickerCancelButton:ClearAllPoints()
    ColorPickerOkayButton:ClearAllPoints()
    ColorPickerCancelButton:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOMRIGHT", -6, 6)
    ColorPickerCancelButton:SetPoint("BOTTOMLEFT", ColorPickerFrame, "BOTTOM", 0, 6)
    ColorPickerOkayButton:SetPoint("BOTTOMLEFT", ColorPickerFrame, "BOTTOMLEFT", 6, 6)
    ColorPickerOkayButton:SetPoint("RIGHT", ColorPickerCancelButton, "LEFT", -4, 0)
    OpacitySliderFrame:GwSkinSliderFrame()
    ColorPickerOkayButton:GwSkinButton(false, true)
    ColorPickerCancelButton:GwSkinButton(false, true)

    ColorPickerFrame:HookScript("OnShow", function(frame)
        if frame.hasOpacity then
            ColorPPBoxA:Show()
            ColorPPBoxLabelA:Show()
            ColorPPBoxH:SetScript("OnTabPressed", ColorPPBoxA_SetFocus)
            UpdateAlphaText()
            UpdateColorTexts()
        else
            ColorPPBoxA:Hide()
            ColorPPBoxLabelA:Hide()
            ColorPPBoxH:SetScript("OnTabPressed", ColorPPBoxR_SetFocus)
            UpdateColorTexts()
        end

        OpacitySliderFrame:SetScript("OnValueChanged", onValueChanged)
        frame:SetScript("OnColorSelect", onColorSelect)
    end)

    local classButton = CreateFrame("Button", "ColorPPClass", ColorPickerFrame, "GwStandardButton")
    classButton:SetText(CLASS)
    classButton:SetSize(80, 22)
    classButton:SetPoint("TOPRIGHT", ColorPickerFrame, "TOPRIGHT", 0, 0)
    classButton:SetScript("OnClick", function()
        local color = GW.GWGetClassColor(GW.myclass, true)
        ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
        ColorSwatch:SetColorTexture(color.r, color.g, color.b)
        if ColorPickerFrame.hasOpacity then
            OpacitySliderFrame:SetValue(0)
        end
    end)

    local boxes = {"R", "G", "B", "H", "A"}
    for i = 1, #boxes do
        local rgb = boxes[i]
        local box = CreateFrame("EditBox", "ColorPPBox" .. rgb, ColorPickerFrame, "InputBoxTemplate")
        box:SetPoint("TOP", "ColorPickerWheel", "BOTTOM", 0, -15)
        box:SetFrameStrata("DIALOG")
        box:SetAutoFocus(false)
        box:SetTextInsets(0, 7, 0, 0)
        box:SetJustifyH("RIGHT")
        box:SetHeight(24)
        box:SetID(i)
        GW.SkinTextBox(box.Middle, box.Left, box.Right)

        if i == 4 then
            box:SetMaxLetters(6)
            box:SetWidth(56)
            box:SetNumeric(false)
        else
            box:SetMaxLetters(3)
            box:SetWidth(40)
            box:SetNumeric(true)
        end

        local label = box:CreateFontString("ColorPPBoxLabel" .. rgb, "ARTWORK", "GameFontNormalSmall")
        label:SetPoint("RIGHT", "ColorPPBox" .. rgb, "LEFT", -5, 0)
        label:SetText(i == 4 and "#" or rgb)
        label:SetTextColor(1, 1, 1)

        if i == 5 then
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
                    if i ~= 4 then
                        UpdateColorTexts(nil, nil, nil, eb)
                    end
                    if i == 4 and eb:GetNumLetters() ~= 6 then
                        return
                    end
                    UpdateColor()
                elseif key == "ENTER" or key == "ESCAPE" then
                    eb:ClearFocus()
                    UpdateColorTexts(nil, nil, nil, eb)
                    UpdateColor()
                end
            end)
        end

        box:SetScript("OnEditFocusGained", function(eb)
            eb:SetCursorPosition(0)
            eb:HighlightText()
        end)
        box:SetScript("OnEditFocusLost", function(eb)
            eb:HighlightText(0, 0)
        end)
        box:Show()
    end

    local offsets
    if GW.Mists then
        offsets = {
            hex = -15,
            blue = -40,
            green = -25,
            red = -25
        }
    else
        offsets = {
            hex = -15,
            blue = -15,
            green = -15,
            red = -15
        }
    end

    ColorPPBoxA:SetPoint("RIGHT", ColorPickerCancelButton, "RIGHT", 0, 20)
    ColorPPBoxH:SetPoint("RIGHT", ColorPPBoxA, "LEFT", offsets.hex, 0)
    ColorPPBoxB:SetPoint("RIGHT", ColorPPBoxH, "LEFT", offsets.blue, 0)
    ColorPPBoxG:SetPoint("RIGHT", ColorPPBoxB, "LEFT", offsets.green, 0)
    ColorPPBoxR:SetPoint("RIGHT", ColorPPBoxG, "LEFT", offsets.red, 0)

    local mover = CreateFrame("Frame", nil, ColorPickerFrame)
    mover:SetPoint("TOPLEFT", ColorPickerFrame, "TOP", -60, 0)
    mover:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "TOP", 60, -15)
    mover:SetScript("OnMouseDown", function()
        ColorPickerFrame:StartMoving()
    end)
    mover:SetScript("OnMouseUp", function()
        ColorPickerFrame:StopMovingOrSizing()
    end)
    mover:EnableMouse(true)

    ColorPickerFrame:SetUserPlaced(true)
    ColorPickerFrame:EnableKeyboard(false)
    ColorPickerFrame:SetClampedToScreen(true)
end
