include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	TextBoxContent = ""
	local author = self:Getowning_ent()
	local author = (IsValid(author)) and author:Nick() or "Unknown"
	timer.Simple( 0.5, function() BOOKTITLE = (self:GetNWString("Title")..", By "..author); clBookTitle = self:GetNWString("Title") end)
end

function saveBookTitle(ent, title)
	if string.len(title) > Book_MaxTitleLength then
		ent:Getowning_ent():ChatPrint("Error, your title was too long; must be less than 20 characters")
	else
		local author = ent:Getowning_ent()
		local author = (IsValid(author)) and author:Nick() or "Unknown"
		ent:SetNWString("Title", title)
		BOOKTITLE = (title..", By "..author)

		net.Start("updateServer")
			net.WriteEntity(ent)
			net.WriteString(title)
			net.WriteString(TextBoxContent)
		net.SendToServer()
	end
end

function checkText(text)
	if string.len(text) > Book_MaxText then
		LocalPlayer():ChatPrint("Book text is more than the max ("..Book_MaxText..") and will be cut.")
		local t = string.Explode("", text)
		local newString = ""
		for i = 1, Book_MaxText do
			newString = (newString..t[i])
		end
		return newString
	else
		return text
	end
end

function openBookEdit(ent, title)
	if textOpen == true then return end
	textOpen = true
	local ply = LocalPlayer()
	local MenuBase = vgui.Create("DFrame")
	MenuBase:SetSize(ScrW()/2, ScrH()/2)
	MenuBase:SetPos(0, 0)
	MenuBase:SetTitle(BOOKTITLE)
	MenuBase:SetDeleteOnClose(false)
	MenuBase:SetDraggable(false)
	MenuBase:SetBackgroundBlur(false)
	MenuBase:Center(true)
	MenuBase:SetVisible(true)
	MenuBase:ShowCloseButton(false)
	MenuBase.Paint = function()
		draw.RoundedBox( 8, 0, 0, MenuBase:GetWide(), MenuBase:GetTall(), Color( 0, 0, 0, 150 ) )
	end
	MenuBase:MakePopup()

	local cl = vgui.Create("DButton", MenuBase)
	cl:SetSize( 50, 20 )
	cl:SetPos( MenuBase:GetWide() - 60, 0 )
	cl:SetText( "X" )
	cl:SetFont( "CloseCaption_Bold" )
	cl:SetTextColor( Color( 255, 255, 255, 255 ) )
	cl.Paint = function( self, w, h )
		local kcol
		if self.hover then
			kcol = Color( 255, 150, 150, 255 )
		else
			kcol = Color( 175, 100, 100 )
		end
		draw.RoundedBoxEx( 0, 0, 0, w, h, Color( 255, 150, 150, 255 ), false, false, true, true )
		draw.RoundedBoxEx( 0, 1, 0, w - 2, h - 1, kcol, false, false, true, true )
	end
	cl.DoClick = function()
		MenuBase:Close()
		textOpen = false
		net.Start( "Close" )
		net.SendToServer()
	end
	cl.OnCursorEntered = function( self )
		self.hover = true
	end
	cl.OnCursorExited = function( self )
		self.hover = false
	end

	local ScrollBar = vgui.Create( "DScrollPanel", MenuBase )
	ScrollBar:SetSize( MenuBase:GetWide() - 50, MenuBase:GetTall() - 40 )
	ScrollBar:SetPos( 25,30 )
		
	local Base1 = vgui.Create("DPanel", ScrollBar)
	Base1:SetPos(0,0)
	Base1:SetSize(MenuBase:GetWide() - 20, (ScrH()/2) - 50)
	Base1:SizeToContents()
	Base1.Paint = function()
		draw.RoundedBox( 8, 0, 0, Base1:GetWide(), Base1:GetTall(), Color( 255, 255, 255, 255 ) )
	end

	local titleText = vgui.Create("DLabel", Base1)
	titleText:SetPos(5, 20)
	titleText:SetColor(Color(0, 0, 0, 255))
	titleText:SetText("Title your book: ")
	titleText:SizeToContents()

	local titleInput = vgui.Create("DTextEntry", Base1)
	titleInput:SetPos(85, 15)
	titleInput:SetSize(100, 20)
	titleInput:SetHistoryEnabled(true)
	titleInput:SetText(ent:GetNWString("Title") or "")
	titleInput.OnEnter = function(self)
		saveBookTitle(ent, self:GetText())
		MenuBase:Close()
		textOpen = false
		net.Start( "Close" )
		net.SendToServer()
	end

	local titleSaveButton = vgui.Create("DButton", Base1)
	titleSaveButton:SetPos(190, 15)
	titleSaveButton:SetText("Save Title")
	titleSaveButton:SetSize(60, 20)
	titleSaveButton.DoClick = function()
		saveBookTitle(ent, titleInput:GetText())
		MenuBase:Close()
		textOpen = false
		net.Start( "Close" )
		net.SendToServer()
	end

	local titleText = vgui.Create("DLabel", Base1)
	titleText:SetPos(260, 18)
	titleText:SetColor(Color(0, 0, 0, 255))
	titleText:SetText("WARNING; This will close the book, save your work!")
	titleText:SizeToContents()

	local helpText1 = vgui.Create("DLabel", Base1)
	helpText1:SetPos(310, 50)
	helpText1:SetColor(Color(0, 0, 0, 255))
	helpText1:SetText("These icons help customize your book")
	helpText1:SizeToContents()

	local helpText2 = vgui.Create("DLabel", Base1)
	helpText2:SetPos(310, 60)
	helpText2:SetColor(Color(0, 0, 0, 255))
	helpText2:SetText("Hit the 'i' button for more.")
	helpText2:SizeToContents()


	local freeze = vgui.Create("DImageButton", Base1)
	freeze:SetPos(310, 75)
	freeze:SetImage("icon16/stop.png")
	freeze:SizeToContents()
	freeze.DoClick = function()
		net.Start("bookAction")
			net.WriteEntity(ent)
			net.WriteEntity(LocalPlayer())
			net.WriteString("Freeze")
		net.SendToServer()
	end

	local unfreeze = vgui.Create("DImageButton", Base1)
	unfreeze:SetPos(335, 75)
	unfreeze:SetImage("icon16/arrow_right.png")
	unfreeze:SizeToContents()
	unfreeze.DoClick = function()
		net.Start("bookAction")
			net.WriteEntity(ent)
			net.WriteEntity(LocalPlayer())
			net.WriteString("Unfreeze")
		net.SendToServer()
	end

	local setcolor = vgui.Create("DImageButton", Base1)
	setcolor:SetPos(360, 75)
	setcolor:SetImage("icon16/color_wheel.png")
	setcolor:SizeToContents()
	setcolor.DoClick = function()
		local Frame = vgui.Create( "DFrame" )
		Frame:SetSize( 300, 186 )
		Frame:Center()
		Frame:MakePopup()

		local Mixer = vgui.Create( "DColorMixer", Frame )
		Mixer:Dock(FILL)
		Mixer:SetLabel("Change Book Color")
		Mixer:SetPalette(true) 		
		Mixer:SetAlphaBar(false) 
		Mixer:SetWangs(true)			
		Mixer:SetColor(Color(255, 255, 255))
		Mixer.ValueChanged = function(ctrl, color)
			net.Start("bookAction")
				net.WriteEntity(ent)
				net.WriteEntity(LocalPlayer())
				net.WriteString("ChangeColor")
				net.WriteColor(Color(color.r, color.g, color.b))
			net.SendToServer()
		end
	end

	local publish = vgui.Create("DImageButton", Base1)
	publish:SetPos(380, 75)
	publish:SetImage("icon16/book_add.png")
	publish:SizeToContents()
	publish.DoClick = function()
		net.Start("bookAction")
			net.WriteEntity(ent)
			net.WriteEntity(LocalPlayer())
			net.WriteString("Publish")
		net.SendToServer()
		MenuBase:Close()
		textOpen = false
		net.Start( "Close" )
		net.SendToServer()
	end

	local info = vgui.Create("DImageButton", Base1)
	info:SetPos(405, 75)
	info:SetImage("icon16/information.png")
	info:SizeToContents()
	info.DoClick = function()
		net.Start("bookAction")
			net.WriteEntity(ent)
			net.WriteEntity(LocalPlayer())
			net.WriteString("Help")
		net.SendToServer()
	end

	local text = vgui.Create("DTextEntry", Base1)
	text:SetPos(5, 50)
	text:SetSize(300, 240)
	text:SetHistoryEnabled(true)
	text:SetMultiline(true)
	text:SetText(TextBoxContent)

	MenuBase.OnClose = function()
		TextBoxContent = checkText(text:GetText())

		net.Start("updateServer")
			net.WriteEntity(ent)
			net.WriteString(ent:GetNWString("Title"))
			net.WriteString(TextBoxContent)
		net.SendToServer()
	end

	local saveButton = vgui.Create("DButton", Base1)
	saveButton:SetPos(5, 295)
	saveButton:SetText("Save your book")
	saveButton:SetSize(100, 20)
	saveButton.DoClick = function()
		TextBoxContent = checkText(text:GetText())
		

		net.Start("updateServer")
			net.WriteEntity(ent)
			net.WriteString(ent:GetNWString("Title"))
			net.WriteString(TextBoxContent)
		net.SendToServer()
		
		print(BOOKTITLE.." Saved!")
		surface.PlaySound("items/ammo_pickup.wav")
	end

	local saveText = vgui.Create("DLabel", Base1)
	saveText:SetPos(115, 298)
	saveText:SetColor(Color(0, 0, 0, 255))
	saveText:SetText("Warning: Nothing will appear to happen, but if it makes a sound, it saved")
	saveText:SizeToContents()
