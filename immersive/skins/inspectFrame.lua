local _, GW = ...

local function Update_InspectPaperDollItemSlotButton(button)
    local unit = button.hasItem and InspectFrame.unit
    local quality = unit and GetInventoryItemQuality(unit, button:GetID())
    if quality and quality > 1 then
        local r, g, b = C_Item.GetItemQualityColor(quality)
        button.backdrop:SetBackdropBorderColor(r, g, b)
        return
    end

    button.backdrop:SetBackdropBorderColor(1, 1, 1, 1)
end

local function SkinInspectFrameOnLoad()
    if not GW.settings.INSPECTION_SKIN_ENABLED then return end

    GW.CreateFrameHeaderWithBody(InspectFrame, InspectNameText, "Interface/AddOns/GW2_UI/textures/character/addon-window-icon", {}, 20)
    InspectFrame.gwHeader.windowIcon:SetSize(65, 65)
    InspectFrame.gwHeader.windowIcon:ClearAllPoints()
    InspectFrame.gwHeader.windowIcon:SetPoint("CENTER", InspectFrame.gwHeader.BGLEFT, "LEFT", 25, -5)

    InspectFrameCloseButton:GwSkinButton(true)
    InspectFrameCloseButton:SetSize(20, 20)
    InspectFrameCloseButton:SetPoint("TOPRIGHT", -5, -5)
    InspectFramePortrait:Hide()
    InspectNameText:SetWidth(250)
    InspectLevelText:ClearAllPoints()
    InspectLevelText:SetPoint("TOP", InspectNameText, "BOTTOM", 0, -10)

    hooksecurefunc("InspectFrame_UnitChanged", function(self)
        SetPortraitTexture(InspectFrame.gwHeader.windowIcon, self.unit);
    end)

    InspectFrame:HookScript("OnShow", function(self)
        SetPortraitTexture(InspectFrame.gwHeader.windowIcon, self.unit);
    end)

    for i = 1, 3 do
        GW.HandleTabs(_G["InspectFrameTab" .. i], true)
        _G["InspectFrameTab" .. i]:SetSize(80, 24)
        if i > 1 then
            _G["InspectFrameTab" .. i]:ClearAllPoints()
            _G["InspectFrameTab" .. i]:SetPoint("RIGHT",  _G["InspectFrameTab" .. i - 1], "RIGHT", 75, 0)
        end
    end

    _G.InspectPaperDollFrame:GwStripTextures()

    InspectFrame.mover = CreateFrame("Frame", nil, InspectFrame)
    InspectFrame.mover:EnableMouse(true)
    InspectFrame:SetMovable(true)
    InspectFrame.mover:SetSize(InspectFrame:GetWidth(), 30)
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

    for _, slot in ipairs({InspectPaperDollItemsFrame:GetChildren()}) do
        local icon = _G[slot:GetName() .. "IconTexture"]
        local cooldown = _G[slot:GetName() .. "Cooldown"]

        slot:GwStripTextures()
        slot:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
        slot.backdrop:SetAllPoints()
        slot:SetFrameLevel(slot:GetFrameLevel() + 2)
        slot:GwStyleButton()

        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        icon:GwSetInside()

        if cooldown then
            GW.RegisterCooldown(cooldown)
        end
    end

    hooksecurefunc("InspectPaperDollItemSlotButton_Update", Update_InspectPaperDollItemSlotButton)
    hooksecurefunc("PanelTemplates_SelectTab", function(tab)
        local name = tab:GetName()
        local text = tab.Text or _G[name .. "Text"]
        text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 2))
    end)

    GW.HandleRotateButton(_G.InspectModelFrameRotateLeftButton)
    _G.InspectModelFrameRotateLeftButton:SetPoint("TOPLEFT", 3, -3)
    _G.InspectModelFrameRotateLeftButton:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
    _G.InspectModelFrameRotateLeftButton:GetNormalTexture():SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
    _G.InspectModelFrameRotateLeftButton:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
    _G.InspectModelFrameRotateLeftButton:GetPushedTexture():SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0)

    GW.HandleRotateButton(_G.InspectModelFrameRotateRightButton)
    _G.InspectModelFrameRotateRightButton:SetPoint("TOPLEFT", _G.InspectModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)
    _G.InspectModelFrameRotateRightButton:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
    _G.InspectModelFrameRotateRightButton:GetNormalTexture():SetTexCoord(0, 0, 1, 0, 0, 1, 1, 1)
    _G.InspectModelFrameRotateRightButton:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
    _G.InspectModelFrameRotateRightButton:GetPushedTexture():SetTexCoord(0, 1, 0, 0, 1, 1, 1, 0)

    InspectTalentFrame:GwStripTextures()
    InspectTalentFrameCloseButton:GwSkinButton(true)
    InspectTalentFrameCloseButton:SetSize(20, 20)
    InspectTalentFrameCloseButton:SetPoint("TOPRIGHT", -5, -5)
    -- HandleTab looks weird
    for i = 1, 3 do
        local tab = _G["InspectTalentFrameTab"..i]
        tab:GwStripTextures()
        tab:SetHeight(24)
        tab:GwSkinButton(false, true)
    end

    InspectTalentFramePointsBar:GwStripTextures()

    _G.InspectTalentFrameSpentPointsText:SetPoint("LEFT", _G.InspectTalentFramePointsBar, "LEFT", 12, -1)
    _G.InspectTalentFrameTalentPointsText:SetPoint("RIGHT", _G.InspectTalentFramePointsBar, "RIGHT", -12, -1)

    _G.InspectTalentFrameScrollFrame:GwStripTextures()
    _G.InspectTalentFrameScrollFrame:GwCreateBackdrop()

    InspectTalentFrameScrollFrame:GwSkinScrollFrame()
    InspectTalentFrameScrollFrameScrollBar:GwSkinScrollBar()
    InspectTalentFrameScrollFrameScrollBar:SetPoint("TOPLEFT", _G.InspectTalentFrameScrollFrame, "TOPRIGHT", 10, -16)

    for i = 1, _G.MAX_NUM_TALENTS do
        local talent = _G["InspectTalentFrameTalent" .. i]
        local icon = _G["InspectTalentFrameTalent" .. i .. "IconTexture"]
        local rank = _G["InspectTalentFrameTalent" .. i .. "Rank"]

        if talent then
            talent:GwStripTextures()
            talent:GwStyleButton()

            icon:GwSetInside()
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            icon:SetDrawLayer("ARTWORK")

            rank:SetTextColor(1, 1, 1)
        end
    end


    -- Give inspect frame model backdrop it"s color back
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

    -- Honor/Arena/PvP Tab
    InspectPVPFrame:GwStripTextures(true)

    for i = 1, MAX_ARENA_TEAMS do
        local inspectpvpTeam = _G["InspectPVPTeam" .. i]

        inspectpvpTeam:GwStripTextures()
        inspectpvpTeam:GwCreateBackdrop()
        inspectpvpTeam.backdrop:SetPoint("TOPLEFT", 9, -4)
        inspectpvpTeam.backdrop:SetPoint("BOTTOMRIGHT", -24, 3)


        _G["InspectPVPTeam" .. i .. "Highlight"]:GwKill()
    end
end

local function LoadInspectFrameSkin()
    GW.RegisterLoadHook(SkinInspectFrameOnLoad, "Blizzard_InspectUI", InspectFrame)
end
GW.LoadInspectFrameSkin = LoadInspectFrameSkin
