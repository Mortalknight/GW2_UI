-- enUS localization

local function GWUseThisLocalization()
-- Create a global variable for the language strings
GwLocalization = {}

-- Settings
GwLocalization['SETTINGS_TITLE'] = 'Settings' 
GwLocalization['MOVE_HUD_BUTTON'] = 'Move HUD' 
GwLocalization['SETTINGS_RESET_TO_DEFAULT'] = 'Reset to Default.'
GwLocalization['SETTINGS_ACCEPT'] = 'Accept' 
GwLocalization['SETTINGS_CANCEL'] = 'Cancel' 
GwLocalization['SETTINGS_VERSION'] = 'Version' 
GwLocalization['SETTINGS_SAVE_RELOAD'] = 'Save and Reload' 
GwLocalization['SETTINGS_DELETE'] = 'Delete' 
GwLocalization['SETTINGS_ACTIVATE'] = 'Activate' 
GwLocalization['SETTINGS_BUTTON'] = 'GW2 UI Settings' 
GwLocalization['SETTING_LOCK_HUD'] = 'Lock HUD' 


GwLocalization['MODULES_CAT'] = 'MODULES' 
GwLocalization['MODULES_CAT_TOOLTIP'] = 'Enable and disable components' 
GwLocalization['MODULES_DESC'] = 'Enable or disable the modules you need and don\'t need.' 
GwLocalization['MODULES_TOOLTIP'] = 'Enable or disable UI modules.'
GwLocalization['HEALTH_GLOBE'] = 'Health Globe' 
GwLocalization['RESOURCE'] = 'Resource Bar' 
GwLocalization['FOCUS_FRAME'] = 'Focus Target Frame' 
GwLocalization['TARGET_FRAME'] = 'Target Frame' 
GwLocalization['CHAT_BUBBLES'] = 'Chat Bubbles' 
GwLocalization['MINIMAP'] = 'Minimap'  
GwLocalization['QUEST_TRACKER'] = 'Quest Tracker' 
GwLocalization['TOOLTIPS'] = 'Tooltips' 
GwLocalization['CHAT_FRAME'] = 'Chat Frame' 
GwLocalization['QUESTING_FRAME'] = 'Immersive Questing' 
GwLocalization['PLAYER_AURAS'] = 'Player Auras' 
GwLocalization['ACTION_BARS'] = 'Action Bars' 
GwLocalization['INVENTORY_FRAME'] = 'Inventory Frame' 
GwLocalization['FONTS'] = 'Fonts' 
GwLocalization['CASTING_BAR'] = 'Casting Bar' 
GwLocalization['CLASS_POWER'] = 'Class Power' 
GwLocalization['GROUP_FRAMES'] = 'Group Frames' 

GwLocalization['TARGET_CAT'] = 'TARGET' 
GwLocalization['TARGET_DESC'] = 'Modify the target frame settings.'
GwLocalization['TARGET_TOOLTIP'] = 'Edit the target frame settings.' 
GwLocalization['TARGET_OF_TARGET'] = 'Target of Target' 
GwLocalization['HEALTH_VALUE'] = 'Health Value' 
GwLocalization['HEALTH_PERCENTAGE'] = 'Health Percentage' 
GwLocalization['CLASS_COLOR'] = 'Class Color' 
GwLocalization['SHOW_DEBUFFS'] = 'Show Debuffs' 
GwLocalization['SHOW_ALL_DEBUFFS'] = 'Show All Debuffs' 
GwLocalization['SHOW_BUFFS'] = 'Show Buffs' 

GwLocalization['FOCUS_CAT'] = 'FOCUS' 
GwLocalization['FOCUS_DESC'] = 'Modify the focus frame settings.'
GwLocalization['FOCUS_TOOLTIP'] = 'Edit the focus frame settings.' 
GwLocalization['FOCUS_TARGET'] = 'Focus Target' 

