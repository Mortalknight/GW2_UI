---@class GW2
local GW = select(2, ...)

local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
local WOW_PROJECT_CLASSIC = 2
local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE
local WOW_PROJECT_WRATH_CLASSIC = 11
local WOW_PROJECT_CATACLYSM_CLASSIC = 14
local WOW_PROJECT_MISTS_CLASSIC = 19

local MediaPath = "Interface/AddOns/GW2_UI/Textures/social/"

GW.friendsList = {}
GW.friendsList.delimiter = format("|cff%s | |r", "979fad")
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

-- Collapsible list headers (SocialUIScrollableHeaderTemplate) in the currency frame look:
-- pill texture removed, GW backdrop + separator, arrow instead of plus/minus
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

local function HandleActionButton(button)
    if not button or button.IsSkinned then return end

    button:GwCreateBackdrop(GW.BackdropTemplates.Default, true)

    if button.NormalTexture then button.NormalTexture:SetAlpha(0) end
    if button.PushedTexture then button.PushedTexture:SetAlpha(0) end
    if button.HighlightTexture then
        button.HighlightTexture:SetColorTexture(1, 1, 1, 0.25)
        button.HighlightTexture:SetAllPoints()
    end

    button.IsSkinned = true
end

local function HandleSocialCard(card)
    if not card or card.gwSkinned then return end
    card.gwSkinned = true

    card:GwStripTextures()

    if card.CollapseButton then
        hooksecurefunc(card.CollapseButton, "UpdateCollapsedState", UpdateHeaderCollapseIcon)
        UpdateHeaderCollapseIcon(card.CollapseButton)
    end

    if card.ButtonText then
        card.gwBackground = card:CreateTexture(nil, "BACKGROUND")
        card.gwBackground:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
        card.gwBackground:SetAllPoints(card)

        card.ButtonText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        card.ButtonText:GwLockTextColor(1, 1, 1)
        return
    end

    if not card.Background and not card.PartyButton and not card.AcceptButton then
        return
    end

    if card.Background then
        card.Background:SetAlpha(0)
    end

    if card.SetSelected then
        hooksecurefunc(card, "SetSelected", function(c, selected)
            if c.gwSelected then
                c.gwSelected:SetShown(selected)
            end
        end)
    end

    if card.Selected then
        -- color is owned by the hover kit (HandleItemListScrollBoxHover recolors
        -- Selected on every scroll update) — only pull the texture inside the card
        card.Selected:GwSetInside(card, 2, 2)
    end

    HandleActionButton(card.PartyButton)
    HandleActionButton(card.RAFSummonButton)

    if card.AcceptButton then
        card.AcceptButton:GwSkinButton(false, true)
    end

    if card.DeclineButton then
        card.DeclineButton:GwSkinButton(false, true)
        card.DeclineButton:GwSkinNegativeButton()
    end
end

local function HandleInitializedCard(card)
    HandleSocialCard(card)

    -- Blizzards InitializeBackground writes its card atlas on every element
    -- assignment — straight onto the background texture the GW hover kit
    -- (AddListItemChildHoverTexture) swapped in; reset it to the GW zebra texture
    if card.IsSkinned and card.Background and not card.ButtonText then
        card.Background:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
    end
end

-- Shared base structure of all SocialUI tabs (SocialUIContactsFrameTemplate):
-- FilterBar (SearchBar + filter dropdown), ScrollBox/ScrollBar and ActionButton
-- cardContentHandler (optional): runs per card after every element initialization —
-- used by the list specific content passes (friends, recent allies) that rebuild
-- the Blizzard texts in the GW look
local function SkinSocialContactsView(view, cardContentHandler)
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
        view.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnInitializedFrame, function(_, card)
            HandleInitializedCard(card)
            if cardContentHandler and card.elementData then
                cardContentHandler(card)
            end
        end, view)
        view.ScrollBox:ForEachFrame(function(card)
            HandleInitializedCard(card)
            if cardContentHandler and card.elementData then
                cardContentHandler(card)
            end
        end)

        view.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnUpdate, function()
            GW.HandleItemListScrollBoxHover(view.ScrollBox)
        end, view)
        GW.HandleItemListScrollBoxHover(view.ScrollBox)
    end
