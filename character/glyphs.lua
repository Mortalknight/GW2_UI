local _, GW = ...

local function setGlyphButtonState(self, active)
    if active then
        self.name:SetTextColor(0.7, 0.7, 0.5, 1)
        self.typeName:SetTextColor(0.5, 0.5, 0.5, 1)
        self.icon:SetDesaturated(false);
    else
        self.name:SetTextColor(0.5, 0.5, 0.5, 1)
        self.typeName:SetTextColor(0.3, 0.3, 0.3, 1)
        self.icon:SetDesaturated(true);
    end
end

local function skinButton(button)
    button:GwSkinButton(false, true)

    button.name:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE")
    button.name:SetTextColor(0.7, 0.7, 0.5, 1)
    button.typeName:SetFont(DAMAGE_TEXT_FONT, 10, "OUTLINE")
    button.typeName:SetTextColor(0.5, 0.5, 0.5, 1)

    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg")
    button:GetNormalTexture():SetBlendMode("ADD")
    button:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
    button:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
    button:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
    button.selectedTex:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress")
    button.selectedTex:SetTexCoord(0, 1, 0, 1)
end


local function updateGlyphListFrame()
    if InCombatLockdown() then return end
    local scrollFrame = GlyphFrame.scrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons
    local numButtons = #buttons
    local numGlyphs = GetNumGlyphs()
    local currentHeader = 1

    for i = 1, numButtons do
        local button = buttons[i]
        local idx = offset + i
        if idx <= numGlyphs  then
            local name, glyphType, isKnown, icon, glyphID = GetGlyphInfo(idx)
            if name == "header" then
                local header = _G["GlyphFrameHeader"..currentHeader]
                if not header.skinned then
                    header.skinned = true
                    header:GwStripTextures()
                    header:GwCreateBackdrop('Transparent')
                    header.name:SetFont(DAMAGE_TEXT_FONT, 14, "OUTLINE")
                    header.name:SetTextColor(1, 1, 1, 1)

                    header:HookScript("OnClick", updateGlyphListFrame)
                end

                currentHeader = currentHeader + 1;
            else
                setGlyphButtonState(button, isKnown)
            end
        end
    end
end



local function glyphFrame_Update()
    --TODO: Adjust to out talents
    --Set the PlayerTalentFrame.pet and PlayerTalentFrame.talentGroup to the correct value if our talent frame is used
end


local function takeOverBlizzardsGlypheFrame()
    TalentFrame_LoadUI()
    GlyphFrame_LoadUI()

    --Error message

 
    local glyphesFrame = CreateFrame("Frame", "GwGlyphesFrame", GwCharacterWindow, "GwGlyphTempContainer")
    hooksecurefunc("GlyphFrame_OnEvent", function(self, event, ...)
        if ( event == "ADDON_LOADED" ) then
            local name = ...
            if ( name == "Blizzard_GlyphUI" and C_AddOns.IsAddOnLoaded("Blizzard_TalentUI") or name == "Blizzard_TalentUI" ) then
                self:ClearAllPoints()
                self:SetParent(glyphesFrame)
                self:SetPoint("TOPLEFT", glyphesFrame, 3, 0)
                self:SetPoint("BOTTOMRIGHT", glyphesFrame, -150, 20)
            end
        elseif event == "USE_GLYPH" then
            updateGlyphListFrame()
        end
    end)

    glyphesFrame.notice:SetFont(UNIT_NAME_FONT,12)

    glyphesFrame.notice:SetText("Notice: You might encounter an error message when attempting to apply a glyph. This is because Blizzard has not re-implemented some of their glyph API functions. You can simply ignore this message and try again.")


    GlyphFrame_OnEvent(GlyphFrame, "ADDON_LOADED", "Blizzard_GlyphUI")
    GlyphFrame:Show()

    GlyphFrame.sideInset:ClearAllPoints()
    GlyphFrame.sideInset:SetPoint("TOPLEFT", glyphesFrame, "TOPRIGHT", -200, -60)
    GlyphFrame.sideInset:SetPoint("BOTTOMRIGHT", glyphesFrame, "BOTTOMRIGHT", -10, 100)

    GlyphFrame.background:SetSize(650, 600)
    GlyphFrame.background:SetTexture()

    -- skinning
    updateGlyphListFrame()
    hooksecurefunc(GlyphFrame.scrollFrame, "update", updateGlyphListFrame)
    hooksecurefunc("GlyphFrame_UpdateGlyphList", updateGlyphListFrame)
    hooksecurefunc("GlyphFrame_Update", glyphFrame_Update)
    GlyphFrameSideInsetBackground:Hide()

    GlyphFrame.glow:ClearAllPoints()
    GlyphFrame.glow:SetPoint("TOPLEFT", glyphesFrame, 3, 0)
    GlyphFrame.glow:SetPoint("BOTTOMRIGHT", glyphesFrame, -150, 20)

    GlyphFrame.sparkleFrame:GwKill()
    GlyphFrame.sideInset:GwStripTextures()

    GlyphFrame.clearInfo:ClearAllPoints()
    GlyphFrame.clearInfo:SetPoint("TOPLEFT", glyphesFrame, "TOPLEFT", 10, -10)
    GlyphFrame.clearInfo.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    GlyphFrame.clearInfo.name:SetFont(DAMAGE_TEXT_FONT, 12, "OUTLINE")
    GlyphFrame.clearInfo.name:SetTextColor(1, 1, 1, 1)

    GlyphFrame.scrollFrame:GwSkinScrollFrame()
    GlyphFrameScrollFrameScrollBar:GwSkinScrollBar()

    GlyphFrameFilterDropDown:GwSkinDropDownMenu(20, GW.BackdropTemplates.DopwDown, 20)
    GlyphFrameFilterDropDown:SetWidth(167)
    GlyphFrameFilterDropDown:ClearAllPoints()
    GlyphFrameFilterDropDown:SetPoint("TOPLEFT", GlyphFrameSearchBox, "BOTTOMLEFT", -5, -3)

    GW.SkinTextBox(GlyphFrameSearchBoxMiddle, GlyphFrameSearchBoxLeft, GlyphFrameSearchBoxRight)

    return glyphesFrame
end

local function LoadGlyphes()
    hooksecurefunc("HybridScrollFrame_CreateButtons", function(self, name)
        if name == "GlyphSpellButtonTemplate" and not self.isGw2Skinned then
            self.isGw2Skinned = true
            -- skinn buttons here
            local buttons = self.buttons
            for i = 1, #buttons do
                if not buttons[i].isGw2Skinned then
                    buttons[i].isGw2Skinned = true
                    skinButton(buttons[i])
                end
            end
        end
    end)

    UIParent:UnregisterEvent("USE_GLYPH")
    return takeOverBlizzardsGlypheFrame()
end
GW.LoadGlyphes = LoadGlyphes
