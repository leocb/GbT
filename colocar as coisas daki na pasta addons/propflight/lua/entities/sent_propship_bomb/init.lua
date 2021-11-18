AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside  
AddCSLuaFile( "shared.lua" )  --and shared scripts are sent.     
include('shared.lua')     

function ENT:Initialize()   

self.Entity:SetModel("models/props_junk/watermelon01.mdl")
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox               
local phys = self.Entity:GetPhysicsObject()  	
if (phys:IsValid()) then  		
phys:Wake()  	
end  
self.Entity:SetMaterial("debug/env_cubemap_model")
end     
  


function ENT:Touch(activator)
	self.Entity:Explode()
end

function ENT:Explode()
local pos = self.Entity:GetPos()
	local effectdata = EffectData()
		effectdata:SetOrigin( pos )
		effectdata:SetStart(self.Entity:GetPos())
		effectdata:SetMagnitude( 80 )
		effectdata:SetScale( 10 )
		effectdata:SetRadius( 30 )
	util.Effect( "Explosion", effectdata )
	util.BlastDamage( self.Entity, self.pilot, pos, 150, self.damage )
	self.Entity:Remove()
end

function ENT:Think()
if self.life < CurTime() then
self.Entity:Explode()
end
end
