local addonName, GW = ...

local function StaticPopup_Show(arg1, arg2)
	if (arg1 == "ADDON_ACTION_FORBIDDEN" and addonName == arg2) then
        GW.ShowPopup({text = GW.L["Typing /reload will usually clear this type of error without disabling the addon\n\nIf the issue persists, this is not normal. Please report any details to GW2 UI"],
            OnAccept = function() C_UI.Reload() end,
            button1 = RELOADUI,
            button2 = IGNORE,
            point = {"TOP", StaticPopup1, "BOTTOM", 0, -10},
            hasFixedPosition = true})
	end
end

hooksecurefunc("StaticPopup_Show", StaticPopup_Show)