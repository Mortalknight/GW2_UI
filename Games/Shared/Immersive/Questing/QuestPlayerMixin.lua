---@class GW2
local GW = select(2, ...)

local emotes = GW.immersiveQuesting.emotes

GwImmersiveQuestingPlayerModelMixin = {}

function GwImmersiveQuestingPlayerModelMixin:SetupModel()
    self.is_unit_set = false
    self:ClearAll()
end

function GwImmersiveQuestingPlayerModelMixin:ClearAll()
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
    -- don't need any others because by MOP races we have the scroll kit
}
function GwImmersiveQuestingPlayerModelMixin:SetAction(action)
    if not self.is_loaded then
        self.defer_action = action
        return
    end
    self.defer_action = false

    if action == "read" then
        self:SetSheathed(true, false)
        if GW.Retail or GW.Mists then
            self:SetAnimation(emotes.IdleRead)
            self:ApplySpellVisualKit(29521, false)
        else
            local frame = NO_KIT_FRAMES[self.race_id][self.body_type]
            if frame < 0 then
                self:FreezeAnimation(emotes.Sheath, 0, -frame)
            else
                self:FreezeAnimation(emotes.Train, 0, frame)
            end
            self:ApplySpellVisualKit(230853, false)
        end
    elseif action == "kneel" then
        self:SetAnimation(emotes.IdleKneel)
    elseif action == "no" then
        self:SetAnimation(emotes.No)
    elseif action == "yes" then
        self:SetAnimation(emotes.Yes)
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
