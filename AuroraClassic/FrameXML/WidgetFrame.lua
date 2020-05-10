local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	-- Credits ShestakUI
    hooksecurefunc(_G.UIWidgetTemplateCaptureBarMixin, "Setup", function(widgetInfo)
        widgetInfo.LeftLine:SetAlpha(0)
        widgetInfo.RightLine:SetAlpha(0)
        widgetInfo.BarBackground:SetAlpha(0)
        widgetInfo.Glow1:SetAlpha(0)
        widgetInfo.Glow2:SetAlpha(0)
        widgetInfo.Glow3:SetAlpha(0)

        widgetInfo.LeftBar:SetTexture(C.media.backdrop)
        widgetInfo.NeutralBar:SetTexture(C.media.backdrop)
        widgetInfo.RightBar:SetTexture(C.media.backdrop)

        widgetInfo.LeftBar:SetVertexColor(.2, .6, 1)
        widgetInfo.NeutralBar:SetVertexColor(.8, .8, .8)
        widgetInfo.RightBar:SetVertexColor(.9, .2, .2)

        if not widgetInfo.bg then
            widgetInfo.bg = F.SetBD(widgetInfo)
            widgetInfo.bg:Point("TOPLEFT", widgetInfo.LeftBar, -2, 2)
            widgetInfo.bg:Point("BOTTOMRIGHT", widgetInfo.RightBar, 2, -2)
        end
    end)

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
    frame:SetScript("OnEvent", function()
        for _, widgetFrame in pairs(_G.UIWidgetTopCenterContainerFrame.widgetFrames) do
            if widgetFrame.widgetType == _G.Enum.UIWidgetVisualizationType.DoubleStatusBar then
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

                        bar.styled = true
                    end
                end
            end
        end
    end)
end)