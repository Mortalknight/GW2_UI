local _, GW = ...
local L = GW.L

local LibCustomGlow = GW.Libs.CustomGlows
local ALPHA = 0.3

-- tables
local checkIds = {}
local buffInfos = {}

local reminderBuffs = {
    Flask = {
        -- Dragonflight
        [1] = 370652, -- Phial of Static Empowerment
        [2] = 370661, -- Phial of Icy Preservation
		[3] = 371172, -- Phial of Tepid Versatility
		[4] = 371186, -- Charged Phial of Alacrity
		[5] = 371204, -- Phial of Still Air
		[6] = 371339, -- Phial of Elemental Chaos
		[7] = 371354, -- Phial of the Eye in the Storm
		[8] = 371386, -- Phial of Charged Isolation
		[9] = 373257, -- Phial of Glacial Fury
		[10] = 374000, -- Iced Phial of Corrupting Rage
    },
    DefiledAugmentRune = {
        [1] = 224001,			-- Defiled Augumentation (15 primary stat)
        [2] = 270058,			-- Battle Scarred Augmentation (60 primary stat)
        [3] = 347901,			-- Veiled Augmentation (18 primary stat)
        [4] = 367405,           -- Eternal Augment Rune
    },
    Food = {
        [1] = 104280,	-- Well Fed

        -- Shadowlands
        [2] = 259455,	-- Well Fed
        [3] = 308434,	-- Well Fed
        [4] = 308488,	-- Well Fed
        [5] = 308506,	-- Well Fed
        [6] = 308514,	-- Well Fed
        [7] = 308637,	-- Well Fed
        [8] = 327715,	-- Well Fed
        [9] = 327851,	-- Well Fed

        -- DF
        [10] = 382149,	-- Well Fed
        [11] = 396092,	-- Well Fed
        [12] = 327708,	-- Well Fed
        [13] = 457284,	-- Well Fed
    },
    Intellect = {
        [1] = 1459, -- Arcane Intellect
        [2] = 264760, -- War-Scroll of Intellect
    },
    Stamina = {
        [1] = 21562, -- Power Word: Fortitude
        [2] = 6307, -- Blood Pact
        [3] = 264764, -- War-Scroll of Fortitude
    },
    AttackPower = {
        [1] = 6673, -- Battle Shout
        [2] = 264761, -- War-Scroll of Battle
    },
    Versatility = {
		[1] = 1126,    -- Mark of the Wild
	},
    Mastery = {
        [1] = 462854,  -- Skyfury
    },
    MovementBuff = {
        [1] = 381752, -- Evoker
        [2] = 381732, -- Evoker
        [3] = 381741, -- Evoker
        [4] = 381746, -- Evoker
        [5] = 381748, -- Evoker
        [6] = 381749, -- Evoker
        [7] = 381750, -- Evoker
        [8] = 381751, -- Evoker
        [9] = 381753, -- Evoker
        [10] = 381754, -- Evoker
        [11] = 381756, -- Evoker
        [12] = 381757, -- Evoker
        [13] = 381758, -- Evoker
    },
    Weapon = { -- EnchantsID
        [1] = nil,
    },
    Custom = {
        -- spellID,	-- Spell Info
    },
}

local ButtonMixin = {}

function ButtonMixin:Init(parent, anchor, isFirst)
    self:SetSize(28, 28)
    if isFirst then
        self:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 2, 2)
    else
        self:SetPoint("LEFT", anchor, "RIGHT", 3, 0)
    end
    self:SetFrameLevel(parent:GetFrameLevel() + 10)

    self.icon = self:CreateTexture(nil, "OVERLAY")
    self.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.icon:SetPoint("TOPLEFT", 2, -2)
    self.icon:SetPoint("BOTTOMRIGHT", -2, 2)

    -- Setze Standard-Pushed/Highlight Texturen
    self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed")
    self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
end

function ButtonMixin:UpdateStyle(haveBuff, settings, glowLib, classColor)
    if not haveBuff then
        self.icon:SetDesaturated(settings.MISSING_RAID_BUFF_INVERT and settings.MISSING_RAID_BUFF_grayed_out or false)
        self:SetAlpha((not settings.MISSING_RAID_BUFF_INVERT and 1) or (settings.MISSING_RAID_BUFF_dimmed and ALPHA or 1))
        if settings.MISSING_RAID_BUFF_animated then
            glowLib.ButtonGlow_Start(self, {classColor.r, classColor.g, classColor.b, 1}, nil, -0.25, nil, 1)
        else
            glowLib.ButtonGlow_Stop(self)
        end
    else
        self.icon:SetDesaturated(settings.MISSING_RAID_BUFF_INVERT and false or settings.MISSING_RAID_BUFF_grayed_out)
        self:SetAlpha((settings.MISSING_RAID_BUFF_INVERT and 1) or (settings.MISSING_RAID_BUFF_dimmed and ALPHA or 1))
        glowLib.ButtonGlow_Stop(self)
    end
