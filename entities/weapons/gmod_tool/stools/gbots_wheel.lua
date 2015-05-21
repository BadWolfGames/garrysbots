//Hacky GBots wheel tool, doesn't use SENTs. by craze

TOOL.Category		= "Garry's Bots"
TOOL.Name		= "#Wheel"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "torque" ] 		= "3000"
TOOL.ClientConVar[ "friction" ] 	= "1"
TOOL.ClientConVar[ "nocollide" ] 	= "1"
//TOOL.ClientConVar[ "forcelimit" ] 	= "0"
TOOL.ClientConVar[ "fwd" ] 		= "8"	// Forward key
TOOL.ClientConVar[ "bck" ] 		= "5"	// Back key
TOOL.ClientConVar[ "toggle" ] 		= "0"	// Togglable
TOOL.ClientConVar[ "model" ] 		= "models/props_vehicles/carparts_wheel01a.mdl"
TOOL.ClientConVar[ "rx" ] 		= "90"
TOOL.ClientConVar[ "ry" ] 		= "0"
TOOL.ClientConVar[ "rz" ] 		= "90"
TOOL.ClientConVar[ "reverse" ] 		= "0"

if ( CLIENT ) then
	language.Add( 'Tool.gbots.wheel.name', 'Wheel Tool' )
	language.Add( 'Tool.gbots.wheel.desc', 'Attaches a wheel to something.' )
	language.Add( 'Tool.gbots.wheel.0', 'Click on a prop to attach a wheel.' )
end

function TOOL:LeftClick( trace )
	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end

	// If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end

	if (CLIENT) then return true end

	local ply = self:GetOwner()

	if ( !self:GetSWEP():CheckLimit( "gbots_wheels" ) ) then return false end

	local targetPhys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )

	// Get client's CVars
	local torque		= self:GetClientNumber( "torque" )
	local friction 		= self:GetClientNumber( "friction" )
	local nocollide		= self:GetClientNumber( "nocollide" )
	//local limit		= self:GetClientNumber( "forcelimit" )
	local limit		= 0
	local toggle		= self:GetClientNumber( "toggle" )
	local reverse		= self:GetClientNumber( "reverse" ) != 0
	local model		= self:GetClientInfo( "model" )

	local fwd		= self:GetClientNumber( "fwd" )
	local bck		= self:GetClientNumber( "bck" )

	if reverse then
		torque = -torque
		reverse = -1
	else
		reverse = 1
	end

	if ( !util.IsValidModel( model ) ) then return false end
	if ( !util.IsValidProp( model ) ) then return false end

	if !PropCheck( ply, model ) then return false end //found another use for this!

	// Create the wheel
	local wheelEnt = MakeWheel2( ply, trace.HitPos, Angle(0,0,0), model )

	// Make sure we have our wheel angle
	self.wheelAngle = Angle( tonumber(self:GetClientInfo( "rx" )), tonumber(self:GetClientInfo( "ry" )), tonumber(self:GetClientInfo( "rz" )) )

	local TargetAngle = trace.HitNormal:Angle() + self.wheelAngle	
	wheelEnt:SetAngles( TargetAngle )

	local CurPos = wheelEnt:GetPos()
	local NearestPoint = wheelEnt:NearestPoint( CurPos - (trace.HitNormal * 512) )
	local wheelOffset = CurPos - NearestPoint

	wheelEnt:SetPos( trace.HitPos + wheelOffset + trace.HitNormal )

	// Wake up the physics object so that the entity updates
	wheelEnt:GetPhysicsObject():Wake()

	local TargetPos = wheelEnt:GetPos()

	// Set the hinge Axis perpendicular to the trace hit surface
	local LPos1 = wheelEnt:GetPhysicsObject():WorldToLocal( TargetPos + trace.HitNormal )
	local LPos2 = targetPhys:WorldToLocal( trace.HitPos )

	local constraint, axis = constraint.Motor( wheelEnt, trace.Entity, 0, trace.PhysicsBone, LPos1,	LPos2, friction, torque, 0, nocollide, toggle, ply, limit, fwd, bck, 1 )

	constraint.axis = axis //hackage

	undo.Create("wheel")
	undo.AddEntity( axis )
	undo.AddEntity( constraint )
	undo.AddEntity( wheelEnt )
	undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "wheels", axis )
	ply:AddCleanup( "wheels", constraint )
	ply:AddCleanup( "wheels", wheelEnt )

	local effectdata = EffectData()
		effectdata:SetOrigin( wheelEnt:WorldToLocal( wheelEnt:NearestPoint( wheelEnt:GetPos() + trace.HitNormal * 512 ) ) ) //wow...
		effectdata:SetEntity( wheelEnt )
		effectdata:SetScale( reverse )
	util.Effect( "wheel_indicator", effectdata, true, true )

	return true
