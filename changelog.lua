local _, GW = ...

GW.ChangelogType = EnumUtil.MakeEnum(
	"feature",
	"change",
	"bug"
)

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



addChange("10.2.1", {
    {GW.ChangelogType.bug, [=[More chat secrets]=]},
    {GW.ChangelogType.bug, [=[Grid color error]=]},
    {GW.ChangelogType.bug, [=[Equipment manager item level]=]},
    {GW.ChangelogType.bug, [=[Vehicle leave button on TBC]=]},
    {GW.ChangelogType.bug, [=[Missing widgets on TBC and Mists]=]},
    {GW.ChangelogType.bug, [=[PvP UI fixes]=]},
    {GW.ChangelogType.change, [=[Grid buffs can be disabled (retail)]=]},
})

addChange("10.2.0", {
    {GW.ChangelogType.feature, [=[Added all new aura filter options to grids (retail)]=]},
    {GW.ChangelogType.feature, [=[Added party pet grid]=]},
    {GW.ChangelogType.feature, [=[Added new aura filter options to target unitframe]=]},
    {GW.ChangelogType.bug, [=[More secrets with 12.0.1]=]},
})

addChange("10.1.0", {
    {GW.ChangelogType.feature, [=[Added bar size settings to: Targetframe, Target of targetframe, Focusframe, Target of focusframe and playerframe]=]},
    {GW.ChangelogType.feature, [=[Added option to change chatbubble size]=]},
    {GW.ChangelogType.feature, [=[Added option to toggle the dodgebar]=]},
    {GW.ChangelogType.feature, [=[Added option to toggle the skyridingbar]=]},
    {GW.ChangelogType.feature, [=[Added option to anchor the classpower bar to center to have them alligned when using profile on different characters]=]},
    {GW.ChangelogType.feature, [=[Added option to show keybinds only on used slots]=]},
    {GW.ChangelogType.feature, [=[Added option for a rectangle minimap (Read the setting notes)]=]},
    {GW.ChangelogType.change, [=[Gear manager: Gears can now be draged to the actionbars]=]},
    {GW.ChangelogType.change, [=[ Dodgebar, skyridingbar and player ressourcebars now fades with player frame)]=]},
    {GW.ChangelogType.bug, [=[Some more secrets (retail)]=]},
    {GW.ChangelogType.bug, [=[Grid range fader is working again]=]},
    {GW.ChangelogType.bug, [=[Raidmarkers are now showing correclty]=]},
    {GW.ChangelogType.bug, [=[Many more fixes]=]},
})

addChange("10.0.5", {
    {GW.ChangelogType.bug, [=[Gamemenu skin on TBC]=]},
    {GW.ChangelogType.bug, [=[Aura tooltip works again]=]},
    {GW.ChangelogType.bug, [=[Chatframe secret value]=]},
    {GW.ChangelogType.bug, [=[Forbidden tooltips]=]},
    {GW.ChangelogType.bug, [=[Socal frame lua error]=]},
    {GW.ChangelogType.bug, [=[Frame fader fixes]=]},
    {GW.ChangelogType.bug, [=[Raid target fix]=]},
})

addChange("10.0.4", {
    {GW.ChangelogType.change, [=[Added grid aura filter options for retail, that are all blizzard allows at the moment]=]},
    {GW.ChangelogType.bug, [=[Totembar error on none Retail clients]=]},
    {GW.ChangelogType.bug, [=[Grid backgorund on none Retail clients]=]},
})

addChange("10.0.3", {
    {GW.ChangelogType.bug, [=[Tooltip error on TBC]=]},
})

addChange("10.0.2", {
    {GW.ChangelogType.bug, [=[Tooltip error on TBC]=]},
})

addChange("10.0.1", {
    {GW.ChangelogType.bug, [=[Tooltip error on TBC]=]},
})

addChange("10.0.0", {
    {GW.ChangelogType.feature, [=[Midnight support]=]},
})

addChange("9.1.0", {
    {GW.ChangelogType.feature, [=[Social frame for TBC]=]},
    {GW.ChangelogType.bug, [=[Chat frame fixes (TBC)]=]},
    {GW.ChangelogType.bug, [=[Questlog skin fixes (TBC)]=]},
    {GW.ChangelogType.bug, [=[Hide Keyring if actionbar not enabled (TBC & Era)]=]},
    {GW.ChangelogType.bug, [=[Fix minimap left click lua error (TBC)]=]},
    {GW.ChangelogType.bug, [=[Fix spellbook and talents not clickable (TBC)]=]},
    {GW.ChangelogType.bug, [=[Fix totembar lua error (TBC)]=]},
    {GW.ChangelogType.bug, [=[Update spellbook (TBC)]=]},
    {GW.ChangelogType.bug, [=[Fix objectives tracker actionbutton (TBC)]=]},
    {GW.ChangelogType.bug, [=[Fix customs classcolor on none retail clients]=]},
    {GW.ChangelogType.bug, [=[Fix merchant skin (TBC))]=]},
    {GW.ChangelogType.bug, [=[Fix missing auto repair text (TBC)]=]},
    {GW.ChangelogType.bug, [=[Fix not cancable player auras (TBC)]=]},
})

addChange("9.0.2", {
    {GW.ChangelogType.bug, [=[Added missing raid debuffs for TBC]=]},
    {GW.ChangelogType.bug, [=[Added many TBC checks]=]},
    {GW.ChangelogType.bug, [=[Fix tooltip (TBC)]=]},
    {GW.ChangelogType.bug, [=[Fix gossip skin (TBC)]=]},
    {GW.ChangelogType.bug, [=[Added missing minimap tracking (TBC)]=]},
})

addChange("9.0.1", {
    {GW.ChangelogType.bug, [=[Pet happines is now active on TBC]=]},
    {GW.ChangelogType.bug, [=[Questlog skin updates for TBC]=]},
    {GW.ChangelogType.bug, [=[Update Honor Tab for TBC]=]},
    {GW.ChangelogType.bug, [=[Many actionbar fixes for TBC]=]},
    {GW.ChangelogType.bug, [=[Disable some objectives tracker modules which are not supported in TBC, like Boss frames]=]},
    {GW.ChangelogType.bug, [=[Fix micromenu lua error]=]},
    {GW.ChangelogType.bug, [=[Fix chatframe lua error]=]},
    {GW.ChangelogType.bug, [=[Added missing consts for TBC]=]},
    {GW.ChangelogType.bug, [=[Fix shaman classpowe error on TBC]=]},
})

addChange("9.0.0", {
    {GW.ChangelogType.feature, [=[TBC support]=]},
})

addChange("8.6.2", {
    {GW.ChangelogType.bug, [=[Used wrong setting for worldmap scale for era]=]},
})

