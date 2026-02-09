---@class LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

---@class LibCS.MythicPlus : AceModule, AceEvent-3.0
local MythicPlus = LibCS:NewModule('MythicPlus', 'AceEvent-3.0')
LibCS.MythicPlus = MythicPlus

-- Rating color brackets (based on Blizzard's M+ rating colors)
local RATING_COLORS = {
	{ rating = 0, color = { 0.62, 0.62, 0.62 } }, -- Gray
	{ rating = 750, color = { 0.12, 1.0, 0.0 } }, -- Green
	{ rating = 1500, color = { 0.0, 0.44, 0.87 } }, -- Blue
	{ rating = 1750, color = { 0.64, 0.21, 0.93 } }, -- Purple
	{ rating = 2000, color = { 1.0, 0.5, 0.0 } }, -- Orange
	{ rating = 2500, color = { 0.9, 0.8, 0.5 } }, -- Keystone Hero (tan/gold)
}

-- Local state
local mplusFrame = nil
local dungeonRows = {}
local isInitialized = false

---Get color for a given M+ rating
---@param rating number
---@return number r
---@return number g
---@return number b
local function GetRatingColor(rating)
	local selectedColor = RATING_COLORS[1].color

	for _, colorDef in ipairs(RATING_COLORS) do
		if rating >= colorDef.rating then
			selectedColor = colorDef.color
		end
	end

	return selectedColor[1], selectedColor[2], selectedColor[3]
end

---Calculate star rating based on run time vs timer
---@param runTime number Time in seconds
---@param dungeonTimer number Par time in seconds
---@return number stars (0-3)
local function GetStarRating(runTime, dungeonTimer)
	if runTime == 0 or dungeonTimer == 0 then
		return 0
	end

	if runTime < (dungeonTimer * 0.6) then
		return 3 -- +3
	elseif runTime < (dungeonTimer * 0.8) then
		return 2 -- +2
	elseif runTime <= dungeonTimer then
		return 1 -- +1
	end

	return 0 -- Depleted
end

---Get star display string
---@param stars number
---@return string
local function GetStarString(stars)
	if stars >= 3 then
		return '|cff00ff00+++|r'
	elseif stars == 2 then
		return '|cff88ff00++|r'
	elseif stars == 1 then
		return '|cffffff00+|r'
	else
		return '|cff888888-|r'
	end
end

---Get the player's current M+ rating summary
---@return table|nil
function MythicPlus:GetRatingSummary()
	if not C_PlayerInfo or not C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
		return nil
	end

	return C_PlayerInfo.GetPlayerMythicPlusRatingSummary('player')
end

---Get current season's run history
---@return table
function MythicPlus:GetRunHistory()
	if not C_MythicPlus or not C_MythicPlus.GetRunHistory then
		return {}
	end

	return C_MythicPlus.GetRunHistory(true, false) or {}
end

---Get current dungeon map table
---@return table
function MythicPlus:GetDungeonMaps()
	if not C_ChallengeMode or not C_ChallengeMode.GetMapTable then
		return {}
	end

	return C_ChallengeMode.GetMapTable() or {}
end

---Get run count by key level thresholds
---@return table
function MythicPlus:GetRunProgression()
	local runHistory = self:GetRunHistory()
	local progression = {
		['20+'] = 0,
		['15+'] = 0,
		['10+'] = 0,
		['7+'] = 0,
		['5+'] = 0,
		['2+'] = 0,
		total = 0,
	}

	for _, run in ipairs(runHistory) do
		if run.completed then
			progression.total = progression.total + 1
			if run.level >= 20 then
				progression['20+'] = progression['20+'] + 1
			elseif run.level >= 15 then
				progression['15+'] = progression['15+'] + 1
			elseif run.level >= 10 then
				progression['10+'] = progression['10+'] + 1
			elseif run.level >= 7 then
				progression['7+'] = progression['7+'] + 1
			elseif run.level >= 5 then
				progression['5+'] = progression['5+'] + 1
			elseif run.level >= 2 then
				progression['2+'] = progression['2+'] + 1
			end
		end
	end

	return progression
end

---Get weekly vault progress
---@return table
function MythicPlus:GetVaultProgress()
	if not C_WeeklyRewards or not C_WeeklyRewards.GetActivities then
		return {}
	end

	local activities = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Activities)
	local vaultSlots = {}

	for _, activity in ipairs(activities) do
		if activity.type == Enum.WeeklyRewardChestThresholdType.Activities then
			table.insert(vaultSlots, {
				threshold = activity.threshold,
				progress = activity.progress,
				level = activity.level,
				unlocked = activity.progress >= activity.threshold,
			})
		end
	end

	return vaultSlots
