local _, GW = ...

local function SkinGearQuipper()
    GqUiFrame:StripTextures()
    GqEventBindingFrame:StripTextures()

    GqUiFrame.CloseButton:SkinButton(true)
    GqUiFrame.CloseButton:SetSize(20, 20)

    local tex = GqUiFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", GqUiFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    tex:SetSize(GqUiFrame:GetWidth() + 30, 450)
    GqUiFrame.tex = tex

    GqUiFrame:SetPoint("TOPRIGHT", 310, -12);

    GqUiFrame:HookScript("OnShow", function()
        GqUiFrame:SetPoint("TOPRIGHT", 350, -12)
    end)

    GqUiFrame_BtnSaveSet:SkinButton(false, true)
    GqUiFrame_BtnDeleteSet:SkinButton(false, true)
    GqUiScrollFrame:StripTextures()
    GqUiScrollFrame:CreateBackdrop(GW.skins.constBackdropFrame, true, 10)
    GqUiEventBindingsScrollFrame:StripTextures()
    GqUiEventBindingsScrollFrame:CreateBackdrop(GW.skins.constBackdropFrame, true, 10)
    GqUiScrollFrameVSlider.RightEdge:Hide()
    GqUiScrollFrameVSlider.LeftEdge:Hide()
    GqUiScrollFrameVSlider.BottomLeftCorner:Hide()
    GqUiScrollFrameVSlider.BottomRightCorner:Hide()
    GqUiScrollFrameVSlider.BottomEdge:Hide()
    GqUiScrollFrameVSlider.TopLeftCorner:Hide()
    GqUiScrollFrameVSlider.TopRightCorner:Hide()
    GqUiScrollFrameVSlider.TopEdge:Hide()
    GqUiScrollFrameVSlider:StripTextures()
    GqUiScrollFrameVSlider:SkinScrollBar()
    GqUiScrollFrameVSlider.Center:SetTexture("Interface/AddOns/GW2_UI/textures/scrollbg")
    GqUiScrollFrameVSlider.Center:SetWidth(3)

    GqUiEventBindingsScrollFrameVSlider.RightEdge:Hide()
    GqUiEventBindingsScrollFrameVSlider.LeftEdge:Hide()
    GqUiEventBindingsScrollFrameVSlider.BottomLeftCorner:Hide()
    GqUiEventBindingsScrollFrameVSlider.BottomRightCorner:Hide()
    GqUiEventBindingsScrollFrameVSlider.BottomEdge:Hide()
    GqUiEventBindingsScrollFrameVSlider.TopLeftCorner:Hide()
    GqUiEventBindingsScrollFrameVSlider.TopRightCorner:Hide()
    GqUiEventBindingsScrollFrameVSlider.TopEdge:Hide()
    GqUiEventBindingsScrollFrameVSlider:StripTextures()
    GqUiEventBindingsScrollFrameVSlider:SkinScrollBar()
    GqUiEventBindingsScrollFrameVSlider.Center:SetTexture("Interface/AddOns/GW2_UI/textures/scrollbg")
    GqUiEventBindingsScrollFrameVSlider.Center:SetWidth(3)

    hooksecurefunc(gearquipper, "InitUI", function()
        GwCharacterWindow.paperDollButton:Kill()
        GwCharacterWindow.paperDollLabel:Kill()
    end)

    GqUiEventBindingsScrollFrameVSlider:SkinScrollBar()
    GqEventBindingFrame_CbDisableEvents:SkinCheckButton()
    GqEventBindingFrame_CbDisableEvents:SetSize(15, 15)

    hooksecurefunc(gearquipper, "ShowSetInfo", function()
        if not GqUiSetInfoFrame_CheckButtonPartial.hookedGW then
            GqUiSetInfoFrame_CheckButtonPartial:SkinCheckButton()
            GqUiSetInfoFrame_CheckButtonPartial:SetSize(15, 15)

            GqUiSetInfoFrame_CheckButtonPartial:ClearAllPoints()
            GqUiSetInfoFrame_CheckButtonPartial:SetPoint("TOPLEFT", 0, -25)
            GqUiSetInfoFrame_CheckButtonPartial.hookedGW = true
        end

        if not GqUiSetInfoFrame_CheckButtonActionSlots.hookedGW then
            GqUiSetInfoFrame_CheckButtonActionSlots:SkinCheckButton()
            GqUiSetInfoFrame_CheckButtonActionSlots:SetSize(15, 15)

            GqUiSetInfoFrame_CheckButtonActionSlots:ClearAllPoints()
            GqUiSetInfoFrame_CheckButtonActionSlots:SetPoint("TOPLEFT", 0, -50)
            GqUiSetInfoFrame_CheckButtonActionSlots.hookedGW = true
        end
    end)

    hooksecurefunc(gearquipper, "CreatePaperDollButton", function()
        if not GQ_PaperDollButton.hookedGW then
            GQ_PaperDollButton:Hide()
            GQ_PaperDollButton.hookedGW = true
        end
    end)

    hooksecurefunc(gearquipper, "CreateSlotStateBox", function(_, slotName)
        local btn =_G[slotName .. "StateBox"]
        if not btn.hookedGW then
            btn:SkinCheckButton()
            btn:SetSize(15, 15)
            btn.hookedGW = true
        end
    end)


    hooksecurefunc(gearquipper, "RefreshSetList", function()
        if not GqAddSetButton.hookedGW then
            GqAddSetButton:SkinButton(false, true)
            GqAddSetButton.hookedGW = true
        end

        local setNames = gearquipper:LoadSetNames()
        for index, _ in ipairs(setNames) do
            if not _G["GqUiSetCheckBox_" .. index].hookedGW then
                _G["GqUiSetCheckBox_" .. index]:SkinCheckButton()
                _G["GqUiSetCheckBox_" .. index]:SetSize(15, 15)
                _G["GqUiSetCheckBox_" .. index].hookedGW = true
            end
        end
    end)

    hooksecurefunc(gearquipper, "RefreshEventEntries", function()
        if not GqAddEventBinding.hookedGW then
            GqAddEventBinding:SkinButton(false, true)
            GqAddEventBinding.hookedGW = true
        end
    end)

    GqUiFrameEvents:StripTextures()
    GqUiFrameEvents.CloseButton:SkinButton(true)
    GqUiFrameEvents.CloseButton:SetSize(20, 20)
    GqUiFrameEvents:CreateBackdrop(GW.skins.constBackdropFrame, true, 10)

    GqUiFrameEvents_CbPVE:SkinCheckButton()
    GqUiFrameEvents_CbPVE:SetSize(15, 15)

    GqUiFrameEvents_CbPVP:SkinCheckButton()
    GqUiFrameEvents_CbPVP:SetSize(15, 15)

    GqUiFrameEvents_BtnApply:SkinButton(false, true)
    GqUiFrameEvents_BtnCancel:SkinButton(false, true)

    hooksecurefunc("GqUiFrameEvents_OnShow", function()
        if not GqUiFrameEvents_CbEventType.hookedGW then
            GqUiFrameEvents_CbEventType:SkinDropDownMenu()
            GqUiFrameEvents_CbEventType:SetWidth(185)

            GqUiFrameEvents_CbSetName:SkinDropDownMenu()
            GqUiFrameEvents_CbSetName:SetWidth(185)

            GqUiFrameEvents_CbEventType.hookedGW = true
        end
    end)

    hooksecurefunc(gearquipper, "CreateEventEntry", function(_, index)
        local btn = _G["GqUiBindingEntry_" .. index .. "_BtnDelete"]
        local dd = _G["GqUiBindingEntry_" .. index .. "_SetDropdown"]
        if not btn.hookedGW then
            btn:SkinButton(false, true)
            btn.hookedGW = true
        end
        if not dd.hookedGW then
            dd:SkinDropDownMenu()
            dd:SetWidth(160)
            dd.hookedGW = true
        end
    end)

end
GW.SkinGearQuipper = SkinGearQuipper