---@class LibCS
local LibCS = LibStub('AceAddon-3.0'):GetAddon('LibCS')

-- Raid data for progression tracking
-- Statistic IDs can be found via /dump GetStatistic(id) or from wowhead
-- These need to be updated each tier

---@class RaidBossData
---@field name string
---@field normal number Statistic ID for normal kills
---@field heroic number Statistic ID for heroic kills
---@field mythic number Statistic ID for mythic kills

---@class RaidTierData
---@field id number Instance ID
---@field name string
---@field shortName string
---@field numBosses number
---@field bosses RaidBossData[]
---@field minTOC number Minimum interface version
---@field maxTOC number Maximum interface version

-- Current expansion raids (The War Within)
-- Note: Statistic IDs need to be verified in-game for accuracy
LibCS.RaidData = {
	-- Liberation of Undermine (11.1)
	{
		id = 2769,
		name = 'Liberation of Undermine',
		shortName = 'LoU',
		numBosses = 8,
		minTOC = 110100,
		maxTOC = 999999,
		bosses = {
			-- These statistic IDs are placeholders and need verification
			{ name = 'Vexie and the Geargrinders', normal = 0, heroic = 0, mythic = 0 },
			{ name = 'Cauldron of Carnage', normal = 0, heroic = 0, mythic = 0 },
			{ name = 'Rik Reverb', normal = 0, heroic = 0, mythic = 0 },
			{ name = 'Stix Bunkjunker', normal = 0, heroic = 0, mythic = 0 },
			{ name = 'Sprocketmonger Lockenstock', normal = 0, heroic = 0, mythic = 0 },
			{ name = 'The One-Armed Bandit', normal = 0, heroic = 0, mythic = 0 },
			{ name = "Mug'Zee, Heads of Security", normal = 0, heroic = 0, mythic = 0 },
			{ name = 'Gallywix', normal = 0, heroic = 0, mythic = 0 },
		},
	},
	-- Nerub-ar Palace (11.0)
	{
		id = 2657,
		name = 'Nerub-ar Palace',
		shortName = 'NaP',
		numBosses = 8,
		minTOC = 110000,
		maxTOC = 999999,
		bosses = {
			-- These statistic IDs are placeholders and need verification
			{ name = 'Ulgrax the Devourer', normal = 0, heroic = 0, mythic = 0 },
			{ name = 'The Bloodbound Horror', normal = 0, heroic = 0, mythic = 0 },
			{ name = 'Sikran, Captain of the Sureki', normal = 0, heroic = 0, mythic = 0 },
			{ name = "Rasha'nan", normal = 0, heroic = 0, mythic = 0 },
			{ name = "Broodtwister Ovi'nax", normal = 0, heroic = 0, mythic = 0 },
			{ name = "Nexus-Princess Ky'veza", normal = 0, heroic = 0, mythic = 0 },
			{ name = 'The Silken Court', normal = 0, heroic = 0, mythic = 0 },
			{ name = 'Queen Ansurek', normal = 0, heroic = 0, mythic = 0 },
		},
	},
}

-- Difficulty constants
LibCS.RaidDifficulties = {
	{ key = 'normal', name = 'Normal', color = { 0.12, 1.0, 0.0 } }, -- Green
	{ key = 'heroic', name = 'Heroic', color = { 0.64, 0.21, 0.93 } }, -- Purple
	{ key = 'mythic', name = 'Mythic', color = { 1.0, 0.5, 0.0 } }, -- Orange
}

---Get raid data by instance ID
---@param instanceID number
---@return RaidTierData|nil
function LibCS:GetRaidDataByID(instanceID)
	for _, raid in ipairs(LibCS.RaidData) do
		if raid.id == instanceID then
			return raid
		end
	end
	return nil
end

---Get all current tier raids
---@return RaidTierData[]
function LibCS:GetCurrentRaids()
	local currentTOC = select(4, GetBuildInfo())
	local raids = {}

	for _, raid in ipairs(LibCS.RaidData) do
		if currentTOC >= raid.minTOC and currentTOC <= raid.maxTOC then
			table.insert(raids, raid)
		end
	end

	return raids
end

---Get kill count for a boss statistic ID
---@param statID number
---@return number
function LibCS:GetBossKillCount(statID)
	if statID == 0 then
		return 0
	end

	local count = GetStatistic(statID)
	if count == nil or count == '--' then
		return 0
	end

	return tonumber(count) or 0
end
