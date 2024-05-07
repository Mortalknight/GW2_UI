local _, GW = ...
local L = GW.L
local RegisterMovableFrame = GW.RegisterMovableFrame
local RGBToHex = GW.RGBToHex
local GWGetClassColor = GW.GWGetClassColor
local Wait = GW.Wait
local GetUnitItemLevel = GW.GetUnitItemLevel
local PopulateUnitIlvlsCache = GW.PopulateUnitIlvlsCache
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local nameRoleIcon = GW.nameRoleIcon


local MountIDs = {}
local targetList = {}
local classification = {
    worldboss = format("|cffAF5050 %s|r", BOSS),
    rareelite = format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
    elite = "|cffAF5050+|r",
    rare = format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC)
}
local genderTable = {
    " " .. UNKNOWN .. " ",
    " " .. MALE .. " ",
    " " .. FEMALE .. " "
}

local LEVEL1 = strlower(TOOLTIP_UNIT_LEVEL:gsub('%s?%%s%s?%-?',''))
local LEVEL2 = strlower((TOOLTIP_UNIT_LEVEL_RACE or TOOLTIP_UNIT_LEVEL_CLASS):gsub('^%%2$s%s?(.-)%s?%%1$s','%1'):gsub('^%-?г?о?%s?',''):gsub('%s?%%s%s?%-?',''))
local IDLine = "|cffffedba%s|r %d"

local TT = CreateFrame("Frame")


local function IsModKeyDown(setting)
    local k = setting or GW.settings.ADVANCED_TOOLTIP_ID_MODIFIER
    return k == "ALWAYS" or ((k == "SHIFT" and IsShiftKeyDown()) or (k == "CTRL" and IsControlKeyDown()) or (k == "ALT" and IsAltKeyDown()))
end

local function EmbeddedItemTooltip_ID(self, id)
    if self:IsForbidden() then return end
    if self.Tooltip:IsShown() and IsModKeyDown() then
        self.Tooltip:AddLine(format(IDLine, ID, id))
        self.Tooltip:Show()
    end
end

local function EmbeddedItemTooltip_QuestReward(self)
    if self:IsForbidden() then return end
    if self.Tooltip:IsShown() and IsModKeyDown() then
        self.Tooltip:AddLine(format(IDLine, ID, self.itemID or self.spellID))
        self.Tooltip:Show()
    end
end

local function RemoveTrashLines(self)
    if self:IsForbidden() then return end

	local info = self:GetTooltipData()
	if not (info and info.lines[3]) then return end

	for i, line in next, info.lines, 3 do
		local text = line and line.leftText
		if not text or text == '' then
			break
		elseif text == PVP or text == FACTION_ALLIANCE or text == FACTION_HORDE then
			local left = _G['GameTooltipTextLeft' .. i]
			left:SetText('')
			left:Hide()
		end
	end
end

local function SetUnitAura(self, unit, index, filter)
    if not self or self:IsForbidden() then return end

    local auraData = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
    if not auraData then return end

    local mountID, mountText = MountIDs[auraData.spellId], ""
    if mountID then
        local _, _, sourceText = C_MountJournal.GetMountInfoExtraByID(mountID)
        mountText = sourceText and gsub(sourceText, "|n%s+|n", "|n")

        if mountText then
            self:AddLine(" ")
            self:AddLine(mountText, 1, 1, 1)
        end
    end

    if IsModKeyDown() then
        if mountText then
            self:AddLine(" ")
        end

        if auraData.sourceUnit then
            local _, class = UnitClass(auraData.sourceUnit)
            local color = GWGetClassColor(class, GW.settings.ADVANCED_TOOLTIP_SHOW_CLASS_COLOR, true)
            self:AddDoubleLine(format(IDLine, ID, auraData.spellId), format("|c%s%s|r", color.colorStr, UnitName(auraData.sourceUnit) or UNKNOWN))
        else
            self:AddLine(format(IDLine, ID, auraData.spellId))
        end
    end

    self:Show()
end

local function GameTooltip_OnTooltipSetSpell(self, data)
    if (self ~= GameTooltip) or self:IsForbidden() or not IsModKeyDown() then return end

	local id = (data and data.id) or select(2, self:GetSpell())
	if not id then return end

	local ID = format(IDLine, _G.ID, id)
	local info = self:GetTooltipData()
	if info and info.lines[3] then
		for _, line in next, info.lines, 3 do
			local text = line and line.leftText
			if not text or text == '' then return end

			if strfind(text, ID) then
				return -- this is called twice on talents for some reason?
			end
		end
	end

	self:AddLine(ID)
	self:Show()
end

local function GetKeystoneModifiers(linkType, ...)
    if type(linkType) ~= "string" then return end
    local modifierOffset = 4
    if linkType:find("item") then
        if ... == "138019" then
            modifierOffset = 16
        else
            return
        end
    elseif not linkType:find("keystone") then
        return
    end

    local modifiers = {}
    for i = modifierOffset, select("#", ...) do
        local num = strmatch(select(i, ...) or "", "^(%d+)")
        if num then
            local modifierID = tonumber(num)
            if modifierID then
                tinsert(modifiers, modifierID)
            end
        end
    end

    local numModifiers = #modifiers
    if modifiers[numModifiers] and modifiers[numModifiers] < 2 then
        tremove(modifiers, numModifiers)
    end

    return modifiers
end

local function ScanKeystone(self, link)
    if GW.settings.ADVANCED_TOOLTIP_SHOW_KEYSTONEINFO then
        if not link then
            _, link = self:GetItem()
        end
        if type(link) == "string" then
            local modifiers = GetKeystoneModifiers(strsplit(":", link))
            if modifiers then
                for _, modifierID in ipairs(modifiers) do
                    local modifierName, modifierDescription = C_ChallengeMode.GetAffixInfo(modifierID)
                    if modifierName and modifierDescription then
                        self:AddLine(format("|cff00ff00%s|r - %s", modifierName, modifierDescription), 0, 1, 0, true)
                    end
                end
                self:Show()
            end
        end
    end
end