addChange("8.6.1", {
    {GW.ChangelogType.bug, [=[Worldmap position and scale is not saved (era)]=]},
    {GW.ChangelogType.change, [=[FCT default style uses now a fallback from on nameplate anchor]=]},
    {GW.ChangelogType.change, [=[XP bar rework]=]},
})

addChange("8.6.0", {
    {GW.ChangelogType.feature, [=[Add option to invert multiactionbars, to follow the blizzard layout]=]},
    {GW.ChangelogType.bug, [=[Chatframe fixes]=]},
})

addChange("8.5.3", {
    {GW.ChangelogType.change, [=[Add housing micro button]=]},
    {GW.ChangelogType.bug, [=[Many chat related fixes]=]},
    {GW.ChangelogType.bug, [=[Socket skin error (Mists)]=]},
})

addChange("8.5.2", {
    {GW.ChangelogType.change, [=[Updates for 11.2.7]=]},
})

addChange("8.5.1", {
    {GW.ChangelogType.change, [=[Talent switch works again (Mists)]=]},
})

addChange("8.5.0", {
    {GW.ChangelogType.feature, [=[Added Recent Alliens tab to social panel (retail)]=]},
    {GW.ChangelogType.feature, [=[Add CD Manager skin (retail)]=]},
    {GW.ChangelogType.bug, [=[Fix character stats lus error (mists)]=]},
    {GW.ChangelogType.bug, [=[Fix druid mana bar in bear form]=]},
})

addChange("8.4.6", {
    {GW.ChangelogType.bug, [=[Fix era honor lua error]=]},
})

addChange("8.4.5", {
    {GW.ChangelogType.bug, [=[Fix spellbook lua error (era)]=]},
})

addChange("8.4.4", {
    {GW.ChangelogType.bug, [=[Remove not needed and outdated libs]=]},
})

addChange("8.4.3", {
    {GW.ChangelogType.bug, [=[Fix talent tooltip (era)]=]},
    {GW.ChangelogType.bug, [=[Fix rare hunter pet name error (era & mists)]=]},
    {GW.ChangelogType.bug, [=[Fix objectives tracker (mists)]=]},
})

addChange("8.4.2", {
    {GW.ChangelogType.change, [=[1.15.8 fixes]=]},
})

addChange("8.4.1", {
    {GW.ChangelogType.bug, [=[Fix Bag lua error (Era)]=]},
    {GW.ChangelogType.bug, [=[Fix PetTracker lua error (Retail)]=]},
})

addChange("8.4.0", {
    {GW.ChangelogType.feature, [=[Added option to disable micromenu module]=]},
    {GW.ChangelogType.feature, [=[Added monk stagger value to classpower bar]=]},
    {GW.ChangelogType.bug, [=[Fix Questie Map Coords error (Era & Mists)]=]},
    {GW.ChangelogType.bug, [=[Fix classpower 'Only show in combat' option when leaving a vehicle]=]},
    {GW.ChangelogType.change, [=[Refactor seperate bag option]=]},
    {GW.ChangelogType.change, [=[TOC update (Mists)]=]},
})

addChange("8.3.5", {
    {GW.ChangelogType.bug, [=[Fix settings dependecies tooltip]=]},
    {GW.ChangelogType.bug, [=[Fix reset profile option]=]},
    {GW.ChangelogType.bug, [=[Fix Paladin classpower]=]},
    {GW.ChangelogType.change, [=[Add missing auctionator frame skin]=]},
    {GW.ChangelogType.change, [=[Update classpower aura handling, this should be a performace boost, if your class has a classpower based on a de/buff]=]},
})

addChange("8.3.4", {
    {GW.ChangelogType.bug, [=[Player powerbar is now correctly hidden in specific situations]=]},
    {GW.ChangelogType.bug, [=[Fixed Lua error for fresh characters]=]},
    {GW.ChangelogType.bug, [=[Fixed Game Menu skin issue when using ConsolePort]=]},
    {GW.ChangelogType.bug, [=[Fixed fading issue with player pet frame icon]=]},
    {GW.ChangelogType.bug, [=[Fixed Lua error in Who-list]=]},
    {GW.ChangelogType.bug, [=[Fixed Lua error when opening the settings menu]=]},
    {GW.ChangelogType.bug, [=[Fixed Lua error in immersive questing when required money is missing (Era & Mists)]=]},
})

addChange("8.3.3",{
    {GW.ChangelogType.bug, [=[Fix wrong classpower color for warlocks (Mists)]=]},
    {GW.ChangelogType.bug, [=[Fix settings lua error is UI Scale is used]=]},
})

addChange("8.3.2",{
    {GW.ChangelogType.bug, [=[Fix micromenu issue with consoleport addon]=]},
})

addChange("8.3.1",{
    {GW.ChangelogType.change, [=[Settingsframe rework, addons can now hook into it]=]},
    {GW.ChangelogType.bug, [=[Fix TSM Loading issue]=]},
    {GW.ChangelogType.bug, [=[Fix DB migration for old profiles]=]},
    {GW.ChangelogType.bug, [=[Fix druid bear hud background]=]},
    {GW.ChangelogType.bug, [=[Fix quest item not clickable (retail)]=]},
    {GW.ChangelogType.bug, [=[Fix quest item texture too big (era)]=]},
    {GW.ChangelogType.bug, [=[Fix druid eclipsebar (mists)]=]},
})

addChange("8.3.0",{
    {GW.ChangelogType.change, [=[11.2.0 support]=]},
})

addChange("8.2.8",{
    {GW.ChangelogType.bug, [=[Fix absorb bar toggle]=]},
    {GW.ChangelogType.change, [=[Enable absorb bar toggle on Mists and Retail clients]=]},
})

addChange("8.2.7",{
    {GW.ChangelogType.bug, [=[Fix hunter classpower]=]},
    {GW.ChangelogType.bug, [=[Fix micro stuttering while leaving combat (retail)]=]},
})

addChange("8.2.6",{
    {GW.ChangelogType.bug, [=[Migration lua error for new users]=]},
    {GW.ChangelogType.bug, [=[GW2 Layout creation if max Account Layouts are reached (retail)]=]},
    {GW.ChangelogType.bug, [=[Fix micromenu moving (mists)]=]},
    {GW.ChangelogType.bug, [=[Copy chat / emote button not clickable (mists & era)]=]},
})

addChange("8.2.5",{
    {GW.ChangelogType.bug, [=[Fix quest sorting (era & mists)]=]},
    {GW.ChangelogType.bug, [=[Fix reputation text (retail)]=]},
    {GW.ChangelogType.bug, [=[Fix classpower]=]},
    {GW.ChangelogType.bug, [=[Fix objectives tracker quest item (era)]=]},
})

