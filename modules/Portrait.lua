---@type LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.Portrait : AceModule, AceEvent-3.0
local Portrait = LibCS:NewModule('Portrait', 'AceEvent-3.0')
LibCS.Portrait = Portrait

local isInitialized = false
local config = {}

function Portrait:OnInitialize()
    config = LibCS.Database:GetModuleConfig('portrait')
    self:SetupDynamicBackgrounds()
end

function Portrait:GetSetting(key, defaultValue)
    return LibCS.Database:GetModuleSetting('portrait', key, defaultValue)
end

function Portrait:OnEnable()
    if not isInitialized then
        self:EnhanceExistingPortrait()
        isInitialized = true
    end
    
    self:RegisterEvent('ACTIVE_PLAYER_SPECIALIZATION_CHANGED')
    self:RegisterEvent('UNIT_LEVEL')
    self:RegisterEvent('UNIT_NAME_UPDATE')
    self:RegisterEvent('PLAYER_TALENT_UPDATE')
end

function Portrait:OnDisable()
    self:UnregisterAllEvents()
    self:RestoreOriginalPortrait()
end

function Portrait:EnhanceExistingPortrait()
    if not CharacterModelScene then
        return
    end
    
    self:SetupDynamicBackground()
    self:EnhanceCharacterInfo()
end

function Portrait:SetupDynamicBackgrounds()
    if not self:GetSetting('showBackground', true) then
        return
    end
    
    local visual, isAtlas = LibCS:GetDynamicBackground()
    if visual then
        self:ApplyBackground(visual, isAtlas)
    end
end

---@param visual string
---@param isAtlas boolean
function Portrait:ApplyBackground(visual, isAtlas)
    if not LibCS.CharacterFrameBgTex then
        return
    end
    
    if isAtlas then
        LibCS.CharacterFrameBgTex:SetAtlas(visual, true)
    else
        LibCS.CharacterFrameBgTex:SetTexture(visual)
    end
end

function Portrait:EnhanceCharacterInfo()
    if not self:GetSetting('showHeader', true) and not self:GetSetting('showFooter', true) then
        return
    end
    
    self:UpdateCharacterInfo()
end

function Portrait:UpdateCharacterInfo()
    local playerName = UnitName('player')
    local playerLevel = UnitLevel('player')
    local className = UnitClass('player')
    
    local specName = ''
    if GetSpecialization then
        local spec = GetSpecialization()
        if spec then
            local _, specNameFull = GetSpecializationInfo(spec)
            specName = specNameFull and (specNameFull .. ' ') or ''
        end
    end
    
    if self:GetSetting('showHeader', true) then
        local headerText = string.format('%d %s', playerLevel, playerName)
        self:UpdateFrameText('header', headerText)
    end
    
    if self:GetSetting('showFooter', true) then
        local footerText = specName .. className
        self:UpdateFrameText('footer', footerText)
    end
end

---@param frameType 'header'|'footer'
---@param text string
function Portrait:UpdateFrameText(frameType, text)
    if frameType == 'header' then
        -- Create header banner frame
        local headerFrame = self:GetOrCreateHeaderFrame()
        if CharacterFrameTitleText then
            CharacterFrameTitleText:SetParent(headerFrame)
            CharacterFrameTitleText:ClearAllPoints()
            CharacterFrameTitleText:SetPoint('CENTER', headerFrame, 'CENTER')
            CharacterFrameTitleText:SetText(text)
        end
        if CharacterLevelText then
            CharacterLevelText:SetText('')
        end
    elseif frameType == 'footer' then
        local footerFrame = self:GetOrCreateFooterFrame()
        if footerFrame and footerFrame.text then
            footerFrame.text:SetText(text)
        end
    end
end

function Portrait:GetOrCreateFooterFrame()
    if _G['LibCS_FooterFrame'] then
        return _G['LibCS_FooterFrame']
    end
    
    local footerFrame = CreateFrame('Frame', 'LibCS_FooterFrame', CharacterFrame)
    footerFrame:SetSize(200, 30)
    footerFrame:SetPoint('BOTTOM', CharacterFrame, 'BOTTOM', 0, 25)
    
    -- Add banner background
    footerFrame.background = footerFrame:CreateTexture(nil, 'BACKGROUND')
    footerFrame.background:SetAtlas('gearUpdate-BG', true)
    footerFrame.background:SetAllPoints()
    
    footerFrame.text = footerFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    footerFrame.text:SetPoint('CENTER')
    footerFrame.text:SetTextColor(1, 1, 1, 1)
    
    return footerFrame
