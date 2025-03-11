local _, GW = ...
local TRACKER_TYPE_COLOR = GW.TRACKER_TYPE_COLOR

local function OnEvent(self, event, ...)
    self:UpdateAchievementLayout(event, ...)
end

local function CollapseHeader(self, forceCollapse, forceOpen)
    if (not self.collapsed or forceCollapse) and not forceOpen then
        self.collapsed = true
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    else
        self.collapsed = false
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
    self:UpdateAchievementLayout()
end
GW.CollapseAchievementHeader = CollapseHeader

local function LoadAchievementFrame(container)
    container:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED")
    container:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE")
    container:RegisterEvent("ACHIEVEMENT_EARNED")
    container:RegisterEvent("CONTENT_TRACKING_UPDATE")
    container:SetScript("OnEvent", OnEvent)

    container.header = CreateFrame("Button", nil, container, "GwQuestTrackerHeader")
    container.header.icon:SetTexCoord(0, 0.5, 0, 0.25)
    container.header.title:GwSetFontTemplate(DAMAGE_TEXT_FONT, GW.TextSizeType.HEADER)
    container.header.title:SetShadowOffset(1, -1)
    container.header.title:SetText(TRACKER_HEADER_ACHIEVEMENTS)

    container.collapsed = false
    container.header:SetScript("OnMouseDown",
        function(self)
            CollapseHeader(self:GetParent(), false, false)
        end
    )
    container.header.title:SetTextColor(
        TRACKER_TYPE_COLOR.ACHIEVEMENT.r,
        TRACKER_TYPE_COLOR.ACHIEVEMENT.g,
        TRACKER_TYPE_COLOR.ACHIEVEMENT.b
    )

    container.timedCriteria = {}

    container:UpdateAchievementLayout()
end
GW.LoadAchievementFrame = LoadAchievementFrame