addChange("8.2.4",{
    {GW.ChangelogType.bug, [=[Fix warbank itemlevel (retail)]=]},
    {GW.ChangelogType.bug, [=[Hide multibars during pet battle (mists)]=]},
    {GW.ChangelogType.bug, [=[Fix target health % values]=]},
    {GW.ChangelogType.bug, [=[Fix combopoints on target]=]},
    {GW.ChangelogType.bug, [=[Fix minimap instance difficult indicator (retail)]=]},
    {GW.ChangelogType.bug, [=[Fix actionbar coloring (mists)]=]},
    {GW.ChangelogType.bug, [=[Fix title filter error (retail)]=]},
})

addChange("8.2.3",{
    {GW.ChangelogType.bug, [=[Loading error]=]},
    {GW.ChangelogType.change, [=[Add more options to player de/buff settings]=]},
})

addChange("8.2.2",{
    {GW.ChangelogType.bug, [=[Bagnator skin error (Mists)]=]},
    {GW.ChangelogType.bug, [=[Objectives tracker actionbutton error (Era)]=]},
})

addChange("8.2.1",{
    {GW.ChangelogType.bug, [=[Arena frame lua error (Mists)]=]},
})

addChange("8.2.0",{
    {GW.ChangelogType.feature, [=[Add option to hide absorb bar on all unitframes]=]},
})

addChange("8.1.9",{
    {GW.ChangelogType.bug, [=[Scenario error (retail)]=]},
    {GW.ChangelogType.bug, [=[Bag sorting (Mists & Era)]=]},
})

addChange("8.1.8",{
    {GW.ChangelogType.bug, [=[Bag opening lag]=]},
    {GW.ChangelogType.bug, [=[Wrong tooltip faction (Retail)]=]},
    {GW.ChangelogType.bug, [=[Friendstooltip show correct game now]=]},
    {GW.ChangelogType.bug, [=[Spellbook tweaks (Mists)]=]},
})

addChange("8.1.7",{
    {GW.ChangelogType.bug, [=[Shadow prist orbs (mists)]=]},
    {GW.ChangelogType.bug, [=[DK runes (mists)]=]},
    {GW.ChangelogType.bug, [=[Unitframe absorb amounts (mists)]=]},
})

addChange("8.1.6",{
    {GW.ChangelogType.bug, [=[Next round of Mists fixes]=]},
})

addChange("8.1.5",{
    {GW.ChangelogType.change, [=[Added temp chi bg texture]=]},
})

addChange("8.1.4",{
    {GW.ChangelogType.bug, [=[Next round of Mists fixes]=]},
})

addChange("8.1.3",{
    {GW.ChangelogType.bug, [=[Fix issue with 8.1.2]=]},
})

addChange("8.1.2",{
    {GW.ChangelogType.bug, [=[More Mists adjustments]=]},
})

addChange("8.1.1",{
    {GW.ChangelogType.bug, [=[More Mists adjustments]=]},
})

addChange("8.1.0",{
    {GW.ChangelogType.bug, [=[Mists support]=]},
})

addChange("8.0.7",{
    {GW.ChangelogType.bug, [=[Fix collection tracking collapse (retail)]=]},
})

addChange("8.0.6",{
    {GW.ChangelogType.bug, [=[Some more fixes for all versions]=]},
})

addChange("8.0.5",{
    {GW.ChangelogType.bug, [=[Fix target level color (era & cata)]=]},
    {GW.ChangelogType.bug, [=[Fix unit level at tooltip (era)]=]},
    {GW.ChangelogType.bug, [=[Fix aura tooltip (era & cata)]=]},
    {GW.ChangelogType.bug, [=[Fix mirror timer (era & cata)]=]},
    {GW.ChangelogType.bug, [=[Fix objectives tooltip (era & cata)]=]},
    {GW.ChangelogType.bug, [=[Fix copying profiles)]=]},
})

addChange("8.0.4",{
    {GW.ChangelogType.bug, [=[Fix microbar moving (cata)]=]},
    {GW.ChangelogType.bug, [=[Readd spellbook and talent setting (cata)]=]},
    {GW.ChangelogType.bug, [=[Fix skyridingbar (retail)]=]},
})

addChange("8.0.3",{
    {GW.ChangelogType.bug, [=[Fix eclips bar on era]=]},
    {GW.ChangelogType.bug, [=[Fix micromenu moving on era and cata]=]},
})

addChange("8.0.2",{
    {GW.ChangelogType.bug, [=[Combopoint error for era and cata]=]},
})

addChange("8.0.1",{
    {GW.ChangelogType.feature, [=[Merged Retail, Era and Cata version]=]},
})

addChange("7.15.0",{
    {GW.ChangelogType.feature, [=[Added more option to unitframe fader]=]},
    {GW.ChangelogType.feature, [=[Added option to extend player powerbar hight (player unitframe)]=]},
    {GW.ChangelogType.change, [=[Add required settings to settings tooltip]=]},
    {GW.ChangelogType.bug, [=[Fix Pawn integration]=]},
})

addChange("7.14.1",{
    {GW.ChangelogType.bug, [=[Fix settings lua error]=]},
})

addChange("7.14.0",{
    {GW.ChangelogType.feature, [=[Added unitframe fader options to all unitframes]=]},
    {GW.ChangelogType.bug, [=[Raidlock error]=]},
    {GW.ChangelogType.bug, [=[Fix buff reminder]=]},
    {GW.ChangelogType.bug, [=[Fix pawn integration]=]},
})

addChange("7.13.2",{
    {GW.ChangelogType.bug, [=[Fix issue with 7.13.1]=]},
})

addChange("7.13.1",{
    {GW.ChangelogType.bug, [=[Hero panel opens for enchants]=]},
    {GW.ChangelogType.bug, [=[Weapon enchants should now show correclty]=]},
    {GW.ChangelogType.bug, [=[Fix Pawn integration]=]},
    {GW.ChangelogType.bug, [=[Raid lock lua error]=]},
    {GW.ChangelogType.change, [=[Redo reputation frame, should load and react faster]=]},
    {GW.ChangelogType.change, [=[Add radio button texture]=]},
    {GW.ChangelogType.change, [=[Added Nightfall to objectives tracker]=]},
    {GW.ChangelogType.change, [=[Update some skins]=]},
    {GW.ChangelogType.change, [=[Added 3 new widget mover to move hud mode]=]},
    {GW.ChangelogType.change, [=[Added some animations]=]},
})

