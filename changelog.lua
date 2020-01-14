local _, GW = ...

local GW_CHANGELOGS = ""

--VERSION 5.0.0
GW_CHANGELOGS = "   - A significant refactoring took place to reduce addon conflicts and taint issues\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Reputation has been moved to a top-level character tab\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Currency has been moved from bags to a top-level character tab (CF#76)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Right-side multi action bars no longer show after load/zoning when set to fade (CF#137, CF#102)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Resolved multiple issues with character panel key bindings (including CF#107 and CF#121)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - The custom player aura frame can now be disabled without causing errors (CF#117)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix starting bag/bank icon size inconsistencies (CF#138)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Game menu hover is more efficient and also now only shows GW2 and total mem usage (CF#122)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Action bars now remain un-faded when a flyout skill menu is open\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fixed missing stat tooltips in character screen\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Hide macro name on action bar buttons\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Updated for 8.x Battle For Azeroth!\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added custom talent and spellbook panels to the character window\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Bag micro button now includes empty bag slot counter (contributor inzenir, CF#152)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Health globe now includes PvP/War Mode flag indicator (CF#95)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.0\n\n" .. GW_CHANGELOGS

--VERSION 5.0.1
GW_CHANGELOGS = "   - Zone transitions should not cause intermittent map errors (CF#162)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Resolve monk power bar problems (CF#161)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Clicking quest name will no longer cause a lua error (CF#165)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Warmode/pvp tooltip will now show properly outside of Org/SW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fixed actionbar and vehicle UI issues (CF#163, CF#164)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.1\n\n" .. GW_CHANGELOGS

--VERSION 5.0.2
GW_CHANGELOGS = "   - Fix flicker on comparison tooltips (CF#166)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix missing chi bar for windwalker monks (CF#170)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.2\n\n" .. GW_CHANGELOGS

--VERSION 5.0.3
GW_CHANGELOGS = "   - Disabled PvP HUD for now because of API changes (CF#173)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Handle API change in several class powers (CF#178)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix problems with HUD movers when HUD is scaled\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Allow shift-click to link spells and abilities in chat & macros\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - More actionbar fixes (CF#169... I hope)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.3\n\n" .. GW_CHANGELOGS

--VERSION 5.0.4
GW_CHANGELOGS = "   - Changed many strings to use default Blizz translations to simplify translation contributions\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Fix problem where UI can disappear after vehicles, taxis, etc. (CF#185, CF#193)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix a legacy map API issue in M+\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Error frame font now tied to font setting toggle (CF#196)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Properly hide multibars during pet battles\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix a Lua error that occurs when selecting equipment in hero panel (CF#183)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.4\n\n" .. GW_CHANGELOGS

--VERSION 5.0.5
GW_CHANGELOGS = "   - Fix Hunter MongooseBar\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Default objective tracker placement improved when using custom minimap/actionbars\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix problem where UI can disappear after vehicles, taxis, etc. (CF#200)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix some issues with the Garrison-/Orderhall Minimapbutton (CF#13)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix some classpowerbar issues (colors and displaying) (CF#128)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix an actionbar overlapping issue (CF#37)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix quest tracker moving to bottom of screen sometimes (CF#195, CF#168)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - All existing localizations updated with new strings.\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Simplified Chinese and Italian are now available, thanks to all of our volunteer translators from Curseforge!\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nLOCALIZATION\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Include Azerite item overlays in hero panel\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Minimap can now be placed at top or bottom (CF#113)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add ability to bind Keys by hover\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.5\n\n" .. GW_CHANGELOGS

--VERSION 5.0.6
GW_CHANGELOGS = "   - Garrison button should show (when appropriate) on initial load now\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Test for disabled default CompactRaidFrame addon (CF#142)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Un-break auto-quest tracking\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Only show Hunter Mongoose bar when talented\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Add HUD option to toggle black edge borders (CF#197)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.6\n\n" .. GW_CHANGELOGS

--VERSION 5.0.7
GW_CHANGELOGS = "   - Voice chat button should now fade properly (CF#213)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Totem frames (e.g. Black Ox Statue, Earth Elemental, etc.) should now show in the upper-right roughly where buffs used to be until we can build a better solution (CF#93)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - No more flickering on Azerite compare tooltips! (CF#211)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Made the gold counter on the bag a bit wider for all the goblins out there\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Talents now show whether you can change them in the toolip just like the default UI\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add enrage class power bar for Fury Warriors\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Changed the default quest BG texture and made it easier to replace this texture\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.7\n\n" .. GW_CHANGELOGS

