---@class GW2
local GW = select(2, ...)

local SKILL_RANKS_PER_SKILL_LEVEL = 5
local DEFENSE_SKILL_ID = 95
local SAME_LEVEL_OFFSET, BOSS_LEVEL_OFFSET = 0, 3
local HIDDEN_SKILL_LINE_CATEGORIES = {[7] = true}
local skillsPanel

local WEAPON_SKILL_LINES = {
    [43] = false, [44] = false, [54] = false, [55] = false, [136] = false, [160] = false, [172] = false,
    [173] = false, [229] = false, [162] = false, [3014] = false,
    [45] = true, [46] = true, [176] = true, [226] = true, [228] = true,
}

local function GetWeaponSkillDiff(levelOffset, weaponSkill)
    return (UnitLevel("player") + levelOffset) * SKILL_RANKS_PER_SKILL_LEVEL - weaponSkill
end

local function GetHitChance(levelOffset, weaponSkill)
    return GetWeaponSkillDiff(levelOffset, weaponSkill) * -0.04
end

local function GetGlancingBlowPenalty(levelOffset, weaponSkill)
    local skillDiff = GetWeaponSkillDiff(levelOffset, weaponSkill)
    local low = 1.30 - 0.05 * skillDiff
    if skillDiff > 10 then low = low + 0.1 end
    low = math.max(0.01, math.min(low, 0.91))

    local high = 1.20 - 0.03 * skillDiff
    if skillDiff > 10 then high = high + 0.1 end
    high = math.min(0.99, math.max(high, 0.20))

    return 100 - math.max(0, math.min(1, (low + high) / 2)) * 100
end

local function GetGlancingBlowChance(levelOffset, weaponSkill)
    weaponSkill = math.min(UnitLevel("player") * SKILL_RANKS_PER_SKILL_LEVEL, weaponSkill)
    local chance = 0.02 * GetWeaponSkillDiff(levelOffset, weaponSkill) + 0.1
    return math.max(-100, math.min(100, chance * 100))
end

local function FormatSignedPercent(value)
    if value == 0 then value = 0 end
    local text = format("%.2f%%", value)
    return value > 0 and "+" .. text or text
end

local function FormatPercent(value)
    return format("%.0f%%", value)
end

local function GetSkillInfo(index)
    local info = C_SkillInfo.GetSkillLineInfo(index)
    if info and info.skillID == DEFENSE_SKILL_ID then
        info.modifier = select(2, UnitDefenseSkill("player"))
    end
    return info
end

local function ShouldShowSkillLine(info)
    if info.isHeader then
        return not HIDDEN_SKILL_LINE_CATEGORIES[info.skillID]
    end
    return not HIDDEN_SKILL_LINE_CATEGORIES[info.skillLineCategoryID]
end

local function SetBarValues(bar, info)
    local maxRank = math.max(info.maxRank, 1)
    bar:SetMinMaxValues(0, maxRank)
    bar:SetValue(info.rank)
    if info.modifier == 0 then
        bar.text:SetText(info.rank .. " / " .. info.maxRank)
    else
        local color = info.modifier > 0 and GREEN_FONT_COLOR_CODE .. "+" or RED_FONT_COLOR_CODE
        bar.text:SetText(info.rank .. " (" .. color .. info.modifier .. FONT_COLOR_CODE_CLOSE .. ") / " .. info.maxRank)
    end
end

---------- details ----------

local SECTION_PADDING = 10

local function AcquireSection(details)
    details.sectionPool = details.sectionPool or {}
    details.sectionsUsed = (details.sectionsUsed or 0) + 1
    local section = details.sectionPool[details.sectionsUsed]
    if not section then
        section = CreateFrame("Frame", nil, details.Rows)
        section:SetWidth(215)
        GW.AddDetailsBackground(section)

        -- header like the heirloom headers of the collections skin: accent dot, title, fading line
        section.accent = section:CreateTexture(nil, "ARTWORK")
        section.accent:SetColorTexture(1, 1, 1, 0.85)
        section.accent:SetSize(5, 5)
        section.accent:SetPoint("TOPLEFT", section, "TOPLEFT", 4, -SECTION_PADDING - 7)

        section.header = section:CreateFontString(nil, "OVERLAY")
        section.header:SetPoint("TOPLEFT", section, "TOPLEFT", SECTION_PADDING + 4, -SECTION_PADDING)
        section.header:SetWidth(215 - 2 * SECTION_PADDING - 4)
        section.header:SetJustifyH("LEFT")
        section.header:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        section.header:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

        section.separator = section:CreateTexture(nil, "ARTWORK")
        section.separator:SetTexture("Interface/AddOns/GW2_UI/textures/hud/levelreward-sep.png")
        section.separator:SetVertexColor(1, 1, 1, 0.65)
        section.separator:SetTexCoord(0.5, 413 / 512, 0, 1)
        section.separator:SetSize(215 - 2 * SECTION_PADDING - 4, 2)
        section.separator:SetPoint("TOPLEFT", section.header, "BOTTOMLEFT", 0, -1)

        section.text = section:CreateFontString(nil, "OVERLAY")
        section.text:SetPoint("TOPLEFT", section.header, "BOTTOMLEFT", 0, -8)
        section.text:SetWidth(215 - 2 * SECTION_PADDING)
        section.text:SetJustifyH("LEFT")
        section.text:SetJustifyV("TOP")
        section.text:SetWordWrap(true)
        section.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
        section.text:SetTextColor(1, 1, 1)
        details.sectionPool[details.sectionsUsed] = section
    end
    section:Show()
    return section