end
net.Receive("openBookEdit", function(len,ply)
	ent = net.ReadEntity()
	title = net.ReadString()
	openBookEdit(ent, title)
end)






/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





function openBookROM(ent, title, text)
	local origauthor = ent:Getowning_ent()
	local author = (IsValid(origauthor)) and origauthor:Nick() or "Unknown"
	if textOpen == true then return end
	textOpen = true
	local ply = LocalPlayer()
	local MenuBase = vgui.Create("DFrame")
	MenuBase:SetSize(ScrW()/2, ScrH()/2)
	MenuBase:SetPos(0, 0)
	MenuBase:SetTitle(title..", By "..author)
	MenuBase:SetDeleteOnClose(false)
	MenuBase:SetDraggable(false)
	MenuBase:SetBackgroundBlur(false)
	MenuBase:Center(true)
	MenuBase:SetVisible(true)
	MenuBase:ShowCloseButton(false)
	MenuBase.Paint = function()
		draw.RoundedBox( 8, 0, 0, MenuBase:GetWide(), MenuBase:GetTall(), Color( 0, 0, 0, 150 ) )
	end
	MenuBase:MakePopup()

	local cl = vgui.Create("DButton", MenuBase)
	cl:SetSize( 50, 20 )
	cl:SetPos( MenuBase:GetWide() - 60, 0 )
	cl:SetText( "X" )
	cl:SetFont( "CloseCaption_Bold" )
	cl:SetTextColor( Color( 255, 255, 255, 255 ) )
	cl.Paint = function( self, w, h )
		local kcol
		if self.hover then
			kcol = Color( 255, 150, 150, 255 )
		else
			kcol = Color( 175, 100, 100 )
		end
		draw.RoundedBoxEx( 0, 0, 0, w, h, Color( 255, 150, 150, 255 ), false, false, true, true )
		draw.RoundedBoxEx( 0, 1, 0, w - 2, h - 1, kcol, false, false, true, true )
	end
	cl.DoClick = function()
		MenuBase:Close()
		textOpen = false
		net.Start( "Close" )
		net.SendToServer()
	end
	cl.OnCursorEntered = function( self )
		self.hover = true
	end
	cl.OnCursorExited = function( self )
		self.hover = false
	end

	local ScrollBar = vgui.Create( "DScrollPanel", MenuBase )
	ScrollBar:SetSize( MenuBase:GetWide() - 50, MenuBase:GetTall() - 40 )
	ScrollBar:SetPos( 25,30 )
		
	local Base1 = vgui.Create("DPanel", ScrollBar)
	Base1:SetPos(0,0)
	Base1:SetSize(MenuBase:GetWide() - 20, (ScrH()/2) - 50)
	Base1:SizeToContents()
	Base1.Paint = function()
		draw.RoundedBox( 8, 0, 0, Base1:GetWide(), Base1:GetTall(), Color( 255, 255, 255, 255 ) )
	end

	local paragraph = vgui.Create("DTextEntry", ScrollBar)
	paragraph:SetPos(5, 5)
	paragraph:SetSize(Base1:GetWide() - 50, Base1:GetTall(-5))
	paragraph:SetTextColor(Color(0, 0, 0, 255))
	paragraph:SetWrap(true)
	paragraph:SetMultiline(true)
	paragraph:SetDrawBackground(false)
	paragraph:SetDrawBorder(false)
	paragraph:SetEditable(false)
	paragraph:SetText(text)

	if LocalPlayer() == origauthor then
	local freeze = vgui.Create("DImageButton", Base1)
	freeze:SetPos(10, Base1:GetTall() - 20)
	freeze:SetImage("icon16/stop.png")
	freeze:SizeToContents()
	freeze.DoClick = function()
		net.Start("bookAction")
			net.WriteEntity(ent)
			net.WriteEntity(LocalPlayer())
			net.WriteString("Freeze")
		net.SendToServer()
	end

	local unfreeze = vgui.Create("DImageButton", Base1)
	unfreeze:SetPos(35, Base1:GetTall() - 20)
	unfreeze:SetImage("icon16/arrow_right.png")
	unfreeze:SizeToContents()
	unfreeze.DoClick = function()
		net.Start("bookAction")
			net.WriteEntity(ent)
			net.WriteEntity(LocalPlayer())
			net.WriteString("Unfreeze")
		net.SendToServer()
	end

	local setcolor = vgui.Create("DImageButton", Base1)
	setcolor:SetPos(60, Base1:GetTall() - 20)
	setcolor:SetImage("icon16/color_wheel.png")
	setcolor:SizeToContents()
	setcolor.DoClick = function()
		local Frame = vgui.Create( "DFrame" )
		Frame:SetSize( 300, 186 ) --good size for example
		Frame:Center()
		Frame:MakePopup()

		local Mixer = vgui.Create( "DColorMixer", Frame )
		Mixer:Dock(FILL)
		Mixer:SetLabel("Change Book Color")
		Mixer:SetPalette(true) 		
		Mixer:SetAlphaBar(false) 
		Mixer:SetWangs(true)			
		Mixer:SetColor(Color(255, 255, 255))
		Mixer.ValueChanged = function(ctrl, color)
			net.Start("bookAction")
				net.WriteEntity(ent)
				net.WriteEntity(LocalPlayer())
				net.WriteString("ChangeColor")
				net.WriteColor(Color(color.r, color.g, color.b))
			net.SendToServer()
		end
	end
	end
end
net.Receive("openBookRead", function(len, ply)
	ent = net.ReadEntity()
	title = net.ReadString()
	txt = net.ReadString()
	openBookROM(ent, title, txt)
end)