end

function ButtonMixin:UpdateForType(buffType)
    local found = false
    local buffTbl = buffInfos[buffType]
    if buffTbl then
        for _, buff in ipairs(buffTbl) do
            if buff.hasBuff then
                self.icon:SetTexture(buff.texId)
                found = true
                break
            end
        end
        if not found then
            self.icon:SetTexture(buffTbl[1] and buffTbl[1].texId or nil)
        end
        self:UpdateStyle(found, GW.settings, LibCustomGlow, self:GetParent().classColor)
    end
end

local RaidBuffReminderMixin = {}

function RaidBuffReminderMixin:OnLoad()
    -- Setze Klassenfarbe
    self.classColor = GW.GWGetClassColor(GW.myclass, true)
    -- Initialisiere BuffInfos
    self:UpdateBuffInfos()

    -- Erstelle Buttons und mische ButtonMixin ein
    self.intButton = CreateFrame("Button", nil, self)
    Mixin(self.intButton, ButtonMixin)
    self.intButton:Init(self, self, true)

    self.staminaButton = CreateFrame("Button", nil, self)
    Mixin(self.staminaButton, ButtonMixin)
    self.staminaButton:Init(self, self.intButton, false)

    self.attackPowerButton = CreateFrame("Button", nil, self)
    Mixin(self.attackPowerButton, ButtonMixin)
    self.attackPowerButton:Init(self, self.staminaButton, false)

    self.versatilityButton = CreateFrame("Button", nil, self)
    Mixin(self.versatilityButton, ButtonMixin)
    self.versatilityButton:Init(self, self.attackPowerButton, false)

    self.movementButton = CreateFrame("Button", nil, self)
    Mixin(self.movementButton, ButtonMixin)
    self.movementButton:Init(self, self.versatilityButton, false)

    self.masteryButton = CreateFrame("Button", nil, self)
    Mixin(self.masteryButton, ButtonMixin)
    self.masteryButton:Init(self, self.movementButton, false)

    self.flaskButton = CreateFrame("Button", nil, self)
    Mixin(self.flaskButton, ButtonMixin)
    self.flaskButton:Init(self, self.masteryButton, false)

    self.foodButton = CreateFrame("Button", nil, self)
    Mixin(self.foodButton, ButtonMixin)
    self.foodButton:Init(self, self.flaskButton, false)

    self.daRuneButton = CreateFrame("Button", nil, self)
    Mixin(self.daRuneButton, ButtonMixin)
    self.daRuneButton:Init(self, self.foodButton, false)

    self.customButton = CreateFrame("Button", nil, self)
    Mixin(self.customButton, ButtonMixin)
    self.customButton:Init(self, self.daRuneButton, false)
end

function RaidBuffReminderMixin:UpdateBuffInfos()
    -- Füllt die buffInfos-Tabelle basierend auf reminderBuffs
    for key, tbl in pairs(reminderBuffs) do
        buffInfos[key] = {}
        if type(tbl) == "table" then
            for idx, spellID in pairs(tbl) do
                local spellInfo = C_Spell.GetSpellInfo(spellID)
                if spellInfo then
                    buffInfos[key][idx] = {
                        name    = spellInfo.name,
                        texId   = (key == "Weapon") and GetInventoryItemTexture("player", 16) or spellInfo.iconID,
                        spellId = spellID,
                        hasBuff = false
                    }
                end
            end
        end
    end
end