end

function TOOL:RightClick( trace )
end

function TOOL:Reload( trace )
	if (!trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end

	local constraints = constraint.FindConstraints( trace.Entity, "Motor" )
	local numconsts = #constraints
	for k, const in pairs(constraints) do
		local wheel
		local constent = const.Entity[1]
		if constent then
			wheel = constent.Entity
		end

		if (wheel && wheel:IsValid()) then
			wheel:Remove()
		end

		const.Constraint:Remove()
	end

	return numconsts != 0
end

if ( SERVER ) then
	CreateConVar('sbox_maxgbots_wheels', 20)

	function MakeWheel2( pl, Pos, Ang, Model ) //this isn't dupe compatible so I don't really need this...
		if ( !pl:CheckLimit( "gbots_wheels" ) ) then return false end
	
		local wheel = ents.Create( "prop_physics" )
		if ( !wheel:IsValid() ) then return end

		wheel:SetModel( Model )
		wheel:SetPos( Pos )
		wheel:SetAngles( Ang )
		wheel:Spawn()

		wheel:SetVar("Founder", pl)

		GAMEMODE:PlayerSpawnedProp( pl, Model, wheel )

		pl:AddCount( "wheels", wheel )

		return wheel
	end
end

function TOOL:UpdateGhostWheel( ent, player )
	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end
	
	local tr 	= util.GetPlayerTrace( player, player:GetAimVector() )
	local trace 	= util.TraceLine( tr )
	if (!trace.Hit) then return end
	
	if ( trace.Entity:IsPlayer() ) then
	
		ent:SetNoDraw( true )
		return
		
	end
	
	local Ang = trace.HitNormal:Angle() + self.wheelAngle
	local CurPos = ent:GetPos()
	local NearestPoint = ent:NearestPoint( CurPos - (trace.HitNormal * 512) )
	local WheelOffset = CurPos - NearestPoint
	
	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos + trace.HitNormal + WheelOffset )
	ent:SetAngles( Ang )
	
	ent:SetNoDraw( false )
end

function TOOL:Think()
	if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != self:GetClientInfo( "model" )) then
		self.wheelAngle = Angle( tonumber(self:GetClientInfo( "rx" )), tonumber(self:GetClientInfo( "ry" )), tonumber(self:GetClientInfo( "rz" )) )
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end

	self:UpdateGhostWheel( self.GhostEntity, self:GetOwner() )
end