addChange("7.13.0",{
    {GW.ChangelogType.feature, [=[Cooldown Manager skin]=]},
    {GW.ChangelogType.feature, [=[Add paragon indicator to reputation category list]=]},
    {GW.ChangelogType.bug, [=[PetTracker integration now work as expected]=]},
    {GW.ChangelogType.bug, [=[WQT integration now work as expected]=]},
    {GW.ChangelogType.bug, [=[Error when entering delves]=]},
    {GW.ChangelogType.change, [=[Rewritten objectives tracker, should perform much better now]=]},
    {GW.ChangelogType.change, [=[Better CLEU handling with sharing over the addon]=]},
    {GW.ChangelogType.change, [=[Much more optimization over all modules of the addon]=]},
})

addChange("7.12.1",{
    {GW.ChangelogType.change, [=[Skin tweaks]=]},
    {GW.ChangelogType.bug, [=[Fix profile lua error]=]},
    {GW.ChangelogType.bug, [=[Fix FCT lua error]=]},
    {GW.ChangelogType.bug, [=[Castbar channel ticks]=]},
    {GW.ChangelogType.bug, [=[Target frame debuff settings are working again]=]},
})

addChange("7.12.0",{
    {GW.ChangelogType.bug, [=[Update for 11.1.0]=]},
})

addChange("7.11.1",{
    {GW.ChangelogType.bug, [=[Fix actionbar taint]=]},
})

addChange("7.11.0",{
    {GW.ChangelogType.feature, [=[dded option to hide target item level display]=]},
    {GW.ChangelogType.feature, [=[Added option to show Singing Socket gems]=]},
    {GW.ChangelogType.change, [=[Update auctionator skin]=]},
    {GW.ChangelogType.bug, [=[Repuration error]=]},
    {GW.ChangelogType.bug, [=[Notification tooltip]=]},
    {GW.ChangelogType.bug, [=[Fix inverted statusbar]=]},
    {GW.ChangelogType.bug, [=[Party frame auras can stuck sometimes]=]},
})

addChange("7.10.0",{
    {GW.ChangelogType.feature, [=[Added Talking Head Scaler]=]},
    {GW.ChangelogType.feature, [=[Target/Focus frame bars no inverted in inverted mode]=]},
    {GW.ChangelogType.change, [=[Optimize aura handling for all unitframes]=]},
    {GW.ChangelogType.change, [=[Optimize Healthbar and Powerbar handling]=]},
    {GW.ChangelogType.bug, [=[Fix PetTracker loading]=]},
})

addChange("7.9.3",{
    {GW.ChangelogType.change, [=[Remove CUSTOM_CLASS_COLOR support and cahnge it to GW2 Class colors]=]},
    {GW.ChangelogType.change, [=[Add option to set number format]=]},
})

addChange("7.9.2",{
    {GW.ChangelogType.change, [=[TRP3 chat support]=]},
})

addChange("7.9.1",{
    {GW.ChangelogType.change, [=[TRP3 chat support]=]},
})

addChange("7.9.0",{
    {GW.ChangelogType.feature, [=[Added grid out of range alpha value setting]=]},
    {GW.ChangelogType.feature, [=[Added custom class color support]=]},
    {GW.ChangelogType.change, [=[Update more dropdowns]=]},
    {GW.ChangelogType.change, [=[Use local number delimiter]=]},
    {GW.ChangelogType.change, [=[11.0.7 changes]=]},
    {GW.ChangelogType.bug, [=[Fix PetTracker integration]=]},
    {GW.ChangelogType.bug, [=[Fix Blizzard mirror timer not shown]=]},
    {GW.ChangelogType.bug, [=[Setting search works again]=]},
})

addChange("7.8.0",{
    {GW.ChangelogType.feature, [=[Add option to hook profiles to a spec. This will switch the profile on spec switch]=]},
    {GW.ChangelogType.feature, [=[Add todoloo support for GW2 Objectives tracker]=]},
    {GW.ChangelogType.feature, [=[Add searchbox for player titles]=]},
    {GW.ChangelogType.feature, [=[Add slash command to clear tracked but already earned achievements (blizzard bug): /gw2 clear achievements]=]},
    {GW.ChangelogType.feature, [=[Add option to change profile icons]=]},
    {GW.ChangelogType.feature, [=[Add TRP3 support for GW2 chatbubbles]=]},
    {GW.ChangelogType.change, [=[Added fraction icons to the guild datatext]=]},
    {GW.ChangelogType.change, [=[Change all dropdown elements to new blizzard ui system]=]},
    {GW.ChangelogType.change, [=[Allow max 4 watched tokens with gw2 bags enabled]=]},
    {GW.ChangelogType.bug, [=[Objectives tracker bonus step names]=]},
    {GW.ChangelogType.bug, [=[Achievement skin scroll height]=]},
    {GW.ChangelogType.bug, [=[Grid aura indicators now only shows player auras]=]},
    {GW.ChangelogType.bug, [=[Fix dodgebar for some classes]=]},
    {GW.ChangelogType.bug, [=[Fix objectives tracker loading order]=]},
})

addChange("7.7.2",{
    {GW.ChangelogType.bug, [=[Guild data info lua error]=]},
    {GW.ChangelogType.change, [=[Skin updates]=]},
    {GW.ChangelogType.change, [=[Guild data info text]=]},
    {GW.ChangelogType.change, [=[Stackcount setting]=]},
})

addChange("7.7.1",{
    {GW.ChangelogType.change, [=[Add Dracthyr fraction to tooltip]=]},
    {GW.ChangelogType.change, [=[Add stackcount to tooltip]=]},
    {GW.ChangelogType.change, [=[Changes for 11.0.5]=]},
})

addChange("7.7.0",{
    {GW.ChangelogType.feature, [=[Option to copy a single chat line]=]},
    {GW.ChangelogType.feature, [=[Option to show chat history]=]},
    {GW.ChangelogType.feature, [=[Option to show channel ticks on castbar]=]},
    {GW.ChangelogType.feature, [=[Option to control the grid name update frequence to save some fps]=]},
    {GW.ChangelogType.feature, [=[Add mastery buff to raid buff reminder]=]},
    {GW.ChangelogType.change, [=[Jailers tower error]=]},
    {GW.ChangelogType.change, [=[Social frame lua error]=]},
    {GW.ChangelogType.change, [=[Player castbar sometimes stuck on screen]=]},
    {GW.ChangelogType.change, [=[Update some skins]=]},
    {GW.ChangelogType.change, [=[Add warband reputation indicator]=]},
})

