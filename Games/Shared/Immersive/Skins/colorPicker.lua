---@class GW2
local GW = select(2, ...)

-- Adds channel inputs, class/default colors and a copy slot to Blizzard's color picker.
-- Only hooks are used, so Blizzard keeps calling the caller's swatch/opacity functions.
-- Modern clients nest the picker in ColorPickerFrame.Content, classic clients use the frame itself.

local parts
local channelBoxes = {} -- R, G, B, A
local tabOrder = {}
local lastAlpha
local copied

local function GetParts()
    local content = ColorPickerFrame.Content
    if content then
        local colorSelect = content.ColorPicker
        return {
            select = colorSelect,
            hexBox = content.HexBox,
            GetAlpha = function() return colorSelect:GetColorAlpha() end,
            SetAlpha = function(a)
                colorSelect:SetColorAlpha(a)
                -- the modern alpha bar has no change script of its own
                if ColorPickerFrame.opacityFunc then ColorPickerFrame.opacityFunc() end
            end,
        }
    end

    -- the classic slider stores transparency, its OnValueChanged calls opacityFunc
    return {
        select = ColorPickerFrame,
        GetAlpha = function() return 1 - OpacitySliderFrame:GetValue() end,
        SetAlpha = function(a) OpacitySliderFrame:SetValue(1 - a) end,
    }
end

local function ShowValue(box, value)
    if not box:HasFocus() then
        box:SetText(value)
    end
end

local function RefreshBoxes()
    local r, g, b = parts.select:GetColorRGB()
    ShowValue(channelBoxes[1], Round(r * 255))
    ShowValue(channelBoxes[2], Round(g * 255))
    ShowValue(channelBoxes[3], Round(b * 255))
    if parts.ownHex then
        ShowValue(parts.hexBox, CreateColor(r, g, b):GenerateHexColorNoAlpha())
    end
    lastAlpha = nil -- the alpha box refreshes itself on its next update
end

local function TrackAlpha(box)
    local alpha = parts.GetAlpha()
    if alpha ~= lastAlpha then
        lastAlpha = alpha
        ShowValue(box, Round(alpha * 100))
    end
end

local function SetPickerColor(r, g, b, a)
    parts.select:SetColorRGB(r, g, b)
    if a and ColorPickerFrame.hasOpacity then
        parts.SetAlpha(a)
    end
end

local function ApplyChannel(box, userInput)
    if not userInput then return end

    local value = min(box:GetNumber(), box.maxValue) / box.maxValue
    if box.channel == 4 then
        parts.SetAlpha(value)
        return
    end

    local r, g, b = parts.select:GetColorRGB()
    if box.channel == 1 then
        r = value
    elseif box.channel == 2 then
        g = value
    else
        b = value
    end
    parts.select:SetColorRGB(r, g, b)
end

local function ApplyHex(box, userInput)
    local text = box:GetText()
    if userInput and text:match("^%x%x%x%x%x%x$") then
        parts.select:SetColorRGB(CreateColorFromRGBHexString(text):GetRGB())
    end
end