--VERSION 5.0.8
GW_CHANGELOGS = "   - All allied races should display the same as base race in hero panel (CF#224)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Raid frame auras now correctly aligned\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Raid frame auras now disappears when no longer present on a player\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Minmap buttons now fade when Minimap is hidden (CF#226)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - All chat tabs now should have the correct font\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fade all chat buttons\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Level rewards window should now display passive skills with correct mask\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix a layout issue with quest items\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Raid frames should display names properly\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Restored PvP Arathi HUD\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Add coordinates to minimap\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add dynamic cam option toggle\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Make the Azerite bar more awesome\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add Pawn support to Hero window\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add option to toggle world markers\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.8\n\n" .. GW_CHANGELOGS

--VERSION 5.0.9
GW_CHANGELOGS = "   - Add 'Deposit all'-Button to bank view (credit Munsio)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - The minimap clock options have been updated to include time manager (credit Munsio)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Display passive talents in spellbook\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix some Minmap Button collecting issues (CF#212; credit Munsio)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - High level M+ keys now properly show 4th affix\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Hide health globe in pet battles when using custom action bars (CF#235)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix a scrolling issue and click-to-expand when searching issue in reputation list\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Font sizing issues in chat have been fixed (CF#231, CF#232)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Group frames can now be moved properly to the right of the screen (CF#194)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Add Leader, Assist, Mainassist and Maintank icon to raid frames\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Raid frames now have incoming heal prediction\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add link to Clique options that lets Clique use default spell panel for spell binding\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add link to Outfitter in hero panel that temporarily uses default character frame (CF#219)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Mythic keystone level now visible in the objectives tracker (CF#234)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add background imagery to reputation entries (for the beginning: BfA and Legion; credit v_riz_table_Kao)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.9\n\n" .. GW_CHANGELOGS

--VERSION 5.0.10
GW_CHANGELOGS = "   - Performance fixes in all unit frame event handling\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Major refactor of the class power system mainly for performance reasons\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Fix dodge/dash bar showing incorrect charge counts in some cases\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Resolove some map errors that could occur on initial transition into Arathi Basin BG\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Pet portaits should now update correctly when swapping pets\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - More fixes to vehicle UI behaviors (CF#251, CF#253, possibly CF#244)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added logic to hopefully fix the loading screen crashing bug (CF#254)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix the dodge/dash bar 'antennas' (CF#241)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix a raid frame target border issue\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Druid class power bars should behave more cleanly, especially when shape shifting and with affinities\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Add LFG button to Quests and World Quests (CF#125)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add background imagery to reputation entries (MoP, WoD, Cata, TLK)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - M+ tracker updates: added two and three chest indicator and death counter\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add a new health globe animation\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add a new LFG icon animation\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add power bar to boss frames (CF#240)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Protection Paladins and Warriors now have a damage reduction class power bar\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Add frenzy counter for Beast Mastery Hunter's class power\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.10\n\n" .. GW_CHANGELOGS

--VERSION 5.0.11
GW_CHANGELOGS = "   - Reputation search bug squashed\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Quests with progress bars and items should now show correctly in the tracker\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix a major issue in minimap icon handling (CF#254/CF#258)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Arena frames added to the objectives tracker\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.11\n\n" .. GW_CHANGELOGS

--VERSION 5.0.12
GW_CHANGELOGS = "   - Fix Lua error at fraction window\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix some issues with the new Arena frames incl CF#261\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Castbar gets stuck on screen (CF#263)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Add link to MyRolePlay in hero panel that temporarily uses default character frame (CF#264)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Configurable class buff indicators in raid frames\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Support for hiding auras and showing missing buffs in raid frames\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Option to preview raid frames for different group sizes\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Support for hiding auras and showing missing buffs in raid frames\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Option to preview raid frames for different group sizes\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Additional options for raid layout and sizing\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Option to sort raid frames by group instead of role\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.12 - We would like to welcome Shrugal to the development team!\n\n" .. GW_CHANGELOGS

--VERSION 5.0.13
GW_CHANGELOGS = "   - Fix a bug that the raidframe target border stuck\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added middle mouse button to party and raidframes\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Add background imagery to reputation entries (BC, Classic, Others)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.13\n\n" .. GW_CHANGELOGS

--VERSION 5.0.14
GW_CHANGELOGS = "   - Jaina is now visible when using the immersive quest view in War Campaign quests\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix an error with the custom UI in Arathi Basin BG (and Brawl version)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.14\n\n" .. GW_CHANGELOGS

