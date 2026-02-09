---@class LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.Stats : AceModule, AceEvent-3.0
local Stats = LibCS:NewModule('Stats', 'AceEvent-3.0')
LibCS.Stats = Stats

-- Blizzard's official DR brackets (percent caps + multipliers)
-- Reference: https://www.wowhead.com/guide/diminishing-returns-on-secondary-stats-in-world-of-warcraft
local DR_BRACKETS = {
	{ 30, 1.00 }, -- 0% penalty (0-30%)
	{ 39, 0.90 }, -- 10% penalty (30-39%)
	{ 47, 0.80 }, -- 20% penalty (39-47%)
	{ 54, 0.70 }, -- 30% penalty (47-54%)
	{ 66, 0.60 }, -- 40% penalty (54-66%)
	{ 126, 0.50 }, -- 50% penalty (66-126%)
}

-- Color thresholds for DR visualization
local DR_COLORS = {
	{ threshold = 0, color = { 0.0, 1.0, 0.0 } }, -- Green: no DR
	{ threshold = 30, color = { 1.0, 1.0, 0.0 } }, -- Yellow: mild DR
	{ threshold = 47, color = { 1.0, 0.5, 0.0 } }, -- Orange: moderate DR
	{ threshold = 66, color = { 1.0, 0.0, 0.0 } }, -- Red: severe DR
}

-- Combat rating constants
local RATING_IDS = {
	CriticalStrike = CR_CRIT_SPELL,
	Haste = CR_HASTE_SPELL,
	Mastery = CR_MASTERY,
	Versatility = CR_VERSATILITY_DAMAGE_DONE,
	VersatilityDR = CR_VERSATILITY_DAMAGE_TAKEN,
	Leech = CR_LIFESTEAL,
	Avoidance = CR_AVOIDANCE,
	Speed = CR_SPEED,
}

-- Stat display order
local STAT_ORDER = {
	{ key = 'CriticalStrike', name = STAT_CRITICAL_STRIKE, hasDR = true },
	{ key = 'Haste', name = STAT_HASTE, hasDR = true },
	{ key = 'Mastery', name = STAT_MASTERY, hasDR = true },
	{ key = 'Versatility', name = STAT_VERSATILITY, hasDR = true },
}

local TERTIARY_STATS = {
	{ key = 'Leech', name = STAT_LIFESTEAL, hasDR = true },
	{ key = 'Avoidance', name = STAT_AVOIDANCE, hasDR = true },
	{ key = 'Speed', name = STAT_SPEED, hasDR = true },
}

---@class StatDRInfo
---@field rawRating number
---@field rawPercent number
---@field rawPercent2 number? For versatility (damage reduction)
---@field effectivePercent number
---@field effectivePercent2 number? For versatility
---@field percentLost number
---@field percentLost2 number? For versatility
---@field ratingLost number
---@field effectiveRating number

-- Local state
local statsFrame = nil
local statRows = {}
local isInitialized = false

---Apply diminishing returns to a raw percent value
---@param rawPercent number
---@return number effectivePercent
---@return number percentLost
local function ApplySecondaryDR(rawPercent)
	local remaining = rawPercent
	local effective = 0
	local lastCap = 0

	for _, bracket in ipairs(DR_BRACKETS) do
		if remaining <= 0 then
			break
		end

		local cap, mult = bracket[1], bracket[2]
		local slice = math.min(remaining, cap - lastCap)

		effective = effective + slice * mult
		remaining = remaining - slice
		lastCap = cap
	end

	local percentLost = rawPercent - effective
	return effective, percentLost
end

---Get the color for a given DR percentage
---@param rawPercent number
---@return number r
---@return number g
---@return number b
local function GetDRColor(rawPercent)
	local selectedColor = DR_COLORS[1].color

	for _, colorDef in ipairs(DR_COLORS) do
		if rawPercent >= colorDef.threshold then
			selectedColor = colorDef.color
		end
	end

	return selectedColor[1], selectedColor[2], selectedColor[3]
