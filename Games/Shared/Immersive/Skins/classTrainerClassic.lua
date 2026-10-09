---@class GW2
local GW = select(2, ...)

-- The trainer of the classic clients (Era, TBC, Wrath, Mists): the old window with its big art, eleven fixed rows
-- and a detail pane below them; the modern clients keep classTrainer.lua
if GW.isModern then return end

local MENU_HOVER = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"

local function SkinMoneyFrame(money)
    local name = money:GetName()
    for _, coin in ipairs({"Gold", "Silver", "Copper"}) do
        local text = _G[name .. coin .. "ButtonText"]
        if text then
            GW.StyleMoneyText(text, coin)
        end
    end
end

local headerFont = CreateFont("GwClassTrainerHeaderFont")
headerFont:CopyFontObject(GameFontNormal)
headerFont:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

-- leatrix plus adds rows for its taller trainer, every update looks for new ones
local skinnedRows = {}
local function SkinRows()
    local i = 1
    while _G["ClassTrainerSkill" .. i] do
        local row = _G["ClassTrainerSkill" .. i]
        if not skinnedRows[row] then
            skinnedRows[row] = true
            GW.HookClassicCollapseTexture(row)
            _G["ClassTrainerSkill" .. i .. "Highlight"]:SetAlpha(0)
            GW.AddListItemChildHoverTexture(row)
        end
        -- blizzard gives the headers its yellow font on every update
        if row:IsShown() and select(3, GetTrainerServiceInfo(row:GetID())) == "header" then
            row:SetNormalFontObject(headerFont)
        end
        i = i + 1
    end
end

local function SkinTrainAllButton()
    local button = _G.LeaPlusGlobalTrainAllButton
    if button then
        button:GwSkinButton(false, true)
    end
end

local function UpdateSkillIcon()
    local texture = ClassTrainerSkillIcon:GetNormalTexture()
    if texture then
        texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
end

local function ApplyClassTrainerSkin()
    local frame = ClassTrainerFrame
    frame:GwStripTextures()
    ClassTrainerFramePortrait:Hide()
    ClassTrainerExpandButtonFrame:GwStripTextures()

    -- the old window draws a frame in its art, our window covers what lies inside it
    GW.CreateFrameHeaderWithBody(frame, ClassTrainerNameText, nil, nil, nil, nil, true)
    frame.gwHeader:ClearAllPoints()
    frame.gwHeader:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 10, -43)
    frame.gwHeader:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -34, -43)
    frame.tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -34, 75)
    ClassTrainerNameText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    ClassTrainerNameText:SetJustifyH("LEFT")
    frame.gwHeader.windowIcon:SetSize(48, 48)
    frame.gwHeader.windowIcon:ClearAllPoints()
    frame.gwHeader.windowIcon:SetPoint("CENTER", frame.gwHeader, "BOTTOMLEFT", 30, 19)
    frame:HookScript("OnShow", function(self)
        GW.SetHeaderPortrait(self.gwHeader, UnitExists("npc") and "npc" or "player")
        SkinTrainAllButton()
    end)

    ClassTrainerGreetingText:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    ClassTrainerGreetingText:ClearAllPoints()
    ClassTrainerGreetingText:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -52)
    ClassTrainerGreetingText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -40, -52)
    ClassTrainerGreetingText:SetHeight(14)
    ClassTrainerGreetingText:SetWordWrap(false)

    ClassTrainerFrameCloseButton:GwSkinButton(true)
    ClassTrainerFrameCloseButton:SetSize(20, 20)
    ClassTrainerFrameCloseButton:ClearAllPoints()
    ClassTrainerFrameCloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -39, -16)
    ClassTrainerTrainButton:GwSkinButton(false, true)
    ClassTrainerCancelButton:GwSkinButton(false, true)
    if frame.FilterDropdown then
        frame.FilterDropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true, nil, 100)
    end

    -- list and details: our scroll bars, our arrows on the headers, our hover and selection;
    -- the row colors stay blizzards, they tell what can be learned
    for _, scrollFrame in ipairs({ClassTrainerListScrollFrame, ClassTrainerDetailScrollFrame}) do
        scrollFrame:GwStripTextures()
        _G[scrollFrame:GetName() .. "ScrollBar"]:GwSkinScrollBar()
        scrollFrame:GwSkinScrollFrame()
    end
    ScrollFrame_OnScrollRangeChanged(ClassTrainerDetailScrollFrame)
    -- the list bg also holds the collapse all row and the filter, the rows keep some space to its edge
    local listBg = GW.CreateDetailsBackgroundTexture(frame)
    listBg:SetPoint("TOPLEFT", ClassTrainerExpandButtonFrame, "TOPLEFT", 0, 0)
    listBg:SetPoint("BOTTOMRIGHT", ClassTrainerListScrollFrame, "BOTTOMRIGHT", 24, -4)
    local detailBg = GW.CreateDetailsBackgroundTexture(frame)
    detailBg:SetPoint("TOPLEFT", listBg, "BOTTOMLEFT", 0, -4)
    detailBg:SetPoint("BOTTOMRIGHT", ClassTrainerDetailScrollFrame, "BOTTOMRIGHT", 24, -4)
    SkinRows()
    hooksecurefunc("ClassTrainerFrame_Update", SkinRows)
    ClassTrainerSkillHighlight:SetTexture(MENU_HOVER)

    GW.HookClassicCollapseTexture(ClassTrainerCollapseAllButton)
    ClassTrainerCollapseAllButton:ClearHighlightTexture()
    ClassTrainerCollapseAllButton:GetFontString():GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    ClassTrainerCollapseAllButton:GetFontString():GwLockTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    ClassTrainerSkillIcon:GwStripTextures()
    ClassTrainerSkillIcon:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
    ClassTrainerSkillIcon.backdrop:SetBackdropBorderColor(GW.Colors.SkinColors.IconBorder:GetRGBA())
    hooksecurefunc("ClassTrainer_SetSelection", UpdateSkillIcon)
    ClassTrainerSkillName:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    ClassTrainerSkillName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    ClassTrainerCostLabel:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    ClassTrainerSkillDescription:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
    SkinMoneyFrame(ClassTrainerDetailMoneyFrame)
    SkinMoneyFrame(ClassTrainerMoneyFrame)
end

local function LoadClassTrainerSkin()
    if not GW.settings.skins.classTrainer.enabled then return end
    GW.RegisterLoadHook(ApplyClassTrainerSkin, "Blizzard_TrainerUI", ClassTrainerFrame)
end
GW.LoadClassTrainerSkin = LoadClassTrainerSkin
