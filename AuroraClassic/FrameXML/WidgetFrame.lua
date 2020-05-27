local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	-- Credits ShestakUI
	local atlasColors = {
		["UI-Frame-Bar-Fill-Blue"] = {.2, .6, 1},
		["UI-Frame-Bar-Fill-Red"] = {.9, .2, .2},
		["UI-Frame-Bar-Fill-Yellow"] = {1, .6, 0},
		["objectivewidget-bar-fill-left"] = {.2, .6, 1},
		["objectivewidget-bar-fill-right"] = {.9, .2, .2}
	}

	local function updateBarTexture(self, atlas)
		if atlasColors[atlas] then
			self:SetStatusBarTexture(C.media.backdrop)
			self:SetStatusBarColor(unpack(atlasColors[atlas]))
		end
	end

	local doubleBarType = _G.Enum.UIWidgetVisualizationType.DoubleStatusBar
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
	frame:SetScript("OnEvent", function()
		for _, widgetFrame in pairs(_G.UIWidgetTopCenterContainerFrame.widgetFrames) do
			if widgetFrame.widgetType == doubleBarType then
				for _, bar in pairs({widgetFrame.LeftBar, widgetFrame.RightBar}) do
					if not bar.styled then
						bar.BG:SetAlpha(0)
						bar.BorderLeft:SetAlpha(0)
						bar.BorderRight:SetAlpha(0)
						bar.BorderCenter:SetAlpha(0)
						bar.Spark:SetAlpha(0)
						bar.SparkGlow:SetAlpha(0)
						bar.BorderGlow:SetAlpha(0)
						F.SetBD(bar)
						hooksecurefunc(bar, "SetStatusBarAtlas", updateBarTexture)

						bar.styled = true
					end
				end
			end
		end
	end)

	hooksecurefunc(_G.UIWidgetTemplateCaptureBarMixin, "Setup", function(self)
		self.LeftLine:SetAlpha(0)
		self.RightLine:SetAlpha(0)
		self.BarBackground:SetAlpha(0)
		self.Glow1:SetAlpha(0)
		self.Glow2:SetAlpha(0)
		self.Glow3:SetAlpha(0)

		self.LeftBar:SetTexture(C.media.backdrop)
		self.NeutralBar:SetTexture(C.media.backdrop)
		self.RightBar:SetTexture(C.media.backdrop)

		self.LeftBar:SetVertexColor(.2, .6, 1)
		self.NeutralBar:SetVertexColor(.8, .8, .8)
		self.RightBar:SetVertexColor(.9, .2, .2)

		if not self.bg then
			self.bg = F.SetBD(self)
			self.bg:Point("TOPLEFT", self.LeftBar, -2, 2)
			self.bg:Point("BOTTOMRIGHT", self.RightBar, 2, -2)
		end
	end)

	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, "Setup", function(self)
		local bar = self.Bar
		local atlas = bar:GetStatusBarAtlas()
		updateBarTexture(bar, atlas)

		if not bar.styled then
			bar.BGLeft:SetAlpha(0)
			bar.BGRight:SetAlpha(0)
			bar.BGCenter:SetAlpha(0)
			bar.BorderLeft:SetAlpha(0)
			bar.BorderRight:SetAlpha(0)
			bar.BorderCenter:SetAlpha(0)
			bar.Spark:SetAlpha(0)
			F.CreateBDFrame(bar, .25)

			bar.styled = true
		end
	end)

	hooksecurefunc(_G.UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin, "Setup", function(self)
		self.Frame:SetAlpha(0)
	end)

	hooksecurefunc(_G.UIWidgetTemplateSpellDisplayMixin, "Setup", function(self)
		local spellFrame = self.Spell

		if spellFrame and not spellFrame.styled then
			spellFrame.DebuffBorder:SetTexture(nil)
			F.ReskinIcon(spellFrame.Icon)

			spellFrame.styled = true
		end
	end)
end)