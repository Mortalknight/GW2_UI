local _, GW = ...
local addChange = GW.addChange

local ct = {
  bug = 1,
  feature = 2,
  change = 3,
}
GW.CHANGELOGS_TYPES = ct
--[[
AddChange(string addonVersion, table changeList)
  {
   GW_CHANGELOGS_TYPES fixType // bugfix, feature
   string description
  }
]]

addChange("8.2.4",{
    {ct.bug, [=[Fix warbank itemlevel (retail)]=]},
    {ct.change, [=[Hide multibars during pet battle (mists)]=]},
    {ct.change, [=[Fix target health % values]=]},
    {ct.change, [=[Fix combopoints on target]=]},
    {ct.change, [=[Fix minimap instance difficult indicator (retail)]=]},
    {ct.change, [=[Fix actionbar coloring (mists)]=]},
    {ct.change, [=[Fix title filter error (retail)]=]},
})

addChange("8.2.3",{
    {ct.bug, [=[Loading error]=]},
    {ct.change, [=[Add more options to player de/buff settings]=]},
})

addChange("8.2.2",{
    {ct.bug, [=[Bagnator skin error (Mists)]=]},
    {ct.bug, [=[Objectives tracker actionbutton error (Era)]=]},
})

addChange("8.2.1",{
    {ct.bug, [=[Arena frame lua error (Mists)]=]},
})

addChange("8.2.0",{
    {ct.feature, [=[Add option to hide absorb bar on all unitframes]=]},
})

addChange("8.1.9",{
    {ct.bug, [=[Scenario error (retail)]=]},
    {ct.bug, [=[Bag sorting (Mists & Era)]=]},
})

addChange("8.1.8",{
    {ct.bug, [=[Bag opening lag]=]},
    {ct.bug, [=[Wrong tooltip faction (Retail)]=]},
    {ct.bug, [=[Friendstooltip show correct game now]=]},
    {ct.bug, [=[Spellbook tweaks (Mists)]=]},
})

addChange("8.1.7",{
    {ct.bug, [=[Shadow prist orbs (mists)]=]},
    {ct.bug, [=[DK runes (mists)]=]},
    {ct.bug, [=[Unitframe absorb amounts (mists)]=]},
})

addChange("8.1.6",{
    {ct.bug, [=[Next round of Mists fixes]=]},
})

addChange("8.1.5",{
    {ct.change, [=[Added temp chi bg texture]=]},
})

addChange("8.1.4",{
    {ct.bug, [=[Next round of Mists fixes]=]},
})

addChange("8.1.3",{
    {ct.bug, [=[Fix issue with 8.1.2]=]},
})

addChange("8.1.2",{
    {ct.bug, [=[More Mists adjustments]=]},
})

addChange("8.1.1",{
    {ct.bug, [=[More Mists adjustments]=]},
})

addChange("8.1.0",{
    {ct.bug, [=[Mists support]=]},
})

addChange("8.0.7",{
    {ct.bug, [=[Fix collection tracking collapse (retail)]=]},
})

addChange("8.0.6",{
    {ct.bug, [=[Some more fixes for all versions]=]},
})

addChange("8.0.5",{
    {ct.bug, [=[Fix target level color (era & cata)]=]},
    {ct.bug, [=[Fix unit level at tooltip (era)]=]},
    {ct.bug, [=[Fix aura tooltip (era & cata)]=]},
    {ct.bug, [=[Fix mirror timer (era & cata)]=]},
    {ct.bug, [=[Fix objectives tooltip (era & cata)]=]},
    {ct.bug, [=[Fix copying profiles)]=]},
})

addChange("8.0.4",{
    {ct.bug, [=[Fix microbar moving (cata)]=]},
    {ct.bug, [=[Readd spellbook and talent setting (cata)]=]},
    {ct.bug, [=[Fix skyridingbar (retail)]=]},
})

addChange("8.0.3",{
    {ct.bug, [=[Fix eclips bar on era]=]},
    {ct.bug, [=[Fix micromenu moving on era and cata]=]},
})

addChange("8.0.2",{
    {ct.bug, [=[Combopoint error for era and cata]=]},
})

addChange("8.0.1",{
    {ct.feature, [=[Merged Retail, Era and Cata version]=]},
})