end

---Get current week's affixes
---@return table
function MythicPlus:GetCurrentAffixes()
	if not C_MythicPlus or not C_MythicPlus.GetCurrentAffixes then
		return {}
	end

	return C_MythicPlus.GetCurrentAffixes() or {}
end

---Get best run for a specific dungeon
---@param mapID number
---@return table|nil
function MythicPlus:GetBestRunForDungeon(mapID)
	if not C_MythicPlus or not C_MythicPlus.GetSeasonBestAffixScoreInfoForMap then
		return nil
	end

	local affixScores, bestOverall = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)
	return bestOverall
end

---Create a dungeon row frame
---@param parent Frame
---@param index number
---@return Frame
local function CreateDungeonRow(parent, index)
	local row = CreateFrame('Frame', nil, parent)
	row:SetSize(parent:GetWidth() - 10, 24)

	-- Background
	row.bg = row:CreateTexture(nil, 'BACKGROUND')
	row.bg:SetAllPoints()
	row.bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)

	-- Dungeon icon
	row.icon = row:CreateTexture(nil, 'ARTWORK')
	row.icon:SetSize(20, 20)
	row.icon:SetPoint('LEFT', row, 'LEFT', 2, 0)

	-- Dungeon name
	row.name = row:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
	row.name:SetPoint('LEFT', row.icon, 'RIGHT', 5, 0)
	row.name:SetWidth(80)
	row.name:SetJustifyH('LEFT')
	row.name:SetWordWrap(false)

	-- Best key level
	row.level = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
	row.level:SetPoint('LEFT', row.name, 'RIGHT', 5, 0)
	row.level:SetWidth(30)
	row.level:SetJustifyH('CENTER')

	-- Score
	row.score = row:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
	row.score:SetPoint('RIGHT', row, 'RIGHT', -5, 0)
	row.score:SetJustifyH('RIGHT')

	return row
end

