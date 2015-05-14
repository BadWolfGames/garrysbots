//----------------------------------------GUI
//VGUI DEFINES
local WINDOW0 = {}

surface.CreateFont("PostGameFont", {
	font = "coolvetica",
	size = 20,
	weight = 500,
	antialias = true,
	additive = false,
})

function WINDOW0:Init()
	self.HEIGHT = 400
	self.WIDTH = 250
	self.CENTER_OFFSET = 150
	self.DROP_AMOUNT = 100
	self.CORNER_SIZE = 10

	self.MAIN_COLOR = Color(64, 64, 64, 255)

	self.SIZE_EXTENTION = 10

	self.OpenPos = self.DROP_AMOUNT
	self.ClosedPos = -self.HEIGHT - self.SIZE_EXTENTION + 1

	self:SetZPos(1)
	self:SetSize(self.WIDTH, self.HEIGHT + self.SIZE_EXTENTION)
	self:SetPos(0, self.ClosedPos)
	self.open = false
	self:SetVisible(true)
end

function WINDOW0:SetHeight()
	self:SetSize(self.WIDTH, self.HEIGHT + self.SIZE_EXTENTION)
	self.ClosedPos = -self.HEIGHT - self.SIZE_EXTENTION + 1
	self.OpenPos = self.DROP_AMOUNT
end

function WINDOW0:Paint()
	if self.open then
		if self.X != self.OpenPos then
			self:SetPos(self.X, math.Approach( self.Y, self.OpenPos, (math.abs( self.Y - self.OpenPos ) + 1) * 10 * FrameTime() ))
		end
	else
		if self.X != self.ClosedPos then
			self:SetPos(self.X, math.Approach( self.Y, self.ClosedPos, (math.abs( self.Y - self.ClosedPos ) + 1) * 10 * FrameTime() ))
		end
	end

	draw.RoundedBox( self.CORNER_SIZE, 0, 0, self:GetWide(), self:GetTall() - self.SIZE_EXTENTION, self.MAIN_COLOR )
	return true
end
vgui.Register("BaseMenu", WINDOW0)

local WINDOW1 = {}

function WINDOW1:Init()
	self.WIDTH = ScrW()*0.9
	self.DROP_AMOUNT = ScrH()*0.05

	//BUTTONS and TITLES
	local offset = 5
	local title1 = vgui.Create( "MenuTitle", self)
	title1.TEXT = "Garry's Bots Help"
	title1:SetPos(5, offset)
	title1:SetSize(self.WIDTH - 10, 25)
	offset = offset + 30

	local html1 = vgui.Create( "HTML", self)
	html1:SetHTML(HelpMenuHTML)
	html1:SetPos(5, offset)
	html1:SetSize(self.WIDTH - 10, ScrH()*0.9 - offset - 5)
	offset = offset + html1:GetTall() + 5

	self.HEIGHT = offset
	self:SetHeight()
	self:SetPos(ScrW()/2 - self.WIDTH/2, self.ClosedPos)
end
vgui.Register("F1Menu", WINDOW1, "BaseMenu")

local WINDOW2 = {}

function WINDOW2:Init()
	//BUTTONS and TITLES
	local offset = 5
	local title1 = vgui.Create( "MenuTitle", self)
	title1.TEXT = "Change Team"
	title1:SetPos(5, offset)
	offset = offset + 30

	local button1 = vgui.Create( "MenuButton", self)
	button1.TEXT = "Blue Team"
	button1.COMMAND = "gb_changeteam blue"
	button1:SetPos(5, offset)
	offset = offset + 30

	local button2 = vgui.Create( "MenuButton", self)
	button2.TEXT = "Red Team"
	button2.COMMAND = "gb_changeteam red"
	button2:SetPos(5, offset)
	offset = offset + 30

	self.HEIGHT = offset
	self:SetHeight()
	self:SetPos(ScrW()/2 - self.CENTER_OFFSET - self.WIDTH, self.ClosedPos)
