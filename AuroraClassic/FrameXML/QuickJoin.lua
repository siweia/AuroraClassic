local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	if C.isNewPatch then
		F.ReskinScroll(QuickJoinScrollFrame.scrollBar)
	else
		F.ReskinScroll(QuickJoinScrollFrameScrollBar)
	end
	F.Reskin(QuickJoinFrame.JoinQueueButton)

	F.CreateBD(QuickJoinRoleSelectionFrame)
	F.CreateSD(QuickJoinRoleSelectionFrame)
	F.Reskin(QuickJoinRoleSelectionFrame.AcceptButton)
	F.Reskin(QuickJoinRoleSelectionFrame.CancelButton)
	F.ReskinClose(QuickJoinRoleSelectionFrame.CloseButton)
	F.StripTextures(QuickJoinRoleSelectionFrame)

	F.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonTank, "TANK")
	F.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonHealer, "HEALER")
	F.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonDPS, "DPS")
end)