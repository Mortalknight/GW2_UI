local _, GW = ...

local function AchievementFrameCategories_DisplayButton (elementData)
if ( elementData.isChild ) then
        self.Button:SetWidth(221);
        --self.Button.Label:SetFontObject("GameFontHighlight");
    --	self.parentID = elementData.parent;
    --	self.Button.Background:SetVertexColor(0.6, 0.6, 0.6);
    else
        self.Button:SetWidth(221);
    --	self.Button.Label:SetFontObject("GameFontNormal");
    --	self.parentID = elementData.parent;
    --	self.Button.Background:SetVertexColor(1, 1, 1);
    end
--[[
    local categoryName, parentID, flags;
    local numAchievements, numCompleted;

    local id = elementData.id;

    -- kind of janky
    if ( id == "summary" ) then
        categoryName = ACHIEVEMENT_SUMMARY_CATEGORY;
        numAchievements, numCompleted = GetNumCompletedAchievements(InGuildView());
    else
        categoryName, parentID, flags = GetCategoryInfo(id);
        numAchievements, numCompleted = AchievementFrame_GetCategoryTotalNumAchievements(id, true);
    end

    self.Button.Label:SetText(categoryName);
    self.categoryID = id;
    self.flags = flags;

    -- For the tooltip
    self.Button.name = categoryName;
    if ( id == FEAT_OF_STRENGTH_ID ) then
        -- This is the feat of strength category since it's sorted to the end of the list
        self.Button.text = FEAT_OF_STRENGTH_DESCRIPTION;
        self.Button.showTooltipFunc = AchievementFrameCategory_FeatOfStrengthTooltip;
    elseif ( id == GUILD_FEAT_OF_STRENGTH_ID ) then
        self.Button.text = GUILD_FEAT_OF_STRENGTH_DESCRIPTION;
        self.Button.showTooltipFunc = AchievementFrameCategory_FeatOfStrengthTooltip;
    elseif ( AchievementFrame.selectedTab == 1 or AchievementFrame.selectedTab == 2 ) then
        self.Button.text = nil;
        self.Button.numAchievements = numAchievements;
        self.Button.numCompleted = numCompleted;
        self.Button.numCompletedText = numCompleted.."/"..numAchievements;
        self.Button.showTooltipFunc = AchievementFrameCategory_StatusBarTooltip;
    else
        self.Button.showTooltipFunc = nil;
    end

    self:UpdateSelectionState(elementData.selected);
]]
end

local function SetupButtonHighlight(button, background)
    if not button then return end

    button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover")

    local hl = button:GetHighlightTexture()
    hl:SetVertexColor(0.8, 0.8, 0.8, 0.8)
    hl:SetInside(background)
end

