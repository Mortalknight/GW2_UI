---@class GW2
local GW = select(2, ...)
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad

local PANEL_WIDTH = 608
local BLIZZARD_PAGE_WIDTH = 782

local profs = {
    ["185"] = {icon = 133971, atlas = "gather", idx = 6},
    ["356"] = {icon = 136245, atlas = "gather", idx = 5},
    ["129"] = {icon = 135966},
    ["171"] = {atlas = "prod", idx = 4},
    ["164"] = {atlas = "prod", idx = 8},
    ["333"] = {atlas = "prod", idx = 6},
    ["202"] = {atlas = "prod", idx = 3},
    ["165"] = {atlas = "prod", idx = 2},
    ["197"] = {atlas = "prod", idx = 1},
    ["182"] = {atlas = "gather", idx = 2},
    ["186"] = {atlas = "gather", idx = 3},
    ["393"] = {atlas = "gather", idx = 1},
}

local PROFESSION_RANKS = {
    {75, APPRENTICE},
    {150, JOURNEYMAN},
    {225, EXPERT},
    {300, ARTISAN},
}

-- Camelot returns the secondaries as first aid, fishing, cooking
local ROW_PLACEHOLDERS = {
    {header = PROFESSIONS_FIRST_PROFESSION, text = PROFESSIONS_MISSING_PROFESSION},
    {header = PROFESSIONS_SECOND_PROFESSION, text = PROFESSIONS_MISSING_PROFESSION},
    {header = PROFESSIONS_COOKING, text = PROFESSIONS_COOKING_MISSING, icon = profs["185"].icon},
    {header = PROFESSIONS_FISHING, text = PROFESSIONS_FISHING_MISSING, icon = profs["356"].icon},
    {header = PROFESSIONS_FIRST_AID, text = PROFESSIONS_FIRST_AID_MISSING, icon = profs["129"].icon},
}

local function GetProfessionRows()
    local prof1, prof2, firstAid, fishing, cooking = GetProfessions()
    return {prof1, prof2, cooking, fishing, firstAid}
end

---------- overview ----------

local function profButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetSpellBookItem(self.spellbookIndex, self.booktype)
    GameTooltip:Show()
end

local profButtonSecure_OnDragStart = [=[
    local spellId = self:GetAttribute("spell")
    if not spellId then
        return "clear", nil
    end
    return "clear", "spell", spellId
]=]

local function updateButton(self, spellIdx)
    if spellIdx then
        local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(spellIdx, Enum.SpellBookSpellBank.Player)
        self.spellbookIndex = spellIdx
        self.booktype = Enum.SpellBookSpellBank.Player
        self.skillName = C_SpellBook.GetSpellBookItemName(spellIdx, Enum.SpellBookSpellBank.Player)
        self.icon:SetTexture(C_SpellBook.GetSpellBookItemTexture(spellIdx, Enum.SpellBookSpellBank.Player))
        self.name:SetText(self.skillName)
        self:RegisterForClicks("AnyUp", "AnyDown")
        self:SetAttribute("type1", "spell")
        self:SetAttribute("type2", "spell")
        self:SetAttribute("spell", spellBookItemInfo and spellBookItemInfo.spellID)
        self:SetAttribute("_ondragstart", profButtonSecure_OnDragStart)
        self:Enable()
        self:SetAlpha(1)
    else
        self.spellbookIndex = nil
        self.booktype = nil
        self.skillName = nil
        self.icon:SetTexture(nil)
        self.name:SetText(nil)
        self:SetAttribute("type1", nil)
        self:SetAttribute("type2", nil)
        self:SetAttribute("spell", nil)
        self:SetAttribute("_ondragstart", nil)
        self:Disable()
        self:SetAlpha(0)
    end
    self.unlearn:Hide()
end

local function unlearn_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetText(UNLEARN_SKILL_TOOLTIP)
    GameTooltip:Show()
end

local function unlearn_OnClick(self)
    if InCombatLockdown() then
        PlaySound(44310)
        UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0)
        return
    end
    local skill = self:GetParent()
    StaticPopup_Show("UNLEARN_SKILL", skill.skillName, nil, skill.profId)
end

