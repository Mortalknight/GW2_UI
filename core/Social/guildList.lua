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

local function UpdateGuildStatus()
	if FriendsFrame.playerStatusFrame then
		local playerZone = GW.Libs.GW2Lib:GetPlayerLocationZoneText()
		for i = 1, GUILDMEMBERS_TO_DISPLAY do
			local button = _G["GuildFrameButton"..i]
			if button and button.guildIndex then
				local _, _, _, level, className, zone, _, _, online = GetGuildRosterInfo(button.guildIndex)
				local classFilename = GW.UnlocalizedClassName(className)
				if classFilename then
					if online then
						local classTextColor = GW.GWGetClassColor(classFilename, true, true)
						local levelTextColor = GetQuestDifficultyColor(level)
						_G["GuildFrameButton"..i.."Name"]:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
						_G["GuildFrameButton"..i.."Level"]:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)

						if zone == playerZone then
							_G["GuildFrameButton"..i.."Zone"]:SetTextColor(0, 1, 0)
						else
							_G["GuildFrameButton"..i.."Zone"]:SetTextColor(1, 1, 1)
						end
					end

                    GW.SetClassIcon(button.icon, classFilename)
				end
			end
		end
	else
		for i = 1, GUILDMEMBERS_TO_DISPLAY do
			local button = _G["GuildFrameGuildStatusButton"..i]
			if button and button.guildIndex then
				local _, _, _, _, className, _, _, _, online = GetGuildRosterInfo(button.guildIndex)
				local classFilename = online and GW.UnlocalizedClassName(className)
				if classFilename then
					local classTextColor = GW.GWGetClassColor(classFilename, true, true)
					_G["GuildFrameGuildStatusButton"..i.."Name"]:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
					_G["GuildFrameGuildStatusButton"..i.."Online"]:SetTextColor(1, 1, 1)
				end
			end
		end
	end
end

function GW.SkinGuildList()
    if not GW.TBC then return end

    -- this will taint
    --[[
    GUILDMEMBERS_TO_DISPLAY = 22
    for i = 14, GUILDMEMBERS_TO_DISPLAY do
        local button = CreateFrame("Button", "GuildFrameButton" .. i, GuildPlayerStatusFrame, "FriendsFrameGuildPlayerStatusButtonTemplate", i)
        button:SetPoint("TOPLEFT", _G["GuildFrameButton" .. i -1], "BOTTOMLEFT", 0, 0)

        button = CreateFrame("Button", "GuildFrameGuildStatusButton" .. i, GuildStatusFrame, "FriendsFrameGuildStatusButtonTemplate", i)
        button:SetPoint("TOPLEFT", _G["GuildFrameButton" .. i -1], "BOTTOMLEFT", 0, 0)
    end
    ]]

    for i = 1, GUILDMEMBERS_TO_DISPLAY do
        local button = _G["GuildFrameButton"..i]
		local level = _G["GuildFrameButton"..i.."Level"]
		local name = _G["GuildFrameButton"..i.."Name"]
		local classButton = _G["GuildFrameButton"..i.."Class"]
		local statusName = _G["GuildFrameGuildStatusButton"..i.."Name"]

        button.icon = button:CreateTexture("$parentIcon", "ARTWORK")
		button.icon:SetPoint("LEFT", 48, 0)
		button.icon:SetSize(15, 15)
		button.icon:SetTexture("Interface/AddOns/GW2_UI/textures/party/classicons.png")
		button.icon:GwCreateBackdrop(nil, true, nil, nil, nil, nil, nil, button.icon)

        level:ClearAllPoints()
		level:SetPoint("TOPLEFT", 10, -1)
		name:SetSize(100, 14)
		name:ClearAllPoints()
		name:SetPoint("LEFT", 85, 0)
		classButton:Hide()
		statusName:ClearAllPoints()
		statusName:SetPoint("LEFT", 10, 0)

        _G["GuildFrameGuildStatusButton" .. i]:GetHighlightTexture():SetTexture("")
        GW.AddListItemChildHoverTexture(_G["GuildFrameGuildStatusButton" .. i])

        _G["GuildFrameButton" .. i]:GetHighlightTexture():SetTexture("")
        GW.AddListItemChildHoverTexture(_G["GuildFrameButton" .. i])
    end

    hooksecurefunc("GuildStatus_Update", UpdateGuildStatus)

    GuildFrameColumnHeader3:ClearAllPoints()
	GuildFrameColumnHeader3:SetPoint("TOPLEFT", 8, -57)
	GuildFrameColumnHeader4:ClearAllPoints()
	GuildFrameColumnHeader4:SetPoint("LEFT", GuildFrameColumnHeader3, "RIGHT", -2, -0)
	GuildFrameColumnHeader4:SetWidth(50)
	GuildFrameColumnHeader1:ClearAllPoints()
	GuildFrameColumnHeader1:SetPoint("LEFT", GuildFrameColumnHeader4, "RIGHT", -2, -0)
	GuildFrameColumnHeader1:SetWidth(105)
	GuildFrameColumnHeader2:ClearAllPoints()
	GuildFrameColumnHeader2:SetPoint("LEFT", GuildFrameColumnHeader1, "RIGHT", -2, -0)
	GuildFrameColumnHeader2:SetWidth(127)

    GuildFrameLFGButton:GwSkinCheckButton()
    GuildFrameLFGButton:SetSize(15, 15)

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
     GuildListScrollFrame:SetPoint("TOPLEFT", GuildFrame, "TOPLEFT", 10, -60)

    GuildFrameNotesLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    GuildFrameNotesLabel:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)

    GuildFrameTotals:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    GuildFrameOnlineTotals:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    GuildFrameNotesLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
    GuildFrameNotesText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)

    GuildFrameLFGFrame:GwStripTextures()

    for _, object in pairs(Headers) do
        local frame = _G[object]
        frame:GwStripTextures()
        local r = {frame:GetRegions()}
        for _,c in pairs(r) do
            if c:GetObjectType() == "FontString" then
                c:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
            end
        end
        GW.HandleScrollFrameHeaderButton(frame)
    end
end