local function SetHyperlink(self, link)
    if self:IsForbidden() then return end

    if select(3, string.find(link, "(%a-):")) == "achievement" then
        local _, _, achievementID = string.find(link, ":(%d+):")
        local _, _, GUID = string.find(link, ":%d+:(.-):")

        if GUID == UnitGUID("player") then
            self:Show()
            return
        end

        self:AddLine(" ")
        local _, _, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)

        if completed then
            if earnedBy then
                if earnedBy ~= "" then
                    self:AddLine(format(ACHIEVEMENT_EARNED_BY, earnedBy))
                end
                if not wasEarnedByMe then
                    self:AddLine(format(ACHIEVEMENT_NOT_COMPLETED_BY, GW.myname))
                elseif GW.myname ~= earnedBy then
                    self:AddLine(format(ACHIEVEMENT_COMPLETED_BY, GW.myname))
                end
            end
        end
        self:Show()
        return
    end
    ScanKeystone(self, link)
end

local function SetToyByItemID(self, id)
    if self:IsForbidden() then return end
    if id and IsModKeyDown() then
        self:AddLine(format(IDLine, ID, id))
        self:Show()
    end
end

local function SetCurrencyToken(self, index)
    if self:IsForbidden() then return end

    local id = IsModKeyDown() and tonumber(strmatch(C_CurrencyInfo.GetCurrencyListLink(index), "currency:(%d+)"))
    if not id then return end

    self:AddLine(format(IDLine, ID, id))
    self:Show()
end

local function AddQuestID(frame)
    if GameTooltip:IsForbidden() then return end

    local questID = IsModKeyDown() and (frame.questLogIndex and C_QuestLog.GetQuestIDForLogIndex(frame.questLogIndex) or frame.questID)
    if not questID then return end

    GameTooltip:AddLine(format(IDLine, ID, questID))

    if GameTooltip.ItemTooltip:IsShown() then
        GameTooltip:AddLine(" ")
    end

    GameTooltip:Show()
end

local function SetBackpackToken(self, id)
    if self:IsForbidden() then return end
    if id and IsModKeyDown() then
        local info = C_CurrencyInfo.GetBackpackCurrencyInfo(id)
        if info and info.currencyTypesID then
            self:AddLine(format(IDLine, ID, info.currencyTypesID))
            self:Show()
        end
    end
end

local function GameTooltip_OnTooltipCleared(self)
    if self:IsForbidden() then return end

    self.ItemLevelShown = nil

    if self.ItemTooltip then
        self.ItemTooltip:Hide()
    end

    -- This code is to reset stuck widgets.
    GameTooltip_ClearMoney(self)
    GameTooltip_ClearStatusBars(self)
    GameTooltip_ClearProgressBars(self)
    GameTooltip_ClearWidgetSet(self)
end

local function GameTooltip_OnTooltipSetItem(self, data)
    if (self ~= GameTooltip and self ~= ShoppingTooltip1 and self ~= ShoppingTooltip2) or self:IsForbidden() then return end

    local itemID, bagCount, bankCount
    local modKey = IsModKeyDown()
    local GetItem = TooltipUtil.GetDisplayedItem or self.GetItem
    if GetItem then
        local _, link = GetItem(self)

        if not link then return end

        if modKey then
            itemID = format(("*%s|r %s"):gsub("*", GW.Gw2Color), ID, (data and data.id) or strmatch(link, ":(%w+)"))
        end

        if GW.settings.ADVANCED_TOOLTIP_OPTION_ITEMCOUNT then
            local num = C_Item.GetItemCount(link)
            local numall = C_Item.GetItemCount(link, true)
            if GW.settings.ADVANCED_TOOLTIP_OPTION_ITEMCOUNT == "BAG" then
                bagCount = format(("*%s|r %d"):gsub("*", GW.Gw2Color), INVENTORY_TOOLTIP, num)
            elseif GW.settings.ADVANCED_TOOLTIP_OPTION_ITEMCOUNT == "BANK" then
                bankCount = format(("*%s|r %d"):gsub("*", GW.Gw2Color), BANK, (numall - num))
            elseif GW.settings.ADVANCED_TOOLTIP_OPTION_ITEMCOUNT == "BOTH" then
                bagCount = format(("*%s|r %d"):gsub("*", GW.Gw2Color), INVENTORY_TOOLTIP, num)
                bankCount = format(("*%s|r %d"):gsub("*", GW.Gw2Color), BANK, (numall - num))
            end
        end

        ScanKeystone(self, link)
    else
        local id = data and data.id
        if id then
            itemID = format(("*%s|r %s"):gsub("*", GW.Gw2Color), ID, id)
        end
    end

    if itemID or bagCount or bankCount then self:AddLine(" ") end
    if itemID or bagCount then self:AddDoubleLine(itemID or " ", bagCount or " ") end
    if bankCount then self:AddDoubleLine(" ", bankCount) end
end

local function GetLevelLine(self, offset, raw)
    if self:IsForbidden() then return end

    local info = self:GetTooltipData()
    if not (info and info.lines[offset]) then return end

    for i, line in next, info.lines, offset do
		local text = line and line.leftText
		if not text or text == '' then return end

		local lower = strlower(text)
		if lower and (strfind(lower, LEVEL1) or strfind(lower, LEVEL2)) then
			if raw then
				return line, info.lines[i + 1]
			else
				return _G['GameTooltipTextLeft' .. i], _G['GameTooltipTextLeft' .. i + 1]
			end
		end
	end
end

