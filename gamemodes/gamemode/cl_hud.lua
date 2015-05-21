surface.CreateFont("HUD_Font", {
	font = "coolvetica",
	size = 28,
	weight = 500,
	antialias = true,
	additive = false,
})

local fade_offset = 0 //needs to keep its value outside of DrawHUD

function DrawHUD()
	//DEFINES
	local TOP_BAR_SIZE = 20
	local TOP_BAR_BORDER_SIZE = 3
	local SCORE_BOX_WIDTH = 200
	local SCORE_BOX_HEIGHT = 82
	local SCORE_BOX_CORNER_SIZE = 10

	local TOP_BAR_COLOR = Color(64, 64, 64, 180)
	local TOP_BAR_BORDER_COLOR = Color(0, 0, 0, 255)
	//local TOP_BAR_BORDER_COLOR2 = Color(255, 255, 0, 255)
	local TOP_BAR_BORDER_COLOR2 = team.GetColor(LocalPlayer():Team())
	local TOP_BAR_TEXT_COLOR = Color(255, 255, 255, 255)
	local SCORE_BOX_COLOR = TOP_BAR_COLOR //I wouldn't change this...

	local TOP_BAR_FONT = "HudHintTextLarge"
	local SCORE_BOX_FONT = "HUD_Font"

	local FADE_RATE = 0.5
	local FADE_ACCURACY = 40

	//bar background
	draw.RoundedBox( 0, 0, 0, ScrW()/2 - SCORE_BOX_WIDTH/2, TOP_BAR_SIZE, TOP_BAR_COLOR );
	draw.RoundedBox( 0, ScrW()/2 + SCORE_BOX_WIDTH/2, 0, ScrW()/2 - SCORE_BOX_WIDTH/2, TOP_BAR_SIZE, TOP_BAR_COLOR );

	//score panel
	draw.RoundedBox( SCORE_BOX_CORNER_SIZE, ScrW()/2 - SCORE_BOX_WIDTH/2, -25, SCORE_BOX_WIDTH, SCORE_BOX_HEIGHT + TOP_BAR_SIZE + TOP_BAR_BORDER_SIZE, SCORE_BOX_COLOR );

	//bar border
	local num_chunks = FADE_ACCURACY * 2 + 3 //3 for left center and right
	local chunk_size = ScrW() / num_chunks
	local r_unit = (TOP_BAR_BORDER_COLOR2.r - TOP_BAR_BORDER_COLOR.r) / (FADE_ACCURACY + 1)
	local g_unit = (TOP_BAR_BORDER_COLOR2.g - TOP_BAR_BORDER_COLOR.g) / (FADE_ACCURACY + 1)
	local b_unit = (TOP_BAR_BORDER_COLOR2.b - TOP_BAR_BORDER_COLOR.b) / (FADE_ACCURACY + 1)
	local a_unit = (TOP_BAR_BORDER_COLOR2.a - TOP_BAR_BORDER_COLOR.a) / (FADE_ACCURACY + 1)

	fade_offset = fade_offset + FADE_RATE
	if fade_offset > num_chunks then
		fade_offset = 0
	end

	for i=1, num_chunks do
		local position = (i-1 + math.floor(fade_offset)) * chunk_size

		while (position >= ScrW()) do
			position = position - ScrW()
		end

		local color_position

		if i > math.ceil(num_chunks / 2) then
			color_position = math.ceil(num_chunks / 2) - (i - math.ceil(num_chunks / 2))
		else
			color_position = i - 1
		end

		local new_color = Color(
			TOP_BAR_BORDER_COLOR.r + (r_unit * color_position),
			TOP_BAR_BORDER_COLOR.g + (g_unit * color_position),
			TOP_BAR_BORDER_COLOR.b + (b_unit * color_position),
			TOP_BAR_BORDER_COLOR.a + (a_unit * color_position) )

		draw.RoundedBox( 0, position, TOP_BAR_SIZE, chunk_size + 1, TOP_BAR_BORDER_SIZE, new_color );
		//I add one to the size to combat a rounding error you sometimes get
	end

	//bar text
	local round = ""
	if gb_CurrentRound == 1 then
		round = "Build"
	elseif gb_CurrentRound == 2 then
		round = "Fight"
	else
		round = "Post Game"
	end

	local spacing = (ScrW()-4) / 5
	draw.DrawText( "Core Health: "..LocalPlayer():GetVar("gb_corehealth", 0), TOP_BAR_FONT, 2 + (spacing * 0), 2, TOP_BAR_TEXT_COLOR)
	draw.DrawText( "Time Left: "..string.FormattedTime( gb_RoundTimer, "%02i:%02i"), TOP_BAR_FONT, 2 + (spacing * 0.7), 2, TOP_BAR_TEXT_COLOR)
	draw.DrawText( "Round: "..round, TOP_BAR_FONT, 2 + (spacing * 4.4), 2, TOP_BAR_TEXT_COLOR)

	//score panel text
	draw.DrawText( "Cores Remaining", SCORE_BOX_FONT, ScrW()/2 - 82, TOP_BAR_SIZE + TOP_BAR_BORDER_SIZE + 2, Color(255, 255, 255, 255))
	draw.DrawText( "Red: "..gb_NumRedCores, SCORE_BOX_FONT, ScrW()/2 - 90, TOP_BAR_SIZE + TOP_BAR_BORDER_SIZE + 2 + 27, Color(255, 0, 0, 255))
	draw.DrawText( "|", SCORE_BOX_FONT, ScrW()/2 - 3, TOP_BAR_SIZE + TOP_BAR_BORDER_SIZE + 2 + 27, Color(0, 0, 0, 255))
	draw.DrawText( "Blue: "..gb_NumBlueCores, SCORE_BOX_FONT, ScrW()/2 + 20, TOP_BAR_SIZE + TOP_BAR_BORDER_SIZE + 2 + 27, Color(0, 0, 255, 255))

	//Draw the fuxoring melon owner names.
	for k, v in pairs(player.GetAll()) do
		local melon = v:GetNetworkedEntity("gb_core").DamageProp

		if (melon && melon:IsValid()) then
			local alpha = 0
			local position = melon:GetPos()
			local position = Vector(position.x, position.y, position.z + 30)
			local screenpos = position:ToScreen()
			local dist = position:Distance(LocalPlayer():GetPos())
			local dist = dist / 4
			local dist = math.floor(dist)

			if(dist > 100) then
				alpha = 255 - (dist - 100)
			else
				alpha = 255
			end

			if(alpha > 255) then
				alpha = 255
			elseif(alpha < 0) then
				alpha = 0
			end

			draw.DrawText( v:Nick(), "DefaultSmall", screenpos.x, screenpos.y, Color(255, 255, 255, alpha), 1)
			draw.DrawText( v:GetVar("gb_corehealth", 0), "DefaultSmall", screenpos.x, screenpos.y + 10, Color(255, 255, 255, alpha), 1)
		end
	end
end
hook.Add("HUDPaint", "DrawHUD", DrawHUD); 

function HideHud(name)      
	for k, v in pairs{"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"} do          
		if name == v then 
			return false      
		end

		return true   
	end  
end
hook.Add("HUDShouldDraw", "Hide HUD Components", HideHud)
