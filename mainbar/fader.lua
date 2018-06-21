local _, GW = ...
local callback = {}

function gwActionBar_AddStateCallback(m)
    local k = GW.countTable(callback) + 1
    callback[k] = m
end

local function actionBarStateChanged()
    for k, v in pairs(callback) do
        v()
    end
end

local function actionBarFrameShow(f, name)
    GwStopAnimation(name)
    f.gw_FadeShowing = true
    actionBarStateChanged()
    addToAnimation(
        name,
        0,
        1,
        GetTime(),
        0.1,
        function()
            f:SetAlpha(animations[name]["progress"])
        end,
        nil,
        function()
            for i = 1, 12 do
                f.gw_MultiButtons[i].cooldown:SetDrawBling(true)
            end
            actionBarStateChanged()
        end
    )
end

local function actionBarFrameHide(f, name)
    GwStopAnimation(name)
    f.gw_FadeShowing = false
    for i = 1, 12 do
        f.gw_MultiButtons[i].cooldown:SetDrawBling(false)
    end
    addToAnimation(
        name,
        1,
        0,
        GetTime(),
        0.1,
        function()
            f:SetAlpha(animations[name]["progress"])
        end,
        nil,
        function()
            actionBarStateChanged()
        end
    )
end

function gwActionBar_FadeCheck(self, elapsed)
    self.gw_LastFadeCheck = self.gw_LastFadeCheck - elapsed
    if self.gw_LastFadeCheck > 0 then
        return
    end
    self.gw_LastFadeCheck = 0.1
    if not self:IsShown() then
        return
    end

    if self:IsMouseOver(100, -100, -100, 100) or UnitAffectingCombat("player") then
        if not self.gw_FadeShowing then
            actionBarFrameShow(self, self:GetName())
        end
    elseif self.gw_FadeShowing and UnitAffectingCombat("player") == false then
        actionBarFrameHide(self, self:GetName())
    end
end
