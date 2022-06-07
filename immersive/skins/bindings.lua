local _, GW = ...
local constBackdropFrameBorder = GW.skins.constBackdropFrameBorder
local AFP = GW.AddProfiling

local function keybind_OnDragStart(self)
    self.moving = true
    self:GetParent():StartMoving()
end
AFP("keybind_OnDragStart", keybind_OnDragStart)

local function keybind_OnDragStop(self)
    self.moving = nil
    self:GetParent():StopMovingOrSizing()
end
AFP("keybind_OnDragStop", keybind_OnDragStop)

local function keybind_OnShow(self)
    MultiBarRight.QuickKeybindGlow:Hide()
    MultiBarLeft.QuickKeybindGlow:Hide()
    MultiBarBottomRight.QuickKeybindGlow:Hide()
    MultiBarBottomLeft.QuickKeybindGlow:Hide()
end
AFP("keybind_OnShow", keybind_OnShow)

local function hook_SetupBinding(_, button)
    button:SkinButton(false, true)
end
AFP("hook_SetupBinding", hook_SetupBinding)

local function hook_SetSelected(keyBindingButton, isSelected)
    keyBindingButton.selectedHighlight:SetAlpha(0)
    if isSelected then
        keyBindingButton:SetScript("OnEnter", nil)
        keyBindingButton:SetScript("OnLeave", nil)
    else
        keyBindingButton:SetScript("OnEnter", GwStandardButton_OnEnter)
        keyBindingButton:SetScript("OnLeave", GwStandardButton_OnLeave)
        GwStandardButton_OnLeave(keyBindingButton)
    end
end
AFP("hook_SetSelected", hook_SetSelected)

local function ApplyBindingsUISkin()
    if not GW.GetSetting("BINDINGS_SKIN_ENABLED") then return end

    local buttons = {
        "defaultsButton",
        "unbindButton",
        "okayButton",
        "cancelButton",
        "quickKeybindButton",
        "clickCastingButton"
    }

    for _, v in pairs(buttons) do
        KeyBindingFrame[v]:SkinButton(false, true)
    end

    KeyBindingFrame.Header.CenterBG:Hide()
    KeyBindingFrame.Header.RightBG:Hide()
    KeyBindingFrame.Header.LeftBG:Hide()
    KeyBindingFrame.Header.Text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    KeyBindingFrame.BG:Hide()
    local tex = KeyBindingFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", KeyBindingFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = KeyBindingFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    KeyBindingFrame.tex = tex

    KeyBindingFrameCategoryList:StripTextures()
    KeyBindingFrameCategoryList:CreateBackdrop(constBackdropFrameBorder)
    KeyBindingFrame.bindingsContainer:StripTextures()
    KeyBindingFrame.bindingsContainer:CreateBackdrop(constBackdropFrameBorder)

    KeyBindingFrame.characterSpecificButton:SkinCheckButton()
    KeyBindingFrame.characterSpecificButton:SetSize(15, 15)

    KeyBindingFrameScrollFrame:SkinScrollFrame()
    KeyBindingFrameScrollFrameScrollBar:SkinScrollBar()

    hooksecurefunc("BindingButtonTemplate_SetupBindingButton", hook_SetupBinding)

    hooksecurefunc("BindingButtonTemplate_SetSelected", hook_SetSelected)

    -- QuickKeybind
    QuickKeybindFrame:StripTextures()
    QuickKeybindFrame.Header:StripTextures()
    QuickKeybindFrame.Header.Text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    QuickKeybindFrame.characterSpecificButton:SkinCheckButton()
    QuickKeybindFrame.characterSpecificButton:SetSize(13, 13)

    local tex = QuickKeybindFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", QuickKeybindFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = QuickKeybindFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    QuickKeybindFrame.tex = tex

    local buttons = {"okayButton", "defaultsButton", "cancelButton"}
    for _, v in pairs(buttons) do
        QuickKeybindFrame[v]:SkinButton(false, true)
    end

    QuickKeybindFrame:HookScript("OnShow", keybind_OnShow)

    -- make the frame movable (maybe someone have a actionbar behinde that frame)
    QuickKeybindFrame:SetClampedToScreen(true)
    QuickKeybindFrame.Header:EnableMouse(true)
    QuickKeybindFrame.Header:RegisterForDrag("LeftButton")

    QuickKeybindFrame.Header:SetScript("OnDragStart", keybind_OnDragStart)

    QuickKeybindFrame.Header:SetScript("OnDragStop", keybind_OnDragStop)
end
AFP("ApplyBindingsUISkin", ApplyBindingsUISkin)

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
        GwTalentDetailsFrame:Show()
        ClickBindingFrame:SetFocusedFrame(frame);
    end
end
AFP("spellbook_OnClick", spellbook_OnClick)

local function ApplyClickBindingUISkin()
    if not GW.GetSetting("BINDINGS_SKIN_ENABLED") then return end

    GW.HandlePortraitFrame(ClickBindingFrame, true)

    ClickBindingFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    ClickBindingFrame.TutorialButton.Ring:Hide()
    ClickBindingFrame.TutorialButton:SetPoint("TOPLEFT", ClickBindingFrame, "TOPLEFT", -12, 12)

    for _, v in next, { "ResetButton", "AddBindingButton", "SaveButton" } do
        ClickBindingFrame[v]:SkinButton(false, true)
    end

    ClickBindingFrame.ScrollBar:HandleTrimScrollBar()
    ClickBindingFrame.ScrollBoxBackground:Hide()
    hooksecurefunc(ClickBindingFrame.ScrollBox, "Update", HandleScrollChild)

    if GW.GetSetting("USE_TALENT_WINDOW") then
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
                    GwTalentDetailsFrame:Show()
                end
            end

            for _, portrait in ipairs(ClickBindingFrame.FramePortraits) do
                portrait:SetSelectedState(portrait:GetFrame() == frame)
            end
        end
    end

    -- Tutorial Frame
    ClickBindingFrame.TutorialFrame.NineSlice:StripTextures()
    ClickBindingFrame.TutorialFrame.TitleBg:Hide()

    if not ClickBindingFrame.TutorialFrame.SetBackdrop then
        Mixin(ClickBindingFrame.TutorialFrame, BackdropTemplateMixin)
        ClickBindingFrame.TutorialFrame:HookScript("OnSizeChanged", ClickBindingFrame.TutorialFrame.OnBackdropSizeChanged)
    end

    ClickBindingFrame.TutorialFrame:SetBackdrop(GW.skins.constBackdropFrame)

    ClickBindingFrame.TutorialFrame.CloseButton:SkinButton(true)
    ClickBindingFrame.TutorialFrame.CloseButton:SetSize(20, 20)
end
AFP("ApplyClickBindingUISkin", ApplyClickBindingUISkin)

local function LoadBindingsUISkin()
    GW.RegisterLoadHook(ApplyBindingsUISkin, "Blizzard_BindingUI", KeyBindingFrame)
    GW.RegisterLoadHook(ApplyClickBindingUISkin, "Blizzard_ClickBindingUI", ClickBindingFrame)
end
GW.LoadBindingsUISkin = LoadBindingsUISkin