end

---Get DR info for a specific combat rating
---@param ratingID number
---@return StatDRInfo
function Stats:GetStatDRInfo(ratingID)
	local rawRating = GetCombatRating(ratingID)

	-- If no rating, no DR applies
	if rawRating <= 0 then
		return {
			rawRating = 0,
			rawPercent = 0,
			rawPercent2 = 0,
			effectivePercent = 0,
			effectivePercent2 = 0,
			percentLost = 0,
			percentLost2 = 0,
			ratingLost = 0,
			effectiveRating = 0,
		}
	end

	local rawPercent, rawPercent2 = 0, 0
	local ratingPercent = 0
	local effectivePercent, effectivePercent2 = 0, 0
	local percentLost, percentLost2 = 0, 0

	-- Versatility has two bonuses (damage done and damage taken reduction)
	if ratingID == CR_VERSATILITY_DAMAGE_DONE then
		-- Rating-derived %
		ratingPercent = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
		local ratingPercent2 = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN)

		-- Total raw % (rating + buffs)
		rawPercent = ratingPercent + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
		rawPercent2 = ratingPercent2 + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)

		-- Apply DR to raw %
		effectivePercent, percentLost = ApplySecondaryDR(rawPercent)
		effectivePercent2, percentLost2 = ApplySecondaryDR(rawPercent2)
	else
		-- Normal secondary stat
		ratingPercent = GetCombatRatingBonus(ratingID)
		rawPercent = ratingPercent

		effectivePercent, percentLost = ApplySecondaryDR(rawPercent)
	end

	-- Convert % lost to rating lost (using rating-derived % only)
	local ratingLost = 0
	local effectiveRating = rawRating
	if ratingPercent > 0 then
		local percentPerRating = ratingPercent / rawRating
		ratingLost = percentLost / percentPerRating
		effectiveRating = rawRating - ratingLost
	end

	return {
		rawRating = rawRating,
		rawPercent = rawPercent,
		rawPercent2 = rawPercent2,
		effectivePercent = effectivePercent,
		effectivePercent2 = effectivePercent2,
		percentLost = percentLost,
		percentLost2 = percentLost2,
		ratingLost = ratingLost,
		effectiveRating = effectiveRating,
	}
end

---Get current movement speed
---@return number currentSpeed
---@return number runSpeed
---@return number flightSpeed
---@return number swimSpeed
function Stats:GetMovementSpeed()
	local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed('player')
	runSpeed = runSpeed / BASE_MOVEMENT_SPEED * 100
	flightSpeed = flightSpeed / BASE_MOVEMENT_SPEED * 100
	swimSpeed = swimSpeed / BASE_MOVEMENT_SPEED * 100
	currentSpeed = currentSpeed / BASE_MOVEMENT_SPEED * 100

	local displaySpeed = runSpeed

	if UnitInVehicle('player') then
		local vehicleSpeed = GetUnitSpeed('Vehicle') / BASE_MOVEMENT_SPEED * 100
		displaySpeed = vehicleSpeed
	elseif IsSwimming('player') then
		displaySpeed = swimSpeed
	elseif UnitOnTaxi('player') then
		displaySpeed = currentSpeed
	elseif IsFlying('player') then
		displaySpeed = flightSpeed
	end

	return displaySpeed, runSpeed, flightSpeed, swimSpeed
end

---Create a stat row frame
---@param parent Frame
---@param index number
---@return Frame
local function CreateStatRow(parent, index)
	local row = CreateFrame('Frame', nil, parent)
	row:SetHeight(18)

	-- Stat name (left)
	row.name = row:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
	row.name:SetPoint('LEFT', row, 'LEFT', 0, 0)
	row.name:SetJustifyH('LEFT')

	-- Stat value (right)
	row.value = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
	row.value:SetPoint('RIGHT', row, 'RIGHT', 0, 0)
	row.value:SetJustifyH('RIGHT')

	-- DR indicator (between name and value)
	row.dr = row:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
	row.dr:SetPoint('RIGHT', row.value, 'LEFT', -5, 0)
	row.dr:SetJustifyH('RIGHT')
	row.dr:Hide()

	row:SetScript('OnEnter', function(self)
		if self.tooltipTitle then
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
			GameTooltip:AddLine(self.tooltipTitle, 1, 1, 1)
			if self.tooltipText then
				GameTooltip:AddLine(self.tooltipText, nil, nil, nil, true)
			end
			GameTooltip:Show()
		end
	end)

	row:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)

	return row
