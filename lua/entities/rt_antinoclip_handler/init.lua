
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:SetEnt( ent )
	if ( string.Left( ent:GetModel(), 1 ) == "*" ) then return false end // We don't want to try and use this on brushes!
	self.Entity:SetModel( ent:GetModel() )
	self.Entity:SetPos( ent:GetPos() )
	self.Entity:SetAngles( ent:GetAngles() )
	self.Entity:SetParent( ent )
	self.Ent = ent
	return true
end
function ENT:SetFunctions( funcs )
	self.Functions = funcs
end
function ENT:SetAffect( func )
	self.Affect = func
end

function ENT:Initialize()
	self.Ent = self.Ent or self:GetParent()
	if ( !self.Ent || !self.Ent:IsValid() ) then self:Remove() end
	
	// Initialise physics.
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Entity:SetTrigger( true )
	self.Entity:SetNotSolid( true )
	
	self.Functions = self.Functions or {}
	self.Affect = self.Affect or function() end
end
function ENT:StartTouch( touched )
	if ( touched && touched:IsPlayer() && touched:GetMoveType() == MOVETYPE_NOCLIP ) then
		if ( !self.Owner || !self.Owner:IsValid() || !self.Affect( self.Owner, touched, self.Entity ) ) then return end
		for _, func in pairs( self.Functions ) do
			pcall( func, touched, self )
		end
	end
end
