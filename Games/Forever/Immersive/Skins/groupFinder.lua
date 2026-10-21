---@class GW2
local GW = select(2, ...)

-- The vanilla style group finder of Forever: one window with the pages listing, browsing and who list, their
-- tabs sit on the right. It gets the look of our social window, the side tabs move to our left panel.
-- The window stays blizzards ui panel, opening and closing is not touched (gamepad window focus).

local PAGE_TOP = 12
-- the browse list starts under the dropdown row, which keeps clear of our header
local BROWSE_LIST_TOP = -66
local CHECKED = "Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png"
local MENU_HOVER = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"
-- the part of blizzards role atlas names that tells the role
local ATLAS_ROLES = {tank = "TANK", heal = "HEALER", dps = "DAMAGER"}
local TAB_ICONS = {
    "Interface/AddOns/GW2_UI/textures/social/tabicon_raid.png",
    "Interface/AddOns/GW2_UI/textures/social/tabicon_quickjoin.png",
    "Interface/AddOns/GW2_UI/textures/social/tabicon_who.png",
}

local function SkinDropdown(dropdown)
    if dropdown then
        dropdown:GwHandleDropDownBox(nil, true, nil, dropdown:GetWidth())
    end
end

-- small square buttons with an icon keep the icon and get a light hover; blizzards square art only loses its
-- alpha, an empty texture does not clear it
local function SkinIconButton(button, icon)
    for _, texture in ipairs({button:GetNormalTexture(), button:GetPushedTexture(), button:GetDisabledTexture()}) do
        texture:SetAlpha(0)
    end
    button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover.png")
    button:GetHighlightTexture():SetAlpha(0.3)
    button:SetSize(24, 24)
    icon:ClearAllPoints()
    icon:SetPoint("CENTER")
    icon:SetSize(16, 16)
end

-- every page is its own portrait frame under the window; its art is atlas based and partly shown by blizzard,
-- so all of it only loses its alpha
local function SkinPage(page)
    for _, region in ipairs({page:GetRegions()}) do
        if region:IsObjectType("Texture") then
            region:SetAlpha(0)
        end
    end
    GW.HandlePortraitFrameArt(page)
    page.TitleContainer:Hide()
    if page.Inset then
        page.Inset.CustomBG:Hide()
        page.Inset.Border:Hide()
    end
    page:ClearAllPoints()
    page:SetPoint("TOPLEFT", page:GetParent(), "TOPLEFT", 0, -PAGE_TOP)
    page:SetPoint("BOTTOMRIGHT", page:GetParent(), "BOTTOMRIGHT")
end

local function SkinListRow(row)
    if row.ResultBG then
        row.ResultBG:SetAlpha(0)
    end
    if row.InviteButton then
        SkinIconButton(row.InviteButton, row.InviteButton.Icon)
        row.InviteButton.Icon:SetDesaturated(true)
    end
    -- the groups and players headers of the browse list: an own background, the zebra helper skips them
    if row.CategoryLabel then
        row.gwSkinned = true
        row.gwHeaderBg = row:CreateTexture(nil, "BACKGROUND")
        row.gwHeaderBg:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
        row.gwHeaderBg:SetAllPoints()
        -- the dark background alone gets lost on the list, a line marks the header
        row.gwHeaderLine = row:CreateTexture(nil, "BORDER")
        row.gwHeaderLine:SetColorTexture(GW.Colors.SkinColors.HeaderBorder:GetRGBA())
        row.gwHeaderLine:SetPoint("BOTTOMLEFT")
        row.gwHeaderLine:SetPoint("BOTTOMRIGHT")
        row.gwHeaderLine:SetHeight(1)
        row.Highlight:SetAlpha(0)
        GW.AddRowHover(row, MENU_HOVER, nil, "BACKGROUND")
        row.CategoryLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
        row.CategoryLabel:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        for icon, collapsed in pairs({[row.ExpandIcon] = true, [row.CollapseIcon] = false}) do
            GW.SetCollapseArrow(icon, collapsed)
            icon:SetSize(16, 16)
        end
    end
    if row.ActivityName then
        row.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        row.ActivityName:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        if row.PlaystyleLabel then
            row.PlaystyleLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        end
    end
end

-- rows of the result lists: our zebra rows with hover instead of blizzards bars
local function SkinListRows(box)
    for _, row in next, {box.ScrollTarget:GetChildren()} do
        if not row.gwRowSkinned then
            row.gwRowSkinned = true
            SkinListRow(row)
        end
    end
    GW.HandleItemListScrollBoxHover(box)
