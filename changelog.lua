local _, GW = ...

local function addChange(addonVersion, changeList)
    tinsert(GW.changelog, {version = addonVersion, changes = changeList})
end

--[[
AddChange(string addonVersion, table changeList)
  {
   GW_CHANGELOGS_TYPES fixType // bugfix, feature
   string description
  }
]]

addChange("10.3.0", {
    {GW.Enum.ChangelogType.feature, [=[Add option to change unitframe healtbar texture]=]},
    {GW.Enum.ChangelogType.feature, [=[Add option ot add Healtglobe spacing to not manage actionsbars (Retail)]=]},
    {GW.Enum.ChangelogType.feature, [=[Added own chat command history]=]},
    {GW.Enum.ChangelogType.change, [=[Tooltips updates]=]},
    {GW.Enum.ChangelogType.change, [=[Color handling refactor]=]},
    {GW.Enum.ChangelogType.change, [=[Update TBC advanced stats]=]},
    {GW.Enum.ChangelogType.bug, [=[Grid buff handling on none retail clients]=]},
    {GW.Enum.ChangelogType.bug, [=[More bug fixes]=]},
})

addChange("10.2.2", {
    {GW.Enum.ChangelogType.bug, [=[Fix lua error with housing]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix CD Manager Skin, which can cause that the CD Manager was disapearing]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix worldmap skin]=]},
})

addChange("10.2.1", {
    {GW.Enum.ChangelogType.bug, [=[More chat secrets]=]},
    {GW.Enum.ChangelogType.bug, [=[Grid color error]=]},
    {GW.Enum.ChangelogType.bug, [=[Equipment manager item level]=]},
    {GW.Enum.ChangelogType.bug, [=[Vehicle leave button on TBC]=]},
    {GW.Enum.ChangelogType.bug, [=[Missing widgets on TBC and Mists]=]},
    {GW.Enum.ChangelogType.bug, [=[PvP UI fixes]=]},
    {GW.Enum.ChangelogType.change, [=[Grid buffs can be disabled (retail)]=]},
})

addChange("10.2.0", {
    {GW.Enum.ChangelogType.feature, [=[Added all new aura filter options to grids (retail)]=]},
    {GW.Enum.ChangelogType.feature, [=[Added party pet grid]=]},
    {GW.Enum.ChangelogType.feature, [=[Added new aura filter options to target unitframe]=]},
    {GW.Enum.ChangelogType.bug, [=[More secrets with 12.0.1]=]},
})

addChange("10.1.0", {
    {GW.Enum.ChangelogType.feature, [=[Added bar size settings to: Targetframe, Target of targetframe, Focusframe, Target of focusframe and playerframe]=]},
    {GW.Enum.ChangelogType.feature, [=[Added option to change chatbubble size]=]},
    {GW.Enum.ChangelogType.feature, [=[Added option to toggle the dodgebar]=]},
    {GW.Enum.ChangelogType.feature, [=[Added option to toggle the skyridingbar]=]},
    {GW.Enum.ChangelogType.feature, [=[Added option to anchor the classpower bar to center to have them alligned when using profile on different characters]=]},
    {GW.Enum.ChangelogType.feature, [=[Added option to show keybinds only on used slots]=]},
    {GW.Enum.ChangelogType.feature, [=[Added option for a rectangle minimap (Read the setting notes)]=]},
    {GW.Enum.ChangelogType.change, [=[Gear manager: Gears can now be draged to the actionbars]=]},
    {GW.Enum.ChangelogType.change, [=[ Dodgebar, skyridingbar and player ressourcebars now fades with player frame)]=]},
    {GW.Enum.ChangelogType.bug, [=[Some more secrets (retail)]=]},
    {GW.Enum.ChangelogType.bug, [=[Grid range fader is working again]=]},
    {GW.Enum.ChangelogType.bug, [=[Raidmarkers are now showing correclty]=]},
    {GW.Enum.ChangelogType.bug, [=[Many more fixes]=]},
})

addChange("10.0.5", {
    {GW.Enum.ChangelogType.bug, [=[Gamemenu skin on TBC]=]},
    {GW.Enum.ChangelogType.bug, [=[Aura tooltip works again]=]},
    {GW.Enum.ChangelogType.bug, [=[Chatframe secret value]=]},
    {GW.Enum.ChangelogType.bug, [=[Forbidden tooltips]=]},
    {GW.Enum.ChangelogType.bug, [=[Socal frame lua error]=]},
    {GW.Enum.ChangelogType.bug, [=[Frame fader fixes]=]},
    {GW.Enum.ChangelogType.bug, [=[Raid target fix]=]},
})

addChange("10.0.4", {
    {GW.Enum.ChangelogType.change, [=[Added grid aura filter options for retail, that are all blizzard allows at the moment]=]},
    {GW.Enum.ChangelogType.bug, [=[Totembar error on none Retail clients]=]},
    {GW.Enum.ChangelogType.bug, [=[Grid backgorund on none Retail clients]=]},
})

addChange("10.0.3", {
    {GW.Enum.ChangelogType.bug, [=[Tooltip error on TBC]=]},
})

addChange("10.0.2", {
    {GW.Enum.ChangelogType.bug, [=[Tooltip error on TBC]=]},
})

addChange("10.0.1", {
    {GW.Enum.ChangelogType.bug, [=[Tooltip error on TBC]=]},
})

addChange("10.0.0", {
    {GW.Enum.ChangelogType.feature, [=[Midnight support]=]},
})

addChange("9.1.0", {
    {GW.Enum.ChangelogType.feature, [=[Social frame for TBC]=]},
    {GW.Enum.ChangelogType.bug, [=[Chat frame fixes (TBC)]=]},
    {GW.Enum.ChangelogType.bug, [=[Questlog skin fixes (TBC)]=]},
    {GW.Enum.ChangelogType.bug, [=[Hide Keyring if actionbar not enabled (TBC & Era)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix minimap left click lua error (TBC)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix spellbook and talents not clickable (TBC)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix totembar lua error (TBC)]=]},
    {GW.Enum.ChangelogType.bug, [=[Update spellbook (TBC)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix objectives tracker actionbutton (TBC)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix customs classcolor on none retail clients]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix merchant skin (TBC))]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix missing auto repair text (TBC)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix not cancable player auras (TBC)]=]},
})

