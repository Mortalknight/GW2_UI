local _, GW = ...
GW.DEFAULTS = GW.DEFAULTS or {}
GW.DEFAULTS.RAIDDEBUFFS = {}
GW.ImportendRaidDebuff = {}

local function RemoveOldRaidDebuffsFormProfiles()
    local profiles = GW2UI_SETTINGS_PROFILES or {}
    for k, _ in pairs(profiles) do
        if profiles[k] then
            if profiles[k].RAIDDEBUFFS then
                for id, _ in pairs(profiles[k].RAIDDEBUFFS) do
                    if GW.DEFAULTS.RAIDDEBUFFS[id] == nil then
                        GW2UI_SETTINGS_PROFILES[k].RAIDDEBUFFS[id] = nil
                    end
                end
            end
        end
    end
end
GW.RemoveOldRaidDebuffsFormProfiles = RemoveOldRaidDebuffsFormProfiles

local function SetDefaultOnTheFly(id)
    GW.DEFAULTS.RAIDDEBUFFS[id] = true
    GW.ImportendRaidDebuff[id] = true
end

-------------------------------------------------
-------------------- Dungeons -------------------
-------------------------------------------------
-- Blackrock Caverns
-- Throne of the Tides
-- The Stonecore
-- The Vortex Pinnacle
-- Grim Batol
-- Halls of Origination
-- Deadmines
-- Shadowfang Keep
-- Lost City of the Tol'vir
-------------------------------------------------
-------------------- Phase 1 --------------------
-------------------------------------------------
-- Baradin Hold
SetDefaultOnTheFly(95173)	-- Consuming Darkness
SetDefaultOnTheFly(96913)	-- Searing Shadows
SetDefaultOnTheFly(104936)	-- Skewer
SetDefaultOnTheFly(105067)	-- Seething Hate
-- Blackwing Descent
SetDefaultOnTheFly(91911)	-- Constricting Chains
SetDefaultOnTheFly(94679)	-- Parasitic Infection
SetDefaultOnTheFly(94617)	-- Mangle
SetDefaultOnTheFly(78199)	-- Sweltering Armor
SetDefaultOnTheFly(91433)	-- Lightning Conductor
SetDefaultOnTheFly(91521)	-- Incineration Security Measure
SetDefaultOnTheFly(80094)	-- Fixate
SetDefaultOnTheFly(91535)	-- Flamethrower
SetDefaultOnTheFly(80161)	-- Chemical Cloud
SetDefaultOnTheFly(92035)	-- Acquiring Target
SetDefaultOnTheFly(79835)	-- Poison Soaked Shell
SetDefaultOnTheFly(91555)	-- Power Generator
SetDefaultOnTheFly(92048)	-- Shadow Infusion
SetDefaultOnTheFly(92053)	-- Shadow Conductor
SetDefaultOnTheFly(77699)	-- Flash Freeze
SetDefaultOnTheFly(77760)	-- Biting Chill
SetDefaultOnTheFly(92754)	-- Engulfing Darkness
SetDefaultOnTheFly(92971)	-- Consuming Flames
SetDefaultOnTheFly(92989)	-- Rend
SetDefaultOnTheFly(92423)	-- Searing Flame
SetDefaultOnTheFly(92485)	-- Roaring Flame
SetDefaultOnTheFly(92407)	-- Sonic Breath
SetDefaultOnTheFly(78092)	-- Tracking
SetDefaultOnTheFly(82881)	-- Break
SetDefaultOnTheFly(89084)	-- Low Health
SetDefaultOnTheFly(81114)	-- Magma
SetDefaultOnTheFly(94128)	-- Tail Lash
SetDefaultOnTheFly(79339)	-- Explosive Cinders
SetDefaultOnTheFly(79318)	-- Dominion
-- The Bastion of Twilight
SetDefaultOnTheFly(39171)	-- Malevolent Strikes
SetDefaultOnTheFly(83710)	-- Furious Roar
SetDefaultOnTheFly(92878)	-- Blackout
SetDefaultOnTheFly(86840)	-- Devouring Flames
SetDefaultOnTheFly(95639)	-- Engulfing Magic
SetDefaultOnTheFly(92886)	-- Twilight Zone
SetDefaultOnTheFly(88518)	-- Twilight Meteorite
SetDefaultOnTheFly(86505)	-- Fabulous Flames
SetDefaultOnTheFly(93051)	-- Twilight Shift
SetDefaultOnTheFly(92511)	-- Hydro Lance
SetDefaultOnTheFly(82762)	-- Waterlogged
SetDefaultOnTheFly(92505)	-- Frozen
SetDefaultOnTheFly(92518)	-- Flame Torrent
SetDefaultOnTheFly(83099)	-- Lightning Rod
SetDefaultOnTheFly(92075)	-- Gravity Core
SetDefaultOnTheFly(92488)	-- Gravity Crush
SetDefaultOnTheFly(82660)	-- Burning Blood
SetDefaultOnTheFly(82665)	-- Heart of Ice
SetDefaultOnTheFly(83500)	-- Swirling Winds
SetDefaultOnTheFly(83581)	-- Grounded
SetDefaultOnTheFly(92067)	-- Static Overload
SetDefaultOnTheFly(86028)	-- Cho's Blast
SetDefaultOnTheFly(86029)	-- Gall's Blast
SetDefaultOnTheFly(93187)	-- Corrupted Blood
SetDefaultOnTheFly(82125)	-- Corruption: Malformation
SetDefaultOnTheFly(82170)	-- Corruption: Absolute
SetDefaultOnTheFly(93200)	-- Corruption: Sickness
SetDefaultOnTheFly(82411)	-- Debilitating Beam
SetDefaultOnTheFly(91317)	-- Worshipping
SetDefaultOnTheFly(92956)	-- Wrack
-- Throne of the Four Winds
SetDefaultOnTheFly(93131)	-- Ice Patch
SetDefaultOnTheFly(86206)	-- Soothing Breeze
SetDefaultOnTheFly(93122)	-- Toxic Spores
SetDefaultOnTheFly(93058)	-- Slicing Gale
SetDefaultOnTheFly(93260)	-- Ice Storm
SetDefaultOnTheFly(93295)	-- Lightning Rod
SetDefaultOnTheFly(87873)	-- Static Shock
SetDefaultOnTheFly(87856)	-- Squall Line
SetDefaultOnTheFly(88427)	-- Electrocute
-------------------------------------------------
-------------------- Phase 3 --------------------
-------------------------------------------------
-- Zul'Aman (Dungeon)
-- Zul'Gurub (Dungeon)
-- Firelands
SetDefaultOnTheFly(99506)	-- Widows Kiss
SetDefaultOnTheFly(97202)	-- Fiery Web Spin
SetDefaultOnTheFly(49026)	-- Fixate
SetDefaultOnTheFly(97079)	-- Seeping Venom
SetDefaultOnTheFly(99389)	-- Imprinted
SetDefaultOnTheFly(101296)	-- Fiero Blast
SetDefaultOnTheFly(100723)	-- Gushing Wound
SetDefaultOnTheFly(101729)	-- Blazing Claw
SetDefaultOnTheFly(100640)	-- Harsh Winds
SetDefaultOnTheFly(100555)	-- Smouldering Roots
SetDefaultOnTheFly(99837)	-- Crystal Prison
SetDefaultOnTheFly(99937)	-- Jagged Tear
SetDefaultOnTheFly(99403)	-- Tormented
SetDefaultOnTheFly(99256)	-- Torment
SetDefaultOnTheFly(99252)	-- Blaze of Glory
SetDefaultOnTheFly(99516)	-- Countdown
SetDefaultOnTheFly(98450)	-- Searing Seeds
SetDefaultOnTheFly(98565)	-- Burning Orb
SetDefaultOnTheFly(98313)	-- Magma Blast
SetDefaultOnTheFly(99145)	-- Blazing Heat
SetDefaultOnTheFly(99399)	-- Burning Wound
SetDefaultOnTheFly(99613)	-- Molten Blast
SetDefaultOnTheFly(100293)	-- Lava Wave
SetDefaultOnTheFly(100675)	-- Dreadflame
SetDefaultOnTheFly(100249)	-- Combustion
SetDefaultOnTheFly(99532)	-- Melt Armor
-------------------------------------------------
-------------------- Phase 4 --------------------
-------------------------------------------------
-- Dragon Soul
SetDefaultOnTheFly(103541)	-- Safe
SetDefaultOnTheFly(103536)	-- Warning
SetDefaultOnTheFly(103534)	-- Danger
SetDefaultOnTheFly(103687)	-- Crush Armor
SetDefaultOnTheFly(108570)	-- Black Blood of the Earth
SetDefaultOnTheFly(103434)	-- Disrupting Shadows
SetDefaultOnTheFly(105171)	-- Deep Corruption
SetDefaultOnTheFly(105465)	-- Lighting Storm
SetDefaultOnTheFly(104451)	-- Ice Tomb
SetDefaultOnTheFly(109325)	-- Frostflake
SetDefaultOnTheFly(105289)	-- Shattered Ice
SetDefaultOnTheFly(105285)	-- Target
SetDefaultOnTheFly(105259)	-- Watery Entrenchment
SetDefaultOnTheFly(107061)	-- Ice Lance
SetDefaultOnTheFly(109075)	-- Fading Light
SetDefaultOnTheFly(108043)	-- Sunder Armor
SetDefaultOnTheFly(107558)	-- Degeneration
SetDefaultOnTheFly(107567)	-- Brutal Strike
SetDefaultOnTheFly(108046)	-- Shockwave
SetDefaultOnTheFly(110214)	-- Shockwave
SetDefaultOnTheFly(105479)	-- Searing Plasma
SetDefaultOnTheFly(105490)	-- Fiery Grip
SetDefaultOnTheFly(105563)	-- Grasping Tendrils
SetDefaultOnTheFly(106199)	-- Blood Corruption: Death
SetDefaultOnTheFly(105841)	-- Degenerative Bite
SetDefaultOnTheFly(106385)	-- Crush
SetDefaultOnTheFly(106730)	-- Tetanus
SetDefaultOnTheFly(106444)	-- Impale
SetDefaultOnTheFly(106794)	-- Shrapnel (Target)
SetDefaultOnTheFly(105445)	-- Blistering Heat
SetDefaultOnTheFly(108649)	-- Corrupting Parasite