end
vgui.Register("F2Menu", WINDOW2, "BaseMenu")

local WINDOW3 = {}

function WINDOW3:Init()
	//BUTTONS and TITLES
	local offset = 5
	local title1 = vgui.Create( "MenuTitle", self)
	title1.TEXT = "Control Panel"
	title1:SetPos(5, offset)
	offset = offset + 30

	local button1 = vgui.Create( "MenuButton", self)
	button1.TEXT = "Toggle Camera"
	button1.COMMAND = "gb_togglecam"
	button1:SetPos(5, offset)
	offset = offset + 30

	local button2 = vgui.Create( "MenuButton", self)
	button2.TEXT = "Forfeit"
	button2.COMMAND = "gb_forfeit"
	button2:SetPos(5, offset)
	offset = offset + 30

	local button3 = vgui.Create( "MenuButton", self)
	button3.TEXT = "Voteskip"
	button3.COMMAND = "gb_voteskip"
	button3:SetPos(5, offset)
	offset = offset + 30

	local button4 = vgui.Create( "MenuButton", self)
	button4.TEXT = "Toggle Music"
	button4.COMMAND = "gb_togglemusic"
	button4:SetPos(5, offset)
	offset = offset + 30

	local button5 = vgui.Create( "MenuButton", self)
	button5.TEXT = "Check Prop Health"
	button5.COMMAND = "gethealth"
	button5:SetPos(5, offset)
	offset = offset + 30

	self.HEIGHT = offset
	self:SetHeight()
	self:SetPos(ScrW()/2 - self.WIDTH/2, self.ClosedPos)
end
vgui.Register("F3Menu", WINDOW3, "BaseMenu")

local WINDOW4 = {}

function WINDOW4:Init()
	//BUTTONS and TITLES
	local offset = 5
	local title1 = vgui.Create( "MenuTitle", self)
	title1.TEXT = "SENTS"
	title1:SetPos(5, offset)
	offset = offset + 30

	local button1 = vgui.Create( "MenuButton", self)
	button1.TEXT = "Spawn Core"
	button1.COMMAND = "gm_spawnsent2 gb_core"
	button1:SetPos(5, offset)
	offset = offset + 30

	local button2 = vgui.Create( "MenuButton", self)
	button2.TEXT = "Spawn Camera"
	button2.COMMAND = "gm_spawnsent2 gb_cam"
	button2:SetPos(5, offset)
	offset = offset + 30

	self.HEIGHT = offset
	self:SetHeight()
	self:SetPos(ScrW()/2 + self.CENTER_OFFSET, self.ClosedPos)
end
vgui.Register("F4Menu", WINDOW4, "BaseMenu")

local MOTD_WINDOW = {}

function MOTD_WINDOW:Init()
	self.WIDTH = ScrW()*0.9
	self.DROP_AMOUNT = ScrH()*0.05

	local offset = 5
	local title1 = vgui.Create( "MenuTitle", self)
	title1.TEXT = "-IMPORTANT-"
	title1:SetPos(5, offset)
	title1:SetSize(self.WIDTH - 10, 25)
	offset = offset + 30

	local html1 = vgui.Create( "HTML", self)
	html1:SetHTML(MOTDHTML)
	html1:SetPos(5, offset)
	html1:SetSize(self.WIDTH - 10, ScrH()*0.9 - offset - 35)
	offset = offset + html1:GetTall() + 5

	local button1 = vgui.Create( "CloseButton", self)
	button1.Parent = self //I shouldn't have to do ths...
	button1.ALIGNMENT = TEXT_ALIGN_CENTER
	button1.TEXT = "Close"
	button1:SetSize(65, 25)
	button1:SetPos(self.WIDTH/2 - button1:GetWide()/2, offset)

	local button2 = vgui.Create( "CheckButton", self)
	button2:SetText("I have read the MOTD")
	button2:SetSize(135, 25)
	button2:SetPos(self.WIDTH/2 + button1:GetWide()/2 + 15, offset)
	self.Accept = button2
	offset = offset + 30

	self.HEIGHT = offset
	self:SetHeight()
	self:SetPos(ScrW()/2 - self.WIDTH/2, self.OpenPos)
	self.open = true
