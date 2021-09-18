local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame

local function SkinBarShop()
    if not GW.GetSetting("BARBERSHOP_SKIN_ENABLED") then return end
    _G.BarberShopFrame.ResetButton:SkinButton(false, true)
    _G.BarberShopFrame.CancelButton:SkinButton(false, true)
    _G.BarberShopFrame.AcceptButton:SkinButton(false, true)

    _G.BarberShopFrame.TopBackgroundOverlay:SetDrawLayer("BACKGROUND", 0)
    _G.BarberShopFrame.LeftBackgroundOverlay:SetDrawLayer("BACKGROUND", 0)
    _G.BarberShopFrame.RightBackgroundOverlay:SetDrawLayer("BACKGROUND", 0)

    _G.CharCustomizeFrame.SmallButtons.ResetCameraButton:SkinButton(false, true)
    _G.CharCustomizeFrame.SmallButtons.ZoomOutButton:SkinButton(false, true)
    _G.CharCustomizeFrame.SmallButtons.ZoomInButton:SkinButton(false, true)
    _G.CharCustomizeFrame.SmallButtons.RotateLeftButton:SkinButton(false, true)
    _G.CharCustomizeFrame.SmallButtons.RotateRightButton:SkinButton(false, true)

    hooksecurefunc(_G.CharCustomizeFrame, "SetSelectedCatgory", function(list)
        for button in list.selectionPopoutPool:EnumerateActive() do
            if not button.isSkinned then
                button.DecrementButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/backicon")
                button.DecrementButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/character/backicon")
                button.DecrementButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/character/backicon")
                button.IncrementButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/forwardicon")
                button.IncrementButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/character/forwardicon")
                button.IncrementButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/character/forwardicon")

                local popoutButton = button.SelectionPopoutButton
                popoutButton.Popout:StripTextures()
                popoutButton.Popout:CreateBackdrop(constBackdropFrame)
                popoutButton.Popout.backdrop:SetFrameLevel(popoutButton.Popout:GetFrameLevel())

                button.isSkinned = true
            end
        end

        local optionPool = list.pools:GetPool('CharCustomizeOptionCheckButtonTemplate')
        for button in optionPool:EnumerateActive() do
            if not button.isSkinned then
                button.Button:SkinCheckButton()
                button.isSkinned = true
            end
        end
    end)
end

local function LoadBarShopUISkin()
    GW.RegisterSkin("Blizzard_BarbershopUI", function() SkinBarShop() end)
end
GW.LoadBarShopUISkin = LoadBarShopUISkin
