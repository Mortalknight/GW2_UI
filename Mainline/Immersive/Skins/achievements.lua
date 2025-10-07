local _, GW = ...
local GW_CLASS_COLORS = GW.GW_CLASS_COLORS
local L = GW.L
--[[
TODO
Background alignment after comparison
]]

local AchievementBackgroundTextures = {
    blue = "Interface/AddOns/GW2_UI/textures/uistuff/achievementcompletebg.png",
    red = "Interface/AddOns/GW2_UI/textures/uistuff/achievementcompletebgred.png"
}
GW.AchievementFrameSkinFunction.AchievementBackgroundTextures = AchievementBackgroundTextures


-- Bar colors for accountWide / earnd by character
local barColors = {
    incomplete = {r=93/255, g=93/255, b=93/255, a=1},
    red = {r=153/255, g=60/255, b=48/255, a=1},
    blue = {r=48/255, g=56/255, b=153/255, a=1},
}
GW.AchievementFrameSkinFunction.BarColors = barColors
-- Text Helper functions
local function setSmallText(self)
    self:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
    self:SetTextColor(0.7, 0.7, 0.7)
end
GW.AchievementFrameSkinFunction.SetSmallText = setSmallText
local function setNormalText(self)
    self:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    self:SetTextColor(1, 1, 1)
end
GW.AchievementFrameSkinFunction.SetNormalText = setNormalText
local function setTitleText(self)
    self:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    self:SetTextColor(1, 1, 1)
end
GW.AchievementFrameSkinFunction.SetTitleText = setTitleText

-- Blizzard hacking starts here for overwriting functions to allow our own custom categories
-- is there a less hacky way of doing this?
-- DO NOT DELETE THINGS HERE IF DISABLE CUSTOM CATEGORIES
-- INSTED DON'T RUN AchievementFrameCategories_OnLoad

--Blizzard data values
local hackingBlizzardFunction = false
local FEAT_OF_STRENGTH_ID = 81
local GUILD_FEAT_OF_STRENGTH_ID = 15093
local GUILD_CATEGORY_ID = 15076
local achievementFunctions
local AchievementCategoryIndex = 1
local GuildCategoryIndex = 2
local StatisticsCategoryIndex = 3

local function InGuildView()
    return achievementFunctions == GUILD_ACHIEVEMENT_FUNCTIONS
end

local function IsCategoryFeatOfStrength(category)
    return category == FEAT_OF_STRENGTH_ID or category == GUILD_FEAT_OF_STRENGTH_ID
end
local selectedCategoryID = 0
-- this function overwrites AchievementCategoryTemplateMixin:Init(elementData)
-- we need to replace it since custom categories are hard coded into the function
-- Any changes made to AchievementCategoryTemplateMixin:Init needs to be reflected here
local function customCategorieInit(self, elementData)
    if ( elementData.isChild ) then
        self.Button:SetWidth(ACHIEVEMENTUI_CATEGORIESWIDTH - 25);
        self.Button.Label:SetFontObject("GameFontHighlight");
        self.parentID = elementData.parent;
        self.Button.Background:SetVertexColor(0.6, 0.6, 0.6);
    else
        self.Button:SetWidth(ACHIEVEMENTUI_CATEGORIESWIDTH - 10);
        self.Button.Label:SetFontObject("GameFontNormal");
        self.parentID = elementData.parent;
        self.Button.Background:SetVertexColor(1, 1, 1);
    end

    local categoryName, _, flags;
    local numAchievements, numCompleted;

    local id = elementData.id;

    -- kind of janky
    if ( id == "summary" ) then
        categoryName = ACHIEVEMENT_SUMMARY_CATEGORY;
        numAchievements, numCompleted = GetNumCompletedAchievements(InGuildView());
    elseif ( id == "watchlist" ) then -- custom watchlist category
        categoryName = L["Watch list"]
        numAchievements = #C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)
        numCompleted = 0 -- might need to change or only used for bars?
    else
        categoryName, _, flags = GetCategoryInfo(id);
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
end

local function AchievementFrameCategories_MakeCategoryList(source, fakeSummaryId)
    local categories = {};
    if fakeSummaryId then
        tinsert(categories, { id = fakeSummaryId });
    end
    -- only change to this function is this line seems overkill
    tinsert(categories, { id = "watchlist" });

    for _, id in next, source do
        local _, parent = GetCategoryInfo(id);
        if ( parent == -1 or parent == GUILD_CATEGORY_ID ) then
            tinsert(categories, { id = id });
        end
    end

    local _, parent;
    for i = #source, 1, -1 do
        _, parent = GetCategoryInfo(source[i]);
        for j, category in next, categories do
            if ( category.id == parent ) then
                category.parent = true;
                category.collapsed = true;
                local elementData = {
                    id = source[i],
                    parent = category.id,
                    hidden = true,
                    isChild = (type(category.id) == "number"),
                };
                tinsert(categories, j+1, elementData);
            end
        end
    end
    return categories;
end

--- overrider for blizzard function
-- AchievementFrameAchievements_UpdateDataProvider
local wasPrevCatCustom = false
local function UpdateCategoriesDataProvider()
-- hackfix for AchievementFrame_GetOrSelectCurrentCategory()
-- no other way of emulate its behaviour
    local category = selectedCategoryID

    if category == "summary" then
        return;
    end

    local customCat = category == "watchlist" or false
    local trackedAchievements = C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)
    if customCat then
        ACHIEVEMENTUI_SELECTEDFILTER = function(cat)
            return #trackedAchievements, 0, 0
        end
    else
        if wasPrevCatCustom then
            ACHIEVEMENTUI_SELECTEDFILTER = AchievementFrame_GetCategoryNumAchievements_All
        end
    end
    wasPrevCatCustom = customCat

    local numAchievements, numCompleted, completedOffset = ACHIEVEMENTUI_SELECTEDFILTER(category);
    local fosShown = numAchievements == 0 and IsCategoryFeatOfStrength(category);
    AchievementFrameAchievementsFeatOfStrengthText:SetShown(fosShown);
    if fosShown then
        local asGuild = AchievementFrame.selectedTab == 2;
        AchievementFrameAchievementsFeatOfStrengthText:SetText(asGuild and GUILD_FEAT_OF_STRENGTH_DESCRIPTION or FEAT_OF_STRENGTH_DESCRIPTION);
    end

    local newDataProvider = CreateDataProvider();
    for index = 1, numAchievements do
        if index <= numAchievements then
            local filteredIndex = index + completedOffset;
            local id = 0
            if customCat then
                id = trackedAchievements[index]
                newDataProvider:Insert({category = category, id = id}); -- we use blizzard built in id look up insted of index (thank you twitter intigration)
            else
                id = GetAchievementInfo(category, filteredIndex);
                newDataProvider:Insert({category = category, index = filteredIndex, id = id});
            end
        end
    end
    AchievementFrameAchievements.ScrollBox:SetDataProvider(newDataProvider);
end
-- Blizzard code overwriting is executed here simply dont run this function to disable it
local function AchievementFrameCategories_OnLoad(self)
    -- Create our own data provider function to hack in the watch list cat
    AchievementFrameAchievements_UpdateDataProvider = UpdateCategoriesDataProvider
    -- assign new make category function
    ACHIEVEMENT_FUNCTIONS.categories = AchievementFrameCategories_MakeCategoryList(GetCategoryList(), "summary")
    -- create new filter function for our watch list so we dont run into an error when building achievement lists
    ACHIEVEMENTUI_SELECTEDFILTER = function(categoryID)
        if categoryID == "watchlist" then
            local trackedAchievements = C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)
            return #trackedAchievements, 0, 0
        end
        local numAchievements, numCompleted, numIncomplete = GetCategoryNumAchievements(categoryID);
        return numAchievements, numCompleted, 0;
    end
    -- re build the scroll frame with our init function
    local view = CreateScrollBoxListLinearView();
    view:SetElementInitializer("AchievementCategoryTemplate", function(frame, elementData)
        customCategorieInit(frame, elementData);
    end);
    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

    hackingBlizzardFunction = true
end

