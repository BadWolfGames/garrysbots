/*-----------------
	Global VGUI Defines
-----------------*/
local BUTTON = {}
function BUTTON:Init()
	self.CORNER_SIZE = 10

	self.TEXT_XOFFSET = 7
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
	CloseAllMenus()
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

/*-----------------
	Menu Functions
-----------------*/
F4Menu = vgui.Create( "F4Menu" )
F3Menu = vgui.Create( "F3Menu" )
F2Menu = vgui.Create( "F2Menu" )
F1Menu = vgui.Create( "F1Menu" )

if !MOTDWindow && !IsValid(MOTDWindow) then
	MOTDWindow = vgui.Create( "MOTDWindow" )
end
AnnouncementWindow = vgui.Create( "Announcement" )
PostGameWindow = vgui.Create( "PostGameScreen" )

//MENU CONRTOL
function AllMenusClosed()
	return (!F1Menu.open && !F2Menu.open && !F3Menu.open && !F4Menu.open)
end

function CloseAllMenus()
	F1Menu.open = false F2Menu.open = false F3Menu.open = false F4Menu.open = false
	gui.EnableScreenClicker(false)
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
	MOTDWindow.open = true
end)

net.Receive("gb_announcement", function()
	local time = net.ReadUInt(32)
	local count = net.ReadUInt(32)

	AnnouncementWindow.time = time

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
	if IsValid(PostGameWindow) then
		--times
		for i=1, net.ReadUInt(16) do
			PostGameWindow.Times[i] = {}
			PostGameWindow.Times[i][1] = net.ReadEntity()
			PostGameWindow.Times[i][2] = net.ReadUInt(16)
		end

		--healths
		for i=1, net.ReadUInt(16) do
			PostGameWindow.Healths[i] = {}
			PostGameWindow.Healths[i][1] = net.ReadEntity()
			PostGameWindow.Healths[i][2] = net.ReadUInt(16)
		end

		--damages
		for i=1, net.ReadUInt(16) do
			PostGameWindow.Damages[i] = {}
			PostGameWindow.Damages[i][1] = net.ReadEntity()
			PostGameWindow.Damages[i][2] = net.ReadUInt(16)
		end

		PostGameWindow.WinColor = net.ReadColor()
		PostGameWindow.WinText = net.ReadString()

		PostGameWindow:LoadData()
		PostGameWindow:SetVisible(true)
		timer.Simple(25,function()
			if IsValid(PostGameWindow) then
				PostGameWindow:SetVisible(false)
				PostGameWindow:Remove()		
			end	
		end)
	end
end)