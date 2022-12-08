local addonName, GW = ...

local function StaticPopup_Show(arg1, arg2)
	if (arg1 == "ADDON_ACTION_FORBIDDEN" and addonName == arg2) then
        GW.WarningPrompt(
            GW.L["Typing /reload will usually clear this type of error without disabling the addon\n\nIf the issue persists, this is not normal. Please report any details to GW2 UI"],
            function() C_UI.Reload() end,
            {"TOP", StaticPopup1, "BOTTOM", 0, -10},
            RELOADUI,
            IGNORE
        )
	end
end

hooksecurefunc("StaticPopup_Show", StaticPopup_Show)