addChange("9.0.2", {
    {GW.Enum.ChangelogType.bug, [=[Added missing raid debuffs for TBC]=]},
    {GW.Enum.ChangelogType.bug, [=[Added many TBC checks]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix tooltip (TBC)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix gossip skin (TBC)]=]},
    {GW.Enum.ChangelogType.bug, [=[Added missing minimap tracking (TBC)]=]},
})

addChange("9.0.1", {
    {GW.Enum.ChangelogType.bug, [=[Pet happines is now active on TBC]=]},
    {GW.Enum.ChangelogType.bug, [=[Questlog skin updates for TBC]=]},
    {GW.Enum.ChangelogType.bug, [=[Update Honor Tab for TBC]=]},
    {GW.Enum.ChangelogType.bug, [=[Many actionbar fixes for TBC]=]},
    {GW.Enum.ChangelogType.bug, [=[Disable some objectives tracker modules which are not supported in TBC, like Boss frames]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix micromenu lua error]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix chatframe lua error]=]},
    {GW.Enum.ChangelogType.bug, [=[Added missing consts for TBC]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix shaman classpowe error on TBC]=]},
})

addChange("9.0.0", {
    {GW.Enum.ChangelogType.feature, [=[TBC support]=]},
})

addChange("8.6.2", {
    {GW.Enum.ChangelogType.bug, [=[Used wrong setting for worldmap scale for era]=]},
})

addChange("8.6.1", {
    {GW.Enum.ChangelogType.bug, [=[Worldmap position and scale is not saved (era)]=]},
    {GW.Enum.ChangelogType.change, [=[FCT default style uses now a fallback from on nameplate anchor]=]},
    {GW.Enum.ChangelogType.change, [=[XP bar rework]=]},
})

addChange("8.6.0", {
    {GW.Enum.ChangelogType.feature, [=[Add option to invert multiactionbars, to follow the blizzard layout]=]},
    {GW.Enum.ChangelogType.bug, [=[Chatframe fixes]=]},
})

addChange("8.5.3", {
    {GW.Enum.ChangelogType.change, [=[Add housing micro button]=]},
    {GW.Enum.ChangelogType.bug, [=[Many chat related fixes]=]},
    {GW.Enum.ChangelogType.bug, [=[Socket skin error (Mists)]=]},
})

addChange("8.5.2", {
    {GW.Enum.ChangelogType.change, [=[Updates for 11.2.7]=]},
})

addChange("8.5.1", {
    {GW.Enum.ChangelogType.change, [=[Talent switch works again (Mists)]=]},
})

addChange("8.5.0", {
    {GW.Enum.ChangelogType.feature, [=[Added Recent Alliens tab to social panel (retail)]=]},
    {GW.Enum.ChangelogType.feature, [=[Add CD Manager skin (retail)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix character stats lus error (mists)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix druid mana bar in bear form]=]},
})

addChange("8.4.6", {
    {GW.Enum.ChangelogType.bug, [=[Fix era honor lua error]=]},
})

addChange("8.4.5", {
    {GW.Enum.ChangelogType.bug, [=[Fix spellbook lua error (era)]=]},
})

addChange("8.4.4", {
    {GW.Enum.ChangelogType.bug, [=[Remove not needed and outdated libs]=]},
})

addChange("8.4.3", {
    {GW.Enum.ChangelogType.bug, [=[Fix talent tooltip (era)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix rare hunter pet name error (era & mists)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix objectives tracker (mists)]=]},
})

addChange("8.4.2", {
    {GW.Enum.ChangelogType.change, [=[1.15.8 fixes]=]},
})

addChange("8.4.1", {
    {GW.Enum.ChangelogType.bug, [=[Fix Bag lua error (Era)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix PetTracker lua error (Retail)]=]},
})

addChange("8.4.0", {
    {GW.Enum.ChangelogType.feature, [=[Added option to disable micromenu module]=]},
    {GW.Enum.ChangelogType.feature, [=[Added monk stagger value to classpower bar]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix Questie Map Coords error (Era & Mists)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix classpower 'Only show in combat' option when leaving a vehicle]=]},
    {GW.Enum.ChangelogType.change, [=[Refactor seperate bag option]=]},
    {GW.Enum.ChangelogType.change, [=[TOC update (Mists)]=]},
})

addChange("8.3.5", {
    {GW.Enum.ChangelogType.bug, [=[Fix settings dependecies tooltip]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix reset profile option]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix Paladin classpower]=]},
    {GW.Enum.ChangelogType.change, [=[Add missing auctionator frame skin]=]},
    {GW.Enum.ChangelogType.change, [=[Update classpower aura handling, this should be a performace boost, if your class has a classpower based on a de/buff]=]},
})

addChange("8.3.4", {
    {GW.Enum.ChangelogType.bug, [=[Player powerbar is now correctly hidden in specific situations]=]},
    {GW.Enum.ChangelogType.bug, [=[Fixed Lua error for fresh characters]=]},
    {GW.Enum.ChangelogType.bug, [=[Fixed Game Menu skin issue when using ConsolePort]=]},
    {GW.Enum.ChangelogType.bug, [=[Fixed fading issue with player pet frame icon]=]},
    {GW.Enum.ChangelogType.bug, [=[Fixed Lua error in Who-list]=]},
    {GW.Enum.ChangelogType.bug, [=[Fixed Lua error when opening the settings menu]=]},
    {GW.Enum.ChangelogType.bug, [=[Fixed Lua error in immersive questing when required money is missing (Era & Mists)]=]},
})

addChange("8.3.3",{
    {GW.Enum.ChangelogType.bug, [=[Fix wrong classpower color for warlocks (Mists)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix settings lua error is UI Scale is used]=]},
})

addChange("8.3.2",{
    {GW.Enum.ChangelogType.bug, [=[Fix micromenu issue with consoleport addon]=]},
})

addChange("8.3.1",{
    {GW.Enum.ChangelogType.change, [=[Settingsframe rework, addons can now hook into it]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix TSM Loading issue]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix DB migration for old profiles]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix druid bear hud background]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix quest item not clickable (retail)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix quest item texture too big (era)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix druid eclipsebar (mists)]=]},
})

addChange("8.3.0",{
    {GW.Enum.ChangelogType.change, [=[11.2.0 support]=]},
})

addChange("8.2.8",{
    {GW.Enum.ChangelogType.bug, [=[Fix absorb bar toggle]=]},
    {GW.Enum.ChangelogType.change, [=[Enable absorb bar toggle on Mists and Retail clients]=]},
})

addChange("8.2.7",{
    {GW.Enum.ChangelogType.bug, [=[Fix hunter classpower]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix micro stuttering while leaving combat (retail)]=]},
})

