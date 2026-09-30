---@class GW2
local GW = select(2, ...)

-- blizzard frames without the backdrop mixin get it for our backdrop
local function SetFrameBackdrop(frame, template)
    if not frame.SetBackdrop then
        Mixin(frame, BackdropTemplateMixin)
        frame:HookScript("OnSizeChanged", frame.OnBackdropSizeChanged)
    end
    frame:SetBackdrop(template)
end

-- our menu and tile labels stay on one line; blizzards texts break with a newline or "|n",
-- a hyphen before it joins the word again
local joiningLines = false
local function JoinLines(label)
    local text = label:GetText()
    if joiningLines or GW.IsSecretValue(text) or not text then return end
    local joined = text:gsub("-\n", ""):gsub("-|n", ""):gsub("\n", " "):gsub("|n", " ")
    if joined ~= text then
        joiningLines = true
        label:SetText(joined)
        joiningLines = false
    end
end

-- the text already there and every one blizzard sets later
local function KeepOneLine(label)
    JoinLines(label)
    hooksecurefunc(label, "SetText", JoinLines)
end

-- a reward of the finders: the icon in a 42px frame on the left, the plate behind the name gone
local function SkinReward(button, icon, count, nameFrame, template)
    button:GwCreateBackdrop(template)
    button.backdrop:ClearAllPoints()
    button.backdrop:SetPoint("LEFT", 1, 0)
    button.backdrop:SetSize(42, 42)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:SetDrawLayer("OVERLAY")
    icon:GwSetInside(button.backdrop)
    count:SetDrawLayer("OVERLAY")
    nameFrame:SetTexture()
    nameFrame:SetSize(118, 39)
end

local function SkinMoneyReward(name)
    local button = _G[name]
    if not button.backdrop then
        SkinReward(button, _G[name .. "IconTexture"], _G[name .. "Count"], _G[name .. "NameFrame"])
    end
end

-- item rewards, the frame in their quality color; this works for the dungeon, raid and scenario finder
local function SkinItemReward(parentFrame, _, index, _, _, _, _, _, _, quality)
    local item = _G[parentFrame:GetName() .. "Item" .. index]
    if not item then return end
    if not item.backdrop then
        SkinReward(item, item.Icon, item.Count, item.NameFrame, GW.BackdropTemplates.ColorableBorderOnly)
        item.shortageBorder:SetTexture()
        item.IconBorder:GwKill()
    end
    if quality then
        local color = GW.GetBagItemQualityColor(quality)
        item.backdrop:SetBackdropBorderColor(color and color.r or 1, color and color.g or 1, color and color.b or 1)
    end
end

local function GetAffixTexture(affix)
    if affix.info then
        return CHALLENGE_MODE_EXTRA_AFFIX_INFO[affix.info.key].texture
    elseif affix.affixID then
        return select(3, C_ChallengeMode.GetAffixInfo(affix.affixID))
    end
end

-- the affixes of the week and of a slotted keystone as square icons; the keystone frame names its
-- dungeon and level in one line
local function SkinAffixes(frame)
    local mapID, _, level = C_ChallengeMode.GetSlottedKeystoneInfo()
    if mapID and frame.DungeonName then
        local mapName = C_ChallengeMode.GetMapUIInfo(mapID)
        if mapName and level then
            frame.DungeonName:SetText(mapName .. "|cffffffff - |r(" .. level .. ")")
        end
        frame.PowerLevel:SetText("")
    end

    local affixes = frame.AffixesContainer and frame.AffixesContainer.Affixes or frame.Affixes
    for _, affix in ipairs(affixes or {}) do
        affix.Border:SetTexture()
        if affix.CircleMask then
            affix.CircleMask:Hide()
        end
        affix.Portrait:SetTexture(GetAffixTexture(affix))
        GW.HandleIcon(affix.Portrait, true)
        affix.Percent:SetFont(DAMAGE_TEXT_FONT, 16, "OUTLINE")
    end
end

-- a season notice of the pvp or mythic+ tab: our frame, gold headings and white text
local function SkinSeasonNotice(notice)
    notice:GwStripTextures()
    SetFrameBackdrop(notice, GW.BackdropTemplates.DefaultWithColorableBorder)
    notice:SetFrameLevel(5)
    notice.Leave:GwSkinButton(false, true)
end

local function SetNoticeText(text, r, g, b)
    if text then
        text:SetTextColor(r, g, b)
        text:SetShadowOffset(1, -1)
    end
end

