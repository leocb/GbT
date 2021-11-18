TOOL.Category		= "propflight"
TOOL.Name			= "#propflight"
TOOL.Command		= nil
TOOL.ConfigName		= ""
if ( CLIENT ) then
TOOL.ClientConVar[ "acc" ] = "50"
TOOL.ClientConVar[ "speed" ] = "1000"
--TOOL.ClientConVar[ "ori" ] = "0"
TOOL.ClientConVar[ "hp" ] = "1"
TOOL.ClientConVar[ "weapons" ] = "0"
TOOL.ClientConVar[ "damage" ] = "20"
TOOL.ClientConVar[ "fuse" ] = "3"
TOOL.ClientConVar[ "trail" ] = "1"
	language.Add( "propflight", "propflight" )
	language.Add( "Tool_propflight_name", "PropFlight Stool" )
	language.Add( "Tool_propflight_desc", "Creates prop based aircraft." )
	language.Add( "Tool_propflight_0", "Left click to turn a prop into an aircraft" )
	language.Add( "Undone_propflight", "Undone propflight" )
end

--local orient = {
--	{"Forward","0"},
--	{"Right","1"},
--	{"Up", "2"}
--	}

local weapons = {
	{"Scout" , "0"},
	{ "Gunship" , "1"},
	{ "Bomber", "2"}
	}

function TOOL:LeftClick( trace )
if ( !trace.Entity ) then 
	return false 
end
if trace.Entity:GetClass() == "prop_physics" then
local pos = trace.Entity:GetPos()
local Ang = trace.Entity:GetAngles()
local mass = trace.Entity:GetPhysicsObject():GetMass()
local lockm = ents.Create( "sent_propship" )
	lockm:SetModel( trace.Entity:GetModel() )  
trace.Entity:Remove()	
	lockm:SetPos(pos)
	lockm:SetAngles(Ang)
	lockm.maxspeed = tonumber(self:GetClientInfo("speed"))
--	lockm.orient = tonumber(self:GetClientInfo("ori"))
	if self:GetClientInfo("trail") == "1" then
	lockm.trail = true
	else
	lockm.trail = false
	end
	lockm.acc = tonumber(self:GetClientInfo("acc"))
	lockm.health = (mass * tonumber(self:GetClientInfo("hp")))
	lockm.weapontype = tonumber(self:GetClientInfo("weapons"))
	lockm.shotdamage = tonumber(self:GetClientInfo("damage"))
	lockm.fuse = tonumber(self:GetClientInfo("fuse"))
	lockm:Spawn()
	local eds = EffectData() 
				eds:SetEntity( lockm ) 
				util.Effect( "propspawn", eds, true, true ) 
    self:GetOwner():AddCleanup( "propship", lockm )
	return true
else
return false
end
end




function TOOL.BuildCPanel( lpanel )
    lpanel:AddControl( 'Slider', { 
		Label = 'Acceleration :',
		Type = "Integer",
		Description = "Increments at which the speed increases, in units/sec",
		Min = 1,
		Max = 1000,
		Command = 'propflight_acc'
	} )
	lpanel:AddControl( 'Slider', { 
		Label = 'Max Speed :',
		Type = "Integer",
		Description = "Maximum speed in units/sec",
		Min = 100,
		Max = 10000,
		Command = 'propflight_speed'
	} )
--		combo = {}
--	combo.Label = "Flight Orientation :"
--	combo.MenuButton = 1
--	combo.Folder = "settings/menu/main/construct/Propflight/"
--	combo.Options = {}
	
--	for k, v in pairs( orient ) do
--	  combo.Options[ v[ 1 ] ] = { propflight_ori = v[ 2 ] }
--	end
--	lpanel:AddControl( "ComboBox", combo ) 				 -- this deals with some ropey orientation stuff that doesn't work
	lpanel:AddControl( 'Slider', { 
			Label = 'HP :',
		Type = "Integer",
		Description = "The total hp is the mass of the prop times this number.",
		Min = 1,
		Max = 4,
		Command = 'propflight_hp'
	} )
	lpanel:AddControl( 'Checkbox', { 
		Label = 'Trail :',
		Description = "Enables a smoketrail when the engine is running.",
		Command = 'propflight_trail'
	} )	
			combo = {}
	combo.Label = "Ship Type :"
	combo.MenuButton = 1
	combo.Folder = "settings/menu/main/construct/Propflight/"
	combo.Options = {}
	
	for k, v in pairs( weapons ) do
	  combo.Options[ v[ 1 ] ] = { propflight_weapons = v[ 2 ] }
	end
	lpanel:AddControl( "ComboBox", combo ) 		
	lpanel:AddControl( 'Slider', { 
			Label = 'Weapon Damage :',
		Type = "Integer",
		Description = "Damage for the onboard weapon, if it has one",
		Min = 1,
		Max = 1000,
		Command = 'propflight_damage'
	} )
	lpanel:AddControl( 'Slider', { 
			Label = 'Bomb Fuse :',
		Type = "Integer",
		Description = "Fuse for the bombs, if it has any",
		Min = 1,
		Max = 5,
		Command = 'propflight_fuse'
	} )
end