addChange("8.2.6",{
    {GW.Enum.ChangelogType.bug, [=[Migration lua error for new users]=]},
    {GW.Enum.ChangelogType.bug, [=[GW2 Layout creation if max Account Layouts are reached (retail)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix micromenu moving (mists)]=]},
    {GW.Enum.ChangelogType.bug, [=[Copy chat / emote button not clickable (mists & era)]=]},
})

addChange("8.2.5",{
    {GW.Enum.ChangelogType.bug, [=[Fix quest sorting (era & mists)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix reputation text (retail)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix classpower]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix objectives tracker quest item (era)]=]},
})

addChange("8.2.4",{
    {GW.Enum.ChangelogType.bug, [=[Fix warbank itemlevel (retail)]=]},
    {GW.Enum.ChangelogType.bug, [=[Hide multibars during pet battle (mists)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix target health % values]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix combopoints on target]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix minimap instance difficult indicator (retail)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix actionbar coloring (mists)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix title filter error (retail)]=]},
})

addChange("8.2.3",{
    {GW.Enum.ChangelogType.bug, [=[Loading error]=]},
    {GW.Enum.ChangelogType.change, [=[Add more options to player de/buff settings]=]},
})

addChange("8.2.2",{
    {GW.Enum.ChangelogType.bug, [=[Bagnator skin error (Mists)]=]},
    {GW.Enum.ChangelogType.bug, [=[Objectives tracker actionbutton error (Era)]=]},
})

addChange("8.2.1",{
    {GW.Enum.ChangelogType.bug, [=[Arena frame lua error (Mists)]=]},
})

addChange("8.2.0",{
    {GW.Enum.ChangelogType.feature, [=[Add option to hide absorb bar on all unitframes]=]},
})

addChange("8.1.9",{
    {GW.Enum.ChangelogType.bug, [=[Scenario error (retail)]=]},
    {GW.Enum.ChangelogType.bug, [=[Bag sorting (Mists & Era)]=]},
})

addChange("8.1.8",{
    {GW.Enum.ChangelogType.bug, [=[Bag opening lag]=]},
    {GW.Enum.ChangelogType.bug, [=[Wrong tooltip faction (Retail)]=]},
    {GW.Enum.ChangelogType.bug, [=[Friendstooltip show correct game now]=]},
    {GW.Enum.ChangelogType.bug, [=[Spellbook tweaks (Mists)]=]},
})

addChange("8.1.7",{
    {GW.Enum.ChangelogType.bug, [=[Shadow prist orbs (mists)]=]},
    {GW.Enum.ChangelogType.bug, [=[DK runes (mists)]=]},
    {GW.Enum.ChangelogType.bug, [=[Unitframe absorb amounts (mists)]=]},
})

addChange("8.1.6",{
    {GW.Enum.ChangelogType.bug, [=[Next round of Mists fixes]=]},
})

addChange("8.1.5",{
    {GW.Enum.ChangelogType.change, [=[Added temp chi bg texture]=]},
})

addChange("8.1.4",{
    {GW.Enum.ChangelogType.bug, [=[Next round of Mists fixes]=]},
})

addChange("8.1.3",{
    {GW.Enum.ChangelogType.bug, [=[Fix issue with 8.1.2]=]},
})

addChange("8.1.2",{
    {GW.Enum.ChangelogType.bug, [=[More Mists adjustments]=]},
})

addChange("8.1.1",{
    {GW.Enum.ChangelogType.bug, [=[More Mists adjustments]=]},
})

addChange("8.1.0",{
    {GW.Enum.ChangelogType.bug, [=[Mists support]=]},
})

addChange("8.0.7",{
    {GW.Enum.ChangelogType.bug, [=[Fix collection tracking collapse (retail)]=]},
})

addChange("8.0.6",{
    {GW.Enum.ChangelogType.bug, [=[Some more fixes for all versions]=]},
})

addChange("8.0.5",{
    {GW.Enum.ChangelogType.bug, [=[Fix target level color (era & cata)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix unit level at tooltip (era)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix aura tooltip (era & cata)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix mirror timer (era & cata)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix objectives tooltip (era & cata)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix copying profiles)]=]},
})

addChange("8.0.4",{
    {GW.Enum.ChangelogType.bug, [=[Fix microbar moving (cata)]=]},
    {GW.Enum.ChangelogType.bug, [=[Readd spellbook and talent setting (cata)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix skyridingbar (retail)]=]},
})

addChange("8.0.3",{
    {GW.Enum.ChangelogType.bug, [=[Fix eclips bar on era]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix micromenu moving on era and cata]=]},
})

addChange("8.0.2",{
    {GW.Enum.ChangelogType.bug, [=[Combopoint error for era and cata]=]},
})

addChange("8.0.1",{
    {GW.Enum.ChangelogType.feature, [=[Merged Retail, Era and Cata version]=]},
})

addChange("7.15.0",{
    {GW.Enum.ChangelogType.feature, [=[Added more option to unitframe fader]=]},
    {GW.Enum.ChangelogType.feature, [=[Added option to extend player powerbar hight (player unitframe)]=]},
    {GW.Enum.ChangelogType.change, [=[Add required settings to settings tooltip]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix Pawn integration]=]},
})

addChange("7.14.1",{
    {GW.Enum.ChangelogType.bug, [=[Fix settings lua error]=]},
})

addChange("7.14.0",{
    {GW.Enum.ChangelogType.feature, [=[Added unitframe fader options to all unitframes]=]},
    {GW.Enum.ChangelogType.bug, [=[Raidlock error]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix buff reminder]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix pawn integration]=]},
})

addChange("7.13.2",{
    {GW.Enum.ChangelogType.bug, [=[Fix issue with 7.13.1]=]},
})

addChange("7.13.1",{
    {GW.Enum.ChangelogType.bug, [=[Hero panel opens for enchants]=]},
    {GW.Enum.ChangelogType.bug, [=[Weapon enchants should now show correclty]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix Pawn integration]=]},
    {GW.Enum.ChangelogType.bug, [=[Raid lock lua error]=]},
    {GW.Enum.ChangelogType.change, [=[Redo reputation frame, should load and react faster]=]},
    {GW.Enum.ChangelogType.change, [=[Add radio button texture]=]},
    {GW.Enum.ChangelogType.change, [=[Added Nightfall to objectives tracker]=]},
    {GW.Enum.ChangelogType.change, [=[Update some skins]=]},
    {GW.Enum.ChangelogType.change, [=[Added 3 new widget mover to move hud mode]=]},
    {GW.Enum.ChangelogType.change, [=[Added some animations]=]},
})

