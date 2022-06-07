local _, GW = ...
local constBackdropFrame = GW.skins.constBackdropFrame
local AFP = GW.AddProfiling

local function hook_SetSelectedCategory(list)
    for button in list.selectionPopoutPool:EnumerateActive() do
        if not button.isSkinned then
            button.DecrementButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/backicon")
            button.DecrementButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/character/backicon")
            button.DecrementButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/character/backicon")
            button.IncrementButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/forwardicon")
            button.IncrementButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/character/forwardicon")
            button.IncrementButton:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/character/forwardicon")

            local popoutButton = button.Button
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
end
AFP("hook_SetSelectedCategory", hook_SetSelectedCategory)

local function SkinBarShop()
    if not GW.GetSetting("BARBERSHOP_SKIN_ENABLED") then return end
    BarberShopFrame.ResetButton:SkinButton(false, true)
    BarberShopFrame.CancelButton:SkinButton(false, true)
    BarberShopFrame.AcceptButton:SkinButton(false, true)

    BarberShopFrame.TopBackgroundOverlay:SetDrawLayer("BACKGROUND", 0)
    BarberShopFrame.LeftBackgroundOverlay:SetDrawLayer("BACKGROUND", 0)
    BarberShopFrame.RightBackgroundOverlay:SetDrawLayer("BACKGROUND", 0)

    CharCustomizeFrame.SmallButtons.ResetCameraButton:SkinButton(false, true)
    CharCustomizeFrame.SmallButtons.ZoomOutButton:SkinButton(false, true)
    CharCustomizeFrame.SmallButtons.ZoomInButton:SkinButton(false, true)
    CharCustomizeFrame.SmallButtons.RotateLeftButton:SkinButton(false, true)
    CharCustomizeFrame.SmallButtons.RotateRightButton:SkinButton(false, true)

    hooksecurefunc(_G.CharCustomizeFrame, "SetSelectedCategory", hook_SetSelectedCategory)
end
AFP("SkinBarShop", SkinBarShop)

local function LoadBarShopUISkin()
    GW.RegisterLoadHook(SkinBarShop, "Blizzard_BarbershopUI", BarberShopFrame)
end
GW.LoadBarShopUISkin = LoadBarShopUISkin