addChange("7.15.0",{
    {ct.feature, [=[Added more option to unitframe fader]=]},
    {ct.feature, [=[Added option to extend player powerbar hight (player unitframe)]=]},
    {ct.change, [=[Add required settings to settings tooltip]=]},
    {ct.bug, [=[RFix Pawn integration]=]},
})

addChange("7.14.1",{
    {ct.bug, [=[Fix settings lua error]=]},
})

addChange("7.14.0",{
    {ct.feature, [=[Added unitframe fader options to all unitframes]=]},
    {ct.bug, [=[Raidlock error]=]},
    {ct.bug, [=[Fix buff reminder]=]},
    {ct.bug, [=[Fix pawn integration]=]},
})

addChange("7.13.2",{
    {ct.bug, [=[Fix issue with 7.13.1]=]},
})

addChange("7.13.1",{
    {ct.bug, [=[Hero panel opens for enchants]=]},
    {ct.bug, [=[Weapon enchants should now show correclty]=]},
    {ct.bug, [=[Fix Pawn integration]=]},
    {ct.bug, [=[Raid lock lua error]=]},
    {ct.change, [=[Redo reputation frame, should load and react faster]=]},
    {ct.change, [=[Add radio button texture]=]},
    {ct.change, [=[Added Nightfall to objectives tracker]=]},
    {ct.change, [=[Update some skins]=]},
    {ct.change, [=[Added 3 new widget mover to move hud mode]=]},
    {ct.change, [=[Added some animations]=]},
})

addChange("7.13.0",{
    {ct.feature, [=[Cooldown Manager skin]=]},
    {ct.feature, [=[Add paragon indicator to reputation category list]=]},
    {ct.bug, [=[PetTracker integration now work as expected]=]},
    {ct.bug, [=[WQT integration now work as expected]=]},
    {ct.bug, [=[Error when entering delves]=]},
    {ct.change, [=[Rewritten objectives tracker, should perform much better now]=]},
    {ct.change, [=[Better CLEU handling with sharing over the addon]=]},
    {ct.change, [=[Much more optimization over all modules of the addon]=]},
})

addChange("7.12.1",{
    {ct.change, [=[Skin tweaks]=]},
    {ct.bug, [=[Fix profile lua error]=]},
    {ct.bug, [=[Fix FCT lua error]=]},
    {ct.bug, [=[Castbar channel ticks]=]},
    {ct.bug, [=[Target frame debuff settings are working again]=]},
})

addChange("7.12.0",{
    {ct.bug, [=[Update for 11.1.0]=]},
})

addChange("7.11.1",{
    {ct.bug, [=[Fix actionbar taint]=]},
})

addChange("7.11.0",{
    {ct.feature, [=[dded option to hide target item level display]=]},
    {ct.feature, [=[Added option to show Singing Socket gems]=]},
    {ct.change, [=[Update auctionator skin]=]},
    {ct.bug, [=[Repuration error]=]},
    {ct.bug, [=[Notification tooltip]=]},
    {ct.bug, [=[Fix inverted statusbar]=]},
    {ct.bug, [=[Party frame auras can stuck sometimes]=]},
})

addChange("7.10.0",{
    {ct.feature, [=[Added Talking Head Scaler]=]},
    {ct.feature, [=[Target/Focus frame bars no inverted in inverted mode]=]},
    {ct.change, [=[Optimize aura handling for all unitframes]=]},
    {ct.change, [=[Optimize Healthbar and Powerbar handling]=]},
    {ct.bug, [=[Fix PetTracker loading]=]},
})

addChange("7.9.3",{
    {ct.change, [=[Remove CUSTOM_CLASS_COLOR support and cahnge it to GW2 Class colors]=]},
    {ct.change, [=[Add option to set number format]=]},
})

addChange("7.9.2",{
    {ct.change, [=[TRP3 chat support]=]},
})

addChange("7.9.1",{
    {ct.change, [=[TRP3 chat support]=]},
})

