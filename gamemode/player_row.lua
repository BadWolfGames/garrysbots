include( "player_infocard.lua" )

//surface.CreateFont( "verdana", 16, 400, true, false, "SuiScoreboardPlayerName" )

surface.CreateFont( "SuiScoreboardPlayerName", {
	font = "verdana",
	size = 16,
	weight = 400
})

local texGradient = surface.GetTextureID( "gui/center_gradient" )

local texRatings = {}
texRatings[ 'none' ] 		= surface.GetTextureID( "gui/silkicons/user" )
texRatings[ 'smile' ] 		= surface.GetTextureID( "gui/silkicons/emoticon_smile" )
texRatings[ 'lol' ] 		= surface.GetTextureID( "gui/silkicons/emoticon_smile" )
texRatings[ 'gay' ] 		= surface.GetTextureID( "gui/gmod_logo" )
texRatings[ 'stunter' ] 	= surface.GetTextureID( "gui/inv_corner16" )
texRatings[ 'god' ] 		= surface.GetTextureID( "gui/gmod_logo" )
texRatings[ 'curvey' ] 		= surface.GetTextureID( "gui/corner16" )
texRatings[ 'best_landvehicle' ]	= surface.GetTextureID( "gui/faceposer_indicator" )
texRatings[ 'best_airvehicle' ] 		= surface.GetTextureID( "gui/arrow" )
texRatings[ 'naughty' ] 	= surface.GetTextureID( "gui/silkicons/exclamation" )
texRatings[ 'friendly' ]	= surface.GetTextureID( "gui/silkicons/user" )
texRatings[ 'informative' ]	= surface.GetTextureID( "gui/info" )
texRatings[ 'love' ] 		= surface.GetTextureID( "gui/silkicons/heart" )
texRatings[ 'artistic' ] 	= surface.GetTextureID( "gui/silkicons/palette" )
texRatings[ 'gold_star' ] 	= surface.GetTextureID( "gui/silkicons/star" )
texRatings[ 'builder' ] 	= surface.GetTextureID( "gui/silkicons/wrench" )

surface.GetTextureID( "gui/silkicons/emoticon_smile" )
local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()

	local color = Color( 100, 100, 100, 255 )

	if ( self.Armed ) then
		color = Color( 125, 125, 125, 255 )
	end
	
	if ( self.Selected ) then
		color = Color( 125, 125, 125, 255 )
	end
	
	if ( self.Player:Team() == TEAM_CONNECTING ) then
		color = Color( 100, 100, 100, 155 )
	elseif ( self.Player:IsValid() ) then
		//if ( team.GetName(self.Player:Team() ) == Unassigned) then
		if ( tostring(self.Player:Team()) == tostring("1001") ) then
			color = Color( 100, 100, 100, 255 )
		else	
			tcolor = team.GetColor(self.Player:Team())
			color = Color(tcolor.r,tcolor.g,tcolor.b,225)
			
		end
	elseif ( self.Player:IsAdmin() ) then
		color = Color( 255, 155, 0, 255 )
	end
	
	if ( self.Player == LocalPlayer() ) then
	
		tcolor = team.GetColor(self.Player:Team())
		color = Color(tcolor.r,tcolor.g,tcolor.b,255)
	
	end

	if ( self.Open || self.Size != self.TargetSize ) then
	
		draw.RoundedBox( 4, 18, 16, self:GetWide()-36, self:GetTall() - 16, color )
		draw.RoundedBox( 4, 20, 16, self:GetWide()-40, self:GetTall() - 16 - 2, Color( 225, 225, 225, 150 ) )
		
		surface.SetTexture( texGradient )
		surface.SetDrawColor( 255, 255, 255, 100 )
		surface.DrawTexturedRect( 20, 16, self:GetWide()-40, self:GetTall() - 16 - 2 ) 
	
	end
	
	draw.RoundedBox( 4, 18, 0, self:GetWide()-36, 24, color )
	
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 150 )
	surface.DrawTexturedRect( 0, 0, self:GetWide()-36, 24 ) 
	
	surface.SetTexture( self.texRating )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 20, 4, 16, 16 ) 	
	
	return true

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )

	self.Player = ply
	
	self.infoCard:SetPlayer( ply )
	
	self:UpdatePlayerData()

end

