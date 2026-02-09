-- Framework.lua - Initial addon setup and library management
-- This file creates the LibCS addon and sets up the foundation

local LibCS = LibStub('AceAddon-3.0'):NewAddon('LibCS', 'AceConsole-3.0', 'AceEvent-3.0') ---@class LibCS
LibCS:SetDefaultModuleLibraries('AceEvent-3.0', 'AceTimer-3.0')
_G.LibCS = LibCS

-- Version information
LibCS.Version = C_AddOns.GetAddOnMetadata('Libs-CharacterScreen', 'Version') or '0.0.0'
LibCS.BuildNum = C_AddOns.GetAddOnMetadata('Libs-CharacterScreen', 'X-Build') or 0

-- Library management
LibCS.Lib = {}

---@param name string
---@param library string|table
---@param silent? boolean
LibCS.AddLib = function(name, library, silent)
	if not name then
		return
	end

	if type(library) == 'table' then
		LibCS.Lib[name] = library
	else
		LibCS.Lib[name] = LibStub(library, silent)
	end
end

-- Initialize core libraries
LibCS.AddLib('AceDB', 'AceDB-3.0')
LibCS.AddLib('AceConfig', 'AceConfig-3.0')
LibCS.AddLib('AceConfigDialog', 'AceConfigDialog-3.0')
LibCS.AddLib('AceSerializer', 'AceSerializer-3.0')

-- Setup Logger - use LibAT if available, otherwise create a fallback
if LibAT and LibAT.Logger then
	LibCS.Logger = LibAT.Logger.RegisterAddon('LibCS')
else
	-- Fallback logger that prints to console (enable for debugging)
	local DEBUG_ENABLED = true -- Set to false to silence debug output
	local function debugPrint(level, msg)
		if DEBUG_ENABLED then
			print('|cff00ff00LibCS|r [' .. level .. ']: ' .. tostring(msg))
		end
	end
	LibCS.Logger = {
		debug = function(msg)
			debugPrint('DEBUG', msg)
		end,
		info = function(msg)
			debugPrint('INFO', msg)
		end,
		warning = function(msg)
			debugPrint('WARN', msg)
		end,
		error = function(msg)
			debugPrint('ERROR', msg)
		end,
		critical = function(msg)
			debugPrint('CRIT', msg)
		end,
	}
end

-- Specialization to background visual mapping
---@type table<number, string>
local SpecializationVisuals = {
	[0250] = 'deathknight-blood',
	[0251] = 'deathknight-frost',
	[0252] = 'deathknight-unholy',
	[0577] = 'demonhunter-havoc',
	[0581] = 'demonhunter-vengeance',
	[0102] = 'druid-balance',
	[0103] = 'druid-feral',
	[0104] = 'druid-guardian',
	[0105] = 'druid-restoration',
	[1467] = 'evoker-devastation',
	[1468] = 'evoker-preservation',
	[1473] = 'evoker-augmentation',
	[0253] = 'hunter-beastmastery',
	[0254] = 'hunter-marksmanship',
	[0255] = 'hunter-survival',
	[0062] = 'mage-arcane',
	[0063] = 'mage-fire',
	[0064] = 'mage-frost',
	[0268] = 'monk-brewmaster',
	[0269] = 'monk-windwalker',
	[0270] = 'monk-mistweaver',
	[0065] = 'paladin-holy',
	[0066] = 'paladin-protection',
	[0070] = 'paladin-retribution',
	[0256] = 'priest-discipline',
	[0257] = 'priest-holy',
	[0258] = 'priest-shadow',
	[0259] = 'rogue-assassination',
	[0260] = 'rogue-outlaw',
	[0261] = 'rogue-subtlety',
	[0262] = 'shaman-elemental',
	[0263] = 'shaman-enhancement',
	[0264] = 'shaman-restoration',
	[0265] = 'warlock-affliction',
	[0266] = 'warlock-demonology',
	[0267] = 'warlock-destruction',
	[0071] = 'warrior-arms',
	[0072] = 'warrior-fury',
	[0073] = 'warrior-protection',
}

-- Core utility functions
---@param specID? number
---@return string?, boolean?
function LibCS:GetDynamicBackground(specID)
	if GetSpecialization then
		local currentSpecialization = GetSpecialization()
		if currentSpecialization then
			specID = specID or GetSpecializationInfo(currentSpecialization)
		end
	end

	local visual = SpecializationVisuals[specID]
	local atlas = visual and ('talents-background-%s'):format(visual)
	if atlas and C_Texture.GetAtlasInfo(atlas) then
		return atlas, true
	end
	local classBG = 'Artifacts-' .. UnitClass('player') .. '-BG'
	if C_Texture.GetAtlasInfo(classBG) then
		return classBG, true
	end
end

-- Main LibCS event handlers
function LibCS:OnInitialize()
	self:RegisterChatCommand('libcs', 'ChatCommand')
end

function LibCS:OnEnable()
	self:RegisterEvent('UNIT_LEVEL')
	self:RegisterEvent('UNIT_NAME_UPDATE')
	self:RegisterEvent('ACTIVE_PLAYER_SPECIALIZATION_CHANGED')
	self:RegisterEvent('UNIT_MODEL_CHANGED')
end

---@param input string
function LibCS:ChatCommand(input)
	if CharacterFrame:IsShown() then
		CharacterFrame:Hide()
	else
		CharacterFrame:Show()
	end
end

---@param event string
---@param unit string
function LibCS:UNIT_LEVEL(event, unit)
	if unit == 'player' and self.FrameManager then
		self.FrameManager:UpdateCharacterInfo()
	end
end

---@param event string
---@param unit string
function LibCS:UNIT_NAME_UPDATE(event, unit)
	if unit == 'player' then
		local portraitModule = LibCS.Core and LibCS.Core:GetModule('Portrait')
		if portraitModule and portraitModule.UpdateCharacterInfo then
			portraitModule:UpdateCharacterInfo()
		end
	end
end

function LibCS:ACTIVE_PLAYER_SPECIALIZATION_CHANGED()
	if self.FrameManager and LibCS.CharacterFrameBgTex then
		self.FrameManager:ApplyBackgroundVisual(LibCS.CharacterFrameBgTex)
	end

	-- Also update character info for the new spec
	local portraitModule = LibCS.Core and LibCS.Core:GetModule('Portrait')
	if portraitModule and portraitModule.UpdateCharacterInfo then
		portraitModule:UpdateCharacterInfo()
	end
end

---@param event string
---@param unit string
function LibCS:UNIT_MODEL_CHANGED(event, unit)
	if unit == 'player' then
		local portraitModule = self.Core and self.Core:GetModule('Portrait')
		if portraitModule and portraitModule.RefreshModel then
			portraitModule:RefreshModel()
		end
	end
end
