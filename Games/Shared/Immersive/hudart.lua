---@class GW2
local GW = select(2, ...)

local TEXTURE_PATH = "Interface/AddOns/GW2_UI/textures/hud/"

local actionHudPlayerAuras = {}
local actionHudPlayerPetAuras = {}

local curveOne, curveTwo

-- For creates a model effect somewhere on the hud with a trigger buff
local function createModelFx(self, modelFX)
    local anchor = modelFX.anchor
    local modelID = modelFX.modelID
    local modelPosition = modelFX.modelPosition

    if modelID == self.actionBarHudFX.currentModelID and self.actionBarHudFX:IsShown() then
        return
    end

    if _G[anchor.target] == nil then
        return
    end
    self.actionBarHudFX.currentModelID = modelID
    self.actionBarHudFX:MakeCurrentCameraCustom()
    self.actionBarHudFX:SetParent(UIParent)
    self.actionBarHudFX:SetFrameStrata(self:GetFrameStrata())
    self.actionBarHudFX:SetFrameLevel(self:GetFrameLevel() - 1)
    self.actionBarHudFX:SetModel(modelID)
    self.actionBarHudFX:SetPosition(modelPosition.x, modelPosition.y, modelPosition.z)
    self.actionBarHudFX:SetFacing(modelPosition.rotation)
    self.actionBarHudFX:ClearAllPoints()
    self.actionBarHudFX:SetPoint(anchor.point, anchor.target, anchor.relPoint, anchor.x, anchor.y)
    self.actionBarHudFX:Show()

    if GwHudFXDebug then
        GwHudFXDebug.x:SetText(modelPosition.x)
        GwHudFXDebug.y:SetText(modelPosition.y)
        GwHudFXDebug.z:SetText(modelPosition.z)
        GwHudFXDebug.rotation:SetText(modelPosition.rotation)
    end
end


local currentTexture = nil

-- Retail: the aura HUD art containers only apply the settings here — the combat
-- gate itself is a secure visibility state driver on their parent frame. It MUST
-- be secure: showing a container from addon code during combat would run its
-- refresh tainted, and tainted aura access is blocked while auras are secret.
local function UpdateAuraArtVisibility(self)
    if not self.gwAuraArtContainers then return end

    if InCombatLockdown() then
        GW.CombatQueue:Queue("GwHudAuraArtVisibility", UpdateAuraArtVisibility, {self})
        return
    end

    local show = GW.settings.HUD_BACKGROUND and GW.settings.HUD_SPELL_SWAP
    for _, container in next, self.gwAuraArtContainers do
        container:SetShown(show)
    end
end

local function GetDruidFormArt()
    if GW.myClassID ~= GW.Enum.ClassIndex.Druid then return end

    local form = GetShapeshiftFormID()
    if form == BEAR_FORM then
        return TEXTURE_PATH .. "leftshadow_bear.png", TEXTURE_PATH .. "rightshadow_bear.png"
    elseif form == CAT_FORM then
        return TEXTURE_PATH .. "leftshadow_cat.png", TEXTURE_PATH .. "rightshadow_cat.png"
    end
end