end

---Update a stat row with current data
---@param row Frame
---@param statDef table
local function UpdateStatRow(row, statDef)
	local ratingID = RATING_IDS[statDef.key]
	if not ratingID then
		row:Hide()
		return
	end

	local drInfo = Stats:GetStatDRInfo(ratingID)

	-- Set name
	row.name:SetText(statDef.name)

	-- Set value based on stat type
	local valueText = ''
	local r, g, b = GetDRColor(drInfo.rawPercent)

	if statDef.key == 'Versatility' then
		-- Versatility shows both damage and DR values
		valueText = format('%.2f%% / %.2f%%', drInfo.effectivePercent, drInfo.effectivePercent2)
	elseif statDef.key == 'Mastery' then
		-- Mastery uses GetMasteryEffect for actual bonus
		local masteryEffect = GetMasteryEffect()
		valueText = format('%.2f%%', masteryEffect)
	else
		valueText = format('%.2f%%', drInfo.effectivePercent)
	end

	row.value:SetText(valueText)
	row.value:SetTextColor(r, g, b)

	-- Set DR indicator if there's DR loss
	if statDef.hasDR and drInfo.percentLost > 0.01 then
		row.dr:SetText(format('(-%.1f%%)', drInfo.percentLost))
		row.dr:SetTextColor(1, 0.3, 0.3)
		row.dr:Show()
	else
		row.dr:Hide()
	end

	-- Build tooltip
	row.tooltipTitle = format('%s: %d rating', statDef.name, drInfo.rawRating)
	local tooltipLines = {
		format('Raw: %.2f%%', drInfo.rawPercent),
		format('Effective: %.2f%%', drInfo.effectivePercent),
	}
	if drInfo.percentLost > 0.01 then
		table.insert(tooltipLines, format('|cffff5555Lost to DR: %.2f%% (%d rating)|r', drInfo.percentLost, drInfo.ratingLost))
	end
	row.tooltipText = table.concat(tooltipLines, '\n')

	row:Show()
end

---Create the stats display frame
function Stats:CreateStatsFrame()
	if statsFrame then
		return statsFrame
	end

	-- Create main container parented to CharacterFrame directly for visibility
	statsFrame = CreateFrame('Frame', 'LibCS_StatsFrame', CharacterFrame)
	statsFrame:SetSize(180, 300)
	-- Position on right side of the character frame
	statsFrame:SetPoint('TOPLEFT', CharacterFrame, 'TOPRIGHT', 10, -50)
	statsFrame:SetFrameStrata('HIGH')

	-- Add a visible background so we can see it
	statsFrame.bg = statsFrame:CreateTexture(nil, 'BACKGROUND')
	statsFrame.bg:SetAllPoints()
	statsFrame.bg:SetColorTexture(0.1, 0.1, 0.1, 0.9)

	LibCS.Logger.info('Stats: Created stats frame at TOPRIGHT of CharacterFrame')

	-- Header
	local header = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
	header:SetPoint('TOP', statsFrame, 'TOP', 0, -10)
	header:SetText('Combat Stats')
	statsFrame.header = header

	-- Create stat rows directly (no scroll frame for simplicity)
	local yOffset = 35
	local rowHeight = 20

	-- Secondary stats
	for i, statDef in ipairs(STAT_ORDER) do
		local row = CreateStatRow(statsFrame, i)
		row:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 5, -yOffset)
		row:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -5, -yOffset)
		statRows[statDef.key] = row
		yOffset = yOffset + rowHeight
	end

	-- Separator
	yOffset = yOffset + 10

	-- Tertiary stats
	for i, statDef in ipairs(TERTIARY_STATS) do
		local row = CreateStatRow(statsFrame, #STAT_ORDER + i)
		row:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 5, -yOffset)
		row:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -5, -yOffset)
		statRows[statDef.key] = row
		yOffset = yOffset + rowHeight
	end

	-- Movement speed
	yOffset = yOffset + 10
	local speedRow = CreateStatRow(statsFrame, 100)
	speedRow:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 5, -yOffset)
	speedRow:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -5, -yOffset)
	speedRow.name:SetText(STAT_MOVEMENT_SPEED)
	statRows['MovementSpeed'] = speedRow

	return statsFrame
