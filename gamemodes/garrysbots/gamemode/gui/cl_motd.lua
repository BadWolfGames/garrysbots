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
	button1.Parent = self //I shouldnt have to do ths...
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
