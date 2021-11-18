
TOOL.Category		= "Construction"
TOOL.Name			= "#Particle Maker"
TOOL.Command		= nil
TOOL.ConfigName		= ""

-- The 'default' convars, will always be there
TOOL.ClientConVar["Weld"]	= "1"
TOOL.ClientConVar["Frozen"]	= "1"

TOOL.ClientConVar["Key"]	= "5"
TOOL.ClientConVar["Toggle"]	= "0"
TOOL.ClientConVar["Gun"]	= "0"
TOOL.ClientConVar["Trace"]	= "0"

ParticleOptions = 
{
	{Name = "Material",			Type = "String",	Value = ""},
	
	{Name = "ColorR1",			Type = "Float",		Value = 255,	Min = 0,		Max = 255	},
	{Name = "ColorG1",			Type = "Float",		Value = 255,	Min = 0,		Max = 255	},
	{Name = "ColorB1",			Type = "Float",		Value = 255,	Min = 0,		Max = 255	},
	{Name = "ColorR2",			Type = "Float",		Value = 255,	Min = 0,		Max = 255	},
	{Name = "ColorG2",			Type = "Float",		Value = 255,	Min = 0,		Max = 255	},
	{Name = "ColorB2",			Type = "Float",		Value = 255,	Min = 0,		Max = 255	},
	{Name = "ColorRand",		Type = "Bool",		Value = 0,		Min = 0,		Max = 1		},
	{Name = "Velocity",			Type = "Float",		Value = 500.01,	Min = 0,		Max = 10000	},
	{Name = "Spread",			Type = "Float",		Value = 50,		Min = 0,		Max = 360	},
	{Name = "Delay",			Type = "Float",		Value = 0.2,	Min = 0.001,	Max = 10	},
	{Name = "Number",			Type = "Int",		Value = 1,		Min = 1,		Max = 10	},
	{Name = "DieTime",			Type = "Float",		Value = 3,		Min = 0,		Max = 10	},
	{Name = "StartAlpha",		Type = "Float",		Value = 255,	Min = 0,		Max = 255	},
	{Name = "EndAlpha",			Type = "Float",		Value = 0,		Min = 0,		Max = 255	},
	{Name = "StartSize",		Type = "Float",		Value = 10,		Min = 0,		Max = 100	},
	{Name = "EndSize",			Type = "Float",		Value = 20,		Min = 0,		Max = 100	},
	{Name = "StartLength",		Type = "Float",		Value = 0,		Min = 0,		Max = 100	},
	{Name = "EndLength",		Type = "Float",		Value = 0,		Min = 0,		Max = 100	},
	{Name = "RollRand",			Type = "Float",		Value = 0,		Min = 0,		Max = 10	},
	{Name = "RollDelta",		Type = "Float",		Value = 0,		Min = -10,		Max = 10	},
	{Name = "AirResistance",	Type = "Float",		Value = 5,		Min = 0,		Max = 1000	},
	{Name = "Bounce",			Type = "Float",		Value = 0.2,	Min = 0,		Max = 10	},
	{Name = "Gravity",			Type = "Float",		Value = -50,	Min = -1000,	Max = 1000	},
	{Name = "Collide",			Type = "Bool",		Value = 1,		Min = 0,		Max = 1		},
	{Name = "Lighting",			Type = "Bool",		Value = 0,		Min = 0,		Max = 1		},
	{Name = "Sliding",			Type = "Bool",		Value = 0,		Min = 0,		Max = 1		},
	
	{Name = "3D",				Type = "Bool",		Value = 0,		Min = 0,		Max = 1		},
	{Name = "Align",			Type = "Bool",		Value = 1,		Min = 0,		Max = 1		},
	{Name = "Stick",			Type = "Bool",		Value = 1,		Min = 0,		Max = 1		},
	{Name = "DoubleSided",		Type = "Bool",		Value = 1,		Min = 0,		Max = 1		},
	{Name = "AngleVelX",		Type = "Float",		Value = 50,		Min = -500,		Max = 500	},
	{Name = "AngleVelY",		Type = "Float",		Value = 50,		Min = -500,		Max = 500	},
	{Name = "AngleVelZ",		Type = "Float",		Value = 50,		Min = -500,		Max = 500	},
	{Name = "StickLifeTime",	Type = "Float",		Value = 2,		Min = 0.01,		Max = 10	},
	{Name = "StickStartSize",	Type = "Float",		Value = 20,		Min = 0,		Max = 100	},
	{Name = "StickEndSize",		Type = "Float",		Value = 0,		Min = 0,		Max = 100	},
	{Name = "StickStartAlpha",	Type = "Float",		Value = 255,	Min = 0,		Max = 255	},
	{Name = "StickEndAlpha",	Type = "Float",		Value = 0,		Min = 0,		Max = 255	},
}

