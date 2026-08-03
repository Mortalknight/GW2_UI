---@class GW2
local GW = select(2, ...)
local CP = GW.ClassPowers

-- DEATH KNIGHT (runes)
if GW.myClassID ~= GW.Enum.ClassIndex.Deathknight or GW.Classic or GW.TBC or GW.Wrath then return end

local animations = GW.animations
local RUNETYPE_BLOOD = 1
local RUNETYPE_FROST = 2
local RUNETYPE_UNHOLY = 3
local RUNETYPE_DEATH = 4

local iconTextures = {
    [RUNETYPE_BLOOD] = "Interface/AddOns/GW2_UI/textures/altpower/runes-blood.png",
    [RUNETYPE_FROST] = "Interface/AddOns/GW2_UI/textures/altpower/runes.png",
    [RUNETYPE_UNHOLY] = "Interface/AddOns/GW2_UI/textures/altpower/runes-unholy.png",
    [RUNETYPE_DEATH] = "Interface/AddOns/GW2_UI/textures/altpower/runes-death.png"
}
local RUNE_TIMER_ANIMATIONS = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
}

local getBlizzardRuneId = {
    [1] = 1,
    [2] = 2,
    [3] = 5,
    [4] = 6,
    [5] = 3,
    [6] = 4,
}

local function getRuneData(index, out)
    if GW.Retail then
        local start, duration, ready = GetRuneCooldown(index)
        local progress = 1
        if start ~= nil and duration > 0 then
            progress = (GetTime() - start) / duration
        end
        out.start = start
        out.duration = duration
        out.ready = ready
        out.progress = progress
        out.runeType = nil -- no need in retail
        return out
    else
        local correctRuneId = getBlizzardRuneId[index]
        local start, duration, ready = GetRuneCooldown(correctRuneId)
        local runeType = GetRuneType(correctRuneId)

        local progress = 1
        if start == nil then
            start = GetTime()
            duration = 0
        end
        out.start = start
        out.duration = duration
        out.ready = ready
        out.progress = progress
        out.runeType = runeType
        return out
    end
end

-- Reused per-rune tables + scratch array so RUNE_POWER_UPDATE (frequent in DK combat) does not
-- allocate 7 tables on every event.
local runeDataPool = { {}, {}, {}, {}, {}, {} }
local runeDataSorted = {}
local function runeProgressSort(a, b) return a.progress > b.progress end

local function powerRune(self)
    local f = self
    local fr = self.runeBar
    local runeData = runeDataSorted

    for i = 1, 6 do
        runeData[i] = getRuneData(i, runeDataPool[i])
    end

    if GW.Retail then
        table.sort(runeData, runeProgressSort)
    end

    for i = 1, 6 do
        local data = runeData[i]
        local fFill = fr["runeTexFill" .. i]
        local fTex = fr["runeTex" .. i]
        local fFlare = fr["flare" .. i]
        local animId = "RUNE_TIMER_ANIMATIONS" .. i

        if not GW.Retail and data.runeType then
            fFill:SetTexture(iconTextures[data.runeType])
            fTex:SetTexture(iconTextures[data.runeType])
        end

        if data.ready and fFill then
            fFill:SetTexCoord(0.5, 1, 0, 1)
            fFill:SetHeight(32)
            fFill:SetVertexColor(1, 1, 1, 1)
            if GW.Retail then
                fFill:SetDesaturated(false)
            end
            if animations[animId] then
                animations[animId].completed = true
                animations[animId].duration = 0
            end
        else
            if data.start == 0 then
                return
            end
            GW.AddToAnimation(
                animId,
                GW.Retail and data.progress or RUNE_TIMER_ANIMATIONS[i],
                1,
                data.start,
                data.duration,
                function(p)
                    fFill:SetTexCoord(0.5, 1, 1 - p, 1)
                    fFill:SetHeight(32 * p)
                    if GW.Retail then
                        fFill:SetVertexColor(1, 1, 1, 0.5)
                        fFill:SetDesaturated(true)
                        fFill:SetBlendMode("BLEND")
                        fFlare:SetVertexColor(1, 1, 1, 0)
                    else
                        fFill:SetVertexColor(0.6 * p, 0.6 * p, 0.6 * p)
                    end
                end,
                "noease",
                function()
                    f.flare:ClearAllPoints()
                    f.flare:SetPoint("CENTER", fFill, "CENTER", 0, 0)
                    GW.AddToAnimation(
                        "RUNE_FLARE_ANIMATIONS" .. i,
                        1,
                        0,
                        GetTime(),
                        0.5,
                        function(p)
                            if GW.Retail then
                                fFlare:SetVertexColor(1, 1, 1, p)
                                fFlare:SetSize(512 * math.sin(p * math.pi * 0.5), 256)
                                fFlare:SetBlendMode("ADD")
                            else
                                f.flare:SetAlpha(math.min(1, math.max(0, p)))
                            end
                        end
                    )
                end
            )

            if not GW.Retail then
                RUNE_TIMER_ANIMATIONS[i] = 0
            end
        end
        fTex:SetTexCoord(0, 0.5, 0, 1)
    end
end


local function setDeathKnight(f)
    local fr = f.runeBar
    CP.SetClassPowerAnchor(f, f.gwMover, "TOPLEFT", 0, CP.GetAnchorMode() == "DEFAULT" and -10 or 0)

    f.background:SetTexture(nil)
    f.fill:SetTexture(nil)
    f.flare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/runeflash.png")
    f.flare:SetWidth(256)
    f.flare:SetHeight(128)
    fr:Show()

    if GW.Retail then
        local texture = "runes-blood"
        if GW.myspec == 2 then     -- frost
            texture = "runes"
        elseif GW.myspec == 3 then -- unholy
            texture = "runes-unholy"
        end

        for i = 1, 6 do
            local fFill = fr["runeTexFill" .. i]
            local fTex = fr["runeTex" .. i]
            local fFlare = fr["flare" .. i]

            fFill:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/" .. texture .. ".png")
            fTex:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/" .. texture .. ".png")
            fFlare:SetRotation(1.5708)
            fFlare:SetVertexColor(1, 1, 1, 0)
            fFlare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/runeflash.png")
        end
    elseif GW.Mists then
        for i = 1, 6 do
            local texture
            local fFill = fr["runeTexFill" .. i]
            local fTex = fr["runeTex" .. i]
            local fFlare = fr["flare" .. i]

            if i <= 2 then
                texture = "runes-blood"
            elseif i <= 4 then
                texture = "runes-unholy"
            else
                texture = "runes"
            end

            fFill:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/" .. texture .. ".png")
            fTex:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/" .. texture .. ".png")
            fFlare:SetRotation(1.5708)
            fFlare:SetVertexColor(1, 1, 1, 0)
            fFlare:SetTexture("Interface/AddOns/GW2_UI/textures/altpower/runeflash.png")
        end
    end

    f:SetScript("OnEvent", powerRune)
    powerRune(f)
    f:RegisterEvent("RUNE_POWER_UPDATE")

    return true
end

CP.setups[GW.Enum.ClassIndex.Deathknight] = setDeathKnight
