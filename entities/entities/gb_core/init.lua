AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:UpdateCoreHealth()
	if (self.Owner && self.Owner:IsValid()) then
		if (self.aHealth < 0) then
			self.aHealth = 0
		end

		self.Owner:SetNetworkedInt("gb_corehealth", math.ceil(self.aHealth))
	end
end

function ENT:UpdateTeamCores_Server(red, blue) //used to give an instant reaction
	gb_NumRedCores = red
	gb_NumBlueCores = blue

	CheckCores()

	net.Start("gb_updateteamcores")
		net.WriteInt(red, 32)
		net.WriteInt(blue, 32)
	net.Broadcast()
end

function ENT:CheckFlip()
	local ang = self.Entity:GetUp():Angle()

	if ang.p < 270	then
		return true
	end

	return false
end

function ENT:SpawnFunction(ply, tr)
	if ( !tr.Hit ) then return end

	if (ply:GetNetworkedEntity("gb_core"):IsValid()) then
		ply:PrintMessage(HUD_PRINTTALK, "You already have a core!")
		return 
	end

	self.Owner = ply //used internally
	self.Team = ply:Team()

	local SpawnPos = tr.HitPos + (tr.HitNormal * 30)
	local ent = ents.Create("gb_core")
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent.OwnerTeam = ply:Team()
	ent:Activate()

	if (ent:IsValid()) then
		ply:SetNetworkedEntity("gb_core", ent)
	end

	local ownerteam = ply:Team()
	if (ownerteam == 1) then
		self:UpdateTeamCores_Server(gb_NumRedCores + 1, gb_NumBlueCores)

	elseif (ownerteam == 2) then
		self:UpdateTeamCores_Server(gb_NumRedCores, gb_NumBlueCores + 1)
	end

	return ent
end

function ENT:Initialize()
	self.Entity:SetModel( "models/props_junk/PopCan01a.mdl" ) //something small
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self.Entity.CollisionGroup = COLLISION_GROUP_WORLD

	local phys = self.Entity:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake() 
	end
	
	self.aHealth = gb_CoreHealth
	self.Dead = false

	self:MakeDamageProp()
	self:UpdateCoreHealth()
end

function ENT:MakeDamageProp()
	local prop = ents.Create( "prop_physics" ) //damage model
	if ( !prop:IsValid() ) then return end

	prop:SetModel( "models/props_junk/watermelon01.mdl" ) //actual core model
	prop:SetPos( self.Entity:GetPos() )
	prop:SetAngles( self.Entity:GetAngles() )
	local teamcolor = team.GetColor(self.Owner:Team())
	local teamcolorfix = Color(teamcolor.r, teamcolor.g, teamcolor.b)
	prop:SetColor(teamcolorfix)
	prop:Spawn()
	prop:Fire("sethealth", "99999") //dont break
	prop:Fire("physdamagescale", tostring(gb_CoreDamageScale)) //adjust
	prop:SetVar("DamageModel", self) //used by the damage hook
	prop:SetVar("Founder", self.Owner)
	prop.aHealth = gb_CoreHealth

	self.Entity:SetParent(prop)

	self.DamageProp = prop
	self.Entity:SetNetworkedEntity("DamageProp", prop)
end

function ENT:Damage(dmg)
	self.aHealth = self.aHealth - dmg
	local dmgprop = self.Entity:GetNetworkedEntity("DamageProp")
	dmgprop.aHealth = dmgprop.aHealth - dmg
	
	self:UpdateCoreHealth()
end

function ENT:Destroy()
	for k, v in pairs(player.GetAll()) do
		if v == self.Owner then
			Announcement({"Your core was destroyed!"}, 5, v)
		else
			Announcement({self.Owner:Name().."'s core was destroyed!"}, 5, v)
		end
	end

	DestroyRobot(self.Owner)
end

function ENT:DestroyEffects()
	self.Dead = true

	local ed = EffectData()
	local phy = self.Entity:GetPhysicsObject()
	local phy2 = self.DamageProp:GetPhysicsObject()

	if phy:IsValid() then phy:EnableMotion(false) end
	if phy2:IsValid() then phy2:EnableMotion(false) end

	ed:SetEntity(self.DamageProp)

	local teamcolor = team.GetColor(self.Owner:Team())
	if(teamcolor.r < teamcolor.b) then
		ed:SetMagnitude(1)
	elseif(teamcolor.r > teamcolor.b) then
		ed:SetMagnitude(2)
	end

	util.PrecacheSound("ambient/explosions/explode_1.wav")
	util.Effect("core_asplode", ed)

	timer.Simple(1, function()
		self.DamageProp.EmitSound(self.DamageProp, "ambient/explosions/explode_1.wav", 500, 100)
	end)

	timer.Simple(1.01, function()
		self.Entity.Remove(self.Entity)
	end)
end

function ENT:OnRemove()
	if self.DamageProp:IsValid() then
		self.DamageProp:Remove()
	end

	if self.Owner:IsPlayer() then
		self.aHealth = 0
		self:UpdateCoreHealth()
		if (self.Owner:GetVar("gb_time", 0) > 1) then
			self.Owner:SetVar("gb_time", self.Owner:GetVar("gb_time") - 1)
		end
	end

	if (self.Team == 1) then
		self:UpdateTeamCores_Server(gb_NumRedCores - 1, gb_NumBlueCores)
	elseif (self.Team == 2) then
		self:UpdateTeamCores_Server(gb_NumRedCores, gb_NumBlueCores - 1)
	end
end

function ENT:Think()
	if (self.DamageProp && self.DamageProp:IsValid()) then
		self.DamageProp:Fire("sethealth", "99999")
	else
		self:MakeDamageProp()
	end

	if gb_CurrentRound != 1 then
		if self:CheckFlip() then
			self:Damage(1)
		end

		if !constraint.HasConstraints(self.DamageProp) then
			self:Damage(10)
		end

		if (self.aHealth <= 0 && !self.Dead) then
			self:Destroy()
		end
	end
end