addChange("7.9.0",{
    {ct.feature, [=[Added grid out of range alpha value setting]=]},
    {ct.feature, [=[Added custom class color support]=]},
    {ct.change, [=[Update more dropdowns]=]},
    {ct.change, [=[Use local number delimiter]=]},
    {ct.change, [=[11.0.7 changes]=]},
    {ct.bug, [=[Fix PetTracker integration]=]},
    {ct.bug, [=[Fix Blizzard mirror timer not shown]=]},
    {ct.bug, [=[Setting search works again]=]},
})

addChange("7.8.0",{
    {ct.feature, [=[Add option to hook profiles to a spec. This will switch the profile on spec switch]=]},
    {ct.feature, [=[Add todoloo support for GW2 Objectives tracker]=]},
    {ct.feature, [=[Add searchbox for player titles]=]},
    {ct.feature, [=[Add slash command to clear tracked but already earned achievements (blizzard bug): /gw2 clear achievements]=]},
    {ct.feature, [=[Add option to change profile icons]=]},
    {ct.feature, [=[Add TRP3 support for GW2 chatbubbles]=]},
    {ct.change, [=[Added fraction icons to the guild datatext]=]},
    {ct.change, [=[Change all dropdown elements to new blizzard ui system]=]},
    {ct.change, [=[Allow max 4 watched tokens with gw2 bags enabled]=]},
    {ct.bug, [=[Objectives tracker bonus step names]=]},
    {ct.bug, [=[Achievement skin scroll height]=]},
    {ct.bug, [=[Grid aura indicators now only shows player auras]=]},
    {ct.bug, [=[Fix dodgebar for some classes]=]},
    {ct.bug, [=[Fix objectives tracker loading order]=]},
})

addChange("7.7.2",{
    {ct.bug, [=[Guild data info lua error]=]},
    {ct.change, [=[Skin updates]=]},
    {ct.change, [=[Guild data info text]=]},
    {ct.change, [=[Stackcount setting]=]},
})

addChange("7.7.1",{
    {ct.change, [=[Add Dracthyr fraction to tooltip]=]},
    {ct.change, [=[Add stackcount to tooltip]=]},
    {ct.change, [=[Changes for 11.0.5]=]},
})

addChange("7.7.0",{
    {ct.feature, [=[Option to copy a single chat line]=]},
    {ct.feature, [=[Option to show chat history]=]},
    {ct.feature, [=[Option to show channel ticks on castbar]=]},
    {ct.feature, [=[Option to control the grid name update frequence to save some fps]=]},
    {ct.feature, [=[Add mastery buff to raid buff reminder]=]},
    {ct.change, [=[Jailers tower error]=]},
    {ct.change, [=[Social frame lua error]=]},
    {ct.change, [=[Player castbar sometimes stuck on screen]=]},
    {ct.change, [=[Update some skins]=]},
    {ct.change, [=[Add warband reputation indicator]=]},
})

addChange("7.6.0",{
    {ct.feature, [=[Add option to shorten healtglobe shield values]=]},
    {ct.feature, [=[Add option to hide player frame at party grid]=]},
    {ct.feature, [=[Add option to hide class icons at grids, if no class color is used]=]},
    {ct.bug, [=[Fix drawn layer of lfg accept button]=]},
    {ct.bug, [=[Fix BigWigs integration]=]},
    {ct.change, [=[Add Monk hero talent to dodgebar]=]},
    {ct.change, [=[Added theater event timer bar to objectives tracker]=]},
    {ct.change, [=[Update some skins]=]},
})

addChange("7.5.0",{
    {ct.feature, [=[Add option to shorten values, like health values or damage text]=]},
    {ct.bug, [=[Fix new font settings]=]},
    {ct.bug, [=[fix LSM with new fonts]=]},
})

addChange("7.4.0",{
    {ct.feature, [=[New Font system
        - You can now select between multiple different font styles
        - You can select your own fonts for texts and header texts
        - You can adjust the font size for: Big Headers, Header, Normal and Small texts

        - To select the font like before this update, use 'GW2 Legacy']=]},
    {ct.feature, [=[Tooltips gets font size option for all 3 types]=]},
    {ct.feature, [=[Added TWW events to the event tracker]=]},
    {ct.feature, [=[Added auction house skin]=]},
    {ct.feature, [=[Added fx animation to the dynamic hud (not all classes yet)]=]},
    {ct.feature, [=[Added remaning live to delve tracker]=]},
    {ct.feature, [=[Find an small easter agg with the GW2 settings splash screen]=]},
    {ct.change, [=[Add DK hero talent to dodgebar]=]},
    {ct.change, [=[Update some textures]=]},
    {ct.change, [=[Update some skins]=]},
    {ct.bug, [=[Fix barber shop skin]=]},
})

