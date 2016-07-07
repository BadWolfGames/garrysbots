DeriveGamemode( "sandbox" )

GM.Name    = "Garry's Bots "..gb_Version
GM.Author  = "LuaBanana, mahalis, craze, BWG"
GM.Email   = "N/A"
GM.Website = ""

function GM:Initialize()
	if SERVER then
		timer.Create("SyncTime", 7.5, 0, SyncTime)
	end

	-- Start roundtimer.
	gb_RoundTimer = gb_BuildTime
	timer.Create("RoundTimer", 1, 0, TimerCountdown)

	-- TEAMS NEED TO BE SET UP CLIENTSIDE & SERVERSIDE!!
	team.SetUp( 1, "Red Team", Color( 255, 0, 0, 255 ) )
	team.SetUp( 2, "Blue Team", Color( 0, 55, 255, 255 ) )
end

function UpdateCores() --maintain propper core count
	gb_NumRedCores = 0
	gb_NumBlueCores = 0
	
	for k,v in pairs(player.GetAll()) do
		if v:GetNetworkedEntity("gb_core"):IsValid() then
			if (v:Team() == 1) then
				gb_NumRedCores = gb_NumRedCores + 1
			elseif  (v:Team() == 2) then
				gb_NumBlueCores = gb_NumBlueCores + 1
			end
		end
	end
end
timer.Create("UpdateCores", 1, 0, UpdateCores)