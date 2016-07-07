function CheckCores()
	if gb_CurrentRound != 2 then return end

	if (gb_NumBlueCores <= 0 or gb_NumRedCores <= 0) then
		timer.Simple(3,function()
			GameOver()
		end)
	end
end

function ChangeRound(round)
	gb_CurrentRound = round

	net.Start("gb_changeround")
		net.WriteUInt(round, 32)
	net.Broadcast()

	SyncTime()
end

function StartFight()
	if ( gb_NumBlueCores <= 0 or gb_NumRedCores <= 0 ) then return end
	gb_RoundTimer = gb_FightTime
	ChangeRound(2)

	Announcement({"FIGHT!"}, 5)

	-- Put everyone in spectator mode
	local allplayers = player.GetAll()
	for k, v in pairs(allplayers) do
		-- Put them into spectator mode
		local cam = v:GetNetworkedEntity("gb_cam")

		if gb_RoundSpecAll == true then
			if(cam:IsValid()) then
				v:Spectate( OBS_MODE_CHASE )
				v:SpectateEntity(cam)
				v:StripWeapons()
				v:SetNetworkedBool("spectating", true)
			else
				v:Spectate( OBS_MODE_ROAMING )
				v:StripWeapons()
				v:SetNetworkedBool("spectating", false)
			end
		else
			if v:GetNetworkedEntity("gb_core"):IsValid() then
				if(cam:IsValid()) then
					v:Spectate( OBS_MODE_CHASE )
					v:SpectateEntity(cam)
					v:StripWeapons()
					v:SetNetworkedBool("spectating", true)
				else
					v:Spectate( OBS_MODE_ROAMING )
					v:StripWeapons()
					v:SetNetworkedBool("spectating", false)
				end
			end
		end
	end

	-- Teleport all the robots into the arena
	robotspawns = ents.FindByClass("info_robot")

	for k, v in pairs(allplayers) do
		local core = v:GetNetworkedEntity("gb_core")

		if(core:IsValid()) then
			if (#robotspawns <= 0) then break end --no more spawns...

			local randomspawn = math.random(#robotspawns)
			local spawnent = table.remove(robotspawns, randomspawn)
			local spawnpos = spawnent:GetPos()
			local corepos = core:GetPos()
			local const = constraint.GetAllConstrainedEntities(core:GetTable().DamageProp)

			for _, Ent in pairs(const) do
				local phys1 = Ent:GetPhysicsObject()

				if phys1 and phys1:IsValid() then
					phys1:EnableMotion( true )
					phys1:Wake()
					phys1:ApplyForceCenter( Vector( 0, 0, -1) )
				end

				Ent:SetPos((Ent:GetPos() - corepos + spawnpos))
			end

			core:GetTable().DamageProp:SetPos(spawnent:GetPos())

			local phys = core:GetTable().DamageProp:GetPhysicsObject()
			if phys and phys:IsValid() then
				phys:EnableMotion( true )
				phys:Wake()
				phys:ApplyForceCenter( Vector( 0, 0, -1) )
			end

			table.remove(robotspawns, randomspawn)
		end
	end

	concommand.Add("undo", NoUndo )
	concommand.Add("gmod_undo", NoUndo )
	concommand.Add("gmod_undonum", NoUndo )

	timer.Create("survival time", 1, 0, SurvivalTime)
	timer.Create("checkcores", 1, 0, CheckCores)
end


VoteSkipInfo = {}
function VoteSkip( ply, command, args )
	if (gb_CurrentRound != 1) then
		ply:PrintMessage( HUD_PRINTTALK, "You may only voteskip the build round." )
		return
	end

	if ( gb_NumBlueCores <= 0 or gb_NumRedCores <= 0 ) then 
		ply:PrintMessage( HUD_PRINTTALK, "There aren't enough cores to voteskip!" )
		return 
	end

	if !table.HasValue(VoteSkipInfo, ply) then
		table.insert(VoteSkipInfo, ply)

		for k, v in pairs(VoteSkipInfo) do
			if !v:IsPlayer() then
				VoteSkipInfo[k] = nil
			end
		end

		local percent = #VoteSkipInfo / #player.GetAll()
		local required = math.ceil(gb_VoteSkipPercent * #player.GetAll())
		local remaining = required - #VoteSkipInfo

		if (percent >= gb_VoteSkipPercent) then
			Announcement({ply:Name().." has voted to skip the build round.", "Required "..required.." voteskips reached"}, 5)
			StartFight()
		else
			Announcement({ply:Name().." has voted to skip the build round.", remaining.." more votes needed"}, 5)
		end
	end
end
concommand.Add("gb_voteskip", VoteSkip )

function Changethemap()
	local map = game.GetMapNext()
	local prefix = map:sub(0, 3)

	if prefix == "gb_" then
		game.LoadNextMap()
	else
		game.ConsoleCommand("changelevel "..game.GetMap().."\n")
	end
end

function GameOver(winteam)
	ChangeRound(3)

	local winmsg = "No contest!"
	if winteam then
		if winteam == 0 then
			winmsg = "It's a tie!"
		elseif winteam == 1 then
			winmsg = "Red team wins!"
		elseif winteam == 2 then
			winmsg = "Blue team wins!"
		end

	else
		if gb_NumRedCores > gb_NumBlueCores then
			-- Red team wins!
			winteam = 1
			winmsg = "Red team wins!"
		elseif gb_NumRedCores < gb_NumBlueCores then
			-- Blue team wins!
			winteam = 2
			winmsg = "Blue team wins!"
		elseif gb_NumRedCores == gb_NumBlueCores then
			-- It was a tie! D:
			winteam = 0
			winmsg = "It's a tie!"
		end
	end


	local times = {}
	for k, v in pairs(player.GetAll()) do
		table.insert(times, {v, v:GetVar("gb_time", 0)})
	end

	local new_times = {}
	for i=1, #times do
		local longest = {0,0,0}

		for k, v in pairs(times) do
			if (v[2] > longest[2] || longest[1] == 0) then
				longest = {v[1], v[2], k}
			end
		end

		if (longest[2] != 0) then
			table.insert(new_times, {longest[1], longest[2]})
		end

		table.remove(times, longest[3])
	end

	local time_count = #new_times
	if time_count > 10 then
		time_count = 10
	end

	local healths = {}
	for k, v in pairs(player.GetAll()) do
		if (v:GetVar("gb_time", 0) > 0) then
			table.insert(healths, {v, v:GetNetworkedInt("gb_corehealth", 0)})
		end
	end

	local new_healths = {}
	for i=1, #healths do
		local longest = {0,0,0}

		for k, v in pairs(healths) do
			if (v[2] > longest[2] || longest[1] == 0) then
				longest = {v[1], v[2], k}
			end
		end

		--if (longest[2] != 0) then
		table.insert(new_healths, {longest[1], longest[2]})

		--end
		table.remove(healths, longest[3])
	end

	local health_count = #new_healths
	if health_count > 10 then
		health_count = 10
	end

	local damages = {}
	for k, v in pairs(player.GetAll()) do
		if (v:GetVar("gb_time", 0) > 0) then
			table.insert(damages, {v, v:GetVar("DamageDelt", 0)})
		end
	end

	local new_damages = {}
	for i=1, #damages do
		local longest = {0,0,0}

		for k, v in pairs(damages) do
			if (v[2] > longest[2] || longest[1] == 0) then
				longest = {v[1], v[2], k}
			end
		end

		//if (longest[2] != 0) then
		table.insert(new_damages, {longest[1], longest[2]})

		//end
		table.remove(damages, longest[3])
	end

	local damage_count = #new_damages
	if damage_count > 20 then
		damage_count = 20
	end

	local wincolor = Color(128, 128, 128, 255)
	if winteam != 0 then
		wincolor = team.GetColor(winteam)
	end

	net.Start("gb_postgame")
		--time
		net.WriteUInt(time_count, 16)
		for i=1, time_count do
			net.WriteEntity(new_times[i][1])
			net.WriteUInt(new_times[i][2], 16)
		end

		--health
		net.WriteUInt(health_count, 16)
		for i=1, health_count do
			net.WriteEntity(new_healths[i][1])
			net.WriteUInt(new_healths[i][2], 16)
		end

		--damage
		net.WriteUInt(damage_count, 16)
		for i=1, damage_count do
			net.WriteEntity(new_damages[i][1])
			net.WriteUInt(new_damages[i][2], 16)
		end

		net.WriteColor(Color(wincolor.r, wincolor.g, wincolor.b, 255))
		net.WriteString(winmsg)
	net.Broadcast()

	timer.Simple(gb_PostGameTime, Changethemap)
	timer.Remove("RoundTimer")
	timer.Remove("survival time")
	timer.Remove("checkcores")
end