local function GetRankTitle(skillMax)
    local title
    for _, rank in ipairs(PROFESSION_RANKS) do
        if skillMax < rank[1] then
            break
        end
        title = rank[2]
    end
    return title
end

local function updateOverview(fmOverview)
    if InCombatLockdown() then
        return
    end

    local rows = GetProfessionRows()
    local txR = 588 / 1024
    local txH = 110

    for i = 1, 5 do
        local fm = fmOverview.profs[i]
        local idx = rows[i]
        if idx then
            local name, icon, skill, skillMax, num, offset, profId, skillMod, _, _, skillDesc = GetProfessionInfo(idx)
            fm.skillName = name
            fm.profId = profId
            fm.icon:SetTexture(icon)
            fm.icon:SetDesaturated(false)
            fm.title:SetText(name)
            fm.desc:SetText((skillDesc and skillDesc ~= "") and skillDesc or GetRankTitle(skillMax) or "")
            fm.desc:SetWidth(220)
            fm.StatusBar:SetValue(skillMax > 0 and skill / skillMax or 0)
            if skillMod and skillMod ~= 0 then
                fm.StatusBar.currentValue:SetText(skill .. " +" .. skillMod .. "/" .. skillMax)
            else
                fm.StatusBar.currentValue:SetText(skill .. "/" .. skillMax)
            end
            fm.StatusBar:Show()
            fm.btn1:Show()
            fm.btn2:Show()
            updateButton(fm.btn1, num and num >= 1 and offset + 1 or nil)
            updateButton(fm.btn2, num and num >= 2 and offset + 2 or nil)

            local p = profId and profs[profId .. ""]
            if p and p.atlas then
                local txT = (p.idx - 1) * txH
                fm.background:SetTexture("Interface/AddOns/GW2_UI/textures/character/professions_overview_" .. p.atlas)
                fm.background:SetTexCoord(0, txR, txT / 1024, (txT + txH) / 1024)
                fm.background:SetAlpha(0.5)
            else
                fm.background:SetTexture("Interface/AddOns/GW2_UI/textures/character/paperdollbg.png")
                fm.background:SetTexCoord(0, 1, 1, 0)
                fm.background:SetAlpha(1.0)
            end
            fm.background:SetDesaturated(false)
            fm.unlearn:SetShown(i <= 2)
        else
            local placeholder = ROW_PLACEHOLDERS[i]
            fm.icon:SetTexture(placeholder.icon or 134938)
            fm.title:SetText(placeholder.header)
            fm.desc:SetText(placeholder.text)
            fm.desc:SetWidth(450)
            fm.skillName = nil
            fm.profId = nil
            fm.icon:SetDesaturated(true)
            fm.StatusBar:Hide()
            fm.btn1:Hide()
            fm.btn2:Hide()
            fm.background:SetTexture("Interface/AddOns/GW2_UI/textures/character/paperdollbg.png")
            fm.background:SetTexCoord(0, 1, 1, 0)
            fm.background:SetAlpha(1.0)
            fm.background:SetDesaturated(true)
            fm.unlearn:Hide()
        end
    end
end

local function overview_OnUpdate(self, elapsed)
    if self.delay then
        self.delay = self.delay - elapsed
        if self.delay > 0 then
            return
        end
    end
    self:SetScript("OnUpdate", nil)
    updateOverview(self)
    self.queuedUpdate = false
end

local function queueUpdate(fm, delay)
    if fm.queuedUpdate then
        return
    end
    fm.queuedUpdate = true
    fm.delay = delay
    fm:SetScript("OnUpdate", overview_OnUpdate)
end

