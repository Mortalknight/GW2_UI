---@class GW2
local GW = select(2, ...)

local L = GW.L
local PROTECTED_LINE = L["<protected message, cannot be copied>"]
local window

-- the last lines of a chat window as plain text in their chat colors
local function GetChatText(chatFrame)
    local lines = {}
    local numMessages = chatFrame:GetNumMessages()
    for index = math.max(1, numMessages - GW.settings.chat.maxCopyLines + 1), numMessages do
        local text, r, g, b = chatFrame:GetMessageInfo(index)
        if GW.IsSecretValue(text) or type(text) == "string" and strfind(text, "|K", 1, true) then
            tinsert(lines, GW.RGBToHex(GW.Colors.SkinColors.Disabled:GetRGB()) .. PROTECTED_LINE .. "|r")
        elseif type(text) == "string" then
            tinsert(lines, GW.RGBToHex(r or 1, g or 1, b or 1) .. GW.GetPlainChatLine(text, true) .. "|r")
        end
    end
    return table.concat(lines, "\n")
end

local function CreateWindow()
    window = CreateFrame("Frame", "GW2_UICopyChatFrame", UIParent)
    window:SetSize(700, 200)
    window:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 15)
    window:SetFrameStrata("DIALOG")
    window:SetMovable(true)
    window:SetResizable(true)
    window:SetResizeBounds(350, 100)
    window:EnableMouse(true)
    window:Hide()
    tinsert(UISpecialFrames, "GW2_UICopyChatFrame")

    window:GwCreateBackdrop(GW.BackdropTemplates.Default, true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    window:SetScript("OnHide", window.StopMovingOrSizing)

    local resizer = CreateFrame("Button", nil, window)
    resizer:SetSize(16, 16)
    resizer:SetPoint("BOTTOMRIGHT", -2, 2)
    resizer:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/resize.png")
    resizer:SetScript("OnMouseDown", function() window:StartSizing("BOTTOMRIGHT") end)
    resizer:SetScript("OnMouseUp", function() window:StopMovingOrSizing() end)

    local text = CreateFrame("Frame", nil, window, "ScrollingEditBoxTemplate")
    text:SetPoint("TOPLEFT", 8, -30)
    text:SetPoint("BOTTOMRIGHT", -20, 20)
    text:GetEditBox():SetMaxLetters(0) -- a few hundred lines are far beyond the default
    if GW.settings.chat.gw2Style then
        local _, size = text:GetEditBox():GetFont()
        text:GetEditBox():SetFont(GW.Libs.LSM:Fetch("font", "GW2_UI_Chat"), size or 14, "")
    end
    text:RegisterCallback("OnEscapePressed", window.Hide, window)
    window.text = text

    local scrollBar = CreateFrame("EventFrame", nil, window, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", text, "TOPRIGHT", 6, 0)
    scrollBar:SetPoint("BOTTOMLEFT", text, "BOTTOMRIGHT", 6, 0)
    ScrollUtil.RegisterScrollBoxWithScrollBar(text:GetScrollBox(), scrollBar)
    GW.SkinSlimScrollBar(scrollBar)

    local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT")
    close:SetSize(20, 20)
    close:GwSkinButton(true)
end

local function ToggleWindow(chatFrame)
    if window:IsShown() then
        window:Hide()
        return
    end
    local editBox = window.text:GetEditBox()
    window.text:SetText(GetChatText(chatFrame))
    window:Show()
    editBox:SetCursorPosition(editBox:GetNumLetters())
    for _, delay in ipairs({0, 0.1}) do
        C_Timer.After(delay, function()
            window.text:GetScrollBox():ScrollToEnd(ScrollBoxConstants.NoScrollInterpolation)
        end)
    end
end

-- a right click on the button of the main window opens blizzards chat menu instead
local function OpenChatMenu(button)
    if ChatMenu then
        ChatMenu:ClearAllPoints()
        if strfind(GW.GetScreenQuadrant(button), "LEFT") then
            ChatMenu:SetPoint("BOTTOMLEFT", button, "TOPRIGHT")
        else
            ChatMenu:SetPoint("BOTTOMRIGHT", button, "TOPLEFT")
        end
        ToggleFrame(ChatMenu)
    else
        ChatFrameMenuButton:OpenMenu()
    end
end

-- chatFrame.copyButton, the chat fading shows and hides it with the tab
local function CreateButton(chatFrame)
    local button = CreateFrame("Button", nil, chatFrame)
    button:SetSize(20, 22)
    button:SetPoint("TOPRIGHT", chatFrame, "TOPRIGHT", GW.isModern and 20 or 0, GW.isModern and 26 or 4)
    button:SetFrameLevel(chatFrame:GetFrameLevel() + 5)
    button:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/maximize_button.png")
    button:GetNormalTexture():SetAlpha(0.35)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetScript("OnClick", function()
        ToggleWindow(chatFrame)
    end)
    button:SetScript("OnEnter", function(self) self:GetNormalTexture():SetAlpha(1) end)
    button:SetScript("OnLeave", function(self) self:GetNormalTexture():SetAlpha(0.35) end)
    chatFrame.copyButton = button
end

GW.RegisterChatModule({
    onLoad = CreateWindow,
    onFrame = CreateButton,
})
