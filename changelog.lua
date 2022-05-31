local _, GW = ...
local v = GW.vernotes

v("5.29.0", [=[
NEW
    - Added alert notification system
FIXES
    - Fix some rare lua errors
]=])

v("5.28.2", [=[
FIXES
    - Fix an error if pet grid is enabled
]=])

v("5.28.1", [=[
FIXES
    - Fix an error if no timestamp format is set
]=])

v("5.28.0", [=[
NEW
    - Added a toggle for target, target target, focus and focus target castbar
    - Added option to show a separate energy bar for some bosses like Anduin at the objectives boss frames
    - Added 2 Details skin (by SHOODOX)
    - Added GW2 style worldmap and minimap player pin
    - Added option to set a timer to auto scroll down the chat
    - Added option to set the number of chat messages which are scrolled with one scroll
    - Added an option to hide placeholder in move hud mode
    - Added ooption to hide tooltips ins combat and a override setting
    - Minimap can now be sized by a slider
    - New icons for chat buttons
    - New lfg animation

FIXES
    - Fix issue with target debuff spacing in some situations
    - Fix a wrong total reputation callculation per expansion
    - Hide voicetab correctly

]=])

v("5.27.1", [=[
    FIXES
    - You can now apply glyphs again
    - Fix a lua error while rename an equipment set
]=])

v("5.27.0", [=[
NEW
    - Added option to disable player new de/buff animation
FIXES
    - Some chat issues on russian clients
    - Possible actionbar lua error
    - Possible torghast fix
]=])

v("5.26.0", [=[
NEW
    - Make "PowerBarContainer" movable
    - Added individual bar width settings for multibar right 1 and 2

FIXES
    - Fix an issue with the multibar right 1 & 2 mover
    - Fix a chat issue on ruRU clients
    - Fix a lua error with barber skin
]=])

v("5.25.0", [=[
NEW
    - Update for 9.2.0
    - Split Inventory Skin and Loot Window Skin
    - Added indicator for unused talent points
    - Added new option 'XP Quest Percent', which shows how much % that quest gives you in relation to the total xp needed for next level
    - Added new option 'Mark Quest Reward', which marks the most valuable quest reward item
]=])

v("5.24.3", [=[
FIXES
    - Fix gossip skin error
]=])

v("5.24.2", [=[
FIXES
    - Fix rare player aura issue
]=])

v("5.24.1", [=[
FIXES
    - Fix player frame background overlay
]=])

v("5.24.0", [=[
NEW
    - Added option for alternative target/focus background texture

MISC
    - Tweak character talent frame
]=])

v("5.23.0", [=[
NEW
    - Skins:
        - LFG
        - Allied Races
        - Weekly Rewards
        - Chromie Time
    - Added option to change tooltip font size
    - Added option to show "SpellQueueWindow" on castbar

FIXES
    - Fix some cooldown issues for extra action buttons
    - Show correct buffs in vehicle UI
    - Some actionbar hotkey issues
]=])

v("5.22.1", [=[
FIXES
    - Fix cooldown lua error
]=])

v("5.22.0", [=[
NEW
    - Added option to set mainbar and multibar button spacing
    - Added System datainfo to minimap fps text
FIXES
    - Some tooltip issues
]=])

v("5.21.1", [=[
FIXES
    - Tooltip statusbar color
]=])

v("5.21.0", [=[
NEW
- Added text option to tooltip healthbar

FIXES
- Fix some tooltip issues
- Aura tooltips are now updating correctly to show remaning time
- Fix item upgrade skin
]=])

v("5.20.1", [=[
FIXES
    - 9.1.5 tooltip issue
]=])

v("5.19.0", [=[
NEW
    - Added raid pet grid
    - Added option to fade main actionbar

FIXES
    - Raid buff indicators should now show as expected
    - Fix charged combo points

]=])

v("5.19.2", [=[
FIXES
    - Minimap button issue

MISC
    - Update locals
]=])

v("5.19.1", [=[
FIXES
    - Ember court issue
    - Garrision minimap icon tweaks
]=])

v("5.19.0", [=[
NEW
    - Added 'Smart' Raid Markers: Use a defined key (via keybinds) to open the smart raid marker menu.
        This opens a circle with all raid markers directly under your cursor
    - Added a prio for scaling important and dispellable debuffs

MISC
    - Redo raid and party grid profiling
]=])

v("5.18.0", [=[
NEW
    - Added Encounter Journal, Soulbinds and Convenant Sanctum Skin
    - Added 'Friends' tooltip to character micro menu button
FIXES
    - Raid frame sort by role
]=])

v("5.17.2", [=[
FIXES
    - Missing raid buff pet battle overlapping
    - Raid frame sort by role

MISC
    - Added OmniCD support
]=])

v("5.17.1", [=[
FIXES
    - Tweak raid/party profiles and fix some bugs
    - You can now change raid/party profile settings while in a party/raid

    MISC
    - Added option to show chat timestamps for all messages
    - Added ability to add a custom sound for chat keyword alert
]=])

