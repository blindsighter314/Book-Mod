function book_HudPaint()
	local TraceSettings = {
		start = LocalPlayer():GetShootPos(),
		endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetForward() * 200,
		filter = LocalPlayer()
	}
	
	local Trace = util.TraceLine( TraceSettings )
	local Target = Trace.Entity
	
	if Target:IsValid() then
		if Target:GetClass() == "ent_book" then
			local title = Target:GetNWString("Title")
			local author = Target:Getowning_ent()
			local author = (IsValid(author)) and author:Nick() or "Unknown"
			
			halo.Add({Target}, Target:GetColor(), 5, 5, 2)
			
			draw.DrawText( title, "CloseCaption_Bold", ScrW() * 0.5, ScrH() * 0.55, Color(0, 102, 204, 255), TEXT_ALIGN_CENTER )
			draw.DrawText( "Written By: "..author, "CloseCaption_Bold", ScrW() * 0.5, ScrH() * 0.55 + 20, Color(0, 102, 204, 255), TEXT_ALIGN_CENTER )
			draw.DrawText( "Press E to read", "CloseCaption_Bold", ScrW() * 0.5, ScrH() * 0.55 + 40, Color(0, 102, 204, 255), TEXT_ALIGN_CENTER )
		end
	end
end
hook.Add("HUDPaint", "Paint Book Hud", book_HudPaint)