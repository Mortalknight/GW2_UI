---@class GW2
local GW = select(2, ...)

-- blizzards possess bar stays where the edit mode puts it, only its two buttons get our look
function GW.SkinPossessBar()
    for i = 1, NUM_POSSESS_SLOTS or 0 do
        local button = _G["PossessButton" .. i]
        if button then
            if button.SlotBackground then
                button.SlotBackground:SetAlpha(0)
            end
            GW.setActionButtonStyle(button:GetName(), nil, nil, true)
        end
    end
end
