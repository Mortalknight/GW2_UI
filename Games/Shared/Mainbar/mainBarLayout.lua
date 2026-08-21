---@class GW2
local GW = select(2, ...)

-- Layout manager for the mainbar cluster (pet bar, MultiBarBottomLeft/Right, buff and
-- debuff bars): a secure state driver repositions their MOVERS on combat/vehicle/
-- petbattle/override transitions. It has to be secure - protected frames hang on these
-- movers, and moving such an anchor mid combat is only allowed to secure execution.
--
-- This file is the SINGLE source of truth for the cluster positions. Every Register*
-- call kicks the secure handler once, so the frames land on their final position right
-- at login - there is no separate insecure login formula anymore (the old "position
-- mover" blocks in the per-flavor actionbars.lua were removed). The base coordinates
-- come from the mover defaults in defaults2.lua; only the deviations from those
-- defaults are the named constants below.

-- deviations from the defaults2.lua mover positions, applied while the frames sit at
-- their default position (isMoved unset):
local MULTIBAR_X_PLAYER_AS_TARGET = 316 -- bottom bars move inward when the player frame is centered as target frame
local MULTIBAR_Y_NO_XPBAR = 114         -- bottom bars move down when the XP bar module is disabled
local PET_X_PLAYER_AS_TARGET_SHIFT = 54 -- pet bar follows the left bottom bar inward
local PET_Y_RAISED = 212                -- pet bar sits above MultiBarBottomLeft while that bar is visible

-- same triggers, but for the insecure one-shot login positioning of the power bar and
-- the class power bar (they never move mid-session, so they stay outside the secure
-- snippet). The magnitudes deviate on purpose from the bar values above (52 vs 53/54) -
-- they are pixel-tuned per frame, do not "unify" them without checking in game.
local HUD_Y_NO_XPBAR_SHIFT = 14          -- power/class power move down when the XP bar module is disabled
local HUD_X_PLAYER_AS_TARGET_SHIFT = 52  -- power/class power shift sideways when the player frame is centered

-- returns the x/y login shift for the insecure HUD frames; direction is a
-- GW.Enum.HudShiftDirection value (Left = power bar, Right = class power)
local function GetHudClusterShift(direction)
    local xOff = GW.settings.PLAYER_AS_TARGET_FRAME and (HUD_X_PLAYER_AS_TARGET_SHIFT * direction) or 0
    local yOff = not GW.settings.XPBAR_ENABLED and HUD_Y_NO_XPBAR_SHIFT or 0
    return xOff, yOff
end
GW.GetHudClusterShift = GetHudClusterShift

local lm = {}

function lm:RegisterBuffFrame(f)
    local l = self.layoutFrame
    l:SetFrameRef("buffs", f)
    l:SetFrameRef("buffs_mover", f.gwMover)
    self.buffFrame = f
    self:onstate_None()
end

function lm:RegisterDebuffFrame(f)
    local l = self.layoutFrame
    l:SetFrameRef("debuffs", f)
    l:SetFrameRef("debuffs_mover", f.gwMover)
    self.debuffFrame = f
    -- same kick as buffs/pet: without it the debuff mover kept its default position
    -- until the first fade or combat, because the buff kick ran before this ref existed
    self:onstate_None()
end

function lm:RegisterMultiBarLeft(f)
    local l = self.layoutFrame
    l:SetFrameRef("mbl", f)
    l:SetFrameRef("mbl_mover", f.gwMover)
    self.mblFrame = f
    -- kick the handler so the bar gets its login position from the secure formula -
    -- this replaces the old insecure "position mover" duplicate in actionbars.lua
    self:onstate_None()
end

function lm:RegisterMultiBarRight(f)
    local l = self.layoutFrame
    l:SetFrameRef("mbr", f)
    l:SetFrameRef("mbr_mover", f.gwMover)
    self.mbrFrame = f
    self:onstate_None()
end

function lm:RegisterPetFrame(f)
    local l = self.layoutFrame
    l:SetFrameRef("pet", f)
    l:SetFrameRef("pet_mover", f.gwMover)
    self.petFrame = f
    self:onstate_None()
end

function lm:onstate_None()
    if InCombatLockdown() then
        return
    end
    -- if out of combat and not in the state driver, run the layout
    -- handler with "outcombat" state
    local l = self.layoutFrame
    if l:GetAttribute("currentHandlerState") == "none" then
        local c = "local newstate = 'outcombat'\n"
        c = c .. self.layoutFrame:GetAttribute("_onstate-barlayout")
        l:Execute(c)
    end
end

local onstate_Barlayout = [=[
    --print("layout manager new state", newstate)
    if newstate ~= "outcombat" then
        self:SetAttribute("currentHandlerState", newstate)
    end

    if self:GetAttribute("inMoveHudMode") then return end

    local uip = self:GetFrameRef("UIP")
    local mbr = self:GetFrameRef("mbr")
    local mbr_mover = self:GetFrameRef("mbr_mover")
    local mbl = self:GetFrameRef("mbl")
    local mbl_mover = self:GetFrameRef("mbl_mover")
    local bbar = self:GetFrameRef("buffs")
    local bbarmover = self:GetFrameRef("buffs_mover")
    local dbar = self:GetFrameRef("debuffs")
    local dbarmover = self:GetFrameRef("debuffs_mover")
    local pet = self:GetFrameRef("pet")
    local petmover = self:GetFrameRef("pet_mover")
    local mbX = self:GetAttribute("mbXOfs")
    local mbY = self:GetAttribute("mbYOfs")
    local petX = self:GetAttribute("petXOfs")
    local petY = self:GetAttribute("petYOfs")
    local petYRaised = self:GetAttribute("petYRaisedOfs")

    if mbl and mbl:IsShown() and not mbl:GetAttribute("isMoved") and pet and not pet:GetAttribute("isMoved") then
        if newstate == "incombat" then
            petmover:ClearAllPoints()
            petmover:SetPoint("BOTTOMRIGHT", uip, "BOTTOM", petX, petYRaised)
        else
            if mbl and mbl:IsShown() then
                if mbl:GetAttribute("gw_FadeShowing") then
                    petmover:ClearAllPoints()
                    petmover:SetPoint("BOTTOMRIGHT", uip, "BOTTOM", petX, petYRaised)
                else
                    petmover:ClearAllPoints()
                    petmover:SetPoint("BOTTOMRIGHT", uip, "BOTTOM", petX, petY)
                end
            end
        end
    end

    -- only set the dbarmover frame to the correct position, based on scaling
    if newstate == "outcombat" and dbarmover and bbar and not dbar:GetAttribute("isMoved") and not bbar:GetAttribute("isMoved") and mbr and not mbr:GetAttribute("isMoved") then
        local buff_action = "none"
        if mbr:IsShown() and mbr:GetAttribute("gw_FadeShowing") then
            buff_action = "high"
        end
        local y_off = (buff_action == "high" and 200 or 100)
        dbarmover:ClearAllPoints()
        dbarmover:SetPoint("BOTTOMRIGHT", mbr, "BOTTOMRIGHT", 0, y_off)
    end

    --mbrFrame
    if mbr and not mbr:GetAttribute("isMoved") and mbr_mover then
        mbr_mover:ClearAllPoints()
        mbr_mover:SetPoint("BOTTOMRIGHT", uip, "BOTTOM", mbX, mbY)
    end

    --mblFrame
    if mbl and not mbl:GetAttribute("isMoved") and mbl_mover then
        mbl_mover:ClearAllPoints()
        mbl_mover:SetPoint("BOTTOMLEFT", uip, "BOTTOM", -mbX, mbY)
    end

    if bbar and not bbar:GetAttribute("isMoved") and mbr and not mbr:GetAttribute("isMoved") then
        local buff_action = "none"
        if newstate == "incombat" or newstate == "outcombat" then
            buff_action = "low"
            if mbr:IsShown() then
                if newstate == "outcombat" then
                    if mbr:GetAttribute("gw_FadeShowing") then
                        buff_action = "high"
                    end
                else
                    buff_action = "high"
                end
            end
        elseif newstate == "petb" then
            buff_action = "hide"
        elseif newstate == "obar" then
            buff_action = "show"
        elseif newstate == "vbar" then
            buff_action = "high"
        end

        if buff_action == "high" or buff_action == "low" then
            local y_off = (buff_action == "high") and 100 or 0
            bbarmover:ClearAllPoints()
            bbarmover:SetPoint("BOTTOMRIGHT", mbr, "BOTTOMRIGHT", 0, y_off)
            bbar:Show()
            if dbar then dbar:Show() end
        elseif buff_action == "hide" then
            bbar:Hide()
            if dbar then dbar:Hide() end
        elseif buff_action == "show" then
            bbar:Show()
            if dbar then dbar:Show() end
        end
    end
]=]

local function LoadMainbarLayout()
    local l = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    -- All cluster coordinates are computed ONCE here (mover defaults from defaults2.lua
    -- plus the deviation constants above) and handed to the secure snippet as attributes.
    -- Computing once is safe only because PLAYER_AS_TARGET_FRAME and XPBAR_ENABLED both
    -- force a reload popup - if that reload requirement is ever lifted, these attributes
    -- have to be recomputed from the setting callbacks.
    local defaults = GW.globalDefault.profile
    local pfat = GW.settings.PLAYER_AS_TARGET_FRAME
    l:SetAttribute("mbXOfs", pfat and MULTIBAR_X_PLAYER_AS_TARGET or defaults.MultiBarBottomRight.xOfs)
    l:SetAttribute("mbYOfs", GW.settings.XPBAR_ENABLED and defaults.MultiBarBottomRight.yOfs or MULTIBAR_Y_NO_XPBAR)
    l:SetAttribute("petXOfs", defaults.pet_pos.xOfs + (pfat and PET_X_PLAYER_AS_TARGET_SHIFT or 0))
    l:SetAttribute("petYOfs", defaults.pet_pos.yOfs)
    l:SetAttribute("petYRaisedOfs", PET_Y_RAISED)
    l:SetAttribute("_onstate-barlayout", onstate_Barlayout)
    l.oocHandler = function()
        lm:onstate_None()
    end
    l:SetFrameRef("UIP", UIParent)

    RegisterStateDriver(l, "barlayout", "[overridebar] obar; [vehicleui] vbar; [petbattle] petb; [combat] incombat; none")

    l:RegisterEvent("PLAYER_REGEN_ENABLED")
    l:SetScript("OnEvent", function(self)
        self:SetAttribute("currentHandlerState", "none")
        self:oocHandler()
    end)

    -- ONE fade callback for the whole manager - buffs and pet each registered their own
    -- identical one before, so every bar fade executed the snippet twice
    GW.AddActionBarCallback(function()
        lm:onstate_None()
    end)

    lm.layoutFrame = l
    return lm
end
GW.LoadMainbarLayout = LoadMainbarLayout