local function FocusNext(current)
    local index = tIndexOf(tabOrder, current) or 0
    for step = 1, #tabOrder do
        local box = tabOrder[(index + step - 1) % #tabOrder + 1]
        if box:IsShown() then
            box:SetFocus()
            return
        end
    end
end

local function CreateInputBox(parent, label, width)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetSize(width, 22)
    box:SetAutoFocus(false)
    box:SetJustifyH("CENTER")
    box:SetFontObject("GameFontNormalSmall")
    box:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    GW.SkinTextBox(box.Middle, box.Left, box.Right)

    box.label = box:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    box.label:SetPoint("RIGHT", box, "LEFT", -6, 0)
    box.label:SetText(label)
    box.label:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    box:SetScript("OnEnterPressed", box.ClearFocus)
    box:SetScript("OnTabPressed", FocusNext)
    -- shows the clamped value once typing is done
    box:HookScript("OnEditFocusLost", RefreshBoxes)
    return box
end

local function CreateChannelBox(parent, label, channel, maxValue)
    local box = CreateInputBox(parent, label, 40)
    box:SetNumeric(true)
    box:SetMaxLetters(3)
    box.channel, box.maxValue = channel, maxValue
    box:SetScript("OnTextChanged", ApplyChannel)
    return box
end

local function CreateButton(parent, text, onClick)
    local button = CreateFrame("Button", nil, parent, "GwStandardButton")
    button:SetHeight(22)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

local function GetDefaultColor()
    -- our settings pass their default along, other callers never set this key
    local info = ColorPickerFrame:GetExtraInfo()
    return type(info) == "table" and info.gw2Default or nil
end

local function CreateTools(frame)
    local tools = {}

    tools.class = CreateButton(frame, CLASS, function()
        local color = GW.GWGetClassColor(GW.myclass, true)
        SetPickerColor(color.r, color.g, color.b)
    end)

    tools.default = CreateButton(frame, DEFAULT, function()
        local color = GetDefaultColor()
        if color then
            SetPickerColor(color.r, color.g, color.b, color.a)
        end
    end)

    tools.paste = CreateButton(frame, CALENDAR_PASTE_EVENT, function()
        SetPickerColor(copied.r, copied.g, copied.b, copied.a)
    end)
    tools.paste:Disable()

    -- a thin strip on top of the paste button shows what was copied
    tools.copiedSwatch = frame:CreateTexture(nil, "ARTWORK")
    tools.copiedSwatch:SetPoint("BOTTOMLEFT", tools.paste, "TOPLEFT", 0, 2)
    tools.copiedSwatch:SetPoint("BOTTOMRIGHT", tools.paste, "TOPRIGHT", 0, 2)
    tools.copiedSwatch:SetHeight(4)
    tools.copiedSwatch:Hide()

    tools.copy = CreateButton(frame, CALENDAR_COPY_EVENT, function()
        local r, g, b = parts.select:GetColorRGB()
        copied = { r = r, g = g, b = b, a = ColorPickerFrame.hasOpacity and parts.GetAlpha() or nil }
        tools.copiedSwatch:SetColorTexture(r, g, b)
        tools.copiedSwatch:Show()
        tools.paste:Enable()
    end)

    return tools
end

local function PlaceInputRow(frame)
    channelBoxes[1]:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 30, 40)
    for i = 2, #channelBoxes do
        channelBoxes[i]:SetPoint("LEFT", channelBoxes[i - 1], "RIGHT", 24, 0)
    end
    parts.hexBox:ClearAllPoints()
    parts.hexBox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 40)
end

-- modern: swatches and tools as a column right of the picker
local function LayoutModern(frame, tools)
    local content = frame.Content
    content.ColorSwatchCurrent:ClearAllPoints()
    content.ColorSwatchCurrent:SetPoint("TOPRIGHT", content, "TOPRIGHT", -60, -40)
    content.ColorSwatchCurrent:SetSize(48, 24)
    content.ColorSwatchOriginal:ClearAllPoints()
    content.ColorSwatchOriginal:SetPoint("LEFT", content.ColorSwatchCurrent, "RIGHT", 0, 0)
    content.ColorSwatchOriginal:SetSize(48, 24)
    -- the checkerboard is placed from the right edge, which moves with our width
    content.AlphaBackground:SetAllPoints(content.ColorPicker.Alpha)

    tools.copy:SetPoint("TOPLEFT", content.ColorSwatchCurrent, "BOTTOMLEFT", 0, -12)
    tools.copy:SetWidth(47)
    tools.paste:SetPoint("LEFT", tools.copy, "RIGHT", 2, 0)
    tools.paste:SetWidth(47)
    tools.class:SetPoint("TOPLEFT", tools.copy, "BOTTOMLEFT", 0, -6)
    tools.class:SetWidth(96)
    tools.default:SetPoint("TOPLEFT", tools.class, "BOTTOMLEFT", 0, -2)
    tools.default:SetWidth(96)

    parts.hexBox:SetSize(96, 22)
    parts.hexBox.Hash:SetFontObject("GameFontNormalSmall")
    parts.hexBox:SetFontObject("GameFontNormalSmall")
    parts.hexBox:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    GW.SkinTextBox(parts.hexBox.Middle, parts.hexBox.Left, parts.hexBox.Right)
