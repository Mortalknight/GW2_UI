local _, GW = ...

local constBackdropDropDown = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/gwstatusbar",
    edgeFile = "",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
}
GW.BackdropTemplates.DopwDown = constBackdropDropDown

local constBackdropFrame = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png",
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-border.png",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.BackdropTemplates.Default = constBackdropFrame

local constBackdropFrameBorder = {
    bgFile = "",
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-border.png",
    tile = false,
    tileSize = 64,
    edgeSize = 32,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.BackdropTemplates.OnlyBorder = constBackdropFrameBorder

local constBackdropFrameSmallerBorder = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png",
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-border.png",
    tile = false,
    tileSize = 64,
    edgeSize = 18,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.BackdropTemplates.DefaultWithSmallBorder = constBackdropFrameSmallerBorder

local constBackdropFrameStatusBar = {
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/statusbar.png",
    --edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-border.png",
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}
GW.BackdropTemplates.StatusBar = constBackdropFrameStatusBar

local constBackdropFrameColorBorder = {
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white.png",
    bgFile = "Interface/AddOns/GW2_UI/textures/uistuff/ui-tooltip-background.png",
    edgeSize = 1
}
GW.BackdropTemplates.DefaultWithColorableBorder = constBackdropFrameColorBorder

local constBackdropFrameColorBorderNoBackground = {
    edgeFile = "Interface/AddOns/GW2_UI/textures/uistuff/white.png",
    bgFile = "",
    edgeSize = 1
}
GW.BackdropTemplates.ColorableBorderOnly = constBackdropFrameColorBorderNoBackground