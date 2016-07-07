include( "player_infocard.lua" )

-- checking for utime for the hours
utimecheck = false
if file.Exists("autorun/cl_utime.lua", "LUA") then 
	utimecheck = true
end


-- checking for ulib for the team names
ulibcheck = false
if file.Exists("ulib/cl_init.lua", "LUA") then 
	ulibcheck = true
end

local texGradient = surface.GetTextureID( "gui/center_gradient" )

--[[local texRatings = {}
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

surface.GetTextureID( "gui/silkicons/emoticon_smile" )]]--

local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint( w, h )
	if not IsValid( self.Player ) then
		self:Remove()
		SCOREBOARD:InvalidateLayout()
		return 
	end 
	
	local color = Color( 100, 100, 100, 255 )

	if self.Armed then
		color = Color( 125, 125, 125, 255 )
	end
	
	if self.Selected then
		color = Color( 125, 125, 125, 255 )
	end
	
	if self.Player:Team() == TEAM_CONNECTING then
		color = Color( 100, 100, 100, 155 )
	elseif IsValid( self.Player ) then
		if self.Player:Team() == TEAM_UNASSIGNED then
			color = Color( 100, 100, 100, 255 )
		else	
			color = team.GetColor( self.Player:Team() )
		end
	elseif self.Player:IsAdmin() then
		color = Color( 255, 155, 0, 255 )
	end
	
	if self.Player == LocalPlayer() then
		color = team.GetColor( self.Player:Team() )
	end

	if self.Open or self.Size ~= self.TargetSize then
		draw.RoundedBox( 4, 18, 16, self:GetWide() - 36, self:GetTall() - 16, color )
		draw.RoundedBox( 4, 20, 16, self:GetWide() - 40, self:GetTall() - 16 - 2, Color( 225, 225, 225, 150 ) )
		
		surface.SetTexture( texGradient )
		surface.SetDrawColor( 255, 255, 255, 75 )
		surface.DrawTexturedRect( 20, 16, self:GetWide(), self:GetTall() - 18 )
	end
	
	draw.RoundedBox( 4, 18, 0, self:GetWide() - 36, 38, color )
	
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 25 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), 38 ) 
	
	--[[surface.SetTexture( self.texRating )
	surface.SetDrawColor( 255, 255, 255, 255 )
	-- surface.DrawTexturedRect( 20, 4, 16, 16 )
	surface.DrawTexturedRect( 56, 3, 16, 16 )]]--
	
	return true
end

--[[-------------------------------------------------------
   Name: SetPlayer
-------------------------------------------------------]]--
function PANEL:SetPlayer( ply )
	self.Player = ply
	self.infoCard:SetPlayer( ply )
	self:UpdatePlayerData()
	self.imgAvatar:SetPlayer( ply )
end

--[[function PANEL:CheckRating( name, count )
	if self.Player:GetNetworkedInt( "Rating." .. name, 0 ) > count then
		count = self.Player:GetNetworkedInt( "Rating." .. name, 0 )
		self.texRating = texRatings[ name ]
	end
	return count
end]]

--[[---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------]]--
function PANEL:UpdatePlayerData()
	local ply = self.Player
	if not IsValid( ply ) then return end
	
	self.lblName:SetText( ply:Nick() )
	--if ulibcheck then self.lblTeam:SetText( team.GetName( ply:Team() ) ) end
	if utimecheck then self.lblHours:SetText( math.floor( ply:GetUTimeTotalTime() / 3600 ) ) end
	self.lblHealth:SetText( ply:GetVar("gb_corehealth", 0) )
	self.lblPing:SetText( ply:Ping() )


	
	-- Work out what icon to draw
	--[[self.texRating = surface.GetTextureID( "gui/silkicons/emoticon_smile" )

	self.texRating = texRatings[ 'none' ]
	local count = 0
	
	count = self:CheckRating( 'wrench', count )
	count = self:CheckRating( 'anchor', count )
	count = self:CheckRating( 'palette', count )
	count = self:CheckRating( 'information', count )
	count = self:CheckRating( 'group', count )
	count = self:CheckRating( 'joystick', count )
	count = self:CheckRating( 'asterisk_orange', count )
	count = self:CheckRating( 'shield', count )
	count = self:CheckRating( 'time', count )
	count = self:CheckRating( 'coins', count )
	count = self:CheckRating( 'comments', count )
	count = self:CheckRating( 'bug', count )
	count = self:CheckRating( 'heart', count )
	count = self:CheckRating( 'user_gray', count )
	count = self:CheckRating( 'tux', count )]]
end

