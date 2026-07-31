---@class GW2
local GW = select(2, ...)
local RegisterMovableFrame = GW.RegisterMovableFrame

-- 12.1: Player-Buff-/Debuff-Leisten auf Basis des neuen AuraContainer-Systems
-- (CustomAuraContainerTemplate, laeuft in Blizzards Secure Environment).
-- Ersetzt auf Retail die SecureAuraHeaderTemplate-basierte aurabar aus Games/Shared/Aura.
-- Der Container uebernimmt: sichere Aura-Zuordnung, Sortierung, Layout, Rechtsklick-Cancel,
-- Tooltips sowie saemtliche Anzeige-Updates (Icon, Dauer, Stacks, Dispel-Farbe) ueber die
-- Setter-API von CustomAuraButtonSharedMixin.

local debuffColorCurve

local DIRECTION_TO_POINT = {
    DOWNR = "TOPLEFT",
    DOWN = "TOPRIGHT",
    UPR = "BOTTOMLEFT",
    UP = "BOTTOMRIGHT",
    UPL_COLUMN = "BOTTOMRIGHT",
    UPR_COLUMN = "BOTTOMLEFT",
    DOWNL_COLUMN = "TOPRIGHT",
    DOWNR_COLUMN = "TOPLEFT",
}

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
    UPR = 1,
    DOWNR = 1,
    DOWN = -1,
    UP = -1,
    UPL_COLUMN = -1,
    UPR_COLUMN = 1,
    DOWNL_COLUMN = -1,
    DOWNR_COLUMN = 1,
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
    UPR = 1,
    DOWNR = -1,
    DOWN = -1,
    UP = 1,
    UPL_COLUMN = 1,
    UPR_COLUMN = 1,
    DOWNL_COLUMN = -1,
    DOWNR_COLUMN = -1,
}

local DIRECTION_IS_COLUMN_LAYOUT = {
    UPL_COLUMN = true,
    UPR_COLUMN = true,
    DOWNL_COLUMN = true,
    DOWNR_COLUMN = true,
}

local DIRECTION_TO_DEBUFF_ANCHOR = {
    DOWNR = "BOTTOMLEFT",
    DOWN = "BOTTOMRIGHT",
    UPR = "TOPLEFT",
    UP = "TOPRIGHT",
    UPL_COLUMN = "TOPRIGHT",
    UPR_COLUMN = "TOPLEFT",
    DOWNL_COLUMN = "BOTTOMRIGHT",
    DOWNR_COLUMN = "BOTTOMLEFT",
}

local SORT_METHOD_MAP = {
    INDEX = AuraContainerSortMethod.Default,
    NAME = AuraContainerSortMethod.NameOnly,
    TIME = AuraContainerSortMethod.ExpirationOnly,
}

-- Zwei feste Gruppen pro Container: "eigene" und "fremde" Auras.
-- Damit bilden wir das alte separateOwn (Seperate -1/0/1) ab, da Gruppen nachtraeglich
-- nicht entfernt werden koennen (ClearAuraGroups ist nicht Teil der Inbound-API):
--  Seperate  1: own vor others |  -1: others vor own |  0: own deaktiviert (maxFrameCount 0), others zeigt alles
local GROUP_OWN = "GwAurasOwn"
local GROUP_OTHERS = "GwAurasOthers"

local function GetButtonMainAxisSize(db)
    local width = db.IconSize
    local height = db.KeepSizeRatio and width or db.IconHeight
    return DIRECTION_IS_COLUMN_LAYOUT[db.GrowDirection] and height or width, width, height
end

