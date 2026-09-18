---@class GW2
local GW = select(2, ...)

local GetNumSkillLines = C_SkillInfo and C_SkillInfo.GetNumSkillLines or GetNumSkillLines


function GW.GetSkillLineInfo(index)
    if C_SkillInfo then
        return C_SkillInfo.GetSkillLineInfo(index)
    else
        local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier,
        skillMaxRank, isAbandonable, _, _, _, _,
        skillDescription = GetSkillLineInfo(skillIndex)
        return {
            skillID = index,
            name = skillName,
            isHeader = isHeader,
            isCollapsed = not isExpanded,
            rank = skillRank,
            tempPoints = numTempPoints,
            modifier = skillModifier,
            maxRank = skillMaxRank,
            isAbandonable = isAbandonable,
            description = skillDescription
        }
    end
end

local function getSkillElement(self, index)
    if _G["GwPaperSkillsItem" .. index] then return _G["GwPaperSkillsItem" .. index] end
    local f = CreateFrame("Button", "GwPaperSkillsItem" .. index, self.scroll.scrollchild, "GwPaperSkillsItem")
    f.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    f.name:SetText(UNKNOWN)
    f.val:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    f.val:SetText(UNKNOWN)
    f:SetText("")
    f.arrow:ClearAllPoints()
    f.arrow:SetPoint("RIGHT", -5, 0)
    f.arrow2:ClearAllPoints()
    f.arrow2:SetPoint("RIGHT", -5, 0)

    f:SetScript("OnClick", function()
        if not f.isHeader then return end

        if f.isExpanded then
            CollapseSkillHeader(f.skillIndex)
        else
            ExpandSkillHeader(f.skillIndex)
        end

        GW.UpdateSkills(self)
    end)

    return f
end

local function updateSkillItem(self)
    if self.isHeader then
        self:SetHeight(30)
        self.val:Hide()
        self.StatusBar:Hide()
        self.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
        self.bgheader:Show()
        self.bg:Hide()
        self.bgstatic:Hide()
        if self.isExpanded then
            self.arrow:Show()
            self.arrow2:Hide()
        else
            self.arrow:Hide()
            self.arrow2:Show()
        end
    else
        self:SetHeight(50)
        self.val:Show()
        self.StatusBar:Show()
        self.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
        self.arrow:Hide()
        self.arrow2:Hide()
        self.bgheader:Hide()
        self.bg:Show()
        self.bgstatic:Show()
    end
end

local function abandonProffesionOnClick(self)
    local skillIndex = self:GetParent().skillIndex
    local skillName = self:GetParent().skillName

    GW.ShowPopup({text = UNLEARN_SKILL:format(skillName), OnAccept = function() AbandonSkill(skillIndex) end})
end

local function abandonProffesionOnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(UNLEARN_SKILL_TOOLTIP, 1, 1, 1)
    GameTooltip:Show()
end

function GW.UpdateSkills(self)
    local height = 50
    local y = 0
    local LastElement = nil
    local totlaHeight = 0

    self.scroll.scrollchild:SetSize(self.scroll:GetSize())
    self.scroll.scrollchild:SetWidth(self.scroll:GetWidth() - 20)

    for skillIndex = 1, GetNumSkillLines() do
        local skillInfo = GW.GetSkillLineInfo(skillIndex)

        skillInfo.rank = skillInfo.rank + skillInfo.tempPoints

        local f = getSkillElement(self, skillIndex)
        local zebra = skillIndex % 2

        f.skillIndex = skillIndex
        f.skillName = skillInfo.name
        if LastElement==nil then
            f:SetPoint("TOPLEFT", 0, -y)
        else
            f:SetPoint("TOPLEFT", LastElement, "BOTTOMLEFT", 0, 0)
        end

        if skillInfo.isAbandonable then
            f.abandon:Show()
            f.abandon:SetScript("OnClick", abandonProffesionOnClick)
            f.abandon:SetScript("OnEnter", abandonProffesionOnEnter)
            f.abandon:SetScript("OnLeave", GameTooltip_Hide)
        else
            f.abandon:Hide()
            f.abandon:SetScript("OnClick", nil)
            f.abandon:SetScript("OnEnter", nil)
            f.abandon:SetScript("OnLeave", nil)
        end

        if skillInfo.maxRank == 0 then skillInfo.maxRank = 1 end

        LastElement = f

        if skillInfo.modifier == 0 then
			f.val:SetText(skillInfo.rank .. " / " .. skillInfo.maxRank)
		else
			local color = RED_FONT_COLOR_CODE
			if skillInfo.modifier > 0 then
				color = GREEN_FONT_COLOR_CODE .. "+"
			end
            f.val:SetText(skillInfo.rank .." (" .. color .. skillInfo.modifier .. FONT_COLOR_CODE_CLOSE .. ") /" .. skillInfo.maxRank)
		end

        y = y + height
        f.name:SetText(skillInfo.name)
        f.tooltip = skillInfo.name
        f.tooltip2 = skillInfo.description
        f.StatusBar:SetValue(skillInfo.rank / skillInfo.maxRank)
        f.isHeader = skillInfo.isHeader
        f.isExpanded = not skillInfo.isCollapsed
        f:SetID(skillIndex)
        f.bg:SetVertexColor(1, 1, 1, zebra)
        updateSkillItem(f)
        totlaHeight = totlaHeight + f:GetHeight()
    end
    self.scroll.slider.thumb:SetHeight((self.scroll:GetHeight()/totlaHeight) * self.scroll.slider:GetHeight() )
    self.scroll.slider:SetMinMaxValues (0,math.max(0,totlaHeight - self.scroll:GetHeight()))
end

function GW.LoadPDSkills(parent, fmMenu)
    local skillsFrame = CreateFrame("Frame", "GwPaperSkills", parent, "GwPaperSkills")

    skillsFrame.scroll:SetScrollChild(skillsFrame.scroll.scrollchild)
    GW.UpdateSkills(skillsFrame)
    skillsFrame.scroll:SetScript("OnMouseWheel", function(self, arg1)
        arg1 = -arg1 * 15
        local min, max = self.slider:GetMinMaxValues()
        local s = math.min(max,math.max(self:GetVerticalScroll() + arg1,min))
        self.slider:SetValue(s)
        self:SetVerticalScroll(s)

    end)
    skillsFrame.scroll.slider:SetValue(1)

    skillsFrame:RegisterEvent("CHAT_MSG_SKILL")
   skillsFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
    skillsFrame:RegisterEvent("SKILL_LINES_CHANGED")
    if not GW.Forever then
        skillsFrame:RegisterEvent("TRADE_SKILL_UPDATE")
    end
    skillsFrame:SetScript("OnEvent", GW.UpdateSkills)

    fmMenu:SetupBackButton(skillsFrame.backButton, CHARACTER .. ": " .. SKILLS)

    return skillsFrame
end