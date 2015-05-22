AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel( "models/props_lab/jar01a.mdl" )	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.Active = false
end

function ENT:SetWeights( off, on, ent )
	self.OffWeight = off or 1
	self.OnWeight = on or 1

	local physob = self.Entity:GetPhysicsObject()
	if physob then physob:SetMass(off) end
	self.Entity:SetOverlayText("Weight: "..tostring(off))
end

local function Toggle_Weight( pl, ent )
	if (!ent:IsValid()) then return false end
	local physob = ent:GetPhysicsObject()

	if physob then
		if ent:GetTable().Active then
			physob:SetMass(ent:GetTable().OffWeight)
		else
			physob:SetMass(ent:GetTable().OnWeight)
		end
		ent:GetTable().Active = !ent:GetTable().Active

		physob:Wake()
	end

	ent:SetOverlayText("Weight: "..tostring(physob:GetMass()))

	return true
end
numpad.Register( "Weight_Toggle", Toggle_Weight )
