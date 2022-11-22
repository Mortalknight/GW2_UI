local _, GW = ...

local function ApplyOrderHallTalentFrameSkin()
    if not GW.GetSetting("ORDERRHALL_TALENT_FRAME_SKIN_ENABLED") then return end

    GW.HandlePortraitFrame(OrderHallTalentFrame, true)
    OrderHallTalentFrameTitleText:SetFont(DAMAGE_TEXT_FONT, 16, "OUTLINE")
    OrderHallTalentFrame.BackButton:SkinButton(false, true)
    GW.HandleIcon(OrderHallTalentFrame.Currency.Icon, true)
    OrderHallTalentFrame.OverlayElements:SetAlpha(0)

    hooksecurefunc(OrderHallTalentFrame, "RefreshAllData", function(frame)
        if frame.CloseButton.Border then frame.CloseButton.Border:SetAlpha(0) end
        if frame.CurrencyBG then frame.CurrencyBG:SetAlpha(0) end

        frame:StripTextures(false, true)

        OrderHallTalentFrame.portrait:Show()
        OrderHallTalentFrame.portrait:SetAlpha(1)

        if frame.buttonPool then
            for bu in frame.buttonPool:EnumerateActive() do
                if bu.talent then
                    if not bu.SetBackdrop then
                        Mixin(bu, BackdropTemplateMixin)
                        bu:HookScript("OnSizeChanged", bu.OnBackdropSizeChanged)
                    end
                    bu:SetBackdrop(GW.constBackdropFrameColorBorder)

                    bu.Border:SetAlpha(0)
                    bu.Highlight:SetColorTexture(1, 1, 1, 0.25)
                    bu.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                    bu.Icon:SetInside()
                    local isAvailable = bu.talent.talentAvailability == Enum.GarrisonTalentAvailability.Available
                    local overrideDisplayAsAvailable = bu.talent.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableNotEnoughResources
                    local canDisplayAsAvailable = bu.talent.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableAnotherIsResearching or bu.talent.talentAvailability == Enum.GarrisonTalentAvailability.UnavailableAlreadyHave
                    local shouldDisplayAsAvailable = (canDisplayAsAvailable or overrideDisplayAsAvailable) and bu.talent.hasInstantResearch

                    if bu.talent.researched or bu.talent.selected then
                        bu:SetBackdropBorderColor(1, 0.8, 0)
                    elseif isAvailable or shouldDisplayAsAvailable then
                        bu:SetBackdropBorderColor(0, 1, 0)
                    else
                        bu:SetBackdropBorderColor(1, 1, 1)
                    end
                end
            end
        end
    end)

end

local function LoadOrderHallTalentFrameSkin()
    GW.RegisterLoadHook(ApplyOrderHallTalentFrameSkin, "Blizzard_OrderHallUI", OrderHallTalentFrame)
end
GW.LoadOrderHallTalentFrameSkin = LoadOrderHallTalentFrameSkin