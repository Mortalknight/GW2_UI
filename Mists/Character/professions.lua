local _, GW = ...
local FACTION_BAR_COLORS = GW.FACTION_BAR_COLORS

local profs = {
    ["100"] = {["tag"] = "firstAid", ["icon"] = 133678},
    ["185"] = {["tag"] = "cook", ["icon"] = 133971, ["atlas"] = "gather", ["idx"] = 6},
    ["356"] = {["tag"] = "fish", ["icon"] = 136245, ["atlas"] = "gather", ["idx"] = 5},
    ["794"] = {["tag"] = "arch", ["icon"] = 441139, ["atlas"] = "gather", ["idx"] = 4},
    ["171"] = {["tag"] = "alch", ["atlas"] = "prod", ["idx"] = 4},
    ["164"] = {["tag"] = "smith", ["atlas"] = "prod", ["idx"] = 8},
    ["333"] = {["tag"] = "enchant", ["atlas"] = "prod", ["idx"] = 6},
    ["202"] = {["tag"] = "eng", ["atlas"] = "prod", ["idx"] = 3},
    ["773"] = {["tag"] = "scribe", ["atlas"] = "prod", ["idx"] = 7},
    ["755"] = {["tag"] = "jewel", ["atlas"] = "prod", ["idx"] = 5},
    ["165"] = {["tag"] = "leather", ["atlas"] = "prod", ["idx"] = 2},
    ["197"] = {["tag"] = "tailor", ["atlas"] = "prod", ["idx"] = 1},
    ["182"] = {["tag"] = "herb", ["atlas"] = "gather", ["idx"] = 2},
    ["186"] = {["tag"] = "mine", ["atlas"] = "gather", ["idx"] = 3},
    ["393"] = {["tag"] = "skin", ["atlas"] = "gather", ["idx"] = 1}
}

local function TalProfButton_OnModifiedClick(self)
    local slot = self.spellbookIndex
    local book = self.booktype
    if IsModifiedClick("CHATLINK") then
        if MacroFrameText and MacroFrameText:HasFocus() then
            local spell, subSpell = GetSpellBookItemName(slot, book)
            if spell and not IsPassiveSpell(slot, book) then
                if subSpell and strlen(subSpell) > 0 then
                    ChatEdit_InsertLink(spell .. "(" .. subSpell .. ")")
                else
                    ChatEdit_InsertLink(spell)
                end
            end
        else
            local profLink, profId = GetSpellTradeSkillLink(slot, book)
            if profId then
                ChatEdit_InsertLink(profLink)
            else
                ChatEdit_InsertLink(GetSpellLink(slot, book))
            end
        end
    elseif IsModifiedClick("PICKUPACTION") and not InCombatLockdown() and not IsPassiveSpell(slot, book) then
        PickupSpellBookItem(slot, book)
    end
end

local function profButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetSpellBookItem(self.spellbookIndex, self.booktype)
    GameTooltip:Show()
end


local profButtonSecure_OnDragStart =
    [=[
    local spellId = self:GetAttribute("spell")
    if not spellId then
        return "clear", nil
    end
    return "clear", "spell", spellId
    ]=]

local function updateButton(self, spellIdx, unlearn)
    if spellIdx then
        local tex = GetSpellBookItemTexture(spellIdx, BOOKTYPE_PROFESSION)
        local name, _, spellId = GetSpellBookItemName(spellIdx, BOOKTYPE_PROFESSION)
        self.spellbookIndex = spellIdx
        self.booktype = BOOKTYPE_PROFESSION
        self.skillName = name
        self.icon:SetTexture(tex)
        self.name:SetText(name)
        self.modifiedClick = TalProfButton_OnModifiedClick
        self:RegisterForClicks("AnyDown")
        self:SetAttribute("type1", "spell")
        self:SetAttribute("type2", "spell")
        self:SetAttribute("shift-type1", "modifiedClick")
        self:SetAttribute("shift-type2", "modifiedClick")
        self:SetAttribute("spell", spellId)
        self:SetAttribute("_ondragstart", profButtonSecure_OnDragStart)
        self:Enable()
        if unlearn then
            self.unlearn:Show()
        else
            self.unlearn:Hide()
        end
        if name then
            self:SetAlpha(1)
        else
            self:SetAlpha(0)
        end
    else
        self.spellbookIndex = nil
        self.booktype = nil
        self.skillname = nil
        self.specIdx = nil
        self.icon:SetTexture(nil)
        self.name:SetText(nil)
        self:SetAttribute("type1", nil)
        self:SetAttribute("type2", nil)
        self:SetAttribute("shift-type1", nil)
        self:SetAttribute("shift-type2", nil)
        self:SetAttribute("spell", nil)
        self:SetAttribute("_ondragstart", nil)
        self:Disable()
        self.unlearn:Hide()
        self:SetAlpha(0)
    end
