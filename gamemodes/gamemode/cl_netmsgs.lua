//Contains all of the net messages we send.

net.Receive("gb_changeround", function()
	local data = net.ReadInt(32)

	ChangeRound(data)
end)

net.Receive("gb_timercountdown", function()
	gb_RoundTimer = net.ReadInt(32)
end)

net.Receive("gb_updateteamcores", function()
	gb_NumRedCores = net.ReadInt(32)
	gb_NumBlueCores = net.ReadInt(32)
end)