end

function MOTD_WINDOW:Paint()
	if self.open then
		gui.EnableScreenClicker( true ) //prevent them from doing anything
		if self.X != self.OpenPos then
			self:SetPos(self.X, math.Approach( self.Y, self.OpenPos, (math.abs( self.Y - self.OpenPos ) + 1) * 10 * FrameTime() ))
		end
	else
		if self.X != self.ClosedPos then
			self:SetPos(self.X, math.Approach( self.Y, self.ClosedPos, (math.abs( self.Y - self.ClosedPos ) + 1) * 10 * FrameTime() ))
		end
	end

	draw.RoundedBox( self.CORNER_SIZE, 0, 0, self:GetWide(), self:GetTall() - self.SIZE_EXTENTION, self.MAIN_COLOR )
	return true
end
vgui.Register("MOTDWindow", MOTD_WINDOW, "BaseMenu")

local ANNOUNCEMENT_WINDOW = {}

function ANNOUNCEMENT_WINDOW:Init()
	self.CORNER_SIZE = 10

	self.MAIN_COLOR = Color(64, 64, 64, 255)
	self.TEXT_AREA_COLOR = Color(128, 128, 128, 255)
	self.TITLE_COLOR = Color(255, 0, 0, 255)
	self.TITLE_TEXT_COLOR = Color(255, 255, 255, 255)
	self.TEXT_COLOR = Color(255, 255, 255, 255)

	self.FONT = "HudHintTextLarge"

	self:SetZPos(1)
	self:SetSize(300, 65)
	self:SetPos(ScrW()/2 - self:GetWide()/2, ScrH()*0.28)
	self.alpha = 255
	self.text = {}
	self.time = 0
	self:SetVisible(false)
end

function ANNOUNCEMENT_WINDOW:Timer()
	self.time = self.time - 1
end

function ANNOUNCEMENT_WINDOW:Paint()
	if self.time > 0 then
		self.alpha = 255
	elseif self.alpha > 0 then
		self.alpha = self.alpha - 10
		if self.alpha < 0 then
			self.alpha = 0
		end
	else
		self:SetVisible(false)
	end

	self:SetSize(self:GetWide(),  40 + (table.getn(self.text) * 15) + 10)
	draw.RoundedBox( self.CORNER_SIZE, 0, 0, self:GetWide(), self:GetTall(), Color(self.MAIN_COLOR.r, self.MAIN_COLOR.g, self.MAIN_COLOR.b, self.alpha) )
	draw.RoundedBox( self.CORNER_SIZE, 5, 5, self:GetWide() - 10, 25, Color(self.TITLE_COLOR.r, self.TITLE_COLOR.g, self.TITLE_COLOR.b, self.alpha) )
	draw.RoundedBox( self.CORNER_SIZE, 5, 35, self:GetWide() - 10, self:GetTall() - 40, Color(self.TEXT_AREA_COLOR.r, self.TEXT_AREA_COLOR.g, self.TEXT_AREA_COLOR.b, self.alpha) )
	draw.DrawText( "-Announcement-", self.FONT, self:GetWide()/2, 10, Color(self.TITLE_TEXT_COLOR.r, self.TITLE_TEXT_COLOR.g, self.TITLE_TEXT_COLOR.b, self.alpha), TEXT_ALIGN_CENTER )
	for k, v in pairs(self.text) do
		draw.DrawText( v, self.FONT, self:GetWide()/2, 40 + ((k - 1) * 15), Color(self.TEXT_COLOR.r, self.TEXT_COLOR.g, self.TEXT_COLOR.b, self.alpha), TEXT_ALIGN_CENTER )
	end
	return true
