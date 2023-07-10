local _, GW = ...

local function HandleMirrorTimer(self, timer)
	local bar = self:GetAvailableTimer(timer)
	if bar then
		bar.atlasHolder = CreateFrame("Frame", nil, bar)
		bar.atlasHolder:SetClipsChildren(true)
		bar.atlasHolder:GwSetInside()

		bar.StatusBar:SetParent(bar.atlasHolder)
		bar.StatusBar:ClearAllPoints()
		bar.StatusBar:SetSize(200, 18)
		bar.StatusBar:SetPoint("TOP", 0, 2)
		bar:SetSize(200, 18)

		bar.Text:ClearAllPoints()
		bar.Text:SetParent(bar.StatusBar)
		bar.Text:SetPoint("CENTER", bar.StatusBar, 0, 1)

		bar:GwStripTextures()
		bar:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
	end
end

local function LoadMirrorTimers()
	hooksecurefunc(MirrorTimerContainer, "SetupTimer", HandleMirrorTimer)
end
GW.LoadMirrorTimers = LoadMirrorTimers
