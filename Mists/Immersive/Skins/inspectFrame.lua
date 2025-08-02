local _, GW = ...

local passiveHighlight = "Interface/AddOns/GW2_UI/textures/talents/passive_highlight"
local activeHighlight = "Interface/AddOns/GW2_UI/textures/talents/active_highlight"
local passiveOutline = "Interface/AddOns/GW2_UI/textures/talents/passive_outline"
local activeOutline = "Interface/AddOns/GW2_UI/textures/talents/background_border"

local function Update_InspectPaperDollItemSlotButton(button)
    local unit = button.hasItem and InspectFrame.unit
    local quality = unit and GetInventoryItemQuality(unit, button:GetID())
    if quality and quality > 1 then
        local r, g, b = C_Item.GetItemQualityColor(quality)
        button.backdrop:SetBackdropBorderColor(r, g, b)
        return
    end

    button.backdrop:SetBackdropBorderColor(1, 1, 1, 1, 0.8)
end

local function UpdateGlyph(frame)
    local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup
    local _, glyphType, _, _, iconFilename = GetGlyphSocketInfo(frame:GetID(), talentGroup, true, INSPECTED_UNIT)
    if iconFilename then
        SetPortraitToTexture(frame.texture, iconFilename)
    else
        frame.texture:SetTexture("Interface/AddOns/GW2_UI/textures/character/glyphs/237647")
    end
    frame.ring:SetTexCoord(0, 1, 0, 1)
    if glyphType == 1 then
        frame.ring:SetSize(60, 60)
    else
        frame.ring:SetSize(50, 50)
    end
end