local function SetUnitText(self, unit, isPlayerUnit)
    local name, realm = UnitName(unit)

    if isPlayerUnit then
        local localeClass, class = UnitClass(unit)
        if not localeClass or not class then return end

        local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
        local pvpName, gender = UnitPVPName(unit), UnitSex(unit)
        local level, realLevel = UnitEffectiveLevel(unit), UnitLevel(unit)
        local relationship = UnitRealmRelationship(unit)
        local isShiftKeyDown = IsShiftKeyDown()

        local nameColor = GWGetClassColor(class, GW.settings.ADVANCED_TOOLTIP_SHOW_CLASS_COLOR, true)

        if GW.settings.ADVANCED_TOOLTIP_SHOW_PLAYER_TITLES and pvpName and pvpName ~= "" then
            name = pvpName
        end

        if realm and realm ~= "" then
            if isShiftKeyDown or GW.settings.ADVANCED_TOOLTIP_SHOW_REALM_ALWAYS then
                name = name .. "-" .. realm
            elseif relationship == LE_REALM_RELATION_COALESCED then
                name = name .. FOREIGN_SERVER_LABEL
            elseif relationship == LE_REALM_RELATION_VIRTUAL then
                name = name .. INTERACTIVE_SERVER_LABEL
            end
        end

        local awayText = UnitIsAFK(unit) and AFK_LABEL or UnitIsDND(unit) and DND_LABEL or ""
        GameTooltipTextLeft1:SetFormattedText("|c%s%s%s|r", nameColor.colorStr, name or UNKNOWN, awayText)

        local levelLine, specLine = GetLevelLine(self, (guildName and 2 or 1))
        if guildName then
            if guildRealm and isShiftKeyDown then
                guildName = guildName.."-"..guildRealm
            end

            local text = GW.settings.ADVANCED_TOOLTIP_SHOW_GUILD_RANKS and format("<|cff00ff10%s|r> [|cff00ff10%s|r]", guildName, guildRankName) or format("<|cff00ff10%s|r>", guildName)
            if levelLine == GameTooltipTextLeft2 then
                self:AddLine(text, 1, 1, 1)
            else
                GameTooltipTextLeft2:SetText(text)
            end
        end

        if levelLine then
            local diffColor = GetCreatureDifficultyColor(level)
            local race, englishRace = UnitRace(unit)
            local _, localizedFaction = GW.GetUnitBattlefieldFaction(unit)
            if localizedFaction and englishRace == "Pandaren" then race = localizedFaction .. " " .. race end
            local hexColor = GW.RGBToHex(diffColor.r, diffColor.g, diffColor.b)
            local unitGender = GW.settings.ADVANCED_TOOLTIP_SHOW_GENDER and genderTable[gender]
            if level < realLevel then
                levelLine:SetFormattedText("%s%s|r |cffFFFFFF(%s)|r %s%s", hexColor, level > 0 and level or "??", realLevel, unitGender or "", race or "")
            else
                levelLine:SetFormattedText("%s%s|r %s%s", hexColor, level > 0 and level or "??", unitGender or "", race or "")
            end

            local specText = specLine and specLine:GetText()
            if specText then
                specLine:SetFormattedText("|c%s%s|r", nameColor.colorStr, specText)
            end
        end

        return nameColor
    else
        local isPetCompanion = UnitIsBattlePetCompanion(unit)
        local levelLine, classLine = GetLevelLine(self, 1)
        if levelLine then
            local pvpFlag, diffColor, level = "", "", ""
            local creatureClassification = UnitClassification(unit)
            local creatureType = UnitCreatureType(unit)

            if isPetCompanion or UnitIsWildBattlePet(unit) then
                level = UnitBattlePetLevel(unit)

                local petType = UnitBattlePetType(unit)
                local petClass = _G["BATTLE_PET_NAME_" .. petType]
                if creatureType then
                    creatureType = format("%s %s", creatureType, petClass)
                else
                    creatureType = petClass
                end

                local teamLevel = C_PetJournal.GetPetTeamAverageLevel()
                if teamLevel then
                    diffColor = GetRelativeDifficultyColor(teamLevel, level)
                else
                    diffColor = GetCreatureDifficultyColor(level)
                end
            else
                level = UnitEffectiveLevel(unit)
                diffColor = GetCreatureDifficultyColor(level)
            end

            if UnitIsPVP(unit) then
                pvpFlag = format(" (%s)", PVP)
            end

            levelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", classification[creatureClassification] or "", creatureType or "", pvpFlag)

            local classText = creatureType and classLine and classLine:GetText()
            if creatureType == classText then
                classLine:SetText("")
                classLine:Hide()
            end
        end

        local unitReaction = UnitReaction(unit, "player")
        local nameColor = unitReaction and GW.settings.ADVANCED_TOOLTIP_SHOW_CLASS_COLOR and GW.FACTION_BAR_COLORS[unitReaction] or RAID_CLASS_COLORS.PRIEST
        if unitReaction and unitReaction >= 5 then nameColor = COLOR_FRIENDLY[1] end --Friend
        local nameColorStr = nameColor.colorStr or RGBToHex(nameColor.r, nameColor.g, nameColor.b, "ff")

        if not isPetCompanion then
            GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", nameColorStr, name or UNKNOWN)
        end

        return (UnitIsTapDenied(unit) and {r = 159 / 255, g = 159 / 255, b = 159 / 255}) or nameColor
    end
end

local function AddTargetInfo(self, unit)
    local unitTarget = unit.."target"
    if unit ~= "player" and UnitExists(unitTarget) then
        local targetColor
        if UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget) then
            local _, class = UnitClass(unitTarget)
            targetColor = GWGetClassColor(class, GW.settings.ADVANCED_TOOLTIP_SHOW_CLASS_COLOR, true)
        else
            targetColor = GW.FACTION_BAR_COLORS[UnitReaction(unitTarget, "player")]
        end

        self:AddDoubleLine(format("%s:", TARGET), format("|cff%02x%02x%02x%s|r", targetColor.r * 255, targetColor.g * 255, targetColor.b * 255, UnitName(unitTarget)))
    end

    if IsInGroup() then
        local isInRaid = IsInRaid()
        for i = 1, GetNumGroupMembers() do
            local groupUnit = (isInRaid and "raid" or "party")..i
            if UnitIsUnit(groupUnit.."target", unit) and not UnitIsUnit(groupUnit,"player") then
                local _, class = UnitClass(groupUnit)
                local classColor = GWGetClassColor(class, GW.settings.ADVANCED_TOOLTIP_SHOW_CLASS_COLOR, true)
                tinsert(targetList, format("|c%s%s|r", classColor.colorStr, UnitName(groupUnit)))
            end
        end

        local numList = #targetList
        if numList > 0 then
            self:AddLine(format("%s (|cffffffff%d|r): %s", L["Targeted by:"], numList, table.concat(targetList, ", ")), nil, nil, nil, true)
            wipe(targetList)
        end
    end
