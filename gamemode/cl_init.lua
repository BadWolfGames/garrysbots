include( "defines.lua" )
include( "config.lua" )
include( "shared.lua" )
include( "cl_netmsgs.lua" )
include( "cl_hud.lua" )
include( "cl_gui.lua" )
include( "cl_spawnmenu.lua" )
include( "sh_scoreboard.lua" )

local function DisallowSpawnMenu( )  	
	if gb_CurrentRound != 1 then
		return false 
	end
end     
hook.Add( "SpawnMenuOpen", "DisallowSpawnMenu", DisallowSpawnMenu)

function TimerCountdown()
	gb_RoundTimer = gb_RoundTimer - 1

	if gb_RoundTimer < 0 then
		gb_RoundTimer = 0
	end
end

function TimeSurvivedUpdate()
	for k, v in pairs(player.GetAll()) do
		if (v:GetNetworkedEntity("gb_core"):IsValid()) then //todo: move over to networked bools
			v:SetVar("gb_time", gb_FightTime - gb_RoundTimer) //inaccurate value for the scoreboard
		end
	end
end

function UpdateCoreHealth()
	for k, v in pairs(player.GetAll()) do
		if (v != LocalPlayer()) then
			if (v:GetNetworkedEntity("gb_core"):IsValid()) then //todo: move over to networked bools
				v:SetVar("gb_corehealth", v:GetNetworkedInt("gb_corehealth"))
			else
				v:SetVar("gb_corehealth", 0)
			end
		end
	end
end
timer.Create("UpdateCoreHealth", 1, 0, UpdateCoreHealth)

function UpdateOurCoreHealth()
	if (LocalPlayer():GetNetworkedEntity("gb_core"):IsValid()) then //todo: move over to networked bools
		LocalPlayer():SetVar("gb_corehealth", LocalPlayer():GetNetworkedInt("gb_corehealth"))
	else
		LocalPlayer():SetVar("gb_corehealth", 0)
	end
end

function WorkAroundFix()
	timer.Create("UpdateOurCoreHealth", 0.5, 0, UpdateOurCoreHealth)
end
timer.Create("WRFix", 1, 1, WorkAroundFix)

local MusicEnabled = true
function ChangeRound(round)
	gb_CurrentRound = round

	if (round == 2) then
		timer.Create("Time Survived Update", 1.5, 0, TimeSurvivedUpdate)

		if MusicEnabled then
			surface.PlaySound("music/HL2_song29.mp3")
			timer.Destroy("MusicLoop")
			timer.Create("MusicLoop", 136, 0, LoopMusic)
		end
	end
end

function LoopMusic()
	surface.PlaySound("music/HL2_song29.mp3")
end

function ToggleMusic()
	if MusicEnabled then
		LocalPlayer():ConCommand("stopsounds\n")
		timer.Destroy("MusicLoop")
		MusicEnabled = false
	else
		if(gb_CurrentRound == 2) then
			surface.PlaySound("music/HL2_song29.mp3")
			timer.Create("MusicLoop", 136, 0, LoopMusic)
			MusicEnabled = true
		end
	end
end
concommand.Add("gb_togglemusic", ToggleMusic)