local function selectBg(self)
    if not GW.settings.HUD_BACKGROUND or not GW.settings.HUD_SPELL_SWAP then
        return
    end

    local right = TEXTURE_PATH .. "rightshadow.png"
    local left = TEXTURE_PATH .. "leftshadow.png"
    local modelFX = nil

    if UnitIsDeadOrGhost("player") then
        right = TEXTURE_PATH .. "rightshadow_dead.png"
        left = TEXTURE_PATH .. "leftshadow_dead.png"
    end

    local formLeft, formRight = GetDruidFormArt()
    if formLeft then
        left, right = formLeft, formRight
    end

    if GW.Libs.GW2Lib:IsPlayerSkyRiding() then
        right = TEXTURE_PATH .. "rightshadow-dragon.png"
        left = TEXTURE_PATH .. "leftshadow-dragon.png"
    end

    if UnitAffectingCombat("player") then
        right = TEXTURE_PATH .. "rightshadowcombat.png"
        left = TEXTURE_PATH .. "leftshadowcombat.png"

        if formLeft then
            left, right = formLeft, formRight
        end

        local auraFound = false
        if not GW.Retail then
            for spellID, auraData in pairs(actionHudPlayerAuras) do
                if C_UnitAuras.GetPlayerAuraBySpellID(spellID) then
                    right = auraData.right
                    left = auraData.left
                    modelFX = auraData.modelFX
                    auraFound = true
                    break
                end
            end

            -- pet buffs
            if not auraFound then
                for i = 1, 40 do
                    local auraData = C_UnitAuras.GetBuffDataByIndex("pet", i)
                    local petAura = auraData and actionHudPlayerPetAuras[auraData.spellId]
                    if petAura and petAura.unit == "pet" then
                        right = petAura.right
                        left = petAura.left
                        modelFX = petAura.modelFX
                        break
                    end
                end
            end
        end
    end

    if modelFX then
        createModelFx(self, modelFX)
    elseif self.actionBarHudFX:IsShown() and not GwHudFXDebug then
        self.actionBarHudFX:Hide()
    end

    if currentTexture ~= left then
        currentTexture = left

        self.actionBarHud.Right:SetTexture(right)
        self.actionBarHud.Left:SetTexture(left)

        GW.AddToAnimation("DynamicHud", 0, 1, GetTime(), 0.2, function(prog)
            self.actionBarHud.Right:SetAlpha(prog)
            self.actionBarHud.Left:SetAlpha(prog)
        end)
    end
end


local function combatHealthState(self)
    if not GW.settings.HUD_BACKGROUND then
        return
    end
    local healthPercentage = UnitHealth("player") / UnitHealthMax("player")

    if healthPercentage < 0.5 and not UnitIsDeadOrGhost("player") then
        healthPercentage = healthPercentage / 0.5
        local alpha = 1 - healthPercentage - 0.2
        if alpha < 0 then alpha = 0 end
        if alpha > 1 then alpha = 1 end

        self.actionBarHud.Left:SetVertexColor(1, healthPercentage, healthPercentage)
        self.actionBarHud.Right:SetVertexColor(1, healthPercentage, healthPercentage)

        self.actionBarHud.RightSwim:SetVertexColor(1, healthPercentage, healthPercentage)
        self.actionBarHud.LeftSwim:SetVertexColor(1, healthPercentage, healthPercentage)

        self.actionBarHud.LeftBlood:SetVertexColor(1, 1, 1, alpha)
        self.actionBarHud.RightBlood:SetVertexColor(1, 1, 1, alpha)
    else
        self.actionBarHud.Left:SetVertexColor(1, 1, 1)
        self.actionBarHud.Right:SetVertexColor(1, 1, 1)

        self.actionBarHud.LeftSwim:SetVertexColor(1, 1, 1)
        self.actionBarHud.RightSwim:SetVertexColor(1, 1, 1)

        self.actionBarHud.LeftBlood:SetVertexColor(1, 1, 1, 0)
        self.actionBarHud.RightBlood:SetVertexColor(1, 1, 1, 0)
    end
end

local function combatHealthStateRetail(self)
    if not GW.settings.HUD_BACKGROUND then
        return
    end

    if not UnitIsDeadOrGhost("player") then
        local colorOne = UnitHealthPercent("player", true, curveOne)
        local colorTwo = UnitHealthPercent("player", true, curveTwo)

        self.actionBarHud.Left:SetVertexColor(colorOne:GetRGB())
        self.actionBarHud.Right:SetVertexColor(colorOne:GetRGB())

        self.actionBarHud.RightSwim:SetVertexColor(colorOne:GetRGB())
        self.actionBarHud.LeftSwim:SetVertexColor(colorOne:GetRGB())

        self.actionBarHud.LeftBlood:SetVertexColor(colorTwo:GetRGBA())
        self.actionBarHud.RightBlood:SetVertexColor(colorTwo:GetRGBA())
    else
        self.actionBarHud.Left:SetVertexColor(1, 1, 1)
        self.actionBarHud.Right:SetVertexColor(1, 1, 1)

        self.actionBarHud.LeftSwim:SetVertexColor(1, 1, 1)
        self.actionBarHud.RightSwim:SetVertexColor(1, 1, 1)

        self.actionBarHud.LeftBlood:SetVertexColor(1, 1, 1, 0)
        self.actionBarHud.RightBlood:SetVertexColor(1, 1, 1, 0)
    end
