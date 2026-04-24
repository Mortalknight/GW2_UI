---@class GW2
local GW = select(2, ...)

local model_tweaks = GW.immersiveQuesting.modelTweaks
local npc_tweaks = GW.immersiveQuesting.npcTweaks
local emotes = GW.immersiveQuesting.emotes
local board_types = GW.immersiveQuesting.boardTypes

GwImmersiveQuestingGiverModelMixin = {}

-- emotes used (at random) for talk sequences and end sign-off
local mid_set = {"Talk", "Talk2", "Yes", "No", "Point"}
local end_set = {"Bow", "Salute"}

function GwImmersiveQuestingGiverModelMixin:OnAnimFinished()
    if self.anim_next ~= -1 then
        self.anim_playing = true
        if self.half_kits then
            self:PlayAnimKit(self.anim_next)
        else
            self:SetAnimation(self.anim_next)
        end
        self.anim_next = -1
    elseif self.anim_playing then
        self.anim_playing = false
        if not self.half_kits and self.idle_anim ~= -1 then
            self:SetAnimation(self.idle_anim)
        end
    end
end

function GwImmersiveQuestingGiverModelMixin:setQuestGiverAnimation(count, qString, qStringInt)
    if qString == nil or qString[qStringInt] == nil then
        return
    end

    if not self.is_loaded or not self.do_anims then
        return
    end

    -- determine main emote to play for this line
    local prefix = self.half_kits and "Half" or ""
    local a = "Talk"
    local s = string.sub(qString[qStringInt], -1)
    local overwrite_next = false
    if qStringInt >= count then
        a = end_set[math.random(1, #end_set)]
        overwrite_next = true
    elseif s == "!" then
        a = "TalkExclamation"
    elseif s == "?" then
        a = "TalkQuestion"
    end

    -- if playing something, don't interrupt to avoid spastic motions on click-thru
    if self.anim_playing then
        if self.anim_next == -1 or overwrite_next then
            if a == "Talk" then
                a = mid_set[math.random(1, #mid_set)]
            end
            if self:HasAnimation(emotes[a]) then
                self.anim_next = emotes[prefix .. a]
            elseif not overwrite_next then
                self.anim_next = emotes[prefix .. "Talk"]
            else
                self.anim_next = -1
            end
        end
    else
        self.anim_playing = true
        self.anim_next = -1
        if qStringInt < count then
            if a == "Talk" then
                a = mid_set[math.random(1, #mid_set)]
            end
        end
        local play_anim = nil
        if self:HasAnimation(emotes[a]) then
            play_anim = emotes[prefix .. a]
        elseif not overwrite_next then
            play_anim = emotes[prefix .. "Talk"]
        end
        if play_anim ~= nil then
            if self.half_kits then
                self:PlayAnimKit(play_anim)
            else
                self:SetAnimation(play_anim)
            end
        end
    end
end

local function getCreatureID(target)
    if not target then
        return 0
    end
    if UnitCreatureID then
        return UnitCreatureID(target)
    end
	return tonumber(string.match(UnitGUID(target), "Creature%-.-%-.-%-.-%-.-%-(.-)%-"))
end


function GwImmersiveQuestingGiverModelMixin:SetQuestUnit(creature_id, display_id)
    self.is_clear = false

    -- SetCreature/SetUnit will immediately call OnModelLoaded if there
    -- is no load delay, BEFORE completing execution here
    if creature_id ~= nil then
        self.creature_id = creature_id
        self:SetCreature(creature_id, display_id or 0)
        return true
    else
        -- we do it this way to get equipped weapon; otherwise we could just set by creature ID
        self.creature_id = getCreatureID("questnpc")
        if self.creature_id and GW.immersiveQuesting.displayIdOverrides[self.creature_id] then
            self:SetCreature(self.creature_id, GW.immersiveQuesting.displayIdOverrides[self.creature_id] or 0)
            return true
        end
        local did_set_unit = self:SetUnit("questnpc")
        if not did_set_unit then
            self.creature_id = 0
        end
        return did_set_unit
    end
end

function GwImmersiveQuestingGiverModelMixin:OnModelLoaded()
    if self.is_clear then
        return
    end
    local fileID = self.file_id ~= nil and self.file_id or self:GetModelFileID()
    local tweaks = nil
    local tweak_opts = nil
    local creatureID = self.creature_id

    local z = 50
    local x = -100
    local p = 0.0
    local f = -0.5

    local c_tweaks = creatureID and npc_tweaks[creatureID]
    local m_tweaks = fileID and model_tweaks[fileID]
    if c_tweaks ~= nil and type(c_tweaks) ~= 'table' and m_tweaks and type(m_tweaks) == 'table' then
        -- merge scalar sf changes from creature override into existing model table
        tweaks = m_tweaks
        m_tweaks.sf = c_tweaks
    elseif c_tweaks then
        tweaks = c_tweaks
    elseif m_tweaks then
        tweaks = m_tweaks
    end
    if tweaks ~= nil and type(tweaks) == 'table' then
        tweak_opts = tweaks
    end
    local mod_sf = -20 -- default if not changed results in sf of 0.8
    if tweak_opts ~= nil then
        if tweak_opts['sf'] ~= nil then
            mod_sf = tweak_opts['sf']
        end
    elseif tweaks ~= nil then
        mod_sf = tweaks
    end
    local sf = 1.0 + (mod_sf/100)

    self.idle_anim = emotes.Idle

    if tweak_opts ~= nil then
        if tweak_opts.x then
            x = x + tweak_opts.x
        end
        if tweak_opts.z then
            z = z + tweak_opts.z
        end
        if tweak_opts.p ~= nil then
            p = tweak_opts.p
        end
        if tweak_opts.f ~= nil then
            f = tweak_opts.f
        end
        if tweak_opts.ia ~= nil then
            self.idle_anim = tweak_opts.ia
        end
        if tweak_opts.ik ~= nil then
            self.idle_kit = tweak_opts.ik
        end
        if tweak_opts.hk ~= nil then
            self.half_kits = tweak_opts.hk
        end
    end

    GW.Debug("giver model - fileID:", fileID, "| creatureID:", creatureID, "| sf:", sf, "| dID:", self:GetDisplayInfo(), "| f:", f)

    self.do_anims = self.idle_anim ~= -1 and true or false
    self:SetPitch(p)
    self:SetFacing(f)
    if self.idle_kit ~= -1 then
        self:PlayAnimKit(self.idle_kit, true)
    elseif self.idle_anim ~= -1 then
        self:SetAnimation(self.idle_anim)
    end
    self:SetModelScale(sf)
    self:SetViewTranslation(x, z)

    self.is_loaded = true
    self.FadeIn:Play()
end

function GwImmersiveQuestingGiverModelMixin:SetBoardUnit(board_type, map_id)
    self.is_clear = false
    self.do_anims = false
    local board_id = board_types[board_type]
    if board_id ~= nil then
        if type(board_id) == "table" then
            if map_id and board_id[map_id] then
                return self:SetQuestUnit(board_id[map_id])
            else
                self.file_id = board_types["genericplayerchoice"]
            end
        else
            self.file_id = board_id
        end
    else
        self.file_id = board_types["genericplayerchoice"]
    end
    self:SetModel(self.file_id)
    return true
end

function GwImmersiveQuestingGiverModelMixin:SetModelUnit(file_id)
    self.is_clear = false
    self.do_anims = false
    self.file_id = file_id
    self:SetModel(self.file_id)
end

function GwImmersiveQuestingGiverModelMixin:SetupModel()
    self:ClearAll()
    self:SetFacingLeft(true)
end

function GwImmersiveQuestingGiverModelMixin:OnHide()
    self:ClearAll()
end

function GwImmersiveQuestingGiverModelMixin:ClearAll()
    self.creature_id = 0
    self.file_id = nil
    self.do_anims = false
    self.idle_anim = emotes.Idle
    self.idle_kit = -1
    self.half_kits = false
    self.anim_next = -1
    self.anim_playing = false
    self.is_clear = true
    self.is_loaded = false

    self:SetUnit("none")
    self:SetAlpha(0)

    self:SetFacing(0)
    self:SetPitch(0)
    self:SetModelScale(1.0)
    self:ClearTransform()
end