// Add all settings
for _,v in pairs(ParticleOptions) do
	TOOL.ClientConVar[v.Name] = v.Value
	TOOL.ClientConVar["wire_"..v.Name] = "0"
end

cleanup.Register("particles")
CreateConVar("sbox_maxparticles", 1, FCVAR_NOTIFY)
CreateConVar("particle_Clamp", 1, FCVAR_NOTIFY)

if (CLIENT) then

	language.Add("Tool_particle_name", "Particle Maker")
	language.Add("Tool_particle_desc", "Left click: Spawn/update particle maker  Right click: Get settings")
	language.Add("Tool_particle_0", "Made by: Killer HAHA (Robbis_1)")
	
	language.Add("Undone_particle", "Undone Particle Maker")
	
	language.Add("Cleanup_particles", "Particle Maker")
	language.Add("Cleaned_particles", "Cleaned up all Particle Makers")
	language.Add("SBoxLimit_particles", "You've reached the Particle Makers limit!")

end

function TOOL:BoolToNum(Data)
	local NewData = Data
	for k,v in pairs(NewData) do
		if (type(v) == "boolean") then
			if (v) then
				NewData[k] = 1
			else
				NewData[k] = 0
			end
		end
	end
	
	return NewData
end

function TOOL:GetNetworkedValues(Ent)
	local Data = Ent:GetData(ParticleOptions)
	Data = Ent:BoolToNum(Data)
	
	return Data
end

function TOOL:GetValues()
	local Data = {}
	
	for k,v in pairs(ParticleOptions) do
		Data[k] = {}
		
		if (v.Type == "String") then
			Data[k].Value = self:GetClientInfo(v.Name)
		elseif (v.Type == "Bool") then
			Data[k].Value = util.tobool(self:GetClientNumber(v.Name))
		else
			local Value = self:GetClientNumber(v.Name)
			if not (SinglePlayer()) and (util.tobool(GetConVarNumber("particle_Clamp"))) then
				-- Clamp stuff in multiplayer.. because people are idiots T_T
				Value = math.Clamp(Value, v.Min, v.Max)
			end
			
			Data[k].Value = Value
		end
		
		Data[k].Type = v.Type
		Data[k].Name = v.Name
	end
	
	return Data
end

local function SetValues(Ent, Data, Toggle)
	if (type(Data) == "table") then
		local PMTable = Ent:GetTable()
		
		PMTable:SetToggle(Toggle)
		PMTable:SetData(Data)
		
		PMTable:UpdateInputs()
	end
	
	-- duplicator.StoreEntityModifier(Ent, "particle", Data)
end
-- duplicator.RegisterEntityModifier("particle", SetValues)

local function ParticleMakerReady(Ply, _3D, Trace, Gun)
	umsg.Start("ParticleMakerReady")
		umsg.Bool(Trace)
		umsg.Bool(_3D)
		umsg.Bool(Gun)
		umsg.Entity(Ply)
	umsg.End()
end

