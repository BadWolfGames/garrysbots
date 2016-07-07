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
	self.WinText = "No contest!"
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