end
GW.SkinSocialContactsView = SkinSocialContactsView

-- Content pass for the friends list cards (FriendsListSocialCardTemplate): Blizzard
-- bakes its colors into the display strings on EVERY refresh (WrapTextInColorCode in
-- FriendsListUtil), so this has to run after each ScrollBox update and rebuild the
-- texts and icons in the GW look. All data sits on card.elementData.accountInfo
-- (same shape as C_BattleNet.GetFriendAccountInfo).
local function UpdateFriendCardContent(card)
    local accountInfo = card.elementData and card.elementData.accountInfo
    if not accountInfo then return end
    -- invite cards use a different sub-template without the content regions but may
    -- still carry accountInfo — only restyle full friend cards
    if not card.PresenceHolder or not card.Name then return end
    local gameAccountInfo = accountInfo.gameAccountInfo or {}

    if not card.gwContentSkinned then
        card.gwContentSkinned = true
        card.Level:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -1)
        card.Class:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -1)
        card.Location:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, nil, -1)
    end

    -- status: GW square icons instead of the atlas dots
    local status
    if gameAccountInfo.isOnline then
        if accountInfo.isAFK or gameAccountInfo.isGameAFK then
            status = "AFK"
        elseif accountInfo.isDND or gameAccountInfo.isGameBusy then
            status = "DND"
        else
            status = "Online"
        end
    else
        status = "Offline"
    end
    card.PresenceHolder.PresenceIcon:SetTexture(GW.friendsList.statusIcons.square[status])
    card.PresenceHolder.PresenceIcon:SetTexCoord(0, 1, 0, 1)

    -- account name in the color of the game the friend is playing

    local gameName = gameAccountInfo.clientProgram and GW.friendsList.projectCodes[strupper(gameAccountInfo.clientProgram)]
    local clientColor = gameName and GW.friendsList.clientData[gameName] and GW.friendsList.clientData[gameName].color
    local accountName = accountInfo.accountName
    if accountName and accountName ~= "" and clientColor and gameAccountInfo.isOnline then
        card.FriendName:SetText(GW.StringWithRGB(accountName, clientColor))
    end

    if gameAccountInfo.characterName and gameAccountInfo.characterName ~= "" then
        local isOnline = gameAccountInfo.isOnline
        local classToken = gameAccountInfo.classFilename
        if not classToken or classToken == "" then
            classToken = GW.UnlocalizedClassName(gameAccountInfo.className)
        end
        local classColor = isOnline and classToken and GW.GWGetClassColor(classToken, true, true) or DARKGRAY_COLOR

        local nameString = GW.StringWithRGB(gameAccountInfo.characterName, classColor)
        if TimerunningUtil and gameAccountInfo.timerunningSeasonID and gameAccountInfo.timerunningSeasonID ~= 0 and gameAccountInfo.timerunningSeasonID ~= "" then
            nameString = TimerunningUtil.AddSmallIcon(nameString) or nameString
        end
        card.Name:SetText(nameString)

        if gameAccountInfo.characterLevel and gameAccountInfo.characterLevel > 0 then
            local levelColor = isOnline and GetQuestDifficultyColor(gameAccountInfo.characterLevel) or DARKGRAY_COLOR
            card.Level:SetText(GW.friendsList.delimiter .. GW.StringWithRGB(tostring(gameAccountInfo.characterLevel), levelColor))
        end
        if gameAccountInfo.className and gameAccountInfo.className ~= "" then
            card.Class:SetText(GW.friendsList.delimiter .. GW.StringWithRGB(gameAccountInfo.className, classColor))
        end

        card.Level:ClearAllPoints()
        card.Level:SetPoint("BOTTOMLEFT", card.Name, "BOTTOMRIGHT", 2, 0)
        card.Class:ClearAllPoints()
        card.Class:SetPoint("BOTTOMLEFT", card.Level, "BOTTOMRIGHT", 2, 0)
        card.Class:SetPoint("RIGHT", card.TextHolder, "RIGHT")
    end

    if gameAccountInfo.isOnline then
        -- strip hex color codes AND the newer named-color tags ("|cnCOLOR_NAME:")
        local plain = gsub(gsub(gsub(card.Location:GetText() or "", "|c%x%x%x%x%x%x%x%x", ""), "|cn[^:]+:", ""), "|r", "")
        card.Location:SetText(GW.StringWithRGB(plain, { r = 1, g = 1, b = 1 }))
    end

    local iconHolder = card.GameIconHolder
    if iconHolder and iconHolder:IsShown() and iconHolder.Icon then
        local texture
        local wowID = gameAccountInfo.wowProjectID
        if gameName == "World of Warcraft" and wowID then
            if GW.friendsList.expansionData[wowID] then
                texture = GW.friendsList.expansionData[wowID].icon
            end
            if wowID == WOW_PROJECT_MAINLINE and gameAccountInfo.timerunningSeasonID and GW.friendsList.timerunningSeasonIcon[gameAccountInfo.timerunningSeasonID] then
                texture = GW.friendsList.timerunningSeasonIcon[gameAccountInfo.timerunningSeasonID]
            end
            if not texture and gameAccountInfo.factionName and GW.friendsList.factionIcons[gameAccountInfo.factionName] then
                texture = GW.friendsList.factionIcons[gameAccountInfo.factionName]
            end
        end

        if texture then
            iconHolder.Icon:SetTexture(texture)
            iconHolder.Icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
            iconHolder.Icon:SetAlpha(1)
        else
            iconHolder.Icon:SetTexCoord(0, 1, 0, 1)
        end
    end
