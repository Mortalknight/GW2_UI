local _, GW = ...

local function gwSetStaticPopupSize()
    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]
        StaticPopup.tex:SetSize(StaticPopup:GetSize())
        _G["StaticPopup" .. i .. "AlertIcon"]:SetTexture("Interface/AddOns/GW2_UI/textures/warning-icon") 
        _G["StaticPopup" .. i .. "ItemFrameNameFrame"]:SetTexture(nil)
        _G["StaticPopup" .. i .. "ItemFrame"].IconBorder:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagitemborder")
        _G["StaticPopup" .. i .. "ItemFrameIconTexture"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        _G["StaticPopup" .. i .. "ItemFrameNormalTexture"]:SetTexture(nil)
        _G["StaticPopup" .. i .. "CloseButton"]:SkinButton(true)
        _G["StaticPopup" .. i .. "CloseButton"]:SetSize(20, 20)
        _G["StaticPopup" .. i .. "CloseButton"]:ClearAllPoints()
        _G["StaticPopup" .. i .. "CloseButton"]:SetPoint("TOPRIGHT", -20, -5)
    end
end

local function SkinStaticPopup()
    for i = 1, 4 do
        local StaticPopup = _G["StaticPopup" .. i]

        StaticPopup:StripTextures()
        StaticPopup:CreateBackdrop()
        StaticPopup.CoverFrame:Hide()
        StaticPopup.Separator:Hide()

        local tex = StaticPopup:CreateTexture("bg", "BACKGROUND")
        tex:SetPoint("TOP", StaticPopup, "TOP", 0, 0)
        tex:SetSize(StaticPopup:GetSize())
        tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
        StaticPopup.tex = tex

        --Style Buttons (upto 5)
        for ii = 1, 5 do
            if ii < 5 then
                _G["StaticPopup" .. i .. "Button" .. ii]:SkinButton(false, true)
            else
                _G["StaticPopup" .. i .. "ExtraButton"]:SkinButton(false, true)
            end
        end

        --Change EditBox
        _G["StaticPopup" .. i .. "EditBoxLeft"]:Hide()
        _G["StaticPopup" .. i .. "EditBoxRight"]:Hide()
        _G["StaticPopup" .. i .. "EditBoxMid"]:SetTexture("Interface/AddOns/GW2_UI/textures/gwstatusbar-bg")
        _G["StaticPopup" .. i .. "EditBoxMid"]:ClearAllPoints()
        _G["StaticPopup" .. i .. "EditBoxMid"]:SetPoint("TOPLEFT", _G["StaticPopup" .. i .. "EditBoxLeft"], "BOTTOMRIGHT", -25, 3)
        _G["StaticPopup" .. i .. "EditBoxMid"]:SetPoint("BOTTOMRIGHT", _G["StaticPopup" .. i .. "EditBoxRight"], "TOPLEFT", 25, -3)
    end

    hooksecurefunc("StaticPopup_OnUpdate", gwSetStaticPopupSize)
    --Movie skip Frame
    hooksecurefunc("CinematicFrame_OnDisplaySizeChanged", function(self)
        if self and self.closeDialog and not self.closeDialog.template then
            self.closeDialog:StripTextures()

            local tex = self.closeDialog:CreateTexture("bg", "BACKGROUND")
            tex:SetPoint("TOP", self.closeDialog, "TOP", 0, 0)
            tex:SetSize(self.closeDialog:GetSize())
            tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
            self.closeDialog.tex = tex

            local dialogName = self.closeDialog.GetName and self.closeDialog:GetName()
            local closeButton = self.closeDialog.ConfirmButton or (dialogName and _G[dialogName .. "ConfirmButton"])
            local resumeButton = self.closeDialog.ResumeButton or (dialogName and _G[dialogName .. "ResumeButton"])
            if closeButton then closeButton:SkinButton(false, true) end
            if resumeButton then resumeButton:SkinButton(false, true) end
        end
    end)

    hooksecurefunc("MovieFrame_PlayMovie", function(self)
        if self and self.CloseDialog and not self.CloseDialog.template then
            self.CloseDialog.Border:Hide()

            local tex = self.CloseDialog:CreateTexture("bg", "BACKGROUND")
            tex:SetPoint("TOP", self.CloseDialog, "TOP", 0, 0)
            tex:SetSize(self.CloseDialog:GetSize())
            tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
            self.CloseDialog.tex = tex

            self.CloseDialog.ConfirmButton:SkinButton(false, true)
            self.CloseDialog.ResumeButton:SkinButton(false, true)
        end
    end)
end
GW.SkinStaticPopup = SkinStaticPopup