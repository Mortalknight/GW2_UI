local _, GW = ...

local GW_DEFAULT = {}
GW.DEFAULTS = GW_DEFAULT

GW_DEFAULT["TARGET_ENABLED"] = true
GW_DEFAULT["FOCUS_ENABLED"] = true
GW_DEFAULT["PET_ENABLED"] = true
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
GW_DEFAULT["SHOW_QUESTTRACKER_COMPASS"] = true
GW_DEFAULT["MINIMAP_HOVER"] = "NONE"
GW_DEFAULT["CLASS_POWER"] = true
GW_DEFAULT["GROUP_FRAMES"] = true
GW_DEFAULT["PETBAR_ENABLED"] = true
GW_DEFAULT["PETBAR_LOCKED"] = true
GW_DEFAULT["TOOLTIP_MOUSE"] = false

GW_DEFAULT["BUTTON_ASSIGNMENTS"] = true

GW_DEFAULT["HUD_SPELL_SWAP"] = true

GW_DEFAULT["BAG_ITEM_SIZE"] = 45
GW_DEFAULT["BANK_ITEM_SIZE"] = 45

GW_DEFAULT["BAG_WIDTH"] = 480
GW_DEFAULT["BAG_REVERSE_SORT"] = true

GW_DEFAULT["BAG_POSITION"] = {}
GW_DEFAULT["BAG_POSITION"]["point"] = "RIGHT"
GW_DEFAULT["BAG_POSITION"]["relativePoint"] = "RIGHT"
GW_DEFAULT["BAG_POSITION"]["xOfs"] = -256
GW_DEFAULT["BAG_POSITION"]["yOfs"] = 256

GW_DEFAULT["BANK_WIDTH"] = 720
GW_DEFAULT["BANK_REVERSE_SORT"] = false

GW_DEFAULT["BANK_POSITION"] = {}
GW_DEFAULT["BANK_POSITION"]["point"] = "LEFT"
GW_DEFAULT["BANK_POSITION"]["relativePoint"] = "LEFT"
GW_DEFAULT["BANK_POSITION"]["xOfs"] = 256
GW_DEFAULT["BANK_POSITION"]["yOfs"] = 256

GW_DEFAULT["RAID_CLASS_COLOR"] = false
GW_DEFAULT["RAID_STYLE_PARTY"] = false
GW_DEFAULT["RAID_UNIT_FLAGS"] = "NONE"
GW_DEFAULT["RAID_UNIT_MARKERS"] = false

GW_DEFAULT["target_HEALTH_VALUE_ENABLED"] = false
GW_DEFAULT["target_HEALTH_VALUE_TYPE"] = false
GW_DEFAULT["target_CLASS_COLOR"] = true

GW_DEFAULT["FADE_BOTTOM_ACTIONBAR"] = true
GW_DEFAULT["HIDE_CHATSHADOW"] = false
GW_DEFAULT["HIDE_QUESTVIEW"] = false
GW_DEFAULT["USE_CHAT_BUBBLES"] = false
GW_DEFAULT["DISABLE_NAMEPLATES"] = false
GW_DEFAULT["DISABLE_TOOLTIPS"] = false
GW_DEFAULT["DISABLE_CHATFRAME"] = false
GW_DEFAULT["CHATFRAME_FADE"] = true
GW_DEFAULT["FADE_MICROMENU"] = false

GW_DEFAULT["target_TARGET_ENABLED"] = true
GW_DEFAULT["target_DEBUFFS"] = true
GW_DEFAULT["target_DEBUFFS_FILTER"] = true
GW_DEFAULT["target_BUFFS"] = true
GW_DEFAULT["target_BUFFS_FILTER"] = true
GW_DEFAULT["target_BUFFS_FILTER_ALL"] = false

GW_DEFAULT["focus_TARGET_ENABLED"] = true
GW_DEFAULT["focus_DEBUFFS"] = true
GW_DEFAULT["focus_DEBUFFS_FILTER"] = true
GW_DEFAULT["focus_BUFFS"] = true
GW_DEFAULT["focus_BUFFS_FILTER"] = true
GW_DEFAULT["focus_BUFFS_FILTER_ALL"] = false

GW_DEFAULT["focus_HEALTH_VALUE_ENABLED"] = false
GW_DEFAULT["focus_HEALTH_VALUE_TYPE"] = false
GW_DEFAULT["focus_CLASS_COLOR"] = true

GW_DEFAULT["target_x_position"] = -100
GW_DEFAULT["target_y_position"] = -100

GW_DEFAULT["focus_x_position"] = -350
GW_DEFAULT["focus_y_position"] = -100

GW_DEFAULT["multibarleft_x_position"] = -300
GW_DEFAULT["multibarleft_y_position"] = -0

GW_DEFAULT["multibarright_x_position"] = -260
GW_DEFAULT["multibarright_y_position"] = -0

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

