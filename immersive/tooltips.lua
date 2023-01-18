local _, GW = ...
local L = GW.L
local GetSetting = GW.GetSetting
local RegisterMovableFrame = GW.RegisterMovableFrame
local RGBToHex = GW.RGBToHex
local GWGetClassColor = GW.GWGetClassColor
local COLOR_FRIENDLY = GW.COLOR_FRIENDLY
local CI = GW.Libs.CI

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

local LEVEL1 = strlower(_G.TOOLTIP_UNIT_LEVEL:gsub("%s?%%s%s?%-?", ""))
local LEVEL2 = strlower(_G.TOOLTIP_UNIT_LEVEL_CLASS:gsub("^%%2$s%s?(.-)%s?%%1$s", "%1"):gsub("^%-?г?о?%s?", ""):gsub("%s?%%s%s?%-?", ""))
local IDLine = "|cffffedba%s|r %d"

local function IsModKeyDown(setting)
    local k = setting and GetSetting(setting) or GetSetting("ADVANCED_TOOLTIP_ID_MODIFIER")
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
    for i = 3, self:NumLines() do
        local tiptext = _G["GameTooltipTextLeft" .. i]
        local linetext = tiptext:GetText()

        if linetext == PVP or linetext == FACTION_ALLIANCE or linetext == FACTION_HORDE then
            tiptext:SetText("")
            tiptext:Hide()
        end
    end
end

local function SetUnitAura(self, unit, index, filter)
    if not self or self:IsForbidden() then return end

    local name, _, _, _, _, _, source, _, _, spellID = UnitAura(unit, index, filter)
    if not name then return end

    if IsModKeyDown() then
        if source then
            local _, class = UnitClass(source)
            local color = GWGetClassColor(class, GetSetting("ADVANCED_TOOLTIP_SHOW_CLASS_COLOR"), true)
            self:AddDoubleLine(format(IDLine, ID, spellID), format("|c%s%s|r", color.colorStr, UnitName(source) or UNKNOWN))
        else
            self:AddLine(format(IDLine, ID, spellID))
        end
    end

    self:Show()
end

local function GameTooltip_OnTooltipSetSpell(self)
    if self:IsForbidden() or not IsModKeyDown() then return end

    local _, id = self:GetSpell()
    if not id then return end

    local ID = format(IDLine, ID, id)
    for i = 3, self:NumLines() do
        local line = _G[format("GameTooltipTextLeft%d", i)]
        local text = line and line:GetText()
        if text and strfind(text, ID) then
            return
        end
    end

    self:AddLine(ID)
    self:Show()
end