addChange("7.13.0",{
    {GW.Enum.ChangelogType.feature, [=[Cooldown Manager skin]=]},
    {GW.Enum.ChangelogType.feature, [=[Add paragon indicator to reputation category list]=]},
    {GW.Enum.ChangelogType.bug, [=[PetTracker integration now work as expected]=]},
    {GW.Enum.ChangelogType.bug, [=[WQT integration now work as expected]=]},
    {GW.Enum.ChangelogType.bug, [=[Error when entering delves]=]},
    {GW.Enum.ChangelogType.change, [=[Rewritten objectives tracker, should perform much better now]=]},
    {GW.Enum.ChangelogType.change, [=[Better CLEU handling with sharing over the addon]=]},
    {GW.Enum.ChangelogType.change, [=[Much more optimization over all modules of the addon]=]},
})

addChange("7.12.1",{
    {GW.Enum.ChangelogType.change, [=[Skin tweaks]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix profile lua error]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix FCT lua error]=]},
    {GW.Enum.ChangelogType.bug, [=[Castbar channel ticks]=]},
    {GW.Enum.ChangelogType.bug, [=[Target frame debuff settings are working again]=]},
})

addChange("7.12.0",{
    {GW.Enum.ChangelogType.bug, [=[Update for 11.1.0]=]},
})

addChange("7.11.1",{
    {GW.Enum.ChangelogType.bug, [=[Fix actionbar taint]=]},
})

addChange("7.11.0",{
    {GW.Enum.ChangelogType.feature, [=[dded option to hide target item level display]=]},
    {GW.Enum.ChangelogType.feature, [=[Added option to show Singing Socket gems]=]},
    {GW.Enum.ChangelogType.change, [=[Update auctionator skin]=]},
    {GW.Enum.ChangelogType.bug, [=[Repuration error]=]},
    {GW.Enum.ChangelogType.bug, [=[Notification tooltip]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix inverted statusbar]=]},
    {GW.Enum.ChangelogType.bug, [=[Party frame auras can stuck sometimes]=]},
})

addChange("7.10.0",{
    {GW.Enum.ChangelogType.feature, [=[Added Talking Head Scaler]=]},
    {GW.Enum.ChangelogType.feature, [=[Target/Focus frame bars no inverted in inverted mode]=]},
    {GW.Enum.ChangelogType.change, [=[Optimize aura handling for all unitframes]=]},
    {GW.Enum.ChangelogType.change, [=[Optimize Healthbar and Powerbar handling]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix PetTracker loading]=]},
})

addChange("7.9.3",{
    {GW.Enum.ChangelogType.change, [=[Remove CUSTOM_CLASS_COLOR support and cahnge it to GW2 Class colors]=]},
    {GW.Enum.ChangelogType.change, [=[Add option to set number format]=]},
})

addChange("7.9.2",{
    {GW.Enum.ChangelogType.change, [=[TRP3 chat support]=]},
})

addChange("7.9.1",{
    {GW.Enum.ChangelogType.change, [=[TRP3 chat support]=]},
})

addChange("7.9.0",{
    {GW.Enum.ChangelogType.feature, [=[Added grid out of range alpha value setting]=]},
    {GW.Enum.ChangelogType.feature, [=[Added custom class color support]=]},
    {GW.Enum.ChangelogType.change, [=[Update more dropdowns]=]},
    {GW.Enum.ChangelogType.change, [=[Use local number delimiter]=]},
    {GW.Enum.ChangelogType.change, [=[11.0.7 changes]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix PetTracker integration]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix Blizzard mirror timer not shown]=]},
    {GW.Enum.ChangelogType.bug, [=[Setting search works again]=]},
})

addChange("7.8.0",{
    {GW.Enum.ChangelogType.feature, [=[Add option to hook profiles to a spec. This will switch the profile on spec switch]=]},
    {GW.Enum.ChangelogType.feature, [=[Add todoloo support for GW2 Objectives tracker]=]},
    {GW.Enum.ChangelogType.feature, [=[Add searchbox for player titles]=]},
    {GW.Enum.ChangelogType.feature, [=[Add slash command to clear tracked but already earned achievements (blizzard bug): /gw2 clear achievements]=]},
    {GW.Enum.ChangelogType.feature, [=[Add option to change profile icons]=]},
    {GW.Enum.ChangelogType.feature, [=[Add TRP3 support for GW2 chatbubbles]=]},
    {GW.Enum.ChangelogType.change, [=[Added fraction icons to the guild datatext]=]},
    {GW.Enum.ChangelogType.change, [=[Change all dropdown elements to new blizzard ui system]=]},
    {GW.Enum.ChangelogType.change, [=[Allow max 4 watched tokens with gw2 bags enabled]=]},
    {GW.Enum.ChangelogType.bug, [=[Objectives tracker bonus step names]=]},
    {GW.Enum.ChangelogType.bug, [=[Achievement skin scroll height]=]},
    {GW.Enum.ChangelogType.bug, [=[Grid aura indicators now only shows player auras]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix dodgebar for some classes]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix objectives tracker loading order]=]},
})

addChange("7.7.2",{
    {GW.Enum.ChangelogType.bug, [=[Guild data info lua error]=]},
    {GW.Enum.ChangelogType.change, [=[Skin updates]=]},
    {GW.Enum.ChangelogType.change, [=[Guild data info text]=]},
    {GW.Enum.ChangelogType.change, [=[Stackcount setting]=]},
})

addChange("7.7.1",{
    {GW.Enum.ChangelogType.change, [=[Add Dracthyr fraction to tooltip]=]},
    {GW.Enum.ChangelogType.change, [=[Add stackcount to tooltip]=]},
    {GW.Enum.ChangelogType.change, [=[Changes for 11.0.5]=]},
})

addChange("7.7.0",{
    {GW.Enum.ChangelogType.feature, [=[Option to copy a single chat line]=]},
    {GW.Enum.ChangelogType.feature, [=[Option to show chat history]=]},
    {GW.Enum.ChangelogType.feature, [=[Option to show channel ticks on castbar]=]},
    {GW.Enum.ChangelogType.feature, [=[Option to control the grid name update frequence to save some fps]=]},
    {GW.Enum.ChangelogType.feature, [=[Add mastery buff to raid buff reminder]=]},
    {GW.Enum.ChangelogType.change, [=[Jailers tower error]=]},
    {GW.Enum.ChangelogType.change, [=[Social frame lua error]=]},
    {GW.Enum.ChangelogType.change, [=[Player castbar sometimes stuck on screen]=]},
    {GW.Enum.ChangelogType.change, [=[Update some skins]=]},
    {GW.Enum.ChangelogType.change, [=[Add warband reputation indicator]=]},
})

