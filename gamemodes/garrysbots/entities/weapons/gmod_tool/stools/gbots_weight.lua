TOOL.Category = "Garry's Bots"
TOOL.Name = "Weights"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar[ "onweight" ] = "150"
TOOL.ClientConVar[ "offweight" ] = "15"
TOOL.ClientConVar[ "keygroup" ] = "0"

if ( CLIENT ) then
	language.Add( 'Tool.gbots_weight.name', 'Toggle-able Weights' )
	language.Add( 'Tool.gbots_weight.desc', 'Create toggle-able weights attached to something.' )
	language.Add( 'Tool.gbots_weight.0', 'Click somewhere to attach a toggle weight.' )

	language.Add( 'Undone.gbots_weight', 'Toggle Weight Undone' )
	language.Add( 'Cleanup.gbots_weight', 'Toggle Weights' )
	language.Add( 'Cleaned.gbots_weight', 'Cleaned up all Toggle Weights' )
	language.Add( 'SBoxLimit.gbots_weights', 'Maximum Toggle Weights Reached' )
end

function TOOL:LeftClick( trace )
	if trace.Entity && trace.Entity:IsPlayer() then return false end

	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end

	if (CLIENT) then return true end

	local ply = self:GetOwner()

	local onweight	= self:GetClientNumber( "onweight" )
	local offweight	= self:GetClientNumber( "offweight" )
	local key	= self:GetClientNumber( "keygroup" )

	local model 	= "models/props_lab/jar01a.mdl"
	
	if ( trace.Entity:IsValid() && trace.Entity:GetClass() == "gb_weight" && trace.Entity.pl == ply ) then
		trace.Entity:SetWeights( offweight, onweight )
		return true
	end
	
	if ( !self:GetSWEP():CheckLimit( "gbots_weights" ) ) then return false end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local weight = MakeWeight( ply, model, Ang, trace.HitPos, key, offweight, onweight )

	local min = weight:OBBMins()
	weight:SetPos( trace.HitPos - trace.HitNormal * min.z )

	local const

	if trace.Entity:IsValid() then
		const = constraint.Weld( weight, trace.Entity, 0, trace.PhysicsBone, 0, true, true )
	end

	undo.Create("gbots_weight")
		undo.AddEntity( weight )
		undo.AddEntity( const )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "gbots_weight", weight )
	ply:AddCleanup( "gbots_weight", const )

	return true
end

function TOOL:RightClick( trace )
end

function TOOL:UpdateGhostWeight( ent, player )
	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end

	local tr 	= util.GetPlayerTrace( player, player:GetAimVector() )
	local trace 	= util.TraceLine( tr )
	if (!trace.Hit) then return end

	if (trace.Entity && trace.Entity:GetClass() == "gb_weight" || trace.Entity:IsPlayer()) then
		ent:SetNoDraw( true )
		return
	end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetAngles( Ang )

	ent:SetNoDraw( false )
end

function TOOL:Think()
	if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != "models/props_lab/jar01a.mdl") then
		self:MakeGhostEntity( "models/props_lab/jar01a.mdl", Vector(0,0,0), Angle(0,0,0) )
	end

	self:UpdateGhostWeight( self.GhostEntity, self:GetOwner() )
end

if (SERVER) then
	CreateConVar('sbox_maxgbots_weights', 10)

	function MakeWeight( pl, Model, Ang, Pos, key, offweight, onweight )
		if ( !pl:CheckLimit( "gbots_weights" ) ) then return false end

		local weight = ents.Create( "gb_weight" )
		if (!weight:IsValid()) then return false end
		weight:SetModel( Model )

		weight:SetAngles( Ang )
		weight:SetPos( Pos )
		weight:Spawn()

		weight:GetTable():SetWeights( offweight, onweight )
		--weight:GetTable():SetPlayer( pl )

		numpad.OnDown( pl, key, "Weight_Toggle", weight )

		pl:AddCount( "gbots_weights", weight )

		DoPropSpawnedEffect( weight )

		return weight
	end

	duplicator.RegisterEntityClass( "gbots_weight", MakeWeight, "Model", "Ang", "Pos", "key", "offweight", "onweight" )
end

function TOOL.BuildCPanel( panel )
	panel:AddControl("Header", {
		Text = "Toggleable Weights",
		Description = "Places toggleable weights." })

	panel:AddControl( "Numpad", {
		Label = "Toggle",
		Command = "gbots_weight_keygroup",
		ButtonSize = "22" })

	panel:AddControl("Slider", {
		Label = "On Weight",
		Type = "Float",
		Min = "1",
		Max = "10000",
		Command = "gbots_weight_onweight" })

	panel:AddControl("Slider", {
		Label = "Off Weight",
		Type = "Float",
		Min = "1",
		Max = "10000",
		Command = "gbots_weight_offweight" })
end
