local _, GW = ...

local GW_DEFAULT = GW.DEFAULTS or {}
GW.DEFAULTS = GW_DEFAULT

GW_DEFAULT["GW2_UI_VERSION"] = "WELCOME"

GW_DEFAULT["TARGET_ENABLED"] = true
GW_DEFAULT["FOCUS_ENABLED"] = true
GW_DEFAULT["POWERBAR_ENABLED"] = true
GW_DEFAULT["CHATBUBBLES_ENABLED"] = true
GW_DEFAULT["NAMEPLATES_ENABLED"] = true
GW_DEFAULT["MINIMAP_ENABLED"] = true
GW_DEFAULT["QUESTTRACKER_ENABLED"] = true
GW_DEFAULT["TOOLTIPS_ENABLED"] = true
GW_DEFAULT["CHATFRAME_ENABLED"] = true
GW_DEFAULT["QUESTVIEW_ENABLED"] = true
GW_DEFAULT["HEALTHGLOBE_ENABLED"] = true
GW_DEFAULT["PLAYER_BUFFS_ENABLED"] = true
GW_DEFAULT["ACTIONBARS_ENABLED"] = true
GW_DEFAULT["BAGS_ENABLED"] = true
GW_DEFAULT["NPC_CAM_ENABLED"] = false
GW_DEFAULT["FONTS_ENABLED"] = true
GW_DEFAULT["CASTINGBAR_ENABLED"] = true
GW_DEFAULT["HIDEACTIONBAR_BACKGROUND_ENABLED"] = false
GW_DEFAULT["SHOWACTIONBAR_MACRO_NAME_ENABLED"] = false
GW_DEFAULT["SHOW_QUESTTRACKER_COMPASS"] = true
GW_DEFAULT["QUESTTRACKER_SHOW_XP"] = true
GW_DEFAULT["MINIMAP_HOVER"] = "NONE"
GW_DEFAULT["MINIMAP_POS"] = "BOTTOM"
GW_DEFAULT["CLASS_POWER"] = true
GW_DEFAULT["RAID_FRAMES"] = true
GW_DEFAULT["PARTY_FRAMES"] = true
GW_DEFAULT["PETBAR_ENABLED"] = true
GW_DEFAULT["BORDER_ENABLED"] = true
GW_DEFAULT["TOOLTIP_MOUSE"] = false
GW_DEFAULT["ADVANCED_TOOLTIP"] = true
GW_DEFAULT["TOOLTIP_FONT_SIZE"] = 12
GW_DEFAULT["ADVANCED_TOOLTIP_OPTION_ITEMCOUNT"] = "BOTH"
GW_DEFAULT["ADVANCED_TOOLTIP_SHOW_TARGET_INFO"] = true
GW_DEFAULT["ADVANCED_TOOLTIP_SHOW_REALM_ALWAYS"] = true
GW_DEFAULT["ADVANCED_TOOLTIP_SHOW_GUILD_RANKS"] = true
GW_DEFAULT["ADVANCED_TOOLTIP_SHOW_CLASS_COLOR"] = true
GW_DEFAULT["ADVANCED_TOOLTIP_SHOW_GENDER"] = false
GW_DEFAULT["ADVANCED_TOOLTIP_ID_MODIFIER"] = "NONE"
GW_DEFAULT["DYNAMIC_CAM"] = false
GW_DEFAULT["PIXEL_PERFECTION"] = false
GW_DEFAULT["XPBAR_ENABLED"] = true

GW_DEFAULT["GW_COMBAT_TEXT_MODE"] = "GW2"
GW_DEFAULT["GW_COMBAT_TEXT_BLIZZARD_COLOR"] = false
GW_DEFAULT["GW_COMBAT_TEXT_COMMA_FORMAT"] = false

GW_DEFAULT["PET_FLOATING_COMBAT_TEXT"] = false
GW_DEFAULT["PET_AURAS_UNDER"] = false

GW_DEFAULT["BUTTON_ASSIGNMENTS"] = true

GW_DEFAULT["HUD_BACKGROUND"] = true
GW_DEFAULT["HUD_SPELL_SWAP"] = true

GW_DEFAULT["BAG_ITEM_SIZE"] = 40

GW_DEFAULT["PLAYER_UNIT_HEALTH"] = "VALUE"
GW_DEFAULT["PLAYER_UNIT_ABSORB"] = "VALUE"