local function GetLevelLine(self, offset, guildName)
    if self:IsForbidden() then return end

    if guildName then
        offset = 3
    end

    for i = offset, self:NumLines() do
        local tipLine = _G["GameTooltipTextLeft"..i]
        local tipText = tipLine and tipLine:GetText() and strlower(tipLine:GetText())
        if tipText and (strfind(tipText, LEVEL1) or strfind(tipText, LEVEL2)) then
            return tipLine
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
        local realLevel = UnitLevel(unit)
        local relationship = UnitRealmRelationship(unit)
        local isShiftKeyDown = IsShiftKeyDown()
        local playerTitles = GetSetting("ADVANCED_TOOLTIP_SHOW_PLAYER_TITLES")
        local alwaysShowRealm = GetSetting("ADVANCED_TOOLTIP_SHOW_REALM_ALWAYS")
        local guildRanks = GetSetting("ADVANCED_TOOLTIP_SHOW_GUILD_RANKS")
        local showGender = GetSetting("ADVANCED_TOOLTIP_SHOW_GENDER")

        local nameColor = GWGetClassColor(class, GetSetting("ADVANCED_TOOLTIP_SHOW_CLASS_COLOR"), true)

        if pvpName and playerTitles then
            name = pvpName
        end

        if realm and realm ~= "" then
            if isShiftKeyDown or alwaysShowRealm then
                name = name .. "-" .. realm
            elseif relationship == LE_REALM_RELATION_COALESCED then
                name = name .. FOREIGN_SERVER_LABEL
            elseif relationship == LE_REALM_RELATION_VIRTUAL then
                name = name .. INTERACTIVE_SERVER_LABEL
            end
        end

        local awayText = UnitIsAFK(unit) and AFK_LABEL or UnitIsDND(unit) and DND_LABEL or ""
        GameTooltipTextLeft1:SetFormattedText("|c%s%s%s|r", nameColor.colorStr, name or UNKNOWN, awayText)

        local levelLine = GetLevelLine(self, 2, guildName)
        if guildName then
            if guildRealm and isShiftKeyDown then
                guildName = guildName .. "-" .. guildRealm
            end

            local text = guildRanks and format("<|cff00ff10%s|r> [|cff00ff10%s|r]", guildName, guildRankName) or format("<|cff00ff10%s|r>", guildName)
            if levelLine == GameTooltipTextLeft2 then
                self:AddLine(text, 1, 1, 1)
            else
                GameTooltipTextLeft2:SetText(text)
            end
        end

        if levelLine then
            local diffColor = GetCreatureDifficultyColor(realLevel)
            local race, englishRace = UnitRace(unit)
            local _, localizedFaction = GW.GetUnitBattlefieldFaction(unit)
            if localizedFaction and englishRace == "Pandaren" then race = localizedFaction.." "..race end
            local hexColor = GW.RGBToHex(diffColor.r, diffColor.g, diffColor.b)
            local unitGender = showGender and genderTable[gender]
            levelLine:SetFormattedText("%s%s|r %s%s |c%s%s|r", hexColor, realLevel > 0 and realLevel or "??", unitGender or "", race or "", nameColor.colorStr, localeClass)
        end

        return nameColor
    else
        local levelLine = GetLevelLine(self, 2)
        if levelLine then
            local pvpFlag, diffColor, level = "", "", ""
            local creatureClassification = UnitClassification(unit)
            local creatureType = UnitCreatureType(unit) or ""

            level = UnitLevel(unit)
            diffColor = GetCreatureDifficultyColor(level)

            if UnitIsPVP(unit) then
                pvpFlag = format(" (%s)", PVP)
            end

            levelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", classification[creatureClassification] or "", creatureType, pvpFlag)
        end

        local unitReaction = UnitReaction(unit, "player")
        local nameColor = unitReaction and GetSetting("ADVANCED_TOOLTIP_SHOW_CLASS_COLOR") and GW.FACTION_BAR_COLORS[unitReaction] or RAID_CLASS_COLORS.PRIEST
        if unitReaction and unitReaction >= 5 then nameColor = COLOR_FRIENDLY[1] end --Friend
        local nameColorStr = nameColor.colorStr or RGBToHex(nameColor.r, nameColor.g, nameColor.b, "ff")

        GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", nameColorStr, name or UNKNOWN)

        return (UnitIsTapDenied(unit) and {r = 159 / 255, g = 159 / 255, b = 159 / 255}) or nameColor
     end
end

local function AddTargetInfo(self, unit)
    local unitTarget = unit.."target"
    if unit ~= "player" and UnitExists(unitTarget) then
        local targetColor
        if UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget) then
            local _, class = UnitClass(unitTarget)
            targetColor = GWGetClassColor(class, GetSetting("ADVANCED_TOOLTIP_SHOW_CLASS_COLOR"), true)
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
                local classColor = GWGetClassColor(class, GetSetting("ADVANCED_TOOLTIP_SHOW_CLASS_COLOR"), true)
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

