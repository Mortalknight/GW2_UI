---@class GW2
local GW = select(2, ...)

function GW.ChangeFlyoutStyle(self)
    self.Background.End:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png")
    self.Background.HorizontalMiddle:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png")
    self.Background.VerticalMiddle:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png")
    self.Background.Start:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png")

    local i = 1
    local btn = _G["SpellFlyoutPopupButton" .. i]
    while btn do
        if btn.NormalTexture then
            btn:SetNormalTexture("Interface/AddOns/GW2_UI/textures/bag/bagnormal.png")
        end
        btn.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        btn:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed.png")
        btn:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png")
        i = i + 1
        btn = _G["SpellFlyoutPopupButton" .. i]
    end
end

function GW.FlyoutDirection(actionbar)
    if InCombatLockdown() then return end

    for i = 1, 12 do
        local button = actionbar.gw_Buttons[i]
        if button.FlyoutArrowContainer then
            --Change arrow direction depending on what bar the button is on
            local point = GW.GetScreenQuadrant(actionbar)
            if point ~= "UNKNOWN" then
                local direction
                if strfind(point, "TOP") then
                    direction = "DOWN"
                elseif point == "RIGHT" then
                    direction = "LEFT"
                elseif point == "LEFT" then
                    direction = "RIGHT"
                elseif point == "CENTER" or strfind(point, "BOTTOM") then
                    direction = "UP"
                end
                if direction then
                    -- the attribute write runs OnAttributeChanged, blizzard updates the flyout arrow itself
                    GW.SetSecureAttribute(button, "flyoutDirection", direction)
                end
            end
        end
    end
end
