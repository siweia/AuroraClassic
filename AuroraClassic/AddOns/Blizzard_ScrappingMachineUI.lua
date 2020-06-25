local F, C = unpack(select(2, ...))

C.themes["Blizzard_ScrappingMachineUI"] = function()
	F.ReskinPortraitFrame(ScrappingMachineFrame)
	F.Reskin(ScrappingMachineFrame.ScrapButton)

	local ItemSlots = ScrappingMachineFrame.ItemSlots
	F.StripTextures(ItemSlots)

	for button in pairs(ItemSlots.scrapButtons.activeObjects) do
		F.StripTextures(button)
		button.IconBorder:SetAlpha(0)
		button.Icon:SetTexCoord(.08, .92, .08, .92)
		button.bg = F.CreateBDFrame(button.Icon, .25)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints(button.Icon)
		F.HookIconBorderColor(button.IconBorder)
	end
end