function GM:AddGamemodeToolMenuCategories()
	spawnmenu.AddToolCategory( "Main", "Construction", "#Construction" )
	spawnmenu.AddToolCategory( "Main", "Garry's Bots", "#Garry's Bots" )

	local baseAddToolCategory = spawnmenu.AddToolCategory
	
	function spawnmenu.AddToolCategory( tab, RealName, PrintName )
		if (tab == "Main") then return end
		baseAddToolCategory( tab, RealName, PrintName )
	end
end

local baseAddToolMenuOption = spawnmenu.AddToolMenuOption
function spawnmenu.AddToolMenuOption( tab, cat, name, text, cmd, cp, cpf, btn )
	if (tab == "Main") then
		if !gb_ToolsWhitelist[name] then return end

		if cat != "Garry's Bots" then
			baseAddToolMenuOption( tab, "Construction", name, text, cmd, cp, cpf, btn )
		else
			baseAddToolMenuOption( tab, "Garry's Bots", name, text, cmd, cp, cpf, btn )
		end
	else
		baseAddToolMenuOption( tab, cat, name, text, cmd, cp, cpf, btn )
	end
end

local ws_dupe = WorkshopFileBase()
function ws_dupe:DownloadAndArm(id)
	return false
end