local function loadOverview(parent)
    local fmOverview = CreateFrame("Frame", "GwProfessionsOverview", parent, "GwProfessionsOverview")
    fmOverview.profs = {}

    for i = 1, 5 do
        local fm = CreateFrame("Frame", nil, fmOverview, "GwProfessionsOverFrame")
        if i > 1 then
            fm:ClearAllPoints()
            fm:SetPoint("TOPLEFT", fmOverview, "TOPLEFT", 10, -10 - ((i - 1) * 115))
        end

        local mask = UIParent:CreateMaskTexture()
        mask:SetPoint("CENTER", fm.icon, "CENTER", 0, 0)
        mask:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_border.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetSize(60, 60)
        fm.icon:AddMaskTexture(mask)

        fm.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, "SHADOW")
        fm.title:SetTextColor(1, 1, 1, 1)
        fm.desc:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
        fm.desc:SetTextColor(0.8, 0.8, 0.8, 1)
        fm.StatusBar.currentValue:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "SHADOW")
        fm.StatusBar:SetMinMaxValues(0, 1)
        fm.StatusBar:SetValue(0)
        fm.StatusBar:SetStatusBarColor(GW.Colors.FactionBarColors[5]:GetRGB())

        for _, btn in ipairs({fm.btn1, fm.btn2}) do
            btn.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW")
            btn.name:SetTextColor(1, 1, 1, 1)
            btn:SetScript("OnEnter", profButton_OnEnter)
            btn:SetScript("OnLeave", GameTooltip_Hide)
            btn:EnableMouse(true)
            btn:RegisterForDrag("LeftButton")
            btn.unlearn:Hide()
        end

        fm.unlearn:SetScript("OnClick", unlearn_OnClick)
        fm.unlearn:SetScript("OnEnter", unlearn_OnEnter)
        fm.unlearn:SetScript("OnLeave", GameTooltip_Hide)

        fmOverview.profs[i] = fm
    end

    fmOverview:SetScript("OnShow", updateOverview)
    fmOverview:SetScript("OnEvent", function(self)
        if GW.inWorld then
            queueUpdate(self)
        end
    end)
    fmOverview:RegisterEvent("SKILL_LINES_CHANGED")
    fmOverview:RegisterEvent("TRIAL_STATUS_UPDATE")
    fmOverview:RegisterEvent("SPELLS_CHANGED")

    updateOverview(fmOverview)
    return fmOverview
end

---------- embedded crafting frame ----------

local craftingContainer
local fmOverview
local fmMenu

local function ShowOverviewView()
    craftingContainer:Hide()
    fmOverview:Show()
    fmMenu.overviewMenu.activeTexture:Show()
    for _, tab in ipairs(ProfessionsFrame.rightProfessionTabs) do
        tab.activeTexture:Hide()
    end
end

local function ShowCraftingView()
    fmOverview:Hide()
    craftingContainer:Show()
    fmMenu.overviewMenu.activeTexture:Hide()
    local info = Professions.GetProfessionInfo()
    local skillLine = info.parentProfessionID or info.professionID
    for _, tab in ipairs(ProfessionsFrame.rightProfessionTabs) do
        tab.activeTexture:SetShown(tab.skillLine == skillLine)
    end
end

local function KeepInContainer(frame, container)
    hooksecurefunc(frame, "SetParent", function(self, parent)
        if parent ~= container then
            self:SetParent(container)
        end
    end)
    hooksecurefunc(frame, "SetPoint", function(self, _, relativeTo)
        if relativeTo ~= container then
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
            self:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, 0)
        end
    end)
end

local function KeepHidden(frame)
    frame:Hide()
    hooksecurefunc(frame, "Show", frame.Hide)
    hooksecurefunc(frame, "SetShown", function(self, shown)
        if shown then self:Hide() end
    end)
end

local ARROW = "Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png"
local CONTROL_HEIGHT = 24

local function SkinArrowButton(button, rotation)
    button:GwStripTextures()
    button:SetNormalTexture(ARROW)
    button:GetNormalTexture():SetRotation(rotation)
    button:SetPushedTexture(ARROW)
    button:GetPushedTexture():SetRotation(rotation)
    button:SetHighlightTexture(ARROW, "ADD")
    button:GetHighlightTexture():SetRotation(rotation)
    button:GetHighlightTexture():SetAlpha(0.3)
    button:SetSize(20, 20)
end

local function SkinRankBar(rankBar)
    rankBar.Background:Hide()
    rankBar.Border:Hide()
    rankBar.Flare:SetAlpha(0)
    -- the fill keeps blizzards width math (441 of 453), so the bar keeps its size and shrinks by scale
    rankBar.Fill:ClearAllPoints()
    rankBar.Fill:SetPoint("TOPLEFT", rankBar, "TOPLEFT", 6, 0)
    rankBar.Fill:SetHeight(18)
    rankBar:SetSize(453, 18)
    rankBar:SetScale(0.8)
    GW.AddStatusBarFrame(rankBar)
    rankBar.Rank.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "THINOUTLINE")