local function AddInspectInfo(self, unit, numTries, r, g, b)
    if not unit or numTries > 3 or not CanInspect(unit) then return end

    local unitGUID = UnitGUID(unit)
    if not unitGUID then return end
    local specIndex = CI:GetSpecialization(unitGUID) or 1
    local x1, x2, x3 = 0, 0, 0

    x1, x2, x3 = CI:GetTalentPoints(unitGUID)
    local _, gearScore = GW.Libs.LibGearScore:GetScore(unitGUID)

    if unitGUID == UnitGUID("player") then
        self:AddDoubleLine(TALENTS .. ":", string.format("%s [%d/%d/%d]", CI:GetSpecializationName(GW.myclass, specIndex, true), x1, x2, x3), nil, nil, nil, r, g, b)
    else
        local _, className = UnitClass(unit)
        self:AddDoubleLine(TALENTS .. ":", string.format("%s [%d/%d/%d]", CI:GetSpecializationName(className, specIndex, true), x1, x2, x3), nil, nil, nil, r, g, b)  
    end

    if gearScore then
        self:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL .. ":" , gearScore.AvgItemLevel, nil, nil, nil, 1, 1, 1)
        self:AddDoubleLine("GearScore:" , gearScore.GearScore, nil, nil, nil, 1, 1, 1)
    end
end

local function GameTooltip_OnTooltipSetUnit(self)
    if self:IsForbidden() then return end

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

    if GetSetting("ADVANCED_TOOLTIP_SHOW_TARGET_INFO") and not isShiftKeyDown and not isControlKeyDown then
        AddTargetInfo(self, unit)
    end

    if isShiftKeyDown and color then
        AddInspectInfo(self, unit, 0, color.r, color.g, color.b)
    end

    if unit and not isPlayerUnit and IsModKeyDown() then
        local guid = UnitGUID(unit) or ""
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

    local textWidth = self.StatusBar.text:GetStringWidth()
    if textWidth then
        self:SetMinimumWidth(textWidth)
    end

end

local function GameTooltipStatusBar_OnValueChanged(self, value)
    if self:IsForbidden() or not value or not self.text or not GetSetting("ADVANCED_TOOLTIP_SHOW_HEALTHBAR_TEXT") then return end

    local _, unit = self:GetParent():GetUnit()
    if not unit then
        local frame = GetMouseFocus()
        if frame and frame.GetAttribute then
            unit = frame:GetAttribute("unit")
        end
    end

    local _, max = self:GetMinMaxValues()
    if value > 0 and max == 1 then
        self.text:SetFormattedText("%d%%", floor(value * 100))
        self:SetStatusBarColor(159 / 255, 159 / 255, 159 / 255)
    elseif value == 0 or (unit and UnitIsDeadOrGhost(unit)) then
        self.text:SetText(DEAD)
    else
        self.text:SetText(GW.CommaValue(value).." / "..GW.CommaValue(max))
    end
end

local function GameTooltip_OnTooltipCleared(self)
    if self:IsForbidden() then return end
    self.itemCleared = nil
end

local function GameTooltip_OnTooltipSetItem(self)
    if self:IsForbidden() then return end

    local _, link = self:GetItem()
    local num = GetItemCount(link)
    local numall = GetItemCount(link,true)
    local left, right, bankCount = " ", " ", " "
    local itemCountOption = GetSetting("ADVANCED_TOOLTIP_OPTION_ITEMCOUNT")

    if link and IsModKeyDown() then
        right = format(("*%s|r %s"):gsub("*", GW.Gw2Color), ID, strmatch(link, ":(%w+)"))
    end

    if itemCountOption == "BAG" then
        left = format(("*%s|r %d"):gsub("*", GW.Gw2Color), INVENTORY_TOOLTIP, num)
    elseif itemCountOption == "BANK" then
        bankCount = format(("*%s|r %d"):gsub("*", GW.Gw2Color), BANK, (numall - num))
    elseif itemCountOption == "BOTH" then
        left = format(("*%s|r %d"):gsub("*", GW.Gw2Color), INVENTORY_TOOLTIP, num)
        bankCount = format(("*%s|r %d"):gsub("*", GW.Gw2Color), BANK, (numall - num))
    end

    if left ~= " " or right ~= " " then
        self:AddLine(" ")
        self:AddDoubleLine(left, right)
    end
    if bankCount ~= " " then
        self:AddDoubleLine(bankCount, " ")
    end
