---@class GW2
local GW = select(2, ...)

local emotes = GW.immersiveQuesting.emotes

GwImmersiveQuestingPlayerModelMixin = {}

function GwImmersiveQuestingPlayerModelMixin:SetupModel()
    self.is_unit_set = false
    self:ClearAll()
end

local ONE_SHOT_FALLBACK_SECONDS = 2

local function returnToIdle(self)
    if self.one_shot_playing then
        self.one_shot_playing = false
        self:SetAnimation(emotes.Idle)
    end
end

function GwImmersiveQuestingPlayerModelMixin:PlayOneShot(emote)
    self.one_shot_playing = true
    self.one_shot_token = (self.one_shot_token or 0) + 1
    local token = self.one_shot_token
    self:SetAnimation(emote)
    C_Timer.After(ONE_SHOT_FALLBACK_SECONDS, function()
        if self.one_shot_token == token then
            returnToIdle(self)
        end
    end)
end

function GwImmersiveQuestingPlayerModelMixin:OnAnimFinished()
    returnToIdle(self)
end

local function walkInProgress()
    local frame = GwImmersiveQuestFrame
    return frame and frame.isFullscreen and frame.walkProgress and frame.walkProgress < 1
end

function GwImmersiveQuestingPlayerModelMixin:CanWalk()
    return self.is_loaded and self.base_facing and not self.pose_locked and not self.one_shot_playing
end

function GwImmersiveQuestingPlayerModelMixin:FlushPendingEmote()
    if self.pending_emote then
        local emote = self.pending_emote
        self.pending_emote = nil
        self:PlayOneShot(emote)
    end
end

function GwImmersiveQuestingPlayerModelMixin:SetWalkState(walking, turn)
    if not self.is_loaded or not self.base_facing then
        return
    end
    if walking then
        if not self.walking then
            self.walking = true
            self:SetAnimation(emotes.Walk)
        end
        self:SetFacing(self.base_facing + turn)
    elseif self.walking then
        self.walking = false
        self:SetFacing(self.base_facing)
        self:SetAnimation(emotes.Idle)
        self:FlushPendingEmote()
    end
end

function GwImmersiveQuestingPlayerModelMixin:ClearAll()
    self.walking = false
    self.pose_locked = false
    self.pending_emote = nil
    self.one_shot_playing = false
    self.is_loaded = false
    self.defer_action = false
    self:SetUnit("none")
    self:SetModelScale(1.0)
    self:RefreshCamera()
end

function GwImmersiveQuestingPlayerModelMixin:OnShow()
    if not self.is_unit_set then
        if not (GW.Retail or GW.Mists) then
            local player_loc = PlayerLocation:CreateFromUnit("player")
            local race_id = C_PlayerInfo.GetRace(player_loc)
            local body_type = C_PlayerInfo.GetSex(player_loc) + 2
            self.race_id = race_id
            self.body_type = body_type
        end
        self.is_unit_set = true
    end
    self:SetUnit("player")
    -- NOTE: the above SetUnit call will immediately call OnModelLoaded if
    -- there is no load delay BEFORE continuing on in here; don't add anything
    -- after those calls without considering the timing issue
end

function GwImmersiveQuestingPlayerModelMixin:OnHide()
    self:ClearAll()
end