function TOOL:LeftClick(Trace)
	if (self:GetClientNumber("Gun") == 1) then return false end
	if (Trace.Entity) and (Trace.Entity:IsPlayer()) then return false end
	if (SERVER) and not (util.IsValidPhysicsObject(Trace.Entity, Trace.PhysicsBone)) then return false end
	if (CLIENT) then return true end
	
	local Ply = self:GetOwner()
	local _3D = self:GetClientNumber("3D") == 1
	local Toggle = self:GetClientNumber("Toggle") == 1
	local Key = self:GetClientNumber("Key")
	local Data = self:GetValues()
	
	
	// We shot an existing particle maker - just change its values
	if (Trace.Entity:IsValid()) and (Trace.Entity:GetClass() == "gmod_particlemaker") and (Trace.Entity:GetPlayer() == Ply) then
		SetValues(Trace.Entity, Data, Toggle)
		DoPropSpawnedEffect(Trace.Entity)
		ParticleMakerReady(Ply, _3D, false, false)
		return true
	end
	
	if (!self:GetSWEP():CheckLimit("particles")) then return false end
	
	local ParticleMaker = MakeParticle(Ply, Trace.HitPos, Data, Toggle, Key, _3D, false, false)
	local Angle = Trace.HitNormal:Angle()
		Angle:RotateAroundAxis(Angle:Right(), -90)
	ParticleMaker:SetAngles(Angle)
	
	local Weld
	if (Trace.Entity:IsValid()) then
		if (self:GetClientNumber("Weld") == 1) then
			Weld = constraint.Weld(ParticleMaker, Trace.Entity, 0, Trace.PhysicsBone, 0, 0, true)
			
			ParticleMaker:GetPhysicsObject():EnableCollisions(false)
			ParticleMaker.nocollide = true
		end
	end
	
	if (self:GetClientNumber("Frozen") == 1) then
		ParticleMaker:GetPhysicsObject():EnableMotion(false)
	end
	
	undo.Create("particle")
		undo.AddEntity(ParticleMaker)
		undo.AddEntity(Weld)
		undo.SetPlayer(Ply)
	undo.Finish()
	
	return true

end

function TOOL:RightClick(Trace)
	if (Trace.Entity) and (Trace.Entity:IsPlayer()) then return false end
	if (SERVER) and not (util.IsValidPhysicsObject(Trace.Entity, Trace.PhysicsBone)) then return false end
	
	if (Trace.Entity:IsValid()) and (Trace.Entity:GetClass() == "gmod_particlemaker") then
		if (CLIENT) then return true end
		
		local Data = self:GetNetworkedValues(Trace.Entity)
		
		for _,v in pairs(Data) do
			local Command = "particle_" .. v.Name
			if (ConVarExists(Command)) then
				self:GetOwner():ConCommand(Command .. " " .. v.Value)
			end
		end
		
		return true
	end
end

function TOOL:Holster()
	local Owner = self:GetOwner()
	
	if (Owner) and (Owner.ParticleMaker) and (Owner.ParticleMaker:IsValid()) then
		Owner.ParticleMaker:Remove()
		Owner.ParticleMaker = nil
	end
end

if (SERVER) then
	-- Make clients download the materials file
	resource.AddFile("data/Particle Materials.txt")
	
	function TOOL:Think()
		if (self:GetClientNumber("Gun") == 1) then
			local Owner = self:GetOwner()
			
			if (Owner:KeyDown(IN_ATTACK)) then
				
				if (not Owner.ParticleMaker) then
					
					local Data = self:GetValues()
					local TraceLine = self:GetClientNumber("Trace") == 1
					local _3D = self:GetClientNumber("3D") == 1
					
					local ParticleMaker = MakeParticle(Owner, Vector(0, 0, 0), Data, false, nil, _3D, TraceLine, true)
					
					if not (ParticleMaker) then return end
					
					ParticleMaker:SetColor(255, 255, 255, 0)
					ParticleMaker:SetNetworkedEntity("Player", Owner)
					ParticleMaker:SetOn(true)
					Owner.ParticleMaker = ParticleMaker
				end
			else
				if (Owner.ParticleMaker) and (Owner.ParticleMaker:IsValid()) then
					Owner.ParticleMaker:Remove()
					Owner.ParticleMaker = nil
				end
			end
		end
	end

	function MakeParticle(Ply, Pos, Data, Toggle, Key, _3D, Trace, Gun)
		
		if not (Ply:CheckLimit("particles")) then return nil end
		
		local ParticleMaker = ents.Create("gmod_particlemaker")
		if (!ParticleMaker:IsValid()) then return false end
		
		ParticleMaker:SetPos(Pos)
		ParticleMaker:SetPlayer(Ply)
		ParticleMaker:Spawn()
		
		SetValues(ParticleMaker, Data, Toggle)
		
		ParticleMakerReady(Ply, _3D, Trace, Gun)
		
		if (Key) then
			numpad.OnDown(Ply, Key, "Particles_On", ParticleMaker)
			numpad.OnUp(Ply, Key, "Particles_Off", ParticleMaker)
		end		
		
		if (Pos != Vector(0, 0, 0)) then
			DoPropSpawnedEffect(ParticleMaker)
		end
		
		Ply:AddCount("particles", ParticleMaker)
		Ply:AddCleanup("particles", ParticleMaker)
		
		return ParticleMaker
		
	end