GwLocalization['HUD_CAT'] = 'HUD' 
GwLocalization['HUD_DESC'] = 'Edit the modules in the Heads-Up Display for more customization.' 
GwLocalization['HUD_TOOLTIP'] = 'Edit the HUD modules.' 
GwLocalization['ACTION_BAR_FADE'] = 'Fade Action Bars' 
GwLocalization['DYNAMIC_HUD'] = 'Dynamic HUD' 
GwLocalization['CHAT_FADE'] = 'Fade Chat' 
GwLocalization['HIDE_EMPTY_SLOTS'] = 'Hide Empty Slots' 
GwLocalization['COMPASS_TOGGLE'] = 'Toggle Compass' 
GwLocalization['ADV_CAST_BAR'] = 'Advanced Casting Bar' 
GwLocalization['HUD_SCALE'] = 'HUD Scale' 
    GwLocalization['HUD_SCALE_DEFAULT'] = 'Default' 
    GwLocalization['HUD_SCALE_SMALL'] = 'Small' 
    GwLocalization['HUD_SCALE_TINY'] = 'Tiny' 
GwLocalization['MINIMAP_SCALE'] = 'Minimap Scale' 
    GwLocalization['MINIMAP_SCALE_LARGE'] = 'Large' 
    GwLocalization['MINIMAP_SCALE_MEDIUM'] = 'Medium' 
    GwLocalization['MINIMAP_SCALE_DEFAULT'] = 'Default' 

GwLocalization['GROUP_CAT'] = 'GROUP' 
GwLocalization['GROUP_DESC'] = 'Edit the party and raid options to suit your needs.' 
GwLocalization['GROUP_TOOLTIP'] = 'Edit the group settings.' 
GwLocalization['RAID_PARTY_STYLE'] = 'Raid Styled Party' 
GwLocalization['CLASS_COLOR_RAID'] = 'Use Class Colors' 
GwLocalization['POWER_BARS_RAID'] = 'Show Power Bars' 
GwLocalization['DEBUFF_DISPELL'] = 'Display only Dispellable Debuffs' 
GwLocalization['RAID_CONT_HEIGHT'] = 'Set Raid Frame Container Height' 
GwLocalization['RAID_BAR_WIDTH'] = 'Set Raid Unit Width' 
GwLocalization['RAID_BAR_HEIGHT'] = 'Set Raid Unit Height' 

GwLocalization['PROFILES_CAT'] = 'PROFILES' 
GwLocalization['PROFILES_DESC'] = 'Profiles are an easy way to share your settings across characters and realms.' 
GwLocalization['PROFILES_TOOLTIP'] = 'Add and remove profiles.' 
GwLocalization['PROFILES_DEFAULT_SETTINGS'] = 'Default Settings' 
GwLocalization['PROFILES_DEFAULT_SETTINGS_PROMPT'] = 'Are you sure you want to load the default settings?\n\nAll previous settings will be lost.' 
GwLocalization['PROFILES_NEW_PROFILE'] = 'New Profile' 
GwLocalization['PROFILES_LOAD_BUTTON'] = 'Load' 
GwLocalization['PROFILES_CREATED'] = 'Created: ' 
GwLocalization['PROFILES_CREATED_BY'] = '\nCreated by: ' 
GwLocalization['PROFILES_LAST_UPDATE'] = '\nLast updated: ' 
GwLocalization['PROFILES_DELETE'] = 'Are you sure you want to delete this profile?' 
GwLocalization['PROFILES_MISSING_LOAD'] = 'If you see this message. We forgot to load some text. Dont worry we have very capable sample text just like this one to fill you with the information.' 


