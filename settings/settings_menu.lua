local _, GW = ...
local GwSettingsMenuSearchable
local AddToAnimation

local btnIndex = 0
local newButtonAnchorPoint = nil
local menuButtons = {}

local GwSettingsSearchResultPanel;
local matchingOptionFrames = {}

local function CharacterMenuButton_OnLoad(self, odd, hasArrow, margin, isSubCat)
    self.hover:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
    self.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
    if odd then
        self:ClearNormalTexture()
    else
        self:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-bg")
    end

    self:GetFontString():SetTextColor(255 / 255, 241 / 255, 209 / 255)
    self:GetFontString():SetShadowColor(0, 0, 0, 0)
    self:GetFontString():SetShadowOffset(1, -1)
    self:GetFontString():SetFont(DAMAGE_TEXT_FONT, 14)
    self:GetFontString():SetJustifyH("LEFT")
    self.arrow:ClearAllPoints();
    self.arrow:SetPoint("LEFT", 10, 0)
    self.arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right")
    self.arrow:SetSize(16, 16)
    if not hasArrow then
        self.arrow:Hide()
        self:GetFontString():SetPoint("LEFT", self, "LEFT", margin + (isSubCat and 0 or 20), 0)
    else
        self:GetFontString():SetPoint("LEFT", self, "LEFT", margin, 0)
    end
end

