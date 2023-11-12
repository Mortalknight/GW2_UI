local _, GW = ...
local GetSetting = GW.GetSetting

local function ReplaceIconString(frame, text)
    if not text then text = frame:GetText() end
    if not text or text == "" then return end

    local newText, count = gsub(text, "|T(%d+):24:24[^|]*|t", " |T%1:16:16:0:0:64:64:5:59:5:59|t")
    if count > 0 then frame:SetFormattedText("%s", newText) end
end

local function GenericTraitFrameSkin()
    GenericTraitFrame:GwStripTextures()
    GW.CreateFrameHeaderWithBody(GenericTraitFrame, GenericTraitFrame.Header.Title, "Interface/AddOns/GW2_UI/textures/character/questlog-window-icon")

    GenericTraitFrame.CloseButton:GwSkinButton(true)
    GenericTraitFrame.CloseButton:SetPoint("TOPRIGHT", -3, -2)

    ReplaceIconString(GenericTraitFrame.Currency.UnspentPointsCount)
    hooksecurefunc(GenericTraitFrame.Currency.UnspentPointsCount, 'SetText', ReplaceIconString)
end

local function LoadGenericTraitFrameSkin()
    if not GetSetting("GENERIC_TRAINT_SKIN_ENABLED") then return end
    GW.RegisterLoadHook(GenericTraitFrameSkin, "Blizzard_GenericTraitUI", GenericTraitFrame)
end
GW.LoadGenericTraitFrameSkin = LoadGenericTraitFrameSkin