addChange("7.6.0",{
    {GW.ChangelogType.feature, [=[Add option to shorten healtglobe shield values]=]},
    {GW.ChangelogType.feature, [=[Add option to hide player frame at party grid]=]},
    {GW.ChangelogType.feature, [=[Add option to hide class icons at grids, if no class color is used]=]},
    {GW.ChangelogType.bug, [=[Fix drawn layer of lfg accept button]=]},
    {GW.ChangelogType.bug, [=[Fix BigWigs integration]=]},
    {GW.ChangelogType.change, [=[Add Monk hero talent to dodgebar]=]},
    {GW.ChangelogType.change, [=[Added theater event timer bar to objectives tracker]=]},
    {GW.ChangelogType.change, [=[Update some skins]=]},
})

addChange("7.5.0",{
    {GW.ChangelogType.feature, [=[Add option to shorten values, like health values or damage text]=]},
    {GW.ChangelogType.bug, [=[Fix new font settings]=]},
    {GW.ChangelogType.bug, [=[fix LSM with new fonts]=]},
})

addChange("7.4.0",{
    {GW.ChangelogType.feature, [=[New Font system
        - You can now select between multiple different font styles
        - You can select your own fonts for texts and header texts
        - You can adjust the font size for: Big Headers, Header, Normal and Small texts

        - To select the font like before this update, use 'GW2 Legacy']=]},
    {GW.ChangelogType.feature, [=[Tooltips gets font size option for all 3 types]=]},
    {GW.ChangelogType.feature, [=[Added TWW events to the event tracker]=]},
    {GW.ChangelogType.feature, [=[Added auction house skin]=]},
    {GW.ChangelogType.feature, [=[Added fx animation to the dynamic hud (not all classes yet)]=]},
    {GW.ChangelogType.feature, [=[Added remaning live to delve tracker]=]},
    {GW.ChangelogType.feature, [=[Find an small easter agg with the GW2 settings splash screen]=]},
    {GW.ChangelogType.change, [=[Add DK hero talent to dodgebar]=]},
    {GW.ChangelogType.change, [=[Update some textures]=]},
    {GW.ChangelogType.change, [=[Update some skins]=]},
    {GW.ChangelogType.bug, [=[Fix barber shop skin]=]},
})

addChange("7.3.0",{
    {GW.ChangelogType.feature, [=[Delves support for objectives tracker]=]},
    {GW.ChangelogType.feature, [=[Added group progress to objectives tooltip]=]},
    {GW.ChangelogType.change, [=[Update some skins]=]},
    {GW.ChangelogType.bug, [=[Objectives tracker auto turn in quests]=]},
    {GW.ChangelogType.bug, [=[Totem tracker should work again]=]},
})

addChange("7.2.0",{
    {GW.ChangelogType.feature, [=[Talent frame skin]=]},
    {GW.ChangelogType.feature, [=[Tooltip Item Count now has options Include Reagents and Include Warband]=]},
    {GW.ChangelogType.feature, [=[Keybind support for immersive questing]=]},
    {GW.ChangelogType.feature, [=[Keybind support for gossip skin]=]},
    {GW.ChangelogType.feature, [=[Stancebar can now be disabled]=]},
    {GW.ChangelogType.feature, [=[DK runes now get sorted based on there progress]=]},
    {GW.ChangelogType.feature, [=[Add timer to tracked achievements]=]},
    {GW.ChangelogType.feature, [=[New immersive questing backgrounds for TWW]=]},
    {GW.ChangelogType.change, [=[Chat frame alert color is now saved per character]=]},
    {GW.ChangelogType.change, [=[Update some skins]=]},
    {GW.ChangelogType.change, [=[Update imported debuffs]=]},
    {GW.ChangelogType.bug, [=[EJ skin error]=]},
    {GW.ChangelogType.bug, [=[Raid frame ignored auras works again]=]},
    {GW.ChangelogType.bug, [=[Fix GW2_Layout creation process]=]},
})

addChange("7.1.0",{
    {GW.ChangelogType.feature, [=[Added option to skin blizzards default actionbars
        That function disabled our managed actionbars and there hooked features]=]},
    {GW.ChangelogType.feature, [=[Adventuremap skin]=]},
    {GW.ChangelogType.bug, [=[Objectives tracker actionbutton works again]=]},
    {GW.ChangelogType.bug, [=[Error handler shows only GW2 errors]=]},
    {GW.ChangelogType.bug, [=[M+ progess counter should show correect % again (raw value is not possible atm)]=]},
    {GW.ChangelogType.bug, [=[Fix minimap lua error]=]},
    {GW.ChangelogType.change, [=[Added TRP3 tooltips support]=]},
    {GW.ChangelogType.change, [=[Immersive Question changes and improvements]=]},
})

addChange("7.0.2",{
    {GW.ChangelogType.change, [=[Added self reading animation to immersive questing]=]},
    {GW.ChangelogType.bug, [=[Fix error handler]=]},
    {GW.ChangelogType.bug, [=[Fix objective tracker action button handling]=]},
    {GW.ChangelogType.bug, [=[Fix event objectives click functions]=]},
    {GW.ChangelogType.bug, [=[Fix currency transfer taint error]=]},
    {GW.ChangelogType.bug, [=[Fix ouf range indicator]=]},
})

addChange("7.0.1",{
    {GW.ChangelogType.bug, [=[First round of fixes]=]},
})

addChange("7.0.0",{
    {GW.ChangelogType.change, [=[Update for TWW]=]},
})

addChange("6.14.10",{
    {GW.ChangelogType.bug, [=[Show character item info now works correctly]=]},
    {GW.ChangelogType.change, [=[Export some api]=]},
})

addChange("6.14.9",{
    {GW.ChangelogType.change, [=[Export some api]=]},
})

addChange("6.14.8",{
    {GW.ChangelogType.change, [=[Update toc]=]},
})

addChange("6.14.7",{
    {GW.ChangelogType.change, [=[Prepare for 10.2.7]=]},
})

addChange("6.14.6",{
    {GW.ChangelogType.bug, [=[Fix GW2 slash commands]=]},
    {GW.ChangelogType.bug, [=[Fix merchant frame next/prev page button position]=]},
    {GW.ChangelogType.bug, [=[Fix lua error if our minimap is disableds]=]},
    {GW.ChangelogType.bug, [=[Fix character itemlevel was not shown]=]},
})

addChange("6.14.5",{
    {GW.ChangelogType.bug, [=[Party frame visibility]=]},
})

addChange("6.14.4",{
    {GW.ChangelogType.bug, [=[Tooltip M+ lua error]=]},
})

addChange("6.14.3",{
    {GW.ChangelogType.bug, [=[Party visibility]=]},
})

addChange("6.14.2",{
    {GW.ChangelogType.change, [=[Update for 10.2.6]=]},
})

