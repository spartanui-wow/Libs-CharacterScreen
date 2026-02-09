---@class LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.RaidProgress : AceModule, AceEvent-3.0
local RaidProgress = LibCS:NewModule('RaidProgress', 'AceEvent-3.0')
LibCS.RaidProgress = RaidProgress

-- Difficulty colors
local DIFFICULTY_COLORS = {
	normal = { 0.12, 1.0, 0.0 }, -- Green
	heroic = { 0.64, 0.21, 0.93 }, -- Purple
	mythic = { 1.0, 0.5, 0.0 }, -- Orange
}

-- Local state
local raidFrame = nil
local raidRows = {}
local isInitialized = false

---@class RaidProgressionData
---@field normal number
---@field heroic number
---@field mythic number
---@field totalBosses number

---Get progression for a specific raid
---@param raidData RaidTierData
---@return RaidProgressionData
function RaidProgress:GetRaidProgression(raidData)
	local progression = {
		normal = 0,
		heroic = 0,
		mythic = 0,
		totalBosses = raidData.numBosses,
	}

	for _, boss in ipairs(raidData.bosses) do
		if LibCS:GetBossKillCount(boss.normal) > 0 then
			progression.normal = progression.normal + 1
		end
		if LibCS:GetBossKillCount(boss.heroic) > 0 then
			progression.heroic = progression.heroic + 1
		end
		if LibCS:GetBossKillCount(boss.mythic) > 0 then
			progression.mythic = progression.mythic + 1
		end
	end

	return progression
end

---Get the highest difficulty with kills
---@param progression RaidProgressionData
---@return string difficulty
---@return number kills
function RaidProgress:GetHighestProgression(progression)
	if progression.mythic > 0 then
		return 'mythic', progression.mythic
	elseif progression.heroic > 0 then
		return 'heroic', progression.heroic
	elseif progression.normal > 0 then
		return 'normal', progression.normal
	end
	return 'normal', 0
end

---Create a raid row frame
---@param parent Frame
---@param index number
---@return Frame
local function CreateRaidRow(parent, index)
	local row = CreateFrame('Frame', nil, parent)
	row:SetSize(parent:GetWidth() - 10, 50)

	-- Background
	row.bg = row:CreateTexture(nil, 'BACKGROUND')
	row.bg:SetAllPoints()
	row.bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)

	-- Raid name
	row.name = row:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	row.name:SetPoint('TOPLEFT', row, 'TOPLEFT', 5, -5)
	row.name:SetJustifyH('LEFT')

	-- Progression bars container
	row.bars = CreateFrame('Frame', nil, row)
	row.bars:SetPoint('TOPLEFT', row.name, 'BOTTOMLEFT', 0, -3)
	row.bars:SetPoint('BOTTOMRIGHT', row, 'BOTTOMRIGHT', -5, 5)

	-- Create difficulty progress displays
	row.difficulties = {}
	local barWidth = (row:GetWidth() - 20) / 3

	for i, diff in ipairs(LibCS.RaidDifficulties) do
		local diffFrame = CreateFrame('Frame', nil, row.bars)
		diffFrame:SetSize(barWidth - 5, 18)
		diffFrame:SetPoint('LEFT', row.bars, 'LEFT', (i - 1) * barWidth, 0)

		-- Background bar
		diffFrame.bgBar = diffFrame:CreateTexture(nil, 'BACKGROUND')
		diffFrame.bgBar:SetAllPoints()
		diffFrame.bgBar:SetColorTexture(0.2, 0.2, 0.2, 0.8)

		-- Progress bar
		diffFrame.progressBar = diffFrame:CreateTexture(nil, 'ARTWORK')
		diffFrame.progressBar:SetPoint('LEFT')
		diffFrame.progressBar:SetHeight(diffFrame:GetHeight())
		diffFrame.progressBar:SetColorTexture(diff.color[1], diff.color[2], diff.color[3], 0.8)

		-- Label
		diffFrame.label = diffFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
		diffFrame.label:SetPoint('CENTER')
		diffFrame.label:SetTextColor(1, 1, 1)

		row.difficulties[diff.key] = diffFrame
	end

	-- Tooltip on hover
	row:EnableMouse(true)
	row:SetScript('OnEnter', function(self)
		if self.tooltipData then
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
			GameTooltip:AddLine(self.tooltipData.name, 1, 1, 1)

			for _, diff in ipairs(LibCS.RaidDifficulties) do
				local kills = self.tooltipData[diff.key] or 0
				local total = self.tooltipData.totalBosses or 0
				local r, g, b = diff.color[1], diff.color[2], diff.color[3]
				GameTooltip:AddDoubleLine(diff.name .. ':', format('%d/%d', kills, total), 1, 1, 1, r, g, b)
			end

			GameTooltip:Show()
		end
	end)

	row:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)

	return row
end