--VERSION 5.0.15
GW_CHANGELOGS = "   - Update TOC version to 8.1\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.15\n\n" .. GW_CHANGELOGS

--VERSION 5.0.16
GW_CHANGELOGS = "   - Changed shaman raid indicator colors to match the spell icon colors\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Fixed ready check for party frames\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fixed reagent bank sizing\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fixed raid frame positioning problem happening since 8.1\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fixed text of equipment set save and delete dialog\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Added Paragon pending reward icon\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Raid aura indicators now show stack count for auras with more than one stack\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added 'Edit' button to equipment sets to change name and icon\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added option to show target average item level instead of prestige level\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.16\n\n" .. GW_CHANGELOGS

--VERSION 5.0.17
GW_CHANGELOGS = "   - Party frames should display names properly\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Re-enabled updating raid frames when the party/raid changes during combat\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Improved performance of displaying raid auras (~10x) to prevent stuttering in large raids\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Added itemlevel to Hero window\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added option to show healthvalues on raidframes\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.17\n\n" .. GW_CHANGELOGS

--VERSION 5.0.18
GW_CHANGELOGS = "   - This is a bandaid fix for the ItemButton API change; for now items have unsightly ilvl borders and the equipment selection tool doesn't show icons properly until a more in-depth fix is available\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.18\n\n" .. GW_CHANGELOGS

--VERSION 5.0.19
GW_CHANGELOGS = "   - In-depth fix for the ItemButton API change\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.19\n\n" .. GW_CHANGELOGS

--VERSION 5.0.20
GW_CHANGELOGS = "   - Added warfront ressources\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nNEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.20\n\n" .. GW_CHANGELOGS

--VERSION 5.0.21
GW_CHANGELOGS = "   - Fix lua error in arena\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.21\n\n" .. GW_CHANGELOGS

--VERSION 5.0.22
GW_CHANGELOGS = "   - Fixed error message when right-clicking bag icons (CurseForge#276)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fixed bank and reagent bank sorting giving error message or not working at all\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Added Questtracking by click on the questname\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added ability to set specs to equipment sets (click on edit button)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added a tooltip showing money of characters on the same faction+realm to the bag money text\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added option to hide raid aura tooltips (and disable ignoring by shift+right clicking) while in combat\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added ignoring auras by shift+right clicking on them\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "NEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.22\n\n" .. GW_CHANGELOGS

--VERSION 5.0.23
GW_CHANGELOGS = "   - Update for Patch 8.2.0\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nNEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.23\n\n" .. GW_CHANGELOGS

--VERSION 5.0.24
GW_CHANGELOGS = "   - Heart of Azeroth can now be opend from the hero window\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fixed Lua error when open Bags/Banks after moving\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.24\n\n" .. GW_CHANGELOGS

--VERSION 5.0.25
GW_CHANGELOGS = "   - Play nicely with WarfrontRareTracker addon\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fix errors in bag and bank resizing\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.25\n\n" .. GW_CHANGELOGS

--VERSION 5.0.26
GW_CHANGELOGS = "   - Changed Click and Shift-Click for local und server time\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Resolve texture masking issue on health globe spark\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Added new zones' reputation images\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Track reputation while under max level\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nNEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.26\n\n" .. GW_CHANGELOGS

--VERSION 5.0.27
GW_CHANGELOGS = "   - Added indicator for 'Glimmer of Light'\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Paladin beacons use the same indicator slot, and colors now match their spell icon colors\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Fixed achievement criteria not tracked correctly\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Improve HUD performance in certain cases with event filtering\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Multiple tweaks to issues in target, unit, and focus frame behaviors\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fixed bag close button not working at bank, vendor or mailbox\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Added dungeon difficulty to minimap\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added raid info to Hero window -> curreny tab\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added scrollbar to titles\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added durability icon to character stats\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added FPS to Minimap\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added threat text on target\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added Reward Tooltip to WorldQuests\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nNEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.0.27\n\n" .. GW_CHANGELOGS

--VERSION 5.1.0
GW_CHANGELOGS = "   - Fixed getting an 'empty UI' after visiting the bank and then zoning\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fixed multiple secure handler and in-combat issues with the micromenu\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fixed lua error in achievement tracking\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Bag and character frames now 'raise' on interaction\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Overhaul bank & bags to fix a number of issues (#206, #188)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added itemlevel and itemborder quality to equipment selection\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.0\n\n" .. GW_CHANGELOGS

