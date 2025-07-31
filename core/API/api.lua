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


--Pawn integration
do
    local PawnLoaded = false
    local frame = CreateFrame("Frame")
    local upgradeCache = {}
    local pending = {}
    local limit = 2 / 60 / 4
    local resetInterval = 1 / 8
    local timerResetsAt = 0
    local left = 0
    local lastRefresh = 0

	local function PostRefresh(forceUpdate)
        local now = GetTime()
        if (now - lastRefresh < 0.1) and not forceUpdate then
            return
        end
        lastRefresh = now
		ContainerFrame_UpdateAll()
    end

    local function OnEvent(self, event, ...)
        if event == "ADDON_LOADED" and not PawnLoaded then
            local name = ...
            if name == "Pawn" or C_AddOns.IsAddOnLoaded("Pawn") then
                hooksecurefunc("PawnInvalidateBestItems", PostRefresh)
                hooksecurefunc("PawnResetTooltips", PostRefresh)
                self:UnregisterEvent("ADDON_LOADED")
                PawnLoaded = true
            end
		elseif event == "PLAYER_EQUIPMENT_CHANGED" then
			PostRefresh(true)
			upgradeCache = {}
        end
    end

    frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", OnEvent)

    local function ShouldPawnShow(itemLink)
        local classID = select(6, C_Item.GetItemInfoInstant(itemLink))
        return PawnLoaded and (classID == Enum.ItemClass.Armor or classID == Enum.ItemClass.Weapon)
    end

    local function GetPawnUpgradeStatus(itemLink)
        if upgradeCache[itemLink] ~= nil then
            return upgradeCache[itemLink]
        end

        local start = GetTimePreciseSec()

        if start >= timerResetsAt then
            timerResetsAt = start + resetInterval
            left = limit
        elseif left <= 0 then
            return nil
        end

        local result = PawnShouldItemLinkHaveUpgradeArrowUnbudgeted(itemLink)
        local elapsed = GetTimePreciseSec() - start

        left = left - elapsed
        if result ~= nil then
            upgradeCache[itemLink] = result
           	return result
        end

        if C_Item.IsItemDataCachedByID(itemLink) then
        	upgradeCache[itemLink] = false
           	return false
        end
        return nil
    end

    local function OnUpdate(self)
        for _, data in pairs(pending) do
            local result = GetPawnUpgradeStatus(data.itemLink)
            if result ~= nil then
				data.button.UpgradeIcon:SetShown(result)
                pending[data.itemLink] = nil
            end
        end

        if next(pending) == nil then
            self:SetScript("OnUpdate", nil)
            PostRefresh()
        end
    end

    local function RegisterPawnUpgradeIcon(button, itemLink)
        local result = upgradeCache[itemLink]
        if result ~= nil then
            button.UpgradeIcon:SetShown(result)
        end

        result = ShouldPawnShow(itemLink) and GetPawnUpgradeStatus(itemLink)
        if result == nil then
            pending[itemLink] = {button = button, itemLink = itemLink}
            frame:SetScript("OnUpdate", OnUpdate)
        else
            upgradeCache[itemLink] = result
			button.UpgradeIcon:SetShown(result)
        end
    end
    GW.RegisterPawnUpgradeIcon = RegisterPawnUpgradeIcon
end