local _, GW = ...

local function HandleGoldIcon(button)
    local Button = _G[button]
    if Button.backdrop then return end

    local count = _G[button.."Count"]
    local nameFrame = _G[button.."NameFrame"]
    local iconTexture = _G[button.."IconTexture"]

    Button:GwCreateBackdrop()
    Button.backdrop:ClearAllPoints()
    Button.backdrop:SetPoint("LEFT", 1, 0)
    Button.backdrop:SetSize(42, 42)

    iconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    iconTexture:SetDrawLayer("OVERLAY")
    iconTexture:SetParent(Button.backdrop)
    iconTexture:GwSetInside()

    count:SetParent(Button.backdrop)
    count:SetDrawLayer("OVERLAY")

    nameFrame:SetTexture()
    nameFrame:SetSize(118, 39)
end

local function SkinItemButton(parentFrame, _, index, _, _, _, _, _, _, quality)
    local parentName = parentFrame:GetName()
    local item = _G[parentName .. "Item" .. index]
    if item and not item.backdrop then
        item:GwCreateBackdrop(GW.BackdropTemplates.ColorableBorderOnly)
        item.backdrop:ClearAllPoints()
        item.backdrop:SetPoint("LEFT", 1, 0)
        item.backdrop:SetSize(42, 42)

        item.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        item.Icon:SetDrawLayer("OVERLAY")
        item.Icon:SetParent(item.backdrop)
        item.Icon:GwSetInside()

        item.Count:SetDrawLayer("OVERLAY")
        item.Count:SetParent(item.backdrop)

        item.NameFrame:SetTexture()
        item.NameFrame:SetSize(118, 39)

        item.shortageBorder:SetTexture()

        item.roleIcon1:SetParent(item.backdrop)
        item.roleIcon2:SetParent(item.backdrop)

        GW.HandleIconBorder(item.IconBorder, item.backdrop)
        item.IconBorder:GwKill()
    end
    if quality then
        local color = GW.GetBagItemQualityColor(quality)
        local r, g, b = 1, 1, 1
        if color then
            r, g, b = color.r, color.g, color.b
        end
        item.backdrop:SetBackdropBorderColor(r, g, b)
    end
end

local function HandleAffixIcons(self)
    local MapID, _, PowerLevel = C_ChallengeMode.GetSlottedKeystoneInfo()

    if MapID then
        local Name = C_ChallengeMode.GetMapUIInfo(MapID)

        if Name and PowerLevel then
            self.DungeonName:SetText(Name .. "|cffffffff - |r" .. "(" .. PowerLevel .. ")")
        end

        self.PowerLevel:SetText("")
    end
    local list = self.AffixesContainer and self.AffixesContainer.Affixes or self.Affixes
    if not list then return end

    for _, frame in ipairs(list) do
        frame.Border:SetTexture()
        frame.Portrait:SetTexture()

        if frame.info then
            frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
        elseif frame.affixID then
            local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
            frame.Portrait:SetTexture(filedataid)
        end

        GW.HandleIcon(frame.Portrait, true)

        frame.Percent:SetFont(DAMAGE_TEXT_FONT, 16, "OUTLINE")
    end
end