local function SkinLookingForGroupFrames()
    if not GW.settings.skins.lfg.enabled then return end

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
    PVEFrameTitleText:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader, nil, 6)

    -- copied from blizzard need to icon switching
    local panels = {
        { name = "GroupFinderFrame", addon = nil },
        { name = "PVPUIFrame", addon = "Blizzard_PVPUI" },
        { name = "ChallengesFrame", addon = "Blizzard_ChallengesUI", check = function() return UnitLevel("player") >= GetMaxLevelForPlayerExpansion(); end, hideLeftInset = true },
        { name = "DelvesDashboardFrame", addon = "Blizzard_DelvesDashboardUI", check = function() return GetExpansionLevel() >= LE_EXPANSION_WAR_WITHIN end, hideLeftInset = true },
    }

    local tabs = {PVEFrameTab1, PVEFrameTab2, PVEFrameTab3, PVEFrameTab4}
    for idx, tab in pairs(tabs) do
        if not tab.gwSkinned then
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

    -- the call to arms bonus of a role shows on the role icon, not in blizzards extra art
    for _, role in ipairs({"Tank", "Healer", "DPS"}) do
        _G["LFDQueueFrameRoleButton" .. role .. "IncentiveIcon"]:SetAlpha(0)
        _G["LFDQueueFrameRoleButton" .. role].shortageBorder:GwKill()
    end

    -- the role checks of the dungeon and raid finder and of the role poll
    for _, prefix in ipairs({"LFDQueueFrameRoleButton", "RaidFinderQueueFrameRoleButton", "RolePollPopupRoleButton"}) do
        for _, role in ipairs({"Tank", "Healer", "DPS", "Leader"}) do
            local button = _G[prefix .. role]
            if button then
                (button.checkButton or button.CheckButton):GwSkinCheckButton(false, 15)
            end
        end
    end

    hooksecurefunc("SetCheckButtonIsRadio", function(self)
        self:GwSkinCheckButton(false, 15)
    end)

    -- the checks of the application dialog sit in the corner of their role icon
    for _, key in ipairs({"TankButton", "HealerButton", "DamagerButton"}) do
        local check = LFGListApplicationDialog[key].CheckButton
        check:ClearAllPoints()
        check:SetPoint("BOTTOMLEFT", 0, 0)
    end

    -- the application dialog centers the roles the player can take; all three keep blizzards layout
    hooksecurefunc("LFGListApplicationDialog_UpdateRoles", function(dialog)
        local tank, healer, dps = C_LFGList.GetAvailableRoles()
        local roles = {}
        for i, button in ipairs({dialog.TankButton, dialog.HealerButton, dialog.DamagerButton}) do
            if select(i, tank, healer, dps) then
                tinsert(roles, button)
            end
        end
        if #roles == 1 then
            roles[1]:ClearAllPoints()
            roles[1]:SetPoint("TOP", dialog, "TOP", 0, -35)
        elseif #roles == 2 then
            roles[1]:ClearAllPoints()
            roles[1]:SetPoint("TOPRIGHT", dialog, "TOP", -40, -35)
            roles[2]:ClearAllPoints()
            roles[2]:SetPoint("TOPLEFT", dialog, "TOP", 40, -35)
        end
    end)

    -- blizzard hides the art and the check of a role that cannot be picked; the art stays (grey when
    -- the role is never available), the check only while it is set
    local function KeepRoleArt(button, grey)
        -- the pvp role buttons call it bg
        local art = button.background or button.bg
        if art then
            art:Show()
            if grey then
                art:SetDesaturated(true)
            end
        end
    end
    hooksecurefunc("LFG_DisableRoleButton", function(button)
        local check = button.checkButton
        check:SetAlpha(check:GetChecked() and 1 or 0)
        KeepRoleArt(button)
    end)
    hooksecurefunc("LFG_EnableRoleButton", function(button)
        button.checkButton:SetAlpha(1)
    end)
    hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(button)
        KeepRoleArt(button, true)
    end)

    -- the menu of the group finder: our menu rows with an arrow, one line of text each
    local function SkinGroupButton(button, index)
        button.ring:GwKill()
        button.bg:GwKill()
        button.icon:Hide()
        button:GwSkinButton(false, true)
        button.gwBorderFrame:Hide()
        button:SetHeight(36)
        -- every other row is a little lighter
        if index % 2 == 1 then
            button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/character/menu-bg.png")
        else
            button:ClearNormalTexture()
        end
        button.hover:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-hover.png")
        button.limitHoverStripAmount = 1 -- our hover texture needs the full strip

        button.arrow = button:CreateTexture(nil, "OVERLAY")
        button.arrow:SetSize(10, 20)
        button.arrow:SetPoint("RIGHT", button, "RIGHT", 0, 0)
        button.arrow:SetTexture("Interface/AddOns/GW2_UI/textures/character/menu-arrow.png")

        local name = button.name
        name:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        name:SetJustifyH("LEFT")
        name:SetPoint("LEFT", button, "LEFT", 5, 0)
        name:SetWidth(button:GetWidth())
        KeepOneLine(name)
    end

    hooksecurefunc("GroupFinderFrame_EvaluateButtonVisibility", function()
        for i = 1, 4 do
            local button = GroupFinderFrame["groupButton" .. i]
            -- GwSkinButton marks the button itself, the arrow tells ours apart
            if not button.arrow then
                SkinGroupButton(button, i)
            end
            button:ClearAllPoints()
            if i == 1 then
                button:SetPoint("TOPLEFT", 10, -40)
            else
                button:SetPoint("TOP", GroupFinderFrame["groupButton" .. i - 1], "BOTTOM", 0, 0)
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

    -- the scenario finder only exists in some seasons
    if ScenarioQueueFrame then
        for _, frame in ipairs({ScenarioQueueFrame, ScenarioFinderFrameInset, ScenarioQueueFrameSpecificScrollFrame}) do
            frame:GwStripTextures()
        end
        ScenarioQueueFrameBackground:SetAlpha(0)
        ScenarioQueueFrameTypeDropdown:GwHandleDropDownBox()
        ScenarioQueueFrameFindGroupButton:GwSkinButton(false, true)
        GW.HandleTrimScrollBar(ScenarioQueueFrameRandomScrollFrame.ScrollBar)
    end

    -- Raid finder
    LFDQueueFrameFindGroupButton:GwSkinButton(false, true)

    LFDParentFrame:GwStripTextures()
    LFDParentFrameInset:GwStripTextures()

    SkinMoneyReward("LFDQueueFrameRandomScrollFrameChildFrameMoneyReward")
    SkinMoneyReward("RaidFinderQueueFrameScrollFrameChildFrameMoneyReward")

    LFDQueueFrameRandomScrollFrameChildFrameTitle:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    LFDQueueFrameRandomScrollFrameChildFrameTitle:SetShadowColor(0, 0, 0, 0)
    LFDQueueFrameRandomScrollFrameChildFrameTitle:SetShadowOffset(1, -1)
    LFDQueueFrameRandomScrollFrameChildFrameTitle:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader)

    LFDQueueFrameRandomScrollFrameChildFrameRewardsLabel:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    LFDQueueFrameRandomScrollFrameChildFrameRewardsLabel:SetShadowColor(0, 0, 0, 0)
    LFDQueueFrameRandomScrollFrameChildFrameRewardsLabel:SetShadowOffset(1, -1)
    LFDQueueFrameRandomScrollFrameChildFrameRewardsLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader)

    LFDQueueFrameRandomScrollFrameChildFrameDescription:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    LFDQueueFrameRandomScrollFrameChildFrameRewardsDescription:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)

    GW.HandleTrimScrollBar(LFDQueueFrameRandomScrollFrame.ScrollBar)
    GW.HandleScrollControls(LFDQueueFrameRandomScrollFrame)

    -- dungeon groups of the specific list open and close with our arrows
    hooksecurefunc("LFGDungeonListButton_SetDungeon", function(button)
        local toggle = button and button.expandOrCollapseButton
        if toggle and toggle:IsShown() then
            local arrow = button.isCollapsed and "arrow_right" or "arrowdown_down"
            toggle:SetNormalTexture("Interface/AddOns/GW2_UI/Textures/uistuff/" .. arrow .. ".png")
        end
    end)

    LFDQueueFrameTypeDropdown:GwHandleDropDownBox()
    LFDQueueFrameTypeDropdown:ClearAllPoints()
    LFDQueueFrameTypeDropdown:SetPoint("BOTTOMLEFT", 40, 287)
    LFDQueueFrameTypeDropdown:SetWidth(300)
    LFDQueueFrameTypeDropdownName:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    LFDQueueFrameTypeDropdownName:ClearAllPoints()
    LFDQueueFrameTypeDropdownName:SetPoint("RIGHT", LFDQueueFrameTypeDropdown, "LEFT", 0, 0)

    RaidFinderFrameRoleInset:GwStripTextures()
    RaidFinderQueueFrameSelectionDropdown:GwHandleDropDownBox()
    RaidFinderQueueFrameSelectionDropdown:ClearAllPoints()
    RaidFinderQueueFrameSelectionDropdown:SetPoint("BOTTOMLEFT", 90, 287)
    RaidFinderQueueFrameSelectionDropdown:SetWidth(250)
    RaidFinderQueueFrameSelectionDropdownName:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    RaidFinderQueueFrameSelectionDropdownName:ClearAllPoints()
    RaidFinderQueueFrameSelectionDropdownName:SetPoint("RIGHT", RaidFinderQueueFrameSelectionDropdown, "LEFT", 0, 0)

    RaidFinderFrameFindRaidButton:GwStripTextures()
    RaidFinderFrameFindRaidButton:GwSkinButton(false, true)

    RaidFinderQueueFrameSelectionDropdownName:SetTextColor(GW.Colors.FallbackWhite:GetRGB())

    RaidFinderQueueFrameScrollFrameChildFrameTitle:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    RaidFinderQueueFrameScrollFrameChildFrameRewardsLabel:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    RaidFinderQueueFrameScrollFrameChildFrameTitle:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader)
    RaidFinderQueueFrameScrollFrameChildFrameRewardsLabel:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.Enum.TextSizeType.BigHeader)
    RaidFinderQueueFrameScrollFrameChildFrameDescription:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    RaidFinderQueueFrameScrollFrameChildFrameRewardsDescription:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)

    hooksecurefunc("LFGRewardsFrame_SetItemButton", SkinItemReward)

    GW.HandleTrimScrollBar(LFDQueueFrameSpecific.ScrollBar)
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

    LFGListFrame.CategorySelection.Label:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    LFGListFrame.CategorySelection.Label:SetShadowColor(0, 0, 0, 0)
    LFGListFrame.CategorySelection.Label:SetShadowOffset(1, -1)
    LFGListFrame.CategorySelection.Label:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Header)
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
    EntryCreation.Label:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    EntryCreation.Label:SetFont(DAMAGE_TEXT_FONT, 16)
    EntryCreation.NameLabel:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    EntryCreation.DescriptionLabel:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
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

    EntryCreation.CrossFactionGroup.CheckButton:GwSkinCheckButton(false, 15)
    EntryCreation.ItemLevel.CheckButton:GwSkinCheckButton(false, 15)
    EntryCreation.MythicPlusRating.CheckButton:GwSkinCheckButton(false, 15)
    EntryCreation.PrivateGroup.CheckButton:GwSkinCheckButton(false, 15)
    EntryCreation.PVPRating.CheckButton:GwSkinCheckButton(false, 15)
    EntryCreation.PvpItemLevel.CheckButton:GwSkinCheckButton(false, 15)
    EntryCreation.VoiceChat.CheckButton:GwSkinCheckButton(false, 15)

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
    LFGListFrame.SearchPanel.CategoryName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    GW.HandleTrimScrollBar(LFGListFrame.SearchPanel.ScrollBar)
    GW.HandleScrollControls(LFGListFrame.SearchPanel)

    hooksecurefunc(LFGListFrame.SearchPanel.ScrollBox, "Update", function(self)
        for _, child in next, {self.ScrollTarget:GetChildren()} do
            if not child.gwSkinned and child.Name then
                child.Name:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
                hooksecurefunc(child.Name, "SetTextColor", GW.LockWhiteButtonColor)
                GW.AddListItemChildHoverTexture(child)
                child.gwSkinned = true
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
        if not button.DeclineButton.gwSkinned then
            button.DeclineButton:GwSkinButton(false, true)
            if button.DeclineButton.Icon then
                button.DeclineButton.Icon:SetDrawLayer("ARTWORK", 7)
            end
        end
        if not button.InviteButton.gwSkinned then
            button.InviteButton:GwSkinButton(false, true)
            if button.InviteButton.Icon then
                button.InviteButton.Icon:SetDrawLayer("ARTWORK", 7)
            end
        end
        if not button.InviteButtonSmall.gwSkinned then
            button.InviteButtonSmall:GwSkinButton(false, true)
            if button.InviteButtonSmall.Icon then
                button.InviteButtonSmall.Icon:SetDrawLayer("ARTWORK", 7)
            end
        end
    end)

    hooksecurefunc("LFGListSearchEntry_Update", function(button)
        if not button.CancelButton.gwSkinned then
            button.CancelButton:GwSkinButton(true)
            button.CancelButton:SetSize(18, 18)
        end
    end)

    -- the suggestions below the search box as our buttons, a little apart from each other
    hooksecurefunc("LFGListSearchPanel_UpdateAutoComplete", function(panel)
        local autoComplete = panel.AutoCompleteFrame
        local shown = 0
        for i, button in ipairs(autoComplete.Results) do
            button:GwSkinButton(false, true)
            if i > 1 then
                button:SetPoint("TOPLEFT", autoComplete.Results[i - 1], "BOTTOMLEFT", 0, -2)
                button:SetPoint("TOPRIGHT", autoComplete.Results[i - 1], "BOTTOMRIGHT", 0, -2)
            end
            if button:IsShown() then
                shown = shown + 1
            end
        end
        if shown > 0 then
            autoComplete:SetHeight(shown * (autoComplete.Results[1]:GetHeight() + 3.5) + 8)
        end
    end)

    LFGListFrame.SearchPanel.AutoCompleteFrame:GwStripTextures()
    LFGListFrame.SearchPanel.AutoCompleteFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
    LFGListFrame.SearchPanel.AutoCompleteFrame.backdrop:SetPoint("TOPLEFT", LFGListFrame.SearchPanel.AutoCompleteFrame, "TOPLEFT", 0, 3)
    LFGListFrame.SearchPanel.AutoCompleteFrame.backdrop:SetPoint("BOTTOMRIGHT", LFGListFrame.SearchPanel.AutoCompleteFrame, "BOTTOMRIGHT", 6, 3)

    LFGListFrame.SearchPanel.AutoCompleteFrame:SetPoint("TOPLEFT", LFGListFrame.SearchPanel.SearchBox, "BOTTOMLEFT", -2, -8)
    LFGListFrame.SearchPanel.AutoCompleteFrame:SetPoint("TOPRIGHT", LFGListFrame.SearchPanel.SearchBox, "BOTTOMRIGHT", -4, -8)

    --ApplicationViewer (Custom Groups)
    LFGListFrame.ApplicationViewer.EntryName:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
    LFGListFrame.ApplicationViewer.EntryName:SetFont(DAMAGE_TEXT_FONT, 16)
    LFGListFrame.ApplicationViewer.InfoBackground:Hide()
    --LFGListFrame.ApplicationViewer.InfoBackground:GwCreateBackdrop("Transparent")
    LFGListFrame.ApplicationViewer.AutoAcceptButton:GwSkinCheckButton()

    LFGListFrame.ApplicationViewer.Inset:GwStripTextures()
    LFGListFrame.ApplicationViewer.UnempoweredCover.Background:SetAlpha(0)
    LFGListFrame.ApplicationViewer.UnempoweredCover.Label:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
    LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot1:SetVertexColor(GW.Colors.FallbackWhite:GetRGB())
    LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot2:SetVertexColor(GW.Colors.FallbackWhite:GetRGB())
    LFGListFrame.ApplicationViewer.UnempoweredCover.Waitdot3:SetVertexColor(GW.Colors.FallbackWhite:GetRGB())

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
    LFGListFrame.ApplicationViewer.RemoveEntryButton:GwSkinNegativeButton()
    LFGListFrame.ApplicationViewer.EditButton:GwSkinButton(false, true)
    LFGListFrame.ApplicationViewer.BrowseGroupsButton:GwSkinButton(false, true)
    LFGListFrame.ApplicationViewer.EditButton:ClearAllPoints()
    LFGListFrame.ApplicationViewer.EditButton:SetPoint("BOTTOMRIGHT", -6, 3)
    LFGListFrame.ApplicationViewer.BrowseGroupsButton:ClearAllPoints()
    LFGListFrame.ApplicationViewer.BrowseGroupsButton:SetPoint("BOTTOMLEFT", -1, 3)
    LFGListFrame.ApplicationViewer.BrowseGroupsButton:SetSize(120, 22)

    GW.HandleTrimScrollBar(LFGListFrame.ApplicationViewer.ScrollBar)
    GW.HandleScrollControls(LFGListFrame.ApplicationViewer)

    hooksecurefunc(LFGListFrame.ApplicationViewer.ScrollBox, "Update", GW.HandleItemListScrollBoxHover)

    -- the leader has the edit button, the remove button goes beside it; the others get the corner
    hooksecurefunc("LFGListApplicationViewer_UpdateInfo", function(frame)
        local remove = frame.RemoveEntryButton
        remove:ClearAllPoints()
        if UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) then
            remove:SetPoint("RIGHT", frame.EditButton, "LEFT", -2, 0)
        else
            remove:SetPoint("BOTTOMLEFT", -1, 3)
        end
    end)

    -- the category tiles of the premade groups: framed art, the selected one with a yellow frame

    hooksecurefunc("LFGListCategorySelection_AddButton", function(selection, index, categoryID, filters)
        local button = selection.CategoryButtons[index]
        if not button then return end
        if not button.gwSkinned then
            button.gwSkinned = true
            SetFrameBackdrop(button, GW.BackdropTemplates.DefaultWithColorableBorder)
            button.Cover:Hide()
            button.Icon:SetDrawLayer("BACKGROUND", 2)
            button.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            button.Icon:GwSetInside()
            button.HighlightTexture:SetColorTexture(1, 1, 1, 0.1)
            button.HighlightTexture:GwSetInside()

            -- one line on our narrower tiles
            local label = button.Label
            label:SetFontObject("GameFontNormal")
            label:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
            label:SetShadowColor(0, 0, 0, 0)
            label:SetShadowOffset(1, -1)
            KeepOneLine(label)
        end

        button.SelectedTexture:Hide()
        local selected = selection.selectedCategory == categoryID and selection.selectedFilters == filters
        button:SetBackdropBorderColor(selected and 1 or 0, selected and 1 or 0, 0)
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

                        local color = GW.GWGetClassColor(class, true)
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
                    local memberInfo = C_LFGList.GetSearchResultPlayerInfo(button.resultID, i)
                    if memberInfo and memberInfo.assignedRole then
                        tinsert(cache[memberInfo.assignedRole], {class = memberInfo.classFilename, role = memberInfo.assignedRole})
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

    GW.MakeFrameMovable(PVEFrame, nil, "lfg", true)
    PVEFrame:SetClampedToScreen(true)
    PVEFrame:SetClampRectInsets(-40, 0, PVEFrameHeader:GetHeight() - 30, 0)
end

-- the mode buttons of the pvp tabs: a dark frame, our hover, and a light frame while selected
local HOVER_TEXTURE = "Interface/AddOns/GW2_UI/textures/character/menu-hover.png"
local modeButtons = {}

local function UpdateModeSelection(selected)
    local button = modeButtons[selected]
    if button then
        local r, g, b = 0, 0, 0
        if selected:IsShown() then
            r, g, b = GW.Colors.TextColors.LightHeader:GetRGB()
        end
        button.backdrop:SetBackdropBorderColor(r, g, b)
    end
end

-- blizzard dims the art of a mode that cannot be queued, our frame dims with it
local function DimModeButton(normal, alpha)
    local button = modeButtons[normal]
    if button then
        button.backdrop:SetAlpha(alpha)
    end
end

local function SkinModeButton(button)
    -- emptied, not faded: blizzard sets the alpha of its art itself
    button.NormalTexture:SetTexture()
    button:GetPushedTexture():SetTexture()
    button:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true, 0, 0)
    -- dark on its own, the tabs below differ in brightness
    button.backdrop:SetBackdropColor(0.35, 0.35, 0.35, 1)
    modeButtons[button.NormalTexture] = button
    DimModeButton(button.NormalTexture, button.NormalTexture:GetAlpha())
    hooksecurefunc(button.NormalTexture, "SetAlpha", DimModeButton)

    button:SetHighlightTexture(HOVER_TEXTURE)
    local highlight = button:GetHighlightTexture()
    highlight:SetBlendMode("BLEND")
    highlight:SetVertexColor(GW.Colors.SkinColors.CardHover:GetRGBA())
    highlight:SetAllPoints(button)

    -- blizzards glow stays hidden, its state picks the color of our frame
    local selected = button.SelectedTexture
    selected:SetAlpha(0)
    modeButtons[selected] = button
    for _, method in ipairs({"Show", "Hide", "SetShown"}) do
        hooksecurefunc(selected, method, UpdateModeSelection)
    end
    UpdateModeSelection(selected)

    local reward = button.Reward
    if reward then
        reward.Border:Hide()
        reward.CircleMask:Hide()
        GW.HandleIcon(reward.Icon)
        reward.Icon:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
    end
