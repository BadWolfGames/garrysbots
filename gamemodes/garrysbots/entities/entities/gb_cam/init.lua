AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:SpawnFunction( ply, tr )
	if( !tr.Hit ) then return end

	if(ply:GetNetworkedEntity("gb_cam"):IsValid()) then
		ply:PrintMessage(HUD_PRINTTALK, "You already have a camera!")
		return 
	end

	local SpawnPos = tr.HitPos + (tr.HitNormal * 30)
	local ent = ents.Create("gb_cam")
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	if(ent:IsValid()) then
		ply:SetNetworkedEntity("gb_cam", ent)
	end

	local ownerteam = ply:Team()
	local teamcolor = team.GetColor(ownerteam)
	local teamcolorfix = Color(teamcolor.r, teamcolor.g, teamcolor.b)
	ent:SetColor(teamcolorfix)

	return ent
end

function ENT:PostEntityPaste(ply,ent,tab)
	self:Remove()
end

function ENT:Initialize()
	self.Entity:SetModel( "models/dav0r/camera.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake() 
	end

	self.aHealth = 50000
end


function ENT:Think()

end