end

local function AnchorRankBar(page)
    page.RankBar:ClearAllPoints()
    page.RankBar:SetPoint("TOP", page, "TOP", 0, -14)
    page.LinkButton:ClearAllPoints()
    page.LinkButton:SetPoint("LEFT", page.RankBar, "RIGHT", 10, 0)
end

local recipeHeaderFont = CreateFont("GwProfessionsRecipeHeaderFont")
recipeHeaderFont:SetTextColor(1, 1, 1)
recipeHeaderFont:SetFont(DAMAGE_TEXT_FONT, 14, "")

local function SkinRecipeHeader(header)
    header:GwStripTextures()
    header.gwBackground = header:CreateTexture(nil, "BACKGROUND")
    header.gwBackground:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spell-sep.png")
    header.gwBackground:SetAllPoints(header)
    header:SetNormalFontObject(recipeHeaderFont)
    header:SetHighlightFontObject(recipeHeaderFont)
    header:SetDisabledFontObject(recipeHeaderFont)
    header.ButtonText:SetJustifyH("LEFT")
    header.ButtonText:GwLockTextColor(1, 1, 1)
    header.CollapseButton:GwStripTextures()
    header.CollapseButton:SetAlpha(0)
    header.gwArrow = header:CreateTexture(nil, "OVERLAY")
    header.gwArrow:SetTexture(ARROW)
    header.gwArrow:SetSize(24, 24)
    header.gwArrow:SetPoint("RIGHT", header, "RIGHT", -6, 0)
    header.RankBar:SetAlpha(0)
end

local function UpdateRecipeHeaderArrow(header, node)
    header.gwArrow:SetRotation(node:IsCollapsed() and math.pi / 2 or 0)
end

-- own hover and selection textures: the list helper would latch onto blizzards HighlightTexture
-- key, which only blizzard shows
local function SkinRecipeRow(row)
    KeepHidden(row.SelectedOverlay)
    KeepHidden(row.HighlightOverlay)
    row.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    row.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)

    row.gwHoverTexture = row:CreateTexture(nil, "ARTWORK", nil, 0)
    row.gwHoverTexture:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    row.gwHoverTexture:SetVertexColor(0.8, 0.8, 0.8, 0.8)
    row.gwHoverTexture:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.gwHoverTexture:SetPoint("TOP", row, "TOP", 0, 0)
    row.gwHoverTexture:SetPoint("BOTTOM", row, "BOTTOM", 0, 0)
    row.gwHoverTexture:SetPoint("RIGHT", row, "LEFT", 0, 0)
    row.gwHoverTexture:Hide()
    row.limitHoverStripAmount = 1

    row.gwSelected = row:CreateTexture(nil, "ARTWORK", nil, 0)
    row.gwSelected:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
    row.gwSelected:SetVertexColor(0.8, 0.8, 0.8, 1)
    row.gwSelected:SetAllPoints(row)
    row.gwSelected:Hide()

    hooksecurefunc(row, "SetSelected", function(self, selected)
        self.gwSelected:SetShown(selected == true)
    end)
end

-- the rows hand their mouse motion up to the scroll box, so the hover is polled instead of
-- waiting for an OnEnter that never arrives
local function UpdateRecipeHover(scrollBox)
    local hovered
    if scrollBox:IsMouseOver() then
        for _, child in next, {scrollBox.ScrollTarget:GetChildren()} do
            if child.gwHoverTexture and child:IsShown() and child:IsMouseOver() then
                hovered = child
                break
            end
        end
    end
    if hovered == scrollBox.gwHoveredRow then
        if hovered then hovered.gwHoverTexture:Show() end
        return
    end
    if scrollBox.gwHoveredRow then
        scrollBox.gwHoveredRow.gwHoverTexture:Hide()
    end
    scrollBox.gwHoveredRow = hovered
    if hovered then
        hovered.gwHoverTexture:Show()
        GW.TriggerButtonHoverAnimation(hovered, hovered.gwHoverTexture)
    end
