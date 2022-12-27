local _, GW = ...
local AFP = GW.AddProfiling
local GetSetting = GW.GetSetting

local function updateNewGlow(self)
    if self.NewOutline:IsShown() then
        self.backdrop:SetBackdropBorderColor(0, .8, 0)
    else
        self.backdrop:SetBackdropBorderColor(0, 0, 0)
    end
end
AFP("updateNewGlow", updateNewGlow)

local function HandleScrollChild(self)
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local child = select(i, self.ScrollTarget:GetChildren())
        local icon = child and child.Icon
        if icon and not icon.IsSkinned then
            GW.HandleIcon(icon)
            child.Background:Hide()
            child:CreateBackdrop(GW.constBackdropFrameColorBorder, true)

            child.DeleteButton:SkinButton(false, true)
            child.DeleteButton:SetSize(20, 20)
            child.FrameHighlight:SetInside(child.bg)
            child.FrameHighlight:SetColorTexture(1, 1, 1, .20)

            child.NewOutline:SetTexture("")
            hooksecurefunc(child, "Init", updateNewGlow)

            icon.IsSkinned = true
        end
    end
end
AFP("HandleScrollChild", HandleScrollChild)

local function spellbook_OnClick(self)
    local frame = self:GetFrame()

    if frame == SpellBookFrame then
        frame = GwCharacterWindow
    end
    if ClickBindingFrame:GetFocusedFrame() == frame then
        ClickBindingFrame:ClearFocusedFrame();
    else
        GwPaperDollDetailsFrame:Hide()
        GwReputationyDetailsFrame:Hide()
        GwCurrencyDetailsFrame:Hide()
        GwProfessionsDetailsFrame:Hide()
        GwSpellbookDetailsFrame:Show()
        ClickBindingFrame:SetFocusedFrame(frame);
    end
end
AFP("spellbook_OnClick", spellbook_OnClick)

local function ApplyClickBindingUISkin()
    if not GetSetting("BINDINGS_SKIN_ENABLED") then return end

    GW.HandlePortraitFrame(ClickBindingFrame, true)

    ClickBindingFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    ClickBindingFrame.TutorialButton.Ring:Hide()
    ClickBindingFrame.TutorialButton:SetPoint("TOPLEFT", ClickBindingFrame, "TOPLEFT", -12, 12)

    for _, v in next, { "ResetButton", "AddBindingButton", "SaveButton" } do
        ClickBindingFrame[v]:SkinButton(false, true)
    end

    GW.HandleTrimScrollBar(ClickBindingFrame.ScrollBar)
    ClickBindingFrame.ScrollBoxBackground:Hide()
    hooksecurefunc(ClickBindingFrame.ScrollBox, "Update", HandleScrollChild)

    if GetSetting("USE_SPELLBOOK_WINDOW") then
        ClickBindingFrame.SpellbookPortrait.FrameName = "GwCharacterWindow"

        ClickBindingFrame.SpellbookPortrait:SetScript("OnClick", spellbook_OnClick)

        ClickBindingFrame.SetFocusedFrame = function(_, frame)
            if frame == SpellBookFrame then frame = GwCharacterWindow end
            if (frame == ClickBindingFrame:GetFocusedFrame()) or not (frame == GwCharacterWindow or frame == MacroFrame) then
                return;
            end

            HideUIPanel(ClickBindingFrame:GetFocusedFrame());
            ClickBindingFrame.focusedFrame = frame;

            if not frame:IsShown() then
                ShowUIPanel(frame);
                if frame == GwCharacterWindow then
                    GwPaperDollDetailsFrame:Hide()
                    GwReputationyDetailsFrame:Hide()
                    GwCurrencyDetailsFrame:Hide()
                    GwProfessionsDetailsFrame:Hide()
                    GwSpellbookDetailsFrame:Show()
                end
            end

            for _, portrait in ipairs(ClickBindingFrame.FramePortraits) do
                portrait:SetSelectedState(portrait:GetFrame() == frame)
            end
        end
    end

    -- Tutorial Frame
    ClickBindingFrame.TutorialFrame.NineSlice:StripTextures()
    local titleBG = ClickBindingFrame.TutorialFrame.TitleBg or ClickBindingFrame.TutorialFrame.Bg
    if titleBG then
        titleBG:Hide()
    end

    if not ClickBindingFrame.TutorialFrame.SetBackdrop then
        Mixin(ClickBindingFrame.TutorialFrame, BackdropTemplateMixin)
        ClickBindingFrame.TutorialFrame:HookScript("OnSizeChanged", ClickBindingFrame.TutorialFrame.OnBackdropSizeChanged)
    end

    ClickBindingFrame.TutorialFrame:SetBackdrop(GW.skins.constBackdropFrame)
end
AFP("ApplyClickBindingUISkin", ApplyClickBindingUISkin)

local function LoadBindingsUISkin()
    GW.RegisterLoadHook(ApplyClickBindingUISkin, "Blizzard_ClickBindingUI", ClickBindingFrame)
end
GW.LoadBindingsUISkin = LoadBindingsUISkin