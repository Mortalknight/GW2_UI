local _, GW = ...
local GetSetting = GW.GetSetting

local function SkinInspectFrameOnLoad()
    if not GetSetting("INSPECTION_SKIN_ENABLED") then return end

    local w, h = InspectFrame:GetSize()
    InspectFrame:GwStripTextures()
    InspectFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")
    InspectFrameCloseButton:GwSkinButton(true)
    InspectFrameCloseButton:SetSize(20, 20)
    InspectPaperDollFrame.ViewButton:GwSkinButton(false, true)
    if not InspectFrame.tex then
        local tex = InspectFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
        tex:SetPoint("TOP", InspectFrame, "TOP", 0, 20)
        tex:SetSize(w + 50, h + 70)
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
        InspectFrame.tex = tex
    else
        InspectFrame.tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    end

    InspectFrame.mover = CreateFrame("Frame", nil, InspectFrame)
    InspectFrame.mover:EnableMouse(true)
    InspectFrame:SetMovable(true)
    InspectFrame.mover:SetSize(w, 30)
    InspectFrame.mover:SetPoint("BOTTOMLEFT", InspectFrame, "TOPLEFT", 0, -20)
    InspectFrame.mover:SetPoint("BOTTOMRIGHT", InspectFrame, "TOPRIGHT", 0, 20)
    InspectFrame.mover:RegisterForDrag("LeftButton")
    InspectFrame:SetClampedToScreen(true)
    InspectFrame.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    InspectFrame.mover:SetScript("OnDragStop", function(self)
        local self = self:GetParent()

        self:StopMovingOrSizing()
    end)

    for i = 1, 3 do
        GW.HandleTabs(_G["InspectFrameTab" .. i], true)
        _G["InspectFrameTab" .. i]:SetSize(80, 24)
        if i > 1 then
            _G["InspectFrameTab" .. i]:ClearAllPoints()
            _G["InspectFrameTab" .. i]:SetPoint("RIGHT",  _G["InspectFrameTab" .. i - 1], "RIGHT", 75, 0)
        end
    end

    hooksecurefunc("PanelTemplates_SelectTab", function(tab)
        local name = tab:GetName()
        local text = tab.Text or _G[name .. "Text"]
        text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 2))
    end)

    InspectModelFrame:GwStripTextures()
    InspectModelFrameBorderTopLeft:GwKill()
    InspectModelFrameBorderTopRight:GwKill()
    InspectModelFrameBorderTop:GwKill()
    InspectModelFrameBorderLeft:GwKill()
    InspectModelFrameBorderRight:GwKill()
    InspectModelFrameBorderBottomLeft:GwKill()
    InspectModelFrameBorderBottomRight:GwKill()
    InspectModelFrameBorderBottom:GwKill()
    InspectModelFrameBorderBottom2:GwKill()

    InspectPaperDollItemsFrame.InspectTalents:GwSkinButton(false, true)

    InspectModelFrame.BackgroundOverlay:SetColorTexture(0, 0, 0)

    -- Give inspect frame model backdrop it's color back
    for _, corner in pairs({"TopLeft","TopRight","BotLeft","BotRight"}) do
        local bg = _G["InspectModelFrameBackground" .. corner]
        if bg then
            bg:SetDesaturated(false)
            hooksecurefunc(bg, "SetDesaturated", function(bckgnd, value)
                if value and bckgnd.ignoreDesaturated then
                    bckgnd:SetDesaturated(false)
                end
            end)
        end
    end

    for _, Slot in pairs({InspectPaperDollItemsFrame:GetChildren()}) do
        if Slot:IsObjectType("Button") or Slot:IsObjectType("ItemButton") then
            if not Slot.icon then return end
            GW.HandleIcon(Slot.icon, true, GW.BackdropTemplates.DefaultWithColorableBorder)

            Slot.icon.backdrop:SetFrameLevel(Slot:GetFrameLevel())
            Slot.icon:GwSetInside()
            Slot:GwStripTextures()
            GW.HandleIconBorder(Slot.IconBorder, Slot.icon.backdrop)
        end
    end

    InspectPVPFrame.BG:GwKill()
    InspectGuildFrameBG:GwKill()
end

local function LoadInspectFrameSkin()
    GW.RegisterLoadHook(SkinInspectFrameOnLoad, "Blizzard_InspectUI", InspectFrame)
end
GW.LoadInspectFrameSkin = LoadInspectFrameSkin
