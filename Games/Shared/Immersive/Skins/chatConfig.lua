---@class GW2
local GW = select(2, ...)

local WINDOW_ICON = "Interface/AddOns/GW2_UI/textures/character/settings-window-icon.png"
local LIST_HOVER = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"
local LIST_ZEBRA = "Interface/AddOns/GW2_UI/textures/character/menu-bg.png"
local RADIO_BUTTONS = {"CombatConfigColorsColorizeEntireLineBySource", "CombatConfigColorsColorizeEntireLineByTarget"}
local PANEL_BUTTONS = {
    "ChatConfigFrameDefaultButton",
    "ChatConfigFrameRedockButton",
    "CombatLogDefaultButton",
    "TextToSpeechDefaultButton",
    "ChatConfigFrameCancelButton",
    "ChatConfigFrameOkayButton",
    "ChatConfigCombatSettingsFiltersDeleteButton",
    "ChatConfigCombatSettingsFiltersAddFilterButton",
    "ChatConfigCombatSettingsFiltersCopyFilterButton",
    "CombatConfigSettingsSaveButton",
}

-- only the art shrinks, blizzards rows are laid out around the button size
local function SkinCheckButton(button, isRadio)
    button:GwSkinCheckButton(isRadio, button:GetHeight() < 22 and 13 or 15, true)
end

-- blizzard colours either the normal texture (old swatches) or the Color texture (ColorSwatchTemplate)
local function SkinColorSwatch(swatch)
    if swatch.gwSkinned then return end
    swatch.gwSkinned = true

    local background = swatch.SwatchBg or _G[swatch:GetName() .. "SwatchBg"]
    background:SetColorTexture(0, 0, 0, 1)
    background:SetSize(14, 14)

    if swatch.InnerBorder then
        swatch.InnerBorder:Hide()
    end
    if swatch.Color then
        swatch.Color:SetSize(12, 12)
    end

    local normal = swatch:GetNormalTexture()
    if normal then
        normal:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/white.png")
        normal:ClearAllPoints()
        normal:SetPoint("CENTER")
        normal:SetSize(12, 12)
    end
end

-- a font object instead of a text colour: blizzard swaps the font objects on hover, which resets the colour
local listFont = CreateFont("GwChatConfigListFont")
listFont:CopyFontObject(GameFontNormalLeft)
listFont:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

local function IsOptionRow(box)
    local name = box:GetName()
    return box.CheckButton or box.Button or box.Text or (name and (_G[name .. "ColorSwatch"] or _G[name .. "Text"]))
end

-- option rows lose their boxes and read as a list, the groups around them get a thin border
local function SkinBox(box)
    box.gwSkinned = true
    box.NineSlice:Hide()

    if box.header then
        box.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end

    local colorHeader = box:GetName() and _G[box:GetName() .. "ColorHeader"]
    if colorHeader then
        colorHeader:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    end

    if IsOptionRow(box) then
        if box.Button then
            box.Button:GwSkinButton(false, true)
        end
        -- list rows are numbered (...Checkbox3, ...Swatch3); the reorderable channel rows keep their place and swap content
        local index = tonumber(strmatch(box:GetName() or "", "(%d+)$"))
        if index and index % 2 == 1 then
            local zebra = box:CreateTexture(nil, "BACKGROUND", nil, 1)
            zebra:SetAllPoints(box)
            zebra:SetTexture(LIST_ZEBRA)
        end
        return
    end

    box:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly, true)
    box.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
end

local function SkinDescendants(frame)
    for _, child in ipairs({frame:GetChildren()}) do
        local name = child:GetName()
        if child.NineSlice and child.layoutType == "TooltipDefaultLayout" and not child.gwSkinned then
            SkinBox(child)
        end
        if child:IsObjectType("CheckButton") then
            SkinCheckButton(child)
        elseif name and strmatch(name, "ColorSwatch$") then
            SkinColorSwatch(child)
        end

        SkinDescendants(child)
    end
end

-- the filter buttons are recycled (scroll box) or scrolled through (faux scroll), so the stripe follows the position
local function SetListZebra(button, index)
    if not button.gwZebra then
        button.gwZebra = button:CreateTexture(nil, "BACKGROUND", nil, 1)
        button.gwZebra:SetAllPoints(button)
        button.gwZebra:SetTexture(LIST_ZEBRA)
    end
    button.gwZebra:SetShown(index % 2 == 1)
end

local function SkinListButton(button)
    button:SetNormalFontObject(listFont)
    button:SetHighlightFontObject(listFont)
    button:SetHighlightTexture(LIST_HOVER)
    local highlight = button:GetHighlightTexture()
    highlight:SetVertexColor(1, 1, 1, 1)
    highlight:SetBlendMode("BLEND")
end

local function SkinScrollFrame(scrollFrame)
    local scrollBar = scrollFrame.ScrollBar or _G[scrollFrame:GetName() .. "ScrollBar"]
    if scrollBar.SetHideIfUnscrollable then
        GW.HandleTrimScrollBar(scrollBar)
        GW.HandleScrollControls(scrollFrame)
    else
        scrollBar:GwSkinScrollBar()
        scrollFrame:GwSkinScrollFrame()
    end
end

