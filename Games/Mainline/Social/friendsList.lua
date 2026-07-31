---@class GW2
local GW = select(2, ...)

local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
local WOW_PROJECT_CLASSIC = 2
local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE
local WOW_PROJECT_WRATH_CLASSIC = 11
local WOW_PROJECT_CATACLYSM_CLASSIC = 14
local WOW_PROJECT_MISTS_CLASSIC = 19

local MediaPath = "Interface/AddOns/GW2_UI/Textures/social/"
local delimiter = format("|cff%s | |r", "979fad")

GW.friendsList = {}
GW.friendsList.projectCodes = {
    ["ANBS"] = "Diablo Immortal",
    ["Hero"] = "Heroes of the Storm",
    ["OSI"] = "Diablo II",
    ["S2"] = "StarCraft II",
    ["VIPR"] = "Call of Duty: Black Ops 4",
    ["W3"] = "WarCraft III",
    ["APP"] = "Battle.net App",
    ["FORE"] = "Call of Duty: Vanguard",
    ["LAZR"] = "Call of Duty: MW2 Campaign Remastered",
    ["RTRO"] = "Blizzard Arcade Collection",
    ["WLBY"] = "Crash Bandicoot 4: It's About Time",
    ["WTCG"] = "Hearthstone",
    ["ZEUS"] = "Call of Duty: Blac Ops Cold War",
    ["D3"] = "Diablo III",
    ["GRY"] = "Warcraft Arclight Rumble",
    ["ODIN"] = "Call of Duty: Mordern Warfare II",
    ["S1"] = "StarCraft",
    ["WOW"] = "World of Warcraft",
    ["PRO"] = "Overwatch",
    ["PRO-ZHCN"] = "Overwatch",
}

