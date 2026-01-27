local _, GW = ...

local delimiter = format("|cff%s | |r", "979fad")

local function ReskinRecentAllyButton(button)
    if not button.isSkinned then
        local normal = button.PartyButton:GetNormalTexture()
        normal:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-down.png")
        normal:SetTexCoord(0, 1, 0, 1)
        normal:SetSize(18, 18)
        normal:ClearAllPoints()
        normal:SetPoint("CENTER")
        normal:SetVertexColor(1, 1, 1, 1)

        local disabled = button.PartyButton:GetDisabledTexture()
        disabled:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-down.png")
        disabled:SetTexCoord(0, 1, 0, 1)
        disabled:SetSize(18, 18)
        disabled:ClearAllPoints()
        disabled:SetPoint("CENTER")
        disabled:SetVertexColor(0.4, 0.4, 0.4, 1)
        disabled:SetDesaturated(true)

        local highlight = button.PartyButton:GetHighlightTexture()
        highlight:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-up.png")
        highlight:SetTexCoord(0, 1, 0, 1)
        highlight:SetSize(18, 18)
        highlight:ClearAllPoints()
        highlight:SetPoint("CENTER")
        highlight:SetVertexColor(1, 1, 1, 1)

        button.isSkinned = true
    end

    local data = button.elementData
    if not data then
        return
    end

    local status
    local stateData = data.stateData
    if stateData.isOnline then
        if stateData.isAFK then
            status = "AFK"
        elseif stateData.isDND then
            status = "DND"
        else
            status = "Online"
        end
    else
        status = "Offline"
    end

    if status then
        if GW.friendsList.statusIcons.default[status] then
            button.OnlineStatusIcon:SetTexture(GW.friendsList.statusIcons.square[status])
        end
    end

    local CharacterData = button.CharacterData
    if not CharacterData then
        return
    end
    local characterData = data.characterData

    if CharacterData.Name then
        for _, key in pairs({ "NameDivider", "Level", "LevelDivider", "Class" }) do
            if CharacterData[key] then
                CharacterData[key]:Hide()
            end
        end

        local classFile = characterData and characterData.classID and select(2, GetClassInfo(characterData.classID))
        local nameString
        if stateData.isOnline and characterData.name then
            local classcolor = GW.GWGetClassColor(classFile, true, true, true)
            nameString = WrapTextInColorCode(characterData.name, classcolor.colorStr)
        else
            nameString = format("|cff%s%s|r", "979fad", characterData.name)
        end

        local level = characterData.level
        if level then
            if stateData.isOnline then
                nameString = nameString .. GW.StringWithRGB(delimiter .. level, GetQuestDifficultyColor(level))
            else
                nameString = nameString .. delimiter ..  format("|cff%s%s|r", "979fad", level)
            end
        end

        if nameString then
            CharacterData.Name:SetText(nameString)
        end

        CharacterData.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        CharacterData.Name.maxWidth = button:GetWidth() - 60
        CharacterData.Name:SetWidth(CharacterData.Name.maxWidth)
    end

    if CharacterData.MostRecentInteraction then
        CharacterData.MostRecentInteraction:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    end

    if CharacterData.Location then
        if stateData.currentLocation then
            local realmName = characterData.realmName or ""

            local locationText
            if stateData.currentLocation and stateData.currentLocation ~= "" and realmName and realmName ~= "" and realmName ~= GW.myrealm then
                locationText = stateData.currentLocation .. " - " .. realmName
            elseif stateData.currentLocation and stateData.currentLocation ~= "" then
                locationText = stateData.currentLocation
            else
                locationText = realmName or ""
            end

            if not stateData.isOnline then
                locationText = GW.StringWithRGB(characterData.name, {r = 0.49, g = 0.52, b = 0.54})
            else
                locationText = GW.StringWithRGB(locationText, {r = 0.49, g = 0.52, b = 0.54})
            end

            CharacterData.Location:SetText(locationText)
        end

        CharacterData.Location:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    end
end

function GW.SkinRecentAlliesList()
    if not GW.Retail then return end

    hooksecurefunc(RecentAlliesFrame.List.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
    GW.HandleTrimScrollBar(RecentAlliesFrame.List.ScrollBar, true)
    GW.HandleScrollControls(RecentAlliesFrame.List)
    hooksecurefunc(RecentAlliesFrame.List.ScrollBox, "Update", function(scrollBox)
        scrollBox:ForEachFrame(ReskinRecentAllyButton)
    end)
end

