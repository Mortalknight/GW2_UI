local _, ns = ...
ns.oUF = {}
ns.oUF.Private = {}

ns.oUF.isTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC -- not used
ns.oUF.isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
ns.oUF.isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
ns.oUF.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
ns.oUF.isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local season = C_Seasons and C_Seasons.GetActiveSeason()
ns.oUF.isClassicHC = season == 3 -- Hardcore
ns.oUF.isClassicSOD = season == 2 -- Season of Discovery
ns.oUF.isClassicAnniv = season == 11 -- Anniversary
ns.oUF.isClassicAnnivHC = season == 12 -- Anniversary Hardcore