end

function GW.SkinFriendList()
    local FriendsList = SocialUIFrame.FriendsList
    local BattleNetBar = SocialUIFrame.BattleNetBar
    local BNetBar = BattleNetBar.ControlsContainer

    BNetBar.BattleNetBackground:SetAlpha(0)
    BattleNetBar.Background:SetAlpha(0)

    BattleNetBar:ClearAllPoints()
    BattleNetBar:SetPoint("TOPLEFT", SocialUIFrame.gwHeader, "BOTTOMLEFT", 0, 0)
    BattleNetBar:SetPoint("TOPRIGHT", SocialUIFrame.gwHeader, "BOTTOMRIGHT", 0, 0)

    BNetBar.OnlineStatusDropdown:GwHandleDropDownBox()
    BNetBar.OnlineStatusDropdown:SetSize(55, 24)
    BNetBar.OnlineStatusDropdown:ClearAllPoints()
    BNetBar.OnlineStatusDropdown:SetPoint("LEFT", BNetBar, "LEFT", 10, 0)
    BNetBar.OnlineStatusDropdown.Background:SetAlpha(0)

    -- small square icon button on the right, the menu icon is kept
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

    SkinSocialContactsView(FriendsList, UpdateFriendCardContent)

    --View Friends BN Frame
    local button = CreateFrame("Button", nil, BNetBar.PersonalBattleTagDisplay, "GwStandardButton")
    button:SetAllPoints()
    button:GwCreateBackdrop(nil, true)
    button:GetNormalTexture():SetVertexColor(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, 0.5)

    button.hover.r = FRIENDS_BNET_BACKGROUND_COLOR.r
    button.hover.g = FRIENDS_BNET_BACKGROUND_COLOR.g
    button.hover.b = FRIENDS_BNET_BACKGROUND_COLOR.b

    button:SetScript("OnClick", function() BNetBar.BattleNetMenuButton:SocialUIRequestToggleSideWindow(SocialUISideWindowType.BattleNetBroadcastFrame) end)

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
