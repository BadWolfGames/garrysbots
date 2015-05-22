// Config
gb_sb_top = "Garry's Bots"
gb_sb_middle = "Press F1 for the help menu."
gb_sb_bottom = "Developed by LuaBanana and Craze, maintained by BWG"

gb_BuildTime = 900
gb_FightTime = 300

gb_PostGameTime = 25

gb_MaxPropSize = 400

gb_MaxPropMass = 2000

gb_FriendlyFire = false

gb_VoteSkipPercent = 0.75

gb_CoreHealth = 1000
gb_CoreDamageScale = 1.5

gb_PropDamageScale = 0.75
gb_PropHealthAdd = 25
gb_PropMaxHealth = 500

gb_SuddenDeath = true //at 1:00 remaining in the fight, prop damage scales
gb_SuddenDeathPropDamageScale = 5

//1 - fixed
//2 - dynamic A
//3 - dynamic B
gb_PropHealthMethod = 2

//fixed settings
gb_FixedPropHealth = 100

//dynamic A settings
gb_PropSizeModifier = 0.006

//dynamic B settings
gb_PropHealthModifier = 0.075

gb_BannedProps = {
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_junk/trashdumpster02.mdl",
	"models/props_phx/ball.mdl",
	"models/props_phx/amraam.mdl",
	"models/props_phx/mk-82.mdl",
	"models/props_phx/oildrum001_explosive.mdl",
	"models/props_phx/ww2bomb.mdl",
	"models/props_phx/torpedo.mdl",
	"models/props_phx/misc/flakshell_big.mdl",
	"models/props_phx/cannonball.mdl",
	"models/props_phx/misc/smallcannonball.mdl",
	"models/props_junk/propane_tank001a.mdl",
	"models/props_junk/gascan001a.mdl"
}

AllowableTools = {
	"adv_duplicator",
	"ballsocket",
	"ballsocket_adv",
	"ballsocket_ez",
	"elastic",
	"hydraulic",
	"muscle",
	"motor",
	"nocollide",
	"pulley",
	"remover",
	"slider",
	"gbots_thruster",
	"weld",
	"weld_ez",
	"gbots_wheel",
	"winch",
	"axis",
	"rope",
	"gbots_weight",
	"wheel"
}

AllowableWorldTools = { //things that you can shoot the world with, needs to be in the other table too
	"adv_duplicator"
}

MOTDHTML = [[
<html>
<body bgcolor=#dbdbdb>
<div style="text-align: center;">
<div style="width: 80%; margin: 0px auto; border: 10px solid #c9d6e4; background-color: #ededed; padding: 10px; font-size: 12px; font-family: Tahoma; margin-top: 30px; color: #818181; text-align: left;">
<div style="font-size: 30px; width: 100%; text-align: center; font-weight: bold;">Garry's Bots</div><br>

<div style="font-size: 20px; width: 100%; font-weight: bold; text-align: center;">-Notice-</div><br>
<div style="text-align: center;">CHILDREN ARE FREE TAKE THEM<br></div>

<div style="font-size: 20px; width: 100%; font-weight: bold;">Rules:</div><br>
1. No huge bots<br>
2. Listen to the admins<br>
3. If you get kicked, don't instantly reconnect, thats asking for a ban<br>
4. Don't bitch about the lag! If it's lagging, everyone else notices it too. Unless it's just you, then we can't do anything about it<br>
5. Ceiling/Wall bots are ok IF YOU ARE ACTUALLY PLAYING. If you are just hiding there so you will win, you'll find yourself banned.<br>
6. Asking about things that are covered in the MOTD/Help screen will earn you a kick.

<br><br>
<div style="font-size: 20px; width: 100%; font-weight: bold;">Help:</div><br>
Refer to the gamemode help screen, press F1.<br><br>

<div style="width: 100%; text-align: center; margin: 10px; font-weight: bold;">- Server Administration</div>
</div>
</div>

</body>
</html>
]]

HelpMenuHTML = [[
<html>
<body bgcolor=#dbdbdb>
<div style="text-align: center;">
<div style="width: 80%; margin: 0px auto; border: 10px solid #c9d6e4; background-color: #ededed; padding: 10px; font-size: 12px; font-family: Tahoma; margin-top: 30px; color: #818181; text-align: left;">

<div style="font-size: 30px; width: 100%; text-align: center; font-weight: bold;">Garry's Bots Help</div><br>
<div style="text-align: center; font-weight: bold;">Current version of Garry's Bots: ]]..gb_Version..[[</div><br>

<div style="font-size: 20px; width: 100%; font-weight: bold;">How to play:</div><br>
To play, you will need a core SENT, this can be spawned from the F4 menu.<br>
You can also find the camera in this menu, if you have one of these, you will acutomaticly spectate it when the fight starts.<br>
Your core must be pointing up(the direction of the laser), otherwise you will take flipping damage.<br>
Be sure to weld to your core, only things that are constrained to the core will be teleported into the arena.<br>
If your core is destroyed, you robot dies, be sure to protect it!<br><br>

Everything takes damage, when a prop takes enough damage it will fall off, and eventually explode.<br>
You can also press F3 to access the forfeit button, which will destroy your robot.<br><br>

If you have any other questions, just ask around.<br><br>

<div style="width: 100%; text-align: center; margin: 10px; font-weight: bold;">- The Garry's Bots Dev team</div>
</div>
</div>
</body>
</html>
]]
