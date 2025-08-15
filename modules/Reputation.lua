---@type LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.Reputation : AceModule, AceEvent-3.0
local Reputation = LibCS:NewModule('Reputation', 'AceEvent-3.0')
LibCS.Reputation = Reputation

local isInitialized = false
local config = {}

function Reputation:OnInitialize()
    config = LibCS.Database:GetModuleConfig('reputation')
end

function Reputation:GetSetting(key, defaultValue)
    return LibCS.Database:GetModuleSetting('reputation', key, defaultValue)
end

function Reputation:OnEnable()
    if not self:GetSetting('enabled', true) then
        return
    end
    
    if not isInitialized then
        self:EnhanceReputationFrame()
        isInitialized = true
    end
    
    self:RegisterEvent('UPDATE_FACTION')
    self:RegisterEvent('PLAYER_ENTERING_WORLD')
end

function Reputation:OnDisable()
    self:UnregisterAllEvents()
end

function Reputation:EnhanceReputationFrame()
    -- Hook ReputationFrame updates to enhance display
    if ReputationFrame and ReputationFrame.ScrollBox then
        self:SecureHookScript(ReputationFrame.ScrollBox, 'OnUpdate', 'UpdateReputationDisplay')
        
        -- Initial update
        C_Timer.After(1, function()
            self:UpdateReputationDisplay()
        end)
    end
end

function Reputation:UpdateReputationDisplay()
    -- Skip if PrettyReps is loaded (compatibility)
    if IsAddOnLoaded('PrettyReps') then
        return
    end
    
    if not ReputationFrame or not ReputationFrame.ScrollBox or not ReputationFrame.ScrollBox.ScrollTarget then
        return
    end
    
    local children = {ReputationFrame.ScrollBox.ScrollTarget:GetChildren()}
    
    for _, child in ipairs(children) do
        if child.index then
            self:EnhanceReputationRow(child)
        end
    end
end

---@param row Frame
function Reputation:EnhanceReputationRow(row)
    if not row or not row.index then
        return
    end
    
    local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canSetInactive = GetFactionInfo(row.index)
    
    if not name or name == 'Inactive' or name == 'Other' then
        return
    end
    
    local children = {row:GetChildren()}
    for _, rowChild in ipairs(children) do
        self:StyleReputationRowChild(rowChild, factionID, standingID, barMin, barMax, barValue)
    end
end

---@param rowChild Frame
---@param factionID number
---@param standingID number
---@param barMin number
---@param barMax number
---@param barValue number
function Reputation:StyleReputationRowChild(rowChild, factionID, standingID, barMin, barMax, barValue)
    -- Style background
    if rowChild.Background then
        rowChild.Background:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\Gradient.jpg')
        rowChild.Background:SetColorTexture(0.15, 0.15, 0.15, 0.90)
        
        if rowChild.ReputationBar then
            rowChild.Background:SetPoint('TOPRIGHT', rowChild.ReputationBar, 'TOPLEFT')
            rowChild.Background:SetHeight(rowChild:GetHeight() * 0.9)
        end
    end
    
    -- Style reputation bar
    if rowChild.ReputationBar then
        self:StyleReputationBar(rowChild.ReputationBar, rowChild, factionID, standingID, barMin, barMax, barValue)
    end
end

---@param repBar Frame
---@param parent Frame
---@param factionID number
---@param standingID number
---@param barMin number
---@param barMax number
---@param barValue number
function Reputation:StyleReputationBar(repBar, parent, factionID, standingID, barMin, barMax, barValue)
    if repBar.LeftTexture then
        repBar.LeftTexture:SetTexture('Interface\\AddOns\\Libs-CharacterScreen\\media\\Gradient.jpg')
        
        -- Create gradient based on reputation standing
        local color1, color2 = self:GetReputationColors(factionID, standingID)
        repBar.LeftTexture:SetGradient('Vertical', color1, color2)
        repBar.LeftTexture:SetAlpha(0.9)
        repBar.LeftTexture:SetPoint('RIGHT', parent, 'RIGHT')
        
        repBar:SetWidth(202)
        repBar:SetHeight(parent:GetHeight() * 0.9)
    end
    
    if repBar.RightTexture then
        repBar.RightTexture:Hide()
    end
    
    -- Handle special faction types
    self:HandleSpecialFactionTypes(repBar, parent, factionID, standingID)
end

