// cl_umsg.lua
// Houses all the hooks that recieve the usermessages from the server

local function ChangeRound_UMSG(data)
	ChangeRound(data:ReadLong())
end
usermessage.Hook("changeround", ChangeRound_UMSG)

local function SyncCountdown(data)
	gb_RoundTimer = data:ReadLong()
end
usermessage.Hook("timercountdown", SyncCountdown)

local function UpdateTeamCores(data)
	gb_NumRedCores = data:ReadLong()
	gb_NumBlueCores = data:ReadLong()
end
usermessage.Hook("updateteamcores", UpdateTeamCores)