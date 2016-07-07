include( "admin_buttons.lua" )
include( "vote_button.lua" )

local PANEL = {}

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Init()
	self.InfoLabels = {}
	self.InfoLabels[ 1 ] = {}
	self.InfoLabels[ 2 ] = {}
	self.InfoLabels[ 3 ] = {}
	
	self.btnMute = vgui.Create( "suispawnmenuadminbutton", self )
	
	--[[self.btnKick = vgui.Create( "suiplayerkickbutton", self )
	self.btnBan = vgui.Create( "suiplayerbanbutton", self )
	self.btnPBan = vgui.Create( "suiplayerpermbanbutton", self )]]--
	--[[
	self.VoteButtons = {}

	self.VoteButtons[5] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[5]:SetUp( "icon16/wrench.png", "wrench", "Good Builder!" )
	
	self.VoteButtons[4] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[4]:SetUp( "icon16/anchor.png", "anchor", "Slow Builder!" )

	self.VoteButtons[3] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[3]:SetUp( "icon16/palette.png", "palette", "Artistic!" )

	self.VoteButtons[2] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[2]:SetUp( "icon16/information.png", "information", "Informative!" )

	self.VoteButtons[1] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[1]:SetUp( "icon16/group.png", "group", "Team Player!" )


	self.VoteButtons[10] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[10]:SetUp( "icon16/joystick.png", "joystick", "Great Maneuverability!" )

	self.VoteButtons[9] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[9]:SetUp( "icon16/asterisk_orange.png", "asterisk_orange", "Great Offense!" )

	self.VoteButtons[8] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[8]:SetUp( "icon16/shield.png", "shield", "Great Defender!" )

	self.VoteButtons[7] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[7]:SetUp( "icon16/time.png", "time", "Quick Builder!" )

	self.VoteButtons[6] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[6]:SetUp( "icon16/coins.png", "coins", "Big Spender!" )

	
	self.VoteButtons[15] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[15]:SetUp( "icon16/comments.png", "comments", "Talkative!" )

	self.VoteButtons[14] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[14]:SetUp( "icon16/bug.png", "bug", "Gross!" )
	
	self.VoteButtons[13] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[13]:SetUp( "icon16/heart.png", "heart", "Friendly!" )

	self.VoteButtons[12] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[12]:SetUp( "icon16/user_gray.png", "user_gray", "Naughty!" )
	
	self.VoteButtons[11] = vgui.Create( "suispawnmenuvotebutton", self )
	self.VoteButtons[11]:SetUp( "icon16/tux.png", "tux", "Stylish!" )]]--

end

--[[-------------------------------------------------------
   Name: PerformLayout
-------------------------------------------------------]]--

surface.CreateFont( "suiscoreboardcardinfo", {
	font = "DefaultSmall", 
	size = 12, 
	weight = 0
})

function PANEL:SetInfo( column, k, v )
	if ( !v || v == "" ) then v = "N/A" end

	if ( !self.InfoLabels[ column ][ k ] ) then
		self.InfoLabels[ column ][ k ] = {}
		self.InfoLabels[ column ][ k ].Key 	= vgui.Create( "DLabel", self )
		self.InfoLabels[ column ][ k ].Value 	= vgui.Create( "DLabel", self )
		self.InfoLabels[ column ][ k ].Key:SetText( k )
		self.InfoLabels[ column ][ k ].Key:SetTextColor( Color( 0, 0, 0, 255 ) )
		self.InfoLabels[ column ][ k ].Key:SetFont( "suiscoreboardcardinfo" )
		self:InvalidateLayout()
	end
	
	self.InfoLabels[ column ][ k ].Value:SetText( v )
	self.InfoLabels[ column ][ k ].Value:SetTextColor( Color( 0, 0, 0, 255 ) )
	self.InfoLabels[ column ][ k ].Value:SetFont( "suiscoreboardcardinfo" )
	return true
end


/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )
	self.Player = ply
	self:UpdatePlayerData()
