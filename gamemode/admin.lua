function GlobalMsg(msg)
	for _, ply in pairs(player.GetAll()) do
		ply:PrintMessage(HUD_PRINTTALK, msg)
	end
end

function FindPly(name)
	for _, ply in pairs(player.GetAll()) do
		if(string.find(string.lower(ply:Nick()), string.lower(name)) != nil) then
			return ply
		end
	end
	return nil
end

function Admin_StartFight(ply, cmd, args)
	if(ply:IsAdmin()) then
		StartFight()
	else
		ply:PrintMessage(HUD_PRINTTALK, "You are not an admin!\n")
	end
end
concommand.Add("admin_startfight", Admin_StartFight)

function Admin_Announce(ply, cmd, args)
	if(ply:IsAdmin()) then
		if(#args > 1) then
			local msgs = {}
			for i=2, #args do
				table.insert(msgs, args[i])
			end
			Announcement(msgs, args[1])
		else
			ply:PrintMessage(HUD_PRINTTALK, "Incorrect syntax!\n")
		end
	else
		ply:PrintMessage(HUD_PRINTTALK, "You are not an admin!\n")
	end
end
concommand.Add("admin_announce", Admin_Announce)

function Admin_ChangeTime(ply, cmd, args)
	if(ply:IsAdmin()) then
		if(#args == 1) then
			local time = args[1]
			if(tonumber(time) != nil) then
				gb_RoundTimer = time
				SyncTime()
				GlobalMsg(ply:Nick() .. " changed the timer to " .. string.FormattedTime( gb_RoundTimer, "%02i:%02i"))
			else
				ply:PrintMessage(HUD_PRINTTALK, "Incorrect syntax!\n")
			end
		else
			ply:PrintMessage(HUD_PRINTTALK, "Incorrect syntax!\n")
		end
	else
		ply:PrintMessage(HUD_PRINTTALK, "You are not an admin!\n")
	end
end
concommand.Add("admin_changetime", Admin_ChangeTime)

function Admin_Kick(ply, cmd, args)
	if(ply:IsAdmin()) then
		if(#args == 2) then
			local targetply = FindPly(args[1])
			if(targetply != nil) then
				game.ConsoleCommand("kickid "..targetply:UserID().." "..args[2].."\n")
			else
				ply:PrintMessage(HUD_PRINTTALK, "No target found!\n")
			end
		else
			ply:PrintMessage(HUD_PRINTTALK, "Incorrect syntax!\n")
		end
	else
		ply:PrintMessage(HUD_PRINTTALK, "You are not an admin!\n")
	end
end
concommand.Add("admin_kick", Admin_Kick)

function Admin_DestroyRobot(ply, cmd, args)
	if(ply:IsAdmin()) then
		if(#args == 1) then
			local targetply = FindPly(args[1])
			if(targetply != nil) then
				DestroyRobot(targetply)
				GlobalMsg(ply:Nick() .. " destroyed " .. targetply:Nick() .. "'s robot\n")
			else
				ply:PrintMessage(HUD_PRINTTALK, "No target found!\n")
			end
		else
			ply:PrintMessage(HUD_PRINTTALK, "Incorrect syntax!\n")
		end
	else
		ply:PrintMessage(HUD_PRINTTALK, "You are not an admin!\n")
	end
end
concommand.Add("admin_destroyrobot", Admin_DestroyRobot)

function Admin_ChangeTeam(ply, cmd, args)
	if(ply:IsAdmin()) then
		if(#args == 2) then
			local targetply = FindPly(args[1])
			if(targetply != nil) then
				if(tonumber(args[2]) != nil) then
					if(tonumber(args[2]) == 1 or tonumber(args[2]) == 2) then
						RemoveRobot(targetply)
						targetply:SetTeam(tonumber(args[2]))
						targetply:KillSilent()
						if(tonumber(args[2]) == 1) then local tname = "Red" end
						if(tonumber(args[2]) == 2) then local tname = "Blue" end
						GlobalMsg(ply:Nick() .. " changed " .. targetply:Nick() .. " to the " .. tname .. " team\n")
					else
						ply:PrintMessage(HUD_PRINTTALK, "Incorrect syntax!\n")
					end
				else
					ply:PrintMessage(HUD_PRINTTALK, "Incorrect syntax!\n")
				end
			else
				ply:PrintMessage(HUD_PRINTTALK, "No target found!\n")
			end
		else
			ply:PrintMessage(HUD_PRINTTALK, "Incorrect syntax!\n")
		end
	else
		ply:PrintMessage(HUD_PRINTTALK, "You are not an admin!\n")
	end
end
concommand.Add("admin_changeteam", Admin_ChangeTeam)
