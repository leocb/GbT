
TOOL.Category		= "Construction"
TOOL.Name		= "#Sound Emitter"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "model" ]		= "models/props_lab/citizenradio.mdl"
TOOL.ClientConVar[ "sound" ] 		= "coast.siren_citizen"
TOOL.ClientConVar[ "length" ]		= "-1"
TOOL.ClientConVar[ "looping" ]		= "1"
TOOL.ClientConVar[ "delay" ]		= "0"
TOOL.ClientConVar[ "toggle" ]		= "0"
TOOL.ClientConVar[ "dmgactivate" ] 	= "0"
TOOL.ClientConVar[ "dmgtoggle" ] 	= "0"
TOOL.ClientConVar[ "key"    ] 		= "2"
TOOL.ClientConVar[ "volume" ]		= "100"
TOOL.ClientConVar[ "pitch"  ]		= "100"

if SERVER then
	if !ConVarExists("sbox_maxmv_soundemitters") then
		CreateConVar("sbox_maxmv_soundemitters",3)
	end
elseif CLIENT then
	language.Add( "mv_soundemitter", "Sound Emitter" )
	language.Add( "Tool_mv_soundemitter_name", "Sound Emitter" )
	language.Add( "Tool_mv_soundemitter_desc", "Create a sound emitter" )
	language.Add( "Tool_mv_soundemitter_0", "Left Click: Weld.   Right Click: Spawn.   Reload: Copy settings or model." )

	language.Add( "SBoxLimit_mv_soundemitters", "You've hit the Sound Emitter limit!" )
	language.Add( "Undone_mv_soundemitter", "Undone Sound Emitter" )
	language.Add( "Cleanup_mv_soundemitter", "Sound Emitters" )
	language.Add( "Cleaned_mv_soundemitter", "Cleaned up all Sound Emitters" )
end

cleanup.Register( "mv_soundemitter" )

//snag the custom sound presets

if file.Exists("../PresetSounds.txt") then
	local SoundPresets = util.KeyValuesToTable(file.Read("../PresetSounds.txt"))
	for key,value in pairs(SoundPresets) do
		list.Set( "MVSoundEmitterSound", key, value )
	end
else
	Msg("WARNING: Could not find PresetSounds.txt!\n")
	local SoundPresets = {}
	list.Set( "MVSoundEmitterSound", "Blank", {
		mv_soundemitter_sound = "",
		mv_soundemitter_length = 0, mv_soundemitter_looping = 0} )
end