end

local function AddSection(details, header, text)
    local section = AcquireSection(details)
    section.header:SetText(header)
    section.text:SetText(text)
    section:SetHeight(section.header:GetStringHeight() + 8 + section.text:GetStringHeight() + 2 * SECTION_PADDING)
end

local function ResetSections(details)
    for _, section in ipairs(details.sectionPool or {}) do
        section:Hide()
    end
    details.sectionsUsed = 0
end

local function LayoutSections(details)
    local previous
    for i = 1, details.sectionsUsed or 0 do
        local section = details.sectionPool[i]
        section:ClearAllPoints()
        if previous then
            section:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -8)
        else
            section:SetPoint("TOPLEFT", details.Rows, "TOPLEFT", 0, 0)
        end
        previous = section
    end
end

local function AddWeaponSkillRows(details, info)
    local isRanged = WEAPON_SKILL_LINES[info.skillID]
    local weaponSkill = info.rank + info.modifier

    local sameLevelHit = FormatSignedPercent(GetHitChance(SAME_LEVEL_OFFSET, weaponSkill))
    local sameLevelFormat = isRanged and WEAPON_SKILL_DETAIL_SAME_LEVEL_RANGED or WEAPON_SKILL_DETAIL_SAME_LEVEL
    AddSection(details, WEAPON_SKILL_DETAIL_SAME_LEVEL_HEADER, sameLevelFormat:format(sameLevelHit, sameLevelHit))

    local bossHit = FormatSignedPercent(GetHitChance(BOSS_LEVEL_OFFSET, weaponSkill))
    local bossText
    if isRanged then
        bossText = WEAPON_SKILL_DETAIL_BOSS_RANGED:format(bossHit, bossHit)
    else
        bossText = WEAPON_SKILL_DETAIL_BOSS:format(bossHit, bossHit, FormatPercent(GetGlancingBlowChance(BOSS_LEVEL_OFFSET, weaponSkill)), FormatPercent(GetGlancingBlowPenalty(BOSS_LEVEL_OFFSET, weaponSkill)))
    end
    AddSection(details, WEAPON_SKILL_DETAIL_BOSS_HEADER, bossText)
end

local function GetSelectedSkillInfo()
    local index = C_SkillInfo.GetSelectedSkill()
    if not index or index <= 0 then return end
    local info = GetSkillInfo(index)
    if info and not info.isHeader then
        return info
    end
end

local function RefreshDetails(details)
    ResetSections(details)
    local info = GetSelectedSkillInfo()
    if not info then
        details.Title:SetText("")
        details.Description:SetText("")
        details.RankBar:Hide()
        details.Empty:Show()
        return
    end

    details.Empty:Hide()
    details.RankBar:Show()
    details.Title:SetText(info.name)
    SetBarValues(details.RankBar, info)
    details.Description:SetText(info.description or "")

    if WEAPON_SKILL_LINES[info.skillID] ~= nil then
        AddWeaponSkillRows(details, info)
    end
    LayoutSections(details)
end

---------- list ----------

local function abandon_OnClick(self)
    local entry = self:GetParent()
    GW.ShowPopup({text = UNLEARN_SKILL:format(entry.info.name), OnAccept = function() C_SkillInfo.AbandonSkill(entry.info.skillID) end})
end

local function abandon_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(UNLEARN_SKILL_TOOLTIP, 1, 1, 1)
    GameTooltip:Show()
end

local function header_OnClick(self)
    if self.info.isCollapsed then
        C_SkillInfo.ExpandSkillHeader(self.skillIndex)
    else
        C_SkillInfo.CollapseSkillHeader(self.skillIndex)
    end
end

local function entry_OnClick(self)
    C_SkillInfo.SetSelectedSkill(self.skillIndex)
    GW.UpdateSkillsPanel(skillsPanel)
end