end

function Portrait:GetOrCreateHeaderFrame()
    if _G['LibCS_HeaderFrame'] then
        return _G['LibCS_HeaderFrame']
    end
    
    local headerFrame = CreateFrame('Frame', 'LibCS_HeaderFrame', CharacterFrame)
    headerFrame:SetSize(200, 30)
    headerFrame:SetPoint('TOP', CharacterFrame, 'TOP', 0, -25)
    
    -- Add banner background  
    headerFrame.background = headerFrame:CreateTexture(nil, 'BACKGROUND')
    headerFrame.background:SetAtlas('gearUpdate-BG', true)
    headerFrame.background:SetAllPoints()
    
    return headerFrame
end

function Portrait:RestoreOriginalPortrait()
    if _G['LibCS_FooterFrame'] then
        _G['LibCS_FooterFrame']:Hide()
    end
    
    if CharacterFrameTitleText then
        CharacterFrameTitleText:SetText(UnitPVPName('player') or UnitName('player'))
    end
    
    if CharacterLevelText then
        local level = UnitLevel('player')
        if level > 0 then
            CharacterLevelText:SetText(LEVEL .. ' ' .. level)
        end
    end
end

function Portrait:OnFrameShow()
    if self:GetSetting('showBackground', true) then
        self:SetupDynamicBackgrounds()
    end
    self:UpdateCharacterInfo()
end

function Portrait:OnFrameHide()
end

function Portrait:RefreshModel()
    if CharacterModelScene and CharacterModelScene:IsShown() then
        -- Try different API methods to refresh character model
        if CharacterModelScene.RefreshUnit then
            CharacterModelScene:RefreshUnit()
        elseif CharacterModelScene.SetDisplayInfo then
            -- Alternative: force refresh by getting current display info
            local displayInfo = C_PlayerInfo.GetDisplayID()
            if displayInfo then
                CharacterModelScene:SetDisplayInfo(displayInfo)
            end
        elseif CharacterModelScene.SetModelByUnit then
            CharacterModelScene:SetModelByUnit('player')
        end
    end
end

function Portrait:SetupDynamicBackground()
    if not self:GetSetting('showBackground', true) then
        return
    end
    
    local textureKit = self:GetCurrentTextureKit()
    self:ApplyTextureKit(textureKit)
end

---@return string
function Portrait:GetCurrentTextureKit()
    local _, className = UnitClass('player')
    local factionGroup = UnitFactionGroup('player')
    
    if factionGroup == 'Alliance' then
        return 'alliance'
    elseif factionGroup == 'Horde' then
        return 'horde'
    else
        return 'neutral'
    end
end

---@param textureKit string
function Portrait:ApplyTextureKit(textureKit)
    if not LibCS.CharacterFrameBg then
        return
    end
    
    local visual, isAtlas = LibCS:GetDynamicBackground()
    if visual then
        self:ApplyBackground(visual, isAtlas)
    else
        self:ApplyFallbackBackground(textureKit)
    end
end

---@param textureKit string  
function Portrait:ApplyFallbackBackground(textureKit)
    if not LibCS.CharacterFrameBgTex then
        return
    end
    
    local fallbackTexture = string.format('Interface\\AddOns\\Libs-CharacterScreen\\media\\frame\\UIFrame%s.png', 
        textureKit:gsub('^%l', string.upper))
    
    LibCS.CharacterFrameBgTex:SetTexture(fallbackTexture)
end

function Portrait:ACTIVE_PLAYER_SPECIALIZATION_CHANGED()
    if self:GetSetting('showBackground', true) then
        self:SetupDynamicBackgrounds()
    end
    self:UpdateCharacterInfo()
end

---@param event string
---@param unit string
function Portrait:UNIT_LEVEL(event, unit)
    if unit == 'player' then
        self:UpdateCharacterInfo()
    end
end

---@param event string  
---@param unit string
function Portrait:UNIT_NAME_UPDATE(event, unit)
    if unit == 'player' then
        self:UpdateCharacterInfo()
    end
end

function Portrait:PLAYER_TALENT_UPDATE()
    self:UpdateCharacterInfo()
end