---Create the M+ display frame
function MythicPlus:CreateMPlusFrame()
	if mplusFrame then
		return mplusFrame
	end

	-- Create main container (positioned in right panel area)
	mplusFrame = CreateFrame('Frame', 'LibCS_MythicPlusFrame', CharacterFrameInsetRight)
	mplusFrame:SetAllPoints()

	-- Header with rating
	local header = mplusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	header:SetPoint('TOP', mplusFrame, 'TOP', 0, -5)
	header:SetText('Mythic+ Rating')
	mplusFrame.header = header

	-- Rating display
	local ratingText = mplusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
	ratingText:SetPoint('TOP', header, 'BOTTOM', 0, -5)
	mplusFrame.ratingText = ratingText

	-- Vault progress header
	local vaultHeader = mplusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
	vaultHeader:SetPoint('TOP', ratingText, 'BOTTOM', 0, -10)
	vaultHeader:SetText('|cff88aacc Weekly Vault|r')
	mplusFrame.vaultHeader = vaultHeader

	-- Vault slots container
	local vaultContainer = CreateFrame('Frame', nil, mplusFrame)
	vaultContainer:SetSize(mplusFrame:GetWidth() - 20, 24)
	vaultContainer:SetPoint('TOP', vaultHeader, 'BOTTOM', 0, -5)
	mplusFrame.vaultContainer = vaultContainer

	-- Create 3 vault slot indicators
	mplusFrame.vaultSlots = {}
	for i = 1, 3 do
		local slot = CreateFrame('Frame', nil, vaultContainer)
		slot:SetSize(50, 20)
		slot:SetPoint('LEFT', vaultContainer, 'LEFT', (i - 1) * 55, 0)

		slot.bg = slot:CreateTexture(nil, 'BACKGROUND')
		slot.bg:SetAllPoints()
		slot.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

		slot.text = slot:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
		slot.text:SetPoint('CENTER')

		mplusFrame.vaultSlots[i] = slot
	end

	-- Affixes header
	local affixHeader = mplusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
	affixHeader:SetPoint('TOP', vaultContainer, 'BOTTOM', 0, -10)
	affixHeader:SetText('|cff88aacc Current Affixes|r')
	mplusFrame.affixHeader = affixHeader

	-- Affix container
	local affixContainer = CreateFrame('Frame', nil, mplusFrame)
	affixContainer:SetSize(mplusFrame:GetWidth() - 20, 24)
	affixContainer:SetPoint('TOP', affixHeader, 'BOTTOM', 0, -5)
	mplusFrame.affixContainer = affixContainer

	mplusFrame.affixIcons = {}

	-- Dungeons header
	local dungeonHeader = mplusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
	dungeonHeader:SetPoint('TOP', affixContainer, 'BOTTOM', 0, -10)
	dungeonHeader:SetText('|cff88aacc Dungeon Progress|r')
	mplusFrame.dungeonHeader = dungeonHeader

	-- Scroll frame for dungeons
	local scrollFrame = CreateFrame('ScrollFrame', nil, mplusFrame, 'UIPanelScrollFrameTemplate')
	scrollFrame:SetPoint('TOPLEFT', dungeonHeader, 'BOTTOMLEFT', 0, -5)
	scrollFrame:SetPoint('BOTTOMRIGHT', mplusFrame, 'BOTTOMRIGHT', -25, 5)

	local scrollChild = CreateFrame('Frame', nil, scrollFrame)
	scrollChild:SetSize(scrollFrame:GetWidth(), 1)
	scrollFrame:SetScrollChild(scrollChild)
	mplusFrame.scrollChild = scrollChild

	return mplusFrame
end

