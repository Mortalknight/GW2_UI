local _, GW = ...
local v = GW.vernotes

v("2.1.6 Era", [=[
FIXES
    Fix some lua errors
]=])

v("2.1.5 Era", [=[
FIXES
    Fix some lua errors
]=])

v("2.1.4 Era", [=[
FIXES
    Fix some lua errors
]=])

v("2.1.3 Era", [=[
FIXES
    Fix some lua errors
]=])

v("2.1.2 Era", [=[
FIXES
    Fix some lua errors
]=])

v("2.1.1 Era", [=[
FIXES
    Fix some lua errors
]=])

v("2.1.0 Era", [=[
MISC
    Update for 1.14.4
]=])

v("2.0.8 Era", [=[
MISC
    Check grid auras more frequently
]=])

v("2.0.7 Era", [=[
MISC
    Fix questie integration
]=])

v("2.0.6 Era", [=[
MISC
    Update for 1.14.3
]=])

v("2.0.5 Era", [=[
MISC
    - Update libs
]=])


v("2.0.4 Era", [=[
FIXES
    - Fix tooltip lua error
]=])

v("2.0.3 Era", [=[
FIXES
    - Fix a PTR bug
]=])

v("2.0.2 Era", [=[
FIXES
    - Fix target debuffs not shown correctly
    - Minimap tracking icon lua error
]=])

v("2.0.1 Era", [=[
FIXES
    - Remove a bunch of migration errors
]=])


v("2.0.0 Era", [=[
    Update for 1.14.0

    Added all features from BC Classic
]=])

v(
    "1.10.8",
    [=[
    - Adjust combopoint anchors
]=]
)

v(
    "1.10.7",
    [=[
    - Added direbear to classpower
]=]
)

v(
    "1.10.6",
    [=[
    - Update sorting to the latest version
    - Update extended char stats
]=]
)

v(
    "1.10.5",
    [=[
    - Party buff shows now correct duration
]=]
)

v(
    "1.10.4",
    [=[
    - Fix lua error
]=]
)

v(
    "1.10.3",
    [=[
    - Fix lua error
]=]
)

v(
    "1.10.1/2",
    [=[
    - Fix party buff error
]=]
)

v(
    "1.10.0",
    [=[
    - We now use blizzards heropanel itemslots, that means that now everything can applyed to that buttons and the can be used, if they have "use" attributes
        (This "breaks" addons like Outfitter, here yoou need to use the Outfitter Panel in combi with GW2 hero panel)
    - Update libs
    - Update toc
]=]
)
v(
    "1.9.3",
    [=[
        - Added clique
        - Fix lua error
]=]
)
v(
    "1.9.2",
    [=[
        - Added profile sharing
        - Druid fixes
        - Fix lua error
]=]
)

v(
    "1.9.1",
    [=[
        - Added profile sharing
        - Druid fixes
]=]
)

v(
    "1.9.0",
    [=[
        - Added Outfitter support
        - Added target portrait damage
]=]
)

v(
    "1.8.9",
    [=[
        - Update libs
        - Update tooltips
]=]
)

v(
    "1.8.8",
    [=[
        - Make bottom left and right multibar moveable
        - Added Worldmap skin (incl. Player and Mouse coords, moving and resizing)
        - Bug fixes
]=]
)

v(
    "1.8.7",
    [=[
        - Fix petbar auto moving in default position
]=]
)

v(
    "1.8.6",
    [=[
        - Fix lua error if enter an invalid player de/buff size
        - Fix petbar auto moving in default position
        - Fix combopoint on target error
]=]
)

v(
    "1.8.5",
    [=[
        - Added party leader indicator
        - Fix error in afk mode
        - Fix Mana/Energy Ticker events
]=]
)

v(
    "1.8.4a",
    [=[
        - Added option to change player buff and debuff size
        - Added option to hide Mana/Energy tickerbar out of combat
        - Fix lua error in party frames
        - Fix lua error with frFR
        - Fix Mana/Energy for energy only classes
]=]
)