end
vgui.Register("Announcement", ANNOUNCEMENT_WINDOW)

local POSTGAME_WINDOW = {}

function POSTGAME_WINDOW:Init()
	self.CORNER_SIZE = 10

	self.MAIN_COLOR = Color(64, 64, 64, 150)
	self.TEXT_AREA_COLOR = Color(128, 128, 128, 150)
	self.TITLE_COLOR = Color(255, 0, 0, 255)
	self.TITLE_TEXT_COLOR = Color(255, 255, 255, 255)
	self.TEXT_COLOR = Color(255, 255, 255, 150)

	self.FONT = "HudHintTextLarge"
	self.FONT2 = "PostGameFont" //HudHintTextLarge has issues with colors other than white

	self:SetZPos(1)
	self:SetSize(750, 450)
	self:SetPos(ScrW()/2 - self:GetWide()/2, ScrH()*0.15)
	self.WinText = "default"
	self.WinColor = Color(128, 128, 128, 255)
	self.Times = {}
	self.Healths = {}
	self.Damages = {}
	self:SetVisible(false)
end

function POSTGAME_WINDOW:LoadData()
	for k, v in pairs(self.Times) do
		if v[1]:IsValid() then
			v[1] = {v[1]:Name(), team.GetColor(v[1]:Team())}
		else
			v[1] = {"???", Color(0,0,0,255)}
		end
	end

	for k, v in pairs(self.Healths) do
		if v[1]:IsValid() then
			v[1] = {v[1]:Name(), team.GetColor(v[1]:Team())}
		else
			v[1] = {"???", Color(0,0,0,255)}
		end
	end

	for k, v in pairs(self.Damages) do
		if v[1]:IsValid() then
			v[1] = {v[1]:Name(), team.GetColor(v[1]:Team())}
		else
			v[1] = {"???", Color(0,0,0,255)}
		end
	end
end

function POSTGAME_WINDOW:Paint()
	draw.RoundedBox( self.CORNER_SIZE, 0, 0, self:GetWide(), self:GetTall(), self.MAIN_COLOR )

	local offset = 5
	draw.RoundedBox( self.CORNER_SIZE, 5, offset, self:GetWide() - 10, 25, self.TITLE_COLOR )
	draw.DrawText( "-Post Game Report-", self.FONT, self:GetWide()/2, offset + 5, self.TITLE_TEXT_COLOR, TEXT_ALIGN_CENTER )

	offset = offset + 30
	draw.RoundedBox( self.CORNER_SIZE, 5, offset, self:GetWide() - 10, 25, self.WinColor )
	draw.DrawText( self.WinText, self.FONT, self:GetWide()/2, offset + 5, self.TITLE_TEXT_COLOR, TEXT_ALIGN_CENTER )

	offset = offset + 30
	local half_size = (self:GetTall() - offset - 10)/2
	draw.RoundedBox( self.CORNER_SIZE, 5, offset, self:GetWide()/2 - 7.5, half_size, self.TEXT_AREA_COLOR )
	draw.DrawText( "Survival Times:", self.FONT, 10, offset + 5, self.TEXT_COLOR )
	for k, v in pairs(self.Times) do
		draw.DrawText( k..". "..v[1][1], self.FONT2, 10 + 15, offset + 30 + ((k - 1) * 15), v[1][2] )
		draw.DrawText( string.FormattedTime( v[2], "%02i:%02i"), self.FONT2, self:GetWide()/2 - 7.5, offset + 30 + ((k - 1) * 15), v[1][2], 2 )
	end

	draw.RoundedBox( self.CORNER_SIZE, self:GetWide()/2 + 2.5, offset, self:GetWide()/2 - 7.5, half_size * 2 + 5, self.TEXT_AREA_COLOR )
	draw.DrawText( "Damage Dealt:", self.FONT, self:GetWide()/2 + 7.5, offset + 5, self.TEXT_COLOR )
	for k, v in pairs(self.Damages) do
		draw.DrawText( k..". "..v[1][1], self.FONT2, self:GetWide()/2 + 7.5 + 15, offset + 30 + ((k - 1) * 15), v[1][2] )
		draw.DrawText( v[2], self.FONT2, self:GetWide() - 10, offset + 30 + ((k - 1) * 15), v[1][2], 2 )
	end

	offset = offset + half_size + 5
	draw.RoundedBox( self.CORNER_SIZE, 5, offset, self:GetWide()/2 - 7.5, half_size, self.TEXT_AREA_COLOR )
	draw.DrawText( "Core Healths:", self.FONT, 10, offset + 5, self.TEXT_COLOR )
	for k, v in pairs(self.Healths) do
		draw.DrawText( k..". "..v[1][1], self.FONT2, 10 + 15, offset + 30 + ((k - 1) * 15), v[1][2] )
		draw.DrawText( v[2], self.FONT2, self:GetWide()/2 - 7.5, offset + 30 + ((k - 1) * 15), v[1][2], 2 )
	end

	return true
