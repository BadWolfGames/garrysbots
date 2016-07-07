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
include( "sh_scoreboard.lua" )
include( "sv_funcs.lua" )
include( "sv_damage.lua" )
include( "sv_admin.lua" )
include( "sv_commands.lua" )
include( "sv_player.lua" )
include( "sv_round.lua" )
include( "sv_propspawn.lua" )
include( "sv_robot.lua" )

util.AddNetworkString("gb_timercountdown")
util.AddNetworkString("gb_changeround")
util.AddNetworkString("gb_updateteamcores")
util.AddNetworkString("gb_postgame")
util.AddNetworkString("gb_announcement")

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

function GM:CanTool( pl, tr, toolmode )
	if !gb_ToolsWhitelist[toolmode] then
		pl:PrintMessage(HUD_PRINTTALK, "That tool is not allowed.")
		return false
	end

	local trent = tr.Entity

	if ((!trent:IsValid() && !trent:IsWorld()) || trent:IsPlayer() || (trent:IsWorld() && !gb_WorldToolsWhitelist[toolmode]) ) then
		return false
	elseif (trent:IsWorld() && gb_WorldToolsWhitelist[toolmode]) then
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

function GM:AllowPlayerPickup(ply, ent)
	return false
end

function GM:GetFallDamage(ply, speed)
	return false
end

--//bug fix
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

--bug fix
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


function GM:CanPlayerEnterVehicle( player, vehicle, role )
	return false
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