function TOOL.BuildCPanel( CPanel )
	// HEADER
	CPanel:AddControl( "Header", { Text = "#Tool_wheel_name", Description	= "#Tool_wheel_desc" }  )
	
	local Options = { Default = { wheel_torque = "3000",
									wheel_friction = "0",
									wheel_nocollide = "1",
									wheel_forcelimit = "0" } }
									
	local CVars = { "wheel_torque", "wheel_friction", "wheel_nocollide", "wheel_forcelimit" }
	
	CPanel:AddControl( "ComboBox", { Label = "#Presets",
									 MenuButton = 1,
									 Folder = "wheel",
									 Options = Options,
									 CVars = CVars } )
									 
									 
	CPanel:AddControl( "Numpad", { Label = "#WheelTool_group",
									 Label2 = "#WheelTool_group_reverse",
									 Command = "gbots_wheel_fwd",
									 Command2 = "gbots_wheel_bck",
									 ButtonSize = "22" } )
									 
	CPanel:AddControl( "PropSelect", { Label = "#WheelTool_model",
									 ConVar = "gbots_wheel_model",
									 Category = "Wheels",
									 Models = list.Get( "WheelModels2" ) } )
									 
	CPanel:AddControl( "Slider", { Label = "#WheelTool_torque",
									 Description = "#WheelTool_torque_desc",
									 Type = "Float",
									 Min = 10,
									 Max = 10000,
									 Command = "gbots_wheel_torque" } )
									 
									 
	//CPanel:AddControl( "Slider", { Label = "#WheelTool_forcelimit",
	//								 Description = "#WheelTool_forcelimit_desc",
	//								 Type = "Float",
	//								 Min = 0,
	//								 Max = 50000,
	//								 Command = "gbots_wheel_forcelimit" } )
									 
	CPanel:AddControl( "Slider", { Label = "#WheelTool_friction",
									 Description = "#WheelTool_friction_desc",
									 Type = "Float",
									 Min = 0,
									 Max = 100,
									 Command = "gbots_wheel_friction" } )
									 
	CPanel:AddControl( "CheckBox", { Label = "#WheelTool_nocollide",
									 Description = "#WheelTool_nocollide_desc",
									 Command = "gbots_wheel_nocollide" } )
									 
	CPanel:AddControl( "CheckBox", { Label = "#WheelTool_toggle",
									 Description = "#WheelTool_toggle_desc",
									 Command = "gbots_wheel_toggle" } )

	CPanel:AddControl( "CheckBox", { Label = "Counterclockwise:",
									 Description = "Spin the wheel the other direction",
									 Command = "gbots_wheel_reverse" } )
									
end

list.Set( "WheelModels2", "models/props_junk/sawblade001a.mdl", { 		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_vehicles/carparts_wheel01a.mdl", { 	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 90} )
list.Set( "WheelModels2", "models/props_vehicles/apc_tire001.mdl", { 		gbots_wheel_rx = 0, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_vehicles/tire001a_tractor.mdl", { 	gbots_wheel_rx = 0, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_vehicles/tire001b_truck.mdl", { 	gbots_wheel_rx = 0, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_vehicles/tire001c_car.mdl", { 		gbots_wheel_rx = 0, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_wasteland/controlroom_filecabinet002a.mdl", { gbots_wheel_rx = 90, gbots_wheel_ry = 0, 	gbots_wheel_rz = 0})
list.Set( "WheelModels2", "models/props_borealis/bluebarrel001.mdl", { 		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_c17/oildrum001.mdl", { 			gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
//list.Set( "WheelModels2", "models/props_c17/playground_carousel01.mdl", { 	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_c17/chair_office01a.mdl", { 		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_c17/TrapPropeller_Blade.mdl", { 	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_wasteland/wheel01.mdl", { 		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 90} )
list.Set( "WheelModels2", "models/props_trainstation/trainstation_clock001.mdl", { gbots_wheel_rx = 0, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_junk/metal_paintcan001a.mdl", { 	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_c17/pulleywheels_large01.mdl", { 	gbots_wheel_rx = 0, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )

//PHX wheels
list.Set( "WheelModels2", "models/props_phx/facepunch_barrel.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/oildrum001.mdl", {			gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/mechanics/medgear.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/mechanics/biggear.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/gears/bevel9.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/gears/bevel12.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/gears/bevel24.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/gears/bevel36.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/smallwheel.mdl", {			gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/gears/spur24.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/gears/spur36.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/wheels/trucktire.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/wheels/trucktire2.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/wheels/metal_wheel1.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/wheels/metal_wheel2.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/wheels/wooden_wheel1.mdl", {	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/wheels/wooden_wheel2.mdl", {	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_c17/TrapPropeller_Blade.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/trains/wheel_medium.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/trains/medium_wheel_2.mdl", {	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/trains/double_wheels.mdl", {	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/trains/double_wheels2.mdl", {	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/wheels/drugster_back.mdl", {	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/wheels/drugster_front.mdl", {	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/misc/propeller2x_small.mdl", {	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/misc/propeller3x_small.mdl", {	gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/misc/paddle_small.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
list.Set( "WheelModels2", "models/props_phx/misc/paddle_small2.mdl", {		gbots_wheel_rx = 90, 	gbots_wheel_ry = 0, 	gbots_wheel_rz = 0} )