end

-- Central catalog of all aura driven HUD arts, gated by class. Only the entries of
-- the logged in class are registered: the classic combat scan in selectBg then only
-- checks auras the player can actually have, and the retail path creates no tracker
-- containers for spells of other classes.
local ACTION_HUD_AURAS = {
    -- DRUID (bear/cat form art is NOT aura driven — selectBg reads GetShapeshiftFormID
    -- directly, which needs no registration and works in combat on every client)
    { class = GW.Enum.ClassIndex.Druid, auraID = 48518, unit = "player", -- Lunar Eclipse
        left = TEXTURE_PATH .. "left_lunareclipse.png", right = TEXTURE_PATH .. "right_lunareclipse.png",
        modelFX = {
            anchor = { point = "BOTTOM", relPoint = "BOTTOM", target = "Gw2_HudBackgroud", x = 0, y = 100 },
            modelID = 1513212,
            modelPosition = { x = -2.5, y = 0, z = -3.4, rotation = 0 },
        } },
    { class = GW.Enum.ClassIndex.Druid, auraID = 48517, unit = "player", -- Solar Eclipse
        left = TEXTURE_PATH .. "left_solareclips.png", right = TEXTURE_PATH .. "right_solareclips.png",
        modelFX = {
            anchor = { point = "BOTTOM", relPoint = "BOTTOM", target = "Gw2_HudBackgroud", x = 0, y = 100 },
            modelID = 530798,
            modelPosition = { x = 2, y = 0, z = -0.1, rotation = 0 },
        } },

    -- PALADIN
    { class = GW.Enum.ClassIndex.Paladin, auraID = 31842, unit = "player", -- Avenging Wrath (Holy)
        left = TEXTURE_PATH .. "leftshadow_holy.png", right = TEXTURE_PATH .. "rightshadow_holy.png",
        modelFX = {
            anchor = { point = "BOTTOM", relPoint = "BOTTOM", target = "Gw2_HudBackgroud", x = 0, y = 100 },
            modelID = 2481207, -- cfx_paladin_avengingwrath_statechest.m2 (wings)
            modelPosition = { x = 0, y = 0, z = 0, rotation = 0 },
        } },
    { class = GW.Enum.ClassIndex.Paladin, auraID = 31884, unit = "player", -- Avenging Wrath
        left = TEXTURE_PATH .. "leftshadow_holy.png", right = TEXTURE_PATH .. "rightshadow_holy.png",
        modelFX = {
            anchor = { point = "BOTTOM", relPoint = "BOTTOM", target = "Gw2_HudBackgroud", x = 0, y = 100 },
            modelID = 2481207, -- cfx_paladin_avengingwrath_statechest.m2 (wings)
            modelPosition = { x = 0, y = 0, z = 0, rotation = 0 },
        } },

    -- DEATH KNIGHT
    { class = GW.Enum.ClassIndex.Deathknight, auraID = 51271, unit = "player", -- Pillar of Frost
        left = TEXTURE_PATH .. "leftshadow_frost.png", right = TEXTURE_PATH .. "rightshadow_frost.png",
        modelFX = {
            anchor = { point = "BOTTOM", relPoint = "BOTTOM", target = "Gw2_HudBackgroud", x = 0, y = 50 },
            modelID = 165900, -- deathknight_frostpresence.m2 (frost aura loop)
            modelPosition = { x = 0, y = 0, z = 0, rotation = 0 },
        } },
    { class = GW.Enum.ClassIndex.Deathknight, auraID = 63560, unit = "pet", -- Dark Transformation
        left = TEXTURE_PATH .. "leftshadow_unholy.png", right = TEXTURE_PATH .. "rightshadow_unholy.png",
        modelFX = {
            anchor = { point = "BOTTOM", relPoint = "BOTTOM", target = "Gw2_HudBackgroud", x = 0, y = 50 },
            modelID = 240852, -- deathknight_unholyblight_state.m2 (unholy miasma)
            modelPosition = { x = 0, y = 0, z = 0, rotation = 0 },
        } },

    -- DEMON HUNTER
    { class = GW.Enum.ClassIndex.Demonhunter, auraID = 162264, unit = "player", -- Metamorphosis (Havoc)
        left = TEXTURE_PATH .. "leftshadow_metamorph.png", right = TEXTURE_PATH .. "rightshadow_metamorph.png",
        modelFX = {
            anchor = { point = "BOTTOM", relPoint = "BOTTOM", target = "Gw2_HudBackgroud", x = 0, y = 50 },
            modelID = 1308539, -- cfx_demonhunter_metamorphosisdps_impactbase.m2
            modelPosition = { x = 0, y = 0, z = 0, rotation = 0 },
        } },
    { class = GW.Enum.ClassIndex.Demonhunter, auraID = 187827, unit = "player", -- Metamorphosis (Vengeance)
        left = TEXTURE_PATH .. "leftshadow_metamorph.png", right = TEXTURE_PATH .. "rightshadow_metamorph.png",
        modelFX = {
            anchor = { point = "BOTTOM", relPoint = "BOTTOM", target = "Gw2_HudBackgroud", x = 0, y = 50 },
            modelID = 1308539, -- cfx_demonhunter_metamorphosisdps_impactbase.m2
            modelPosition = { x = 0, y = 0, z = 0, rotation = 0 },
        } },

    -- SHAMAN
    { class = GW.Enum.ClassIndex.Shaman, auraID = 215785, unit = "player", -- Hot Hand
        left = TEXTURE_PATH .. "leftshadow_shaman_fire.png", right = TEXTURE_PATH .. "rightshadow_shaman_fire.png",
        modelFX = {
            anchor = { point = "BOTTOM", relPoint = "BOTTOM", target = "Gw2_HudBackgroud", x = 0, y = 50 },
            modelID = 1568420, -- cfx_shaman_lavaburst_casthands.m2 (burning hands)
            modelPosition = { x = 0, y = 0, z = 0, rotation = 0 },
        } },
    { class = GW.Enum.ClassIndex.Shaman, auraID = 77762, unit = "player", -- Lava Surge
        left = TEXTURE_PATH .. "leftshadow_shaman_fire.png", right = TEXTURE_PATH .. "rightshadow_shaman_fire.png",
        modelFX = {
            anchor = { point = "BOTTOM", relPoint = "BOTTOM", target = "Gw2_HudBackgroud", x = 0, y = 50 },
            modelID = 1113663, -- cfx_shaman_lavaburst_precastbase.m2 (lava swirl)
            modelPosition = { x = 0, y = 0, z = 0, rotation = 0 },
        } },
    { class = GW.Enum.ClassIndex.Shaman, auraID = 201846, unit = "player", -- Stormbringer
        left = TEXTURE_PATH .. "leftshadow_shaman_storm.png", right = TEXTURE_PATH .. "rightshadow_shaman_storm.png",
        modelFX = {
            anchor = { point = "BOTTOM", relPoint = "BOTTOM", target = "Gw2_HudBackgroud", x = 0, y = 50 },
            modelID = 1380810, -- cfx_shaman_crashingstorm_statebase.m2 (storm state)
            modelPosition = { x = 0, y = 0, z = 0, rotation = 0 },
        } },

    -- EVOKER
    { class = GW.Enum.ClassIndex.Evoker, auraID = 375087, unit = "player", -- Dragonrage
        left = TEXTURE_PATH .. "evokerdpsleft.png", right = TEXTURE_PATH .. "evokerdpsright.png",
        modelFX = {
            anchor = { point = "BOTTOM", relPoint = "BOTTOM", target = "Gw2_HudBackgroud", x = 0, y = 50 },
            modelID = 4697927,
            modelPosition = { x = 2, y = 0, z = 0, rotation = 0 },
        } },
}