end

local function UpdateRecipeListSkins(scrollBox)
    scrollBox:ForEachFrame(function(child, node)
        if not child.gwSkinned then
            if child.CollapseButton then
                SkinRecipeHeader(child)
            elseif child.HighlightOverlay then
                SkinRecipeRow(child)
            end
            child.gwSkinned = true
        end
        if child.gwArrow then
            UpdateRecipeHeaderArrow(child, node)
        end
    end)
end

local function SkinReagentSlots(form)
    for slot in form.reagentSlotPool:EnumerateActive() do
        if not slot.gwSkinned then
            GW.HandleIcon(slot.Button.Icon, true, GW.BackdropTemplates.DefaultWithColorableBorder, true)
            GW.HandleIconBorder(slot.Button.IconBorder, slot.Button.Icon.backdrop)
            slot.Name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
            slot.gwSkinned = true
        end
    end
end

local SCHEMATIC_WIDTH = 330

local function SkinSchematicForm(form)
    form:GwStripTextures()
    KeepHidden(form.Background)
    -- the camelot xml adds a second NineSlice under the same key, the template one stays reachable only as child
    for _, child in ipairs({form:GetChildren()}) do
        if child.TopLeftCorner and child.Center then
            KeepHidden(child)
            child:SetAlpha(0)
        end
    end
    -- the condensed layout asks for 500, that does not fit next to the recipe list
    form:HookScript("OnSizeChanged", function(self, width)
        if width > SCHEMATIC_WIDTH then
            self:SetWidth(SCHEMATIC_WIDTH)
        end
    end)
    form:SetWidth(SCHEMATIC_WIDTH)
    GW.AddDetailsBackground(form)
    -- crafted item: square GW item button instead of the round blizzard medallion
    local output = form.OutputIcon
    output.Icon:RemoveMaskTexture(output.CircleMask)
    GW.HandleItemButton(output, true)
    output:SetSize(44, 44)
    -- blizzard sets a round quality ring on every refresh, it becomes our square border
    output.IconBorder:ClearAllPoints()
    output.IconBorder:SetAllPoints(output)
    hooksecurefunc(output.IconBorder, "SetAtlas", function(self)
        self:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder.png")
    end)
    output.Count:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "THINOUTLINE")
    form.TrackRecipeCheckbox:GwSkinCheckButton(false, 15)
    form.TrackRecipeCheckbox.Text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)

    form.Reagents.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    form.Reagents.Label:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    hooksecurefunc(form, "Init", SkinReagentSlots)
end

