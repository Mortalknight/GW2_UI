local _, GW = ...
local RegisterMovableFrame = GW.RegisterMovableFrame
local GetSetting = GW.GetSetting

local function updateLootFrameButtons(self)
    for i=1,3 do 
        local button  = _G["LootButton"..i]
        local nameFrame = _G["LootButton"..i.."NameFrame"]
        local item = button.Item

        if item and not item.backdrop then
            local Icon = _G["LootButton"..i.."IconTexture"]
            item:GwStripTextures()
            item.icon:SetTexture(Icon)
            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
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

        if nameFrame then
            nameFrame:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\menu-hover")
            nameFrame:SetHeight(button:GetHeight())
            nameFrame:SetPoint("LEFT", button, "RIGHT", 0, 0)
        end

        if button.Text then
            button.Text:SetFont(UNIT_NAME_FONT, 12)
        end
    end
end

local function LoadLootFrameSkin()
    if not GetSetting("LOOTFRAME_SKIN_ENABLED") then return end

    LootFrame:GwStripTextures()
    LootFrameBg:Hide()
    LootFrameTitleText:Hide()
 
    LootFramePortraitFrame:Hide()
    LootFramePortrait:Hide()
    LootFramePortraitOverlay:Hide()

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
        RegisterMovableFrame(LootFrame, BUTTON_LAG_LOOT, "LOOTFRAME_POS", ALL .. ",Blizzard", nil, {"default", "scaleable"})
        hooksecurefunc(LootFrame, "SetPoint", function(_, _, holder)
            if holder ~= LootFrame.gwMover then
                LootFrame:ClearAllPoints()
                LootFrame:SetPoint("TOPLEFT", LootFrame.gwMover)
            end
        end)
    end

    LootFrame:GwKillEditMode()

    LootFrameCloseButton:ClearAllPoints()
    LootFrameCloseButton:SetPoint("RIGHT", GwLootFrameTitle.BGRIGHT, "RIGHT", -5, -2)
    LootFrameCloseButton:SetSize(20,20)
    LootFrameCloseButton:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-normal")
    LootFrameCloseButton:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover")
    LootFrameCloseButton:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/window-close-button-hover")

    updateLootFrameButtons(LootFrame)
end
GW.LoadLootFrameSkin = LoadLootFrameSkin