GwLocalization['SETTINGS_NO_LOAD_ERROR'] = 'Some text has not loaded, please try refreshing the interface.'


    -- Settings Descriptions
    GwLocalization['HEALTH_GLOBE_DESC'] = 'Enable the health bar replacement.' 
    GwLocalization['RESOURCE_DESC'] = 'Replace the default mana/power bar.' 
    GwLocalization['FOCUS_FRAME_DESC'] = 'Enable the focus target frame replacement.' 
    GwLocalization['TARGET_FRAME_DESC'] = 'Enable the target frame replacement.' 
    GwLocalization['CHAT_BUBBLES_DESC'] = 'Replace the default UI chat bubbles.' 
    GwLocalization['MINIMAP_DESC'] = 'Use the GW2 UI Minimap frame.' 
    GwLocalization['QUEST_TRACKER_DESC'] = 'Enable the revamped and improved quest tracker.' 
    GwLocalization['TOOLTIPS_DESC'] = 'Replace the default UI tooltips.' 
    GwLocalization['CHAT_FRAME_DESC'] = 'Enable the improved chat window.' 
    GwLocalization['QUESTING_FRAME_DESC'] = 'Enable the immersive questing view.' 
    GwLocalization['PLAYER_AURAS_DESC'] = 'Move and resize the player auras.' 
    GwLocalization['ACTION_BARS_DESC'] = 'Use the GW2 UI improved action bars.' 
    GwLocalization['INVENTORY_FRAME_DESC'] = 'Enable the unified inventory interface.' 
    GwLocalization['FONTS_DESC'] = 'Replace the default fonts with GW2 UI fonts.' 
    GwLocalization['CASTING_BAR_DESC'] = 'Enable the GW2 style casting bar.' 
    GwLocalization['CLASS_POWER_DESC'] = 'Enable the alternate class powers.' 
    GwLocalization['GROUP_FRAMES_DESC'] = 'Replace the default UI group frames.' 

    GwLocalization['TARGET_OF_TARGET_DESC'] = 'Enable the target of target frame.' 
    GwLocalization['HEALTH_VALUE_DESC'] = 'Show health as a numerical value.' 
    GwLocalization['HEALTH_PERCENTAGE_DESC'] = 'Display health as a percentage. Can be used as well as, or instead of Health Value.' 
    GwLocalization['CLASS_COLOR_DESC'] = 'Display the class color as the health bar.' 
    GwLocalization['SHOW_DEBUFFS_DESC'] = 'Display the target\'s debuffs that you have inflicted.' 
    GwLocalization['SHOW_ALL_DEBUFFS_DESC'] = 'Display all of the target\'s debuffs.' 
    GwLocalization['SHOW_BUFFS_DESC'] = 'Display the target\'s buffs.' 

    GwLocalization['FOCUS_TARGET_DESC'] = 'Display the focus target frame.' 

    GwLocalization['ACTION_BAR_FADE_DESC'] = 'Fade the additional action bars when out of combat.' 
    GwLocalization['DYNAMIC_HUD_DESC'] = 'Enable or disable the dynamically changing HUD background.' 
    GwLocalization['CHAT_FADE_DESC'] = 'Allow the chat to fade when not in use.' 
    GwLocalization['HIDE_EMPTY_SLOTS_DESC'] = 'Hide the empty action bar slots.' 
    GwLocalization['COMPASS_TOGGLE_DESC'] = 'Enable or disable the quest tracker compass.' 
    GwLocalization['ADV_CAST_BAR_DESC'] = 'Enable or disable the advanced casting bar.' 
    GwLocalization['HUD_SCALE_DESC'] = 'Change the HUD size.' 
    GwLocalization['MINIMAP_SCALE_DESC'] = 'Change the Minimap size.' 

    GwLocalization['RAID_PARTY_STYLE_DESC'] = 'Style the party frames like the raid frames.' 
    GwLocalization['CLASS_COLOR_RAID_DESC'] = 'Use the class color instead of class icons.' 
    GwLocalization['POWER_BARS_RAID_DESC'] = 'Display the power bars on the raid units.' 
    GwLocalization['DEBUFF_DISPELL_DESC'] = 'Only displays the debuffs that you are able to dispell.' 
    GwLocalization['RAID_CONT_HEIGHT_DESC'] = 'Set the maximum height that the raid frames can be displayed.' 
    GwLocalization['RAID_BAR_WIDTH_DESC'] = 'Set the width of the raid units.' 
    GwLocalization['RAID_BAR_HEIGHT_DESC'] = 'Set the height of the raid units.' 

    GwLocalization['PROFILES_DEFAULT_SETTINGS_DESC'] = 'Load the default addon settings to the current profile.' 
	
	GwLocalization['HUD_MOVE_ERR'] = 'You can not move elements during combat!' 

    

