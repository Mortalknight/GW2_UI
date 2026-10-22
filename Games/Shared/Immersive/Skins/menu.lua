---@class GW2
local GW = select(2, ...)

local SEPARATOR = "Interface/AddOns/GW2_UI/textures/hud/levelreward-sep.png"

local function SetSeparator(texture)
    texture:SetTexture(SEPARATOR)
    texture:SetTexCoord(0.2, 0.8, 0, 1)
    texture:SetHeight(2)
end

local function SkinUIDropDownMenu()
    hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
        local listFrame = _G["DropDownList" .. level]
        local listFrameName = listFrame:GetName()
        local expandArrow = _G[listFrameName .. "Button" .. index .. "ExpandArrow"];
        if expandArrow then
            expandArrow:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
            expandArrow:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
            expandArrow:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
            expandArrow:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png")
        end

        local Backdrop = _G[listFrameName .. "Backdrop"]
        if Backdrop and not Backdrop.template then
            Backdrop:GwStripTextures()
            Backdrop:GwCreateBackdrop(GW.BackdropTemplates.Default)
        end

        local menuBackdrop = _G[listFrameName .. "MenuBackdrop"]
        if menuBackdrop and not menuBackdrop.template then
            menuBackdrop:GwStripTextures()
            menuBackdrop:GwCreateBackdrop(GW.BackdropTemplates.Default)
        end
    end)
end

local function SkinDropDownList()
    hooksecurefunc("ToggleDropDownMenu", function(level)
        if not level then
            level = 1
        end

        for i = 1, _G.UIDROPDOWNMENU_MAXBUTTONS do
            local button = _G["DropDownList" .. level .. "Button" .. i]
            local check = _G["DropDownList" .. level .. "Button" .. i .. "Check"]
            local uncheck = _G["DropDownList" .. level .. "Button" .. i .. "UnCheck"]
            local arrow = _G["DropDownList" .. level .. "Button" .. i .. "ExpandArrow"]
            local highlight = _G["DropDownList" .. level .. "Button" .. i .. "Highlight"]

            highlight:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover.png")
            highlight:SetBlendMode("BLEND")
            highlight:SetDrawLayer("BACKGROUND")
            highlight:SetAlpha(0.5)
            highlight:GwSetOutside(button, 8)

            check:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png")
            check:SetTexCoord(unpack(GW.TexCoords))
            check:SetSize(13, 13)
            uncheck:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png")
            uncheck:SetTexCoord(unpack(GW.TexCoords))
            uncheck:SetSize(13, 13)
            if not button.backdrop then
                button:GwCreateBackdrop()
            end

            if button.hasArrow then
                arrow:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right.png")
            end

            if not button.notCheckable then
                button.backdrop:Show()
            else
                button.backdrop:Hide()
            end
        end
    end)

    hooksecurefunc("UIDropDownMenu_SetIconImage", function(icon, texture)
        if texture:find("Divider") then
            SetSeparator(icon)
        end
    end)
end

-- blizzards menu frames come from a pool and lose their art again on every open. The backdrop is an own
-- frame behind the menu, no child of it and nothing written onto it: the menu lays out its children and
-- reads its fields, from our code that taints it and with it the gamepad window focus
local menuBackdrops = {}

local function SkinMenuFrame(menu)
    menu:GwStripTextures()
    local backdrop = menuBackdrops[menu]
    if not backdrop then
        backdrop = CreateFrame("Frame", nil, UIParent)
        backdrop:SetAllPoints(menu)
        backdrop:GwCreateBackdrop(GW.BackdropTemplates.Default)
        menu:HookScript("OnHide", function() backdrop:Hide() end)
        menuBackdrops[menu] = backdrop
        -- long menus scroll, with the slim bar of our windows
        if menu.ScrollBar then
            GW.SkinSlimScrollBar(menu.ScrollBar)
        end
    end
    -- submenus open above their parent, the backdrop follows the level of its menu
    backdrop:SetFrameStrata(menu:GetFrameStrata())
    backdrop:SetFrameLevel(math.max(1, menu:GetFrameLevel() - 1))
    backdrop:Show()
end

-- the opened menu, and every submenu it opens later
local function SkinOpenedMenu(manager, _, description)
    local menu = manager:GetOpenMenu()
    if menu then
        SkinMenuFrame(menu)
        description:AddMenuAcquiredCallback(SkinMenuFrame)
    end
end

-- the divider is the only texture of its entry, blizzard hands it back to the initializer and not to the hook
local function SkinDivider(frame)
    for _, region in ipairs({frame:GetRegions()}) do
        if region:IsObjectType("Texture") and region:IsShown() then
            SetSeparator(region)
        end
    end
end