end

-- our role icons in the group entries, the class icons and empty slots stay
local function SkinRoleIcons(display)
    for _, icon in ipairs(display.Icons) do
        local atlas = icon:GetAtlas()
        for key, role in pairs(ATLAS_ROLES) do
            if atlas and atlas:find(key) then
                icon:SetTexture(GW.nameRoleIconPure[role])
                icon:SetTexCoord(4 / 64, 60 / 64, 4 / 64, 60 / 64)
            end
        end
    end
end

-- our scroll bar with its track line, like the other windows
local function SkinScrollBar(frame)
    GW.HandleTrimScrollBar(frame.ScrollBar)
    GW.HandleScrollControls(frame)
end

local function SkinList(page)
    GW.AddDetailsBackground(page.ScrollBox)
    SkinScrollBar(page)
    hooksecurefunc(page.ScrollBox, "Update", SkinListRows)
end

---------- listing ----------

-- the layout frame takes its size from blizzards hover art, so that stays as it is without alpha; our frame
-- and hover lie on the picture and stay out of the layout
local function SkinCategoryButtons(view)
    for _, button in ipairs(view.CategoryButtons) do
        if not button.gwSkinned then
            button.gwSkinned = true
            button:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly)
            button.backdrop:ClearAllPoints()
            button.backdrop:SetAllPoints(button.Icon)
            button.backdrop:SetFrameLevel(button:GetFrameLevel() + 1)
            button.backdrop:SetBackdropBorderColor(GW.Colors.SkinColors.CardBorder:GetRGB())
            button.backdrop.ignoreInLayout = true
            button.Cover:SetAlpha(0)
            button:GetPushedTexture():SetAlpha(0)
            button.HighlightTexture:SetAlpha(0)
            button.gwHover = button:CreateTexture(nil, "HIGHLIGHT")
            button.gwHover:SetTexture(MENU_HOVER)
            button.gwHover:SetVertexColor(GW.Colors.SkinColors.CardHover:GetRGBA())
            button.gwHover:SetAllPoints(button.Icon)
            button.gwHover.ignoreInLayout = true
            button.Label:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
        end
    end
end

-- blizzard sets the check art on every update, a group with some activities picked gets a faded check
local function SkinActivityCheck(button, partly)
    local check = button.CheckButton
    if not check.gwSkinned then
        -- the row itself takes no mouse, its name, check and toggle do
        GW.AddRowHover(button, MENU_HOVER, {button.NameButton, button.CheckButton, button.ExpandOrCollapseButton}, "BACKGROUND")
    end
    check:GwSkinCheckButton(false, 15)
    check:SetCheckedTexture(CHECKED)
    check:SetDisabledCheckedTexture(CHECKED)
    check:GetCheckedTexture():SetAlpha(partly and 0.5 or 1)
end

-- group and activity rows come from one pool, the header art follows the row
local function SetHeaderArt(button, isHeader)
    if not button.gwHeaderBg then
        button.gwHeaderBg = button:CreateTexture(nil, "BACKGROUND")
        button.gwHeaderBg:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
        button.gwHeaderBg:SetAllPoints()
    end
    button.gwHeaderBg:SetShown(isHeader)
end

local function SkinActivityGroupButton(button, elementData, isCollapsed)
    local partly = not LFGListingFrame:AreAllActivitiesForActivityGroupSelected(elementData.activityGroupID)
    SkinActivityCheck(button, partly)
    SetHeaderArt(button, true)
    button.NameButton.Name:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    -- the row hover covers the toggle, blizzards plus highlight goes
    local toggle = button.ExpandOrCollapseButton
    toggle:GetHighlightTexture():SetAlpha(0)
    GW.SetCollapseArrow(toggle:GetNormalTexture(), isCollapsed)
    toggle:GetNormalTexture():SetSize(16, 16)
end

-- the header color stays on a reused row, the level has the same font object and its color
local function SkinActivityButton(button)
    SkinActivityCheck(button, false)
    SetHeaderArt(button, false)
    button.NameButton.Name:SetTextColor(button.Level:GetTextColor())
end

