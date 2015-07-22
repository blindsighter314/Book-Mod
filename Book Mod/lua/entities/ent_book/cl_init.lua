include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	HistoryTable = {""}
	local author = self:Getowning_ent()
	local author = (IsValid(author)) and author:Nick() or "Unknown"
	//Timer because BOOKTITLE was being declared before the NWString was lol
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
			net.WriteTable(HistoryTable)
		net.SendToServer()
	end
end

function checkText(text, num)
	if string.len(text) > Book_MaxTextPerLine then
		LocalPlayer():ChatPrint("Line "..num.." of your book was too long and will be cut")
		local t = string.Explode("", text)
		local newString = ""
		for i = 1, Book_MaxTextPerLine do
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
	Base1:SetSize(MenuBase:GetWide() - 20, 600)
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
	helpText1:SetPos(5, 50)
	helpText1:SetColor(Color(0, 0, 0, 255))
	helpText1:SetText("Scroll down to the bottom to save your writing.|")
	helpText1:SizeToContents()

	local helpText2 = vgui.Create("DLabel", Base1)
	helpText2:SetPos(250, 50)
	helpText2:SetColor(Color(0, 0, 0, 255))
	helpText2:SetText("These icons help customize your book, hit the 'i' button for more.")
	helpText2:SizeToContents()



	local freeze = vgui.Create("DImageButton", Base1)
	freeze:SetPos(260, 65)
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
	unfreeze:SetPos(285, 65)
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
	setcolor:SetPos(310, 65)
	setcolor:SetImage("icon16/color_wheel.png")
	setcolor:SizeToContents()
	setcolor.DoClick = function()
		local Frame = vgui.Create( "DFrame" )
		Frame:SetSize( 300, 186 ) --good size for example
		Frame:Center()
		Frame:MakePopup()

		local Mixer = vgui.Create( "DColorMixer", Frame )
		Mixer:Dock(FILL)			--Make Mixer fill place of Frame
		Mixer:SetLabel("Change Book Color")
		Mixer:SetPalette(true) 		--Show/hide the palette			DEF:true
		Mixer:SetAlphaBar(false) 		--Show/hide the alpha bar		DEF:true
		Mixer:SetWangs(true)			--Show/hide the R G B A indicators 	DEF:true
		Mixer:SetColor(Color(255, 255, 255))	--Set the default color
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
	publish:SetPos(335, 65)
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
	info:SetPos(360, 65)
	info:SetImage("icon16/information.png")
	info:SizeToContents()
	info.DoClick = function()
		net.Start("bookAction")
			net.WriteEntity(ent)
			net.WriteEntity(LocalPlayer())
			net.WriteString("Help")
		net.SendToServer()
	end














	local spacer = 520
	local indent = 22
	local count = 1

	local text1 = vgui.Create("DTextEntry", Base1)
	text1:SetPos(5, spacer)
	text1:SetSize(MenuBase:GetWide() - 100, 20)
	text1:SetHistoryEnabled(true)
	text1:SetText(HistoryTable[count] or "")
	text1.OnEnter = function(self)
		text1:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text2 = vgui.Create("DTextEntry", Base1)
	text2:SetPos(5, spacer)
	text2:SetSize(MenuBase:GetWide() - 100, 20)
	text2:SetHistoryEnabled(true)
	text2:SetText(HistoryTable[count] or "")
	text2.OnEnter = function(self)
		text1:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text3 = vgui.Create("DTextEntry", Base1)
	text3:SetPos(5, spacer)
	text3:SetSize(MenuBase:GetWide() - 100, 20)
	text3:SetHistoryEnabled(true)
	text3:SetText(HistoryTable[count] or "")
	text3.OnEnter = function(self)
		text2:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text4 = vgui.Create("DTextEntry", Base1)
	text4:SetPos(5, spacer)
	text4:SetSize(MenuBase:GetWide() - 100, 20)
	text4:SetHistoryEnabled(true)
	text4:SetText(HistoryTable[count] or "")
	text4.OnEnter = function(self)
		text3:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text5 = vgui.Create("DTextEntry", Base1)
	text5:SetPos(5, spacer)
	text5:SetSize(MenuBase:GetWide() - 100, 20)
	text5:SetHistoryEnabled(true)
	text5:SetText(HistoryTable[count] or "")
	text5.OnEnter = function(self)
		text4:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text6 = vgui.Create("DTextEntry", Base1)
	text6:SetPos(5, spacer)
	text6:SetSize(MenuBase:GetWide() - 100, 20)
	text6:SetHistoryEnabled(true)
	text6:SetText(HistoryTable[count] or "")
	text6.OnEnter = function(self)
		text5:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text7 = vgui.Create("DTextEntry", Base1)
	text7:SetPos(5, spacer)
	text7:SetSize(MenuBase:GetWide() - 100, 20)
	text7:SetHistoryEnabled(true)
	text7:SetText(HistoryTable[count] or "")
	text7.OnEnter = function(self)
		text6:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text8 = vgui.Create("DTextEntry", Base1)
	text8:SetPos(5, spacer)
	text8:SetSize(MenuBase:GetWide() - 100, 20)
	text8:SetHistoryEnabled(true)
	text8:SetText(HistoryTable[count] or "")
	text8.OnEnter = function(self)
		text7:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text9 = vgui.Create("DTextEntry", Base1)
	text9:SetPos(5, spacer)
	text9:SetSize(MenuBase:GetWide() - 100, 20)
	text9:SetHistoryEnabled(true)
	text9:SetText(HistoryTable[count] or "")
	text9.OnEnter = function(self)
		text8:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text10 = vgui.Create("DTextEntry", Base1)
	text10:SetPos(5, spacer)
	text10:SetSize(MenuBase:GetWide() - 100, 20)
	text10:SetHistoryEnabled(true)
	text10:SetText(HistoryTable[count] or "")
	text10.OnEnter = function(self)
		text9:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text11 = vgui.Create("DTextEntry", Base1)
	text11:SetPos(5, spacer)
	text11:SetSize(MenuBase:GetWide() - 100, 20)
	text11:SetHistoryEnabled(true)
	text11:SetText(HistoryTable[count] or "")
	text11.OnEnter = function(self)
		text10:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text12 = vgui.Create("DTextEntry", Base1)
	text12:SetPos(5, spacer)
	text12:SetSize(MenuBase:GetWide() - 100, 20)
	text12:SetHistoryEnabled(true)
	text12:SetText(HistoryTable[count] or "")
	text12.OnEnter = function(self)
		text11:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text13 = vgui.Create("DTextEntry", Base1)
	text13:SetPos(5, spacer)
	text13:SetSize(MenuBase:GetWide() - 100, 20)
	text13:SetHistoryEnabled(true)
	text13:SetText(HistoryTable[count] or "")
	text13.OnEnter = function(self)
		text12:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text14 = vgui.Create("DTextEntry", Base1)
	text14:SetPos(5, spacer)
	text14:SetSize(MenuBase:GetWide() - 100, 20)
	text14:SetHistoryEnabled(true)
	text14:SetText(HistoryTable[count] or "")
	text14.OnEnter = function(self)
		text13:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text15 = vgui.Create("DTextEntry", Base1)
	text15:SetPos(5, spacer)
	text15:SetSize(MenuBase:GetWide() - 100, 20)
	text15:SetHistoryEnabled(true)
	text15:SetText(HistoryTable[count] or "")
	text15.OnEnter = function(self)
		text14:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text16 = vgui.Create("DTextEntry", Base1)
	text16:SetPos(5, spacer)
	text16:SetSize(MenuBase:GetWide() - 100, 20)
	text16:SetHistoryEnabled(true)
	text16:SetText(HistoryTable[count] or "")
	text16.OnEnter = function(self)
		text15:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text17 = vgui.Create("DTextEntry", Base1)
	text17:SetPos(5, spacer)
	text17:SetSize(MenuBase:GetWide() - 100, 20)
	text17:SetHistoryEnabled(true)
	text17:SetText(HistoryTable[count] or "")
	text17.OnEnter = function(self)
		text16:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text18 = vgui.Create("DTextEntry", Base1)
	text18:SetPos(5, spacer)
	text18:SetSize(MenuBase:GetWide() - 100, 20)
	text18:SetHistoryEnabled(true)
	text18:SetText(HistoryTable[count] or "")
	text18.OnEnter = function(self)
		text17:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text19 = vgui.Create("DTextEntry", Base1)
	text19:SetPos(5, spacer)
	text19:SetSize(MenuBase:GetWide() - 100, 20)
	text19:SetHistoryEnabled(true)
	text19:SetText(HistoryTable[count] or "")
	text19.OnEnter = function(self)
		text18:RequestFocus()
	end

	spacer = spacer - indent
	count = count + 1

	local text20 = vgui.Create("DTextEntry", Base1)
	text20:SetPos(5, spacer)
	text20:SetSize(MenuBase:GetWide() - 100, 20)
	text20:SetHistoryEnabled(true)
	text20:SetText(HistoryTable[count] or "")
	text20.OnEnter = function(self)
		print(self:GetText())
		text19:RequestFocus()
	end

	spacer = spacer - indent









	

	local saveButton = vgui.Create("DButton", Base1)
	saveButton:SetPos(5, spacer + 485)
	saveButton:SetText("Save your book")
	saveButton:SetSize(100, 20)
	saveButton.DoClick = function()
		HistoryTable[1] 	= checkText(text1:GetText(), 20)
		HistoryTable[2] 	= checkText(text2:GetText(), 19)
		HistoryTable[3] 	= checkText(text3:GetText(), 18)
		HistoryTable[4] 	= checkText(text4:GetText(), 17)
		HistoryTable[5] 	= checkText(text5:GetText(), 16)
		HistoryTable[6] 	= checkText(text6:GetText(), 15)
		HistoryTable[7] 	= checkText(text7:GetText(), 14)
		HistoryTable[8] 	= checkText(text8:GetText(), 13)
		HistoryTable[9] 	= checkText(text9:GetText(), 12)
		HistoryTable[10] 	= checkText(text10:GetText(), 11)
		HistoryTable[11] 	= checkText(text11:GetText(), 10)
		HistoryTable[12] 	= checkText(text12:GetText(), 9)
		HistoryTable[13] 	= checkText(text13:GetText(), 8)
		HistoryTable[14] 	= checkText(text14:GetText(), 7)
		HistoryTable[15] 	= checkText(text15:GetText(), 6)
		HistoryTable[16] 	= checkText(text16:GetText(), 5)
		HistoryTable[17] 	= checkText(text17:GetText(), 4)
		HistoryTable[18] 	= checkText(text18:GetText(), 3)
		HistoryTable[19] 	= checkText(text19:GetText(), 2)
		HistoryTable[20] 	= checkText(text20:GetText(), 1)

		net.Start("updateServer")
			net.WriteEntity(ent)
			net.WriteString(ent:GetNWString("Title"))
			net.WriteTable(HistoryTable)
		net.SendToServer()
		
		print(BOOKTITLE.." Saved!")
		surface.PlaySound("items/ammo_pickup.wav")
	end

	local saveText = vgui.Create("DLabel", Base1)
	saveText:SetPos(115, spacer + 485)
	saveText:SetColor(Color(0, 0, 0, 255))
	saveText:SetText("Warning: Nothing will appear to happen, but if it makes a sound, it saved")
	saveText:SizeToContents() 
end
net.Receive("openBookEdit", function(len,ply)
	ent = net.ReadEntity()
	title = net.ReadString()
	openBookEdit(ent, title)
end)






/////////////////////////////////////////////////////////////////////////////////////////////////////////////








function openBookROM(ent, title)
	local author = ent:Getowning_ent()
	local author = (IsValid(author)) and author:Nick() or "Unknown"
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
	Base1:SetSize(MenuBase:GetWide() - 20, 300)
	Base1:SizeToContents()
	Base1.Paint = function()
		draw.RoundedBox( 8, 0, 0, Base1:GetWide(), Base1:GetTall(), Color( 255, 255, 255, 255 ) )
	end

	local paragraph = vgui.Create("DLabel", Base1)
	paragraph:SetPos(5, 5)
	paragraph:SetColor(Color(0, 0, 0, 255))
	paragraph:SetText(ent:GetNWString("Text"))
	paragraph:SizeToContents() 
end
net.Receive("openBookRead", function(len, ply)
	ent = net.ReadEntity()
	title = net.ReadString()
	openBookROM(ent, title)
end)