for _, art in next, ACTION_HUD_AURAS do
    if art.class == GW.myClassID then
        if art.unit == "pet" then
            actionHudPlayerPetAuras[art.auraID] = art
        else
            actionHudPlayerAuras[art.auraID] = art
        end
    end
end

local function updateDebugPosition()
    local x = tonumber(GwHudFXDebug.x:GetText())
    local y = tonumber(GwHudFXDebug.y:GetText())
    local z = tonumber(GwHudFXDebug.z:GetText())
    local rotation = tonumber(GwHudFXDebug.rotation:GetText())
    if x ~= nil and y ~= nil and z ~= nil and rotation ~= nil then
        Gw2_HudBackgroud.actionBarHudFX:SetPosition(x, y, z)
        Gw2_HudBackgroud.actionBarHudFX:SetFacing(rotation)
        GwHudFXDebug.editbox:SetText(
            "{ x = " .. x .. ", y = " .. y .. ", z = " .. z .. ", rotation = " .. rotation .. " }"
        );
    end
end

local function createCoordDebugInput(self, labelText, index)
    local f = CreateFrame("EditBox", nil, self)
    f:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -(22 * index))
    f:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0 - (22 * index))
    f:SetSize(20, 20)
    f:SetAutoFocus(false)
    f:SetMultiLine(false)
    f:SetMaxLetters(50)
    f:SetFontObject(ChatFontNormal)
    f:SetText("")

    f.bg = f:CreateTexture(nil, "ARTWORK", nil, 1)
    f.bg:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png") -- add custom overlay texture here
    f.bg:SetAllPoints()

    f.label = f:CreateFontString(nil, "ARTWORK")
    f.label:SetPoint("RIGHT", f, "LEFT", 0, 0)
    f.label:SetJustifyH("LEFT")
    f.label:SetJustifyV("MIDDLE")
    f.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "OUTLINE")
    f.label:SetText(labelText)

    f:SetScript("OnTextChanged", function() updateDebugPosition() end)
    return f