-- blizzard places the comment on every show; it spans from the back to the post button, its own background
-- lies 5 around it
local function PlaceComment(page)
    local activity = page.ActivityView
    local comment = activity.Comment
    local listBg = activity.gwListBg
    comment:ClearAllPoints()
    if activity.commentRequired then
        -- without a list the comment takes its place
        comment:SetPoint("TOPLEFT", listBg, "TOPLEFT", 5, -5)
        comment:SetPoint("BOTTOMRIGHT", listBg, "BOTTOMRIGHT", -5, 5)
    else
        comment:SetPoint("BOTTOMLEFT", page.BackButton, "TOPLEFT", 5, 48)
        comment:SetPoint("BOTTOMRIGHT", page.PostButton, "TOPRIGHT", -5, 48)
    end
end

local function SkinListing(page)
    SkinPage(page)
    page.RolesSection:GwStripTextures()
    GW.AddDetailsBackground(page.RolesSection)
    page.DividerFrame:Hide()

    page.BackButton:GwSkinButton(false, true)
    page.PostButton:GwSkinButton(false, true)

    for _, button in ipairs(page.SoloRoleButtons.RoleButtons) do
        button.CheckButton:GwSkinCheckButton(false, 15)
    end
    local group = page.GroupRoleButtons
    group.RolePollButton:GwSkinButton(false, true)
    SkinDropdown(group.RoleDropdown)
    page.NewPlayerFriendlyButton.CheckButton:GwSkinCheckButton(false, 15)

    local activity = page.ActivityView
    activity.BarTop:Hide()
    for _, bar in ipairs(activity.BarComponents) do
        bar:Hide()
    end
    SkinDropdown(activity.PlayStyleDropdown)
    activity.PlayStyleDropdown:ClearAllPoints()
    activity.PlayStyleDropdown:SetPoint("BOTTOMLEFT", activity.ScrollBox, "TOPLEFT", -3, 10)
    SkinDropdown(activity.VoiceChatDropdown)
    -- the voice chat dropdown ends with the post button below it
    activity.VoiceChatDropdown:ClearAllPoints()
    activity.VoiceChatDropdown:SetPoint("BOTTOMRIGHT", page.PostButton, "TOPRIGHT", 2, 8)
    activity.VoiceChatLabel:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    activity.LevelRangesCheckbox.Text:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    activity.LevelRangesCheckbox.Checkbox:GwSkinCheckButton(false, 15)
    -- on the view, not the list: categories with only a comment hide the list
    activity.gwListBg = GW.CreateDetailsBackgroundTexture(activity)
    activity.gwListBg:SetAllPoints(activity.ScrollBox)
    SkinScrollBar(activity)
    GW.AddEditBoxBackground(activity.Comment)
    activity:HookScript("OnShow", function() PlaceComment(page) end)
    activity.Comment:HookScript("OnSizeChanged", function(self, width)
        self.EditBox:SetWidth(width - 18)
    end)
    hooksecurefunc("LFGListingActivityView_InitActivityGroupButton", SkinActivityGroupButton)
    hooksecurefunc("LFGListingActivityView_InitActivityButton", SkinActivityButton)

    SkinCategoryButtons(page.CategoryView)
    hooksecurefunc("LFGListingCategorySelection_UpdateCategoryButtons", SkinCategoryButtons)
end

---------- browsing ----------

-- blizzard sets the list anchors again whenever its scroll bar shows or hides, the top edge follows ours
local function RaiseBrowseList(box)
    local function SetTop(self)
        self.gwSettingTop = true
        self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", 7, BROWSE_LIST_TOP)
        self.gwSettingTop = nil
    end
    hooksecurefunc(box, "SetPoint", function(self, point)
        if point == "TOPLEFT" and not self.gwSettingTop then
            SetTop(self)
        end
    end)
    SetTop(box)
end