addChange("7.3.0",{
    {ct.feature, [=[Delves support for objectives tracker]=]},
    {ct.feature, [=[Added group progress to objectives tooltip]=]},
    {ct.change, [=[Update some skins]=]},
    {ct.bug, [=[Objectives tracker auto turn in quests]=]},
    {ct.bug, [=[Totem tracker should work again]=]},
})

addChange("7.2.0",{
    {ct.feature, [=[Talent frame skin]=]},
    {ct.feature, [=[Tooltip Item Count now has options Include Reagents and Include Warband]=]},
    {ct.feature, [=[Keybind support for immersive questing]=]},
    {ct.feature, [=[Keybind support for gossip skin]=]},
    {ct.feature, [=[Stancebar can now be disabled]=]},
    {ct.feature, [=[DK runes now get sorted based on there progress]=]},
    {ct.feature, [=[Add timer to tracked achievements]=]},
    {ct.feature, [=[New immersive questing backgrounds for TWW]=]},
    {ct.change, [=[Chat frame alert color is now saved per character]=]},
    {ct.change, [=[Update some skins]=]},
    {ct.change, [=[Update imported debuffs]=]},
    {ct.bug, [=[EJ skin error]=]},
    {ct.bug, [=[Raid frame ignored auras works again]=]},
    {ct.bug, [=[Fix GW2_Layout creation process]=]},
})

addChange("7.1.0",{
    {ct.feature, [=[Added option to skin blizzards default actionbars
        That function disabled our managed actionbars and there hooked features]=]},
    {ct.feature, [=[Adventuremap skin]=]},
    {ct.bug, [=[Objectives tracker actionbutton works again]=]},
    {ct.bug, [=[Error handler shows only GW2 errors]=]},
    {ct.bug, [=[M+ progess counter should show correect % again (raw value is not possible atm)]=]},
    {ct.bug, [=[Fix minimap lua error]=]},
    {ct.change, [=[Added TRP3 tooltips support]=]},
    {ct.change, [=[Immersive Question changes and improvements]=]},
})

addChange("7.0.2",{
    {ct.change, [=[Added self reading animation to immersive questing]=]},
    {ct.bug, [=[Fix error handler]=]},
    {ct.bug, [=[Fix objective tracker action button handling]=]},
    {ct.bug, [=[Fix event objectives click functions]=]},
    {ct.bug, [=[Fix currency transfer taint error]=]},
    {ct.bug, [=[Fix ouf range indicator]=]},
})

addChange("7.0.1",{
    {ct.bug, [=[First round of fixes]=]},
})

addChange("7.0.0",{
    {ct.change, [=[Update for TWW]=]},
})

addChange("6.14.10",{
    {ct.bug, [=[Show character item info now works correctly]=]},
    {ct.change, [=[Export some api]=]},
})

addChange("6.14.9",{
    {ct.change, [=[Export some api]=]},
})

addChange("6.14.8",{
    {ct.change, [=[Update toc]=]},
})

addChange("6.14.7",{
    {ct.change, [=[Prepare for 10.2.7]=]},
})

addChange("6.14.6",{
    {ct.bug, [=[Fix GW2 slash commands]=]},
    {ct.bug, [=[Fix merchant frame next/prev page button position]=]},
    {ct.bug, [=[Fix lua error if our minimap is disableds]=]},
    {ct.bug, [=[Fix character itemlevel was not shown]=]},
})

addChange("6.14.5",{
    {ct.bug, [=[Party frame visibility]=]},
})

addChange("6.14.4",{
    {ct.bug, [=[Tooltip M+ lua error]=]},
})

addChange("6.14.3",{
    {ct.bug, [=[Party visibility]=]},
})

addChange("6.14.2",{
    {ct.change, [=[Update for 10.2.6]=]},
})

