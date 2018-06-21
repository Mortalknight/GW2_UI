local _, GW = ...
local windowsList = {}
hasBeenLoaded = false

windowsList[1] = {}
windowsList[1]["ONLOAD"] = gw_register_character_window
windowsList[1]["SETTING_NAME"] = "USE_CHARACTER_WINDOW"
windowsList[1]["TAB_ICON"] = "tabicon_character"
windowsList[1]["ONCLICK"] = function()
    ToggleCharacter("PaperDollFrame")
end
windowsList[1]["OPEN"] = "ToggleTalentFrame"

windowsList[2] = {}
windowsList[2]["ONLOAD"] = gw_register_talent_window
windowsList[2]["SETTING_NAME"] = "USE_TALENT_WINDOW_DEV"
windowsList[2]["TAB_ICON"] = "tabicon_spellbook"
windowsList[2]["ONCLICK"] = function()
    ToggleTalentFrame()
end
windowsList[2]["OPEN"] = "ToggleTalentFrame"

local tabIndex = 1

local function loadBaseFrame()
    if hasBeenLoaded then
        return
    end
    hasBeenLoaded = true

    local fmGCWMF = CreateFrame("Frame", "GwCharacterWindowMoverFrame", UIParent, "GwCharacterWindowMoverFrame")
    local fnGCWMF_OnDragStart = function(self)
        self:StartMoving()
    end
    local fnGCWMF_OnDragStop = function(self)
        self:StopMovingOrSizing()
    end
    fmGCWMF:SetScript("OnDragStart", fnGCWMF_OnDragStart)
    fmGCWMF:SetScript("OnDragStop", fnGCWMF_OnDragStop)
    fmGCWMF:RegisterForDrag("LeftButton")
    CreateFrame("Button", "GwCharacterWindow", UIParent, "GwCharacterWindow,")

    GwCharacterWindow.WindowHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    GwCharacterWindow.WindowHeader:SetTextColor(255 / 255, 241 / 255, 209 / 255)

    GwCharacterWindowMoverFrame:Hide()

    GwCharacterWindow.close:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
    GwCharacterWindow.close:SetFrameRef("GwCharacterWindowMoverFrame", GwCharacterWindowMoverFrame)

    GwCharacterWindow.close:SetAttribute(
        "_onclick",
        [=[
     
        self:GetFrameRef('GwCharacterWindow'):Hide()
        self:GetFrameRef('GwCharacterWindowMoverFrame'):Hide()
        if self:GetFrameRef('GwCharacterWindow'):IsVisible() then
              self:GetFrameRef('GwCharacterWindow'):Hide()
        end
    ]=]
    )

    GwCharacterWindow:SetAttribute("windowPanelOpen", 0)

    --   tinsert(UISpecialFrames, "GwCharacterWindow")

    --   GwCharacterWindow:HookScript('OnHide',function() GwCharacterWindowMoverFrame:Hide() end)
    --    GwCharacterWindow:HookScript('OnShow',function() GwCharacterWindowMoverFrame:Show() end)

    --  table.insert(UISpecialFrames, "GwCharacterWindow")

    GwCharacterWindow:SetAttribute(
        "_onshow",
        [=[ 
        self:SetBindingClick(false,'ESCAPE',self:GetName(),'Escape')
        ]=]
    )
    GwCharacterWindow:SetAttribute("_onhide", [=[
        self:ClearBindings()    
    ]=])
    GwCharacterWindow:SetAttribute(
        "_onclick",
        [=[
        
        if button=='Escape' then
            self:Hide()
            self:GetFrameRef('GwCharacterWindowMoverFrame'):Hide()
        end
    ]=]
    )
    GwCharacterWindow:Hide()
    GwCharacterWindow:SetFrameRef("GwCharacterWindowMoverFrame", GwCharacterWindowMoverFrame)
    GwCharacterWindow:SetAttribute(
        "_onattributechanged",
        [=[ 
       
        
        if value==nil or value==true then return end       
  
        
        if value==1 and self:GetFrameRef('GwCharacterWindowContainer')~=nil and self:GetFrameRef('GwCharacterWindowContainer'):IsVisible()  then
            self:SetAttribute('windowPanelOpen',0)
            return
        end 
        if value==2 and self:GetFrameRef('GwTalentFrame')~=nil and self:GetFrameRef('GwTalentFrame'):IsVisible() then
             self:SetAttribute('windowPanelOpen',0)
            return
        end
        
        
       
        if self:GetFrameRef('GwTalentFrame')~=nil then
            self:GetFrameRef('GwTalentFrame'):Hide()
        end
        if self:GetFrameRef('GwCharacterWindowContainer')~=nil then
            self:GetFrameRef('GwCharacterWindowContainer'):Hide()
        end
    
  
        if not self:IsVisible() and value~=0 then
            self:Show()
            self:GetFrameRef('GwCharacterWindowMoverFrame'):Show()
        end
        

        if value==1 and self:GetFrameRef('GwCharacterWindowContainer')~=nil then
            self:GetFrameRef('GwCharacterWindowContainer'):Show()
        end 
        if value==2 and self:GetFrameRef('GwTalentFrame')~=nil then
            self:GetFrameRef('GwTalentFrame'):Show()
        end
        
        if value==0 then
            self:Hide()
            self:GetFrameRef('GwCharacterWindowMoverFrame'):Hide()
        
        end
  
    ]=]
    )
