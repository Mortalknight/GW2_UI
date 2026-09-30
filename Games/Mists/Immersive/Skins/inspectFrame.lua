---@class GW2
local GW = select(2, ...)

-- Window, header, tabs, paperdoll and model come from the shared base skin; what is left here are the panels
-- mists brings on top: the talent tree with its specialisation and the glyph sockets.

local TALENT_TEXTURES = {
    passive = {
        highlight = "Interface/AddOns/GW2_UI/textures/talents/passive_highlight.png",
        outline = "Interface/AddOns/GW2_UI/textures/talents/passive_outline.png",
    },
    active = {
        highlight = "Interface/AddOns/GW2_UI/textures/talents/active_highlight.png",
        outline = "Interface/AddOns/GW2_UI/textures/talents/background_border.png",
    },
}

-- majors sit on the right column, minors on the left; offsets per glyph id
local GLYPH_POINTS = { { 90, -10 }, { 15, 0 }, { 90, -100 }, { 15, -90 }, { 90, -190 }, { 15, -180 } }

-- our art per Blizzard button, kept out of their frames
local talentButtons = {}
local glyphIcons = {}
local glyphsSkinned = false

local function UpdateGlyph(glyph)
    local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup
    local _, glyphType, _, _, iconFilename = GetGlyphSocketInfo(glyph:GetID(), talentGroup, true, INSPECTED_UNIT)
    local icon = glyphIcons[glyph]
    if iconFilename then
        SetPortraitToTexture(icon, iconFilename)
    else
        icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/glyphs/237647.png")
    end

    -- Blizzard crops its ring atlas per type, ours is a whole texture
    local ringSize = glyphType == 1 and 60 or 50
    glyph.ring:SetTexCoord(0, 1, 0, 1)
    glyph.ring:SetSize(ringSize, ringSize)
end

local function UpdateTalentButtons()
    local query = { groupIndex = 1, isInspect = false, target = INSPECTED_UNIT }
    for _, entry in ipairs(talentButtons) do
        query.tier, query.column = entry.tier, entry.column
        local info = C_SpecializationInfo.GetTalentInfo(query)
        local art = IsPassiveSpell(info.spellID) and TALENT_TEXTURES.passive or TALENT_TEXTURES.active
        local button = entry.button
        local chosen = info.selected or button.available

        entry.highlight:SetTexture(art.highlight)
        entry.highlight:SetShown(chosen)
        entry.outline:SetTexture(art.outline)
        -- passive talents get a round icon
        if art == TALENT_TEXTURES.passive then
            button.icon:AddMaskTexture(entry.mask)
        else
            button.icon:RemoveMaskTexture(entry.mask)
        end
        button.icon:SetVertexColor(GW.Colors.FallbackWhite:GetRGBA())
        button.icon:SetDesaturated(not chosen)
        button:SetAlpha(1)
    end
end

local function SkinTalentButton(button, tier, column)
    button:GwStripTextures()
    button:SetSize(30, 30)
    button:GwStyleButton(nil, true)

    local highlight = button:GetHighlightTexture()
    highlight:GwSetInside(button.backdrop)
    highlight:SetSize(30, 30)

    local outline = button:CreateTexture(nil, "BACKGROUND")
    outline:SetPoint("CENTER")
    outline:SetSize(40, 40)

    local mask = button:CreateMaskTexture()
    mask:SetPoint("CENTER")
    mask:SetSize(30, 30)
    mask:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_border.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.icon:GwSetInside(button.backdrop)
    button.icon:SetDrawLayer("ARTWORK", 2)

    talentButtons[#talentButtons + 1] = { button = button, tier = tier, column = column, highlight = highlight, outline = outline, mask = mask }
end

local function SkinTalents()
    local talents = InspectTalentFrame.InspectTalents
    talents.tier1:SetPoint("TOPLEFT", 20, -142)

    local tier = 1
    while talents["tier" .. tier] do
        local row = talents["tier" .. tier]
        local column = 1
        while row["talent" .. column] do
            SkinTalentButton(row["talent" .. column], tier, column)
            column = column + 1
        end
        tier = tier + 1
    end

    -- Blizzard refreshes the talents through this method once the inspect data arrives
    hooksecurefunc(talents, "OnShow", UpdateTalentButtons)
end

-- Blizzard fills in name, icon and tooltip itself, only the looks change
local function SkinSpec()
    local spec = InspectTalentFrame.InspectSpec
    spec:GwCreateBackdrop(GW.BackdropTemplates.Default)
    spec.backdrop:SetPoint("TOPLEFT", 15, -13)
    spec.backdrop:SetPoint("BOTTOMRIGHT", 20, 8)
    -- below the spec icon and texts
    spec.backdrop:SetFrameLevel(max(0, spec:GetFrameLevel() - 1))
    spec:SetHitRectInsets(15, -13, 20, 8)

    spec.ring:SetTexture("")
    spec.specIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    spec.roleIcon:SetSize(20, 20)
    spec.specName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    spec.roleName:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
end

-- the sockets are filled once the talent frame shows for the first time
local function SkinGlyphs(frame)
    if glyphsSkinned then return end
    glyphsSkinned = true

    for id, point in ipairs(GLYPH_POINTS) do
        local glyph = frame.InspectGlyphs["Glyph" .. id]
        local size = id % 2 == 1 and 30 or 50
        glyph:SetSize(size, size)
        glyph:SetPoint("TOPLEFT", point[1], point[2])
        glyph.highlight:SetTexture(nil)
        glyph.glyph:GwKill()
        glyph.ring:SetTexture("Interface/AddOns/GW2_UI/textures/character/glyphbgmajorequip.png")

        local icon = glyph:CreateTexture(nil, "OVERLAY", nil, 7)
        icon:GwSetInside()
        glyphIcons[glyph] = icon
        UpdateGlyph(glyph)
        hooksecurefunc(glyph, "UpdateSlot", UpdateGlyph)
    end
end

local function SkinInspectFrameOnLoad()
    if not GW.SkinInspectFrameBase() then return end

    InspectTalentFrame:GwStripTextures()
    SkinSpec()
    SkinTalents()
    InspectTalentFrame:HookScript("OnShow", SkinGlyphs)
end

local function LoadInspectFrameSkin()
    GW.RegisterLoadHook(SkinInspectFrameOnLoad, "Blizzard_InspectUI", InspectFrame)
end
GW.LoadInspectFrameSkin = LoadInspectFrameSkin