end

local function AddMountInfo(self, unit)
    local index = 1
    local auraData = C_UnitAuras.GetBuffDataByIndex(unit, index)
    while auraData do
        local mountID = MountIDs[auraData.spellId]
        if mountID then
            local _, _, sourceText = C_MountJournal.GetMountInfoExtraByID(mountID)
            self:AddDoubleLine(format("%s:", MOUNT), auraData.name, nil, nil, nil, 1, 1, 1)

            local mountText = sourceText and IsControlKeyDown() and gsub(sourceText, "|n%s+|n", "|n")
            if mountText then
                local sourceModified = gsub(mountText, "|n", "\10")
                for x in gmatch(sourceModified, "[^\10]+\10?") do
                    local left, right = strmatch(x, "(.-|r)%s?([^\10]+)\10?")
                    if left and right then
                        self:AddDoubleLine(left, right, nil, nil, nil, 1, 1, 1)
                    else
                        self:AddDoubleLine(FROM, gsub(mountText, "|c%x%x%x%x%x%x%x%x",""), nil, nil, nil, 1, 1, 1)
                    end
                end
            end

            break
        else
            index = index + 1
            auraData = C_UnitAuras.GetBuffDataByIndex(unit, index)
        end
    end
end

local function AddRoleInfo(self, unit)
    local r, g, b, role = 1, 1, 1, UnitGroupRolesAssigned(unit)
    if IsInGroup() and (UnitInParty(unit) or UnitInRaid(unit)) and (role ~= "NONE") then
        if role == "HEALER" then
            role, r, g, b = nameRoleIcon[role] .. HEALER, 0, 1, 0.59
        elseif role == "TANK" then
            role, r, g, b = nameRoleIcon[role] .. TANK, 0.51, 0.67, 0.9
        elseif role == "DAMAGER" then
            role, r, g, b = nameRoleIcon[role] .. DAMAGER, 0.77, 0.12, 0.24
        end
        -- if in raid add also the assist function here eg: Role:      [] Tank ([] Maintank)
        local isGroupLeader = UnitIsGroupLeader(unit)
        local isGroupAssist = UnitIsGroupAssistant(unit)
        local raidId = UnitInRaid(unit)
        local raidRole = ""
        if raidId then
            local raidR = select(10, GetRaidRosterInfo(raidId))
            if raidR == "MAINTANK" then raidRole = " (|TInterface/AddOns/GW2_UI/textures/party/icon-maintank:0:0:0:-3:64:64:4:60:4:60|t " .. MAINTANK .. ")" end
            if raidR == "MAINASSIST" then raidRole = " (|TInterface/AddOns/GW2_UI/textures/party/icon-mainassist:0:0:0:-1:64:64:4:60:4:60|t " .. MAIN_ASSIST .. ")" end
        end

        self:AddDoubleLine(format("%s:", ROLE), role .. raidRole, nil, nil, nil, r, g, b)
        if isGroupLeader or isGroupAssist then
            local roleString
            if isGroupLeader then
                roleString = "|TInterface/AddOns/GW2_UI/textures/party/icon-groupleader:0:0:0:-2:64:64:4:60:4:60|t " .. (IsInRaid() and RAID_LEADER or PARTY_LEADER)
            else
                roleString = "|TInterface/AddOns/GW2_UI/textures/party/icon-assist:0:0:0:-2:64:64:4:60:4:60|t " .. RAID_ASSISTANT
            end
            self:AddDoubleLine(" ", roleString, nil, nil, nil, r, g, b)
        end
    end
end

local function AddMythicInfo(self, unit)
    local data = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
    if data and data.currentSeasonScore and data.currentSeasonScore > 0 then
        local color = C_ChallengeMode.GetDungeonScoreRarityColor(data.currentSeasonScore)
        if not color or color == nil then color = {} end

        self:AddDoubleLine(DUNGEON_SCORE_LEADER:format("@"):gsub(": @", ""), GW.CommaValue(data.currentSeasonScore), nil, nil, nil, color.r or 1, color.g or 1, color.b or 1)
    end
end

local function TT_OnEvent(_, event, unitGUID)
    if UnitExists("mouseover") and UnitGUID("mouseover") == unitGUID then
        local itemLevel, retryUnit, retryTable, iLevelDB = GetUnitItemLevel("mouseover")
        if itemLevel == "tooSoon" then
            Wait(0.05, function()
                local canUpdate = true
                for _, x in ipairs(retryTable) do
                    local slotInfo = GW.GetGearSlotInfo(retryUnit, x)
                    if slotInfo == "tooSoon" then
                        canUpdate = false
                    else
                        iLevelDB[x] = slotInfo.iLvl
                        slotInfo = nil --clear cache
                    end
                end

                if canUpdate then
                    local calculateItemLevel = GW.CalculateAverageItemLevel(iLevelDB, retryUnit)
                    PopulateUnitIlvlsCache(unitGUID, calculateItemLevel, true)
                end
            end)
        else
            PopulateUnitIlvlsCache(unitGUID, itemLevel, true)
        end
    end

    if event then
        TT:UnregisterEvent(event)
    end
end

