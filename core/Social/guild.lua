local _, GW = ...

local Headers = {
    "GuildFrameColumnHeader1",
    "GuildFrameColumnHeader2",
    "GuildFrameColumnHeader3",
    "GuildFrameColumnHeader4",
    "GuildFrameGuildStatusColumnHeader1",
    "GuildFrameGuildStatusColumnHeader2",
    "GuildFrameGuildStatusColumnHeader3",
    "GuildFrameGuildStatusColumnHeader4",
}

local function LoadGuildList(tabContainer)
    local guildFrame = CreateFrame("Frame", "GwGuildFrame", tabContainer, "GwGuildFrameTemplate")
    guildFrame.Container = tabContainer

    GUILDMEMBERS_TO_DISPLAY = 22

    for i = 14, GUILDMEMBERS_TO_DISPLAY do
        local button = CreateFrame("Button", "GuildFrameButton" .. i, GuildPlayerStatusFrame, "FriendsFrameGuildPlayerStatusButtonTemplate", i)
        button:SetPoint("TOPLEFT", _G["GuildFrameButton" .. i -1], "BOTTOMLEFT", 0, 0)

        button = CreateFrame("Button", "GuildFrameGuildStatusButton" .. i, GuildStatusFrame, "FriendsFrameGuildStatusButtonTemplate", i)
        button:SetPoint("TOPLEFT", _G["GuildFrameButton" .. i -1], "BOTTOMLEFT", 0, 0)
    end

    for i = 1, GUILDMEMBERS_TO_DISPLAY do
        _G["GuildFrameButton" .. i]:SetWidth(420)
        _G["GuildFrameButton" .. i .. "Name"]:SetWidth(130)
        _G["GuildFrameButton" .. i .. "Zone"]:SetWidth(130)

        _G["GuildFrameGuildStatusButton" .. i]:SetWidth(420)
        _G["GuildFrameGuildStatusButton" .. i .. "Name"]:SetWidth(130)
        _G["GuildFrameGuildStatusButton" .. i .. "Note"]:SetWidth(130)

        _G["GuildFrameGuildStatusButton" .. i]:GetHighlightTexture():SetTexture("")
        GW.AddListItemChildHoverTexture(_G["GuildFrameGuildStatusButton" .. i])

        _G["GuildFrameButton" .. i]:GetHighlightTexture():SetTexture("")
        GW.AddListItemChildHoverTexture(_G["GuildFrameButton" .. i])

        _G["GuildFrameButton" .. i]:SetScript("OnClick", FriendsFrameGuildStatusButton_OnClick)
        _G["GuildFrameGuildStatusButton" .. i]:SetScript("OnClick", FriendsFrameGuildStatusButton_OnClick)
    end

    GuildFrameColumnHeader1:SetWidth(130)
    GuildFrameColumnHeader2:SetWidth(130)
    GuildFrameGuildStatusColumnHeader1:SetWidth(145)
    GuildFrameGuildStatusColumnHeader3:SetWidth(130)

    guildFrame:SetScript("OnShow", function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        GuildFrame:Show()
        GuildStatus_Update()
    end)

    GuildFrame:SetParent(guildFrame)
    GuildFrame:ClearAllPoints()
    GuildFrame:SetAllPoints(guildFrame)
    GuildFrame.SetParent = GW.NoOp
    GuildFrame.ClearAllPoints = GW.NoOp
    GuildFrame.SetAllPoints = GW.NoOp
    GuildFrame.SetPoint = GW.NoOp

	GW.HandleNextPrevButton(GuildFrameGuildListToggleButton, "right")
    GuildFrameAddMemberButton:GwSkinButton(false, true)
    GuildFrameGuildInformationButton:GwSkinButton(false, true)
    GuildFrameControlButton:GwSkinButton(false, true)
    GuildFrameNotesText:SetWidth(450)
    GuildMOTDEditButton:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

    GuildFrame:GwStripTextures()
    GuildListScrollFrame:GwStripTextures()
    GuildListScrollFrameScrollBar:GwSkinScrollBar()
    GuildListScrollFrame:GwSkinScrollFrame()
    GuildListScrollFrame.ScrollChildFrame:SetWidth(420)

    GuildListScrollFrame:SetPoint("TOPLEFT", GuildFrame, "TOPLEFT", 10, -50)
    GuildListScrollFrame:SetSize(450, 400)

    GuildFrameNotesLabel:SetPoint("TOPLEFT", GuildListScrollFrame, "BOTTOMLEFT", 0, -10)
    GuildFrameTotals:SetPoint("TOPLEFT", GuildMOTDEditButton, "BOTTOMLEFT", 0, -10)
    GuildFrameGuildListToggleButton:SetPoint("LEFT", GuildFrameTotals, "RIGHT", 335, 0)
    GuildFrameGuildListToggleButton.SetPoint = GW.NoOp

    GuildFrameNotesLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    GuildFrameNotesLabel:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

    GuildFrameTotals:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    GuildFrameOnlineTotals:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    GuildFrameNotesLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    GuildFrameNotesText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)

    GuildFrameLFGFrame:GwStripTextures()
    GuildFrameLFGButton:GwSkinCheckButton()
    GuildFrameLFGButton:SetSize(15, 15)

    GuildControlPopupFrame:SetPoint("TOPLEFT", guildFrame, "TOPRIGHT", 40, 6)
    GuildInfoFrame:SetPoint("TOPLEFT", guildFrame, "TOPRIGHT", 40, 6)
    GuildMemberDetailFrame:SetPoint("TOPLEFT", guildFrame, "TOPRIGHT", 40, 6)

	GuildControlPopupFrame:SetParent(guildFrame)
	GuildInfoFrame:SetParent(guildFrame)
	GuildMemberDetailFrame:SetParent(guildFrame)
	GuildEventLogFrame:SetParent(guildFrame)

    for _, object in pairs(Headers) do
        local frame = _G[object]
        frame:GwStripTextures()
        local r = {frame:GetRegions()}
        for _,c in pairs(r) do
            if c:GetObjectType() == "FontString" then
                c:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            end
        end
    end

    for _, object in pairs(Headers) do
        GW.HandleScrollFrameHeaderButton(_G[object])
    end
end
GW.LoadGuildList = LoadGuildList
