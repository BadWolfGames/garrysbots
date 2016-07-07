local ply = FindMetaTable( "Player" )

function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )

	if (team.NumPlayers(2) > team.NumPlayers(1)) then
		ply:SetTeam( 1 )
	elseif (team.NumPlayers(2) < team.NumPlayers(1)) then
		ply:SetTeam( 2 )
	else
		ply:SetTeam( math.random(1,2) )
	end

	if gb_CurrentRound != 1 then
		ply:StripWeapons()
		ply:Spectate( OBS_MODE_ROAMING )
	end

	ply:SetVar("DamageDelt", 0)

	net.Start("gb_timercountdown")
		net.WriteInt(gb_RoundTimer, 32)
	net.Send(ply)
	net.Start("gb_changeround")
		net.WriteInt(gb_CurrentRound, 32)
	net.Send(ply)
	net.Start("gb_updateteamcores")
		net.WriteInt(gb_NumRedCores, 32)
		net.WriteInt(gb_NumBlueCores, 32)
	net.Send(ply)

end

function GM:PlayerSpawn( ply )
	self.BaseClass:PlayerSpawn( ply )
	ply:ShouldDropWeapon(false)

	if gb_CurrentRound != 1 then
		local cam = ply:GetNetworkedEntity("gb_cam")
		if(cam:IsValid()) then
			ply:Spectate( OBS_MODE_CHASE )
			ply:SpectateEntity(cam)
		else
			ply:Spectate( OBS_MODE_ROAMING )
		end
		ply:StripWeapons()
	end
end

function GM:PlayerLoadout(ply)
	if gb_CurrentRound == 1 then
		ply:Give( "gmod_tool" )
		ply:Give( "gmod_camera" )
		ply:Give( "weapon_physgun" )
	end
	return true
end

function GM:PlayerDisconnected( ply )
	RemoveRobot( ply )
end

function GM:PlayerSelectSpawn(ply)
	if ply:Team() == 2 then
		spawns = ents.FindByClass( "info_player_blue" )
		local randomspawn = math.random(#spawns)
		return spawns[randomspawn]
	
	elseif ply:Team() == 1 then
		spawns = ents.FindByClass( "info_player_red" )
		local randomspawn = math.random(#spawns)
		return spawns[randomspawn]
	end
end