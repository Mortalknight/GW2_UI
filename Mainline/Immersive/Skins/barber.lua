local _, GW = ...

local function HandleNextPrev(button)
    GW.HandleNextPrevButton(button)
    button:SetSize(30, 30)

    -- remove these to fix error on SetHighlightAtlas from AlphaHighlightButtonMixin
    button:SetScript("OnMouseUp", nil)
    button:SetScript("OnMouseDown", nil)
end

local function SetSelectedCategory(list)
    if list.selectionPopoutPool then
        for frame in list.selectionPopoutPool:EnumerateActive() do
            if not frame.IsSkinned then
                if frame.DecrementButton then
                    HandleNextPrev(frame.DecrementButton)
                    HandleNextPrev(frame.IncrementButton)
                end

                local button = frame.Button
                if button then
                    if button.HighlightTexture then
                        button.HighlightTexture:SetAlpha(0)
                    end

                    if button.NormalTexture then
                        button.NormalTexture:SetAlpha(0)
                    end

                    local popout = button.Popout
                    if popout then
                        local r, g, b, a = 1, 1, 1,
                        popout:GwStripTextures()
                        popout:GwCreateBackdrop(GW.BackdropTemplates.Default)
                        popout:SetBackdropColor(r, g, b, max(a, 0.7))
                        popout.backdrop:SetFrameLevel(popout:GetFrameLevel())
                    end

                    button:GwSkinButton(false, true, false, true)
                    button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
                    button.backdrop:SetBackdropBorderColor(0, 0, 0)
                    button.backdrop:GwSetInside(nil, 4, 4)

                    button:HookScript("OnEnter", function()
                        button.backdrop:SetBackdropBorderColor(1, 1, 1)
                    end)
                    button:HookScript("OnLeave", function()
                        button.backdrop:SetBackdropBorderColor(0, 0, 0)
                    end)

                end

                frame.IsSkinned = true
            end
        end
    end

    if list.dropdownPool then
        for option in list.dropdownPool:EnumerateActive() do
            if not option.IsSkinned then
                option.Dropdown:GwSkinButton(false, true)
                option.Label:SetTextColor(1, 1, 1)
                option.Dropdown.Text:SetTextColor(0, 0, 0)
                option.Dropdown.SelectionDetails.SelectionName:SetTextColor(0, 0, 0)
                option.Dropdown.SelectionDetails.SelectionNumber:SetTextColor(0, 0, 0)
                hooksecurefunc(option.Dropdown.SelectionDetails.SelectionNumber, "SetTextColor", function(self, r, g, b)
                    if r ~= 0 or g ~= 0 or b ~= 0 then
                        self:SetTextColor(0, 0, 0)
                    end
                end)
                hooksecurefunc(option.Dropdown.SelectionDetails.SelectionName, "SetTextColor", function(self, r, g, b)
                    if r ~= 0 or g ~= 0 or b ~= 0 then
                        self:SetTextColor(0, 0, 0)
                    end
                end)
                hooksecurefunc(option.Dropdown.Text, "SetTextColor", function(self, r, g, b)
                    if r ~= 0 or g ~= 0 or b ~= 0 then
                        self:SetTextColor(0, 0, 0)
                    end
                end)
                option.DecrementButton:GwSkinButton(false, true, nil, nil, nil, nil, true)
                option.IncrementButton:GwSkinButton(false, true, nil, nil, nil, nil, true)

                option.IsSkinned = true
            end
        end
    end

    if list.sliderPool then
        for slider in list.sliderPool:EnumerateActive() do
            if not slider.IsSkinned then
                slider:GwSkinSliderFrame()

                slider.IsSkinned = true
            end
        end
    end

    local optionPool = list.pools and list.pools:GetPool("CharCustomizeOptionCheckButtonTemplate")
    if optionPool then
        for frame in optionPool:EnumerateActive() do
            if not frame.IsSkinned then
                if frame.Button then
                    frame.Button:GwSkinCheckButton()
                    frame.Button:SetSize(20, 20)
                end

                frame.IsSkinned = true
            end
        end
    end
end


local function SkinCharacterCustomizeSkin()
    if not GW.settings.BARBERSHOP_SKIN_ENABLED then return end

    CharCustomizeFrame.SmallButtons.ResetCameraButton:GwSkinButton(nil, nil, nil, true, nil, true, true)
    CharCustomizeFrame.SmallButtons.ZoomOutButton:GwSkinButton(false, false, false, true, false, true, true)
    CharCustomizeFrame.SmallButtons.ZoomInButton:GwSkinButton(false, false, false, true, false, true, true)
    CharCustomizeFrame.SmallButtons.RotateLeftButton:GwSkinButton(false, false, false, true, false, true, true)
    CharCustomizeFrame.SmallButtons.RotateRightButton:GwSkinButton(false, false, false, true, false, true, true)
    CharCustomizeFrame.RandomizeAppearanceButton:GwSkinButton(false, false, false, true, false, true, true)

    hooksecurefunc(CharCustomizeFrame, "AddMissingOptions", SetSelectedCategory)
end


local function SkinBarShop()
    if not GW.settings.BARBERSHOP_SKIN_ENABLED then return end
    BarberShopFrame.ResetButton:GwSkinButton(false, true)
    BarberShopFrame.CancelButton:GwSkinButton(false, true)
    BarberShopFrame.AcceptButton:GwSkinButton(false, true)

    BarberShopFrame.TopBackgroundOverlay:SetDrawLayer("BACKGROUND", 0)
    BarberShopFrame.LeftBackgroundOverlay:SetDrawLayer("BACKGROUND", 0)
    BarberShopFrame.RightBackgroundOverlay:SetDrawLayer("BACKGROUND", 0)
end


local function LoadBarShopUISkin()
    GW.RegisterLoadHook(SkinBarShop, "Blizzard_BarbershopUI", BarberShopFrame)
    GW.RegisterLoadHook(SkinCharacterCustomizeSkin, "Blizzard_CharacterCustomize", CharCustomizeFrame)
end
GW.LoadBarShopUISkin = LoadBarShopUISkin