addChange("6.14.1",{
    {GW.ChangelogType.bug, [=[Fix details profile]=]},
    {GW.ChangelogType.bug, [=[Fix player debuff show wrong icon texture]=]},
    {GW.ChangelogType.bug, [=[Fix gossip skin text height]=]},
    {GW.ChangelogType.bug, [=[Fix small unitframe height]=]},
    {GW.ChangelogType.bug, [=[Fix ToT mover]=]},
    {GW.ChangelogType.bug, [=[Fix playerframe level up icon]=]},
    {GW.ChangelogType.bug, [=[Fix objectiv tracker hover not showing all details]=]},
    {GW.ChangelogType.bug, [=[Fix creating new profile]=]},

    {GW.ChangelogType.change, [=[Update merchant skin]=]},
    {GW.ChangelogType.change, [=[Change castbar mover frame beased on details option]=]},
    {GW.ChangelogType.change, [=[Added Masque actionbutton skin]=]},
})

addChange("6.14.0", {
    {GW.ChangelogType.feature, [=[Added Big Dig event timer]=]},
    {GW.ChangelogType.feature, [=[Added option to change pulltimer seconds]=]},

    {GW.ChangelogType.bug, [=[Raidframes name overlapping]=]},
    {GW.ChangelogType.bug, [=[Chat install process]=]},
    {GW.ChangelogType.bug, [=[Alt player background setting]=]},
    {GW.ChangelogType.bug, [=[Colorpicker error]=]},
})

addChange("6.13.3",{
    {GW.ChangelogType.bug, [=[Remove print statement]=]},
})

addChange("6.13.2",{
    {GW.ChangelogType.bug, [=[Fix profile page error]=]},
    {GW.ChangelogType.bug, [=[Fix db migration error]=]},
    {GW.ChangelogType.bug, [=[Handle evoker soar correct]=]},
})

addChange("6.13.1",{
    {GW.ChangelogType.bug, [=[Fix error a profile rename]=]},
})

addChange("6.13.0",{
    {GW.ChangelogType.feature, [=[Switch to a new database format to better handle profiles. That requires a reload after the first login on each character.]=]},
    {GW.ChangelogType.feature, [=[Added right click function to the minimaps expansion icon to show also the landing pages from previous addons]=]},
    {GW.ChangelogType.feature, [=[Added animated statusbars to the pet frame]=]},
    {GW.ChangelogType.feature, [=[Added copy/paste function to colorpicker]=]},
    {GW.ChangelogType.feature, [=[Added option to disable objectives statusbars to have a more compact objectives tracker]=]},

    {GW.ChangelogType.change, [=[Some more settings does not requires a reload]=]},

    {GW.ChangelogType.bug, [=[Fix stancebar error. You can now use the button in combat again]=]},
    {GW.ChangelogType.bug, [=[Fix worldmap event tracker container size]=]},
    {GW.ChangelogType.bug, [=[Fix tank frame middle icon]=]},
    {GW.ChangelogType.bug, [=[Fix auraindicators updating]=]},
    {GW.ChangelogType.bug, [=[GW2 setting window is now moveable]=]},
})


addChange("6.12.0",{
    {GW.ChangelogType.feature, [=[Added new paladin classpower texture and animation]=]},
    {GW.ChangelogType.feature, [=[Added new arms warrior classpower]=]},
    {GW.ChangelogType.feature, [=[Update GW2 boss frames, they are now unitframes]=]},
    {GW.ChangelogType.feature, [=[Added options to toggle grid rol icons, tank icons and leader icons]=]},

    {GW.ChangelogType.change, [=[Adjust grid out of range alpha value]=]},
    {GW.ChangelogType.change, [=[Update grid to work again with OmniCD]=]},

    {GW.ChangelogType.bug, [=[Fix PP mode get saved correctly]=]},
    {GW.ChangelogType.bug, [=[Fix move HUD grid]=]},
    {GW.ChangelogType.bug, [=[Fix immersive Questing taint issue]=]},
    {GW.ChangelogType.bug, [=[Fix arena frame lua errors]=]},
    {GW.ChangelogType.bug, [=[Fix classpower error in combat]=]},
})

addChange("6.11.1",{
    {GW.ChangelogType.bug,[=[Correct LEMO integration which was causing an lua error during installation process]=]},
    {GW.ChangelogType.bug,[=[Tweak Event Timer height]=]},
})

addChange("6.11.0",{
    {GW.ChangelogType.feature, [=[Redo all grids: Party, Raid, Raid Pet]=]},
    {GW.ChangelogType.feature, [=[Grids are now secure and can update during combat]=]},
    {GW.ChangelogType.feature, [=[Added new grids:
        - Maintank
        - Raid 10
        - Raid 25
        - Raid 40]=]},
    {GW.ChangelogType.feature, [=[Raid grids switch automaticly between the 3 raid grids, based on the number of players at the raid]=]},
    {GW.ChangelogType.feature, [=[Added new grouping and sorting settings to all grids:
        - Group by: Role, Class, Group, Name, Index
        - Sort direction
        - Sortmethode: Name, Index
        - Raidwaid sorting: If disabled the grouping and sorting settings are applyed per raid group]=]},
    {GW.ChangelogType.feature, [=[All grids have there individual settings (Raid 10, Raid 25, Raid 40, Maintank, Raid Pet, Group)]=]},
    {GW.ChangelogType.feature, [=[Added Superbloom event timer to worldmap]=]},
    {GW.ChangelogType.feature, [=[Added options to change the worldmap coordinats lable]=]},
    {GW.ChangelogType.feature, [=[Added option to hide classpower bar outside of combat]=]},

    {GW.ChangelogType.change, [=[Update for 10.2.0]=]},
    {GW.ChangelogType.change, [=[Update RAF skin]=]},
    {GW.ChangelogType.change, [=[Update Time Manager skin]=]},
    {GW.ChangelogType.change, [=[Added back right click option on bags]=]},
    {GW.ChangelogType.change, [=[Added S3 raid debuffs]=]},
    {GW.ChangelogType.change, [=[Adjust damage text animations]=]},
    {GW.ChangelogType.change, [=[Update TaintLess]=]},

    {GW.ChangelogType.bug, [=[Fix ready check skin]=]},
    {GW.ChangelogType.bug, [=[Fix blurr on raid warning font]=]},
    {GW.ChangelogType.bug, [=[Fix Pet Tracker and WQT Anchor points]=]},
    {GW.ChangelogType.bug, [=[Fix travler log header stucking after tracking activity is completed]=]},
    {GW.ChangelogType.bug, [=[Fix some taints]=]},
})

addChange("6.10.1",{
    {GW.ChangelogType.bug,[=[10.1.7 fixes]=]},
})

addChange("6.10.0",{
    {GW.ChangelogType.bug,[=[Added evoker ebon might bar]=]},
})