end

-- the conquest and honor bars in our status bar look; blizzard picks the fill by state
local CONQUEST_FILL = {
    ["_pvpqueue-conquestbar-fill-yellow"] = CreateColor(1, 0.82, 0),
    ["_pvpqueue-conquestbar-fill-blue"] = CreateColor(0.3, 0.6, 1),
    ["_pvpqueue-conquestbar-fill-disabled"] = CreateColor(0.45, 0.45, 0.45),
}

local function RecolorConquestFill(fill, atlas)
    fill:SetTexture("Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar.png")
    fill:SetVertexColor((CONQUEST_FILL[atlas] or CONQUEST_FILL["_pvpqueue-conquestbar-fill-yellow"]):GetRGB())
end

local function SkinConquestBar(bar)
    for _, art in ipairs({bar.Border, bar.Background, bar.Reward.Ring, bar.Reward.CircleMask}) do
        art:Hide()
    end
    GW.AddStatusBarFrame(bar)
    RecolorConquestFill(bar.FillTexture, bar.FillTexture:GetAtlas())
    hooksecurefunc(bar.FillTexture, "SetAtlas", RecolorConquestFill)
    bar.Reward:ClearAllPoints()
    bar.Reward:SetPoint("LEFT", bar, "RIGHT", 4, 0)
    GW.HandleIcon(bar.Reward.Icon, true)