local function HandleAchivementsScrollControls(self)
    self.ScrollBar:ClearAllPoints()
    self.ScrollBar:SetWidth(20)
    self.ScrollBar:SetPoint("TOPLEFT",self,"TOPRIGHT",0,-12)
    self.ScrollBar:SetPoint("BOTTOMLEFT",self,"BOTTOMRIGHT",0,12)

    self.ScrollBar.Track:ClearAllPoints()
    self.ScrollBar.Track:SetPoint("TOPLEFT",self.ScrollBar,"TOPLEFT",0,0)
    self.ScrollBar.Track:SetPoint("BOTTOMRIGHT",self.ScrollBar,"BOTTOMRIGHT",0,0)

    local bg = self.ScrollBar.Track:CreateTexture(nil, "BACKGROUND", nil, 0)
    bg:ClearAllPoints();
    bg:SetPoint("TOP",0,0)
    bg:SetPoint("BOTTOM",0,0)
    bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbg.png")


    self.ScrollBar.Back:ClearAllPoints()
    self.ScrollBar.Back:SetPoint("BOTTOM",self.ScrollBar,"TOP",0,0)
    self.ScrollBar.Back:SetSize(12,12)
    bg = self.ScrollBar.Back:CreateTexture(nil, "BACKGROUND", nil, 0)
    bg:ClearAllPoints();
    bg:SetPoint("TOPLEFT",0,0)
    bg:SetPoint("BOTTOMRIGHT",0,0)
    bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbutton.png")

    self.ScrollBar.Forward:ClearAllPoints()
    self.ScrollBar.Forward:SetPoint("TOP",self.ScrollBar,"BOTTOM",0,0)
    self.ScrollBar.Forward:SetSize(12,12)
    bg = self.ScrollBar.Forward:CreateTexture(nil, "BACKGROUND", nil, 0)
    bg:ClearAllPoints();
    bg:SetPoint("TOPLEFT",0,0)
    bg:SetPoint("BOTTOMRIGHT",0,0)
    bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/scrollbutton.png")
    bg:SetTexCoord(0,1,1,0)
end

local function catMenuButtonState(self, selected)
    if selected then
        selectedCategoryID = self.categoryID
        if hackingBlizzardFunction then
            UpdateCategoriesDataProvider()
        end
    end
    ---zeeeebra
    local zebra = (self:GetOrderIndex() % 2)==1 or false
    if zebra then
        self.Button.Background:SetVertexColor(1, 1, 1, 1)
    else
        self.Button.Background:SetVertexColor(0, 0, 0, 0)
    end

    local elementData = self:GetElementData()
    if elementData.parent and (type(elementData.parent) == "number") then
        self.Button.Label:SetPoint("LEFT", self, "LEFT", 40, 0)
        self.Button.arrow:Hide()
    elseif elementData.parent and  not (type(elementData.parent) == "number")  then
        self.Button.Label:SetPoint("LEFT", self, "LEFT", 30, 0)
        self.Button.arrow:Show()
        self.Button.arrow:SetSize(16,16)
        if not elementData.collapsed then
            self.Button.arrow:SetRotation(-1.5707)
        else
            self.Button.arrow:SetRotation(0)
        end
    else
        self.Button.Label:SetPoint("LEFT", self, "LEFT", 30, 0)
        self.Button.arrow:Hide()
    end

    --for summary and watchlist
    local iconTexture = "Interface/AddOns/GW2_UI/textures/uistuff/arrow_right.png"
    if self.categoryID=="summary" or self.categoryID=="watchlist" then
        iconTexture = self.categoryID=="watchlist" and "Interface/AddOns/GW2_UI/textures/uistuff/watchicon.png" or "Interface/AddOns/GW2_UI/textures/uistuff/hamburger.png"
        self.Button.arrow:SetTexture(iconTexture)
        self.Button.arrow:SetSize(25,25)
        self.Button.arrow:Show()
        self.Button.arrow:SetRotation(0)
        self.Button.Label:SetPoint("LEFT", self, "LEFT", 40, 0)
    else
        self.Button.arrow:SetTexture(iconTexture)
    end
end

local function CatMenuButton(_, button)
    local arrow = button:CreateTexture(nil, "BACKGROUND", nil, 0)
    button.arrow = arrow
    button.arrow:ClearAllPoints();
    button.arrow:SetPoint("LEFT",10,0)
    button.arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right.png")
    button.arrow:SetSize(16,16)

    button.Label:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    button.Label:SetShadowColor(0, 0, 0, 0)
    button.Label:SetShadowOffset(1, -1)
    button.Label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    button.Label:SetJustifyH("LEFT")
    button.Label:SetJustifyV("MIDDLE")
end

local function SetupButtonHighlight(button, background)
    if not button then return end

    button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    button.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    local hl = button:GetHighlightTexture()
    hl:SetVertexColor(0.8, 0.8, 0.8, 0.8)
    hl:GwSetInside(background)
    button:HookScript("OnEnter",function()
        GW.TriggerButtonHoverAnimation(button, hl)
    end)
end

local function skinAchievementSummaryHeaders(self)
    local fname = self:GetName()
    local texture = _G[fname.."Header"] or _G[fname.."Texture"]
    local text = _G[fname.."Title"]
    self:SetHeight(32)
    texture:SetTexture("Interface/AddOns/GW2_UI/textures/talents/talents_header.png")
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT")
    texture:SetPoint("BOTTOMRIGHT")
    text:ClearAllPoints()
    text:SetPoint("LEFT",10,0)
    setTitleText(text)
end
local function skinAchievementSummaryStatusBar(self)
    if not self then return end
    self:GwStripTextures()
    local fname = self:GetName()
    local bar = _G[fname.."FillBar"]
    local fill = _G[fname.."Bar"]
    local title = _G[fname.."Title"] or self.Label
    local text = _G[fname.."Text"]
    local spark = _G[fname.."Spark"]
    local button =  _G[fname.."Button"]

    if button then
        _G[fname.."ButtonHighlight"]:GwStripTextures()
    end

    if not spark then
        self.spark = self:CreateTexture(fname.."Spark", "BORDER", nil, 7)
        self.spark:ClearAllPoints();
        self.spark:SetPoint("RIGHT",fill,"RIGHT", 0,0)
        self.spark:SetSize(10,fill:GetHeight())
        self.spark:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar-spark-white.png")
    end

    fill:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    self:SetStatusBarColor(GW_CLASS_COLORS[GW.myclass].r,GW_CLASS_COLORS[GW.myclass].g,GW_CLASS_COLORS[GW.myclass].b,1)

    bar:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
    bar:SetVertexColor(1, 1, 1, 0.5)
    bar:GwSetOutside()
    title:ClearAllPoints()
    title:SetPoint("BOTTOMLEFT",self,"TOPLEFT",0,5)
    setNormalText(title)

    text:ClearAllPoints()
    text:SetPoint("RIGHT",self,"RIGHT",-5,0)
    text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.SMALL)
    text:SetTextColor(1,1,1)
    text:SetHeight(bar:GetHeight())
    text:SetJustifyV("MIDDLE")

    hooksecurefunc(self, "SetValue", function(_, value)
        local _, max = self:GetMinMaxValues()
        self.spark:SetShown(value ~= max)
    end)
end

local function reanchorSummaryCategoriy(index)
    local self = _G["AchievementFrameSummaryCategoriesCategory"..index]
    if not self then return end
    local odd =  (index % 2)==1 or false
    local relativeFrame
    if odd then
        relativeFrame = _G["AchievementFrameSummaryCategoriesCategory"..(index - 2)]
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT",relativeFrame,"BOTTOMLEFT",0,-25)
        self:SetWidth(relativeFrame:GetWidth())
    else
        relativeFrame = _G["AchievementFrameSummaryCategoriesCategory"..(index - 1)]
        self:ClearAllPoints()
        self:SetPoint("LEFT",relativeFrame,"RIGHT",10,0)
        self:SetWidth(relativeFrame:GetWidth())
    end
end
local function skinMetasAchievements(self)
    setSmallText(self.Label)
end
local function skinCriteriaText(self)
    setSmallText(self.Name)
end
local function skinCriteriaStatusbar(parentFrame,self)
    if self.skinned==true then return end
    self.skinned = true

    self:GwStripTextures()
    local text = self.Text

    local bar = select(1,self:GetRegions())
    local fill = select(6,self:GetRegions())

    fill:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    bar:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
    bar:SetVertexColor(1,1,1,0.5)

    local bColor = barColors.incomplete
    if parentFrame.completed and parentFrame.accountWide then
        bColor = barColors.blue
    elseif parentFrame.completed and not parentFrame.accountWide  then
        bColor = barColors.red
    end

    self:SetStatusBarColor(
        bColor.r,
        bColor.g,
        bColor.b
    )

    text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.SMALL)
    text:SetTextColor(1,1,1)
    text:SetHeight(bar:GetHeight())
    text:SetJustifyV("MIDDLE")
