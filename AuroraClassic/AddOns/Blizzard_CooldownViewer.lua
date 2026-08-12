local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

-- SideTabs
local function reskinSideTab(tab)
	if not tab then return end

	B.StripTextures(tab, 2)
	tab.bg = B.SetBD(tab)
	tab.bg:SetInside(nil, 2, 2)
	local hl = tab:CreateTexture(nil, "HIGHLIGHT")
	hl:SetColorTexture(1, 1, 1, .25)
	hl:SetInside(tab.bg)

	tab.SelectedTexture:SetDrawLayer("BACKGROUND")
	tab.SelectedTexture:SetColorTexture(cr, cg, cb, .25)
	tab.SelectedTexture:SetInside(tab.bg)
end

-- Collapse buttons
local oldAtlas = {
	["Options_ListExpand_Right"] = 1,
	["Options_ListExpand_Right_Expanded"] = 2,
}
local function updateCollapse(texture, atlas)
	if oldAtlas[atlas] == 1 then
		texture:SetAtlas("Soulbinds_Collection_CategoryHeader_Expand")
	elseif oldAtlas[atlas] == 2 then
		texture:SetAtlas("Soulbinds_Collection_CategoryHeader_Collapse")
	end
end

local function updateButtons(frame)
	for button in frame.itemPool:EnumerateActive() do
		if not button.styled then
			B.ReskinIcon(button.Icon)
			button.Highlight:SetColorTexture(1, 1, 1, .25)
			button.styled = true
		end
	end

	local header = frame.Header
	if header and not header.styled then
		B.StripTextures(header)

		if header.Right then
			B.StripTextures(header)
			hooksecurefunc(header.Right, "SetAtlas", updateCollapse)
			hooksecurefunc(header.HighlightRight, "SetAtlas", updateCollapse)
			updateCollapse(header.Right)
			updateCollapse(header.HighlightRight)
			B.CreateBDFrame(header, .25):SetInside(nil, 2, 2)
		end
		header.styled = true
	end
end

C.themes["Blizzard_CooldownViewer"] = function()
	local frame = CooldownViewerSettings
	if frame then
		B.ReskinPortraitFrame(frame)
		B.ReskinEditBox(frame.SearchBox)
		B.ReskinTrimScroll(frame.CooldownScroll.ScrollBar)
		B.ReskinDropDown(frame.LayoutDropdown)
		B.Reskin(frame.UndoButton)

		-- Side tabs
		for _, tab in ipairs(frame.TabButtons) do
			reskinSideTab(tab)
		end

		hooksecurefunc(frame, "RefreshLayout", function(self)
			for categoryDisplay in self.categoryPool:EnumerateActive() do
				if not categoryDisplay.styled then
					updateButtons(categoryDisplay)
					hooksecurefunc(categoryDisplay, "RefreshLayout", updateButtons)
					categoryDisplay.styled = true
				end
			end
		end)
	end

	if not AuroraClassicDB.CooldownMgr then return end

	-- Keep DebuffBorder Blizzard-owned; its aura/dispel state may be restricted.
	local function reskinCooldownItem(self)
		for itemFrame in self.itemFramePool:EnumerateActive() do
			if itemFrame.Bar then
				if not itemFrame.styled then
					local iconFrame = itemFrame.Icon
					if iconFrame then
						local icon, mask, overlay = iconFrame:GetRegions()
						mask:Hide()
						overlay:Hide()
						iconFrame.bg = B.ReskinIcon(icon, true)
						icon:SetInside(iconFrame, 5, 5)
					end

					local barFrame = itemFrame.Bar
					if barFrame then
						B.StripTextures(barFrame)
						barFrame.BarBG:SetAlpha(0)
						barFrame:SetStatusBarTexture(DB.normTex)
						B.SetBD(barFrame)
						barFrame:GetStatusBarTexture():ClearTextureSlice()
					end

					itemFrame.styled = true
				end
			elseif itemFrame.Icon then
				if not itemFrame.styled then
					local icon, mask, overlay = itemFrame:GetRegions()
					mask:Hide()
					overlay:Hide()
					icon.bg = B.ReskinIcon(icon, true)
					icon:SetInside(itemFrame, 2, 2)

					local cooldown = itemFrame.Cooldown
					if cooldown then
						cooldown:SetInside(icon.bg)
						cooldown:SetDrawEdge(false)
						cooldown:SetDrawSwipe(true)
						cooldown:SetSwipeTexture(DB.bdTex)
					end

					local outOfRange = itemFrame.OutOfRange
					if outOfRange then
						outOfRange:SetInside(icon.bg)
						outOfRange:SetColorTexture(.8, .1, .1, .25)
					end

					itemFrame.styled = true
				end
			end
		end
	end
	hooksecurefunc(UtilityCooldownViewer, "RefreshLayout", reskinCooldownItem)
	hooksecurefunc(EssentialCooldownViewer, "RefreshLayout", reskinCooldownItem)
	hooksecurefunc(BuffIconCooldownViewer, "RefreshLayout", reskinCooldownItem)
	hooksecurefunc(BuffBarCooldownViewer, "RefreshLayout", reskinCooldownItem)
end
