local _, GW = ...

local colorBuffer = {}

local function alphaValue(num)
    return num and floor((num * 100) + .05) or 0
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
    if not alpha then
        alpha = alphaValue(ColorPickerFrame:GetColorAlpha())
    end

    GwColorPPBoxA:SetText(alpha)
end

local delayWait, delayFunc = 0.15, nil
local function delayCall()
    if delayFunc then
        delayFunc()
        delayFunc = nil
    end
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

local last = { r = 0, g = 0, b = 0, a = 0 }
local function onAlphaValueChanged(_, value)
    local alpha = alphaValue(value)
    if last.a ~= alpha then
        last.a = alpha
    else
        return
    end

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

local function UpdateAlpha(tbox)
    local num = tbox:GetNumber()
    if num > 100 then
        tbox:SetText(100)
        num = 100
    end

    local value = num * 0.01
    ColorPickerFrame.Content.ColorPicker:SetColorAlpha(value)
    onAlphaValueChanged(nil, value)
end

local function ColorPPBoxA_SetFocus()
    GwColorPPBoxA:SetFocus()
end

local function ColorPPBoxR_SetFocus()
    GwColorPPBoxR:SetFocus()
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
                if box == GwColorPPBoxR then
                    r = c
                elseif box == GwColorPPBoxG then
                    g = c
                elseif box == GwColorPPBoxB then
                    b = c
                end
            end
        end
    end

    r, g, b = GW.RoundDec(r * 255), GW.RoundDec(g * 255), GW.RoundDec(b * 255)

    ColorPickerFrame.Content.HexBox:SetText(("%.2x%.2x%.2x"):format(r, g, b))
    GwColorPPBoxR:SetText(r)
    GwColorPPBoxG:SetText(g)
    GwColorPPBoxB:SetText(b)
end

local function onColorSelect(frame, r, g, b)
    if frame.noColorCallback then
        return -- prevent error from E:GrabColorPickerValues, better note in that function
    elseif r ~= last.r or g ~= last.g or b ~= last.b then
        last.r, last.g, last.b = r, g, b
    else -- colors match so we don"t need to update, most likely mouse is held down
        return
    end

    ColorPickerFrame.Content.ColorSwatchCurrent:SetColorTexture(r, g, b)
    UpdateColorTexts(r, g, b)
    UpdateAlphaText()

    if not frame:IsVisible() then
        delayCall()
    elseif not delayFunc then
        delayFunc = ColorPickerFrame.func
        if delayFunc then
            C_Timer.After(delayWait, function() delayCall() end)
		end
    end
end

