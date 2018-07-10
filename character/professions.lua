local _, GW = ...
local CharacterMenuButton_OnLoad = GW.CharacterMenuButton_OnLoad
--local CharacterMenuButtonBack_OnLoad = GW.CharacterMenuButtonBack_OnLoad
local FACTION_BAR_COLORS = GW.FACTION_BAR_COLORS
local Debug = GW.Debug

local profs = {
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

local function profButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetSpellBookItem(self.spellIdx, BOOKTYPE_PROFESSION)
    GameTooltip:Show()
end
GW.AddForProfiling("professions", "profButton_OnEnter", profButton_OnEnter)

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
        self.spellIdx = spellIdx
        self.skillName = name
        self.icon:SetTexture(tex)
        self.name:SetText(name)
        self:SetAttribute("type", "spell")
        self:SetAttribute("spell", spellId)
        self:SetAttribute("_ondragstart", profButtonSecure_OnDragStart)
        self:Enable()
        if unlearn then
            self.unlearn:Show()
        else
            self.unlearn:Hide()
        end
    else
        self.spellIdx = nil
        self.skillname = nil
        self.specIdx = nil
        self.icon:SetTexture(nil)
        self.name:SetText(nil)
        self:SetAttribute("type", nil)
        self:SetAttribute("spell", nil)
        self:SetAttribute("_ondragstart", nil)
        self:Disable()
        self.unlearn:Hide()
    end
end
GW.AddForProfiling("professions", "updateButton", updateButton)

local function unlearn_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetText(UNLEARN_SKILL_TOOLTIP)
    GameTooltip:Show()
end
GW.AddForProfiling("professions", "unlearn_OnEnter", unlearn_OnEnter)

local function unlearn_OnClick(self, button)
    if InCombatLockdown() then
        PlaySound(44310)
        UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0)
        return
    end
    local skill = self:GetParent()
    StaticPopup_Show("UNLEARN_SKILL", skill.skillName, nil, skill.profId)
end
GW.AddForProfiling("professions", "unlearn_OnClick", unlearn_OnClick)

local function unlearnSpec_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:SetText(UNLEARN_SPECIALIZATION_TOOLTIP)
    GameTooltip:Show()
end
GW.AddForProfiling("professions", "unlearnSpec_OnEnter", unlearnSpec_OnEnter)

local function unlearnSpec_OnClick(self, button)
    if InCombatLockdown() then
        PlaySound(44310)
        UIErrorsFrame:AddMessage(SPELL_FAILED_AFFECTING_COMBAT, 1.0, 0.1, 0.1, 1.0)
        return
    end
    local skill = self:GetParent()
    StaticPopup_Show("UNLEARN_SPECIALIZATION", skill.skillName, nil, skill.specIdx)
end
GW.AddForProfiling("professions", "unlearnSpec_OnClick", unlearnSpec_OnClick)

local function updateOverview(fmOverview)
    if InCombatLockdown() then
        return
    end

    local fmProfs = fmOverview.profs
    local iProf1, iProf2, iArch, iFish, iCook, _ = GetProfessions()

    local txR = 588 / 1024
    local txH = 110

    for i = 1, 5, 1 do
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
        end
        if idx ~= nil then
            local name, icon, skill, skillMax, num, offset, profId, skillMod, specId, specOff, skillDesc =
                GetProfessionInfo(idx)
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
            if skillDesc ~= nil then
                fm.desc:SetText(skillDesc)
            else
                fm.desc:SetText(nil)
            end
            fm.desc:SetWidth(220)
            fm.StatusBar:SetValue(skill / skillMax)
            fm.StatusBar.currentValue:SetText(skill .. "/" .. skillMax)
            if skillMod and skillMod ~= 0 then
                fm.StatusBar.bonusValue:SetText("(+" .. skillMod .. ")")
            else
                fm.StatusBar.bonusValue:SetText(nil)
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
                fm.background:SetTexture("Interface/AddOns/GW2_UI/textures/character/paperdollbg")
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
                fm.icon:SetTexture(1392955)
                fm.title:SetText(PROFESSIONS_FIRST_PROFESSION)
                fm.desc:SetText(PROFESSIONS_MISSING_PROFESSION)
            elseif i == 2 then
                fm.icon:SetTexture(1392955)
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
            fm.background:SetTexture("Interface/AddOns/GW2_UI/textures/character/paperdollbg")
            fm.background:SetTexCoord(0, 1, 1, 0)
            fm.background:SetAlpha(1.0)
            SetDesaturation(fm.background, true)
            fm.unlearn:Hide()
        end
    end
