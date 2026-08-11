---@class GW2
local GW = select(2, ...)

-- Content pass for the recent allies cards (RecentAlliesSocialCardTemplate): Blizzard
-- bakes its colors into the display strings on every refresh, so this runs after each
-- element initialization (wired through SkinSocialContactsView) and rebuilds the
-- texts and icons in the GW look. The data sits on card.elementData
-- ({ characterData, stateData, interactionData }).
local function UpdateRecentAllyCardContent(card)
    local elementData = card.elementData
    local characterData = elementData.characterData
    local stateData = elementData.stateData
    if not characterData or not stateData then return end

    if not card.gwContentSkinned then
        card.gwContentSkinned = true
        card.Level:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -1)
        card.Class:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -1)
        card.MostRecentInteraction:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -1)
        card.Location:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -1)
    end

    local isOnline = stateData.isOnline
    card.PresenceHolder.PresenceIcon:SetTexture(GW.friendsList.statusIcons.square[isOnline and "Online" or "Offline"])
    card.PresenceHolder.PresenceIcon:SetTexCoord(0, 1, 0, 1)

    local classInfo = characterData.classID and C_CreatureInfo.GetClassInfo(characterData.classID)
    local classColor = isOnline and classInfo and GW.GWGetClassColor(classInfo.classFile, true, true, true) or DARKGRAY_COLOR

    if characterData.name and characterData.name ~= "" then
        card.Name:SetText(GW.StringWithRGB(characterData.name, classColor))
    end
    if characterData.level and characterData.level > 0 then
        local levelColor = isOnline and GetQuestDifficultyColor(characterData.level) or DARKGRAY_COLOR
        card.Level:SetText(GW.friendsList.delimiter .. GW.StringWithRGB(tostring(characterData.level), levelColor))
    end
    if classInfo then
        card.Class:SetText(GW.friendsList.delimiter .. GW.StringWithRGB(classInfo.className, classColor))
    end

    card.Level:ClearAllPoints()
    card.Level:SetPoint("BOTTOMLEFT", card.Name, "BOTTOMRIGHT", 2, 1)
    card.Class:ClearAllPoints()
    card.Class:SetPoint("BOTTOMLEFT", card.Level, "BOTTOMRIGHT", 2, 0)
    card.Class:SetPoint("RIGHT", card.TextHolder, "RIGHT")

    if isOnline then
        for _, key in next, { "MostRecentInteraction", "Location" } do
            -- strip hex color codes AND the newer named-color tags ("|cnCOLOR_NAME:")
            local plain = gsub(gsub(gsub(card[key]:GetText() or "", "|c%x%x%x%x%x%x%x%x", ""), "|cn[^:]+:", ""), "|r", "")
            if plain ~= "" then
                card[key]:SetText(GW.StringWithRGB(plain, { r = 1, g = 1, b = 1 }))
            end
        end
    end
end

function GW.SkinRecentAlliesList()
    local RecentAlliesList = SocialUIFrame.RecentAlliesList
    if not RecentAlliesList then return end

    GW.SkinSocialContactsView(RecentAlliesList, UpdateRecentAllyCardContent)
end