-- Bags
GwLocalization['INVENTORY_TITLE'] = 'Inventory'  
GwLocalization['COMPACT_ICONS'] = 'Compact Icons' 
GwLocalization['EXPAND_ICONS'] = 'Large Icons' 
GwLocalization['SORT_BAGS'] = 'Sort Bags'  
GwLocalization['CLICK_TO_TRACK'] = 'Click to track' 

-- Bank
GwLocalization['BANK_TITLE'] = 'Bank' 
GwLocalization['REAGENT_BANK_TITLE'] = 'Reagents Bank' 
GwLocalization['BANK_BUY_SLOTS'] = 'Purchase More Slots' 
GwLocalization['REAGENT_BANK_DEPOSIT_ALL'] = 'Deposit All' 
GwLocalization['PURCHASE_REAGENT_BANK'] = 'Purchase ' 
GwLocalization['SORT_BANK'] = 'Sort Bank' 
GwLocalization['BANK_COMPACT_ICONS'] = 'Compact Icons' 
GwLocalization['BANK_EXPAND_ICONS'] = 'Large Icons' 
GwLocalization['NAME_LOAD_ERROR'] = 'Name could not be loaded'
GwLocalization['AMOUNT_LOAD_ERROR'] = 'Amount could not be loaded'

-- Character
GwLocalization['CHARACTER_TITLE'] = 'Hero'
GwLocalization['CHARACTER_HEADER'] = 'Character' 
GwLocalization['CHARACTER_NOT_LOADED'] = 'Not loaded.' 
GwLocalization['CHARCTER_EQUIP_OUTFIT'] = 'Equip' 
GwLocalization['CHARACTER_SAVE_OUTFIT'] = 'Save' 
GwLocalization['CHARACTER_DELETE_OUTFIT'] = 'Delete' 
GwLocalization['CHARACTER_MENU_EQUIPMENT'] = 'Equipment' 
GwLocalization['CHARACTER_MENU_OUTFITS'] = 'Outfits' 
GwLocalization['CHARACTER_MENU_TITLES'] = 'Titles' 
GwLocalization['CHARACTER_MENU_REPS'] = 'Reputations' 
GwLocalization['CHARACTER_MENU_EQUIPMENT_RETURN'] = 'Character: Equipment' 
GwLocalization['CHARACTER_MENU_OUTFITS_RETURN'] = 'Character: Outfits' 
GwLocalization['CHARACTER_MENU_TITLES_RETURN'] = 'Character: Titles' 
GwLocalization['CHARACTER_MENU_REPS_RETURN'] = 'Character: Reputation' 
GwLocalization['CHARACTER_NAME_UNKNOWN'] = 'Unknown'
GwLocalization['CHARACTER_STATS'] = 'Stats'
GwLocalization['CHARACTER_LEVEL_CLASS'] = 'Level %n class'
GwLocalization['CHARACTER_CURRENT_RANK'] = 'CURRENT' 
GwLocalization['CHARACTER_NEXT_RANK'] = 'NEXT' 
GwLocalization['CHARACTER_REP_SEARCH'] = 'Search...' 
GwLocalization['CHARACTER_OUTFITS_SAVE'] = 'Are you sure you want to save the outfit "' 
GwLocalization['CHARACTER_OUTFITS_DELETE'] = 'Are you sure you want to delete the outfit "' 
GwLocalization['CHARACTER_REPUTATION_INACTIVE'] = 'Inactive' 
GwLocalization['CHARACTER_REPUTATION_TRACK'] = 'Show as bar' 
GwLocalization['CHARACTER_OUTFIT_NEW'] = 'New outfit' 

