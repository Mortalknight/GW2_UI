local _, GW = ...

local function LoadDetailsSkin()
    local details = _G.Details
    if not details then return end


    if details.IsLoaded and not details.IsLoaded() then
        C_Timer.After(0, function() LoadDetailsSkin() end)
        return
    end

    details:InstallSkin("GW2 UI Default", {
        file = "Interface/AddOns/GW2_UI/textures/addonSkins/details_skin",
        author = "GW2 UI",
        version = "1.0.1",
        site = "unknown",
        desc = "Skin to match the GW2 UI",

        can_change_alpha_head = false,
        icon_anchor_main = {4, 1},
        icon_anchor_plugins = {-9, -7},
        icon_plugins_size = {19, 19},

        -- the four anchors:
        icon_point_anchor = {-37, 0},
        left_corner_anchor = {-107, 0},
        right_corner_anchor = {96, 0},

        icon_point_anchor_bottom = {-37, 0},
        left_corner_anchor_bottom = {-107, 0},
        right_corner_anchor_bottom = {96, 0},

        attribute_icon_anchor = {34, -6},
        attribute_icon_size = {24, 24},

        --overwrites
        instance_cprops = {
            ["hide_icon"] = true,
            ["auto_hide_menu"] = {
                ["left"] = true,
                ["right"] = true,
            },
            ["show_statusbar"] = false,
            ["bg_r"] = 0,
            ["bg_g"] = 0,
            ["bg_b"] = 0,
            ["bg_alpha"] = 0,
            ["toolbar_side"] = 1,
            ["micro_displays_side"] = 2,
            ["attribute_text"] = {
                ["enabled"] = true,
                ["shadow"] = false,
                ["side"] = 1,
                ["text_size"] = 13,
                ["text_face"] = "GW2_UI Headlines",
                ["anchor"] = {
                    -12, -- [1]
                    2, -- [2]
                },
                ["text_color"] = {
                    1, -- [1]
                    1, -- [2]
                    1, -- [3]
                    1, -- [4]
                },
            },
            ["menu_anchor"] = {
                4, -- [1]
                1, -- [2]
                ["side"] = 2
            },
            ["toolbar_icon_file"] = "Interface/AddOns/GW2_UI/textures/addonSkins/details_toolbar_icons",
            ["menu_icons"] = {
                true, -- [1]
                true, -- [2]
                true, -- [3]
                true, -- [4]
                true, -- [5]
                false, -- [6]
                ["space"] = -1,
                ["shadow"] = false,
            },
            ["menu_icons_size"] = 1.1,
            ["color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
                0, -- [4]
            },
            ["row_info"] = {
                ["use_spec_icons"] = false,
                ["height"] = 24,
                ["space"] = {
                    ["right"] = 0,
                    ["left"] = 0,
                    ["between"] = 1,
                },
                ["texture"] = "GW2_UI_Details",
                ["texture_file"] = "Interface/Addons/GW2_UI/textures/addonSkins/details_statusbar",
                ["texture_class_colors"] = true,
                ["fixed_texture_color"] = {
                    0, -- [1]
                    0, -- [2]
                    0, -- [3]
                    0, -- [4]
                },
                ["texture_background"] = "GW2_UI",
                ["texture_background_file"] = "Interface/Addons/GW2_UI/textures/hud/castinbar-white",
                ["texture_background_class_color"] = false,
                ["fixed_texture_background_color"] = {
                    0, -- [1]
                    0, -- [2]
                    0, -- [3]
                    0.45, -- [4]
                },
                ["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
                ["textR_show_data"] = {
                    true, -- [1]
                    true, -- [2]
                    false, -- [3]
                },
                ["alpha"] = 1,
                ["icon_file"] = "Interface/AddOns/GW2_UI/textures/addonSkins/details_class_icons",
                ["no_icon"] = false,
                ["start_after_icon"] = false,
                ["font_size"] = 12,
                ["font_face"] = "GW2_UI_Chat",
                ["font_face_file"] = "Interface/AddOns/GW2_UI/fonts/trebuchet_ms.ttf",
                ["fixed_text_color"] = {
                    1, -- [1]
                    1, -- [2]
                    1, -- [3]
                    1, -- [4]
                },
                ["textL_class_colors"] = false,
                ["textR_class_colors"] = false,
                ["textR_outline"] = false,
                ["textL_outline"] = false,
                ["textR_enable_custom_text"] = false,
                ["percent_type"] = 1,
                ["textL_show_number"] = true,
                ["textL_enable_custom_text"] = false,
                ["textL_outline_small"] = true,
                ["textL_outline_small_color"] = {
                    0, -- [1]
                    0, -- [2]
                    0, -- [3]
                    1, -- [4]
                },
                ["textR_outline_small"] = true,
                ["textR_outline_small_color"] = {
                    0, -- [1]
                    0, -- [2]
                    0, -- [3]
                    1, -- [4]
                },
            }
        }
    })

    details:InstallSkin("GW2 UI Colored", {
        file = "Interface/AddOns/GW2_UI/textures/addonSkins/details_skin",
        author = "GW2 UI",
        version = "1.0.1",
        site = "unknown",
        desc = "Skin to match the GW2 UI",

        can_change_alpha_head = false,
        icon_anchor_main = {4, 1},
        icon_anchor_plugins = {-9, -7},
        icon_plugins_size = {19, 19},

        -- the four anchors:
        icon_point_anchor = {-37, 0},
        left_corner_anchor = {-107, 0},
        right_corner_anchor = {96, 0},

        icon_point_anchor_bottom = {-37, 0},
        left_corner_anchor_bottom = {-107, 0},
        right_corner_anchor_bottom = {96, 0},

        attribute_icon_anchor = {34, -6},
        attribute_icon_size = {24, 24},

        --overwrites
        instance_cprops = {
            ["hide_icon"] = true,
            ["auto_hide_menu"] = {
                ["left"] = true,
                ["right"] = true,
            },
            ["show_statusbar"] = false,
            ["bg_r"] = 0,
            ["bg_g"] = 0,
            ["bg_b"] = 0,
            ["bg_alpha"] = 0,
            ["toolbar_side"] = 1,
            ["micro_displays_side"] = 2,
            ["attribute_text"] = {
                ["enabled"] = true,
                ["shadow"] = false,
                ["side"] = 1,
                ["text_size"] = 13,
                ["text_face"] = "GW2_UI Headlines",
                ["anchor"] = {
                    -12, -- [1]
                    2, -- [2]
                },
                ["text_color"] = {
                    1, -- [1]
                    1, -- [2]
                    1, -- [3]
                    1, -- [4]
                },
            },
            ["menu_anchor"] = {
                4, -- [1]
                1, -- [2]
                ["side"] = 2
            },
            ["toolbar_icon_file"] = "Interface/AddOns/GW2_UI/textures/addonSkins/details_toolbar_icons",
            ["menu_icons"] = {
                true, -- [1]
                true, -- [2]
                true, -- [3]
                true, -- [4]
                true, -- [5]
                false, -- [6]
                ["space"] = -1,
                ["shadow"] = false,
            },
            ["menu_icons_size"] = 1.1,
            ["color"] = {
                0, -- [1]
                0, -- [2]
                0, -- [3]
                0, -- [4]
            },
            ["row_info"] = {
                ["use_spec_icons"] = false,
                ["height"] = 24,
                ["space"] = {
                    ["right"] = 0,
                    ["left"] = 0,
                    ["between"] = 1,
                },
                ["texture"] = "GW2_UI_Details",
                ["texture_file"] = "Interface/Addons/GW2_UI/textures/addonSkins/details_statusbar",
                ["texture_class_colors"] = true,
                ["fixed_texture_color"] = {
                    0, -- [1]
                    0, -- [2]
                    0, -- [3]
                    0, -- [4]
                },
                ["texture_background"] = "GW2_UI",
                ["texture_background_file"] = "Interface/Addons/GW2_UI/textures/hud/castinbar-white",
                ["texture_background_class_color"] = false,
                ["fixed_texture_background_color"] = {
                    0, -- [1]
                    0, -- [2]
                    0, -- [3]
                    0.45, -- [4]
                },
                ["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
                ["textR_show_data"] = {
                    true, -- [1]
                    true, -- [2]
                    false, -- [3]
                },
                ["alpha"] = 1,
                ["icon_file"] = "Interface/AddOns/GW2_UI/textures/addonSkins/details_class_icons_colored",
                ["no_icon"] = false,
                ["start_after_icon"] = false,
                ["font_size"] = 12,
                ["font_face"] = "GW2_UI_Chat",
                ["font_face_file"] = "Interface/AddOns/GW2_UI/fonts/trebuchet_ms.ttf",
                ["fixed_text_color"] = {
                    1, -- [1]
                    1, -- [2]
                    1, -- [3]
                    1, -- [4]
                },
                ["textL_class_colors"] = false,
                ["textR_class_colors"] = false,
                ["textR_outline"] = false,
                ["textL_outline"] = false,
                ["textR_enable_custom_text"] = false,
                ["percent_type"] = 1,
                ["textL_show_number"] = true,
                ["textL_enable_custom_text"] = false,
                ["textL_outline_small"] = true,
                ["textL_outline_small_color"] = {
                    0, -- [1]
                    0, -- [2]
                    0, -- [3]
                    1, -- [4]
                },
                ["textR_outline_small"] = true,
                ["textR_outline_small_color"] = {
                    0, -- [1]
                    0, -- [2]
                    0, -- [3]
                    1, -- [4]
                },
            }
        }
    })
end
GW.LoadDetailsSkin = LoadDetailsSkin