end


local function unlearn_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetText(UNLEARN_SKILL_TOOLTIP)
    GameTooltip:Show()
end


local function unlearn_OnClick(self)
    if InCombatLockdown() then
        PlaySound(44310)
        UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0)
        return
    end
    local skill = self:GetParent()
    StaticPopup_Show("UNLEARN_SKILL", skill.skillName, nil, skill.profId)
end


local function unlearnSpec_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetText(UNLEARN_SPECIALIZATION_TOOLTIP)
    GameTooltip:Show()
end


local function unlearnSpec_OnClick(self)
    if InCombatLockdown() then
        PlaySound(44310)
        UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0)
        return
    end
    local skill = self:GetParent()
    StaticPopup_Show("UNLEARN_SPECIALIZATION", skill.skillName, nil, skill.specIdx)
end


local function updateOverview(fmOverview)
    if InCombatLockdown() then
        return
    end

    local fmProfs = fmOverview.profs
    local iProf1, iProf2, iArch, iFish, iCook, iFirstAid = GetProfessions()

    local txR = 588 / 1024
    local txH = 110

    for i = 1, 6, 1 do
        local fm = fmProfs[i]
        local idx
        if i == 1 then
            idx = iProf1
        elseif i == 2 then
            idx = iProf2
        elseif i == 3 then
            idx = iCook
        elseif i == 4 then
            idx = iFish
        elseif i == 5 then
            idx = iArch
        elseif i == 6 then
            idx = iFirstAid
        end
        if idx then
            local name, icon, skill, skillMax, num, offset, profId, skillMod, specId, specOff, skillDesc = GetProfessionInfo(idx)
            local skillValue = 0
            fm.skillName = name
            fm.profId = profId
            fm.icon:SetTexture(icon)
            SetDesaturation(fm.icon, false)
            fm.title:SetText(name)

            if not skillDesc then
                for k = 1, #PROFESSION_RANKS do
                    local value, title = PROFESSION_RANKS[k][1], PROFESSION_RANKS[k][2]
                    if skillMax < value then
                        break
                    end
                    skillDesc = title
                end
            end

            if skillMax > 0 then
                skillValue = skill / skillMax
            end
            fm.desc:SetText(skillDesc and skillDesc)
            fm.desc:SetWidth(220)
            fm.StatusBar:SetValue(skillValue)
            if skillMod and skillMod ~= 0 then
                fm.StatusBar.currentValue:SetText(skill .. " +" .. skillMod .. "/" .. skillMax)
            else
                fm.StatusBar.currentValue:SetText(skill .. "/" .. skillMax)
            end
            fm.StatusBar:Show()
            fm.btn1:Show()
            fm.btn2:Show()
            local unlearn1 = false
            local unlearn2 = false
            if specId and specId > 0 and specOff == 1 then
                unlearn1 = true
                fm.btn1.specIdx = specId
            elseif specId and specId > 0 and specOff == 2 then
                unlearn2 = true
                fm.btn2.specIdx = specId
            end
            if num and num == 1 then
                updateButton(fm.btn1, offset + 1, unlearn1)
                updateButton(fm.btn2, nil)
            elseif num and num ~= 1 then
                updateButton(fm.btn1, offset + 1, unlearn1)
                updateButton(fm.btn2, offset + 2, unlearn2)
            else
                updateButton(fm.btn1, nil)
                updateButton(fm.btn2, nil)
            end

            if profId and profs[profId .. ""] then
                local p = profs[profId .. ""]
                local txT = (p.idx - 1) * txH
                fm.background:SetTexture("Interface/AddOns/GW2_UI/textures/character/professions_overview_" .. p.atlas)
                fm.background:SetTexCoord(0, txR, txT / 1024, (txT + txH) / 1024)
                fm.background:SetAlpha(0.5)
            else
                fm.background:SetTexture("Interface/AddOns/GW2_UI/textures/character/paperdollbg.png")
                fm.background:SetTexCoord(0, 1, 1, 0)
                fm.background:SetAlpha(1.0)
            end
            SetDesaturation(fm.background, false)
            if i > 2 then
                fm.unlearn:Hide()
            else
                fm.unlearn:Show()
            end
        else
            if i == 1 then
                fm.icon:SetTexture("Interface\\Icons\\INV_Scroll_04")
                fm.title:SetText(PROFESSIONS_FIRST_PROFESSION)
                fm.desc:SetText(PROFESSIONS_MISSING_PROFESSION)
            elseif i == 2 then
                fm.icon:SetTexture("Interface\\Icons\\INV_Scroll_04")
                fm.title:SetText(PROFESSIONS_SECOND_PROFESSION)
                fm.desc:SetText(PROFESSIONS_MISSING_PROFESSION)
            elseif i == 3 then
                fm.icon:SetTexture(profs["185"].icon)
                fm.title:SetText(PROFESSIONS_COOKING)
                fm.desc:SetText(PROFESSIONS_COOKING_MISSING)
            elseif i == 4 then
                fm.icon:SetTexture(profs["356"].icon)
                fm.title:SetText(PROFESSIONS_FISHING)
                fm.desc:SetText(PROFESSIONS_FISHING_MISSING)
            elseif i == 5 then
                fm.icon:SetTexture(profs["794"].icon)
                fm.title:SetText(PROFESSIONS_ARCHAEOLOGY)
                fm.desc:SetText(PROFESSIONS_ARCHAEOLOGY_MISSING)
            elseif i == 6 then
                fm.icon:SetTexture(profs["100"].icon)
                fm.title:SetText(PROFESSIONS_FIRST_AID)
                fm.desc:SetText(PROFESSIONS_FIRST_AID_MISSING)
            else
                fm.icon:SetTexture(nil)
                fm.title:SetText(nil)
                fm.desc:SetText(nil)
            end
            fm.desc:SetWidth(450)
            fm.skillName = nil
            fm.profId = nil
            SetDesaturation(fm.icon, true)
            fm.StatusBar:Hide()
            fm.btn1:Hide()
            fm.btn2:Hide()
            fm.background:SetTexture("Interface/AddOns/GW2_UI/textures/character/paperdollbg.png")
            fm.background:SetTexCoord(0, 1, 1, 0)
            fm.background:SetAlpha(1.0)
            SetDesaturation(fm.background, true)
            fm.unlearn:Hide()
        end
    end
