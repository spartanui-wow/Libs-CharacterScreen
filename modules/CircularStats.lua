---@type LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.CircularStats : AceModule, AceEvent-3.0
local CircularStats = LibCS:NewModule('CircularStats', 'AceEvent-3.0')
LibCS.CircularStats = CircularStats

local isInitialized = false
local config = {}
local statCircles = {}

---@type table<string, table>
local statConfig = {
	['Strength'] = {color = {1, 0, 0}, priority = 1},
	['Agility'] = {color = {0, 1, 0}, priority = 2},
	['Intellect'] = {color = {0, 0, 1}, priority = 3},
	['Stamina'] = {color = {1, 1, 0}, priority = 4},
	['Critical Strike'] = {color = {1, 0.5, 0}, priority = 5},
	['Haste'] = {color = {1, 0, 1}, priority = 6},
	['Mastery'] = {color = {0, 1, 1}, priority = 7},
	['Versatility'] = {color = {0.5, 1, 0.5}, priority = 8}
}

---@type table<number, table>
local progressColors = {
	[0] = {0.5, 0.5, 0.5}, -- Gray (0-10%)
	[10] = {0, 1, 0}, -- Green (10-20%)
	[20] = {0, 0.5, 1}, -- Blue (20-30%)
	[30] = {0.7, 0, 1}, -- Purple (30-40%)
	[40] = {1, 0.5, 0} -- Orange (40%+)
}

function CircularStats:OnInitialize()
	config = LibCS.Database:GetModuleConfig('circularstats')

	-- This module will be disabled by default until implemented
	if not LibCS.Database:GetModuleSetting('circularstats', 'enabled', false) then
		print('CircularStats module framework created but disabled. Enable when ready to implement.')
		return
	end
end

function CircularStats:GetSetting(key, defaultValue)
	return LibCS.Database:GetModuleSetting('circularstats', key, defaultValue)
end

function CircularStats:OnEnable()
	if not self:GetSetting('enabled', false) then
		return
	end

	if not isInitialized then
		self:CreateStatCircles()
		isInitialized = true
	end

	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('COMBAT_RATING_UPDATE')
	self:RegisterEvent('PLAYER_DAMAGE_DONE_MODS')
end

function CircularStats:OnDisable()
	self:UnregisterAllEvents()
	self:RemoveStatCircles()
end

function CircularStats:CreateStatCircles()
	-- Framework for creating circular stat displays
	-- This will replace the traditional CharacterStatsPane stats

	if not CharacterFrameInsetRight then
		return
	end

	local circleSize = self:GetSetting('circleSize', 40)
	local spacing = self:GetSetting('circleSpacing', 5)
	local columns = self:GetSetting('columns', 2)

	-- TODO: Implementation for circular stats
	-- This is the framework that will be expanded later

	--[[ Future Implementation Plan:

    1. Create circular frames for each stat
    2. Add progress rings around each circle showing 0-100%
    3. Color coding: gray->green->blue->purple->orange as percentage increases
    4. Display stat values in center of circles
    5. Position in grid layout within CharacterFrameInsetRight
    6. Update values dynamically when stats change
    7. Tooltips showing detailed stat information

    Stat Categories to Display:
    - Primary Stats: Str/Agi/Int, Stamina
    - Secondary Stats: Crit, Haste, Mastery, Versatility
    - Defensive Stats: Armor, Avoidance
    - Special Stats: Leech, Speed

    Progress Ring Calculation:
    - Each stat will have a soft cap percentage (usually 20-40%)
    - Progress ring fills from 0% to this cap
    - Color transitions based on percentage thresholds

    --]]
end

---@param statName string
---@param value number
---@param percentage number
function CircularStats:UpdateStatCircle(statName, value, percentage)
	-- Framework for updating individual stat circles
	-- Will be implemented when the module is enabled
end

---@param percentage number
---@return table color RGB values
function CircularStats:GetProgressColor(percentage)
	-- Determine color based on percentage thresholds
	for threshold, color in pairs(progressColors) do
		if percentage >= threshold then
			return color
		end
	end
	return progressColors[0] -- Default to gray
end

function CircularStats:RemoveStatCircles()
	-- Clean up circular stat displays
	for statName, circle in pairs(statCircles) do
		if circle and circle.Hide then
			circle:Hide()
			circle:SetParent(nil)
		end
	end
	statCircles = {}
end

function CircularStats:PLAYER_ENTERING_WORLD()
	if self:GetSetting('enabled', false) then
		-- Update all stat circles when entering world
		self:RefreshAllStats()
	end
end

function CircularStats:COMBAT_RATING_UPDATE()
	if self:GetSetting('enabled', false) then
		-- Update secondary stats when combat ratings change
		self:RefreshSecondaryStats()
	end
end

function CircularStats:PLAYER_DAMAGE_DONE_MODS()
	if self:GetSetting('enabled', false) then
		-- Update damage-related stats
		self:RefreshDamageStats()
	end
end

function CircularStats:RefreshAllStats()
	-- Framework for refreshing all stat displays
	-- Implementation pending module enablement
end

function CircularStats:RefreshSecondaryStats()
	-- Framework for refreshing secondary stats (crit, haste, etc.)
	-- Implementation pending module enablement
end

function CircularStats:RefreshDamageStats()
	-- Framework for refreshing damage-related stats
	-- Implementation pending module enablement
end

---@return table<string, table>
function CircularStats:GetStatConfig()
	return statConfig
end

---@return table<string, Frame>
function CircularStats:GetStatCircles()
	return statCircles
end
