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


-- copy from blizzard and modified to prevent ESC error
local function GuildStatus_Update()
    GwGuildFrame.playersInBotRank = 0
	local totalMembers, onlineMembers = GetNumGuildMembers();
	local numGuildMembers = 0;
	local showOffline = GetGuildRosterShowOffline();
	if (showOffline) then
		numGuildMembers = totalMembers;
	else
		numGuildMembers = onlineMembers;
	end
	local name, isAway;
	local fullName, rank, rankIndex, level, class, zone, note, officernote, online;
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
	local maxRankIndex = GuildControlGetNumRanks() - 1;
	local button;
	local onlinecount = 0;
	local guildIndex;

	-- Get selected guild member info
	fullName, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());
	GuildFrame.selectedName = fullName;
	-- If there's a selected guildmember
	if ( GetGuildRosterSelection() > 0 ) then
		local displayedName = Ambiguate(fullName, "guild");
		-- Update the guild member details frame
		GuildMemberDetailName:SetText(displayedName);
		GuildMemberDetailLevel:SetText(format(FRIENDS_LEVEL_TEMPLATE, level, class));
		GuildMemberDetailZoneText:SetText(zone);
		GuildMemberDetailRankText:SetText(rank);
		if ( online ) then
			GuildMemberDetailOnlineText:SetText(GUILD_ONLINE_LABEL);
		else
			GuildMemberDetailOnlineText:SetText(GuildFrame_GetLastOnline(GetGuildRosterSelection()));
		end
		-- Update public note
		if ( CanEditPublicNote() ) then
			PersonalNoteText:SetTextColor(1.0, 1.0, 1.0);
			if ( (not note) or (note == "") ) then
				note = GUILD_NOTE_EDITLABEL;
			end
		else
			PersonalNoteText:SetTextColor(0.65, 0.65, 0.65);
		end
		GuildMemberNoteBackground:EnableMouse(CanEditPublicNote());
		PersonalNoteText:SetText(note);
		-- Update officer note
		if ( C_GuildInfo.CanViewOfficerNote() ) then
			if ( C_GuildInfo.CanEditOfficerNote() ) then
				if ( (not officernote) or (officernote == "") ) then
					officernote = GUILD_OFFICERNOTE_EDITLABEL;
				end
				OfficerNoteText:SetTextColor(1.0, 1.0, 1.0);
			else
				OfficerNoteText:SetTextColor(0.65, 0.65, 0.65);
			end
			GuildMemberOfficerNoteBackground:EnableMouse(C_GuildInfo.CanEditOfficerNote());
			OfficerNoteText:SetText(officernote);

			-- Resize detail frame
			GuildMemberDetailOfficerNoteLabel:Show();
			GuildMemberOfficerNoteBackground:Show();
			GuildMemberDetailFrame:SetHeight(GUILD_DETAIL_OFFICER_HEIGHT);
		else
			GuildMemberDetailOfficerNoteLabel:Hide();
			GuildMemberOfficerNoteBackground:Hide();
			GuildMemberDetailFrame:SetHeight(GUILD_DETAIL_NORM_HEIGHT);
		end

		-- Manage guild member related buttons
		if ( CanGuildPromote() and ( rankIndex > 1 ) and ( rankIndex > (guildRankIndex + 1) ) ) then
			GuildFramePromoteButton:Enable();
		else 
			GuildFramePromoteButton:Disable();
		end
		if ( CanGuildDemote() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) and ( rankIndex ~= maxRankIndex ) ) then
			GuildFrameDemoteButton:Enable();
		else
			GuildFrameDemoteButton:Disable();
		end
		-- Hide promote/demote buttons if both disabled
		if ( not GuildFrameDemoteButton:IsEnabled() and not GuildFramePromoteButton:IsEnabled() ) then
			GuildFramePromoteButton:Hide();
			GuildFrameDemoteButton:Hide();
			GuildMemberDetailRankText:SetPoint("RIGHT", "GuildMemberDetailFrame", "RIGHT", -10, 0);
		else
			GuildFramePromoteButton:Show();
			GuildFrameDemoteButton:Show();
			GuildMemberDetailRankText:SetPoint("RIGHT", "GuildFramePromoteButton", "LEFT", 3, 0);
		end
		if ( CanGuildRemove() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) ) then
			GuildMemberRemoveButton:Enable();
		else
			GuildMemberRemoveButton:Disable();
		end
		if ( (UnitName("player") == displayedName) or (not online) ) then
			GuildMemberGroupInviteButton:Disable();
		else
			GuildMemberGroupInviteButton:Enable();
		end

		GuildFrame.selectedName = GetGuildRosterInfo(GetGuildRosterSelection()); 
	end
	
	-- Message of the day stuff
	local guildMOTD = GetGuildRosterMOTD();
	if ( CanEditMOTD() ) then
		if ( (not guildMOTD) or (guildMOTD == "") ) then
			--guildMOTD = GUILD_MOTD_EDITLABEL; -- A bug in the 1.12 lua code caused this to never actually appear.
		end
		GuildFrameNotesText:SetTextColor(1.0, 1.0, 1.0);
		GuildMOTDEditButton:Enable();
	else
		GuildFrameNotesText:SetTextColor(0.65, 0.65, 0.65);
		GuildMOTDEditButton:Disable();
	end
	GuildFrameNotesText:SetText(guildMOTD);

	-- Scrollbar stuff
	local showScrollBar = nil;
	if ( numGuildMembers > GUILDMEMBERS_TO_DISPLAY ) then
		showScrollBar = 1;
	end

	-- Get number of online members
	for i=1, numGuildMembers, 1 do
		name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(i);
		if ( online ) then
			onlinecount = onlinecount + 1;
		end
		if ( rankIndex == maxRankIndex ) then
			GwGuildFrame.playersInBotRank = GwGuildFrame.playersInBotRank + 1;
		end
	end
	GuildFrameTotals:SetText(format(GetText("GUILD_TOTAL", nil, numGuildMembers), numGuildMembers));
	GuildFrameOnlineTotals:SetText(format(GUILD_TOTALONLINE, onlineMembers));

	-- Update global guild frame buttons
	if ( IsGuildLeader() ) then
		GuildFrameControlButton:Enable();
	else
		GuildFrameControlButton:Disable();
	end
	if ( CanGuildInvite() ) then
		GuildFrameAddMemberButton:Enable();
	else
		GuildFrameAddMemberButton:Disable();
	end

	if ( GwGuildFrame.playerStatusFrame ) then
		-- Player specific info
		local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);

		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i;
			button = getglobal("GuildFrameButton"..i);
			button.guildIndex = guildIndex;

			fullName, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(guildIndex);
			if (fullName and (showOffline or online)) then
				local displayedName = Ambiguate(fullName, "guild");
				getglobal("GuildFrameButton"..i.."Name"):SetText(displayedName);
				getglobal("GuildFrameButton"..i.."Zone"):SetText(zone);
				getglobal("GuildFrameButton"..i.."Level"):SetText(level);
				getglobal("GuildFrameButton"..i.."Class"):SetText(class);
				if ( not online ) then
					getglobal("GuildFrameButton"..i.."Name"):SetTextColor(0.5, 0.5, 0.5);
					getglobal("GuildFrameButton"..i.."Zone"):SetTextColor(0.5, 0.5, 0.5);
					getglobal("GuildFrameButton"..i.."Level"):SetTextColor(0.5, 0.5, 0.5);
					getglobal("GuildFrameButton"..i.."Class"):SetTextColor(0.5, 0.5, 0.5);
				else
					getglobal("GuildFrameButton"..i.."Name"):SetTextColor(1.0, 0.82, 0.0);
					getglobal("GuildFrameButton"..i.."Zone"):SetTextColor(1.0, 1.0, 1.0);
					getglobal("GuildFrameButton"..i.."Level"):SetTextColor(1.0, 1.0, 1.0);
					getglobal("GuildFrameButton"..i.."Class"):SetTextColor(1.0, 1.0, 1.0);
				end
			else
				getglobal("GuildFrameButton"..i.."Name"):SetText(nil);
				getglobal("GuildFrameButton"..i.."Zone"):SetText(nil);
				getglobal("GuildFrameButton"..i.."Level"):SetText(nil);
				getglobal("GuildFrameButton"..i.."Class"):SetText(nil);
			end

			-- If need scrollbar resize columns
			if ( showScrollBar ) then
				getglobal("GuildFrameButton"..i.."Zone"):SetWidth(95);
				getglobal("GuildFrameButton"..i.."Class"):SetWidth(80);
			else
				getglobal("GuildFrameButton"..i.."Zone"):SetWidth(130);
			end

			if ( guildIndex > numGuildMembers ) then
				button:Hide();
			else
				button:Show();
			end
		end

		-- ScrollFrame update
		FauxScrollFrame_Update(GuildListScrollFrame, numGuildMembers, GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT );

		GuildPlayerStatusFrame:Show();
		GuildStatusFrame:Hide();
	else
		-- Guild specific info
		local year, month, day, hour;
		local yearlabel, monthlabel, daylabel, hourlabel;
		local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);

		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			guildIndex = guildOffset + i;
			button = getglobal("GuildFrameGuildStatusButton"..i);
			button.guildIndex = guildIndex;

			fullName, rank, rankIndex, level, class, zone, note, officernote, online, isAway = GetGuildRosterInfo(guildIndex);
			if (fullName and (showOffline or online)) then
				local displayedName = Ambiguate(fullName, "guild");
				getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetText(displayedName);
				getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetText(rank);
				getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetText(note);

				if ( online ) then
					if ( isAway == 2 ) then
						getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(CHAT_FLAG_DND);
					elseif ( isAway == 1 ) then
						getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(CHAT_FLAG_AFK);
					else
						getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(GUILD_ONLINE_LABEL);
					end

					getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetTextColor(1.0, 0.82, 0.0);
					getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetTextColor(1.0, 1.0, 1.0);
					getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetTextColor(1.0, 1.0, 1.0);
					getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetTextColor(1.0, 1.0, 1.0);
				else
					getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(GuildFrame_GetLastOnline(guildIndex));
					getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetTextColor(0.5, 0.5, 0.5);
					getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetTextColor(0.5, 0.5, 0.5);
					getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetTextColor(0.5, 0.5, 0.5);
					getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetTextColor(0.5, 0.5, 0.5);
				end
			else
				getglobal("GuildFrameGuildStatusButton"..i.."Name"):SetText(nil);
				getglobal("GuildFrameGuildStatusButton"..i.."Rank"):SetText(nil);
				getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetText(nil);
				getglobal("GuildFrameGuildStatusButton"..i.."Online"):SetText(nil);
			end

			getglobal("GuildFrameGuildStatusButton"..i.."Note"):SetWidth(130);

			if ( guildIndex > numGuildMembers ) then
				button:Hide();
			else
				button:Show();
			end
		end

		-- ScrollFrame update
		FauxScrollFrame_Update(GuildListScrollFrame, numGuildMembers, GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT );

		GuildPlayerStatusFrame:Hide();
		GuildStatusFrame:Show();
	end
