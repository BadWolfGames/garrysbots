// sh_func.lua
// Houses the most important functions server-side

function Announcement(text, time, player)
	local rf = RecipientFilter()
	rf:AddAllPlayers()
	rf = player or rf

	umsg.Start("Announcement", rf)
		umsg.Long(time)
		umsg.Long(table.getn(text))
		for k, v in pairs(text) do
			umsg.String(v)
		end
	umsg.End()
end

function SyncTime()
	local rf = RecipientFilter()
	rf:AddAllPlayers()

	umsg.Start("timercountdown", rf)
		umsg.Long(gb_RoundTimer)
	umsg.End()

	//im planning on adding more to this...
end

function SurvivalTime()
	for k, v in pairs(player.GetAll()) do
		if (v:GetNetworkedEntity("gb_core"):IsValid()) then
			v:SetVar("gb_time", gb_FightTime - gb_RoundTimer)
		end
	end
end

function ChangeRound(round)
	gb_CurrentRound = round

	local rf = RecipientFilter()
	rf:AddAllPlayers()

	umsg.Start("changeround", rf)
		umsg.Long(round)
	umsg.End()

	SyncTime()
end

function NoUndo( player, command, args )
	player:PrintMessage( HUD_PRINTTALK, "Sorry, but undo is disabled during the fight round." )
end

