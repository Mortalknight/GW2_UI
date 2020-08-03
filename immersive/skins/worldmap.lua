local _, GW = ...

local function SkinWorldMap()
    local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:StripTextures()
	WorldMapFrame.BorderFrame:Kill()
	WorldMapFrame.BlackoutFrame:Kill()

	local tex = WorldMapFrame:CreateTexture("bg", "BACKGROUND")
    local w, h = WorldMapFrame:GetSize()
    tex:SetPoint("TOP", WorldMapFrame, "TOP", 10, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    tex:SetSize(w + 120, h + 80 )
    WorldMapFrame.tex = tex

	_G.WorldMapContinentDropDown:SkinDropDownMenu()
	_G.WorldMapZoneDropDown:SkinDropDownMenu()

	_G.WorldMapContinentDropDown:SetPoint('TOPLEFT', WorldMapFrame, 'TOPLEFT', 330, -35)
	_G.WorldMapContinentDropDown:SetWidth(205)
	_G.WorldMapContinentDropDown:SetHeight(33)
	_G.WorldMapZoneDropDown:SetPoint('LEFT', _G.WorldMapContinentDropDown, 'RIGHT', -20, 0)
	_G.WorldMapZoneDropDown:SetWidth(205)
	_G.WorldMapZoneDropDown:SetHeight(33)

	_G.WorldMapZoomOutButton:SetPoint('LEFT', _G.WorldMapZoneDropDown, 'RIGHT', 3, 3)
	_G.WorldMapZoomOutButton:SetHeight(21)

	_G.WorldMapZoomOutButton:SkinButton(false, true)

	_G.WorldMapFrameCloseButton:SkinButton(true)
	_G.WorldMapFrameCloseButton:SetSize(25, 25)
	_G.WorldMapFrameCloseButton:ClearAllPoints()
    _G.WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", 20, -25)
	_G.WorldMapFrameCloseButton:SetFrameLevel(_G.WorldMapFrameCloseButton:GetFrameLevel() + 2)
end
GW.SkinWorldMap = SkinWorldMap