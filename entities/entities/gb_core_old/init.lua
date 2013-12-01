AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function UpdateCoreHealth(ply, amt)
	if (ply) then
		if (ply:IsPlayer()) then
			ply:SetNetworkedInt("gb_corehealth", math.ceil(amt))
		end
	end
end

function ENT:SpawnFunction( ply, tr )
	if( !tr.Hit ) then return end
	if(ply:GetNetworkedEntity("gb_core"):IsValid()) then
		ply:PrintMessage(HUD_PRINTTALK, "You already have a core!")
		return 
	end

	local SpawnPos = tr.HitPos + (tr.HitNormal * 30)
	local ent = ents.Create("gb_core")
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	UpdateCoreHealth(ply, 1000)

	if(ent:IsValid()) then
		ply:SetNetworkedEntity("gb_core", ent)
	end
	local ownerteam = ply:Team()
	if(ownerteam == 1) then
		UpdateTeamCores_Server(gb_NumRedCores + 1, gb_NumBlueCores)
	elseif(ownerteam == 2) then
		UpdateTeamCores_Server(gb_NumRedCores, gb_NumBlueCores + 1)
	end
	local teamcolor = team.GetColor(ownerteam)
	ent:SetColor(teamcolor.r, teamcolor.g, teamcolor.b, teamcolor.a)
	return ent
end

function UpdateTeamCores_Server(red, blue)
	gb_NumRedCores = red
	gb_NumBlueCores = blue
	local rf = RecipientFilter()
	rf:AddAllPlayers()
	umsg.Start("updateteamcores", rf)
		umsg.Long(red)
		umsg.Long(blue)
	umsg.End()
end

function ENT:Initialize()

	self.Entity:SetModel( "models/props_junk/watermelon01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake() 
	end
	self.aHealth = 1000
end

function ENT:OnTakeDamage(dmg)
	if gb_CurrentRound == 1 then return end

	self.aHealth = self.aHealth - dmg:GetDamage()

	if (self.aHealth <= 0) then
		local vPoint = self.GetPos(self)
		local effectdata = EffectData()
		effectdata:SetStart( vPoint )
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale( 2 )
		util.Effect( "Explosion", effectdata )
		util.Effect( "cball_explode", effectdata )
		self.Remove(self)
		return
	end
	if (self.Entity:GetVar("Founder", "nothing" )) then
		UpdateCoreHealth(self.Entity:GetVar( "Founder", "nothing" ), self.aHealth)
	end
end

function ENT:OnRemove()
	if (not !self.Entity:GetVar( "Founder", "nothing" )) then
		//MsgAll("                         core destroyed, had owner\n")
		self.Entity:GetVar( "Founder", "nothing" ):PrintMessage(HUD_PRINTTALK, "Your core was destroyed!")
		UpdateCoreHealth(self.Entity:GetVar( "Founder", "nothing" ), 0)
		local ownerteam = self.Entity:GetVar( "Founder", "nothing" ):Team()
		if(ownerteam == 1) then
			UpdateTeamCores_Server(gb_NumRedCores - 1, gb_NumBlueCores)
		elseif(ownerteam == 2) then
			UpdateTeamCores_Server(gb_NumRedCores, gb_NumBlueCores - 1)
		end

		if gb_CurrentRound != 1 then
			DestroyRobot(self.Entity:GetVar( "Founder", "nothing" ))
		end
	else
		//MsgAll("                            Core destroyed, no owner, falling back\n")
		local r,g,b,a = self.Entity:GetColor()
		if r > b then
			UpdateTeamCores_Server(gb_NumRedCores - 1, gb_NumBlueCores)
		else
			UpdateTeamCores_Server(gb_NumRedCores, gb_NumBlueCores - 1)
		end
	end
end

function checkFlip( ent, distance )
	if distance then	
		local trace = {}
		trace.start = ent:GetPos()
		trace.endpos = trace.start + (ent:GetUp() * distance)
		trace.mask = MASK_SOLID
		
		local tr = util.TraceLine( trace )
		
		if tr.HitWorld then
			if tr.HitNormal:Angle().p <= 300 and tr.HitNormal:Angle().p > 240 then
				return true
			end
		end
	else
		local ang = ent:GetUp():Angle()
		if ang.p < 270	then
			return true
		end
	end
	return false

end

function ENT:Think()
	if(gb_CurrentRound == 2) then
		if(checkFlip(self.Entity)) then
			self.aHealth = self.aHealth - 1
				if(not !self.Entity:GetVar("Founder", "nothing" )) then
					UpdateCoreHealth(self.Entity:GetVar( "Founder", "nothing" ), self.aHealth)
				end
		end

		if (self.aHealth <= 0) then
			local vPoint = self.GetPos(self)
			local effectdata = EffectData()
			effectdata:SetStart( vPoint )
			effectdata:SetOrigin( vPoint )
			effectdata:SetScale( 2 )
			util.Effect( "Explosion", effectdata )
			util.Effect( "cball_explode", effectdata )
			self.Remove(self)
			return
		end

		if(!constraint.HasConstraints(self.Entity)) then
			local vPoint = self.GetPos(self)
			local effectdata = EffectData()
			effectdata:SetStart( vPoint )
			effectdata:SetOrigin( vPoint )
			effectdata:SetScale( 2 )
			util.Effect( "Explosion", effectdata )
			util.Effect( "cball_explode", effectdata )
			self.Remove(self)
		end
	end
end
