---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- WARLOCK (soul shards/burning embers/demonic fury, green fire textures)
if GW.myClassID ~= GW.Enum.ClassIndex.Warlock or GW.Classic or GW.TBC or GW.Wrath then return end

local function SetWarlockResourceAnchors(owner)
    if not owner then
        return
    end

    -- Main shard block follows the classpower anchor mode, not the custom resource side.
    CP.SetClassPowerAnchor(owner.warlock, owner, "LEFT")

    if GW.myspec == 3 then
        local side = CP.GetCustomResourceBarSide()
        local gap = CP.GetClassPowerCustomResourceBarGap(4)
        owner.warlock.shardFragment:ClearAllPoints()
        if side == "LEFT" then
            owner.warlock.shardFragment:SetPoint("RIGHT", owner.warlock, "LEFT", -gap, 0)
        else
            owner.warlock.shardFragment:SetPoint("LEFT", owner.warlock, "RIGHT", gap, 0)
        end
    end
end

local function updateTextureBasedOnCondition(self)
    if GW.myClassID == 9 then           -- Warlock
        -- Hook green fire
        if GW.IsSpellKnown(101508) then -- check for spell id 101508
            self.warlock.shardFlare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/soulshardflare-green.png")
            self.warlock.shardFragment.barFill:SetTexture(
                "Interface/AddOns/GW2_UI/textures/altpower/soulshardfragmentbarfill-green.png")
            for i = 1, 5 do
                self.warlock["shard" .. i]:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/soulshard-green.png")
            end
        else
            local textureShardFlare = self.useRedTexture and
                "Interface/AddOns/GW2_UI/textures/altpower/soulshardflare-red.png" or
                "Interface/AddOns/GW2_UI/textures/altpower/soulshardflare.png"
            local textureShardFragmentFill = self.useRedTexture and
                "Interface/AddOns/GW2_UI/textures/altpower/soulshardfragmentbarfill-red.png" or
                "Interface/AddOns/GW2_UI/textures/altpower/soulshardfragmentbarfill.png"
            local textureShardShard = self.useRedTexture and "Interface/AddOns/GW2_UI/textures/altpower/soulshard-red.png" or
                "Interface/AddOns/GW2_UI/textures/altpower/soulshard.png"

            self.warlock.shardFlare:SetTexture(textureShardFlare)
            self.warlock.shardFragment.barFill:SetTexture(textureShardFragmentFill)
            for i = 1, 5 do
                self.warlock["shard" .. i]:SetTexture(textureShardShard)
            end
        end
    end
end

local function powerSoulshard(self, event, ...)
    if event == "LEARNED_SPELL_IN_SKILL_LINE" then
        updateTextureBasedOnCondition(self)
        return
    end

    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and (pType ~= "SOUL_SHARDS" and pType ~= "BURNING_EMBERS") then
        return
    end
    local powerType = self.warlock.powerType
    local pwrMax = UnitPowerMax("player", powerType)
    local pwr = UnitPower("player", powerType)
    local old_power = self.gwPower
    self.gwPower = pwr

    local shardSlots = min(max(pwrMax, 0), 5)
    if shardSlots > 0 then
        local minWidth = (GW.myspec == 3) and 132 or 0
        local shardWidth = max(shardSlots * 32, minWidth)
        self.warlock:SetWidth(shardWidth)
        self:SetWidth(max(self.gwMover:GetWidth(), shardWidth))
        SetWarlockResourceAnchors(self)
    end

    for i = 1, shardSlots do
        self.warlock["shardBg" .. i]:Show()
        if pwr >= i then
            self.warlock["shard" .. i]:Show()
            self.warlock.shardFlare:ClearAllPoints()
            self.warlock.shardFlare:SetPoint("CENTER", self.warlock["shard" .. i], "CENTER", 0, 0)
            if pwr > old_power then
                self.warlock.shardFlare:Show()
                GW.AddToAnimation(
                    "WARLOCK_SHARD_FLARE",
                    0,
                    5,
                    GetTime(),
                    0.7,
                    function(p)
                        p = GW.RoundInt(p)
                        self.warlock.shardFlare:SetTexCoord(GW.getSpriteByIndex(self.warlock.flareMap, p))
                    end,
                    nil,
                    function()
                        self.warlock.shardFlare:Hide()
                    end
                )
            end
        else
            self.warlock["shard" .. i]:Hide()
        end
    end
    for i = shardSlots + 1, 5 do
        self.warlock["shardBg" .. i]:Hide()
        self.warlock["shard" .. i]:Hide()
    end

    if GW.myspec == 3 then -- Destruction
        local shardPower = UnitPower("player", powerType, true)
        local shardModifier = UnitPowerDisplayMod(powerType)
        shardPower = (shardModifier ~= 0) and (shardPower / shardModifier) or 0
        shardPower = Saturate(shardPower - pwr)
        if shardPower == 0 then shardPower = 0.00000000000001 end

        --Hide fragment bar if capped
        if pwr >= pwrMax or shardPower >= 1 then
            self.warlock.shardFragment:Hide()
        else
            self.warlock.shardFragment:Show()
        end

        self.warlock.shardFragment.barFill:SetWidth(130 * shardPower)
        self.warlock.shardFragment.barFill:SetTexCoord(0, shardPower, 0, 1)
        if self.warlock.shardFragment.amount < shardPower then
            GW.AddToAnimation(
                "WARLOCK_FRAGMENT_FLARE",
                1,
                0,
                GetTime(),
                0.3,
                function(p)
                    self.warlock.shardFragment.flare:SetAlpha(math.min(1, math.max(0, p)))
                end
            )
        end
        self.warlock.shardFragment.amount = shardPower
    end