GW.friendsList.clientData = {
    ["Diablo Immortal"] = {
        color = { r = 0.768, g = 0.121, b = 0.231 },
    },
    ["Heroes of the Storm"] = {
        color = { r = 0, g = 0.8, b = 1 },
    },
    ["Diablo II"] = {
        color = { r = 0.768, g = 0.121, b = 0.231 },
    },
    ["StarCraft II"] = {
        color = { r = 0.749, g = 0.501, b = 0.878 },
    },
    ["Call of Duty: Black Ops 4"] = {
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["WarCraft III"] = {
        color = { r = 0.796, g = 0.247, b = 0.145 },
    },
    ["Battle.net App"] = {
        color = { r = 0.509, g = 0.772, b = 1 },
    },
    ["Call of Duty: Vanguard"] = {
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["Call of Duty: MW2 Campaign Remastered"] = {
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["Blizzard Arcade Collection"] = {
        color = { r = 0.509, g = 0.772, b = 1 },
    },
    ["Crash Bandicoot 4: It's About Time"] = {
        color = { r = 0.509, g = 0.772, b = 1 },
    },
    ["Hearthstone"] = {
        color = { r = 1, g = 0.694, b = 0 },
    },
    ["Call of Duty: Blac Ops Cold War"] = {
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["Diablo III"] = {
        color = { r = 0.768, g = 0.121, b = 0.231 },
    },
    ["Warcraft Arclight Rumble"] = {
        color = { r = 0.945, g = 0.757, b = 0.149 },
    },
    ["Call of Duty: Mordern Warfare II"] = {
        color = { r = 0, g = 0.8, b = 0 },
    },
    ["StarCraft"] = {
        color = { r = 0.749, g = 0.501, b = 0.878 },
    },
    ["World of Warcraft"] = {
        color = { r = 0.866, g = 0.690, b = 0.180 },
    },
    ["Overwatch"] = {
        color = { r = 1, g = 1, b = 1 },
    },
}

GW.friendsList.timerunningSeasonIcon = {
    [2] = MediaPath .. "GameIcons/WOW_LEG",
}

GW.friendsList.expansionData = {
    [WOW_PROJECT_MAINLINE] = {
        name = "Retail",
        suffix = nil,
        maxLevel = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion() or GetMaxPlayerLevel()),
        icon = MediaPath .. "GameIcons/WOW_Retail",
    },
    [WOW_PROJECT_CLASSIC] = {
        name = "Classic",
        suffix = "Classic",
        maxLevel = 60,
        icon = MediaPath .. "GameIcons/WOW_Classic",
    },
    [WOW_PROJECT_BURNING_CRUSADE_CLASSIC] = {
        name = "TBC",
        suffix = "TBC",
        maxLevel = 70,
        icon = MediaPath .. "GameIcons/WOW_TBC",
    },
    [WOW_PROJECT_WRATH_CLASSIC] = {
        name = "WotLK",
        suffix = "WotLK",
        maxLevel = 80,
        icon = MediaPath .. "GameIcons/WOW_WotLK",
    },
    [WOW_PROJECT_CATACLYSM_CLASSIC] = {
        name = "Cata",
        suffix = "Cata",
        maxLevel = 85,
        icon = MediaPath .. "GameIcons/WOW_Cata",
    },
    [WOW_PROJECT_MISTS_CLASSIC] = {
        name = "MoP",
        suffix = "MoP",
        maxLevel = 90,
        icon = MediaPath .. "GameIcons/WOW_MoP",
    },
}

GW.friendsList.factionIcons = {
    ["Alliance"] = MediaPath .. "GameIcons/Alliance",
    ["Horde"] = MediaPath .. "GameIcons/Horde",
}

GW.friendsList.statusIcons = {
    default = {
        Online = FRIENDS_TEXTURE_ONLINE,
        Offline = FRIENDS_TEXTURE_OFFLINE,
        DND = FRIENDS_TEXTURE_DND,
        AFK = FRIENDS_TEXTURE_AFK,
    },
    square = {
        Online = MediaPath .. "StatusIcons/Square/Online",
        Offline = MediaPath .. "StatusIcons/Square/Offline",
        DND = MediaPath .. "StatusIcons/Square/DND",
        AFK = MediaPath .. "StatusIcons/Square/AFK",
    },
    color = {
        Online  = { Color = {0.243, 0.57, 1} },
        Offline = { Color = {0.486, 0.518, 0.541} },
        DND     = { Color = {1, 0, 0} },
        AFK     = { Color = {1, 1, 0} },
    },
}

local function HandleInviteTexNormal(self)
    self:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-down.png")
    self:SetTexCoord(0, 1, 0, 1)
    self:SetSize(16, 16)
    self:ClearAllPoints()
    self:SetPoint("CENTER")
    self:SetVertexColor(1, 1, 1, 1)
end

local function HandleInviteTexDisabled(self)
    self:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-down.png")
    self:SetTexCoord(0, 1, 0, 1)
    self:SetSize(18, 18)
    self:ClearAllPoints()
    self:SetPoint("CENTER")
    self:SetVertexColor(0.4, 0.4, 0.4, 1)
    self:SetDesaturated(true)
end

-- Einklappbare Listen-Header (SocialUIScrollableHeaderTemplate) im Currency-Frame-Look:
-- Pill-Textur weg, GW-Backdrop + Trenner, Pfeil statt Plus/Minus
local function UpdateHeaderCollapseIcon(collapseButton)
    collapseButton.Icon:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
    collapseButton.Icon:SetSize(16, 16)
    collapseButton.Icon:SetRotation(collapseButton.collapsed and 1.570796325 or 0)

    local highlight = collapseButton:GetHighlightTexture()
    if highlight then
        highlight:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        highlight:SetRotation(collapseButton.collapsed and 1.570796325 or 0)
    end
end

local function ReskinListHeader(header)
    if header.gwSkinned then return end
    header.gwSkinned = true

    -- der PTR-Client hat hier zusätzlich eine Background-Textur (Pill) — alles wegstrippen
    header:GwStripTextures()
    header:SetNormalTexture("")
    header:SetHighlightTexture("")

    header.gwBackground = header:CreateTexture(nil, "BACKGROUND")
    header.gwBackground:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
    header.gwBackground:SetAllPoints(header)

    header.ButtonText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    header.ButtonText:GwLockTextColor(1, 1, 1)

    if header.CollapseButton then
        hooksecurefunc(header.CollapseButton, "UpdateCollapsedState", UpdateHeaderCollapseIcon)
        UpdateHeaderCollapseIcon(header.CollapseButton)
    end
end

local function ReskinListHeaders(scrollBox)
    scrollBox:ForEachFrame(function(child)
        if child.CollapseButton and child.ButtonText then
            ReskinListHeader(child)
        end
    end)
end

-- Gemeinsames Grundgerüst aller SocialUI-Tabs (SocialUIContactsFrameTemplate):
-- FilterBar (SearchBar + Filterdropdown), ScrollBox/ScrollBar und ActionButton
local function SkinSocialContactsView(view)
    if not view or view.gwContactsViewSkinned then return end
    view.gwContactsViewSkinned = true

    local FilterBar = view.FilterBar
    if FilterBar then
        if FilterBar.SearchBar then
            FilterBar.SearchBar.Background:SetAlpha(0)
            GW.SkinTextBox(nil, nil, nil, nil, nil, 0, 0, nil, FilterBar.SearchBar)
        end
        if FilterBar.SearchFilterDropdown then
            FilterBar.SearchFilterDropdown.OnButtonStateChanged = GW.NoOp
            FilterBar.SearchFilterDropdown:GwHandleDropDownBox()
        end
    end

    if view.ActionButton then
        view.ActionButton:GwSkinButton(false, true)
    end

    if view.ScrollBar then
        GW.HandleTrimScrollBar(view.ScrollBar)
        GW.HandleScrollControls(view)
    end
    if view.ScrollBox then
        hooksecurefunc(view.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)
        hooksecurefunc(view.ScrollBox, "Update", ReskinListHeaders)
    end
end
GW.SkinSocialContactsView = SkinSocialContactsView

local function UpdateFriendButton(button)
    if not button.isSkinned then
        local normal = button.travelPassButton:GetNormalTexture()
        normal:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-down.png")
        normal:SetTexCoord(0, 1, 0, 1)
        normal:SetSize(18, 18)
        normal:ClearAllPoints()
        normal:SetPoint("CENTER")
        normal:SetVertexColor(1, 1, 1, 1)

        local disabled = button.travelPassButton:GetDisabledTexture()
        disabled:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-down.png")
        disabled:SetTexCoord(0, 1, 0, 1)
        disabled:SetSize(18, 18)
        disabled:ClearAllPoints()
        disabled:SetPoint("CENTER")
        disabled:SetVertexColor(0.4, 0.4, 0.4, 1)
        disabled:SetDesaturated(true)

        local highlight = button.travelPassButton:GetHighlightTexture()
        highlight:SetTexture("Interface/AddOns/GW2_UI/textures/icons/lfdmicrobutton-up.png")
        highlight:SetTexCoord(0, 1, 0, 1)
        highlight:SetSize(18, 18)
        highlight:ClearAllPoints()
        highlight:SetPoint("CENTER")
        highlight:SetVertexColor(1, 1, 1, 1)

        if GW.Retail then
            hooksecurefunc(button.travelPassButton.NormalTexture, "SetAtlas", HandleInviteTexNormal)
            hooksecurefunc(button.travelPassButton.DisabledTexture, "SetAtlas", HandleInviteTexDisabled)
        end

        button.isSkinned = true
    end


    if button.buttonType == FRIENDS_BUTTON_TYPE_DIVIDER then
        return
    end

    local gameName, realID, name, server, class, area, level, faction, status, wowID, timerunningSeasonID

    if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        -- WoW friends
        wowID = WOW_PROJECT_MAINLINE
        gameName = GW.friendsList.projectCodes["WOW"]
        local friendInfo = C_FriendList.GetFriendInfoByIndex(button.id)
        name, server = strsplit("-", friendInfo.name)
        level = friendInfo.level
        class = friendInfo.className
        area = friendInfo.area
        faction = GW.myfaction

        if friendInfo.connected then
            if friendInfo.afk then
                status = "AFK"
            elseif friendInfo.dnd then
                status = "DND"
            else
                status = "Online"
            end
        else
            status = "Offline"
        end
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET and BNConnected() then
        -- Battle.net friends
        local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
        if friendAccountInfo then
            realID = friendAccountInfo.accountName

            local gameAccountInfo = friendAccountInfo.gameAccountInfo
            gameName = GW.friendsList.projectCodes[strupper(gameAccountInfo.clientProgram)]

            if gameAccountInfo.isOnline then
                if friendAccountInfo.isAFK or gameAccountInfo.isGameAFK then
                    status = "AFK"
                elseif friendAccountInfo.isDND or gameAccountInfo.isGameBusy then
                    status = "DND"
                else
                    status = "Online"
                end
            else
                status = "Offline"
            end

            -- Fetch version if friend playing WoW
            if gameName == "World of Warcraft" then
                wowID = gameAccountInfo.wowProjectID
                name = gameAccountInfo.characterName or ""
                level = gameAccountInfo.characterLevel or 0
                faction = gameAccountInfo.factionName or nil
                class = gameAccountInfo.className or ""
                area = gameAccountInfo.areaName or ""
                timerunningSeasonID = gameAccountInfo.timerunningSeasonID or ""

                if wowID and wowID ~= 1 and GW.friendsList.expansionData[wowID] then
                    local suffix = GW.friendsList.expansionData[wowID].suffix and " (" .. GW.friendsList.expansionData[wowID].suffix .. ")" or ""
                    local serverStrings = { strsplit(" - ", gameAccountInfo.richPresence) }
                    server = (serverStrings[#serverStrings] or BNET_FRIEND_TOOLTIP_WOW_CLASSIC) .. suffix .. "*"
                elseif wowID and wowID == 1 and name == "" then
                    server = gameAccountInfo.richPresence -- Plunderstorm
                else
                    server = gameAccountInfo.realmDisplayName or ""
                end
            end
        end
    end

    if status then
        button.status:SetTexture(GW.friendsList.statusIcons.square[status])
    end

    button.gameIcon:SetTexCoord(0, 1, 0, 1)

    if gameName then
        local buttonTitle, buttonText

        -- real ID
        local clientColor = GW.friendsList.clientData[gameName] and GW.friendsList.clientData[gameName].color
        local realIDString = realID and clientColor and GW.StringWithRGB(realID, clientColor) or realID

        -- name
        local classColor = GW.GWGetClassColor(GW.UnlocalizedClassName(class), true, true, true)
        local nameString = name and classColor and GW.StringWithRGB(name, classColor) or name
        if TimerunningUtil and timerunningSeasonID and timerunningSeasonID ~= "" and nameString ~= nil then
            nameString = TimerunningUtil.AddSmallIcon(nameString) or nameString -- add timerunning tag
        end

        if wowID and GW.friendsList.expansionData[wowID] and level and level ~= 0 then
            nameString = nameString .. GW.StringWithRGB(delimiter .. level, GetQuestDifficultyColor(level))
        end

        -- combine Real ID and Name
        if nameString and nameString ~= "" and realIDString and realIDString ~= "" then
            buttonTitle = realIDString .. delimiter .. nameString
        elseif nameString and nameString ~= "" then
            buttonTitle = nameString
        else
            buttonTitle = realIDString or ""
        end

        button.name:SetText(buttonTitle)

        -- area
        if area then
            if area ~= "" and server and server ~= "" and server ~= GW.myrealm then
                buttonText = GW.StringWithRGB(area .. " - " .. server, {r = 1, g = 1, b = 1})
            elseif area ~= "" then
                buttonText = GW.StringWithRGB(area, {r = 1, g = 1, b = 1})
            else
                buttonText = server or ""
            end

            button.info:SetText(buttonText)
        end

        -- game icon
        local texOrAtlas
        if wowID and GW.friendsList.expansionData[wowID] then
            texOrAtlas = GW.friendsList.expansionData[wowID].icon
            if wowID == WOW_PROJECT_MAINLINE and timerunningSeasonID and GW.friendsList.timerunningSeasonIcon[timerunningSeasonID] then
                texOrAtlas = GW.friendsList.timerunningSeasonIcon[timerunningSeasonID]
            end
        end

        if texOrAtlas == nil and faction and GW.friendsList.factionIcons[faction] then
            texOrAtlas = GW.friendsList.factionIcons[faction]
        end

        if texOrAtlas then
            button.gameIcon:SetAlpha(1)
            button.gameIcon:SetTexture(texOrAtlas)
            button.gameIcon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
        end
    end

    button.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    button.info:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -1)

    if button.Favorite and button.Favorite:IsShown() then
        button.Favorite:ClearAllPoints()
        button.Favorite:SetPoint("LEFT", button.name, "LEFT", button.name:GetStringWidth(), 0)
    end

    button:SetSize(460, 34)
    button.name:SetWidth(400)
end


function GW.SkinFriendList()
    local FriendsList = SocialUIFrame.FriendsList
    local BattleNetBar = SocialUIFrame.BattleNetBar
    local BNetBar = BattleNetBar.ControlsContainer

    BNetBar.BattleNetBackground:SetAlpha(0)
    BattleNetBar.Background:SetAlpha(0)

    -- Blizzard verankert die BattleNetBar nur zentriert mit fester Breite (413) und hängt alle
    -- Tab-Inhalte an ihre linke Kante — nach unserem Resize auf 500 muss die Bar deshalb die volle
    -- Fensterbreite aufspannen, sonst rutscht der komplette Inhalt nach rechts
    BattleNetBar:ClearAllPoints()
    BattleNetBar:SetPoint("TOPLEFT", SocialUIFrame.gwHeader, "BOTTOMLEFT", 0, 0)
    BattleNetBar:SetPoint("TOPRIGHT", SocialUIFrame.gwHeader, "BOTTOMRIGHT", 0, 0)

    BNetBar.OnlineStatusDropdown:GwHandleDropDownBox()
    BNetBar.OnlineStatusDropdown:SetSize(55, 24)
    BNetBar.OnlineStatusDropdown:ClearAllPoints()
    BNetBar.OnlineStatusDropdown:SetPoint("LEFT", BNetBar, "LEFT", 10, 0)
    BNetBar.OnlineStatusDropdown.Background:SetAlpha(0)

    -- kleiner quadratischer Icon-Button rechts, das Menü-Icon bleibt erhalten
    BNetBar.BattleNetMenuButton:GwSkinButton(false, nil, nil, nil, nil, true)
    BNetBar.BattleNetMenuButton:SetSize(24, 24)
    BNetBar.BattleNetMenuButton:ClearAllPoints()
    BNetBar.BattleNetMenuButton:SetPoint("RIGHT", BNetBar, "RIGHT", -10, 0)
    BNetBar.BattleNetMenuButton:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    BNetBar.BattleNetMenuButton.Icon:SetDesaturated(true)
    BNetBar.BattleNetMenuButton.Icon:SetVertexColor(1, 1, 1)
    BNetBar.BattleNetMenuButton.Icon:SetSize(14, 14)

    BNetBar.PersonalBattleTagDisplay:ClearAllPoints()
    BNetBar.PersonalBattleTagDisplay:SetPoint("LEFT", BNetBar.OnlineStatusDropdown, "RIGHT", 5, 0)
    BNetBar.PersonalBattleTagDisplay:SetPoint("RIGHT", BNetBar.BattleNetMenuButton, "LEFT", -5, 0)
    BNetBar.PersonalBattleTagDisplay:SetHeight(24)

    SkinSocialContactsView(FriendsList)

    hooksecurefunc("FriendsFrame_UpdateFriendButton", UpdateFriendButton)

    --View Friends BN Frame
    local button = CreateFrame("Button", nil, BNetBar.PersonalBattleTagDisplay, "GwStandardButton")
    button:SetAllPoints()
    button:GwCreateBackdrop(nil, true)
    button:GetNormalTexture():SetVertexColor(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, 0.5)

    button.hover.r = FRIENDS_BNET_BACKGROUND_COLOR.r
    button.hover.g = FRIENDS_BNET_BACKGROUND_COLOR.g
    button.hover.b = FRIENDS_BNET_BACKGROUND_COLOR.b

    button:SetScript("OnClick", function() BNetBar.BattleNetMenuButton:SocialUIRequestToggleSideWindow(SocialUISideWindowType.BattleNetBroadcastFrame) end)

    -- Der Overlay-Button liegt als eigenes Frame über dem BattleTag-Text und würde ihn beim
    -- Hovern übermalen — Text auf den Button umhängen, damit er immer obenauf liegt
    BNetBar.PersonalBattleTagDisplay.DisplayText:SetParent(button)
    BNetBar.PersonalBattleTagDisplay.DisplayText:SetDrawLayer("OVERLAY", 7)
    if BNetBar.PersonalBattleTagDisplay.CopyBattleTagToClipboardButton then
        BNetBar.PersonalBattleTagDisplay.CopyBattleTagToClipboardButton:SetFrameLevel(button:GetFrameLevel() + 1)
    end
    if BNetBar.PersonalBattleTagDisplay.BattleNetUnavailableNoticeButton then
        BNetBar.PersonalBattleTagDisplay.BattleNetUnavailableNoticeButton:SetFrameLevel(button:GetFrameLevel() + 1)
    end

    FriendsFriendsFrame.ScrollFrameBorder:Hide()
    FriendsFriendsFrame.SendRequestButton:GwSkinButton(false, true)
    FriendsFriendsFrame.CloseButton:GwSkinButton(false, true)

    local broadcastFrame = SocialUIFrame.BattleNetBroadcastFrame
    broadcastFrame:GwStripTextures()
    broadcastFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    broadcastFrame:ClearAllPoints()
    broadcastFrame:SetPoint("TOPLEFT", SocialUIFrame.gwHeader, "BOTTOMRIGHT", 45, 1)
    broadcastFrame.EditBox:GwStripTextures()
    GW.HandleBlizzardRegions(broadcastFrame.EditBox)
    GW.SkinTextBox(broadcastFrame.EditBox.MiddleBorder, broadcastFrame.EditBox.LeftBorder, broadcastFrame.EditBox.RightBorder, nil, nil, 5, 5)
    broadcastFrame.UpdateButton:GwSkinButton(false, true)
    broadcastFrame.CancelButton:GwSkinButton(false, true)
    broadcastFrame.CancelButton:GwSkinNegativeButton()

    AddFriendFrame:GwStripTextures()
    AddFriendFrame:GwCreateBackdrop(GW.BackdropTemplates.Default)
    AddFriendEntryFrameAcceptButton:GwSkinButton(false, true)
    AddFriendEntryFrameCancelButton:GwSkinNegativeButton(false, true)
    GW.SkinTextBox(_G["AddFriendNameEditBoxMiddle"], _G["AddFriendNameEditBoxLeft"], _G["AddFriendNameEditBoxRight"])
end