--create pool for search result breadcrumbs
local breadCrumbPool = {}
local function createBreadCrumbFrame()
    local f = CreateFrame("Frame", nil,GwSettingsSearchResultPanel.scroll.scrollchild,"GwSettingsSearchBreadCrumb")

    f.header:SetFont(DAMAGE_TEXT_FONT, 20)
    f.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    f.breadcrumb:SetFont(DAMAGE_TEXT_FONT, 12)
    f.breadcrumb:SetTextColor(255 / 255, 241 / 255, 209 / 255)

    breadCrumbPool[#breadCrumbPool + 1] = f
    return f
end

local function hideBreadCrumbFrames()
  for i=1,#breadCrumbPool do
      local f = breadCrumbPool[i]
      f:Hide()
  end
end

local function updateScrollFrame(self)
    local height = 0
    for i=1,#menuButtons do
        local b = menuButtons[i]
        height = height + b:GetHeight()
        if b.content:IsVisible() then
        height = height + b.content.height
        end
    end

    local scrollMax = max(0, height - self.scroll:GetHeight())

    if scrollMax==0 then
        self.scroll.slider.thumb:Hide()
    else
        self.scroll.slider.thumb:Show()
    end

    self.scroll.scrollchild:SetHeight(self.scroll:GetHeight())
    self.scroll.scrollchild:SetWidth(self.scroll:GetWidth() - 20)
    self.scroll.slider:SetMinMaxValues(0, scrollMax)
    --Calculate how big the thumb is this is IMPORTANT for UX :<
    self.scroll.slider.thumb:SetHeight(self.scroll.slider:GetHeight() * (self.scroll:GetHeight() / (scrollMax + self.scroll:GetHeight())) )
    self.scroll.slider:SetValue(1)
    self.scroll.maxScroll = scrollMax
end

local function toggleMenuItem(self,active)
    if AddToAnimation==nil then
        AddToAnimation = GW.AddToAnimation
    end
    if active then
        self.content:Show()
        self.button.arrow:SetRotation(0)
        self.content:SetHeight(self.content.height)
        updateScrollFrame(GwSettingsMenuSearchable)
        AddToAnimation(self:GetName(), 0,1, GetTime(), 0.2, function(p)
            self.button.arrow:SetRotation(-1.5707*p)
        end, "noease")

        return
    end
    self.content:Hide()
    self.content:SetHeight(0)
    updateScrollFrame(GwSettingsMenuSearchable)
    --can be done with animation groups
    AddToAnimation(self:GetName(), 1,0, GetTime(), 0.2, function(p)
        self.button.arrow:SetRotation(-1.5707*p)
    end, "noease")

end
local function resetMenu(collapse)
    for _,menuItem in pairs(menuButtons) do
        if menuItem.content.buttonCount>0 then
            for _, subButton in pairs(menuItem.content.buttons) do
            subButton.activeTexture:Hide()
            end
        end
        menuItem.button.activeTexture:Hide()
        if menuItem.content:IsVisible() and collapse then
            toggleMenuItem(menuItem,false)
        end
    end
end
GW.ResetSettingsMenuCategories = resetMenu

local function resetSearchables()
    for _, of in pairs(matchingOptionFrames) do
        of:ClearAllPoints()
        of:SetParent(of.searchAble.og_parent)
        of:SetPoint(of.searchAble.og_point ,of.searchAble.og_relativePoint, of.searchAble.og_x, of.searchAble.og_y)
        if of.searchAble.og_dd_container_parent then
            of.container:SetParent(of.searchAble.og_dd_container_parent)
        end
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
        --  l.iconbg:Hide()
        l.cat_panel:Hide()

        if l.cat_crollFrames then
            for _, v in pairs(l.cat_crollFrames) do
                v:Hide()
            end
        end
        -- hide all profiles
        if l.cat_profilePanels then
            for _, pp in ipairs(l.cat_profilePanels) do
                pp:Hide()
            end
        end
    end
    basePanel:Show()

    if panelFrame then
        panelFrame:Show()
    end

    GW.lastSelectedSettingsMenuCategorie.button = self
    GW.lastSelectedSettingsMenuCategorie.basePanel = basePanel
    GW.lastSelectedSettingsMenuCategorie.panelFrame = panelFrame
end
GW.SwitchSettingsMenuCategorie = switchCat

local function searchInputChanged(self)
    if not self:HasFocus() then return end

    local text = self:GetText()
    if text == nil or text == "" then
        return
    end
    if text == SEARCH then
        return
    end
    resetMenu(true)
    hideBreadCrumbFrames()
    self:SetTextColor(1, 1, 1)
    switchCat(nil, GwSettingsSearchResultPanel)

    local box_padding = 8
    local pY = -48
    local padding = {x = box_padding, y = 0}
    local numRows = 0
    local maximumXSize = 440
    local first = true
    GwSettingsSearchResultPanel.sub:Show()

    for _, panel in pairs(GW.getOptionReference()) do
        first = true
        for _, of in pairs(panel.options) do

            local titleText = of.displayName
            local groupHeaderName = of.groupHeaderName and of.groupHeaderName:lower() or nil
            titleText = titleText:lower()
            text = text:lower()
            if titleText ~= nil and (string.find(titleText, text, 1, true) or (groupHeaderName and string.find(groupHeaderName, text, 1, true))) and of.optionType ~= "header" then
                GwSettingsSearchResultPanel.sub:Hide()
                -- get the original points and save them for later when we need to put the frame back, also save the dropdown container parent
                local point, relativeTo, _, xOfs, yOfs = of:GetPoint()
                of.searchAble = {
                    og_parent = of:GetParent(),
                    og_point = point,
                    og_relativePoint = relativeTo,
                    og_x = xOfs,
                    og_y = yOfs,
                    og_dd_container_parent = nil
                }
                if of.optionType == "dropdown" then
                    of.searchAble.og_dd_container_parent = of.container:GetParent()
                end
                matchingOptionFrames[#matchingOptionFrames + 1] = of

                if first then
                    local breadCrumb = createBreadCrumbFrame()
                    breadCrumb.header:SetText(panel.header)
                    breadCrumb.header:SetWidth(breadCrumb.header:GetStringWidth())
                    breadCrumb.breadcrumb:SetText(panel.breadCrumb)

                    breadCrumb:ClearAllPoints()
                    breadCrumb:SetPoint("TOPLEFT", GwSettingsSearchResultPanel.scroll.scrollchild, "TOPLEFT", box_padding, padding.y)
                    padding.y = padding.y + (pY + box_padding)
                    padding.x = box_padding
                    numRows = numRows + 1
                end

                if (of.newLine and not first) or padding.x > maximumXSize  then
                    padding.y = padding.y + (pY + box_padding)
                    padding.x = box_padding
                    numRows = numRows + 1
                end

                if first then
                    first = false
                end

                of:ClearAllPoints()
                of:SetParent(GwSettingsSearchResultPanel.scroll.scrollchild)
                of:SetPoint("TOPLEFT", GwSettingsSearchResultPanel.scroll.scrollchild, "TOPLEFT", padding.x, padding.y)
                if of.optionType == "dropdown" then
                  of.container:SetParent(GwSettingsSearchResultPanel.scroll)
                end

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

    local scrollMax = max(0, numRows * 40 - GwSettingsSearchResultPanel:GetHeight() + 50)
    GwSettingsSearchResultPanel.scroll.scrollchild:SetHeight(GwSettingsSearchResultPanel:GetHeight())
    GwSettingsSearchResultPanel.scroll.scrollchild:SetWidth(GwSettingsSearchResultPanel.scroll:GetWidth() - 20)
    GwSettingsSearchResultPanel.scroll.slider:SetMinMaxValues(0, scrollMax)
    --Calculate how big the thumb is this is IMPORTANT for UX :<
    GwSettingsSearchResultPanel.scroll.slider.thumb:SetHeight(GwSettingsSearchResultPanel.scroll.slider:GetHeight() * (GwSettingsSearchResultPanel:GetHeight() / (scrollMax + GwSettingsSearchResultPanel:GetHeight())) )

    GwSettingsSearchResultPanel.scroll.slider:SetValue(1)
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

    menuItem.button:SetText(name)

    --load button styling
    local zebra  = false

    --set default button count and height for margins of sub buttons
    menuItem.content.buttonCount = 0
    menuItem.content.height = menuItem:GetHeight()
    menuItem.content.buttons = {}

    menuItem.basePanel = basePanel

    -- create sub buttons for each panel
    for _, panelFrame in pairs(frames) do
        panelFrame:Hide()
        local subButton = CreateFrame("Button", name .. "GwSearchableSubButton" .. menuItem.content.buttonCount, menuItem.content, "GwSettingsMenuSearchableSubButton")

        --Grab the breadcrumb title from the panel
        subButton:SetText(panelFrame.breadcrumb:GetText())

        -- set parent button needed
        subButton.parentButton = menuItem
        subButton.refFrame = panelFrame
        --anchor subbutton to content frame
        subButton:SetPoint("TOPLEFT", menuItem.content, "TOPLEFT", 0, menuItem.content.buttonCount * -subButton:GetHeight())
        --save total height for later usage
        menuItem.content.height = menuItem.content.height + subButton:GetHeight()
        menuItem.content.buttons[menuItem.content.buttonCount] = subButton
        zebra = (menuItem.content.buttonCount % 2) == 1 or false
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
                switchCat(menuItem.content.buttons[0], basePanel, menuItem.content.buttons[0].refFrame)
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
    GwSettingsSearchResultPanel.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
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
    GwSettingsMenuSearchable.search.input:SetScript("OnEditFocusGained", function(self) if self:GetText()==SEARCH then self:SetText("") end end)
    GwSettingsMenuSearchable.search.input:SetScript("OnEditFocusLost", function(self) if self:GetText()==nil or self:GetText()=="" then self:SetTextColor(178 / 255, 178 / 255, 178 / 255) self:SetText(SEARCH) end end)
    GwSettingsMenuSearchable.search.input:SetScript("OnEnterPressed", fnGWP_input_OnEnterPressed)
    GwSettingsMenuSearchable.search.input:SetScript("OnTextChanged",searchInputChanged)

    -- load the scrollbox on first load
    GwSettingsMenuSearchable.firstTimeLoaded = true
    GwSettingsMenuSearchable:HookScript("OnShow", function()
        if GwSettingsMenuSearchable.firstTimeLoaded then
            resetMenu(true)
            switchCat(_G[GW.L["Modules"] .. "GwSearchableItem"].button, _G[GW.L["Modules"] .. "GwSearchableItem"].basePanel)
            GwSettingsMenuSearchable.firstTimeLoaded = false
        end
    end)
end
GW.loadSettingsSearchAbleMenu  = loadSettingsSearchAbleMenu
