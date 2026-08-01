---@class GW2
local GW = select(2, ...)

-- 12.1: RecentAlliesSocialCardTemplate — the FontStrings live directly on the card button
local function ReskinRecentAllyCard(button)
    if button.gwSkinned then return end
    button.gwSkinned = true

    for _, key in pairs({ "Name", "Level", "Class" }) do
        if button[key] then
            button[key]:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        end
    end
    for _, key in pairs({ "MostRecentInteraction", "Location" }) do
        if button[key] then
            button[key]:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        end
    end
end

function GW.SkinRecentAlliesList()
    local RecentAlliesList = SocialUIFrame.RecentAlliesList
    if not RecentAlliesList then return end

    GW.SkinSocialContactsView(RecentAlliesList)

    hooksecurefunc(RecentAlliesList.ScrollBox, "Update", function(scrollBox)
        scrollBox:ForEachFrame(ReskinRecentAllyCard)
    end)
end
