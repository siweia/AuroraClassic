local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinActionButton(button)
	if button.__auroraPetBattleStyled then return end

	button:GetNormalTexture():SetAlpha(0)
	button:GetPushedTexture():SetTexture(DB.pushedTex)
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	B.ReskinIcon(button.Icon)

	button.__auroraPetBattleStyled = true
end

local function reskinActionButtons(frame)
	for _, button in ipairs(frame.BottomFrame.abilityButtons) do
		reskinActionButton(button)
	end
end

local function reskinAuras(holder)
	for _, aura in ipairs(holder.frames) do
		if not aura.__auroraPetBattleStyled then
			B.ReskinIcon(aura.Icon)
			aura.__auroraPetBattleStyled = true
		end
	end
end

tinsert(C.defaultThemes, function()
	if not AuroraClassicDB.PetBattle then return end

	local frame = PetBattleFrame
	local bottom = frame.BottomFrame

	frame.TopArtLeft:SetAlpha(0)
	B.SetBD(frame.TopArtLeft)
	frame.TopArtRight:SetAlpha(0)
	B.SetBD(frame.TopArtRight)
	frame.TopVersus:SetAlpha(0)
	B.ReskinIcon(frame.WeatherFrame.Icon)

	-- Native display updates own portrait mirroring and all status borders.
	local units = {
		frame.ActiveAlly, frame.ActiveEnemy,
		frame.Ally2, frame.Ally3, frame.Enemy2, frame.Enemy3,
		bottom.PetSelectionFrame.Pet1,
		bottom.PetSelectionFrame.Pet2,
		bottom.PetSelectionFrame.Pet3,
	}
	for _, unit in ipairs(units) do
		B.CreateBDFrame(unit.Icon, .25)
		unit.ActualHealthBar:SetTexture(DB.normTex)
		unit.HealthBarBG:SetColorTexture(0, 0, 0, .5)
		if unit.HealthDivider then
			unit.HealthDivider:SetColorTexture(0, 0, 0)
		end
	end

	for _, unit in ipairs({frame.ActiveAlly, frame.ActiveEnemy}) do
		unit.HealthBarFrame:SetAlpha(0)
		B.CreateBDFrame(unit.HealthBarBG, .25)
	end

	for i = 1, 3 do
		local unit = bottom.PetSelectionFrame["Pet"..i]
		unit.Framing:SetAlpha(0)
		B.SetBD(unit.Framing)
	end

	bottom.LeftEndCap:SetAlpha(0)
	bottom.RightEndCap:SetAlpha(0)
	bottom.Background:SetAlpha(0)
	B.SetBD(bottom.Background)
	B.StripTextures(bottom.FlowFrame)
	B.StripTextures(bottom.Delimiter)
	B.StripTextures(bottom.MicroButtonFrame)

	for _, button in ipairs({bottom.SwitchPetButton, bottom.CatchButton, bottom.ForfeitButton}) do
		reskinActionButton(button)
	end
	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", reskinActionButtons)
	reskinActionButtons(frame)

	-- Keep native timer visibility, fill UVs, text and the pass-button layout.
	local timer = bottom.TurnTimer
	timer.TimerBG:SetColorTexture(0, 0, 0, AuroraClassicDB.Alpha)
	timer.ArtFrame:SetVertexColor(0, 0, 0)
	timer.ArtFrame2:SetVertexColor(0, 0, 0)
	B.Reskin(timer.SkipButton)

	local xp = bottom.xpBar
	local xpName = xp:GetName()
	_G[xpName.."Left"]:SetAlpha(0)
	_G[xpName.."Right"]:SetAlpha(0)
	_G[xpName.."Middle"]:SetAlpha(0)
	xp:SetStatusBarTexture(DB.normTex)
	B.SetBD(xp)
	for i = 1, 6 do
		_G["PetBattleXPBarDiv"..i]:SetVertexColor(0, 0, 0)
	end

	-- Skin only widgets already created by Blizzard; retain DebuffBorder state.
	hooksecurefunc("PetBattleAuraHolder_Update", reskinAuras)
	for _, holder in ipairs({
		frame.AllyBuffFrame, frame.AllyDebuffFrame,
		frame.EnemyBuffFrame, frame.EnemyDebuffFrame,
		frame.AllyPadBuffFrame, frame.AllyPadDebuffFrame,
		frame.EnemyPadBuffFrame, frame.EnemyPadDebuffFrame,
	}) do
		reskinAuras(holder)
	end
end)
