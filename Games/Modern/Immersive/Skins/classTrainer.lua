---@class GW2
local GW = select(2, ...)

local ARROW = "Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png"
local STATUSBAR = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png"
local MENU_BG = "Interface/AddOns/GW2_UI/textures/character/menu-bg.png"
local MENU_HOVER = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"
local ROW_HOVER = "Interface/AddOns/GW2_UI/textures/uistuff/achievementhover.png"

local function SkinMoneyFrame(money)
    for _, coin in ipairs({"Gold", "Silver", "Copper"}) do
        local text = money[coin .. "Button"] and money[coin .. "Button"].Text or _G[money:GetName() and money:GetName() .. coin .. "ButtonText"]
        if text then
            text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
        end
    end
end

local function SkinCategoryRow(row)
    row.LeftPiece:SetAlpha(0)
    row.RightPiece:SetAlpha(0)
    row.CenterPiece:SetAlpha(0)

    row.gwBackground = row:CreateTexture(nil, "BACKGROUND")
    row.gwBackground:SetAllPoints(row)
    row.gwBackground:SetTexture(MENU_BG)

    row.Label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    row.Label:GwLockTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    row.CollapseIconAlphaAdd:SetAlpha(0)
    row.CollapseIcon:SetSize(16, 16)
    hooksecurefunc(row.CollapseIcon, "SetAtlas", function(self, atlas)
        self:SetTexture(ARROW)
        self:SetRotation(atlas and atlas:find("expand") and math.pi / 2 or 0)
    end)
end

local function SkinSkillRow(row)
    -- the skill icon is a region of the row, so stripping the row would take it with it
    for _, texture in ipairs({row:GetNormalTexture(), row:GetHighlightTexture(), row:GetPushedTexture()}) do
        texture:SetAlpha(0)
    end

    row.gwBackground = row:CreateTexture(nil, "BACKGROUND")
    row.gwBackground:SetAllPoints(row)
    row.gwBackground:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png")
    row.gwBackground:SetVertexColor(1, 1, 1, 0.2)

    row.gwHover = row:CreateTexture(nil, "ARTWORK", nil, 1)
    row.gwHover:SetTexture(ROW_HOVER)
    row.gwHover:SetVertexColor(0.8, 0.8, 0.8, 0.8)
    row.gwHover:SetPoint("LEFT", row, "LEFT")
    row.gwHover:SetPoint("TOP", row, "TOP")
    row.gwHover:SetPoint("BOTTOM", row, "BOTTOM")
    row.gwHover:SetPoint("RIGHT", row, "LEFT")
    row.gwHover:Hide()
    row.limitHoverStripAmount = 1
    row:HookScript("OnEnter", function(self)
        self.gwHover:Show()
        GW.TriggerButtonHoverAnimation(self, self.gwHover)
    end)
    row:HookScript("OnLeave", function(self)
        self.gwHover:Hide()
    end)

    row.gwSelected = row:CreateTexture(nil, "ARTWORK", nil, 0)
    row.gwSelected:SetAllPoints(row)
    row.gwSelected:SetTexture(MENU_HOVER)
    row.gwSelected:SetVertexColor(0.8, 0.8, 0.8, 1)
    row.gwSelected:SetShown(row.selectedTex:IsShown())
    row.selectedTex:SetAlpha(0)
    hooksecurefunc(row.selectedTex, "Show", function()
        row.gwSelected:Show()
    end)
    hooksecurefunc(row.selectedTex, "Hide", function()
        row.gwSelected:Hide()
    end)

    GW.HandleIcon(row.icon, true, GW.BackdropTemplates.DefaultWithColorableBorder, true)
    row.icon.backdrop:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)

    row.name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    row.name:GwLockTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    row.subText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    row.subText:GwLockTextColor(1, 1, 1)
    row.nameSubText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    row.nameSubText:GwLockTextColor(0.75, 0.75, 0.75)
    row.alternateCost:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    SkinMoneyFrame(row.money)
end

local function SkinRows(scrollBox)
    scrollBox:ForEachFrame(function(row)
        if not row.gwSkinned then
            row.gwSkinned = true
            if row.CollapseIcon then
                SkinCategoryRow(row)
            elseif row.icon then
                SkinSkillRow(row)
            end
        end
    end)
end

local function ApplyClassTrainerSkin()
    if not GW.settings.skins.classTrainer.enabled then return end

    GW.HandlePortraitFrame(ClassTrainerFrame)
    GW.HandlePortraitFrameArt(ClassTrainerFrame)
    ClassTrainerFrame.BG:Hide()
    ClassTrainerFrameMoneyBg:Hide()
    ClassTrainerFrame.NineSlice:Hide()
    ClassTrainerFrame.Bg:Hide()

    GW.CreateFrameHeaderWithBody(ClassTrainerFrame, ClassTrainerFrame:GetTitleText(), "Interface/AddOns/GW2_UI/textures/character/spellbook-window-icon.png", nil, nil, nil, true)
    ClassTrainerFrame:GetTitleText():GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)

    ClassTrainerFrame.gwHeader.windowIcon:SetSize(48, 48)
    ClassTrainerFrame.gwHeader.windowIcon:ClearAllPoints()
    ClassTrainerFrame.gwHeader.windowIcon:SetPoint("CENTER", ClassTrainerFrame.gwHeader, "BOTTOMLEFT", 30, 19)
    ClassTrainerFrame:HookScript("OnShow", function(self)
        GW.SetHeaderPortrait(self.gwHeader, "npc")
    end)

    ClassTrainerFrame.CloseButton:GwSkinButton(true, false)
    ClassTrainerFrame.CloseButton:SetSize(20, 20)

    ClassTrainerFrame.TrainButton:GwSkinButton(false, true)
    ClassTrainerFrame.FilterDropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, 100)
    local moneyPanel = CreateFrame("Frame", nil, ClassTrainerFrame)
    moneyPanel:SetFrameLevel(math.max(0, ClassTrainerFrame.money:GetFrameLevel() - 1))
    moneyPanel:SetPoint("TOPLEFT", ClassTrainerFrameMoneyBg, "TOPLEFT", 6, -2)
    moneyPanel:SetPoint("BOTTOMRIGHT", ClassTrainerFrameMoneyBg, "BOTTOMRIGHT", -6, 12)
    GW.AddDetailsBackground(moneyPanel)
    SkinMoneyFrame(ClassTrainerFrame.money)
    ClassTrainerFrame.trainingPoints.text:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)

    local bar = ClassTrainerStatusBar
    bar:GwStripTextures()
    bar:SetStatusBarTexture(STATUSBAR)
    bar:SetStatusBarColor(GW.Colors.FactionBarColors[4]:GetRGB())
    bar.rankText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal, "THINOUTLINE")
    GW.AddStatusBarFrame(bar)

    GW.AddDetailsBackground(ClassTrainerFrame.ScrollBox)
    GW.HandleTrimScrollBar(ClassTrainerFrame.ScrollBar)
    GW.HandleScrollControls(ClassTrainerFrame)
    hooksecurefunc(ClassTrainerFrame.ScrollBox, "Update", SkinRows)

    SkinSkillRow(ClassTrainerFrame.skillStepButton)
    ClassTrainerFrame.skillStepButton.gwSkinned = true
end

local function LoadClassTrainerSkin()
    GW.RegisterLoadHook(ApplyClassTrainerSkin, "Blizzard_TrainerUI", ClassTrainerFrame)
end
GW.LoadClassTrainerSkin = LoadClassTrainerSkin
