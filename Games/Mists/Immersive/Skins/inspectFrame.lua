---@class GW2
local GW = select(2, ...)

-- Window, header, tabs, paperdoll and model come from the shared base skin; what is left here are the panels
-- mists brings on top: the talent tree with its specialisation and the glyph sockets.

local passiveHighlight = "Interface/AddOns/GW2_UI/textures/talents/passive_highlight.png"
local activeHighlight = "Interface/AddOns/GW2_UI/textures/talents/active_highlight.png"
local passiveOutline = "Interface/AddOns/GW2_UI/textures/talents/passive_outline.png"
local activeOutline = "Interface/AddOns/GW2_UI/textures/talents/background_border.png"

local function UpdateGlyph(frame)
    local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup
    local _, glyphType, _, _, iconFilename = GetGlyphSocketInfo(frame:GetID(), talentGroup, true, INSPECTED_UNIT)
    if iconFilename then
        SetPortraitToTexture(frame.texture, iconFilename)
    else
        frame.texture:SetTexture("Interface/AddOns/GW2_UI/textures/character/glyphs/237647.png")
    end
    frame.ring:SetTexCoord(0, 1, 0, 1)
    if glyphType == 1 then
        frame.ring:SetSize(60, 60)
    else
        frame.ring:SetSize(50, 50)
    end
end

local function UpdateTalentButtons()
    local talentInfoQuery = {
        groupIndex = 1,
        isInspect = false,
        target = INSPECTED_UNIT
    }

    for i = 1, 6 do
        for j = 1, 3 do
            local button = _G["InspectTalentFrameTalentRow" .. i .. "Talent" .. j]
            if button then
                talentInfoQuery.tier = i
                talentInfoQuery.column = j
                local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
                local isPassive = IsPassiveSpell(talentInfo.spellID)
                if isPassive then
                    button.highlight:SetTexture(passiveHighlight)
                    button.icon:AddMaskTexture(button.mask)
                    button.outline:SetTexture(passiveOutline)
                else
                    button.highlight:SetTexture(activeHighlight)
                    button.icon:RemoveMaskTexture(button.mask)
                    button.outline:SetTexture(activeOutline)
                end

                button.icon:SetVertexColor(1, 1, 1, 1)
                button:SetAlpha(1)
                if talentInfo.selected or button.available then
                    button.highlight:Show()
                    button.icon:SetDesaturated(false)
                else
                    button.highlight:Hide()
                    button.icon:SetDesaturated(true)
                end
            end
        end
    end
end

local function SkinSpec()
    local InspectSpec = InspectTalentFrame.InspectSpec
    InspectSpec:GwCreateBackdrop(GW.BackdropTemplates.Default)
    InspectSpec.backdrop:SetPoint("TOPLEFT", 15, -13)
    InspectSpec.backdrop:SetPoint("BOTTOMRIGHT", 20, 8)
    InspectSpec:SetHitRectInsets(15, -13, 20, 8)
    InspectSpec.backdrop:SetFrameLevel(InspectTalentFrame.InspectTalents:GetFrameLevel())

    InspectSpec.ring:SetTexture("")

    InspectSpec.specIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    InspectSpec.specIcon.backdrop = CreateFrame("Frame", nil, InspectSpec)
    InspectSpec.specIcon.backdrop:GwSetOutside(InspectSpec.specIcon)
    InspectSpec.specIcon:SetParent(InspectSpec.specIcon.backdrop)

    InspectSpec:HookScript("OnShow", function(frame)
        frame.tooltip = nil

        local spec = INSPECTED_UNIT and GetInspectSpecialization(INSPECTED_UNIT)
        local _, _, desc, icon = GetSpecializationInfoByID(spec, UnitSex(INSPECTED_UNIT))
        if icon and desc then
            frame.tooltip = desc
            frame.roleIcon:SetSize(20, 20)
            frame.roleIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            frame.roleName:SetTextColor(1, 1, 1)
            frame.specIcon:SetTexture(icon)
            frame.specName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        end

        UpdateTalentButtons()
    end)
end

local function SkinTalentButtons()
    for i = 1, 6 do
        for j = 1, 3 do
            local button = _G["InspectTalentFrameTalentRow" .. i .. "Talent" .. j]
            if button then
                button:GwStripTextures()
                button:SetSize(30, 30)
                button:GwStyleButton(nil, true)
                button:GetHighlightTexture():GwSetInside(button.backdrop)
                button.highlight = button:GetHighlightTexture()
                button.highlight:SetSize(30, 30)

                button.outline = button:CreateTexture(nil, "BACKGROUND")
                button.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/background_border.png")
                button.outline:SetSize(40, 40)
                button.outline:SetPoint("CENTER", button, "CENTER", 0, 0)

                button.mask = button:CreateMaskTexture()
                button.mask:SetPoint("CENTER", button, "CENTER", 0, 0)
                button.mask:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_border.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                button.mask:SetSize(30, 30)

                if button.icon then
                    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    button.icon:GwSetInside(button.backdrop)
                    button.icon:SetDrawLayer("ARTWORK", 2)
                end
            end
        end
    end
end

-- the sockets only exist once the talent frame has been shown for the first time
local function SkinGlyphs(frame)
    if frame.gwSkinned then return end
    frame.gwSkinned = true

    local InspectGlyphs = frame.InspectGlyphs
    for i = 1, 6 do
        local glyph = InspectGlyphs["Glyph" .. i]

        glyph.highlight:SetTexture(nil)
        glyph.glyph:GwKill()
        glyph.ring:SetTexture("Interface/AddOns/GW2_UI/textures/character/glyphbgmajorequip.png")
        glyph:SetSize(i % 2 == 1 and 30 or 50, i % 2 == 1 and 30 or 50)

        if not glyph.texture then
            glyph.texture = glyph:CreateTexture(nil, "OVERLAY", nil, 7)
            glyph.texture:GwSetInside()

            UpdateGlyph(glyph)
            hooksecurefunc(glyph, "UpdateSlot", UpdateGlyph)
        end
    end

    InspectGlyphs.Glyph1:SetPoint("TOPLEFT", 90, -10)
    InspectGlyphs.Glyph2:SetPoint("TOPLEFT", 15, 0)
    InspectGlyphs.Glyph3:SetPoint("TOPLEFT", 90, -100)
    InspectGlyphs.Glyph4:SetPoint("TOPLEFT", 15, -90)
    InspectGlyphs.Glyph5:SetPoint("TOPLEFT", 90, -190)
    InspectGlyphs.Glyph6:SetPoint("TOPLEFT", 15, -180)
end

local function SkinInspectFrameOnLoad()
    if not GW.SkinInspectFrameBase() then return end

    InspectTalentFrame:GwStripTextures()
    InspectTalentFrame.InspectTalents.tier1:SetPoint("TOPLEFT", 20, -142)
    SkinSpec()
    SkinTalentButtons()
    InspectTalentFrame:HookScript("OnShow", SkinGlyphs)
end

local function LoadInspectFrameSkin()
    GW.RegisterLoadHook(SkinInspectFrameOnLoad, "Blizzard_InspectUI", InspectFrame)
end
GW.LoadInspectFrameSkin = LoadInspectFrameSkin
