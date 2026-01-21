local _, GW = ...

local CooldownManagerFunctions = {}

local function updateCollapse(self, collapsed)
    if collapsed then
        self.Icon:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        self.Icon:SetRotation(1.570796325)
    else
        self.Icon:SetTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
        self.Icon:SetRotation(0)
    end
end

local function updateTextColor(self, r, g, b)
    if r ~= 1 or g ~= 1 or b ~= 1 then
        self:SetTextColor(1, 1, 1)
    end
end

local function SkinHeaders(header)
    if header.IsSkinned then return end

    if header.HighlightMiddle then header.HighlightMiddle:SetAlpha(0) end
    if header.HighlightLeft then header.HighlightLeft:SetAlpha(0) end
    if header.HighlightRight then header.HighlightRight:SetAlpha(0) end
    if header.Middle then header.Middle:Hide() end
    if header.Left then header.Left:Hide() end
    if header.Right then header.Right:Hide() end

    header:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly)
    header.backdrop:SetBackdropBorderColor(1, 1, 1, 0.2)
    header:SetNormalTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
    header:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/bag/bag-sep.png")
    header:GetHighlightTexture():SetColorTexture(1, 0.93, 0.73, 0.25)

    header:GetNormalTexture():ClearAllPoints()
    header:GetNormalTexture():SetPoint("TOPLEFT", header, "TOPLEFT", 1, -1)
    header:GetNormalTexture():SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -1, 1)

    header:GetHighlightTexture():ClearAllPoints()
    header:GetHighlightTexture():SetPoint("TOPLEFT", header, "TOPLEFT", 1, -1)
    header:GetHighlightTexture():SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -1, 1)

    header.Name:SetTextColor(1, 1, 1)
    header.Icon = header:CreateTexture(nil, "ARTWORK")
    header.Icon:SetSize(16, 16)
    header.Icon:SetPoint("RIGHT", header, "RIGHT", -4, 0)
    updateCollapse(header, false)
    hooksecurefunc(header, "UpdateCollapsedState", updateCollapse)
    hooksecurefunc(header.Name, "SetTextColor", updateTextColor)

    header.IsSkinned = true
end

function CooldownManagerFunctions:CountText(text, parent)
    text:ClearAllPoints()
    text:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    text:SetJustifyH("RIGHT")
    text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL, "OUTLINE")
    text:SetTextColor(1, 1, 0.6)
end

function CooldownManagerFunctions:UpdateTextContainer(container)
    local countText = container.Applications and container.Applications.Applications
    if countText then
        CooldownManagerFunctions:CountText(countText, container)
    end

    local chargeText = container.ChargeCount and container.ChargeCount.Current
    if chargeText then
        CooldownManagerFunctions:CountText(chargeText, container)
    end
end

function CooldownManagerFunctions:UpdateTextBar(bar)
    if bar.Name then
        bar.Name:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        bar.Name:SetShadowColor(0, 0, 0, 1)
        bar.Name:SetShadowOffset(1, -1)
    end

    if bar.Duration then
        bar.Duration:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.NORMAL)
        bar.Duration:SetShadowColor(0, 0, 0, 1)
        bar.Duration:SetShadowOffset(1, -1)
    end
end

--TODO
function CooldownManagerFunctions:RefreshIconBorder()
    if self.DebuffBorder then
        self.DebuffBorder.Texture:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
	end
end

function CooldownManagerFunctions:SkinIcon(container, icon)
    CooldownManagerFunctions:UpdateTextContainer(container)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    if not icon.gwBackdrop then
        local backDrop = CreateFrame("Frame", nil, container, "GwActionButtonBackdropTmpl")
        local backDropSize = 1

        backDrop:SetPoint("TOPLEFT", container, "TOPLEFT", -backDropSize, backDropSize)
        backDrop:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", backDropSize, -backDropSize)

        container.gwBackdrop = backDrop
    end

    container.gwBackdrop.bg:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
    container.gwBackdrop.border1:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
    container.gwBackdrop.border2:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
    container.gwBackdrop.border3:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))
    container.gwBackdrop.border4:SetAlpha(tonumber(GW.settings.ACTIONBAR_BACKGROUND_ALPHA))

    for _, region in next, { container:GetRegions() } do
        if region:IsObjectType("Texture") then
            local texture = region:GetTexture()
            local atlas = region:GetAtlas()

            if GW.NotSecretValue(texture) and texture == 6707800 then
                region:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/white.png")
            elseif GW.NotSecretValue(atlas) and atlas == "UI-HUD-CoolDownManager-IconOverlay" then -- 6704514
                region:SetAlpha(0)
            end
        end
    end
end

function CooldownManagerFunctions:RefreshCooldownInfo()
    local pipTexture = self:GetPipTexture()
    pipTexture:Hide()
end