-- our arrow already points right, a pooled texture reused for something else keeps no rotation
local function SkinSubmenuArrow(entry)
    local arrow = entry.arrow
    if arrow then
        arrow:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right.png")
        arrow:SetSize(15, 15)
    end
end

-- the boxes of checkbox and radio entries; blizzard draws them from atlases, the modern clients put the tick
-- on a second texture that only exists while the entry is selected
local function SkinSelection(frame, selectedTexture, unselectedTexture)
    local box = frame.leftTexture1
    if not box then return end
    local tick = frame.leftTexture2
    local atlas = box:GetAtlas()
    local selected = tick ~= nil or (atlas ~= nil and atlas:find("yellow") ~= nil)
    box:SetTexture(selected and selectedTexture or unselectedTexture)
    box:SetTexCoord(0, 1, 0, 1)
    box:SetSize(14, 14)
    if tick then
        tick:SetTexture(nil)
    end
end

local function SkinCheckbox(_, frame)
    SkinSelection(frame, "Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked.png", "Interface/AddOns/GW2_UI/textures/uistuff/checkbox.png")
end

local function SkinRadio(_, frame)
    SkinSelection(frame, "Interface/AddOns/GW2_UI/textures/uistuff/radio-selected.png", "Interface/AddOns/GW2_UI/textures/uistuff/radio-unselected.png")
    local box = frame.leftTexture1
    if box and frame.fontString then
        box:SetPoint("LEFT", 2, 0)
        frame.fontString:SetPoint("LEFT", box, "RIGHT", 7, 0)
    end
end

local HOVER_STRENGTH = GW.Colors.SkinColors.HighlightWhite.a

local function SetNegative(button)
    local color = GW.Colors.SkinColors.Negative
    local strength = GW.settings.skins.dropdown.enabled and HOVER_STRENGTH or 1
    button.highlight:SetVertexColor(color.r * strength, color.g * strength, color.b * strength)
    if button.fontString then
        button.fontString:SetText(color:WrapTextInColorCode(button.fontString:GetText()))
    end
end

function GW.SetMenuEntryNegative(description)
    description:AddInitializer(SetNegative)
end

-- entries with a colored text get a hover in that color, like the raid markers or the loot threshold;
-- the text color is only final once the entry is set up, so it is read when the hover shows
local tintHooked = setmetatable({}, {__mode = "k"})
local function TintHighlight(highlight)
    local fontString = highlight:GetParent().fontString
    if not fontString then return end
    local r, g, b = fontString:GetTextColor()
    if r < 0.99 or g < 0.99 or b < 0.99 then
        highlight:SetVertexColor(r * HOVER_STRENGTH, g * HOVER_STRENGTH, b * HOVER_STRENGTH)
    end
end

hooksecurefunc(MenuVariants, "CreateHighlight", function(frame)
    local highlight = frame.highlight
    if GW.settings.skins.dropdown.enabled then
        highlight:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover.png")
        highlight:SetVertexColor(HOVER_STRENGTH, HOVER_STRENGTH, HOVER_STRENGTH)
        if not tintHooked[highlight] then
            tintHooked[highlight] = true
            hooksecurefunc(highlight, "Show", TintHighlight)
        end
    else
        highlight:SetVertexColor(1, 1, 1)
    end
end)

local function UpdateHighlightEnabled(frame, enabled)
    local highlight = frame.highlight
    if highlight and highlight:IsShown() then
        highlight:SetAlpha(enabled and 1 or MenuVariants.DisabledHighlightOpacity)
    end
end

local function SkinVoiceLevels(frame)
    local slider = frame.Slider
    if slider and not slider.gwSkinned then
        slider.gwSkinned = true
        slider:GwSkinSliderFrame()
        GW.AddSliderValueFill(slider)
    end
end

local function LoadDropDownSkin()
    if not GW.settings.skins.dropdown.enabled then return end

    SkinDropDownList()
    SkinUIDropDownMenu()

    local manager = Menu.GetManager()
    if manager then
        hooksecurefunc(manager, "OpenMenu", SkinOpenedMenu)
        hooksecurefunc(manager, "OpenContextMenu", SkinOpenedMenu)
    end
    hooksecurefunc(MenuVariants, "CreateSubmenuArrow", SkinSubmenuArrow)
    hooksecurefunc(MenuVariants, "CreateCheckbox", SkinCheckbox)
    hooksecurefunc(MenuVariants, "CreateRadio", SkinRadio)
    hooksecurefunc(MenuVariants, "CreateDivider", SkinDivider)
    hooksecurefunc(MenuTemplates, "SetHierarchyEnabled", UpdateHighlightEnabled)
    if UnitPopupVoiceLevelsMixin then
        hooksecurefunc(UnitPopupVoiceLevelsMixin, "OnAttach", SkinVoiceLevels)
    end
end
GW.LoadDropDownSkin = LoadDropDownSkin