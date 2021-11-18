
TOOL.Category		= "Construction"
TOOL.Name			= "#Anti-NoClip"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if ( CLIENT ) then
	language.Add( "Tool_rt_antinoclip_name", "Anti-NoClip" )
	language.Add( "Tool_rt_antinoclip_desc", "Protect your props from noclip." )
	language.Add( "Tool_rt_antinoclip_0", "Left click to apply. Right click to remove." )
end

// Actions.
TOOL.Actions = {}

function AntiNoClip_RegisterAction( name, func )
	local unique = string.lower( string.Replace( name, " ", "_" ) )
	TOOL.Actions[ unique ] = { Name = name, Function = func }
end
for _, file in pairs( file.FindInLua( "antinoclip/*.lua" ) ) do
	include( "antinoclip/" .. file )
	AddCSLuaFile( "antinoclip/" .. file )
end
AntiNoClip_RegisterAction = nil

// Convars.
for unique, _ in pairs( TOOL.Actions ) do
	TOOL.ClientConVar[ "action_" .. unique ] = "0"
end

// Affect.
TOOL.Affect = {
	{ "Ignore only you", function( o, p ) return p != o end },
	{ "Ignore only your team", function( o, p ) return p:Team() != o:Team() end },
	{ "Affect only you", function( o, p ) return p == o end },
	{ "Affect only your team", function( o, p ) return p:Team() == o:Team() end },
	{ "Affect everyone", function() return true end },
	{ "Affect PP buddies", function( o, p, e ) return gamemode.Call( "PlayerUse", p, e ) != false end },
	{ "Ignore PP buddies", function( o, p, e ) return !( gamemode.Call( "PlayerUse", p, e ) != false ) end },
}
TOOL.ClientConVar[ "affect" ] = "1"

if ( CLIENT ) then
	for _, info in pairs( TOOL.Affect ) do
		language.Add( info[ 1 ], info[ 1 ] )
	end
end

function TOOL:LeftClick( trace, antinoclip )
	if ( !trace.Entity:IsValid() ) then return end
	if ( trace.Entity:IsPlayer() ) then return end
	if ( CLIENT ) then return true end
	
	if ( antinoclip == nil ) then antinoclip = true end
	if ( antinoclip ) then
		local handler = self:GetHandler( trace.Entity )
			handler:SetFunctions( self:GetFunctions() )
			handler:SetAffect( self:GetAffect() )
			handler.Owner = self:GetOwner()
		return true
	elseif ( !antinoclip ) then
		if ( trace.Entity.AntiNoClip && trace.Entity.AntiNoClip:IsValid() ) then
			trace.Entity.AntiNoClip:Remove()
			trace.Entity.AntiNoClip = nil
		end
		return true
	end
	
	return false
end
function TOOL:RightClick( trace )
	return self:LeftClick( trace, false )
end

function TOOL:GetHandler( ent )
	if ( ent.AntiNoClip && ent.AntiNoClip:IsValid() ) then return ent.AntiNoClip end
	
	local an = ents.Create( "rt_antinoclip_handler" )
		an:SetEnt( ent )
	an:Spawn()
	
	ent.AntiNoClip = an
	
	return an
end
function TOOL:GetFunctions()
	local funcs = {}
	for unique, action in pairs( self.Actions ) do
		if ( self:GetClientNumber( "action_" .. unique ) == 1 ) then funcs[ #funcs + 1 ] = action.Function end
	end
	return funcs
end
function TOOL:GetAffect()
	local affect = math.Clamp( self:GetClientNumber( "affect" ), 0, #self.Affect )
	return self.Affect[ affect ][ 2 ]
end

local TOOL = TOOL
function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "LOL", Description = "#Tool_rt_antinoclip_desc" } )
	
	panel:AddControl( "Label", { Text = "Affect" } )
	
	local affect = {}
	for i, info in pairs( TOOL.Affect ) do
		affect[ "#" .. info[ 1 ] ] = { rt_antinoclip_affect = i }
	end
	panel:AddControl( "ComboBox", { Options = affect } )
	
	panel:AddControl( "Label", { Text = "Actions" } )
	for unique, action in pairs( TOOL.Actions ) do
		panel:AddControl( "CheckBox", { Label = action.Name, Command = "rt_antinoclip_action_" .. unique } )
	end
end
