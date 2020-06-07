local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	F.ReskinPortraitFrame(MerchantFrame)
	F.ReskinDropDown(MerchantFrameLootFilter)
	F.StripTextures(MerchantPrevPageButton)
	F.ReskinArrow(MerchantPrevPageButton, "left")
	F.StripTextures(MerchantNextPageButton)
	F.ReskinArrow(MerchantNextPageButton, "right")
	MerchantMoneyInset:Hide()
	MerchantMoneyBg:Hide()
	MerchantNameText:SetDrawLayer("ARTWORK")
	MerchantExtraCurrencyBg:SetAlpha(0)
	MerchantExtraCurrencyInset:SetAlpha(0)
	BuybackBG:SetAlpha(0)

	MerchantFrameTab1:ClearAllPoints()
	MerchantFrameTab1:SetPoint("CENTER", MerchantFrame, "BOTTOMLEFT", 50, -14)
	MerchantFrameTab2:SetPoint("LEFT", MerchantFrameTab1, "RIGHT", -15, 0)

	for i = 1, 2 do
		F.ReskinTab(_G["MerchantFrameTab"..i])
	end

	for i = 1, BUYBACK_ITEMS_PER_PAGE do
		local item = _G["MerchantItem"..i]
		local name = item.Name
		local button = item.ItemButton
		local icon = button.icon
		local moneyFrame = _G["MerchantItem"..i.."MoneyFrame"]

		F.StripTextures(item)
		F.CreateBDFrame(item, .25)

		F.StripTextures(button)
		button.IconBorder:SetAlpha(0)
		button:ClearAllPoints()
		button:SetPoint("LEFT", item, 4, 0)
		local hl = button:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside()

		F.ReskinIcon(icon)
		icon:SetInside()
		name:SetFontObject(Number12Font)
		name:SetPoint("LEFT", button, "RIGHT", 2, 9)

		moneyFrame:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)
		for j = 1, 3 do
			local currency = _G["MerchantItem"..i.."AltCurrencyFrameItem"..j]
			local texture = _G["MerchantItem"..i.."AltCurrencyFrameItem"..j.."Texture"]
			currency:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)
			F.ReskinIcon(texture)
		end
	end

	MerchantBuyBackItemSlotTexture:SetAlpha(0)
	MerchantBuyBackItemNameFrame:Hide()
	MerchantBuyBackItemItemButton:SetNormalTexture("")
	MerchantBuyBackItemItemButton:SetPushedTexture("")
	MerchantBuyBackItemItemButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	MerchantBuyBackItemItemButton:GetHighlightTexture():SetAllPoints(MerchantBuyBackItemItemButtonIconTexture)
	MerchantBuyBackItemItemButton.IconBorder:SetAlpha(0)

	F.CreateBD(MerchantBuyBackItemItemButton, 0)
	F.CreateBD(MerchantBuyBackItem, .25)

	MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
	MerchantBuyBackItemItemButtonIconTexture:SetInside()

	MerchantBuyBackItemName:SetHeight(25)
	MerchantBuyBackItemName:ClearAllPoints()
	MerchantBuyBackItemName:SetPoint("LEFT", MerchantBuyBackItemSlotTexture, "RIGHT", -5, 8)

	local function reskinMerchantInteract(button)
		button:SetPushedTexture("")
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		F.CreateBDFrame(button)
	end

	reskinMerchantInteract(MerchantGuildBankRepairButton)
	MerchantGuildBankRepairButtonIcon:SetTexCoord(.595, .8075, .05, .52)

	reskinMerchantInteract(MerchantRepairAllButton)
	MerchantRepairAllIcon:SetTexCoord(.31375, .53, .06, .52)

	reskinMerchantInteract(MerchantRepairItemButton)
	local ic = MerchantRepairItemButton:GetRegions()
	ic:SetTexture("Interface\\Icons\\INV_Hammer_20")
	ic:SetTexCoord(.08, .92, .08, .92)

	hooksecurefunc("MerchantFrame_UpdateCurrencies", function()
		for i = 1, MAX_MERCHANT_CURRENCIES do
			local bu = _G["MerchantToken"..i]
			if bu and not bu.styled then
				local icon = _G["MerchantToken"..i.."Icon"]
				local count = _G["MerchantToken"..i.."Count"]
				count:SetPoint("TOPLEFT", bu, "TOPLEFT", -2, 0)
				F.ReskinIcon(icon)

				bu.styled = true
			end
		end
	end)

	hooksecurefunc("MerchantFrame_UpdateRepairButtons", function()
		if CanGuildBankRepair() then
			MerchantRepairText:SetPoint("CENTER", MerchantFrame, "BOTTOMLEFT", 65, 73)
		end
	end)
end)