-- Groesse + Icon-Zuschnitt pro Button (analog UpdateIcon der alten aurabar).
-- WICHTIG: Das Flow-Layout des Containers nutzt elementWidth/Height nur zum Rechnen
-- (GetElementSize) und setzt nur Ankerpunkte (ApplyElementLayout) — die Framegroesse
-- muessen wir selbst setzen, sonst sind die Buttons 0x0 und unsichtbar
local function UpdateButtonSizeAndCrop(button, db)
    local width = db.IconSize
    local height = db.KeepSizeRatio and width or db.IconHeight
    button:SetSize(width, height)

    if not button.status or not button.status.icon then return end

    if db.KeepSizeRatio then
        button.status.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    else
        local left, right, top, bottom = GW.CropRatio(width, height)
        button.status.icon:SetTexCoord(left, right, top, bottom)
    end
end

-- Aufbau der GW-Optik pro Aura-Button (ersetzt GwAuraSecureTmpl aus aurabar.xml).
-- Wird einmalig pro Frame vom Container aufgerufen (batched erstellt, Zugriff in Combat
-- kann durch Secret Values eingeschraenkt sein — deshalb hier NUR Regionen bauen und
-- an die Mixin-Setter uebergeben, keine eigenen Aura-Daten lesen!)
local function InitializeAuraButton(button, header, isDebuff, isEnchant)
    -- Der Button selbst ist forbidden (HookScript/Animationen darauf sind durch
    -- Secret Aspects gesperrt) — deshalb haengt die gesamte GW-Optik an einem
    -- eigenen Wrapper-Frame: dessen OnShow feuert mit, wenn der Container den
    -- Button einblendet, und Animationen darauf sind erlaubt
    local visual = CreateFrame("Frame", nil, button)
    visual:SetAllPoints(button)
    visual:SetFrameLevel(button:GetFrameLevel() + 1)
    button.gwVisual = visual

    -- Rahmen
    local border = CreateFrame("Frame", nil, visual)
    border:SetFrameLevel(visual:GetFrameLevel())
    border:SetPoint("TOPLEFT", visual, "TOPLEFT", 2, -2)
    border:SetPoint("BOTTOMRIGHT", visual, "BOTTOMRIGHT", -2, 2)

    local borderBackground = border:CreateTexture(nil, "BACKGROUND")
    borderBackground:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    borderBackground:SetVertexColor(0, 0, 0)
    borderBackground:SetAllPoints(border)

    border.inner = border:CreateTexture(nil, "BORDER")
    border.inner:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    border.inner:SetAlpha(0.75)
    border.inner:SetPoint("TOPLEFT", border, "TOPLEFT", 1, -1)
    border.inner:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, 1)
    button.border = border

    -- Cooldown-Swipe: sichtbar ist nur der 2px-Ring zwischen Icon (Inset 4) und
    -- Cooldown (Inset 2) — dafuer braucht der Swipe die deckend weisse Textur
    -- (entspricht dem SwipeTexture-Color-Block aus dem alten GwAuraSecureTmpl)
    local cooldown = CreateFrame("Cooldown", nil, visual, "CooldownFrameTemplate")
    cooldown:SetFrameLevel(visual:GetFrameLevel() + 1)
    cooldown:SetPoint("TOPLEFT", visual, "TOPLEFT", 2, -2)
    cooldown:SetPoint("BOTTOMRIGHT", visual, "BOTTOMRIGHT", -2, 2)
    cooldown:SetDrawBling(false)
    cooldown:SetDrawEdge(false)
    cooldown:SetDrawSwipe(true)
    cooldown:SetReverse(false)
    cooldown:SetHideCountdownNumbers(true) -- Dauer-Text kommt als eigener FontString unters Icon
    cooldown:SetSwipeTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png", 1, 1, 1, 1)
    button.cooldown = cooldown

    -- Icon + Overlay + Texte
    local status = CreateFrame("Frame", nil, visual)
    status:SetFrameLevel(visual:GetFrameLevel() + 2)
    status:SetPoint("TOPLEFT", visual, "TOPLEFT", 4, -4)
    status:SetPoint("BOTTOMRIGHT", visual, "BOTTOMRIGHT", -4, 4)
    button.status = status

    status.icon = status:CreateTexture(nil, "ARTWORK")
    status.icon:SetAllPoints(status)

    local overlay = status:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture("Interface/AddOns/GW2_UI/textures/icons/icon-overlay.png")
    overlay:SetAllPoints(status)

    status.stacks = status:CreateFontString(nil, "OVERLAY")
    status.stacks:SetJustifyH("CENTER")
    status.stacks:SetJustifyV("BOTTOM")
    status.stacks:SetPoint("TOPLEFT", status, "BOTTOMLEFT", 1, 15)
    status.stacks:SetPoint("BOTTOMRIGHT", status, "BOTTOMRIGHT", -1, 0)
    status.stacks:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOWOUTLINE")

    status.duration = status:CreateFontString(nil, "OVERLAY")
    status.duration:SetJustifyH("CENTER")
    status.duration:SetSize(36, 13)
    status.duration:SetPoint("TOP", status, "BOTTOM", 0, -6)
    status.duration:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "SHADOW", -1)

    -- Regionen beim Container registrieren — ab hier haelt Blizzard alles aktuell
    button:SetIcon(status.icon)
    button:SetDurationCooldown(cooldown)
    button:SetDurationText(status.duration)
    button:SetApplicationCount(status.stacks)

    -- Rechtsklick-Cancel (macht der Container secure selbst — auch fuer Enchants)
    -- und Tooltip-Anker wie im alten System
    button:SetCancelAuraButtons("RightButtonUp, RightButtonDown")
    button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", -5, -5)

    if isEnchant then
        -- Waffen-Verzauberungen bekommen wie bisher den Curse-farbenen Rahmen
        border.inner:SetVertexColor(GW.Colors.DebuffColors.Curse:GetRGB())
    elseif isDebuff then
        -- Dispel-Typ-Faerbung uebernimmt der Container: PreserveAsset behaelt unsere
        -- Textur und setzt nur die VertexColor anhand der Farbkurve; showWithoutDispelType
        -- sorgt dafuer, dass auch Debuffs ohne Dispel-Typ gefaerbt werden (Kurve: None = 0)
        button:AddDispelTypeTexture(border.inner, {
            style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
            showWhenHarmful = true,
            showWithoutDispelType = true,
            customDispelColorCurve = debuffColorCurve,
        })
    else
        border.inner:SetVertexColor(GW.Colors.Fallback:GetRGB())
    end

    -- HINWEIS: Die alte Zoom-In-Animation fuer neue Auras (NewAuraAnimation) ist mit dem
    -- Container-System nicht umsetzbar: Die Shown-Secrecy des AuraButton-Intrinsics erfasst
    -- die gesamte Kind-Hierarchie — OnShow-Handler (auch auf eigenen Wrapper-Frames) werden
    -- mit "blocked by secret aspects" abgelehnt, damit der Zeitpunkt neuer Auras nicht an
    -- Addon-Code leakt. Falls Blizzard einen Anim-Hook nachliefert, hier wieder einbauen.

    button.header = header
    button.gwInit = true

    -- Button am Container cachen, damit UpdateAuraHeader Settings-Aenderungen
    -- (z. B. den Icon-Zuschnitt) auf alle vorhandenen Buttons anwenden kann
    tinsert(header.gwButtons, button)
    UpdateButtonSizeAndCrop(button, GW.settings[header.setting])
