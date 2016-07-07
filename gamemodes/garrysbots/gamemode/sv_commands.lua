hook.Add("KeyPress", "gb_KeyPressedHook", function(ply, key)
	local healthobjs = {"prop_physics"}

	if(key == 32) then
		local traceres = ply:GetEyeTrace()
		local ent = traceres.Entity
		local healthobjs = {"prop_physics"}

		if (ent:IsValid() || !ent:IsWorld() || !ent:IsPlayer() ) then
			local mass = ent:GetPhysicsObject():GetMass()
			if table.HasValue( healthobjs, ent:GetClass() ) then
				ply:PrintMessage(HUD_PRINTTALK, "Prop Health: " .. tostring(ent.aHealth).."  ||  Prop Mass: " .. mass )
			end
		end
	else
		return
	end
end)

concommand.Add("gm_giveswep", function(ply, cmd, args)
	return
end)

concommand.Add("gm_spawnsent", function(ply, cmd, args)
	return
end)

concommand.Add("gm_spawnsent2", function(ply, cmd, args)
	local AllowedSENTs = { "gb_cam", "gb_core" }
	if ( args[1] == nil || !table.HasValue( AllowedSENTs, args[1] ) || gb_CurrentRound != 1 ) then return end

	local sent = scripted_ents.GetStored( args[1] )
	if (sent == nil) then return end

	sent = sent.t

	if (!sent.SpawnFunction) then return end

	if ( !gamemode.Call( "PlayerSpawnSENT", ply, args[1] ) ) then return end

	local vStart = ply:GetShootPos()
	local vForward = ply:GetAimVector()
	local trace = {}
	trace.start = vStart
	trace.endpos = vStart + (vForward * 2048)
	trace.filter = ply
	local tr = util.TraceLine( trace )
	local entity = sent:SpawnFunction( ply, tr )

	if ( entity ) then
		gamemode.Call( "PlayerSpawnedSENT", ply, entity )

		undo.Create("SENT")
			undo.SetPlayer(ply)
			undo.AddEntity(entity)
		undo.Finish( "Scripted Entity ("..tostring(args[1])..")" )

		ply:AddCleanup( "sents", entity )		
		entity:SetVar( "Founder", ply )
	end
end)

concommand.Add("gmod_spawnnpc", function(ply, cmd, args)
	return
end)

concommand.Add("gm_spawnvehicle", function(ply, cmd, args)
	return
end)

concommand.Add("gb_togglecam", function(ply, cmd, args)
	local spectating = ply:GetNetworkedBool("spectating")
	local cam = ply:GetNetworkedEntity("gb_cam")

	if(spectating) then
		if(gb_CurrentRound == 1) then
			ply:UnSpectate()
			ply:Give( "gmod_tool" )
			ply:Give( "gmod_camera" )
			ply:Give( "weapon_physgun" )
			ply:SetNetworkedBool("spectating", false)
		else
			ply:UnSpectate()
			ply:Spectate( OBS_MODE_ROAMING )
			ply:SetNetworkedBool("spectating", false)
		end
		ply:SetEyeAngles(Angle(ply:EyeAngles().p, ply:EyeAngles().y, 0))

	elseif(!spectating) then
		if(cam:IsValid()) then
			ply:UnSpectate()
			ply:Spectate( OBS_MODE_CHASE )
			ply:SpectateEntity(cam)
			ply:StripWeapons()
			ply:SetNetworkedBool("spectating", true)
		else
			ply:PrintMessage(HUD_PRINTTALK, "You do not have a camera!")	
		end
	end
end)

concommand.Add("gb_changeteam", function(ply, cmd, args)
	if gb_CurrentRound != 1 then
		ply:ChatPrint("You cannot change teams during the fight.")
		return
	end

	if (team.NumPlayers(1) == team.NumPlayers(2)) then
		RemoveRobot(ply)
		ply:Kill()

		if args[1] == "red" then
			ply:SetTeam( 1 )
		elseif args[1] == "blue" then
			ply:SetTeam( 2 )
		end

		return

	elseif (team.NumPlayers(1) < team.NumPlayers(2)) then
		if args[1] == "red" then
			RemoveRobot(ply)
			ply:Kill()
			ply:SetTeam( 1 )

			return
		end

	elseif (team.NumPlayers(1) > team.NumPlayers(2)) then
		if args[1] == "blue" then
			RemoveRobot(ply)
			ply:Kill()
			ply:SetTeam( 2 )

			return
		end
	end

	ply:ChatPrint("There are too many players on that team.")
end)

concommand.Add("gb_forfeit", function(ply, cmd, args)
	if gb_CurrentRound == 1 then
		ply:ChatPrint("You can only forfeit during the fight.")
		return
	end

	DestroyRobot(ply)
end)

hook.Add("PlayerNoClip", "gb_Noclip", function(ply, bool)
	local spectating = ply:GetNetworkedBool("spectating")
	print(spectating)

	if spectating then
		return false
	end
end)

concommand.Add("gethealth", function(ply, cmd, args)
	local traceres = ply:GetEyeTrace()
	local ent = traceres.Entity
	local healthobjs = {"prop_physics"}

	if (ent:IsValid() || !ent:IsWorld() || !ent:IsPlayer() ) then
		local mass = ent:GetPhysicsObject():GetMass()
		if table.HasValue( healthobjs, ent:GetClass() ) then
			ply:PrintMessage(HUD_PRINTTALK, "Prop Health: " .. tostring(ent.aHealth).."  ||  Prop Mass: " .. mass )
		end
	end

end)