end

local function loadFXModelDebug()
    --debug stuff
    local debugModelPositionData = CreateFrame("Frame", "GwHudFXDebug", UIParent)
    debugModelPositionData:SetSize(300, 300)
    debugModelPositionData:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    debugModelPositionData.bg = debugModelPositionData:CreateTexture(nil, "ARTWORK", nil, 1)
    debugModelPositionData.bg:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png") -- add custom overlay texture here
    debugModelPositionData.bg:SetAllPoints()
    debugModelPositionData.bg:SetSize(300, 300)

    debugModelPositionData.editbox = CreateFrame("EditBox", nil, debugModelPositionData)
    debugModelPositionData.editbox:SetPoint("TOPLEFT", debugModelPositionData, "TOPLEFT", 5, -5)
    debugModelPositionData.editbox:SetPoint("BOTTOMRIGHT", debugModelPositionData, "BOTTOMRIGHT", -5, 5)
    debugModelPositionData.editbox:SetAutoFocus(false)
    debugModelPositionData.editbox:SetMultiLine(true)
    debugModelPositionData.editbox:SetMaxLetters(2000)
    debugModelPositionData.editbox:SetFontObject(ChatFontNormal)
    debugModelPositionData.editbox:SetText("")

    debugModelPositionData.x = createCoordDebugInput(debugModelPositionData, "X:", 1)
    debugModelPositionData.y = createCoordDebugInput(debugModelPositionData, "Y:", 2)
    debugModelPositionData.z = createCoordDebugInput(debugModelPositionData, "Z:", 3)
    debugModelPositionData.rotation = createCoordDebugInput(debugModelPositionData, "Rotation:", 4)
