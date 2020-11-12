local _, GW = ...

local function skinHelpFrameOnEvent()
    local frames = {
        _G.HelpFrameLeftInset,
        _G.HelpFrameMainInset,
        _G.HelpFrameKnowledgebase,
        _G.HelpFrameKnowledgebaseErrorFrame,
    }

    local buttons = {
        _G.HelpFrameAccountSecurityOpenTicket,
        _G.HelpFrameOpenTicketHelpOpenTicket,
        _G.HelpFrameKnowledgebaseSearchButton,
        _G.HelpFrameKnowledgebaseNavBarHomeButton,
        _G.HelpFrameCharacterStuckStuck,
        _G.HelpFrameSubmitSuggestionSubmit,
        _G.HelpFrameReportBugSubmit,
    }

    for i = 1, #frames do
        frames[i]:StripTextures(true)
        frames[i]:CreateBackdrop(GW.skins.constBackdropFrame)
    end

    local Header = _G.HelpFrame.Header
    Header:StripTextures(true)
    Header:SetFrameLevel(Header:GetFrameLevel() + 2)
    _G.HelpFrameKnowledgebaseErrorFrame:SetFrameLevel(_G.HelpFrameKnowledgebaseErrorFrame:GetFrameLevel() + 2)
    Header.Text:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    local HelpFrameReportBugScrollFrame = _G.HelpFrameReportBugScrollFrame
    HelpFrameReportBugScrollFrame:StripTextures()
    HelpFrameReportBugScrollFrame:CreateBackdrop(GW.skins.constBackdropFrame)
    HelpFrameReportBugScrollFrame.backdrop:SetPoint("TOPLEFT", -4, 4)
    HelpFrameReportBugScrollFrame.backdrop:SetPoint("BOTTOMRIGHT", 6, -4)

    for i = 1, _G.HelpFrameReportBug:GetNumChildren() do
        local child = select(i, _G.HelpFrameReportBug:GetChildren())
        if child and not child:GetName() then
            child:StripTextures()
        end
    end

    _G.HelpFrameReportBugScrollFrameScrollBar:SkinScrollBar()

    local HelpFrameSubmitSuggestionScrollFrame = _G.HelpFrameSubmitSuggestionScrollFrame
    HelpFrameSubmitSuggestionScrollFrame:StripTextures()
    HelpFrameSubmitSuggestionScrollFrame:CreateBackdrop(GW.skins.constBackdropFrame)
    HelpFrameSubmitSuggestionScrollFrame.backdrop:SetPoint("TOPLEFT", -4, 4)
    HelpFrameSubmitSuggestionScrollFrame.backdrop:SetPoint("BOTTOMRIGHT", 6, -4)
    for i = 1, _G.HelpFrameSubmitSuggestion:GetNumChildren() do
        local child = select(i, _G.HelpFrameSubmitSuggestion:GetChildren())
        if not child:GetName() then
            child:StripTextures()
        end
    end

    _G.HelpFrameSubmitSuggestionScrollFrameScrollBar:SkinScrollBar()
    _G.HelpFrameKnowledgebaseScrollFrame2ScrollBar:SkinScrollBar()
    
    _G.BrowserSettingsTooltip:StripTextures()
    _G.BrowserSettingsTooltip:CreateBackdrop(GW.skins.constBackdropFrame)
    _G.BrowserSettingsTooltip.CookiesButton:SkinButton(false, true)

    -- skin sub buttons
    for i = 1, #buttons do
        buttons[i]:StripTextures(true)
        buttons[i]:SkinButton(false, true)

        if buttons[i].text then
            buttons[i].text:ClearAllPoints()
            buttons[i].text:SetPoint("CENTER")
            buttons[i].text:SetJustifyH("CENTER")
        end
    end

    -- skin main buttons
    for i = 1, 6 do
        local b = _G["HelpFrameButton"..i]
        b:SkinButton(false, true)
        b.text:ClearAllPoints()
        b.text:SetPoint("CENTER")
        b.text:SetJustifyH("CENTER")
        _G["HelpFrameButton" .. i .. "Selected"]:SetAlpha(0)
    end

    _G.HelpFrameButton16:SkinButton(false, true)
    _G.HelpFrameButton16.text:ClearAllPoints()
    _G.HelpFrameButton16.text:SetPoint("CENTER")
    _G.HelpFrameButton16.text:SetJustifyH("CENTER")
    _G.HelpFrameButton16Selected:SetAlpha(0)

    -- skin table options
    for i = 1, _G.HelpFrameKnowledgebaseScrollFrameScrollChild:GetNumChildren() do
        local b = _G["HelpFrameKnowledgebaseScrollFrameButton" .. i]
        b:StripTextures(true)
        b:SkinButton()
    end

    --Navigation buttons
    local HelpBrowserNavHome = _G.HelpBrowserNavHome
    HelpBrowserNavHome:SkinButton()
    HelpBrowserNavHome.Icon:SetDesaturated(true)
    HelpBrowserNavHome:SetSize(26, 26)
    HelpBrowserNavHome:ClearAllPoints()
    HelpBrowserNavHome:SetPoint("BOTTOMLEFT", _G.HelpBrowser, "TOPLEFT", -5, 9)
    GW.HandleNextPrevButton(_G.HelpBrowserNavBack, "left")
    _G.HelpBrowserNavBack:SetSize(26, 26)
    GW.HandleNextPrevButton(_G.HelpBrowserNavForward, "right")
    _G.HelpBrowserNavForward:SetSize(26, 26)
    _G.HelpBrowserNavReload:SkinButton()
    _G.HelpBrowserNavReload:SetSize(26, 26)
    _G.HelpBrowserNavReload.Icon:SetDesaturated(true)
    _G.HelpBrowserNavStop:SkinButton()
    _G.HelpBrowserNavStop:SetSize(26, 26)
    _G.HelpBrowserNavStop.Icon:SetDesaturated(true)
    _G.HelpBrowserBrowserSettings:SkinButton()
    _G.HelpBrowserBrowserSettings:SetSize(26, 26)
    _G.HelpBrowserBrowserSettings:ClearAllPoints()
    _G.HelpBrowserBrowserSettings:SetPoint("TOPRIGHT", _G.HelpFrameCloseButton, "TOPLEFT", -3, -8)
    _G.HelpBrowserBrowserSettings.Icon:SetDesaturated(true)
    
    -- skin misc items
    _G.HelpFrameKnowledgebaseSearchBox:ClearAllPoints()
    _G.HelpFrameKnowledgebaseSearchBox:SetPoint("TOPLEFT", _G.HelpFrameMainInset, "TOPLEFT", 13, -10)
    _G.HelpFrameKnowledgebaseNavBar:StripTextures()
    
    local HelpFrame = _G.HelpFrame
    HelpFrame:StripTextures(true)
    HelpFrame:CreateBackdrop()
    local tex = HelpFrame:CreateTexture("bg", "BACKGROUND")
    tex:SetPoint("TOP", HelpFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg")
    local w, h = HelpFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    HelpFrame.tex = tex

    _G.HelpFrameKnowledgebaseScrollFrameScrollBar:SkinScrollBar()
    _G.HelpFrameCloseButton:SkinButton(true)
    _G.HelpFrameCloseButton:SetSize(25, 25)
    _G.HelpFrameKnowledgebaseErrorFrameCloseButton:SkinButton(true)
    _G.HelpFrameKnowledgebaseErrorFrameCloseButton:SetSize(25, 25)
    
    -- Hearth Stone Button
    _G.HelpFrameCharacterStuckHearthstone.IconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    _G.HelpFrameGM_ResponseNeedMoreHelp:SkinButton()
    _G.HelpFrameGM_ResponseCancel:SkinButton()
end
GW.skinHelpFrameOnEvent = skinHelpFrameOnEvent
