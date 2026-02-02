local _, GW = ...

local function ReplaceIconString(frame, text)
    if frame._gw2SetText then return end
    if not text then text = frame:GetText() end
    if not text or text == "" then return end

    local newText, count = gsub(text, "|T(%d+):24:24[^|]*|t", " |T%1:16:16:0:0:64:64:5:59:5:59|t")
    if count > 0 and newText ~= text then
        frame._gw2SetText = true
        frame:SetFormattedText("%s", newText)
        frame._gw2SetText = false
    end
end

local function RemoveTexture(self)
    self.BorderOverlay:Hide()
    self.Background:Hide()
    self.NineSlice:Hide()
end

local function GenericTraitFrameSkin()
    GenericTraitFrame:GwStripTextures()
    GenericTraitFrame.BorderOverlay:Hide()
    GenericTraitFrame.Background:Hide()
    GW.CreateFrameHeaderWithBody(GenericTraitFrame, GenericTraitFrame.Header.Title, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon.png")
    GenericTraitFrame.Header.Title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)

    GenericTraitFrame.CloseButton:GwSkinButton(true)
    GenericTraitFrame.CloseButton:SetPoint("TOPRIGHT", -3, -2)

    hooksecurefunc(GenericTraitFrame, "ApplyLayout", RemoveTexture)
    local unspentCount = GenericTraitFrame.Currency.UnspentPointsCount
    if unspentCount then
        ReplaceIconString(unspentCount)
        hooksecurefunc(unspentCount, "SetText", ReplaceIconString)
    end
end

local function LoadGenericTraitFrameSkin()
    if not GW.settings.GENERIC_TRAINT_SKIN_ENABLED then return end
    GW.RegisterLoadHook(GenericTraitFrameSkin, "Blizzard_GenericTraitUI", GenericTraitFrame)
end
GW.LoadGenericTraitFrameSkin = LoadGenericTraitFrameSkin