end
local function skinAchievementFrameSummaryAchievement(self)
    self.skinned = true
    self:GwStripTextures()

    local overlay = _G[self:GetName().."Overlay"]
    local icon = _G[self:GetName().."Texture"]

    self.Label:ClearAllPoints()
    self.Label:SetPoint("TOPLEFT",self,"TOPLEFT",70,-5)
    self.Label:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,-5)
    self.Label:SetHeight(20)
    self.Label:SetJustifyH("LEFT")
    setTitleText(self.Label)

    self.Description:ClearAllPoints()
    self.Description:SetPoint("TOPLEFT",self.Label,"BOTTOMLEFT",0,-5)
    self.Description:SetPoint("TOPRIGHT",self.Label,"BOTTOMRIGHT",0,-5)
    self.Description:SetJustifyH("LEFT")
    self.Description:SetHeight(30)
    setNormalText(self.Description)

    self.DateCompleted:ClearAllPoints()
    self.DateCompleted:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",-5,5)
    self.DateCompleted:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,5)
    self.DateCompleted:SetHeight(15)
    self.DateCompleted:SetJustifyH("RIGHT")
    setSmallText(self.DateCompleted)

    self.TitleBar:Hide()
    self.TitleBar:ClearAllPoints()
    self.TitleBar:SetAlpha(0)

    overlay:Hide()
    icon:Hide()

    self.Shield:ClearAllPoints()
    self.Shield:SetPoint("CENTER",self,"LEFT",40,0)

    self.Background:Hide()

    self.gwBackdrop = CreateFrame("Frame",nil,self,"GwDarkInsetBorder")

    self.completedBackground = self:CreateTexture(nil, "BACKGROUND", nil, 3)
    self.completedBackground:ClearAllPoints();
    self.completedBackground:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    self.completedBackground:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
    self.completedBackground:SetWidth( self:GetHeight() * 2 )
    self.completedBackground:SetTexture(AchievementBackgroundTextures.blue)
    self.completedBackground:SetVertexColor(1,1,1,0.7)

    self.fBackground = self:CreateTexture(nil, "BACKGROUND", nil, 0)
    self.fBackground:ClearAllPoints()
    self.fBackground:SetPoint("TOPLEFT")
    self.fBackground:SetPoint("BOTTOMRIGHT")
    self.fBackground:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
    self.fBackground:SetVertexColor(1,1,1,0.2)

    self.Highlight:GwStripTextures()
    self.Highlight.Bottom:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/achievementhover.png")
    self.Highlight.Bottom:SetBlendMode("ADD")
    self.Highlight.Bottom:ClearAllPoints()
    self.Highlight.Bottom:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    self.Highlight.Bottom:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)
    self.Highlight.Bottom:SetTexCoord(0,1,0,1)
    self.Highlight.Bottom:SetVertexColor(1,1,1,1)
    self.hasSkinnedHighlight = true

    self:HookScript("OnEnter", function()
        GW.TriggerButtonHoverAnimation(self,self.Highlight.Bottom)
    end)
end

local function updateSummaryAchievementTexture(self, achievementID)
    local _, _, _, _, _, _, _, _, flags = GetAchievementInfo(achievementID)
    if bit.band(flags, ACHIEVEMENT_FLAGS_ACCOUNT) == ACHIEVEMENT_FLAGS_ACCOUNT then
        self.completedBackground:SetTexture(AchievementBackgroundTextures.blue)
    else
        self.completedBackground:SetTexture(AchievementBackgroundTextures.red)
    end
end

local function updateAchievementFrameSummaryAchievement(self, achievementID)
    if not self.skinned then
        skinAchievementFrameSummaryAchievement(self)
    end
    setNormalText(self.Description)
    if achievementID and self.achievementId ~= achievementID then
        updateSummaryAchievementTexture(self, achievementID)
        self.achievementId = achievementID
    end
end

local function skinAchievementFrameListAchievement(self)
    self.skinned = true
    self:GwStripTextures()
    self:SetHeight(120)
    local overlay = self.Icon.frame
    local icon = self.Icon.texture

    self.cBackground = self:CreateTexture(nil, "BACKGROUND", nil, 2)
    self.cBackground:ClearAllPoints();
    self.cBackground:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    self.cBackground:SetSize(self:GetHeight(),self:GetHeight())
    self.cBackground:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
    self.cBackground:SetVertexColor(1,1,1,0.4)

    self.trackBackground = self:CreateTexture(nil, "BACKGROUND", nil, 1)
    self.trackBackground:ClearAllPoints();
    self.trackBackground:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)
    self.trackBackground:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    self.trackBackground:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/achievementfootertracked.png")

    local tbg = select(2,self.Tracked:GetRegions())
    local highlight = select(3,self.Tracked:GetRegions())
    local tText = select(1,self.Tracked:GetRegions())
    local hover = select(4,self.Tracked:GetRegions())
    local checked = select(5,self.Tracked:GetRegions())
    tbg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/watchicon.png")
    highlight:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/watchiconactive.png")
    checked:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/watchiconactive.png")
    hover:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/watchicon.png")
    tText:Hide()

    self.gwBackdrop = CreateFrame("Frame",nil,self,"GwDarkInsetBorder")
    self.Label:ClearAllPoints()
    self.Label:SetPoint("TOPLEFT",self.cBackground,"TOPRIGHT",20,0)
    self.Label:SetPoint("TOPRIGHT",self,"TOPRIGHT",-20,0)
    self.Label:SetHeight(30)
    setTitleText(self.Label)
    self.Label:SetJustifyH("LEFT")

    self.Description:ClearAllPoints()
    self.Description:SetPoint("TOPLEFT",self.Label,"BOTTOMLEFT",0,-5)
    self.Description:SetPoint("TOPRIGHT",self.Label,"BOTTOMRIGHT",0,-5)
    self.Description:SetJustifyH("LEFT")
    self.Description:SetHeight(40)
    setNormalText(self.Description)

    self.rewardIcon = self:CreateTexture(nil, "BORDER", nil, 0)
    self.rewardIcon:ClearAllPoints();
    self.rewardIcon:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",125,3)
    self.rewardIcon:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/rewardchestsmall.png")
    self.rewardIcon:SetSize(24,24)

    hooksecurefunc(self.Reward, "Hide", function() self.rewardIcon:Hide() end)
    hooksecurefunc(self.Reward, "Show", function() self.rewardIcon:Show() end)

    if not self.Reward:IsShown() then
        self.rewardIcon:Hide()
    end

    self.Reward:ClearAllPoints()
    self.Reward:SetPoint("BOTTOMLEFT",self.rewardIcon,"BOTTOMRIGHT",5,5)
    self.Reward:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,5)
    self.Reward:SetJustifyH("LEFT")
    self.Reward:SetHeight(15)
    setSmallText(self.Reward)

    self.HiddenDescription:SetPoint("TOPLEFT",self.Label,"BOTTOMLEFT",0,-5)
    self.HiddenDescription:SetPoint("TOPRIGHT",self.Label,"BOTTOMRIGHT",0,-5)
    self.HiddenDescription:SetJustifyH("LEFT")
    self.HiddenDescription:SetHeight(40)
    setNormalText(self.HiddenDescription)

    self.DateCompleted:ClearAllPoints()
    self.DateCompleted:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",-5,5)
    self.DateCompleted:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,5)
    self.DateCompleted:SetHeight(15)
    self.DateCompleted:SetJustifyH("RIGHT")
    setSmallText(self.DateCompleted)

    overlay:Hide()
    icon:Hide()

    self.Shield:ClearAllPoints()
    self.Shield:SetPoint("CENTER",self.cBackground,"CENTER",0,0)

    hooksecurefunc(self,"ToggleTracking",function(self)
        self.GwUpdateAchievementFrameListAchievement(self)
    end)

    hooksecurefunc(self,"DisplayObjectives",function(self)
        local objectivesFrame = self:GetObjectiveFrame();

        objectivesFrame:ClearAllPoints();
        objectivesFrame:SetPoint("TOPLEFT",self.HiddenDescription,"BOTTOMLEFT");
        objectivesFrame:SetPoint("TOPRIGHT",self.HiddenDescription,"BOTTOMRIGHT");

        for _, v in pairs(objectivesFrame.metas) do
            skinMetasAchievements(v)
        end
        for _, v in pairs(objectivesFrame.criterias) do
            skinCriteriaText(v)
        end
        for _, v in pairs(objectivesFrame.progressBars) do
            skinCriteriaStatusbar(self, v)
        end
    end)

    self.Background:Hide()
    self.Background:ClearAllPoints()
    self.Background:SetAlpha(0)
    self.TitleBar:Hide()
    self.TitleBar:ClearAllPoints()
    self.TitleBar:SetAlpha(0)

    self.TopRightTsunami:SetAlpha(0)
    self.TopLeftTsunami:SetAlpha(0)
    self.TopTsunami1:SetAlpha(0)
    self.BottomTsunami1:SetAlpha(0)
    self.BottomRightTsunami:SetAlpha(0)
    self.BottomLeftTsunami:SetAlpha(0)
    --GuildCornerR
    --GuildCornerL

    if not self.fBackground then
        self.fBackground = self:CreateTexture(nil, "BACKGROUND", nil, 0)
        self.fBackground:ClearAllPoints();
        self.fBackground:SetPoint("TOPLEFT")
        self.fBackground:SetPoint("BOTTOMRIGHT")
        self.fBackground:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
        self.fBackground:SetVertexColor(1,1,1,0.2)
    end
    if not self.bottomBar then
        self.bottomBar = self:CreateTexture(nil, "BACKGROUND", nil, 2)
        self.bottomBar:ClearAllPoints();
        self.bottomBar:SetPoint("BOTTOMRIGHT")
        self.bottomBar:SetSize(512,64)
        self.bottomBar:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/achievementfooter.png")
    end
    if not self.completedBackground then
        self.completedBackground = self:CreateTexture(nil, "BACKGROUND", nil, 3)
        self.completedBackground:ClearAllPoints();
        self.completedBackground:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
        self.completedBackground:SetPoint("BOTTOMLEFT",self,"TOPLEFT",0,-120)
        self.completedBackground:SetWidth(240)
        self.completedBackground:SetTexture(AchievementBackgroundTextures.blue)
        self.completedBackground:SetVertexColor(1,1,1,0.7)
    end

    self.Tracked:ClearAllPoints()
    self.Tracked:SetPoint("BOTTOMRIGHT",self.bottomBar,"BOTTOMRIGHT",-7,0)
    self.Tracked:SetSize(30,30)
    self.Tracked:HookScript("OnClick",function()
        if selectedCategoryID == "watchlist" then
            UpdateCategoriesDataProvider()
        end
    end)

    self.Highlight:GwStripTextures()
    self.Highlight.Bottom:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/achievementhover.png")
    self.Highlight.Bottom:SetBlendMode("ADD")
    self.Highlight.Bottom:ClearAllPoints()
    self.Highlight.Bottom:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    self.Highlight.Bottom:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)
    self.Highlight.Bottom:SetTexCoord(0,1,0,1)
    self.Highlight.Bottom:SetVertexColor(1,1,1,1)
    self.hasSkinnedHighlight = true

    self:HookScript("OnEnter",function()
        GW.TriggerButtonHoverAnimation(self,self.Highlight.Bottom)
    end)
