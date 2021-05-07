local _, GW = ...

local IGNORE_SIZE = 32

local function loadIgnore(ignorewin)
    local USED_IGNORE_HEIGHT
    local zebra

    local offset = HybridScrollFrame_GetOffset(ignorewin)
    local numIgnores = C_FriendList.GetNumIgnores()

    for i = 1, #ignorewin.buttons do
        local slot = ignorewin.buttons[i]

        local idx = i + offset

        if idx > numIgnores then
            -- empty row (blank starter row, final row, and any empty entries)
            slot.item:Hide()
            slot.item.IgnoreIdx = nil
        else
            slot.item.IgnoreIdx = idx
            local name = C_FriendList.GetIgnoreName(idx)
            if not name then
                slot.item.name:SetText(UNKNOWN)
            else
                slot.item.name:SetText(name)
            end

            -- set zebra color by idx or watch status
            zebra = idx % 2
            if (C_FriendList.GetSelectedIgnore() or 0) == idx then
                slot.item.zebra:SetVertexColor(1, 1, 0.5, 0.15)
            else
                slot.item.zebra:SetVertexColor(zebra, zebra, zebra, 0.05)
            end

            slot.item.remove:Show()
            slot.item:Show()
        end
    end

    USED_IGNORE_HEIGHT = IGNORE_SIZE * numIgnores
    HybridScrollFrame_Update(ignorewin, USED_IGNORE_HEIGHT, 433)
end
GW.AddForProfiling("social_ignore", "loadIgnore", loadIgnore)

local function item_OnClick(self)
    if not self.IgnoreIdx then
        return
    end
    C_FriendList.SetSelectedIgnore(self.IgnoreIdx)
    loadIgnore(GwIgnoreWindow.IgnoreScroll)
end
GW.AddForProfiling("social_ignore", "ignore_OnClick", ignore_OnClick)

local removeIgnore_OnEnter = function(self)
    self.icon:SetBlendMode("ADD")
end

local removeIgnore_OnLeave = function(self)
    self.icon:SetBlendMode("BLEND")
end

local function removeFromeIgnore(self)
    if not self:GetParent().IgnoreIdx then
        return
    end

    C_FriendList.DelIgnoreByIndex(self:GetParent().IgnoreIdx)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

local function ignoreSetup(ignorewin)
    HybridScrollFrame_CreateButtons(ignorewin, "GwIgnoreRow", 12, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
    for i = 1, #ignorewin.buttons do
        local slot = ignorewin.buttons[i]
        slot:SetWidth(ignorewin:GetWidth() - 12)
        slot.item.name:SetFont(UNIT_NAME_FONT, 12)
        slot.item.name:SetTextColor(1, 1, 1)
        if not slot.item.ScriptsHooked then
            slot.item:HookScript("OnClick", item_OnClick)
            slot.item.remove:HookScript("OnEnter", removeIgnore_OnEnter)
            slot.item.remove:HookScript("OnLeave", removeIgnore_OnLeave)
            slot.item.remove:HookScript("OnClick", removeFromeIgnore)
            slot.item.ScriptsHooked = true
        end
    end

    loadIgnore(ignorewin)
end
GW.AddForProfiling("social_ignore", "ignoreSetup", ignoreSetup)

local function LoadIgnoreList(tabContainer)
    local ignorewin_outer = CreateFrame("Frame", "GwIgnoreWindow", tabContainer, "GwIgnoreWindow")
    local ignorewin = ignorewin_outer.IgnoreScroll

    ignorewin.update = loadIgnore
    ignorewin.scrollBar.doNotHide = true
    ignoreSetup(ignorewin)

    ignorewin_outer.ignoreHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    ignorewin_outer.ignoreHeader:SetTextColor(255 / 255, 241 / 255, 209 / 255)

    -- update ignore window when a ignore update event occurs
    ignorewin:SetScript(
        "OnEvent",
        function(self)
            if GW.inWorld and self:IsShown() then
                loadIgnore(self)
            end
        end
    )
    ignorewin:RegisterEvent("IGNORELIST_UPDATE")

    ignorewin_outer.ignore:SetScript("OnClick", function()
        if UnitCanCooperate("player", "target") and UnitIsPlayer("target") then
            local name, server = UnitName("target")
            local fullname = name;
            if server and UnitRealmRelationship("target") ~= LE_REALM_RELATION_SAME then
                fullname = name .. "-" .. server
            end
            C_FriendList.AddIgnore(fullname)
            PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
        else
            StaticPopup_Show("ADD_IGNORE")
        end
    end)


    SlashCmdList["IGNORE"] = function(msg)
        if InCombatLockdown() then return end

        if ( msg ~= "" or UnitIsPlayer("target") ) then
            local bNetIDAccount = BNet_GetBNetIDAccount(msg);
            if ( bNetIDAccount ) then
                if ( BNIsFriend(bNetIDAccount) ) then
                    SendSystemMessage(ERR_CANNOT_IGNORE_BN_FRIEND);
                else
                    BNSetBlocked(bNetIDAccount, not BNIsBlocked(bNetIDAccount));
                end
            else
                C_FriendList.AddOrDelIgnore(msg);
            end
        else
            GwSocialWindow:SetAttribute("windowpanelopen", "ignorelist")
        end
    end

    SlashCmdList["UNIGNORE"] = function(msg)
        if InCombatLockdown() then return end

        if ( msg ~= "" or UnitIsPlayer("target") ) then
            C_FriendList.DelIgnore(msg);
        else
            GwSocialWindow:SetAttribute("windowpanelopen", "ignorelist")
        end
    end
end
GW.LoadIgnoreList = LoadIgnoreList