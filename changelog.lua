local _, GW = ...

local GW_CHANGELOGS = ""

--VERSION 0.4.0
GW_CHANGELOGS = "- Added AuraDurationClassic\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added bank frame\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Petframe can now be moved\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Pet happiness now only visible for hunters\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix some lua errors\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix some bugs in raidframes\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added combopoints for druids\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- If a class has only one Stanceicon, it will be showen instead of the 'Sweap-Button'\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added temp weapon enchants as buff\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n0.4.0\n\n" .. GW_CHANGELOGS

--VERSION 0.5.0
GW_CHANGELOGS = "- Fix druid combobar (Cat)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added target castbars (Blizzard removed the ability to distinguish between spell ranks in the combat log, so cast times are always based on the highest rank; No ability to detect if a cast was canceled, so the castbar runs to the end)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n0.5.0\n\n" .. GW_CHANGELOGS

--VERSION 0.6.0
GW_CHANGELOGS = "- Added custom tacking icons (if some is missing please tell us the ID and type)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Make tooltip moveable\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Small fixes\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- If petbar is locked, the bar is now moving up and down with the left multibar if this one is fading in and out\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- The buffbar is now moving up and down with the right multibar if this one is fading in and out\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added custom hunter happiness texture (portrait frame background)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix MultiBarRight and MultiBarLeft was not scale after reload\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added custom border to stancebutton and make them smaller\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added itemquality border to bags and bank\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n0.6.0\n\n" .. GW_CHANGELOGS

--VERSION 0.7.0
GW_CHANGELOGS = "- Added SharedMedia (Font, Background, Statusbar)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix some lua error\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added more custom tracking icons\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Update libs\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix castingbar not safe position one some points on screen\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Update mana and energy regen animation\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Hook combopoints to unitframe option\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n0.7.0\n\n" .. GW_CHANGELOGS

--VERSION 0.8.0
GW_CHANGELOGS = "- Added ability to hook combopoints to the traget frame\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added back Immersive Questing\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added back Questtracker\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added all tracking icons\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix some bugs\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n0.8.0\n\n" .. GW_CHANGELOGS

--VERSION 0.9.0
GW_CHANGELOGS = "- Fix combopoint position under target if target is casting\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added custom border for raidbosses\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added ability to seperate MultiBarLeft and MultiBarRight\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fixed an error in Immersive Questing\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fixed an error where the MultiBarLeft and MultiBarRight change the size if you attack from stealth\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Support QuestGuru\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "    - RClick to close quest log if open\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "    - Shift + LClick to link quest name in currently open chat\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "    - Shift + RClick to link quest objects and progress in currently open chat\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "    - Ctrl + Click to untrack the quest\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Change QuestTracker click actions:\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n0.9.0\n\n" .. GW_CHANGELOGS

--VERSION 0.9.1
GW_CHANGELOGS = "- Added support for GatherLite after there Update\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added 'Color level number'\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added Pixel Perfection-Mode\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix a bug in Immersice Questing\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Hide default Bliizard PetBarFrame\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix position of exp bar\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n0.9.1\n\n" .. GW_CHANGELOGS

--VERSION 1.0.0
GW_CHANGELOGS = "- Update Aura Indicator for raidframes\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Update locals (zhTW, ptBR)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added level to QuestTracker\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added back Searchbar to bag and bank\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added Welcome- and Changelog Page\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added TitanClassic Support (MultiBarRight should not move a bit down)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix MultiBarLeft and Right finally (also when get attack in stealth)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added back Chatwindow\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added back Dynamic-Cam Mode\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Change debuff position on target and player if target/player has no buffs\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added enemy buffs on targetframe\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added itemborder for professionbags\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added back Health option to raidframes\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added HealPrediction for Raidframes: Used libHealComm - Works only if all others has also this lib installed and setup\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added Character Panel\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added Talent Panel\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added Spellbook\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.0.0\n\n" .. GW_CHANGELOGS

--VERSION 1.1.0
GW_CHANGELOGS = "- Tooltip now anchor to the bottom right of the Tooltip mover frame\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added custom mainmenu\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added custom loot frame\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added custom staticpopup\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added Pet diet info\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Update libs\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.1.0\n\n" .. GW_CHANGELOGS

--VERSION 1.2.0
GW_CHANGELOGS = "- Added custom UIDropDownMenu\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added repu background for Wildhammer Clan\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Change range indicator for Multibars\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Make XP-Bar as a module\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.2.0\n\n" .. GW_CHANGELOGS

--VERSION 1.2.1
GW_CHANGELOGS = "- Update libs\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix a position error with the MultiBarBottomRight\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix a tooltip error with resistence tooltips\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.2.1\n\n" .. GW_CHANGELOGS

