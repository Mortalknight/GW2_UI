local _, GW = ...

-- this is the layout manager for all the pieces of the mainbar frame that
-- have inter-related movement/visibility; it has intimate knowledge of the
-- internals of the action bars, player auras, and pet bar
-- TODO: not finished yet, only doing buff stuff mostly at this point, and
-- still has all the previous bugs with aura stuff and WQs

local Debug = GW.Debug

local lm = {}

function lm:RegisterBuffFrame(f)
    local l = self.layoutFrame
    l:SetFrameRef("buffs", f)
    self.buffFrame = f

    local up = self
    GW.AddActionBarCallback(function()
        up:onstate_None()
    end)
    self:onstate_None()
end

function lm:RegisterDebuffFrame(f)
    local l = self.layoutFrame
    l:SetFrameRef("debuffs", f)
    self.debuffFrame = f
end

function lm:RegisterMultiBarLeft(f)
    local l = self.layoutFrame
    l:SetFrameRef("mbl", f)
    self.mblFrame = f
end

function lm:RegisterMultiBarRight(f)
    local l = self.layoutFrame
    l:SetFrameRef("mbr", f)
    self.mbrFrame = f
end

function lm:RegisterPetFrame(f)
    local l = self.layoutFrame
    l:SetFrameRef("pet", f)
    self.petFrame = f
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

    local uip = self:GetFrameRef("UIP")
    local mbr = self:GetFrameRef("mbr")
    local mbl = self:GetFrameRef("mbl")
    local bbar = self:GetFrameRef("buffs")
    local dbar = self:GetFrameRef("debuffs")
    local pet = self:GetFrameRef("pet")

    if mbl and mbl:IsShown() and not mbl:GetAttribute("isMoved") and pet and not pet:GetAttribute("isMoved") then
        if newstate == "incombat" then
            pet:ClearAllPoints()
            pet:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -53, 212)
        else
            if mbl and mbl:IsShown() then
                if mbl:GetAttribute("gw_FadeShowing") then
                    pet:ClearAllPoints()
                    pet:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -53, 212)
                else
                    pet:ClearAllPoints()
                    pet:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -53, 120)
                end
            end
        end
    end

    if bbar and not bbar:GetAttribute("isMoved") and mbr and not mbr:GetAttribute("isMoved") then
        local buff_action = "none"
        if newstate == "incombat" or newstate == "outcombat" then
            buff_action = "low"
            if mbr and mbr:IsShown() and not mbr:GetAttribute("isMoved") then
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
            buff_action = "low"
        end

        if buff_action == "high" or buff_action == "low" then
            local y_off = (buff_action == "high") and 100 or 00
            local grow_dir = bbar:GetAttribute("growDir")
            local anchor_hb = grow_dir == "UPR" and "BOTTOMLEFT" or grow_dir == "DOWNR" and "TOPLEFT" or grow_dir == "UP" and "BOTTOMRIGHT" or grow_dir == "DOWN" and "TOPRIGHT"
            bbar:ClearAllPoints()
            bbar:SetPoint(anchor_hb, mbr, anchor_hb, 0, y_off)
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
    l:SetAttribute("_onstate-barlayout", onstate_Barlayout)
    l.oocHandler = function()
        lm:onstate_None()
    end
    l:SetFrameRef("UIP", UIParent)

    RegisterStateDriver(l, "barlayout", "[overridebar] obar; [vehicleui] vbar; [petbattle] petb; [combat] incombat; none")

    l:RegisterEvent("PLAYER_REGEN_ENABLED")
    l:SetScript("OnEvent", function(self, event)
        self:SetAttribute("currentHandlerState", "none")
        self:oocHandler()
    end)

    lm.layoutFrame = l
    return lm
end
GW.LoadMainbarLayout = LoadMainbarLayout
GW.AddForProfiling("mainbar_layout", "LayoutManager", lm)
