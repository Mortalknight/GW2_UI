local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting

local LibCustomGlow = GW.Libs.CustomGlows
local ALPHA = 0.3
local classColor = GW.GWGetClassColor(GW.myclass, true)
local color = {classColor.r, classColor.g, classColor.b, 1}

-- tables
local ReminderBuffs = {
    Flask = {
        -- BFA
        251836,			-- Flask of the Currents (238 agi)
        251837,			-- Flask of Endless Fathoms (238 int)
        251838,			-- Flask of the Vast Horizon (357 sta)
        251839,			-- Flask of the Undertow (238 str)
        298836,			-- Greater Flask of the Currents
        298837,			-- Greater Flask of Endless Fathoms
        298839,			-- Greater Flask of the Vast Horizon
        298841,			-- Greater Flask of the Undertow

        -- Shadowlands
        307166,			-- Eternal FLask (190 stat)
        307185,			-- Spectral Flask of Power (73 stat)
        307187,			-- Spectral Flask of Stamina (109 sta)
    },
    DefiledAugmentRune = {
        224001,			-- Defiled Augumentation (15 primary stat)
        270058,			-- Battle Scarred Augmentation (60 primary stat)
        347901,			-- Veiled Augmentation (18 primary stat)
    },
    Food = {
        104280,	-- Well Fed

        -- Shadowlands
        259455,	-- Well Fed
        308434,	-- Well Fed
        308488,	-- Well Fed
        308506,	-- Well Fed
        308514,	-- Well Fed
        308637,	-- Well Fed
        327715,	-- Well Fed
        327851,	-- Well Fed
    },
    Intellect = {
        1459, -- Arcane Intellect
        264760, -- War-Scroll of Intellect
    },
    Stamina = {
        6307, -- Blood Pact
        21562, -- Power Word: Fortitude
        264764, -- War-Scroll of Fortitude
    },
    AttackPower = {
        6673, -- Battle Shout
        264761, -- War-Scroll of Battle
    },
    Weapon = {
        1, -- just a fallback
    },
    Custom = {
        -- spellID,	-- Spell name
    },
}

local Weapon_Enchants = {
    6188, -- Shadowcore Oil
    6190, -- Embalmer's Oil
    6200, -- Shaded Sharpening Stone
}

local function EnchantsID(id)
    for _, v in ipairs(Weapon_Enchants) do
        if id == v then
            return true
        end
    end
    return false
end

local function CheckPlayerBuff(spellIdToCheck)
    for i = 1, 40 do
        local spellId = select(10, UnitBuff("player", i))
        if not spellId then return false end
        if spellId == spellIdToCheck then
            return true
        end
    end
    return false
end

local flaskbuffs = ReminderBuffs["Flask"]
local foodbuffs = ReminderBuffs["Food"]
local darunebuffs = ReminderBuffs["DefiledAugmentRune"]
local intellectbuffs = ReminderBuffs["Intellect"]
local staminabuffs = ReminderBuffs["Stamina"]
local attackpowerbuffs = ReminderBuffs["AttackPower"]
local weaponEnch = ReminderBuffs["Weapon"]

local function setButtonStyle(button, state)
    local invert = GetSetting("MISSING_RAID_BUFF_INVERT")
    local animated = GetSetting("MISSING_RAID_BUFF_animated")
    local dimmed = GetSetting("MISSING_RAID_BUFF_dimmed")
    local grayedout = GetSetting("MISSING_RAID_BUFF_grayed_out")

    if state == "MISSING" then
        if not invert then
            button.t:SetDesaturated(false)
        else
            if grayedout then
                button.t:SetDesaturated(true)
            else
                button.t:SetDesaturated(false)
            end
        end
        button:SetAlpha(not invert and 1 or dimmed and ALPHA or 1)
        if animated then
            LibCustomGlow.PixelGlow_Start(button.animationButton, color, nil, -0.25, nil, 1)
        end
    else
        button:SetAlpha(invert and 1 or dimmed and ALPHA or 1)
        LibCustomGlow.PixelGlow_Stop(button.animationButton)

        if not invert then
            if grayedout then
                button.t:SetDesaturated(true)
            else
                button.t:SetDesaturated(false)
            end
        else
            button.t:SetDesaturated(false)
        end
    end
end