end
vgui.Register("PostGameScreen", POSTGAME_WINDOW)

local BUTTON = {}

function BUTTON:Init()
	self.CORNER_SIZE = 10

	self.TEXT_XOFFSET = 3
	self.TEXT_YOFFSET = 5

	self.COLOR = Color(128, 128, 128, 255)
	self.HOVER_COLOR = Color(64, 64, 255, 255)
	self.PUSH_COLOR = Color(255, 255, 64, 255)
	self.TEXT_COLOR = Color(255, 255, 255, 255)

	self.TEXT = "Default Text"
	self.FONT = "HudHintTextLarge"
	self.ALIGNMENT = TEXT_ALIGN_LEFT

	self.COMMAND = "say lulz"

	self.color = self.COLOR

	self:SetZPos(2)
	self:SetSize(240, 25) //default
end

function BUTTON:DoClick()
	surface.PlaySound( "ui/buttonclick.wav" )
	LocalPlayer():ConCommand(self.COMMAND)
end

function BUTTON:Paint()
	if self.Selected then
		self.color = self.PUSH_COLOR
	elseif self.Armed then
		self.color = self.HOVER_COLOR
	else
		self.color = self.COLOR
	end

	if (self.ALIGNMENT == 1) then
		self.TEXT_XOFFSET = self:GetWide()/2
	end

	draw.RoundedBox( self.CORNER_SIZE, 0, 0, self:GetWide(), self:GetTall(), self.color )
	draw.DrawText( self.TEXT, self.FONT, self.TEXT_XOFFSET, self.TEXT_YOFFSET, self.TEXT_COLOR, self.ALIGNMENT )
	return true
end
vgui.Register( "MenuButton", BUTTON, "Button" )

local BUTTON2 = {}
function BUTTON2:DoClick()
	surface.PlaySound( "ui/buttonclick.wav" )
	self.Parent.open = false

	if (self.Parent.Accept:GetValue() == "0") then
		LocalPlayer():ConCommand("echo Read the damn MOTD next time.\n")
		LocalPlayer():ConCommand("disconnect\n")
		return
	end

	gui.EnableScreenClicker( !AllMenusClosed() )
end
vgui.Register( "CloseButton", BUTTON2, "MenuButton" ) //motd close button, dont use it for ANYTHING else

local TITLELABEL = {}
function TITLELABEL:Init()
	self.CORNER_SIZE = 10

	self.TEXT_XOFFSET = 3
	self.TEXT_YOFFSET = 5

	self.COLOR = Color(255, 0, 0, 255)
	self.TEXT_COLOR = Color(255, 255, 255, 255)

	self.TEXT = "Default Text"
	self.FONT = "HudHintTextLarge"
	self.ALIGNMENT = TEXT_ALIGN_LEFT

	self:SetZPos(2)
	self:SetSize(240, 25) //default
