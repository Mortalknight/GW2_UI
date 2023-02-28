local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame
local AFP = GW.AddProfiling
local GetSetting = GW.GetSetting

local function hook_SetSelectedCategory(list)
    if list.selectionPopoutPool then
        for button in list.selectionPopoutPool:EnumerateActive() do
            if not button.isSkinned then
                GW.HandleNextPrevButton(button.DecrementButton)
                GW.HandleNextPrevButton(button.IncrementButton)
                button.DecrementButton:SetSize(30, 30)
                button.IncrementButton:SetSize(30, 30)

                -- remove these to fix error on SetHighlightAtlas from AlphaHighlightButtonMixin
                button.DecrementButton:SetScript("OnMouseUp", nil)
                button.DecrementButton:SetScript("OnMouseDown", nil)
                button.IncrementButton:SetScript("OnMouseUp", nil)
                button.IncrementButton:SetScript("OnMouseDown", nil)

                local popoutButton = button.Button
                popoutButton.HighlightTexture:SetAlpha(0)
                popoutButton.NormalTexture:SetAlpha(0)

                popoutButton.Popout:GwStripTextures()
                popoutButton.Popout:GwCreateBackdrop(constBackdropFrame)
                popoutButton.Popout.backdrop:SetFrameLevel(popoutButton.Popout:GetFrameLevel())

                popoutButton:GwSkinButton(false, true, false, true)
                popoutButton:GwCreateBackdrop(GW.constBackdropFrameColorBorder)
                popoutButton.backdrop:SetBackdropBorderColor(0, 0, 0)
                popoutButton.backdrop:GwSetInside(nil, 4, 4)

                popoutButton:HookScript("OnEnter", function()
                    popoutButton.backdrop:SetBackdropBorderColor(1, 1, 1)
                end)
                popoutButton:HookScript("OnLeave", function()
                    popoutButton.backdrop:SetBackdropBorderColor(0, 0, 0)
                end)

                button.isSkinned = true
            end
        end
    end

    local optionPool = list.pools and list.pools:GetPool("CharCustomizeOptionCheckButtonTemplate")
    if optionPool then
        for button in optionPool:EnumerateActive() do
            if not button.isSkinned then
                button.Button:GwSkinCheckButton()
                button.Button:SetSize(20, 20)
                button.isSkinned = true
            end
        end
    end
end
AFP("hook_SetSelectedCategory", hook_SetSelectedCategory)

local function SkinBarShop()
    if not GetSetting("BARBERSHOP_SKIN_ENABLED") then return end
    BarberShopFrame.ResetButton:GwSkinButton(false, true)
    BarberShopFrame.CancelButton:GwSkinButton(false, true)
    BarberShopFrame.AcceptButton:GwSkinButton(false, true)

    BarberShopFrame.TopBackgroundOverlay:SetDrawLayer("BACKGROUND", 0)
    BarberShopFrame.LeftBackgroundOverlay:SetDrawLayer("BACKGROUND", 0)
    BarberShopFrame.RightBackgroundOverlay:SetDrawLayer("BACKGROUND", 0)

    CharCustomizeFrame.SmallButtons.ResetCameraButton:GwSkinButton(false, false, false, true, false, true)
    CharCustomizeFrame.SmallButtons.ZoomOutButton:GwSkinButton(false, false, false, true, false, true)
    CharCustomizeFrame.SmallButtons.ZoomInButton:GwSkinButton(false, false, false, true, false, true)
    CharCustomizeFrame.SmallButtons.RotateLeftButton:GwSkinButton(false, false, false, true, false, true)
    CharCustomizeFrame.SmallButtons.RotateRightButton:GwSkinButton(false, false, false, true, false, true)

    hooksecurefunc(CharCustomizeFrame, "SetSelectedCategory", hook_SetSelectedCategory)
end
AFP("SkinBarShop", SkinBarShop)

local function LoadBarShopUISkin()
    GW.RegisterLoadHook(SkinBarShop, "Blizzard_BarbershopUI", BarberShopFrame)
end
GW.LoadBarShopUISkin = LoadBarShopUISkin