end

local function UpdateAchievementFrameListAchievement(self)
    if not self.GetElementData then
        return
    end

    if not self.skinned then
        self.GwUpdateAchievementFrameListAchievement = UpdateAchievementFrameListAchievement
        skinAchievementFrameListAchievement(self)
    end

    local id, _, _, completed, _, _, _, _, flags, _, _, isGuild, wasEarnedByMe, _ = GetAchievementInfo(self.id);
    -- needed for status bars
    self.accountWide = bit.band(flags, ACHIEVEMENT_FLAGS_ACCOUNT) == ACHIEVEMENT_FLAGS_ACCOUNT
    self.isGuild = isGuild

    local elementData = self:GetElementData()

    if not elementData.selected then
        self:SetHeight(120)
    else
        self:Expand(math.max(120, self:DisplayObjectives(self.id, self.completed)))
    end

    if self.completed then
        self.completedBackground:Show()
        self.cBackground:Hide()
        self.completedBackground:SetAlpha(1)
    else
        self.completedBackground:Hide()
        self.cBackground:Show()
        if self.accountWide then
            self.completedBackground:Show()
            self.completedBackground:SetAlpha(0.1)
        end
    end

    if self.accountWide then
        self.completedBackground:SetTexture(AchievementBackgroundTextures.blue)
    else
        self.completedBackground:SetTexture(AchievementBackgroundTextures.red)
    end

    if ( not completed or (not wasEarnedByMe and not isGuild) ) then
        self.Tracked:Show()
        self.DateCompleted:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",-50,5)
        self.DateCompleted:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,5)
        self.bottomBar:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/achievementfooter.png")
    else
        self.Tracked:Hide()
        self.DateCompleted:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",-5,5)
        self.DateCompleted:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,5)
        self.bottomBar:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/achievementfooternotrack.png")
    end

    if C_ContentTracking.IsTracking(Enum.ContentTrackingType.Achievement, id) then
        self.trackBackground:Show()
        self.bottomBar:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/achievementfooternotrack.png")
    else
        self.trackBackground:Hide()
    end

    setSmallText(self.Reward)

    self.Background:Hide()
    self.TitleBar:Hide()
    self.TopRightTsunami:Hide()
    self.TopLeftTsunami:Hide()
    self.TopTsunami1:Hide()
    self.BottomTsunami1:Hide()
    self.BottomRightTsunami:Hide()
    self.BottomLeftTsunami:Hide()

    self.HiddenDescription:SetTextColor(1,1,1)
    self.Description:SetTextColor(1,1,1)
end

local function skinAchievementFrameListStats(self)
    self.skinned = true

    self.Background:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
    setNormalText(self.Text)
    setNormalText(self.Value)
    setTitleText(self.Title)
    if self.FriendValue then
        setNormalText(self.FriendValue)
    end
    self.Title:ClearAllPoints()
    self.Title:SetPoint("LEFT",10,0)
    self.Middle:ClearAllPoints()
    self.Middle:SetAllPoints()
    self.Left:Hide()
    self.Right:Hide()
    if self.Middle2 then
        self.Middle2:Hide()
        self.Left2:Hide()
        self.Right2:Hide()
    end

    self.Middle:SetTexture("Interface/AddOns/GW2_UI/textures/talents/talents_header.png")
end
local function UpdateAchievementFrameListStats(self)
    if not self.skinned then
        skinAchievementFrameListStats(self)
    end
    self.Left:Hide()
    self.Right:Hide()
    if self.Middle2 then
        self.Middle2:Hide()
        self.Left2:Hide()
        self.Right2:Hide()
    end
    self:SetHeight(32)
    self.Middle:SetTexCoord(0,1,0,1)
end

local function skinAchievementFrameTab(self,index)
    self.skinned = true
    self:GwStripTextures()
    self:SetSize(64,40)
    self.Text:Hide()

    self.icon = self:CreateTexture(nil, "BACKGROUND", nil, 0)
    self.icon:SetAllPoints()

    if index==1 then
        self.icon:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/tabicon_achievement.png")
    elseif index==2 then
        self.icon:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/tabicon_guild.png")
    else
        self.icon:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/tabicon_stats.png")
    end
    self.icon:SetTexCoord(0.51, 1, 0, 0.625)
end

local function updateAchievementFrameTab(self,index)
    if not self.skinned then
        skinAchievementFrameTab(self,index)
    end
    self:SetSize(64,40)
end

local function updateAchievementFrameTabLayout()
    local x = 0
    for i=1,3 do
        local f = _G["AchievementFrameTab"..i]
        if f and f:IsShown() then
            f:ClearAllPoints()
            f:SetPoint("TOPRIGHT",AchievementFrame.LeftSidePanel,"TOPLEFT", 1, -32 + (-40 * x))
            f:SetParent(AchievementFrame.LeftSidePanel)
            updateAchievementFrameTab(f,i)
            x = x + 1
        end
    end
end

local function AchievementFrameTabSetTabState()
    AchievementFrameHeader.breadCrumb:SetText("")
    local tab
    for i=1,3 do
        tab = _G["AchievementFrameTab"..i]
        if tab then
            if not tab.skinned then
                skinAchievementFrameTab(tab,i)
            end
            tab.icon:SetTexCoord(0.51, 1, 0, 0.625)
        end
    end

    if AchievementFrame.selectedTab then
        tab = _G["AchievementFrameTab"..AchievementFrame.selectedTab]
        if tab==nil then return end
        if not tab.skinned then
            skinAchievementFrameTab(tab,AchievementFrame.selectedTab)
        end
        if AchievementFrame.selectedTab~=1 then
            AchievementFrameHeader.breadCrumb:SetText(tab.Text:GetText())
        end
        tab.icon:SetTexCoord(0, 0.5, 0, 0.625)
    end
end

