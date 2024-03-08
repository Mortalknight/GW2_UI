local _, GW = ...

local Masque = LibStub("Masque", true)

local function AddMasqueSkin()
    if not Masque then return end
    -- Add a new skin to Masque.
    Masque:AddSkin("GW2 Actionbutton Skin", {
    -- Info
        Authors = "GW2 UI",
        Description = "Only for Actionbuttons",
        Discord = "https://discord.gg/MZZtRWt",
        Version = "1.0.0",
        Shape = "Square",
        Masque_Version = 100105,
        Backdrop = {
            Texture = [[Interface/AddOns/GW2_UI/textures/addonSkins/Backdrop]],
            Color = {1,1,1,1},
            Width = 38,
            Height = 38,
        },
        Icon = {
            TexCoords = {0.1, 0.9, 0.1, 0.9},
            Width = 36,
            Height = 36,
        },
        Flash = {
            Width = 38,
            Height = 38,
            Color = {1, 1, 1, 0.5},
        },
        Cooldown = {
            Width = 38,
            Height = 38,
        },
        Pushed = {
            Width = 38,
            Height = 38,
            Texture = [[Interface/AddOns/GW2_UI/textures/uistuff/actionbutton-pressed]],
        },
        Normal = {
            Texture = [[Interface\AddOns\GW2_UI\textures\bag\bagnormal]],
            Width = 38,
            Height = 38,
            Static = true,
        },
        Disabled = {
            Hide = true,
        },
        Checked = {
            Width = 38,
            Height = 38,
            BlendMode = "ADD",
            Color = {1, 1, 1, 1},
            Texture = [[Interface/AddOns/GW2_UI/textures/uistuff/UI-Quickslot-Depress]],
        },
        Border = {
            Width = 38,
            Height = 38,
            BlendMode = "ADD",
            Color = {0, 0, 0, 1},
            OffsetX = 0,
            OffsetY = 0,
            Texture = [[Interface\AddOns\GW2_UI\textures\addonSkins\Border]],
        },
        Gloss = {
            Hide = true,
        },
        AutoCastable = {
            Width = 38,
            Height = 38,
            OffsetX = 0.5,
            OffsetY = -0.5,
            Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
        },
        Highlight = "Checked",
        SlotHighlight = "Checked",
        Name = {Hide = true},
        Count = {
            JustifyH = "RIGHT",
            JustifyV = "MIDDLE",
            Width = 38,
            Height = 10,
            Point = "TOPRIGHT",
            RelPoint = "TOPRIGHT",
            OffsetX = -3,
            OffsetY = -3,
        },
        HotKey = {
            JustifyH = "CENTER",
            JustifyV = "MIDDLE",
            DrawLayer = "OVERLAY",
            Width = 38,
            Height = 10,
            Anchor = "Icon",
            Point = "CENTER",
            RelPoint = "BOTTOM",
            OffsetX = 0,
            OffsetY = 0,
        },
        AutoCast = {
            Width = 38,
            Height = 38,
            OffsetX = 1,
            OffsetY = -1,
        },

    }, true)
end
GW.AddMasqueSkin = AddMasqueSkin