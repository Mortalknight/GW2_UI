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

	local info = { name = tt:GetName(), lines = {} }
	info.leftTextName = info.name .. "TextLeft"
	info.rightTextName = info.name .. "TextRight"

	tt.GetTooltipData = function()
		wipe(info.lines)

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