resource.AddFile("materials/effects/whiteoverlay.vmt")
resource.AddFile("materials/sprites/coreglow.vmt")
resource.AddFile("materials/sprites/coreshrap.vmt")
resource.AddFile("materials/sprites/coresmoke.vmt")
AddCSLuaFile( "defines.lua" )
AddCSLuaFile( "config.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_netmsgs.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "gui/cl_announcement.lua" )
AddCSLuaFile( "gui/cl_motd.lua" )
AddCSLuaFile( "gui/cl_postgame.lua" )
AddCSLuaFile( "gui/cl_windows.lua" )
AddCSLuaFile( "cl_gui.lua" )
AddCSLuaFile( "cl_spawnmenu.lua" )
AddCSLuaFile( "sh_scoreboard.lua" )
include( "defines.lua" )
include( "config.lua" )
include( "shared.lua" )
include( "sv_funcs.lua" )
include( "sh_scoreboard.lua" )
include( "sv_admin.lua" )

util.AddNetworkString("gb_timercountdown")
util.AddNetworkString("gb_changeround")
util.AddNetworkString("gb_updateteamcores")
util.AddNetworkString("gb_postgame")
util.AddNetworkString("gb_announcement")

hook.Add("KeyPress", "gb_KeyPressedHook", function(ply, key)
	local healthobjs = {"prop_physics"}

	if(key == 32) then
		local traceres = ply:GetEyeTrace()
		local ent = traceres.Entity
		local healthobjs = {"prop_physics"}

		if (!ent:IsValid() || ent:IsWorld() || ent:IsPlayer() || !table.HasValue( healthobjs, ent:GetClass())) then
			return
		else
			ply:PrintMessage(HUD_PRINTTALK, "Prop Health: " .. tostring(ent.aHealth))
		end
	else
		return
	end
end)

concommand.Add("gm_giveswep", function(ply, cmd, args)
	return
end)

concommand.Add("gm_spawnsent", function(ply, cmd, args)
	return
end)

concommand.Add("gm_spawnsent2", function(ply, cmd, args)
	local AllowedSENTs = { "gb_cam", "gb_core" }
	if ( args[1] == nil || !table.HasValue( AllowedSENTs, args[1] ) || gb_CurrentRound != 1 ) then return end

	local sent = scripted_ents.GetStored( args[1] )
	if (sent == nil) then return end

	sent = sent.t

	if (!sent.SpawnFunction) then return end

	if ( !gamemode.Call( "PlayerSpawnSENT", ply, args[1] ) ) then return end

	local vStart = ply:GetShootPos()
	local vForward = ply:GetAimVector()
	local trace = {}
	trace.start = vStart
	trace.endpos = vStart + (vForward * 2048)
	trace.filter = ply
	local tr = util.TraceLine( trace )
	local entity = sent:SpawnFunction( ply, tr )

	if ( entity ) then
		gamemode.Call( "PlayerSpawnedSENT", ply, entity )

		undo.Create("SENT")
			undo.SetPlayer(ply)
			undo.AddEntity(entity)
		undo.Finish( "Scripted Entity ("..tostring(args[1])..")" )

		ply:AddCleanup( "sents", entity )		
		entity:SetVar( "Player", ply )
	end
end)

concommand.Add("gmod_spawnnpc", function(ply, cmd, args)
	return
end)

concommand.Add("gm_spawnvehicle", function(ply, cmd, args)
	return
end)

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

concommand.Add("gb_togglecam", function(ply, cmd, args)
	local spectating = ply:GetNetworkedBool("spectating")
	local cam = ply:GetNetworkedEntity("gb_cam")

	if(spectating) then
		if(gb_CurrentRound == 1) then
			ply:UnSpectate()
			ply:Give( "gmod_tool" )
			ply:Give( "gmod_camera" )
			ply:Give( "weapon_physgun" )
			ply:SetNetworkedBool("spectating", false)
		else
			ply:UnSpectate()
			ply:Spectate( OBS_MODE_ROAMING )
			ply:SetNetworkedBool("spectating", false)
		end
		ply:SetEyeAngles(Angle(ply:EyeAngles().p, ply:EyeAngles().y, 0))

	elseif(!spectating) then
		if(cam:IsValid()) then
			ply:UnSpectate()
			ply:Spectate( OBS_MODE_CHASE )
			ply:SpectateEntity(cam)
			ply:StripWeapons()
			ply:SetNetworkedBool("spectating", true)
		else
			ply:PrintMessage(HUD_PRINTTALK, "You do not have a camera!")	
		end
	end
end)

concommand.Add("gb_changeteam", function(ply, cmd, args)
	if gb_CurrentRound != 1 then
		ply:ChatPrint("You cannot change teams during the fight.")
		return
	end

	if (team.NumPlayers(1) == team.NumPlayers(2)) then
		RemoveRobot(ply)
		ply:Kill()

		if args[1] == "red" then
			ply:SetTeam( 1 )
		elseif args[1] == "blue" then
			ply:SetTeam( 2 )
		end

		return

	elseif (team.NumPlayers(1) < team.NumPlayers(2)) then
		if args[1] == "red" then
			RemoveRobot(ply)
			ply:Kill()
			ply:SetTeam( 1 )

			return
		end

	elseif (team.NumPlayers(1) > team.NumPlayers(2)) then
		if args[1] == "blue" then
			RemoveRobot(ply)
			ply:Kill()
			ply:SetTeam( 2 )

			return
		end
	end

	ply:ChatPrint("There are too many players on that team.")
end)

KaboomTable = {}
timer.Create("kaboom", 0.1, 0, function()
	if #KaboomTable == 0 then return end //nothing to blow up
	local ent = KaboomTable[1]
	table.remove(KaboomTable, 1)

	if (ent != nil && ent:IsValid()) then
		DestroyProp(ent)
	else
		Kaboom()
	end
end)

function DestroyProp(ent)
	local vPoint = ent:GetPos()

	local effectdata = EffectData()
	effectdata:SetStart( vPoint )
	effectdata:SetOrigin( vPoint )
	effectdata:SetScale( 2 )
	util.Effect( "Explosion", effectdata )
	ent.Remove(ent)
end

function RemoveRobot( player )
	for k, ent in pairs(ents.GetAll()) do
		if ent:GetVar( "Founder", "nothing" ) == player then
			ent.Remove(ent)
		end
	end
end

function DestroyRobot(player)
	if player:GetNetworkedEntity("gb_core"):IsValid() then
		player:GetNetworkedEntity("gb_core"):GetTable():DestroyEffects()
	end

	local RemoveMe = {"gb_cam", "gmod_thruster", "gmod_wheel", "prop_physics"} //delete all of these
	for k, TypeToRemove in pairs(RemoveMe) do
		local playerents = ents.FindByClass(TypeToRemove)

		for k, ent in pairs(playerents) do
			if ent:IsValid() then
				if (ent:GetVar( "Founder", "nothing" ) == player && !ent:GetVar("DamageModel")) then
					table.insert( KaboomTable, ent )
				end
			end
		end
	end
end

concommand.Add("gb_forfeit", function(ply, cmd, args)
	if gb_CurrentRound == 1 then
		ply:ChatPrint("You can only forfeit during the fight.")
		return
	end

	DestroyRobot(ply)
end)

function GM:PlayerDisconnected( ply )
	RemoveRobot( ply )
end

function GM:ShowHelp( ply )
end

hook.Add("ShowHelp", "gb_F1Menu", function(ply)
	ply:ConCommand("gb_openf1")
end)

hook.Add("ShowTeam", "gb_F2Menu", function(ply)
	ply:ConCommand("gb_openf2")
end)

hook.Add("ShowSpare1", "gb_F3Menu", function(ply)
	ply:ConCommand("gb_openf3")
end)

hook.Add("ShowSpare2", "gb_F4Menu", function(ply)
	ply:ConCommand("gb_openf4")
end)

hook.Add("PlayerSay", "gb_MOTDCmd", function(ply, text)
	if string.lower(text) == "!motd" then
		ply:ConCommand("gb_openmotd")
	end
end)

hook.Add("PlayerNoClip", "gb_Noclip", function(ply, bool)
	local spectating = ply:GetNetworkedBool("spectating")
	print(spectating)

	if spectating then
		return false
	end
end)

function GM:CanTool( pl, tr, toolmode )
	if !gb_ToolsWhitelist[toolmode] then
		pl:PrintMessage(HUD_PRINTTALK, "That tool is not allowed.")
		return false
	end

	local trent = tr.Entity
	if ((!trent:IsValid() && !trent:IsWorld()) || trent:IsPlayer() || (trent:IsWorld() && !gb_WorldToolsWhitelist[toolmode])) then
		return false
	elseif (trent:IsWorld() && gb_WorldToolsWhitelist[toolmode] then
		return true
	end

	if (!trent:GetVar( "Founder", "nothing" )) then //unowned
		trent:SetVar( "Founder", pl ) //own it
	end

	if (trent:GetVar( "Founder", "nothing" ) == pl || pl:IsAdmin()) then
		return GAMEMODE.BaseClass:CanTool(pl, tr, toolmode)
	else
		pl:PrintMessage(HUD_PRINTTALK, "This is not your entity!")
		return false
	end
end

function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )

	if (team.NumPlayers(2) > team.NumPlayers(1)) then
		ply:SetTeam( 1 )

	elseif (team.NumPlayers(2) < team.NumPlayers(1)) then
		ply:SetTeam( 2 )

	else
		ply:SetTeam( math.random(1,2) )
	end

	if gb_CurrentRound != 1 then
		ply:StripWeapons()
		ply:Spectate( OBS_MODE_ROAMING )
	end

	ply:SetVar("DamageDelt", 0)

	net.Start("gb_timercountdown")
		net.WriteInt(gb_RoundTimer, 32)
	net.Send(ply)

	net.Start("gb_changeround")
		net.WriteInt(gb_CurrentRound, 32)
	net.Send(ply)

	net.Start("gb_updateteamcores")
		net.WriteInt(gb_NumRedCores, 32)
		net.WriteInt(gb_NumBlueCores, 32)
	net.Send(ply)
end

function GM:PlayerSpawn( ply )
	self.BaseClass:PlayerSpawn( ply )
	ply:ShouldDropWeapon(false) //fix the spectator with gun bug

	if gb_CurrentRound != 1 then
		// Put them into spectator mode
		local cam = ply:GetNetworkedEntity("gb_cam")

		if(cam:IsValid()) then
			ply:Spectate( OBS_MODE_CHASE )
			ply:SpectateEntity(cam)
		else
			ply:Spectate( OBS_MODE_ROAMING )
		end
		ply:StripWeapons()
	end
end

function GM:PlayerSelectSpawn(ply)
	if ply:Team() == 2 then
		spawns = ents.FindByClass( "info_player_blue" )
		local randomspawn = math.random(#spawns)
		return spawns[randomspawn]
	
	elseif ply:Team() == 1 then
		spawns = ents.FindByClass( "info_player_red" )
		local randomspawn = math.random(#spawns)
		return spawns[randomspawn]
	end
end

function GM:PlayerSpawnedProp( ply, model, prop )
	prop:SetVar( "Founder", ply )

	self.BaseClass:PlayerSpawnedProp( ply, model, prop )

	local color = team.GetColor( ply:Team() )
	local colorfix = Color(color.r, color.g, color.b)
	local physObj = prop:GetPhysicsObject()

	// Set the color
	prop:SetColor(colorfix)
	physObj:Sleep()

	SetPropHealth(prop)
end

function GM:PlayerSpawnedSENT( ply, prop )
	prop:SetVar( "Founder", ply )

	self.BaseClass:PlayerSpawnedSENT(ply, prop)
end

function GM:AllowPlayerPickup(ply, ent)
	return false
end

function GM:GetFallDamage(ply, speed)
	return false
end

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

		prop:Fire("physdamagescale", tostring(gb_PropDamageScale))
	end
end

//bug fix
local baseRemoveAllConstraints = constraint.RemoveAll
function constraint.RemoveAll(ent)
	local constraints = constraint.FindConstraints( ent, "Motor" )

	for k, const in pairs(constraints) do
		if const.axis then
			const.axis:Remove()
		end
	end

	baseRemoveAllConstraints(ent)
end

//bug fix
local baseRemoveConstraints = constraint.RemoveConstraints
function constraint.RemoveConstraints( ent, type )
	if (string.lower(type) == "motor") then
		local constraints = constraint.FindConstraints( ent, "Motor" )

		for k, const in pairs(constraints) do
			if const.axis then
				const.axis:Remove()
			end
		end
	end

	baseRemoveConstraints(ent, type)
end

function GM:EntityTakeDamage( ent, dmginfo )
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()
	local inflictor = dmginfo:GetInflictor()

	if (ent:IsWorld() || ent:IsPlayer() || attacker:IsPlayer() || gb_CurrentRound == 1) then return end

	if (attacker && !attacker:IsWorld() && attacker:IsValid() && attacker:GetVar("Founder"):IsValid() && ent:GetVar("Founder"):IsValid()) then
		if (!gb_FriendlyFire && (attacker:GetVar("Founder"):Team() == ent:GetVar("Founder"):Team()) && (attacker:GetVar("Founder") != ent:GetVar("Founder"))) then
			attacker:GetVar("Founder"):PrintMessage(HUD_PRINTTALK, "Watch the friendly fire!")
			return
		end

		if (attacker:GetVar("Founder") != ent:GetVar("Founder")) then
			ent:GetVar("Founder"):SetVar("DamageDelt", ent:GetVar("Founder"):GetVar("DamageDelt") + amount)
		else
			return //no self damage
		end
	end

	if ent:GetVar("DamageModel") then
		if ent:GetVar("DamageModel"):IsValid() then
			ent:GetVar("DamageModel"):Damage(amount)
		end
	else
		if (ent.aHealth == nil) then
			SetPropHealth(ent)
		end

		ent.aHealth = ent.aHealth - amount

		if (ent.aHealth <= 0) then
			constraint.RemoveAll(ent)
		end

		if (ent.aHealth < -100) then
			DestroyProp(ent)
		end
	end
end

function GM:CanPlayerEnterVehicle( player, vehicle, role )
	return false
end

function GM:PlayerLoadout(ply)
	if gb_CurrentRound == 1 then
		ply:Give( "gmod_tool" )
		ply:Give( "gmod_camera" )
		ply:Give( "weapon_physgun" )
	end

	return true
end

function GM:PhysgunPickup(ply, ent)
	if (ent:GetClass() == "gb_core" || !ent:IsValid() || ent:IsWorld()) then return end
	if (ent:IsPlayer() && !ply:IsAdmin()) then return end

	if (!ent:GetVar( "Founder", "nothing" )) then //unowned
		ent:SetVar( "Founder", ply ) //own it
	end

	if (ent:GetVar( "Founder", "nothing" ) == ply || ply:IsAdmin()) then
		return true
	end

	return false
end

concommand.Add("gethealth", function(ply, cmd, args)
	local traceres = ply:GetEyeTrace()
	local ent = traceres.Entity
	local healthobjs = {"prop_physics"}

	if (!ent:IsValid() || ent:IsWorld() || ent:IsPlayer() || !table.HasValue( healthobjs, ent:GetClass())) then
		ply:PrintMessage(HUD_PRINTTALK, "You must be looking at a prop to do this!")
	else
		ply:PrintMessage(HUD_PRINTTALK, "Current Prop Health: " .. tostring(ent.aHealth))
	end
end)