end

--[[
C_Timer.After(1, function()
    loadFXModelDebug()
end)
]]

-- Retail: reading auras from insecure code is blocked while they are secret (in
-- combat — exactly when this art shows), so the texture swap runs over invisible
-- aura tracker containers whose button carries the art; the engine shows and hides
-- it with the aura. One container per art, spells sharing textures share a container.
-- Model FX come back as STATIC PlayerModel children of the button (set up once in
-- OnModelLoaded) — only Lua-driven FX reactions to aura values stay impossible.
local function CreateAuraArtContainers(self)
    local artByLeftTexture = {}
    for _, auraList in next, { actionHudPlayerAuras, actionHudPlayerPetAuras } do
        for spellID, aura in pairs(auraList) do
            local art = artByLeftTexture[aura.left]
            if not art then
                art = { left = aura.left, right = aura.right, unit = aura.unit, modelFX = aura.modelFX, spellIDs = {} }
                artByLeftTexture[aura.left] = art
            end
            art.spellIDs[spellID] = true
        end
    end

    -- combat gate: shows the aura art only while in combat (like the old logic).
    -- Driven by a SECURE state driver so that the containers' OnShow refresh runs
    -- untainted and may access the (secret) aura data in combat
    local combatGate = CreateFrame("Frame", "GwHudAuraArtGate", self.actionBarHud)
    combatGate:SetAllPoints(self.actionBarHud)
    RegisterStateDriver(combatGate, "visibility", "[combat] show; hide")
    self.gwAuraArtGate = combatGate

    self.gwAuraArtContainers = {}
    local index = 0
    for _, art in pairs(artByLeftTexture) do
        index = index + 1
        local container = GW.CreateAuraTrackerContainer({
            name = "GwHudAuraArt" .. index,
            -- parented to the combat gate (child of the art frame, so HUD scaling
            -- still applies to the overlays)
            parent = combatGate,
            unit = art.unit,
            filter = "HELPFUL",
            spellIDs = art.spellIDs,
            width = 1024,
            height = 256,
            createWidgets = function(button)
                local left = button:CreateTexture(nil, "BACKGROUND")
                left:SetTexture(art.left)
                left:SetSize(512, 256)
                left:SetPoint("LEFT", button, "LEFT", 0, 0)

                local right = button:CreateTexture(nil, "BACKGROUND")
                right:SetTexture(art.right)
                right:SetSize(512, 256)
                right:SetPoint("RIGHT", button, "RIGHT", 0, 0)

                -- the model FX is fully static per aura (model, position, camera) — only
                -- the show/hide is dynamic, and that comes for free as a button child
                if art.modelFX then
                    local anchor = art.modelFX.anchor
                    local modelPosition = art.modelFX.modelPosition
                    local fx = CreateFrame("PlayerModel", nil, button)
                    fx:SetSize(500, 500)
                    if _G[anchor.target] then
                        fx:SetPoint(anchor.point, _G[anchor.target], anchor.relPoint, anchor.x, anchor.y)
                    else
                        fx:SetPoint("BOTTOM", button, "BOTTOM", anchor.x, anchor.y)
                    end

                    -- models load asynchronously — camera and position have to be applied
                    -- once the model data is there, not right after SetModel. The pcall
                    -- covers late fires while the button subtree is access restricted
                    -- (secret auras in combat); by then the first fire has set things up.
                    local function ApplyModelSetup(model)
                        model:MakeCurrentCameraCustom()
                        model:SetPosition(modelPosition.x, modelPosition.y, modelPosition.z)
                        model:SetFacing(modelPosition.rotation)
                    end
                    fx:SetScript("OnModelLoaded", function(model)
                        pcall(ApplyModelSetup, model)
                    end)
                    fx:SetModel(art.modelFX.modelID)
                    pcall(ApplyModelSetup, fx)
                end
                return {}
            end,
            refreshEvents = art.unit == "pet" and { "UNIT_PET" } or nil,
            refreshUnit = art.unit == "pet" and "player" or nil,
        })
        container:SetFrameLevel(self.actionBarHud:GetFrameLevel() + 1)
        container:ClearAllPoints()
        container:SetPoint("BOTTOM", self.actionBarHud, "BOTTOM", 0, 0)
        tinsert(self.gwAuraArtContainers, container)
    end

    -- settings state (containers stay shown/hidden by settings, combat via the gate)
    UpdateAuraArtVisibility(self)
