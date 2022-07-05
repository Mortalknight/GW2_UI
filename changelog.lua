local _, GW = ...
local v = GW.vernotes

v("1.22.0 TBC", [=[
NEW
    - Added option for guild repair
    - Minimap can now be scaled with a slider
]=])

v("1.21.1 TBC", [=[
FIXES
    - Fix chat lua error
]=])

v("1.21.0 TBC", [=[
NEW
    - Added Details Skins
FIXES
    - Adjust GearQuipper frame position
]=])


v("1.20.0 TBC", [=[
NEW
    - Added a toggle for target, target target, focus and focus target castbar
FIXES
    - Change from "UNIT_HEALTH" event to "UNIT_HEALTH_FREQUENT" to prevent a blizzard bug
]=])

v("1.19.1 TBC", [=[
FIXES
    - Fix an issue where so buttons was missing on the module tab
    - Added missing player aura animation toggle
]=])

v("1.19.0 TBC", [=[
NEW
    - Update for 2.5.4
    - Redo player de/buffs
    - Added more options
]=])

v("1.18.0 TBC", [=[
NEW
    - Add option to show macronames on actionbuttons
    - Add option to adjust actionbutton padding
    - Add option to fade main actionbar
    - Added option to show "SpellQueueWindow" on castbar

FIXES
    - Fix hotkeynames

MISC
    - Update for 2.5.3
]=])


v("1.17.4 TBC", [=[
FIXES
    - Raid frame issue
]=])

v("1.17.3 TBC", [=[
MISC
    - Added possible bg and arena taint fix
]=])

v("1.17.2 TBC", [=[
FIXES
    - Raid / Party grid HP issue
]=])

v("1.17.1 TBC", [=[
FIXES
    - Minimap button issue
]=])

v("1.17.0 TBC", [=[
NEW
    - Added option "Show both party frames and party grid"
    - Added grid layouts for raid and party

FIXES
    - CN/TW font issue
]=])

v("1.16.0 TBC", [=[
NEW
    - Added 'Smart' Raid Markers: Use a defined key (via keybinds) to open the smart raid marker menu.
        This opens a circle with all raid markers directly under your cursor
    - StanceBar saves show state during sessions
    - Added option to set a scale value for important dungeon and raid debuffs
    - Added option to set a scale value for dispellable debuffs
    - Added a prio for scaling important and dispellable debuffs

FIXES
    - Fix a lua error with 2.5.2

MISC
    - Update TOC
    - Update libs
]=])

v("1.15.2 TBC", [=[
FIXES
    - Ready Check-Button is now working

MISC
    - Added Nether Portal - Perseverence to important debuffs
    - Disable player absorb
]=])

v("1.15.1 TBC", [=[
FIXES
    - Healthglobe fixes
]=])

v("1.15.0 TBC", [=[
NEW
    - Added support for GearScore Addon at player hero panel

FIXES
    - Tooltip issue
]=])

v("1.14.3 TBC", [=[
FIXES
    - Fix a Questie bug
]=])

v("1.14.2 TBC", [=[
FIXES
    - Some smaller bugs
]=])

v("1.14.1 TBC", [=[
FIXES
    - Fix issue with override incompatible addon function
]=])

v("1.14.0 TBC", [=[
NEW
    - Added preview mode for party and raidframes

FIXES
    - Fix and issues with unknown spells
    - Healtglobe now works with mouseover addons

MISC
    - You can now link talents into the chat
]=])

v("1.13.1 TBC", [=[
FIXES
    - If incompatible addons are loaded that is now mentioned at the gw2 settings

MISC
    - The setting "Dungeon & Raid Debuffs" has now tooltips
    - Added and exeption for incompatible bag addons
]=])

v("1.13.0 TBC", [=[
NEW
    - Added option to show party pets
    - Added unknown spells tab

ADDED
    - Error handler
    - Incompatible Addon check
]=])

v("1.12.1 TBC", [=[
FIXES
    - Stats issue
]=])

v("1.12.0 TBC", [=[
NEW
    - Added option to show pet auras under the frame
    - Added option to show a additional ressourcebar with player as target frame
    - Added aborb value to healtglobe (we calculate the player absorb based on buffs)

FIXES
    - Some stats tooltips
]=])