local function SkinBrowse(page)
    SkinPage(page)
    RaiseBrowseList(page.ScrollBox)
    SkinDropdown(page.CategoryDropdown)
    SkinDropdown(page.ActivityDropdown)
    -- blizzards refresh art brings its own frame, the round arrow of its reset buttons has none
    page.RefreshButton.Icon:SetAtlas("common-icon-undo")
    page.RefreshButton.Icon:SetDesaturated(true)
    SkinIconButton(page.RefreshButton, page.RefreshButton.Icon)

    -- one row over the list, starting at its left edge, 8 apart; our dropdown frame sits 3 in on the left
    -- and 2 on the right
    page.CategoryDropdown:ClearAllPoints()
    page.CategoryDropdown:SetPoint("BOTTOMLEFT", page.ScrollBox, "TOPLEFT", -3, 10)
    page.ActivityDropdown:ClearAllPoints()
    page.ActivityDropdown:SetPoint("LEFT", page.CategoryDropdown, "RIGHT", 3, 0)
    page.RefreshButton:ClearAllPoints()
    page.RefreshButton:SetPoint("LEFT", page.ActivityDropdown, "RIGHT", 6, 0)

    -- the cog of our micro menu instead of blizzards options icon
    local options = page.OptionsButton
    options.Icon:SetAlpha(0)
    options:SetSize(20, 20)
    options.gwCog = options:CreateTexture(nil, "ARTWORK")
    options.gwCog:SetTexture("Interface/AddOns/GW2_UI/textures/icons/mainmenumicrobutton-up.png")
    options.gwCog:SetAllPoints()
    options:ClearAllPoints()
    options:SetPoint("LEFT", page.RefreshButton, "RIGHT", 8, 0)

    -- blizzard keeps the list 40 above the bottom, the buttons go below it
    page.SendMessageButton:GwSkinButton(false, true)
    page.GroupInviteButton:GwSkinButton(false, true)
    page.SendMessageButton:SetPoint("BOTTOMLEFT", 21, 6)
    page.GroupInviteButton:SetPoint("BOTTOMRIGHT", -21, 6)

    SkinList(page)
    hooksecurefunc("LFGBrowseGroupDataDisplayEnumerate_Update", SkinRoleIcons)

    -- the group tooltip is an own frame, not the game tooltip our tooltip module styles
    GW.Tooltip.SetStyle(LFGBrowseSearchEntryTooltip)
end

---------- who list ----------

-- the rows read like our friends list: name | level | class, below race | zone or guild
local function SkinWhoRow(row, elementData)
    local info = elementData.info
    if not row.gwWhoSkinned then
        row.gwWhoSkinned = true
        row.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        for _, text in ipairs({row.Level, row.Class, row.Race, row.Variable, row.GuildName}) do
            text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        end
        row.Name:ClearAllPoints()
        row.Name:SetPoint("TOPLEFT", 10, -14)
        row.Level:ClearAllPoints()
        row.Level:SetPoint("BOTTOMLEFT", row.Name, "BOTTOMRIGHT", 2, 0)
        row.Class:ClearAllPoints()
        row.Class:SetPoint("BOTTOMLEFT", row.Level, "BOTTOMRIGHT", 2, 0)
        row.Class:SetPoint("RIGHT", row.InviteButton, "LEFT", -4, 0)
        row.Race:ClearAllPoints()
        row.Race:SetPoint("TOPLEFT", row.Name, "BOTTOMLEFT", 0, -6)
        row.Variable:ClearAllPoints()
        row.Variable:SetPoint("LEFT", row.Race, "RIGHT", 0, 0)
        row.GuildName:ClearAllPoints()
        row.GuildName:SetPoint("LEFT", row.Variable, "RIGHT", 0, 0)
        row.GuildName:SetPoint("RIGHT", row.InviteButton, "LEFT", -4, 0)
    end

    local delimiter = GW.friendsList.delimiter
    local classColor = info.filename and GW.GWGetClassColor(info.filename, true, true) or GW.Colors.FallbackWhite
    row.Name:SetText(GW.StringWithRGB(row.Name:GetText(), classColor))
    row.Level:SetText(delimiter .. GW.StringWithRGB(tostring(info.level), GetQuestDifficultyColor(info.level)))
    row.Class:SetText(delimiter .. GW.StringWithRGB(info.classStr, classColor))
    row.Race:SetText(info.raceStr)
    row.Race:SetTextColor(GW.Colors.FallbackWhite:GetRGB())

    -- blizzards sort decides whether the second column is zone, guild or race; race and guild have their own place
    local variable = row.Variable:GetText()
    local guild = info.fullGuildName
    local showVariable = variable and variable ~= "" and variable ~= info.raceStr and variable ~= guild
    row.Variable:SetText(showVariable and (delimiter .. variable) or "")
    row.GuildName:SetText((guild and guild ~= "") and (delimiter .. guild) or "")
    row.Variable:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    row.GuildName:SetTextColor(GW.Colors.SkinColors.SubText:GetRGB())
end