local function SkinLookingForGroupFrames()
    if not GW.settings.LFG_SKIN_ENABLED then return end

    GW.HandlePortraitFrame(PVEFrame, false)
    PVEFrame.CloseButton:SetPoint("TOPRIGHT", -5, -2)

    LFDQueueFrame:GwStripTextures(true)
    RaidFinderFrame:GwStripTextures()
    RaidFinderQueueFrame:GwStripTextures(true)

    GW.CreateFrameHeaderWithBody(PVEFrame, PVEFrameTitleText, "Interface/AddOns/GW2_UI/textures/Groups/dungeon-window-icon.png", {
        LFDQueueFrame,
        RaidFinderQueueFrame,
        LFGListPVEStub
    }, nil, true, true)
    PVEFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER, nil, 6)

    -- copied from blizzard need to icon switching
    local panels = {
        { name = "GroupFinderFrame", addon = nil },
        { name = "PVPUIFrame", addon = "Blizzard_PVPUI" },
        { name = "ChallengesFrame", addon = "Blizzard_ChallengesUI", check = function() return UnitLevel("player") >= GetMaxLevelForPlayerExpansion(); end, hideLeftInset = true },
        { name = "DelvesDashboardFrame", addon = "Blizzard_DelvesDashboardUI", check = function() return GetExpansionLevel() >= LE_EXPANSION_WAR_WITHIN end, hideLeftInset = true },
    }

    local tabs = {PVEFrameTab1, PVEFrameTab2, PVEFrameTab3, PVEFrameTab4}
    for idx, tab in pairs(tabs) do
        if not tab.isSkinned then
            local id = idx == 1 and "dungeon" or idx == 2 and "pvp" or idx == 3 and "mythic" or idx == 4 and "delve" or "dungeon"
            local iconTexture = "Interface/AddOns/GW2_UI/Textures/Groups/tabicon_" .. id .. ".png"


            tab:HookScript("OnClick", function(self)
                if panels[self:GetID()].check and not  panels[self:GetID()].check() then return end
                if idx == 1 then
                    PVEFrame.gwHeader.windowIcon:SetTexture("Interface/AddOns/GW2_UI/textures/Groups/dungeon-window-icon.png")
                elseif idx == 2 then
                    PVEFrame.gwHeader.windowIcon:SetTexture("Interface/AddOns/GW2_UI/textures/Groups/pvp-window-icon.png")
                elseif idx == 3 then
                    PVEFrame.gwHeader.windowIcon:SetTexture("Interface/AddOns/GW2_UI/textures/Groups/mythic-window-icon.png")
                elseif idx == 4 then
                    PVEFrame.gwHeader.windowIcon:SetTexture("Interface/AddOns/GW2_UI/textures/Groups/delve-window-icon.png")
                end
            end)

			GW.SkinSideTabButton(tab, iconTexture, tab:GetText())
		end

		tab:ClearAllPoints()
		tab:SetPoint("TOPRIGHT", PVEFrame.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * (idx - 1)))
		tab:SetParent(PVEFrame.LeftSidePanel)
		tab:SetSize(64, 40)
    end

    -- copy from blizzard and modified
    PVEFrame:HookScript("OnShow", function(self)
        -- If timerunning enabled, hide PVP and M+, and re-anchor delves to Dungeons tab
        if TimerunningUtil.TimerunningEnabledForPlayer() then
            self.tab2:Hide()
            self.tab3:Hide()
            if self.tab4 and self.tab4:IsShown() then
                self.tab4:ClearAllPoints()
                self.tab4:SetPoint("TOPRIGHT", self.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * (2 - 1))) -- 4 = index but here 2 because 2 and 3 are hidden
            end
        else
        -- Otherwise, anchor Delves tab to PVP if M+ hidden, or to M+ if both are shown - to prevent a gap if the player is ineligible for M+ and we hide the tab
            if self.tab4 and self.tab4:IsShown() then
                if self.tab2:IsShown() and not self.tab3:IsShown() then
                    self.tab4:ClearAllPoints()
                    self.tab4:SetPoint("TOPRIGHT", self.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * (3 - 1))) -- 4 = index but here 3 because 3 is hidden
                elseif self.tab2:IsShown() and self.tab3:IsShown() then
                    self.tab4:ClearAllPoints()
                    self.tab4:SetPoint("TOPRIGHT", self.LeftSidePanel, "TOPLEFT", 1, -32 + (-40 * (4 - 1))) -- 4 = index
                end
            end
        end
    end)

    PVEFrame.gwHeader.windowIcon:ClearAllPoints()
    PVEFrame.gwHeader.windowIcon:SetPoint("CENTER", PVEFrame.gwHeader, "BOTTOMLEFT", -26, 35)
    PVEFrameTitleText:ClearAllPoints()
    PVEFrameTitleText:SetPoint("BOTTOMLEFT", PVEFrame.gwHeader, "BOTTOMLEFT", 25, 10)

    PVEFrameBg:Hide()
    PVEFrame.shadows:GwKill()

    LFDQueueFramePartyBackfillBackfillButton:GwSkinButton(false, true)
    LFDQueueFramePartyBackfillNoBackfillButton:GwSkinButton(false, true)

    LFDQueueFrameRoleButtonTankIncentiveIcon:SetAlpha(0)
    LFDQueueFrameRoleButtonHealerIncentiveIcon:SetAlpha(0)
    LFDQueueFrameRoleButtonDPSIncentiveIcon:SetAlpha(0)
    LFDQueueFrameRoleButtonTank.shortageBorder:GwKill()
    LFDQueueFrameRoleButtonDPS.shortageBorder:GwKill()
    LFDQueueFrameRoleButtonHealer.shortageBorder:GwKill()

    local RoleButtons1 = {
        _G.LFDQueueFrameRoleButtonHealer,
        _G.LFDQueueFrameRoleButtonDPS,
        _G.LFDQueueFrameRoleButtonLeader,
        _G.LFDQueueFrameRoleButtonTank,
        _G.RaidFinderQueueFrameRoleButtonHealer,
        _G.RaidFinderQueueFrameRoleButtonDPS,
        _G.RaidFinderQueueFrameRoleButtonLeader,
        _G.RaidFinderQueueFrameRoleButtonTank,
        _G.RolePollPopupRoleButtonTank,
        _G.RolePollPopupRoleButtonHealer,
        _G.RolePollPopupRoleButtonDPS,
    }

    for _, roleButton in pairs(RoleButtons1) do
        local checkButton = roleButton.checkButton or roleButton.CheckButton
        checkButton:GwSkinCheckButton()
        checkButton:SetSize(15, 15)
    end

    hooksecurefunc("SetCheckButtonIsRadio", function(self)
        if not self.isSkinned then
            self:GwSkinCheckButton()
            self:SetSize(15, 15)
        end
    end)

    local repositionCheckButtons = {
        LFGListApplicationDialog.TankButton.CheckButton,
        LFGListApplicationDialog.HealerButton.CheckButton,
        LFGListApplicationDialog.DamagerButton.CheckButton,
    }
    for _, checkButton in pairs(repositionCheckButtons) do
        checkButton:ClearAllPoints()
        checkButton:SetPoint("BOTTOMLEFT", 0, 0)
    end

    hooksecurefunc("LFGListApplicationDialog_UpdateRoles", function(dialog)
        local availTank, availHealer, availDPS = C_LFGList.GetAvailableRoles()

        local avail1, avail2
        if availTank then
            avail1 = dialog.TankButton
        end
        if availHealer then
            if avail1 then
                avail2 = dialog.HealerButton
            else
                avail1 = dialog.HealerButton
            end
        end
        if availDPS then
            if avail1 then
                avail2 = dialog.DamagerButton
            else
                avail1 = dialog.DamagerButton
            end
        end

        if avail2 then
            avail1:ClearAllPoints()
            avail1:SetPoint("TOPRIGHT", dialog, "TOP", -40, -35)
            avail2:ClearAllPoints()
            avail2:SetPoint("TOPLEFT", dialog, "TOP", 40, -35)
        elseif avail1 then
            avail1:ClearAllPoints()
            avail1:SetPoint("TOP", dialog, "TOP", 0, -35)
        end
    end)

    hooksecurefunc("LFG_DisableRoleButton", function(button)
        if button.checkButton:GetChecked() then
            button.checkButton:SetAlpha(1)
        else
            button.checkButton:SetAlpha(0)
        end

        if button.background then
            button.background:Show()
        end
    end)

    hooksecurefunc("LFG_EnableRoleButton", function(button)
        button.checkButton:SetAlpha(1)
    end)

    hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(button)
        if button.background then
            button.background:Show()
            button.background:SetDesaturated(true)
        end
    end)

    hooksecurefunc("GroupFinderFrame_EvaluateButtonVisibility", function()
        for i = 1, 4 do
            local bu = GroupFinderFrame["groupButton" .. i]
            GroupFinderFrame.groupButton1:GetText()
            bu.ring:GwKill()
            bu.bg:GwKill()
            bu:GwSkinButton(false, true)

            bu:SetHeight(36)

            bu:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
            bu.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
            bu.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
            if i % 2 == 1 then
                bu:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
            else
                bu:ClearNormalTexture()
            end

            bu.arrow = bu:CreateTexture(nil, "OVERLAY")
            bu.arrow:SetSize(10, 20)
            bu.arrow:SetPoint("RIGHT", bu, "RIGHT", 0, 0)
            bu.arrow:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-arrow.png")

            bu.name:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
            bu.name:SetJustifyH("LEFT")
            bu.name:SetPoint("LEFT", bu, "LEFT", 5, 0)
            bu.name:SetWidth(bu:GetWidth())
            hooksecurefunc(bu.name, "SetText", function()
                if not bu.name.SetTextGw2 then
                    bu.name.SetTextGw2 = true
                    bu.name:SetText(bu.name:GetText():gsub("-\n", ""):gsub("\n", ""))
                    bu.name.SetTextGw2 = false
                end
            end)

            bu.gwBorderFrame:Hide()

            bu.icon:Hide()

            bu:ClearAllPoints()
            if i == 1 then
                bu:SetPoint("TOPLEFT", 10, -40)
            else
                bu:SetPoint("TOP", GroupFinderFrame["groupButton" .. i - 1], "BOTTOM", 0, 0)
            end
        end
    end)

    hooksecurefunc("GroupFinderFrame_SelectGroupButton", function(idx)
        for i = 1, 4 do
            local bu = GroupFinderFrame["groupButton" .. i]
            if i == idx then
                bu.hover.skipHover = true
                bu.hover:SetAlpha(1)
                bu.hover:SetPoint("RIGHT", bu, "LEFT", bu:GetWidth(), 0)
            else
                bu.hover.skipHover = false
                bu.hover:SetAlpha(1)
                bu.hover:SetPoint("RIGHT", bu, "LEFT", 0, 0)
            end

        end
    end)

    if ScenarioQueueFrame then
        ScenarioQueueFrame:GwStripTextures()
        ScenarioFinderFrameInset:GwStripTextures()
        ScenarioQueueFrameBackground:SetAlpha(0)
        ScenarioQueueFrameTypeDropdown:GwHandleDropDownBox()
        GW.HandleTrimScrollBar(ScenarioQueueFrameRandomScrollFrame.ScrollBar)
        ScenarioQueueFrameFindGroupButton:GwSkinButton(false, true)

        ScenarioQueueFrameSpecificScrollFrame:GwStripTextures()
        --GW.HandleTrimScrollBar(ScenarioQueueFrameSpecificScrollFrame.ScrollBar)

        if ScenarioQueueFrameRandomScrollFrameScrollBar then
            ScenarioQueueFrameRandomScrollFrameScrollBar:SetAlpha(0)
        end
    end

    -- Raid finder
    LFDQueueFrameFindGroupButton:GwSkinButton(false, true)

    LFDParentFrame:GwStripTextures()
    LFDParentFrameInset:GwStripTextures()

    HandleGoldIcon("LFDQueueFrameRandomScrollFrameChildFrameMoneyReward")
    HandleGoldIcon("RaidFinderQueueFrameScrollFrameChildFrameMoneyReward")

    LFDQueueFrameRandomScrollFrameChildFrameTitle:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    LFDQueueFrameRandomScrollFrameChildFrameTitle:SetShadowColor(0, 0, 0, 0)
    LFDQueueFrameRandomScrollFrameChildFrameTitle:SetShadowOffset(1, -1)
    LFDQueueFrameRandomScrollFrameChildFrameTitle:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER)

    LFDQueueFrameRandomScrollFrameChildFrameRewardsLabel:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    LFDQueueFrameRandomScrollFrameChildFrameRewardsLabel:SetShadowColor(0, 0, 0, 0)
    LFDQueueFrameRandomScrollFrameChildFrameRewardsLabel:SetShadowOffset(1, -1)
    LFDQueueFrameRandomScrollFrameChildFrameRewardsLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER)

    LFDQueueFrameRandomScrollFrameChildFrameDescription:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    LFDQueueFrameRandomScrollFrameChildFrameRewardsDescription:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)

    GW.HandleTrimScrollBar(LFDQueueFrameRandomScrollFrame.ScrollBar)
    GW.HandleScrollControls(LFDQueueFrameRandomScrollFrame)

    hooksecurefunc("LFGDungeonListButton_SetDungeon", function(button)
        if button and button.expandOrCollapseButton:IsShown() then
            if button.isCollapsed then
                button.expandOrCollapseButton:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrow_right.png")
            else
                button.expandOrCollapseButton:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/uistuff/arrowdown_down.png")
            end
        end
    end)

    LFDQueueFrameTypeDropdown:GwHandleDropDownBox()
    LFDQueueFrameTypeDropdown:ClearAllPoints()
    LFDQueueFrameTypeDropdown:SetPoint("BOTTOMLEFT", 40, 287)
    LFDQueueFrameTypeDropdown:SetWidth(300)
    LFDQueueFrameTypeDropdownName:SetTextColor(1, 1, 1)
    LFDQueueFrameTypeDropdownName:ClearAllPoints()
    LFDQueueFrameTypeDropdownName:SetPoint("RIGHT", LFDQueueFrameTypeDropdown, "LEFT", 0, 0)

    RaidFinderFrameRoleInset:GwStripTextures()
    RaidFinderQueueFrameSelectionDropdown:GwHandleDropDownBox()
    RaidFinderQueueFrameSelectionDropdown:ClearAllPoints()
    RaidFinderQueueFrameSelectionDropdown:SetPoint("BOTTOMLEFT", 90, 287)
    RaidFinderQueueFrameSelectionDropdown:SetWidth(250)
    RaidFinderQueueFrameSelectionDropdownName:SetTextColor(1, 1, 1)
    RaidFinderQueueFrameSelectionDropdownName:ClearAllPoints()
    RaidFinderQueueFrameSelectionDropdownName:SetPoint("RIGHT", RaidFinderQueueFrameSelectionDropdown, "LEFT", 0, 0)


    RaidFinderFrameFindRaidButton:GwStripTextures()
    RaidFinderFrameFindRaidButton:GwSkinButton(false, true)

    RaidFinderQueueFrameSelectionDropdownName:SetTextColor(1, 1, 1)

    RaidFinderQueueFrameScrollFrameChildFrameTitle:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    RaidFinderQueueFrameScrollFrameChildFrameRewardsLabel:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    RaidFinderQueueFrameScrollFrameChildFrameTitle:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER)
    RaidFinderQueueFrameScrollFrameChildFrameRewardsLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.BIG_HEADER)
    RaidFinderQueueFrameScrollFrameChildFrameDescription:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    RaidFinderQueueFrameScrollFrameChildFrameRewardsDescription:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)

    --Skin Reward Items (This works for all frames, LFD, Raid, Scenario)
    hooksecurefunc("LFGRewardsFrame_SetItemButton", SkinItemButton)

    GW.HandleTrimScrollBar(LFDQueueFrameSpecific.ScrollBar, true)
    GW.HandleScrollControls(LFDQueueFrameSpecific)

    _G[_G.LFDQueueFrame.PartyBackfill:GetName().."BackfillButton"]:GwSkinButton(false, true)
    _G[_G.LFDQueueFrame.PartyBackfill:GetName().."NoBackfillButton"]:GwSkinButton(false, true)
    _G[_G.RaidFinderQueueFrame.PartyBackfill:GetName().."BackfillButton"]:GwSkinButton(false, true)
    _G[_G.RaidFinderQueueFrame.PartyBackfill:GetName().."NoBackfillButton"]:GwSkinButton(false, true)

    --LFGListFrame
    LFGListFrame.CategorySelection.Inset:GwStripTextures()
    LFGListFrame.CategorySelection.StartGroupButton:GwSkinButton(false, true)
    LFGListFrame.CategorySelection.StartGroupButton:ClearAllPoints()
    LFGListFrame.CategorySelection.StartGroupButton:SetPoint("BOTTOMLEFT", -1, 3)
    LFGListFrame.CategorySelection.FindGroupButton:GwSkinButton(false, true)
    LFGListFrame.CategorySelection.FindGroupButton:ClearAllPoints()
    LFGListFrame.CategorySelection.FindGroupButton:SetPoint("BOTTOMRIGHT", -6, 3)

    LFGListFrame.CategorySelection.Label:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    LFGListFrame.CategorySelection.Label:SetShadowColor(0, 0, 0, 0)
    LFGListFrame.CategorySelection.Label:SetShadowOffset(1, -1)
    LFGListFrame.CategorySelection.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.HEADER)
    LFGListFrame.CategorySelection.Label:ClearAllPoints()
    LFGListFrame.CategorySelection.Label:SetPoint("TOP", -3, -45)

    local EntryCreation = LFGListFrame.EntryCreation
    EntryCreation.Inset:GwStripTextures()
    EntryCreation.CancelButton:GwSkinButton(false, true)
    EntryCreation.ListGroupButton:GwSkinButton(false, true)
    EntryCreation.CancelButton:ClearAllPoints()
    EntryCreation.CancelButton:SetPoint("BOTTOMLEFT", -1, 3)
    EntryCreation.ListGroupButton:ClearAllPoints()
    EntryCreation.ListGroupButton:SetPoint("BOTTOMRIGHT", -6, 3)
    EntryCreation.Description:GwCreateBackdrop(GW.BackdropTemplates.Default, true, 5, 5)
    EntryCreation.Label:SetTextColor(1, 1, 1)
    EntryCreation.Label:SetFont(DAMAGE_TEXT_FONT, 16)
    EntryCreation.NameLabel:SetTextColor(1, 1, 1)
    EntryCreation.DescriptionLabel:SetTextColor(1, 1, 1)
    GW.HandleBlizzardRegions(EntryCreation.Description)

    EntryCreation.ItemLevel.EditBox:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 4)
    GW.HandleBlizzardRegions(EntryCreation.ItemLevel.EditBox)
    EntryCreation.MythicPlusRating.EditBox:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 4)
    GW.HandleBlizzardRegions(EntryCreation.MythicPlusRating.EditBox)
    EntryCreation.Name:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 4)
    GW.HandleBlizzardRegions(EntryCreation.Name)
    EntryCreation.PVPRating.EditBox:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 4)
    GW.HandleBlizzardRegions(EntryCreation.PVPRating.EditBox)
    EntryCreation.PvpItemLevel.EditBox:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 4)
    GW.HandleBlizzardRegions(EntryCreation.PvpItemLevel.EditBox)
    EntryCreation.VoiceChat.EditBox:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 4)
    GW.HandleBlizzardRegions(EntryCreation.VoiceChat.EditBox)

    EntryCreation.GroupDropdown:GwHandleDropDownBox()
    EntryCreation.ActivityDropdown:GwHandleDropDownBox()
    EntryCreation.PlayStyleDropdown:GwHandleDropDownBox()

    EntryCreation.CrossFactionGroup.CheckButton:GwSkinCheckButton()
    EntryCreation.ItemLevel.CheckButton:GwSkinCheckButton()
    EntryCreation.MythicPlusRating.CheckButton:GwSkinCheckButton()
    EntryCreation.PrivateGroup.CheckButton:GwSkinCheckButton()
    EntryCreation.PVPRating.CheckButton:GwSkinCheckButton()
    EntryCreation.PvpItemLevel.CheckButton:GwSkinCheckButton()
    EntryCreation.VoiceChat.CheckButton:GwSkinCheckButton()

    EntryCreation.CrossFactionGroup.CheckButton:SetSize(15, 15)
    EntryCreation.ItemLevel.CheckButton:SetSize(15, 15)
    EntryCreation.MythicPlusRating.CheckButton:SetSize(15, 15)
    EntryCreation.PrivateGroup.CheckButton:SetSize(15, 15)
    EntryCreation.PVPRating.CheckButton:SetSize(15, 15)
    EntryCreation.PvpItemLevel.CheckButton:SetSize(15, 15)
    EntryCreation.VoiceChat.CheckButton:SetSize(15, 15)

    EntryCreation.ActivityFinder.Dialog:GwStripTextures()
    EntryCreation.ActivityFinder.Dialog.BorderFrame:GwStripTextures()

    EntryCreation.ActivityFinder.Dialog.EntryBox:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true, 4)
    GW.HandleBlizzardRegions(EntryCreation.ActivityFinder.Dialog.EntryBox)
    EntryCreation.ActivityFinder.Dialog.SelectButton:GwSkinButton(false, true)
    EntryCreation.ActivityFinder.Dialog.CancelButton:GwSkinButton(false, true)

    LFGListApplicationDialog:GwStripTextures()
    LFGListApplicationDialog.SignUpButton:GwSkinButton(false, true)
    LFGListApplicationDialog.CancelButton:GwSkinButton(false, true)
    GW.HandleBlizzardRegions(LFGListApplicationDialogDescription)
    GW.SkinTextBox(LFGListApplicationDialogDescription.MiddleTex, LFGListApplicationDialogDescription.LeftTex, LFGListApplicationDialogDescription.RightTex, LFGListApplicationDialogDescription.TopTex, LFGListApplicationDialogDescription.BottomTex)
    LFGListApplicationDialog:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)

    LFGListInviteDialog:GwStripTextures()
    LFGListInviteDialog:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder)
    LFGListInviteDialog.AcknowledgeButton:GwSkinButton(false, true)
    LFGListInviteDialog.AcceptButton:GwSkinButton(false, true)
    LFGListInviteDialog.DeclineButton:GwSkinButton(false, true)

    GW.SkinTextBox(LFGListFrame.SearchPanel.SearchBox.Middle, LFGListFrame.SearchPanel.SearchBox.Left, LFGListFrame.SearchPanel.SearchBox.Right)
    LFGListFrame.SearchPanel.BackButton:GwSkinButton(false, true)
    LFGListFrame.SearchPanel.SignUpButton:GwSkinButton(false, true)
    LFGListFrame.SearchPanel.BackButton:ClearAllPoints()
    LFGListFrame.SearchPanel.BackButton:SetPoint("BOTTOMLEFT", -1, 3)
    LFGListFrame.SearchPanel.SignUpButton:ClearAllPoints()
    LFGListFrame.SearchPanel.SignUpButton:SetPoint("BOTTOMRIGHT", -6, 3)
    LFGListFrame.SearchPanel.ResultsInset:GwStripTextures()
    LFGListFrame.SearchPanel.CategoryName:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    GW.HandleTrimScrollBar(LFGListFrame.SearchPanel.ScrollBar, true)
    GW.HandleScrollControls(LFGListFrame.SearchPanel)

    hooksecurefunc(LFGListFrame.SearchPanel.ScrollBox, "Update", function(self)
        for _, child in next, {self.ScrollTarget:GetChildren()} do
            if not child.IsSkinned and child.Name then
                child.Name:SetTextColor(1, 1, 1)
                hooksecurefunc(child.Name, "SetTextColor", GW.LockWhiteButtonColor)
                GW.AddListItemChildHoverTexture(child)
                child.IsSkinned = true
            end
        end
        GW.HandleItemListScrollBoxHover(self)
    end)

    LFGListFrame.SearchPanel.FilterButton:GwSkinButton(false, true)
    LFGListFrame.SearchPanel.FilterButton:SetPoint("TOPRIGHT", LFGListFrame.SearchPanel, "TOPRIGHT", 0, -58)
    LFGListFrame.SearchPanel.RefreshButton:GwSkinButton(false, true)
    LFGListFrame.SearchPanel.BackToGroupButton:GwSkinButton(false, true)
    LFGListFrame.SearchPanel.RefreshButton:SetSize(24, 24)
    LFGListFrame.SearchPanel.RefreshButton.Icon:SetDesaturated(true)
    LFGListFrame.SearchPanel.RefreshButton.Icon:SetPoint("CENTER")

    hooksecurefunc("LFGListApplicationViewer_UpdateApplicant", function(button)
        if not button.DeclineButton.isSkinned then
            button.DeclineButton:GwSkinButton(false, true)
            if button.DeclineButton.Icon then
                button.DeclineButton.Icon:SetDrawLayer("ARTWORK", 7)
            end
        end
        if not button.InviteButton.isSkinned then
            button.InviteButton:GwSkinButton(false, true)
            if button.InviteButton.Icon then
                button.InviteButton.Icon:SetDrawLayer("ARTWORK", 7)
            end
        end
        if not button.InviteButtonSmall.isSkinned then
            button.InviteButtonSmall:GwSkinButton(false, true)
            if button.InviteButtonSmall.Icon then
                button.InviteButtonSmall.Icon:SetDrawLayer("ARTWORK", 7)
            end
        end
    end)

    hooksecurefunc("LFGListSearchEntry_Update", function(button)
        if not button.CancelButton.isSkinned then
            button.CancelButton:GwSkinButton(true)
            button.CancelButton:SetSize(18, 18)
        end
    end)

    hooksecurefunc("LFGListSearchPanel_UpdateAutoComplete", function(panel)
        for _, child in next, { LFGListFrame.SearchPanel.AutoCompleteFrame:GetChildren() } do
            if not child.isSkinned and child:IsObjectType("Button") then
                child:GwSkinButton(false, true)
                child.isSkinned = true
            end
        end

        local matchingActivities = C_LFGList.GetAvailableActivities(panel.categoryID, nil, panel.filters, panel.SearchBox:GetText())
        local numResults = min(#matchingActivities, MAX_LFG_LIST_SEARCH_AUTOCOMPLETE_ENTRIES)

        for i = 2, numResults do
            local button = panel.AutoCompleteFrame.Results[i]
            if button and not button.moved then
                button:SetPoint("TOPLEFT", panel.AutoCompleteFrame.Results[i-1], "BOTTOMLEFT", 0, -2)
                button:SetPoint("TOPRIGHT", panel.AutoCompleteFrame.Results[i-1], "BOTTOMRIGHT", 0, -2)
                button.moved = true
            end
        end
        panel.AutoCompleteFrame:SetHeight(numResults * (panel.AutoCompleteFrame.Results[1]:GetHeight() + 3.5) + 8)
    end)

    LFGListFrame.SearchPanel.AutoCompleteFrame:GwStripTextures()
    LFGListFrame.SearchPanel.AutoCompleteFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    LFGListFrame.SearchPanel.AutoCompleteFrame.backdrop:SetPoint("TOPLEFT", LFGListFrame.SearchPanel.AutoCompleteFrame, "TOPLEFT", 0, 3)
    LFGListFrame.SearchPanel.AutoCompleteFrame.backdrop:SetPoint("BOTTOMRIGHT", LFGListFrame.SearchPanel.AutoCompleteFrame, "BOTTOMRIGHT", 6, 3)

    LFGListFrame.SearchPanel.AutoCompleteFrame:SetPoint("TOPLEFT", LFGListFrame.SearchPanel.SearchBox, "BOTTOMLEFT", -2, -8)
    LFGListFrame.SearchPanel.AutoCompleteFrame:SetPoint("TOPRIGHT", LFGListFrame.SearchPanel.SearchBox, "BOTTOMRIGHT", -4, -8)

    --ApplicationViewer (Custom Groups)
    LFGListFrame.ApplicationViewer.EntryName:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
    LFGListFrame.ApplicationViewer.EntryName:SetFont(DAMAGE_TEXT_FONT, 16)
    LFGListFrame.ApplicationViewer.InfoBackground:Hide()
    --LFGListFrame.ApplicationViewer.InfoBackground:GwCreateBackdrop("Transparent")
    LFGListFrame.ApplicationViewer.AutoAcceptButton:GwSkinCheckButton()

    LFGListFrame.ApplicationViewer.Inset:GwStripTextures()
    LFGListFrame.ApplicationViewer.UnempoweredCover.Background:SetAlpha(0)
    LFGListFrame.ApplicationViewer.UnempoweredCover.Label:SetTextColor(1, 1, 1)
    LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot1:SetVertexColor(1, 1, 1)
    LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot2:SetVertexColor(1, 1, 1)
    LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot3:SetVertexColor(1, 1, 1)

    GW.AddDetailsBackground(LFGListFrame.ApplicationViewer.UnempoweredCover)

    GW.HandleScrollFrameHeaderButton(LFGListFrame.ApplicationViewer.NameColumnHeader)
    GW.HandleScrollFrameHeaderButton(LFGListFrame.ApplicationViewer.RoleColumnHeader)
    GW.HandleScrollFrameHeaderButton(LFGListFrame.ApplicationViewer.ItemLevelColumnHeader)
    GW.HandleScrollFrameHeaderButton(LFGListFrame.ApplicationViewer.RatingColumnHeader, true)
    LFGListFrame.ApplicationViewer.NameColumnHeader:ClearAllPoints()
    LFGListFrame.ApplicationViewer.NameColumnHeader:SetPoint("BOTTOMLEFT", LFGListFrame.ApplicationViewer.Inset, "TOPLEFT", 4, 1)
    LFGListFrame.ApplicationViewer.RoleColumnHeader:ClearAllPoints()
    LFGListFrame.ApplicationViewer.RoleColumnHeader:SetPoint("LEFT", LFGListFrame.ApplicationViewer.NameColumnHeader, "RIGHT", 1, 0)
    LFGListFrame.ApplicationViewer.ItemLevelColumnHeader:ClearAllPoints()
    LFGListFrame.ApplicationViewer.ItemLevelColumnHeader:SetPoint("LEFT", LFGListFrame.ApplicationViewer.RoleColumnHeader, "RIGHT", 1, 0)
    LFGListFrame.ApplicationViewer.RatingColumnHeader:ClearAllPoints()
    LFGListFrame.ApplicationViewer.RatingColumnHeader:SetPoint("LEFT", LFGListFrame.ApplicationViewer.ItemLevelColumnHeader, "RIGHT", 1, 0)

    LFGListFrame.ApplicationViewer.RefreshButton:GwSkinButton(false, true)
    LFGListFrame.ApplicationViewer.RefreshButton:SetSize(24, 24)
    LFGListFrame.ApplicationViewer.RefreshButton:ClearAllPoints()
    LFGListFrame.ApplicationViewer.RefreshButton:SetPoint("BOTTOMRIGHT", LFGListFrame.ApplicationViewer.Inset, "TOPRIGHT", 16, 4)
    LFGListFrame.ApplicationViewer.RefreshButton.Icon:SetDesaturated(true)

    LFGListFrame.ApplicationViewer.RemoveEntryButton:GwSkinButton(false, true)
    LFGListFrame.ApplicationViewer.EditButton:GwSkinButton(false, true)
    LFGListFrame.ApplicationViewer.BrowseGroupsButton:GwSkinButton(false, true)
    LFGListFrame.ApplicationViewer.EditButton:ClearAllPoints()
    LFGListFrame.ApplicationViewer.EditButton:SetPoint("BOTTOMRIGHT", -6, 3)
    LFGListFrame.ApplicationViewer.BrowseGroupsButton:ClearAllPoints()
    LFGListFrame.ApplicationViewer.BrowseGroupsButton:SetPoint("BOTTOMLEFT", -1, 3)
    LFGListFrame.ApplicationViewer.BrowseGroupsButton:SetSize(120, 22)

    GW.HandleTrimScrollBar(LFGListFrame.ApplicationViewer.ScrollBar, true)
    GW.HandleScrollControls(LFGListFrame.ApplicationViewer)

    hooksecurefunc(LFGListFrame.ApplicationViewer.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    hooksecurefunc("LFGListApplicationViewer_UpdateInfo", function(frame)
        frame.RemoveEntryButton:ClearAllPoints()

        if UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) then
            frame.RemoveEntryButton:SetPoint("RIGHT", frame.EditButton, "LEFT", -2, 0)
        else
            frame.RemoveEntryButton:SetPoint("BOTTOMLEFT", -1, 3)
        end
    end)

    hooksecurefunc("LFGListCategorySelection_AddButton", function(btn, btnIndex, categoryID, filters)
        local button = btn.CategoryButtons[btnIndex]
        if button then
            if not button.isSkinned then
                if not button.SetBackdrop then
                    _G.Mixin(button, _G.BackdropTemplateMixin)
                    button:HookScript("OnSizeChanged", button.OnBackdropSizeChanged)
                end
                button:SetBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)

                button.Icon:SetDrawLayer("BACKGROUND", 2)
                button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                button.Icon:GwSetInside()
                button.Cover:Hide()
                button.HighlightTexture:SetColorTexture(1, 1, 1, 0.1)
                button.HighlightTexture:GwSetInside()

                button.Label:SetFontObject("GameFontNormal")

                button.Label:SetTextColor(1, 1, 1)
                button.Label:SetShadowColor(0, 0, 0, 0)
                button.Label:SetShadowOffset(1, -1)

                hooksecurefunc(button.Label, "SetText", function()
                    if not button.Label.SetTextGw2 then
                        button.Label.SetTextGw2 = true
                        button.Label:SetText(button.Label:GetText():gsub("-\n", ""):gsub("\n", ""))
                        button.Label.SetTextGw2 = false
                    end
                end)

                button.isSkinned = true
            end

            button.SelectedTexture:Hide()
            local selected = btn.selectedCategory == categoryID and btn.selectedFilters == filters
            if selected then
                button:SetBackdropBorderColor(1, 1, 0)
            else
                button:SetBackdropBorderColor(0, 0, 0)
            end
        end
    end)

    C_Timer.After(2, function()
        if not GW.ShouldBlockIncompatibleAddon("LfgInfo") then
            local ReskinIcon = function(parent, icon, class, role)
                if role then
                    icon:SetAlpha(1)
                else
                    icon:SetAlpha(0)
                end

                if parent then
                    -- Create bar in class color behind
                    if class then
                        if not icon.line then
                            local line = parent:CreateTexture(nil, "ARTWORK")
                            line:SetTexture("Interface/Addons/GW2_UI/Textures/uistuff/gwstatusbar.png")
                            line:SetSize(16, 3)
                            line:SetPoint("TOP", icon, "BOTTOM", 0, -1)
                            icon.line = line
                        end

                        local color = GW.GWGetClassColor(class, true, false)
                        icon.line:SetVertexColor(color.r, color.g, color.b)
                        icon.line:SetAlpha(1)
                    elseif parent and icon.line then
                        icon.line:SetAlpha(0)
                    end
                end
            end

            hooksecurefunc("LFGListGroupDataDisplayEnumerate_Update", function(enumerate)
                local button = enumerate:GetParent():GetParent()
                if not button.resultID then
                    return
                end

                local result = C_LFGList.GetSearchResultInfo(button.resultID)

                if not result then
                    return
                end

                -- order in lfg view
                local cache = {
                    TANK = {},
                    HEALER = {},
                    DAMAGER = {}
                }

                for i = 1, result.numMembers do
                    local role, class = C_LFGList.GetSearchResultMemberInfo(button.resultID, i)
                    if role then
                        tinsert(cache[role], {class = class, role = role})
                    end
                end

                for i = 5, 1, -1 do -- The index of icon starts from right
                    local icon = enumerate["Icon" .. i]
                    if icon and icon.SetTexture then
                        if #cache.TANK > 0 then
                            ReskinIcon(enumerate, icon, cache.TANK[1].class, cache.TANK[1].role)
                            tremove(cache.TANK, 1)
                        elseif #cache.HEALER > 0 then
                            ReskinIcon(enumerate, icon, cache.HEALER[1].class, cache.HEALER[1].role)
                            tremove(cache.HEALER, 1)
                        elseif #cache.DAMAGER > 0 then
                            ReskinIcon(enumerate, icon, cache.DAMAGER[1].class, cache.DAMAGER[1].role)
                            tremove(cache.DAMAGER, 1)
                        else
                            ReskinIcon(enumerate, icon)
                        end
                    end
                end
            end)
        end
    end)

    GW.MakeFrameMovable(PVEFrame, nil, "PvEWindow", true)
    PVEFrame:SetClampedToScreen(true)
    PVEFrame:SetClampRectInsets(-40, 0, PVEFrameHeader:GetHeight() - 30, 0)