end


local function movePlacement(self)
    local settings = GetSetting("GameTooltipPos")
    self:ClearAllPoints()
    self:SetPoint(settings.point, UIParent, settings.relativePoint, settings.xOfs, settings.yOfs)
end
GW.AddForProfiling("tooltips", "movePlacement", movePlacement)

local constBackdropArgs = {
    bgFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Background",
    edgeFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Border",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local function anchorTooltip(self, p)
    self:SetOwner(p, GetSetting("CURSOR_ANCHOR_TYPE"), GetSetting("ANCHOR_CURSOR_OFFSET_X"), GetSetting("ANCHOR_CURSOR_OFFSET_Y"))
end
GW.AddForProfiling("tooltips", "anchorTooltip", anchorTooltip)

local function SetItemRef()
    if ItemRefTooltip:IsShown() then
        ItemRefCloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/window-close-button-normal")
        ItemRefCloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")
        ItemRefCloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/window-close-button-hover")
        ItemRefCloseButton:SetSize(20, 20)
        ItemRefCloseButton:ClearAllPoints()
        ItemRefCloseButton:SetPoint("TOPRIGHT", -3, -3)
        ItemRefTooltip:StripTextures()
        ItemRefTooltip:CreateBackdrop(constBackdropArgs)

        if IsAddOnLoaded("Pawn") then
            if ItemRefTooltip.PawnIconFrame then ItemRefTooltip.PawnIconFrame.PawnIconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9) end
        end
    end
end

local function GameTooltip_AddQuestRewardsToTooltip(self, questID)
    if not (self and questID and self.progressBar) or self:IsForbidden() then return end

    local _, max = self.progressBar:GetMinMaxValues()
    GW.StatusBarColorGradient(self.progressBar, self.progressBar:GetValue(), max)
end

local function GameTooltip_ClearProgressBars(self)
    self.progressBar = nil
end

local function GameTooltip_ShowStatusBar(self)
    if not self or not self.statusBarPool or self:IsForbidden() then return end

    local sb = self.statusBarPool:GetNextActive()
    if not sb or sb.backdrop then return end

    sb:StripTextures()
    sb:CreateBackdrop(GW.skins.constBackdropFrameBorder)
    sb:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/gwstatusbar")
end

local function GameTooltip_ShowProgressBar(self)
    if not self or not self.progressBarPool or self:IsForbidden() then return end

    local sb = self.progressBarPool:GetNextActive()
    if not sb or not sb.Bar then return end

    self.progressBar = sb.Bar

    if not sb.Bar.backdrop then
        sb.Bar:StripTextures()
        sb.Bar:CreateBackdrop(GW.constBackdropFrameColorBorder, true)
        sb.Bar.backdrop:SetBackdropBorderColor(0, 0, 0, 1)
        sb.Bar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/gwstatusbar")
    end
end

local function shouldHiddenInCombat(tooltip)
    if tooltip:GetUnit() then
        local unitReaction = UnitReaction("player", tooltip:GetUnit())
        if not unitReaction then return false end

        local unitSetting = GetSetting("HIDE_TOOLTIP_IN_COMBAT_UNIT")
        if unitSetting == "ALL" or
            (string.find(unitSetting, "HOSTILE") and unitReaction <= 3 or
            string.find(unitSetting, "NEUTRAL") and unitReaction == 4 or
            string.find(unitSetting, "FRIENDLY") and unitReaction >= 5) then
            return true
        end
    end
    return false
end

local function SetStyle(self, _, isEmbedded)
    if not self or (self == GW.ScanTooltip or isEmbedded or self.IsEmbedded or not self.NineSlice) or self:IsForbidden() then return end

    if self.Delimiter1 then self.Delimiter1:SetTexture() end
    if self.Delimiter2 then self.Delimiter2:SetTexture() end


    self.NineSlice:Hide()
    self:CreateBackdrop({
        bgFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Background",
        edgeFile = "Interface/AddOns/GW2_UI/textures/UI-Tooltip-Border",
        edgeSize = GW.Scale(32),
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    })
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

