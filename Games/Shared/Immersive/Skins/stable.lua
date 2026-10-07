---@class GW2
local GW = select(2, ...)

-- the hunter stable, four builds: retail (StableFrame), Forever (PetStableFrame of Blizzard_StableUI),
-- Mists (paged PetStableFrame) and Era, TBC and Wrath (the old PetStableFrame with its big art)
local MENU_BG = "Interface/AddOns/GW2_UI/textures/character/menu-bg.png"
local MENU_HOVER = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"
local ARROW = "Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_down.png"
local STATUSBAR = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png"
local CHECKED = "Interface/AddOns/GW2_UI/textures/uistuff/ui-quickslot-depress.png"

local function GetTitle(frame)
    return frame.TitleContainer and frame.TitleContainer.TitleText or frame.TitleText or _G[frame:GetName() .. "TitleText"]
end

-- header with the stable master as portrait
local function SkinWindow(frame, title)
    GW.CreateFrameHeaderWithBody(frame, title, nil, nil, nil, nil, true)
    title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)
    title:SetJustifyH("LEFT")
    frame.gwHeader.windowIcon:SetSize(48, 48)
    frame.gwHeader.windowIcon:ClearAllPoints()
    frame.gwHeader.windowIcon:SetPoint("CENTER", frame.gwHeader, "BOTTOMLEFT", 30, 19)
    frame:HookScript("OnShow", function(self)
        GW.SetHeaderPortrait(self.gwHeader, "npc")
    end)
end

local function SkinTemplateWindow(frame)
    GW.HandlePortraitFrame(frame)
    GW.HandlePortraitFrameArt(frame)
    local title = GetTitle(frame)
    if frame.TitleContainer then
        frame.TitleContainer:Hide()
    end
    SkinWindow(frame, title)
end

local function SkinInset(inset)
    if inset.NineSlice then
        inset.NineSlice:Hide()
    end
    if inset.Bg then
        inset.Bg:Hide()
    end
    GW.AddDetailsBackground(inset)
end

local function SkinSlot(button)
    GW.HandleItemButton(button, true)
    -- mists marks the selected pet with a texture of its own
    if button.Checked then
        button.Checked:SetTexture(CHECKED)
        button.Checked:SetAllPoints()
    end
end

-- the number of slots differs from client to client, the buttons are named after their place
local function SkinSlots(prefix)
    local i = 1
    while _G[prefix .. i] do
        SkinSlot(_G[prefix .. i])
        i = i + 1
    end
end

local function SkinStatusBar(bar)
    bar:GwStripTextures()
    bar:SetStatusBarTexture(STATUSBAR)
    GW.AddStatusBarFrame(bar)
end

-- retail: the list of stabled pets
local function SkinCategoryRow(row)
    row.LeftPiece:SetAlpha(0)
    row.RightPiece:SetAlpha(0)
    row.CenterPiece:SetAlpha(0)
    row.CollapseIconAlphaAdd:SetAlpha(0)

    local background = row:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetTexture(MENU_BG)
    row.Label:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    row.Label:GwLockTextColor(GW.Colors.TextColors.LightHeader:GetRGB())

    row.CollapseIcon:SetSize(16, 16)
    hooksecurefunc(row.CollapseIcon, "SetAtlas", function(self, atlas)
        self:SetTexture(ARROW)
        self:SetRotation(atlas and atlas:find("expand") and math.pi / 2 or 0)
    end)
end

local function SkinPetRow(row)
    row.Background:SetAlpha(0)
    row.Selected:SetTexture(MENU_HOVER)
    row.Selected:SetVertexColor(GW.Colors.SkinColors.ListSelected:GetRGBA())
    row.Highlight:SetTexture(MENU_HOVER)
    row.Highlight:SetVertexColor(GW.Colors.SkinColors.ListHover:GetRGBA())
    row.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Normal)
    row.Type:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)
end

local skinnedRows = {}
local function SkinRows(scrollBox)
    scrollBox:ForEachFrame(function(row)
        if skinnedRows[row] then return end
        skinnedRows[row] = true
        if row.CollapseIcon then
            SkinCategoryRow(row)
        elseif row.Selected then
            SkinPetRow(row)
        end
    end)
end

local skinnedAbilities = {}
local function SkinAbilities(list)
    for ability in list.abilityPool:EnumerateActive() do
        if not skinnedAbilities[ability] then
            skinnedAbilities[ability] = true
            GW.HandleIcon(ability.Icon, true)
        end
    end
end