end

local function UpdateAuraHeader(header)
    if not header or not header.gwIsAuraContainer then return end

    local db = GW.settings[header.setting]
    local mainAxisSize, width, height = GetButtonMainAxisSize(db)
    local grow_dir = db.GrowDirection
    local isColumnLayout = DIRECTION_IS_COLUMN_LAYOUT[grow_dir]
    local horizontalSpacing = db.HorizontalSpacing
    local verticalSpacing = db.VerticalSpacing
    local maxWraps = db.MaxWraps
    local wrapAfter = db.WrapAfter
    if not wrapAfter or wrapAfter < 1 or wrapAfter > 20 then
        wrapAfter = 7
    end

    local mainAxisSpacing = isColumnLayout and verticalSpacing or horizontalSpacing
    local crossAxisSpacing = isColumnLayout and horizontalSpacing or verticalSpacing

    -- Flow-Layout des Containers
    header:SetFlowLayoutAxis(isColumnLayout and AnchorUtil.FlowLayoutAxis.Vertical or AnchorUtil.FlowLayoutAxis.Horizontal)
    header:SetFlowLayoutAnchorPoint(DIRECTION_TO_POINT[grow_dir])
    header:SetFlowLayoutGrowthDirection(
        DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[grow_dir] > 0 and AnchorUtil.FlowDirection.Right or AnchorUtil.FlowDirection.Left,
        DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[grow_dir] > 0 and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down
    )
    -- wrapAfter (Anzahl) -> maximale Zeilenlaenge in Pixeln
    header:SetFlowLayoutMaximumLineSize(wrapAfter * (mainAxisSize + mainAxisSpacing))

    -- Sortierung & Gruppen
    local sortMethod = SORT_METHOD_MAP[db.SortMethod] or AuraContainerSortMethod.Default
    local sortDirection = db.SortDir == "-" and AuraContainerSortDirection.Reverse or AuraContainerSortDirection.Normal
    local separate = db.Seperate or 0
    local maxFrames = wrapAfter * maxWraps

    local groupLayout = {
        elementSpacing = mainAxisSpacing,
        lineSpacing = crossAxisSpacing,
        elementWidth = width,
        elementHeight = height,
    }

    if separate == 0 then
        -- keine Trennung: "others" zeigt alles, "own" wird stillgelegt
        header:SetAuraGroupCandidateFilters(GROUP_OTHERS, {})
        header:SetAuraGroupMaxFrameCount(GROUP_OWN, 0)
        header:SetAuraGroupMaxFrameCount(GROUP_OTHERS, maxFrames)
    else
        header:SetAuraGroupCandidateFilters(GROUP_OWN, { isFromPlayerOrPlayerPet = true })
        header:SetAuraGroupCandidateFilters(GROUP_OTHERS, { isFromPlayerOrPlayerPet = false })
        header:SetAuraGroupMaxFrameCount(GROUP_OWN, maxFrames)
        header:SetAuraGroupMaxFrameCount(GROUP_OTHERS, maxFrames)
    end

    local ownLayout = CopyTable(groupLayout)
    local othersLayout = CopyTable(groupLayout)
    ownLayout.layoutIndex = separate == -1 and 2 or 1
    othersLayout.layoutIndex = separate == -1 and 1 or 2

    header:SetAuraGroupSortMethod(GROUP_OWN, sortMethod, sortDirection)
    header:SetAuraGroupSortMethod(GROUP_OTHERS, sortMethod, sortDirection)
    header:SetAuraGroupLayout(GROUP_OWN, ownLayout)
    header:SetAuraGroupLayout(GROUP_OTHERS, othersLayout)

    -- Groesse + Icon-Zuschnitt auf allen gecachten Buttons aktualisieren
    for _, button in next, header.gwButtons do
        UpdateButtonSizeAndCrop(button, db)
    end

    -- isMoved auf den Layout-Proxy spiegeln (der Secure-Layout-Manager liest es dort)
    if header.gwLayoutProxy then
        header.gwLayoutProxy:SetAttribute("isMoved", header.isMoved and true or false)
    end

    -- Containergroesse (fuer Mover-Rahmen), analog zu minWidth/minHeight der alten Header
    local minWidth = ((wrapAfter == 1 and 0 or horizontalSpacing) + width) * (isColumnLayout and maxWraps or wrapAfter)
    local minHeight = ((maxWraps == 1 and 0 or verticalSpacing) + height) * (isColumnLayout and wrapAfter or maxWraps)
    header:SetSize(math.max(minWidth, width + 1), math.max(minHeight, height + 1))

    -- Verankerung: Buffs am Mover, Debuffs relativ zu den Buffs (solange nicht separat verschoben)
    if header.filter == "HELPFUL" then
        header:ClearAllPoints()
        header:SetPoint(DIRECTION_TO_POINT[grow_dir], header.gwMover, DIRECTION_TO_POINT[grow_dir], 0, 0)
    else
        header:ClearAllPoints()
        if not header.isMoved then
            local anchor = DIRECTION_TO_DEBUFF_ANCHOR[grow_dir]
            header:SetPoint(anchor, GW2UIPlayerBuffs, anchor, 0, DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[grow_dir] * (verticalSpacing + height))
        else
            header:SetPoint(DIRECTION_TO_POINT[grow_dir], header.gwMover, DIRECTION_TO_POINT[grow_dir], 0, 0)
        end
    end
