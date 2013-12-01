include('shared.lua')

/* DamageProp returns nil which is why the laser no show up? */
/*function ENT:DrawTranslucent( bDontDrawModel )
	if ( bDontDrawModel ) then return end

	if (!self.DamageProp || !self.DamageProp:IsValid()) then
		self.DamageProp = self.Entity:GetNetworkedEntity("DamageProp")
		return
	end

	if !IsValid(self.DamageProp) then
		print("I RETURN AN ERROR AT LINE 13 OF CL_INIT.LUA OF GB_CORE!")
	end

	-- local start = self.DamageProp:GetPos()
	-- local endpos = start + (self.DamageProp:GetUp() * 20)

	-- render.SetMaterial(Material( "cable/redlaser" ) )
	-- render.DrawBeam(start, endpos, 12, 0, 10, Color(255, 255, 255, 255))
end*/

function ENT:Initialize()
end

function ENT:Draw()
	self.BaseClass.Draw(self)

	local beam_length = 20
	if (beam_length > 0) then

		local start = self.Entity:GetPos()
		local endpos = start + (self.Entity:GetUp() * beam_length)
		
		local bbmin, bbmax = self.Entity:GetRenderBounds()
		local lspos = self.Entity:WorldToLocal(start)
		local lepos = self.Entity:WorldToLocal(endpos)
		if (lspos.x < bbmin.x) then bbmin.x = lspos.x end
		if (lspos.y < bbmin.y) then bbmin.y = lspos.y end
		if (lspos.z < bbmin.z) then bbmin.z = lspos.z end
		if (lspos.x > bbmax.x) then bbmax.x = lspos.x end
		if (lspos.y > bbmax.y) then bbmax.y = lspos.y end
		if (lspos.z > bbmax.z) then bbmax.z = lspos.z end
		if (lepos.x < bbmin.x) then bbmin.x = lepos.x end
		if (lepos.y < bbmin.y) then bbmin.y = lepos.y end
		if (lepos.z < bbmin.z) then bbmin.z = lepos.z end
		if (lepos.x > bbmax.x) then bbmax.x = lepos.x end
		if (lepos.y > bbmax.y) then bbmax.y = lepos.y end
		if (lepos.z > bbmax.z) then bbmax.z = lepos.z end
		self.Entity:SetRenderBounds(bbmin, bbmax, Vector()*6)

		local trace = {}
		trace.start = start
		trace.endpos = endpos
		trace.filter = { self.Entity }

		local trace = util.TraceLine(trace)
		if (trace.Hit) then
			endpos = trace.HitPos
		end

		render.SetMaterial(Material( "cable/redlaser" ) )
		render.DrawBeam(start, endpos, 12, 0, 10, Color(255, 255, 255, 255))
	end
end

function ENT:Think()
end