local function SkinRetailStable()
    local frame = StableFrame
    SkinTemplateWindow(frame)
    frame.MainHelpButton:Hide()
    frame.StableTogglePetButton:GwSkinButton(false, true)
    frame.ReleasePetButton:GwSkinButton(false, true)

    local modelScene = frame.PetModelScene
    modelScene.Inset:SetAlpha(0)
    GW.HandleModelSceneControlFrame(modelScene.ControlFrame)
    modelScene.PetInfo.Specialization:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true)
    hooksecurefunc(modelScene.AbilitiesList, "Layout", SkinAbilities)

    local list = frame.StabledPetList
    list.Backgroud:Hide()
    SkinInset(list.Inset)
    list.ListName:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader)
    list.ListName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    -- the counter is a small inset of its own, its paw icon stays
    for _, key in ipairs({"BorderTopLeft", "BorderTopRight", "BorderBottomLeft", "BorderBottomRight", "BorderLeftMiddle", "BorderRightMiddle"}) do
        list.ListCounter[key]:Hide()
    end
    GW.HandleTrimScrollBar(list.ScrollBar)
    GW.HandleScrollControls(list)
    list.ScrollBar:SetHideIfUnscrollable(true)
    hooksecurefunc(list.ScrollBox, "Update", SkinRows)

    local filterBar = list.FilterBar
    GW.SkinBagSearchBox(filterBar.SearchBox)
    filterBar.FilterDropdown:GwHandleDropDownBox(GW.BackdropTemplates.DopwDown, true)

    local activeList = frame.ActivePetList
    activeList.ActivePetListBG:SetAlpha(0)
    activeList.ActivePetListBGBar:SetAlpha(0)
    activeList.ListName:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.Header)
    activeList.ListName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
end

local function SkinForeverStable()
    local frame = PetStableFrame
    SkinTemplateWindow(frame)
    frame.purchaseButton:GwSkinButton(false, true)

    local modelScene = frame.modelScene
    modelScene.Inset:SetAlpha(0)
    GW.HandleModelSceneControlFrame(modelScene.ControlFrame)
    SkinStatusBar(frame.expBar.StatusBar)
    frame.expBar.overlay:GwStripTextures()

    SkinSlot(PetStableCurrentPet)
    SkinSlots("PetStableStabledPet")
    PetStableMoneyFrame.Border:SetAlpha(0)
end

local function SkinMistsStable()
    local frame = PetStableFrame
    SkinTemplateWindow(frame)
    PetStableFrameModelBg:Hide()
    PetStableActiveBg:Hide()
    PetStableFrameStableBg:Hide()
    SkinInset(PetStableLeftInset)
    SkinInset(PetStableBottomInset)
    GW.HandleModelSceneControlFrame(PetStableModelScene.ControlFrame)
    GW.HandleIcon(PetStableSelectedPetIcon, true)

    SkinSlots("PetStableActivePet")
    SkinSlots("PetStableStabledPet")
end

-- the old window draws a frame in its art, our window covers what lies inside it
local function SkinClassicStable()
    local frame = PetStableFrame
    frame:GwStripTextures()
    PetStableFramePortrait:Hide()
    SkinWindow(frame, PetStableTitleLabel)
    frame.gwHeader:ClearAllPoints()
    frame.gwHeader:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 10, -43)
    frame.gwHeader:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -34, -43)
    frame.tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -34, 75)

    PetStableFrameCloseButton:GwSkinButton(true)
    PetStableFrameCloseButton:SetSize(20, 20)
    PetStableFrameCloseButton:ClearAllPoints()
    PetStableFrameCloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -39, -16)
    PetStablePurchaseButton:GwSkinButton(false, true)

    -- the button named right sits on the left and turns the model to the left
    GW.HandleClassicRotateButton(PetStableModelRotateRightButton, "left")
    GW.HandleClassicRotateButton(PetStableModelRotateLeftButton, "right")

    SkinSlot(PetStableCurrentPet)
    SkinSlots("PetStableStabledPet")
end

local function LoadStableSkin()
    if not GW.settings.skins.stable.enabled then return end

    if GW.Retail then
        GW.RegisterLoadHook(SkinRetailStable, "Blizzard_StableUI", StableFrame)
    elseif GW.Forever then
        GW.RegisterLoadHook(SkinForeverStable, "Blizzard_StableUI", PetStableFrame)
    elseif GW.Mists then
        GW.RegisterLoadHook(SkinMistsStable, "Blizzard_UIPanels_Game", PetStableFrame)
    else
        GW.RegisterLoadHook(SkinClassicStable, "Blizzard_UIPanels_Game", PetStableFrame)
    end
end
GW.LoadStableSkin = LoadStableSkin