local function SkinAndEnhanceColorPicker()
    if C_AddOns.IsAddOnLoaded("ColorPickerPlus") then return end

    ColorPickerFrame.swatchFunc = GW.NoOp

    ColorPickerFrame:SetClampedToScreen(true)
    ColorPickerFrame:SetUserPlaced(true)
    ColorPickerFrame:EnableKeyboard(false)

    ColorPickerFrame:SetHeight(ColorPickerFrame:GetHeight() + 40)


    ColorPickerFrame.Border:Hide()
    ColorPickerFrame.Header:GwStripTextures()
    GW.CreateFrameHeaderWithBody(ColorPickerFrame, ColorPickerFrame.Header.Text, "Interface/AddOns/GW2_UI/textures/character/settings-window-icon")

    ColorPickerFrame.Footer.CancelButton:ClearAllPoints()
    ColorPickerFrame.Footer.OkayButton:ClearAllPoints()
    ColorPickerFrame.Footer.CancelButton:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOMRIGHT", -6, 6)
    ColorPickerFrame.Footer.CancelButton:SetPoint("BOTTOMLEFT", ColorPickerFrame, "BOTTOM", 0, 6)
    ColorPickerFrame.Footer.OkayButton:SetPoint("BOTTOMLEFT", ColorPickerFrame,"BOTTOMLEFT", 6,6)
    ColorPickerFrame.Footer.OkayButton:SetPoint("RIGHT", ColorPickerFrame.Footer.CancelButton, "LEFT", -4, 0)
    ColorPickerFrame.Footer.OkayButton:GwSkinButton(false, true)
    ColorPickerFrame.Footer.CancelButton:GwSkinButton(false, true)
    GW.SkinTextBox(ColorPickerFrame.Content.HexBox.Middle, ColorPickerFrame.Content.HexBox.Left, ColorPickerFrame.Content.HexBox.Right)

    ColorPickerFrame.Content.HexBox.Hash:SetFontObject("GameFontNormalSmall")
    local HexText = ColorPickerFrame.Content.HexBox:GetRegions()
    HexText:SetFontObject("GameFontNormalSmall")
    HexText:SetTextColor(1, 1, 1)

    ColorPickerFrame.Content.ColorPicker:SetScript("OnColorSelect", onColorSelect)

    ColorPickerFrame:HookScript("OnShow", function(frame)
        local r, g, b = frame:GetColorRGB()
        frame.Content.ColorSwatchOriginal:SetColorTexture(r, g, b)

        if frame.hasOpacity then
            GwColorPPBoxA:Show()
            GwColorPPBoxLabelA:Show()
            frame.Content.HexBox:SetScript("OnTabPressed", ColorPPBoxA_SetFocus)
            UpdateAlphaText()
            frame:SetWidth(405)
        else
            GwColorPPBoxA:Hide()
            GwColorPPBoxLabelA:Hide()
            frame.Content.HexBox:SetScript("OnTabPressed", ColorPPBoxR_SetFocus)
            frame:SetWidth(345)
        end

        UpdateColorTexts(nil, nil, nil, frame.Content.HexBox)
    end)

    -- add Color Swatch for the copied color
    local swatchWidth, swatchHeight = ColorPickerFrame.Content.ColorSwatchCurrent:GetSize()
    local copiedColor = ColorPickerFrame:CreateTexture("GwColorPPCopyColorSwatch")
    copiedColor:SetColorTexture(0,0,0)
    copiedColor:SetSize(swatchWidth, swatchHeight)
    copiedColor:Hide()

    -- add copy button to the ColorPickerFrame
    local copyButton = CreateFrame("Button", "GwColorPPCopy", ColorPickerFrame, "GwStandardButton")
    copyButton:SetText(CALENDAR_COPY_EVENT)
    copyButton:SetSize(60, 22)

    -- copy color into buffer on button click
    copyButton:SetScript("OnClick", function()
        -- copy current dialog colors into buffer
        colorBuffer.r, colorBuffer.g, colorBuffer.b = ColorPickerFrame:GetColorRGB()

        -- enable Paste button and display copied color into swatch
        GwColorPPPaste:Enable()
        GwColorPPCopyColorSwatch:SetColorTexture(colorBuffer.r, colorBuffer.g, colorBuffer.b)
        GwColorPPCopyColorSwatch:Show()

        colorBuffer.a = (ColorPickerFrame.hasOpacity and ColorPickerFrame:GetColorAlpha()) or nil
    end)

    local alphaUpdater = CreateFrame("Frame", "$parent_AlphaUpdater", ColorPickerFrame)
    alphaUpdater:SetScript("OnUpdate", function()
        if ColorPickerFrame.Content.ColorPicker.Alpha:IsMouseOver() then
            onAlphaValueChanged(nil, ColorPickerFrame:GetColorAlpha())
        end
    end)

    --class color button
    local classButton = CreateFrame("Button", "GwColorPPClass", ColorPickerFrame, "GwStandardButton")
    classButton:SetText(CLASS)
    classButton:SetSize(80, 22)
    classButton:SetPoint("TOPRIGHT", ColorPickerFrame, "TOPRIGHT", 0, 0)

    classButton:SetScript("OnClick", function()
        local color = GW.GWGetClassColor(GW.myclass, true, true)
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(color.r, color.g, color.b)
        ColorPickerFrame.Content.ColorSwatchCurrent:SetColorTexture(color.r, color.g, color.b)
    end)

    -- add paste button to the ColorPickerFrame
    local pasteButton = CreateFrame("Button", "GwColorPPPaste", ColorPickerFrame, "GwStandardButton")
    pasteButton:SetText(CALENDAR_PASTE_EVENT)
    pasteButton:SetSize(60, 22)
    pasteButton:Disable() -- enable when something has been copied

    -- paste color on button click, updating frame components
    pasteButton:SetScript("OnClick", function()
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(colorBuffer.r, colorBuffer.g, colorBuffer.b)
        ColorPickerFrame.Content.ColorSwatchCurrent:SetColorTexture(colorBuffer.r, colorBuffer.g, colorBuffer.b)

        if ColorPickerFrame.hasOpacity and colorBuffer.a then
            if colorBuffer.a then
                ColorPickerFrame.Content.ColorPicker:SetColorAlpha(colorBuffer.a)
                onAlphaValueChanged(nil, colorBuffer.a)
            end
        end
    end)

    -- set up edit box frames and interior label and text areas
    for i, rgb in next, { "R", "G", "B", "A" } do
        local box = CreateFrame("EditBox", "GwColorPPBox" .. rgb, ColorPickerFrame, "InputBoxTemplate")
        box:SetPoint("TOP", ColorPickerFrame.Content.ColorSwatchOriginal, "BOTTOM", 0, -105)
        box:SetFrameStrata("DIALOG")
        box:SetAutoFocus(false)
        box:SetTextInsets(0, 7, 0, 0)
        box:SetJustifyH("RIGHT")
        box:SetHeight(24)
        box:SetID(i)

        GW.SkinTextBox(box.Middle, box.Left, box.Right)
        box:SetFontObject("GameFontNormalSmall")
        box:SetTextColor(1, 1, 1)

        box:SetMaxLetters(3)
        box:SetWidth(40)
        box:SetNumeric(true)

        -- label
        local label = box:CreateFontString("GwColorPPBoxLabel" .. rgb, "ARTWORK", "GameFontNormalSmall")
        label:SetPoint("RIGHT", "GwColorPPBox" .. rgb, "LEFT", -5, 0)
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
                    UpdateColorTexts(nil, nil, nil, eb)
                    UpdateColor()
                elseif key == "ENTER" or key == "ESCAPE" then
                    eb:ClearFocus()
                    UpdateColorTexts(nil, nil, nil, eb)
                    UpdateColor()
                end
            end)
        end

        box:SetScript("OnEditFocusGained", function(eb) eb:SetCursorPosition(0) eb:HighlightText() end)
        box:SetScript("OnEditFocusLost", function(eb) eb:HighlightText(0, 0) end)
        box:Show()
    end

    ColorPickerFrame.Content.AlphaBackground:SetAllPoints(ColorPickerFrame.Content.ColorPicker.Alpha)

    ColorPickerFrame.Content.ColorSwatchCurrent:SetPoint("TOPLEFT", ColorPickerFrame.Content, "TOPRIGHT", -120, -37)
    ColorPickerFrame.Content.ColorSwatchOriginal:SetPoint("TOPLEFT", ColorPickerFrame.Content.ColorSwatchCurrent, "BOTTOMLEFT", 0, -2)

    GwColorPPCopyColorSwatch:SetPoint("BOTTOM", pasteButton, "TOP", 0, 5)

    copyButton:SetPoint("TOPLEFT", ColorPickerFrame.Content.ColorSwatchOriginal, "BOTTOMLEFT", -6, -5)
    pasteButton:SetPoint("TOPLEFT", copyButton, "TOPRIGHT", 2, 0)

    classButton:SetPoint("TOP", copyButton, "BOTTOMRIGHT", 0, -7)

    ColorPickerFrame.Content.HexBox:ClearAllPoints()
    ColorPickerFrame.Content.HexBox:SetPoint("TOPRIGHT", classButton, "BOTTOMRIGHT", 0, -2)
    ColorPickerFrame.Content.HexBox:SetWidth(78)

    GwColorPPBoxA:SetPoint("RIGHT", ColorPickerFrame.Content.HexBox, "LEFT", -45, 0)

    GwColorPPBoxR:SetPoint("LEFT", ColorPickerFrame.Content, 25, 0)
    GwColorPPBoxG:SetPoint("LEFT", GwColorPPBoxR, 65, 0)
    GwColorPPBoxB:SetPoint("LEFT", GwColorPPBoxG, 65, 0)

    GwColorPPBoxR:SetScript("OnTabPressed", function() GwColorPPBoxG:SetFocus() end)
    GwColorPPBoxG:SetScript("OnTabPressed", function() GwColorPPBoxB:SetFocus() end)
    GwColorPPBoxB:SetScript("OnTabPressed", function() ColorPickerFrame.Content.HexBox:SetFocus() end)
    GwColorPPBoxA:SetScript("OnTabPressed", function() GwColorPPBoxR:SetFocus() end)

    -- make the color picker movable.
    local mover = CreateFrame("Frame", nil, ColorPickerFrame)
    mover:SetPoint("TOPLEFT", ColorPickerFrame, "TOP", -60, 0)
    mover:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "TOP", 60, -15)
    mover:SetScript("OnMouseDown", function() ColorPickerFrame:StartMoving() end)
    mover:SetScript("OnMouseUp", function() ColorPickerFrame:StopMovingOrSizing() end)
    mover:EnableMouse(true)
end
GW.SkinAndEnhanceColorPicker = SkinAndEnhanceColorPicker