end
GW.AddForProfiling("professions", "updateOverview", updateOverview)

local function overview_OnUpdate(self, elapsed)
    self:SetScript("OnUpdate", nil)
    updateOverview(self)
    self.queuedUpdate = false
end
GW.AddForProfiling("professions", "overview_OnUpdate", overview_OnUpdate)

local function queueUpdate(fm)
    if fm.queuedUpdate then
        return
    end

    fm.queuedUpdate = true
    fm:SetScript("OnUpdate", overview_OnUpdate)
end
GW.AddForProfiling("professions", "queueUpdate", queueUpdate)

local function overview_OnEvent(self, event, ...)
    if event == "SKILL_LINES_CHANGED" or event == "TRIAL_STATUS_UPDATE" or event == "SPELLS_CHANGED" then
        if not self:IsShown() then
            return
        end
        queueUpdate(self)
    end
end
GW.AddForProfiling("professions", "overview_OnEvent", overview_OnEvent)

local function overview_OnShow(self)
    updateOverview(self)
end
GW.AddForProfiling("professions", "overview_OnShow", overview_OnShow)

local function loadOverview(parent)
    local fmOverview = CreateFrame("Frame", nil, parent, "GwProfessionsOverview")
    fmOverview.profs = {}

    for i = 1, 5, 1 do
        local fm = CreateFrame("Frame", nil, fmOverview, "GwProfessionsOverFrame")
        if i > 1 then
            fm:ClearAllPoints()
            fm:SetPoint("TOPLEFT", fmOverview, "TOPLEFT", 10, -10 - ((i - 1) * 115))
        end

        local mask = UIParent:CreateMaskTexture()
        mask:SetPoint("CENTER", fm.icon, "CENTER", 0, 0)
        mask:SetTexture(
            "Interface\\AddOns\\GW2_UI\\textures\\talents\\passive_border",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        mask:SetSize(60, 60)
        fm.icon:AddMaskTexture(mask)

        fm.title:SetFont(DAMAGE_TEXT_FONT, 18)
        fm.title:SetTextColor(1, 1, 1, 1)
        fm.title:SetShadowColor(0, 0, 0, 1)
        fm.title:SetShadowOffset(1, -1)
        fm.desc:SetFont(UNIT_NAME_FONT, 14)
        fm.desc:SetTextColor(0.8, 0.8, 0.8, 1)
        fm.desc:SetShadowColor(0, 0, 0, 1)
        fm.desc:SetShadowOffset(1, -1)

        fm.StatusBar.currentValue:SetFont(UNIT_NAME_FONT, 12)
        fm.StatusBar.bonusValue:SetFont(UNIT_NAME_FONT, 12)

        fm.StatusBar.currentValue:SetShadowColor(0, 0, 0, 1)
        fm.StatusBar.bonusValue:SetShadowColor(0, 0, 0, 1)

        fm.StatusBar.currentValue:SetShadowOffset(1, -1)
        fm.StatusBar.bonusValue:SetShadowOffset(1, -1)

        fm.StatusBar:SetMinMaxValues(0, 1)
        fm.StatusBar:SetValue(0)
        fm.StatusBar:SetStatusBarColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b)

        fm.btn1.name:SetFont(DAMAGE_TEXT_FONT, 14)
        fm.btn1.name:SetTextColor(1, 1, 1, 1)
        fm.btn1.name:SetShadowColor(0, 0, 0, 1)
        fm.btn1.name:SetShadowOffset(1, -1)
        fm.btn1:SetScript("OnEnter", profButton_OnEnter)
        fm.btn1:SetScript("OnLeave", GameTooltip_Hide)
        fm.btn1:EnableMouse(true)
        fm.btn1:RegisterForDrag("LeftButton")

        fm.btn2.name:SetFont(DAMAGE_TEXT_FONT, 14)
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
GW.AddForProfiling("professions", "loadOverview", loadOverview)

local function LoadProfessions(tabContainer)
    local fmMenu = CreateFrame("Frame", nil, tabContainer, "GwCharacterMenu")

    loadOverview(tabContainer)

    fmMenu.overviewMenu = CreateFrame("Button", nil, fmMenu, "GwCharacterMenuButtonTemplate")
    fmMenu.overviewMenu:SetText(TRADESKILLS)
    fmMenu.overviewMenu:ClearAllPoints()
    fmMenu.overviewMenu:SetPoint("TOPLEFT", fmMenu, "TOPLEFT")

    CharacterMenuButton_OnLoad(fmMenu.overviewMenu, false)

    fmMenu.overviewMenu:SetNormalTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
end
GW.LoadProfessions = LoadProfessions