end


local function powerDemonicFury(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "DEMONIC_FURY" then
        return
    end

    local power = UnitPower("player", Enum.PowerType.DemonicFury)
    local maxPower = UnitPowerMax("player", Enum.PowerType.DemonicFury)
    local percent = power / maxPower
    if event == "CLASS_POWER_INIT" then
        self.customResourceBar:ForceFillAmount(percent)
    else
        self.customResourceBar:SetFillAmount(percent)
    end
end

local function setWarlock(f)
    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f.warlock:SetWidth(5 * 32)
    f:SetWidth(max(f.gwMover:GetWidth(), f.warlock:GetWidth()))
    f:SetHeight(32)
    SetWarlockResourceAnchors(f)
    f.warlock:Show()
    if GW.myspec == 3 then -- Destruction
        f.warlock.shardFragment.amount = -1
        f.warlock.shardFragment:Show()
        local flarAnimationMap = {
            width = 512,
            height = 512,
            colums = 2,
            rows = 4
        }
        f.warlock.flareMap = flarAnimationMap
    else
        f.warlock.shardFragment:Hide()
    end
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    if GW.Mists then
        f:RegisterEvent("UNIT_DISPLAYPOWER")
    end
    -- Register "LEARNED_SPELL_IN_SKILL_LINE" so we can check for the green fire spell and check an login
    f:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE")
    f.useRedTexture = false

    if GW.Retail then
        f.warlock.powerType = Enum.PowerType.SoulShards
        f:SetScript("OnEvent", powerSoulshard)
        powerSoulshard(f, "CLASS_POWER_INIT")
    elseif GW.Mists then
        if GW.myspec == 1 then
            f.warlock.powerType = Enum.PowerType.SoulShards
            f:SetScript("OnEvent", powerSoulshard)
            powerSoulshard(f, "CLASS_POWER_INIT")
        elseif GW.myspec == 2 then
            f.warlock:Hide()
            CP.setPowerTypeMeta(f.customResourceBar)
            f.customResourceBar:Show()
            f.customResourceBar:SetWidth(312)
            CP.SetClassPowerCustomResourceBarAnchor(f.customResourceBar, f.gwMover, f, -5, 0, 2, 4)

            f:SetScript("OnEvent", powerDemonicFury)
            powerDemonicFury(f, "CLASS_POWER_INIT")
        elseif GW.myspec == 3 then
            f.warlock.powerType = Enum.PowerType.BurningEmbers
            f:SetScript("OnEvent", powerSoulshard)
            powerSoulshard(f, "CLASS_POWER_INIT")
            f.useRedTexture = true
        end
    end

    updateTextureBasedOnCondition(f)

    return true
end

CP.setups[GW.Enum.ClassIndex.Warlock] = setWarlock