---Update a raid row with current data
---@param row Frame
---@param raidData RaidTierData
local function UpdateRaidRow(row, raidData)
	local progression = RaidProgress:GetRaidProgression(raidData)

	row.name:SetText(raidData.name)

	-- Update difficulty bars
	for key, diffFrame in pairs(row.difficulties) do
		local kills = progression[key] or 0
		local total = progression.totalBosses

		-- Update progress bar width
		local progressWidth = (kills / total) * diffFrame:GetWidth()
		diffFrame.progressBar:SetWidth(math.max(progressWidth, 0.1))

		-- Update label
		diffFrame.label:SetText(format('%d/%d', kills, total))
	end

	-- Store tooltip data
	row.tooltipData = {
		name = raidData.name,
		normal = progression.normal,
		heroic = progression.heroic,
		mythic = progression.mythic,
		totalBosses = progression.totalBosses,
	}

	row:Show()
end

---Create the raid progress display frame
function RaidProgress:CreateRaidFrame()
	if raidFrame then
		return raidFrame
	end

	-- Create main container
	raidFrame = CreateFrame('Frame', 'LibCS_RaidProgressFrame', CharacterFrameInsetRight)
	raidFrame:SetAllPoints()

	-- Header
	local header = raidFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	header:SetPoint('TOP', raidFrame, 'TOP', 0, -5)
	header:SetText('Raid Progress')
	raidFrame.header = header

	-- Scroll frame for raids
	local scrollFrame = CreateFrame('ScrollFrame', nil, raidFrame, 'UIPanelScrollFrameTemplate')
	scrollFrame:SetPoint('TOPLEFT', header, 'BOTTOMLEFT', 0, -10)
	scrollFrame:SetPoint('BOTTOMRIGHT', raidFrame, 'BOTTOMRIGHT', -25, 5)

	local scrollChild = CreateFrame('Frame', nil, scrollFrame)
	scrollChild:SetSize(scrollFrame:GetWidth(), 1)
	scrollFrame:SetScrollChild(scrollChild)
	raidFrame.scrollChild = scrollChild

	return raidFrame
end

---Update the raid progress display
function RaidProgress:UpdateDisplay()
	if not raidFrame or not CharacterFrame:IsVisible() then
		return
	end

	local currentRaids = LibCS:GetCurrentRaids()
	local yOffset = 0
	local rowHeight = 55

	-- Clear existing rows
	for _, row in pairs(raidRows) do
		row:Hide()
	end

	for i, raidData in ipairs(currentRaids) do
		local row = raidRows[raidData.id]
		if not row then
			row = CreateRaidRow(raidFrame.scrollChild, i)
			raidRows[raidData.id] = row
		end

		row:ClearAllPoints()
		row:SetPoint('TOPLEFT', raidFrame.scrollChild, 'TOPLEFT', 0, -yOffset)

		UpdateRaidRow(row, raidData)
		yOffset = yOffset + rowHeight
	end

	-- If no raids found, show message
	if #currentRaids == 0 then
		if not raidFrame.noDataText then
			raidFrame.noDataText = raidFrame.scrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
			raidFrame.noDataText:SetPoint('CENTER', raidFrame.scrollChild, 'CENTER', 0, 0)
			raidFrame.noDataText:SetText('No raid data available')
			raidFrame.noDataText:SetTextColor(0.5, 0.5, 0.5)
		end
		raidFrame.noDataText:Show()
	elseif raidFrame.noDataText then
		raidFrame.noDataText:Hide()
	end

	raidFrame.scrollChild:SetHeight(math.max(yOffset, 100))
end

function RaidProgress:OnInitialize()
	-- Nothing to initialize until enabled
end

function RaidProgress:OnEnable()
	if not isInitialized then
		self:CreateRaidFrame()
		isInitialized = true
	end

	-- Register events
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'OnRaidEvent')
	self:RegisterEvent('ENCOUNTER_END', 'OnRaidEvent')
	self:RegisterEvent('UPDATE_INSTANCE_INFO', 'OnRaidEvent')

	-- Hook character frame show
	if CharacterFrame then
		CharacterFrame:HookScript('OnShow', function()
			self:UpdateDisplay()
		end)
	end

	-- Initial update if character frame is visible
	if CharacterFrame and CharacterFrame:IsVisible() then
		C_Timer.After(0.5, function()
			self:UpdateDisplay()
		end)
	end

	-- Hide by default since Stats module uses the same space
	if raidFrame then
		raidFrame:Hide()
	end
end

function RaidProgress:OnDisable()
	self:UnregisterAllEvents()

	if raidFrame then
		raidFrame:Hide()
	end
end

function RaidProgress:OnRaidEvent(event, ...)
	-- Throttle updates
	if not self.updatePending then
		self.updatePending = true
		C_Timer.After(0.5, function()
			self.updatePending = false
			self:UpdateDisplay()
		end)
	end
end

---Show the raid progress panel
function RaidProgress:Show()
	if raidFrame then
		raidFrame:Show()
		self:UpdateDisplay()
	end

	-- Hide Stats panel if it exists
	if _G['LibCS_StatsFrame'] then
		_G['LibCS_StatsFrame']:Hide()
	end

	-- Hide M+ panel if it exists
	if _G['LibCS_MythicPlusFrame'] then
		_G['LibCS_MythicPlusFrame']:Hide()
	end
end

---Hide the raid progress panel
function RaidProgress:Hide()
	if raidFrame then
		raidFrame:Hide()
	end
end
