local _, GW = ...

local function SkinUIDropDownMenu()
    hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
        local listFrame = _G["DropDownList" .. level]
        local listFrameName = listFrame:GetName()
        local expandArrow = _G[listFrameName .. "Button" .. index .. "ExpandArrow"];
        if expandArrow then
            expandArrow:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
            expandArrow:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
            expandArrow:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
            expandArrow:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down")
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

            highlight:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/button_hover")
            highlight:SetBlendMode("BLEND")
            highlight:SetDrawLayer("BACKGROUND")
            highlight:SetAlpha(0.5)
            highlight:GwSetOutside(button, 8)

            check:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkboxchecked")
            check:SetTexCoord(unpack(GW.TexCoords))
            check:SetSize(13, 13)
            uncheck:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/checkbox")
            uncheck:SetTexCoord(unpack(GW.TexCoords))
            uncheck:SetSize(13, 13)
            if not button.backdrop then
                button:GwCreateBackdrop()
            end

            if button.hasArrow then
                arrow:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrow_right")
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

local backdrops = {}
local function SkinFrame(frame)
    frame:GwStripTextures()

    if backdrops[frame] then
        frame.backdrop = backdrops[frame] -- relink it back
    else
        frame:GwCreateBackdrop(GW.BackdropTemplates.Default)
        backdrops[frame] = frame.backdrop

        if frame.ScrollBar then
            GW.HandleTrimScrollBar(frame.ScrollBar)
        end
    end
end

local function OpenMenu(manager)
    local menu = manager:GetOpenMenu()
    if menu then
        SkinFrame(menu)
    end
end

local function LoadDropDownSkin()
    if not GW.settings.DROPDOWN_SKIN_ENABLED then return end

    SkinDropDownList()
    SkinUIDropDownMenu()

    local manager = Menu.GetManager()
    hooksecurefunc(manager, "OpenMenu", OpenMenu)
    hooksecurefunc(manager, "OpenContextMenu", OpenMenu)
end
GW.LoadDropDownSkin = LoadDropDownSkin