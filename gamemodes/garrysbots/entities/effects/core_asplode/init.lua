local whi = Material("effects/whiteoverlay")

EFFECT.sTime = 0
EFFECT.blu = 1
local function rndSph()
	return Vector(math.random()*2 - 1,math.random()*2 - 1,math.random()*2 - 1):GetNormal()
end

function EFFECT:Init(data)
	self.sTime = CurTime()
	local e = data:GetEntity()
	local ePos = e:GetPos()
	local eAng = e:GetAngles()
	self.Entity:SetPos(ePos)
	self.Entity:SetAngles(eAng)
	self.Entity:SetModel(e:GetModel())

	if(math.Round(data:GetMagnitude()) == 2) then
		self.blu = 0
	elseif(math.Round(data:GetMagnitude()) == 1) then
		self.blu = 1
	end
		
	
	-- 2d
	local emitter = ParticleEmitter(ePos)
	for i=0, 20 do
		local pPos = rndSph() * 20
		local vel = pPos * 30
		local particle = emitter:Add("sprites/coresmoke",ePos + pPos)
		if particle then
			particle:SetVelocity(vel)
			particle:SetLifeTime(-1)
			particle:SetDieTime(0.6)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(40)
			particle:SetEndSize(60)
			particle:SetAirResistance(800)
			if self.blu == 1 then
				particle:SetColor(40,160,255,255)
			elseif self.blu == 0 then
				particle:SetColor(255,120,40,255)
			end
		end
	end
	for i=0,300 do
		local pPos = rndSph() * 16
		local vel = pPos * math.Rand(8,40)
		local particle = emitter:Add("sprites/coreglow",ePos + pPos)
		if particle then
			particle:SetVelocity(vel)
			particle:SetLifeTime(-1)
			particle:SetDieTime(2.6)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(6)
			particle:SetEndSize(1)
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0,0,-300))
			particle:SetCollide(true)
			particle:SetBounce(0.7)
			if self.blu == 1 then
				particle:SetColor(40,100,255,255)
			elseif self.blu == 0 then
				particle:SetColor(255,80,20,255)
			end
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-40,40))
		end
	end
	local particle = emitter:Add("sprites/coreglow",ePos)
	if particle then
		particle:SetLifeTime(0)
		particle:SetDieTime(1)
		particle:SetStartAlpha(0)
		particle:SetEndAlpha(255)
		particle:SetStartSize(40)
		particle:SetEndSize(200)
		if self.blu == 1 then
			particle:SetColor(40,120,255,255)
		elseif self.blu == 0 then
			particle:SetColor(255,120,40,255)
		end
	end
	
	-- 3d
	local hem = ParticleEmitter(ePos,true)
	for i=1,3 do
		local particle = hem:Add("sprites/coreshrap",ePos)
		if particle then
			particle:SetLifeTime(-1)
			particle:SetDieTime(0.4 + math.random()*0.3)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(10)
			particle:SetEndSize(math.Rand(360,440))
			if self.blu == 1 then
				particle:SetColor(40,180,255,255)
			elseif self.blu == 0 then
				particle:SetColor(255,160,40,255)
			end
			particle:SetAngles(Vector(0,0,1):Angle())
			particle:SetAngleVelocity(Angle(0,math.Rand(-100,100),0))
		end
	end
	
	return true
end

function EFFECT:Think()
	if CurTime() < self.sTime + 1.1 then
		return true
	else
		return false
	end
end

function EFFECT:Render()
	self.Entity:SetColor(255,255,255,200)
	--self.Entity:SetColor(255,255,255,math.Clamp((CurTime() - self.sTime)*255,0,255))
	cam.Start3D(EyePos() + (self.Entity:GetPos() - EyePos()):GetNormal()*1.0,EyeAngles())
		--SetMaterialOverride(whi)
		self.Entity:DrawModel()
		--SetMaterialOverride(0)
	cam.End3D()
end