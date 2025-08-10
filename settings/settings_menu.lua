local _, GW = ...
local GwSettingsMenuSearchable

local btnIndex = 0
local newButtonAnchorPoint = nil
local menuButtons = {}

local GwSettingsSearchResultPanel
local matchingOptionFrames = {}
local breadCrumbPool, breadCrumbActive = {}, {}
local lastQuery = ""

local function CharacterMenuButton_OnLoad(self, odd, hasArrow, margin, isSubCat)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    if odd then
        self:ClearNormalTexture()
    else
        self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
    end

    self.arrow:ClearAllPoints()
    self.arrow:SetPoint("LEFT", 10, 0)
    self.arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right")
    self.arrow:SetSize(16, 16)
    if not hasArrow then
        self.arrow:Hide()
        self.text:SetPoint("LEFT", self, "LEFT", margin + (isSubCat and 0 or 20), 0)
    else
        self.text:SetPoint("LEFT", self, "LEFT", margin, 0)
    end
end

--create pool for search result breadcrumbs
local function acquireBreadCrumb()
    local f = tremove(breadCrumbPool)
    if not f then
        f = CreateFrame("Frame", nil, GwSettingsSearchResultPanel.scroll.scrollchild, "GwSettingsSearchBreadCrumb")
        f.header:SetFont(DAMAGE_TEXT_FONT, 20)
        f.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r, GW.TextColors.LIGHT_HEADER.g, GW.TextColors.LIGHT_HEADER.b)
        f.header:SetWordWrap(false)
        f.header:SetNonSpaceWrap(true)
        f.header:SetMaxLines(1)
        f.header:SetJustifyH("LEFT")
        f.header:SetHeight(25)

        f.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
        f.breadcrumb:SetTextColor(GW.TextColors.LIGHT_HEADER.r, GW.TextColors.LIGHT_HEADER.g, GW.TextColors.LIGHT_HEADER.b)
        f.breadcrumb:SetWordWrap(false)
        f.breadcrumb:SetNonSpaceWrap(true)
        f.breadcrumb:SetMaxLines(1)
        f.breadcrumb:SetJustifyH("LEFT")
        f.breadcrumb:SetHeight(25)
    end
    f:Show()
    breadCrumbActive[#breadCrumbActive + 1] = f
    return f
end

local function hideBreadCrumbFrames()
    for i = 1, #breadCrumbActive do
        local f = breadCrumbActive[i]
        f:Hide()
        f:ClearAllPoints()
        f.header:SetText("")
        f.breadcrumb:SetText("")
        breadCrumbPool[#breadCrumbPool + 1] = f -- zurück in den Pool
    end
    wipe(breadCrumbActive)
end

local function updateScrollFrame(self)
    local height = 0
local counter = 0
    for i = 1, #menuButtons do
        local b = menuButtons[i]
        height = height + b:GetHeight()
        if b.content:IsVisible() then
            height = height + b.content.height
            counter = counter + 1
        end
    end

    local viewport = self.scroll:GetHeight() or 0
    local contentH = math.max(viewport + 1, height)

    self.scroll.scrollchild:SetHeight(contentH)
    self.scroll.scrollchild:SetWidth((self.scroll:GetWidth() or 0) - 20)

    local scrollMax = math.max(0, contentH - viewport)
    self.scroll.slider:SetMinMaxValues(0, scrollMax)

    local thumbH = (self.scroll.slider:GetHeight() or 0) * (viewport / ((scrollMax + viewport) > 0 and (scrollMax + viewport) or 1))
    self.scroll.slider.thumb:SetHeight(math.max(8, thumbH))
    self.scroll.slider.thumb:SetShown(scrollMax > 0)
    self.scroll.slider:SetShown(scrollMax > 0)

    if scrollMax > 0 and not self.scroll._sliderInit then
        self.scroll.slider:SetValue(0)
        self.scroll._sliderInit = true
    end

    local cur = self.scroll.slider:GetValue() or 0
    local clamped = math.min(cur, scrollMax)
    self.scroll.slider:SetValue(clamped)

    self.scroll.maxScroll = scrollMax
end

local function toggleMenuItem(self,active)
    if active then
        self.content:Show()
        self.button.arrow:SetRotation(0)
        self.content:SetHeight(self.content.height + self:GetHeight())
        updateScrollFrame(GwSettingsMenuSearchable)
        GW.AddToAnimation(self:GetDebugName(), 0,1, GetTime(), 0.2,
            function(p) self.button.arrow:SetRotation(-1.5707 * p) end,
            "noease")
        return
    end
    self.content:Hide()
    self.content:SetHeight(0)
    updateScrollFrame(GwSettingsMenuSearchable)
    --can be done with animation groups
    GW.AddToAnimation(self:GetDebugName(), 1,0, GetTime(), 0.2,
        function(p) self.button.arrow:SetRotation(-1.5707 * p) end,
        "noease")
end
local function resetMenu(collapse)
    for _, menuItem in pairs(menuButtons) do
        if menuItem.content.buttonCount > 0 then
            for _, subButton in pairs(menuItem.content.buttons) do
            subButton.activeTexture:Hide()
            end
        end
        menuItem.button.activeTexture:Hide()
        if menuItem.content:IsVisible() and collapse then
            toggleMenuItem(menuItem, false)
        end
    end
end
GW.ResetSettingsMenuCategories = resetMenu

local function resetSearchables()
    for _, of in pairs(matchingOptionFrames) do
        of:ClearAllPoints()
        of:SetParent(of.searchAble.og_parent)
        of:SetPoint(of.searchAble.og_point, of.searchAble.og_relativePoint, of.searchAble.og_x, of.searchAble.og_y)
    end

    matchingOptionFrames = {}
end

GW.lastSelectedSettingsMenuCategorie = {
    button = nil,
    basePanel = nil,
    panelFrame = nil
}
local function switchCat(self, basePanel, panelFrame)
    local settings_cat = GW.getSettingsCat()
    resetSearchables()
    if self then
        self.activeTexture:Show()
    end
    --hide search results
    GwSettingsSearchResultPanel:Hide()

    for _, l in ipairs(settings_cat) do
        l.cat_panel:Hide()

        if l.cat_scrollFrames then
            for _, v in ipairs(l.cat_scrollFrames) do
                v:Hide()
                GW.UpdateSettingsFrameScrollVisibility(v)
            end
        end
    end
    basePanel:Show()

    if panelFrame then
        panelFrame:Show()
        GW.UpdateSettingsFrameScrollVisibility(panelFrame)
    end

    GW.lastSelectedSettingsMenuCategorie.button = self
    GW.lastSelectedSettingsMenuCategorie.basePanel = basePanel
    GW.lastSelectedSettingsMenuCategorie.panelFrame = panelFrame
end
GW.SwitchSettingsMenuCategorie = switchCat

local function searchInputChanged(self)
    if not self:HasFocus() then return end

    local raw = self:GetText()
    if not raw or raw == "" or raw == SEARCH then
        self.clearButton:Hide()
        return
    end

    local query = raw:lower()
    if query == lastQuery then return end
    lastQuery = query

    resetMenu(true)
    hideBreadCrumbFrames()
    self:SetTextColor(1, 1, 1)
    switchCat(nil, GwSettingsSearchResultPanel)
    self.clearButton:Show()

    local box_padding, pY = 8, -48
    local padding = {x = box_padding, y = 0}
    local numRows, first = 0, true
    local maximumXSize = GwSettingsSearchResultPanel.scroll:GetWidth() - 2 * box_padding

    GwSettingsSearchResultPanel.sub:Show()

    for _, panel in pairs(GW.getOptionReference()) do
        first = true
        for _, of in pairs(panel.options) do
            local t = of.displayName and of.displayName:lower()
            local g = of.groupHeaderName and of.groupHeaderName:lower()
            if (t and t:find(query, 1, true)) or (g and g:find(query, 1, true)) then
                GwSettingsSearchResultPanel.sub:Hide()
                -- get the original points and save them for later when we need to put the frame back, also save the dropdown container parent
                if not of.searchAble then
                    local point, relativeTo, _, xOfs, yOfs = of:GetPoint()
                    of.searchAble = {
                        og_parent = of:GetParent(),
                        og_point = point,
                        og_relativePoint = relativeTo,
                        og_x = xOfs, og_y = yOfs,
                    }
                end
                matchingOptionFrames[#matchingOptionFrames + 1] = of

                if first then
                    local breadCrumb = acquireBreadCrumb()
                    breadCrumb:SetWidth(GwSettingsSearchResultPanel.scroll.scrollchild:GetWidth() - 8)
                    breadCrumb.header:SetText(panel.header)
                    breadCrumb.breadcrumb:SetText(panel.breadCrumb)
                    breadCrumb:ClearAllPoints()
                    breadCrumb:SetPoint("TOPLEFT", GwSettingsSearchResultPanel.scroll.scrollchild, "TOPLEFT", box_padding, padding.y)
                    padding.y = padding.y + (pY + box_padding)
                    padding.x = box_padding
                    numRows = numRows + 1
                end

                if (of.newLine and not first) or padding.x > maximumXSize then
                    padding.y = padding.y + (pY + box_padding)
                    padding.x = box_padding
                    numRows = numRows + 1
                end

                if first then first = false end

                of:ClearAllPoints()
                of:SetParent(GwSettingsSearchResultPanel.scroll.scrollchild)
                of:SetPoint("TOPLEFT", GwSettingsSearchResultPanel.scroll.scrollchild, "TOPLEFT", padding.x, padding.y)

                if not of.newLine then
                    padding.x = padding.x + of:GetWidth() + box_padding
                else
                    padding.x = maximumXSize + 10
                end

            end
        end
        -- leave room for the next breakcrumb title
        if not first then
            padding.y = padding.y + (pY + box_padding)
            padding.x = box_padding + 10
            numRows = numRows + 1
        end
    end

    local contentH = math.max(GwSettingsSearchResultPanel:GetHeight(), numRows * 40 + 50)
    GwSettingsSearchResultPanel.scroll.scrollchild:SetHeight(contentH)
    GwSettingsSearchResultPanel.scroll.scrollchild:SetWidth(GwSettingsSearchResultPanel.scroll:GetWidth() - 20)
    local scrollMax = math.max(0, contentH - GwSettingsSearchResultPanel.scroll:GetHeight())
    GwSettingsSearchResultPanel.scroll.slider:SetMinMaxValues(0, scrollMax)
    local thumbH = GwSettingsSearchResultPanel.scroll.slider:GetHeight() * (GwSettingsSearchResultPanel.scroll:GetHeight() / (scrollMax + GwSettingsSearchResultPanel.scroll:GetHeight()))
    GwSettingsSearchResultPanel.scroll.slider.thumb:SetHeight(thumbH)
    GwSettingsSearchResultPanel.scroll.maxScroll = scrollMax
end

local function settingsMenuAddButton(name, basePanel, frames)
    --Create base menu item button and container
    local menuItem = CreateFrame("Frame", name .. "GwSearchableItem", GwSettingsMenuSearchable.scroll.scrollchild, "GwSettingsMenuSearchableItem")

    menuButtons[#menuButtons + 1] = menuItem

    --anchor menuItem to last button if any
    if newButtonAnchorPoint then
        menuItem:SetPoint("TOPLEFT", newButtonAnchorPoint, "BOTTOMLEFT", 0, 0)
    else
        menuItem:SetPoint("TOPLEFT", GwSettingsMenuSearchable.scroll.scrollchild, "TOPLEFT", 0, 0)
    end

    hooksecurefunc(menuItem.content, "SetHeight", function(_, height)
        menuItem.contentSizer:SetHeight(math.max(36, height))
    end)

    menuItem.button.text:SetText(name)

    --load button styling
    local zebra = false

    --set default button count and height for margins of sub buttons
    menuItem.content.buttonCount = 0
    menuItem.content.height = 0
    menuItem.content.buttons = {}

    menuItem.basePanel = basePanel

    -- create sub buttons for each panel
    for _, panelFrame in pairs(frames) do
        panelFrame:Hide()
        local subButton = CreateFrame("Button", name .. "GwSearchableSubButton" .. menuItem.content.buttonCount, menuItem.content, "GwSettingsMenuSearchableSubButton")

        --Grab the breadcrumb title from the panel
        subButton.text:SetText(panelFrame.breadcrumb:GetText())

        -- set parent button needed
        subButton.parentButton = menuItem
        subButton.refFrame = panelFrame
        --anchor subbutton to content frame
        subButton:SetPoint("TOPLEFT", menuItem.content, "TOPLEFT", 0, menuItem.content.buttonCount * -subButton:GetHeight())
        --save total height for later usage
        menuItem.content.height = menuItem.content.height + subButton:GetHeight()
        menuItem.content.buttons[menuItem.content.buttonCount] = subButton
        zebra = (menuItem.content.buttonCount % 2) == 1
        CharacterMenuButton_OnLoad(subButton, zebra, false, 40, true)

        --setup click handler for showing panels
        subButton:SetScript("OnClick",function()
            resetMenu(false)
            switchCat(subButton, basePanel, panelFrame)
            GwSettingsMenuSearchable.search.input:SetTextColor(178 / 255, 178 / 255, 178 / 255)
            GwSettingsMenuSearchable.search.input:SetText(SEARCH)
        end)

        menuItem.content.buttonCount = menuItem.content.buttonCount + 1
    end

    zebra = (btnIndex % 2) == 1 or false
    if menuItem.content.buttonCount > 0 then
        CharacterMenuButton_OnLoad(menuItem.button, zebra, true, 30)
        -- set click action depending on child frames
        menuItem.button:SetScript("OnClick", function()
            local shouldShow = not menuItem.content:IsVisible()
            --Only display first panel if we toggle on
            resetMenu(true)
            if shouldShow then
                local firstChild = menuItem.content.buttons[0] or menuItem.content.buttons[1]
                if firstChild then
                    switchCat(firstChild, basePanel, firstChild.refFrame)
                else
                    switchCat(menuItem.button, basePanel)
                end
            end
            --Display submenu
            toggleMenuItem(menuItem, shouldShow)
            GwSettingsMenuSearchable.search.input:SetTextColor(178 / 255, 178 / 255, 178 / 255)
            GwSettingsMenuSearchable.search.input:SetText(SEARCH)
        end)
        -- hide conent frame by default
        menuItem.content:Hide()
        menuItem.content:SetHeight(0)
    else
        -- if no child frames we just toggle
        CharacterMenuButton_OnLoad(menuItem.button, zebra, false, 10)
        menuItem.button:SetScript("OnClick", function()
            resetMenu(true)
            switchCat(menuItem.button, basePanel)
        end)
    end

    --Assign next buttons anchorpoint
    newButtonAnchorPoint = menuItem.contentSizer
    btnIndex = btnIndex + 1
end
GW.settingsMenuAddButton = settingsMenuAddButton;

local function settingMenuToggle(toggle)
    if toggle then
        GwSettingsMenuSearchable:Show()
    else
        GwSettingsMenuSearchable:Hide()
    end
    GwSettingsSearchResultPanel:Hide()
end
GW.settingMenuToggle = settingMenuToggle

local function loadSettingsSearchAbleMenu()
    GwSettingsMenuSearchable = CreateFrame("Frame", "GwSettingsMenuSearchable",GwSettingsWindow,"GwSettingsMenuSearchable")
    GwSettingsMenuSearchable.scroll:SetScrollChild(GwSettingsMenuSearchable.scroll.scrollchild)

    GwSettingsSearchResultPanel = CreateFrame("Frame", "GwSettingsSearchResultPanel",GwSettingsWindow.panels,"GwSettingsSearchResultPanel")
    GwSettingsSearchResultPanel.header:SetFont(DAMAGE_TEXT_FONT, 20)
    GwSettingsSearchResultPanel.header:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    GwSettingsSearchResultPanel.header:SetText(SEARCH)
    GwSettingsSearchResultPanel.sub:SetFont(UNIT_NAME_FONT, 12)
    GwSettingsSearchResultPanel.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    GwSettingsSearchResultPanel.sub:SetText(SETTINGS_SEARCH_NOTHING_FOUND)
    GwSettingsSearchResultPanel:Hide()
    GwSettingsSearchResultPanel.scroll:SetScrollChild(GwSettingsSearchResultPanel.scroll.scrollchild)

    -- joink!
    local fnGWP_input_OnEscapePressed = function(self)
        self:ClearFocus()
    end
    local fnGWP_input_OnEnterPressed = function(self)
        self:ClearFocus()
    end
    GwSettingsMenuSearchable.search.input:SetFont(UNIT_NAME_FONT, 14, "")
    GwSettingsMenuSearchable.search.input:SetTextColor(178 / 255, 178 / 255, 178 / 255)
    GwSettingsMenuSearchable.search.input:SetText(SEARCH)
    GwSettingsMenuSearchable.search.input:SetScript("OnEscapePressed", fnGWP_input_OnEscapePressed)
    GwSettingsMenuSearchable.search.input:SetScript("OnEditFocusGained", function(self) if self:GetText()==SEARCH then self:SetText("") end self.clearButton:Show() end)
    GwSettingsMenuSearchable.search.input:SetScript("OnEditFocusLost", function(self) if self:GetText()==nil or self:GetText()=="" then self:SetTextColor(178 / 255, 178 / 255, 178 / 255) self:SetText(SEARCH) self.clearButton:Hide() end end)
    GwSettingsMenuSearchable.search.input:SetScript("OnEnterPressed", fnGWP_input_OnEnterPressed)
    GwSettingsMenuSearchable.search.input:SetScript("OnTextChanged", searchInputChanged)
    GwSettingsMenuSearchable.search.input.clearButton:SetScript("OnClick", function(self)
        local edit = self:GetParent()
        edit:ClearFocus()
        edit:SetText(SEARCH)
        edit:SetTextColor(178 / 255, 178 / 255, 178 / 255)
        hideBreadCrumbFrames()
        resetSearchables()
        GW.SettingsFrameSwitchCategorieModule(2)
    end)


    -- load the scrollbox on first load
    GwSettingsMenuSearchable.firstTimeLoaded = true
    GwSettingsMenuSearchable:HookScript("OnShow", function()
        if GwSettingsMenuSearchable.firstTimeLoaded then
            resetMenu(true)
            switchCat(_G[GW.L["Modules"] .. "GwSearchableItem"].button, _G[GW.L["Modules"] .. "GwSearchableItem"].basePanel)
            GwSettingsMenuSearchable.firstTimeLoaded = false
        end
        updateScrollFrame(GwSettingsMenuSearchable)
    end)
end
GW.loadSettingsSearchAbleMenu  = loadSettingsSearchAbleMenu