local lastGUID
local function AddInspectInfo(self, unit, numTries, r, g, b)
    if self.ItemLevelShown or (not unit) or (numTries > 3) or not CanInspect(unit) then return end

    local unitGUID = UnitGUID(unit)
    if not unitGUID then return end

    if unitGUID == UnitGUID("player") then
        self.ItemLevelShown = true
        self:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL .. ":", GetUnitItemLevel(unit), nil, nil, nil, 1, 1, 1)
    elseif GW.unitIlvlsCache[unitGUID] and GW.unitIlvlsCache[unitGUID].time then
        local itemLevel = GW.unitIlvlsCache[unitGUID].itemLevel
        if not itemLevel or (GetTime() - GW.unitIlvlsCache[unitGUID].time > 120) then
            GW.unitIlvlsCache[unitGUID].time = nil
            GW.unitIlvlsCache[unitGUID].itemLevel = nil
            return Wait(0.33, AddInspectInfo(self, unit, numTries + 1, r, g, b))
        end

        self.ItemLevelShown = true
        self:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL .. ":", itemLevel, nil, nil, nil, 1, 1, 1)
    elseif unitGUID then
        if not GW.unitIlvlsCache[unitGUID] then
            GW.unitIlvlsCache[unitGUID] = {unitColor = {r, g, b}}
        end

        if lastGUID ~= unitGUID then
            lastGUID = unitGUID
            NotifyInspect(unit)
            TT:RegisterEvent("INSPECT_READY")
            TT:SetScript("OnEvent", TT_OnEvent)
        else
            TT_OnEvent(TT, nil, unitGUID)
        end
    end
end

local function GameTooltip_OnTooltipSetUnit(self, data)
    if self ~= GameTooltip or self:IsForbidden() then return end

    local _, unit = self:GetUnit()
    local isPlayerUnit = UnitIsPlayer(unit)

    if not unit then
        local GMF = GetMouseFocus()
        local focusUnit = GMF and GMF.GetAttribute and GMF:GetAttribute("unit")
        if focusUnit then unit = focusUnit end
        if not unit or not UnitExists(unit) then
            return
        end
    end

    RemoveTrashLines(self)

    local isShiftKeyDown = IsShiftKeyDown()
    local isControlKeyDown = IsControlKeyDown()
    local color = SetUnitText(self, unit, isPlayerUnit)

    if GW.settings.ADVANCED_TOOLTIP_SHOW_TARGET_INFO and not isShiftKeyDown and not isControlKeyDown then
        AddTargetInfo(self, unit)
    end

    if GW.settings.ADVANCED_TOOLTIP_SHOW_MOUNT and (isPlayerUnit and unit ~= "player") and not isShiftKeyDown then
        AddMountInfo(self, unit)
    end

    if GW.settings.ADVANCED_TOOLTIP_SHOW_ROLE then
        AddRoleInfo(self, unit)
    end

    if GW.settings.ADVANCED_TOOLTIP_SHOW_DUNGEONSCORE then
        AddMythicInfo(self, unit)
    end

    if isShiftKeyDown and color and not self.ItemLevelShown then
        AddInspectInfo(self, unit, 0, color.r, color.g, color.b)
    end

    if unit and not isPlayerUnit and IsModKeyDown() and not C_PetBattles.IsInBattle() then
        local guid = (data and data.guid) or UnitGUID(unit) or ""
        local id = tonumber(strmatch(guid, "%-(%d-)%-%x-$"), 10)
        if id then -- NPC ID"s
            self:AddLine(format(IDLine, ID, id))
        end
    end

    if color and color.r and color.g and color.b then
        self.StatusBar:SetStatusBarColor(color.r, color.g, color.b)
    else
        self.StatusBar:SetStatusBarColor(159 / 255, 159 / 255, 159 / 255)
    end

    if self.StatusBar.text then
        local textWidth = self.StatusBar.text:GetStringWidth()
        if textWidth then
            self:SetMinimumWidth(textWidth)
        end
    end
end

local function GameTooltipStatusBar_OnValueChanged(self, value)
    if self:IsForbidden() or not value or not self.text or not GW.settings.ADVANCED_TOOLTIP_SHOW_HEALTHBAR_TEXT then return end

    local _, unit = self:GetParent():GetUnit()
    if not unit then
        local frame = GetMouseFocus()
        if frame and frame.GetAttribute then
            unit = frame:GetAttribute("unit")
        end
    end

    if value == 0 or (unit and UnitIsDeadOrGhost(unit)) then
        self.text:SetText(DEAD)
    else
        local max
        if unit then -- try to get real health values
            value, max = UnitHealth(unit), UnitHealthMax(unit)
        else
            _, max = self:GetMinMaxValues()
        end
        if value > 0 and max == 1 then
            self.text:SetFormattedText("%d%%", floor(value * 100))
            self:SetStatusBarColor(159 / 255, 159 / 255, 159 / 255)
        else
            self.text:SetText(GW.CommaValue(value) .. " / " .. GW.CommaValue(max))
        end
    end
end

local function SetItemRef(link)
    if IsModifierKeyDown() or not (link and strfind(link, "^spell:")) then return end

    ItemRefTooltip:AddLine(format(IDLine, ID, strmatch(link, ":(%d+)")))
    ItemRefTooltip:Show()
end

