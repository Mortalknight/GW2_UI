local _, GW = ...
local SkinButton = GW.skins.SkinButton

local function SkinGhostFrame()
    local GhostFrame = _G.GhostFrame

    local tex = GhostFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", GhostFrame, "TOP", 0, 0)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/button")
    tex:SetSize(_G.GhostFrameContentsFrame:GetSize())
    GhostFrame.tex = tex
    SkinButton(GhostFrame, false, false, true)

    _G.GhostFrameContentsFrameText:SetTextColor(0, 0, 0, 1)
    _G.GhostFrameContentsFrameText:SetShadowOffset(0, 0)

    _G.GhostFrameContentsFrameIcon:SetTexture("Interface/Icons/spell_holy_guardianspirit")
    _G.GhostFrameContentsFrameIcon:ClearAllPoints()
    _G.GhostFrameContentsFrameIcon:SetPoint("RIGHT", _G.GhostFrameContentsFrameText, "LEFT", -5, 0)
    _G.GhostFrameContentsFrameIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    GhostFrame:SetScript("OnMouseUp", nil)
    GhostFrame:SetScript("OnMouseDown", nil)

    local r = {_G.GhostFrame:GetRegions()}
    local i = 1
    for _,c in pairs(r) do
        if c:GetObjectType() == "Texture" and i < 7 then
            c:Hide()
        end
        i = i + 1
    end
end
GW.SkinGhostFrame = SkinGhostFrame