local function InitHeader(button, elementData)
    if not button.gwSkinned then
        button.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        button:SetScript("OnClick", header_OnClick)
        button.gwSkinned = true
    end
    button.info = elementData
    button.skillIndex = elementData.skillIndex
    button.Name:SetText(elementData.name)
    button.arrow:SetRotation(elementData.isCollapsed and math.pi / 2 or 0)
end

local function InitEntry(button, elementData)
    if not button.gwSkinned then
        button.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
        button.Bar.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
        button.Bar.text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        button.Bar:SetStatusBarColor(240 / 255, 240 / 255, 155 / 255)
        GW.AddStatusBarFrame(button.Bar)
        button:SetScript("OnClick", entry_OnClick)
        button.abandon:SetScript("OnClick", abandon_OnClick)
        button.abandon:SetScript("OnEnter", abandon_OnEnter)
        button.abandon:SetScript("OnLeave", GameTooltip_Hide)
        GW.AddListItemChildHoverTexture(button)
        button.gwSkinned = true
    end
    button.info = elementData
    button.skillIndex = elementData.skillIndex
    button.Name:SetText(elementData.name)
    SetBarValues(button.Bar, elementData)
    button.zebra:SetVertexColor(1, 1, 1, elementData.zebra and 1 or 0)
    button.selected:SetShown(C_SkillInfo.GetSelectedSkill() == elementData.skillIndex)
    button.abandon:SetShown(elementData.isAbandonable)
end

local function SelectFirstSkillIfNoneSelected()
    if GetSelectedSkillInfo() then return end
    for index = 1, C_SkillInfo.GetNumSkillLines() do
        local info = GetSkillInfo(index)
        if info and info.parentSkillLineID == 0 and not info.isHeader and ShouldShowSkillLine(info) then
            C_SkillInfo.SetSelectedSkill(index)
            return
        end
    end
end

function GW.UpdateSkillsPanel(panel)
    SelectFirstSkillIfNoneSelected()

    local dataProvider = CreateDataProvider()
    local zebra = false
    for index = 1, C_SkillInfo.GetNumSkillLines() do
        local info = GetSkillInfo(index)
        if info and info.parentSkillLineID == 0 and ShouldShowSkillLine(info) then
            info.skillIndex = index
            if info.isHeader then
                zebra = false
            else
                zebra = not zebra
                info.zebra = zebra
            end
            dataProvider:Insert(info)
        end
    end
    panel.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
    RefreshDetails(panel.Details)
end

local function panel_OnEvent(self)
    if self:IsShown() then
        GW.UpdateSkillsPanel(self)
    end
end

function GW.LoadSkillsPanel(tabContainer, fmMenu)
    local panel = CreateFrame("Frame", "GwPaperSkills", tabContainer, "GwSkillsPanelTemplate")
    skillsPanel = panel

    local view = CreateScrollBoxListLinearView()
    view:SetElementFactory(function(factory, elementData)
        if elementData.isHeader then
            factory("GwSkillsHeaderTemplate", InitHeader)
        else
            factory("GwSkillsEntryTemplate", InitEntry)
        end
    end)
    view:SetElementExtentCalculator(function(_, elementData)
        return elementData.isHeader and 30 or 44
    end)
    view:SetPadding(0, 0, 0, 0, 2)
    ScrollUtil.InitScrollBoxListWithScrollBar(panel.ScrollBox, panel.ScrollBar, view)
    GW.HandleTrimScrollBar(panel.ScrollBar)
    GW.HandleScrollControls(panel)
    panel.ScrollBar:SetHideIfUnscrollable(true)

    local details = panel.Details
    GW.AddDetailsBackground(details)
    details.Description:SetPoint("TOP", details.RankBar, "BOTTOM", 0, -14)
    details.Description:SetPoint("LEFT", details, "LEFT", 10, 0)
    details.Description:SetPoint("RIGHT", details, "RIGHT", -10, 0)
    details.RankBar:SetStatusBarColor(240 / 255, 240 / 255, 155 / 255)
    GW.AddStatusBarFrame(details.RankBar)
    details.Title:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
    details.Title:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    details.RankBar.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small, "THINOUTLINE")
    details.RankBar.text:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    details.Description:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    details.Description:SetTextColor(1, 1, 1)
    details.Empty:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    details.Empty:SetTextColor(0.6, 0.6, 0.6)
    details.Empty:SetText(SKILL_DETAIL_SELECT_PROMPT)

    panel:RegisterEvent("SKILL_LINES_CHANGED")
    panel:RegisterUnitEvent("UNIT_LEVEL", "player")
    panel:SetScript("OnEvent", panel_OnEvent)
    panel:SetScript("OnShow", GW.UpdateSkillsPanel)

    fmMenu:SetupBackButton(panel.backButton, CHARACTER .. ": " .. SKILLS)

    return panel
end