local function GameTooltip_SetDefaultAnchor(self, parent)
    if self:IsForbidden() or self:GetAnchorType() ~= "ANCHOR_NONE" then return end

    if self.StatusBar then
        self.StatusBar:SetAlpha(GW.settings.TOOLTIP_HEALTHBAER_POSITION == "DISABLED" and 0 or 1)
        if GW.settings.TOOLTIP_HEALTHBAER_POSITION == "BOTTOM" then
            if self.StatusBar.anchoredToTop then
                self.StatusBar:ClearAllPoints()
                self.StatusBar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", GW.BorderSize, -(GW.SpacingSize * 3))
                self.StatusBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -GW.BorderSize, -(GW.SpacingSize * 3))
                self.StatusBar.anchoredToTop = false

                if self.StatusBar.text then
                    self.StatusBar.text:SetPoint("CENTER", self.StatusBar, 0, 0)
                end
            end
        elseif GW.settings.TOOLTIP_HEALTHBAER_POSITION == "TOP" then
            if not self.StatusBar.anchoredToTop then
                self.StatusBar:ClearAllPoints()
                self.StatusBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", GW.BorderSize, (GW.SpacingSize * 3))
                self.StatusBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -GW.BorderSize, (GW.SpacingSize * 3))
                self.StatusBar.anchoredToTop = true

                if self.StatusBar.text then
                    self.StatusBar.text:SetPoint("CENTER", self.StatusBar, 0, 0)
                end
            end
        end
    end

    if GW.settings.TOOLTIP_MOUSE then
        self:SetOwner(parent, GW.settings.CURSOR_ANCHOR_TYPE, GW.settings.ANCHOR_CURSOR_OFFSET_X, GW.settings.ANCHOR_CURSOR_OFFSET_Y)
        return
    else
        self:SetOwner(parent, "ANCHOR_NONE")
    end

    local TooltipMover = GameTooltip.gwMover
    local _, anchor = self:GetPoint()

    if anchor == nil or anchor == TooltipMover or anchor == GameTooltipDefaultContainer or anchor == UIParent then
        self:ClearAllPoints()
        local point = GW.GetScreenQuadrant(TooltipMover)

        if point == "TOPLEFT" then
            self:SetPoint("TOPLEFT", TooltipMover, "TOPLEFT", 0, 0)
        elseif point == "TOPRIGHT" then
            self:SetPoint("TOPRIGHT", TooltipMover, "TOPRIGHT", -0, 0)
        elseif point == "BOTTOMLEFT" or point == "LEFT" then
            self:SetPoint("BOTTOMLEFT", TooltipMover, "BOTTOMLEFT", 0, 0)
        else
            self:SetPoint("BOTTOMRIGHT", TooltipMover, "BOTTOMRIGHT", 0, 0)
        end
    end
end

local function SetTooltipFonts()
    local font = UNIT_NAME_FONT
    local fontOutline = ""
    local headerSize = tonumber(GW.settings.TOOLTIP_FONT_SIZE)
    local smallTextSize = tonumber(GW.settings.TOOLTIP_FONT_SIZE)
    local textSize = tonumber(GW.settings.TOOLTIP_FONT_SIZE)

    GameTooltipHeaderText:SetFont(font, headerSize, fontOutline)
    GameTooltipTextSmall:SetFont(font, smallTextSize, fontOutline)
    GameTooltipText:SetFont(font, textSize, fontOutline)

    if DatatextTooltip then
        DatatextTooltipTextLeft1:SetFont(font, textSize, fontOutline)
        DatatextTooltipTextRight1:SetFont(font, textSize, fontOutline)
    end

    for _, tt in ipairs(GameTooltip.shoppingTooltips) do
        for i = 1, tt:GetNumRegions() do
            local region = select(i, tt:GetRegions())
            if region:IsObjectType("FontString") then
                region:SetFont(font, smallTextSize, fontOutline)
            end
        end
    end
end
GW.SetTooltipFonts = SetTooltipFonts

local function GameTooltip_AddQuestRewardsToTooltip(self, questID)
    if not (self and questID and self.progressBar) or self:IsForbidden() then return end

    local _, max = self.progressBar:GetMinMaxValues()
    GW.StatusBarColorGradient(self.progressBar, self.progressBar:GetValue(), max)
end

local function GameTooltip_ClearProgressBars(self)
    self.progressBar = nil
end

local function GameTooltip_ShowProgressBar(self)
    if not self or not self.progressBarPool or self:IsForbidden() then return end

    local sb = self.progressBarPool:GetNextActive()
    if not sb or not sb.Bar then return end

    self.progressBar = sb.Bar

    if not sb.Bar.backdrop then
        sb.Bar:GwStripTextures()
        sb.Bar:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
        sb.Bar.backdrop:SetBackdropBorderColor(0, 0, 0, 1)
        sb.Bar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/uistuff/gwstatusbar")
    end
end

local function GameTooltip_ShowStatusBar(self)
    if not self or not self.statusBarPool or self:IsForbidden() then return end

    local sb = self.statusBarPool:GetNextActive()
    if not sb or sb.backdrop then return end

    sb:GwStripTextures()
    sb:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
    sb.backdrop:SetBackdropBorderColor(0, 0, 0, 1)
    sb:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/uistuff/gwstatusbar")
end

local function SkinItemRefTooltipCloseButton()
    ItemRefTooltip.CloseButton:GwSkinButton(true)
    ItemRefTooltip.CloseButton:SetSize(20, 20)
    ItemRefTooltip.CloseButton:ClearAllPoints()
    ItemRefTooltip.CloseButton:SetPoint("TOPRIGHT", -3, -3)

    if C_AddOns.IsAddOnLoaded("Pawn") then
        if ItemRefTooltip.PawnIconFrame then ItemRefTooltip.PawnIconFrame.PawnIconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9) end
    end
end

local function SkinQueueStatusFrame()
    QueueStatusFrame:GwStripTextures()
    QueueStatusFrame:GwCreateBackdrop({
        bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background",
        edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
        tile = false,
        tileSize = 64,
        edgeSize = 32,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    })
end

local function SkinBattlePetTooltip()
    local skin_battle_pet_tt = function(self)
        self.NineSlice:Hide()
        self:GwCreateBackdrop({
            bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background",
            edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
            tile = false,
            tileSize = 64,
            edgeSize = 32,
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        })
    end

    hooksecurefunc("SharedPetBattleAbilityTooltip_SetAbility", function(self) skin_battle_pet_tt(self) end)
    hooksecurefunc("FloatingBattlePet_Show", function()
        if FloatingBattlePetTooltip:IsShown() then
            FloatingBattlePetTooltip.CloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal")
            FloatingBattlePetTooltip.CloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover")
            FloatingBattlePetTooltip.CloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover")
            FloatingBattlePetTooltip.CloseButton:SetSize(20, 20)
            FloatingBattlePetTooltip.CloseButton:ClearAllPoints()
            FloatingBattlePetTooltip.CloseButton:SetPoint("TOPRIGHT", -3, -3)

            skin_battle_pet_tt(FloatingBattlePetTooltip)
        end
    end)

    hooksecurefunc("BattlePetToolTip_Show", function()
        if not BattlePetTooltip then return end
        skin_battle_pet_tt(BattlePetTooltip)

        if not BattlePetTooltip.speciesID or not IsModKeyDown() then return end

        BattlePetTooltip:AddLine(" ")
        BattlePetTooltip:AddLine(format(IDLine, ID, BattlePetTooltip.speciesID))
        BattlePetTooltip:Show()
    end)