addChange("7.6.0",{
    {GW.Enum.ChangelogType.feature, [=[Add option to shorten healtglobe shield values]=]},
    {GW.Enum.ChangelogType.feature, [=[Add option to hide player frame at party grid]=]},
    {GW.Enum.ChangelogType.feature, [=[Add option to hide class icons at grids, if no class color is used]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix drawn layer of lfg accept button]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix BigWigs integration]=]},
    {GW.Enum.ChangelogType.change, [=[Add Monk hero talent to dodgebar]=]},
    {GW.Enum.ChangelogType.change, [=[Added theater event timer bar to objectives tracker]=]},
    {GW.Enum.ChangelogType.change, [=[Update some skins]=]},
})

addChange("7.5.0",{
    {GW.Enum.ChangelogType.feature, [=[Add option to shorten values, like health values or damage text]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix new font settings]=]},
    {GW.Enum.ChangelogType.bug, [=[fix LSM with new fonts]=]},
})

addChange("7.4.0",{
    {GW.Enum.ChangelogType.feature, [=[New Font system
        - You can now select between multiple different font styles
        - You can select your own fonts for texts and header texts
        - You can adjust the font size for: Big Headers, Header, Normal and Small texts

        - To select the font like before this update, use 'GW2 Legacy']=]},
    {GW.Enum.ChangelogType.feature, [=[Tooltips gets font size option for all 3 types]=]},
    {GW.Enum.ChangelogType.feature, [=[Added TWW events to the event tracker]=]},
    {GW.Enum.ChangelogType.feature, [=[Added auction house skin]=]},
    {GW.Enum.ChangelogType.feature, [=[Added fx animation to the dynamic hud (not all classes yet)]=]},
    {GW.Enum.ChangelogType.feature, [=[Added remaning live to delve tracker]=]},
    {GW.Enum.ChangelogType.feature, [=[Find an small easter agg with the GW2 settings splash screen]=]},
    {GW.Enum.ChangelogType.change, [=[Add DK hero talent to dodgebar]=]},
    {GW.Enum.ChangelogType.change, [=[Update some textures]=]},
    {GW.Enum.ChangelogType.change, [=[Update some skins]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix barber shop skin]=]},
})

addChange("7.3.0",{
    {GW.Enum.ChangelogType.feature, [=[Delves support for objectives tracker]=]},
    {GW.Enum.ChangelogType.feature, [=[Added group progress to objectives tooltip]=]},
    {GW.Enum.ChangelogType.change, [=[Update some skins]=]},
    {GW.Enum.ChangelogType.bug, [=[Objectives tracker auto turn in quests]=]},
    {GW.Enum.ChangelogType.bug, [=[Totem tracker should work again]=]},
})

addChange("7.2.0",{
    {GW.Enum.ChangelogType.feature, [=[Talent frame skin]=]},
    {GW.Enum.ChangelogType.feature, [=[Tooltip Item Count now has options Include Reagents and Include Warband]=]},
    {GW.Enum.ChangelogType.feature, [=[Keybind support for immersive questing]=]},
    {GW.Enum.ChangelogType.feature, [=[Keybind support for gossip skin]=]},
    {GW.Enum.ChangelogType.feature, [=[Stancebar can now be disabled]=]},
    {GW.Enum.ChangelogType.feature, [=[DK runes now get sorted based on there progress]=]},
    {GW.Enum.ChangelogType.feature, [=[Add timer to tracked achievements]=]},
    {GW.Enum.ChangelogType.feature, [=[New immersive questing backgrounds for TWW]=]},
    {GW.Enum.ChangelogType.change, [=[Chat frame alert color is now saved per character]=]},
    {GW.Enum.ChangelogType.change, [=[Update some skins]=]},
    {GW.Enum.ChangelogType.change, [=[Update imported debuffs]=]},
    {GW.Enum.ChangelogType.bug, [=[EJ skin error]=]},
    {GW.Enum.ChangelogType.bug, [=[Raid frame ignored auras works again]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix GW2_Layout creation process]=]},
})

addChange("7.1.0",{
    {GW.Enum.ChangelogType.feature, [=[Added option to skin blizzards default actionbars
        That function disabled our managed actionbars and there hooked features]=]},
    {GW.Enum.ChangelogType.feature, [=[Adventuremap skin]=]},
    {GW.Enum.ChangelogType.bug, [=[Objectives tracker actionbutton works again]=]},
    {GW.Enum.ChangelogType.bug, [=[Error handler shows only GW2 errors]=]},
    {GW.Enum.ChangelogType.bug, [=[M+ progess counter should show correect % again (raw value is not possible atm)]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix minimap lua error]=]},
    {GW.Enum.ChangelogType.change, [=[Added TRP3 tooltips support]=]},
    {GW.Enum.ChangelogType.change, [=[Immersive Question changes and improvements]=]},
})

addChange("7.0.2",{
    {GW.Enum.ChangelogType.change, [=[Added self reading animation to immersive questing]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix error handler]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix objective tracker action button handling]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix event objectives click functions]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix currency transfer taint error]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix ouf range indicator]=]},
})

addChange("7.0.1",{
    {GW.Enum.ChangelogType.bug, [=[First round of fixes]=]},
})

addChange("7.0.0",{
    {GW.Enum.ChangelogType.change, [=[Update for TWW]=]},
})

addChange("6.14.10",{
    {GW.Enum.ChangelogType.bug, [=[Show character item info now works correctly]=]},
    {GW.Enum.ChangelogType.change, [=[Export some api]=]},
})

addChange("6.14.9",{
    {GW.Enum.ChangelogType.change, [=[Export some api]=]},
})

addChange("6.14.8",{
    {GW.Enum.ChangelogType.change, [=[Update toc]=]},
})

addChange("6.14.7",{
    {GW.Enum.ChangelogType.change, [=[Prepare for 10.2.7]=]},
})

addChange("6.14.6",{
    {GW.Enum.ChangelogType.bug, [=[Fix GW2 slash commands]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix merchant frame next/prev page button position]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix lua error if our minimap is disableds]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix character itemlevel was not shown]=]},
})

