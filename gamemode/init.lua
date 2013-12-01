resource.AddFile("materials/effects/whiteoverlay.vmt")
resource.AddFile("materials/sprites/coreglow.vmt")
resource.AddFile("materials/sprites/coreshrap.vmt")
resource.AddFile("materials/sprites/coresmoke.vmt")
AddCSLuaFile( "defines.lua" )
AddCSLuaFile( "config.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_umsg.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_gui.lua" )
AddCSLuaFile( "cl_spawnmenu.lua" )
AddCSLuaFile( "sh_scoreboard.lua" )
include( "defines.lua" )
include( "config.lua" )
include( "shared.lua" )
include( "game_func.lua" )
include( "sh_scoreboard.lua" )
include( "admin.lua" )

function KeyPressed (ply, key)
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
end
hook.Add( "KeyPress", "KeyPressedHook", KeyPressed ) 

function CCSpawnSWEP( player, command, arguments )
	return
end
concommand.Add( "gm_giveswep", CCSpawnSWEP )

function CCSpawnSENT( player, command, arguments )//break the SENT menu
	return
end
concommand.Add( "gm_spawnsent", CCSpawnSENT )

function CCSpawnSENT2( player, command, arguments )
	local AllowedSENTs = { "gb_cam", "gb_core" }
	if ( arguments[1] == nil || !table.HasValue( AllowedSENTs, arguments[1] ) || gb_CurrentRound != 1 ) then return end

	local sent = scripted_ents.GetStored( arguments[1] )
	if (sent == nil) then return end

	sent = sent.t

	if (!sent.SpawnFunction) then return end

	if ( !gamemode.Call( "PlayerSpawnSENT", player, arguments[1] ) ) then return end

	local vStart = player:GetShootPos()
	local vForward = player:GetAimVector()
	local trace = {}
	trace.start = vStart
	trace.endpos = vStart + (vForward * 2048)
	trace.filter = player
	local tr = util.TraceLine( trace )
	local entity = sent:SpawnFunction( player, tr )

	if ( entity ) then
		gamemode.Call( "PlayerSpawnedSENT", player, entity )

		undo.Create("SENT")
			undo.SetPlayer(player)
			undo.AddEntity(entity)
		undo.Finish( "Scripted Entity ("..tostring(arguments[1])..")" )

		player:AddCleanup( "sents", entity )		
		entity:SetVar( "Player", player )
	end
end
concommand.Add( "gm_spawnsent2", CCSpawnSENT2 )

function CCSpawnNPC( player, command, arguments )
	return
end
concommand.Add( "gmod_spawnnpc", CCSpawnNPC )

function CCSpawnVehicle( player, command, arguments )
	return
end
concommand.Add( "gm_spawnvehicle", CCSpawnVehicle )

function CCSpawn( player, command, arguments )
	if gb_CurrentRound != 1 then return end

	if ( arguments[1] == nil ) then return end
	if ( !gamemode.Call( "PlayerSpawnObject", player ) ) then return end
	if ( !util.IsValidProp( arguments[1] ) ) then return end

	GMODSpawnProp( player, arguments[1], 0, 0 )
end
concommand.Add( "gm_spawn", CCSpawn )

function PropCheck( player, model )
	local prop = DoPlayerEntitySpawn( player, "prop_physics", model, 1 )
	local min,max = prop:WorldSpaceAABB()
	local size = min:Distance(max)
	local physob = prop:GetPhysicsObject()
	local propmass = 0
	if (physob && physob:IsValid()) then propmass = physob:GetMass() end
	prop:Remove()

	for k, v in pairs(gb_BannedProps) do
		if string.gsub(string.gsub(model, "/", ""), "\\", "") == string.gsub(string.gsub(v, "/", ""), "\\", "") then
			//player:ChatPrint("That prop is banned.")
			player:ChatPrint("That prop is not allowed.")
			return false
		end
	end

	if size > gb_MaxPropSize then
		//player:ChatPrint("That prop is too big.")
		player:ChatPrint("That prop is not allowed.")
		return false
	end

	if propmass > gb_MaxPropMass then
		//player:ChatPrint("That prop is too heavy.")
		player:ChatPrint("That prop is not allowed.")
		return false
	end

	return true
end
hook.Add("PlayerSpawnProp", "Prop Check", PropCheck)

function ToggleCamera(ply, cmd, args)
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
end
concommand.Add("gb_togglecam", ToggleCamera)

function ChangeTeam(ply, cmd, args)
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
end
concommand.Add("gb_changeteam", ChangeTeam)

