local _, ns = ...
ns.oUF = {}
ns.oUF.Private = {}

local _, _, _ , wowToc = GetBuildInfo()
ns.oUF.isTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC -- not used
ns.oUF.isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
ns.oUF.isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
ns.oUF.isMists = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC
ns.oUF.isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
ns.oUF.isForever = wowToc >= 16000 and wowToc < 20000
ns.oUF.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and not ns.oUF.isForever
ns.oUF.isModern = ns.oUF.isRetail or ns.oUF.isForever

local season = C_Seasons and C_Seasons.GetActiveSeason()
ns.oUF.isClassicHC = season == 3 -- Hardcore
ns.oUF.isClassicSOD = season == 2 -- Season of Discovery
ns.oUF.isClassicAnniv = season == 11 -- Anniversary
ns.oUF.isClassicAnnivHC = season == 12 -- Anniversary Hardcore
