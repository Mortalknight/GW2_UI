local _, GW = ...
local v = GW.vernotes

v("1.14.01TBC", [=[
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
