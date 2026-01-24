local _, ns = ...
local oUF = ns.oUF

local _FRAMES = {}
local CheckHighlightFrame

local normalColor = CreateColor(1, 1, 1, 1)
local noColor = CreateColor(0, 0, 0, 0)

local function Update(self, event)
	local element = self.Health.highlightBorder
    local isSameUnit = UnitIsUnit(self.unit, "target")

    element:SetVertexColor(noColor:GetRGBA())

    if self:IsMouseOver() then
        element:SetVertexColor(normalColor:GetRGBA())
        return
    end

    if ns.Retail then
        element:SetVertexColorFromBoolean(isSameUnit, normalColor, noColor)
    else
        if isSameUnit then
            element:SetVertexColor(normalColor:GetRGBA())
        else
            element:SetVertexColor(noColor:GetRGBA())
        end
    end
end

-- Internal updating method
local timer = 0
local function CheckHighlightFrameUpdate(_, elapsed)
	timer = timer + elapsed

	if(timer >= .15) then
		for _, object in next, _FRAMES do
			if(object:IsShown()) then
				Update(object, 'OnUpdate')
			end
		end

		timer = 0
	end
end

local function Enable(self)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", Update, true)
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", Update, true)

    if (not CheckHighlightFrame) then
        CheckHighlightFrame = CreateFrame('Frame')
        CheckHighlightFrame:SetScript('OnUpdate', CheckHighlightFrameUpdate)
    end

    table.insert(_FRAMES, self)
    CheckHighlightFrame:Show()

    return true
end

local function Disable(self)
    self:UnregisterEvent("PLAYER_TARGET_CHANGED", Update, true)
    self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT", Update, true)

    for index, frame in next, _FRAMES do
        if(frame == self) then
            table.remove(_FRAMES, index)
            break
        end
    end

    if(#_FRAMES == 0) then
        CheckHighlightFrame:Hide()
    end
end

oUF:AddElement('HeighlightUnitFrame', Update, Enable, Disable)