local function skinAchevement()
    local AchievementFrame = _G.AchievementFrame
    local AchievementFrameSummary = _G.AchievementFrameSummary
    local AchievementFrameCategories = _G.AchievementFrameCategories

    AchievementFrame:StripTextures()
    AchievementFrame.Header:StripTextures()
    AchievementFrameSummary:StripTextures()
    AchievementFrameCategories:StripTextures()
    AchievementFrameSummary:GetChildren():Hide()


    AchievementFrame:SetSize(853,627)
    AchievementFrameCategories:SetSize(231,498)
    AchievementFrameCategories:ClearAllPoints()
    AchievementFrameCategories:SetPoint("TOPLEFT",10,-100)


    AchievementFrame.Header.Shield:ClearAllPoints()
    AchievementFrame.Header.Shield:SetSize(40,40)
    AchievementFrame.Header.Shield:SetPoint("TOPLEFT",AchievementFrame,"TOPLEFT",10,-30)


    AchievementFrame.Header.Points:ClearAllPoints()
    AchievementFrame.Header.Points:SetPoint("LEFT",AchievementFrame.Header.Shield,"RIGHT",10,0)
    AchievementFrame.Header.Points:SetFont(DAMAGE_TEXT_FONT, 24)

    AchievementFrame.Header.Title:Hide()
    --  AchievementFrameSummaryAchievement1:StripTextures()

    GW.CreateFrameHeaderWithBody(AchievementFrame, nil, "Interface/AddOns/GW2_UI/textures/character/worldmap-window-icon")
    AchievementFrameHeader:ClearAllPoints()
    AchievementFrameHeader:SetPoint("BOTTOMLEFT",AchievementFrame,"TOPLEFT")
    AchievementFrameHeader:SetPoint("BOTTOMRIGHT",AchievementFrame,"TOPRIGHT")
    AchievementFrame.tex:ClearAllPoints()
    AchievementFrame.tex:SetPoint("TOPLEFT",AchievementFrame,"TOPLEFT",0,0)
    AchievementFrame.tex:SetSize(853,853)
    AchievementFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/windowbg")

    AchievementFrameCloseButton:SkinButton(true)
    AchievementFrameCloseButton:SetSize(20, 20)
    AchievementFrameCloseButton:SetPoint("TOPRIGHT",-10,30)

    AchievementFrameSummary:ClearAllPoints()
    AchievementFrameSummary:SetPoint("TOPLEFT",AchievementFrame,"TOPLEFT",241,0)
    AchievementFrameSummary:SetSize(622,621)

    AchievementFrame.SearchBox:ClearAllPoints()
    AchievementFrame.SearchBox:SetPoint('BOTTOMLEFT', AchievementFrameCategories, 'TOPLEFT', 0, 0)
    AchievementFrame.SearchBox:SetPoint('BOTTOMRIGHT', AchievementFrameCategories, 'TOPRIGHT', 0, 0)

    GW.SkinTextBox(AchievementFrame.SearchBox.Middle, AchievementFrame.SearchBox.Left, AchievementFrame.SearchBox.Right)

	AchievementFrameFilterDropDown:SkinDropDownMenu()
	AchievementFrameFilterDropDown:ClearAllPoints()
	AchievementFrameFilterDropDown:SetPoint('RIGHT', AchievementFrame.SearchBox, 'LEFT', 5, -5)

    local tex = AchievementFrameCategories:CreateTexture("bg", "BACKGROUND", nil, 0)
    tex:SetPoint("TOPLEFT", AchievementFrameCategories, "TOPLEFT", 0, 0)
    tex:SetSize(256, 512)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/236menubg")
    AchievementFrameCategories.tex = tex

    GW.HandleTrimScrollBar(AchievementFrameCategories.ScrollBar)
	GW.HandleTrimScrollBar(AchievementFrameAchievements.ScrollBar)

    hooksecurefunc(_G.AchievementFrameCategories.ScrollBox, 'Update', function(frame)
        for _, child in next, { frame.ScrollTarget:GetChildren() } do
            local button = child.Button
            if button then
                if not button.IsSkinned then
                    button:StripTextures()
                    button.Background:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg")
                    button.Background:ClearAllPoints()
                    button.Background:SetPoint("TOPLEFT",button,"TOPLEFT",0,0)
                    button.Background:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",0,0)
                    SetupButtonHighlight(button, button.Background)

                    button.IsSkinned = true
                end
                if button:GetWidth() ~= 221 then
                    button:SetWidth(221)
                    button.Background:SetWidth(221)
                end
            end
        end
    end)

--    hooksecurefunc(AchievementCategoryTemplate,"Init ",AchievementFrameCategories_DisplayButton)







hooksecurefunc('AchievementFrameSummary_UpdateAchievements', function()
    AchievementFrameSummary:ClearAllPoints()
    AchievementFrameSummary:SetPoint("TOPLEFT",AchievementFrame,"TOPLEFT",241,0)
    AchievementFrameSummary:SetPoint("BOTTOMRIGHT",AchievementFrame,"BOTTOMRIGHT",0,0)
    --AchievementFrameSummary:SetSize(622,621)
    end)


end
local function LoadAchivementSkin()
    GW.RegisterLoadHook(skinAchevement, "Blizzard_AchievementUI")
end

GW.LoadAchivementSkin = LoadAchivementSkin