---@param factionID number
---@param standingID number
---@return table, table
function Reputation:GetReputationColors(factionID, standingID)
    -- Check for special faction types
    local isMajorFaction = factionID and C_Reputation.IsMajorFaction(factionID)
    local isParagon = factionID and C_Reputation.IsFactionParagon(factionID)
    local repInfo = factionID and C_GossipInfo.GetFriendshipReputation(factionID)
    
    if isMajorFaction then
        -- Special colors for major factions (more vibrant)
        return CreateColor(0.1, 0.3, 0.8, 0.4), CreateColor(0.2, 0.5, 1.0, 0.8) -- Blue gradient
    elseif isParagon then
        -- Gold/orange for paragon factions
        return CreateColor(0.8, 0.5, 0.1, 0.4), CreateColor(1.0, 0.8, 0.2, 0.8)
    elseif repInfo and repInfo.friendshipFactionID > 0 then
        -- Green for friendship factions
        return CreateColor(0.1, 0.6, 0.2, 0.4), CreateColor(0.2, 0.8, 0.4, 0.8)
    else
        -- Standard reputation colors
        local colorIndex = standingID or 4
        local barColor = FACTION_BAR_COLORS[colorIndex]
        if barColor then
            local r, g, b = barColor.r, barColor.g, barColor.b
            return CreateColor(r * 0.3, g * 0.3, b * 0.3, 0.4), CreateColor(r, g, b, 0.8)
        end
    end
    
    -- Fallback colors (neutral gray)
    return CreateColor(0.2, 0.2, 0.2, 0.4), CreateColor(0.5, 0.5, 0.5, 0.8)
end

---@param repBar Frame
---@param parent Frame
---@param factionID number
---@param standingID number
function Reputation:HandleSpecialFactionTypes(repBar, parent, factionID, standingID)
    if not factionID then
        return
    end
    
    local isMajorFaction = C_Reputation.IsMajorFaction(factionID)
    if isMajorFaction then
        self:UpdateMajorFactionDisplay(repBar, parent, factionID)
    end
    
    local isParagon = C_Reputation.IsFactionParagon(factionID)
    if isParagon then
        self:UpdateParagonDisplay(repBar, parent, factionID)
    end
end

---@param repBar Frame
---@param parent Frame
---@param factionID number
function Reputation:UpdateMajorFactionDisplay(repBar, parent, factionID)
    -- Enhanced display for major factions (Dragonflight, TWW, etc.)
    if not repBar.LibCS_MajorFactionGlow then
        repBar.LibCS_MajorFactionGlow = repBar:CreateTexture(nil, 'OVERLAY')
        repBar.LibCS_MajorFactionGlow:SetAtlas('UI-thewarwithin-Highlight-Top', true)
        repBar.LibCS_MajorFactionGlow:SetPoint('CENTER', repBar, 'CENTER')
        repBar.LibCS_MajorFactionGlow:SetAlpha(0.3)
        repBar.LibCS_MajorFactionGlow:SetScale(0.8)
    end
    
    repBar.LibCS_MajorFactionGlow:Show()
end

---@param repBar Frame  
---@param parent Frame
---@param factionID number
function Reputation:UpdateParagonDisplay(repBar, parent, factionID)
    -- Special treatment for paragon factions
    local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
    
    if hasRewardPending and not repBar.LibCS_ParagonIndicator then
        repBar.LibCS_ParagonIndicator = repBar:CreateTexture(nil, 'OVERLAY')
        repBar.LibCS_ParagonIndicator:SetAtlas('UI-thewarwithin-embellishmenttop', true)
        repBar.LibCS_ParagonIndicator:SetPoint('RIGHT', repBar, 'RIGHT', 5, 0)
        repBar.LibCS_ParagonIndicator:SetSize(16, 16)
        repBar.LibCS_ParagonIndicator:SetVertexColor(1, 0.8, 0) -- Gold color
    end
    
    if repBar.LibCS_ParagonIndicator then
        repBar.LibCS_ParagonIndicator:SetShown(hasRewardPending)
    end
end

function Reputation:UPDATE_FACTION()
    C_Timer.After(0.1, function()
        self:UpdateReputationDisplay()
    end)
end

function Reputation:PLAYER_ENTERING_WORLD()
    C_Timer.After(2, function()
        self:UpdateReputationDisplay()
    end)
end

-- Utility functions for other modules
---@param factionID number
---@return boolean
function Reputation:IsMajorFaction(factionID)
    return factionID and C_Reputation.IsMajorFaction(factionID) or false
end

---@param factionID number  
---@return table?
function Reputation:GetFactionInfo(factionID)
    if not factionID then
        return nil
    end
    
    local info = {}
    info.isMajor = C_Reputation.IsMajorFaction(factionID)
    info.isParagon = C_Reputation.IsFactionParagon(factionID)
    info.friendship = C_GossipInfo.GetFriendshipReputation(factionID)
    
    if info.isParagon then
        local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
        info.paragon = {
            currentValue = currentValue,
            threshold = threshold,
            rewardQuestID = rewardQuestID,
            hasRewardPending = hasRewardPending
        }
    end
    
    return info
end