addChange("6.14.1",{
    {ct.bug, [=[Fix details profile]=]},
    {ct.bug, [=[Fix player debuff show wrong icon texture]=]},
    {ct.bug, [=[Fix gossip skin text height]=]},
    {ct.bug, [=[Fix small unitframe height]=]},
    {ct.bug, [=[Fix ToT mover]=]},
    {ct.bug, [=[Fix playerframe level up icon]=]},
    {ct.bug, [=[Fix objectiv tracker hover not showing all details]=]},
    {ct.bug, [=[Fix creating new profile]=]},

    {ct.change, [=[Update merchant skin]=]},
    {ct.change, [=[Change castbar mover frame beased on details option]=]},
    {ct.change, [=[Added Masque actionbutton skin]=]},
})

addChange("6.14.0", {
    {ct.feature, [=[Added Big Dig event timer]=]},
    {ct.feature, [=[Added option to change pulltimer seconds]=]},

    {ct.bug, [=[Raidframes name overlapping]=]},
    {ct.bug, [=[Chat install process]=]},
    {ct.bug, [=[Alt player background setting]=]},
    {ct.bug, [=[Colorpicker error]=]},
})

addChange("6.13.3",{
    {ct.bug, [=[Remove print statement]=]},
})

addChange("6.13.2",{
    {ct.bug, [=[Fix profile page error]=]},
    {ct.bug, [=[Fix db migration error]=]},
    {ct.bug, [=[Handle evoker soar correct]=]},
})

addChange("6.13.1",{
    {ct.bug, [=[Fix error a profile rename]=]},
})

addChange("6.13.0",{
    {ct.feature, [=[Switch to a new database format to better handle profiles. That requires a reload after the first login on each character.]=]},
    {ct.feature, [=[Added right click function to the minimaps expansion icon to show also the landing pages from previous addons]=]},
    {ct.feature, [=[Added animated statusbars to the pet frame]=]},
    {ct.feature, [=[Added copy/paste function to colorpicker]=]},
    {ct.feature, [=[Added option to disable objectives statusbars to have a more compact objectives tracker]=]},

    {ct.change, [=[Some more settings does not requires a reload]=]},

    {ct.bug, [=[Fix stancebar error. You can now use the button in combat again]=]},
    {ct.bug, [=[Fix worldmap event tracker container size]=]},
    {ct.bug, [=[Fix tank frame middle icon]=]},
    {ct.bug, [=[Fix auraindicators updating]=]},
    {ct.bug, [=[GW2 setting window is now moveable]=]},
})


addChange("6.12.0",{
    {ct.feature, [=[Added new paladin classpower texture and animation]=]},
    {ct.feature, [=[Added new arms warrior classpower]=]},
    {ct.feature, [=[Update GW2 boss frames, they are now unitframes]=]},
    {ct.feature, [=[Added options to toggle grid rol icons, tank icons and leader icons]=]},

    {ct.change, [=[Adjust grid out of range alpha value]=]},
    {ct.change, [=[Update grid to work again with OmniCD]=]},

    {ct.bug, [=[Fix PP mode get saved correctly]=]},
    {ct.bug, [=[Fix move HUD grid]=]},
    {ct.bug, [=[Fix immersive Questing taint issue]=]},
    {ct.bug, [=[Fix arena frame lua errors]=]},
    {ct.bug, [=[Fix classpower error in combat]=]},
})

addChange("6.11.1",{
    {ct.bug,[=[Correct LEMO integration which was causing an lua error during installation process]=]},
    {ct.bug,[=[Tweak Event Timer height]=]},
})

