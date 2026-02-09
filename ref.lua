---@diagnostic disable
function PaperDollFrame_OnEvent(self, event, ...)
	local unit = ...
	if event == 'PLAYER_ENTERING_WORLD' or event == 'GX_RESTARTED' then
		return
	elseif event == 'UNIT_MODEL_CHANGED' and unit == 'player' then
		PaperDollFrame_SetPlayer()
		return
	elseif event == 'KNOWN_TITLES_UPDATE' or (event == 'UNIT_NAME_UPDATE' and unit == 'player') then
		if PaperDollFrame.TitleManagerPane:IsShown() then
			PaperDollTitlesPane_Update()
		end
	end

	if not self:IsVisible() then
		return
	end

	if unit == 'player' then
		if event == 'UNIT_LEVEL' then
			PaperDollFrame_SetLevel()
		elseif
			event == 'UNIT_DAMAGE'
			or event == 'UNIT_ATTACK_SPEED'
			or event == 'UNIT_RANGEDDAMAGE'
			or event == 'UNIT_ATTACK'
			or event == 'UNIT_STATS'
			or event == 'UNIT_RANGED_ATTACK_POWER'
			or event == 'UNIT_SPELL_HASTE'
			or event == 'UNIT_MAXHEALTH'
			or event == 'UNIT_AURA'
			or event == 'UNIT_RESISTANCES'
		then
			self:SetScript('OnUpdate', PaperDollFrame_QueuedUpdate)
		end
	end

	if
		event == 'COMBAT_RATING_UPDATE'
		or event == 'MASTERY_UPDATE'
		or event == 'SPEED_UPDATE'
		or event == 'LIFESTEAL_UPDATE'
		or event == 'AVOIDANCE_UPDATE'
		or event == 'BAG_UPDATE'
		or event == 'PLAYER_EQUIPMENT_CHANGED'
		or event == 'PLAYER_AVG_ITEM_LEVEL_UPDATE'
		or event == 'PLAYER_DAMAGE_DONE_MODS'
		or event == 'PLAYER_TARGET_CHANGED'
	then
		self:SetScript('OnUpdate', PaperDollFrame_QueuedUpdate)
	elseif event == 'PLAYER_TALENT_UPDATE' then
		PaperDollFrame_SetLevel()
		self:SetScript('OnUpdate', PaperDollFrame_QueuedUpdate)
	elseif event == 'ACTIVE_TALENT_GROUP_CHANGED' then
		PaperDollFrame_UpdateStats()
	elseif event == 'SPELL_POWER_CHANGED' then
		self:SetScript('OnUpdate', PaperDollFrame_QueuedUpdate)
	elseif event == 'TRIAL_STATUS_UPDATE' then
		PaperDollFrame_SetLevel()
	end
end