function TOOL:LeftClick( trace, worldweld )

	if trace.Entity && trace.Entity:IsPlayer() then return false end
	if (CLIENT) then return true end
	if (worldweld == nil) then worldweld = true end

	// If there's no physics object then we can't constraint it!
	if ( SERVER && worldweld && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end

	local ply = self:GetOwner()

	local sound		= self:GetClientInfo("sound")
	local model		= self:GetClientInfo("model")
	local length		= self:GetClientNumber("length")
	local looping		= self:GetClientInfo("looping")
	local delay		= self:GetClientNumber("delay")
	local toggle		= self:GetClientInfo("toggle")
	local dmgactivate	= self:GetClientInfo("dmgactivate")
	local dmgtoggle		= self:GetClientInfo("dmgtoggle")
	local key   		= self:GetClientNumber("key")
	local volume		= self:GetClientNumber("volume")
	local pitch 		= self:GetClientNumber("pitch")

	if ( !self:GetSWEP():CheckLimit( "mv_soundemitters" ) ) then return false end

	// We shot an existing sensor - just change its values
	if ( trace.Entity:IsValid() && trace.Entity:GetClass() == "mv_soundemitter" && trace.Entity:GetTable():GetPlayer() == ply ) then
		local enttable = trace.Entity:GetTable()

		enttable:SetSound( sound )
		enttable:SetLength( length )
		enttable:SetLooping( looping )
		enttable:SetDelay( delay )
		enttable:SetToggle( toggle )
		enttable:SetDamageActivate( dmgactivate )
		enttable:SetDamageToggle( dmgtoggle )
		enttable:SetVolume( volume )
		enttable:SetPitch( pitch )
		return true

	end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local emitter = MakeMVSoundEmitter( ply, trace.HitPos, Ang, model, sound, length, looping, delay, toggle, dmgactivate, dmgtoggle, volume, pitch, key, false )

	if !emitter then return false end

	local min = emitter:OBBMins()
	emitter:SetPos( trace.HitPos - trace.HitNormal * min.z )

	undo.Create("mv_soundemitter")
	undo.AddEntity( emitter )

	if ( worldweld and ( trace.Entity != nil or trace.Entity:IsWorld() ) ) then
		local weld = constraint.Weld( trace.Entity, emitter, trace.PhysicsBone, 0, 0 )
		trace.Entity:DeleteOnRemove( emitter )

		emitter:GetPhysicsObject():EnableCollisions( false )
		emitter:GetTable().nocollide = true
		undo.AddEntity( weld )
	end

	undo.SetPlayer( ply )
	undo.Finish()

	return true
end

function TOOL:RightClick( trace )
	return self:LeftClick( trace, false )
end

function TOOL:Reload( trace )
	if !trace.Entity then return false end
	if CLIENT then return true end

	local Ent = trace.Entity
	if Ent:IsValid() then
		local myowner = self:GetOwner()
		if Ent:GetClass() == "mv_soundemitter" then
			local ETab = Ent:GetTable()
			myowner:ConCommand("mv_soundemitter_model "..tostring(Ent:GetModel()))
			myowner:ConCommand("mv_soundemitter_sound "..tostring(ETab:GetSound()))
			myowner:ConCommand("mv_soundemitter_length "..tostring(ETab:GetLength()))
			myowner:ConCommand("mv_soundemitter_looping "..tostring(ETab:GetLooping()))
			myowner:ConCommand("mv_soundemitter_delay "..tostring(ETab:GetDelay()))
			myowner:ConCommand("mv_soundemitter_toggle "..tostring(ETab:GetToggle()))
			myowner:ConCommand("mv_soundemitter_dmgactivate "..tostring(ETab:GetDamageActivate()))
			myowner:ConCommand("mv_soundemitter_dmgtoggle "..tostring(ETab:GetDamageToggle()))
			myowner:ConCommand("mv_soundemitter_volume "..tostring(ETab:GetVolume()))
			myowner:ConCommand("mv_soundemitter_pitch "..tostring(ETab:GetPitch()))
			myowner:ConCommand("mv_soundemitter_key "..tostring(ETab:GetKey()))
			return true
		elseif Ent:GetModel() then
			myowner:ConCommand("mv_soundemitter_model "..tostring(Ent:GetModel()))
			return true
		end
	end
end

if SERVER then
	function MakeMVSoundEmitter(  ply, pos, ang, model, sound, length, looping, delay, toggle, dmgactivate, dmgtoggle, volume, pitch, key, nocollide  )

		if ( !ply:CheckLimit( "mv_soundemitters" ) ) then return false end

		local emitter = ents.Create( "mv_soundemitter" )
		if (!emitter:IsValid()) then return false end

		emitter:SetModel( model )
		emitter:SetPos( pos )
		emitter:SetAngles( ang )
		emitter:Spawn()
		local enttable = emitter:GetTable()

		enttable:SetPlayer( ply )
		enttable:SetSound( sound )
		enttable:SetLength( length )
		enttable:SetLooping( looping )
		enttable:SetDelay( delay )
		enttable:SetToggle( toggle )
		enttable:SetDamageActivate( dmgactivate )
		enttable:SetDamageToggle( dmgtoggle )
		enttable:SetVolume( volume )
		enttable:SetPitch( pitch )
		enttable:SetKey( Key )

		numpad.OnDown(ply, key, "mv_soundemitter_Down", emitter)
		numpad.OnUp(ply, key, "mv_soundemitter_Up", emitter)

		if nocollide then emitter:GetPhysicsObject():EnableCollisions( false ) end
		local ttable =
		{
			model		= model,
			sound 		= sound,
			length		= length,
			looping		= looping,
			delay		= delay,
			toggle		= toggle,
			dmgactivate	= dmgactivate,
			dmgtoggle	= dmgtoggle,
			volume		= volume,
			pitch		= pitch,
			key		= key,
			nocollide	= nocollide
		}

		table.Merge( emitter:GetTable(), ttable )

		ply:AddCount( "mv_soundemitters", emitter )
		ply:AddCleanup( "mv_soundemitter", emitter )

		DoPropSpawnedEffect( emitter )

		return emitter
	end

	duplicator.RegisterEntityClass( "mv_soundemitter", MakeMVSoundEmitter, "pos", "ang", "model", "sound", "length", "looping", "delay", "toggle", "dmgactivate", "dmgtoggle", "volume", "pitch", "key", "nocollide" )
end

function TOOL.BuildCPanel(CPanel)
	CPanel:ClearControls()

	local Params = {
		Text = "#Tool_mv_soundemitter_name",
		Description = "#Tool_mv_soundemitter_desc" }
	CPanel:AddControl( "Header", Params )

	Params = {
		Label = "#Presets",
		MenuButton = "1",
		Folder = "mv_soundemitter",
		Options = {},
		CVars = {} }
	Params.Options["Default"] = {
		mv_soundemitter_model = "models/props_lab/citizenradio.mdl",
		mv_soundemitter_sound = "coast.siren_citizen",
		mv_soundemitter_length = "-1",
		mv_soundemitter_looping = "1",
		mv_soundemitter_delay = "0",
		mv_soundemitter_toggle = "1",
		mv_soundemitter_dmgactivate = "0",
		mv_soundemitter_volume = "100",
		mv_soundemitter_pitch = "100",
		mv_soundemitter_key = "2" }
	table.insert( Params.CVars, "mv_soundemitter_model" )
	table.insert( Params.CVars, "mv_soundemitter_sound" )
	table.insert( Params.CVars, "mv_soundemitter_length" )
	table.insert( Params.CVars, "mv_soundemitter_loop" )
	table.insert( Params.CVars, "mv_soundemitter_delay" )
	table.insert( Params.CVars, "mv_soundemitter_toggle" )
	table.insert( Params.CVars, "mv_soundemitter_dmgactivate" )
	table.insert( Params.CVars, "mv_soundemitter_volume" )
	table.insert( Params.CVars, "mv_soundemitter_pitch" )
	table.insert( Params.CVars, "mv_soundemitter_key" )
	CPanel:AddControl( "ComboBox", Params )

	Params = {
		Label = "Key",
		Command = "mv_soundemitter_key",
		ButtonSize = 22 }
	CPanel:AddControl( "Numpad", Params )

	Params = {
		Label = "Model",
		ConVar = "mv_soundemitter_model",
		Category = "Sound Emitter",
		Models = list.Get("MVSoundEmitterModel") }
	CPanel:AddControl( "PropSelect", Params )

	Params = {
		Label = "Preset Sounds",
		Description = "Some useful sound effects",
		Command = "mv_soundemitter_sound",
		Height = 200,
		Options = list.Get("MVSoundEmitterSound") }
	CPanel:AddControl( "ListBox", Params )

	Params = {
		Label = "",
		MaxLength = "256",
		Description = "",
		WaitForEnter = "1",
		Command = "mv_soundemitter_sound" }
	CPanel:AddControl( "TextBox", Params )

	Params = {
		Label = "Volume",
		Description = "How loud the sound should play. Default: 100",
		Command = "mv_soundemitter_volume",
		Type = "Float",
		Min = 0,
		Max = 200 }
	CPanel:AddControl( "Slider", Params )

	Params = {
		Label = "Pitch",
		Description = "Adjust the pitch of the sound. Default: 100",
		Command = "mv_soundemitter_pitch",
		Type = "Float",
		Min = 0,
		Max = 250 }
	CPanel:AddControl( "Slider", Params )

	Params = {
		Label = "Length",
		Description = "How long to play the sound. -1 means the sound loops on its own. (seconds)",
		Command = "mv_soundemitter_length",
		Type = "Float",
		Min = "-1",
		Max = "300" }
	CPanel:AddControl( "Slider", Params )

	Params = {
		Label = "Loop",
		Description = "If this is checked and the length is more than 0 then the sound will loop.",
		Command = "mv_soundemitter_looping" }
	CPanel:AddControl( "CheckBox", Params )

	Params = {
		Label = "Delay",
		Description = "How long to wait before playing the sound. (seconds)",
		Command = "mv_soundemitter_delay",
		Type = "Float",
		Min = "0",
		Max = "100" }
	CPanel:AddControl( "Slider", Params )

	Params = {
		Label = "Toggle",
		Description = "Toggle turning the sound emitter on and off",
		Command = "mv_soundemitter_toggle" }
	CPanel:AddControl( "CheckBox", Params )

	Params = {
		Label = "Activate on Damage",
		Description = "If something damages the emitter it will activate.",
		Command = "mv_soundemitter_dmgactivate" }
	CPanel:AddControl( "CheckBox", Params )

	Params = {
		Label = "Toggle on Damage",
		Description = "If something damages the emitter it will toggle but only if 'Activate on Damage' is on.",
		Command = "mv_soundemitter_dmgtoggle" }
	CPanel:AddControl( "CheckBox", Params )
end

function TOOL:UpdateGhostMVSoundEmitter( ent, player )

	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end

	local tr 	= utilx.GetPlayerTrace( player, player:GetCursorAimVector() )
	local trace 	= util.TraceLine( tr )

	if (!trace.Hit) then return end

	if (trace.Entity && trace.Entity:GetClass() == "mv_soundemitter" || trace.Entity:IsPlayer()) then

		ent:SetNoDraw( true )
		return

	end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	ent:SetAngles( Ang )

	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )

	ent:SetNoDraw( false )

end

function TOOL:Think()

	if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != self:GetClientInfo("model") ) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end

	self:UpdateGhostMVSoundEmitter( self.GhostEntity, self:GetOwner() )

end

list.Set( "MVSoundEmitterModel", "models/props_lab/citizenradio.mdl", {})
list.Set( "MVSoundEmitterModel", "models/props/cs_office/radio.mdl", {})
list.Set( "MVSoundEmitterModel", "models/props_citizen_tech/transponder.mdl", {})
list.Set( "MVSoundEmitterModel", "models/vehicle/vehicle_engine_block.mdl", {})
list.Set( "MVSoundEmitterModel", "models/Items/car_battery01.mdl", {})
list.Set( "MVSoundEmitterModel", "models/props_c17/TrapPropeller_Engine.mdl", {})
list.Set( "MVSoundEmitterModel", "models/props_c17/tv_monitor01.mdl", {})

/* enable these if you have them
list.Set( "MVSoundEmitterModel", "models/jaanus/thruster_megaphn.mdl", {})
list.Set( "MVSoundEmitterModel", "models/jaanus/thruster_shoop.mdl", {})
list.Set( "MVSoundEmitterModel", "models/jaanus/thruster_invisi.mdl", {})
*/