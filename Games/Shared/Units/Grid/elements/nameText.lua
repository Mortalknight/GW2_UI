---@class GW2
local GW = select(2, ...)

local function Construct_NameText(frame)
    local name = GW.CreateRaisedText(frame.RaisedElementParent)

    name:SetShadowOffset(-1, -1)
    name:SetShadowColor(0, 0, 0, 1)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(false)
    name:GwSetFontTemplate(UNIT_NAME_FONT, GW.Enum.TextSizeType.Small)

    name:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    name:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)


    return name
end
GW.Construct_NameText = Construct_NameText

local function UpdateNameSettings(frame)
    local name = frame.Name
    frame:Tag(name, frame.nameTagString)
end
GW.UpdateNameSettings = UpdateNameSettings