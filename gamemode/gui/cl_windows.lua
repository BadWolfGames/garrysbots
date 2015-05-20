//Base menu
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

//F1 Menu
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

//F2 Menu
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

//F3 Menu
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

//F4 Menu
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