function PANEL:CheckRating( name, count )

	if ( self.Player:GetNetworkedInt( "Rating."..name, 0 ) > count ) then
		count = self.Player:GetNetworkedInt( "Rating."..name, 0 )
		self.texRating = texRatings[ name ]
	end
	
	return count

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()

	if ( !self.Player ) then return end
	if ( !self.Player:IsValid() ) then return end

	// self.lblName:SetText( team.GetName(self.Player:Team()) .." - ".. self.Player:Nick()  )
	self.lblName:SetText( self.Player:Nick() )
	self.lblTeam:SetText( team.GetName(self.Player:Team()) )
	self.lblHealth:SetText( self.Player:GetVar("gb_corehealth", 0) )
	self.lblTime:SetText( string.FormattedTime( self.Player:GetVar("gb_time", 0), "%02i:%02i") )
	self.lblPing:SetText( self.Player:Ping() )


	
	
	// Work out what icon to draw
	self.texRating = surface.GetTextureID( "gui/silkicons/emoticon_smile" )
	
	self.texRating = texRatings[ 'none' ]
	local count = 0
	
	count = self:CheckRating( 'smile', count )
	count = self:CheckRating( 'love', count )
	count = self:CheckRating( 'artistic', count )
	count = self:CheckRating( 'gold_star', count )
	count = self:CheckRating( 'builder', count )
	count = self:CheckRating( 'lol', count )
	count = self:CheckRating( 'gay', count )
	count = self:CheckRating( 'curvey', count )
	count = self:CheckRating( 'god', count )
	count = self:CheckRating( 'stunter', count )
	count = self:CheckRating( 'best_landvehicle', count )
	count = self:CheckRating( 'best_airvehicle', count )
	count = self:CheckRating( 'friendly', count )
	count = self:CheckRating( 'informative', count )
	count = self:CheckRating( 'naughty', count )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Init()

	self.Size = 24
	self:OpenInfo( false )
	
	self.infoCard	= vgui.Create( "SuiScorePlayerInfoCard", self )
	
	self.lblName 	= vgui.Create( "Label", self )
	self.lblTeam 	= vgui.Create( "Label", self )
	self.lblHealth 	= vgui.Create( "Label", self )
	self.lblTime 	= vgui.Create( "Label", self )
	self.lblPing 	= vgui.Create( "Label", self )
	
	// If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled( false )
	self.lblTeam:SetMouseInputEnabled( false )
	self.lblHealth:SetMouseInputEnabled( false )
	self.lblTime:SetMouseInputEnabled( false )
	self.lblPing:SetMouseInputEnabled( false )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	self.lblName:SetFont( "SuiScoreboardPlayerName" )
	self.lblTeam:SetFont( "SuiScoreboardPlayerName" )
	self.lblHealth:SetFont( "SuiScoreboardPlayerName" )
	self.lblTime:SetFont( "SuiScoreboardPlayerName" )
	self.lblPing:SetFont( "SuiScoreboardPlayerName" )
	
	self.lblName:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblTeam:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblHealth:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblTime:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblPing:SetFGColor( Color( 0, 0, 0, 255 ) )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:DoClick()

	if ( self.Open ) then
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	else
		surface.PlaySound( "ui/buttonclick.wav" )
	end

	self:OpenInfo( !self.Open )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:OpenInfo( bool )

	if ( bool ) then
		self.TargetSize = 140
	else
		self.TargetSize = 24
	end
	
	self.Open = bool

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()

	if ( self.Size != self.TargetSize ) then
	
		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	//	self:GetParent():InvalidateLayout()
	
	end
	
	if ( !self.PlayerUpdate || self.PlayerUpdate < CurTime() ) then
	
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
		
	end

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( self:GetWide(), self.Size )
	
	self.lblName:SizeToContents()
	self.lblName:SetPos( 38, 3 )
	self.lblTeam:SizeToContents()
	local COLUMN_SIZE = 45
	
	self.lblPing:SetPos( self:GetWide() - COLUMN_SIZE * 1, 0 )
	self.lblTime:SetPos( self:GetWide() - COLUMN_SIZE * 3.4, 0 )
	self.lblHealth:SetPos( self:GetWide() - COLUMN_SIZE * 5.4, 0 )
	self.lblTeam:SetPos( self:GetWide() - COLUMN_SIZE * 8.2, 3 )
	
	if ( self.Open || self.Size != self.TargetSize ) then
	
		self.infoCard:SetVisible( true )
		self.infoCard:SetPos( 18, self.lblName:GetTall() + 10 )
		self.infoCard:SetSize( self:GetWide() - 36, self:GetTall() - self.lblName:GetTall() - 10 )
	
	else
	
		self.infoCard:SetVisible( false )
	
	end
	
	

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:HigherOrLower( row )

	if ( self.Player:Team() == TEAM_CONNECTING ) then return false end
	if ( row.Player:Team() == TEAM_CONNECTING ) then return true end
	
	if ( self.Player:Team() ~= row.Player:Team() ) then
		return self.Player:Team() < row.Player:Team()
	end
	
	if ( self.Player:GetNetworkedInt("gb_time") == row.Player:GetNetworkedInt("gb_time") ) then
	
		return self.Player:GetNetworkedInt("gb_corehealth") > row.Player:GetNetworkedInt("gb_corehealth")
	
	end

	return self.Player:GetNetworkedInt("gb_time") > row.Player:GetNetworkedInt("gb_time")

end


vgui.Register( "SuiScorePlayerRow", PANEL, "Button" )