--[[-------------------------------------------------------
   Name: Init
-------------------------------------------------------]]--
function PANEL:Init()
	self.Size = 38
	self:OpenInfo( false )
	
	self.infoCard	= vgui.Create( "suiscoreplayerinfocard", self )
	
	self.lblName 	= vgui.Create( "DLabel", self )
	--if ulibcheck then self.lblTeam 	= vgui.Create( "DLabel", self ) end
	if utimecheck then  self.lblHours 	= vgui.Create( "DLabel", self ) end
	self.lblHealth 	= vgui.Create( "DLabel", self )
	self.lblPing 	= vgui.Create( "DLabel", self )
	self.lblPing:SetText( "9999" )
	
	self.btnAvatar = vgui.Create( "DButton", self )
	self.btnAvatar.DoClick = function() self.Player:ShowProfile() end
	self.imgAvatar = vgui.Create( "AvatarImage", self.btnAvatar )
	
	-- If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled( false )
	--if ulibcheck then self.lblTeam:SetMouseInputEnabled( false ) end
	if utimecheck then self.lblHours:SetMouseInputEnabled( false ) end
	self.lblHealth:SetMouseInputEnabled( false )
	self.lblPing:SetMouseInputEnabled( false )
	self.imgAvatar:SetMouseInputEnabled( false )
end

--[[-------------------------------------------------------
   Name: ApplySchemeSettings
-------------------------------------------------------]]--
function PANEL:ApplySchemeSettings()
	self.lblName:SetFont( "HudHintTextLarge" )
	--if ulibcheck then self.lblTeam:SetFont( "suiscoreboardplayername" ) end
	if utimecheck then self.lblHours:SetFont( "suiscoreboardplayername" ) end
	self.lblHealth:SetFont( "Trebuchet24" )
	self.lblPing:SetFont( "Trebuchet24" )

	local tc = team.GetColor( LocalPlayer():Team() )
	
	self.lblName:SetTextColor( color_white )
	--if ulibcheck then self.lblTeam:SetTextColor( color_black ) end
	if utimecheck then self.lblHours:SetTextColor( color_black ) end
	self.lblHealth:SetTextColor( Color( 180, 180, 180 ) )
	self.lblPing:SetTextColor( Color( 180, 180, 180 ) )
end

--[[-------------------------------------------------------
   Name: DoClick
-------------------------------------------------------]]--
function PANEL:DoClick()
	if self.Open then
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	else
		surface.PlaySound( "ui/buttonclick.wav" )
	end
	self:OpenInfo( not self.Open )
end

--[[-------------------------------------------------------
   Name: OpenInfo
-------------------------------------------------------]]--
function PANEL:OpenInfo( open )
	if open then
		self.TargetSize = 154
	else
		self.TargetSize = 38
	end
	self.Open = open
end

--[[-------------------------------------------------------
   Name: Think
-------------------------------------------------------]]--
function PANEL:Think()
	if self.Size ~= self.TargetSize then
		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	end
	
	if not self.PlayerUpdate or self.PlayerUpdate < CurTime() then
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
	end
end

--[[-------------------------------------------------------
   Name: PerformLayout
-------------------------------------------------------]]--
function PANEL:PerformLayout()
	self:SetSize( self:GetWide(), self.Size )
	
	self.btnAvatar:SetPos( 21, 4 )
	self.btnAvatar:SetSize( 32, 32 )
 	self.imgAvatar:SetSize( 32, 32 )
	
	self.lblName:SizeToContents()
	--if ulibcheck then self.lblTeam:SizeToContents() end
	if utimecheck then self.lblHours:SizeToContents() end
	self.lblHealth:SizeToContents()
	self.lblPing:SizeToContents()
	self.lblPing:SetWide( 100 )
	
	self.lblName:SetPos( 60, 5 )
	--if ulibcheck then self.lblTeam:SetPos( self:GetParent():GetWide() - 45 * 10.2 - 6, 3 ) end
	if utimecheck then self.lblHours:SetPos( self:GetParent():GetWide() - 45 * 7.5 - 6, 3 ) end
	self.lblHealth:SetPos( self:GetParent():GetWide() - 180, 3 )
	self.lblPing:SetPos( self:GetParent():GetWide() - 45 - 6, 3 )
	
	if self.Open or self.Size ~= self.TargetSize then
		self.infoCard:SetVisible( true )
		self.infoCard:SetPos( 18, self.lblName:GetTall() + 27 )
		self.infoCard:SetSize( self:GetWide() - 36, self:GetTall() - self.lblName:GetTall() + 5 )
	else
		self.infoCard:SetVisible( false )
	end
end

--[[-------------------------------------------------------
   Name: HigherOrLower
-------------------------------------------------------]]--
function PANEL:HigherOrLower( row )
	if self.Player:Team() == TEAM_CONNECTING then return false end
	if row.Player:Team() == TEAM_CONNECTING then return true end
	
	if self.Player:Team() ~= row.Player:Team() then
		return self.Player:Team() < row.Player:Team()
	end
end
vgui.Register( "suiscoreplayerrow", PANEL, "DButton" )