addChange("6.14.5",{
    {GW.Enum.ChangelogType.bug, [=[Party frame visibility]=]},
})

addChange("6.14.4",{
    {GW.Enum.ChangelogType.bug, [=[Tooltip M+ lua error]=]},
})

addChange("6.14.3",{
    {GW.Enum.ChangelogType.bug, [=[Party visibility]=]},
})

addChange("6.14.2",{
    {GW.Enum.ChangelogType.change, [=[Update for 10.2.6]=]},
})

addChange("6.14.1",{
    {GW.Enum.ChangelogType.bug, [=[Fix details profile]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix player debuff show wrong icon texture]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix gossip skin text height]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix small unitframe height]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix ToT mover]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix playerframe level up icon]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix objectiv tracker hover not showing all details]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix creating new profile]=]},

    {GW.Enum.ChangelogType.change, [=[Update merchant skin]=]},
    {GW.Enum.ChangelogType.change, [=[Change castbar mover frame beased on details option]=]},
    {GW.Enum.ChangelogType.change, [=[Added Masque actionbutton skin]=]},
})

addChange("6.14.0", {
    {GW.Enum.ChangelogType.feature, [=[Added Big Dig event timer]=]},
    {GW.Enum.ChangelogType.feature, [=[Added option to change pulltimer seconds]=]},

    {GW.Enum.ChangelogType.bug, [=[Raidframes name overlapping]=]},
    {GW.Enum.ChangelogType.bug, [=[Chat install process]=]},
    {GW.Enum.ChangelogType.bug, [=[Alt player background setting]=]},
    {GW.Enum.ChangelogType.bug, [=[Colorpicker error]=]},
})

addChange("6.13.3",{
    {GW.Enum.ChangelogType.bug, [=[Remove print statement]=]},
})

addChange("6.13.2",{
    {GW.Enum.ChangelogType.bug, [=[Fix profile page error]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix db migration error]=]},
    {GW.Enum.ChangelogType.bug, [=[Handle evoker soar correct]=]},
})

addChange("6.13.1",{
    {GW.Enum.ChangelogType.bug, [=[Fix error a profile rename]=]},
})

addChange("6.13.0",{
    {GW.Enum.ChangelogType.feature, [=[Switch to a new database format to better handle profiles. That requires a reload after the first login on each character.]=]},
    {GW.Enum.ChangelogType.feature, [=[Added right click function to the minimaps expansion icon to show also the landing pages from previous addons]=]},
    {GW.Enum.ChangelogType.feature, [=[Added animated statusbars to the pet frame]=]},
    {GW.Enum.ChangelogType.feature, [=[Added copy/paste function to colorpicker]=]},
    {GW.Enum.ChangelogType.feature, [=[Added option to disable objectives statusbars to have a more compact objectives tracker]=]},

    {GW.Enum.ChangelogType.change, [=[Some more settings does not requires a reload]=]},

    {GW.Enum.ChangelogType.bug, [=[Fix stancebar error. You can now use the button in combat again]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix worldmap event tracker container size]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix tank frame middle icon]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix auraindicators updating]=]},
    {GW.Enum.ChangelogType.bug, [=[GW2 setting window is now moveable]=]},
})


addChange("6.12.0",{
    {GW.Enum.ChangelogType.feature, [=[Added new paladin classpower texture and animation]=]},
    {GW.Enum.ChangelogType.feature, [=[Added new arms warrior classpower]=]},
    {GW.Enum.ChangelogType.feature, [=[Update GW2 boss frames, they are now unitframes]=]},
    {GW.Enum.ChangelogType.feature, [=[Added options to toggle grid rol icons, tank icons and leader icons]=]},

    {GW.Enum.ChangelogType.change, [=[Adjust grid out of range alpha value]=]},
    {GW.Enum.ChangelogType.change, [=[Update grid to work again with OmniCD]=]},

    {GW.Enum.ChangelogType.bug, [=[Fix PP mode get saved correctly]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix move HUD grid]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix immersive Questing taint issue]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix arena frame lua errors]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix classpower error in combat]=]},
})

addChange("6.11.1",{
    {GW.Enum.ChangelogType.bug,[=[Correct LEMO integration which was causing an lua error during installation process]=]},
    {GW.Enum.ChangelogType.bug,[=[Tweak Event Timer height]=]},
})

addChange("6.11.0",{
    {GW.Enum.ChangelogType.feature, [=[Redo all grids: Party, Raid, Raid Pet]=]},
    {GW.Enum.ChangelogType.feature, [=[Grids are now secure and can update during combat]=]},
    {GW.Enum.ChangelogType.feature, [=[Added new grids:
        - Maintank
        - Raid 10
        - Raid 25
        - Raid 40]=]},
    {GW.Enum.ChangelogType.feature, [=[Raid grids switch automaticly between the 3 raid grids, based on the number of players at the raid]=]},
    {GW.Enum.ChangelogType.feature, [=[Added new grouping and sorting settings to all grids:
        - Group by: Role, Class, Group, Name, Index
        - Sort direction
        - Sortmethode: Name, Index
        - Raidwaid sorting: If disabled the grouping and sorting settings are applyed per raid group]=]},
    {GW.Enum.ChangelogType.feature, [=[All grids have there individual settings (Raid 10, Raid 25, Raid 40, Maintank, Raid Pet, Group)]=]},
    {GW.Enum.ChangelogType.feature, [=[Added Superbloom event timer to worldmap]=]},
    {GW.Enum.ChangelogType.feature, [=[Added options to change the worldmap coordinats lable]=]},
    {GW.Enum.ChangelogType.feature, [=[Added option to hide classpower bar outside of combat]=]},

    {GW.Enum.ChangelogType.change, [=[Update for 10.2.0]=]},
    {GW.Enum.ChangelogType.change, [=[Update RAF skin]=]},
    {GW.Enum.ChangelogType.change, [=[Update Time Manager skin]=]},
    {GW.Enum.ChangelogType.change, [=[Added back right click option on bags]=]},
    {GW.Enum.ChangelogType.change, [=[Added S3 raid debuffs]=]},
    {GW.Enum.ChangelogType.change, [=[Adjust damage text animations]=]},
    {GW.Enum.ChangelogType.change, [=[Update TaintLess]=]},

    {GW.Enum.ChangelogType.bug, [=[Fix ready check skin]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix blurr on raid warning font]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix Pet Tracker and WQT Anchor points]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix travler log header stucking after tracking activity is completed]=]},
    {GW.Enum.ChangelogType.bug, [=[Fix some taints]=]},
})

