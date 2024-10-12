local _, GW = ...
local L = GW.L

local LibCustomGlow = GW.Libs.CustomGlows
local ALPHA = 0.3
local classColor

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
        --[12] = 382149,	-- Well Fed
        --[13] = 382149,	-- Well Fed
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
		1126, -- Mark of the Wild
	},
    Mastery = {
        462854, -- Skyfury
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

local function GetBuffInfos()
    local spellInfo
    for k, v in pairs(reminderBuffs) do
        buffInfos[k] = {}
        if type(v) == "table" then
            for sk, id in pairs(v) do
                spellInfo = C_Spell.GetSpellInfo(id)
                if spellInfo then
                    buffInfos[k][sk] = {name = spellInfo.name, texId = spellInfo.iconID, spellId = id, hasBuff = false}
                    if k == "Weapon" then
                        buffInfos[k][sk].texId = GetInventoryItemTexture("player", 16)
                    end
                end
            end
        end
    end
end

local function CheckForBuffs()
    local auraData, foundBuff
    local hasMainHandEnchant, mainHandEnchantID, hasOffHandEnchant, offHandEnchantId
    wipe(checkIds)

    -- reset all spells
    for k, v in pairs(buffInfos) do
        if type(v) == "table" then
            for sk, _ in pairs(v) do
                buffInfos[k][sk].hasBuff = false
            end
        end
    end

    for i = 1, 40 do
        foundBuff = false
        auraData = C_UnitAuras.GetBuffDataByIndex("player", i)
        if not auraData then
            break
        else
            for k, v in pairs(buffInfos) do
                if type(v) == "table" then
                    for sk, _ in pairs(v) do
                        if k == "Weapon" then
                            hasMainHandEnchant, _, _, mainHandEnchantID, hasOffHandEnchant, _, _, offHandEnchantId = GetWeaponEnchantInfo()
                            if (hasMainHandEnchant and buffInfos[k][sk].spellId == mainHandEnchantID) or (hasOffHandEnchant and buffInfos[k][sk].spellId == offHandEnchantId) then
                                buffInfos[k][sk].hasBuff = true
                                checkIds[mainHandEnchantID or offHandEnchantId] = true
                                foundBuff = true
                                break
                            end
                        else
                            if buffInfos[k][sk].spellId == auraData.spellId then
                                buffInfos[k][sk].hasBuff = true
                                checkIds[auraData.spellId] = true
                                foundBuff = true
                                break

                            end
                        end
                    end
                    if foundBuff then
                        break
                    end
                end
            end

            if not checkIds[auraData.spellId or mainHandEnchantID or offHandEnchantId] then
                checkIds[auraData.spellId or mainHandEnchantID or offHandEnchantId] = true
            end
        end
    end
end

local function setButtonStyle(button, haveBuff)
    if not haveBuff then
        button.icon:SetDesaturated(GW.settings.MISSING_RAID_BUFF_INVERT and GW.settings.MISSING_RAID_BUFF_grayed_out or false)
        button:SetAlpha(not GW.settings.MISSING_RAID_BUFF_INVERT and 1 or GW.settings.MISSING_RAID_BUFF_dimmed and ALPHA or 1)
        if GW.settings.MISSING_RAID_BUFF_animated then
            LibCustomGlow.ButtonGlow_Start(button, {classColor.r, classColor.g, classColor.b, 1}, nil, -0.25, nil, 1)
        else
            LibCustomGlow.ButtonGlow_Stop(button)
        end
    else
        if GW.settings.MISSING_RAID_BUFF_INVERT then
            button.icon:SetDesaturated(false)
        else
            button.icon:SetDesaturated(GW.settings.MISSING_RAID_BUFF_grayed_out)
        end

        button:SetAlpha(GW.settings.MISSING_RAID_BUFF_INVERT and 1 or GW.settings.MISSING_RAID_BUFF_dimmed and ALPHA or 1)
        LibCustomGlow.ButtonGlow_Stop(button)
    end
end

local function OnAuraChange(self)
    local foundBuff = false
    -- check if we have a matching buff
    CheckForBuffs()

    -- Flask
    for _, flask in pairs(buffInfos.Flask) do
        if flask.hasBuff then
            self.flaskButton.icon:SetTexture(flask.texId)
            foundBuff = true
            break
        end
    end
    if not foundBuff then
        self.flaskButton.icon:SetTexture(buffInfos.Flask[1].texId)
    end
    setButtonStyle(self.flaskButton, foundBuff)

    -- Food
    foundBuff = false
    for _, foodbuff in pairs(buffInfos.Food) do
        if foodbuff.hasBuff then
            self.foodButton.icon:SetTexture(foodbuff.texId)
            foundBuff = true
            break
        end
    end
    if not foundBuff then
        self.foodButton.icon:SetTexture(buffInfos.Food[1].texId)
    end
    setButtonStyle(self.foodButton, foundBuff)

    -- Int
    foundBuff = false
    for _, intellectbuff in pairs(buffInfos.Intellect) do
        if intellectbuff.hasBuff then
            self.intButton.icon:SetTexture(intellectbuff.texId)
            foundBuff = true
            break
        end
    end
    if not foundBuff then
        self.intButton.icon:SetTexture(buffInfos.Intellect[1].texId)
    end
    setButtonStyle(self.intButton, foundBuff)

    -- Stamina
    foundBuff = false
    for _, staminabuff in pairs(buffInfos.Stamina) do
        if staminabuff.hasBuff then
            self.staminaButton.icon:SetTexture(staminabuff.texId)
            foundBuff = true
            break
        end
    end
    if not foundBuff then
        self.staminaButton.icon:SetTexture(buffInfos.Stamina[1].texId)
    end
    setButtonStyle(self.staminaButton, foundBuff)

    -- AttackPower
    foundBuff = false
    for _, attackpowerbuff in pairs(buffInfos.AttackPower) do
        if attackpowerbuff.hasBuff then
            self.attackPowerButton.icon:SetTexture(attackpowerbuff.texId)
            foundBuff = true
            break
        end
    end
    if not foundBuff then
        self.attackPowerButton.icon:SetTexture(buffInfos.AttackPower[1].texId)
    end
    setButtonStyle(self.attackPowerButton, foundBuff)

    -- Versatility
    foundBuff = false
    for _, versatilityBuff in pairs(buffInfos.Versatility) do
        if versatilityBuff.hasBuff then
            self.versatilityButton.icon:SetTexture(versatilityBuff.texId)
            foundBuff = true
            break
        end
    end
    if not foundBuff then
        self.versatilityButton.icon:SetTexture(C_Spell.GetSpellTexture(1126))
    end
    setButtonStyle(self.versatilityButton, foundBuff)

    -- MovementBuff
    foundBuff = false
    for _, movementBuff in pairs(buffInfos.MovementBuff) do
        if movementBuff.hasBuff then
            self.movementButton.icon:SetTexture(movementBuff.texId)
            foundBuff = true
            break
        end
    end
    if not foundBuff then
        self.movementButton.icon:SetTexture(buffInfos.MovementBuff[1].texId)
    end
    setButtonStyle(self.movementButton, foundBuff)

     -- Mastery
     foundBuff = false
     for _, masteryBuff in pairs(buffInfos.Mastery) do
         if masteryBuff.hasBuff then
             self.masteryButton.icon:SetTexture(masteryBuff.texId)
             foundBuff = true
             break
         end
     end
     if not foundBuff then
         self.masteryButton.icon:SetTexture(buffInfos.Mastery[1].texId)
     end
     setButtonStyle(self.masteryButton, foundBuff)

    -- runes
    foundBuff = false
    for _, runebuff in pairs(buffInfos.DefiledAugmentRune) do
        if runebuff.hasBuff then
            self.daRuneButton.icon:SetTexture(runebuff.texId)
            foundBuff = true
            break
        end
    end
    if not foundBuff and buffInfos.DefiledAugmentRune and buffInfos.DefiledAugmentRune[1] then
        self.daRuneButton.icon:SetTexture(buffInfos.DefiledAugmentRune[1].texId)
    end
    setButtonStyle(self.daRuneButton, foundBuff)

    -- Weapon
    --[[
    foundBuff = false
    for _, weaponbuff in pairs(buffInfos.Weapon) do
        if weaponbuff.hasBuff then
            self.weaponButton.icon:SetTexture(weaponbuff.texId)
            foundBuff = true
            break
        end
    end
    if not foundBuff and buffInfos.Weapon and buffInfos.Weapon[1] then
        self.weaponButton.icon:SetTexture(buffInfos.Weapon[1].texId)
    end
    setButtonStyle(self.weaponButton, foundBuff)
    ]]

    -- Custom
    if #buffInfos.Custom > 0 then
        self:SetSize(309, 32)
        self.customButton.icon:SetTexture(buffInfos.Custom[1].texId)

        if not self.customButton:IsShown() then self.customButton:Show() end
        setButtonStyle(self.customButton, buffInfos.Custom[1].hasBuff)
    else
        self:SetSize(280, 32)
        self.customButton:Hide()
        LibCustomGlow.PixelGlow_Stop(self.customButton)
    end
end
GW.UpdateMissingRaidBuffs = OnAuraChange

local function SetButtonStyle(button)
    if button.icon then
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end

    button:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed")
    button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
end

local function CreateIconBuff(relativeTo, firstbutton, frame)
    local button = CreateFrame("Button", nil, frame)
    button:SetSize(28, 28)

    if firstbutton then
        button:SetPoint("BOTTOMLEFT", relativeTo, "BOTTOMLEFT", 2, 2)
    else
        button:SetPoint("LEFT", relativeTo, "RIGHT", 3, 0)
    end
    button:SetFrameLevel(frame:GetFrameLevel() + 10)

    button.icon = button:CreateTexture(nil, "OVERLAY")
    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.icon:SetPoint("TOPLEFT", 2, -2)
    button.icon:SetPoint("BOTTOMRIGHT", -2, 2)

    SetButtonStyle(button)

    return button
end

local function UpdateMissingRaidBuffVisibility()
    local VisibilityStates = {
        ["NEVER"] = "hide",
        ["ALWAYS"] = "[petbattle] hide; show",
        ["IN_GROUP"] = "[petbattle] hide; [group:raid] hide; [group:party] show; hide",
        ["IN_RAID"] = "[petbattle] hide; [group:raid] show; [group:party] hide; hide",
        ["IN_RAID_IN_PARTY"] = "[petbattle] hide; [group] show; hide",
    }

    RegisterStateDriver(GW_RaidBuffReminder, "visibility", VisibilityStates[GW.settings.MISSING_RAID_BUFF])
end
GW.UpdateMissingRaidBuffVisibility = UpdateMissingRaidBuffVisibility

local function UpdateMissingRaidBuffCustomSpell()
	wipe(buffInfos.Custom)

	local keywords = gsub(GW.settings.MISSING_RAID_BUFF_custom_id, ",%s", ",")

	for stringValue in gmatch(keywords, "[^,]+") do
		if stringValue ~= "" then
            local spellInfo = C_Spell.GetSpellInfo(tonumber(stringValue))
            buffInfos.Custom[1] = {name = spellInfo.name, texId = spellInfo.iconID, spellId = tonumber(stringValue), hasBuff = false}
            break
		end
	end

    OnAuraChange(GW_RaidBuffReminder)
end
GW.UpdateMissingRaidBuffCustomSpell = UpdateMissingRaidBuffCustomSpell

local function LoadRaidbuffReminder()
    local rbr = CreateFrame("Frame", "GW_RaidBuffReminder", UIParent)

    classColor = GW.GWGetClassColor(GW.myclass, true)

    rbr:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)

    rbr:SetSize(210, 32)

    GW.RegisterMovableFrame(rbr, L["Missing Raid Buffs Bar"], "MISSING_RAID_BUFF_pos", ALL .. ",Raid,Aura", nil, {"default", "scaleable"})
    rbr:ClearAllPoints()
    rbr:SetPoint("TOPLEFT", rbr.gwMover)

    rbr.intButton = CreateIconBuff(rbr, true, rbr)
    rbr.staminaButton = CreateIconBuff(rbr.intButton, false, rbr)
    rbr.attackPowerButton = CreateIconBuff(rbr.staminaButton, false, rbr)
    rbr.versatilityButton = CreateIconBuff(rbr.attackPowerButton, false, rbr)
    rbr.movementButton = CreateIconBuff(rbr.versatilityButton, false, rbr)
    rbr.masteryButton = CreateIconBuff(rbr.movementButton, false, rbr)
    rbr.flaskButton = CreateIconBuff(rbr.masteryButton, false, rbr)
    rbr.foodButton = CreateIconBuff(rbr.flaskButton, false, rbr)
    rbr.daRuneButton = CreateIconBuff(rbr.foodButton, false, rbr)
    --rbr.weaponButton = CreateIconBuff(rbr.foodButton, false, rbr)
    rbr.customButton = CreateIconBuff(rbr.daRuneButton, false, rbr)

    GetBuffInfos()
    UpdateMissingRaidBuffVisibility()
    UpdateMissingRaidBuffCustomSpell()

    rbr:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    rbr:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
    rbr:RegisterUnitEvent("UNIT_AURA", "player")
    rbr:RegisterEvent("PLAYER_REGEN_ENABLED")
    rbr:RegisterEvent("PLAYER_REGEN_DISABLED")
    rbr:RegisterEvent("PLAYER_ENTERING_WORLD")
    rbr:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
    rbr:RegisterEvent("CHARACTER_POINTS_CHANGED")
    rbr:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    rbr:RegisterEvent("GROUP_ROSTER_UPDATE")
    rbr:SetScript("OnEvent", OnAuraChange)
end
GW.LoadRaidbuffReminder = LoadRaidbuffReminder