v(
    "1.8.3",
    [=[
        - Added option for Mana/Energy Tickerbar (Thanks Skippbo#2190 aka Saar for all the time and Tests)
        - Update to 1.13.5
        - Added aggroborder to party and raidframes
]=]
)

v(
    "1.8.2",
    [=[
        - Fix some smaller bugs
        - Added option for 5SR: Manarege Ticker: Shows a Ticker if you are Manarege
]=]
)

v(
    "1.8.1",
    [=[
    - Added option "Show Player in Groupframes"
    - Added 5SR Timer
    - Debuffs and Buffs are now separated and can be moved to different places (Debuffs only grows with Buffs if they are set there default position - To set the de/buffs to there default position, open Move HUD and click on the little button next to there mover frame)
    - Fix druidmanabar in shapeshift form
]=]
)

v(
    "1.8.0",
    [=[
    - Added incoming resurrection icon to raid and party
    - Remove RealMobHealth support - Blizzard delivery the correct values now in there API
    - Added option for range indicator on mainbar
    - Added option to show player health as %, value or both
    - Dodge bar now works as a secure button and can be bound to a key
    - Rebuilt dodge bar for performance and graphical improvement
    - Rebuilt health globe for performance and graphical improvement
    - Added extra manabar for druids in shapeshift form (testing)
    - Add ability to bind Keys by hover
    - Added HUD Scale option as a slider
    - Advanced Character Stats: - Fixed miss chance calculation
                                - Added Arcane Instability talent for mages to spell crit calculation
                                - Added Holy Power talent for paladins to holy crit calculation
                                - Added MP5-Bonus from T2 set bonuses
                                - Add Priests holy crit talent to calculation
    - Added Grid to Move HUD
    - Added back Chatbubbles in none protected areas
    - Added new options to bags: Show Junk Icon", "Colouring professional bags", "Sell Junk automatically"
    - Added "Advanced Tooltips" with these options:
        - Show names in classcolor, show AFK and DND Status, color level, etc.
        - Item Count: Shows how many Items you have in bags and in bank (from this item)
        - Spell/Item IDs: Shows the Spll/Item Id's in the tooltip
        - NPC IDs: Show the NPC ID in the tooltip
        - Target Info: Shows who in your party/raid is targeting this target
        - Display the unit role in the tooltip
        - some more
    - Skin Blizzard Options (Interface and Settings), Addon List, Keybindings and Macro options
    - Added AFK-Mode
    - Added Chat copy button, to copy out text from the chatwindow
    - Update locals (zhTW, ptBR)
    - Added Auto repair mode
    - Chat window can now be separated and moved to the rightside of the screen
    - Added toggle for HUD background
    - Buffs can be canceled in combat
    - Added Keybinds for "Sort Bag" and "Sort Bank"
    - Added LibThreatClassic2
    - Added option to show threath value on target frame
    - Added option to show fps on minimap
    - Added option to show coordinates with 2 digits (click on the coordinats; Thanks to: hatdragon)
    - Added HonorSpy support (Honortab)
    - Added 'Show Debuff', 'Show only dispellable debuffs', 'Show importend raid & instance debuffs' to party and raidframes
    - Added Status Report
    - Split Raid and Group frames to two different options

]=]
)

v(
    "1.7.3",
    [=[
    - Added more stats to the extended stats (hover over the 'Attribute'-label)
]=]
)

v(
    "1.7.2",
    [=[
    - Now the correct resistence will be shown for player and pet
    - Advanced char stats: Redo MP5, now split into Item, Casting, Spirit
    - Fix an overlapping error with health on the healthglobe
    - Added option to set Actionbar fade per Actionbar (Show always, show in combat, show only on mouse over)
    - Added option to show target auras on top
    - Make PlayerAuraFrame moveable
]=]
)

v(
    "1.7.1",
    [=[
    - Fix a lua error when hover the micromenu
    - Update libs
    - Added X and Y offset for tooltip if anchor is set to cursor
    - Added durability icon to char stats
    - Added healthprediction to party, target and target of target frame
    - Added healthprediction to healthglobe
]=]
)

v(
    "1.7.0",
    [=[
    - Fix a bug which causes a conflict with other addons
]=]
)

v(
    "1.6.9",
    [=[
    - Added sorting to bags and bank
        - Also for bags the option to sort to first or last bag (cogwheel at the bag; counts for bag and bank)
    - Added option the set the Stancebar to the left or right of the Actionbar
    - Fix short freeze when open bag or bank
    - Added "Total DPS" into the Damage stats tooltip
    - If minimap is on top now all icons on the minimap are accessable
    - Settings: Checkboxes now also toggle if click on the text
]=]
)

v(
    "1.6.8",
    [=[
    - Fix lua error in BG's for level 60 chars
]=]
)

v(
    "1.6.7",
    [=[
    - Redo Inventory to work with the keyring
]=]
)

v(
    "1.6.6",
    [=[
    - Fix a bug in bankframes
]=]
)

v(
    "1.6.5",
    [=[
    - Added Keyring
]=]
)

v(
    "1.6.4",
    [=[
    - Update libs
    - Error if acception an PvP invite: Workaround: If the invite pops up type /reload then you can accept the invite
    - Added BG queue icon
]=]
)

v(
    "1.6.3",
    [=[
    - Fix lua error for druids
]=]
)

v(
    "1.6.2",
    [=[
    - Added Questtarget to the Immersive dialoge (At the End)
    - Changed Bag and Bank min sizing
    - Changed target debuffs to 8 per row
    - Added option under Skins 'Use Blizzard Class Colors'
    - Added Defense stat for Warrior, Druid and Paladin
]=]
)

v(
    "1.6.1",
    [=[
    - Update libs
]=]
)

v(
    "1.6.0",
    [=[
    - Added Honortab
]=]
)

v(
    "1.5.0",
    [=[
    - Fix chatframe moving and resizing error
    - Update libs
]=]
)

v(
    "1.4.0",
    [=[
    - Added advanced char stats (hover over the 'Attribute'-label)
    - Change lib from LibClassicHealComm-1.0 to LibHealComm-4.0
    - Added pet level to pet frame
    - Update libs
]=]
)

v(
    "1.3.0",
    [=[
    - Make lootframe moveable (if not hooked under mouse)
    - Added a 'Skin'-Tab into settings
]=]
)

v(
    "1.2.1",
    [=[
    - Fix a position error with the MultiBarBottomRight
    - Fix a tooltip error with resistence tooltips
    - Update libs
]=]
)

v(
    "1.2.0",
    [=[
    - Added custom UIDropDownMenu
    - Added repu background for Wildhammer Clan
    - Change range indicator for Multibars
    - Make XP-Bar as a module
]=]
)

v(
    "1.1.0",
    [=[
    - Tooltip now anchor to the bottom right of the Tooltip mover frame
    - Added custom mainmenu
    - Added custom loot frame
    - Added custom staticpopup
    - Added Pet diet info
    - Update libs
]=]
)

v(
    "1.0.0",
    [=[
    - Added Character Panel
    - Added Talent Panel
    - Added Spellbook
    - Added level to QuestTracker
    - Added back Searchbar to bag and bank
    - Added Welcome- and Changelog Page
    - Added TitanClassic Support (MultiBarRight should not move a bit down)
    - Fix MultiBarLeft and Right finally (also when get attack in stealth)
    - Added back Chatwindow
    - Added back Dynamic-Cam Mode
    - Change debuff position on target and player if target/player has no buffs
    - Update locals (zhTW, ptBR)
    - Update Aura Indicator for raidframes
    - Added enemy buffs on targetframe
    - Added itemborder for professionbags
    - Added back Health option to raidframes
    - Added HealPrediction for Raidframes: Used libHealComm - Works only if all others has also this lib installed and setup
]=]
)