addChange("6.11.0",{
    {ct.feature, [=[Redo all grids: Party, Raid, Raid Pet]=]},
    {ct.feature, [=[Grids are now secure and can update during combat]=]},
    {ct.feature, [=[Added new grids:
        - Maintank
        - Raid 10
        - Raid 25
        - Raid 40]=]},
    {ct.feature, [=[Raid grids switch automaticly between the 3 raid grids, based on the number of players at the raid]=]},
    {ct.feature, [=[Added new grouping and sorting settings to all grids:
        - Group by: Role, Class, Group, Name, Index
        - Sort direction
        - Sortmethode: Name, Index
        - Raidwaid sorting: If disabled the grouping and sorting settings are applyed per raid group]=]},
    {ct.feature, [=[All grids have there individual settings (Raid 10, Raid 25, Raid 40, Maintank, Raid Pet, Group)]=]},
    {ct.feature, [=[Added Superbloom event timer to worldmap]=]},
    {ct.feature, [=[Added options to change the worldmap coordinats lable]=]},
    {ct.feature, [=[Added option to hide classpower bar outside of combat]=]},

    {ct.change, [=[Update for 10.2.0]=]},
    {ct.change, [=[Update RAF skin]=]},
    {ct.change, [=[Update Time Manager skin]=]},
    {ct.change, [=[Added back right click option on bags]=]},
    {ct.change, [=[Added S3 raid debuffs]=]},
    {ct.change, [=[Adjust damage text animations]=]},
    {ct.change, [=[Update TaintLess]=]},

    {ct.bug, [=[Fix ready check skin]=]},
    {ct.bug, [=[Fix blurr on raid warning font]=]},
    {ct.bug, [=[Fix Pet Tracker and WQT Anchor points]=]},
    {ct.bug, [=[Fix travler log header stucking after tracking activity is completed]=]},
    {ct.bug, [=[Fix some taints]=]},
})

addChange("6.10.1",{
    {ct.bug,[=[10.1.7 fixes]=]},
})

addChange("6.10.0",{
    {ct.bug,[=[Added evoker ebon might bar]=]},
})

addChange("6.9.2",{
    {ct.bug,[=[Fix an actionbars issue which can crash the client]=]},
})

addChange("6.9.1",{
    {ct.bug,[=[More 10.1.5 related fixes]=]},
})

addChange("6.9.0",{
    {ct.feature,[=[Added font settings for GW2 floating combat text]=]},
    {ct.change,[=[Update for 10.1.5]=]},
})

addChange("6.8.2",{
    {ct.bug,[=[Fix druid little manabar in cat form with player frame in target frame style]=]},
    {ct.bug,[=[Try to handle bags correctly for accounts with not 2FA]=]},
})

addChange("6.8.1",{
    {ct.bug,[=[Fix buff/debuff auto anchor]=]},
    {ct.bug,[=[Fix buff/debuff max wraps setting]=]},
    {ct.bug,[=[Fix socket skin lua error]=]},
    {ct.bug,[=[Fix Pet Tracker integration]=]},

    {ct.change,[=[Added LibUIDropDownMenu to prevent drop down taints]=]},
    {ct.change,[=[Added Diablo 4 to friends data info]=]},
    {ct.change,[=[Update LibEditModeOverride]=]},
})

addChange("6.8.0",{
    {ct.feature,[=[Added option to adjust player de/buff horizontal and vertical spacing]=]},
    {ct.feature,[=[Added option to adjust player de/buff max wrap of lines]=]},
    {ct.feature,[=[Added support for the add PetTracker: Now included at GW2 objectives]=]},
    {ct.feature,[=[Added evoker bleeding support]=]},

    {ct.bug,[=[Avoid possible tooltip taint]=]},
    {ct.bug,[=[Fix casting bar lua error at pvp with an evoker]=]},
    {ct.bug,[=[Fix rare migration process issue]=]},
    {ct.bug,[=[Fix M+ dungeon icon border color at the lfg frame]=]},

    {ct.change,[=[Tweak some hover textures]=]},
    {ct.change,[=[Cooldown round numbers are more accurate now]=]},
})

addChange("6.7.3",{
    {ct.bug,[=[Fix friends frame lua error]=]},
    {ct.bug,[=[Fix encounterjornal taint issue]=]},
})

addChange("6.7.2",{
    {ct.bug,[=[Fix player frame in target frame style]=]},
    {ct.bug,[=[Fix immersive questing error]=]},
    {ct.bug,[=[Fix healtglobe error]=]},
})

addChange("6.7.1",{
    {ct.bug,[=[Fix hero panel anchor error]=]},
    {ct.bug,[=[Fix party frame healthtext error]=]},
    {ct.bug,[=[Fix hero panel item info error]=]},
    {ct.bug,[=[Fix target castingbar texture]=]},
    {ct.bug,[=[Fix pet grid error]=]},

    {ct.change,[=[Handle addon compartment button and add a toggle to hide that button]=]},
})