GW_DEFAULT["BAG_WIDTH"] = 480
GW_DEFAULT["BAG_REVERSE_SORT"] = false
GW_DEFAULT["BAG_ITEM_QUALITY_BORDER_SHOW"] = true
GW_DEFAULT["BAG_ITEM_JUNK_ICON_SHOW"] = false
GW_DEFAULT["BAG_PROFESSION_BAG_COLOR"] = true
GW_DEFAULT["BAG_VENDOR_GRAYS"] = false
GW_DEFAULT["BAG_SHOW_ILVL"] = false
GW_DEFAULT["BAG_SEPARATE_BAGS"] = false
GW_DEFAULT["BAG_HEADER_NAME0"] = ""
GW_DEFAULT["BAG_HEADER_NAME1"] = ""
GW_DEFAULT["BAG_HEADER_NAME2"] = ""
GW_DEFAULT["BAG_HEADER_NAME3"] = ""
GW_DEFAULT["BAG_HEADER_NAME4"] = ""
GW_DEFAULT["BAG_HEADER_NAME5"] = ""

GW_DEFAULT["BAG_POSITION"] = {}
GW_DEFAULT["BAG_POSITION"]["point"] = "TOPRIGHT"
GW_DEFAULT["BAG_POSITION"]["relativePoint"] = "TOPRIGHT"
GW_DEFAULT["BAG_POSITION"]["xOfs"] = -20
GW_DEFAULT["BAG_POSITION"]["yOfs"] = -60

GW_DEFAULT["BANK_ITEM_SIZE"] = 40
GW_DEFAULT["BANK_WIDTH"] = 720
GW_DEFAULT["BANK_REVERSE_SORT"] = false

GW_DEFAULT["BANK_POSITION"] = {}
GW_DEFAULT["BANK_POSITION"]["point"] = "TOPLEFT"
GW_DEFAULT["BANK_POSITION"]["relativePoint"] = "TOPLEFT"
GW_DEFAULT["BANK_POSITION"]["xOfs"] = 60
GW_DEFAULT["BANK_POSITION"]["yOfs"] = -60

GW_DEFAULT["HERO_POSITION"] = {}
GW_DEFAULT["HERO_POSITION"]["point"] = "LEFT"
GW_DEFAULT["HERO_POSITION"]["relativePoint"] = "LEFT"
GW_DEFAULT["HERO_POSITION"]["xOfs"] = 100
GW_DEFAULT["HERO_POSITION"]["yOfs"] = 0
GW_DEFAULT["HERO_POSITION_SCALE"] = 1

GW_DEFAULT["LOOTFRAME_POS"] = {}
GW_DEFAULT["LOOTFRAME_POS"]["point"] = "LEFT"
GW_DEFAULT["LOOTFRAME_POS"]["relativePoint"] = "LEFT"
GW_DEFAULT["LOOTFRAME_POS"]["xOfs"] = 20
GW_DEFAULT["LOOTFRAME_POS"]["yOfs"] = -45
GW_DEFAULT["LOOTFRAME_POS_scale"] = 1

GW_DEFAULT["WORLDMAP_POSITION"] = {}
GW_DEFAULT["WORLDMAP_POSITION"]["point"] = "CENTER"
GW_DEFAULT["WORLDMAP_POSITION"]["relativePoint"] = "CENTER"
GW_DEFAULT["WORLDMAP_POSITION"]["xOfs"] = 0
GW_DEFAULT["WORLDMAP_POSITION"]["yOfs"] = 0
GW_DEFAULT["WORLDMAP_SCALE"] = 0.8

GW_DEFAULT["RAID_CLASS_COLOR"] = false
GW_DEFAULT["RAID_STYLE_PARTY"] = false
GW_DEFAULT["RAID_STYLE_PARTY_AND_FRAMES"] = false
GW_DEFAULT["RAID_UNIT_FLAGS"] = "NONE"
GW_DEFAULT["RAID_UNIT_MARKERS"] = false

