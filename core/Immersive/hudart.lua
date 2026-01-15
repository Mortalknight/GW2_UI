local _, GW = ...

local actionHudPlayerAuras = {}
local actionHudPlayerPetAuras = {}

local curveOne, curveTwo

local function registerActionHudAura(auraID, left, right, unit, modelFX)
    if unit == "player" then
        actionHudPlayerAuras[auraID] = {}
        actionHudPlayerAuras[auraID].auraID = auraID
        actionHudPlayerAuras[auraID].left = left
        actionHudPlayerAuras[auraID].right = right
        actionHudPlayerAuras[auraID].unit = unit
        actionHudPlayerAuras[auraID].modelFX = modelFX
    elseif unit == "pet" then
        actionHudPlayerPetAuras[auraID] = {}
        actionHudPlayerPetAuras[auraID].auraID = auraID
        actionHudPlayerPetAuras[auraID].left = left
        actionHudPlayerPetAuras[auraID].right = right
        actionHudPlayerPetAuras[auraID].unit = unit
        actionHudPlayerPetAuras[auraID].modelFX = modelFX
    end
end
GW.AddForProfiling("hud", "registerActionHudAura", registerActionHudAura)

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
GW.AddForProfiling("hud", "createModelFx", createModelFx)

local currentTexture = nil

local function selectBg(self)
    if not GW.settings.HUD_BACKGROUND or not GW.settings.HUD_SPELL_SWAP then
        return
    end

    local right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow.png"
    local left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow.png"
    local modelFX = nil

    if UnitIsDeadOrGhost("player") then
        right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow_dead.png"
        left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow_dead.png"
    end

    if GW.myClassID == 11 then --Druid
        local form = GetShapeshiftFormID()
        if form == BEAR_FORM then
            right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow_bear.png"
            left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow_bear.png"
        elseif form == CAT_FORM then
            right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow_cat.png"
            left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow_cat.png"
        end
    end

    if GW.Libs.GW2Lib:IsPlayerSkyRiding() then
        right = "Interface/AddOns/GW2_UI/textures/hud/rightshadow-dragon.png"
        left = "Interface/AddOns/GW2_UI/textures/hud/leftshadow-dragon.png"
    end

    if UnitAffectingCombat("player") then
        right = "Interface/AddOns/GW2_UI/textures/hud/rightshadowcombat.png"
        left = "Interface/AddOns/GW2_UI/textures/hud/leftshadowcombat.png"

        local auraFound = false
        if not GW.Retail then
            for spellID, auraData in pairs(actionHudPlayerAuras) do
                if C_UnitAuras.GetPlayerAuraBySpellID(spellID) then
                    C_UnitAuras.GetPlayerAuraBySpellID(375087)
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
GW.AddForProfiling("hud", "selectBg", selectBg)

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

registerActionHudAura(
    5487,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_bear.png",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_bear.png",
    "player"
)

registerActionHudAura(
    768,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_cat.png",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_cat.png",
    "player"
)

--retail
registerActionHudAura(
    31842,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_holy.png",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_holy.png",
    "player"
)
registerActionHudAura(
    31884,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_holy.png",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_holy.png",
    "player"
)
registerActionHudAura(
    51271,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_frost.png",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_frost.png",
    "player"
)
registerActionHudAura(
    162264,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_metamorph.png",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_metamorph.png",
    "player"
)
registerActionHudAura(
    187827,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_metamorph.png",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_metamorph.png",
    "player"
)
registerActionHudAura(
    215785,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_shaman_fire.png",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_shaman_fire.png",
    "player"
)
registerActionHudAura(
    77762,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_shaman_fire.png",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_shaman_fire.png",
    "player"
)
registerActionHudAura(
    201846,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_shaman_storm.png",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_shaman_storm.png",
    "player"
)
registerActionHudAura(
    63560,
    "Interface/AddOns/GW2_UI/textures/hud/leftshadow_unholy.png",
    "Interface/AddOns/GW2_UI/textures/hud/rightshadow_unholy.png",
    "pet"
)
registerActionHudAura(
    375087,
    "Interface/AddOns/GW2_UI/textures/hud/evokerdpsleft.png",
    "Interface/AddOns/GW2_UI/textures/hud/evokerdpsright.png",
    "player", {
        anchor = {
            point = "BOTTOM",
            relPoint = "BOTTOM",
            target = "Gw2_HudBackgroud",
            x = 0,
            y = 50

        },
        modelID = 4697927,

        modelPosition =
        { x = 2, y = 0, z = 0, rotation = 0 }
    }
)
-- Lunar Eclipse
registerActionHudAura(
    48518,
    "Interface/AddOns/GW2_UI/textures/hud/left_lunareclipse.png",
    "Interface/AddOns/GW2_UI/textures/hud/right_lunareclipse.png",
    "player",
    {
        anchor = {
            point = "BOTTOM",
            relPoint = "BOTTOM",
            target = "Gw2_HudBackgroud",
            x = 0,
            y = 100

        },
        modelID = 1513212,

        modelPosition =
        {
            x = -2.5,
            y = 0,
            z = -3.4,
            rotation = 0
        }
    }
)
--Solar Eclipse
registerActionHudAura(
    48517,
    "Interface/AddOns/GW2_UI/textures/hud/left_solareclips.png",
    "Interface/AddOns/GW2_UI/textures/hud/right_solareclips.png",
    "player",
    {
        anchor = {
            point = "BOTTOM",
            relPoint = "BOTTOM",
            target = "Gw2_HudBackgroud",
            x = 0,
            y = 100

        },
        modelID = 530798,

        modelPosition =
        {
            x = 2,
            y = 0,
            z = -0.1,
            rotation = 0
        }
    }
)



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
    f.label:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
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
GW.AddForProfiling("hud", "hud_OnEvent", hud_OnEvent)

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
end
GW.ToggleHudBackground = ToggleHudBackground

local function LoadHudArt()
    local hudArtFrame = CreateFrame("Frame", "Gw2_HudBackgroud", UIParent, "GwHudArtFrame")
    if not (GW.Classic or GW.TBC) then
        GW.MixinHideDuringPetAndOverride(hudArtFrame)
    end

    if GW.Retail then
        curveOne = C_CurveUtil.CreateColorCurve()
        curveOne:SetType(Enum.LuaCurveType.Linear)
        curveOne:AddPoint(0.0, CreateColor(1, 0, 0, 1))
        curveOne:AddPoint(0.5, CreateColor(1, 1, 1, 1))
        curveOne:AddPoint(1.0, CreateColor(1, 1, 1, 1))

        curveTwo = C_CurveUtil.CreateColorCurve()
        curveTwo:SetType(Enum.LuaCurveType.Linear)
        curveTwo:AddPoint(0.0, CreateColor(1, 1, 1, 0.8))
        curveTwo:AddPoint(0.5, CreateColor(1, 1, 1, 1))
        curveTwo:AddPoint(1.0, CreateColor(1, 1, 1, 0))
    end

    ToggleHudBackground()
    GW.RegisterScaleFrame(hudArtFrame.actionBarHud)

    hudArtFrame:SetScript("OnEvent", hud_OnEvent)
    hud_OnEvent(hudArtFrame, "INIT")

    GW.Libs.GW2Lib.RegisterCallback(hudArtFrame, "GW2_PLAYER_SKYRIDING_STATE_CHANGE", function()
        selectBg(hudArtFrame)
    end)

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