local function SkinInspectFrameOnLoad()
    if not GW.settings.INSPECTION_SKIN_ENABLED then return end

    InspectFrame:GwStripTextures()
    GW.CreateFrameHeaderWithBody(InspectFrame, InspectNameText, "Interface/AddOns/GW2_UI/textures/character/addon-window-icon", {}, 20)
    InspectFrame.gwHeader.windowIcon:SetSize(65, 65)
    InspectFrame.gwHeader.windowIcon:ClearAllPoints()
    InspectFrame.gwHeader.windowIcon:SetPoint("CENTER", InspectFrame.gwHeader.BGLEFT, "LEFT", 25, -5)
    InspectFrameCloseButton:GwSkinButton(true)
    InspectFrameCloseButton:SetSize(20, 20)
    InspectFrameCloseButton:SetPoint("TOPRIGHT", -5, -5)
    InspectFramePortrait:Hide()
    InspectNameText:SetWidth(250)
    InspectLevelText:ClearAllPoints()
    InspectLevelText:SetPoint("TOP", InspectNameText, "BOTTOM", 0, -10)

    InspectModelFrameBorderTopLeft:GwKill()
    InspectModelFrameBorderTopRight:GwKill()
    InspectModelFrameBorderTop:GwKill()
    InspectModelFrameBorderLeft:GwKill()
    InspectModelFrameBorderRight:GwKill()
    InspectModelFrameBorderBottomLeft:GwKill()
    InspectModelFrameBorderBottomRight:GwKill()
    InspectModelFrameBorderBottom:GwKill()

    hooksecurefunc("InspectFrame_UnitChanged", function(self)
        SetPortraitTexture(InspectFrame.gwHeader.windowIcon, self.unit);
    end)

    InspectFrame:HookScript("OnShow", function(self)
        SetPortraitTexture(InspectFrame.gwHeader.windowIcon, self.unit);
    end)

    for i = 1, 4 do
        GW.HandleTabs(_G["InspectFrameTab" .. i])
        _G["InspectFrameTab" .. i]:SetSize(80, 24)
        _G["InspectFrameTab" .. i]:ClearAllPoints()
        if i == 1 then
            _G["InspectFrameTab" .. i]:SetPoint("BOTTOMLEFT",  InspectFrame, "BOTTOMLEFT", 0, -24)
        else
            _G["InspectFrameTab" .. i]:SetPoint("RIGHT",  _G["InspectFrameTab" .. i - 1], "RIGHT", 75, 0)
        end
    end

    InspectPaperDollFrame:GwStripTextures()

    InspectFrame.mover = CreateFrame("Frame", nil, InspectFrame)
    InspectFrame.mover:EnableMouse(true)
    InspectFrame:SetMovable(true)
    InspectFrame.mover:SetSize(InspectFrame:GetWidth(), 30)
    InspectFrame.mover:SetPoint("BOTTOMLEFT", InspectFrame, "TOPLEFT", 0, -20)
    InspectFrame.mover:SetPoint("BOTTOMRIGHT", InspectFrame, "TOPRIGHT", 0, 20)
    InspectFrame.mover:RegisterForDrag("LeftButton")
    InspectFrame:SetClampedToScreen(true)
    InspectFrame.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    InspectFrame.mover:SetScript("OnDragStop", function(self)
        local self = self:GetParent()

        self:StopMovingOrSizing()
    end)

    for _, slot in ipairs({InspectPaperDollItemsFrame:GetChildren()}) do
        local icon = _G[slot:GetName() .. "IconTexture"]
        local cooldown = _G[slot:GetName() .. "Cooldown"]

        slot:GwStripTextures()
        slot:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
        slot.backdrop:SetAllPoints()
        slot:SetFrameLevel(slot:GetFrameLevel() + 2)
        slot:GwStyleButton()

        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        icon:GwSetInside()

        if cooldown then
            GW.RegisterCooldown(cooldown)
        end
    end

    hooksecurefunc("InspectPaperDollItemSlotButton_Update", Update_InspectPaperDollItemSlotButton)
    hooksecurefunc("PanelTemplates_SelectTab", function(tab)
        local name = tab:GetName()
        local text = tab.Text or _G[name .. "Text"]
        text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 2))
    end)

    GW.HandleRotateButton(InspectModelFrameRotateLeftButton)
    InspectModelFrameRotateLeftButton:SetPoint("TOPLEFT", 3, -3)
    InspectModelFrameRotateLeftButton:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
    InspectModelFrameRotateLeftButton:GetNormalTexture():SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
    InspectModelFrameRotateLeftButton:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
    InspectModelFrameRotateLeftButton:GetPushedTexture():SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0)

    GW.HandleRotateButton(InspectModelFrameRotateRightButton)
    InspectModelFrameRotateRightButton:SetPoint("TOPLEFT", InspectModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)
    InspectModelFrameRotateRightButton:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
    InspectModelFrameRotateRightButton:GetNormalTexture():SetTexCoord(0, 0, 1, 0, 0, 1, 1, 1)
    InspectModelFrameRotateRightButton:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
    InspectModelFrameRotateRightButton:GetPushedTexture():SetTexCoord(0, 1, 0, 0, 1, 1, 1, 0)

    InspectTalentFrame:GwStripTextures()
    local InspectTalents = InspectTalentFrame.InspectTalents
    InspectTalents.tier1:SetPoint("TOPLEFT", 20, -142)

    local InspectSpec = InspectTalentFrame.InspectSpec
    InspectSpec:GwCreateBackdrop(GW.BackdropTemplates.Default)
    InspectSpec.backdrop:SetPoint("TOPLEFT", 15, -13)
    InspectSpec.backdrop:SetPoint("BOTTOMRIGHT", 20, 8)
    InspectSpec:SetHitRectInsets(15, -13, 20, 8)
    InspectSpec.backdrop:SetFrameLevel(InspectTalents:GetFrameLevel())

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
            frame.specName:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
        end

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

                    if talentInfo.selected then
                        button.highlight:Show()
                        button.icon:SetDesaturated(false)
                        button.icon:SetVertexColor(1, 1, 1, 1)
                        button:SetAlpha(1)
                    elseif button.available then
                        button.highlight:Show()
                        button.icon:SetDesaturated(false)
                        button.icon:SetVertexColor(1, 1, 1, 1)
                        button:SetAlpha(1)
                    else
                        button.highlight:Hide()
                        button.icon:SetDesaturated(true)
                        button.icon:SetVertexColor(1, 1, 1, 1)
                        button:SetAlpha(1)
                    end
                end
            end
        end
    end)

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
                button.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/background_border")
                button.outline:SetSize(40, 40)
                button.outline:SetPoint("CENTER", button, "CENTER", 0, 0)

                button.mask = button:CreateMaskTexture()
                button.mask:SetPoint("CENTER", button, "CENTER", 0, 0)
                button.mask:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_border", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                button.mask:SetSize(30, 30)

                if button.icon then
                    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    button.icon:GwSetInside(button.backdrop)
                    button.icon:SetDrawLayer("ARTWORK", 2)
                end
            end
        end
    end

    InspectTalentFrame:HookScript("OnShow", function(frame)
        if frame.isSkinned then return end

        frame.isSkinned = true

        local InspectGlyphs = frame.InspectGlyphs
        for i = 1, 6 do
            local glyph = InspectGlyphs["Glyph" .. i]

            glyph.highlight:SetTexture(nil)
            glyph.glyph:GwKill()
            glyph.ring:SetTexture("Interface/AddOns/GW2_UI/textures/character/glyphbgmajorequip")

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
    end)

    -- Give inspect frame model backdrop it's color back
    for _, corner in pairs({"TopLeft", "TopRight", "BotLeft", "BotRight"}) do
        local bg = _G["InspectModelFrameBackground" .. corner]
        if bg then
            bg:SetDesaturated(false)
            hooksecurefunc(bg, "SetDesaturated", function(bckgnd, value)
                if value and bckgnd.ignoreDesaturated then
                    bckgnd:SetDesaturated(false)
                end
            end)
        end
    end

    -- Honor/Arena/PvP Tab
    InspectPVPFrame:GwStripTextures()

    for _, name in next, { "RatedBG", "Arena2v2", "Arena3v3", "Arena5v5" } do
        local frame = InspectPVPFrame[name]

        if frame then
            frame:GwStripTextures()
            frame:GwCreateBackdrop(GW.BackdropTemplates.Default)
            frame.backdrop:SetPoint("TOPLEFT", 9, -4)
            frame.backdrop:SetPoint("BOTTOMRIGHT", -24, 3)
            frame.backdrop:SetFrameLevel(frame:GetFrameLevel())
        end
    end
end

local function LoadInspectFrameSkin()
    GW.RegisterLoadHook(SkinInspectFrameOnLoad, "Blizzard_InspectUI", InspectFrame)
end
GW.LoadInspectFrameSkin = LoadInspectFrameSkin