local function skinAchievementComparison(self,isPlayer)
    self.skinned = true
    local parent = self:GetParent()

    self:GwStripTextures()
    self:SetHeight(80)
    self:SetWidth( isPlayer and 395 or  172 )
    self.Icon:Hide()

    if isPlayer then
        self.Label:ClearAllPoints()
        self.Label:SetPoint("TOPLEFT",self,"TOPLEFT",80,-5)
        self.Label:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,-5)
        self.Label:SetHeight(20)
        self.Label:SetJustifyH("LEFT")
        setTitleText(self.Label)
    end

    if isPlayer then
        self.Description:ClearAllPoints()
        self.Description:SetPoint("TOPLEFT",self.Label,"BOTTOMLEFT",0,-5)
        self.Description:SetPoint("TOPRIGHT",self.Label,"BOTTOMRIGHT",0,-5)
        self.Description:SetJustifyH("LEFT")
        self.Description:SetHeight(30)
        setNormalText(self.Description)
    end
    local dateCompleteText = self.DateCompleted or self.Status
    if dateCompleteText then
        dateCompleteText:ClearAllPoints()
        dateCompleteText:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",-5,5)
        dateCompleteText:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,5)
        dateCompleteText:SetHeight(15)
        dateCompleteText:SetJustifyH("RIGHT")
    end
    if self.TitleBar then
        self.TitleBar:Hide()
        self.TitleBar:ClearAllPoints()
        self.TitleBar:SetAlpha(0)
    end
    if self.Shield then
        self.Shield:ClearAllPoints()
        self.Shield:SetPoint("CENTER",self,"LEFT",40,0)
    end

    self.Background:Hide()
    self.gwBackdrop = CreateFrame("Frame",nil,self,"GwDarkInsetBorder")

    self.completedBackground = self:CreateTexture(nil, "BACKGROUND", nil, 3)
    self.completedBackground:ClearAllPoints();
    self.completedBackground:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    self.completedBackground:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",0,0)
    self.completedBackground:SetWidth( self:GetHeight() * 2 )
    self.completedBackground:SetTexture(AchievementBackgroundTextures.blue)
    self.completedBackground:SetVertexColor(1,1,1,0.7)

    if isPlayer then
        parent.fBackground = parent:CreateTexture(nil, "BACKGROUND", nil, o)
        parent.fBackground:ClearAllPoints()
        parent.fBackground:SetPoint("TOPLEFT")
        parent.fBackground:SetPoint("BOTTOMRIGHT")
        parent.fBackground:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
        parent.fBackground:SetVertexColor(1,1,1,0.2)
    end
end

local function updateAchievementComparison(self,isPlayer)
    if not self.skinned then
        skinAchievementComparison(self,isPlayer)
    end

    local parent = self:GetParent()

    if self.Description then
        setNormalText(self.Description)
    end
    local dateCompleteText = self.DateCompleted or self.Status

    if dateCompleteText then
        setSmallText(dateCompleteText)
    end

    if self.completed then
        self.completedBackground:Show()
    else
        self.completedBackground:Hide()
    end

    if isPlayer and parent.GetOrderIndex then
        local zebra = (parent:GetOrderIndex() % 2)==1 or false
        if zebra then
            parent.fBackground:SetVertexColor(1, 1, 1, 0.2)
        else
            parent.fBackground:SetVertexColor(0, 0, 0, 0)
        end
    end
end

local function skinAchievementCompareSummaryStatusBar(self,isPlayer)
    self:GwStripTextures()

    local bar = select(6,self:GetRegions())
    local title = self.Title
    local text = self.Text
    local fill = self.Bar

    self:ClearAllPoints()
    self:SetPoint("BOTTOMLEFT",10,0)
    self:SetPoint("BOTTOMRIGHT",-10,0)

    if not spark then
        self.spark = self:CreateTexture(nil, "OVERLAY", nil, 7)
        self.spark:ClearAllPoints();
        self.spark:SetPoint("RIGHT",fill,"RIGHT", 0,0)
        self.spark:SetSize(10,fill:GetHeight())
        self.spark:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar-spark-white.png")
    end
    local color = isPlayer and GW_CLASS_COLORS[GW.myclass] or GW_CLASS_COLORS[select(2,UnitClass("Target"))]
    if color and color.r then
        self:SetStatusBarColor(color.r,color.g,color.b,1)
    end

    bar:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
    bar:SetVertexColor(1,1,1,0.5)
    self:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    title:ClearAllPoints()
    title:SetPoint("BOTTOMLEFT",self,"TOPLEFT",0,5)
    setNormalText(title)
    text:ClearAllPoints()
    text:SetPoint("RIGHT",self,"RIGHT",-5,0)
    text:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.SMALL)
    text:SetTextColor(1,1,1)
    text:SetHeight(bar:GetHeight())
    text:SetJustifyV("MIDDLE")
end

local function updatePointsDisplay()
    AchievementFrame.Header.Points:SetWidth(171)
    AchievementFrame.Header.Points:ClearAllPoints()
    AchievementFrame.Header.Points:SetPoint("LEFT",AchievementFrame.Header.Shield,"RIGHT",5,0)
    AchievementFrame.Header.Points:SetJustifyH("LEFT")
    if AchievementFrame.selectedTab and AchievementFrame.selectedTab == 2 then
        AchievementFrame.Header.Shield:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/achievementpointiconguild.png");
    else
        if AchievementFrame.selectedTab==1 then
            AchievementFrame.cacheAchievementPoints = AchievementFrame.Header.Points:GetText()
        end
        if AchievementFrame.selectedTab==3  and AchievementFrame.cacheAchievementPoints then
            AchievementFrame.Header.Points:SetText(AchievementFrame.cacheAchievementPoints)
            AchievementFrame.Header.Points:SetTextColor(1,1,1)
        end
        AchievementFrame.Header.Shield:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/achievementpointicon.png");
    end
    AchievementFrame.Header.Shield:ClearAllPoints()
    AchievementFrame.Header.Shield:SetPoint("TOPLEFT",AchievementFrame,"TOPLEFT",10,-25)
    AchievementFrame.Header.Shield:SetSize(50,50)
    AchievementFrame.Header.Shield:SetTexCoord(0, 1, 0, 1);
end

