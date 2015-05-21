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

	self:SetSize(self:GetWide(),  40 + (#self.text * 15) + 10)
	draw.RoundedBox( self.CORNER_SIZE, 0, 0, self:GetWide(), self:GetTall(), Color(self.MAIN_COLOR.r, self.MAIN_COLOR.g, self.MAIN_COLOR.b, self.alpha) )
	draw.RoundedBox( self.CORNER_SIZE, 5, 5, self:GetWide() - 10, 25, Color(self.TITLE_COLOR.r, self.TITLE_COLOR.g, self.TITLE_COLOR.b, self.alpha) )
	draw.RoundedBox( self.CORNER_SIZE, 5, 35, self:GetWide() - 10, self:GetTall() - 40, Color(self.TEXT_AREA_COLOR.r, self.TEXT_AREA_COLOR.g, self.TEXT_AREA_COLOR.b, self.alpha) )
	draw.DrawText( "-Announcement-", self.FONT, self:GetWide()/2, 10, Color(self.TITLE_TEXT_COLOR.r, self.TITLE_TEXT_COLOR.g, self.TITLE_TEXT_COLOR.b, self.alpha), TEXT_ALIGN_CENTER )

	for k,v in pairs(self.text) do
		draw.DrawText( v, self.FONT, self:GetWide()/2, 40 + ((k - 1) * 15), Color(self.TEXT_COLOR.r, self.TEXT_COLOR.g, self.TEXT_COLOR.b, self.alpha), TEXT_ALIGN_CENTER )
	end

	return true
end
vgui.Register("Announcement", ANNOUNCEMENT_WINDOW)
