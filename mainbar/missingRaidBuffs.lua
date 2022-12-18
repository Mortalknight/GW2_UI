local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting

local LibCustomGlow = GW.Libs.CustomGlows
local ALPHA = 0.3
local classColor = GW.GWGetClassColor(GW.myclass, true)

local settings = {}

local function UpdateSettings()
    settings.invert = GetSetting("MISSING_RAID_BUFF_INVERT")
    settings.dimmed = GetSetting("MISSING_RAID_BUFF_dimmed")
    settings.grayedout = GetSetting("MISSING_RAID_BUFF_grayed_out")
    settings.animated = GetSetting("MISSING_RAID_BUFF_animated")
    settings.visibility = GetSetting("MISSING_RAID_BUFF")
    settings.customsId = GetSetting("MISSING_RAID_BUFF_custom_id")
end
GW.UpdateMissingRaidBuffSettings = UpdateSettings

-- tables
local checkIds = {}
local buffInfos = {}
local reminderBuffs = {
    Flask = {
        -- BFA
        [1] = 251836,			-- Flask of the Currents (238 agi)
        [2] = 251837,			-- Flask of Endless Fathoms (238 int)
        [3] = 251838,			-- Flask of the Vast Horizon (357 sta)
        [4] = 251839,			-- Flask of the Undertow (238 str)
        [5] = 298836,			-- Greater Flask of the Currents
        [6] = 298837,			-- Greater Flask of Endless Fathoms
        [7] = 298839,			-- Greater Flask of the Vast Horizon
        [8] = 298841,			-- Greater Flask of the Undertow

        -- Shadowlands
        [9] = 307166,			-- Eternal FLask (190 stat)
        [10] = 307185,			-- Spectral Flask of Power (73 stat)
        [11] = 307187,			-- Spectral Flask of Stamina (109 sta)
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
    Weapon = { -- EnchantsID
        [1] = 6188, -- Shadowcore Oil
        [2] = 6190, -- Embalmer's Oil
        [3] = 6200, -- Shaded Sharpening Stone -- just a fallback
    },
    Custom = {
        -- spellID,	-- Spell Info
    },
}

local function GetBuffInfos()
    local name, textureId
    for k, v in pairs(reminderBuffs) do
        buffInfos[k] = {}
        if type(v) == "table" then
            for sk, id in pairs(v) do
                name, _, textureId = GetSpellInfo(id)
                buffInfos[k][sk] = {name = name, texId = textureId, spellId = id, hasBuff = false}
                if k == "Weapon" then
                    buffInfos[k][sk].texId = GetInventoryItemTexture("player", 16)
                end
            end
        end
    end
end

local function CheckForBuffs()
    local spellID, foundBuff
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
        spellID = select(10, UnitBuff("player", i))
        if not spellID then
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
                            if buffInfos[k][sk].spellId == spellID then
                                buffInfos[k][sk].hasBuff = true
                                checkIds[spellID] = true
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

            if not checkIds[spellID or mainHandEnchantID or offHandEnchantId] then
                checkIds[spellID or mainHandEnchantID or offHandEnchantId] = true
            end
        end
    end
end

local function setButtonStyle(button, haveBuff)
    if not haveBuff then
        button.icon:SetDesaturated(settings.invert and settings.grayedout or false)
        button:SetAlpha(not settings.invert and 1 or settings.dimmed and ALPHA or 1)
        if settings.animated then
            --LibCustomGlow.PixelGlow_Start(button, {classColor.r, classColor.g, classColor.b, 1}, nil, -0.25, nil, 1)
        else
            --LibCustomGlow.PixelGlow_Stop(button)
        end
    else
        button.icon:SetDesaturated(settings.invert and false or settings.grayedout)
        button:SetAlpha(settings.invert and 1 or settings.dimmed and ALPHA or 1)
        --LibCustomGlow.PixelGlow_Stop(button)
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

    --Da Runes
    foundBuff = false
    for _, darunebuff in pairs(buffInfos.DefiledAugmentRune) do
        if darunebuff.hasBuff then
            self.daRuneButton.icon:SetTexture(darunebuff.texId)
            foundBuff = true
            break
        end
    end
    if not foundBuff then
        self.daRuneButton.icon:SetTexture(buffInfos.DefiledAugmentRune[1].texId)
    end
    setButtonStyle(self.daRuneButton, foundBuff)

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

    -- Weapon
    foundBuff = false
    for _, weaponbuff in pairs(buffInfos.Weapon) do
        if weaponbuff.hasBuff then
            self.weaponButton.icon:SetTexture(weaponbuff.texId)
            foundBuff = true
            break
        end
    end
    if not foundBuff then
        self.weaponButton.icon:SetTexture(buffInfos.Weapon[1].texId)
    end
    setButtonStyle(self.weaponButton, foundBuff)

    -- Custom
    if #buffInfos.Custom > 0 then
        self:SetSize(249, 32)
        self.customButton.icon:SetTexture(buffInfos.Custom[1].texId)

        if not self.customButton:IsShown() then self.customButton:Show() end
        setButtonStyle(self.customButton, buffInfos.Custom[1].hasBuff)
    else
        self:SetSize(218, 32)
        self.customButton:Hide()
        --LibCustomGlow.PixelGlow_Stop(self.customButton)
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

    RegisterStateDriver(GW_RaidBuffReminder, "visibility", VisibilityStates[settings.visibility])
end
GW. UpdateMissingRaidBuffVisibility = UpdateMissingRaidBuffVisibility

local function UpdateMissingRaidBuffCustomSpell()
	wipe(buffInfos.Custom)

	local keywords = gsub(settings.customsId, ",%s", ",")

	for stringValue in gmatch(keywords, "[^,]+") do
		if stringValue ~= "" then
            local name, _, textureId = GetSpellInfo(tonumber(stringValue))
            buffInfos.Custom[1] = {name = name, texId = textureId, spellId = tonumber(stringValue), hasBuff = false}
            break
		end
	end

    OnAuraChange(GW_RaidBuffReminder)
end
GW.UpdateMissingRaidBuffCustomSpell = UpdateMissingRaidBuffCustomSpell

local function LoadRaidbuffReminder()
    UpdateSettings()

    local rbr = CreateFrame("Frame", "GW_RaidBuffReminder", UIParent)

    rbr:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)

    rbr:SetSize(218, 32)

    GW.RegisterMovableFrame(rbr, L["Missing Raid Buffs Bar"], "MISSING_RAID_BUFF_pos", "VerticalActionBarDummy", nil, {"default", "scaleable"})
    rbr:ClearAllPoints()
    rbr:SetPoint("TOPLEFT", rbr.gwMover)

    rbr.intButton = CreateIconBuff(rbr, true, rbr)
    rbr.staminaButton = CreateIconBuff(rbr.intButton, false, rbr)
    rbr.attackPowerButton = CreateIconBuff(rbr.staminaButton, false, rbr)
    rbr.flaskButton = CreateIconBuff(rbr.attackPowerButton, false, rbr)
    rbr.foodButton = CreateIconBuff(rbr.flaskButton, false, rbr)
    rbr.daRuneButton = CreateIconBuff(rbr.foodButton, false, rbr)
    rbr.weaponButton = CreateIconBuff(rbr.daRuneButton, false, rbr)
    rbr.customButton = CreateIconBuff(rbr.weaponButton, false, rbr)

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