end

-- classic: the swatch and slider fill the right side, tools go into a row below the wheel
local function LayoutClassic(frame, tools)
    local previous
    for _, button in ipairs({ tools.class, tools.default, tools.copy, tools.paste }) do
        button:SetWidth(67)
        if previous then
            button:SetPoint("LEFT", previous, "RIGHT", 4, 0)
        else
            button:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 70)
        end
        previous = button
    end

    OpacitySliderFrame:GwSkinSliderFrame()
end

local function SkinFrame(frame)
    if frame.Content then
        frame.Border:Hide()
        frame.Header:GwStripTextures()
        GW.CreateFrameHeaderWithBody(frame, frame.Header.Text, "Interface/AddOns/GW2_UI/textures/character/settings-window-icon.png")
    else
        frame:ClearBackdrop()
        ColorPickerFrameHeader:Hide()
        local title
        for _, region in ipairs({ frame:GetRegions() }) do
            if region:GetObjectType() == "FontString" then
                title = region
                break
            end
        end
        GW.CreateFrameHeaderWithBody(frame, title, "Interface/AddOns/GW2_UI/textures/character/settings-window-icon.png")
    end

    local okay = frame.Footer and frame.Footer.OkayButton or ColorPickerOkayButton
    local cancel = frame.Footer and frame.Footer.CancelButton or ColorPickerCancelButton
    okay:ClearAllPoints()
    okay:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 10)
    okay:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -2, 10)
    cancel:ClearAllPoints()
    cancel:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 2, 10)
    cancel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 10)
    okay:GwSkinButton(false, true)
    cancel:GwSkinButton(false, true)

    -- the whole GW header drags the window
    local header = frame.gwHeader
    header:EnableMouse(true)
    header:SetScript("OnMouseDown", function() frame:StartMoving() end)
    header:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)

    frame:SetClampedToScreen(true)
    frame:SetUserPlaced(true)
    -- keeps movement keys working while the picker is open
    frame:EnableKeyboard(false)
end

local function SkinAndEnhanceColorPicker()
    if C_AddOns.IsAddOnLoaded("ColorPickerPlus") then return end

    local frame = ColorPickerFrame
    parts = GetParts()
    SkinFrame(frame)

    for i, label in ipairs({ "R", "G", "B", "A" }) do
        channelBoxes[i] = CreateChannelBox(frame, label, i, i == 4 and 100 or 255)
        tabOrder[i] = channelBoxes[i]
    end
    channelBoxes[4]:SetScript("OnUpdate", TrackAlpha)

    if not parts.hexBox then
        parts.hexBox = CreateInputBox(frame, "#", 64)
        parts.hexBox:SetMaxLetters(6)
        parts.hexBox:SetScript("OnTextChanged", ApplyHex)
        parts.ownHex = true
    else
        parts.hexBox:SetScript("OnTabPressed", FocusNext)
    end
    tinsert(tabOrder, parts.hexBox)

    local tools = CreateTools(frame)
    PlaceInputRow(frame)
    if frame.Content then
        LayoutModern(frame, tools)
    else
        LayoutClassic(frame, tools)
    end
    frame:SetHeight(frame:GetHeight() + (frame.Content and 40 or 70))

    parts.select:HookScript("OnColorSelect", RefreshBoxes)
    frame:HookScript("OnShow", function()
        channelBoxes[4]:SetShown(frame.hasOpacity)
        tools.default:SetEnabled(GetDefaultColor() ~= nil)
        if frame.Content then
            -- room for the tool column next to the widest picker
            frame:SetWidth(frame.hasOpacity and 405 or 345)
        end
        RefreshBoxes()
    end)
end
GW.SkinAndEnhanceColorPicker = SkinAndEnhanceColorPicker