end

local function hud_OnEvent(self, event, ...)
    if event == "UNIT_AURA" then
        selectBg(self)
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        selectBg(self)
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH_FREQUENT" then
        if GW.Retail then
            combatHealthStateRetail(self)
        else
            combatHealthState(self)
        end
    end
end

local function ToggleHudBackground()
    if Gw2_HudBackgroud.actionBarHud.HUDBG then
        for _, f in ipairs(Gw2_HudBackgroud.actionBarHud.HUDBG) do
            if GW.settings.HUD_BACKGROUND then
                f:Show()
            else
                f:Hide()
            end
        end
    end

    if Gw2_HudBackgroud.edgeTint then
        local showBorder = GW.settings.BORDER_ENABLED
        for _, f in ipairs(Gw2_HudBackgroud.edgeTint) do
            if showBorder then
                f:Show()
            else
                f:Hide()
            end
        end
    end

    UpdateAuraArtVisibility(Gw2_HudBackgroud)
end
GW.ToggleHudBackground = ToggleHudBackground

local function LoadHudArt()
    local hudArtFrame = CreateFrame("Frame", "Gw2_HudBackgroud", UIParent, "GwHudArtFrame")
    if not (GW.Classic or GW.TBC or GW.Wrath) then
        GW.MixinHideDuringPetAndOverride(hudArtFrame)
    end

    if GW.Retail then
        curveOne = C_CurveUtil.CreateColorCurve()
        curveOne:SetType(Enum.LuaCurveType.Linear)
        curveOne:AddPoint(0.0, CreateColor(1, 0, 0, 1))
        curveOne:AddPoint(0.5, CreateColor(1, 1, 1, 1))
        curveOne:AddPoint(1.0, CreateColor(1, 1, 1, 1))

        -- blood overlay alpha, replicating the classic formula clamp(0.8 - 2h):
        -- strongest (0.8) near death, linearly gone at 40% health and above
        curveTwo = C_CurveUtil.CreateColorCurve()
        curveTwo:SetType(Enum.LuaCurveType.Linear)
        curveTwo:AddPoint(0.0, CreateColor(1, 1, 1, 0.8))
        curveTwo:AddPoint(0.4, CreateColor(1, 1, 1, 0))
        curveTwo:AddPoint(1.0, CreateColor(1, 1, 1, 0))

        CreateAuraArtContainers(hudArtFrame)
    end

    ToggleHudBackground()
    GW.RegisterScaleFrame(hudArtFrame.actionBarHud)

    hudArtFrame:SetScript("OnEvent", hud_OnEvent)
    hud_OnEvent(hudArtFrame, "INIT")

    EventRegistry:RegisterCallback("GW2_UI.PlayerSkyrindingStateChanged", function()
        selectBg(hudArtFrame)
    end, hudArtFrame)

    hudArtFrame:RegisterEvent("PLAYER_ALIVE")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    hudArtFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hudArtFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
    hudArtFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    hudArtFrame:RegisterUnitEvent("UNIT_AURA", "player")
    if GW.Classic then
        hudArtFrame:RegisterEvent("UNIT_HEALTH_FREQUENT")
    end

    selectBg(hudArtFrame)
    if GW.Retail then
        combatHealthStateRetail(hudArtFrame)
    else
        combatHealthState(hudArtFrame)
    end

    --Loss Of Control Icon Skin
    if LossOfControlFrame then
        LossOfControlFrame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end

    return hudArtFrame
end
GW.LoadHudArt = LoadHudArt