addChange("6.9.2",{
    {GW.ChangelogType.bug,[=[Fix an actionbars issue which can crash the client]=]},
})

addChange("6.9.1",{
    {GW.ChangelogType.bug,[=[More 10.1.5 related fixes]=]},
})

addChange("6.9.0",{
    {GW.ChangelogType.feature,[=[Added font settings for GW2 floating combat text]=]},
    {GW.ChangelogType.change,[=[Update for 10.1.5]=]},
})

addChange("6.8.2",{
    {GW.ChangelogType.bug,[=[Fix druid little manabar in cat form with player frame in target frame style]=]},
    {GW.ChangelogType.bug,[=[Try to handle bags correctly for accounts with not 2FA]=]},
})

addChange("6.8.1",{
    {GW.ChangelogType.bug,[=[Fix buff/debuff auto anchor]=]},
    {GW.ChangelogType.bug,[=[Fix buff/debuff max wraps setting]=]},
    {GW.ChangelogType.bug,[=[Fix socket skin lua error]=]},
    {GW.ChangelogType.bug,[=[Fix Pet Tracker integration]=]},

    {GW.ChangelogType.change,[=[Added LibUIDropDownMenu to prevent drop down taints]=]},
    {GW.ChangelogType.change,[=[Added Diablo 4 to friends data info]=]},
    {GW.ChangelogType.change,[=[Update LibEditModeOverride]=]},
})

addChange("6.8.0",{
    {GW.ChangelogType.feature,[=[Added option to adjust player de/buff horizontal and vertical spacing]=]},
    {GW.ChangelogType.feature,[=[Added option to adjust player de/buff max wrap of lines]=]},
    {GW.ChangelogType.feature,[=[Added support for the add PetTracker: Now included at GW2 objectives]=]},
    {GW.ChangelogType.feature,[=[Added evoker bleeding support]=]},

    {GW.ChangelogType.bug,[=[Avoid possible tooltip taint]=]},
    {GW.ChangelogType.bug,[=[Fix casting bar lua error at pvp with an evoker]=]},
    {GW.ChangelogType.bug,[=[Fix rare migration process issue]=]},
    {GW.ChangelogType.bug,[=[Fix M+ dungeon icon border color at the lfg frame]=]},

    {GW.ChangelogType.change,[=[Tweak some hover textures]=]},
    {GW.ChangelogType.change,[=[Cooldown round numbers are more accurate now]=]},
})

addChange("6.7.3",{
    {GW.ChangelogType.bug,[=[Fix friends frame lua error]=]},
    {GW.ChangelogType.bug,[=[Fix encounterjornal taint issue]=]},
})

addChange("6.7.2",{
    {GW.ChangelogType.bug,[=[Fix player frame in target frame style]=]},
    {GW.ChangelogType.bug,[=[Fix immersive questing error]=]},
    {GW.ChangelogType.bug,[=[Fix healtglobe error]=]},
})

addChange("6.7.1",{
    {GW.ChangelogType.bug,[=[Fix hero panel anchor error]=]},
    {GW.ChangelogType.bug,[=[Fix party frame healthtext error]=]},
    {GW.ChangelogType.bug,[=[Fix hero panel item info error]=]},
    {GW.ChangelogType.bug,[=[Fix target castingbar texture]=]},
    {GW.ChangelogType.bug,[=[Fix pet grid error]=]},

    {GW.ChangelogType.change,[=[Handle addon compartment button and add a toggle to hide that button]=]},
})

addChange("6.7.0",{
    {GW.ChangelogType.feature,[=[Added private aura support)]=]},
    {GW.ChangelogType.feature,[=[Redo the statusbars and add custom animations to the classpower and ressource bars]=]},

    {GW.ChangelogType.bug,[=[Added passive talents back to spellbook]=]},
    {GW.ChangelogType.bug,[=[Tweak vignett alerts to not spam]=]},
    {GW.ChangelogType.bug,[=[Fix talent micro button taint error]=]},
    {GW.ChangelogType.bug,[=[Fix bank taint issue]=]},
    {GW.ChangelogType.bug,[=[Fix vigor bar hidding]=]},

    {GW.ChangelogType.change,[=[Update for 10.1]=]},
    {GW.ChangelogType.change,[=[Make achievement frame movable]=]},
    {GW.ChangelogType.change,[=[Update S2 debuffs]=]},
})