addChange("6.10.1",{
    {GW.Enum.ChangelogType.bug,[=[10.1.7 fixes]=]},
})

addChange("6.10.0",{
    {GW.Enum.ChangelogType.bug,[=[Added evoker ebon might bar]=]},
})

addChange("6.9.2",{
    {GW.Enum.ChangelogType.bug,[=[Fix an actionbars issue which can crash the client]=]},
})

addChange("6.9.1",{
    {GW.Enum.ChangelogType.bug,[=[More 10.1.5 related fixes]=]},
})

addChange("6.9.0",{
    {GW.Enum.ChangelogType.feature,[=[Added font settings for GW2 floating combat text]=]},
    {GW.Enum.ChangelogType.change,[=[Update for 10.1.5]=]},
})

addChange("6.8.2",{
    {GW.Enum.ChangelogType.bug,[=[Fix druid little manabar in cat form with player frame in target frame style]=]},
    {GW.Enum.ChangelogType.bug,[=[Try to handle bags correctly for accounts with not 2FA]=]},
})

addChange("6.8.1",{
    {GW.Enum.ChangelogType.bug,[=[Fix buff/debuff auto anchor]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix buff/debuff max wraps setting]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix socket skin lua error]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix Pet Tracker integration]=]},

    {GW.Enum.ChangelogType.change,[=[Added LibUIDropDownMenu to prevent drop down taints]=]},
    {GW.Enum.ChangelogType.change,[=[Added Diablo 4 to friends data info]=]},
    {GW.Enum.ChangelogType.change,[=[Update LibEditModeOverride]=]},
})

addChange("6.8.0",{
    {GW.Enum.ChangelogType.feature,[=[Added option to adjust player de/buff horizontal and vertical spacing]=]},
    {GW.Enum.ChangelogType.feature,[=[Added option to adjust player de/buff max wrap of lines]=]},
    {GW.Enum.ChangelogType.feature,[=[Added support for the add PetTracker: Now included at GW2 objectives]=]},
    {GW.Enum.ChangelogType.feature,[=[Added evoker bleeding support]=]},

    {GW.Enum.ChangelogType.bug,[=[Avoid possible tooltip taint]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix casting bar lua error at pvp with an evoker]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix rare migration process issue]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix M+ dungeon icon border color at the lfg frame]=]},

    {GW.Enum.ChangelogType.change,[=[Tweak some hover textures]=]},
    {GW.Enum.ChangelogType.change,[=[Cooldown round numbers are more accurate now]=]},
})

addChange("6.7.3",{
    {GW.Enum.ChangelogType.bug,[=[Fix friends frame lua error]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix encounterjornal taint issue]=]},
})

addChange("6.7.2",{
    {GW.Enum.ChangelogType.bug,[=[Fix player frame in target frame style]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix immersive questing error]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix healtglobe error]=]},
})

addChange("6.7.1",{
    {GW.Enum.ChangelogType.bug,[=[Fix hero panel anchor error]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix party frame healthtext error]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix hero panel item info error]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix target castingbar texture]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix pet grid error]=]},

    {GW.Enum.ChangelogType.change,[=[Handle addon compartment button and add a toggle to hide that button]=]},
})

addChange("6.7.0",{
    {GW.Enum.ChangelogType.feature,[=[Added private aura support)]=]},
    {GW.Enum.ChangelogType.feature,[=[Redo the statusbars and add custom animations to the classpower and ressource bars]=]},

    {GW.Enum.ChangelogType.bug,[=[Added passive talents back to spellbook]=]},
    {GW.Enum.ChangelogType.bug,[=[Tweak vignett alerts to not spam]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix talent micro button taint error]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix bank taint issue]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix vigor bar hidding]=]},

    {GW.Enum.ChangelogType.change,[=[Update for 10.1]=]},
    {GW.Enum.ChangelogType.change,[=[Make achievement frame movable]=]},
    {GW.Enum.ChangelogType.change,[=[Update S2 debuffs]=]},
})

addChange("6.6.1",{
    {GW.Enum.ChangelogType.bug,[=[Fix rare lua error during open the worldmap with active worldmap skin]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix issue were is was impossible to buy bank slots]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix macro and gear manager icon selection]=]},

    {GW.Enum.ChangelogType.change,[=[Added tooltips to equipment selection mode]=]},
    {GW.Enum.ChangelogType.change,[=[GW2 achievement frame skin is now compatible with 'Krowi's Achievement Filter' (requires version 55.0 and higher)]=]},
})

addChange("6.6.0",{
    {GW.Enum.ChangelogType.feature,[=[Added 2 new damage text styles: Stacking and Classic (with anchor to nameplats or center of the screen)]=]},
    {GW.Enum.ChangelogType.feature,[=[Added option to show healing numbers for these 2 new styles (classic only with anchor to the center of the screen)]=]},

    {GW.Enum.ChangelogType.bug,[=[Fix move hud error if the frames gets moved back to it default position]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix raid frame summon and resurrection icon]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix friends data info tooltip]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix worldmap drop-down position]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix objectives tracker group finder icon]=]},

    {GW.Enum.ChangelogType.change,[=[Changes for 10.0.7]=]},
    {GW.Enum.ChangelogType.change,[=[Update spell flyout skin]=]},
})


addChange("6.5.1",{
    {GW.Enum.ChangelogType.bug,[=[Fixed memory leak cause by channeling spells]=]},
})

addChange("6.5.0",{
    {GW.Enum.ChangelogType.feature,[=[Added option to add a new micromenu icon to show event timers at the tooltip]=]},

    {GW.Enum.ChangelogType.bug,[=[Fix copy chat corloring]=]},
    {GW.Enum.ChangelogType.bug,[=[Hopefully fix ui flickering]=]},

    {GW.Enum.ChangelogType.change,[=[Show micromenu notification also if the micromenu is fade out]=]},
})

addChange("6.4.1",{
    {GW.Enum.ChangelogType.bug,[=[Create the GW2_Layout only if it does not exist]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix an issue where the default target of target/focus frame is not visible if our target/focus module is turned off]=]},
})

