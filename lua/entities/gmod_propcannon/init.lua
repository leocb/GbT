
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()

	--self.Entity:SetModel( "models/dav0r/tnt/tnt.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

    local phys = self.Entity:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end
end

/*---------------------------------------------------------
   Name: KeyValue
   Desc: Called when a keyvalue is added to us
---------------------------------------------------------*/
function ENT:Setup( force, model, ammo, recoil, reload, proptime, bangpower, bangradius, effect, explodeoncontact)

	self.cannonForce = force
	self.model=model
	self.ammo=ammo
	self.recoil=recoil
	self.reload=reload
	self.reloadtimer=0
	self.firing=false
	self.proptime=proptime
	self.bangpower=bangpower
	self.bangradius=bangradius
	self.effect=effect
	self.explodeoncontact=explodeoncontact
	
	self.Entity:SetModel( model ) 
	
	// Wot no translation :(
	self:SetOverlayText( "Force: " .. math.floor(force)..", Reload: "..math.floor(reload).."\nBang Power:"..math.floor(bangpower)..", Bang Radius:"..math.floor(bangradius).."\nAmmo: "..ammo)
	
end

function ENT:OnTakeDamage( dmginfo )

	self.Entity:TakePhysicsDamage( dmginfo )
	--self.Entity:SetHealth(self.Entity:Health()-dmginfo:GetDamage())
	--if(self.Entity:Health()<=0) then
	--self.Entity:Fire( "break", "", 0 )
    --self.Entity:Remove()
	--end
end

function ENT:StartFiring()
		 self.firing=true
		 self:FireShot()
end

function ENT:StopFiring()
		 self.firing=false
end

function ENT:Think()
    if(self.firing) then
	    self:FireShot()
	end
	if(self.reloadtimer>0) then
		--self:NextThink(CurTime()+self.reloadtimer)
		self.reloadtimer=self.reloadtimer-1
	end
end

function ENT:FireShot()


	if ( !self.Entity:IsValid() ) then Msg("CANNON: Doesn't exist!\n") return end
	
	if(self.reloadtimer<=0) then
	
	self.reloadtimer=self.reload
	
	if(self.effect!="") then
	
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		util.Effect( self.effect, effectdata, true, true )
	
	end
	
	
	local ent = ents.Create( "prop_physics" )
	if ( !ent:IsValid() ) then return end
	ent:SetPos( self.Entity:GetPos())
	ent:SetModel(self.ammo)
	ent:SetOwner(self.Entity)
	
	//ent:SetVelocity(self.Entity:GetForward()*(self.cannonForce/phys2:GetMass()))
	//phys2:SetVelocity(Vector(100,0,0))
	ent:SetAngles(self.Entity:GetAngles())
	
	
    if(self.bangpower>0) then
    	
    	if(self.explodeoncontact) then
	    	ent:SetKeyValue("physdamagescale","500000000000")
	    	--ent:SetHealth(10000)
	    	--ent:SetKeyValue("health","1000")
	    	--Msg("Exploding on impact\n")
		else
		    ent:SetKeyValue("physdamagescale","0.0000001")
		    --ent:SetHealth(10000)
		    --ent:SetKeyValue("health","100000000")
		    --Msg("NOT Exploding on impact\n")
		end
	    ent:SetKeyValue("ExplodeRadius",""..self.bangradius)
	    ent:SetKeyValue("ExplodeDamage",""..self.bangpower)
    
    end
	
	
	ent:Spawn()
	
	
	
	

	
	if(self.bangpower>0) then
	    if(self.proptime>0) then
					ent:Fire("break","0",self.proptime)
					ent:Fire("kill","0",self.proptime+0.1)
		end
		
		ent:Fire("addoutput","onhealthchanged !self,break",0)
		ent:Fire("addoutput","onhealthchanged !self,kill",0.1)
	
	else
	     if(self.proptime>0) then
					ent:Fire("kill","0",self.proptime)
		end
	end
	
	
	local phys = self.Entity:GetPhysicsObject()
	if (!phys:IsValid()) then return end

	local phys2 = ent:GetPhysicsObject()
	if (!phys2:IsValid()) then return end
	
	phys2:SetVelocityInstantaneous(phys:GetVelocity())
	phys2:ApplyForceCenter(self.Entity:GetUp()*self.cannonForce)
	phys:ApplyForceCenter(self.Entity:GetUp()*-1*self.cannonForce*self.recoil)
	
	end
	
end


local function On( pl, ent )
    if ( !ent || ent == NULL ) then return end

	local etab = ent:GetTable()
	etab:StartFiring()
end

local function Off( pl, ent )
   	if ( !ent || ent == NULL ) then return end

	local etab = ent:GetTable()
	etab:StopFiring()
end

numpad.Register( "PropCannon_On", 	On )
numpad.Register( "PropCannon_Off", Off )