local _, GW = ...

local function LoadGlyphes()
    TalentFrame_LoadUI()

    local glyphesFrame = CreateFrame("Frame", "GwGlyphesFrame", GwCharacterWindow, "GwGlyphesFrame")










    return glyphesFrame
end
GW.LoadGlyphes = LoadGlyphes