GW_DEFAULT["GW_SHOW_MULTI_ACTIONBAR_1"] = false
GW_DEFAULT["GW_SHOW_MULTI_ACTIONBAR_2"] = false
GW_DEFAULT["GW_SHOW_MULTI_ACTIONBAR_3"] = false
GW_DEFAULT["GW_SHOW_MULTI_ACTIONBAR_4"] = false
GW_DEFAULT["FADE_MULTIACTIONBAR_1"] = "ALWAYS"
GW_DEFAULT["FADE_MULTIACTIONBAR_2"] = "ALWAYS"
GW_DEFAULT["FADE_MULTIACTIONBAR_3"] = "ALWAYS"
GW_DEFAULT["FADE_MULTIACTIONBAR_4"] = "ALWAYS"
GW_DEFAULT["FADE_MULTIACTIONBAR_5"] = "ALWAYS"
GW_DEFAULT["HIDE_CHATSHADOW"] = false
GW_DEFAULT["HIDE_QUESTVIEW"] = false
GW_DEFAULT["USE_CHAT_BUBBLES"] = false
GW_DEFAULT["DISABLE_NAMEPLATES"] = false
GW_DEFAULT["DISABLE_TOOLTIPS"] = false
GW_DEFAULT["DISABLE_CHATFRAME"] = false
GW_DEFAULT["CHATFRAME_FADE"] = true
GW_DEFAULT["FADE_MICROMENU"] = false
GW_DEFAULT["AFK_MODE"] = true
GW_DEFAULT["CHAT_MAX_COPY_CHAT_LINES"] = 100

GW_DEFAULT["target_TARGET_ENABLED"] = true
GW_DEFAULT["target_TARGET_SHOW_CASTBAR"] = true
GW_DEFAULT["target_SHOW_CASTBAR"] = true
GW_DEFAULT["target_DEBUFFS"] = true
GW_DEFAULT["target_DEBUFFS_FILTER"] = true
GW_DEFAULT["target_BUFFS"] = true
GW_DEFAULT["target_THREAT_VALUE_ENABLED"] = false
GW_DEFAULT["target_BUFFS_FILTER"] = true
GW_DEFAULT["target_BUFFS_FILTER_ALL"] = false
GW_DEFAULT["target_HOOK_COMBOPOINTS"] = false
GW_DEFAULT["target_AURAS_ON_TOP"] = false
GW_DEFAULT["target_HEALTH_VALUE_ENABLED"] = false
GW_DEFAULT["target_HEALTH_VALUE_TYPE"] = false
GW_DEFAULT["target_CLASS_COLOR"] = true
GW_DEFAULT["TARGET_FLOATING_COMBAT_TEXT"] = true
GW_DEFAULT["target_FRAME_INVERT"] = false
GW_DEFAULT["target_BUFFS_FILTER_IMPORTANT"] = false

GW_DEFAULT["focus_TARGET_ENABLED"] = true
GW_DEFAULT["focus_TARGET_SHOW_CASTBAR"] = true
GW_DEFAULT["focus_SHOW_CASTBAR"] = true
GW_DEFAULT["focus_DEBUFFS"] = true
GW_DEFAULT["focus_DEBUFFS_FILTER"] = true
GW_DEFAULT["focus_BUFFS"] = true
GW_DEFAULT["focus_BUFFS_FILTER"] = true
GW_DEFAULT["focus_BUFFS_FILTER_ALL"] = false
GW_DEFAULT["focus_BUFFS_FILTER_IMPORTANT"] = false

GW_DEFAULT["focus_HEALTH_VALUE_ENABLED"] = false
GW_DEFAULT["focus_HEALTH_VALUE_TYPE"] = false
GW_DEFAULT["focus_CLASS_COLOR"] = true
GW_DEFAULT["focus_FRAME_INVERT"] = false

GW_DEFAULT["multibarleft_pos"] = {}
GW_DEFAULT["multibarleft_pos"]["point"] = "RIGHT"
GW_DEFAULT["multibarleft_pos"]["relativePoint"] = "RIGHT"
GW_DEFAULT["multibarleft_pos"]["xOfs"] = -300
GW_DEFAULT["multibarleft_pos"]["yOfs"] = 0

GW_DEFAULT["multibarright_pos"] = {}
GW_DEFAULT["multibarright_pos"]["point"] = "RIGHT"
GW_DEFAULT["multibarright_pos"]["relativePoint"] = "RIGHT"
GW_DEFAULT["multibarright_pos"]["xOfs"] = -260
GW_DEFAULT["multibarright_pos"]["yOfs"] = 0

GW_DEFAULT["target_pos"] = {}
GW_DEFAULT["target_pos"]["point"] = "TOP"
GW_DEFAULT["target_pos"]["relativePoint"] = "TOP"
GW_DEFAULT["target_pos"]["xOfs"] = -56
GW_DEFAULT["target_pos"]["yOfs"] = -100
GW_DEFAULT["target_pos_scale"] = 1

