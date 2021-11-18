AddCSLuaFile( "cl_init.lua" ) // Make sure clientside  
AddCSLuaFile( "shared.lua" )  // and shared scripts are sent.     
include('shared.lua')     

function ENT:Initialize()     	
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      // Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   // after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )         // Toolbox                
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake()  	
	end  
	math.randomseed(CurTime())
	self.pilot = nil
	self.onboard = false
	self.engines = false
	self.dead = false
	self.locked = false
	self.locker = nil
	self.used = false
	self.throttle = 0
	self.aimang = self.Entity:GetAngles()
	self.reload = true
	self.gunsound = Sound("Weapon_m4a1.Single")
	self.bombsound = Sound("weapons/m4a1/m4a1_clipin.wav")
	self.enginesound = Sound("npc/combine_gunship/dropship_engine_near_loop1.wav")
	self.enginesound = CreateSound(self.Entity, "npc/combine_gunship/dropship_engine_near_loop1.wav" ) 
	self.smoke = nil
	self.pilotweps = {}
end     

function ENT:Use(activator)
	if !self.dead and !self.onboard then
		if !self.used then
			if !self.locked and !self.onboard then
				self.Entity:ClimbOn(activator)
			end
		self.used = true
		timer.Simple(0.2,unuse,self)
		end
	end
end

function ENT:OnTakeDamage( dmg )
	if !self.dead then
	local d = dmg:GetDamage()
	self.health = self.health - d
	if self.health <= 0 then
	self.Entity:Explode()
	end
	end
end

function ENT:Explode()
	if !self.dead then
	self.dead = true
	if self.onboard then
	local p = self.pilot
	self.Entity:EngineStop()
	self.Entity:ClimbOff()
	p:Kill()
	end
	local t = 0.5
	for i=1,8 do  
		timer.Simple(t,PropShipRandomBang,self.Entity:GetPos())
		t = t + 0.3
	end
	end
end

 function PropShipRandomBang(position)
 		local effectdata = EffectData()
		local pos = position
		pos.z = pos.z + math.random(-30,30)
		pos.x = pos.x + math.random(-40,40)
		pos.y = pos.y + math.random(-40,40)
		effectdata:SetOrigin( pos)
		effectdata:SetStart(position)
		effectdata:SetMagnitude( 80 )
		effectdata:SetScale( 10 )
		effectdata:SetRadius( 30 )
	util.Effect( "Explosion", effectdata )
 end

 function ENT:PhysicsSimulate( phys, deltatime )

	local a = self.aimang
	local e = self.Entity:GetForward()
	--if self.orient == 1 then
--	e = self.Entity:GetRight()
	--elseif self.orient == 2 then
--	e = self.Entity:GetUp()
--	Msg(tostring(a) .. " " .. tostring(e:Angle()) .. "\n")
--	end												-- more botched angle stuff
	 local pos = self.Entity:GetPos( )
	pos =  pos + (e * self.throttle)
			local mpphys = {}
 			mpphys.secondstoarrive	= 1
			mpphys.pos				= pos
			mpphys.maxangular		= 4000
			mpphys.maxangulardamp	= 10000
			mpphys.maxspeed			= 100000
			mpphys.maxspeeddamp		= 10000
			mpphys.dampfactor		= 0.5
			mpphys.teleportdistance	= 3000
			mpphys.angle			= a
			mpphys.deltatime		= deltatime
			phys:ComputeShadowControl(mpphys)
 end
 
function ENT:ClimbOn(player)
	self.onboard = true
	self.pilot = player
	self.pilot:Spectate( OBS_MODE_CHASE )
	self.pilot:SpectateEntity( self.Entity ) 
	self.pilot:DrawViewModel(false)
	self.pilot:DrawWorldModel(false)
	self.Entity:SetPhysicsAttacker( self.pilot )
	for k, v in pairs(self.pilot:GetWeapons()) do
				table.insert(self.pilotweps,v:GetClass())
			end
	self.pilot:StripWeapons()
end
 
function ENT:ClimbOff()
	self.onboard = false
	self.pilot:UnSpectate()  
	self.pilot:DrawViewModel(true)
	self.pilot:DrawWorldModel(true)
	self.pilot:Spawn()
	local z = self.Entity:GetPos()
	z.z = z.z + 100
	self.pilot:SetPos(z)
	self.Entity:SetPhysicsAttacker( nil )
		timer.Simple(0.2,unuse,self)
	self.pilot:StripWeapons()
	 self.pilot:StripWeapons()
 		local guns = self.pilotweps
		for v = 1, #guns, 1 do
			self.pilot:Give(guns[v])
		end
	self.pilot = nil
	self.used = true