end

local function GuildFrameGuildListToggleButton_OnClick()
	if ( GwGuildFrame.playerStatusFrame ) then
		GwGuildFrame.playerStatusFrame = nil
	else
		GwGuildFrame.playerStatusFrame = 1;
	end
	GuildStatus_Update()
end

local function GuildControlPopupFrameRemoveRankButton_OnUpdate()
	local numRanks = GuildControlGetNumRanks()
	if ( (GuildControlGetRank() == numRanks) and (numRanks > 5) ) then
		GuildControlPopupFrameRemoveRankButton:Show();
		if ( GwGuildFrame.playersInBotRank > 0 ) then
			GuildControlPopupFrameRemoveRankButton:Disable();
		else
			GuildControlPopupFrameRemoveRankButton:Enable();
		end
	else
		GuildControlPopupFrameRemoveRankButton:Hide();
	end
end

local function LoadGuildList(tabContainer)
    local guildFrame = CreateFrame("Frame", "GwGuildFrame", tabContainer, "GwGuildFrameTemplate")
    guildFrame.Container = tabContainer

    _G.GuildStatus_Update = GuildStatus_Update
    _G.GuildFrameGuildListToggleButton_OnClick = GuildFrameGuildListToggleButton_OnClick
    _G.GuildControlPopupFrameRemoveRankButton_OnUpdate = GuildControlPopupFrameRemoveRankButton_OnUpdate

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
