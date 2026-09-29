---@class GW2
local GW = select(2, ...)

local function SetBorderWhite(button)
    button.backdrop:SetBackdropBorderColor(GW.Colors.FallbackWhite:GetRGB())
end

local function SetBorderBlack(button)
    button.backdrop:SetBackdropBorderColor(GW.Colors.Fallback:GetRGB())
end

-- the options with arrows left and right and a popout list in the middle
local function SkinSelectionPopout(frame)
    if frame.DecrementButton then
        GW.SkinStepperArrow(frame.DecrementButton, 30)
        GW.SkinStepperArrow(frame.IncrementButton, 30)
    end

    local button = frame.Button
    if not button then return end
    for _, key in ipairs({"HighlightTexture", "NormalTexture"}) do
        if button[key] then
            button[key]:SetAlpha(0)
        end
    end
    if button.Popout then
        button.Popout:GwStripTextures()
        button.Popout:GwCreateBackdrop(GW.BackdropTemplates.Default)
        button.Popout.backdrop:SetFrameLevel(button.Popout:GetFrameLevel())
    end

    button:GwSkinButton(false, true, false, true)
    button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
    button.backdrop:GwSetInside(nil, 4, 4)
    SetBorderBlack(button)
    button:HookScript("OnEnter", SetBorderWhite)
    button:HookScript("OnLeave", SetBorderBlack)
end

-- our buttons are light, their texts stay black whatever blizzard colors them
local function SkinDropdownOption(option)
    local dropdown = option.Dropdown
    dropdown:GwSkinButton(false, true)
    option.Label:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    for _, text in ipairs({dropdown.Text, dropdown.SelectionDetails.SelectionName, dropdown.SelectionDetails.SelectionNumber}) do
        GW.LockFontStringColor(text, 0, 0, 0)
    end
    for _, arrow in ipairs({option.DecrementButton, option.IncrementButton}) do
        arrow:GwSkinButton(false, true, nil, nil, nil, nil, true)
    end
end

local function SkinSlider(slider)
    slider:GwSkinSliderFrame()
end

local function SkinCheckOption(frame)
    if frame.Button then
        frame.Button:GwSkinCheckButton(false, 20)
    end
end

-- blizzard adds the options of a category when it is picked
local function SkinOptions(list)
    GW.SkinPoolFrames(list.selectionPopoutPool, SkinSelectionPopout)
    GW.SkinPoolFrames(list.dropdownPool, SkinDropdownOption)
    GW.SkinPoolFrames(list.sliderPool, SkinSlider)
    -- the check buttons were renamed with the shared customization ui (12.x)
    for _, template in ipairs({"CustomizationOptionCheckButtonTemplate", "CharCustomizeOptionCheckButtonTemplate"}) do
        GW.SkinPoolFrames(list.pools and list.pools:GetPool(template), SkinCheckOption)
    end
end

local function SkinCharacterCustomizeSkin()
    if not GW.settings.skins.barberShop.enabled then return end
    local frame = CharCustomizeFrame

    frame.SmallButtons.ResetCameraButton:GwSkinButton(nil, nil, nil, true, nil, true, true)
    for _, button in ipairs({frame.SmallButtons.ZoomOutButton, frame.SmallButtons.ZoomInButton, frame.SmallButtons.RotateLeftButton,
        frame.SmallButtons.RotateRightButton, frame.RandomizeAppearanceButton}) do
        button:GwSkinButton(false, false, false, true, false, true, true)
    end

    hooksecurefunc(frame, "AddMissingOptions", SkinOptions)
end

local function SkinBarShop()
    if not GW.settings.skins.barberShop.enabled then return end
    local frame = BarberShopFrame

    for _, button in ipairs({frame.ResetButton, frame.CancelButton, frame.AcceptButton}) do
        button:GwSkinButton(false, true)
    end
    -- the overlays go below the model
    for _, overlay in ipairs({frame.TopBackgroundOverlay, frame.LeftBackgroundOverlay, frame.RightBackgroundOverlay}) do
        overlay:SetDrawLayer("BACKGROUND", 0)
    end
end

local function LoadBarShopUISkin()
    GW.RegisterLoadHook(SkinBarShop, "Blizzard_BarbershopUI", BarberShopFrame)
    GW.RegisterLoadHook(SkinCharacterCustomizeSkin, "Blizzard_CharacterCustomize", CharCustomizeFrame)
end
GW.LoadBarShopUISkin = LoadBarShopUISkin
