-- sv_funcs.lua
-- Houses the most important functions server-side

function Announcement(text, time)
	net.Start("gb_announcement")
		net.WriteUInt(time, 32)
		net.WriteUInt(#text, 32)

		for k,v in pairs(text) do
			net.WriteString(v)
		end
	net.Broadcast()
end

function SyncTime()
	net.Start("gb_timercountdown")
		net.WriteUInt(gb_RoundTimer, 32)
	net.Broadcast()
end

function SurvivalTime()
	for k, v in pairs(player.GetAll()) do
		if (v:GetNetworkedEntity("gb_core"):IsValid()) then
			v:SetVar("gb_time", gb_FightTime - gb_RoundTimer)
		end
	end
end

function NoUndo( player, command, args )
	player:PrintMessage( HUD_PRINTTALK, "Sorry, but undo is disabled during the fight round." )
end

function TimerCountdown()
	if (#player.GetAll() <= 1) then return end
	gb_RoundTimer = gb_RoundTimer - 1

	if gb_CurrentRound == 1 then
		if gb_RoundTimer == 600 then
			Announcement({"[Build] Ten minutes remaining!"}, 5)
		end
		if gb_RoundTimer == 300 then
			Announcement({"[Build] Five minutes remaining!"}, 5)
		end		
		if gb_RoundTimer == 60 then
			Announcement({"[Build] One minute remaining!"}, 5)
		end
	elseif gb_CurrentRound == 2 then
		if gb_RoundTimer == 60 then
			Announcement({"[Fight] One minute remaining! Sudden Death enabled!"}, 5)
			gb_SuddenDeath = true	
		end
	end

	if gb_RoundTimer <= 0 then
		if gb_CurrentRound == 1 then

			if gb_ExtraTime == true then
				if ( gb_NumBlueCores == 0 or gb_NumRedCores == 0 ) then
					Announcement({"[Build] Not enough cores, "..string.NiceTime(gb_ExtraTimeInt).." added."}, 5)
					gb_RoundTimer = gb_ExtraTimeInt
					return
				end
			end
		
			if ( gb_NumBlueCores >= 1 && gb_NumRedCores >= 1 ) then
				StartFight()
			end

		elseif gb_CurrentRound == 2 then
			GameOver()
		end
	end
end