GW_DEFAULT["pet_pos"] = {}
GW_DEFAULT["pet_pos"]["point"] = "BOTTOMRIGHT"
GW_DEFAULT["pet_pos"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["pet_pos"]["xOfs"] = -53
GW_DEFAULT["pet_pos"]["yOfs"] = 120
GW_DEFAULT["pet_pos_scale"] = 1

GW_DEFAULT["castingbar_pos"] = {}
GW_DEFAULT["castingbar_pos"]["point"] = "BOTTOM"
GW_DEFAULT["castingbar_pos"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["castingbar_pos"]["xOfs"] = 0
GW_DEFAULT["castingbar_pos"]["yOfs"] = 300
GW_DEFAULT["castingbar_pos_scale"] = 1

GW_DEFAULT["targettarget_pos"] = {}
GW_DEFAULT["targettarget_pos"]["point"] = "TOP"
GW_DEFAULT["targettarget_pos"]["relativePoint"] = "TOP"
GW_DEFAULT["targettarget_pos"]["xOfs"] = 250
GW_DEFAULT["targettarget_pos"]["yOfs"] = -100
GW_DEFAULT["targettarget_pos_scale"] = 1

GW_DEFAULT["focus_pos"] = {}
GW_DEFAULT["focus_pos"]["point"] = "CENTER"
GW_DEFAULT["focus_pos"]["relativePoint"] = "CENTER"
GW_DEFAULT["focus_pos"]["xOfs"] = -350
GW_DEFAULT["focus_pos"]["yOfs"] = 0
GW_DEFAULT["focus_pos_scale"] = 1

GW_DEFAULT["focustarget_pos"] = {}
GW_DEFAULT["focustarget_pos"]["point"] = "CENTER"
GW_DEFAULT["focustarget_pos"]["relativePoint"] = "CENTER"
GW_DEFAULT["focustarget_pos"]["xOfs"] = -80
GW_DEFAULT["focustarget_pos"]["yOfs"] = -10
GW_DEFAULT["focustarget_pos_scale"] = 1

GW_DEFAULT.MULTIBAR_MARGIIN = 2
GW_DEFAULT.MAINBAR_MARGIIN = 5

GW_DEFAULT["MultiBarBottomLeft"] = {}
GW_DEFAULT["MultiBarBottomLeft"]["point"] = "BOTTOMLEFT"
GW_DEFAULT["MultiBarBottomLeft"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["MultiBarBottomLeft"]["xOfs"] = -372
GW_DEFAULT["MultiBarBottomLeft"]["yOfs"] = 120
GW_DEFAULT["MultiBarBottomLeft_scale"] = 1

GW_DEFAULT["MultiBarBottomLeft"]["size"] = 38
GW_DEFAULT["MultiBarBottomLeft"]["margin"] = 2
GW_DEFAULT["MultiBarBottomLeft"]["ButtonsPerRow"] = 6
GW_DEFAULT["MultiBarBottomLeft"]["hideDefaultBackground"] = true

GW_DEFAULT["MultiBarBottomRight"] = {}
GW_DEFAULT["MultiBarBottomRight"]["point"] = "BOTTOMRIGHT"
GW_DEFAULT["MultiBarBottomRight"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["MultiBarBottomRight"]["xOfs"] = 372
GW_DEFAULT["MultiBarBottomRight"]["yOfs"] = 120
GW_DEFAULT["MultiBarBottomRight_scale"] = 1

GW_DEFAULT["MultiBarBottomRight"]["size"] = 38
GW_DEFAULT["MultiBarBottomRight"]["margin"] = 2
GW_DEFAULT["MultiBarBottomRight"]["ButtonsPerRow"] = 6
GW_DEFAULT["MultiBarBottomRight"]["hideDefaultBackground"] = true

GW_DEFAULT["MULTIBAR_RIGHT_COLS"] = 1

GW_DEFAULT["StanceBar_pos"] = {}
GW_DEFAULT["StanceBar_pos"]["point"] = "BOTTOMLEFT"
GW_DEFAULT["StanceBar_pos"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["StanceBar_pos"]["xOfs"] = -405
GW_DEFAULT["StanceBar_pos"]["yOfs"] = 31
GW_DEFAULT["StanceBar_pos_scale"] = 1
GW_DEFAULT["StanceBar_GrowDirection"] = "UP"
GW_DEFAULT["StanceBarContainerState"] = "close"

GW_DEFAULT["MultiBarRight"] = {}
GW_DEFAULT["MultiBarRight"]["point"] = "RIGHT"
GW_DEFAULT["MultiBarRight"]["relativePoint"] = "RIGHT"
GW_DEFAULT["MultiBarRight"]["xOfs"] = -320
GW_DEFAULT["MultiBarRight"]["yOfs"] = 0
GW_DEFAULT["MultiBarRight_scale"] = 1

GW_DEFAULT["MultiBarRight"]["size"] = 38
GW_DEFAULT["MultiBarRight"]["margin"] = 2
GW_DEFAULT["MultiBarRight"]["ButtonsPerRow"] = 1
GW_DEFAULT["MultiBarRight"]["hideDefaultBackground"] = true

GW_DEFAULT["MultiBarLeft"] = {}
GW_DEFAULT["MultiBarLeft"]["point"] = "RIGHT"
GW_DEFAULT["MultiBarLeft"]["relativePoint"] = "RIGHT"
GW_DEFAULT["MultiBarLeft"]["xOfs"] = -368
GW_DEFAULT["MultiBarLeft"]["yOfs"] = 0
GW_DEFAULT["MultiBarLeft_scale"] = 1

GW_DEFAULT["MultiBarLeft"]["size"] = 38
GW_DEFAULT["MultiBarLeft"]["margin"] = 2
GW_DEFAULT["MultiBarLeft"]["ButtonsPerRow"] = 1
GW_DEFAULT["MultiBarLeft"]["hideDefaultBackground"] = true

GW_DEFAULT["GameTooltipPos"] = {}
GW_DEFAULT["GameTooltipPos"]["point"] = "BOTTOMRIGHT"
GW_DEFAULT["GameTooltipPos"]["relativePoint"] = "BOTTOMRIGHT"
GW_DEFAULT["GameTooltipPos"]["xOfs"] = 0
GW_DEFAULT["GameTooltipPos"]["yOfs"] = 300

GW_DEFAULT["BNToastPos"] = {}
GW_DEFAULT["BNToastPos"]["point"] = "BOTTOM"
GW_DEFAULT["BNToastPos"]["relativePoint"] = "BOTTOMLEFT"
GW_DEFAULT["BNToastPos"]["xOfs"] = 78
GW_DEFAULT["BNToastPos"]["yOfs"] = 246
GW_DEFAULT["BNToastPos_scale"] = 1

GW_DEFAULT["HealthGlobe_pos"] = {}
GW_DEFAULT["HealthGlobe_pos"]["point"] = "BOTTOM"
GW_DEFAULT["HealthGlobe_pos"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["HealthGlobe_pos"]["xOfs"] = 0
GW_DEFAULT["HealthGlobe_pos"]["yOfs"] = 17

GW_DEFAULT["PowerBar_pos"] = {}
GW_DEFAULT["PowerBar_pos"]["point"] = "BOTTOMLEFT"
GW_DEFAULT["PowerBar_pos"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["PowerBar_pos"]["xOfs"] = 53
GW_DEFAULT["PowerBar_pos"]["yOfs"] = 86
GW_DEFAULT["PowerBar_pos_scale"] = 1

GW_DEFAULT["ClasspowerBar_pos"] = {}
GW_DEFAULT["ClasspowerBar_pos"]["point"] = "BOTTOMLEFT"
GW_DEFAULT["ClasspowerBar_pos"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["ClasspowerBar_pos"]["xOfs"] = -372
GW_DEFAULT["ClasspowerBar_pos"]["yOfs"] = 81
GW_DEFAULT["ClasspowerBar_pos_scale"] = 1

GW_DEFAULT["TotemBar_pos"] = {}
GW_DEFAULT["TotemBar_pos"]["point"] = "TOPRIGHT"
GW_DEFAULT["TotemBar_pos"]["relativePoint"] = "TOPRIGHT"
GW_DEFAULT["TotemBar_pos"]["xOfs"] = -500
GW_DEFAULT["TotemBar_pos"]["yOfs"] = -50
GW_DEFAULT["TotemBar_pos_scale"] = 1
GW_DEFAULT["TotemBar_GrowDirection"] = "HORIZONTAL"
GW_DEFAULT["TotemBar_SortDirection"] = "ASC"

GW_DEFAULT["MinimapPos"] = {}
GW_DEFAULT["MinimapPos"]["point"] = "BOTTOMRIGHT"
GW_DEFAULT["MinimapPos"]["relativePoint"] = "BOTTOMRIGHT"
GW_DEFAULT["MinimapPos"]["xOfs"] = -5
GW_DEFAULT["MinimapPos"]["yOfs"] = 21
GW_DEFAULT["MinimapPos_scale"] = 1

GW_DEFAULT["MicromenuPos"] = {}
GW_DEFAULT["MicromenuPos"]["point"] = "TOPLEFT"
GW_DEFAULT["MicromenuPos"]["relativePoint"] = "TOPLEFT"
GW_DEFAULT["MicromenuPos"]["xOfs"] = 0
GW_DEFAULT["MicromenuPos"]["yOfs"] = 1

GW_DEFAULT["QuestTracker_pos"] = {}
GW_DEFAULT["QuestTracker_pos"]["point"] = "TOPRIGHT"
GW_DEFAULT["QuestTracker_pos"]["relativePoint"] = "TOPRIGHT"
GW_DEFAULT["QuestTracker_pos"]["xOfs"] = 0
GW_DEFAULT["QuestTracker_pos"]["yOfs"] = 0
GW_DEFAULT["QuestTracker_pos_height"] = 700
GW_DEFAULT["QuestTracker_pos_scale"] = 1

GW_DEFAULT["player_pos"] = {}
GW_DEFAULT["player_pos"]["point"] = "CENTER"
GW_DEFAULT["player_pos"]["relativePoint"] = "CENTER"
GW_DEFAULT["player_pos"]["xOfs"] = -56
GW_DEFAULT["player_pos"]["yOfs"] = -100
GW_DEFAULT["player_pos_scale"] = 1

GW_DEFAULT["raid_pos"] = {}
GW_DEFAULT["raid_pos"]["point"] = "TOPLEFT"
GW_DEFAULT["raid_pos"]["relativePoint"] = "TOPLEFT"
GW_DEFAULT["raid_pos"]["xOfs"] = 65
GW_DEFAULT["raid_pos"]["yOfs"] = -60

GW_DEFAULT["RAID_WIDTH"] = 55
GW_DEFAULT["RAID_HEIGHT"] = 47
GW_DEFAULT["RAID_POWER_BARS"] = false
GW_DEFAULT["RAID_UNITS_PER_COLUMN"] = 5
GW_DEFAULT["RAID_GROW"] = "DOWN+RIGHT"
GW_DEFAULT["RAID_ANCHOR"] = "POSITION"
GW_DEFAULT["RAID_CONT_WIDTH"] = 0
GW_DEFAULT["RAID_CONT_HEIGHT"] = 0
GW_DEFAULT["RAID_SHOW_DEBUFFS"] = true
GW_DEFAULT["RAID_ONLY_DISPELL_DEBUFFS"] = false
GW_DEFAULT["RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF"] = false
GW_DEFAULT["RAID_AURA_TOOLTIP_IN_COMBAT"] = "IN_COMBAT"
GW_DEFAULT["RAID_UNIT_HEALTH"] = "NONE"

GW_DEFAULT["raid_party_pos"] = {}
GW_DEFAULT["raid_party_pos"]["point"] = "TOPLEFT"
GW_DEFAULT["raid_party_pos"]["relativePoint"] = "TOPLEFT"
GW_DEFAULT["raid_party_pos"]["xOfs"] = 480
GW_DEFAULT["raid_party_pos"]["yOfs"] = -760

GW_DEFAULT["RAID_CLASS_COLOR_PARTY"] = true
GW_DEFAULT["RAID_UNIT_FLAGS_PARTY"] = "NONE"
GW_DEFAULT["RAID_UNIT_MARKERS_PARTY"] = false
GW_DEFAULT["RAID_WIDTH_PARTY"] = 500
GW_DEFAULT["RAID_HEIGHT_PARTY"] = 80
GW_DEFAULT["RAID_POWER_BARS_PARTY"] = true
GW_DEFAULT["RAID_UNITS_PER_COLUMN_PARTY"] = 1
GW_DEFAULT["RAID_GROW_PARTY"] = "DOWN+RIGHT"
GW_DEFAULT["RAID_ANCHOR_PARTY"] = "TOPLEFT"
GW_DEFAULT["RAID_CONT_WIDTH_PARTY"] = 500
GW_DEFAULT["RAID_CONT_HEIGHT_PARTY"] = 80
GW_DEFAULT["RAID_SHOW_DEBUFFS_PARTY"] = true
GW_DEFAULT["RAID_ONLY_DISPELL_DEBUFFS_PARTY"] = false
GW_DEFAULT["RAID_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF_PARTY"] = true
GW_DEFAULT["RAID_SORT_BY_ROLE_PARTY"] = false
GW_DEFAULT["RAID_AURA_TOOLTIP_INCOMBAT_PARTY"] = "IN_COMBAT"
GW_DEFAULT["RAID_UNIT_HEALTH_PARTY"] = "NONE"

GW_DEFAULT["PARTY_UNIT_HEALTH"] = "NONE"
GW_DEFAULT["PARTY_SHOW_DEBUFFS"] = true
GW_DEFAULT["PARTY_ONLY_DISPELL_DEBUFFS"] = false
GW_DEFAULT["PARTY_SHOW_IMPORTEND_RAID_INSTANCE_DEBUFF"] = false
GW_DEFAULT["PARTY_PLAYER_FRAME"] = false
GW_DEFAULT["PARTY_SHOW_PETS"] = false
GW_DEFAULT["FADE_GROUP_MANAGE_FRAME"] = false

GW_DEFAULT["RAIDDEBUFFS_Scale"] = 1
GW_DEFAULT["DISPELL_DEBUFFS_Scale"] = 1
GW_DEFAULT["RAIDDEBUFFS_DISPELLDEBUFF_SCALE_PRIO"] = "DISPELL"

GW_DEFAULT["AUTO_REPAIR"] = false
GW_DEFAULT["HUD_SCALE"] = 1
GW_DEFAULT["MINIMAP_SCALE"] = 170
GW_DEFAULT["MINIMAP_FPS"] = false
GW_DEFAULT["MINIMAP_COORDS_PRECISION"] = 0
GW_DEFAULT["WORLDMAP_COORDS_TOGGLE"] = false
GW_DEFAULT["MINIMAP_COORDS_TOGGLE"] = false
GW_DEFAULT["CASTINGBAR_DATA"] = false
GW_DEFAULT["USE_CHARACTER_WINDOW"] = true

GW_DEFAULT["QUESTTRACKER_SORTING"] = "DEFAULT"

GW_DEFAULT["AURAS_IGNORED"] = strjoin(", ", unpack(GW.MapTable(GW.AURAS_IGNORED, GetSpellInfo)))
GW_DEFAULT["AURAS_MISSING"] = strjoin(", ", unpack(GW.MapTable(GW.AURAS_MISSING, GetSpellInfo)))
GW_DEFAULT["INDICATORS_ICON"] = false
GW_DEFAULT["INDICATORS_TIME"] = true
GW_DEFAULT["INDICATOR_BAR"] = {
    [0] = 0,
    [256] = 194384  -- Discipline: Atonement
}
GW_DEFAULT["INDICATOR_TOPLEFT"] = 0
GW_DEFAULT["INDICATOR_TOP"] = 0
GW_DEFAULT["INDICATOR_TOPRIGHT"] = 0
GW_DEFAULT["INDICATOR_LEFT"] = 0
GW_DEFAULT["INDICATOR_CENTER"] = 0
GW_DEFAULT["INDICATOR_RIGHT"] = 0

GW_DEFAULT["MAINMENU_SKIN_ENABLED"] = true
GW_DEFAULT["STATICPOPUP_SKIN_ENABLED"] = true
GW_DEFAULT["BNTOASTFRAME_SKIN_ENABLED"] = true
GW_DEFAULT["DROPDOWN_SKIN_ENABLED"] = true
GW_DEFAULT["BLIZZARDCLASSCOLOR_ENABLED"] = false
GW_DEFAULT["ADDONLIST_SKIN_ENABLED"] = true
GW_DEFAULT["BINDINGS_SKIN_ENABLED"] = true
GW_DEFAULT["BLIZZARD_OPTIONS_SKIN_ENABLED"] = true
GW_DEFAULT["MACRO_SKIN_ENABLED"] = true
GW_DEFAULT["WORLDMAP_SKIN_ENABLED"] = true

GW_DEFAULT["SORT_BAGS_RIGHT_TO_LEFT"] = 1
GW_DEFAULT["CURSOR_ANCHOR_TYPE"] = "ANCHOR_CURSOR"
GW_DEFAULT["ANCHOR_CURSOR_OFFSET_X"] = 0
GW_DEFAULT["ANCHOR_CURSOR_OFFSET_Y"] = 0

GW_DEFAULT["MAINBAR_RANGEINDICATOR"] = "RED_INDICATOR"

GW_DEFAULT["ACTIVE_PROFILE"] = nil

GW_DEFAULT["PlayerBuffFrame"] = {}
GW_DEFAULT["PlayerBuffFrame"]["point"] = "BOTTOMLEFT"
GW_DEFAULT["PlayerBuffFrame"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["PlayerBuffFrame"]["xOfs"] = 53
GW_DEFAULT["PlayerBuffFrame"]["yOfs"] = 120
GW_DEFAULT["PlayerBuffFrame_GrowDirection"] = "UP"
GW_DEFAULT["PlayerBuffFrame_scale"] = 1

GW_DEFAULT["PlayerDebuffFrame"] = {}
GW_DEFAULT["PlayerDebuffFrame"]["point"] = "BOTTOMLEFT"
GW_DEFAULT["PlayerDebuffFrame"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["PlayerDebuffFrame"]["xOfs"] = 53
GW_DEFAULT["PlayerDebuffFrame"]["yOfs"] = 220
GW_DEFAULT["PlayerDebuffFrame_GrowDirection"] = "UP"
GW_DEFAULT["PlayerDebuffFrame_scale"] = 1

GW_DEFAULT["PlayerBuffFrame_Seperate"] = 0
GW_DEFAULT["PlayerDebuffFrame_Seperate"] = 0

GW_DEFAULT["PlayerBuffFrame_SortDir"] = "+"
GW_DEFAULT["PlayerDebuffFrame_SortDir"] = "+"

GW_DEFAULT["PlayerBuffFrame_SortMethod"] = "INDEX"
GW_DEFAULT["PlayerDebuffFrame_SortMethod"] = "INDEX"

GW_DEFAULT["PLAYER_AURA_WRAP_NUM_DEBUFF"] = 7
GW_DEFAULT["PLAYER_AURA_WRAP_NUM"] = 7
GW_DEFAULT["PLAYER_ENERGY_MANA_TICK"] = true
GW_DEFAULT["PLAYER_ENERGY_MANA_TICK_HIDE_OFC"] = false
GW_DEFAULT["PLAYER_5SR_TIMER"] = true
GW_DEFAULT["PLAYER_AURA_ANIMATION"] = true
GW_DEFAULT["PlayerBuffFrame_ICON_SIZE"] = 32
GW_DEFAULT["PlayerDebuffFrame_ICON_SIZE"] = 32
GW_DEFAULT["PLAYER_TRACKED_DODGEBAR_SPELL"] = ""
GW_DEFAULT["PLAYER_TRACKED_DODGEBAR_SPELL_ID"] = 0
GW_DEFAULT["PLAYER_AS_TARGET_FRAME"] = false
GW_DEFAULT["PLAYER_AS_TARGET_FRAME_SHOW_RESSOURCEBAR"] = false
GW_DEFAULT["player_CLASS_COLOR"] = false
GW_DEFAULT["PLAYER_SHOW_PVP_INDICATOR"] = true
GW_DEFAULT["PLAYER_CASTBAR_SHOW_SPELL_QUEUEWINDOW"] = true

-- incompatible addons
GW_DEFAULT.IncompatibleAddons = {
    Actionbars = {
        Override = false,
        Addons = {
            "Bartender4",
            "Dominos",
        },
    },
    ImmersiveQuesting = {
        Override = false,
        Addons = {
            "Storyline",
            "Immersive",
            "Immersion",
            "Tofu",
            "Queso",
        },
    },
    DynamicCam = {
        Override = false,
        Addons = {
            "DynamicCam",
            "Queso",
        },
    },
    Inventory = {
        Override = false,
        Addons = {
            "AdiBags",
            "ArkInventory",
            "Bagnon",
            "Sorted",
        },
    },
    Minimap = {
        Override = false,
        Addons = {
            "SexyMap",
        },
    },
    FloatingCombatText = {
        Override = false,
        Addons = {
            "ClassicFCT",
            "xCT+",
            "NameplateSCT",
        },
    },
    Objectives = {
        Override = false,
        Addons = {
            "!KalielsTracker",
        },
    },
}