v("5.17.0", [=[
NEW
    - CHAT:
        Added lots of new settings to the chat module
            - Detacting URL Links and make them clickable
            - A Keyword System, which marks your keywords in the chat and plays a sound
            - Classcoloring char names
            - Short Channel names
            - Emoticon's
            - Show role icons before the names (if you are in a raid or party)
            - Spam Intervall: Hides the same messages in a given time
            - Combat Repeate: Close the chat editbox if you type in the same char for a given number while in combat
            - Link Hovering: Shows the tooltip of eg a Achivment while hovering
            - Quick Join Messages: Show clickable Quick Join messages inside of the chat
    - Added a new "Role Bar" which shows your group or raid's role composition
    - Added a new "Missing Raud Buff Bar" which shows you your missing raind buffs. You can also track one custom buff
    - Added tooltipt to the "Important Debuff" Dropdown
    - Added Season 2 "Important Debuffs"
    - Merchant skin
    - Added grid layouts for raid and party
    - Added option to set a scale value for important dungeon and raid debuffs
    - Added option to set a scale value for dispellable debuffs
    - Added option "Show both party frames and party grid"
    - Added option to show M+ keystone info in tooltip

FIXES
    - Display Animapower frame in M+ and raids correctly
    - Fix a lua error in Torghast
    - Small layout fixes
]=])

v("5.16.4", [=[
FIXES
    - Social tab fixes
]=])

v("5.16.3", [=[
FIXES
    - Gossip skin issue
    - Smaller fixes
]=])

v("5.16.2", [=[
FIXES
    - Gossip skin issue
    - Issue with bag bars
    - Some Torghast issues
]=])

v("5.16.1", [=[
FIXES
    - Torghast tracker fixes
]=])

v("5.16.0", [=[
NEW
    - Added social module
    - Added option to show a additional ressourcebar with player as target frame
    - Added option to show party Partyframes
    - Added option to show pets portrait damage
    - Added option to show pet auras below the frame
    - Added option to show M+ score at unit tooltips (Based on Blizzards new score API)

FIXES
    - Redo raid frame aura icon tooltip: New option to set when the aura get a tooltip on mouse over or is click through (no tooltip = click through)
    - Healtglobe now works with mouseover addons

MISC
    - Updated raid debuffs for Sanctum of Domination (All difficulties)  
    - Updated raid debuffs for Tazavesh, the Veiled Market (Mythic) 
]=])

v("5.15.5", [=[
FIXES
    - Fix a tooltip lua error
]=])

v("5.14.4", [=[
FIXES
    - Fix microbar lua error
]=])

v("5.14.3", [=[
FIXES
    - Fix stancebar issue
    - Fix group layout
]=])

v("5.14.2", [=[
FIXES
    - Fix buff layout issue
]=])

v("5.14.1", [=[
FIXES
    - Fix a group layout issue
]=])

v("5.14.0", [=[
NEW
    - Make stancebar movable and let you choose the grow direction
    - Added option to override addon conflict behaivor
    - Ctrl. + click the countdown button (raid control) to trigger the dbm pull timer

FIXES
    - Fix taint issue in pet battle
]=])

v("5.13.4", [=[
FIXES
    - Fix interaction with Dominos
    - Totem frame is now shown with player frame in target frame style
]=])

v("5.13.3", [=[
FIXES
    - Raid styled party frames now working as intended
]=])

v("5.13.2", [=[
FIXES
    - Partyframes: Debuff stacks > 9 are now display correctly 

MISC
    - Partyframes: Make buff line margin smaller to show more buffs
    - Added players raid group into player tooltip
    - Make Raid Control secure: Added Worldmakers into that menu
    - Added option to set max shown lines on copy chat frame
    - Added 'Main Tank', 'Main Assist', 'Group Leader' and 'Group Assist' info to raid unit tooltips
    - Some options are now deactivated if conflicting addons are loaded. In the settings you can see which Addons is causing the deactivation.
]=])

v("5.13.1", [=[
FIXES
    - Fix an error that raid buffs not disapearing
    - Fix an error with conduits datatext if you havent a soulbind
    - Raise PetBattleFrame so auras are not overlapping them anymore
]=])

v("5.13.0", [=[
NEW
    - Added option for important debuffs to target and focus frame

FIXES
    - Fix some lua errors

MISC
    - Code clean up
]=])

v("5.12.1", [=[
FIXES
    - Fix target/focus mask overlapping
    - Fix Great Vault micro menu button interaction with dominos

MISC
    - Update locals
    - Code clean up
]=])

v("5.12.0", [=[
NEW
    - Added "Great Vault" Button to micromenu
    - Added datatext to gametime (hover the time on minimap)
    - Added datatext to talent micro button

FIXES
    - Fix rare ember court and chatframe lua error
    - Fix some target/foucs overlapping

MISC
    - Remove auto sell junk chat output: Blizzard os doing this now
    - Right click guild micromenu button to invite or whisper guild mebers
]=])

v("5.11.2", [=[
FIXES
    - Fix some gossip skin issues
    - Some reputation issues

MISC
    - Update toc
]=])