addChange("6.6.1",{
    {GW.ChangelogType.bug,[=[Fix rare lua error during open the worldmap with active worldmap skin]=]},
    {GW.ChangelogType.bug,[=[Fix issue were is was impossible to buy bank slots]=]},
    {GW.ChangelogType.bug,[=[Fix macro and gear manager icon selection]=]},

    {GW.ChangelogType.change,[=[Added tooltips to equipment selection mode]=]},
    {GW.ChangelogType.change,[=[GW2 achievement frame skin is now compatible with 'Krowi's Achievement Filter' (requires version 55.0 and higher)]=]},
})

addChange("6.6.0",{
    {GW.ChangelogType.feature,[=[Added 2 new damage text styles: Stacking and Classic (with anchor to nameplats or center of the screen)]=]},
    {GW.ChangelogType.feature,[=[Added option to show healing numbers for these 2 new styles (classic only with anchor to the center of the screen)]=]},

    {GW.ChangelogType.bug,[=[Fix move hud error if the frames gets moved back to it default position]=]},
    {GW.ChangelogType.bug,[=[Fix raid frame summon and resurrection icon]=]},
    {GW.ChangelogType.bug,[=[Fix friends data info tooltip]=]},
    {GW.ChangelogType.bug,[=[Fix worldmap drop-down position]=]},
    {GW.ChangelogType.bug,[=[Fix objectives tracker group finder icon]=]},

    {GW.ChangelogType.change,[=[Changes for 10.0.7]=]},
    {GW.ChangelogType.change,[=[Update spell flyout skin]=]},
})


addChange("6.5.1",{
    {GW.ChangelogType.bug,[=[Fixed memory leak cause by channeling spells]=]},
})

addChange("6.5.0",{
    {GW.ChangelogType.feature,[=[Added option to add a new micromenu icon to show event timers at the tooltip]=]},

    {GW.ChangelogType.bug,[=[Fix copy chat corloring]=]},
    {GW.ChangelogType.bug,[=[Hopefully fix ui flickering]=]},

    {GW.ChangelogType.change,[=[Show micromenu notification also if the micromenu is fade out]=]},
})

addChange("6.4.1",{
    {GW.ChangelogType.bug,[=[Create the GW2_Layout only if it does not exist]=]},
    {GW.ChangelogType.bug,[=[Fix an issue where the default target of target/focus frame is not visible if our target/focus module is turned off]=]},
})

addChange("6.4.0",{
    {GW.ChangelogType.feature,[=[Added Trade Post skin]=]},

    {GW.ChangelogType.change,[=[Restructur settings, to make some settings easier to find]=]},

    {GW.ChangelogType.bug,[=[Talent micro button tooltip is hidding corret now]=]},
    {GW.ChangelogType.bug,[=[Correct monthly activity tracker issues]=]},
    {GW.ChangelogType.bug,[=[Correct recipe tracking issues]=]},
    {GW.ChangelogType.bug,[=[Performance improvements]=]},
})
addChange("6.3.1",{
    {GW.ChangelogType.feature,[=[Added workorder indicator to micromenu]=]},

    {GW.ChangelogType.change,[=[Move "new mail" indicator to micromenu]=]},

    {GW.ChangelogType.bug,[=[Performance improvements]=]},
})
addChange("6.2.2",{
    {GW.ChangelogType.change,[=[Fixes for 10.0.5]=]},
})
addChange("6.2.1",{
    {GW.ChangelogType.bug,[=[Fix ElvUI micro menu error]=]},
    {GW.ChangelogType.bug,[=[Fix ElvUI actionbar lua error if our actionbars are disabled]=]},
    {GW.ChangelogType.bug,[=[Fix ElvUI battle.net frame error if both module are enabled]=]},
})
addChange("6.2.0",{
    {GW.ChangelogType.feature,[=[Dragon Riding HUD background has been added]=]},
    {GW.ChangelogType.feature,[=[Vigor has been moved to the Dodge bar]=]},
    {GW.ChangelogType.feature,[=[Added new achievement skin]=]},
    {GW.ChangelogType.feature,[=[Added new gossip skin]=]},
    {GW.ChangelogType.feature,[=[Added fish nets timers to world map]=]},
    {GW.ChangelogType.feature,[=[Added cooking event timer to scenario tracker]=]},
    {GW.ChangelogType.feature,[=[Added option to show enchants and gems on gw2 character panel]=]},
    {GW.ChangelogType.feature,[=[Added option to flash taskbar on world event reminder]=]},
    {GW.ChangelogType.feature,[=[Added group info to premade group list and group tooltips]=]},

    {GW.ChangelogType.change,[=[Update chat bubbles]=]},
    {GW.ChangelogType.change,[=[Update Move HUD textures]=]},
    {GW.ChangelogType.change,[=[Add filters to Move HUD mode]=]},
    {GW.ChangelogType.change,[=[Added char counter to chat editbox]=]},
    {GW.ChangelogType.change,[=[The info block in Mythic+ dungeons now shows more precise progress information]=]},

    {GW.ChangelogType.bug,[=[Fix ElvUI micro menu backdrop]=]},
    {GW.ChangelogType.bug,[=[Fix Details settings page not opens]=]},
    {GW.ChangelogType.bug,[=[Fix wrong data in fps tooltip]=]},
    {GW.ChangelogType.bug,[=[Fix TomTom mini map icons moves into the addon button container]=]},
    {GW.ChangelogType.bug,[=[Fix compass ignoring settings]=]},
})
addChange("6.1.1",{
    {GW.ChangelogType.change,[=[Aura Indicator updates:

- Evoker:
     Added Dream Breath (echo)
     Added Reversion (echo)
     Added Life Bind]=]},
  {GW.ChangelogType.change,[=[Update Talent Micro Button tooltip]=]},

    {GW.ChangelogType.bug,[=[Fix game freezes with scenario tracker]=]},
    {GW.ChangelogType.bug,[=[Fix actionbar taint on spec switch]=]},
    {GW.ChangelogType.bug,[=[Fix HUD background setting]=]},
    {GW.ChangelogType.bug,[=[Fix HUD border setting]=]},
    {GW.ChangelogType.bug,[=[Fix tooltip hide in combat setting]=]},
    {GW.ChangelogType.bug,[=[Fix tooltip healthbar setting]=]},
})
addChange("6.1.0",{
    {GW.ChangelogType.feature,[=[Added brand new settings page]=]},
    {GW.ChangelogType.feature,[=[Added Community Feast and Siege On Dragonbane Keep timer to worldmap]=]},
    {GW.ChangelogType.feature,[=[Added option to set currencies to unused]=]},
    {GW.ChangelogType.feature,[=[Added option to collapse all objective trackers in Mythic+]=]},
    {GW.ChangelogType.feature,[=[Added evoker buff to raid buff reminder]=]},

    {GW.ChangelogType.change,[=[Aura Indicator updates:

- Resto Druid:
       Added Tranquility
       Added Adaptive Swarm

- Priest:
      Added Power Infusion

- Holy Pally:
       Added Barrier of Faith]=]},
    {GW.ChangelogType.change,[=[Social panel skin has been fixed has been readded]=]},
    {GW.ChangelogType.change,[=[Update Raid Debuff Filter and cleanded up Mythic+ Affixes]=]},
    {GW.ChangelogType.change,[=[Update some raid buff reminder spells]=]},

    {GW.ChangelogType.bug,[=[Fix for auto sell taint error]=]},
    {GW.ChangelogType.bug,[=[Temp fix for extra actionbutton taint]=]},
    {GW.ChangelogType.bug,[=[Memory and performance improvements]=]},
})
addChange("6.0.10",{
    {GW.ChangelogType.bug,[=[Error on start]=]},
})
addChange("6.0.9",{
    {GW.ChangelogType.bug,[=[Restored mirror timers]=]},
})
addChange("6.0.8",{
    {GW.ChangelogType.bug,[=[Fix for memory leak]=]},
})
addChange("6.0.7",{
    {GW.ChangelogType.bug,[=[Error on start]=]},
})
addChange("6.0.6",{
    {GW.ChangelogType.bug,[=[Bank issues]=]},
    {GW.ChangelogType.bug,[=[Error on start]=]}
})
addChange("6.0.5",{
    {GW.ChangelogType.bug,[=[Minimap lua error]=]},
    {GW.ChangelogType.bug,[=[Bag taint]=]}
})
addChange("6.0.4",{
    {GW.ChangelogType.bug,[=[Fix some more taint issues]=]},
})
addChange("6.0.3",{
    {GW.ChangelogType.bug,[=[Wrong GW2 moverframe value]=]}
})
addChange("6.0.2",{
    {GW.ChangelogType.bug,[=[Set actionbar 1 to always have 12 buttons]=]},
    {GW.ChangelogType.bug,[=[Actionbar taint on shapshift forms]=]}
})
addChange("6.0.1",{
    {GW.ChangelogType.bug,[=[Fix lua error on login]=]}
})
addChange("6.0.0",{
    {GW.ChangelogType.feature,[=[Update for 10.0.2]=]}
})