function CooldownManagerFunctions:SkinBar(frame, bar)
    CooldownManagerFunctions:UpdateTextBar(bar)

    if frame.Icon then
        bar:SetPoint("LEFT", frame.Icon, "RIGHT", 2, 0)

        CooldownManagerFunctions:SkinIcon(frame.Icon, frame.Icon.Icon)
    end

    for _, region in next, { bar:GetRegions() } do
        if region:IsObjectType("Texture") then
            local atlas = region:GetAtlas()

            if atlas == "UI-HUD-CoolDownManager-Bar-BG" then
                region:SetAlpha(0)
                frame.GwStatusBarBackground = CreateFrame("Frame", nil, frame, "GwStatusBarBackground")
                frame.GwStatusBarBackground:ClearAllPoints()
                frame.GwStatusBarBackground:SetAllPoints(frame.Bar)
                frame.GwStatusBarBackground:SetFrameStrata("BACKGROUND")
                break
            end
        end
    end

    local barTex = bar:GetStatusBarTexture()
    barTex:SetTexCoord(0, 1, 0, 1)
    barTex:SetVertexColor(1, 1, 1, 1)
    barTex:ClearAllPoints()
    barTex:GwSetInside(frame.GwStatusBarBackground)
    bar:SetStatusBarTexture("Interface/AddOns/GW2_UI/textures/bartextures/rage.png")

    bar.Pip:SetHeight(bar:GetHeight())
    bar.Pip:SetTexCoord(0, 1, 0, 1)
    bar.Pip:SetWidth(6)
    bar.Pip:SetBlendMode("BLEND")
    bar.Pip:SetTexture("Interface/AddOns/GW2_UI/textures/bartextures/ragespark.png")
end

function CooldownManagerFunctions:RefreshSpellCooldownInfo()
    if not self.Cooldown then return end
    self.Cooldown:SetSwipeColor(0, 0, 0, 1)
end

function CooldownManagerFunctions:SetTimerShown()
    if self.Cooldown then
        GW.ToggleBlizzardCooldownText(self.Cooldown, self.Cooldown.timer)
    end
end

do
    local hookFunctions = {
        RefreshSpellCooldownInfo = CooldownManagerFunctions.RefreshSpellCooldownInfo,
        SetTimerShown = CooldownManagerFunctions.SetTimerShown,
        RefreshIconBorder = CooldownManagerFunctions.RefreshIconBorder
    }

    function CooldownManagerFunctions:SkinItemFrame(frame)
        if frame.Cooldown then
            frame.Cooldown:SetSwipeTexture("Interface/AddOns/GW2_UI/textures/uistuff/white.png")

            if not frame.Cooldown.isHooked then
                for key, func in next, hookFunctions do
                    if frame[key] then
                        hooksecurefunc(frame, key, func)
                    end
                end
            end
        end

        if frame.Bar then
            CooldownManagerFunctions:SkinBar(frame, frame.Bar)
        elseif frame.Icon then
            CooldownManagerFunctions:SkinIcon(frame, frame.Icon)
        end
    end
end

function CooldownManagerFunctions:AcquireItemFrame(frame)
    CooldownManagerFunctions:SkinItemFrame(frame)
end

function CooldownManagerFunctions:HandleViewer(element)
    hooksecurefunc(element, "OnAcquireItemFrame", CooldownManagerFunctions.AcquireItemFrame)

    for frame in element.itemFramePool:EnumerateActive() do
        CooldownManagerFunctions:SkinItemFrame(frame)
    end
end

function CooldownManagerFunctions:SkinCategoryHeaders()
    if not CooldownViewerSettings or not CooldownViewerSettings.CooldownScroll then return end

    local content = CooldownViewerSettings.CooldownScroll.Content
    if not content then return end

    for _, child in next, { content:GetChildren() } do
        if child.Header then
            SkinHeaders(child.Header)
        end
    end
end

local function ApplyCooldownManagerSkin()
    if not GW.settings.CooldownManagerSkinEnabled then return end

    CooldownManagerFunctions:HandleViewer(UtilityCooldownViewer)
    CooldownManagerFunctions:HandleViewer(BuffBarCooldownViewer)
    CooldownManagerFunctions:HandleViewer(BuffIconCooldownViewer)
    CooldownManagerFunctions:HandleViewer(EssentialCooldownViewer)

    if CooldownViewerSettings then
        GW.HandlePortraitFrame(CooldownViewerSettings)
        GW.CreateFrameHeaderWithBody(CooldownViewerSettings, CooldownViewerSettings.TitleContainer.TitleText, "Interface/AddOns/GW2_UI/textures/character/addon-window-icon.png", {CooldownViewerSettings.CooldownScroll}, nil, nil, true)

        GW.SkinTextBox(CooldownViewerSettings.SearchBox.Middle, CooldownViewerSettings.SearchBox.Left, CooldownViewerSettings.SearchBox.Right)
        GW.HandleTrimScrollBar(CooldownViewerSettings.CooldownScroll.ScrollBar)
        GW.HandleScrollControls(CooldownViewerSettings.CooldownScroll)
        CooldownViewerSettings.UndoButton:GwSkinButton(false, true)
        CooldownViewerSettings.LayoutDropdown:GwHandleDropDownBox()

        local lastTab = nil
        for i, tab in next, { CooldownViewerSettings.SpellsTab, CooldownViewerSettings.AurasTab } do
            GW.HandleTabs(tab, "right", {tab.Icon}, true)
            if i > 1 then
                tab:ClearAllPoints()
                tab:SetPoint("TOP", lastTab, "BOTTOM", 0, 1)
            else
                tab:ClearAllPoints()
                tab:SetPoint("TOPLEFT", CooldownViewerSettings, "TOPRIGHT", 0, -30)
            end
            lastTab = tab
        end
        CooldownManagerFunctions:SkinCategoryHeaders()
        hooksecurefunc(CooldownViewerSettings, 'RefreshLayout', CooldownManagerFunctions.SkinCategoryHeaders)
    end
end

local function LoadCooldownManagerSkin()
    GW.RegisterLoadHook(ApplyCooldownManagerSkin, "Blizzard_CooldownViewer", BuffBarCooldownViewer)
end
GW.LoadCooldownManagerSkin = LoadCooldownManagerSkin