end
GW.UpdateAuraHeader = UpdateAuraHeader

local function newContainer(filter)
    local name = filter == "HELPFUL" and "GW2UIPlayerBuffs" or "GW2UIPlayerDebuffs"
    local isDebuff = filter == "HARMFUL"

    local h = CreateFrame("AuraContainer", name, UIParent, "CustomAuraContainerTemplate")
    h:SetClampedToScreen(true)
    h.gwIsAuraContainer = true
    h.gwButtons = {}
    h.filter = filter
    h.setting = filter == "HELPFUL" and "PlayerBuffs" or "PlayerDebuffs"
    h.name = name

    -- feste Gruppen (siehe Kommentar oben) — Optionen werden in UpdateAuraHeader gesetzt
    h:AddAuraGroup(GROUP_OWN, filter, {
        initializeFrame = function(button) InitializeAuraButton(button, h, isDebuff, false) end,
    })
    h:AddAuraGroup(GROUP_OTHERS, filter, {
        initializeFrame = function(button) InitializeAuraButton(button, h, isDebuff, false) end,
    })

    if filter == "HELPFUL" then
        -- Waffen-Verzauberungen (ersetzt includeWeapons + GetWeaponEnchantInfo-Polling)
        for _, slot in next, { AuraContainerItemEnchantmentSlot.MainHand, AuraContainerItemEnchantmentSlot.OffHand } do
            h:AddItemEnchantment(slot, {
                initializeFrame = function(button) InitializeAuraButton(button, h, false, true) end,
            })
        end
        h:SetItemEnchantmentLayout({ placement = CustomAuraContainerItemEnchantmentPlacement.BeforeAuraGroups })

        RegisterMovableFrame(h, SHOW_BUFFS, "PlayerBuffFrame", "Blizzard,Aura", {316, 100}, {"default", "scaleable"}, true)
    else
        RegisterMovableFrame(h, SHOW_DEBUFFS, "PlayerDebuffFrame", "Blizzard,Aura", {316, 60}, {"default", "scaleable"}, true)
    end

    -- Der AuraContainer ist ein "forbidden frame": SecureHandler-FrameRefs (Layout-Manager)
    -- sind darauf nicht erlaubt. Ein protected Proxy vertritt ihn im Secure-Layout —
    -- der Snippet togglet nur Show/Hide und liest das isMoved-Attribut am registrierten Frame,
    -- verschoben wird ohnehin nur der Mover, an dem der Container haengt.
    local proxy = CreateFrame("Frame", nil, UIParent, "SecureFrameTemplate")
    proxy:SetSize(1, 1)
    proxy:SetPoint("BOTTOM")
    proxy.gwMover = h.gwMover
    proxy:SetAttribute("isMoved", h.isMoved and true or false)
    proxy:HookScript("OnShow", function() h:Show() end)
    proxy:HookScript("OnHide", function() h:Hide() end)
    h.gwLayoutProxy = proxy

    -- Fahrzeug-Wechsel: der Container ist unit-basiert, das alte Attribute-Driver-Konstrukt
    -- ersetzt ein einfacher (insecurer) Event-Switch
    h:SetUnit("player")
    -- WICHTIG: Container sind per Default disabled — ohne SetEnabled(true) registriert
    -- der Container kein UNIT_AURA und parst nichts (ShouldRegisterForDynamicEvents
    -- verlangt IsVisible() UND IsEnabled())
    h:SetEnabled(true)
    local unitWatcher = CreateFrame("Frame")
    unitWatcher:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
    unitWatcher:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
    unitWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    unitWatcher:SetScript("OnEvent", function()
        h:SetUnit(UnitHasVehicleUI("player") and "vehicle" or "player")
    end)

    -- waehrend Haustierkaempfen ausblenden (ersetzt den SecureHandler-StateDriver)
    local petBattleWatcher = CreateFrame("Frame")
    petBattleWatcher:RegisterEvent("PET_BATTLE_OPENING_START")
    petBattleWatcher:RegisterEvent("PET_BATTLE_CLOSE")
    petBattleWatcher:SetScript("OnEvent", function(_, event)
        h:SetShown(event ~= "PET_BATTLE_OPENING_START")
    end)

    UpdateAuraHeader(h)

    return h
