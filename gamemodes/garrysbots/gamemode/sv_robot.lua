function DestroyProp(ent)
	local vPoint = ent:GetPos()

	local r = math.random(1,10)
	if r > 5 then
		local effectdata = EffectData()
		effectdata:SetStart( vPoint )
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale( 1 )
		util.Effect( "Explosion", effectdata )
	end

	constraint.RemoveAll(ent)

	timer.Simple(3,function()
		if IsValid(ent) then
			ent.Remove(ent)
		end
	end)
end

function RemoveRobot( player )
	for k, ent in pairs(ents.GetAll()) do
		if ent:GetVar( "Founder" ) == player then
			ent.Remove(ent)
		end
	end
end

function DestroyRobot(player)
	if player:GetNetworkedEntity("gb_core"):IsValid() then
		player:GetNetworkedEntity("gb_core"):GetTable():DestroyEffects()
	end

	player:PrintMessage(HUD_PRINTTALK,"Your core was destroyed!")

	local removetable = {}
	local gbotsents = {"gb_cam", "gmod_thruster", "gmod_wheel", "prop_physics"}

	for a, b in pairs(ents.GetAll()) do
		if IsValid(b) then
			if table.HasValue(gbotsents,b:GetClass()) then
				if b:GetVar( "Founder" ) == player  then
					DestroyProp(b)
				end
			end
		end
	end
end