v("5.11.1", [=[
FIXES
    - Some setting dropdowns are not accessible
]=])

v("5.11.0", [=[
NEW
    - Added more info to bag and guild micromenu icons

FIXES
    - Fix some gossip skin issues
    - Module buttons are not inactive anymore
    - Fix UTF8 issue if font module is deactivated (for any reason blizzard is not supporting UTF8 if we set a default blizzard font)
]=])

v("5.10.0", [=[
NEW
    - Added socket frame skin
    - Added layout and functions to money tooltip (bags)
    - Immersive Questing: Right click to go one gossip back
    - Immersive Questing: Accept quest with space
    - Added worldmap skin
    - Added gossip skin
    - Added itemupgrade skin

FIXES
    - Objective tracker improvments
    - Focus frame invert is now working
    - Fix auto repair
]=])

v("5.9.1", [=[
FIXES
    - Torghast tooltip issue
    - Fix M+ timer overlapping (Thanks to Sethos)
]=])

v("5.9.0", [=[
NEW
    - Added "player frame in target frame style"
    - Immersive Questing: Trigger "Next Gossip" with space
    - Show cooldowns at bags and character correct by using our own cooldown system
    - Added toggle for player PvP indicator
    - Added "World Quest Addon"-Skin (embedded into objectives tracker)
    - Added option to invert target/focus frame
    - Immersive Questing: Now works with auto accepting quest addons like AAP
    - Added Ember Court to the objectives tracker (Big thanks to Belazor for all the testing)
    - Added Credits

FIXES
    - Update "Raid Debuffs"
    - Guild auto repair if not in guild
    - Gamemenu fixes to better interact with ElvUI
    - Immersive Questing: "Ignore"-Button now only shows if applicable
]=])

v("5.8.0", [=[
NEW
    - Added Talent Set Manager support (button on hero panel)
    - Button flyout direction is based on actionbar screen position

FIXES
    - Fix castbar latency issue
    - Fix rested expbar issue
    - Fix inactive factions listed under classic and others
    - Fix Postal skin issue
    - Update "Raid Debuffs"
    - Possible fix for chatframe floating max error
]=])

v("5.7.5", [=[
FIXES
    - Fix chatframe fade
    - Update party portraits correctly
    - Fix arena headers
    - Fix keybind slash command
    - Fix arena prep frames overlaps with quests
]=])

v("5.7.4", [=[
FIXES
    - Fix some castbar issues
    - Fix some mirrottimer issues
]=])

v("5.7.2", [=[
FIXES
    - Fix scrolling in dropdown settings
]=])

v("5.7.1", [=[
FIXES
    - Fix hero panel icon border if Mail skin is disabled
]=])

v("5.7.0", [=[
NEW
    - Dropdown in GW2 Settings have now scrolling
    - "Important Raid & Dungeon" Debuffs can now be disable/enabled per debuffs
    - Added ingame notification if a new addon update is available (icon at the micromenu)
    - Added missing types at GW2 floating combat text
    - We now use blizzards heropanel itemslots, that means that now everything can applyed to that buttons and the can be used, if they have "use" attributes

FIXES
    - Fix Minimap button alignments
    - Fix an rare error with reputation ignore
    - Added fallback for moverframes, to prevent profile corruptions
    - Fix dodgebar spell changing, if customs spell is Settings
    - Added any button to the healthglobe
]=])

v("5.6.1", [=[
FIXES
    - Fix wrong lib name
]=])

v("5.6.0", [=[
NEW
    - Added error handler, so that yo can see in the chat if a error was caused by GW2 UI
    - Added new Torghast scenario typ and its own texture
    - We now use default garrison and calender icons with our textures, that mean that you get all the notifications now
    - Quest Tracker shows now if a quest is failed
    - Added charged combopoints

FIXES
    - Fix missing Exodar reputation background
    - Fix error while profile renaming
    - Fix item level color issue in bags
    - Fix FCT damage number > 10k
    - Adjust quest view position for a number of Shadowlands NPCs
    - Correct battleground headers
    - Now dodgebar is hidden while actionbaroverride
    - Fix some smaller issues
]=])

v("5.5.2", [=[
FIXES
    - Fix missing Exodar reputation background
    - Fix error while profile renaming
]=])

v("5.5.1", [=[
FIXES
    - Fix equipment manager error
    - Fix Torghast floor/level counter mixup
]=])

v("5.5.0", [=[
NEW
    - Skinning support for Postal in the mail frame UI (Thanks, Hatdragon)
    - Option to disable map coordinates in both minimap and world map (Thanks, Hatdragon)
    - "Copy Profile" function added
    - Organized, optimized, and cleaned up textures to reduce download size
    - Make Micro Bar movable
    - Update "Important Raid debuffs" with Shadowland ones / remove BfA debuffs
    - Added option to show ID's in tooltips with a modifier
    - Torghast info added to the objective tracker

FIXES
    - Adjust quest view position for a number of Shadowlands NPCs
    - Possible fix for "ZoneabilityContainer"
]=])
