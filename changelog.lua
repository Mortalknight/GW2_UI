local _, GW = ...
local v = GW.vernotes

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
    - Dropdown in GW2 Settings habe now scrolling
    - "Importend Raid & Dungeon" Debuffs can now be disable/enabled per debuffs
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