local function OnAuraChange(self, event, arg1)
    if event == "UNIT_AURA" and arg1 ~= "player" then return end

    if (flaskbuffs and flaskbuffs[1]) then
        GW_FlaskFrame.t:SetTexture(select(3, GetSpellInfo(flaskbuffs[1])))
        for _, flaskbuffs in pairs(flaskbuffs) do
            local spellname = select(1, GetSpellInfo(flaskbuffs))
            if AuraUtil.FindAuraByName(spellname, "player") then
                GW_FlaskFrame.t:SetTexture(select(3, GetSpellInfo(flaskbuffs)))
                setButtonStyle(GW_FlaskFrame, "HAVE")
                break
            else
                setButtonStyle(GW_FlaskFrame, "MISSING")
            end
        end
    end

    if (foodbuffs and foodbuffs[1]) then
        GW_FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs[1])))
        for _, foodbuffs in pairs(foodbuffs) do
            local spellname = select(1, GetSpellInfo(foodbuffs))
            GW_FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs)))
            if AuraUtil.FindAuraByName(spellname, "player") then
                setButtonStyle(GW_FoodFrame, "HAVE")
                break
            else
                GW_FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs)))
                setButtonStyle(GW_FoodFrame, "MISSING")
            end
        end
    end

    if (darunebuffs and darunebuffs[1]) then
        GW_DARuneFrame.t:SetTexture(select(3, GetSpellInfo(darunebuffs[1])))
        for _, darunebuffs in pairs(darunebuffs) do
            local spellname = select(1, GetSpellInfo(darunebuffs))
            GW_DARuneFrame.t:SetTexture(select(3, GetSpellInfo(darunebuffs)))
            if AuraUtil.FindAuraByName(spellname, "player") then
                setButtonStyle(GW_DARuneFrame, "HAVE")
                break
            else
                setButtonStyle(GW_DARuneFrame, "MISSING")
            end
        end
    end

    if (intellectbuffs and intellectbuffs[1]) then
        GW_IntellectFrame.t:SetTexture(select(3, GetSpellInfo(intellectbuffs[1])))
        for _, intellectbuffs in pairs(intellectbuffs) do
            local spellname = select(1, GetSpellInfo(intellectbuffs))
            if AuraUtil.FindAuraByName(spellname, "player") then
                GW_IntellectFrame.t:SetTexture(select(3, GetSpellInfo(intellectbuffs)))
                setButtonStyle(GW_IntellectFrame, "HAVE")
                break
            else
                GW_IntellectFrame.t:SetTexture(select(3, GetSpellInfo(1459)))
                setButtonStyle(GW_IntellectFrame, "MISSING")
            end
        end
    end

    if (staminabuffs and staminabuffs[1]) then
        GW_StaminaFrame.t:SetTexture(select(3, GetSpellInfo(staminabuffs[1])))
        for _, staminabuffs in pairs(staminabuffs) do
            local spellname = select(1, GetSpellInfo(staminabuffs))
            if AuraUtil.FindAuraByName(spellname, "player") then
                GW_StaminaFrame.t:SetTexture(select(3, GetSpellInfo(staminabuffs)))
                setButtonStyle(GW_StaminaFrame, "HAVE")
                break
            else
                GW_StaminaFrame.t:SetTexture(select(3, GetSpellInfo(21562)))
                setButtonStyle(GW_StaminaFrame, "MISSING"  )
            end
        end
    end

    if (attackpowerbuffs and attackpowerbuffs[1]) then
        GW_AttackPowerFrame.t:SetTexture(select(3, GetSpellInfo(attackpowerbuffs[1])))
        for _, attackpowerbuffs in pairs(attackpowerbuffs) do
            local spellname = select(1, GetSpellInfo(attackpowerbuffs))
            if AuraUtil.FindAuraByName(spellname, "player") then
                GW_AttackPowerFrame.t:SetTexture(select(3, GetSpellInfo(attackpowerbuffs)))
                setButtonStyle(GW_AttackPowerFrame, "HAVE")
                break
            else
                GW_AttackPowerFrame.t:SetTexture(select(3, GetSpellInfo(6673)))
                setButtonStyle(GW_AttackPowerFrame, "MISSING")
            end
        end
    end

    if (weaponEnch and weaponEnch[1]) then
        local hasMainHandEnchant, _, _, mainHandEnchantID, hasOffHandEnchant, _, _, offHandEnchantId = GetWeaponEnchantInfo()
        GW_WeaponFrame.t:SetTexture(GetInventoryItemTexture('player', 16))
        if (hasMainHandEnchant and EnchantsID(mainHandEnchantID)) or (hasOffHandEnchant and EnchantsID(offHandEnchantId)) then
            setButtonStyle(GW_WeaponFrame, "HAVE")
        else
            setButtonStyle(GW_WeaponFrame, "MISSING")
        end
    end

    if ReminderBuffs.Custom and ReminderBuffs.Custom[1] then
        for _, custombuffs in pairs(ReminderBuffs.Custom) do
            self:SetSize(249, 32)
            local _, _, icon = GetSpellInfo(custombuffs)
            if icon then
                GW_CustomFrame.t:SetTexture(icon)
            end

            if CheckPlayerBuff(custombuffs) then
                setButtonStyle(GW_CustomFrame, "HAVE")
                break
            else
                setButtonStyle(GW_CustomFrame, "MISSING")
            end
        end
        if not GW_CustomFrame:IsShown() then GW_CustomFrame:Show() end
        if not GW_CustomFrameanimation:IsShown() then GW_CustomFrameanimation:Show() end
    else
        self:SetSize(218, 32)
        GW_CustomFrame:Hide()
        GW_CustomFrameanimation:Hide()
        LibCustomGlow.PixelGlow_Stop(GW_CustomFrameanimation)
    end