end

local function ApplyPvPUISkin()
    if not GW.settings.LFG_SKIN_ENABLED then return end

    PVPUIFrame:GwStripTextures()

    for i = 1, 4 do
        local bu = PVPQueueFrame["CategoryButton" .. i]
        bu.Ring:GwKill()
        bu.Background:GwKill()
        bu:GwSkinButton(false, true)

        bu:SetHeight(36)

        bu:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
        bu.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
        bu.limitHoverStripAmount = 1 --limit that value to 0.75 because we do not use the default hover texture
        if i % 2 == 1 then
            bu:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
        else
            bu:ClearNormalTexture()
        end

        bu.arrow = bu:CreateTexture(nil, "OVERLAY")
        bu.arrow:SetSize(10, 20)
        bu.arrow:SetPoint("RIGHT", bu, "RIGHT", 0, 0)
        bu.arrow:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-arrow.png")

        bu.Name:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
        bu.Name:SetShadowColor(0, 0, 0, 0)
        bu.Name:SetShadowOffset(1, -1)
        bu.Name:SetJustifyH("LEFT")
        bu.Name:SetPoint("LEFT", bu, "LEFT", 5, 0)
        bu.Name:SetWidth(bu:GetWidth())
        bu.Name:SetText(bu.Name:GetText():gsub("-|n", ""):gsub("|n", ""))

        hooksecurefunc(bu.Name, "SetText", function()
            if not bu.Name.SetTextGw2 then
                bu.Name.SetTextGw2 = true
                bu.Name:SetText(bu.Name:GetText():gsub("-|n", ""):gsub("|n", ""))
                bu.Name.SetTextGw2 = false
            end
        end)

        bu.gwBorderFrame:Hide()

        bu.Icon:Hide()

        bu:ClearAllPoints()
        if i == 1 then
            bu:SetPoint("TOPLEFT", 10, -40)
        else
            bu:SetPoint("TOP", PVPQueueFrame["CategoryButton" .. i - 1], "BOTTOM", 0, 0)
        end
    end
    hooksecurefunc("PVPQueueFrame_SelectButton", function(idx)
        for i = 1, 4 do
            local bu = PVPQueueFrame["CategoryButton" .. i]
            if i == idx then
                bu.hover.skipHover = true
                bu.hover:SetAlpha(1)
                bu.hover:SetPoint("RIGHT", bu, "LEFT", bu:GetWidth(), 0)
            else
                bu.hover.skipHover = false
                bu.hover:SetAlpha(1)
                bu.hover:SetPoint("RIGHT", bu, "LEFT", 0, 0)
            end
        end
    end)

    PVPQueueFrame.HonorInset:GwStripTextures()
    PVPQueueFrame.HonorInset.Background:GwKill()

    local SEASON_STATE_OFFSEASON = 1
    hooksecurefunc(PVPQueueFrame.HonorInset.RatedPanel, "Update", function(self)
        local seasonState = ConquestFrame.seasonState
        if seasonState == SEASON_STATE_OFFSEASON then
			self.Tier.Title:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
		else
			self.Tier.Title:SetTextColor(1, 1, 1)
		end
    end)

    if PlunderstormFrame then
        PlunderstormFrame.Inset:GwStripTextures()
        PlunderstormFrame.StartQueue:GwSkinButton(false, true)
        PlunderstormFrame.BasicsTitle:SetTextColor(GW.TextColors.LIGHT_HEADER.r,GW.TextColors.LIGHT_HEADER.g,GW.TextColors.LIGHT_HEADER.b)
        PVPQueueFrame.HonorInset.PlunderstormPanel.PlunderstoreButton:GwSkinButton(false, true)
    end

    local SeasonReward = PVPQueueFrame.HonorInset.RatedPanel.SeasonRewardFrame
    SeasonReward:GwCreateBackdrop()
    SeasonReward.Icon:GwSetInside(SeasonReward.backdrop)
    SeasonReward.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    SeasonReward.CircleMask:Hide()
    SeasonReward.Ring:Hide()

    for _, region in next, { SeasonReward:GetRegions() } do
        if region:IsObjectType("FontString") then
            region:SetTextColor(1, 1, 1)
        end
    end

    -- Honor Frame
    local HonorFrame = _G.HonorFrame
    HonorFrame:GwStripTextures()
    ConquestFrame:GwStripTextures()

    for _, v in pairs({ HonorFrame, ConquestFrame, LFGListPVPStub, TrainingGroundsFrame }) do
        GW.AddDetailsBackground(v, nil, -10)
    end

    LFGListPVPStub.tex:ClearAllPoints()
    LFGListPVPStub.tex:SetPoint("TOPLEFT", LFGListPVPStub, "TOPLEFT", 0, -31)
    LFGListPVPStub.tex:SetPoint("BOTTOMRIGHT", LFGListPVPStub, "BOTTOMRIGHT", 0, 0)

    GW.HandleTrimScrollBar(HonorFrame.SpecificScrollBar, true)
    GW.HandleScrollControls(HonorFrame, "SpecificScrollBar")
    HonorFrameTypeDropdown:GwHandleDropDownBox()
    HonorFrameQueueButton:GwSkinButton(false, true)

    local BonusFrame = HonorFrame.BonusFrame
    BonusFrame:GwStripTextures()
    BonusFrame.ShadowOverlay:Hide()
    BonusFrame.WorldBattlesTexture:Hide()

    for _, bonusButton in pairs({"RandomBGButton", "Arena1Button", "RandomEpicBGButton", "BrawlButton", "BrawlButton2"}) do
        local bu = BonusFrame[bonusButton]
        local reward = bu.Reward

        reward.Border:Hide()
        reward.CircleMask:Hide()
        GW.HandleIcon(reward.Icon)
        reward.Icon:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder , true)

        reward.EnlistmentBonus:GwStripTextures()
        reward.EnlistmentBonus:SetSize(20, 20)
        reward.EnlistmentBonus:SetPoint("TOPRIGHT", 2, 2)

        local EnlistmentBonusIcon = reward.EnlistmentBonus:CreateTexture()
        EnlistmentBonusIcon:SetPoint("TOPLEFT", reward.EnlistmentBonus, "TOPLEFT", 2, -2)
        EnlistmentBonusIcon:SetPoint("BOTTOMRIGHT", reward.EnlistmentBonus, "BOTTOMRIGHT", -2, 2)
        EnlistmentBonusIcon:SetTexture([[Interface\Icons\achievement_guildperk_honorablemention_rank2]])
        EnlistmentBonusIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end

    -- Honor Frame Specific Buttons
    hooksecurefunc(HonorFrame.SpecificScrollBox, "Update", function (box)
        for _, bu in next, {box.ScrollTarget:GetChildren()} do
            if not bu.IsSkinned then
                bu.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                bu.Icon:SetPoint("TOPLEFT", 5, -3)

                bu.IsSkinned = true
            end
        end
    end)

    hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(s)
        if s.bg then s.bg:SetDesaturated(true) end
    end)

    HonorFrame.RoleList.TankIcon.checkButton:GwSkinCheckButton()
    HonorFrame.RoleList.HealerIcon.checkButton:GwSkinCheckButton()
    HonorFrame.RoleList.DPSIcon.checkButton:GwSkinCheckButton()
    HonorFrame.RoleList.TankIcon.checkButton:SetSize(15, 15)
    HonorFrame.RoleList.HealerIcon.checkButton:SetSize(15, 15)
    HonorFrame.RoleList.DPSIcon.checkButton:SetSize(15, 15)

    -- Conquest Frame
    ConquestFrame.ShadowOverlay:Hide()

    ConquestJoinButton:GwSkinButton(false, true)

    ConquestFrame.RoleList.TankIcon.checkButton:GwSkinCheckButton()
    ConquestFrame.RoleList.HealerIcon.checkButton:GwSkinCheckButton()
    ConquestFrame.RoleList.DPSIcon.checkButton:GwSkinCheckButton()
    ConquestFrame.RoleList.TankIcon.checkButton:SetSize(15, 15)
    ConquestFrame.RoleList.HealerIcon.checkButton:SetSize(15, 15)
    ConquestFrame.RoleList.DPSIcon.checkButton:SetSize(15, 15)

    for _, bu in pairs({ConquestFrame.RatedSoloShuffle, ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.RatedBG}) do
        local reward = bu.Reward
        reward.Border:Hide()
        reward.CircleMask:Hide()
        GW.HandleIcon(reward.Icon)
        reward.Icon:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
    end

    -- Item Borders for HonorFrame & ConquestFrame
    hooksecurefunc("PVPUIFrame_ConfigureRewardFrame", function(rewardFrame, _, _, itemRewards, currencyRewards)
        local rewardTexture, rewardQuaility, _ = nil, 1, nil

        if currencyRewards then
            for _, reward in ipairs(currencyRewards) do
                local info = C_CurrencyInfo.GetCurrencyInfo(reward.id)
                if info and info.quality == ITEMQUALITY_ARTIFACT then
                    _, rewardTexture, _, rewardQuaility = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.id, reward.quantity, info.name, info.iconFileID, info.quality)
                end
            end
        end

        if not rewardTexture and itemRewards then
            local reward = itemRewards[1]
            if reward then
                _, _, rewardQuaility, _, _, _, _, _, _, rewardTexture = C_Item.GetItemInfo(reward.id)
            end
        end
        if rewardTexture then
            local color = GW.GetQualityColor(rewardQuaility)
            rewardFrame.Icon:SetTexture(rewardTexture)
            if not rewardFrame.Icon.backdrop then
                rewardFrame.Icon:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
            end
            rewardFrame.Icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
        end
    end)

    if GW.settings.TOOLTIPS_ENABLED then
        ConquestTooltip.NineSlice:Hide()
        ConquestTooltip:GwCreateBackdrop({
            bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png",
            edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-border.png",
            edgeSize = GW.Scale(32),
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        })
    end

    -- PvP StatusBars
    for _, Frame in pairs({ HonorFrame, ConquestFrame }) do
        Frame.ConquestBar.Border:Hide()
        Frame.ConquestBar.Background:Hide()
        Frame.ConquestBar.Reward.Ring:Hide()
        Frame.ConquestBar.Reward.CircleMask:Hide()
        if not Frame.ConquestBar.SetBackdrop then
            _G.Mixin(Frame.ConquestBar, _G.BackdropTemplateMixin)
            Frame.ConquestBar:HookScript("OnSizeChanged", Frame.ConquestBar.OnBackdropSizeChanged)
        end
        Frame.ConquestBar:SetBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)

        Frame.ConquestBar.Reward:ClearAllPoints()
        Frame.ConquestBar.Reward:SetPoint("LEFT", Frame.ConquestBar, "RIGHT", 0, 0)
        GW.HandleIcon(Frame.ConquestBar.Reward.Icon, true)
    end

    -- New Season Frame
    local NewSeasonPopup = _G.PVPQueueFrame.NewSeasonPopup
    NewSeasonPopup.Leave:GwSkinButton(false, true)
    NewSeasonPopup:GwStripTextures()
    if not NewSeasonPopup.SetBackdrop then
        _G.Mixin(NewSeasonPopup, _G.BackdropTemplateMixin)
        NewSeasonPopup:HookScript("OnSizeChanged", NewSeasonPopup.OnBackdropSizeChanged)
    end
    NewSeasonPopup:SetBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
    NewSeasonPopup:SetFrameLevel(5)

    local RewardFrame = NewSeasonPopup.SeasonRewardFrame
    RewardFrame:GwCreateBackdrop()
    RewardFrame.CircleMask:Hide()
    RewardFrame.Ring:Hide()
    RewardFrame.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    RewardFrame.backdrop:GwSetOutside(RewardFrame.Icon)

    if NewSeasonPopup.NewSeason then
        NewSeasonPopup.NewSeason:SetTextColor(1, 0.8, 0)
        NewSeasonPopup.NewSeason:SetShadowOffset(1, -1)
    end

    if NewSeasonPopup.SeasonRewardText then
        NewSeasonPopup.SeasonRewardText:SetTextColor(1, 0.8, 0)
        NewSeasonPopup.SeasonRewardText:SetShadowOffset(1, -1)
    end

    if NewSeasonPopup.SeasonDescriptionHeader then
        NewSeasonPopup.SeasonDescriptionHeader:SetTextColor(0, 0, 0)
        NewSeasonPopup.SeasonDescriptionHeader:SetShadowOffset(1, -1)
    end

    NewSeasonPopup:HookScript("OnShow", function(popup)
        if popup.SeasonDescriptions then
            for _, text in next, popup.SeasonDescriptions do
                text:SetTextColor(1, 1, 1)
                text:SetShadowOffset(1, -1)
            end
        end
    end)

    --12.0 Training Ground
    TrainingGroundsFrame.QueueButton:GwSkinButton(false, true)
    TrainingGroundsFrameTypeDropdown:GwHandleDropDownBox()
    TrainingGroundsFrame.BonusTrainingGroundList.ShadowOverlay:Hide()
    TrainingGroundsFrame.BonusTrainingGroundList.WorldBattlesTexture:Hide()
    GW.HandleTrimScrollBar(TrainingGroundsFrame.SpecificTrainingGroundList.ScrollBar)
    TrainingGroundsFrame.Inset:GwStripTextures()
    TrainingGroundsFrame.RoleList.TankIcon.checkButton:GwSkinCheckButton()
    TrainingGroundsFrame.RoleList.HealerIcon.checkButton:GwSkinCheckButton()
    TrainingGroundsFrame.RoleList.DPSIcon.checkButton:GwSkinCheckButton()
    TrainingGroundsFrame.RoleList.TankIcon.checkButton:SetSize(15, 15)
    TrainingGroundsFrame.RoleList.HealerIcon.checkButton:SetSize(15, 15)
    TrainingGroundsFrame.RoleList.DPSIcon.checkButton:SetSize(15, 15)