local function GameTooltip_SetDefaultAnchor(self, parent)
    if self:IsForbidden() or self:GetAnchorType() ~= "ANCHOR_NONE" then return end

    if self.StatusBar then
        local healtBarPosition = GetSetting("TOOLTIP_HEALTHBAER_POSITION")
        self.StatusBar:SetAlpha(healtBarPosition == "DISABLED" and 0 or 1)
        if healtBarPosition == "BOTTOM" then
            if self.StatusBar.anchoredToTop then
                self.StatusBar:ClearAllPoints()
                self.StatusBar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", GW.BorderSize, -(GW.SpacingSize * 3))
                self.StatusBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -GW.BorderSize, -(GW.SpacingSize * 3))
                self.StatusBar.text:SetPoint("CENTER", self.StatusBar, 0, 0)
                self.StatusBar.anchoredToTop = false
            end
        elseif healtBarPosition == "TOP" then
            if not self.StatusBar.anchoredToTop then
                self.StatusBar:ClearAllPoints()
                self.StatusBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", GW.BorderSize, (GW.SpacingSize * 3))
                self.StatusBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -GW.BorderSize, (GW.SpacingSize * 3))
                self.StatusBar.text:SetPoint("CENTER", self.StatusBar, 0, 0)
                self.StatusBar.anchoredToTop = true
            end
        end
    end

    if GetSetting("TOOLTIP_MOUSE") then
        self:SetOwner(parent, GetSetting("CURSOR_ANCHOR_TYPE"), GetSetting("ANCHOR_CURSOR_OFFSET_X"), GetSetting("ANCHOR_CURSOR_OFFSET_Y"))
        return
    else
        self:SetOwner(parent, "ANCHOR_NONE")
    end

    local TooltipMover = GameTooltip.gwMover
    local _, anchor = self:GetPoint()

    if anchor == nil or anchor == TooltipMover or anchor == UIParent then
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
    local headerSize = tonumber(GetSetting("TOOLTIP_FONT_SIZE"))
    local smallTextSize = tonumber(GetSetting("TOOLTIP_FONT_SIZE"))
    local textSize = tonumber(GetSetting("TOOLTIP_FONT_SIZE"))

    GameTooltipHeaderText:SetFont(font, headerSize, fontOutline)
    GameTooltipTextSmall:SetFont(font, smallTextSize, fontOutline)
    GameTooltipText:SetFont(font, textSize, fontOutline)

    if GameTooltip.hasMoney then
        for i = 1, GameTooltip.numMoneyFrames do
            _G["GameTooltipMoneyFrame" .. i .. "PrefixText"]:SetFont(font, textSize, fontOutline)
            _G["GameTooltipMoneyFrame" .. i .. "SuffixText"]:SetFont(font, textSize, fontOutline)
            _G["GameTooltipMoneyFrame" .. i .. "GoldButtonText"]:SetFont(font, textSize, fontOutline)
            _G["GameTooltipMoneyFrame" .. i .. "SilverButtonText"]:SetFont(font, textSize, fontOutline)
            _G["GameTooltipMoneyFrame" .. i .. "CopperButtonText"]:SetFont(font, textSize, fontOutline)
        end
    end

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

