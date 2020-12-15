local _, GW = ...
local v = GW.vernotes

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