--VERSION 5.1.1
GW_CHANGELOGS = "   - Revert debug code showing default bags at the bank :) oops\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Add the /gw_win_reset slash command to reset bag/bank/hero positions\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.1\n\n" .. GW_CHANGELOGS

--VERSION 5.1.2
GW_CHANGELOGS = "   - Change default bag, bank, and hero window positions to be on-screen with more resolutions (use /gw_win_reset to reset them to these defaults)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Bank now has a 'default' container to be consistent with backpack view\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.2\n\n" .. GW_CHANGELOGS

--VERSION 5.1.3
GW_CHANGELOGS = "   - The GW2 micromenu bar will now style properly when ElvUI is installed\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.3\n\n" .. GW_CHANGELOGS

--VERSION 5.1.4
GW_CHANGELOGS = "   - Fail silent for the LibACE check\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.4\n\n" .. GW_CHANGELOGS

--VERSION 5.1.5
GW_CHANGELOGS = "   - Stancebar shows the stancebutton if only one stance is known\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Update TOC for 8.2.5\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Remove deprecated hook for guild microbutton\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Fixed CN & TW font issues\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - GW2_UI works fine with dominos if our Actionsbars are disabled\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS

GW_CHANGELOGS = "   - Added SharedMedia support (Fonts and Textures)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added option to set combpoints to the unitframe\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Temp weapon enchants are now shown as buff\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Stancebuttons have own border\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added Move HUD option for tooltips\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added Welcome- and Changelog Page\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added Pixel Perfection Mode\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nNEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.5\n\n" .. GW_CHANGELOGS

--VERSION 5.1.6
GW_CHANGELOGS = "   - Disable toast messages\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Change debuff position on target if target has no buffs\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.6\n\n" .. GW_CHANGELOGS

--VERSION 5.1.7
GW_CHANGELOGS = "   - Tooltip now anchor to the bottom right of the Tooltip mover frame\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Update locals (zhTW, ptBR)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added skinned loot frame\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added skinned Gamemenu\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added skinned Popups\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added custom Ghost frame\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Make XP-Bar as a module\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added some more custom frames like Dropdowns, etc.\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Change range indicator for Multibars\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nNEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.7\n\n" .. GW_CHANGELOGS

--VERSION 5.1.8
GW_CHANGELOGS = "   - Fix a position error with the MultiBarBottomRight\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.8\n\n" .. GW_CHANGELOGS

--VERSION 5.1.9
GW_CHANGELOGS = "   - Fix a error in ptBR and zhTW local\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.9\n\n" .. GW_CHANGELOGS

--VERSION 5.1.10
GW_CHANGELOGS = "   - Make lootframe moveable (if not hooked under mouse)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added a 'Skin'-Tab into settings\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nNEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.10\n\n" .. GW_CHANGELOGS

--VERSION 5.1.11
GW_CHANGELOGS = "   - Fix a lua error with moving lootframe\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added two new skins\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nNEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.11\n\n" .. GW_CHANGELOGS

--VERSION 5.1.12
GW_CHANGELOGS = "   - Added new skins\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added heal prediction to party frames\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added casttime to target castbar\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nNEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.12\n\n" .. GW_CHANGELOGS

--VERSION 5.1.13
GW_CHANGELOGS = "   - Fix a loading error when action bars are disabled\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.13\n\n" .. GW_CHANGELOGS

--VERSION 5.1.14
GW_CHANGELOGS = "   - Fix chatframe moving and resizing error\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added possibly to track WQ's\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added possibly to show more then one WQ\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added new skins\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nNEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.14\n\n" .. GW_CHANGELOGS

--VERSION 5.1.15
GW_CHANGELOGS = "   - If minimap is on top now all icons on the minimap are accessable\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Classpowerbar now changes if spec changed\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nFIXED\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Settings: Checkboxes now also toggle if click on the text\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nMISCELLANEOUS\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Enhanced durability icon at hero panel\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added more Battleground HUD's\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added option the set the Stancebar to the left or right of the Actionbar\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added aggroborder to partyframes\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added timer to scenarios like Chromie\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nNEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.1.15\n\n" .. GW_CHANGELOGS

--VERSION 5.2.0
GW_CHANGELOGS = "   - Added option to set Actionbar fade per Actionbar (show always, show in combat, show only on mouse over)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added healthprediction to healthglobe\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added healthprediction to target, target of target, focus and target of focus frame\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Update for 8.3\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Added X and Y offset for tooltip if anchor is set to cursor\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\nNEW\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n5.2.0\n\n" .. GW_CHANGELOGS

GW.GW_CHANGELOGS = GW_CHANGELOGS