--VERSION 1.3.0
GW_CHANGELOGS = "- Make lootframe moveable (if not hooked under mouse)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added a 'Skin'-Tab into settings\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.3.0\n\n" .. GW_CHANGELOGS

--VERSION 1.4.0
GW_CHANGELOGS = "- Change lib from LibClassicHealComm-1.0 to LibHealComm-4.0\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added pet level to pet frame\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Update libs\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added advanced char stats (hover over the 'Attribute'-label)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.4.0\n\n" .. GW_CHANGELOGS

--VERSION 1.5.0
GW_CHANGELOGS = "- Fix chatframe moving and resizing error\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Update libs\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.5.0\n\n" .. GW_CHANGELOGS

--VERSION 1.6.0
GW_CHANGELOGS = "- Added Honortab\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.6.0\n\n" .. GW_CHANGELOGS

--VERSION 1.6.1
GW_CHANGELOGS = "- Update libs\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.6.1\n\n" .. GW_CHANGELOGS

--VERSION 1.6.2
GW_CHANGELOGS = "- Added Questtarget to the Immersive dialouge (At the End)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Changed Bag and Bank min sizing\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Changed target debuffs to 8 per row\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added option under Skins 'Use Blizzard Class Colors'\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added Defense stat for Warrior, Druid and Paladin\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.6.2\n\n" .. GW_CHANGELOGS

--VERSION 1.6.3
GW_CHANGELOGS = "- Fix lua error for druids\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.6.3\n\n" .. GW_CHANGELOGS

--VERSION 1.6.4
GW_CHANGELOGS = "- Update libs\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Error if acception an PvP invite: Workaround: If the invite pops up type /reload then you can accept the invite\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added BG queue icon\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.6.4\n\n" .. GW_CHANGELOGS

--VERSION 1.6.5
GW_CHANGELOGS = "- Added Keyring\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.6.5\n\n" .. GW_CHANGELOGS

--VERSION 1.6.6
GW_CHANGELOGS = "- Fix a bug in bankframes\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.6.6\n\n" .. GW_CHANGELOGS

--VERSION 1.6.7
GW_CHANGELOGS = "- Redo Inventory to work with the keyring\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.6.7\n\n" .. GW_CHANGELOGS

--VERSION 1.6.8
GW_CHANGELOGS = "- Fix lua error in BGs for level 60 chars\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.6.8\n\n" .. GW_CHANGELOGS

--VERSION 1.6.9
GW_CHANGELOGS = "- Settings: Checkboxes now also toggle if click on the text\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- If minimap is on top now all icons on the minimap are accessable\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added 'Total DPS' into the Damage stats tooltip\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix short freeze when open bag or bank\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added option the set the Stancebar to the left or right of the Actionbar\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "   - Also for bags the option to sort to first or last bag (cogwheel at the bag; counts for bag and bank)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added sorting to bags and bank\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.6.9\n\n" .. GW_CHANGELOGS

--VERSION 1.7.0
GW_CHANGELOGS = "- Fix a bug which causes a conflict with other addons\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.7.0\n\n" .. GW_CHANGELOGS

--VERSION 1.7.1
GW_CHANGELOGS = "- Added healthprediction to healthglobe\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added healthprediction to party, target and target of target frame\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix a lua error when hover the micromenu\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Update libs\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added X and Y offset for tooltip if anchor is set to cursor\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added durability icon to char stats\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.7.1\n\n" .. GW_CHANGELOGS

--VERSION 1.7.2
GW_CHANGELOGS = "- Make PlayerAuraFrame moveable\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added option to show target auras on top\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added option to set Actionbar fade per Actionbar (Show always, show in combat, show only on mouse over)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Now the correct resistence will be shown for player and pet\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Advanced char stats: Redo MP5, now split into Item, Casting, Spirit\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Fix an overlapping error with health on the healthglobe\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.7.2\n\n" .. GW_CHANGELOGS

--VERSION 1.7.3
GW_CHANGELOGS = "- Added more stats to the extended stats (hover over the 'Attribute'-label)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.7.3\n\n" .. GW_CHANGELOGS

--VERSION 1.8.
GW_CHANGELOGS = "- Added extra manabar for druids in shapeshift form (testing)\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Remove RealMobHealth support - Blizzard delivery the correct values now in there API\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added incoming resurrection icon to raidframes\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added option to show player health as %, value or both\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Added option for range indicator on mainbar\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Dodge bar now works as a secure button and can be bound to a key\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Rebuilt dodge bar for performance and graphical improvement\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "- Rebuilt health globe for performance and graphical improvement\n" .. GW_CHANGELOGS
GW_CHANGELOGS = "\n\n1.8.0\n\n" .. GW_CHANGELOGS


GW.GW_CHANGELOGS = GW_CHANGELOGS