GW_DEFAULT["pet_pos"] = {}
GW_DEFAULT["pet_pos"]["point"] = "BOTTOMLEFT"
GW_DEFAULT["pet_pos"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["pet_pos"]["xOfs"] = -372
GW_DEFAULT["pet_pos"]["yOfs"] = 86

GW_DEFAULT["castingbar_pos"] = {}
GW_DEFAULT["castingbar_pos"]["point"] = "BOTTOM"
GW_DEFAULT["castingbar_pos"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["castingbar_pos"]["xOfs"] = 0
GW_DEFAULT["castingbar_pos"]["yOfs"] = 300

GW_DEFAULT["targettarget_pos"] = {}
GW_DEFAULT["targettarget_pos"]["point"] = "TOP"
GW_DEFAULT["targettarget_pos"]["relativePoint"] = "TOP"
GW_DEFAULT["targettarget_pos"]["xOfs"] = 250
GW_DEFAULT["targettarget_pos"]["yOfs"] = -100

GW_DEFAULT["focus_pos"] = {}
GW_DEFAULT["focus_pos"]["point"] = "CENTER"
GW_DEFAULT["focus_pos"]["relativePoint"] = "CENTER"
GW_DEFAULT["focus_pos"]["xOfs"] = -350
GW_DEFAULT["focus_pos"]["yOfs"] = 0

GW_DEFAULT["focustarget_pos"] = {}
GW_DEFAULT["focustarget_pos"]["point"] = "CENTER"
GW_DEFAULT["focustarget_pos"]["relativePoint"] = "CENTER"
GW_DEFAULT["focustarget_pos"]["xOfs"] = -80
GW_DEFAULT["focustarget_pos"]["yOfs"] = 0

GW_DEFAULT["MultiBarBottomLeft"] = {}
GW_DEFAULT["MultiBarBottomLeft"]["point"] = "BOTTOMLEFT"
GW_DEFAULT["MultiBarBottomLeft"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["MultiBarBottomLeft"]["xOfs"] = -372
GW_DEFAULT["MultiBarBottomLeft"]["yOfs"] = 120

GW_DEFAULT["MultiBarBottomLeft"]["size"] = 38
GW_DEFAULT["MultiBarBottomLeft"]["margin"] = 2
GW_DEFAULT["MultiBarBottomLeft"]["ButtonsPerRow"] = 6
GW_DEFAULT["MultiBarBottomLeft"]["hideDefaultBackground"] = true

GW_DEFAULT["MultiBarBottomRight"] = {}
GW_DEFAULT["MultiBarBottomRight"]["point"] = "BOTTOMRIGHT"
GW_DEFAULT["MultiBarBottomRight"]["relativePoint"] = "BOTTOM"
GW_DEFAULT["MultiBarBottomRight"]["xOfs"] = 372
GW_DEFAULT["MultiBarBottomRight"]["yOfs"] = 120

GW_DEFAULT["MultiBarBottomRight"]["size"] = 38
GW_DEFAULT["MultiBarBottomRight"]["margin"] = 2
GW_DEFAULT["MultiBarBottomRight"]["ButtonsPerRow"] = 6
GW_DEFAULT["MultiBarBottomRight"]["hideDefaultBackground"] = true

GW_DEFAULT["MULTIBAR_RIGHT_COLS"] = 1

GW_DEFAULT["MultiBarRight"] = {}
GW_DEFAULT["MultiBarRight"]["point"] = "RIGHT"
GW_DEFAULT["MultiBarRight"]["relativePoint"] = "RIGHT"
GW_DEFAULT["MultiBarRight"]["xOfs"] = -320
GW_DEFAULT["MultiBarRight"]["yOfs"] = 0

GW_DEFAULT["MultiBarRight"]["size"] = 38
GW_DEFAULT["MultiBarRight"]["margin"] = 2
GW_DEFAULT["MultiBarRight"]["ButtonsPerRow"] = 1
GW_DEFAULT["MultiBarRight"]["hideDefaultBackground"] = true

GW_DEFAULT["MultiBarLeft"] = {}
GW_DEFAULT["MultiBarLeft"]["point"] = "RIGHT"
GW_DEFAULT["MultiBarLeft"]["relativePoint"] = "RIGHT"
GW_DEFAULT["MultiBarLeft"]["xOfs"] = -368
GW_DEFAULT["MultiBarLeft"]["yOfs"] = 0

GW_DEFAULT["MultiBarLeft"]["size"] = 38
GW_DEFAULT["MultiBarLeft"]["margin"] = 2
GW_DEFAULT["MultiBarLeft"]["ButtonsPerRow"] = 1
GW_DEFAULT["MultiBarLeft"]["hideDefaultBackground"] = true

GW_DEFAULT["raid_pos"] = {}
GW_DEFAULT["raid_pos"]["point"] = "TOPLEFT"
GW_DEFAULT["raid_pos"]["relativePoint"] = "TOPLEFT"
GW_DEFAULT["raid_pos"]["xOfs"] = 65
GW_DEFAULT["raid_pos"]["yOfs"] = -60

GW_DEFAULT["RAID_WIDTH"] = 55
GW_DEFAULT["RAID_HEIGHT"] = 47
GW_DEFAULT["RAID_POWER_BARS"] = false
GW_DEFAULT["RAID_UNITS_PER_COLUMN"] = 5
GW_DEFAULT["RAID_ONLY_DISPELL_DEBUFFS"] = false

GW_DEFAULT["HUD_SCALE"] = 1
GW_DEFAULT["MINIMAP_SCALE"] = 170
GW_DEFAULT["CASTINGBAR_DATA"] = false
GW_DEFAULT["USE_CHARACTER_WINDOW"] = true
GW_DEFAULT["USE_TALENT_WINDOW"] = true

GW_DEFAULT["USE_BATTLEGROUND_HUD"] = true

GW_DEFAULT["ACTIVE_PROFILE"] = nil