end

function TITLELABEL:Paint()
	if (self.ALIGNMENT == 1) then
		self.TEXT_XOFFSET = self:GetWide()/2
	end

	draw.RoundedBox( self.CORNER_SIZE, 0, 0, self:GetWide(), self:GetTall(), self.COLOR )
	draw.DrawText( self.TEXT, self.FONT, self.TEXT_XOFFSET, self.TEXT_YOFFSET, self.TEXT_COLOR, self.ALIGNMENT )
	return true
end
vgui.Register( "MenuTitle", TITLELABEL )

F4Menu = vgui.Create( "F4Menu" )
F3Menu = vgui.Create( "F3Menu" )
F2Menu = vgui.Create( "F2Menu" )
F1Menu = vgui.Create( "F1Menu" )

MOTDWindow = vgui.Create( "MOTDWindow" )

AnnouncementWindow = vgui.Create( "Announcement" )

PostGameWindow = vgui.Create( "PostGameScreen" )

//MENU CONRTOL
function AllMenusClosed()
	return (!F1Menu.open && !F2Menu.open && !F3Menu.open && !F4Menu.open)
end

concommand.Add("gb_openf1", function()
	if GAMEMODE.ShowScoreboard then return end

	F1Menu.open = !F1Menu.open
	gui.EnableScreenClicker(!AllMenusClosed())
end)

concommand.Add("gb_openf2", function()
	if GAMEMODE.ShowScoreboard then return end

	F2Menu.open = !F2Menu.open
	gui.EnableScreenClicker(!AllMenusClosed())
end)

concommand.Add("gb_openf3", function()
	if GAMEMODE.ShowScoreboard then return end

	F3Menu.open = !F3Menu.open
	gui.EnableScreenClicker(!AllMenusClosed())
end)

concommand.Add("gb_openf4", function()
	if GAMEMODE.ShowScoreboard then return end

	F4Menu.open = !F4Menu.open
	gui.EnableScreenClicker(!AllMenusClosed())
end)

concommand.Add("gb_openmotd", function()
	MOTD.Window.open = true
end)

net.Receive("gb_announcement", function()
	local time = net.ReadUInt(32)
	local count = net.ReadUInt(32)

	AnnouncementWindow.time = net.ReadInt(8)

	AnnouncementWindow.text = {}
	for i=1, count do
		AnnouncementWindow.text[i] = net.ReadString()
	end

	AnnouncementWindow:SetVisible(true)

	timer.Destroy("Announcement Timer")
	timer.Create("Announcement Timer", 1, AnnouncementWindow.time, function()
		AnnouncementWindow.Timer(AnnouncementWindow)
	end)

	surface.PlaySound("ui/buttonclick.wav")
end)

net.Receive("gb_postgame", function()
	//times
	for i=1, net.ReadUInt(16) do
		PostGameWindow.Times[i] = {}
		PostGameWindow.Times[i][1] = net.ReadEntity()
		PostGameWindow.Times[i][2] = net.ReadUInt(16)
	end

	//healths
	for i=1, net.ReadUInt(16) do
		PostGameWindow.Healths[i] = {}
		PostGameWindow.Healths[i][1] = net.ReadEntity()
		PostGameWindow.Healths[i][2] = net.ReadUInt(16)
	end

	//damages
	for i=1, net.ReadUInt(16) do
		PostGameWindow.Damages[i] = {}
		PostGameWindow.Damages[i][1] = net.ReadEntity()
		PostGameWindow.Damages[i][2] = net.ReadUInt(16)
	end

	PostGameWindow.WinColor = net.ReadColor()
	PostGameWindow.WinText = net.ReadString()

	PostGameWindow:LoadData()
	PostGameWindow:SetVisible(true)
end)