v("1.11.0 TBC", [=[
NEW
    - Added quest items to quest tracker (required Questie)

FIXES
    - Sorting for special bags
]=])

v("1.10.1 TBC", [=[
FIXES
    - Minimap can now be moved
]=])

v("1.10.0 TBC", [=[
NEW
    - You can now track as many quests as you want and untrack them
    - Quest sorting by: Default, Level, Zone (required Questie)

FIXES
    - Raidframe aura indicator not show correctly
]=])

v("1.9.0 TBC", [=[
NEW
    - Option to track all quests

FIXES
    - Pet frame text overlapping
    - Spellbook updating
    - Sorting items with socket
]=])

v("1.8.0 TBC", [=[
NEW
    - Added option for linking quest from questtracker with Questie support
    - Added compass, to track the nearest quest, works only with Questie

FIXES
    - Spellbook error
]=])

v("1.7.3 TBC", [=[
FIXES
    - Change petbar autocast border
    - Change pet happines indicator
    - Spellbook is now open correctly in combat
]=])

v("1.7.2 TBC", [=[
FIXES
    - Fix worldmap mover
]=])

v("1.7.1 TBC", [=[
FIXES
    - Fix minmap addon toggle
]=])

v("1.7.0 TBC", [=[
NEW
    - Added hunter pet exp to experience bar, if pet is not player level

FIXES
    - Quest tracker layout issue
    - Many tweaks
]=])

v("1.6.1 TBC", [=[
FIXES
    - Fix quest log issue
    - Redo raid frame aura icon tooltip: New option to set when the aura get a tooltip on mouse over or is click through (no tooltip = click through)
]=])

v("1.6.0 TBC", [=[
NEW
    - Added option to show quest XP to quest tracker
]=])

v("1.5.1 TBC", [=[
MISC
    - Many repu fixes
    - Ruputation has now a own menu button at the hero panel
    - Added option to ignore bags from sorting (right click the bag)

FIXES
    - Fix hero frame sizer
    - Fix actionbar scaling
]=])

v("1.5.0 TBC", [=[
NEW
    - Added option to show item level at bags

FIXES
    - Fix hero frame sizer
    - Fix actionbar scaling
]=])

v("1.4.1 TBC", [=[
FIXES
    - Fix separate bags in reversed order
]=])

v("1.4.0 TBC", [=[
NEW
    - added scaler to hero panel

FIXES
    - Fix separate bags in reversed order
]=])

v("1.3.0 TBC", [=[
NEW
    - Added option to separate bags

FIXES
    - Fix an issue with raid frames are always in class color
    - Fix auto repair
]=])

v("1.2.0 TBC", [=[
NEW
    - Added combat text to pet frame portrait

FIXES
    - You can now close the worlmap with ESC
    - Fix social data text
    - Fix auto repair
    - Fix stancebar issue
]=])

v("1.1.1 TBC", [=[
FIXES
    - Fix missing focus setting
    - Start fixing bag sorting
    - Fix zhTW font issue
]=])

v("1.1.0 TBC", [=[
NEW
    - Added Focus and Focus target frame
    - Show cooldown at bags, character and spellbook correct by using our own cooldown system
    - Added GearQuipper TBC support: Thanks to Prayos for the quick support and add the GW2 compability on GearQuipper side :)
        (https://www.curseforge.com/wow/addons/gearquipper)

FIXES
    - Fix partyframe layout issue
    - Petbar: You can now see if a auto cast spell is active or not
]=])

v("1.0.2 TBC", [=[
FIXES
    - Show mirror timers (breath/fatigue) correctly
    - Fix talentframe requirment talent linked
    - Bring back HUD Scale slider
]=])

v("1.0.1 TBC", [=[
FIXES
    - Fix combopoint issue while target frame is inverted and combopoints hooked on target frame
    - Player pets (hunter/warlock) can not see there stats at the hero panel
    - Fix texture issue while dead
    - Spellbook spells can now be linked into the chat or macro frame
    - Character postion for Bloodelf and Draenei is now correct
]=])

v("1.0.0 TBC", [=[
    - Many features from retail are now in tbc, like scale frame in move hud mode, player frame in target frame style and much more
]=])
