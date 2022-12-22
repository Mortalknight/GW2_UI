local _, GW = ...
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetSetting = GW.GetSetting

local function updateLootFrameButtons(self)
    for _, button in next, { self.ScrollTarget:GetChildren() } do
        local item = button.Item

        if item and not item.backdrop then
            local Icon = item.icon:GetTexture()
            item:StripTextures()
            item.icon:SetTexture(Icon)

            GW.HandleIcon(item.icon, true, GW.constBackdropFrameColorBorder)
            GW.HandleIconBorder(item.IconBorder, item.icon.backdrop)
            item.IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        end

        if button.BorderFrame then
            button.BorderFrame:SetAlpha(0)
        end
        if button.IconQuestTexture then
            button.IconQuestTexture:SetAlpha(0)
        end
        if button.HighlightNameFrame then
            button.HighlightNameFrame:SetAlpha(0)
        end
        if button.PushedNameFrame then
            button.PushedNameFrame:SetAlpha(0)
        end

        if button.NameFrame then
            button.NameFrame:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
            button.NameFrame:SetHeight(button:GetHeight())
            button.NameFrame:SetPoint("LEFT", button, "RIGHT", 0, 0)
        end

        if button.Text then
            button.Text:SetFont(UNIT_NAME_FONT, 12)
        end
    end
end

local function LoadLootFrameSkin()
    if not GetSetting("LOOTFRAME_SKIN_ENABLED") then return end

    LootFrame:StripTextures()
    LootFrameBg:Hide()
    LootFrameTitleText:Hide()

    local GwLootFrameTitle = CreateFrame("Frame", nil, LootFrame, "GwLootFrameTitleTemp")
    GwLootFrameTitle:SetPoint("BOTTOMLEFT", LootFrame, "TOPLEFT", 0, -25)
    GwLootFrameTitle.headerString:SetFont(DAMAGE_TEXT_FONT, 14)
    GwLootFrameTitle.headerString:SetTextColor(255 / 255, 241 / 255, 209 / 255)

    local w, _ = LootFrame:GetSize()
    GwLootFrameTitle:SetWidth(w)
    GwLootFrameTitle.BGLEFT:SetWidth(w)
    GwLootFrameTitle.BGRIGHT:SetWidth(w)
    GwLootFrameTitle.headerString:SetWidth(w)

    if not LootFrame.SetBackdrop then
        Mixin(LootFrame, BackdropTemplateMixin)
        LootFrame:HookScript("OnSizeChanged", LootFrame.OnBackdropSizeChanged)
    end

    LootFrame:SetBackdrop({
        edgeFile = "",
        bgFile = "Interface/AddOns/GW2_UI/textures/bag/lootframebg",
        edgeSize = 1
    })

    if not GetCVarBool("lootUnderMouse") then
        local pos = GetSetting("LOOTFRAME_POS")
        LootFrame:ClearAllPoints()
        LootFrame:SetPoint(pos.point, nil, pos.relativePoint, pos.xOfs, pos.yOfs)
        RegisterMovableFrame(LootFrame, BUTTON_LAG_LOOT, "LOOTFRAME_POS", "VerticalActionBarDummy", nil, {"default", "scaleable"})
        hooksecurefunc(LootFrame, "SetPoint", function(_, _, holder)
            if holder ~= LootFrame.gwMover then
                LootFrame:ClearAllPoints()
                LootFrame:SetPoint("TOPLEFT", LootFrame.gwMover)
            end
        end)
    end

    LootFrame:KillEditMode()

    LootFrame.ClosePanelButton:ClearAllPoints()
    LootFrame.ClosePanelButton:SetPoint("RIGHT", GwLootFrameTitle.BGRIGHT, "RIGHT", -5, -2)
    LootFrame.ClosePanelButton:SetSize(20,20)
    LootFrame.ClosePanelButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal")
    LootFrame.ClosePanelButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover")
    LootFrame.ClosePanelButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover")

    hooksecurefunc(LootFrame.ScrollBox, "Update", updateLootFrameButtons)
end
GW.LoadLootFrameSkin = LoadLootFrameSkin