function PrepWindow()
	---@class SUI.ICS.ItemButtonFrame : Frame
	---@field ilvlText fontstring
	---@field location number
	--Load supporting addons
	C_AddOns.LoadAddOn('Blizzard_MajorFactions')
	C_AddOns.LoadAddOn('Blizzard_TokenUI')
	WeeklyRewards_LoadUI()
	-- Initialize weakaura variables

	local config = {
		['showrenown'] = true,
		['textoutline'] = '',
		['sheetscale'] = 1,
		['ccsbgcolor'] = { 0.1, 0.1, 0.1, 1 },
		['hpad'] = 0,
		['vpad'] = 0,
	}

	local c = config
	local scaling = c.sheetscale or 1
	local region = _G['CharacterFrame']
	local Width = region:GetWidth()
	local Height = region:GetHeight()
	local modelregion = _G['CharacterModelBackground']
	local charsheet = WeakAuras.GetData('Character Sheet')
	-- local mplussheet = WeakAuras.GetData('CCS MythicPlus Score')
	local ModelAspect = 1.385
	local _G = _G
	local textoptions = c.textoutline
	local LSM = LibStub('LibSharedMedia-3.0')
	local Font = LSM:Fetch('font', 'Arial Narrow')
	-- initialize button spacing.
	local spacing = 3
	local xDistance = Width + spacing
	local xOffset = 250 + charsheet.config.hpad * 0.80 + xDistance * 0 -- only for single button setups
	local xOffset2 = 280 + charsheet.config.hpad * 0.95 + xDistance * 0 -- only for single button setups
	local yOffset = 6
	local btn = _G['CCS_clk_Btn'] or CreateFrame('Button', 'CCS_clk_Btn', region, 'UIPanelButtonTemplate')
	local btn2 = _G['CCS_clk_Btn2'] or CreateFrame('Button', 'CCS_clk_Btn2', region, 'UIPanelButtonTemplate')
	local textstring = MOUNT_JOURNAL_PLAYER
	local texture = 'Interface\\Calendar\\MeetingIcon.blp'

	local GEM_NONE = 0
	local GEM_META = 1
	local GEM_HYDRAULIC = 5
	local GEM_COGWHEEL = 6
	local GEM_PRISMATIC = 7
	local GEM_PUNCHCARDRED = 19
	local GEM_PUNCHCARDYELLOW = 20
	local GEM_PUNCHCARDBLUE = 21
	local GEM_DOMINATION = 22

	local GemInfo = {
		[136256] = { text = EMPTY_SOCKET_BLUE, gtype = GEM_PRISMATIC },
		[407324] = { text = EMPTY_SOCKET_COGWHEEL, gtype = GEM_COGWHEEL },
		[4624650] = { text = EMPTY_SOCKET_TINKER, gtype = GEM_COGWHEEL },
		[4624651] = { text = EMPTY_SOCKET_TINKER, gtype = GEM_COGWHEEL },
		[4624652] = { text = EMPTY_SOCKET_TINKER, gtype = GEM_COGWHEEL },
		[4624653] = { text = EMPTY_SOCKET_TINKER, gtype = GEM_COGWHEEL },
		[4624654] = { text = EMPTY_SOCKET_TINKER, gtype = GEM_COGWHEEL },
		[4624655] = { text = EMPTY_SOCKET_TINKER, gtype = GEM_COGWHEEL },
		[4095404] = { text = EMPTY_SOCKET_DOMINATION, gtype = GEM_DOMINATION },
		[407325] = { text = EMPTY_SOCKET_HYDRAULIC, gtype = GEM_HYDRAULIC },
		[136257] = { text = EMPTY_SOCKET_META, gtype = GEM_META },
		[458977] = { text = EMPTY_SOCKET_PRISMATIC, gtype = GEM_PRISMATIC },
		[2958629] = { text = EMPTY_SOCKET_PUNCHCARDBLUE, gtype = GEM_PUNCHCARDBLUE },
		[2958630] = { text = EMPTY_SOCKET_TINKER, gtype = GEM_PUNCHCARDRED },
		[2958631] = { text = EMPTY_SOCKET_PUNCHCARDYELLOW, gtype = GEM_PUNCHCARDYELLOW },
		[136258] = { text = EMPTY_SOCKET_RED, gtype = GEM_PRISMATIC },
		[136259] = { text = EMPTY_SOCKET_YELLOW, gtype = GEM_PRISMATIC },
	}

	-- local hookfix = function()
	-- 	if MajorFactionRenownFrame:IsVisible() then
	-- 		local fid = MajorFactionRenownFrame:GetCurrentFactionID()
	-- 		EventRegistry:TriggerEvent('MajorFactionRenownMixin.MajorFactionRenownRequest', fid)
	-- 		MajorFactionRenownFrame:Show()
	-- 		MajorFactionRenownFrame:ClearAllPoints()
	-- 		MajorFactionRenownFrame:SetPoint('CENTER', ccs_sf, 'CENTER', 0, 0)
	-- 		MajorFactionRenownFrame:SetFrameStrata('MEDIUM')
	-- 		MajorFactionRenownFrame:SetScale(1.2)
	-- 		MajorFactionRenownFrame.Background:SetAlpha(0.2)
	-- 		MajorFactionRenownFrame:Hide()
	-- 		if _G['CCSf'] then _G['CCSf']:Hide() end
	-- 		if _G['ccs_sf'] then _G['ccs_sf']:Hide() end

	-- 		if not InCombatLockdown() then
	-- 			if ccsm_sf and mplussheet and mplussheet.config and (mplussheet.config.showm_sp == true) and (UnitLevel('player') == GetMaxLevelForLatestExpansion()) then
	-- 				ccsm_sf:Show()
	-- 			elseif ccsm_sf then
	-- 				ccsm_sf:Hide()
	-- 			end
	-- 		end

	-- 		MoveModelLeft()
	-- 		_G['ccs_sf_btn3']:Hide()
	-- 		_G['ccs_sf_btn4']:Hide()
	-- 		_G['ccs_sf_btn5']:Hide()
	-- 		_G['ccs_sf_btn6']:Hide()
	-- 		_G['ccs_sf_btn7']:Hide()
	-- 		_G['ccs_sf_btn8']:Hide()
	-- 	elseif not InCombatLockdown() then
	-- 		if ccsm_sf and mplussheet and mplussheet.config and (mplussheet.config.showm_sp == true) and (UnitLevel('player') == GetMaxLevelForLatestExpansion()) then
	-- 			ccsm_sf:Show()
	-- 		elseif ccsm_sf then
	-- 			ccsm_sf:Hide()
	-- 		end
	-- 	end
	-- end

	module.sf_bafc = function(btn) -- Button and Frame Changes
		local btn3, btn4, btn5, btn6, btn7, btn8 = 0, 0, 0, 0, 0, 0, 0, 0
		local majfac = 0
		if not c.showrenown then
			return
		end

		if btn == 3 then
			btn3 = 1
			majfac = 2564
		elseif btn == 4 then
			btn4 = 1
			majfac = 2507
		elseif btn == 5 then
			btn5 = 1
			majfac = 2511
		elseif btn == 6 then
			btn6 = 1
			majfac = 2503
		elseif btn == 7 then
			btn7 = 1
			majfac = 2510
		elseif btn == 8 then
			btn8 = 1
			majfac = 2574
		end
		CCSf:Show()
		ccs_sf:Show()
		if _G['ccsm_sf'] then
			_G['ccsm_sf']:Hide()
		end
		if btn >= 3 and btn <= 8 then -- Show Major Faction
			CCSf:Show()
			ccs_sf:Show()
			if _G['ccsm_sf'] then
				_G['ccsm_sf']:Hide()
			end
			if WeeklyRewardsFrame:IsVisible() then
				WeeklyRewardsFrame:Hide()
			end
			if MajorFactionRenownFrame:IsVisible() then
				MajorFactionRenownFrame:Hide()
			end
			EventRegistry:TriggerEvent('MajorFactionRenownMixin.MajorFactionRenownRequest', majfac)
			MajorFactionRenownFrame:ClearAllPoints()
			MajorFactionRenownFrame:SetPoint('CENTER', ccs_sf, 'CENTER', 0, 0)
			MajorFactionRenownFrame:SetFrameStrata('MEDIUM')
			MajorFactionRenownFrame:SetScale(1.2)
			MajorFactionRenownFrame.Background:SetAlpha(0.2)
			MajorFactionRenownFrame.CloseButton:Hide()
			MajorFactionRenownFrame:Show()
		end

		PlaySound(62540, 'master', true)
		_G['ccs_sf_btn3_bg']:SetAlpha(0.3 + btn3 * 0.7)
		_G['ccs_sf_btn4_bg']:SetAlpha(0.3 + btn4 * 0.7)
		_G['ccs_sf_btn5_bg']:SetAlpha(0.3 + btn5 * 0.7)
		_G['ccs_sf_btn6_bg']:SetAlpha(0.3 + btn6 * 0.7)
		_G['ccs_sf_btn7_bg']:SetAlpha(0.3 + btn7 * 0.7)
		_G['ccs_sf_btn8_bg']:SetAlpha(0.3 + btn8 * 0.7)
	end

	module.MoveModelLeft = function()
		local Width = 288 + LibCS.DB.padding.h -- Hard code it for now
		local Height = 359 + (7 * LibCS.DB.padding.v) -- Hard code it for now
		modelregion:ClearAllPoints()
		CharacterModelScene:ClearAllPoints()
		CharacterModelScene:SetHeight(Height)
		CharacterModelScene:SetWidth(Height / ModelAspect)
		CharacterModelScene:SetPoint('CENTER', CharacterFrameInset, 'CENTER', 0, 0)
		CharacterModelScene:SetFrameLevel(2)
		CharacterModelScene:Show()
		CharacterModelFrameBackgroundTopLeft:Hide()
		CharacterModelFrameBackgroundBotLeft:Hide()
		CharacterModelFrameBackgroundTopRight:Hide()
		CharacterModelFrameBackgroundBotRight:Hide()
		CharacterModelFrameBackgroundOverlay:ClearAllPoints()
		CharacterModelFrameBackgroundOverlay:SetPoint('TOPLEFT', CharacterModelFrameBackgroundTopLeft, 'TOPLEFT', 0, 0)
		CharacterModelFrameBackgroundOverlay:SetPoint('BOTTOMRIGHT', CharacterModelFrameBackgroundBotRight, 'BOTTOMRIGHT', 0, 70)
		CharacterModelFrameBackgroundOverlay:Hide()
		modelregion:SetSize(Width, CharacterModelScene:GetHeight())
		modelregion:SetPoint('TOPLEFT', CharacterHeadSlot, 'TOPLEFT')
	end

	module.ccs_cshow = function()
		module.MoveModelLeft()
		CharacterModelScene.ControlFrame:Hide()
	end

	-- Set the initial CharacterFrame height and Model Aspect Ratio (for resizing other frames)
	-- This entire section is just moving, resizing, and hiding built in UI elements.
	module.initializecharacterframe = function()
		-- Initial CharacterFrame Height: 420 and Width: 338

		if InCombatLockdown() then
			return
		end

		CharacterFrame:SetHeight(479 + (7 * LibCS.DB.padding.v)) -- Do not allow the frame to get any smaller than the default bliz frame
		local Bgoffset = 17 + LibCS.DB.padding.h

		CharacterFrame.Inset:Hide()
		CharacterFrame.NineSlice:Hide()
		CharacterFrame.Portrait:Hide()
		CharacterFrame.InsetRight.Bg:Hide()

		CharacterFrameBg:SetVertexColor(0, 0, 0, 0)
		CharacterFrameBg:ClearAllPoints()
		CharacterFrameBg:SetPoint('TOPLEFT', CharacterFrame, 'TOPLEFT', 0, 0)
		CharacterFrameBg:SetPoint('BOTTOMRIGHT', CharacterFrame, 'BOTTOMRIGHT', Bgoffset, 0) --275  .449

		CharacterFrame.TopTileStreaks:Hide()
		TokenFramePopup:SetFrameStrata('HIGH')
		ReputationDetailFrame:SetFrameStrata('HIGH')

		local charbg = _G['CharacterFrameBgbg'] or CreateFrame('Frame', 'CharacterFrameBgbg', CharacterFrame)
		local charbgtex = _G['CharacterFrameBgbgtex'] or charbg:CreateTexture('CharacterFrameBgbgtex', 'BACKGROUND', nil, 1)
		local bgr, bgg, bgb, bgalpha = c.ccsbgcolor[1], c.ccsbgcolor[2], c.ccsbgcolor[3], c.ccsbgcolor[4]

		GearManagerPopupFrame:SetFrameStrata('DIALOG')
		GearManagerPopupFrame.IconSelector:SetFrameStrata('FULLSCREEN')

		charbg:ClearAllPoints()
		charbg:SetAllPoints(CharacterFrameBg)
		charbg:SetFrameStrata('BACKGROUND')
		charbgtex:ClearAllPoints()
		charbgtex:SetAllPoints()
		charbgtex:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		charbgtex:SetVertexColor(bgr, bgg, bgb, bgalpha)
		CharacterFrameCloseButton:ClearAllPoints()
		CharacterFrameCloseButton:SetPoint('TOPRIGHT', CharacterFrameBg, 'TOPRIGHT', 5.6, 5)

		-- We need to scale the Name, title, and class text too
		CharacterFrameTitleText:ClearAllPoints()
		CharacterFrameTitleText:SetPoint('TOP', CharacterFrame, 'TOP', 0, 0)
		CharacterFrameTitleText:SetPoint('LEFT', CharacterFrame, 'LEFT', 50, 0)
		CharacterFrameTitleText:SetPoint('RIGHT', CharacterFrameInset, 'RIGHT', -40, 0)
		CharacterFrameTitleText:SetFont(Font, 12)

		CharacterLevelText:ClearAllPoints()
		CharacterLevelText:SetPoint('TOP', CharacterFrameTitleText, 'BOTTOM', 0, 0)

		CharacterLevelText:SetFont(Font, 11)

		CharacterFrameInsetRight:ClearAllPoints()
		CharacterFrameInsetRight:SetPoint('TOPLEFT', CharacterFrameInset, 'TOPRIGHT', 4, 0)
		CharacterFrameInsetRight:SetPoint('BOTTOMRIGHT', CharacterFrameInset, 'BOTTOMRIGHT', 200, 0)
		CharacterStatsPane.ClassBackground:Hide()

		if C_AddOns.IsAddOnLoaded('Pawn') then
			PawnUI_InventoryPawnButton:ClearAllPoints()
			PawnUI_InventoryPawnButton:SetPoint('BOTTOMRIGHT', CharacterFrameInset, 'BOTTOMRIGHT', 0, -55)
		end

		if C_AddOns.IsAddOnLoaded('Narcissus') then
			NarciCharacterFrameDominationIndicator:ClearAllPoints()
			NarciCharacterFrameDominationIndicator:SetPoint('CENTER', CharacterFrameBg, 'TOPRIGHT', -1, -45)
			NarciCharacterFrameClassSetIndicator:ClearAllPoints()
			NarciCharacterFrameClassSetIndicator:SetPoint('CENTER', CharacterFrameBg, 'TOPRIGHT', -1, -45)
		end
		PaperDollFrame:UnregisterAllEvents()
		PaperDollInnerBorderBottom:Hide()
		PaperDollInnerBorderBottom2:Hide()
		PaperDollInnerBorderBottomLeft:Hide()
		PaperDollInnerBorderBottomRight:Hide()
		PaperDollInnerBorderLeft:Hide()
		PaperDollInnerBorderRight:Hide()
		PaperDollInnerBorderTop:Hide()
		PaperDollInnerBorderTopLeft:Hide()
		PaperDollInnerBorderTopRight:Hide()
		CharacterFrameInsetRight.NineSlice:Hide()

		CharacterBackSlotFrame:Hide()
		CharacterChestSlotFrame:Hide()
		CharacterFeetSlotFrame:Hide()
		CharacterFinger0SlotFrame:Hide()
		CharacterFinger1SlotFrame:Hide()
		CharacterHandsSlotFrame:Hide()
		CharacterHeadSlotFrame:Hide()
		CharacterLegsSlotFrame:Hide()
		CharacterMainHandSlotFrame:Hide()
		CharacterNeckSlotFrame:Hide()
		CharacterSecondaryHandSlotFrame:Hide()
		CharacterShirtSlotFrame:Hide()
		CharacterShoulderSlotFrame:Hide()
		CharacterTabardSlotFrame:Hide()
		CharacterTrinket0SlotFrame:Hide()
		CharacterTrinket1SlotFrame:Hide()
		CharacterWaistSlotFrame:Hide()
		CharacterWristSlotFrame:Hide()
		-- All slots on the left (under head) are tied back to this slot
		CharacterHeadSlot:ClearAllPoints()
		CharacterHeadSlot:SetPoint('TOPLEFT', CharacterFrameBg, 'TOPLEFT', 30, -60)
		-- Now we change the spacing of the slots on the left
		CharacterNeckSlot:ClearAllPoints()
		CharacterNeckSlot:SetPoint('TOPLEFT', CharacterHeadSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
		CharacterShoulderSlot:ClearAllPoints()
		CharacterShoulderSlot:SetPoint('TOPLEFT', CharacterNeckSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
		CharacterBackSlot:ClearAllPoints()
		CharacterBackSlot:SetPoint('TOPLEFT', CharacterShoulderSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
		CharacterChestSlot:ClearAllPoints()
		CharacterChestSlot:SetPoint('TOPLEFT', CharacterBackSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
		CharacterShirtSlot:ClearAllPoints()
		CharacterShirtSlot:SetPoint('TOPLEFT', CharacterChestSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
		CharacterTabardSlot:ClearAllPoints()
		CharacterTabardSlot:SetPoint('TOPLEFT', CharacterShirtSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
		CharacterWristSlot:ClearAllPoints()
		CharacterWristSlot:SetPoint('TOPLEFT', CharacterTabardSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)

		-- All slots on the right (under hands) are tied back to this slot
		CharacterHandsSlot:ClearAllPoints()
		CharacterHandsSlot:SetPoint('TOPLEFT', CharacterFrameBg, 'TOPLEFT', 283 + LibCS.DB.padding.h, -60)
		-- Now we change the spacing of the slots on the right
		CharacterWaistSlot:ClearAllPoints()
		CharacterWaistSlot:SetPoint('TOPLEFT', CharacterHandsSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
		CharacterLegsSlot:ClearAllPoints()
		CharacterLegsSlot:SetPoint('TOPLEFT', CharacterWaistSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
		CharacterFeetSlot:ClearAllPoints()
		CharacterFeetSlot:SetPoint('TOPLEFT', CharacterLegsSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
		CharacterFinger0Slot:ClearAllPoints()
		CharacterFinger0Slot:SetPoint('TOPLEFT', CharacterFeetSlot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
		CharacterFinger1Slot:ClearAllPoints()
		CharacterFinger1Slot:SetPoint('TOPLEFT', CharacterFinger0Slot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
		CharacterTrinket0Slot:ClearAllPoints()
		CharacterTrinket0Slot:SetPoint('TOPLEFT', CharacterFinger1Slot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)
		CharacterTrinket1Slot:ClearAllPoints()
		CharacterTrinket1Slot:SetPoint('TOPLEFT', CharacterTrinket0Slot, 'BOTTOMLEFT', 0, -LibCS.DB.padding.v)

		CharacterMainHandSlot:ClearAllPoints()
		CharacterMainHandSlot:SetPoint('BOTTOMLEFT', CharacterFrameBg, 'BOTTOMLEFT', 146 + 89 * LibCS.DB.padding.h / 262, 60)
		CharacterSecondaryHandSlot:ClearAllPoints()
		CharacterSecondaryHandSlot:SetPoint('TOPLEFT', CharacterMainHandSlot, 'TOPRIGHT', 60 * LibCS.DB.padding.h / 262, 0)
		select(16, CharacterMainHandSlot:GetRegions()):Hide()
		select(16, CharacterSecondaryHandSlot:GetRegions()):Hide()
		-- [Toast] Create Base Frame
		local toast = _G['CCS_TOAST'] or CreateFrame('FRAME', 'CCS_TOAST', UIParent)
		toast:SetPoint('TOP', UIParent, 'TOP', 0, -160)
		toast:SetWidth(302)
		toast:SetHeight(70)
		toast:SetMovable(true)
		toast:SetUserPlaced(false)
		toast:SetClampedToScreen(true)
		toast:RegisterForDrag('LeftButton')
		toast:SetScript('OnDragStart', toast.StartMoving)
		toast:SetScript('OnDragStop', toast.StopMovingOrSizing)
		toast:Hide()

		-- [Toast] Create Background Texture
		toast.texture = toast:CreateTexture(nil, 'BACKGROUND')
		toast.texture:SetPoint('TOPLEFT', toast, 'TOPLEFT', -6, 4)
		toast.texture:SetPoint('BOTTOMRIGHT', toast, 'BOTTOMRIGHT', 4, -4)
		toast.texture:SetTexture('Interface\\Garrison\\GarrisonToast')
		toast.texture:SetTexCoord(0, 0.61, 0.33, 0.48)

		-- [Toast] Create Title Text
		toast.title = _G['CCS_TOASTfs1'] or toast:CreateFontString('CCS_TOASTfs1')
		toast.title:SetPoint('TOPLEFT', toast, 'TOPLEFT', 23, -10)
		toast.title:SetWidth(260)
		toast.title:SetHeight(16)
		toast.title:SetJustifyV('TOP')
		toast.title:SetJustifyH('LEFT')
		toast.title:SetFont(Font, 12, textoptions)
		toast.title:Show()

		-- [Toast] Create Description Text
		toast.description = _G['CCS_TOASTfs2'] or toast:CreateFontString('CCS_TOASTfs2')
		toast.description:SetPoint('TOPLEFT', toast.title, 'TOPLEFT', 1, -23)
		toast.description:SetWidth(258)
		toast.description:SetHeight(32)
		toast.description:SetJustifyV('TOP')
		toast.description:SetJustifyH('LEFT')
		toast.description:SetFont(Font, 12, textoptions)
		toast.description:Show()

		CharacterFrame:SetScale(scaling)
		TokenFrame:SetScale(scaling)
		ReputationFrame:SetScale(scaling)

		if WeeklyRewardExpirationWarningDialog then
			WeeklyRewardExpirationWarningDialog:Hide()
		end
	end

	module.initializecharacterframe()

	module.ReputationFrame_Update = function()
		local ks = { ReputationFrame.ScrollBox.ScrollTarget:GetChildren() }
		local gender = UnitSex('player')
		local xtext, factiontext = '', ''

		if IsAddOnLoaded('PrettyReps') then
			return
		end

		for _, k in ipairs(ks) do
			local ks2 = { k:GetChildren() }
			for _, k2 in ipairs(ks2) do -- Individual Row
				local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canSetInactive =
					GetFactionInfo(k.index)

				-- Set the basic location and colors of the Reputation Bar Background and the Sub-bar.
				if k2.Background then
					k2.Background:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
					k2.Background:SetColorTexture(0.15, 0.15, 0.15, 0.90)
					k2.Background:SetPoint('TOPRIGHT', k2.ReputationBar, 'TOPLEFT')
					k2.Background:SetHeight(k2:GetHeight() * 0.9)
				end

				if k2.ReputationBar then
					k2.ReputationBar.LeftTexture:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
					k2.ReputationBar.LeftTexture:SetGradient('Vertical', CreateColor(0, 0, 0, 0.2), CreateColor(0.2, 0.2, 0.2, 0.4)) -- Dark Gray
					k2.ReputationBar.LeftTexture:SetAlpha(0.9)
					k2.ReputationBar.LeftTexture:SetPoint('RIGHT', k2, 'RIGHT')
					k2.ReputationBar:SetWidth(202)
					k2.ReputationBar:SetHeight(k2:GetHeight() * 0.9)
					k2.ReputationBar.RightTexture:Hide()
				end

				if name == 'Inactive' or name == 'Other' then
					-- we skip the inactive header since the friendship lookup doesn't like it.
				else
					local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold =
						C_GossipInfo.GetFriendshipReputation(factionID)
					local colorIndex = standingID
					local barColor = FACTION_BAR_COLORS[colorIndex]
					local factionStandingtext
					local isCapped = (standingID == MAX_REPUTATION_REACTION)
					local isParagon = factionID and C_Reputation.IsFactionParagon(factionID)
					local isMajorFaction = factionID and C_Reputation.IsMajorFaction(factionID)
					local repInfo = factionID and C_GossipInfo.GetFriendshipReputation(factionID)

					if repInfo and repInfo.friendshipFactionID > 0 then
						factionStandingtext = repInfo.reaction
						if repInfo.nextThreshold then
							barMin, barMax, barValue = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing
						else
							-- max rank, make it look like a full bar
							barMin, barMax, barValue = 0, 1, 1
							isCapped = true
						end
						local friendshipColorIndex = 5
						barColor = FACTION_BAR_COLORS[colorIndex]
						k2.friendshipID = repInfo.friendshipFactionID
					elseif isMajorFaction then
						local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)

						barMin, barMax = 0, majorFactionData.renownLevelThreshold
						isCapped = C_MajorFactions.HasMaximumRenown(factionID)
						barValue = isCapped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
						barColor = BLUE_FONT_COLOR

						k2.friendshipID = nil
						factionStandingtext = RENOWN_LEVEL_LABEL .. majorFactionData.renownLevel
					else
						factionStandingtext = GetText('FACTION_STANDING_LABEL' .. standingID, gender)
						k2.friendshipID = nil
					end

					factiontext = factionStandingtext

					if isCapped then
						barMax = 21000
						barValue = 21000
						barMin = 0
					else
						barMax = barMax - barMin
						barValue = barValue - barMin
						barMin = 0
					end

					-- Start making changes if this is a Paragon Rep
					if factionID and C_Reputation.IsFactionParagon(factionID) then
						local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
						local r, g, b = 0, 0.5, 0.9

						factiontext = 'Paragon'
						barMax = threshold
						barValue = currentValue - (floor(currentValue / threshold) - (hasRewardPending and 1 or 0)) * threshold
						barMin = 0
						k2.Paragon:SetShown(hasRewardPending)
						k2.ReputationBar:SetStatusBarColor(r, g, b)
						k2.ReputationBar:SetMinMaxValues(0, barMax)
						k2.ReputationBar:SetValue(barValue)
					end
					-- end of paragon changes
					local fontName, fontHeight, fontFlags = k2.ReputationBar.FactionStanding:GetFont()

					xtext = format(
						'  %s%-17.17s %15.15s%s',
						HIGHLIGHT_FONT_COLOR_CODE,
						factiontext,
						format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax)),
						FONT_COLOR_CODE_CLOSE
					)

					k.rolloverText = xtext
					k.standingText = xtext
					k2.ReputationBar.FactionStanding:SetFont(fontName, c.fontsize_reputation, textoptions)
					k2.Name:SetFont(fontName, c.fontsize_reputation, textoptions)
					k2.ReputationBar.FactionStanding:SetText(xtext)
					k2.ReputationBar.FactionStanding:ClearAllPoints()
					k2.ReputationBar.FactionStanding:SetPoint('LEFT', k2.ReputationBar, 'LEFT')
				end
			end
		end
	end

	module.updatemajorfactions = function()
		local barValue, barMin, barMax, mf, renownlevel, isParagon, isCapped, level
		if not c.showrenown then
			return
		end

		-- Dream Wardens
		mf = C_MajorFactions.GetMajorFactionData(2574)
		isParagon = C_Reputation.IsFactionParagon(2574)
		isCapped = C_MajorFactions.HasMaximumRenown(2574)
		if not isParagon or not isCapped then
			barMin, barMax = 0, mf.renownLevelThreshold
			barValue = isCapped and mf.renownLevelThreshold or mf.renownReputationEarned or 0
			barMax = mf.renownLevelThreshold
			_G['ccs_sf_btn8_pf']:Hide()
		else
			local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(2574)
			level = math.floor(currentValue / threshold)
			barValue = currentValue - (level * threshold)
			barMax = threshold
			_G['ccs_sf_btn8_repval']:SetGradient('Vertical', CreateColor(0, 0.5, 0.9, 0.8), CreateColor(0, 0.5, 0.9, 0.6))
			if hasRewardPending then
				_G['ccs_sf_btn8_pf']:Show()
			else
				_G['ccs_sf_btn8_pf']:Hide()
			end
		end
		renownlevel = mf.renownLevel
		_G['ccs_sf_btn8_repval']:SetWidth(math.min(192, (192 * barValue / barMax) + 0.1)) -- Base is 192
		_G['ccs_sf_btn8_fs2']:SetText(
			format(
				'  %s%-13.13s %13.13s%s',
				HIGHLIGHT_FONT_COLOR_CODE,
				RENOWN_LEVEL_LABEL .. renownlevel,
				format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax)),
				FONT_COLOR_CODE_CLOSE
			)
		)

		-- Loamm Niffen
		mf = C_MajorFactions.GetMajorFactionData(2564)
		isParagon = C_Reputation.IsFactionParagon(2564)
		isCapped = C_MajorFactions.HasMaximumRenown(2564)
		if not isParagon or not isCapped then
			barMin, barMax = 0, mf.renownLevelThreshold
			barValue = isCapped and mf.renownLevelThreshold or mf.renownReputationEarned or 0
			barMax = mf.renownLevelThreshold
			_G['ccs_sf_btn3_pf']:Hide()
		else
			local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(2564)
			level = math.floor(currentValue / threshold)
			barValue = currentValue - (level * threshold)
			barMax = threshold
			_G['ccs_sf_btn3_repval']:SetGradient('Vertical', CreateColor(0, 0.5, 0.9, 0.8), CreateColor(0, 0.5, 0.9, 0.6))
			if hasRewardPending then
				_G['ccs_sf_btn3_pf']:Show()
			else
				_G['ccs_sf_btn3_pf']:Hide()
			end
		end
		renownlevel = mf.renownLevel
		_G['ccs_sf_btn3_repval']:SetWidth(math.min(192, (192 * barValue / barMax) + 0.1)) -- Base is 192
		_G['ccs_sf_btn3_fs2']:SetText(
			format(
				'  %s%-13.13s %13.13s%s',
				HIGHLIGHT_FONT_COLOR_CODE,
				RENOWN_LEVEL_LABEL .. renownlevel,
				format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax)),
				FONT_COLOR_CODE_CLOSE
			)
		)

		-- Maruuk Centaur
		mf = C_MajorFactions.GetMajorFactionData(2503)
		isParagon = C_Reputation.IsFactionParagon(2503)
		isCapped = C_MajorFactions.HasMaximumRenown(2503)
		if not isParagon or not isCapped then
			barMin, barMax = 0, mf.renownLevelThreshold
			barValue = isCapped and mf.renownLevelThreshold or mf.renownReputationEarned or 0
			barMax = mf.renownLevelThreshold
			_G['ccs_sf_btn6_pf']:Hide()
		else
			local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(2503)
			level = math.floor(currentValue / threshold)
			barValue = currentValue - (level * threshold)
			barMax = threshold
			_G['ccs_sf_btn6_repval']:SetGradient('Vertical', CreateColor(0, 0.5, 0.9, 0.8), CreateColor(0, 0.5, 0.9, 0.6))
			if hasRewardPending then
				_G['ccs_sf_btn6_pf']:Show()
			else
				_G['ccs_sf_btn6_pf']:Hide()
			end
		end
		renownlevel = mf.renownLevel
		_G['ccs_sf_btn6_repval']:SetWidth(math.min(192, (192 * barValue / barMax) + 0.1)) -- Base is 192
		_G['ccs_sf_btn6_fs2']:SetText(
			format(
				'  %s%-13.13s %13.13s%s',
				HIGHLIGHT_FONT_COLOR_CODE,
				RENOWN_LEVEL_LABEL .. renownlevel,
				format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax)),
				FONT_COLOR_CODE_CLOSE
			)
		)

		-- Dragonscale Expedition
		mf = C_MajorFactions.GetMajorFactionData(2507)
		isParagon = C_Reputation.IsFactionParagon(2507)
		isCapped = C_MajorFactions.HasMaximumRenown(2507)
		if not isParagon or not isCapped then
			barMin, barMax = 0, mf.renownLevelThreshold
			barValue = isCapped and mf.renownLevelThreshold or mf.renownReputationEarned or 0
			barMax = mf.renownLevelThreshold
			_G['ccs_sf_btn4_pf']:Hide()
		else
			local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(2507)
			level = math.floor(currentValue / threshold)
			barValue = currentValue - (level * threshold)
			barMax = threshold
			_G['ccs_sf_btn4_repval']:SetGradient('Vertical', CreateColor(0, 0.5, 0.9, 0.8), CreateColor(0, 0.5, 0.9, 0.6))
			if hasRewardPending then
				_G['ccs_sf_btn4_pf']:Show()
			else
				_G['ccs_sf_btn4_pf']:Hide()
			end
		end
		renownlevel = mf.renownLevel
		_G['ccs_sf_btn4_repval']:SetWidth(math.min(192, (192 * barValue / barMax) + 0.1)) -- Base is 192
		_G['ccs_sf_btn4_fs2']:SetText(
			format(
				'  %s%-13.13s %13.13s%s',
				HIGHLIGHT_FONT_COLOR_CODE,
				RENOWN_LEVEL_LABEL .. renownlevel,
				format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax)),
				FONT_COLOR_CODE_CLOSE
			)
		)

		-- Valdrakken Accord
		mf = C_MajorFactions.GetMajorFactionData(2510)
		isParagon = C_Reputation.IsFactionParagon(2510)
		isCapped = C_MajorFactions.HasMaximumRenown(2510)
		if not isParagon or not isCapped then
			barMin, barMax = 0, mf.renownLevelThreshold
			barValue = isCapped and mf.renownLevelThreshold or mf.renownReputationEarned or 0
			barMax = mf.renownLevelThreshold
			_G['ccs_sf_btn7_pf']:Hide()
		else
			local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(2510)
			level = math.floor(currentValue / threshold)
			barValue = currentValue - (level * threshold)
			barMax = threshold
			_G['ccs_sf_btn7_repval']:SetGradient('Vertical', CreateColor(0, 0.5, 0.9, 0.8), CreateColor(0, 0.5, 0.9, 0.6))
			if hasRewardPending then
				_G['ccs_sf_btn7_pf']:Show()
			else
				_G['ccs_sf_btn7_pf']:Hide()
			end
		end
		renownlevel = mf.renownLevel
		_G['ccs_sf_btn7_repval']:SetWidth(math.min(192, (192 * barValue / barMax) + 0.1)) -- Base is 192
		_G['ccs_sf_btn7_fs2']:SetText(
			format(
				'  %s%-13.13s %13.13s%s',
				HIGHLIGHT_FONT_COLOR_CODE,
				RENOWN_LEVEL_LABEL .. renownlevel,
				format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax)),
				FONT_COLOR_CODE_CLOSE
			)
		)

		-- Iskaara Tuskarr
		mf = C_MajorFactions.GetMajorFactionData(2511)
		isParagon = C_Reputation.IsFactionParagon(2511)
		isCapped = C_MajorFactions.HasMaximumRenown(2511)
		if not isParagon or not isCapped then
			barMin, barMax = 0, mf.renownLevelThreshold
			barValue = isCapped and mf.renownLevelThreshold or mf.renownReputationEarned or 0
			barMax = mf.renownLevelThreshold
			_G['ccs_sf_btn5_pf']:Hide()
		else
			local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(2511)
			level = math.floor(currentValue / threshold)
			barValue = currentValue - (level * threshold)
			barMax = threshold
			_G['ccs_sf_btn5_repval']:SetGradient('Vertical', CreateColor(0, 0.5, 0.9, 0.8), CreateColor(0, 0.5, 0.9, 0.6))
			if hasRewardPending then
				_G['ccs_sf_btn5_pf']:Show()
			else
				_G['ccs_sf_btn5_pf']:Hide()
			end
		end
		renownlevel = mf.renownLevel
		_G['ccs_sf_btn5_repval']:SetWidth(math.min(192, (192 * barValue / barMax) + 0.1)) -- Base is 192
		_G['ccs_sf_btn5_fs2']:SetText(
			format(
				'  %s%-13.13s %13.13s%s',
				HIGHLIGHT_FONT_COLOR_CODE,
				RENOWN_LEVEL_LABEL .. renownlevel,
				format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax)),
				FONT_COLOR_CODE_CLOSE
			)
		)
	end

	module.InitializeFrameUpdates = function()
		PaperDollFrame.TitleManagerPane:ClearAllPoints()
		PaperDollFrame.TitleManagerPane:SetPoint('TOPLEFT', CharacterFrameInsetRight, 'TOPLEFT', 4, -4)
		PaperDollFrame.TitleManagerPane:SetPoint('BOTTOM', CharacterFrameInsetRight, 'BOTTOM', 0, 10)
		PaperDollFrame.TitleManagerPane.ScrollBox:ClearAllPoints()
		PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint('TOPLEFT', CharacterFrameInsetRight, 'TOPLEFT', 4, -4)
		PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint('BOTTOM', CharacterFrameInsetRight, 'BOTTOM', 0, 10)

		PaperDollFrame.EquipmentManagerPane:ClearAllPoints()
		PaperDollFrame.EquipmentManagerPane:SetPoint('TOPLEFT', CharacterFrameInsetRight, 'TOPLEFT', 4, -4)
		PaperDollFrame.EquipmentManagerPane:SetPoint('BOTTOM', CharacterFrameInsetRight, 'BOTTOM', 0, 10)
		PaperDollFrame.EquipmentManagerPane.ScrollBox:ClearAllPoints()
		PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint('TOPLEFT', PaperDollFrameEquipSet, 'BOTTOMLEFT', 0, 0)
		PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint('BOTTOM', CharacterFrameInsetRight, 'BOTTOM', 0, 10)

		ReputationFrame:ClearAllPoints()
		ReputationFrame:SetPoint('TOPLEFT', CharacterFrameBg, 'TOPLEFT', 0, 0)
		ReputationFrame:SetPoint('BOTTOMRIGHT', CharacterFrameBg, 'BOTTOMRIGHT', 0, 0)

		ReputationFrameFactionLabel:ClearAllPoints()
		ReputationFrameFactionLabel:SetPoint('TOPLEFT', CharacterFrameBg, 'TOPLEFT', 50, -40)
		ReputationFrameStandingLabel:ClearAllPoints()
		ReputationFrameStandingLabel:SetPoint('TOPRIGHT', CharacterFrameBg, 'TOPRIGHT', -70, -40)

		if ReputationFrame:IsVisible() and c.showrenown then
			_G['ccs_sf_btn3']:Show()
			_G['ccs_sf_btn4']:Show()
			_G['ccs_sf_btn5']:Show()
			_G['ccs_sf_btn6']:Show()
			_G['ccs_sf_btn7']:Show()
			_G['ccs_sf_btn8']:Show()
			_G['CCSf']:Show()
			_G['ccs_sf']:Show()
			WeeklyRewardsFrame:Hide()
			if _G['ccsm_sf'] then
				_G['ccsm_sf']:Hide()
			end
			module.sf_bafc(8)
		else
			_G['CCSf']:Hide()
			_G['ccs_sf']:Hide()
		end
	end

	-- Initialize the sub-frame and hook into other frames (only once)
	if not _G['ccs_sf'] then
		if WeeklyRewardExpirationWarningDialog then
			WeeklyRewardExpirationWarningDialog:Hide()
		end

		if WeeklyRewardsFrame.Blackout then
			WeeklyRewardsFrame.Blackout:ClearAllPoints()
		end

		if not _G['CCSf'] then
			CreateFrame('Frame', 'CCSf', CharacterFrame)
		end

		CCSf:ClearAllPoints()
		CCSf:SetPoint('TOPLEFT', CharacterFrameBg, 'TOPRIGHT', 0, 0)
		CCSf:SetPoint('TOPRIGHT', CharacterFrameBg, 'TOPRIGHT', 1612, 0)
		CCSf:SetScale(0.69)
		CCSf:SetSize(1618, 882) -- TEMPORARY
		CCSf:Show()

		CharacterFrameCloseButton:SetScale(0.7)

		local sf = _G['ccs_sf'] or CreateFrame('Frame', 'ccs_sf', CharacterFrame)
		local sf_bg = _G['ccs_sf_bg'] or sf:CreateTexture('ccs_sf_bg', 'BACKGROUND', nil, 2)
		local sf_topbar = _G['ccs_sf_tb'] or sf:CreateTexture('ccs_sf_tb', 'BACKGROUND', nil, 2)
		local sf_topstreaks = _G['ccs_sf_ts'] or sf:CreateTexture('ccs_sf_ts', 'BACKGROUND', nil, 2)
		local sf_bottombar = _G['ccs_sf_bb'] or sf:CreateTexture('ccs_sf_bb', 'BACKGROUND', nil, 2)

		local btn3 = _G['ccs_sf_btn3'] or CreateFrame('Button', 'ccs_sf_btn3', _G['ccs_sf']) --, "SecureActionButtonTemplate");
		if c.showbtn3 then
			btn3:Show()
		else
			btn3:Hide()
		end

		local btn3bg = _G['ccs_sf_btn3_bg'] or btn3:CreateTexture('ccs_sf_btn3_bg', 'BACKGROUND', nil)
		btn3bg:SetAllPoints()
		btn3bg:SetTexture('Interface\\CovenantRenown\\DragonflightMajorFactionsNiffen.BLP')
		btn3bg:SetTexCoord(0, 0.455, 0.78, 0.9)
		btn3bg:SetAlpha(0.3)
		btn3bg:Show()

		local btn3icon = _G['ccs_sf_btn3_icon'] or btn3:CreateTexture('ccs_sf_btn3_icon', 'ARTWORK', nil)
		btn3icon:SetPoint('TOPLEFT', btn3bg, 'TOPLEFT', 5, -7)
		btn3icon:SetTexture('Interface\\MajorFactions\\MajorFactionsIcons.BLP')
		btn3icon:SetTexCoord(0.5, 0.75, 0, 0.25)
		btn3icon:SetSize(40, 45)
		btn3icon:Show()

		local btn3pf = _G['ccs_sf_btn3_pf'] or CreateFrame('Button', 'ccs_sf_btn3_pf', _G['ccs_sf_btn3'])
		local btn3pfglow = _G['ccs_sf_btn3_pf_glow'] or _G['ccs_sf_btn3_pf']:CreateTexture('ccs_sf_btn3_pf_glow', 'BACKGROUND', nil)
		local btn3pficon = _G['ccs_sf_btn3_pf_icon'] or _G['ccs_sf_btn3_pf']:CreateTexture('ccs_sf_btn3_pf_icon', 'ARTWORK', nil)
		local btn3pfchk = _G['ccs_sf_btn3_pf_chk'] or _G['ccs_sf_btn3_pf']:CreateTexture('ccs_sf_btn3_pf_chk', 'OVERLAY', nil)
		btn3pf:SetSize(20, 20)
		btn3pf:SetPoint('CENTER', _G['ccs_sf_btn3_icon'], 'RIGHT')
		btn3pf:SetFrameStrata('HIGH')
		btn3pf:SetFrameLevel(10)
		btn3pf:SetScale(1.6)
		btn3pfglow:SetPoint('CENTER', -1, 0)
		btn3pfglow:SetAtlas('ParagonReputation_Glow', true)
		btn3pfglow:SetScale(1.25)
		btn3pf.Glow = btn3pfglow
		btn3pficon:SetPoint('CENTER')
		btn3pficon:SetAtlas('ParagonReputation_Bag', true)
		btn3pf.Icon = btn3pficon
		btn3pfchk:SetPoint('CENTER', 5, -2)
		btn3pfchk:SetAtlas('ParagonReputation_Checkmark', true)
		btn3pf.Check = btn3pfchk
		btn3pf:Show()
		btn3pf.Glow:Show()
		btn3pf.Icon:Show()
		btn3pf.Check:Show()
		btn3pf:SetScript('OnUpdate', function(self)
			ReputationParagonFrame_OnUpdate(self)
		end)

		local btn3fs1 = _G['ccs_sf_btn3_fs1'] or btn3:CreateFontString('ccs_sf_btn3_fs1')
		btn3fs1:SetPoint('TOP', btn3bg, 'TOP', 27, -5)
		btn3fs1:SetHeight(50)
		btn3fs1:SetJustifyV('TOP')
		btn3fs1:SetJustifyH('CENTER')
		btn3fs1:SetFont(Font, c.fontsize_talentbtntitles or 12, 'OUTLINE')
		btn3fs1:SetText(C_MajorFactions.GetMajorFactionData(2564).name) -- Loamm Niffen
		btn3fs1:Show()

		local btn3repbg = _G['ccs_sf_btn3_repbg'] or btn3:CreateTexture('ccs_sf_btn3_repbg', 'ARTWORK', nil, 1)
		btn3repbg:SetPoint('BOTTOM', btn3bg, 'BOTTOM', 22, 4)
		btn3repbg:SetWidth(195)
		btn3repbg:SetHeight(20)
		btn3repbg:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		btn3repbg:SetGradient('Vertical', CreateColor(0, 0, 0, 0.7), CreateColor(0.2, 0.2, 0.2, 0.9))
		btn3repbg:Show()

		local btn3repval = _G['ccs_sf_btn3_repval'] or btn3:CreateTexture('ccs_sf_btn3_repval', 'ARTWORK', nil, 2)
		btn3repval:SetPoint('TOPLEFT', btn3repbg, 'TOPLEFT', 0, 0)
		btn3repval:SetPoint('BOTTOMLEFT', btn3repbg, 'BOTTOMLEFT', 0, 0)
		btn3repval:SetHeight(20)
		btn3repval:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		btn3repval:SetGradient('Vertical', CreateColor(0, 0.75, 0.95, 0.8), CreateColor(0, 0.75, 0.95, 0.6))
		btn3repval:SetWidth(192)
		btn3repval:Show()

		local btn3fs2 = _G['ccs_sf_btn3_fs2'] or btn3:CreateFontString('ccs_sf_btn3_fs2')
		btn3fs2:SetPoint('BOTTOM', btn3bg, 'BOTTOM', 27, 4)
		btn3fs2:SetHeight(20)
		btn3fs2:SetJustifyV('MIDDLE')
		btn3fs2:SetJustifyH('LEFT')
		btn3fs2:SetFont(Font, c.fontsize_renown or 11, 'OUTLINE')
		btn3fs2:Show()

		btn3:SetScript('OnClick', function()
			sf_bafc(3)
		end)
		btn3:SetScript('OnEnter', function()
			btn3fs1:SetTextColor(1, 1, 0, 1)
		end)
		btn3:SetScript('OnLeave', function()
			btn3fs1:SetTextColor(1, 1, 1, 1)
		end)

		local btn4 = _G['ccs_sf_btn4'] or CreateFrame('Button', 'ccs_sf_btn4', _G['ccs_sf']) --, "SecureActionButtonTemplate");
		if c.showbtn4 then
			btn4:Show()
		else
			btn4:Hide()
		end

		local btn4bg = _G['ccs_sf_btn4_bg'] or btn4:CreateTexture('ccs_sf_btn4_bg', 'BACKGROUND', nil)
		btn4bg:SetAllPoints()
		btn4bg:SetTexture('Interface\\CovenantRenown\\DragonflightMajorFactionsExpedition.BLP')
		btn4bg:SetTexCoord(0, 0.455, 0.78, 0.9)
		btn4bg:SetAlpha(0.3)
		btn4bg:Show()

		local btn4icon = _G['ccs_sf_btn4_icon'] or btn4:CreateTexture('ccs_sf_btn4_icon', 'ARTWORK', nil)
		btn4icon:SetPoint('TOPLEFT', btn4bg, 'TOPLEFT', 5, -7)
		btn4icon:SetTexture('Interface\\MajorFactions\\MajorFactionsIcons.BLP')
		btn4icon:SetTexCoord(0.25, 0.47, 0, 0.25)
		btn4icon:SetSize(40, 45)
		btn4icon:Show()

		local btn4pf = _G['ccs_sf_btn4_pf'] or CreateFrame('Button', 'ccs_sf_btn4_pf', _G['ccs_sf_btn4'])
		local btn4pfglow = _G['ccs_sf_btn4_pf_glow'] or _G['ccs_sf_btn4_pf']:CreateTexture('ccs_sf_btn4_pf_glow', 'BACKGROUND', nil)
		local btn4pficon = _G['ccs_sf_btn4_pf_icon'] or _G['ccs_sf_btn4_pf']:CreateTexture('ccs_sf_btn4_pf_icon', 'ARTWORK', nil)
		local btn4pfchk = _G['ccs_sf_btn4_pf_chk'] or _G['ccs_sf_btn4_pf']:CreateTexture('ccs_sf_btn4_pf_chk', 'OVERLAY', nil)
		btn4pf:SetSize(20, 20)
		btn4pf:SetPoint('CENTER', _G['ccs_sf_btn4_icon'], 'RIGHT')
		btn4pf:SetFrameStrata('HIGH')
		btn4pf:SetFrameLevel(10)
		btn4pf:SetScale(1.6)
		btn4pfglow:SetPoint('CENTER', -1, 0)
		btn4pfglow:SetAtlas('ParagonReputation_Glow', true)
		btn4pfglow:SetScale(1.25)
		btn4pf.Glow = btn4pfglow
		btn4pficon:SetPoint('CENTER')
		btn4pficon:SetAtlas('ParagonReputation_Bag', true)
		btn4pf.Icon = btn4pficon
		btn4pfchk:SetPoint('CENTER', 5, -2)
		btn4pfchk:SetAtlas('ParagonReputation_Checkmark', true)
		btn4pf.Check = btn4pfchk
		btn4pf:Show()
		btn4pf.Glow:Show()
		btn4pf.Icon:Show()
		btn4pf.Check:Show()
		btn4pf:SetScript('OnUpdate', function(self)
			ReputationParagonFrame_OnUpdate(self)
		end)

		local btn4fs1 = _G['ccs_sf_btn4_fs1'] or btn4:CreateFontString('ccs_sf_btn4_fs1')
		btn4fs1:SetPoint('TOP', btn4bg, 'TOP', 27, -5)
		btn4fs1:SetHeight(50)
		btn4fs1:SetJustifyV('TOP')
		btn4fs1:SetJustifyH('CENTER')
		btn4fs1:SetFont(Font, c.fontsize_talentbtntitles or 12, 'OUTLINE')
		btn4fs1:SetText(C_MajorFactions.GetMajorFactionData(2507).name) -- Dragonscale Expedition
		btn4fs1:Show()

		local btn4repbg = _G['ccs_sf_btn4_repbg'] or btn4:CreateTexture('ccs_sf_btn4_repbg', 'ARTWORK', nil, 1)
		btn4repbg:SetPoint('BOTTOM', btn4bg, 'BOTTOM', 22, 4)
		btn4repbg:SetWidth(195)
		btn4repbg:SetHeight(20)
		btn4repbg:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		btn4repbg:SetGradient('Vertical', CreateColor(0, 0, 0, 0.7), CreateColor(0.2, 0.2, 0.2, 0.9))
		btn4repbg:Show()

		local btn4repval = _G['ccs_sf_btn4_repval'] or btn4:CreateTexture('ccs_sf_btn4_repval', 'ARTWORK', nil, 2)
		btn4repval:SetPoint('TOPLEFT', btn4repbg, 'TOPLEFT', 0, 0)
		btn4repval:SetPoint('BOTTOMLEFT', btn4repbg, 'BOTTOMLEFT', 0, 0)
		btn4repval:SetHeight(20)
		btn4repval:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		btn4repval:SetGradient('Vertical', CreateColor(0, 0.75, 0.95, 0.8), CreateColor(0, 0.75, 0.95, 0.6))
		btn4repval:SetWidth(192)
		btn4repval:Show()

		local btn4fs2 = _G['ccs_sf_btn4_fs2'] or btn4:CreateFontString('ccs_sf_btn4_fs2')
		btn4fs2:SetPoint('BOTTOM', btn4bg, 'BOTTOM', 27, 4)
		btn4fs2:SetHeight(20)
		btn4fs2:SetJustifyV('MIDDLE')
		btn4fs2:SetJustifyH('LEFT')
		btn4fs2:SetFont(Font, c.fontsize_renown or 11, 'OUTLINE')
		btn4fs2:Show()

		btn4:SetScript('OnClick', function()
			sf_bafc(4)
		end)
		btn4:SetScript('OnEnter', function()
			btn4fs1:SetTextColor(1, 1, 0, 1)
		end)
		btn4:SetScript('OnLeave', function()
			btn4fs1:SetTextColor(1, 1, 1, 1)
		end)

		local btn5 = _G['ccs_sf_btn5'] or CreateFrame('Button', 'ccs_sf_btn5', _G['ccs_sf']) --, "SecureActionButtonTemplate");
		if c.showbtn5 then
			btn5:Show()
		else
			btn5:Hide()
		end

		local btn5bg = _G['ccs_sf_btn5_bg'] or btn5:CreateTexture('ccs_sf_btn5_bg', 'BACKGROUND', nil)
		btn5bg:SetAllPoints()
		btn5bg:SetTexture('Interface\\CovenantRenown\\DragonflightMajorFactionsTuskarr.BLP')
		btn5bg:SetTexCoord(0, 0.455, 0.78, 0.9)
		btn5bg:SetAlpha(0.3)
		btn5bg:Show()

		local btn5icon = _G['ccs_sf_btn5_icon'] or btn5:CreateTexture('ccs_sf_btn5_icon', 'ARTWORK', nil)
		btn5icon:SetPoint('TOPLEFT', btn5bg, 'TOPLEFT', 5, -7)
		btn5icon:SetTexture('Interface\\MajorFactions\\MajorFactionsIcons.BLP')
		btn5icon:SetTexCoord(0, 0.25, 0.25, 0.5)
		btn5icon:SetSize(45, 45)
		btn5icon:Show()

		local btn5pf = _G['ccs_sf_btn5_pf'] or CreateFrame('Button', 'ccs_sf_btn5_pf', _G['ccs_sf_btn5'])
		local btn5pfglow = _G['ccs_sf_btn5_pf_glow'] or _G['ccs_sf_btn5_pf']:CreateTexture('ccs_sf_btn5_pf_glow', 'BACKGROUND', nil)
		local btn5pficon = _G['ccs_sf_btn5_pf_icon'] or _G['ccs_sf_btn5_pf']:CreateTexture('ccs_sf_btn5_pf_icon', 'ARTWORK', nil)
		local btn5pfchk = _G['ccs_sf_btn5_pf_chk'] or _G['ccs_sf_btn5_pf']:CreateTexture('ccs_sf_btn5_pf_chk', 'OVERLAY', nil)
		btn5pf:SetSize(20, 20)
		btn5pf:SetPoint('CENTER', _G['ccs_sf_btn5_icon'], 'RIGHT')
		btn5pf:SetFrameStrata('HIGH')
		btn5pf:SetFrameLevel(10)
		btn5pf:SetScale(1.6)
		btn5pfglow:SetPoint('CENTER', -1, 0)
		btn5pfglow:SetAtlas('ParagonReputation_Glow', true)
		btn5pfglow:SetScale(1.25)
		btn5pf.Glow = btn5pfglow
		btn5pficon:SetPoint('CENTER')
		btn5pficon:SetAtlas('ParagonReputation_Bag', true)
		btn5pf.Icon = btn5pficon
		btn5pfchk:SetPoint('CENTER', 5, -2)
		btn5pfchk:SetAtlas('ParagonReputation_Checkmark', true)
		btn5pf.Check = btn5pfchk
		btn5pf:Show()
		btn5pf.Glow:Show()
		btn5pf.Icon:Show()
		btn5pf.Check:Show()
		btn5pf:SetScript('OnUpdate', function(self)
			ReputationParagonFrame_OnUpdate(self)
		end)

		local btn5fs1 = _G['ccs_sf_btn5_fs1'] or btn5:CreateFontString('ccs_sf_btn5_fs1')
		btn5fs1:SetPoint('TOP', btn5bg, 'TOP', 27, -5)
		btn5fs1:SetHeight(50)
		btn5fs1:SetJustifyV('TOP')
		btn5fs1:SetJustifyH('CENTER')
		btn5fs1:SetFont(Font, c.fontsize_talentbtntitles or 12, 'OUTLINE')
		btn5fs1:SetText(C_MajorFactions.GetMajorFactionData(2511).name) -- Iskaara Tuskarr
		btn5fs1:Show()

		local btn5repbg = _G['ccs_sf_btn5_repbg'] or btn5:CreateTexture('ccs_sf_btn5_repbg', 'ARTWORK', nil, 1)
		btn5repbg:SetPoint('BOTTOM', btn5bg, 'BOTTOM', 22, 4)
		btn5repbg:SetWidth(195)
		btn5repbg:SetHeight(20)
		btn5repbg:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		btn5repbg:SetGradient('Vertical', CreateColor(0, 0, 0, 0.7), CreateColor(0.2, 0.2, 0.2, 0.9))
		btn5repbg:Show()

		local btn5repval = _G['ccs_sf_btn5_repval'] or btn5:CreateTexture('ccs_sf_btn5_repval', 'ARTWORK', nil, 2)
		btn5repval:SetPoint('TOPLEFT', btn5repbg, 'TOPLEFT', 0, 0)
		btn5repval:SetPoint('BOTTOMLEFT', btn5repbg, 'BOTTOMLEFT', 0, 0)
		btn5repval:SetHeight(20)
		btn5repval:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		btn5repval:SetGradient('Vertical', CreateColor(0, 0.75, 0.95, 0.8), CreateColor(0, 0.75, 0.95, 0.6))
		btn5repval:SetWidth(192)
		btn5repval:Show()

		local btn5fs2 = _G['ccs_sf_btn5_fs2'] or btn5:CreateFontString('ccs_sf_btn5_fs2')
		btn5fs2:SetPoint('BOTTOM', btn5bg, 'BOTTOM', 22, 4)
		btn5fs2:SetHeight(20)
		--btn5fs2:SetJustifyV("MIDDLE")
		btn5fs2:SetJustifyH('LEFT')
		btn5fs2:SetFont(Font, c.fontsize_renown or 11, 'OUTLINE')
		btn5fs2:Show()

		btn5:SetScript('OnClick', function()
			sf_bafc(5)
		end)
		btn5:SetScript('OnEnter', function()
			btn5fs1:SetTextColor(1, 1, 0, 1)
		end)
		btn5:SetScript('OnLeave', function()
			btn5fs1:SetTextColor(1, 1, 1, 1)
		end)

		local btn6 = _G['ccs_sf_btn6'] or CreateFrame('Button', 'ccs_sf_btn6', _G['ccs_sf']) --, "SecureActionButtonTemplate");
		if c.showbtn6 then
			btn6:Show()
		else
			btn6:Hide()
		end

		local btn6bg = _G['ccs_sf_btn6_bg'] or btn6:CreateTexture('ccs_sf_btn6_bg', 'BACKGROUND', nil)
		btn6bg:SetAllPoints()
		btn6bg:SetTexture('Interface\\CovenantRenown\\DragonflightMajorFactionsCentaur.BLP')
		btn6bg:SetTexCoord(0, 0.455, 0.78, 0.9)
		btn6bg:SetAlpha(0.3)
		btn6bg:Show()

		local btn6icon = _G['ccs_sf_btn6_icon'] or btn6:CreateTexture('ccs_sf_btn6_icon', 'ARTWORK', nil)
		btn6icon:SetPoint('TOPLEFT', btn6bg, 'TOPLEFT', 5, -7)
		btn6icon:SetTexture('Interface\\MajorFactions\\MajorFactionsIcons.BLP')
		btn6icon:SetTexCoord(0, 0.25, 0, 0.25)
		btn6icon:SetSize(45, 45)
		btn6icon:Show()

		local btn6pf = _G['ccs_sf_btn6_pf'] or CreateFrame('Button', 'ccs_sf_btn6_pf', _G['ccs_sf_btn6'])
		local btn6pfglow = _G['ccs_sf_btn6_pf_glow'] or _G['ccs_sf_btn6_pf']:CreateTexture('ccs_sf_btn6_pf_glow', 'BACKGROUND', nil)
		local btn6pficon = _G['ccs_sf_btn6_pf_icon'] or _G['ccs_sf_btn6_pf']:CreateTexture('ccs_sf_btn6_pf_icon', 'ARTWORK', nil)
		local btn6pfchk = _G['ccs_sf_btn6_pf_chk'] or _G['ccs_sf_btn6_pf']:CreateTexture('ccs_sf_btn6_pf_chk', 'OVERLAY', nil)
		btn6pf:SetSize(20, 20)
		btn6pf:SetPoint('CENTER', _G['ccs_sf_btn6_icon'], 'RIGHT')
		btn6pf:SetFrameStrata('HIGH')
		btn6pf:SetFrameLevel(10)
		btn6pf:SetScale(1.6)
		btn6pfglow:SetPoint('CENTER', -1, 0)
		btn6pfglow:SetAtlas('ParagonReputation_Glow', true)
		btn6pfglow:SetScale(1.25)
		btn6pf.Glow = btn6pfglow
		btn6pficon:SetPoint('CENTER')
		btn6pficon:SetAtlas('ParagonReputation_Bag', true)
		btn6pf.Icon = btn6pficon
		btn6pfchk:SetPoint('CENTER', 5, -2)
		btn6pfchk:SetAtlas('ParagonReputation_Checkmark', true)
		btn6pf.Check = btn6pfchk
		btn6pf:Show()
		btn6pf.Glow:Show()
		btn6pf.Icon:Show()
		btn6pf.Check:Show()
		btn6pf:SetScript('OnUpdate', function(self)
			ReputationParagonFrame_OnUpdate(self)
		end)

		local btn6fs1 = _G['ccs_sf_btn6_fs1'] or btn6:CreateFontString('ccs_sf_btn6_fs1')
		btn6fs1:SetPoint('TOP', btn6bg, 'TOP', 22, -5)
		btn6fs1:SetHeight(50)
		btn6fs1:SetJustifyV('TOP')
		btn6fs1:SetJustifyH('CENTER')
		btn6fs1:SetFont(Font, c.fontsize_talentbtntitles or 12, 'OUTLINE')
		btn6fs1:SetText(C_MajorFactions.GetMajorFactionData(2503).name) -- Maruuk Centaur
		btn6fs1:Show()

		local btn6repbg = _G['ccs_sf_btn6_repbg'] or btn6:CreateTexture('ccs_sf_btn6_repbg', 'ARTWORK', nil, 1)
		btn6repbg:SetPoint('BOTTOM', btn6bg, 'BOTTOM', 27, 4)
		btn6repbg:SetWidth(195)
		btn6repbg:SetHeight(20)
		btn6repbg:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		btn6repbg:SetGradient('Vertical', CreateColor(0, 0, 0, 0.7), CreateColor(0.2, 0.2, 0.2, 0.9))
		btn6repbg:Show()

		local btn6repval = _G['ccs_sf_btn6_repval'] or btn6:CreateTexture('ccs_sf_btn6_repval', 'ARTWORK', nil, 2)
		btn6repval:SetPoint('TOPLEFT', btn6repbg, 'TOPLEFT', 0, 0)
		btn6repval:SetPoint('BOTTOMLEFT', btn6repbg, 'BOTTOMLEFT', 0, 0)
		btn6repval:SetHeight(20)
		btn6repval:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		btn6repval:SetGradient('Vertical', CreateColor(0, 0.75, 0.95, 0.8), CreateColor(0, 0.75, 0.95, 0.6))
		btn6repval:SetWidth(192)
		btn6repval:Show()

		local btn6fs2 = _G['ccs_sf_btn6_fs2'] or btn6:CreateFontString('ccs_sf_btn6_fs2')
		btn6fs2:SetPoint('BOTTOM', btn6bg, 'BOTTOM', 27, 4)
		btn6fs2:SetHeight(20)
		btn6fs2:SetJustifyV('MIDDLE')
		btn6fs2:SetJustifyH('LEFT')
		btn6fs2:SetFont(Font, c.fontsize_renown or 11, 'OUTLINE')
		btn6fs2:Show()

		btn6:SetScript('OnClick', function()
			sf_bafc(6)
		end)
		btn6:SetScript('OnEnter', function()
			btn6fs1:SetTextColor(1, 1, 0, 1)
		end)
		btn6:SetScript('OnLeave', function()
			btn6fs1:SetTextColor(1, 1, 1, 1)
		end)

		local btn7 = _G['ccs_sf_btn7'] or CreateFrame('Button', 'ccs_sf_btn7', _G['ccs_sf']) --, "SecureActionButtonTemplate");
		if c.showbtn7 then
			btn7:Show()
		else
			btn7:Hide()
		end

		local btn7bg = _G['ccs_sf_btn7_bg'] or btn7:CreateTexture('ccs_sf_btn7_bg', 'BACKGROUND', nil)
		btn7bg:SetAllPoints()
		btn7bg:SetTexture('Interface\\CovenantRenown\\DragonflightMajorFactionsValdrakken.BLP')
		btn7bg:SetTexCoord(0, 0.455, 0.78, 0.9)
		btn7bg:SetAlpha(0.3)
		btn7bg:Show()

		local btn7icon = _G['ccs_sf_btn7_icon'] or btn7:CreateTexture('ccs_sf_btn7_icon', 'ARTWORK', nil)
		btn7icon:SetPoint('TOPLEFT', btn7bg, 'TOPLEFT', 5, -7)
		btn7icon:SetTexture('Interface\\MajorFactions\\MajorFactionsIcons.BLP')
		btn7icon:SetTexCoord(0, 0.25, 0.5, 0.75)
		btn7icon:SetSize(45, 45)
		btn7icon:Show()

		local btn7pf = _G['ccs_sf_btn7_pf'] or CreateFrame('Button', 'ccs_sf_btn7_pf', _G['ccs_sf_btn7'])
		local btn7pfglow = _G['ccs_sf_btn7_pf_glow'] or _G['ccs_sf_btn7_pf']:CreateTexture('ccs_sf_btn7_pf_glow', 'BACKGROUND', nil)
		local btn7pficon = _G['ccs_sf_btn7_pf_icon'] or _G['ccs_sf_btn7_pf']:CreateTexture('ccs_sf_btn7_pf_icon', 'ARTWORK', nil)
		local btn7pfchk = _G['ccs_sf_btn7_pf_chk'] or _G['ccs_sf_btn7_pf']:CreateTexture('ccs_sf_btn7_pf_chk', 'OVERLAY', nil)
		btn7pf:SetSize(20, 20)
		btn7pf:SetPoint('CENTER', _G['ccs_sf_btn7_icon'], 'RIGHT')
		btn7pf:SetFrameStrata('HIGH')
		btn7pf:SetFrameLevel(10)
		btn7pf:SetScale(1.6)
		btn7pfglow:SetPoint('CENTER', -1, 0)
		btn7pfglow:SetAtlas('ParagonReputation_Glow', true)
		btn7pfglow:SetScale(1.25)
		btn7pf.Glow = btn7pfglow
		btn7pficon:SetPoint('CENTER')
		btn7pficon:SetAtlas('ParagonReputation_Bag', true)
		btn7pf.Icon = btn7pficon
		btn7pfchk:SetPoint('CENTER', 5, -2)
		btn7pfchk:SetAtlas('ParagonReputation_Checkmark', true)
		btn7pf.Check = btn7pfchk
		btn7pf:Show()
		btn7pf.Glow:Show()
		btn7pf.Icon:Show()
		btn7pf.Check:Show()
		btn7pf:SetScript('OnUpdate', function(self)
			ReputationParagonFrame_OnUpdate(self)
		end)

		local btn7fs1 = _G['ccs_sf_btn7_fs1'] or btn7:CreateFontString('ccs_sf_btn7_fs1')
		btn7fs1:SetPoint('TOP', btn7bg, 'TOP', 22, -5)
		btn7fs1:SetHeight(50)
		btn7fs1:SetJustifyV('TOP')
		btn7fs1:SetJustifyH('CENTER')
		btn7fs1:SetFont(Font, c.fontsize_talentbtntitles or 12, 'OUTLINE')
		btn7fs1:SetText(C_MajorFactions.GetMajorFactionData(2510).name) -- Valdrakken Accord
		btn7fs1:Show()

		local btn7repbg = _G['ccs_sf_btn7_repbg'] or btn7:CreateTexture('ccs_sf_btn7_repbg', 'ARTWORK', nil, 1)
		btn7repbg:SetPoint('BOTTOM', btn7bg, 'BOTTOM', 27, 4)
		btn7repbg:SetWidth(195)
		btn7repbg:SetHeight(20)
		btn7repbg:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		btn7repbg:SetGradient('Vertical', CreateColor(0, 0, 0, 0.7), CreateColor(0.2, 0.2, 0.2, 0.9))
		btn7repbg:Show()

		local btn7repval = _G['ccs_sf_btn7_repval'] or btn7:CreateTexture('ccs_sf_btn7_repval', 'ARTWORK', nil, 2)
		btn7repval:SetPoint('TOPLEFT', btn7repbg, 'TOPLEFT', 0, 0)
		btn7repval:SetPoint('BOTTOMLEFT', btn7repbg, 'BOTTOMLEFT', 0, 0)
		btn7repval:SetHeight(20)
		btn7repval:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		btn7repval:SetGradient('Vertical', CreateColor(0, 0.75, 0.95, 0.8), CreateColor(0, 0.75, 0.95, 0.6))
		btn7repval:SetWidth(192)
		btn7repval:Show()

		local btn7fs2 = _G['ccs_sf_btn7_fs2'] or btn7:CreateFontString('ccs_sf_btn7_fs2')
		btn7fs2:SetPoint('BOTTOM', btn7bg, 'BOTTOM', 27, 4)
		btn7fs2:SetHeight(20)
		btn7fs2:SetJustifyV('MIDDLE')
		btn7fs2:SetJustifyH('LEFT')
		btn7fs2:SetFont(Font, c.fontsize_renown or 11, 'OUTLINE')
		btn7fs2:Show()

		btn7:SetScript('OnClick', function()
			sf_bafc(7)
		end)
		btn7:SetScript('OnEnter', function()
			btn7fs1:SetTextColor(1, 1, 0, 1)
		end)
		btn7:SetScript('OnLeave', function()
			btn7fs1:SetTextColor(1, 1, 1, 1)
		end)

		local btn8 = _G['ccs_sf_btn8'] or CreateFrame('Button', 'ccs_sf_btn8', _G['ccs_sf']) --, "SecureActionButtonTemplate");
		if c.showbtn8 then
			btn8:Show()
		else
			btn8:Hide()
		end

		local btn8bg = _G['ccs_sf_btn8_bg'] or btn8:CreateTexture('ccs_sf_btn8_bg', 'BACKGROUND', nil)
		btn8bg:SetAllPoints()
		btn8bg:SetTexture('Interface\\CovenantRenown\\DragonflightMajorFactionsDream.BLP')
		btn8bg:SetTexCoord(0, 0.455, 0.78, 0.9)
		btn8bg:SetAlpha(0.3)
		btn8bg:Show()

		local btn8icon = _G['ccs_sf_btn8_icon'] or btn8:CreateTexture('ccs_sf_btn8_icon', 'ARTWORK', nil)
		btn8icon:SetPoint('TOPLEFT', btn8bg, 'TOPLEFT', 5, -7)
		btn8icon:SetTexture('Interface\\MajorFactions\\MajorFactionsIcons.BLP')
		btn8icon:SetTexCoord(0.25, 0.5, 0.25, 0.5)
		btn8icon:SetSize(45, 45)
		btn8icon:Show()

		local btn8pf = _G['ccs_sf_btn8_pf'] or CreateFrame('Button', 'ccs_sf_btn8_pf', _G['ccs_sf_btn8'])
		local btn8pfglow = _G['ccs_sf_btn8_pf_glow'] or _G['ccs_sf_btn8_pf']:CreateTexture('ccs_sf_btn8_pf_glow', 'BACKGROUND', nil)
		local btn8pficon = _G['ccs_sf_btn8_pf_icon'] or _G['ccs_sf_btn8_pf']:CreateTexture('ccs_sf_btn8_pf_icon', 'ARTWORK', nil)
		local btn8pfchk = _G['ccs_sf_btn8_pf_chk'] or _G['ccs_sf_btn8_pf']:CreateTexture('ccs_sf_btn8_pf_chk', 'OVERLAY', nil)
		btn8pf:SetSize(20, 20)
		btn8pf:SetPoint('CENTER', _G['ccs_sf_btn8_icon'], 'RIGHT')
		btn8pf:SetFrameStrata('HIGH')
		btn8pf:SetFrameLevel(10)
		btn8pf:SetScale(1.6)
		btn8pfglow:SetPoint('CENTER', -1, 0)
		btn8pfglow:SetAtlas('ParagonReputation_Glow', true)
		btn8pfglow:SetScale(1.25)
		btn8pf.Glow = btn8pfglow
		btn8pficon:SetPoint('CENTER')
		btn8pficon:SetAtlas('ParagonReputation_Bag', true)
		btn8pf.Icon = btn8pficon
		btn8pfchk:SetPoint('CENTER', 5, -2)
		btn8pfchk:SetAtlas('ParagonReputation_Checkmark', true)
		btn8pf.Check = btn8pfchk
		btn8pf:Show()
		btn8pf.Glow:Show()
		btn8pf.Icon:Show()
		btn8pf.Check:Show()
		btn8pf:SetScript('OnUpdate', function(self)
			ReputationParagonFrame_OnUpdate(self)
		end)

		local btn8fs1 = _G['ccs_sf_btn8_fs1'] or btn8:CreateFontString('ccs_sf_btn8_fs1')
		btn8fs1:SetPoint('TOP', btn8bg, 'TOP', 22, -5)
		btn8fs1:SetHeight(50)
		btn8fs1:SetJustifyV('TOP')
		btn8fs1:SetJustifyH('CENTER')
		btn8fs1:SetFont(Font, c.fontsize_talentbtntitles or 12, 'OUTLINE')
		btn8fs1:SetText(C_MajorFactions.GetMajorFactionData(2574).name) -- Valdrakken Accord
		btn8fs1:Show()

		local btn8repbg = _G['ccs_sf_btn8_repbg'] or btn8:CreateTexture('ccs_sf_btn8_repbg', 'ARTWORK', nil, 1)
		btn8repbg:SetPoint('BOTTOM', btn8bg, 'BOTTOM', 27, 4)
		btn8repbg:SetWidth(195)
		btn8repbg:SetHeight(20)
		btn8repbg:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		btn8repbg:SetGradient('Vertical', CreateColor(0, 0, 0, 0.7), CreateColor(0.2, 0.2, 0.2, 0.9))
		btn8repbg:Show()

		local btn8repval = _G['ccs_sf_btn8_repval'] or btn8:CreateTexture('ccs_sf_btn8_repval', 'ARTWORK', nil, 2)
		btn8repval:SetPoint('TOPLEFT', btn8repbg, 'TOPLEFT', 0, 0)
		btn8repval:SetPoint('BOTTOMLEFT', btn8repbg, 'BOTTOMLEFT', 0, 0)
		btn8repval:SetHeight(20)
		btn8repval:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
		btn8repval:SetGradient('Vertical', CreateColor(0, 0.75, 0.95, 0.8), CreateColor(0, 0.75, 0.95, 0.6))
		btn8repval:SetWidth(192)
		btn8repval:Show()

		local btn8fs2 = _G['ccs_sf_btn8_fs2'] or btn8:CreateFontString('ccs_sf_btn8_fs2')
		btn8fs2:SetPoint('BOTTOM', btn8bg, 'BOTTOM', 27, 4)
		btn8fs2:SetHeight(20)
		btn8fs2:SetJustifyV('MIDDLE')
		btn8fs2:SetJustifyH('LEFT')
		btn8fs2:SetFont(Font, c.fontsize_renown or 11, 'OUTLINE')
		btn8fs2:Show()

		btn8:SetScript('OnClick', function()
			sf_bafc(8)
		end)
		btn8:SetScript('OnEnter', function()
			btn8fs1:SetTextColor(1, 1, 0, 1)
		end)
		btn8:SetScript('OnLeave', function()
			btn8fs1:SetTextColor(1, 1, 1, 1)
		end)

		btn3:SetSize(250, 54)
		btn3:SetPoint('RIGHT', btn4, 'LEFT', -3, 0)
		btn4:SetSize(250, 54)
		btn4:SetPoint('RIGHT', btn5, 'LEFT', -3, 0)
		btn5:SetSize(250, 54)
		btn5:SetPoint('RIGHT', btn6, 'LEFT', -3, 0)
		btn6:SetSize(250, 54)
		btn6:SetPoint('RIGHT', btn7, 'LEFT', -3, 0)
		btn7:SetSize(250, 54)
		btn7:SetPoint('BOTTOMRIGHT', _G['ccs_sf'], 'BOTTOMRIGHT', -3, 3)
		btn8:SetSize(250, 54)
		btn8:SetPoint('RIGHT', btn3, 'LEFT', -3, 0)
		btn3:SetScale(1.05)
		btn4:SetScale(1.05)
		btn5:SetScale(1.05)
		btn6:SetScale(1.05)
		btn7:SetScale(1.05)
		btn8:SetScale(1.05)

		sf:SetScale(0.69)
		module.updatemajorfactions()

		sf_bg:Show()

		--== Frame Hooks
		hooksecurefunc(TokenFrame, 'Show', function()
			-- hookfix()
		end)
		hooksecurefunc(TokenFrame.ScrollBox, 'Update', function()
			local tf = { TokenFrame.ScrollBox.ScrollTarget:GetChildren() }

			for _, t in ipairs(tf) do
				if t and t.Name then
					t.Name:SetFont(t.Name:GetFont(), c.fontsize_currency or 11, '')
				end
				if t and t.Count then
					t.Count:SetFont(t.Count:GetFont(), c.fontsize_currency or 11, '')
				end
			end
		end)

		hooksecurefunc(PaperDollFrame, 'Show', function()
			-- hookfix()
		end)

		hooksecurefunc(CharacterFrame, 'Show', function()
			-- Move blizzard frames around and resize upon CharacterFrame being opened.
			module.InitializeFrameUpdates()
			module.loopitems()
			MajorFactionRenownFrame:SetParent(_G['ccs_sf'])
			WeeklyRewardsFrame:ClearAllPoints()
			WeeklyRewardsFrame:SetParent(CharacterFrame)
			WeeklyRewardsFrame:SetPoint('TOP', CCSf, 'TOP', 0, -20)
			WeeklyRewardsFrame:SetScale(0.85)
			WeeklyRewardsFrame.BackgroundTile:SetAlpha(0.6)
			WeeklyRewardsFrame.CloseButton:Hide()
			WeeklyRewardsFrame:SetFrameStrata('HIGH')
			WeeklyRewardsFrame:Hide()

			sf:ClearAllPoints()
			sf:SetPoint('TOPLEFT', CCSf, 'TOPLEFT', 0, 0)
			sf:SetPoint('TOPRIGHT', CCSf, 'TOPRIGHT', 0, 0)
			sf:SetPoint('BOTTOM', CCSf, 'BOTTOM', 0, -45)

			sf_bg:ClearAllPoints()
			sf_bg:SetAllPoints()
			sf_bg:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_FullWhite.tga')
			sf_bg:SetColorTexture(0.1, 0.1, 0.1, 0.6)

			sf_topbar:ClearAllPoints()
			sf_topbar:SetPoint('TOPLEFT', sf, 'TOPLEFT')
			sf_topbar:SetPoint('TOPRIGHT', sf, 'TOPRIGHT')
			sf_topbar:SetHeight(16)
			sf_topbar:SetTexture('1723833')
			sf_topbar:SetTexCoord(0, 1, 0.586, 0.734)

			sf_topstreaks:ClearAllPoints()
			sf_topstreaks:SetPoint('TOPLEFT', sf_topbar, 'BOTTOMLEFT')
			sf_topstreaks:SetPoint('TOPRIGHT', sf_topbar, 'BOTTOMRIGHT')
			sf_topstreaks:SetHeight(43)
			sf_topstreaks:SetTexture('1723833')
			sf_topstreaks:SetTexCoord(0, 1, 0, 0.328)
			sf_bottombar:ClearAllPoints()
			sf_bottombar:SetPoint('BOTTOMLEFT', sf, 'BOTTOMLEFT')
			sf_bottombar:SetPoint('BOTTOMRIGHT', sf, 'BOTTOMRIGHT')
			sf_bottombar:SetHeight(67)
			sf_bottombar:SetTexture('4556093')
			sf_bottombar:SetTexCoord(0, 0.75, 0, 0.082)
			GameTooltip:Hide()
		end)

		hooksecurefunc(CharacterFrame, 'Hide', function()
			-- Move blizzard frames back so they can be opened normally.
			WeeklyRewardsFrame:ClearAllPoints()
			WeeklyRewardsFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 0)
			WeeklyRewardsFrame:SetParent(UIParent)
			WeeklyRewardsFrame:SetScale(1)
			WeeklyRewardsFrame.BackgroundTile:SetAlpha(1)
			WeeklyRewardsFrame.CloseButton:Show()
			WeeklyRewardsFrame:Hide()
			MajorFactionRenownFrame:Hide()
			MajorFactionRenownFrame:SetParent(UIParent)
			MajorFactionRenownFrame.Background:SetAlpha(1)
			MajorFactionRenownFrame.CloseButton:Show()
			if true then
				_G['ccs_sf_btn3_bg']:SetAlpha(0.3)
				_G['ccs_sf_btn4_bg']:SetAlpha(0.3)
				_G['ccs_sf_btn5_bg']:SetAlpha(0.3)
				_G['ccs_sf_btn6_bg']:SetAlpha(0.3)
				_G['ccs_sf_btn7_bg']:SetAlpha(0.3)
				_G['ccs_sf_btn8_bg']:SetAlpha(0.3)
			end
			GameTooltip:Hide()
		end)
	end

	-- [Paragon Toast] Show the Paragon Toast if a Paragon Reward Quest is accepted.
	module.ShowToast = function(name, text)
		local toast = _G['CCS_TOAST']

		PlaySound(44295, 'master', true)

		if not toast:IsVisible() then
			toast:EnableMouse(false)
			toast.title:SetText(name)
			toast.title:SetAlpha(0)
			toast.description:SetText(text)
			toast.description:SetAlpha(0)
			C_Timer.After(1, function()
				UIFrameFadeIn(toast, 0.5, 0, 1)
			end)
			C_Timer.After(2, function()
				UIFrameFadeIn(toast.title, 0.5, 0, 1)
			end)
			C_Timer.After(2, function()
				UIFrameFadeIn(toast.description, 0.5, 0, 1)
			end)
			C_Timer.After(5, function()
				UIFrameFadeOut(toast, 1, 1, 0)
			end)
		end
	end

	module.getLocationLink = function(location)
		-- Return the item link for the specified 'location'.  If 'location' is
		-- null, return 'nil' instead.

		if location:IsEquipmentSlot() then
			return GetInventoryItemLink('player', location:GetEquipmentSlot())
		else
			return nil
		end
	end

	-- Get the name of the item frame (this is where we hook all of the text and icons)
	module.getSlotFrameName = function(location)
		if location:IsEquipmentSlot() then
			local slotIndex = location:GetEquipmentSlot()
			local slotName

			if slotIndex == 1 then
				slotName = 'Head'
			elseif slotIndex == 2 then
				slotName = 'Neck'
			elseif slotIndex == 3 then
				slotName = 'Shoulder'
			elseif slotIndex == 4 then
				slotName = 'Shirt'
			elseif slotIndex == 5 then
				slotName = 'Chest'
			elseif slotIndex == 6 then
				slotName = 'Waist'
			elseif slotIndex == 7 then
				slotName = 'Legs'
			elseif slotIndex == 8 then
				slotName = 'Feet'
			elseif slotIndex == 9 then
				slotName = 'Wrist'
			elseif slotIndex == 10 then
				slotName = 'Hands'
			elseif slotIndex == 11 then
				slotName = 'Finger0'
			elseif slotIndex == 12 then
				slotName = 'Finger1'
			elseif slotIndex == 13 then
				slotName = 'Trinket0'
			elseif slotIndex == 14 then
				slotName = 'Trinket1'
			elseif slotIndex == 15 then
				slotName = 'Back'
			elseif slotIndex == 16 then
				slotName = 'MainHand'
			elseif slotIndex == 17 then
				slotName = 'SecondaryHand'
			elseif slotIndex == 19 then
				slotName = 'Tabard'
			else
				return nil
			end

			return 'Character' .. slotName .. 'Slot'
		else
			return nil
		end
	end

	-- function to determine if an item needs text facing left or right
	-- Returns 1 if we want the text blocks on the right of the item
	module.eftitemdisplay = function(eslot)
		if eslot == 10 or eslot == 6 or eslot == 7 or eslot == 8 or eslot == 11 or eslot == 12 or eslot == 13 or eslot == 14 or eslot == 16 then
			return true
		end
		return false
	end

	-- Update a Specific Slot
	module.updateLocationInfo = function(slotIndex)
		local slotItem = ItemLocation:CreateFromEquipmentSlot(slotIndex) -- item "location"
		local link = module.getLocationLink(slotItem)
		local slotFrameName = module.getSlotFrameName(slotItem)
		-- local leftdisplay = module.leftitemdisplay(slotIndex)
		local SubElementSetPoint = 'LEFT'
		local SubElementSetPoint2 = 'RIGHT'
		local neg = 1

		-- if leftdisplay then
		-- 	SubElementSetPoint = 'RIGHT'
		-- 	SubElementSetPoint2 = 'LEFT'
		-- 	neg = -1
		-- end

		if slotFrameName == nil or slotIndex == 18 then
			return
		end

		-- Create the basic text and frame elements.
		local nameTxt = _G[slotFrameName .. 'namefs'] or _G[slotFrameName]:CreateFontString(slotFrameName .. 'namefs')
		local ilvlTxt = _G[slotFrameName .. 'ilvlfs'] or _G[slotFrameName]:CreateFontString(slotFrameName .. 'ilvlfs')
		local enchantTxt = _G[slotFrameName .. 'enchantfs'] or _G[slotFrameName]:CreateFontString(slotFrameName .. 'enchantfs')
		local bgfader = _G[slotFrameName .. 'bgfader'] or CreateFrame('Frame', slotFrameName .. 'bgfader', _G[slotFrameName])
		local gemIconframe1 = _G[slotFrameName .. 'gemtex1'] or CreateFrame('Button', slotFrameName .. 'gemtex1', _G[slotFrameName], 'UIPanelButtonTemplate')
		local gemIconframe2 = _G[slotFrameName .. 'gemtex2'] or CreateFrame('Button', slotFrameName .. 'gemtex2', _G[slotFrameName], 'UIPanelButtonTemplate')
		local gemIconframe3 = _G[slotFrameName .. 'gemtex3'] or CreateFrame('Button', slotFrameName .. 'gemtex3', _G[slotFrameName], 'UIPanelButtonTemplate')

		-- set text and icon frame locations and sizes
		-- Item Name Text
		nameTxt:SetPoint(SubElementSetPoint, _G[slotFrameName], SubElementSetPoint2, 10 * neg, 13)
		nameTxt:SetFont(Font, (c.fontsize_iname or 11), textoptions)

		-- Item Level Text
		ilvlTxt:SetPoint(SubElementSetPoint, _G[slotFrameName], SubElementSetPoint2, 10 * neg, 0)
		ilvlTxt:SetFont(Font, (c.fontsize_ilvl or 10), textoptions)

		-- Enchant Text
		enchantTxt:SetPoint(SubElementSetPoint, _G[slotFrameName], SubElementSetPoint2, 10 * neg, -13)
		enchantTxt:SetFont(Font, (c.fontsize_enchant or 10), textoptions)

		-- Shaded background Bar
		bgfader:SetSize(160, 37) -- fader size (scales with the character frame)
		bgfader:SetPoint(SubElementSetPoint, slotFrameName, SubElementSetPoint2, 0, 0)
		bgfader:SetFrameLevel(1)
		-- bgfadertex:SetAllPoints()
		-- bgfadertex:SetTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_AlphaGradient.tga')

		gemIconframe1:SetSize(Width, Height)
		gemIconframe1:SetPoint('TOP' .. SubElementSetPoint2, slotFrameName, 'TOP' .. SubElementSetPoint, -8 * neg, 6)
		gemIconframe1:SetFrameStrata('HIGH')

		gemIconframe2:SetSize(Width, Height)
		gemIconframe2:SetPoint(SubElementSetPoint2, slotFrameName, SubElementSetPoint, -8 * neg, 0)
		gemIconframe2:SetFrameStrata('HIGH')

		gemIconframe3:SetSize(Width, Height)
		gemIconframe3:SetPoint('BOTTOM' .. SubElementSetPoint2, slotFrameName, 'BOTTOM' .. SubElementSetPoint, -8 * neg, -6)
		gemIconframe3:SetFrameStrata('HIGH')

		-- Hide all elements by default (the code below will turn them on as needed)
		nameTxt:Hide()
		ilvlTxt:Hide()
		enchantTxt:Hide()
		gemIconframe1:Hide()
		gemIconframe2:Hide()
		gemIconframe3:Hide()
		bgfader:Hide()

		if slotItem == nil or link == nil then -- Determine if an item is in that slot  (if not, zeroize all of the text fields / icons, etc.)
			nameTxt:SetText('')
			ilvlTxt:SetText('')
			enchantTxt:SetText('')
		else -- Get Information for the Slot to populate information
			-- Populate Bgfader
			-- if c.showitemcolor then
			-- 	local setr, setg, setb, setalpha = c.setitemcolor[1], c.setitemcolor[2], c.setitemcolor[3], c.setitemcolor[4]
			-- 	if leftdisplay then
			-- 		bgfadertex:SetTexCoord(1, 0, 0, 1)
			-- 		if itemRarity == 1 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0, 0, 0, 0.2), CreateColor(1, 1, 1, 0.4)) -- white (Common)
			-- 		elseif itemRarity == 2 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0, 0, 0, 0.2), CreateColor(0.12, 1, 0, 0.4)) -- green (Uncommon)
			-- 		elseif itemRarity == 3 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0, 0, 0, 0.2), CreateColor(0, 0.44, 0.87, 0.4)) -- Blue (Rare)
			-- 		elseif itemRarity == 4 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0, 0, 0, 0.2), CreateColor(0.64, 0.21, 0.93, 0.4)) -- Purple (Epic)
			-- 		elseif itemRarity == 5 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0, 0, 0, 0.2), CreateColor(1, 0.5, 0, 0.4)) -- Orange (Legendary)
			-- 		elseif itemRarity == 6 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0, 0, 0, 0.2), CreateColor(0.9, 0.8, 0.5, 0.4)) -- Tan (Artifact)
			-- 		elseif itemRarity == 7 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0, 0, 0, 0.2), CreateColor(0, 0.8, 1, 0.4)) -- Light Blue (Heirloom)
			-- 		else
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0, 0, 0, 0.2), CreateColor(0.62, 0.62, 0.62, 0.4)) -- gray / poor
			-- 		end
			-- 		if c.showsetitems and setID then
			-- 			if c.showsetclasscolor then
			-- 				setr, setg, setb = GetClassColor(select(2, UnitClass('player')))
			-- 				setalpha = 0.8
			-- 			end
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0, 0, 0, 0.2), CreateColor(setr, setg, setb, setalpha)) -- Set Item Color Left Display
			-- 		end
			-- 	else
			-- 		if itemRarity == 1 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(1, 1, 1, 0.4), CreateColor(0, 0, 0, 0.2)) -- white (Common)
			-- 		elseif itemRarity == 2 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0.12, 1, 0, 0.4), CreateColor(0, 0, 0, 0.2)) -- green (Uncommon)
			-- 		elseif itemRarity == 3 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0, 0.44, 0.87, 0.4), CreateColor(0, 0, 0, 0.2)) -- Blue (Rare)
			-- 		elseif itemRarity == 4 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0.64, 0.21, 0.93, 0.4), CreateColor(0, 0, 0, 0.2)) -- Purple (Epic)
			-- 		elseif itemRarity == 5 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(1, 0.5, 0, 0.4), CreateColor(0, 0, 0, 0.2)) -- Orange (Legendary)
			-- 		elseif itemRarity == 6 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0.9, 0.8, 0.5, 0.4), CreateColor(0, 0, 0, 0.2)) -- Tan (Artifact)
			-- 		elseif itemRarity == 7 then
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0, 0.8, 1, 0.4), CreateColor(0, 0, 0, 0.2)) -- Light Blue (Heirloom)
			-- 		else
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(0.62, 0.62, 0.62, 0.4), CreateColor(0, 0, 0, 0.2)) -- gray / poor
			-- 		end
			-- 		if c.showsetitems and setID then
			-- 			if c.showsetclasscolor then
			-- 				setr, setg, setb = GetClassColor(select(2, UnitClass('player')))
			-- 				setalpha = 0.8
			-- 			end
			-- 			bgfadertex:SetGradient('Horizontal', CreateColor(setr, setg, setb, setalpha), CreateColor(0, 0, 0, 0.2)) -- Set Item Color Right Display
			-- 		end
			-- 	end
			-- 	bgfader:Show()
			-- end
			--Populate the fields we just created.
			local durCur, durMax = GetInventoryItemDurability(slotIndex) -- Get item durability
			local _, _, Color, _, _, _, Gem1, Gem2, Gem3, _, _, _, _, _, _ =
				string.find(link, '|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?')
			local itemName, _, itemRarity, itemiLevel, _, itemType, _, _, _, _, _, _, _, _, expacID, setID, _ = C_Item.GetItemInfo(link)
			local Gemtex1, Gemtex2, Gemtex3 = nil, nil, nil
			local ItemTip = _G['CCS_Scanningtooltip'] or CreateFrame('GameTooltip', 'CCS_Scanningtooltip', WorldFrame, 'GameTooltipTemplate')

			local EmptySocket = false
			local SocketCount = 0
			local Enchant = ''
			-- Parse Item Tooltip for information that cannot be easily obtained or to cross check for blizzard errors.
			ItemTip:SetOwner(WorldFrame, 'ANCHOR_NONE')
			ItemTip:ClearLines()
			_G['CCS_ScanningtooltipTexture1']:SetTexture(nil) -- Gem1
			_G['CCS_ScanningtooltipTexture2']:SetTexture(nil) -- Gem2
			_G['CCS_ScanningtooltipTexture3']:SetTexture(nil) -- Gem3
			ItemTip:SetHyperlink(link)

			for m = 1, ItemTip:NumLines() do
				local enchant = _G['CCS_ScanningtooltipTextLeft' .. m]:GetText():match(ENCHANTED_TOOLTIP_LINE:gsub('%%s', '(.+)'))
				local ilvl = _G['CCS_ScanningtooltipTextLeft' .. m]:GetText():match(ITEM_LEVEL:gsub('%%d', '(%%d+)'))
				local pvp_ilvl
				local emptysocket = _G['CCS_ScanningtooltipTextLeft' .. m]:GetText():match(EMPTY_SOCKET_PRISMATIC)

				if enchant then
					Enchant = enchant
				end
				if ilvl and (tonumber(ilvl) ~= tonumber(itemiLevel)) then
					itemiLevel = ilvl
				end

				if c.showpvpilvl then
					pvp_ilvl = _G['CCS_ScanningtooltipTextLeft' .. m]:GetText():match(PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '(%%d+)'))
					if pvp_ilvl and (tonumber(pvp_ilvl) ~= tonumber(itemiLevel)) then
						itemiLevel = itemiLevel .. ' (' .. PVP .. ' ' .. pvp_ilvl .. ')'
					end
				end

				if emptysocket then
					EmptySocket = true
					SocketCount = SocketCount + 1
				end
			end

			Gemtex1 = _G['CCS_ScanningtooltipTexture1']:GetTexture()
			Gemtex2 = _G['CCS_ScanningtooltipTexture2']:GetTexture()
			Gemtex3 = _G['CCS_ScanningtooltipTexture3']:GetTexture()

			-- Item name info (item name in white as well) [White or Rarity Color, 12]
			if c.showitemname == true then
				if c.itemcolorwhite then
					Color = 'ffffffff'
				end
				if itemName ~= nil then
					if string.len(Color) < 8 then
						Color = 'FF' .. Color
					end
					if strlen(itemName) > c.itemnamelength then
						itemName = format('%.' .. c.itemnamelength .. 's', itemName) .. '...'
					end
					nameTxt:SetText('|c' .. Color .. itemName .. '|r')
				end
				nameTxt:Show()
			end

			-- iLvl information [White]
			if c.showilvl == true then
				if itemiLevel ~= nil then
					ilvlTxt:SetText('|cFF' .. 'ffffff' .. itemiLevel .. '|r')
				end
				ilvlTxt:Show()
			end

			-- Enchant Info [Mint/Red, 10]  (Mint #2afab5)
			if c.showenchants == true then
				if Enchant ~= '' then
					Enchant = '|cFF2afab5' .. Enchant .. '|r'
				end

				if Enchant == '' and c.showenchantgemerrors == true then
					-- This is where we check to see if an enchant is missing from a slot.  I am leaving more code in here to allow me to check (later addition) whether it is a sub-standard enchant for each slot.
					if slotIndex == 1 then --  "Head" -
						Enchant = '|cFFFF0000<' .. ENSCRIBE .. ': ' .. ADDON_MISSING .. '>|r'
					elseif slotIndex == 2 then --  "Neck" !
					elseif slotIndex == 3 then --  "Shoulder"
					elseif slotIndex == 5 then --  "Chest" !
						Enchant = '|cFFFF0000<' .. ENSCRIBE .. ': ' .. ADDON_MISSING .. '>|r'
					elseif slotIndex == 6 then --  "Waist" -
						Enchant = '|cFFFF0000<' .. ENSCRIBE .. ': ' .. ADDON_MISSING .. '>|r'
					elseif slotIndex == 7 then --  "Legs" -
						Enchant = '|cFFFF0000<' .. ENSCRIBE .. ': ' .. ADDON_MISSING .. '>|r'
					elseif slotIndex == 8 then --  "Feet" !
						Enchant = '|cFFFF0000<' .. ENSCRIBE .. ': ' .. ADDON_MISSING .. '>|r'
					elseif slotIndex == 9 then --  "Wrist" !
						Enchant = '|cFFFF0000<' .. ENSCRIBE .. ': ' .. ADDON_MISSING .. '>|r'
					elseif slotIndex == 10 then --  "Hands" !
					elseif slotIndex == 11 then --  "Finger0" !
						Enchant = '|cFFFF0000<' .. ENSCRIBE .. ': ' .. ADDON_MISSING .. '>|r'
					elseif slotIndex == 12 then --  "Finger1" !
						Enchant = '|cFFFF0000<' .. ENSCRIBE .. ': ' .. ADDON_MISSING .. '>|r'
					elseif slotIndex == 15 then --  "Back" !
						Enchant = '|cFFFF0000<' .. ENSCRIBE .. ': ' .. ADDON_MISSING .. '>|r'
					elseif slotIndex == 16 then --  "MainHand" !
						Enchant = '|cFFFF0000<' .. ENSCRIBE .. ': ' .. ADDON_MISSING .. '>|r'
					elseif slotIndex == 17 and itemType == 'Weapon' then --  "SecondaryHand" -
						Enchant = '|cFFFF0000<' .. ENSCRIBE .. ': ' .. ADDON_MISSING .. '>|r'
					end
				end
				if strlen(Enchant) > 100 then
					Enchant = format('%.37s', Enchant) .. '...'
				end
				enchantTxt:SetText(Enchant)
				enchantTxt:Show()
			end

			-- Display Gem Info / missing
			if c.showgems == true then
				local tooltip, tooltip2, tooltip3 = '', '', ''
				local _, gem1Link = C_Item.GetItemGem(link, 1)
				local _, gem2Link = C_Item.GetItemGem(link, 2)
				local _, gem3Link = C_Item.GetItemGem(link, 3)
				local gemCount = 0

				if Gem1 ~= '' or Gemtex1 then
					gemCount = gemCount + 1
				end
				if Gem2 ~= '' or Gemtex2 then
					gemCount = gemCount + 1
				end
				if Gem3 ~= '' or Gemtex3 then
					gemCount = gemCount + 1
				end

				if slotIndex == 2 and expacID == LE_EXPANSION_DRAGONFLIGHT then
					gemCount = 3
				end

				if gemCount == 1 then
					gemIconframe1:ClearAllPoints()
					gemIconframe1:SetPoint(SubElementSetPoint2, slotFrameName, SubElementSetPoint, -8 * neg, 0)
				elseif gemCount == 2 then
					gemIconframe1:ClearAllPoints()
					gemIconframe2:ClearAllPoints()
					gemIconframe1:SetPoint('TOP' .. SubElementSetPoint2, slotFrameName, 'TOP' .. SubElementSetPoint, -8 * neg, -2)
					gemIconframe2:SetPoint('BOTTOM' .. SubElementSetPoint2, slotFrameName, 'BOTTOM' .. SubElementSetPoint, -8 * neg, 2)
				elseif gemCount == 3 then
					gemIconframe1:ClearAllPoints()
					gemIconframe2:ClearAllPoints()
					gemIconframe3:ClearAllPoints()
					gemIconframe2:ClearAllPoints()
					gemIconframe1:SetPoint('TOP' .. SubElementSetPoint2, slotFrameName, 'TOP' .. SubElementSetPoint, -8 * neg, 4)
					gemIconframe2:SetPoint(SubElementSetPoint2, slotFrameName, SubElementSetPoint, -8 * neg, 0)
					gemIconframe3:SetPoint('BOTTOM' .. SubElementSetPoint2, slotFrameName, 'BOTTOM' .. SubElementSetPoint, -8 * neg, -4)
				end

				local Gem1type, Gem2type, Gem3type = 0, 0, 0

				if Gem1 ~= '' then
					local icon = C_Item.GetItemIcon(Gem1)
					gemIconframe1:SetNormalTexture(icon)
					gemIconframe1:Show()
				elseif Gemtex1 then
					gemIconframe1:SetNormalTexture(Gemtex1)
					if GemInfo[Gemtex1] then
						tooltip = GemInfo[Gemtex1].text
					else
						tooltip = EMPTY_SOCKET_TINKER
					end
					gemIconframe1:Show()
				elseif slotIndex == 2 and expacID == LE_EXPANSION_DRAGONFLIGHT and c.showenchants then
					gemIconframe1:SetNormalTexture('Interface\\COMMON\\Indicator-Red.blp')
					tooltip = EMPTY_SOCKET_PRISMATIC .. ': ' .. ADDON_MISSING
					gemIconframe1:Show()
				end

				if Gem2 ~= '' then
					local icon = C_Item.GetItemIcon(Gem2)
					gemIconframe2:SetNormalTexture(icon)
					gemIconframe2:Show()
				elseif Gemtex2 then
					gemIconframe2:SetNormalTexture(Gemtex2)
					if GemInfo[Gemtex2] then
						tooltip2 = GemInfo[Gemtex2].text
					else
						tooltip2 = EMPTY_SOCKET_TINKER
					end
					gemIconframe2:Show()
				elseif slotIndex == 2 and expacID == LE_EXPANSION_DRAGONFLIGHT and c.showenchants then
					gemIconframe2:SetNormalTexture('Interface\\COMMON\\Indicator-Red.blp')
					tooltip2 = EMPTY_SOCKET_PRISMATIC .. ': ' .. ADDON_MISSING
					gemIconframe2:Show()
				end

				if Gem3 ~= '' then
					local icon = C_Item.GetItemIconByID(Gem3)
					gemIconframe3:SetNormalTexture(icon)
					gemIconframe3:Show()
				elseif Gemtex3 then
					gemIconframe3:SetNormalTexture(Gemtex3)
					if GemInfo[Gemtex3] then
						tooltip3 = GemInfo[Gemtex3].text
					else
						tooltip3 = EMPTY_SOCKET_TINKER
					end
					gemIconframe3:Show()
				elseif slotIndex == 2 and expacID == LE_EXPANSION_DRAGONFLIGHT and c.showenchants then
					gemIconframe3:SetNormalTexture('Interface\\COMMON\\Indicator-Red.blp')
					tooltip3 = EMPTY_SOCKET_PRISMATIC .. ': ' .. ADDON_MISSING
					gemIconframe3:Show()
				end

				gemIconframe1:SetScript('OnEnter', function()
					GameTooltip:SetOwner(UIParent, 'ANCHOR_CURSOR')
					if gem1Link then
						GameTooltip:SetHyperlink(gem1Link)
					else
						GameTooltip:AddDoubleLine(tooltip, '', 1, 1, 1, 1, 1, 1)
					end
					GameTooltip:Show()
				end)
				gemIconframe1:SetScript('OnLeave', function()
					GameTooltip:Hide()
				end)
				gemIconframe2:SetScript('OnEnter', function()
					GameTooltip:SetOwner(UIParent, 'ANCHOR_CURSOR')
					if gem2Link then
						GameTooltip:SetHyperlink(gem2Link)
					else
						GameTooltip:AddDoubleLine(tooltip2, '', 1, 1, 1, 1, 1, 1)
					end
					GameTooltip:Show()
				end)
				gemIconframe2:SetScript('OnLeave', function()
					GameTooltip:Hide()
				end)
				gemIconframe2:SetScript('OnClick', function() end)

				gemIconframe3:SetScript('OnEnter', function()
					GameTooltip:SetOwner(UIParent, 'ANCHOR_CURSOR')
					if gem3Link then
						GameTooltip:SetHyperlink(gem3Link)
					else
						GameTooltip:AddDoubleLine(tooltip3, '', 1, 1, 1, 1, 1, 1)
					end
					GameTooltip:Show()
				end)
				gemIconframe3:SetScript('OnLeave', function()
					GameTooltip:Hide()
				end)
				gemIconframe3:SetScript('OnClick', function() end)
			end
		end
	end

	-- Loop through the Paperdoll Items and create/display information
	module.loopitems = function()
		if not InCombatLockdown() then
			for slotIndex = 1, 19 do
				module.updateLocationInfo(slotIndex)
			end
		end
	end

	-----------------------------------------------------------------
	local LOOT_SPECIALIZATION_DEFAULT = LOOT_SPECIALIZATION_DEFAULT
	local SELECT_LOOT_SPECIALIZATION = SELECT_LOOT_SPECIALIZATION
	local _G = _G
	local nukeit = charsheet.config.nukeit

	module.sortAndOffset = function()
		-- initialize button spacing.
		local spacing = 3
		local Width = region:GetWidth()
		local Height = region:GetHeight()
		local xDistance = Width + spacing
		local textoptions = charsheet.config.textoutline

		if textoptions == 1 then
			textoptions = ''
		elseif textoptions == 2 then
			textoptions = 'OUTLINE'
		elseif textoptions == 3 then
			textoptions = 'THICKOUTLINE'
		end

		if c.showlootspec and not nukeit then
			local specIndex = GetLootSpecialization() or 0 -- current loot spec
			local aid, aname, _, aicon = GetSpecializationInfo(GetSpecialization()) -- info for current spec

			for count = 0, 4, 1 do -- count up to 4 (0 for loot spec based on current spec and 4 more since druids have 4 specs)
				local id, name, _, icon = GetSpecializationInfo(count) -- spec info for the loop
				local link = nil -- this is placeholder for other weakauras
				local spellid = nil -- this is placeholder for other weakauras
				local description = '' -- this is placeholder for other weakauras
				local xOffset = (90 * charsheet.config.hpad / 262) + 135 + (xDistance * count)
				local yOffset = 5
				local btn = _G[module.id .. 'Btn' .. count]
				local FirstBtn = false -- use firstbtn to deal with titles/headers

				if count == 0 then
					name = string.format(LOOT_SPECIALIZATION_DEFAULT, aname or '*')
					id = aid
					icon = aicon
					FirstBtn = true
				end

				if id then
					-- begin clickable button frame

					if btn == nil then
						btn = CreateFrame('Button', module.id .. 'Btn' .. count, region, 'UIPanelButtonTemplate')
					end

					btn:SetSize(Width, Height)
					btn:SetPoint('BOTTOMLEFT', PaperDollItemsFrame, 'BOTTOMLEFT', xOffset, yOffset)
					btn:SetNormalTexture(icon)
					btn:SetFrameStrata('HIGH')

					local btnfont1 = _G[btn:GetName() .. 'fs1']
					local btnfont2 = _G[btn:GetName() .. 'fs2']

					if FirstBtn == true and btnfont1 == nil then
						btnfont1 = btn:CreateFontString(btn:GetName() .. 'fs1')
						btnfont1:SetPoint('CENTER', 0, 0)
						btnfont1:SetFont(LSM:Fetch('font', charsheet.subRegions[2].text_font), 16, textoptions)
						btnfont1:SetText('**')
					end

					if FirstBtn == true and btnfont2 == nil then
						btnfont2 = btn:CreateFontString(btn:GetName() .. 'fs2')
						btnfont2:SetPoint('BOTTOMLEFT', btn, 'TOPLEFT', 0, 3)
						btnfont2:SetFont(LSM:Fetch('font', charsheet.subRegions[2].text_font), (c.fontsize_lootspec or 10), textoptions)
						btnfont2:SetText(SELECT_LOOT_SPECIALIZATION)
					end

					local btntex = _G[btn:GetName() .. 'tex']
					if btntex == nil then
						btntex = btn:CreateTexture(btn:GetName() .. 'tex', 'OVERLAY')
					end

					btntex:SetAllPoints(btn)
					region:Show()
					btn:Show()
					btntex:Show()

					if specIndex == 0 and count == 0 then
						btntex:SetTexture('Interface\\ContainerFrame\\UI-Icon-QuestBorder.blp')
					elseif id == specIndex and count > 0 then
						btntex:SetTexture('Interface\\ContainerFrame\\UI-Icon-QuestBorder.blp')
					else
						btntex:SetColorTexture(0, 0, 0, 0.65)
					end

					btn:SetScript('OnEnter', function()
						GameTooltip:SetOwner(UIParent, 'ANCHOR_CURSOR')
						if link then
							GameTooltip:SetHyperlink(link)
						else
							GameTooltip:AddDoubleLine(name, spellid, 1, 1, 1, 1, 1, 1)
							GameTooltip:AddLine(description, nil, nil, nil, true)
						end
						GameTooltip:Show()
					end)
					btn:SetScript('OnLeave', function()
						GameTooltip:Hide()
					end)

					btn:SetScript('OnClick', function()
						-- Add specific functionality when clicking the button
						if count == 0 and specIndex ~= 0 then
							SetLootSpecialization(0)
						elseif id ~= specIndex then
							SetLootSpecialization(id)
						end
						PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK) -- just puts a sound in when clicking on the button for more feedback
					end)
				end
				-- end clickable button frame
			end
		end
	end

	if not module.WA_LOOTSPEC_SETUP then
		module.WA_LOOTSPEC_SETUP = true
	end

	--------------------------------------------------------------------------

	-- -- Create the main button
	-- btn:SetSize(Width, Height)
	-- btn:SetPoint('BOTTOMLEFT', PaperDollItemsFrame, 'BOTTOMLEFT', xOffset, yOffset)
	-- btn:SetFrameStrata('HIGH')
	-- btn:Show()

	-- -- Create the title text
	-- local btnfont1 = _G[btn:GetName() .. 'fs1'] or btn:CreateFontString(btn:GetName() .. 'fs1')

	-- btnfont1:SetPoint('BOTTOM', btn, 'TOP', -3, 2)
	-- btnfont1:SetFont(LSM:Fetch('font', charsheet.subRegions[2].text_font), (c.fontsize_showchar or 10), 'OUTLINE')
	-- btnfont1:SetText(textstring)
	-- btnfont1:SetWordWrap(true)
	-- btn:SetNormalTexture(texture)

	-- -- Create the Weekly Chest button

	-- texture = 'Interface\\Worldmap\\TreasureChest_64.blp'
	-- textstring = REWARDS

	-- btn2:SetSize(Width + 5, Height + 5)
	-- btn2:SetPoint('BOTTOMLEFT', PaperDollItemsFrame, 'BOTTOMLEFT', xOffset2 + 25, yOffset - 3)

	-- btn2:SetFrameStrata('HIGH')
	-- btn2:Show()

	-- -- Create the Talents title text
	-- local btn2font1 = _G[btn2:GetName() .. 'fs1'] or btn2:CreateFontString(btn2:GetName() .. 'fs1')
	-- btn2font1:SetPoint('BOTTOM', btn2, 'TOP', 0, 0)

	-- btn2font1:SetFont(LSM:Fetch('font', charsheet.subRegions[2].text_font), (c.fontsize_showchar or 10), 'THICKOUTLINE')
	-- btn2font1:SetText(textstring)
	-- btn2:SetNormalTexture(texture)

	module.MoveModelRight = function()
		CharacterModelScene:ClearAllPoints()
		modelregion:ClearAllPoints()
		CharacterModelScene:SetHeight(CharacterFrame:GetHeight())
		CharacterModelScene:SetWidth(CharacterFrame:GetHeight() / ModelAspect)
		CharacterModelScene:SetPoint('LEFT', CharacterFrameBg, 'RIGHT', 0, 0)
		CharacterModelScene:Show()
		CharacterModelFrameBackgroundTopLeft:Hide()
		CharacterModelFrameBackgroundBotLeft:Hide()
		CharacterModelFrameBackgroundTopRight:Hide()
		CharacterModelFrameBackgroundBotRight:Hide()
		CharacterModelFrameBackgroundOverlay:ClearAllPoints()
		CharacterModelFrameBackgroundOverlay:SetPoint('TOPLEFT', CharacterModelFrameBackgroundTopLeft, 'TOPLEFT', 0, 0)
		CharacterModelFrameBackgroundOverlay:SetPoint('BOTTOMRIGHT', CharacterModelFrameBackgroundBotRight, 'BOTTOMRIGHT', 0, 70)
		CharacterModelFrameBackgroundOverlay:Hide()
		modelregion:SetSize(CharacterModelScene:GetWidth(), CharacterModelScene:GetHeight())
		modelregion:SetAllPoints(CharacterModelScene)
	end

	module.MoveModelLeft = function()
		local Width = 288 + charsheet.config.hpad -- Hard code it for now
		local Height = 359 + (7 * charsheet.config.vpad) -- Hard code it for now
		local Left = 120 -- Hard code it for now
		modelregion:ClearAllPoints()
		CharacterModelScene:ClearAllPoints()
		CharacterModelScene:SetHeight(Height)
		CharacterModelScene:SetWidth(Height / ModelAspect)
		CharacterModelScene:SetPoint('CENTER', CharacterFrameInset, 'CENTER', 0, 0)
		CharacterModelScene:SetFrameLevel(2)
		CharacterModelScene:Show()
		CharacterModelFrameBackgroundTopLeft:Hide()
		CharacterModelFrameBackgroundBotLeft:Hide()
		CharacterModelFrameBackgroundTopRight:Hide()
		CharacterModelFrameBackgroundBotRight:Hide()
		CharacterModelFrameBackgroundOverlay:ClearAllPoints()
		CharacterModelFrameBackgroundOverlay:SetPoint('TOPLEFT', CharacterModelFrameBackgroundTopLeft, 'TOPLEFT', 0, 0)
		CharacterModelFrameBackgroundOverlay:SetPoint('BOTTOMRIGHT', CharacterModelFrameBackgroundBotRight, 'BOTTOMRIGHT', 0, 70)
		CharacterModelFrameBackgroundOverlay:Hide()
		modelregion:SetSize(Width, CharacterModelScene:GetHeight())
		modelregion:SetPoint('TOPLEFT', CharacterHeadSlot, 'TOPLEFT')
	end

	module.Clicky = function(endstate)
		if endstate == 1 then -- Model code
			if _G['CCSf'] then
				_G['CCSf']:Hide()
			end
			if _G['ccs_sf'] then
				_G['ccs_sf']:Hide()
			end
			if _G['ccsm_sf'] then
				_G['ccsm_sf']:Hide()
			end
			HideUIPanel(MajorFactionRenownFrame)
			WeeklyRewardsFrame:Hide()
			if CharacterModelScene:GetHeight() > 600 then -- This is to move model under the character equipment
				module.MoveModelLeft()
				if _G['ccsm_sf'] and mplussheet and mplussheet.config and (mplussheet.config.showm_sp == true) and (UnitLevel('player') == GetMaxLevelForLatestExpansion()) then
					_G['ccsm_sf']:Show()
				elseif _G['ccsm_sf'] then
					_G['ccsm_sf']:Hide()
				end
			else -- This is to move the model to the right of the character frame.
				module.MoveModelRight()
			end
		end

		if endstate == 2 then -- Subpanel code
			module.MoveModelLeft()

			if _G['CCSf']:IsVisible() then
				if _G['CCSf'] then
					_G['CCSf']:Hide()
				end
				if _G['ccs_sf'] then
					_G['ccs_sf']:Hide()
				end

				HideUIPanel(MajorFactionRenownFrame)
				HideUIPanel(GenericTraitFrame)
				WeeklyRewardsFrame:Hide()
				if _G['ccsm_sf'] and mplussheet and mplussheet.config and (mplussheet.config.showm_sp == true) and (UnitLevel('player') == GetMaxLevelForLatestExpansion()) then
					_G['ccsm_sf']:Show()
				elseif _G['ccsm_sf'] then
					_G['ccsm_sf']:Hide()
				end
			else
				if _G['CCSf'] then
					_G['CCSf']:Show()
				end
				if _G['ccs_sf'] then
					_G['ccs_sf']:Show()
				end
				if _G['ccsm_sf'] then
					_G['ccsm_sf']:Hide()
				end
				WeeklyRewardsFrame:Show()
				MajorFactionRenownFrame:Hide()
				_G['ccs_sf_btn3']:Hide()
				_G['ccs_sf_btn4']:Hide()
				_G['ccs_sf_btn5']:Hide()
				_G['ccs_sf_btn6']:Hide()
				_G['ccs_sf_btn7']:Hide()
				_G['ccs_sf_btn8']:Hide()

				if C_WeeklyRewards.HasAvailableRewards() then
					WeeklyRewardsFrame:SetScale(0.77)
					WeeklyRewardsFrame.Overlay:Hide()
					WeeklyRewardsFrame.Overlay:SetFrameStrata('BACKGROUND')
					C_Timer.NewTicker(0.3, function()
						WeeklyRewardsFrame.Overlay:Hide()
					end, 1)
					WeeklyRewardsFrame.Blackout:Hide()
				end
				ccs_sf_bg:Show()
			end
		end

		PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK) -- just puts a sound in when clicking on the button for more feedback
	end

	btn:SetScript('OnEnter', function()
		GameTooltip:SetOwner(UIParent, 'ANCHOR_CURSOR')
		GameTooltip:AddDoubleLine('', nil, 1, 1, 1, 1, 1, 1)
		GameTooltip:Show()
	end)
	btn:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)
	btn:SetScript('OnClick', function()
		module.Clicky(1)
	end)

	btn2:SetScript('OnEnter', function()
		GameTooltip:SetOwner(UIParent, 'ANCHOR_CURSOR')
		GameTooltip:AddDoubleLine('', nil, 1, 1, 1, 1, 1, 1)
		GameTooltip:Show()
	end)
	btn2:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)
	btn2:SetScript('OnClick', function()
		module.Clicky(2)
	end)
end