end

local function ApplyChallengesUISkin()
    if not GW.settings.LFG_SKIN_ENABLED then return end

    ChallengesFrame:DisableDrawLayer("BACKGROUND")
    ChallengesFrameInset:GwStripTextures()

    ChallengesFrame.WeeklyInfo.Child.Description:SetTextColor(1, 1, 1)

    -- Mythic+ KeyStoneFrame
    local tex = ChallengesKeystoneFrame:CreateTexture(nil, "BACKGROUND")
    tex:SetPoint("TOP", ChallengesKeystoneFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
    local w, h = ChallengesKeystoneFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    ChallengesKeystoneFrame.tex = tex

    ChallengesKeystoneFrame.CloseButton:GwSkinButton(true)
    ChallengesKeystoneFrame.CloseButton:SetSize(20, 20)
    ChallengesKeystoneFrame.StartButton:GwSkinButton(false, true)
    GW.HandleIcon(ChallengesKeystoneFrame.KeystoneSlot.Texture, true)

    ChallengesKeystoneFrame.DungeonName:SetFont(DAMAGE_TEXT_FONT, 26, "OUTLINE")
    ChallengesKeystoneFrame.TimeLimit:SetFont(DAMAGE_TEXT_FONT, 20, "OUTLINE")

    ChallengesKeystoneFrame.KeystoneSlot:HookScript("OnEvent", function(frame, event, itemID)
        if event == "CHALLENGE_MODE_KEYSTONE_SLOTTED" and frame.Texture then
            local texture = select(10, C_Item.GetItemInfo(itemID))
            if texture then
                frame.Texture:SetTexture(texture)
            end
        end
    end)

    hooksecurefunc(ChallengesKeystoneFrame, "OnKeystoneSlotted", HandleAffixIcons)

    hooksecurefunc(ChallengesFrame, "Update", function(frame)
        for _, child in ipairs(frame.DungeonIcons) do
            if not child.isSkinned then
                child:GetRegions():SetAlpha(0)
                if not child.SetBackdrop then
                    _G.Mixin(child, _G.BackdropTemplateMixin)
                    child:HookScript("OnSizeChanged", child.OnBackdropSizeChanged)
                end
                child:SetBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
                child:SetBackdropBorderColor(1, 0.99, 0.85)

                if child.mapID then
                    local _, overAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(child.mapID)
                    if overAllScore then
                        local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(overAllScore)
                        child:SetBackdropBorderColor(color.r, color.g, color.b)
                    end
                end

                GW.HandleIcon(child.Icon, true)
                child.Icon:SetDrawLayer("ARTWORK")
                child.HighestLevel:SetDrawLayer("OVERLAY")
                child.Icon:GwSetInside()

                child.isSkinned = true
            end
        end
    end)

    hooksecurefunc(ChallengesFrame.WeeklyInfo, "SetUp", function(info)
        if C_MythicPlus.GetCurrentAffixes() then
            HandleAffixIcons(info.Child)
        end
    end)

    hooksecurefunc(ChallengesKeystoneFrame, "Reset", function(frame)
        frame:GetRegions():SetAlpha(0)
        frame.InstructionBackground:SetAlpha(0)
        frame.KeystoneSlotGlow:Hide()
        frame.SlotBG:Hide()
        frame.KeystoneFrame:Hide()
        frame.Divider:Hide()
    end)

    -- New Season Frame
    local NoticeFrame = ChallengesFrame.SeasonChangeNoticeFrame
    NoticeFrame.Leave:GwSkinButton(false, true)
    NoticeFrame:GwStripTextures()

    if not NoticeFrame.SetBackdrop then
        _G.Mixin(NoticeFrame, _G.BackdropTemplateMixin)
        NoticeFrame:HookScript("OnSizeChanged", NoticeFrame.OnBackdropSizeChanged)
    end
    NoticeFrame:SetBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
    NoticeFrame:SetBackdropBorderColor(1, 1, 1)

    NoticeFrame:SetFrameLevel(5)
    NoticeFrame.NewSeason:SetTextColor(1, 0.8, 0)
    NoticeFrame.NewSeason:SetShadowOffset(1, -1)
    NoticeFrame.SeasonDescription:SetTextColor(1, 1, 1)
    NoticeFrame.SeasonDescription:SetShadowOffset(1, -1)
    NoticeFrame.SeasonDescription2:SetTextColor(1, 1, 1)
    NoticeFrame.SeasonDescription2:SetShadowOffset(1, -1)
    NoticeFrame.SeasonDescription3:SetTextColor(1, 0.8, 0)
    NoticeFrame.SeasonDescription3:SetShadowOffset(1, -1)

    local affix = NoticeFrame.Affix
    affix.AffixBorder:Hide()
    affix.Portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    hooksecurefunc(affix, "SetUp", function(_, affixID)
        local _, _, texture = C_ChallengeMode.GetAffixInfo(affixID)
        if texture then
            affix.Portrait:SetTexture(texture)
        end
    end)
end

local function ApplyDelvesDashboardUISkin()
    if not GW.settings.LFG_SKIN_ENABLED then return end

    DelvesDashboardFrame.DashboardBackground:SetAlpha(0)
    DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel.CompanionConfigButton:GwSkinButton(false, true)
    hooksecurefunc(DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel.CompanionConfigButton.ButtonText, "SetTextColor", GW.LockBlackButtonColor)
end

local function ApplyDelvesDifficultyPickerSkin()
    if not GW.settings.LFG_SKIN_ENABLED then return end

    local backround = DelvesDifficultyPickerFrame.DelveBackgroundWidgetContainer
    DelvesDifficultyPickerFrame:GwStripTextures()

    local tex = backround:CreateTexture(nil, "BACKGROUND", nil, -7)
    tex:SetPoint("TOP", DelvesDifficultyPickerFrame, "TOP", 0, 25)
    tex:SetTexture("Interface/AddOns/GW2_UI/textures/party/manage-group-bg.png")
    local w, h = DelvesDifficultyPickerFrame:GetSize()
    tex:SetSize(w + 50, h + 50)
    backround.tex = tex


    DelvesDifficultyPickerFrame.Dropdown:GwHandleDropDownBox()
    DelvesDifficultyPickerFrame.EnterDelveButton:GwSkinButton(false, true)
    DelvesDifficultyPickerFrame.CloseButton:GwSkinButton(true)
    DelvesDifficultyPickerFrame.CloseButton:SetSize(20, 20)

    DelvesDifficultyPickerFrame.ScenarioLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.TextSizeType.NORMAL)
    DelvesDifficultyPickerFrame.Description:SetTextColor(1, 1, 1)

    DelvesDifficultyPickerFrame.DelveRewardsContainerFrame.RewardText:SetTextColor(1, 1, 1)

    hooksecurefunc(DelvesDifficultyPickerFrame.DelveRewardsContainerFrame, "SetRewards", function(self)
        C_Timer.After(0, function()
            for rewardFrame in self.rewardPool:EnumerateActive() do
                if not rewardFrame.IsSkinned then
                    rewardFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
                    rewardFrame.NameFrame:SetAlpha(0)
                    rewardFrame.IconBorder:SetAlpha(0)
                    GW.HandleIcon(rewardFrame.Icon)

                    rewardFrame.IsSkinned = true
                end
            end
        end)
    end)
end

local function LoadLFGSkin()
    GW.RegisterLoadHook(ApplyChallengesUISkin, "Blizzard_ChallengesUI", ChallengesFrame)
    GW.RegisterLoadHook(ApplyPvPUISkin, "Blizzard_PVPUI", PVPUIFrame)
    GW.RegisterLoadHook(ApplyDelvesDashboardUISkin, "Blizzard_DelvesDashboardUI", DelvesDashboardFrame)
    GW.RegisterLoadHook(ApplyDelvesDifficultyPickerSkin, "Blizzard_DelvesDifficultyPicker", DelvesDifficultyPickerFrame)

    SkinLookingForGroupFrames()
end
GW.LoadLFGSkin = LoadLFGSkin