function StartFight()
	gb_RoundTimer = gb_FightTime
	ChangeRound(2)

	// Put everyone in spectator mode
	local allplayers = player.GetAll()
	for k, v in pairs(allplayers) do
		// Put them into spectator mode
		local cam = v:GetNetworkedEntity("gb_cam")

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

	// Teleport all the robots into the arena
	robotspawns = ents.FindByClass("info_robot")

	for k, v in pairs(allplayers) do
		local core = v:GetNetworkedEntity("gb_core")
		if(core:IsValid()) then
			if (#robotspawns <= 0) then break end //no more spawns...
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

function CheckCores()
	if gb_CurrentRound != 2 then return end

	if (gb_NumBlueCores <= 0 || gb_NumRedCores <= 0) then
		GameOver()
	end
end

VoteSkipInfo = {}
function VoteSkip( ply, command, args )
	if (gb_CurrentRound != 1) then
		ply:PrintMessage( HUD_PRINTTALK, "You may only voteskip the build round." )
		return
	end

	if !table.HasValue(VoteSkipInfo, ply) then
		table.insert(VoteSkipInfo, ply)
		for k, v in pairs(VoteSkipInfo) do
			if !v:IsPlayer() then
				VoteSkipInfo[k] = nil
			end
		end
		local percent = table.getn(VoteSkipInfo) / table.getn(player.GetAll())
		local required = math.ceil(gb_VoteSkipPercent * table.getn(player.GetAll()))
		local remaining = required - table.getn(VoteSkipInfo)

		if (percent >= gb_VoteSkipPercent) then
			Announcement({ply:Name().." has voted to skip the build round.", "Required "..required.." voteskips reached", "FIGHT!!!"}, 5)
			StartFight()
		else
			Announcement({ply:Name().." has voted to skip the build round.", remaining.." more votes needed"}, 5)
		end
	end
end
concommand.Add("gb_voteskip", VoteSkip )

function Changethemap()
	game.LoadNextMap()
end

function GameOver(winteam)
	ChangeRound(3)

	local winmsg
	if winteam then //override win
		if winteam == 0 then
			winmsg = "It's a tie!"
		elseif winteam == 1 then
			winmsg = "Red team wins!"
		elseif winteam == 2 then
			winmsg = "Blue team wins!"
		end
	else //normal win
		if gb_NumRedCores > gb_NumBlueCores then
			// Red team wins!
			winteam = 1
			winmsg = "Red team wins!"
		elseif gb_NumRedCores < gb_NumBlueCores then
			// Blue team wins!
			winteam = 2
			winmsg = "Blue team wins!"
		elseif gb_NumRedCores == gb_NumBlueCores then
			// It was a tie! D:
			winteam = 0
			winmsg = "It's a tie!"
		end
	end

	local times = {}
	for k, v in pairs(player.GetAll()) do
		table.insert(times, {v, v:GetVar("gb_time", 0)})
	end

	local new_times = {}
	for i=1, table.getn(times) do
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

	local time_count = table.getn(new_times)
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
	for i=1, table.getn(healths) do
		local longest = {0,0,0}
		for k, v in pairs(healths) do
			if (v[2] > longest[2] || longest[1] == 0) then
				longest = {v[1], v[2], k}
			end
		end
		//if (longest[2] != 0) then
			table.insert(new_healths, {longest[1], longest[2]})
		//end
		table.remove(healths, longest[3])
	end

	local health_count = table.getn(new_healths)
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
	for i=1, table.getn(damages) do
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

	local damage_count = table.getn(new_damages)
	if damage_count > 20 then
		damage_count = 20
	end

	local wincolor = team.GetColor(winteam)
	if (winteam == 0) then
		wincolor = Color(128, 128, 128, 255)
	end

	local rf = RecipientFilter()
	rf:AddAllPlayers()

	umsg.Start("PostGame", rf)
		umsg.Short(time_count)
		for i=1, time_count do
			umsg.Entity(new_times[i][1])
			umsg.Short(new_times[i][2])
		end
		umsg.Short(health_count)
		for i=1, health_count do
			umsg.Entity(new_healths[i][1])
			umsg.Short(new_healths[i][2])
		end
		umsg.Short(damage_count)
		for i=1, damage_count do
			umsg.Entity(new_damages[i][1])
			umsg.Short(new_damages[i][2])
		end
		umsg.Short(wincolor.r)
		umsg.Short(wincolor.g)
		umsg.Short(wincolor.b)
		umsg.String(winmsg)
	umsg.End()

	timer.Simple(gb_PostGameTime, Changethemap)
	timer.Remove("RoundTimer")
	timer.Remove("survival time")
	timer.Remove("checkcores")
end

function TimerCountdown()
	gb_RoundTimer = gb_RoundTimer - 1
	if (#player.GetAll() <= 1) then return; end

	//announcements and sudden death
	if gb_CurrentRound == 1 then
		if gb_RoundTimer == 10*60 then
			Announcement({"Ten minutes remaining."}, 5)
		elseif gb_RoundTimer == 5*60 then
			Announcement({"Five minutes remaining."}, 5)
		elseif gb_RoundTimer == 1*60 then
			Announcement({"One minute remaining!"}, 5)
		elseif gb_RoundTimer == 30 then
			Announcement({"30 seconds remaining!"}, 5)
		elseif gb_RoundTimer == 10 then
			Announcement({"10 seconds remaining!"}, 5)
		elseif gb_RoundTimer == 5 then
			Announcement({"5..."}, 2)
		elseif gb_RoundTimer == 4 then
			Announcement({"4..."}, 2)
		elseif gb_RoundTimer == 3 then
			Announcement({"3..."}, 2)
		elseif gb_RoundTimer == 2 then
			Announcement({"2..."}, 2)
		elseif gb_RoundTimer == 1 then
			Announcement({"1..."}, 2)
		end
	elseif gb_CurrentRound == 2 then
		if gb_RoundTimer == 10*60 then
			Announcement({"Ten minutes remaining."}, 5)
		elseif gb_RoundTimer == 5*60 then
			Announcement({"Five minutes remaining."}, 5)
		elseif gb_RoundTimer == 1*60 then
			if gb_SuddenDeath then
				Announcement({ "One minute remaining!", "Sudden Death is now ON" }, 5)

				for k, ent in pairs(ents.FindByClass("prop_physics")) do
					if ent:IsValid() then
						ent:Fire("physdamagescale", tostring(gb_SuddenDeathPropDamageScale))
					end
				end
			else
				Announcement({"One minute remaining!"}, 5)
			end
		elseif gb_RoundTimer == 30 then
			Announcement({"30 seconds remaining!"}, 5)
		elseif gb_RoundTimer == 10 then
			Announcement({"10 seconds remaining!"}, 5)
		elseif gb_RoundTimer == 5 then
			Announcement({"5..."}, 2)
		elseif gb_RoundTimer == 4 then
			Announcement({"4..."}, 2)
		elseif gb_RoundTimer == 3 then
			Announcement({"3..."}, 2)
		elseif gb_RoundTimer == 2 then
			Announcement({"2..."}, 2)
		elseif gb_RoundTimer == 1 then
			Announcement({"1..."}, 2)
		end
	end

	if gb_RoundTimer <= 0 then
		if gb_CurrentRound == 1 then
			Announcement({"FIGHT!"}, 5)
			StartFight()
		elseif gb_CurrentRound == 2 then
			GameOver()
		end
	end
end
