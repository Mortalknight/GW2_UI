local _, GW = ...
local L = GW.L

local LibCustomGlow = GW.Libs.CustomGlows
local ALPHA = 0.3

-- tables
local buffInfos = {}

local reminderBuffs = {
    Flask = {
        -- TWW
        431971, -- Flask of Tempered Aggression
        431972, -- Flask of Tempered Swiftness
        431973, -- Flask of Tempered Versatility
        431974, -- Flask of Tempered Mastery
        432021, -- Flask of Alchemical Chaos
        432021, -- Flask of Alchemical Chaos
        432473, -- Flask of Saving Graces
    },
    DefiledAugmentRune = {
        393438, -- Dreambound Augment Rune
        453250, -- Crystallized Augment Rune
    },
    Food = {
    -- Well Fed
        104280,
        461957, -- (Mastery)
        461958, -- (Vers)
        461959, -- (Crit)
        461960, -- (Haste)
        -- Hearty Well Fed
        462180, -- (Haste)
        462181, -- (Crit)
        462182, -- (Vers)
        462183, -- (Mastery)
        462210, -- (Primary Stat)
        -- Delve
        442522,	-- Delve
    },
    Intellect = {
        1459, -- Arcane Intellect
    },
    Stamina = {
        21562, -- Power Word: Fortitude
    },
    AttackPower = {
        6673, -- Battle Shout
    },
    Versatility = {
        1126, -- Mark of the Wild
    },
    Mastery = {
        462854, -- Skyfury
    },
    CooldownReduce = {
        381748, -- Blessing of the Bronze
    },
    Weapon = {
        1, -- just a fallback
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
    self:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed.png")
    self:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png")
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
    self.classColor = GW.GWGetClassColor(GW.myclass, true)
    self:UpdateBuffInfos()

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

    self.CooldownReduce = CreateFrame("Button", nil, self)
    Mixin(self.CooldownReduce, ButtonMixin)
    self.CooldownReduce:Init(self, self.versatilityButton, false)

    self.masteryButton = CreateFrame("Button", nil, self)
    Mixin(self.masteryButton, ButtonMixin)
    self.masteryButton:Init(self, self.CooldownReduce, false)

    self.flaskButton = CreateFrame("Button", nil, self)
    Mixin(self.flaskButton, ButtonMixin)
    self.flaskButton:Init(self, self.masteryButton, false)

    self.foodButton = CreateFrame("Button", nil, self)
    Mixin(self.foodButton, ButtonMixin)
    self.foodButton:Init(self, self.flaskButton, false)

    self.DefiledAugmentRune = CreateFrame("Button", nil, self)
    Mixin(self.DefiledAugmentRune, ButtonMixin)
    self.DefiledAugmentRune:Init(self, self.foodButton, false)

    self.customButton = CreateFrame("Button", nil, self)
    Mixin(self.customButton, ButtonMixin)
    self.customButton:Init(self, self.CooldownReduce, false)
end

function RaidBuffReminderMixin:UpdateBuffInfos()
    for key, tbl in pairs(reminderBuffs) do
        buffInfos[key] = {}
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

function RaidBuffReminderMixin:CheckForBuffs()
    -- Reset Buff-Status
    for _, tbl in pairs(buffInfos) do
        for _, buff in pairs(tbl) do
            buff.hasBuff = false
        end
    end

    for key, tbl in pairs(buffInfos) do
        for _, buff in pairs(tbl) do
            if key == "Weapon" then
                local hasMainHandEnchant, _, _, mainHandEnchantID, hasOffHandEnchant, _, _, offHandEnchantID = GetWeaponEnchantInfo()
                if (hasMainHandEnchant and buff.spellId == mainHandEnchantID) or (hasOffHandEnchant and buff.spellId == offHandEnchantID) then
                    buff.hasBuff = true
                    break
                end
            elseif C_UnitAuras.GetAuraDataBySpellName("player", buff.name) then
                buff.hasBuff = true
                break
            end
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
    self.CooldownReduce:UpdateForType("CooldownReduce")
    self.masteryButton:UpdateForType("Mastery")
    self.DefiledAugmentRune:UpdateForType("DefiledAugmentRune")

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

    self:UpdateButtons()
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