local function LoadTooltips()
    -- Style Tooltips first
    StyleTooltips()

    -- Skin GameTooltip Status Bar
    GameTooltipStatusBar:SetStatusBarTexture("Interface/Addons/GW2_UI/textures/castinbar-white")
    GameTooltipStatusBar:CreateBackdrop()
    GameTooltipStatusBar:ClearAllPoints()
    GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", GW.BorderSize, -(GW.SpacingSize * 3))
    GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -GW.BorderSize, -(GW.SpacingSize * 3))

    hooksecurefunc("GameTooltip_ShowStatusBar", GameTooltip_ShowStatusBar) -- Skin Status Bars
    hooksecurefunc("GameTooltip_ShowProgressBar", GameTooltip_ShowProgressBar) -- Skin Progress Bars
    hooksecurefunc("GameTooltip_ClearProgressBars", GameTooltip_ClearProgressBars)
    hooksecurefunc("GameTooltip_AddQuestRewardsToTooltip", GameTooltip_AddQuestRewardsToTooltip) -- Color Progress Bars
    hooksecurefunc("SharedTooltip_SetBackdropStyle", SetStyle) -- This also deals with other tooltip borders like AzeriteEssence Tooltip

    --Tooltip Fonts
    if not GameTooltip.hasMoney then
        SetTooltipMoney(GameTooltip, 1, nil, "", "")
        SetTooltipMoney(GameTooltip, 1, nil, "", "")
        GameTooltip_ClearMoney(GameTooltip)
    end
    SetTooltipFonts()

    RegisterMovableFrame(GameTooltip, "Tooltip", "GameTooltipPos", "VerticalActionBarDummy", {230, 80}, {"default"})

    hooksecurefunc("GameTooltip_SetDefaultAnchor", GameTooltip_SetDefaultAnchor)

    if GetSetting("ADVANCED_TOOLTIP") then
        GameTooltip.StatusBar = GameTooltipStatusBar
        GameTooltip.StatusBar:SetScript("OnValueChanged", nil)
        GameTooltip.StatusBar.text = GameTooltip.StatusBar:CreateFontString(nil, "OVERLAY")
        GameTooltip.StatusBar.text:SetPoint("CENTER", GameTooltip.StatusBar, 0, 0)
        GameTooltip.StatusBar.text:SetFont(DAMAGE_TEXT_FONT, 10, "OUTLINE")

        hooksecurefunc("SetItemRef", SetItemRef)
        hooksecurefunc("EmbeddedItemTooltip_SetItemByID", EmbeddedItemTooltip_ID)
        hooksecurefunc("EmbeddedItemTooltip_SetCurrencyByID", EmbeddedItemTooltip_ID)
        hooksecurefunc("EmbeddedItemTooltip_SetItemByQuestReward", EmbeddedItemTooltip_QuestReward)
        hooksecurefunc("EmbeddedItemTooltip_SetSpellByQuestReward", EmbeddedItemTooltip_QuestReward)

        hooksecurefunc(GameTooltip, "SetUnitAura", SetUnitAura)
        hooksecurefunc(GameTooltip, "SetUnitBuff", SetUnitAura)
        hooksecurefunc(GameTooltip, "SetUnitDebuff", SetUnitAura)

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

        GameTooltip:HookScript("OnTooltipSetUnit", GameTooltip_OnTooltipSetUnit)
        GameTooltip:HookScript("OnTooltipSetItem", GameTooltip_OnTooltipSetItem)
        GameTooltip:HookScript("OnTooltipCleared", GameTooltip_OnTooltipCleared)
        GameTooltip:HookScript("OnTooltipSetSpell", GameTooltip_OnTooltipSetSpell)

        GameTooltip.StatusBar:HookScript("OnValueChanged", GameTooltipStatusBar_OnValueChanged)
    end

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:SetScript("OnEvent", function(_, event)
        if not GetSetting("HIDE_TOOLTIP_IN_COMBAT") then return end

        if event == "PLAYER_REGEN_DISABLED" and shouldHiddenInCombat(GameTooltip) and not IsModKeyDown("HIDE_TOOLTIP_IN_COMBAT_OVERRIDE") then
            GameTooltip:Hide()
        end
    end)

    GameTooltip:HookScript("OnShow", function(self)
        if GetSetting("HIDE_TOOLTIP_IN_COMBAT") and InCombatLockdown() and shouldHiddenInCombat(self) and not IsModKeyDown("HIDE_TOOLTIP_IN_COMBAT_OVERRIDE") then
            self:Hide()
        end
    end)
end
GW.LoadTooltips = LoadTooltips