local function SkinCraftingPage(page)
    page:GwStripTextures()

    local list = page.RecipeList
    list.Background:Hide()
    list.BackgroundNineSlice:Hide()
    list.NoResultsText:SetTextColor(1, 1, 1)
    list:SetWidth(260)
    list:ClearAllPoints()
    list:SetPoint("TOPLEFT", page, "TOPLEFT", 5, -40)
    list:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 5, 44)
    GW.HandleTrimScrollBar(list.ScrollBar)
    GW.HandleScrollControls(list)
    list.ScrollBar:SetWidth(4)
    list.ScrollBar:GetThumb():SetWidth(4)
    hooksecurefunc(list.ScrollBox, "Update", UpdateRecipeListSkins)
    -- own updater frame, HookScript installs nothing on a frame without an OnUpdate handler
    local hoverUpdater = CreateFrame("Frame", nil, list.ScrollBox)
    hoverUpdater:SetScript("OnUpdate", function() UpdateRecipeHover(list.ScrollBox) end)

    -- search and filter share the top row with the details view, the recipes scroll below them
    list.ScrollBox:ClearAllPoints()
    list.ScrollBox:SetPoint("TOPLEFT", list, "TOPLEFT", 0, -(CONTROL_HEIGHT + 10))
    list.ScrollBox:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -8, 0)
    list.ScrollBar:ClearAllPoints()
    list.ScrollBar:SetPoint("TOPLEFT", list.ScrollBox, "TOPRIGHT", 2, 0)
    list.ScrollBar:SetPoint("BOTTOMLEFT", list.ScrollBox, "BOTTOMRIGHT", 2, 0)
    GW.AddDetailsBackground(list.ScrollBox)

    local search = list.SearchBox
    GW.SkinTextBox(search.Middle, search.Left, search.Right)
    for _, key in ipairs({"TopLeftTex", "TopTex", "TopRightTex", "BottomLeftTex", "BottomTex", "BottomRightTex"}) do
        if search[key] then
            search[key]:Hide()
        end
    end
    -- blizzard hangs the search box on the filter, the filter follows the search box here
    search:ClearAllPoints()
    search:SetPoint("TOPLEFT", list, "TOPLEFT", 4, -2)
    search:SetSize(160, CONTROL_HEIGHT)

    local dropdown = list.FilterDropdown
    dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, 90)
    dropdown:SetSize(90, CONTROL_HEIGHT)
    dropdown.backdrop:ClearAllPoints()
    dropdown.backdrop:SetPoint("TOPLEFT", dropdown, "TOPLEFT", 0, 0)
    dropdown.backdrop:SetPoint("BOTTOMRIGHT", dropdown, "BOTTOMRIGHT", 0, 0)
    dropdown.ResetButton:GwSkinButton(true)
    dropdown.ResetButton:SetSize(14, 14)
    dropdown.ResetButton:ClearAllPoints()
    dropdown.ResetButton:SetPoint("CENTER", dropdown, "TOPRIGHT", -2, -2)
    dropdown:ClearAllPoints()
    dropdown:SetPoint("TOPLEFT", search, "TOPRIGHT", 6, 1)
    dropdown:SetPoint("BOTTOMLEFT", search, "BOTTOMRIGHT", 6, 0)

    page.CreateButton:GwSkinButton(false, true)
    page.CreateAllButton:GwSkinButton(false, true)
    page.ViewGuildCraftersButton:GwSkinButton(false, true)
    local spinner = page.CreateMultipleInputBox
    spinner:GwStripTextures()
    GW.SkinTextBox(spinner.Middle, spinner.Left, spinner.Right, nil, nil, 10)
    SkinArrowButton(spinner.DecrementButton, math.pi / 2)
    SkinArrowButton(spinner.IncrementButton, -math.pi / 2)

    SkinSchematicForm(page.SchematicForm)

    -- one baseline for the three controls: create button right, the counter and create all to its left
    local function AnchorControls()
        page.CreateButton:ClearAllPoints()
        page.CreateButton:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -8, 10)
        spinner:ClearAllPoints()
        spinner:SetPoint("RIGHT", page.CreateButton, "LEFT", -40, 0)
        page.CreateAllButton:ClearAllPoints()
        page.CreateAllButton:SetPoint("RIGHT", spinner, "LEFT", -60, 0)
    end
    AnchorControls()
    hooksecurefunc(page, "SetControlAnchors", AnchorControls)

    SkinRankBar(page.RankBar)
    AnchorRankBar(page)
    hooksecurefunc(page, "SetRankBarAnchors", AnchorRankBar)
end

---------- menu ----------

local MENU_BG = "Interface/AddOns/GW2_UI/textures/character/menu-bg.png"
local MENU_HOVER = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"

local function IsOpenProfession(tab)
    local base = C_TradeSkillUI.GetBaseProfessionInfo()
    return ProfessionsFrame:IsShown() and base and base.professionID == tab.skillLine
end

-- attributes are prepared out of combat: casting the open profession would toggle it closed
local function UpdateCastOverlay(tab)
    if InCombatLockdown() then return end
    local info = tab.spellOffsetIndex and C_SpellBook.GetSpellBookItemInfo(tab.spellOffsetIndex + 1, Enum.SpellBookSpellBank.Player)
    tab.gwCast:SetAttribute("spell", info and info.spellID)
    tab.gwCast:SetAttribute("type", IsOpenProfession(tab) and "gwnone" or "spell")
end

local function UpdateCastOverlays()
    for _, tab in ipairs(ProfessionsFrame.rightProfessionTabs) do
        UpdateCastOverlay(tab)
    end
end