end

local function CreateIconBuff(name, relativeTo, firstbutton, frame)
    local button = CreateFrame("Button", name, frame)
    button:SetSize(28, 28)
    GW.setActionButtonStyle(name, true)

    if firstbutton then
        button:SetPoint("BOTTOMLEFT", relativeTo, "BOTTOMLEFT", 2, 2)
    else
        button:SetPoint("LEFT", relativeTo, "RIGHT", 3, 0)
    end
    button:SetFrameLevel(frame:GetFrameLevel() + 10)

    button.t = button:CreateTexture(name .. ".t", "OVERLAY")
    button.t:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.t:SetPoint("TOPLEFT", 2, -2)
    button.t:SetPoint("BOTTOMRIGHT", -2, 2)

    button.animationButton = CreateFrame("Button", name .. "animation", GW_RaidBuffReminder)
    button.animationButton:SetSize(30, 30)
    GW.setActionButtonStyle(name .. "animation", true)
    button.animationButton:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    button.animationButton:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)

    return button
end

local function UpdateMissingRaidBuffVisibility()
    local VisibilityStates = {
        ["NEVER"] = "hide",
        ["ALWAYS"] = "[petbattle] hide; show",
        ["IN_GROUP"] = "[group:raid] hide; [group:party] show; [petbattle] hide; hide",
        ["IN_RAID"] = "[group:raid] show; [group:party] hide; [petbattle] hide; hide",
        ["IN_RAID_IN_PARTY"] = "[group] show; [petbattle] hide; hide",
    }

    RegisterStateDriver(GW_RaidBuffReminder, "visibility", VisibilityStates[GetSetting("MISSING_RAID_BUFF")])
end
GW. UpdateMissingRaidBuffVisibility = UpdateMissingRaidBuffVisibility

local function UpdateMissingRaidBuffCustomSpell()
	wipe(ReminderBuffs.Custom)

	local keywords = GetSetting("MISSING_RAID_BUFF_custom_id")
	keywords = gsub(keywords, ',%s', ',')

	for stringValue in gmatch(keywords, '[^,]+') do
		if stringValue ~= "" then
			ReminderBuffs.Custom[#ReminderBuffs.Custom + 1] = tonumber(stringValue)
		end
	end
    GW_13 = flaskbuffs
end
GW.UpdateMissingRaidBuffCustomSpell = UpdateMissingRaidBuffCustomSpell

local function LoadRaidbuffReminder()
    local rbr = CreateFrame("Frame", "GW_RaidBuffReminder", UIParent)

    rbr:CreateBackdrop(GW.skins.constBackdropFrameSmallerBorder, true)

    rbr:SetSize(218, 32)

    GW.RegisterMovableFrame(rbr, L["Missing Raid Buffs Bar"], "MISSING_RAID_BUFF_pos", "VerticalActionBarDummy", nil, nil, {"default", "scaleable"})
    rbr:ClearAllPoints()
    rbr:SetPoint("TOPLEFT", rbr.gwMover)

    local frameTo = nil
    frameTo = CreateIconBuff("GW_IntellectFrame", rbr, true, rbr)
    frameTo = CreateIconBuff("GW_StaminaFrame", frameTo, false, rbr)
    frameTo = CreateIconBuff("GW_AttackPowerFrame", frameTo, false, rbr)
    frameTo = CreateIconBuff("GW_FlaskFrame", frameTo, false, rbr)
    frameTo = CreateIconBuff("GW_FoodFrame", frameTo, false, rbr)
    frameTo = CreateIconBuff("GW_DARuneFrame", frameTo, false, rbr)
    frameTo = CreateIconBuff("GW_WeaponFrame", frameTo, false, rbr)
    CreateIconBuff("GW_CustomFrame", frameTo, false, rbr)

    UpdateMissingRaidBuffVisibility()
    UpdateMissingRaidBuffCustomSpell()

    rbr:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    rbr:RegisterEvent("UNIT_INVENTORY_CHANGED")
    rbr:RegisterEvent("UNIT_AURA")
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