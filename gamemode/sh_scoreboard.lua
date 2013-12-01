	varhost = CreateConVar( 'sb_host' , gb_sb_top , { FCVAR_REPLICATED, FCVAR_ARCHIVE , FCVAR_NOTIFY } )
	varbottom = CreateConVar( 'sb_bottom' , gb_sb_middle, { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
	vardesc = CreateConVar( 'sb_desc', gb_sb_bottom, { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
	varlogo = CreateConVar( 'sb_logo', "gb", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
	varlogox = CreateConVar( 'sb_logoX', "30", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
	varlogoy = CreateConVar( 'sb_logoY', "9", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
	varlogosize = CreateConVar( 'sb_logosize', "75", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )

if SERVER then
	AddCSLuaFile( "sui_scoreboard/admin_buttons.lua" )
	AddCSLuaFile( "sui_scoreboard/cl_tooltips.lua" )
	AddCSLuaFile( "sui_scoreboard/player_frame.lua" )
	AddCSLuaFile( "sui_scoreboard/player_infocard.lua" )
	AddCSLuaFile( "sui_scoreboard/player_row.lua" )
	AddCSLuaFile( "sui_scoreboard/scoreboard.lua" )
	AddCSLuaFile( "sui_scoreboard/vote_button.lua" )

	include( "sui_scoreboard/rating.lua" )
	
else
	include( "sui_scoreboard/scoreboard.lua" )

	SuiScoreBoard = nil
	
	timer.Simple( 1.5, function()
		
		function GAMEMODE:CreateScoreboard()
		
			if ( ScoreBoard ) then
			
				ScoreBoard:Remove()
				ScoreBoard = nil
				
			end
			
			SuiScoreBoard = vgui.Create( "suiscoreboard" )
			
			return true

		end
		
		function GAMEMODE:ScoreboardShow()
			if !AllMenusClosed() then return end //dont break my GUI

			if not SuiScoreBoard then
				self:CreateScoreboard()
			end

			GAMEMODE.ShowScoreboard = true
			gui.EnableScreenClicker( true )

			SuiScoreBoard:SetVisible( true )
			SuiScoreBoard:UpdateScoreboard( true )
			
			return true

		end
		
		function GAMEMODE:ScoreboardHide()
			if !GAMEMODE.ShowScoreboard then return end

			GAMEMODE.ShowScoreboard = false
			gui.EnableScreenClicker( false )

			SuiScoreBoard:SetVisible( false )
			
			return true
			
		end
		
	end )
end