local function LayoutProfessionMenu()
    local previous = fmMenu.overviewMenu
    local index = 0
    for _, tab in ipairs(ProfessionsFrame.rightProfessionTabs) do
        if tab:IsShown() then
            index = index + 1
            tab.gwText:SetText(tab.tooltipText)
            tab.gwBackground:SetShown(index % 2 == 0)
            tab:ClearAllPoints()
            tab:SetPoint("TOPLEFT", previous, "BOTTOMLEFT")
            UpdateCastOverlay(tab)
            previous = tab
        end
    end
end

local function AdoptProfessionTab(tab)
    tab:SetParent(fmMenu)
    tab:SetFrameLevel(fmMenu:GetFrameLevel() + 1)
    tab:SetSize(231, 36)
    tab:Hide()
    for _, key in ipairs({"Background", "SelectedTexture", "TabGlow", "HighlightTexture", "Mask", "Icon"}) do
        tab[key]:Hide()
    end

    tab.gwBackground = tab:CreateTexture(nil, "BACKGROUND")
    tab.gwBackground:SetAllPoints()
    tab.gwBackground:SetTexture(MENU_BG)

    tab.gwText = tab:CreateFontString(nil, "OVERLAY")
    tab.gwText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    tab.gwText:SetJustifyH("LEFT")
    tab.gwText:SetPoint("LEFT", tab, "LEFT", 5, 0)

    tab.arrow = tab:CreateTexture(nil, "ARTWORK")
    tab.arrow:SetSize(10, 20)
    tab.arrow:SetPoint("RIGHT", tab, "RIGHT")
    tab.arrow:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-arrow.png")

    tab.activeTexture = tab:CreateTexture(nil, "OVERLAY")
    tab.activeTexture:SetAllPoints()
    tab.activeTexture:SetTexture(MENU_HOVER)
    tab.activeTexture:Hide()

    tab:GwAddHover()
    tab.hover:SetTexture(MENU_HOVER)
    tab.limitHoverStripAmount = 1
    -- Blizzard lets every tab cast its profession when the frame shows, which opens the wrong one
    EventRegistry:UnregisterCallback("ProfessionsFrame.Show", tab)

    hooksecurefunc(tab, "SetChecked", function(self, checked)
        self.SelectedTexture:Hide()
        self.activeTexture:SetShown(checked)
    end)

    -- Blizzard's own click skips the cast while the closed profession still counts as selected,
    -- so the overlay takes every click: OpenTradeSkill first, the profession spell as fallback
    tab.gwCast = CreateFrame("Button", nil, tab, "SecureActionButtonTemplate")
    tab.gwCast:SetAllPoints()
    tab.gwCast:RegisterForClicks("AnyUp", "AnyDown")
    tab.gwCast:SetAttribute("type", "spell")
    tab.gwCast:SetScript("PreClick", function(self, _, down)
        if InCombatLockdown() or down ~= GetCVarBool("ActionButtonUseKeyDown") or IsOpenProfession(tab) then return end
        self:SetAttribute("type", C_TradeSkillUI.OpenTradeSkill(tab.skillLine) and "gwnone" or "spell")
    end)
    tab.gwCast:SetScript("PostClick", function()
        if ProfessionsFrame:IsShown() then
            ShowCraftingView()
        end
    end)
    tab.gwCast:SetScript("OnEnter", function() GwStandardButton_OnEnter(tab) end)
    tab.gwCast:SetScript("OnLeave", function() GwStandardButton_OnLeave(tab) end)
end

