function SetPropHealth(prop, amount)
	local physob = prop:GetPhysicsObject()

	if physob then
		local propmass = physob:GetMass()
		local min,max = prop:WorldSpaceAABB()
		local size = min:Distance(max)

		if gb_PropHealthMethod == 1 then
			prop.aHealth = amount or gb_FixedPropHealth
		elseif gb_PropHealthMethod == 2 then
			prop.aHealth = amount or math.ceil((size * gb_PropSizeModifier * propmass) + gb_PropHealthAdd)
		elseif gb_PropHealthMethod == 3 then
			prop.aHealth = amount or math.ceil((propmass / (size * gb_PropHealthModifier)) + gb_PropHealthAdd)
		end

		if (!amount && prop.aHealth > gb_PropMaxHealth) then
			prop.aHealth = gb_PropMaxHealth
		end

		prop.aBaseHealth = prop.aHealth
		prop.aMaxHealth = prop.aHealth

		prop:Fire("physdamagescale", tostring(gb_PropDamageScale))
	end
end

function EntDamage(ent,dmg)
	if (ent.aHealth == nil) then
		return
	end

	ent.aHealth = ent.aHealth - dmg

	if (ent.aHealth <= 0) then
		constraint.RemoveAll(ent)
	end

	if (ent.aHealth < -100) then
		DestroyProp(ent)
	end
end

function GM:EntityTakeDamage( ent, dmginfo )
	local attacker = dmginfo:GetAttacker()
	local damage = dmginfo:GetDamage()
	local inflictor = dmginfo:GetInflictor()

	if gb_CurrentRound == 1 then return end

	if gb_SuddenDeath == true then
		dmginfo:SetDamage(math.Round(damage*gb_SuddenDeathPropDamageScale))
	end

	if attacker:GetClass() == "trigger_hurt" then
		EntDamage(ent,damage*2)
		return
	end
	if attacker:IsWorld() then
		EntDamage(ent,damage)
		return
	end
	if attacker:GetClass() == "entityflame" then
		EntDamage(ent,1)
		return
	end

	if ent:IsPlayer() then return end
	if ent:GetVar("Founder") == nil then return end

	if IsValid(ent:GetVar("Founder")) && IsValid(inflictor:GetVar("Founder")) then
		-- Self Damage
		if inflictor:GetVar("Founder") == ent:GetVar("Founder") then
			dmginfo:SetDamage(0)
			return
		end
		-- Team Damage
		if inflictor:GetVar("Founder"):Team() == ent:GetVar("Founder"):Team() && inflictor:GetVar("Founder") != ent:GetVar("Founder") then
			EntDamage(ent,math.Round(damage/2))
			return
		end
		-- Damage to others
		if inflictor:GetVar("Founder") != ent:GetVar("Founder") then
			EntDamage(ent,damage)
			inflictor:GetVar("Founder"):SetVar("DamageDelt", inflictor:GetVar("Founder"):GetVar("DamageDelt") + damage )
			return
		end
	end
end