end

local function setTabIconState(self, b)
    if b then
        self.icon:SetTexCoord(0, 0.5, 0, 0.625)
    else
        self.icon:SetTexCoord(0.5, 1, 0, 0.625)
    end
end

local function createTabIcon(iconName)
    local f =
        CreateFrame(
        "Button",
        "CharacterWindowTab" .. tabIndex,
        GwCharacterWindow,
        "SecureHandlerClickTemplate,SecureHandlerStateTemplate,CharacterWindowTabSelect"
    )

    f.icon:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\character\\" .. iconName)

    f:SetPoint("TOP", GwCharacterWindow, "TOPLEFT", -32, -25 + -((tabIndex - 1) * 45))

    tabIndex = tabIndex + 1

    setTabIconState(f, false)

    return f
end

function Gw_LoadWindows()
    local anyThingToLoad = false
    for k, v in pairs(windowsList) do
        if gwGetSetting(v["SETTING_NAME"]) then
            anyThingToLoad = true
        end
    end
    if not anyThingToLoad then
        return
    end

    loadBaseFrame()

    for k, v in pairs(windowsList) do
        if gwGetSetting(v["SETTING_NAME"]) then
            local ref = v["ONLOAD"]()

            GwCharacterWindow:SetFrameRef(ref:GetName(), ref)

            local f = createTabIcon(v["TAB_ICON"])
            ref:HookScript(
                "OnShow",
                function()
                    setTabIconState(f, true)
                end
            )
            ref:HookScript(
                "OnHide",
                function()
                    setTabIconState(f, false)
                end
            )
        end
    end

    if CharacterWindowTab1 then
        CharacterWindowTab1:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
        CharacterWindowTab1:SetAttribute(
            "_OnClick",
            [=[ 
                self:GetFrameRef('GwCharacterWindow'):SetAttribute('windowPanelOpen',1)
        
            ]=]
        )

        CreateFrame(
            "Button",
            "gwFrameCombatTogglerCharacter",
            UIParent,
            "SecureActionButtonTemplate,gwFrameCombatTogglerSpellbook"
        )

        gwFrameCombatTogglerCharacter:SetAttribute("type", "attribute")
        gwFrameCombatTogglerCharacter:SetAttribute("attribute-frame", GwCharacterWindow)
        gwFrameCombatTogglerCharacter:SetAttribute("attribute-name", "windowPanelOpen")
        gwFrameCombatTogglerCharacter:SetAttribute("attribute-value", 1)
        if GetBindingKey("TOGGLECHARACTER0") ~= nil then
            SetBinding(GetBindingKey("TOGGLECHARACTER0"), "CLICK gwFrameCombatTogglerCharacter:LeftButton")
        end
    end
    if CharacterWindowTab2 then
        CharacterWindowTab2:SetFrameRef("GwCharacterWindow", GwCharacterWindow)
        CharacterWindowTab2:SetAttribute(
            "_OnClick",
            [=[ 
                self:GetFrameRef('GwCharacterWindow'):SetAttribute('windowPanelOpen',2)
        
            ]=]
        )
        CreateFrame(
            "Button",
            "gwFrameCombatTogglerSpellbook",
            UIParent,
            "SecureActionButtonTemplate,gwFrameCombatTogglerSpellbook"
        )

        gwFrameCombatTogglerSpellbook:SetAttribute("type", "attribute")
        gwFrameCombatTogglerSpellbook:SetAttribute("type2", "attribute")
        gwFrameCombatTogglerSpellbook:SetAttribute("attribute-frame", GwCharacterWindow)
        gwFrameCombatTogglerSpellbook:SetAttribute("attribute-name", "windowPanelOpen")
        gwFrameCombatTogglerSpellbook:SetAttribute("attribute-value", 2)
        if GetBindingKey("TOGGLESPELLBOOK") ~= nil then
            SetBinding(GetBindingKey("TOGGLESPELLBOOK"), "CLICK gwFrameCombatTogglerSpellbook:LeftButton")
        end
        if GetBindingKey("TOGGLETALENTS") ~= nil then
            SetBinding(GetBindingKey("TOGGLETALENTS"), "CLICK gwFrameCombatTogglerSpellbook:RightButton")
        end
    end
end