local function EmbedProfessionsFrame()
    -- without the UI panel layout ShowUIPanel/HideUIPanel are plain Show/Hide
    ProfessionsFrame:SetAttribute("UIPanelLayout-defined", false)
    ProfessionsFrame:SetAttribute("UIPanelLayout-enabled", false)
    ProfessionsFrame:SetAttribute("UIPanelLayout-area", nil)

    -- both corners anchored: the frame follows the container whatever Blizzard sets as width
    ProfessionsFrame:SetParent(craftingContainer)
    ProfessionsFrame:SetScale(PANEL_WIDTH / BLIZZARD_PAGE_WIDTH)
    ProfessionsFrame:ClearAllPoints()
    ProfessionsFrame:SetPoint("TOPLEFT", craftingContainer, "TOPLEFT", 0, 0)
    ProfessionsFrame:SetPoint("BOTTOMRIGHT", craftingContainer, "BOTTOMRIGHT", 0, 0)
    KeepInContainer(ProfessionsFrame, craftingContainer)

    ProfessionsFrame:GwStripTextures()
    for _, key in ipairs({"NineSlice", "PortraitContainer", "TitleContainer", "CloseButton", "TabIndicators", "ProfessionsOverviewTab", "BookPage"}) do
        KeepHidden(ProfessionsFrame[key])
    end
    for _, tab in ipairs(ProfessionsFrame.rightProfessionTabs) do
        AdoptProfessionTab(tab)
    end
    hooksecurefunc(ProfessionsFrame, "RefreshRightTabs", LayoutProfessionMenu)
    -- fills the tabs before Blizzard's first secure refresh; the overlay takes the clicks anyway
    ProfessionsFrame:RefreshRightTabs()

    SkinCraftingPage(ProfessionsFrame.CraftingPage)

    -- the overview side tab and the book page are ours now
    hooksecurefunc(ProfessionsFrame, "SelectBookPage", function(self)
        self.CraftingPage:Show()
        if not InCombatLockdown() then
            GwCharacterWindow:SetAttribute("windowpanelopen", "professions")
        end
        ShowOverviewView()
    end)

    local function BringCraftingViewUp()
        if not craftingContainer:GetParent():IsShown() and not InCombatLockdown() then
            GwCharacterWindow:SetAttribute("windowpanelopen", "professions")
        end
        ShowCraftingView()
    end
    ProfessionsFrame:HookScript("OnShow", function()
        BringCraftingViewUp()
        UpdateCastOverlays()
    end)
    ProfessionsFrame:HookScript("OnHide", function()
        if craftingContainer:IsShown() then
            ShowOverviewView()
        end
        UpdateCastOverlays()
    end)

    local sync = CreateFrame("Frame")
    for _, event in ipairs({"SKILL_LINES_CHANGED", "PLAYER_ENTERING_WORLD", "TRADE_SKILL_SHOW", "TRADE_SKILL_LIST_UPDATE", "TRADE_SKILL_CLOSE", "PLAYER_REGEN_ENABLED"}) do
        sync:RegisterEvent(event)
    end
    sync:SetScript("OnEvent", function(_, event)
        if event == "TRADE_SKILL_SHOW" and ProfessionsFrame:IsShown() then
            BringCraftingViewUp()
        elseif (event == "SKILL_LINES_CHANGED" or event == "PLAYER_ENTERING_WORLD") and not ProfessionsFrame:IsShown() and not InCombatLockdown() then
            ProfessionsFrame:RefreshRightTabs()
        end
        UpdateCastOverlays()
    end)
end

local function LoadProfessions(tabContainer)
    fmMenu = CreateFrame("Frame", nil, tabContainer, "GwCharacterPanelMenuTemplate")
    fmOverview = loadOverview(tabContainer)
    craftingContainer = CreateFrame("Frame", "GwProfessionsCrafting", tabContainer, "GwProfessionsOverview")
    craftingContainer:Hide()
    craftingContainer:SetScript("OnHide", function()
        ProfessionsFrame:Hide()
    end)
    tabContainer:HookScript("OnShow", function()
        if not ProfessionsFrame:IsShown() then
            ShowOverviewView()
        end
    end)

    fmMenu.overviewMenu = CreateFrame("Button", nil, fmMenu, "GwCharacterPanelMenuButtonTemplate")
    fmMenu.overviewMenu:SetText(OVERVIEW)
    fmMenu.overviewMenu:GetFontString():GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    fmMenu.overviewMenu:ClearAllPoints()
    fmMenu.overviewMenu:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")
    fmMenu.overviewMenu:SetScript("OnClick", function()
        ProfessionsFrame:Hide()
        ShowOverviewView()
    end)
    CharacterMenuButton_OnLoad(fmMenu.overviewMenu, false)
    fmMenu.overviewMenu.activeTexture:Show()

    -- loaded at login so the tabs exist before the first open
    C_AddOns.LoadAddOn("Blizzard_Professions")
    EmbedProfessionsFrame()
end
GW.LoadProfessions = LoadProfessions