function GwImmersiveQuestingPlayerModelMixin:OnModelLoaded()
    if self.skip_model_load or not self.is_unit_set then
        return
    end

    local file_id = self:GetModelFileID()
    local p_info = GW.immersiveQuesting.playerScales[file_id]

    local x = -70
    local z = -30
    local sf = 1.0
    local f = 0.5
    local ps = ((GW.settings.immersiveQuesting.playerScale - 1.0)/2) + 1.0
    if GwImmersiveQuestFrame and GwImmersiveQuestFrame.isFullscreen then
        local fit = GW.immersiveQuesting.fullscreenFit
        ps = ps * fit.playerScale
        x = x + fit.playerX
        z = z - fit.playerDrop
    end

    if p_info then
        if p_info.x then
            x = x + p_info.x
        end
        if p_info.z then
            z = z + p_info.z
        end
        if p_info.sf then
            sf = 1.0 + (p_info.sf/100)
        end
        if p_info.f then
            f = f * ((100 - p_info.f)/100)
        end
    end

    GW.Debug("player - fileID:", file_id, "| sf:", sf, "| ps:", ps, "| x:", x, "| z:", z, "| f:", f)

    self:SetModelScale(sf * ps)
    self:SetViewTranslation(x, z)
    self.base_facing = f
    self:SetFacing(f)

    local wm = GW.settings.immersiveQuesting.weaponMode
    local hm = GW.settings.immersiveQuesting.showHelmet

    if not hm then
        self:UndressSlot(INVSLOT_HEAD)
    end
    if wm == "STOW" and not self:GetSheathed() then
        self:SetSheathed(true, false)
    elseif wm == "DRAW" and self:GetSheathed() then
        self:SetSheathed(false, false)
    elseif wm == "HIDE" then
        self:SetSheathed(true, true)
    end

    self:SetAnimation(emotes.Idle)

    self.is_loaded = true
    self.FadeIn:Play()
    if self.defer_action then
        self:SetAction(self.defer_action)
    end
    if GwImmersiveQuestFrame then
        GwImmersiveQuestFrame:ReapplyModelWalk()
    end
    if not walkInProgress() then
        self:FlushPendingEmote()
    end
end

local NO_KIT_FRAMES = {
    [1] = { [2] = -150, [3] = -180 }, -- human
    [2] = { [2] = 180, [3] = 280 }, -- orc
    [3] = { [2] = 150, [3] = 180 }, -- dwarf
    [4] = { [2] = 150, [3] = -40 }, -- night elf
    [5] = { [2] = 230, [3] = 140 }, -- undead
    [6] = { [2] = 180, [3] = 100 }, -- tauren
    [7] = { [2] = 90, [3] = 0 }, -- gnome
    [8] = { [2] = -120, [3] = 180 }, -- troll
    [9] = { [2] = 180, [3] = 180 }, -- goblin
    [10] = { [2] = 180, [3] = 180 }, -- blood elf
    [11] = { [2] = 180, [3] = 180 }, -- draenei
    [22] = { [2] = 180, [3] = 180 }, -- worgen
    [95] = { [2] = 180, [3] = 180 }, -- alliance skyborne
    [96] = { [2] = 180, [3] = 180 }, -- horde skyborne
    -- don't need any others because by MOP races we have the scroll kit
}
function GwImmersiveQuestingPlayerModelMixin:SetAction(action)
    if not self.is_loaded then
        self.defer_action = action
        return
    end
    self.defer_action = false

    if action == "read" or action == "kneel" then
        self.pose_locked = true
    end

    if action == "read" then
        self:SetSheathed(true, false)
        if GW.Retail or GW.Mists then
            self:SetAnimation(emotes.IdleRead)
            self:ApplySpellVisualKit(29521, false)
        else
            local raceFrames = NO_KIT_FRAMES[self.race_id]
            local frame = raceFrames and raceFrames[self.body_type] or 180
            if frame < 0 then
                self:FreezeAnimation(emotes.Sheath, 0, -frame)
            else
                self:FreezeAnimation(emotes.Train, 0, frame)
            end
            self:ApplySpellVisualKit(230853, false)
        end
    elseif action == "kneel" then
        self:SetAnimation(emotes.IdleKneel)
    elseif action == "no" or action == "yes" then
        local emote = action == "no" and emotes.No or emotes.Yes
        if walkInProgress() then
            self.pending_emote = emote
        else
            self:PlayOneShot(emote)
        end
    end
end

function GwImmersiveQuestingPlayerModelMixin:OnEvent(event, ...)
    GW.Debug("GwImmersiveQuestingPlayerModelMixin event handling", event, ...)
    if event == "BARBER_SHOP_RESULT" then
        self:SetupModel()
    end
end

function GwImmersiveQuestingPlayerModelMixin:OnLoad()
    self:SetScript("OnEvent", self.OnEvent)
    if not GW.Retail or GW.Mists then
        -- we only need race/body type info if we have to custom animate "reading"
        self:RegisterEvent("BARBER_SHOP_RESULT")
    end
end