local function skinAchevement()
    AchievementFrameCategories_OnLoad(AchievementFrameCategories)
    -- function to "hack" the blizzard functions
    hooksecurefunc("AchievementFrameBaseTab_OnClick", function(tabIndex)
        if tabIndex == AchievementCategoryIndex then
            achievementFunctions = ACHIEVEMENT_FUNCTIONS;
        elseif tabIndex == GuildCategoryIndex then
            achievementFunctions = GUILD_ACHIEVEMENT_FUNCTIONS;
        elseif tabIndex == StatisticsCategoryIndex then
            achievementFunctions = STAT_FUNCTIONS;
        end
    end)

    AchievementFrame:GwStripTextures()
    AchievementFrame.Header:GwStripTextures()
    AchievementFrameSummary:GwStripTextures()
    AchievementFrameCategories:GwStripTextures()
    AchievementFrameSummary:GetChildren():Hide()

    AchievementFrameWaterMark:Hide()

    AchievementFrame:SetSize(853, 627)

    AchievementFrameCategories:SetSize(221, 426)
    AchievementFrameCategories:ClearAllPoints()
    AchievementFrameCategories:SetPoint("TOPLEFT", 10, -172)

    AchievementFrame.Header.Shield:ClearAllPoints()
    AchievementFrame.Header.Shield:SetSize(90, 90)
    AchievementFrame.Header.Shield:SetPoint("TOPLEFT", AchievementFrame, "TOPLEFT", 10, -40)

    hooksecurefunc("AchievementFrame_RefreshView", updatePointsDisplay)
    hooksecurefunc("AchievementFrame_UpdateTabs", updatePointsDisplay)

    AchievementFrame.Header.Points:ClearAllPoints()
    AchievementFrame.Header.Points:SetPoint("LEFT", AchievementFrame.Header.Shield, "RIGHT", 10, 0)
    AchievementFrame.Header.Points:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)

    AchievementFrame.Header.Title:Hide()

    GW.CreateFrameHeaderWithBody(AchievementFrame, nil, "Interface/AddOns/GW2_UI/textures/character/worldmap-window-icon.png", nil, 0, true, true)
    AchivementFrameLeftPanel = AchievementFrame.LeftSidePanel -- needed for krowis skin
    AchievementFrameHeader.windowIcon:ClearAllPoints()
    AchievementFrameHeader.windowIcon:SetPoint("CENTER", AchievementFrameHeader, "BOTTOMLEFT", -26, 26)
    AchievementFrameHeader.windowIcon:SetTexture("Interface/AddOns/GW2_UI/textures/character/achievements-window-icon.png")
    AchievementFrameHeader.header = AchievementFrameHeader:CreateFontString(nil, "OVERLAY")
    AchievementFrameHeader.breadCrumb = AchievementFrameHeader:CreateFontString(nil, "OVERLAY")
    AchievementFrameHeader.header:SetPoint("BOTTOMLEFT", 20, 8)
    AchievementFrameHeader.breadCrumb:SetPoint("LEFT", AchievementFrameHeader.header, "RIGHT", 20, 0)
    AchievementFrameHeader.header:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)
    AchievementFrameHeader.breadCrumb:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    AchievementFrameHeader.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    AchievementFrameHeader.breadCrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    AchievementFrameHeader.header:SetWidth(AchievementFrameHeader.header:GetStringWidth())
    AchievementFrameHeader.header:SetText(ACHIEVEMENTS)
    AchievementFrameHeader.breadCrumb:SetText("")

    updateAchievementFrameTab(AchievementFrameTab1, 1)
    updateAchievementFrameTab(AchievementFrameTab2, 2)
    updateAchievementFrameTab(AchievementFrameTab3, 3)

    hooksecurefunc("AchievementFrame_SetComparisonTabs", updateAchievementFrameTabLayout)
    hooksecurefunc("PanelTemplates_UpdateTabs", updateAchievementFrameTabLayout)
    hooksecurefunc("AchievementFrame_SetTabs", AchievementFrameTabSetTabState)
    hooksecurefunc("AchievementFrame_UpdateTabs", AchievementFrameTabSetTabState)

    hooksecurefunc("AchievementFrame_DisplayComparison",function()
        AchievementFrame:SetSize(853, 627)
        updateAchievementFrameTabLayout()
    end)
    hooksecurefunc("AchievementFrame_ToggleAchievementFrame",function()
        AchievementFrame:SetSize(853, 627)
        updateAchievementFrameTabLayout()
    end)
    AchievementFrame:HookScript("OnShow",function()
        AchievementFrame:SetSize(853, 627)
        updateAchievementFrameTabLayout()
    end)

    AchievementFrameHeader:ClearAllPoints()
    AchievementFrameHeader:SetPoint("BOTTOMLEFT", AchievementFrame, "TOPLEFT")
    AchievementFrameHeader:SetPoint("BOTTOMRIGHT", AchievementFrame, "TOPRIGHT")
    AchievementFrame.tex:ClearAllPoints()
    AchievementFrame.tex:SetTexCoord(0, 1, 0, 0.73633)
    AchievementFrame.tex:SetPoint("TOPLEFT", AchievementFrame, "TOPLEFT", 0, 0)
    AchievementFrame.tex:SetPoint("BOTTOMRIGHT", AchievementFrame, "BOTTOMRIGHT", 0, 0)
    AchievementFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/character/windowbg.png")

    AchievementFrameCloseButton:GwSkinButton(true)
    AchievementFrameCloseButton:SetSize(20, 20)
    AchievementFrameCloseButton:SetPoint("TOPRIGHT", -10, 30)

    AchievementFrameSummary:ClearAllPoints()
    AchievementFrameSummary:SetPoint("TOPLEFT", AchievementFrame, "TOPLEFT", 251, 0)
    AchievementFrameSummary:SetSize(612, 621)

    AchievementFrame.SearchBox:ClearAllPoints()
    AchievementFrame.SearchBox:SetPoint("BOTTOMLEFT", AchievementFrameCategories, "TOPLEFT", 0, 10)
    AchievementFrame.SearchBox:SetWidth(237)
    AchievementFrame.SearchBox:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    GW.SkinTextBox(AchievementFrame.SearchBox.Middle, AchievementFrame.SearchBox.Left, AchievementFrame.SearchBox.Right)
    AchievementFrame.SearchBox:SetHeight(26)
    AchievementFrame.SearchBox.searchIcon:Hide()
    AchievementFrame.SearchBox:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    AchievementFrame.SearchBox.Instructions:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    AchievementFrame.SearchBox.Instructions:SetTextColor(178 / 255, 178 / 255, 178 / 255)

    AchievementFrame.SearchPreviewContainer:GwStripTextures()
    AchievementFrame.SearchPreviewContainer:ClearAllPoints()
    AchievementFrame.SearchPreviewContainer:SetPoint("TOPLEFT", AchievementFrame.SearchBox, "BOTTOMLEFT", 0, 0)
    AchievementFrame.SearchPreviewContainer:SetPoint("TOPRIGHT", AchievementFrame.SearchBox, "BOTTOMRIGHT", 0, 0)

    for i = 1,5 do
        local sp = AchievementFrame.SearchPreviewContainer["SearchPreview" ..i ]
        if sp then
            sp:SetWidth(AchievementFrame.SearchPreviewContainer:GetWidth())
            sp.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        end
    end

    AchievementFrameFilterDropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true)
    AchievementFrameFilterDropdown:ClearAllPoints()
    AchievementFrameFilterDropdown:SetPoint("BOTTOMLEFT", AchievementFrame.SearchBox, "TOPLEFT", 0, 10)
    AchievementFrameFilterDropdown:SetPoint("BOTTOMRIGHT", AchievementFrame.SearchBox, "TOPRIGHT", 0, 10)
    AchievementFrameFilterDropdown:SetHeight(26)

    AchievementFrameFilterDropdown.backdrop:ClearAllPoints()
    AchievementFrameFilterDropdown.backdrop:SetPoint("TOPLEFT", AchievementFrameFilterDropdown, "TOPLEFT", 0, 0)
    AchievementFrameFilterDropdown.backdrop:SetPoint("BOTTOMRIGHT", AchievementFrameFilterDropdown, "BOTTOMRIGHT", 0, 0)
    AchievementFrameFilterDropdown.backdrop:SetAlpha(0.5)

    --create dummy frame
    local dropdownDummyFrame = CreateFrame("Frame", AchievementFrame)
    GW.AchievementFrameFilterDropDownDummy = dropdownDummyFrame -- make that frame "global" for Krowi
    dropdownDummyFrame:SetParent(AchievementFrame)
    dropdownDummyFrame:SetSize(AchievementFrameFilterDropdown:GetSize())
    dropdownDummyFrame:SetAlpha(0.3)

    dropdownDummyFrame.bg = dropdownDummyFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
    dropdownDummyFrame.bg:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
    dropdownDummyFrame.bg:SetPoint("CENTER", dropdownDummyFrame, "CENTER")
    dropdownDummyFrame.bg:SetSize(dropdownDummyFrame:GetSize())


    dropdownDummyFrame.arrow = dropdownDummyFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
    dropdownDummyFrame.arrow:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
    dropdownDummyFrame.arrow:SetPoint("RIGHT", dropdownDummyFrame, "RIGHT", -12, 0)
    dropdownDummyFrame.arrow:SetSize(23, 23)

    dropdownDummyFrame:SetPoint("BOTTOMLEFT", AchievementFrame.SearchBox, "TOPLEFT", 0, 10)
    dropdownDummyFrame:SetPoint("BOTTOMRIGHT", AchievementFrame.SearchBox, "TOPRIGHT", 0, 10)

    AchievementFrameFilterDropdown:HookScript("OnShow", function()
        dropdownDummyFrame:Hide()
    end)
    AchievementFrameFilterDropdown:HookScript("OnHide", function()
        dropdownDummyFrame:Show()
    end)

    local tex = AchievementFrameCategories:CreateTexture(nil, "BACKGROUND", nil, 0)
    tex:SetPoint("TOPLEFT", AchievementFrameCategories, "TOPLEFT", 0, 0)
    tex:SetSize(256, 512)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/236menubg.png")
    AchievementFrameCategories.tex = tex

    AchievementFrameCategories.ScrollBox:SetPoint("TOPLEFT", 0, 0)

    GW.HandleTrimScrollBar(AchievementFrameCategories.ScrollBar, true)
    GW.HandleTrimScrollBar(AchievementFrameAchievements.ScrollBar, true)
    GW.HandleTrimScrollBar(AchievementFrameStats.ScrollBar, true)
    GW.HandleTrimScrollBar(AchievementFrameComparison.AchievementContainer.ScrollBar, true)
    GW.HandleTrimScrollBar(AchievementFrameComparison.StatContainer.ScrollBar, true)

    HandleAchivementsScrollControls(AchievementFrameCategories)
    HandleAchivementsScrollControls(AchievementFrameAchievements)
    HandleAchivementsScrollControls(AchievementFrameStats)
    HandleAchivementsScrollControls(AchievementFrameComparison.AchievementContainer)
    HandleAchivementsScrollControls(AchievementFrameComparison.StatContainer)

    local loaded = false
    hooksecurefunc(AchievementFrameCategories.ScrollBox, "Update", function()
        --wait for load
        if not loaded then
            loaded = true
            AchievementFrameCategories.ScrollBox.view:SetElementExtent(36)
        end
    end)

    local function OnCategoriesFrameViewAcquiredFrame(_, frame, _, new)
        if not new then return end

        frame:SetHeight(36)
        local button = frame.Button
        if button then
            if not button.IsSkinned then
                button:GwStripTextures()
                button.Background:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
                button.Background:ClearAllPoints()
                button.Background:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
                button.Background:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
                button:SetPoint("TOPLEFT", frame, "TOPLEFT", 0,0 )
                button:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
                SetupButtonHighlight(button, button.Background)
                CatMenuButton(frame, button)
                hooksecurefunc(frame, "UpdateSelectionState", catMenuButtonState)

                button.IsSkinned = true
            end
        end
    end

    AchievementFrameCategories.ScrollBox:RegisterCallback(ScrollBoxListViewMixin.Event.OnAcquiredFrame, OnCategoriesFrameViewAcquiredFrame)

    ----SUMMARY
    AchievementFrameSummaryAchievements:ClearAllPoints()
    AchievementFrameSummaryAchievements:SetPoint("TOPLEFT", 0, -10)
    AchievementFrameSummaryAchievements:SetPoint("TOPRIGHT", 0, -10)

    AchievementFrameSummaryCategories:ClearAllPoints()
    AchievementFrameSummaryCategories:SetPoint("TOPLEFT", AchievementFrameSummaryAchievements, "BOTTOMLEFT", 0, -10)
    AchievementFrameSummaryCategories:SetPoint("TOPRIGHT", AchievementFrameSummaryAchievements, "BOTTOMRIGHT", 0, -10)

    skinAchievementSummaryHeaders(AchievementFrameSummaryAchievementsHeader)
    AchievementFrameSummaryAchievementsHeader:SetPoint("TOPLEFT", -10, 0)
    skinAchievementSummaryHeaders(AchievementFrameSummaryCategoriesHeader)
    AchievementFrameSummaryCategoriesHeader:SetPoint("TOPLEFT", -10, 0)

    AchievementFrameSummaryCategoriesStatusBar:ClearAllPoints()
    AchievementFrameSummaryCategoriesStatusBar:SetPoint("TOPLEFT", AchievementFrameSummaryCategoriesHeader, "BOTTOMLEFT", 10, -30)
    AchievementFrameSummaryCategoriesStatusBar:SetPoint("TOPRIGHT", AchievementFrameSummaryCategoriesHeader, "BOTTOMRIGHT", -10, -30)

    skinAchievementSummaryStatusBar(AchievementFrameSummaryCategoriesStatusBar)
    skinAchievementSummaryStatusBar(AchievementFrameSummaryCategoriesCategory1)
    skinAchievementSummaryStatusBar(AchievementFrameSummaryCategoriesCategory2)
    skinAchievementSummaryStatusBar(AchievementFrameSummaryCategoriesCategory3)
    skinAchievementSummaryStatusBar(AchievementFrameSummaryCategoriesCategory4)
    skinAchievementSummaryStatusBar(AchievementFrameSummaryCategoriesCategory5)
    skinAchievementSummaryStatusBar(AchievementFrameSummaryCategoriesCategory6)
    skinAchievementSummaryStatusBar(AchievementFrameSummaryCategoriesCategory7)
    skinAchievementSummaryStatusBar(AchievementFrameSummaryCategoriesCategory8)
    skinAchievementSummaryStatusBar(AchievementFrameSummaryCategoriesCategory9)
    skinAchievementSummaryStatusBar(AchievementFrameSummaryCategoriesCategory10)
    skinAchievementSummaryStatusBar(AchievementFrameSummaryCategoriesCategory11)

    AchievementFrameSummaryCategoriesCategory1:ClearAllPoints()
    AchievementFrameSummaryCategoriesCategory1:SetPoint("TOPLEFT", AchievementFrameSummaryCategoriesStatusBar, "BOTTOMLEFT", 0, -25)
    AchievementFrameSummaryCategoriesCategory1:SetWidth((AchievementFrameSummaryCategoriesStatusBar:GetWidth() / 2) - 20)

    AchievementFrameSummaryCategoriesCategory2:ClearAllPoints()
    AchievementFrameSummaryCategoriesCategory2:SetPoint("LEFT", AchievementFrameSummaryCategoriesCategory1, "RIGHT", 10, 0)
    AchievementFrameSummaryCategoriesCategory2:SetWidth(AchievementFrameSummaryCategoriesCategory1:GetWidth())

    reanchorSummaryCategoriy(3)
    reanchorSummaryCategoriy(4)
    reanchorSummaryCategoriy(5)
    reanchorSummaryCategoriy(6)
    reanchorSummaryCategoriy(7)
    reanchorSummaryCategoriy(8)
    reanchorSummaryCategoriy(9)
    reanchorSummaryCategoriy(10)
    reanchorSummaryCategoriy(11)

    AchievementFrameComparison:GwStripTextures()
    for _, v in next, {AchievementFrameComparison:GetChildren()} do
        if v then
            v:GwStripTextures()
        end
    end
    AchievementFrameComparison:ClearAllPoints()
    AchievementFrameComparison:SetPoint("TOPLEFT", AchievementFrame, "TOPLEFT", 251, -10)
    AchievementFrameComparison:SetSize(582 - 10, 621 - 20)

    AchievementFrameComparison.Background = AchievementFrameComparison:CreateTexture(nil, "BACKGROUND", nil, 0)
    AchievementFrameComparison.Background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/listbackground.png")
    AchievementFrameComparison.Background:ClearAllPoints()
    AchievementFrameComparison.Background:SetPoint("TOPLEFT", AchievementFrameComparison, "TOPLEFT", 0, 0)
    AchievementFrameComparison.Background:SetSize(608, 621)
    AchievementFrameComparison.Background:SetTexCoord(0, 1, 0, 1)

    AchievementFrameComparison.AchievementContainer:ClearAllPoints()
    AchievementFrameComparison.AchievementContainer:SetPoint("TOPLEFT", AchievementFrameComparison, "TOPLEFT", 0, -65)
    AchievementFrameComparison.AchievementContainer:SetPoint("BOTTOMRIGHT", AchievementFrameComparison, "BOTTOMRIGHT", 0, 0)
    AchievementFrameComparison.AchievementContainer.ScrollBox:ClearAllPoints()
    AchievementFrameComparison.AchievementContainer.ScrollBox:SetAllPoints()

    AchievementFrameComparison.Summary:ClearAllPoints()
    AchievementFrameComparison.Summary:SetPoint("TOPLEFT", 0, 0)
    AchievementFrameComparison.Summary:SetSize(582, 60)
    AchievementFrameComparison.Summary.Player:SetSize(395, 45)
    AchievementFrameComparison.Summary.Friend:SetSize(172, 45)

    AchievementFrameComparison.Summary:GwStripTextures()
    AchievementFrameComparison.Summary.Player:GwStripTextures()
    AchievementFrameComparison.Summary.Friend:GwStripTextures()

    AchievementFrameComparison.Summary.bg = AchievementFrameComparison.Summary:CreateTexture(nil, "BACKGROUND", nil, 0)
    AchievementFrameComparison.Summary.bg:ClearAllPoints()
    AchievementFrameComparison.Summary.bg:SetAllPoints()
    AchievementFrameComparison.Summary.bg:SetTexture("Interface/AddOns/GW2_UI/textures/talents/talents_header.png")

    skinAchievementCompareSummaryStatusBar(AchievementFrameComparison.Summary.Player.StatusBar, true)
    skinAchievementCompareSummaryStatusBar(AchievementFrameComparison.Summary.Friend.StatusBar, false)

    AchievementFrameComparisonHeader.Points:ClearAllPoints()
    AchievementFrameComparisonHeader.Points:SetPoint("BOTTOMRIGHT", AchievementFrameComparison.Summary.Friend.StatusBar,"TOPRIGHT", 0, 5)
    AchievementFrameComparisonHeaderName:ClearAllPoints()
    AchievementFrameComparisonHeaderName:SetPoint("BOTTOMLEFT", AchievementFrameComparison.Summary.Friend.StatusBar, "TOPLEFT", 0, 5)
    setNormalText(AchievementFrameComparisonHeader.Points)
    setNormalText(AchievementFrameComparisonHeaderName)
    AchievementFrameComparisonHeaderPortrait:Hide()

    local LoadAchievementFrameComparison = false
    hooksecurefunc(AchievementFrameComparison.AchievementContainer.ScrollBox, "Update", function(frame)
        for _, child in next, {frame.ScrollTarget:GetChildren()} do
            updateAchievementComparison(child.Player, true)
            updateAchievementComparison(child.Friend, false)
        end
        if LoadAchievementFrameComparison == false then
            LoadAchievementFrameComparison = true
            AchievementFrameComparison.AchievementContainer.ScrollBox.view:SetElementExtent(80)
            AchievementFrameComparison.AchievementContainer.ScrollBox.view:SetPadding(0, 10, 0, 0, 5)
        end
    end)

    AchievementFrameComparison.StatContainer:ClearAllPoints()
    AchievementFrameComparison.StatContainer:SetPoint("TOPLEFT",AchievementFrameComparison,"TOPLEFT",0,0)
    AchievementFrameComparison.StatContainer:SetSize(582 - 10, 621 - 20)

    local LoadAchievementFrameComparisonStats = false
    hooksecurefunc(AchievementFrameComparison.StatContainer.ScrollBox, "Update", function(frame)
        for _, child in next, {frame.ScrollTarget:GetChildren()} do
            UpdateAchievementFrameListStats(child)
        end

        if LoadAchievementFrameComparisonStats == false then
            LoadAchievementFrameComparisonStats = true
            AchievementFrameComparison.StatContainer.ScrollBox.view:SetPadding(0, 0, 0, 0, 0)
            AchievementFrameComparison.StatContainer.ScrollBox.view:SetElementExtent(32)
        end
    end)

    AchievementFrameAchievements:GwStripTextures()
    for _, v in next, {AchievementFrameAchievements:GetChildren()} do
        if v then
            v:GwStripTextures()
        end
    end
    AchievementFrameAchievements:ClearAllPoints()
    AchievementFrameAchievements:SetPoint("TOPLEFT", AchievementFrame, "TOPLEFT", 251, -10)
    AchievementFrameAchievements:SetSize(582 - 10, 621 - 20)

    local LoadAchievementFrameAchievements = false
    hooksecurefunc(AchievementFrameAchievements.ScrollBox, "Update", function(frame)
        AchievementFrameAchievements.Background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/listbackground.png")
        AchievementFrameAchievements.Background:ClearAllPoints()
        AchievementFrameAchievements.Background:SetPoint("TOPLEFT", AchievementFrameSummary, "TOPLEFT", -11, -9)
        AchievementFrameAchievements.Background:SetSize(608, 621)
        AchievementFrameAchievements.Background:SetTexCoord(0, 1, 0, 1)

        for _, child in next, {frame.ScrollTarget:GetChildren()} do
            UpdateAchievementFrameListAchievement(child)
        end

        if not LoadAchievementFrameAchievements then
            LoadAchievementFrameAchievements = true

            AchievementFrameAchievements.ScrollBox.view:SetPadding(0, 10, 0, 0, 5)
            AchievementFrameAchievements.ScrollBox.view:SetElementExtentCalculator(function(_, elementData)
                -- sometimes elementData.category, elementData.index is missing and that causes an error
                if SelectionBehaviorMixin.IsElementDataIntrusiveSelected(elementData) and elementData.category and elementData.index then
                    -- 36 is offset from ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT (84) to our default 120
                    return math.max(AchievementTemplateMixin.CalculateSelectedHeight(elementData) + 36, 120)
                else
                    return 120
                end
            end)
        end
    end)

    AchievementFrameStats:GwStripTextures()
    for _, v in next, {AchievementFrameStats:GetChildren()} do
        if v then
            v:GwStripTextures()
        end
    end

    AchievementFrameStats:ClearAllPoints()
    AchievementFrameStats:SetPoint("TOPLEFT", AchievementFrame, "TOPLEFT", 247, -5)
    AchievementFrameStats:SetSize(582 - 10, 621 - 20)

    local LoadAchievementFrameStats = false

    AchievementFrameStats.Background = AchievementFrameStats:CreateTexture(nil, "BACKGROUND", nil, 0)
    AchievementFrameStats.Background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/listbackground.png")
    AchievementFrameStats.Background:ClearAllPoints()
    AchievementFrameStats.Background:SetPoint("TOPLEFT", AchievementFrameSummary, "TOPLEFT", -11, -9)
    AchievementFrameStats.Background:SetSize(608, 621)
    hooksecurefunc(AchievementFrameStats.ScrollBox, "Update", function(frame)
        for _, child in next, {frame.ScrollTarget:GetChildren()} do
            UpdateAchievementFrameListStats(child)
        end

        if LoadAchievementFrameStats == false then
            LoadAchievementFrameStats = true
            AchievementFrameAchievements.ScrollBox.view:SetPadding(0, 0, 0, 0, 0)
            AchievementFrameStats.ScrollBox.view:SetElementExtent(32)
        end
    end)

    hooksecurefunc("AchievementFrame_RefreshView", function()
        AchievementFrameSummary.Background:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/listbackground.png")
        AchievementFrameSummary.Background:ClearAllPoints()
        AchievementFrameSummary.Background:SetPoint("TOPLEFT", AchievementFrameSummary, "TOPLEFT", -11, -9)
        AchievementFrameSummary.Background:SetSize(608, 621)
        AchievementFrameSummary.Background:SetTexCoord(0, 1, 0, 1)
    end)
    hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function(...)
        AchievementFrameSummary:ClearAllPoints()
        AchievementFrameSummary:SetPoint("TOPLEFT", AchievementFrame, "TOPLEFT", 261, 0)
        AchievementFrameSummary:SetSize(582, 621)

        local width = 592/2 - 2.5
        local height = (AchievementFrameSummaryAchievements:GetHeight() - 32 - 10) / 2
        AchievementFrameSummaryAchievement1:ClearAllPoints()
        AchievementFrameSummaryAchievement1:SetPoint("TOPLEFT", AchievementFrameSummaryAchievementsHeader, "BOTTOMLEFT", 0, -5)
        AchievementFrameSummaryAchievement1:SetWidth(width)
        AchievementFrameSummaryAchievement1:SetHeight(height)
        updateAchievementFrameSummaryAchievement(AchievementFrameSummaryAchievement1, select(1, ...))

        AchievementFrameSummaryAchievement2:ClearAllPoints()
        AchievementFrameSummaryAchievement2:SetPoint("TOPLEFT", AchievementFrameSummaryAchievement1, "TOPRIGHT", 5, 0)
        AchievementFrameSummaryAchievement2:SetWidth(width)
        AchievementFrameSummaryAchievement2:SetHeight(height)
        updateAchievementFrameSummaryAchievement(AchievementFrameSummaryAchievement2, select(2, ...))

        AchievementFrameSummaryAchievement3:ClearAllPoints()
        AchievementFrameSummaryAchievement3:SetPoint("TOPLEFT", AchievementFrameSummaryAchievement1, "BOTTOMLEFT", 0, -5)
        AchievementFrameSummaryAchievement3:SetWidth(width)
        AchievementFrameSummaryAchievement3:SetHeight(height)
        updateAchievementFrameSummaryAchievement(AchievementFrameSummaryAchievement3, select(3, ...))

        AchievementFrameSummaryAchievement4:ClearAllPoints()
        AchievementFrameSummaryAchievement4:SetPoint("TOPLEFT", AchievementFrameSummaryAchievement3, "TOPRIGHT", 5, 0)
        AchievementFrameSummaryAchievement4:SetWidth(width)
        AchievementFrameSummaryAchievement4:SetHeight(height)
        updateAchievementFrameSummaryAchievement(AchievementFrameSummaryAchievement4, select(4, ...))
    end)
    -- make the frame movable
    GW.MakeFrameMovable(AchievementFrame, nil, "AchievementWindow", true)
    GW.MakeFrameMovable(AchievementFrame.Header, AchievementFrame, "AchievementWindow")

    AchievementFrame:SetClampedToScreen(true)
    AchievementFrame:SetClampRectInsets(-40, 0, AchievementFrame.Header:GetHeight() - 40, 0)
end

local function LoadAchivementSkin()
    if not GW.settings.ACHIEVEMENT_SKIN_ENABLED then return end

    GW.RegisterLoadHook(skinAchevement, "Blizzard_AchievementUI", AchievementFrame)
end
GW.LoadAchivementSkin = LoadAchivementSkin
