---@class GW2
local GW = select(2, ...)

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
            icon:SetColorTexture(1, 0.93, 0.73, 0.45)
            icon:SetHeight(1)
        end
    end)
end

-- blizzards menu frames come from a pool and lose their art again on every open; the backdrop is
-- created once per frame and kept here, not on the frame
local menuBackdrops = setmetatable({}, {__mode = "k"})

local function SkinMenuFrame(menu)
    menu:GwStripTextures()
    local backdrop = menuBackdrops[menu]
    if not backdrop then
        menu:GwCreateBackdrop(GW.BackdropTemplates.Default)
        backdrop = menu.backdrop
        menuBackdrops[menu] = backdrop
        -- long menus scroll, with the slim bar of our windows
        if menu.ScrollBar then
            GW.SkinSlimScrollBar(menu.ScrollBar)
        end
    end
    -- submenus open above their parent, the backdrop follows the level of its menu
    backdrop:SetFrameLevel(math.max(0, menu:GetFrameLevel() - 1))
end

-- the opened menu, and every submenu it opens later
local function SkinOpenedMenu(manager, _, description)
    local menu = manager:GetOpenMenu()
    if menu then
        SkinMenuFrame(menu)
        description:AddMenuAcquiredCallback(SkinMenuFrame)
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
end
GW.LoadDropDownSkin = LoadDropDownSkin