end

local function shouldHiddenInCombat(tooltip)
    local _, unit = tooltip:GetUnit()
    if unit then
        local unitReaction = UnitReaction("player", unit)
        if not unitReaction then return false end

        if GW.settings.HIDE_TOOLTIP_IN_COMBAT_UNIT == "ALL" or
            (string.find(GW.settings.HIDE_TOOLTIP_IN_COMBAT_UNIT, "HOSTILE") and unitReaction <= 3 or
            string.find(GW.settings.HIDE_TOOLTIP_IN_COMBAT_UNIT, "NEUTRAL") and unitReaction == 4 or
            string.find(GW.settings.HIDE_TOOLTIP_IN_COMBAT_UNIT, "FRIENDLY") and unitReaction >= 5) then
            return true
        end
    end
    return false
end

local function SetStyle(self, _, isEmbedded)
    if not self or (isEmbedded or self.IsEmbedded or not self.NineSlice) or self:IsForbidden() then return end

    if self.Delimiter1 then self.Delimiter1:SetTexture() end
    if self.Delimiter2 then self.Delimiter2:SetTexture() end

    self.NineSlice:Hide()
    self:GwCreateBackdrop({
        bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Background",
        edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/UI-Tooltip-Border",
        edgeSize = GW.Scale(32),
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    })
end

local function AddPremadeGroupInfo(tooltip, resultID)
    if not GW.settings.TOOLTIP_SHOW_PREMADE_GROUP_INFO then
        return
    end

    -- split line
    tooltip:AddLine(" ")
    tooltip:AddLine(L["Party Info"])

    -- add info
    local data = GW.LFGPI.GetPartyInfo(resultID)

    for _, role in ipairs(GW.LFGPI.GetRoleOrder()) do
        for _, line in ipairs(data[role]) do
            tooltip:AddLine(line)
        end
    end

    tooltip:ClearAllPoints()
    tooltip:SetPoint("TOPLEFT", LFGListFrame, "TOPRIGHT", 10, 0)

    tooltip:Show()
end

local function StyleTooltips()
    for _, tt in pairs({
        ItemRefTooltip,
        ItemRefShoppingTooltip1,
        ItemRefShoppingTooltip2,
        FriendsTooltip,
        WarCampaignTooltip,
        EmbeddedItemTooltip,
        ReputationParagonTooltip,
        GameTooltip,
        ShoppingTooltip1,
        ShoppingTooltip2,
        QuickKeybindTooltip,
        GameSmallHeaderTooltip,
        QuestScrollFrame.StoryTooltip,
        QuestScrollFrame.CampaignTooltip,
        PetJournalPrimaryAbilityTooltip,
        GarrisonShipyardMapMissionTooltip,
        BattlePetTooltip,
        PetBattlePrimaryAbilityTooltip,
        PetBattlePrimaryUnitTooltip,
        FloatingBattlePetTooltip,
        FloatingPetBattleAbilityTooltip,
        ShoppingTooltip3,
        ItemRefShoppingTooltip3,
        WorldMapTooltip,
        WorldMapCompareTooltip1,
        WorldMapCompareTooltip2,
        WorldMapCompareTooltip3,
        AtlasLootTooltip,
        QuestHelperTooltip,
        QuestGuru_QuestWatchTooltip,
        TRP2_MainTooltip,
        TRP2_ObjetTooltip,
        TRP2_StaticPopupPersoTooltip,
        TRP2_PersoTooltip,
        TRP2_MountTooltip,
        AltoTooltip,
        AltoScanningTooltip,
        ArkScanTooltipTemplate,
        NxTooltipItem,
        NxTooltipD,
        DBMInfoFrame,
        DBMRangeCheck,
        DatatextTooltip,
        VengeanceTooltip,
        FishingBuddyTooltip,
        FishLibTooltip,
        HealBot_ScanTooltip,
        hbGameTooltip,
        PlateBuffsTooltip,
        LibGroupInSpecTScanTip,
        RecountTempTooltip,
        VuhDoScanTooltip,
        XPerl_BottomTip,
        EventTraceTooltip,
        FrameStackTooltip,
        LibDBIconTooltip,
        RepurationParagonTooltip
    }) do
        SetStyle(tt)
    end
end