-- HUD
GwLocalization['DAMAGED_OR_BROKEN_EQUIPMENT'] = 'Damaged or broken equipment' 
GwLocalization['LEVEL_REWARDS'] = 'Upcoming Level Rewards' 
GwLocalization['LEVEL_REWARDS_RHEADER'] = 'REWARD' 
GwLocalization['LEVEL_REWARDS_LHEADER'] = 'LEVEL' 
GwLocalization['LEVEL_REWARDS_CLOSE'] = 'Close' 
GwLocalization['LEVEL_REWARDS_TALENT'] = 'Talent Point' 
GwLocalization['EXP_BAR_TOOLTIP_EXP_TITLE'] = 'Experience' 
GwLocalization['EXP_BAR_TOOLTIP_EXP_VALUE'] = 'Experience ' 
GwLocalization['EXP_BAR_TOOLTIP_EXP_RESTING'] = ' (Resting)' 
GwLocalization['EXP_BAR_TOOLTIP_EXP_RESTED'] = 'Rested ' 
GwLocalization['EXP_BAR_TOOLTIP_ARTIFACT'] = '\nArtifact: ' 
GwLocalization['EXP_BAR_TOOLTIP_REP'] = ' Reputation ' 
GwLocalization['EXP_BAR_TOOLTIP_HONOR'] = 'Honor ' 
GwLocalization['GW_BAG_MICROBUTTON_STRING'] = 'Inventory' 
GwLocalization['UPDATE_STRING_3'] = 'An |cFFFF0000major|r update is available.\nIt\'s strongly recommended that you update.' 
GwLocalization['UPDATE_STRING_2'] = 'New update available containing new features.' 
GwLocalization['UPDATE_STRING_1'] = 'New update available for download.' 
GwLocalization['FPS_TOOLTIP_1'] = 'FPS ' 
GwLocalization['FPS_TOOLTIP_2'] = 'Latency (Home) ' 
GwLocalization['FPS_TOOLTIP_3'] = 'Latency (World) ' 
GwLocalization['MINIMAP_HOVER'] = 'Minimap details' 
GwLocalization['MINIMAP_HOVER_TOOLTIP'] = 'Show Minimap details on mouseover' 

-- Party
GwLocalization['PARTY_INVITE'] = 'Invite' 
GwLocalization['PARTY_LEAVE'] = 'Leave' 
GwLocalization['PARTY_READY_CHECK'] = 'Ready Check' 
GwLocalization['PARTY_ROLE_CHECK'] = 'Role Check' 
GwLocalization['PARTY_CONVERT'] = 'Convert to Raid' 
GwLocalization['RAID_CONVERT'] = 'Convert to Party' 
GwLocalization['PARTY_INVITE_STRING'] = 'Player Name' 

-- Quest Tracker
GwLocalization['TRACKER_QUEST_TITLE'] = 'Quests' 
GwLocalization['TRACKER_TIME_REMAINING'] = 'Time Remaining' 
GwLocalization['TRACKER_MORE_ADVENTURES'] = 'More adventures await:' 
GwLocalization['TRACKER_ACHIEVEMENTS'] = 'Achievements' 
GwLocalization['TRACKER_EVENTS'] = 'Events' 

-- Quest View
GwLocalization['QUEST_VIEW_DECLINE'] = 'Decline'
GwLocalization['QUEST_VIEW_SKIP'] = 'Skip' 
GwLocalization['QUEST_VIEW_ACCPET'] = 'Accept' 
GwLocalization['QUEST_VIEW_COMPLETE'] = 'Complete' 

-- Map
GwLocalization['MAP_CLOCK_TITLE'] = 'Clock' 
GwLocalization['MAP_CLOCK_LOCAL_REALM'] = 'Shift-Click to switch between Local and Realm time' 
GwLocalization['MAP_CLOCK_STOPWATCH'] = 'Right Click to open the Stopwatch' 
GwLocalization['MAP_CLOCK_MILITARY'] = 'Left Click to toggle military time format' 
GwLocalization['MAP_CLOCK_DISPLAY'] = 'Display: ' 

end

local Locale = GetLocale()
if Locale ~= "deDE" then
	GWUseThisLocalization()
end

-- After using this localization or deciding that we don"t need it, remove it from memory.
GWUseThisLocalization = nil
