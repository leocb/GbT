
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   
	self.Entity:SetMoveType( MOVETYPE_NONE )
end   

function ENT:OnRemove()
	duplicator.ClearEntityModifier(self.ent, "propeller")
	self.ent.Propeller_Ent = nil
end

function ENT:Think()
      

	    if ( !self.ent:IsValid() ) then return end
	    
	    local phys = self.ent:GetPhysicsObject()		// The physics object
		  if ( !phys:IsValid() ) then return end
		
			local force = self.efficiency					// The ideal amount of force

			
			// Lessen the force from a distance
			local ratio = 20
			local curup = self:GetForward()
			local curvel = phys:GetVelocity()
			local angvel = phys:GetAngleVelocity()
			
      // Set up the 'real' force and the offset of the force
			local vForce = curup * (force * angvel.z)  
			
			// Apply it!
			phys:ApplyForceCenter( vForce ) 
	
	self.Entity:NextThink( CurTime())
	return true 
end