end

local function ApplyPvPUISkin()
    if not GW.settings.skins.lfg.enabled then return end

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

        bu.Name:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        bu.Name:SetShadowColor(0, 0, 0, 0)
        bu.Name:SetShadowOffset(1, -1)
        bu.Name:SetJustifyH("LEFT")
        bu.Name:SetPoint("LEFT", bu, "LEFT", 5, 0)
        bu.Name:SetWidth(bu:GetWidth())
        KeepOneLine(bu.Name)

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
            self.Tier.Title:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
        end
    end)

    if PlunderstormFrame then
        PlunderstormFrame.Inset:GwStripTextures()
        PlunderstormFrame.StartQueue:GwSkinButton(false, true)
        PlunderstormFrame.BasicsTitle:SetTextColor(GW.Colors.TextColors.LightHeader:GetRGB())
        PVPQueueFrame.HonorInset.PlunderstormPanel.PlunderstoreButton:GwSkinButton(false, true)
    end

    local SeasonReward = PVPQueueFrame.HonorInset.RatedPanel.SeasonRewardFrame
    SeasonReward:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder)
    SeasonReward.backdrop:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
    SeasonReward.Icon:GwSetInside(SeasonReward.backdrop)
    SeasonReward.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    SeasonReward.CircleMask:Hide()
    SeasonReward.Ring:Hide()

    for _, region in next, { SeasonReward:GetRegions() } do
        if region:IsObjectType("FontString") then
            region:SetTextColor(GW.Colors.FallbackWhite:GetRGB())
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

    GW.HandleTrimScrollBar(HonorFrame.SpecificScrollBar)
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
        SkinModeButton(bu)

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
            if not bu.gwSkinned then
                bu.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                bu.Icon:SetPoint("TOPLEFT", 5, -3)

                bu.gwSkinned = true
            end
        end
    end)


    HonorFrame.RoleList.TankIcon.checkButton:GwSkinCheckButton(false, 15)
    HonorFrame.RoleList.HealerIcon.checkButton:GwSkinCheckButton(false, 15)
    HonorFrame.RoleList.DPSIcon.checkButton:GwSkinCheckButton(false, 15)

    -- Conquest Frame
    ConquestFrame.ShadowOverlay:Hide()

    ConquestJoinButton:GwSkinButton(false, true)

    ConquestFrame.RoleList.TankIcon.checkButton:GwSkinCheckButton(false, 15)
    ConquestFrame.RoleList.HealerIcon.checkButton:GwSkinCheckButton(false, 15)
    ConquestFrame.RoleList.DPSIcon.checkButton:GwSkinCheckButton(false, 15)

    for _, key in ipairs({"RatedSoloShuffle", "RatedBGBlitz", "Arena2v2", "Arena3v3", "RatedBG"}) do
        if ConquestFrame[key] then
            SkinModeButton(ConquestFrame[key])
        end
    end

    -- the reward of a pvp mode: an artifact currency comes first, else the first item; its quality on our frame
    local function GetPvPReward(itemRewards, currencyRewards)
        for _, reward in ipairs(currencyRewards or {}) do
            local info = C_CurrencyInfo.GetCurrencyInfo(reward.id)
            if info and info.quality == ITEMQUALITY_ARTIFACT then
                local _, texture, _, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.id, reward.quantity, info.name, info.iconFileID, info.quality)
                return texture, quality
            end
        end
        local item = itemRewards and itemRewards[1]
        if item then
            local _, _, quality, _, _, _, _, _, _, texture = C_Item.GetItemInfo(item.id)
            return texture, quality
        end
    end

    hooksecurefunc("PVPUIFrame_ConfigureRewardFrame", function(rewardFrame, _, _, itemRewards, currencyRewards)
        local texture, quality = GetPvPReward(itemRewards, currencyRewards)
        if not texture then return end
        local icon = rewardFrame.Icon
        icon:SetTexture(texture)
        if not icon.backdrop then
            icon:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithColorableBorder, true)
        end
        local color = GW.GetQualityColor(quality or 1)
        icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
    end)

    if GW.settings.tooltip.enabled then
        ConquestTooltip.NineSlice:Hide()
        ConquestTooltip:GwCreateBackdrop({
            bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png",
            edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-border.png",
            edgeSize = GW.Scale(32),
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        })
    end

    -- the conquest bars of the honor, conquest and training grounds tab
    for _, tab in ipairs({HonorFrame, ConquestFrame, TrainingGroundsFrame}) do
        SkinConquestBar(tab.ConquestBar)
    end

    local seasonPopup = PVPQueueFrame.NewSeasonPopup
    SkinSeasonNotice(seasonPopup)
    local seasonReward = seasonPopup.SeasonRewardFrame
    seasonReward:GwCreateBackdrop()
    seasonReward.CircleMask:Hide()
    seasonReward.Ring:Hide()
    seasonReward.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    seasonReward.backdrop:GwSetOutside(seasonReward.Icon)
    SetNoticeText(seasonPopup.NewSeason, 1, 0.8, 0)
    SetNoticeText(seasonPopup.SeasonRewardText, 1, 0.8, 0)
    SetNoticeText(seasonPopup.SeasonDescriptionHeader, 0, 0, 0)
    seasonPopup:HookScript("OnShow", function(popup)
        for _, text in ipairs(popup.SeasonDescriptions or {}) do
            SetNoticeText(text, 1, 1, 1)
        end
    end)

    --12.0 Training Ground
    TrainingGroundsFrame.QueueButton:GwSkinButton(false, true)
    TrainingGroundsFrameTypeDropdown:GwHandleDropDownBox()
    TrainingGroundsFrame.BonusTrainingGroundList.ShadowOverlay:Hide()
    TrainingGroundsFrame.BonusTrainingGroundList.WorldBattlesTexture:Hide()
    for _, button in ipairs(TrainingGroundsFrame.BonusTrainingGroundList.BonusTrainingGroundButtons or {}) do
        SkinModeButton(button)
    end
    GW.HandleTrimScrollBar(TrainingGroundsFrame.SpecificTrainingGroundList.ScrollBar)
    TrainingGroundsFrame.Inset:GwStripTextures()
    TrainingGroundsFrame.RoleList.TankIcon.checkButton:GwSkinCheckButton(false, 15)
    TrainingGroundsFrame.RoleList.HealerIcon.checkButton:GwSkinCheckButton(false, 15)
    TrainingGroundsFrame.RoleList.DPSIcon.checkButton:GwSkinCheckButton(false, 15)