local function SkinWhoList(page)
    SkinPage(page)

    -- the list takes the space down to the totals, the search row sits above it with one height of 28
    page.ScrollBox:ClearAllPoints()
    page.ScrollBox:SetPoint("TOPLEFT", page, "TOPLEFT", 7, BROWSE_LIST_TOP)
    page.ScrollBox:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -32, 48)

    SkinDropdown(page.FilterDropdown)
    page.FilterDropdown:ClearAllPoints()
    page.FilterDropdown:SetPoint("BOTTOMRIGHT", page.ScrollBox, "TOPRIGHT", 2, 10)
    page.FilterDropdown:SetHeight(28)
    -- the label keeps blizzards top anchor, it goes between the left edge and our arrow
    local filterText = page.FilterDropdown.Text
    filterText:ClearAllPoints()
    filterText:SetPoint("LEFT", page.FilterDropdown.backdrop, "LEFT", 8, 0)
    filterText:SetPoint("RIGHT", page.FilterDropdown.gw2Arrow, "LEFT", -2, 0)
    filterText:SetJustifyH("CENTER")

    -- a text button instead of the lone magnifier
    local search = page.WhoSearch
    search.Icon:SetAlpha(0)
    search:GwSkinButton(false, true)
    search.gwText = search:CreateFontString(nil, "OVERLAY")
    search.gwText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    search.gwText:SetTextColor(GW.Colors.Fallback:GetRGB())
    search.gwText:SetText(SEARCH)
    search.gwText:SetPoint("CENTER")
    search:SetSize(search.gwText:GetStringWidth() + 30, 28)
    search:ClearAllPoints()
    search:SetPoint("BOTTOMRIGHT", page.FilterDropdown, "BOTTOMLEFT", -5, 0)

    GW.SkinEditBox(page.EditBox, {search = true})
    page.EditBox:ClearAllPoints()
    page.EditBox:SetPoint("BOTTOMLEFT", page.ScrollBox, "TOPLEFT", 0, 10)
    page.EditBox:SetPoint("BOTTOMRIGHT", search, "BOTTOMLEFT", -8, 0)
    -- blizzard sizes the box to its hint text on every show and text scale change
    page.EditBox:SetHeight(28)
    hooksecurefunc(page.EditBox, "AdjustHeightToFitInstructions", function(self)
        self:SetHeight(28)
    end)

    page.WhoFrameTotals:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    SkinList(page)
    hooksecurefunc(LFGWhoListButtonMixin, "InitButton", SkinWhoRow)
end

---------- window ----------

local function ApplyGroupFinderSkin()
    if not GW.settings.skins.lfg.enabled then return end

    local frame = LFGParentFrame
    local icon = "Interface/AddOns/GW2_UI/textures/Groups/dungeon-window-icon.png"
    GW.CreateFrameHeaderWithBody(frame, LFG_TITLE, icon, nil, nil, true, true)
    frame.gwHeader.windowIcon:ClearAllPoints()
    frame.gwHeader.windowIcon:SetPoint("CENTER", frame.gwHeader, "BOTTOMLEFT", -26, 35)
    frame.gwHeader.headerText:ClearAllPoints()
    frame.gwHeader.headerText:SetPoint("BOTTOMLEFT", frame.gwHeader, "BOTTOMLEFT", 25, 10)
    frame:SetClampedToScreen(true)
    frame:SetClampRectInsets(-40, 0, frame.gwHeader:GetHeight() - 30, 0)

    -- moved by its header like the mail; the panel manager can not move it back
    frame:SetScale(GW.settings.skins.lfg.scale)
    frame.mover = CreateFrame("Frame", nil, frame)
    frame.mover:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 0)
    frame.mover:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 0)
    frame.mover:SetHeight(30)
    GW.MakeFrameMovable(frame, nil, "lfg", true)
    GW.MakeFrameMovable(frame.mover, frame, "lfg")
    GW.AddScaleHandle(frame, GW.settings.skins.lfg)

    -- the eye in the corner would sit on our header icon
    LFGParentFramePortrait:SetAlpha(0)
    LFGParentFramePortrait:EnableMouse(false)

    -- like the social window
    LFGParentFrameCloseButton:GwSkinButton(true)
    LFGParentFrameCloseButton:SetSize(20, 20)
    LFGParentFrameCloseButton:ClearAllPoints()
    LFGParentFrameCloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -2)

    GW.SkinLargeSideTabs(frame, {frame.ListingTab, frame.BrowsingTab, frame.WhoListingTab}, TAB_ICONS)
    SkinListing(LFGListingFrame)
    SkinBrowse(LFGBrowseFrame)
    SkinWhoList(LFGWhoListFrame)
end

local function LoadGroupFinderSkin()
    GW.RegisterLoadHook(ApplyGroupFinderSkin, "Blizzard_GroupFinder_VanillaStyle", LFGParentFrame)
end
GW.LoadGroupFinderSkin = LoadGroupFinderSkin