function RaidBuffReminderMixin:CheckForBuffs()
    local auraData, foundBuff
    local hasMainHandEnchant, mainHandEnchantID, hasOffHandEnchant, offHandEnchantID
    wipe(checkIds)
    -- Reset Buff-Status
    for key, tbl in pairs(buffInfos) do
        if type(tbl) == "table" then
            for idx, _ in pairs(tbl) do
                buffInfos[key][idx].hasBuff = false
            end
        end
    end

    for i = 1, 40 do
        auraData = C_UnitAuras.GetBuffDataByIndex("player", i)
        if not auraData then break end

        for key, tbl in pairs(buffInfos) do
            if type(tbl) == "table" then
                foundBuff = false
                for idx, buff in pairs(tbl) do
                    if key == "Weapon" then
                        hasMainHandEnchant, _, _, mainHandEnchantID, hasOffHandEnchant, _, _, offHandEnchantID = GetWeaponEnchantInfo()
                        if (hasMainHandEnchant and buff.spellId == mainHandEnchantID) or (hasOffHandEnchant and buff.spellId == offHandEnchantID) then
                            buff.hasBuff = true
                            checkIds[mainHandEnchantID or offHandEnchantID] = true
                            foundBuff = true
                            break
                        end
                    else
                        if buff.spellId == auraData.spellId then
                            buff.hasBuff = true
                            checkIds[auraData.spellId] = true
                            foundBuff = true
                            break
                        end
                    end
                end
                if foundBuff then break end
            end
        end

        if not checkIds[auraData.spellId or mainHandEnchantID or offHandEnchantID] then
            checkIds[auraData.spellId or mainHandEnchantID or offHandEnchantID] = true
        end
    end
end

function RaidBuffReminderMixin:UpdateButtons()
    if not self:IsShown() then return end
    self:CheckForBuffs()

    self.flaskButton:UpdateForType("Flask")
    self.foodButton:UpdateForType("Food")
    self.intButton:UpdateForType("Intellect")
    self.staminaButton:UpdateForType("Stamina")
    self.attackPowerButton:UpdateForType("AttackPower")
    self.versatilityButton:UpdateForType("Versatility")
    self.movementButton:UpdateForType("MovementBuff")
    self.masteryButton:UpdateForType("Mastery")
    self.daRuneButton:UpdateForType("DefiledAugmentRune")

    if #buffInfos.Custom > 0 then
        self:SetSize(309, 32)
        self.customButton.icon:SetTexture(buffInfos.Custom[1].texId)
        if not self.customButton:IsShown() then self.customButton:Show() end
        self.customButton:UpdateStyle(buffInfos.Custom[1].hasBuff, GW.settings, LibCustomGlow, self.classColor)
    else
        self:SetSize(280, 32)
        self.customButton:Hide()
        LibCustomGlow.PixelGlow_Stop(self.customButton)
    end
end

function RaidBuffReminderMixin:OnEvent()
    self:UpdateButtons()
end

function RaidBuffReminderMixin:UpdateCustomSpell()
    wipe(buffInfos.Custom)
    local keywords = gsub(GW.settings.MISSING_RAID_BUFF_custom_id, ",%s", ",")
    for str in string.gmatch(keywords, "[^,]+") do
        if str ~= "" then
            local spellID = tonumber(str)
            local spellInfo = C_Spell.GetSpellInfo(spellID)
            if spellInfo then
                buffInfos.Custom[1] = {
                    name    = spellInfo.name,
                    texId   = spellInfo.iconID,
                    spellId = spellID,
                    hasBuff = false
                }
            end
            break
        end
    end
    self:UpdateButtons()
end

function RaidBuffReminderMixin:UpdateVisibility()
    local VisibilityStates = {
        ["NEVER"]         = "hide",
        ["ALWAYS"]        = "[petbattle] hide; show",
        ["IN_GROUP"]      = "[petbattle] hide; [group:raid] hide; [group:party] show; hide",
        ["IN_RAID"]       = "[petbattle] hide; [group:raid] show; [group:party] hide; hide",
        ["IN_RAID_IN_PARTY"] = "[petbattle] hide; [group] show; hide",
    }
    RegisterStateDriver(self, "visibility", VisibilityStates[GW.settings.MISSING_RAID_BUFF])
end

local function LoadRaidbuffReminder()
    local rbr = CreateFrame("Frame", "GwRaidBuffReminder", UIParent)
    Mixin(rbr, RaidBuffReminderMixin)
    rbr:OnLoad()

    rbr:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    rbr:SetSize(210, 32)
    GW.RegisterMovableFrame(rbr, L["Missing Raid Buffs Bar"], "MISSING_RAID_BUFF_pos", ALL .. ",Raid,Aura", nil, {"default", "scaleable"})
    rbr:ClearAllPoints()
    rbr:SetPoint("TOPLEFT", rbr.gwMover)

    rbr:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
    rbr:RegisterUnitEvent("UNIT_AURA", "player")
    rbr:RegisterEvent("PLAYER_ENTERING_WORLD")
    rbr:SetScript("OnEvent", rbr.OnEvent)

    rbr:UpdateBuffInfos()
    rbr:UpdateVisibility()
    rbr:UpdateCustomSpell()

    return rbr
end
GW.LoadRaidbuffReminder = LoadRaidbuffReminder