end

local function loadAuras(lm)
    local hb = newContainer("HELPFUL")
    hb:Show()
    lm:RegisterBuffFrame(hb.gwLayoutProxy)
    hooksecurefunc(hb.gwMover, "StopMovingOrSizing", function()
        local grow_dir = GW.settings[hb.setting].GrowDirection
        local anchor_hb = DIRECTION_TO_POINT[grow_dir]

        hb:ClearAllPoints()
        hb:SetPoint(anchor_hb, hb.gwMover, anchor_hb, 0, 0)
    end)

    local hd = newContainer("HARMFUL")
    hd:Show()
    lm:RegisterDebuffFrame(hd.gwLayoutProxy)
    hooksecurefunc(hd.gwMover, "StopMovingOrSizing", function()
        local grow_dir = GW.settings[hd.setting].GrowDirection
        local anchor_hd = DIRECTION_TO_POINT[grow_dir]

        hd:ClearAllPoints()
        hd:SetPoint(anchor_hd, hd.gwMover, anchor_hd, 0, 0)
    end)

    -- Raise PetBattleFrame
    if PetBattleFrame then
        PetBattleFrame:SetFrameLevel(hb:GetFrameLevel() + 5)
    end

    -- Private Auras gibt es in 12.1 nicht mehr als eigenes System —
    -- sie laufen jetzt als normale Debuffs durch den Container
end

local function LoadPlayerAuras(lm)
    -- Blizzard-Leisten ausblenden
    BuffFrame:GwKill()
    if DebuffFrame then
        DebuffFrame:GwKill()
    end

    -- Farbkurve fuer die Dispel-Faerbung der Debuff-Rahmen
    if C_CurveUtil then
        debuffColorCurve = C_CurveUtil.CreateColorCurve()
        debuffColorCurve:SetType(Enum.LuaCurveType.Step)
        for _, dispelIndex in next, GW.Enum.DispelType do
            if GW.Colors.DebuffColors[dispelIndex] then
                debuffColorCurve:AddPoint(dispelIndex, GW.Colors.DebuffColors[dispelIndex])
            end
        end
    end

    -- Der Container nutzt ein eigenes (secure) Tooltip — Optik auf GW-Style umstellen,
    -- aber nur wenn der GW-Tooltip-Skin ueberhaupt aktiv ist
    if GW.settings.TOOLTIPS_ENABLED then
        AuraContainerInbound.SetTooltipBackdrop({
            backdropInfo = GW.BackdropTemplates.Default,
        })
    end

    loadAuras(lm)
end
GW.LoadPlayerAuras = LoadPlayerAuras