addChange("6.4.0",{
    {GW.Enum.ChangelogType.feature,[=[Added Trade Post skin]=]},

    {GW.Enum.ChangelogType.change,[=[Restructur settings, to make some settings easier to find]=]},

    {GW.Enum.ChangelogType.bug,[=[Talent micro button tooltip is hidding corret now]=]},
    {GW.Enum.ChangelogType.bug,[=[Correct monthly activity tracker issues]=]},
    {GW.Enum.ChangelogType.bug,[=[Correct recipe tracking issues]=]},
    {GW.Enum.ChangelogType.bug,[=[Performance improvements]=]},
})
addChange("6.3.1",{
    {GW.Enum.ChangelogType.feature,[=[Added workorder indicator to micromenu]=]},

    {GW.Enum.ChangelogType.change,[=[Move "new mail" indicator to micromenu]=]},

    {GW.Enum.ChangelogType.bug,[=[Performance improvements]=]},
})
addChange("6.2.2",{
    {GW.Enum.ChangelogType.change,[=[Fixes for 10.0.5]=]},
})
addChange("6.2.1",{
    {GW.Enum.ChangelogType.bug,[=[Fix ElvUI micro menu error]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix ElvUI actionbar lua error if our actionbars are disabled]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix ElvUI battle.net frame error if both module are enabled]=]},
})
addChange("6.2.0",{
    {GW.Enum.ChangelogType.feature,[=[Dragon Riding HUD background has been added]=]},
    {GW.Enum.ChangelogType.feature,[=[Vigor has been moved to the Dodge bar]=]},
    {GW.Enum.ChangelogType.feature,[=[Added new achievement skin]=]},
    {GW.Enum.ChangelogType.feature,[=[Added new gossip skin]=]},
    {GW.Enum.ChangelogType.feature,[=[Added fish nets timers to world map]=]},
    {GW.Enum.ChangelogType.feature,[=[Added cooking event timer to scenario tracker]=]},
    {GW.Enum.ChangelogType.feature,[=[Added option to show enchants and gems on gw2 character panel]=]},
    {GW.Enum.ChangelogType.feature,[=[Added option to flash taskbar on world event reminder]=]},
    {GW.Enum.ChangelogType.feature,[=[Added group info to premade group list and group tooltips]=]},

    {GW.Enum.ChangelogType.change,[=[Update chat bubbles]=]},
    {GW.Enum.ChangelogType.change,[=[Update Move HUD textures]=]},
    {GW.Enum.ChangelogType.change,[=[Add filters to Move HUD mode]=]},
    {GW.Enum.ChangelogType.change,[=[Added char counter to chat editbox]=]},
    {GW.Enum.ChangelogType.change,[=[The info block in Mythic+ dungeons now shows more precise progress information]=]},

    {GW.Enum.ChangelogType.bug,[=[Fix ElvUI micro menu backdrop]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix Details settings page not opens]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix wrong data in fps tooltip]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix TomTom mini map icons moves into the addon button container]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix compass ignoring settings]=]},
})
addChange("6.1.1",{
    {GW.Enum.ChangelogType.change,[=[Aura Indicator updates:

- Evoker:
     Added Dream Breath (echo)
     Added Reversion (echo)
     Added Life Bind]=]},
  {GW.Enum.ChangelogType.change,[=[Update Talent Micro Button tooltip]=]},

    {GW.Enum.ChangelogType.bug,[=[Fix game freezes with scenario tracker]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix actionbar taint on spec switch]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix HUD background setting]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix HUD border setting]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix tooltip hide in combat setting]=]},
    {GW.Enum.ChangelogType.bug,[=[Fix tooltip healthbar setting]=]},
})
addChange("6.1.0",{
    {GW.Enum.ChangelogType.feature,[=[Added brand new settings page]=]},
    {GW.Enum.ChangelogType.feature,[=[Added Community Feast and Siege On Dragonbane Keep timer to worldmap]=]},
    {GW.Enum.ChangelogType.feature,[=[Added option to set currencies to unused]=]},
    {GW.Enum.ChangelogType.feature,[=[Added option to collapse all objective trackers in Mythic+]=]},
    {GW.Enum.ChangelogType.feature,[=[Added evoker buff to raid buff reminder]=]},

    {GW.Enum.ChangelogType.change,[=[Aura Indicator updates:

- Resto Druid:
       Added Tranquility
       Added Adaptive Swarm

- Priest:
      Added Power Infusion

- Holy Pally:
       Added Barrier of Faith]=]},
    {GW.Enum.ChangelogType.change,[=[Social panel skin has been fixed has been readded]=]},
    {GW.Enum.ChangelogType.change,[=[Update Raid Debuff Filter and cleanded up Mythic+ Affixes]=]},
    {GW.Enum.ChangelogType.change,[=[Update some raid buff reminder spells]=]},

    {GW.Enum.ChangelogType.bug,[=[Fix for auto sell taint error]=]},
    {GW.Enum.ChangelogType.bug,[=[Temp fix for extra actionbutton taint]=]},
    {GW.Enum.ChangelogType.bug,[=[Memory and performance improvements]=]},
})
addChange("6.0.10",{
    {GW.Enum.ChangelogType.bug,[=[Error on start]=]},
})
addChange("6.0.9",{
    {GW.Enum.ChangelogType.bug,[=[Restored mirror timers]=]},
})
addChange("6.0.8",{
    {GW.Enum.ChangelogType.bug,[=[Fix for memory leak]=]},
})
addChange("6.0.7",{
    {GW.Enum.ChangelogType.bug,[=[Error on start]=]},
})
addChange("6.0.6",{
    {GW.Enum.ChangelogType.bug,[=[Bank issues]=]},
    {GW.Enum.ChangelogType.bug,[=[Error on start]=]}
})
addChange("6.0.5",{
    {GW.Enum.ChangelogType.bug,[=[Minimap lua error]=]},
    {GW.Enum.ChangelogType.bug,[=[Bag taint]=]}
})
addChange("6.0.4",{
    {GW.Enum.ChangelogType.bug,[=[Fix some more taint issues]=]},
})
addChange("6.0.3",{
    {GW.Enum.ChangelogType.bug,[=[Wrong GW2 moverframe value]=]}
})
addChange("6.0.2",{
    {GW.Enum.ChangelogType.bug,[=[Set actionbar 1 to always have 12 buttons]=]},
    {GW.Enum.ChangelogType.bug,[=[Actionbar taint on shapshift forms]=]}
})
addChange("6.0.1",{
    {GW.Enum.ChangelogType.bug,[=[Fix lua error on login]=]}
})
addChange("6.0.0",{
    {GW.Enum.ChangelogType.feature,[=[Update for 10.0.2]=]}
})
