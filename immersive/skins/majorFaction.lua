local _, GW = ...

local function SetupMajorFaction(frame)
	if frame.Divider then frame.Divider:Hide() end
	if frame.NineSlice then frame.NineSlice:Hide() end
	if frame.Border then frame.Border:Hide() end
	if frame.TopLeftBorderDecoration then frame.TopLeftBorderDecoration:Hide() end
	if frame.TopRightBorderDecoration then frame.TopRightBorderDecoration:Hide() end
	if frame.BackgroundShadow then frame.BackgroundShadow:Hide() end
	if frame.CloseButton.Border then frame.CloseButton.Border:Hide() end
    if frame.BottomBorderDecoration then frame.BottomBorderDecoration:Hide() end
    if frame.Background then
        --frame.Background:Hide()
        frame.Background:SetDrawLayer("BACKGROUND", 2)
        frame.Background:ClearAllPoints()
        frame.Background:SetPoint("TOPLEFT", frame, 0, -30)
        frame.Background:SetPoint("BOTTOMRIGHT", frame)
    end
end

local function ApplyMajorFactionsFrameSkin()
    if not GW.settings.MajorFactionSkinEnabled then return end

    MajorFactionRenownFrame:GwStripTextures()
    GW.CreateFrameHeaderWithBody(MajorFactionRenownFrame, MajorFactionRenownFrame.TrackFrame.Title, "")
    MajorFactionRenownFrame.HeaderFrame:ClearAllPoints()
    MajorFactionRenownFrame.HeaderFrame:SetPoint("TOP", MajorFactionRenownFrame, "TOP", 0, -35)
    MajorFactionRenownFrame.TrackFrame.Title:SetJustifyH("LEFT")
    MajorFactionRenownFrame.gwHeader.windowIcon:SetTexture(MajorFactionRenownFrame.HeaderFrame.Icon:GetTexture())
    MajorFactionRenownFrame.gwHeader.windowIcon:ClearAllPoints()
    MajorFactionRenownFrame.gwHeader.windowIcon:SetPoint("CENTER", MajorFactionRenownFrame.gwHeader.BGLEFT, "LEFT", 21, -15)

    hooksecurefunc(MajorFactionRenownFrame.HeaderFrame.Icon, "SetAtlas", function(_, tex)
        MajorFactionRenownFrame.gwHeader.windowIcon:SetAtlas(tex)
    end)

    hooksecurefunc(MajorFactionRenownFrame.TrackFrame.Title, "SetText", function()
        MajorFactionRenownFrame.TrackFrame.Title:SetWidth(MajorFactionRenownFrame.TrackFrame.Title:GetStringWidth() + 20)
    end)

    MajorFactionRenownFrame.TrackFrame.Title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)
    MajorFactionRenownFrame.TrackFrame.AccountWideLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    MajorFactionRenownFrame.TrackFrame.AccountWideLabel:SetTextColor(1, 1, 1)

    MajorFactionRenownFrame.TrackFrame.AccountWideLabel:ClearAllPoints()
    MajorFactionRenownFrame.TrackFrame.AccountWideLabel:SetPoint("RIGHT", MajorFactionRenownFrame.TrackFrame.Title, "RIGHT", MajorFactionRenownFrame.TrackFrame.AccountWideLabel:GetStringWidth(), 0)

    MajorFactionRenownFrame.CloseButton:GwSkinButton(true)
    MajorFactionRenownFrame.CloseButton:ClearAllPoints()
    MajorFactionRenownFrame.CloseButton:SetPoint("TOPRIGHT", -5, -2)

    hooksecurefunc(MajorFactionRenownFrame.CloseButton, "SetPoint", function(self, point, anchor, relPoint, x, y)
        if (x and y) and (x ~= -5 or y ~= -2) then
            MajorFactionRenownFrame.CloseButton:SetPoint("TOPRIGHT", -5, -2)
        end
    end)


    if MajorFactionRenownFrame.LevelSkipButton then
		MajorFactionRenownFrame.LevelSkipButton:GwSkinButton(false, true)
	end

	hooksecurefunc(MajorFactionRenownFrame, 'SetUpMajorFactionData', SetupMajorFaction)
end

local function LoadMajorFactionsFrameSkin()
    GW.RegisterLoadHook(ApplyMajorFactionsFrameSkin, "Blizzard_MajorFactions", MajorFactionRenownFrame)
end
GW.LoadMajorFactionsFrameSkin = LoadMajorFactionsFrameSkin