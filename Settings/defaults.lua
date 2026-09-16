---@class GW2
local GW = select(2, ...)

local GetSpellInfo = C_Spell and C_Spell.GetSpellInfo or GetSpellInfo

local UnitFrameFader = {
    casting = false,
    combat = false,
    hover = false,
    vehicle = false,
    playertarget = false,
    unittarget = false,
    dynamicflight = false,
    health = false,
    maxAlpha = 1,
    minAlpha = 0.35,
    smooth = 0.33,
}

local PlayerAuraSettings = {
    Seperate = 0,
    Sort = "DEFAULT",
    IconSize = 32,
    IconHeight = 32,
    KeepSizeRatio = true,
    GrowDirection = "UP",
    HorizontalSpacing = 1,
    VerticalSpacing = 34,
    MaxWraps = 3,
    WrapAfter = 7,
    NewAuraAnimation = true,
}

-- per grid ignore list default, seeded from the always-ignored spell ids
local GridIgnoredAuras = {}
for _, spellId in ipairs(GW.AURAS_IGNORED) do
    GridIgnoredAuras[spellId] = true
end

local GridAuraFilter = {
    isAuraPlayer = false,
    isAuraRaid = false,
    isAuraRaidPlayer = false,
    isAuraRaidPlayerDispellable = false,
    isAuraExternalDefensive = false,
    isAuraImportant = false,
    -- aura property candidates (see ADVANCED_CANDIDATE_FIELDS in the factory)
    isAuraStealable = false,
    isAuraBoss = false,
    isAuraBossOrRole = false,
    isAuraPriority = false,
    isAuraRole = false,
    isAuraCanApply = false,
    isAuraNameplateAll = false,
    isAuraNameplatePersonal = false,
    isAuraCrowdControl = false,
    isAuraBigDefensive = false,
    isAuraRaidInCombat = false,
    isAuraCancelable = false,
    isAuraCancelablePlayer = false,
    notAuraCancelable = false,
    notAuraCancelablePlayer = false,
}

--private
GW.privateDefaults = {
    profile = {
        GW2_UI_VERSION = "WELCOME",
        NewestSeenAddonVersion = {version = "", sender = "", features = 0, changes = 0, bugs = 0}, -- newest GW2 UI version seen in group or guild
        Layouts = {},
        questWatch = { TrackedQuests = {}, AutoUntrackedQuests = {} }, -- era clients: manual quest tracking state
        PLAYER_TRACKED_DODGEBAR_SPELL_ID = 0,
        CHAT_KEYWORDS_ALERT_COLOR = {r = .5, g = .5, b = .5},
        ChatHistoryLog = {},
        ChatEditHistory = {},
        heroPanel = {
            stats = {
                order = {},
                visibility = {},
            },
        },

        -- GW2 Class colors
        Gw2ClassColor = {
            WARRIOR = { r = 90 / 255, g = 54 / 255, b = 38 / 255, a = 1 },
            PALADIN = { r = 177 / 255, g = 72 / 255, b = 117 / 255, a = 1 },
            HUNTER = { r = 99 / 255, g = 125 / 255, b = 53 / 255, a = 1 },
            ROGUE = { r = 190 / 255, g = 183 / 255, b = 79 / 255, a = 1 },
            PRIEST = { r = 205 / 255, g = 205 / 255, b = 205 / 255, a = 1 },
            DEATHKNIGHT = { r = 148 / 255, g = 62 / 255, b = 62 / 255, a = 1 },
            SHAMAN = { r = 30 / 255, g = 44 / 255, b = 149 / 255, a = 1 },
            --MAGE = {r = 62 / 255, g = 121 / 255, b = 149 / 255, a = 1},
            MAGE = { r = 101 / 255, g = 157 / 255, b = 184 / 255, a = 1 },
            WARLOCK = { r = 125 / 255, g = 88 / 255, b = 154 / 255, a = 1 },
            MONK = { r = 66 / 255, g = 151 / 255, b = 112 / 255, a = 1 },
            DRUID = { r = 158 / 255, g = 103 / 255, b = 37 / 255, a = 1 },
            DEMONHUNTER = { r = 72 / 255, g = 38 / 255, b = 148 / 255, a = 1 },
            EVOKER = { r = 56 / 255, g = 99 / 255, b = 113 / 255, a = 1 }
        },
    },
}

