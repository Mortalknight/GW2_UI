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
    {ct.bug, [=[ix auraindicators updating]=]},
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