end
 
function unuse(self)
	self.used = false
end
 
 function propshipreload(self)
 self.reload = true
 end
 
function ENT:EngineStop()
	self.Entity:GetPhysicsObject():EnableGravity(true)
	self.Entity:StopMotionController()
	self.throttle = 0
	self.engines = false
	self.enginesound:Stop()
	if self.trail then
	self.smoke:Remove()
	end
end

function ENT:EngineStart()
	self.Entity:GetPhysicsObject():EnableGravity(false)
	self.Entity:StartMotionController()
	self.engines = true
	self.enginesound:Play()
	if self.trail then
	smoke = ents.Create("env_smoketrail")
smoke:SetKeyValue("startsize","50")
smoke:SetKeyValue("endsize","100")
smoke:SetKeyValue("minspeed","4")
smoke:SetKeyValue("maxspeed","20")
smoke:SetKeyValue("startcolor","0 0 0")
smoke:SetKeyValue("endcolor","40 40 40")
smoke:SetKeyValue("opacity",".7")
smoke:SetKeyValue("spawnrate","10")
smoke:SetKeyValue("lifetime","3")
smoke:SetPos(self.Entity:GetPos())
smoke:Spawn()
smoke:SetParent(self.Entity)
self.smoke = smoke
end
end

function ENT:FireGun()
 local   bullet = {}  
 bullet.Num = 1  
 bullet.Src = self.Entity:GetPos()  
 bullet.Dir = self.pilot:GetAimVector()  
 bullet.Spread = Vector(0.01,0.01,0.01)  
 bullet.Tracer = 1	  
 bullet.Force = (self.shotdamage * 10)  
 bullet.Damage = self.shotdamage
 self.Entity:FireBullets(bullet)  
 self.Entity:EmitSound( self.gunsound, 200, 100 )
end

function ENT:DropBomb()
if self.reload then
self.reload = false
local lockm = ents.Create( "sent_propship_bomb" ) 
lockm:SetPos(self.Entity:GetPos())
lockm:SetAngles(self.Entity:GetAngles())
lockm:SetOwner(self.Entity)
lockm.damage = self.shotdamage
lockm.life = (CurTime() + self.fuse)
lockm.pilot = self.pilot
lockm:Spawn()
timer.Simple(0.4,propshipreload,self)
self.Entity:EmitSound( self.bombsound, 200, 100 )
end
end


 function ENT:Think() 
 	if !self.dead then
		if self.onboard then
		self.Entity:GetPhysicsObject():Wake()
			if self.pilot:KeyDown(IN_FORWARD) and (self.throttle < self.maxspeed) then
				self.throttle = (self.throttle + self.acc)
			elseif self.pilot:KeyDown(IN_BACK) and self.throttle > 0  then
				self.throttle = (self.throttle - self.acc)
			end
			if !self.pilot:KeyDown(IN_ATTACK2) then
				local ger = self.pilot:GetAimVector():Angle()
			--	local r = nil
			--		if self.orient == 1 then
			--			r = ger:Right()
			--			r.r = r.r * -1
			--			r.p = r.p * -1
			--			self.aimang = r:Angle()
			--		elseif self.orient == 2 then
			--			r = ger:Up()
			--			r.r = r.r * -1
			--			r.y = r.y * -1
		--			end
					--even more royally buggered angle math
				self.aimang = ger
			end	
			local percentile = (100 / self.maxspeed)
			percentile = percentile * self.throttle
			percentile = math.floor( percentile )
			self.pilot:PrintMessage( HUD_PRINTCENTER, "Throttle at " .. tostring(percentile) .. "%, hp at " .. tostring(self.health)) 
			if (!self.engines) and (self.throttle > 0) then
				self.Entity:EngineStart()
			elseif self.engines and (self.throttle <= 0) then
				self.Entity:EngineStop()
			end
			if self.pilot:KeyDown(1) then
			if self.engines then
				if self.weapontype == 1 then
					self.Entity:FireGun()	
				elseif self.weapontype == 2 then
					self.Entity:DropBomb()
				end
			end
			end
			if self.pilot:KeyDown(IN_USE) and !self.used then
				if self.engines then
					self.Entity:EngineStop()
				end
				self.Entity:ClimbOff()
			end
			self.Entity:NextThink(CurTime())
		end
	end
 end


 