end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()
	if not IsValid( self.Player ) then return end

	local rank = "Guest"
	if self.Player:GetUserGroup() == "vip" then
		rank = "Donator"
	elseif self.Player:GetUserGroup() == "moderator" then
		rank = "Moderator"
	elseif self.Player:GetUserGroup() == "admin" then
		rank = "Admin"
	elseif self.Player:GetUserGroup() == "superadmin" then
		rank = "Super Admin"
	end
	
	self:SetInfo( 1, "  Rank: ", rank)
	
	self:SetInfo( 2, "Props:", (self.Player:GetCount( "props" ) or 0 ))
	self:SetInfo( 2, "Thrusters:", (self.Player:GetCount( "thrusters" ) or 0 ))
	self:SetInfo( 2, "Wheels:", (self.Player:GetCount( "wheels" ) or 0 ))
	self:SetInfo( 2, "Weights:", (self.Player:GetCount( "gbots_weights" ) or 0))
	self:SetInfo( 2, "SENTs:", (self.Player:GetCount( "sents" ) or 0))

	if self.Muted == nil or self.Muted ~= self.Player:IsMuted() then
		self.Muted = self.Player:IsMuted()
		if self.Muted then
			self.btnMute.Text = "Unmute"
		else
			self.btnMute.Text = "Mute"
		end
		
		self.btnMute.DoClick = function() self.Player:SetMuted( not self.Muted ) end
	end
	
	self:InvalidateLayout()
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	for _k, column in pairs( self.InfoLabels ) do
		for k, v in pairs( column ) do
			v.Key:SetTextColor( Color( 50, 50, 50, 255 ) )
			v.Value:SetTextColor( Color( 80, 80, 80, 255 ) )
		end
	end
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()
	if self.PlayerUpdate and self.PlayerUpdate > CurTime() then return end
	self.PlayerUpdate = CurTime() + 0.25
	
	self:UpdatePlayerData()
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	local x = 5

	for column, column in pairs( self.InfoLabels ) do
		local y = 0
		local RightMost = 0
	
		for k, v in pairs( column ) do
			v.Key:SetPos( x, y )
			v.Key:SizeToContents()
			
			v.Value:SetPos( x + 60 , y )
			v.Value:SizeToContents()
			
			y = y + v.Key:GetTall() + 2
			
			RightMost = math.max( RightMost, v.Value.x + v.Value:GetWide() )
		end
		
		--x = RightMost + 10
		if(x<100) then
		x = x + 205
		else
		x = x + 115
		end
	end
	
	if self.Player == LocalPlayer() then
		self.btnMute:SetVisible( false )
	else
		self.btnMute:SetVisible( true )
		self.btnMute:SetSize( 46, 20 )
		self.btnMute:SetPos( self:GetWide() - 175, 0 )
	end
	
	--[[if ( !self.Player  || !self.Player:IsAdmin() || !self.Player == !LocalPlayer() || !LocalPlayer():IsAdmin() ) then 
		self.btnKick:SetVisible( false )
		self.btnBan:SetVisible( false )
		self.btnPBan:SetVisible( false )
	else
		self.btnKick:SetVisible( true )
		self.btnBan:SetVisible( true )
		self.btnPBan:SetVisible( true )
	
		self.btnKick:SetPos( self:GetWide() - 175, 85 - (22 * 2) )
		self.btnKick:SetSize( 46, 20 )

		self.btnBan:SetPos( self:GetWide() - 175, 85 - (22 * 1) )
		self.btnBan:SetSize( 46, 20 )
		
		self.btnPBan:SetPos( self:GetWide() - 175, 85 - (22 * 0) )
		self.btnPBan:SetSize( 46, 20 )
	
	end]]--
	--[[
	for k, v in ipairs( self.VoteButtons ) do
		v:InvalidateLayout()
		if k < 6 then
			v:SetPos( self:GetWide() -  k * 25, 0 )
		elseif k < 11 then
			v:SetPos( self:GetWide() -  (k-5) * 25, 36 )
		else 
			v:SetPos( self:GetWide() -  (k-10) * 25, 72 )
		end
		v:SetSize( 20, 32 )
	end]]
end

function PANEL:Paint(w,h)
	return true
end

vgui.Register( "suiscoreplayerinfocard", PANEL, "Panel" )