end


local function overview_OnUpdate(self)
    self:SetScript("OnUpdate", nil)
    updateOverview(self)
    self.queuedUpdate = false
end


local function queueUpdate(fm)
    if fm.queuedUpdate then
        return
    end

    fm.queuedUpdate = true
    fm:SetScript("OnUpdate", overview_OnUpdate)
end


local function overview_OnEvent(self)
    if GW.inWorld and self:IsShown() then
        queueUpdate(self)
    end
end


local function overview_OnShow(self)
    updateOverview(self)
end


local function loadOverview(parent)
    local fmOverview = CreateFrame("Frame", nil, parent, "GwProfessionsOverview")
    fmOverview.profs = {}

    for i = 1, 6, 1 do
        local fm = CreateFrame("Frame", nil, fmOverview, "GwProfessionsOverFrame")
        if i == 3 then
            fm:ClearAllPoints()
            fm:SetPoint("TOPLEFT", fmOverview, "TOPLEFT", 10, -10 - ((i - 1) * 115))
        elseif i == 4 then
            fm:ClearAllPoints()
            fm:SetPoint("TOPLEFT", fmOverview, "TOPLEFT", 10, -10 - ((i - 1) * 105))
        elseif i > 4 then
            fm:ClearAllPoints()
            fm:SetPoint("TOPLEFT", fmOverview, "TOPLEFT", 10, -10 - ((i - 1) * 100))
        elseif i > 1 then
            fm:ClearAllPoints()
            fm:SetPoint("TOPLEFT", fmOverview, "TOPLEFT", 10, -10 - ((i - 1) * 115))
        end

        if i >= 3 then
            fm:SetHeight(90)
            fm.background:SetHeight(90)
            fm.art:SetHeight(90)

            fm.btn2:ClearAllPoints()
            fm.btn2:SetPoint("TOPLEFT", fm, "TOPLEFT", 350, -50)

            fm.desc:SetJustifyV("TOP")

            fm.StatusBar:ClearAllPoints()
            fm.StatusBar:SetPoint("TOPLEFT", fm, "TOPLEFT", 102, -70)
        end

        local mask = UIParent:CreateMaskTexture()
        mask:SetPoint("CENTER", fm.icon, "CENTER", 0, 0)
        mask:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border.png",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        mask:SetSize(60, 60)
        fm.icon:AddMaskTexture(mask)

        fm.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER)
        fm.title:SetTextColor(1, 1, 1, 1)
        fm.title:SetShadowColor(0, 0, 0, 1)
        fm.title:SetShadowOffset(1, -1)
        fm.desc:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        fm.desc:SetTextColor(0.8, 0.8, 0.8, 1)
        fm.desc:SetShadowColor(0, 0, 0, 1)
        fm.desc:SetShadowOffset(1, -1)

        fm.StatusBar.currentValue:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.SMALL)
        fm.StatusBar.currentValue:SetShadowColor(0, 0, 0, 1)
        fm.StatusBar.currentValue:SetShadowOffset(1, -1)

        fm.StatusBar:SetMinMaxValues(0, 1)
        fm.StatusBar:SetValue(0)
        fm.StatusBar:SetStatusBarColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)

        fm.btn1.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        fm.btn1.name:SetTextColor(1, 1, 1, 1)
        fm.btn1.name:SetShadowColor(0, 0, 0, 1)
        fm.btn1.name:SetShadowOffset(1, -1)
        fm.btn1:SetScript("OnEnter", profButton_OnEnter)
        fm.btn1:SetScript("OnLeave", GameTooltip_Hide)
        fm.btn1:EnableMouse(true)
        fm.btn1:RegisterForDrag("LeftButton")

        fm.btn2.name:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
        fm.btn2.name:SetTextColor(1, 1, 1, 1)
        fm.btn2.name:SetShadowColor(0, 0, 0, 1)
        fm.btn2.name:SetShadowOffset(1, -1)
        fm.btn2:SetScript("OnEnter", profButton_OnEnter)
        fm.btn2:SetScript("OnLeave", GameTooltip_Hide)
        fm.btn2:EnableMouse(true)
        fm.btn2:RegisterForDrag("LeftButton")

        fm.unlearn:SetScript("OnClick", unlearn_OnClick)
        fm.unlearn:SetScript("OnEnter", unlearn_OnEnter)
        fm.unlearn:SetScript("OnLeave", GameTooltip_Hide)
        fm.btn1.unlearn:SetScript("OnClick", unlearnSpec_OnClick)
        fm.btn1.unlearn:SetScript("OnEnter", unlearnSpec_OnEnter)
        fm.btn1.unlearn:SetScript("OnLeave", GameTooltip_Hide)
        fm.btn2.unlearn:SetScript("OnClick", unlearnSpec_OnClick)
        fm.btn2.unlearn:SetScript("OnEnter", unlearnSpec_OnEnter)
        fm.btn2.unlearn:SetScript("OnLeave", GameTooltip_Hide)

        fmOverview.profs[i] = fm
    end

    fmOverview:SetScript("OnShow", overview_OnShow)
    fmOverview:SetScript("OnEvent", overview_OnEvent)
    fmOverview:RegisterEvent("SKILL_LINES_CHANGED")
    fmOverview:RegisterEvent("TRIAL_STATUS_UPDATE")
    fmOverview:RegisterEvent("SPELLS_CHANGED")

    updateOverview(fmOverview)
end


local function LoadProfessions()
    local professionWindow = CreateFrame("Frame", "GwProfessionsFrame", GwCharacterWindow, "GwCharacterTabContainer")
    local fmMenu = CreateFrame("Frame", nil, professionWindow, "GwCharacterMenu")

    loadOverview(professionWindow)

    fmMenu.overviewMenu = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate")
    fmMenu.overviewMenu:SetText(TRADESKILLS)
    fmMenu.overviewMenu:ClearAllPoints()
    fmMenu.overviewMenu:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")

    GW.CharacterMenuButton_OnLoad(fmMenu.overviewMenu, false)

    fmMenu.overviewMenu:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover.png")

    return professionWindow
end
GW.LoadProfessions = LoadProfessions