local function LoadTooltips()
    StyleTooltips()
    SkinItemRefTooltipCloseButton()
    SkinQueueStatusFrame()
    SkinBattlePetTooltip()

    QuestScrollFrame.StoryTooltip:SetFrameLevel(4)

    local ItemTT = GameTooltip.ItemTooltip
    GW.HandleIcon(ItemTT.Icon, true)
    GW.HandleIconBorder(ItemTT.IconBorder, ItemTT.Icon.backdrop)
    ItemTT.Count:ClearAllPoints()
    ItemTT.Count:SetPoint("BOTTOMRIGHT", ItemTT.Icon, "BOTTOMRIGHT", 1, 0)

    -- Skin GameTooltip Status Bar
    GameTooltipStatusBar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/hud/castinbar-white")
    GameTooltipStatusBar:GwCreateBackdrop()
    GameTooltipStatusBar:ClearAllPoints()
    GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", GW.BorderSize, -(GW.SpacingSize * 3))
    GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -GW.BorderSize, -(GW.SpacingSize * 3))

    -- Tooltip Styling
    hooksecurefunc("GameTooltip_ShowStatusBar", GameTooltip_ShowStatusBar) -- Skin Status Bars
    hooksecurefunc("GameTooltip_ShowProgressBar", GameTooltip_ShowProgressBar) -- Skin Progress Bars
    hooksecurefunc("GameTooltip_ClearProgressBars", GameTooltip_ClearProgressBars)
    hooksecurefunc("GameTooltip_AddQuestRewardsToTooltip", GameTooltip_AddQuestRewardsToTooltip) -- Color Progress Bars
    hooksecurefunc("SharedTooltip_SetBackdropStyle", SetStyle) -- This also deals with other tooltip borders like AzeriteEssence Tooltip

    -- Functions
    MountIDs = {}
    local mountIDs = C_MountJournal.GetMountIDs()
    for _, mountID in ipairs(mountIDs) do
        local _, spellID = C_MountJournal.GetMountInfoByID(mountID)
        MountIDs[spellID] = mountID
    end

    --Tooltip Fonts
    -- hook here to avoid a taint
    local moneyTooltipSetUp = false
    hooksecurefunc("SetTooltipMoney", function()
        if GameTooltip.hasMoney and not moneyTooltipSetUp then
            local font = UNIT_NAME_FONT
            local fontOutline = ""
            local textSize = tonumber(GW.settings.TOOLTIP_FONT_SIZE)
            for i = 1, GameTooltip.numMoneyFrames do
                _G["GameTooltipMoneyFrame" .. i .. "PrefixText"]:SetFont(font, textSize, fontOutline)
                _G["GameTooltipMoneyFrame" .. i .. "SuffixText"]:SetFont(font, textSize, fontOutline)
                _G["GameTooltipMoneyFrame" .. i .. "GoldButtonText"]:SetFont(font, textSize, fontOutline)
                _G["GameTooltipMoneyFrame" .. i .. "SilverButtonText"]:SetFont(font, textSize, fontOutline)
                _G["GameTooltipMoneyFrame" .. i .. "CopperButtonText"]:SetFont(font, textSize, fontOutline)
            end
            moneyTooltipSetUp = true
        end
    end)
    SetTooltipFonts()

    RegisterMovableFrame(GameTooltip, "Tooltip", "GameTooltipPos", ALL .. ",Blizzard", {230, 80}, {"default"})

    hooksecurefunc("GameTooltip_SetDefaultAnchor", GameTooltip_SetDefaultAnchor)

    GameTooltipDefaultContainer:GwKillEditMode()

    if not GW.IsIncompatibleAddonLoadedOrOverride("LfgInfo", true)  then
        hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", AddPremadeGroupInfo)
    end

    if GW.settings.ADVANCED_TOOLTIP then
        GameTooltip.StatusBar = GameTooltipStatusBar
        GameTooltip.StatusBar:SetScript("OnValueChanged", nil)
        GameTooltip.StatusBar.text = GameTooltip.StatusBar:CreateFontString(nil, "OVERLAY")
        GameTooltip.StatusBar.text:SetPoint("CENTER", GameTooltip.StatusBar, 0, 0)
        GameTooltip.StatusBar.text:SetFont(DAMAGE_TEXT_FONT, 10, "OUTLINE")

        hooksecurefunc("SetItemRef", SetItemRef)
        hooksecurefunc("EmbeddedItemTooltip_SetItemByID", EmbeddedItemTooltip_ID)
        hooksecurefunc("EmbeddedItemTooltip_SetCurrencyByID", EmbeddedItemTooltip_ID)
        hooksecurefunc("EmbeddedItemTooltip_SetSpellWithTextureByID", EmbeddedItemTooltip_ID)
        hooksecurefunc("EmbeddedItemTooltip_SetItemByQuestReward", EmbeddedItemTooltip_QuestReward)
        hooksecurefunc("EmbeddedItemTooltip_SetSpellByQuestReward", EmbeddedItemTooltip_QuestReward)
        hooksecurefunc(GameTooltip, "SetUnitAura", SetUnitAura)
        hooksecurefunc(GameTooltip, "SetUnitBuff", SetUnitAura)
        hooksecurefunc(GameTooltip, "SetUnitDebuff", SetUnitAura)

        hooksecurefunc(GameTooltip, "SetToyByItemID", SetToyByItemID)
        hooksecurefunc(GameTooltip, "SetCurrencyToken", SetCurrencyToken)
        hooksecurefunc(GameTooltip, "SetBackpackToken", SetBackpackToken)
        hooksecurefunc("QuestMapLogTitleButton_OnEnter", AddQuestID)
        hooksecurefunc("TaskPOI_OnEnter", AddQuestID)
        hooksecurefunc(GameTooltip, "SetHyperlink", SetHyperlink)
        hooksecurefunc(ItemRefTooltip, "SetHyperlink", SetHyperlink)

        local eventFrame = CreateFrame("Frame")
        eventFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
        eventFrame:SetScript("OnEvent", function()
            if not GameTooltip:IsForbidden() and GameTooltip:IsShown() then
                local owner = GameTooltip:GetOwner()
                if (owner == UIParent or (GW2_PlayerFrame and owner == GW2_PlayerFrame)) and UnitExists("mouseover") then
                    GameTooltip:SetUnit("mouseover")
                end
            end
        end)

        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, GameTooltip_OnTooltipSetItem)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, GameTooltip_OnTooltipSetUnit)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, GameTooltip_OnTooltipSetSpell)

        GameTooltip:HookScript("OnTooltipCleared", GameTooltip_OnTooltipCleared)
        GameTooltip.StatusBar:HookScript("OnValueChanged", GameTooltipStatusBar_OnValueChanged)
    end

    local eventFrame2 = CreateFrame("Frame")
    eventFrame2:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame2:SetScript("OnEvent", function(_, event)
        if not GW.settings.HIDE_TOOLTIP_IN_COMBAT then return end

        if event == "PLAYER_REGEN_DISABLED" and shouldHiddenInCombat(GameTooltip) and not IsModKeyDown(GW.settings.HIDE_TOOLTIP_IN_COMBAT_OVERRIDE) then
            GameTooltip:Hide()
        end
    end)

    GameTooltip:HookScript("OnShow", function(self)
        if GW.settings.HIDE_TOOLTIP_IN_COMBAT and InCombatLockdown() and shouldHiddenInCombat(self) and not IsModKeyDown(GW.settings.HIDE_TOOLTIP_IN_COMBAT_OVERRIDE) then
            self:Hide()
        end
    end)
end
GW.LoadTooltips = LoadTooltips