GW.globalDefault = {
    profile = {
        profileCreatedCharacter = "GW2_UI",
        profileCreatedDate = date(GW.L["TimeStamp m/d/y h:m:s"]),
        incompatibleAddons = {
            Actionbars = {
                Override = false,
                Addons = {
                    "Bartender4",
                    "Dominos",
                },
            },
            PetFrame = {
                Override = false,
                Addons = {
                    "Bartender4",
                    "Dominos",
                },
            },
            ImmersiveQuesting = {
                Override = false,
                Addons = {
                    "Storyline",
                    "Immersive",
                    "Immersion",
                    "Tofu",
                    "Queso",
                },
            },
            DynamicCam = {
                Override = false,
                Addons = {
                    "DynamicCam",
                    "Queso",
                },
            },
            Inventory = {
                Override = false,
                Addons = {
                    "AdiBags",
                    "ArkInventory",
                    "Bagnon",
                    "Sorted",
                    "Baganator"
                },
            },
            Minimap = {
                Override = false,
                Addons = {
                    "SexyMap",
                },
            },
            FloatingCombatText = {
                Override = false,
                Addons = {
                    "ClassicFCT",
                    "xCT+",
                    "NameplateSCT",
                },
            },
            Objectives = {
                Override = false,
                Addons = {
                    "!KalielsTracker",
                },
            },
            AchievementSkin = {
                Override = false,
                Addons = {},
            },
            LfgInfo = {
                Override = false,
                Addons = {
                    "PremadeGroupsFilter",
                },
            },
            Chat = {
                Override = false,
                Addons = {
                    "Chattynator",
                },
            },
        },

        general = {
            battlegroundHud = true,
            fixGuildNewsSpam = true,
            numberFormat = "POINT",
            dynamicCam = false,
            pixelPerfection = false,
            afkMode = true,
            autoRepair = "NONE",
            questRewardMostValueIcon = true,
            questXpPercent = true,
            blizzardClassColors = false,
        },

        windows = {
            character = {
                enabled = true,
                pos = {
                    point = "LEFT",
                    relativePoint = "LEFT",
                    xOfs = 100,
                    yOfs = 0,
                    hasMoved = false,
                },
                scale = 1,
                itemInfo = false,
                itemInfoMissing = true,
                itemLevelRelativeColor = false,
            },
            social = {
                enabled = true,
                pos = {
                    point = "LEFT",
                    relativePoint = "LEFT",
                    xOfs = 100,
                    yOfs = 0,
                    hasMoved = false,
                },
                scale = 1,
            },
            talent = {
                enabled = true,
            },
            spellbook = {
                enabled = true,
            },
            profession = {
                enabled = true,
            },
        },

        fonts = {
            styleTemplate = "GW2",
            normal = "Interface/AddOns/GW2_UI/fonts/menomonia.ttf",
            headers = "",
            customNormal = "NONE",
            customHeader = "NONE",
            size = {
                bigHeader = 18,
                header = 16,
                normal = 14,
                small = 12,
            },
            outline = "",
        },

        powerBar = {
            enabled = true,
            pos = {
                point = "BOTTOMLEFT",
                relativePoint = "BOTTOM",
                xOfs = 56,
                yOfs = 86,
                hasMoved = false,
            },
            scale = 1,
        },

        roleBar = {
            pos = {
                point = "TOPLEFT",
                relativePoint = "TOPLEFT",
                xOfs = 500,
                yOfs = 0,
                hasMoved = false,
            },
            scale = 1,
            mode = "IN_RAID",
        },

        altPowerBar = {
            pos = {
                point = "TOP",
                relativePoint = "TOP",
                xOfs = 0,
                yOfs = -30,
                hasMoved = false,
            },
            scale = 1,
        },

        hud = {
            scale = 1,
            gridSpacing = 64,
            screenBorder = true,
            dodgeBar = {
                enabled = true,
                cooldownText = true,
            },
            skyridingBar = true,
            xpBar = true,
            background = true,
            dynamicBackground = true,
            fadeGroupManageButton = false,
        },

        tooltip = {
            enabled = true,
            pos = {
                point = "BOTTOMRIGHT",
                relativePoint = "BOTTOMRIGHT",
                xOfs = 0,
                yOfs = 300,
                hasMoved = false,
            },
            anchor = {
                toCursor = false,
                cursorType = "ANCHOR_CURSOR",
                cursorOffsetX = 0,
                cursorOffsetY = 0,
            },
            fontSize = {
                header = 16,
                comparison = 12,
                body = 14,
                healthBar = 10,
            },
            healthBar = {
                values = "RAW",
                shortValues = false,
                position = "BOTTOM",
            },
            hideInCombat = {
                enabled = false,
                units = "ALL",
                overrideKey = "NONE",
            },
            item = {
                count = {
                    Bank = true,
                    Bag = true,
                    Stack = true
                },
                countIncludeReagents = true,
                countIncludeWarband = true,
            },
            unit = {
                mount = true,
                targetInfo = true,
                playerTitles = true,
                realmAlways = true,
                guildRanks = true,
                role = true,
                classColor = true,
                gender = false,
                dungeonScore = true,
                keystoneInfo = true,
                premadeGroupInfo = true,
            },
            idModifier = "NONE",
        },

        chat = {
            interruptAnnounce = "NONE",
            enabled = true,
            bubbles = {
                enabled = true,
                scale = 1,
            },
            fade = true,
            hideEditBox = true,
            buttonsPosition = "LEFT",
            maxCopyLines = 100,
            gw2Style = true,
            scrollMessages = 3,
            scrollDownInterval = 15,
            copyChatLines = false,
            findUrl = true,
            hyperlinkTooltip = true,
            shortChannelNames = false,
            lfgIcons = true,
            spamInterval = 5,
            inCombatTextRepeat = 5,
            classColorMentions = true,
            keywords = {
                list = "%MYNAME%",
                alertNew = "GW2_UI: Ping",
                emoji = true,
            },
            socialLink = true,
            timestampAll = true,
            history = {
                enabled = true,
                types = { -- maybe as setting later
                    WHISPER = true,
                    GUILD = true,
                    PARTY = true,
                    RAID = true,
                    INSTANCE = true,
                    CHANNEL = true,
                    SAY = true,
                    YELL = true,
                    EMOTE = true
                },
                size = 100,
            },
            timeStampFormat = "NONE",
        },

        minimap = {
            enabled = true,
            pos = {
                point = "BOTTOMRIGHT",
                relativePoint = "BOTTOMRIGHT",
                xOfs = -5,
                yOfs = 21,
                hasMoved = false,
            },
            scale = 1.2,
            alwaysShowHoverDetails = {CLOCK = false, ZONE = false, COORDS = false,},
            size = 170,
            resetZoom = 0,
            fps = false,
            fpsTooltipDisabled = false,
            coords = {
                enabled = false,
                precision = 0,
            },
            addonCompartment = true,
            addonFlyoutAlways = false,
            heightPercentage = 100,
            keepSizeRatio = true,
        },

        worldmap = {
            coords = {
                enabled = false,
                position = "TOP",
                offsetX = 0,
                offsetY = 0,
            },
        },

        bags = {
            enabled = true,
            bag = {
                pos = {
                    point = "TOPRIGHT",
                    relativePoint = "TOPRIGHT",
                    xOfs = -20,
                    yOfs = -60,
                    hasMoved = false,
                },
                itemSize = 40,
                itemSpacingX = 5,
                itemSpacingY = 5,
                width = 480,
                reverseNewLoot = false,
                reverseSort = false,
                reverseItemSort = false,
                compactEmptySlots = false,
                separateBags = false,
                separateKeyring = false,
                separateReagentBag = false,
                headerNames = {
                    [0] = "",
                    [1] = "",
                    [2] = "",
                    [3] = "",
                    [4] = "",
                    [5] = "",
                },
            },
            bank = {
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 60,
                    yOfs = -60,
                    hasMoved = false,
                },
                itemSize = 40,
                itemSpacingX = 5,
                itemSpacingY = 5,
                width = 720,
                reverseSort = false,
                separateBags = false,
                headerNames = {
                    [0] = "",
                    [1] = "",
                    [2] = "",
                    [3] = "",
                    [4] = "",
                    [5] = "",
                    [6] = "",
                    [7] = "",
                },
            },
            items = {
                qualityBorder = true,
                junkIcon = false,
                scrapIcon = false,
                upgradeIcon = false,
                levelThreshold = 0,
                newItemGlow = false,
                showItemLevel = false,
                equipmentSetName = false,
                junkDesaturate = false,
                equipmentSetIcon = false,
                markUnusable = false,
            },
            professionBagColor = true,
            professionBagQualityColor = false,
            vendorGrays = false,
            autoSortOnOpen = false,
            autoOpenContexts = {merchant = false, mail = false, auctionHouse = false, bank = false, trade = false},
            extendedVendorPages = 2,
        },

        stanceBar = {
            enabled = true,
            pos = {
                point = "BOTTOMLEFT",
                relativePoint = "BOTTOM",
                xOfs = -405,
                yOfs = 31,
                hasMoved = false,
            },
            scale = 1,
            growDirection = "UP",
            buttonSize = 30,
            spacing = 2,
            alpha = 1,
            mouseOver = false,
            visibility = "show",
            containerState = "close",
        },

        totemBar = {
            enabled = true,
            pos = {
                point = "TOPRIGHT",
                relativePoint = "TOPRIGHT",
                xOfs = -500,
                yOfs = -50,
                hasMoved = false,
            },
            scale = 1,
            growDirection = "HORIZONTAL",
            sortDirection = "ASC",
            spacing = 3,
            buttonSize = 48,
        },

        actionbars = {
            enabled = true,
            barLayout = true,
            healthGlobeSpace = false,
            showMacroNames = false,
            backgroundAlpha = 0.3,
            buttonAssignments = true,
            buttonAssignmentsUsedOnly = false,
            bars = {
                MultiBarBottomLeft = {
                    pos = {
                        point = "BOTTOMLEFT",
                        relativePoint = "BOTTOM",
                        xOfs = -369,
                        yOfs = 120,
                        hasMoved = false,
                    },
                    scale = 1,
                    fade = "ALWAYS",
                    size = 38,
                    ButtonsPerRow = 6,
                    invert = false,
                },
                MultiBarBottomRight = {
                    pos = {
                        point = "BOTTOMRIGHT",
                        relativePoint = "BOTTOM",
                        xOfs = 369,
                        yOfs = 120,
                        hasMoved = false,
                    },
                    scale = 1,
                    fade = "ALWAYS",
                    size = 38,
                    ButtonsPerRow = 6,
                    invert = false,
                },
                MultiBarRight = {
                    pos = {
                        point = "RIGHT",
                        relativePoint = "RIGHT",
                        xOfs = -320,
                        yOfs = 0,
                        hasMoved = false,
                    },
                    scale = 1,
                    fade = "ALWAYS",
                    size = 38,
                    ButtonsPerRow = 1,
                    invert = false,
                },
                MultiBarLeft = {
                    pos = {
                        point = "RIGHT",
                        relativePoint = "RIGHT",
                        xOfs = -368,
                        yOfs = 0,
                        hasMoved = false,
                    },
                    scale = 1,
                    fade = "ALWAYS",
                    size = 38,
                    ButtonsPerRow = 1,
                    invert = false,
                },
                MultiBar5 = {
                    pos = {
                        point = "RIGHT",
                        relativePoint = "RIGHT",
                        xOfs = -368,
                        yOfs = 0,
                        hasMoved = false,
                    },
                    scale = 1,
                    fade = "ALWAYS",
                    size = 38,
                    ButtonsPerRow = 1,
                    invert = false,
                },
                MultiBar6 = {
                    pos = {
                        point = "RIGHT",
                        relativePoint = "RIGHT",
                        xOfs = -368,
                        yOfs = 0,
                        hasMoved = false,
                    },
                    scale = 1,
                    fade = "ALWAYS",
                    size = 38,
                    ButtonsPerRow = 1,
                    invert = false,
                },
                MultiBar7 = {
                    pos = {
                        point = "RIGHT",
                        relativePoint = "RIGHT",
                        xOfs = -368,
                        yOfs = 0,
                        hasMoved = false,
                    },
                    scale = 1,
                    fade = "ALWAYS",
                    size = 38,
                    ButtonsPerRow = 1,
                    invert = false,
                },
            },
            mainBar = {
                fade = "ALWAYS",
            },
            multibarMargin = 2,
            mainbarMargin = 5,
            extraActionButton = {
                pos = {
                    point = "BOTTOM",
                    relativePoint = "BOTTOM",
                    xOfs = -150,
                    yOfs = 300,
                    hasMoved = false,
                },
                scale = 1,
            },
            zoneAbility = {
                pos = {
                    point = "BOTTOM",
                    relativePoint = "BOTTOM",
                    xOfs = 150,
                    yOfs = 300,
                    hasMoved = false,
                },
                scale = 1,
            },
            rangeIndicator = "RED_INDICATOR",
        },

        castingbar = {
            enabled = true,
            pos = {
                point = "BOTTOM",
                relativePoint = "BOTTOM",
                xOfs = 0,
                yOfs = 300,
                hasMoved = false,
            },
            scale = 1,
            height = 15,
            ticks = true,
            width = 176,
            -- what the old "Advanced Casting Bar" toggle switched as a block, one setting each.
            -- The defaults match that toggle being off, existing profiles are migrated
            showName = false,
            showTimer = false,
            showLatency = false,
            iconPosition = "HIDE",
            -- the default colors match the flavored bar textures, so switching custom colors on
            -- does not change the look until one of them is edited
            customColors = false,
            colors = {
                cast = {r = 0.93, g = 0.65, b = 0.15},
                channel = {r = 0.55, g = 0.8, b = 0.2},
                empower = {r = 1, g = 0.72, b = 0.2},
                interrupted = {r = 0.8, g = 0.16, b = 0.11},
                empowerStages = true,
            },
            interruptShake = true,
            interruptSound = false,
            spellQueueWindow = true,
        },

        classpower = {
            enabled = true,
            pos = {
                point = "BOTTOMLEFT",
                relativePoint = "BOTTOM",
                xOfs = -369,
                yOfs = 81,
                hasMoved = false,
            },
            scale = 1,
            onlyInCombat = false,
            anchorMode = "DEFAULT",
            anchorOffsetX = 0,
            anchorOffsetY = 0,
            customResourceBarSide = "AUTO",
            customResourceBarGap = 4,
            showValue = true,
        },

        combatText = {
            pos = {
                point = "CENTER",
                relativePoint = "CENTER",
                xOfs = 400,
                yOfs = 0,
                hasMoved = false,
            },
            scale = 1,
            mode = "GW2",
            blizzardColor = false,
            commaFormat = false,
            shortValues = false,
            style = "Default",
            classicAnchor = "Center",
            showHealing = false,
            fontSize = {
                miss = 18,
                crit = 34,
                normal = 24,
                blockedAbsorbed = 14,
                petModifier = 0.7,
                critModifier = 1.5,
            },
            showIcons = false,
        },

        unitframes = {
            healthGlobe = {
                enabled = true,
                pos = {
                    point = "BOTTOM",
                    relativePoint = "BOTTOM",
                    xOfs = 0,
                    yOfs = 17,
                    hasMoved = false,
                },
                healthValue = "VALUE",
                absorbValue = "VALUE",
                shortHealthValues = false,
                shortShieldValues = false,
            },
            target = {
                enabled = true,
                pos = {
                    point = "TOP",
                    relativePoint = "TOP",
                    xOfs = -56,
                    yOfs = -100,
                    hasMoved = false,
                },
                scale = 1,
                showCastbar = true,
                showAbsorbBar = true,
                buffFilter = "all",
                buffFilterAdvanced = CopyTable(GridAuraFilter),
                debuffFilter = "player",
                debuffFilterAdvanced = CopyTable(GridAuraFilter),
                threatValue = false,
                hookComboPoints = false,
                healthValue = false,
                healthValueType = false,
                classColor = true,
                castingbarShowName = true,
                castingbarShowTimer = false,
                aurasOnTop = false,
                floatingCombatText = true,
                invert = false,
                altBackground = false,
                itemLevel = "PVP_LEVEL",
                shortValues = false,
                healthBarTexture = "GW2_UI_2_DEFAULT",
                auraSmallSize = 20,
                auraBigSize = 26,
                ignoredAuras = {},
                pandemicHighlight = true,
                dispelIcon = "DISPELLABLE",
                auraSort = "DEFAULT",
                healthBarSize = {
                    height = 13,
                    width = 213,
                },
                powerBarSize = {
                    height = 3,
                },
                healthBarTextOffset = {
                    x = 5,
                    y = 0,
                },
                --frame fade
                fader = CopyTable(UnitFrameFader),
            },
            focus = {
                enabled = true,
                pos = {
                    point = "CENTER",
                    relativePoint = "CENTER",
                    xOfs = -350,
                    yOfs = 0,
                    hasMoved = false,
                },
                scale = 1,
                showAbsorbBar = true,
                showCastbar = true,
                aurasOnTop = false,
                buffFilter = "all",
                buffFilterAdvanced = CopyTable(GridAuraFilter),
                debuffFilter = "player",
                debuffFilterAdvanced = CopyTable(GridAuraFilter),
                itemLevel = "PVP_LEVEL",
                healthValue = false,
                healthValueType = false,
                classColor = true,
                castingbarShowName = true,
                castingbarShowTimer = false,
                invert = false,
                altBackground = false,
                shortValues = false,
                healthBarTexture = "GW2_UI_2_DEFAULT",
                auraSmallSize = 20,
                auraBigSize = 26,
                ignoredAuras = {},
                pandemicHighlight = true,
                dispelIcon = "DISPELLABLE",
                auraSort = "DEFAULT",
                healthBarSize = {
                    height = 13,
                    width = 213,
                },
                healthBarTextOffset = {
                    x = 5,
                    y = 0,
                },
                powerBarSize = {
                    height = 3,
                },
                fader = CopyTable(UnitFrameFader),
            },
            party = {
                enabled = true,
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 20,
                    yOfs = -104,
                    hasMoved = false,
                },
                orientation = "VERTICAL",
                spacing = 5,
                healthValue = "NONE",
                showBuffs = true,
                auraIconSize = 20,
                ignoredAuras = {},
                pandemicHighlight = true,
                dispelIcon = "DISPELLABLE",
                healthBarTexture = "GW2_UI_2_DEFAULT",
                showDebuffs = true,
                onlyDispellableDebuffs = false,
                showRaidInstanceDebuffs = false,
                showPlayer = false,
                showPets = false,
                showAbsorbBar = true,
                shortHealthValues = false,
            },
            pet = {
                enabled = true,
                pos = {
                    point = "BOTTOMRIGHT",
                    relativePoint = "BOTTOM",
                    xOfs = -57,
                    yOfs = 120,
                    hasMoved = false,
                },
                scale = 1,
                floatingCombatText = false,
                aurasUnder = false,
                showAbsorbBar = true,
                healthValueRaw = true,
                healthValuePercent = false,
                buffFilter = "all",
                buffFilterAdvanced = CopyTable(GridAuraFilter),
                debuffFilter = "player",
                debuffFilterAdvanced = CopyTable(GridAuraFilter),
                ignoredAuras = {},
                pandemicHighlight = true,
                dispelIcon = "DISPELLABLE",
                auraSort = "DEFAULT",
                fader = CopyTable(UnitFrameFader),
                shortHealthValues = false,
                healthBarTexture = "GW2_UI_2_DEFAULT",
            },
            reactionColors = {
                Friendly = {r = 88 / 255, g = 170 / 255, b = 68 / 255},
                Hostile = {r = 159 / 255, g = 36 / 255, b = 20 / 255},
                TappedDenied = {r = 159 / 255, g = 159 / 255, b = 159 / 255},
            },
            targettarget = {
                enabled = true,
                pos = {
                    point = "TOP",
                    relativePoint = "TOP",
                    xOfs = 250,
                    yOfs = -110,
                    hasMoved = false,
                },
                scale = 1,
                showCastbar = true,
                showAbsorbBar = true,
                healthBarSize = {
                    height = 13,
                    width = 148,
                },
                powerBarSize = {
                    height = 3,
                },
                healthBarTexture = "GW2_UI_2_DEFAULT",
                fader = CopyTable(UnitFrameFader),
            },
            focustarget = {
                enabled = true,
                pos = {
                    point = "CENTER",
                    relativePoint = "CENTER",
                    xOfs = -80,
                    yOfs = -10,
                    hasMoved = false,
                },
                scale = 1,
                showCastbar = true,
                showAbsorbBar = true,
                healthBarSize = {
                    height = 13,
                    width = 148,
                },
                powerBarSize = {
                    height = 3,
                },
                healthBarTexture = "GW2_UI_2_DEFAULT",
                fader = CopyTable(UnitFrameFader),
            },
            player = {
                enabled = false,
                pos = {
                    point = "CENTER",
                    relativePoint = "CENTER",
                    xOfs = -56,
                    yOfs = -100,
                    hasMoved = false,
                },
                scale = 1,
                fader = CopyTable(UnitFrameFader),
                showResourceBar = false,
                classColor = false,
                showAbsorbBar = true,
                pvpIndicator = true,
                energyManaTickHideOutOfCombat = false,
                energyManaTick = true,
                fiveSecondRuleTimer = true,
                altBackground = false,
                healthBarSize = {
                    height = 13,
                    width = 213,
                },
                powerBarSize = {
                    height = 3,
                },
                healthBarTextOffset = {
                    x = 5,
                    y = 0,
                },
                powerBarTextOffset = {
                    x = 5,
                    y = 0,
                },
                healthBarTexture = "GW2_UI_2_DEFAULT",
            },
            --general raid tag update rate
            shortValuePrefixStyle = "ENGLISH",
            shortValueDecimals = 0,
        },

        playerAuras = {
            enabled = true,
            missingAuras = strjoin(", ", unpack(GW.MapTable(GW.AURAS_MISSING, GetSpellInfo, nil, "name"))),
            buffs = {
                pos = {
                    point = "BOTTOMLEFT",
                    relativePoint = "BOTTOM",
                    xOfs = 57,
                    yOfs = 120,
                    hasMoved = false,
                },
                scale = 1,
            },
            debuffs = {
                pos = {
                    point = "BOTTOMLEFT",
                    relativePoint = "BOTTOM",
                    xOfs = 57,
                    yOfs = 220,
                    hasMoved = false,
                },
                scale = 1,
            },
            ignoredAuras = {},
            pandemicHighlight = true,
            dispelIcon = "DISPELLABLE",
        },

        groupFrames = {
            pullTimerSeconds = 10,
            tagUpdateRate = 0.2, -- eventTimerThreshold
            enabled = true,
            raidDebuffs = {},
            raid10 = {
                -- RAID10
                enabled = true,
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 480,
                    yOfs = -760,
                    hasMoved = false,
                },
                height = 47,
                faderRange = true,
                fader = CopyTable(UnitFrameFader),
                classColor = false,
                hideClassIcon = false,
                unitFlags = "NONE",
                unitMarkers = false,
                width = 55,
                groupsPerColumn = 1,
                grow = "DOWN+RIGHT",
                showDebuffs = true,
                onlyDispellableDebuffs = false,
                showRaidInstanceDebuffs = false,
                auraTooltipInCombat = "IN_COMBAT",
                unitHealth = "NONE",
                anchorFromCenter = false,
                wideSorting = false,
                groupBy = "ROLE",
                groupByClassOrder = {"DEATHKNIGHT,DEMONHUNTER,DRUID,EVOKER,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK"},
                sortDirection = "ASC",
                sortMethod = "NAME",
                horizontalSpacing = 2,
                verticalSpacing = 2,
                groupSpacing = 0,
                showRoleIcon = true,
                showTankIcon = true,
                showLeaderIcon = true,
                shortHealthValues = false,
                showAbsorbBar = true,
                debuffFilter = CopyTable(GridAuraFilter),
                buffFilter = CopyTable(GridAuraFilter),
                ignoredAuras = CopyTable(GridIgnoredAuras),
                pandemicHighlight = true,
                dispelIcon = "DISPELLABLE",
                showBuffs = false,
                showPowerBar = "ALL",
                healthBarTexture = "GW2_UI_2_DEFAULT",
            },
            raid25 = {
                -- RAID25
                enabled = true,
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 480,
                    yOfs = -760,
                    hasMoved = false,
                },
                height = 47,
                faderRange = true,
                fader = CopyTable(UnitFrameFader),
                classColor = false,
                hideClassIcon = false,
                unitFlags = "NONE",
                unitMarkers = false,
                width = 55,
                groupsPerColumn = 1,
                grow = "DOWN+RIGHT",
                showDebuffs = true,
                onlyDispellableDebuffs = false,
                showRaidInstanceDebuffs = false,
                auraTooltipInCombat = "IN_COMBAT",
                unitHealth = "NONE",
                anchorFromCenter = false,
                wideSorting = false,
                groupBy = "ROLE",
                sortDirection = "ASC",
                sortMethod = "NAME",
                horizontalSpacing = 2,
                verticalSpacing = 2,
                groupSpacing = 0,
                showRoleIcon = true,
                showTankIcon = true,
                showLeaderIcon = true,
                shortHealthValues = false,
                showAbsorbBar = true,
                debuffFilter = CopyTable(GridAuraFilter),
                buffFilter = CopyTable(GridAuraFilter),
                ignoredAuras = CopyTable(GridIgnoredAuras),
                pandemicHighlight = true,
                dispelIcon = "DISPELLABLE",
                showBuffs = false,
                showPowerBar = "ALL",
                healthBarTexture = "GW2_UI_2_DEFAULT",
                groupByClassOrder = {"DEATHKNIGHT,DEMONHUNTER,DRUID,EVOKER,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK"},
            },
            raid40 = {
                -- RAID40 (RAID_FRAMES is the module master for all group frames)
                enabled = true,
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 65,
                    yOfs = -60,
                    hasMoved = false,
                },
                height = 47,
                faderRange = true,
                fader = CopyTable(UnitFrameFader),
                -- RAID40
                classColor = false,
                hideClassIcon = false,
                unitFlags = "NONE",
                unitMarkers = false,
                width = 55,
                groupsPerColumn = 1,
                grow = "DOWN+RIGHT",
                showDebuffs = true,
                onlyDispellableDebuffs = false,
                showRaidInstanceDebuffs = false,
                auraTooltipInCombat = "IN_COMBAT",
                unitHealth = "NONE",
                anchorFromCenter = false,
                wideSorting = false,
                groupBy = "ROLE",
                sortDirection = "ASC",
                sortMethod = "NAME",
                horizontalSpacing = 2,
                verticalSpacing = 2,
                groupSpacing = 0,
                showRoleIcon = true,
                showTankIcon = true,
                showLeaderIcon = true,
                shortHealthValues = false,
                showAbsorbBar = true,
                buffFilter = CopyTable(GridAuraFilter),
                ignoredAuras = CopyTable(GridIgnoredAuras),
                pandemicHighlight = true,
                dispelIcon = "DISPELLABLE",
                debuffFilter = CopyTable(GridAuraFilter),
                showBuffs = false,
                showPowerBar = "ALL",
                healthBarTexture = "GW2_UI_2_DEFAULT",
                groupByClassOrder = {"DEATHKNIGHT,DEMONHUNTER,DRUID,EVOKER,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK"},
            },
            party = {
                enabled = false,
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 480,
                    yOfs = -760,
                    hasMoved = false,
                },
                height = 80,
                faderRange = true,
                fader = CopyTable(UnitFrameFader),
                -- Party Grid
                classColor = true,
                hideClassIcon = false,
                unitFlags = "NONE",
                unitMarkers = false,
                width = 500,
                groupsPerColumn = 1,
                grow = "DOWN+RIGHT",
                showDebuffs = true,
                onlyDispellableDebuffs = false,
                showRaidInstanceDebuffs = true,
                auraTooltipInCombat = "IN_COMBAT",
                unitHealth = "NONE",
                anchorFromCenter = false,
                wideSorting = true,
                groupBy = "ROLE",
                sortDirection = "ASC",
                sortMethod = "NAME",
                horizontalSpacing = 2,
                verticalSpacing = 2,
                groupSpacing = 0,
                showRoleIcon = true,
                showTankIcon = true,
                showLeaderIcon = true,
                shortHealthValues = false,
                showPlayer = true, -- only for party grid
                showAbsorbBar = true,
                debuffFilter = CopyTable(GridAuraFilter),
                buffFilter = CopyTable(GridAuraFilter),
                ignoredAuras = CopyTable(GridIgnoredAuras),
                pandemicHighlight = true,
                dispelIcon = "DISPELLABLE",
                showBuffs = false,
                showPowerBar = "ALL",
                healthBarTexture = "GW2_UI_2_DEFAULT",
                groupByClassOrder = {"DEATHKNIGHT,DEMONHUNTER,DRUID,EVOKER,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK"},
                withPartyFrames = false,
            },
            partyPet = {
                -- Party Pet
                enabled = false,
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 315,
                    yOfs = -60,
                    hasMoved = false,
                },
                height = 25,
                faderRange = true,
                fader = CopyTable(UnitFrameFader),
                classColor = true, -- always
                hideClassIcon = false, -- always
                unitFlags = "NONE", -- always
                unitMarkers = false,
                width = 50,
                groupsPerColumn = 1, -- fixed
                grow = "DOWN+RIGHT",
                showDebuffs = true,
                onlyDispellableDebuffs = false,
                showRaidInstanceDebuffs = true,
                auraTooltipInCombat = "IN_COMBAT",
                unitHealth = "NONE",
                anchorFromCenter = false,
                wideSorting = true,
                groupBy = "ROLE",
                sortDirection = "ASC",
                sortMethod = "NAME",
                horizontalSpacing = 2,
                verticalSpacing = 2,
                groupSpacing = 0,
                showRoleIcon = false, -- always
                showTankIcon = false, -- always
                showLeaderIcon = false, -- always
                shortHealthValues = false,
                showAbsorbBar = true,
                debuffFilter = CopyTable(GridAuraFilter),
                buffFilter = CopyTable(GridAuraFilter),
                ignoredAuras = CopyTable(GridIgnoredAuras),
                pandemicHighlight = true,
                dispelIcon = "DISPELLABLE",
                showBuffs = false,
                showPowerBar = "NONE", -- always
                healthBarTexture = "GW2_UI_2_DEFAULT",
                groupByClassOrder = {"DEATHKNIGHT,DEMONHUNTER,DRUID,EVOKER,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK"},
            },
            raidPet = {
                -- Raid Pet
                enabled = false,
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 315,
                    yOfs = -60,
                    hasMoved = false,
                },
                height = 25,
                faderRange = true,
                fader = CopyTable(UnitFrameFader),
                classColor = true, -- always
                hideClassIcon = false, -- always
                unitFlags = "NONE", -- always
                unitMarkers = false,
                width = 50,
                groupsPerColumn = 1,
                grow = "DOWN+RIGHT",
                showDebuffs = true,
                onlyDispellableDebuffs = false,
                showRaidInstanceDebuffs = true,
                auraTooltipInCombat = "IN_COMBAT",
                unitHealth = "NONE",
                anchorFromCenter = false,
                wideSorting = true,
                groupBy = "ROLE",
                sortDirection = "ASC",
                sortMethod = "NAME",
                horizontalSpacing = 2,
                verticalSpacing = 2,
                groupSpacing = 0,
                showRoleIcon = false, -- always
                showTankIcon = false, -- always
                showLeaderIcon = false, -- always
                shortHealthValues = false,
                showAbsorbBar = true,
                debuffFilter = CopyTable(GridAuraFilter),
                buffFilter = CopyTable(GridAuraFilter),
                ignoredAuras = CopyTable(GridIgnoredAuras),
                pandemicHighlight = true,
                dispelIcon = "DISPELLABLE",
                showBuffs = false,
                showPowerBar = "NONE", -- always
                healthBarTexture = "GW2_UI_2_DEFAULT",
                groupByClassOrder = {"DEATHKNIGHT,DEMONHUNTER,DRUID,EVOKER,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK"},
            },
            maintank = {
                -- Maintank
                enabled = true,
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 315,
                    yOfs = -60,
                    hasMoved = false,
                },
                height = 28,
                faderRange = true,
                fader = CopyTable(UnitFrameFader),
                classColor = true,
                hideClassIcon = false,
                unitFlags = "NONE",
                unitMarkers = false,
                width = 120,
                groupsPerColumn = 1,
                grow = "DOWN+RIGHT",
                showDebuffs = true,
                onlyDispellableDebuffs = false,
                showRaidInstanceDebuffs = true,
                auraTooltipInCombat = "IN_COMBAT",
                unitHealth = "NONE",
                anchorFromCenter = false, -- always
                wideSorting = true, -- always
                groupBy = "ROLE", -- always
                sortDirection = "ASC", -- always
                sortMethod = "NAME", -- always
                horizontalSpacing = 2,
                verticalSpacing = 2,
                groupSpacing = 0, -- always
                showRoleIcon = true,
                showTankIcon = true,
                showLeaderIcon = true,
                shortHealthValues = false,
                showAbsorbBar = true,
                debuffFilter = CopyTable(GridAuraFilter),
                buffFilter = CopyTable(GridAuraFilter),
                ignoredAuras = CopyTable(GridIgnoredAuras),
                pandemicHighlight = true,
                dispelIcon = "DISPELLABLE",
                showBuffs = false,
                showPowerBar = "NONE", -- always
                healthBarTexture = "GW2_UI_2_DEFAULT",
                groupByClassOrder = {"DEATHKNIGHT,DEMONHUNTER,DRUID,EVOKER,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK"},
            },
            raidDebuffsScale = 1,
            dispelDebuffsScale = 1,
            debuffScalePriority = "DISPELL",
            indicators = {
                icon = false,
                time = true,
                size = 13,
                barWidth = 2,
                stacks = true,
                positions = {
                    BAR = 0,
                    TOPLEFT = 0,
                    TOP = 0,
                    TOPRIGHT = 0,
                    LEFT = 0,
                    CENTER = 0,
                    RIGHT = 0,
                },
            },
        },

        objectives = {
            enabled = true,
            pos = {
                point = "TOPRIGHT",
                relativePoint = "TOPRIGHT",
                xOfs = 0,
                yOfs = 0,
                hasMoved = false,
            },
            scale = 1,
            height = 700,
            -- reset settings
            autoCollapse = {
                MythicPlus = false,
                Raid = false,
                Party = false,
                Delve = false,
                Combat = false,
            },
            compass = true,
            statusBars = true,
            superTrackedOnTop = false,
            showCompleted = false,
            compactMode = false,
            spacing = 1,
            moduleOrder = {"Achievement", "Campaign", "Quests", "Bonus", "Recipe", "MonthlyActivity", "Collection", "HousingInitiative", "WQT", "PetTracker", "Todoloo"},
            showXp = true,
            sorting = "DEFAULT",
        },

        immersiveQuesting = {
            enabled = true,
            lockFrame = false,
            scale = 1,
            showHelmet = true,
            playerScale = 1,
            weaponMode = "STOW",
            titleStyle = "DEFAULT",
            clickAccept = true,
        },
        micromenu = {
            enabled = true,
            pos = {
                point = "TOPLEFT",
                relativePoint = "TOPLEFT",
                xOfs = 0,
                yOfs = 1,
                hasMoved = false,
            },
            scale = 1,
            orientation = "HORIZONTAL",
            -- slot keys in the user's order, empty = default order
            buttonOrder = {},
            -- [slot key] = false for hidden buttons
            buttonVisibility = {},
            notificationIconAnimation = true,
            showBackground = true,
            fade = false,
            eventTimerIcon = false,
            -- chat notice and flash when a newer version is seen
            updateNotification = true,
        },

        notifications = {
            enabled = true,
            pos = {
                point = "BOTTOMRIGHT",
                relativePoint = "BOTTOMRIGHT",
                xOfs = 0,
                yOfs = 300,
                hasMoved = false,
            },
            levelUp = {
                enabled = true,
                sound = "None",
            },
            newSpell = {
                enabled = true,
                sound = "None",
            },
            newMail = {
                enabled = true,
                sound = "None",
            },
            repair = {
                enabled = true,
                sound = "None",
            },
            paragon = {
                enabled = true,
                sound = "None",
            },
            rare = {
                enabled = true,
                sound = "None",
                chat = false,
                -- vignettes that are no rares but use a rare atlas; [vignetteID] = true, the name is filled in once the
                -- vignette is seen (the client has no lookup by id), removed entries hold false
                ignored = {
                    [4024] = true, -- Soul Cage (The Maw and Torghast)
                    [4578] = true, -- Gateway to Hero's Rest (Bastion)
                    [4583] = true, -- Gateway to Hero's Rest (Bastion)
                    [4553] = true, -- Recoverable Corpse (The Maw)
                    [4581] = true, -- Grappling Growth (Maldraxxus)
                    [4582] = true, -- Ripe Purian (Bastion)
                    [4602] = true, -- Aimless Soul (The Maw)
                    [4617] = true, -- Imprisoned Soul (The Maw)
                    [5020] = true, -- Console (Zereth Mortis)
                    [5485] = true, -- Tuskarr Tacklebox (Dragon Isles)
                },
            },
            bagsFull = {
                enabled = true,
                sound = "None",
            },
            greatVault = {
                enabled = true,
                sound = "None",
            },
            calendarInvite = {
                enabled = true,
                sound = "None",
            },
            callToArms = {
                enabled = true,
                sound = "None",
            },
            mageTable = {
                enabled = true,
                sound = "None",
            },
            ritualOfSummoning = {
                enabled = true,
                sound = "None",
            },
            soulwell = {
                enabled = true,
                sound = "None",
            },
            magePortal = {
                enabled = true,
                sound = "None",
            },
        },

        widgets = {
            topCenter = {
                pos = {
                    point = "TOP",
                    relativePoint = "TOP",
                    xOfs = 0,
                    yOfs = -30,
                    hasMoved = false,
                },
                scale = 1,
            },
            powerBarContainer = {
                pos = {
                    point = "TOP",
                    relativePoint = "TOP",
                    xOfs = 0,
                    yOfs = -75,
                    hasMoved = false,
                },
                scale = 1,
            },
            belowMinimapContainer = {
                pos = {
                    point = "TOPRIGHT",
                    relativePoint = "TOPRIGHT",
                    xOfs = -430,
                    yOfs = -130,
                    hasMoved = false,
                },
                scale = 1,
            },
            eventToast = {
                pos = {
                    point = "TOP",
                    relativePoint = "TOP",
                    xOfs = 0,
                    yOfs = -150,
                    hasMoved = false,
                },
                scale = 1,
            },
            ticketStatus = {
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 250,
                    yOfs = -5,
                    hasMoved = false,
                },
                scale = 1,
            },
            bossBanner = {
                pos = {
                    point = "TOP",
                    relativePoint = "TOP",
                    xOfs = 0,
                    yOfs = -125,
                    hasMoved = false,
                },
                scale = 1,
            },
        },

        skins = {
            lootFrame = {
                enabled = true,
                pos = {
                    point = "LEFT",
                    relativePoint = "LEFT",
                    xOfs = 20,
                    yOfs = -45,
                    hasMoved = false,
                },
                scale = 1,
            },
            worldmap = {
                enabled = true,
                pos = {
                    point = "CENTER",
                    relativePoint = "CENTER",
                    xOfs = 0,
                    yOfs = 0,
                    hasMoved = false,
                },
                scale = 1,
            },
            mail = {
                enabled = true,
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 16,
                    yOfs = -116,
                    hasMoved = false,
                },
            },
            bnToast = {
                enabled = true,
                pos = {
                    point = "BOTTOM",
                    relativePoint = "BOTTOMLEFT",
                    xOfs = 78,
                    yOfs = 246,
                    hasMoved = false,
                },
                scale = 1,
            },
            talkingHead = {
                enabled = true,
                scale = 0.9,
            },
            adventureMap = {
                enabled = true,
            },
            achievement = {
                enabled = true,
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 96,
                    yOfs = -115,
                },
            },
            mainMenu = {
                enabled = true,
            },
            staticPopup = {
                enabled = true,
            },
            deathRecap = {
                enabled = true,
            },
            dropdown = {
                enabled = true,
            },
            lfgFrames = {
                enabled = true,
            },
            readyCheck = {
                enabled = true,
            },
            misc = {
                enabled = true,
            },
            immersion = {
                enabled = true,
            },
            auctionator = {
                enabled = true,
            },
            extendedSets = {
                enabled = true,
            },
            flightMap = {
                enabled = true,
            },
            addonList = {
                enabled = true,
            },
            blizzardOptions = {
                enabled = true,
            },
            macro = {
                enabled = true,
            },
            barberShop = {
                enabled = true,
            },
            inspection = {
                enabled = true,
            },
            dressUp = {
                enabled = true,
            },
            helpFrame = {
                enabled = true,
            },
            wqt = {
                enabled = true,
            },
            petTracker = {
                enabled = true,
            },
            todoloo = {
                enabled = true,
            },
            socket = {
                enabled = true,
            },
            gossip = {
                enabled = true,
            },
            questLog = {
                enabled = true,
            },
            itemUpgrade = {
                enabled = true,
            },
            timeManager = {
                enabled = true,
            },
            merchant = {
                enabled = true,
            },
            encounterJournal = {
                enabled = true,
            },
            collections = {
                enabled = true,
            },
            covenantSanctum = {
                enabled = true,
            },
            soulbinds = {
                enabled = true,
            },
            chromieTime = {
                enabled = true,
            },
            alliedRaces = {
                enabled = true,
            },
            weeklyRewards = {
                enabled = true,
            },
            lfg = {
                enabled = true,
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 70,
                    yOfs = -150,
                },
            },
            orderHallTalents = {
                enabled = true,
            },
            alertFrame = {
                enabled = true,
            },
            perkProgram = {
                enabled = true,
            },
            expansionLandingPage = {
                enabled = true,
            },
            genericTraits = {
                enabled = true,
            },
            playerSpells = {
                enabled = true,
            },
            auctionHouse = {
                enabled = true,
                pos = {
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    xOfs = 70,
                    yOfs = -150,
                },
            },
            battlefieldMap = {
                enabled = true,
            },
            majorFaction = {
                enabled = true,
            },
            cooldownManager = {
                enabled = true,
            },
            damageMeter = {
                enabled = true,
            },
            calendar = {
                enabled = true,
            },
            questTimers = {
                enabled = true,
                pos = {
                    point = "TOPRIGHT",
                    relativePoint = "TOPRIGHT",
                    xOfs = -305,
                    yOfs = -0,
                    hasMoved = false,
                },
                scale = 1,
            },
        },

        weeklyEvents = {
            -- Midnight
            weeklyMN = {
                enabled = true,
                desaturate = false,
            },
            professionsWeeklyMN = {
                enabled = true,
                desaturate = false,
            },
            stormarionAssault = {
                enabled = true,
                desaturate = false,
                alert = true,
                alertSeconds = 300,
                stopAlertIfCompleted = true,
                flashTaskbar = true,
            },
            cursedSurges = {
                enabled = true,
                desaturate = false,
                alert = true,
                alertSeconds = 300,
                stopAlertIfCompleted = true,
                flashTaskbar = true,
            },
            -- TWW
            weeklyTWW = {
                enabled = false,
                desaturate = false,
            },
            ecologicalSuccession = {
                enabled = false,
                desaturate = false,
            },
            nightFall = {
                enabled = false,
                desaturate = false,
            },
            ringingDeeps = {
                enabled = false,
                desaturate = false,
            },
            spreadingTheLight = {
                enabled = false,
                desaturate = false,
            },
            underworldOperative = {
                enabled = false,
                desaturate = false,
            },
            theaterTroupe = {
                enabled = false,
                desaturate = false,
                alert = false,
                alertSeconds = 300,
                stopAlertIfCompleted = true,
                flashTaskbar = true,
            },
            -- DF
            communityFeast = {
                enabled = false,
                desaturate = false,
                alert = false,
                alertSeconds = 300,
                stopAlertIfCompleted = true,
                flashTaskbar = true,
            },
            dragonbaneKeep = {
                enabled = false,
                desaturate = false,
                alert = false,
                alertSeconds = 300,
                stopAlertIfCompleted = true,
                flashTaskbar = true,
            },
            researchersUnderFire = {
                enabled = false,
                desaturate = false,
                alert = false,
                alertSeconds = 300,
                stopAlertIfCompleted = true,
                flashTaskbar = true,
            },
            timeRiftThaldraszus = {
                enabled = false,
                desaturate = false,
                alert = false,
                alertSeconds = 300,
                stopAlertIfCompleted = true,
                flashTaskbar = true,
            },
            superBloom = {
                enabled = false,
                desaturate = false,
                alert = false,
                alertSeconds = 300,
                stopAlertIfCompleted = true,
                flashTaskbar = true,
            },
            bigDig = {
                enabled = false,
                desaturate = false,
                alert = false,
                alertSeconds = 300,
                stopAlertIfCompleted = true,
                flashTaskbar = true,
            },
        },
    }
}

Mixin(GW.globalDefault.profile.playerAuras.buffs, CopyTable(PlayerAuraSettings))
Mixin(GW.globalDefault.profile.playerAuras.debuffs, CopyTable(PlayerAuraSettings))


-- grid aura filter defaults: buffs = own raid HoTs, debuffs = important ones
-- (dispellable debuffs always render through their own grid group)
for _, gridProfile in next, { "party", "raid40", "raid25", "raid10" } do
    local grid = GW.globalDefault.profile.groupFrames[gridProfile]
    grid.buffFilter.isAuraPlayer = true
    grid.buffFilter.isAuraRaidInCombat = true
    grid.debuffFilter.isAuraImportant = true
end

-- game default:
if GW.Retail or GW.Mists then
    GW.globalDefault.profile.stanceBar.visibility = "[vehicleui][petbattle] hide; show"
elseif GW.Wrath then
    GW.globalDefault.profile.stanceBar.visibility = "[vehicleui] hide; show"
else
    GW.globalDefault.profile.stanceBar.visibility = "show"
end