end

---Update all stat displays
function Stats:UpdateStats()
	if not statsFrame or not CharacterFrame:IsVisible() then
		return
	end

	-- Update secondary stats
	for _, statDef in ipairs(STAT_ORDER) do
		local row = statRows[statDef.key]
		if row then
			UpdateStatRow(row, statDef)
		end
	end

	-- Update tertiary stats
	for _, statDef in ipairs(TERTIARY_STATS) do
		local row = statRows[statDef.key]
		if row then
			UpdateStatRow(row, statDef)
		end
	end

	-- Update movement speed
	local speedRow = statRows['MovementSpeed']
	if speedRow then
		local speed = self:GetMovementSpeed()
		speedRow.value:SetText(format('%.0f%%', speed))
		speedRow.value:SetTextColor(1, 1, 1)
		speedRow.dr:Hide()
	end
end

function Stats:OnInitialize()
	-- Nothing to initialize until enabled
end

function Stats:OnEnable()
	LibCS.Logger.info('Stats: OnEnable called')

	if not isInitialized then
		-- Delay creation slightly to ensure CharacterFrameInsetRight exists
		C_Timer.After(0.2, function()
			self:CreateStatsFrame()
			isInitialized = true

			-- Make sure the stats frame is shown
			if statsFrame then
				statsFrame:Show()
				LibCS.Logger.info('Stats: Frame shown after creation')
			end

			-- Initial update if character frame is visible
			if CharacterFrame and CharacterFrame:IsVisible() then
				self:UpdateStats()
			end
		end)
	else
		-- Make sure the stats frame is shown
		if statsFrame then
			statsFrame:Show()
		end
	end

	-- Register events
	self:RegisterEvent('COMBAT_RATING_UPDATE', 'OnStatEvent')
	self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED', 'OnStatEvent')
	self:RegisterEvent('MASTERY_UPDATE', 'OnStatEvent')
	self:RegisterEvent('SPEED_UPDATE', 'OnSpeedEvent')
	self:RegisterEvent('PLAYER_STARTED_MOVING', 'OnSpeedEvent')
	self:RegisterEvent('PLAYER_STOPPED_MOVING', 'OnSpeedEvent')
	self:RegisterEvent('UNIT_AURA', 'OnStatEvent')

	-- Hook character frame show
	if CharacterFrame and not self.frameHooked then
		CharacterFrame:HookScript('OnShow', function()
			if statsFrame then
				statsFrame:Show()
			end
			self:UpdateStats()
		end)
		self.frameHooked = true
	end
end

function Stats:OnDisable()
	self:UnregisterAllEvents()

	if statsFrame then
		statsFrame:Hide()
	end
end

function Stats:OnStatEvent(event, ...)
	-- Throttle updates
	if not self.updatePending then
		self.updatePending = true
		C_Timer.After(0.1, function()
			self.updatePending = false
			self:UpdateStats()
		end)
	end
end

function Stats:OnSpeedEvent(event, ...)
	-- Update movement speed immediately
	local speedRow = statRows['MovementSpeed']
	if speedRow and CharacterFrame:IsVisible() then
		local speed = self:GetMovementSpeed()
		speedRow.value:SetText(format('%.0f%%', speed))
	end
end
