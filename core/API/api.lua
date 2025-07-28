local _, GW = ...

local function GetSpellCooldownWrapper(spellID)
	if not spellID then return end

	if GetSpellCooldown then
		local startTime, duration, isEnabled, modRate = GetSpellCooldown(spellID)
		return {startTime = startTime, duration = duration, isEnabled = isEnabled, modRate = modRate}
	else
		local info = C_Spell.GetSpellCooldown(spellID)
		if info then
			return info
		end
	end
end
GW.GetSpellCooldown = GetSpellCooldownWrapper

-- add tooltip data api
local function CompatibleTooltip(tt)
	if tt.GetTooltipData then return end

	tt.GetTooltipData = function()
		local info = { name = tt:GetName(), lines = {} }
		info.leftTextName = info.name .. "TextLeft"
		info.rightTextName = info.name .. "TextRight"

		for i = 1, tt:NumLines() do
			local left = _G[info.leftTextName..i]
			local leftText = left and left:GetText() or nil

			local right = _G[info.rightTextName..i]
			local rightText = right and right:GetText() or nil

			tinsert(info.lines, i, { lineIndex = i, leftText = leftText, rightText = rightText })
		end

		return info
	end
end
CompatibleTooltip(GameTooltip)
CompatibleTooltip(GW.ScanTooltip)

local function CropRatio(width, height, mult)
	local left, right, top, bottom = 0.05, 0.95, 0.05, 0.95
	if not mult then mult = 0.5 end

	local ratio = width / height
	if ratio > 1 then
		local trimAmount = (1 - (1 / ratio)) * mult
		top = top + trimAmount
		bottom = bottom - trimAmount
	else
		local trimAmount = (1 - ratio) * mult
		left = left + trimAmount
		right = right - trimAmount
	end

	return left, right, top, bottom
end
GW.CropRatio = CropRatio

local function SetAlphaRecursive(frame, alpha)
    if not frame or not frame.SetAlpha then return end
    frame:SetAlpha(alpha)

    for _, child in ipairs({frame:GetChildren()}) do
        SetAlphaRecursive(child, alpha)
    end
end
GW.SetAlphaRecursive = SetAlphaRecursive

local function SafeGetParent(obj)
	if type(obj) ~= "table" then
		return nil
	end

	local hasMethod = obj.GetParent and type(obj.GetParent) == "function"
	if hasMethod then
		local ok, parent = pcall(obj.GetParent, obj)
		if ok then
			return parent
		end
	end

	return nil
end
GW.SafeGetParent = SafeGetParent