KaboomTable = {}
function Kaboom()
	if table.getn(KaboomTable) == 0 then return end //nothing to blow up
	local ent = KaboomTable[1]
	table.remove(KaboomTable, 1)
	if (ent != nil && ent:IsValid()) then
		//MsgAll("                                   kaboom ran with valid ent\n")
		DestroyProp(ent)
	else
		//MsgAll("                                   kaboom ran with invalid ent\n")
		Kaboom()
	end
end
timer.Create("kaboom", 0.1, 0, Kaboom)

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
	//MsgAll("                      destroy robot called\n")
	if player:GetNetworkedEntity("gb_core"):IsValid() then
		player:GetNetworkedEntity("gb_core"):GetTable():DestroyEffects()
	end

	local RemoveMe = {"gb_cam", "gmod_thruster", "gmod_wheel", "prop_physics"} //delete all of these
	for k, TypeToRemove in pairs(RemoveMe) do
		local playerents = ents.FindByClass(TypeToRemove)
		for k, ent in pairs(playerents) do
			if ent:IsValid() then
				if (ent:GetVar( "Founder", "nothing" ) == player && !ent:GetVar("DamageModel")) then
					//MsgAll("                                    destroy robot added: "..tostring(ent).."\n")
					table.insert( KaboomTable, ent )
				end
			end
		end
	end
end

function PlayerForfeit( player, command, arguments )
	//MsgAll("                                           forfeit called\n")
	if gb_CurrentRound == 1 then
		player:ChatPrint("You can only forfeit during the fight.")
		return
	end
	DestroyRobot(player)
end
concommand.Add("gb_forfeit", PlayerForfeit)

function GM:PlayerDisconnected( ply )
	RemoveRobot( ply )
end

function GM:ShowHelp( ply )
end

function ShowF1Menu( player )
	umsg.Start("ShowF1Menu", player)
	umsg.End()
end
hook.Add("ShowHelp", "F1Menu", ShowF1Menu)  

function ShowF2Menu( player )
	umsg.Start("ShowF2Menu", player)
	umsg.End()
end
hook.Add("ShowTeam", "F2Menu", ShowF2Menu)  

function ShowF3Menu( player )
	umsg.Start("ShowF3Menu", player)
	umsg.End()
end
hook.Add("ShowSpare1", "F3Menu", ShowF3Menu)

function ShowF4Menu( player )
	umsg.Start("ShowF4Menu", player)
	umsg.End()
end
hook.Add("ShowSpare2", "F4Menu", ShowF4Menu)

function ShowMOTD( player, text )
	if (string.lower(text) == "!motd") then
		umsg.Start("ShowMOTD", player)
		umsg.End()
	end
end
hook.Add("PlayerSay", "ShowMOTD", ShowMOTD)

function GM:CanTool( pl, tr, toolmode )
	//MsgAll("                  toolmode: "..tostring(toolmode).."\n")
	if !table.HasValue( AllowableTools, toolmode ) then
		pl:PrintMessage(HUD_PRINTTALK, "That tool is not allowed.")
		return false
	end

	local trent = tr.Entity
	if ((!trent:IsValid() && !trent:IsWorld()) || trent:IsPlayer() || (trent:IsWorld() && !table.HasValue( AllowableWorldTools, toolmode ))) then
		return false
	elseif (trent:IsWorld() && table.HasValue( AllowableWorldTools, toolmode )) then
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

	umsg.Start("timercountdown", ply)
		umsg.Long(gb_RoundTimer)
	umsg.End()

	umsg.Start("changeround", ply)
		umsg.Long(gb_CurrentRound)
	umsg.End()

	umsg.Start("updateteamcores", ply)
		umsg.Long(gb_NumRedCores)
		umsg.Long(gb_NumBlueCores)
	umsg.End()
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

function GM:PlayerSelectSpawn(pl)
	if pl:Team() == 2 then
		spawns = ents.FindByClass( "info_player_blue" )
		local randomspawn = math.random(#spawns)
		return spawns[randomspawn]
	
	elseif pl:Team() == 1 then
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

function GetPropHealth(ply, cmd, args)
	local traceres = ply:GetEyeTrace()
	local ent = traceres.Entity
	local healthobjs = {"prop_physics"}
	if (!ent:IsValid() || ent:IsWorld() || ent:IsPlayer() || !table.HasValue( healthobjs, ent:GetClass())) then
		ply:PrintMessage(HUD_PRINTTALK, "You must be looking at a prop to do this!")
	else
		ply:PrintMessage(HUD_PRINTTALK, "Current Prop Health: " .. tostring(ent.aHealth))
	end
end
concommand.Add("gethealth", GetPropHealth)
