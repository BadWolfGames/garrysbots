concommand.Add("gm_spawn", function(ply, cmd, args)
	if gb_CurrentRound != 1 then return end

	if ( args[1] == nil ) then return end
	if ( !gamemode.Call( "PlayerSpawnObject", ply ) ) then return end
	if ( !util.IsValidProp( args[1] ) ) then return end

	GMODSpawnProp( ply, args[1], 0, 0 )
end)

hook.Add("PlayerSpawnProp", "gb_PropCheck", function(player, model)
	local prop = DoPlayerEntitySpawn( player, "prop_physics", model, 1 )
	local min,max = prop:WorldSpaceAABB()
	local size = min:Distance(max)
	local physob = prop:GetPhysicsObject()
	local propmass = 0
	if (physob && physob:IsValid()) then propmass = physob:GetMass() end
	prop:Remove()

	for k, v in pairs(gb_BannedProps) do
		if string.gsub(string.gsub(model, "/", ""), "\\", "") == string.gsub(string.gsub(v, "/", ""), "\\", "") then
			player:ChatPrint("That prop is not allowed.")
			return false
		end
	end

	if size > gb_MaxPropSize then
		player:ChatPrint("That prop is not allowed.")
		return false
	end

	if propmass > gb_MaxPropMass then
		player:ChatPrint("That prop is not allowed.")
		return false
	end

	return true
end)


function GM:PlayerSpawnedProp( ply, model, prop )
	prop:SetVar( "Founder", ply )

	self.BaseClass:PlayerSpawnedProp( ply, model, prop )

	local color = team.GetColor( ply:Team() )
	local colorfix = Color(color.r, color.g, color.b)
	local physObj = prop:GetPhysicsObject()

	-- Set the color
	prop:SetColor(colorfix)
	physObj:Sleep()

	SetPropHealth(prop)
end

function GM:PlayerSpawnedSENT( ply, prop )
	prop:SetVar( "Founder", ply )

	self.BaseClass:PlayerSpawnedSENT(ply, prop)
end