---Update the M+ display
function MythicPlus:UpdateDisplay()
	if not mplusFrame or not CharacterFrame:IsVisible() then
		return
	end

	-- Update rating
	local summary = self:GetRatingSummary()
	if summary then
		local rating = summary.currentSeasonScore or 0
		local r, g, b = GetRatingColor(rating)
		mplusFrame.ratingText:SetText(format('%.1f', rating))
		mplusFrame.ratingText:SetTextColor(r, g, b)
	else
		mplusFrame.ratingText:SetText('---')
		mplusFrame.ratingText:SetTextColor(0.5, 0.5, 0.5)
	end

	-- Update vault slots
	local vaultProgress = self:GetVaultProgress()
	for i, slot in ipairs(mplusFrame.vaultSlots) do
		local vaultData = vaultProgress[i]
		if vaultData then
			local progress = vaultData.progress
			local threshold = vaultData.threshold
			if vaultData.unlocked then
				slot.bg:SetColorTexture(0.0, 0.5, 0.0, 0.8)
				slot.text:SetText(format('+%d', vaultData.level or 0))
			else
				slot.bg:SetColorTexture(0.3, 0.3, 0.0, 0.8)
				slot.text:SetText(format('%d/%d', progress, threshold))
			end
		else
			slot.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
			slot.text:SetText('?/?')
		end
	end

	-- Update affixes
	local affixes = self:GetCurrentAffixes()
	-- Clear existing affix icons
	for _, icon in ipairs(mplusFrame.affixIcons) do
		icon:Hide()
	end

	for i, affixInfo in ipairs(affixes) do
		local icon = mplusFrame.affixIcons[i]
		if not icon then
			icon = mplusFrame.affixContainer:CreateTexture(nil, 'ARTWORK')
			icon:SetSize(20, 20)
			mplusFrame.affixIcons[i] = icon
		end

		icon:ClearAllPoints()
		icon:SetPoint('LEFT', mplusFrame.affixContainer, 'LEFT', (i - 1) * 25, 0)

		local affixID = affixInfo.id
		local name, desc, fileDataID = C_ChallengeMode.GetAffixInfo(affixID)
		if fileDataID then
			icon:SetTexture(fileDataID)
		end
		icon:Show()
	end

	-- Update dungeons
	local dungeonMaps = self:GetDungeonMaps()
	local yOffset = 0
	local rowHeight = 26

	-- Clear existing rows
	for _, row in pairs(dungeonRows) do
		row:Hide()
	end

	for i, mapID in ipairs(dungeonMaps) do
		local row = dungeonRows[mapID]
		if not row then
			row = CreateDungeonRow(mplusFrame.scrollChild, i)
			dungeonRows[mapID] = row
		end

		row:ClearAllPoints()
		row:SetPoint('TOPLEFT', mplusFrame.scrollChild, 'TOPLEFT', 0, -yOffset)

		-- Get dungeon info
		local name, _, timeLimit, texture = C_ChallengeMode.GetMapUIInfo(mapID)
		if name then
			row.name:SetText(name)
			if texture then
				row.icon:SetTexture(texture)
			end

			-- Get best run info
			local bestRun = self:GetBestRunForDungeon(mapID)
			if bestRun then
				row.level:SetText(format('+%d', bestRun.level or 0))
				row.score:SetText(format('%.1f', bestRun.overallScore or 0))

				local r, g, b = GetRatingColor(bestRun.overallScore or 0)
				row.score:SetTextColor(r, g, b)
			else
				row.level:SetText('-')
				row.score:SetText('-')
				row.score:SetTextColor(0.5, 0.5, 0.5)
			end

			row:Show()
			yOffset = yOffset + rowHeight
		end
	end

	mplusFrame.scrollChild:SetHeight(math.max(yOffset, 100))
end

function MythicPlus:OnInitialize()
	-- Nothing to initialize until enabled
end

function MythicPlus:OnEnable()
	if not isInitialized then
		self:CreateMPlusFrame()
		isInitialized = true
	end

	-- Register events
	self:RegisterEvent('CHALLENGE_MODE_COMPLETED', 'OnMythicPlusEvent')
	self:RegisterEvent('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE', 'OnMythicPlusEvent')
	self:RegisterEvent('WEEKLY_REWARDS_UPDATE', 'OnMythicPlusEvent')
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'OnMythicPlusEvent')

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
	if mplusFrame then
		mplusFrame:Hide()
	end
end

function MythicPlus:OnDisable()
	self:UnregisterAllEvents()

	if mplusFrame then
		mplusFrame:Hide()
	end
end

function MythicPlus:OnMythicPlusEvent(event, ...)
	-- Throttle updates
	if not self.updatePending then
		self.updatePending = true
		C_Timer.After(0.2, function()
			self.updatePending = false
			self:UpdateDisplay()
		end)
	end
end

---Show the M+ panel (hide Stats panel)
function MythicPlus:Show()
	if mplusFrame then
		mplusFrame:Show()
		self:UpdateDisplay()
	end

	-- Hide Stats panel if it exists
	local statsModule = LibCS.Core and LibCS.Core:GetModule('Stats')
	if statsModule and LibCS.Stats and _G['LibCS_StatsFrame'] then
		_G['LibCS_StatsFrame']:Hide()
	end
end

---Hide the M+ panel
function MythicPlus:Hide()
	if mplusFrame then
		mplusFrame:Hide()
	end
end