end

local function ApplyChallengesUISkin()
    if not GW.settings.skins.lfg.enabled then return end

    ChallengesFrame:DisableDrawLayer("BACKGROUND")
    ChallengesFrameInset:GwStripTextures()

    ChallengesFrame.WeeklyInfo.Child.Description:SetTextColor(GW.Colors.FallbackWhite:GetRGB())

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

    hooksecurefunc(ChallengesKeystoneFrame, "OnKeystoneSlotted", SkinAffixes)

    hooksecurefunc(ChallengesFrame, "Update", function(frame)
        for _, child in ipairs(frame.DungeonIcons) do
            if not child.gwSkinned then
                child:GetRegions():SetAlpha(0)
                SetFrameBackdrop(child, GW.BackdropTemplates.DefaultWithColorableBorder)
                child:SetBackdropBorderColor(GW.Colors.SkinColors.CreamBorder:GetRGB())

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

                child.gwSkinned = true
            end
        end
    end)

    hooksecurefunc(ChallengesFrame.WeeklyInfo, "SetUp", function(info)
        if C_MythicPlus.GetCurrentAffixes() then
            SkinAffixes(info.Child)
        end
    end)

    -- blizzard shows its slot art again whenever the keystone frame resets
    hooksecurefunc(ChallengesKeystoneFrame, "Reset", function(frame)
        frame:GetRegions():SetAlpha(0)
        frame.InstructionBackground:SetAlpha(0)
        for _, art in ipairs({frame.KeystoneSlotGlow, frame.SlotBG, frame.KeystoneFrame, frame.Divider}) do
            art:Hide()
        end
    end)

    local notice = ChallengesFrame.SeasonChangeNoticeFrame
    SkinSeasonNotice(notice)
    notice:SetBackdropBorderColor(GW.Colors.FallbackWhite:GetRGB())
    SetNoticeText(notice.NewSeason, 1, 0.8, 0)
    SetNoticeText(notice.SeasonDescription, 1, 1, 1)
    SetNoticeText(notice.SeasonDescription2, 1, 1, 1)
    SetNoticeText(notice.SeasonDescription3, 1, 0.8, 0)

    local affix = notice.Affix
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
    if not GW.settings.skins.lfg.enabled then return end

    DelvesDashboardFrame.DashboardBackground:SetAlpha(0)
    DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel.CompanionConfigButton:GwSkinButton(false, true)
    hooksecurefunc(DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel.CompanionConfigButton.ButtonText, "SetTextColor", GW.LockBlackButtonColor)
end

local function ApplyDelvesDifficultyPickerSkin()
    if not GW.settings.skins.lfg.enabled then return end

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

    DelvesDifficultyPickerFrame.ScenarioLabel:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Normal)
    DelvesDifficultyPickerFrame.Description:SetTextColor(GW.Colors.FallbackWhite:GetRGB())

    DelvesDifficultyPickerFrame.DelveRewardsContainerFrame.RewardText:SetTextColor(GW.Colors.FallbackWhite:GetRGB())

    hooksecurefunc(DelvesDifficultyPickerFrame.DelveRewardsContainerFrame, "SetRewards", function(self)
        C_Timer.After(0, function()
            for rewardFrame in self.rewardPool:EnumerateActive() do
                if not rewardFrame.gwSkinned then
                    rewardFrame:GwCreateBackdrop(GW.BackdropTemplates.DefaultWithSmallBorder, true)
                    rewardFrame.NameFrame:SetAlpha(0)
                    rewardFrame.IconBorder:SetAlpha(0)
                    GW.HandleIcon(rewardFrame.Icon)

                    rewardFrame.gwSkinned = true
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
