local _, GW = ...

local CooldownManagerFunctions = {}

function CooldownManagerFunctions:CountText(text, parent)
    text:ClearAllPoints()
    text:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -3, -3)
    text:SetJustifyH("RIGHT")
    text:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER, "OUTLINE")
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

function CooldownManagerFunctions:SkinIcon(container, icon)
    CooldownManagerFunctions:UpdateTextContainer(container)
    GW.HandleIcon(icon)

    if not icon.gwBackdrop then
        local backDrop = CreateFrame("Frame", nil, container, "GwActionButtonBackdropTmpl")
        local backDropSize = 1

        backDrop:SetPoint("TOPLEFT", icon, "TOPLEFT", -backDropSize, backDropSize)
        backDrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", backDropSize, -backDropSize)
        icon.gwBackdrop = true
    end

    for _, region in next, { container:GetRegions() } do
        if region:IsObjectType("Texture") then
            local texture = region:GetTexture()
            local atlas = region:GetAtlas()

            if texture == 6707800 then
                region:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/white")
            elseif atlas == "UI-HUD-CoolDownManager-IconOverlay" then -- 6704514
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

            if atlas == "UI-HUD-CoolDownManager-Bar" then
                region:SetPoint("TOPLEFT", 1, 0)
                region:SetPoint("BOTTOMLEFT", -1, 0)
                region:SetTexCoord(0, 1, 0, 1)
                region:SetTexture("Interface/AddOns/GW2_UI/textures/bartextures/statusbar")
            elseif atlas == "UI-HUD-CoolDownManager-Bar-BG" then
                region:GwStripTextures()
            end
        end
    end
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
        SetTimerShown = CooldownManagerFunctions.SetTimerShown
    }

    function CooldownManagerFunctions:SkinItemFrame(frame)
        if frame.Cooldown then
            frame.Cooldown:SetSwipeTexture("Interface/AddOns/GW2_UI/textures/uistuff/white")

            if not frame.Cooldown.isHooked then
                GW.RegisterCooldown(frame.Cooldown)

                for key, func in next, hookFunctions do
                    if frame[key] then
                        hooksecurefunc(frame, key, func)
                    end
                end
            end
        end

        if frame.Bar then
            CooldownManagerFunctions:SkinBar(frame, frame.Bar)
            if not frame.Bar.isHooked then
                frame.Bar.isHooked = true

                hooksecurefunc(frame, "RefreshCooldownInfo", CooldownManagerFunctions.RefreshCooldownInfo)
                frame.GwStatusBarBackground = CreateFrame("Frame", nil, frame, "GwStatusBarBackground")
                frame.GwStatusBarBackground:ClearAllPoints()
                frame.GwStatusBarBackground:SetAllPoints(frame.Bar)
                frame.GwStatusBarBackground:SetFrameStrata("BACKGROUND")
            end
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

local function ApplyCooldownManagerSkin()
    if not GW.settings.CooldownManagerSkinEnabled then return end

    CooldownManagerFunctions:HandleViewer(UtilityCooldownViewer)
    CooldownManagerFunctions:HandleViewer(BuffBarCooldownViewer)
    CooldownManagerFunctions:HandleViewer(BuffIconCooldownViewer)
    CooldownManagerFunctions:HandleViewer(EssentialCooldownViewer)
end

local function LoadCooldownManagerSkin()
    GW.RegisterLoadHook(ApplyCooldownManagerSkin, "Blizzard_CooldownViewer", BuffBarCooldownViewer)
end
GW.LoadCooldownManagerSkin = LoadCooldownManagerSkin