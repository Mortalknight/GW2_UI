---@class GW2
local GW = select(2, ...)

-- 12.1: Blizzard updates the QuickJoin counter itself via tabData.countGenerator -> tab:SetCount().
-- We only redirect the value into our notification badge (GwNotifyRed/GwNotifyText from HandleTabs).
local function HandleTabCount(tab, count)
    local isQuickJoin = tab.tabData and tab.tabData.tabType == SocialUITabType.QuickJoin
    local hasCount = isQuickJoin and count and count > 0

    if tab.GwNotifyText then
        tab.GwNotifyText:SetText(hasCount and count or "")
        tab.GwNotifyText:SetShown(hasCount)
        tab.GwNotifyRed:SetShown(hasCount)
    end
    if isQuickJoin and tab.Count then
        tab.Count:Hide()
    end
end

local function HookTabCounters()
    -- tabs come from a pool and can be reassigned on RefreshTabs
    for tab in SocialUIFrame:EnumerateTabs() do
        if not tab.GwCountHooked then
            tab.GwCountHooked = true
            hooksecurefunc(tab, "SetCount", HandleTabCount)
            tab:RefreshCounter()
        end
    end
end

function GW.SkinQuickJoinList()
    local QuickJoinFrame = SocialUIFrame.QuickJoinFrame
    if not QuickJoinFrame then return end

    GW.SkinSocialContactsView(QuickJoinFrame)

    HookTabCounters()
    hooksecurefunc(SocialUIFrame, "RefreshTabs", HookTabCounters)
end