addChange("6.7.0",{
    {ct.feature,[=[Added private aura support)]=]},
    {ct.feature,[=[Redo the statusbars and add custom animations to the classpower and ressource bars]=]},

    {ct.bug,[=[Added passive talents back to spellbook]=]},
    {ct.bug,[=[Tweak vignett alerts to not spam]=]},
    {ct.bug,[=[Fix talent micro button taint error]=]},
    {ct.bug,[=[Fix bank taint issue]=]},
    {ct.bug,[=[Fix vigor bar hidding]=]},

    {ct.change,[=[Update for 10.1]=]},
    {ct.change,[=[Make achievement frame movable]=]},
    {ct.change,[=[Update S2 debuffs]=]},
})

addChange("6.6.1",{
    {ct.bug,[=[Fix rare lua error during open the worldmap with active worldmap skin]=]},
    {ct.bug,[=[Fix issue were is was impossible to buy bank slots]=]},
    {ct.bug,[=[Fix macro and gear manager icon selection]=]},

    {ct.change,[=[Added tooltips to equipment selection mode]=]},
    {ct.change,[=[GW2 achievement frame skin is now compatible with 'Krowi's Achievement Filter' (requires version 55.0 and higher)]=]},
})

addChange("6.6.0",{
    {ct.feature,[=[Added 2 new damage text styles: Stacking and Classic (with anchor to nameplats or center of the screen)]=]},
    {ct.feature,[=[Added option to show healing numbers for these 2 new styles (classic only with anchor to the center of the screen)]=]},

    {ct.bug,[=[Fix move hud error if the frames gets moved back to it default position]=]},
    {ct.bug,[=[Fix raid frame summon and resurrection icon]=]},
    {ct.bug,[=[Fix friends data info tooltip]=]},
    {ct.bug,[=[Fix worldmap drop-down position]=]},
    {ct.bug,[=[Fix objectives tracker group finder icon]=]},

    {ct.change,[=[Changes for 10.0.7]=]},
    {ct.change,[=[Update spell flyout skin]=]},
})


addChange("6.5.1",{
    {ct.bug,[=[Fixed memory leak cause by channeling spells]=]},
})

addChange("6.5.0",{
    {ct.feature,[=[Added option to add a new micromenu icon to show event timers at the tooltip]=]},

    {ct.bug,[=[Fix copy chat corloring]=]},
    {ct.bug,[=[Hopefully fix ui flickering]=]},

    {ct.change,[=[Show micromenu notification also if the micromenu is fade out]=]},
})

addChange("6.4.1",{
    {ct.bug,[=[Create the GW2_Layout only if it does not exist]=]},
    {ct.bug,[=[Fix an issue where the default target of target/focus frame is not visible if our target/focus module is turned off]=]},
})

addChange("6.4.0",{
    {ct.feature,[=[Added Trade Post skin]=]},

    {ct.change,[=[Restructur settings, to make some settings easier to find]=]},

    {ct.bug,[=[Talent micro button tooltip is hidding corret now]=]},
    {ct.bug,[=[Correct monthly activity tracker issues]=]},
    {ct.bug,[=[Correct recipe tracking issues]=]},
    {ct.bug,[=[Performance improvements]=]},
})
addChange("6.3.1",{
    {ct.feature,[=[Added workorder indicator to micromenu]=]},

    {ct.change,[=[Move "new mail" indicator to micromenu]=]},

    {ct.bug,[=[Performance improvements]=]},
})
addChange("6.2.2",{
    {ct.change,[=[Fixes for 10.0.5]=]},
})
addChange("6.2.1",{
    {ct.bug,[=[Fix ElvUI micro menu error]=]},
    {ct.bug,[=[Fix ElvUI actionbar lua error if our actionbars are disabled]=]},
    {ct.bug,[=[Fix ElvUI battle.net frame error if both module are enabled]=]},
})
addChange("6.2.0",{
    {ct.feature,[=[Dragon Riding HUD background has been added]=]},
    {ct.feature,[=[Vigor has been moved to the Dodge bar]=]},
    {ct.feature,[=[Added new achievement skin]=]},
    {ct.feature,[=[Added new gossip skin]=]},
    {ct.feature,[=[Added fish nets timers to world map]=]},
    {ct.feature,[=[Added cooking event timer to scenario tracker]=]},
    {ct.feature,[=[Added option to show enchants and gems on gw2 character panel]=]},
    {ct.feature,[=[Added option to flash taskbar on world event reminder]=]},
    {ct.feature,[=[Added group info to premade group list and group tooltips]=]},

    {ct.change,[=[Update chat bubbles]=]},
    {ct.change,[=[Update Move HUD textures]=]},
    {ct.change,[=[Add filters to Move HUD mode]=]},
    {ct.change,[=[Added char counter to chat editbox]=]},
    {ct.change,[=[The info block in Mythic+ dungeons now shows more precise progress information]=]},

    {ct.bug,[=[Fix ElvUI micro menu backdrop]=]},
    {ct.bug,[=[Fix Details settings page not opens]=]},
    {ct.bug,[=[Fix wrong data in fps tooltip]=]},
    {ct.bug,[=[Fix TomTom mini map icons moves into the addon button container]=]},
    {ct.bug,[=[Fix compass ignoring settings]=]},
})
addChange("6.1.1",{
    {ct.change,[=[Aura Indicator updates:

- Evoker:
     Added Dream Breath (echo)
     Added Reversion (echo)
     Added Life Bind]=]},
  {ct.change,[=[Update Talent Micro Button tooltip]=]},

    {ct.bug,[=[Fix game freezes with scenario tracker]=]},
    {ct.bug,[=[Fix actionbar taint on spec switch]=]},
    {ct.bug,[=[Fix HUD background setting]=]},
    {ct.bug,[=[Fix HUD border setting]=]},
    {ct.bug,[=[Fix tooltip hide in combat setting]=]},
    {ct.bug,[=[Fix tooltip healthbar setting]=]},
})
addChange("6.1.0",{
    {ct.feature,[=[Added brand new settings page]=]},
    {ct.feature,[=[Added Community Feast and Siege On Dragonbane Keep timer to worldmap]=]},
    {ct.feature,[=[Added option to set currencies to unused]=]},
    {ct.feature,[=[Added option to collapse all objective trackers in Mythic+]=]},
    {ct.feature,[=[Added evoker buff to raid buff reminder]=]},

    {ct.change,[=[Aura Indicator updates:

- Resto Druid:
       Added Tranquility
       Added Adaptive Swarm

- Priest:
      Added Power Infusion

- Holy Pally:
       Added Barrier of Faith]=]},
    {ct.change,[=[Social panel skin has been fixed has been readded]=]},
    {ct.change,[=[Update Raid Debuff Filter and cleanded up Mythic+ Affixes]=]},
    {ct.change,[=[Update some raid buff reminder spells]=]},

    {ct.bug,[=[Fix for auto sell taint error]=]},
    {ct.bug,[=[Temp fix for extra actionbutton taint]=]},
    {ct.bug,[=[Memory and performance improvements]=]},
})
addChange("6.0.10",{
    {ct.bug,[=[Error on start]=]},
})
addChange("6.0.9",{
    {ct.bug,[=[Restored mirror timers]=]},
})
addChange("6.0.8",{
    {ct.bug,[=[Fix for memory leak]=]},
})
addChange("6.0.7",{
    {ct.bug,[=[Error on start]=]},
})
addChange("6.0.6",{
    {ct.bug,[=[Bank issues]=]},
    {ct.bug,[=[Error on start]=]}
})
addChange("6.0.5",{
    {ct.bug,[=[Minimap lua error]=]},
    {ct.bug,[=[Bag taint]=]}
})
addChange("6.0.4",{
    {ct.bug,[=[Fix some more taint issues]=]},
})
addChange("6.0.3",{
    {ct.bug,[=[Wrong GW2 moverframe value]=]}
})
addChange("6.0.2",{
    {ct.bug,[=[Set actionbar 1 to always have 12 buttons]=]},
    {ct.bug,[=[Actionbar taint on shapshift forms]=]}
})
addChange("6.0.1",{
    {ct.bug,[=[Fix lua error on login]=]}
})
addChange("6.0.0",{
    {ct.feature,[=[Update for 10.0.2]=]}
})