local function SkinWindow()
    local headerText = ChatConfigFrame.Header and ChatConfigFrame.Header.Text or ChatConfigFrameHeaderText
    GW.CreateFrameHeaderWithBody(ChatConfigFrame, headerText, WINDOW_ICON, {ChatConfigCategoryFrame, ChatConfigBackgroundFrame})
    -- the classic header text is a fixed 185 wide, too narrow for our font
    headerText:SetSize(0, 0)

    if ChatConfigFrame.Border then
        ChatConfigFrame.Border:Hide()
        ChatConfigFrame.Header:Hide()
    else
        ChatConfigFrame:SetBackdrop(nil)
        ChatConfigFrameHeader:Hide()
    end

    for _, box in ipairs({ChatConfigCategoryFrame, ChatConfigBackgroundFrame}) do
        box.NineSlice:Hide()
        box.gwSkinned = true
    end
end

local function SkinCategories()
    local index = 1
    while _G["ChatConfigCategoryFrameButton" .. index] do
        SkinListButton(_G["ChatConfigCategoryFrameButton" .. index])
        index = index + 1
    end
end

local function SkinTabs()
    for index = 1, #COMBAT_CONFIG_TABS do
        local tab = _G[CHAT_CONFIG_COMBAT_TAB_NAME .. index]
        GW.HandleTabs(tab, "top")
        tab:SetHeight(24)
    end

    -- mainline lists the chat windows as tabs above the categories, pooled and rebuilt on every show
    local tabManager = ChatConfigFrame.ChatTabManager
    if not tabManager then return end

    -- UpdateTabDisplay selects before our hook on it has skinned freshly acquired tabs, those follow right after
    local function UpdateSelection(manager, selectedIndex)
        for tab in manager.tabPool:EnumerateActive() do
            if tab.background then
                tab.background:SetBlendMode(tab:GetID() == selectedIndex and "MOD" or "BLEND")
            end
        end
    end
    hooksecurefunc(tabManager, "UpdateTabDisplay", function(manager)
        for tab in manager.tabPool:EnumerateActive() do
            if not tab.gwSkinned then
                GW.HandleTabs(tab, "top")
                tab:SetHeight(24)
                -- the chat tab art fades itself out, here the tabs have no mouseover fading
                tab:SetAlpha(1)
            end
        end
        UpdateSelection(manager, CURRENT_CHAT_FRAME_ID)
    end)
    hooksecurefunc(tabManager, "UpdateSelection", UpdateSelection)
end

local function SkinCombatSettings()
    local filters = ChatConfigCombatSettingsFilters
    if filters.ScrollBox then
        GW.HandleTrimScrollBar(filters.ScrollBar)
        GW.HandleScrollControls(filters)
        local function SkinFilterButton(button, elementData)
            SkinListButton(button)
            SetListZebra(button, elementData.index)
        end
        -- the registry hands the owner in first, the existing frames come without it
        ScrollUtil.AddInitializedFrameCallback(filters.ScrollBox, function(_, button, elementData)
            SkinFilterButton(button, elementData)
        end, filters)
        filters.ScrollBox:ForEachFrame(SkinFilterButton)
    else
        SkinScrollFrame(ChatConfigCombatSettingsFiltersScrollFrame)
        local index = 1
        while _G["ChatConfigCombatSettingsFiltersButton" .. index] do
            SkinListButton(_G["ChatConfigCombatSettingsFiltersButton" .. index])
            SetListZebra(_G["ChatConfigCombatSettingsFiltersButton" .. index], index)
            index = index + 1
        end
    end

    GW.HandleNextPrevButton(ChatConfigMoveFilterUpButton, "up")
    GW.HandleNextPrevButton(ChatConfigMoveFilterDownButton, "down")

    local editBox = CombatConfigSettingsNameEditBox
    GW.SkinTextBox(editBox.Middle, editBox.Left, editBox.Right)

    for _, name in ipairs(RADIO_BUTTONS) do
        SkinCheckButton(_G[name], true)
    end
end

local function SkinTextToSpeech()
    SkinScrollFrame(ChatConfigTextToSpeechSettings)
    SkinScrollFrame(ChatConfigTextToSpeechMessageSettingsScroll)

    local panel = TextToSpeechFrame.PanelContainer
    for _, dropdown in ipairs({panel.TtsVoiceDropdown, panel.TtsVoiceAlternateDropdown}) do
        dropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, dropdown:GetWidth())
    end
    panel.PlaySampleButton:GwSkinButton(false, true)
    panel.PlaySampleAlternateButton:GwSkinButton(false, true)
    panel.AdjustRateSlider.Slider:GwSkinSliderFrame()
    panel.AdjustVolumeSlider.Slider:GwSkinSliderFrame()
end

local function SkinButtons()
    for _, name in ipairs(PANEL_BUTTONS) do
        _G[name]:GwSkinButton(false, true)
    end
    -- classic only
    if ChatConfigFrame.ToggleChatButton then
        ChatConfigFrame.ToggleChatButton:GwSkinButton(false, true)
    end
end

local function LoadChatConfigSkin()
    if not GW.settings.chat.enabled then return end

    SkinWindow()
    SkinCategories()
    SkinTabs()
    SkinCombatSettings()
    SkinTextToSpeech()
    SkinButtons()
    SkinDescendants(ChatConfigFrame)

    local function Refresh()
        SkinDescendants(ChatConfigFrame)
    end
    ChatConfigFrame:HookScript("OnShow", Refresh)
    hooksecurefunc("ChatConfigCategory_OnClick", Refresh)
    hooksecurefunc("ChatConfig_CreateCheckboxes", Refresh)
    -- the combat message types and the text to speech message types build their check buttons outside those two
    hooksecurefunc("ChatConfig_CreateTieredCheckboxes", Refresh)
    hooksecurefunc("TextToSpeechFrame_UpdateMessageCheckboxes", Refresh)
end
GW.LoadChatConfigSkin = LoadChatConfigSkin