end

function TOOL.BuildCPanel(CPanel)

	// MAIN HEADER
	CPanel:AddControl("Header", { Text = "#Tool_particle_name", Description = "#Tool_particle_desc" })
	
	// Presets
	local params = { Label = "Presets", MenuButton = 1, Folder = "particles", Options = {}, CVars = {} }
		
		params.Options.Default = {}
		for _,v in pairs(ParticleOptions) do
			if (v.Name == "Velocity") then
				params.Options.Default["particle_" .. v.Name] = 500
			else
				params.Options.Default["particle_" .. v.Name] = v.Value
			end
			
			table.insert(params.CVars, "particle_" .. v.Name)
		end
		
	CPanel:AddControl("ComboBox", params)
	
	// Numpad
	CPanel:AddControl("Numpad", { Label = "Make Particles Key", Command = "particle_Key", ButtonSize = 22 })
	
	// Color 1
	CPanel:AddControl("Color", {	Label = "Color 1", 
									Red = "particle_ColorR1", 
									Green = "particle_ColorG1", 
									Blue = "particle_ColorB1", 
									ShowAlpha = 0, 
									ShowHSV = 1, 
									ShowRGB = 1, 
									Multiplier = 255 })
	
	// Color 2
	CPanel:AddControl("Color", {	Label = "Color 2", 
									Red = "particle_ColorR2", 
									Green = "particle_ColorG2", 
									Blue = "particle_ColorB2", 
									ShowAlpha = 0, 
									ShowHSV = 1, 
									ShowRGB = 1, 
									Multiplier = 255 })
	
	
	// Material textbox
	CPanel:AddControl("TextBox",  {Label		= "Material",
									Command 	= "particle_Material" }	)
	
	// Material gallery
	local params = { Label = "Material Gallery", Height = 96, Width = 96, Rows = 2, Stretch = 1, Options = {}, CVars = {} }
	
	local File = file.Read("Particle Materials.txt")
	if (File != nil) then
		local Mats = string.Explode("\n", File)
		for k,v in pairs(Mats) do
			params.Options[k]= { Material = v, particle_Material = v }
		end
	else
		params.Options[1] = { Material = "effects/fire_cloud1", particle_Material = "effects/fire_cloud1" }
		params.Options[2] = { Material = "effects/fire_cloud2", particle_Material = "effects/fire_cloud2" }
		params.Options[3] = { Material = "effects/blood_core", particle_Material = "effects/blood_core" }
		params.Options[4] = { Material = "effects/blueflare1", particle_Material = "effects/blueflare1" }
		params.Options[5] = { Material = "effects/bluemuzzle", particle_Material = "effects/bluemuzzle" }
		params.Options[6] = { Material = "effects/fleck_glass1", particle_Material = "effects/fleck_glass1" }
		params.Options[7] = { Material = "effects/fleck_glass2", particle_Material = "effects/fleck_glass2" }
		params.Options[8] = { Material = "effects/fleck_glass3", particle_Material = "effects/fleck_glass3" }
		params.Options[9] = { Material = "effects/rollerglow", particle_Material = "effects/rollerglow" }
		params.Options[10] = { Material = "effects/spark", particle_Material = "effects/spark" }
		params.Options[11] = { Material = "sprites/strider_blackball", particle_Material = "sprites/strider_blackball" }
		params.Options[12] = { Material = "shadertest/eyeball", particle_Material = "shadertest/eyeball" }

	end
	
	table.insert(params.CVars, "particle_Material")
	CPanel:AddControl("MaterialGallery", params)
	
	//  Weld to props?
	CPanel:AddControl("Checkbox", { Label = "Weld", Command = "particle_Weld" })
	
	// Spawn frozen?
	CPanel:AddControl("Checkbox", { Label = "Frozen", Command = "particle_Frozen" })
	
	// Shoot through the gun
	CPanel:AddControl("Checkbox", { Label = "Fire directly from the STool", Command = "particle_Gun" })
	
	// Use a trace
	CPanel:AddControl("Checkbox", { Label = "Use traceline hit position", Command = "particle_Trace" })
	
	// Random color
	CPanel:AddControl("Checkbox", { Label = "Random color between 1 and 2", Command = "particle_ColorRand" })
	
	// Toggle
	CPanel:AddControl("Checkbox", { Label = "Toggle State", Command = "particle_Toggle" })
	
	// Fire delay
	CPanel:AddControl("Slider",  { Label	= "Fire Delay",
									Type	= "Float",
									Min		= 0.001,
									Max		= 10,
									Command = "particle_Delay" })
	
	// Number particles
	CPanel:AddControl("Slider",  { Label	= "Number Particles",
									Type	= "Integer",
									Min		= 1,
									Max		= 10,
									Command = "particle_Number" })
	
	// Velocity
	CPanel:AddControl("Slider",  { Label	= "Velocity",
									Type	= "Float",
									Min		= 1,
									Max		= 10000,
									Command = "particle_Velocity" })
	
	// Spread
	CPanel:AddControl("Slider",  { Label	= "Spread",
									Type	= "Float",
									Min		= 0,
									Max		= 360,
									Command = "particle_Spread" })
	
	// Die time
	CPanel:AddControl("Slider",  { Label	= "Die Time",
									Type	= "Float",
									Min		= 1,
									Max		= 10,
									Command = "particle_DieTime" })
	
	// Start alpha
	CPanel:AddControl("Slider",  { Label	= "Start Alpha",
									Type	= "Float",
									Min		= 0,
									Max		= 255,
									Command = "particle_StartAlpha" })
	
	// End alpha
	CPanel:AddControl("Slider",  { Label	= "End Alpha",
									Type	= "Float",
									Min		= 0,
									Max		= 255,
									Command = "particle_EndAlpha" })
	
	// Start size
	CPanel:AddControl("Slider",  { Label	= "Start Size",
									Type	= "Float",
									Min		= 0,
									Max		= 100,
									Command = "particle_StartSize" })
	
	// End size
	CPanel:AddControl("Slider",  { Label	= "End Size",
									Type	= "Float",
									Min		= 0,
									Max		= 100,
									Command = "particle_EndSize" })
	
	// Start length
	CPanel:AddControl("Slider",  { Label	= "Start Length",
									Type	= "Float",
									Min		= 0,
									Max		= 100,
									Command = "particle_StartLength" })
	
	// End length
	CPanel:AddControl("Slider",  { Label	= "End Length",
									Type	= "Float",
									Min		= 0,
									Max		= 100,
									Command = "particle_EndLength" })
	
	// Roll
	CPanel:AddControl("Slider",  { Label	= "Random Roll Speed",
									Type	= "Float",
									Min		= 0,
									Max		= 10,
									Command = "particle_RollRand" })
	
	// Roll delta
	CPanel:AddControl("Slider",  { Label	= "Roll Delta",
									Type	= "Float",
									Min		= -10,
									Max		= 10,
									Command = "particle_RollDelta" })
	
	// Air resistance
	CPanel:AddControl("Slider",  { Label	= "Air Resistance",
									Type	= "Float",
									Min		= 0,
									Max		= 1000,
									Command = "particle_AirResistance" })
	
	// Bounce
	CPanel:AddControl("Slider",  { Label	= "Bounce",
									Type	= "Float",
									Min		= 0,
									Max		= 10,
									Command = "particle_Bounce" })
	
	// Gravity
	CPanel:AddControl("Slider",  { Label	= "Gravity Z",
									Type	= "Float",
									Min		= -1000,
									Max		= 1000,
									Command = "particle_Gravity" })
	
	// Collision
	CPanel:AddControl("Checkbox", { Label = "Collide", Command = "particle_Collide" })
	
	// Lighting
	CPanel:AddControl("Checkbox", { Label = "Lighting", Command = "particle_Lighting" })
	
	// Slide
	CPanel:AddControl("Checkbox", { Label = "Sliding", Command = "particle_Sliding", Description = "Disables stick and align, Collision must be enabled." })
	
	
	// 3D HEADER
	CPanel:AddControl("Header", { Text = "3D Controls" })
	
	// Toggle 3D
	CPanel:AddControl("Checkbox", { Label = "3D", Command = "particle_3D" })
	
	// Align
	CPanel:AddControl("Checkbox", { Label = "Align to surface", Command = "particle_Align", Description = "Stick to surface & 3D must be enabled." })
	
	// Stick
	CPanel:AddControl("Checkbox", { Label = "Stick to surface", Command = "particle_Stick", Description = "3D must be enabled." })
	
	// Double sided
	CPanel:AddControl("Checkbox", { Label = "Double sided (2 faces)", Command = "particle_DoubleSided", Description = "3D must be enabled." })
	
	// Angle velocity X
	CPanel:AddControl("Slider",  { Label	= "Angle Velocity X",
									Type	= "Float",
									Min		= -500,
									Max		= 500,
									Command = "particle_AngleVelX" })
	
	// Angle velocity Y
	CPanel:AddControl("Slider",  { Label	= "Angle Velocity Y",
									Type	= "Float",
									Min		= -500,
									Max		= 500,
									Command = "particle_AngleVelY" })
	
	// Angle velocity Z
	CPanel:AddControl("Slider",  { Label	= "Angle Velocity Z",
									Type	= "Float",
									Min		= -500,
									Max		= 500,
									Command = "particle_AngleVelZ" })
	
	// Stick lifetime
	CPanel:AddControl("Slider",  { Label	= "Stick Lifetime",
									Type	= "Float",
									Min		= 0.01,
									Max		= 10,
									Command = "particle_StickLifeTime" })
	
	// Stick start size
	CPanel:AddControl("Slider",  { Label	= "Stick Start Size",
									Type	= "Float",
									Min		= 0,
									Max		= 100,
									Command = "particle_StickStartSize" })
	
	// Stick end size
	CPanel:AddControl("Slider",  { Label	= "Stick End Size",
									Type	= "Float",
									Min		= 0,
									Max		= 100,
									Command = "particle_StickEndSize" })
	
	// Stick start alpha
	CPanel:AddControl("Slider",  { Label	= "Stick Start Alpha",
									Type	= "Float",
									Min		= 0,
									Max		= 255,
									Command = "particle_StickStartAlpha" })
	
	// Stick end alpha
	CPanel:AddControl("Slider",  { Label	= "Stick End Alpha",
									Type	= "Float",
									Min		= 0,
									Max		= 255,
									Command = "particle_StickEndAlpha" })
	
	// Check if wire exists
	if not (Wire_Render) and not (WireAddon) then return end
	
	// WIRE HEADER
	CPanel:AddControl("Header", { Text = "Wire Inputs", Description = "Check the inputs you want to have, fire is on by default" })
	
	// Add all checkboxes
	for _,v in pairs(ParticleOptions) do
		if (v.Type != "String") then
			CPanel:AddControl("Checkbox", { Label = "Wire Input: " .. v.Name, Command = "particle_wire_" .. v.Name })
		end
	end
	
end
