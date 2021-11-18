
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
----------variables------------
ENT.StartExplosion = 0
ENT.StartExpEffectDel = CurTime()
ENT.Inflate = 0
ENT.Deflate = 0
ENT.SavedThings = {}
ENT.SavedThingss = {}
ENT.OpenClosed = 1
ENT.BeanCounter = 0

ENT.Destroyed = 0
ENT.DestroyDel = CurTime()
ENT.DestroyFirst = 0
ENT.DestroySecond = 0
ENT.DestroyThird = 0

ENT.UseDel = CurTime() 

ENT.IsFull = 0
ENT.FullExplosion = 0
ENT.FullExpEffectDel = CurTime()

ENT.IdleDel = CurTime()
ENT.Idle = NULL
ENT.Explosion = NULL

ENT.MegaPortarStop = NULL
ENT.MegaPortarStart = NULL
ENT.MegaPortal = NULL
------------------------------------VARIABLES END
function ENT:SpawnFunction( ply, tr )
--------Spawning the entity and getting some sounds i use.   
 	if ( !tr.Hit ) then return end 
 	 
 	local SpawnPos = tr.HitPos + tr.HitNormal * 10 
 	 
 	local ent = ents.Create( "sent_QuantumStorageDevice" )
	ent:SetPos( SpawnPos ) 
 	ent:Spawn()
 	ent:Activate() 
 	ent.Owner = ply
	return ent 
 	 
end

function ENT:Initialize()
	self.Entity:SetModel( "models/props_junk/garbage_glassbottle001a.mdl")
	self.Entity:SetMaterial("effects/AnnahilationBomb.vtf") 
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	self.Entity:SetSolid(SOLID_VPHYSICS)	
    local phys = self.Entity:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end

self.Idle = CreateSound(self.Entity,"BeerBomb/IdleSound.wav")
self.Explosion = CreateSound(self.Entity,"BeerBomb/explosion.wav")

self.MegaPortarStart = CreateSound(self.Entity,"HL1/ambience/particle_suck2.wav")
self.MegaPortal = CreateSound(self.Entity,"ambient/levels/labs/teleport_malfunctioning.wav")
self.MegaPortarStop = CreateSound(self.Entity,"ambient/levels/labs/electric_explosion1.wav")

for i=1,200 do
self.SavedThings[i] = NULL
self.SavedThingss[i] = NULL
end

end

-------------------------------------------PHYS COLLIDE
function ENT:PhysicsCollide( data, phys ) 
	ent = data.HitEntity

end
---------------
-------------------------------------------THINK
function ENT:Think()

	if CurTime() > self.IdleDel then
	self.IdleDel = CurTime()+1
	self.Entity:EmitSound("BeerBomb/IdleSound.wav", 80, 100)  
	end



		if self.StartExplosion == 1 and self.StartExpEffectDel > CurTime() and self.Inflate == 0 and self.FullExplosion == 0 then

		local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos()) 
		effectdata:SetMagnitude( (self.StartExpEffectDel - CurTime()))
		util.Effect( "Annahilation", effectdata )
	
		effectdata:SetOrigin( self.Entity:GetPos() ) 
		effectdata:SetMagnitude( (self.StartExpEffectDel - CurTime()))
		util.Effect( "AnnahilationHeat", effectdata )
		
		end


			if self.StartExplosion == 1 and self.StartExpEffectDel < CurTime() and self.Inflate == 0 then
			
				self.Inflate = 1
	
				self.StartExpEffectDel = CurTime()+2



					if	self.OpenClosed == 0 then
								local effectdata = EffectData()	
								effectdata:SetOrigin( self.Entity:GetPos() ) 
								effectdata:SetMagnitude( (self.StartExpEffectDel - CurTime()))
								util.Effect( "AnnahilationInflate", effectdata )
					end
					
						if	self.OpenClosed == 1 then	
							local effectdata = EffectData()	
							effectdata:SetOrigin( self.Entity:GetPos() ) 
							effectdata:SetMagnitude( (self.StartExpEffectDel - CurTime()))
							util.Effect( "AnnahilationInflateRed", effectdata )	
						end
			end


				if self.StartExplosion == 1 and self.StartExpEffectDel < CurTime() and self.Inflate == 1 and self.Deflate == 0 then

				self.Deflate = 1
				self.StartExpEffectDel = CurTime()+1


				if	self.OpenClosed == 0 then
					local effectdata = EffectData()
					effectdata:SetOrigin( self.Entity:GetPos() ) 
					effectdata:SetMagnitude( (self.StartExpEffectDel - CurTime()))
					util.Effect( "AnnahilationDeflate", effectdata )	

							for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 200 ) ) do					
	
								if string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_ragdoll") then
								self.BeanCounter = self.BeanCounter+1		
								self.SavedThings[self.BeanCounter] = v:GetClass()
								self.SavedThingss[self.BeanCounter] = v:GetModel()
								v:Remove()
								end							

							end
					self.IsFull = 1
				end
	
				if	self.OpenClosed == 1 then
				local effectdata = EffectData()
				effectdata:SetOrigin( self.Entity:GetPos() ) 
				effectdata:SetMagnitude( (self.StartExpEffectDel - CurTime()))
				util.Effect( "AnnahilationDeflateRed", effectdata )	

							for i=1,self.BeanCounter do 
							
								local	 Prop = ents.Create(self.SavedThings[i])
										 Prop:SetModel(self.SavedThingss[i])
										 Prop:SetPos(self.Entity:GetPos()+ Vector( math.Rand( -100, 100 ), math.Rand( -100, 100 ),math.Rand( 20, 100 ) ))
										 Prop:Spawn() 								
										Msg("Spawning prop \n ")

							end

				end
	
				end

					if self.StartExplosion == 1 and self.StartExpEffectDel > CurTime() then		
						for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 300 ) ) do

								if string.find(v:GetClass(), "prop_ragdoll") and self.OpenClosed == 0 then
								constraint.NoCollide( self.Entity, v, 0, 0 )	
						

								local phys = v:GetPhysicsObject()
								local bones = v:GetPhysicsObjectCount()

								for i=0,bones-1 do 
	
									v:GetPhysicsObjectNum(i):EnableGravity(false)

								end
					end			


								if string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_ragdoll") and self.OpenClosed == 0 then	

								if self.OpenClosed == 0 then
								constraint.NoCollide( self.Entity, v, 0, 0 )			


								if self.OpenClosed == 0 then
								local r,g,b,a = v:GetColor()

								r = r-8
								g = g-8
								b = b-8
								a = a-8

									if a <= 1 then
									a = 0
									end
	
									if r <= 1 then
									r = 0
									end
		
									if g <= 1 then
									g = 0
									end
									
									if b <= 1 then
									b = 0
									end
		
								constraint.NoCollide( self.Entity, v, 0, 0 )
									
								v:SetColor(r,g,b,a)
								end
		
								local phys = v:GetPhysicsObject( )
								phys:EnableGravity(false)
								phys:ApplyForceCenter(Vector(0,0, (phys:GetMass()*8)))
								v:SetGravity( 0.1 ) 

								local direction = v:GetPos()-self.Entity:GetPos()
								direction:Normalize()
								direction = direction*(phys:GetMass()*-20)

								phys:ApplyForceCenter(direction)


									local effectdata = EffectData()
									effectdata:SetEntity(self.Entity)
									effectdata:SetStart( self.Entity:GetPos() )
									effectdata:SetOrigin( v:GetPos() )
									effectdata:SetScale( 5 )
									util.Effect( "TeslaZap", effectdata ) 

								end
							end			
	
								if string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_ragdoll") and self.OpenClosed == 1 then	
									if self.OpenClosed == 1 then						
								constraint.NoCollide( self.Entity, v, 0, 0 )
									
								local phys = v:GetPhysicsObject( )
								phys:ApplyForceCenter(Vector(0,0,(phys:GetMass()*50)))
								v:SetGravity( 0.1 ) 

								local direction = v:GetPos()-self.Entity:GetPos()
								direction:Normalize()
								direction = direction*(phys:GetMass()*50)

								phys:ApplyForceCenter(direction)
						
								end
								end						
								
								if string.find(v:GetClass(), "npc_*") then	

									local Korv = v:Health() - 5
									v:Fire("sethealth", ""..Korv.."", 0)
								
								end	

								if string.find(v:GetClass(), "player*") then	

									local Korv = v:Health() - 1
									v:Fire("sethealth", ""..Korv.."", 0)
								
								end	


						end

						for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 500 ) ) do
						local distance = self.Entity:GetPos():Distance(v:GetPos())
	
							if distance > 300 then
	
									if string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_ragdoll") and self.OpenClosed == 0 then	
									local phys = v:GetPhysicsObject()
									phys:EnableGravity(true)
									v:SetColor(255,255,255,255)
									end
										if string.find(v:GetClass(), "prop_ragdoll") and self.OpenClosed == 0 then
											local phys = v:GetPhysicsObject()
											local bones = v:GetPhysicsObjectCount()
			
											for i=0,bones-1 do 
											v:GetPhysicsObjectNum(i):EnableGravity(true)
			
											end
										end
							end
						end
					end




-----------------------------------------------------
							if self.IsFull == 1 or self.FullExplosion == 1 then
							self.Entity:SetMaterial("effects/AnnahilationBombFull.vtf") 
							end

							if self.IsFull == 0 then
							self.Entity:SetMaterial("effects/AnnahilationBomb.vtf") 
							end
-----------------------------------------------------

		if self.StartExplosion == 1 and self.StartExpEffectDel > CurTime() and self.Inflate == 0 and self.FullExplosion == 1 then

		local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos()) 
		effectdata:SetMagnitude( (self.StartExpEffectDel - CurTime()))
		util.Effect( "AnnahilationOut", effectdata )
	
		effectdata:SetOrigin( self.Entity:GetPos() ) 
		effectdata:SetMagnitude( (self.StartExpEffectDel - CurTime()))
		util.Effect( "AnnahilationHeatOut", effectdata )
		
		end

						if self.StartExplosion == 1 and self.StartExpEffectDel < CurTime() and self.FullExplosion == 1 then
						self.IsFull = 0
						self.StartExplosion = 0

---Resettign values
							for i=1,200 do
							self.SavedThings[i] = NULL
							self.SavedThingss[i] = NULL
							end

							self.StartExplosion = 0
							self.StartExpEffectDel = CurTime()
							self.Inflate = 0
							self.Deflate = 0
							self.BeanCounter = 0
							
							
							self.UseDel = CurTime() 
							
							self.IsFull = 0
							self.FullExplosion = 0
							self.FullExpEffectDel = CurTime()


---Resetting values end

						end


	if self.Destroyed == 1 and self.DestroyDel > CurTime() then

		self.MegaPortarStop:Stop()
		self.MegaPortarStart:Play()

	if self.DestroyFirst == 0 then
	self.DestroyFirst = 1

		self.MegaPortal:Play()

		local effectdata = EffectData()	
		effectdata:SetOrigin( self.Entity:GetPos() ) 
		effectdata:SetMagnitude( (self.StartExpEffectDel - CurTime()))
		util.Effect( "AnnahilationInflate", effectdata )
	end


		if (self.DestroyDel-7.5) < CurTime() and self.DestroySecond == 0 then
		self.DestroySecond = 1
	
			self.MegaPortal:Play()
	
			local effectdata = EffectData()	
			effectdata:SetOrigin( self.Entity:GetPos() ) 
			effectdata:SetMagnitude( (self.StartExpEffectDel - CurTime()))
			util.Effect( "AnnahilationLoop", effectdata )
		end


			if (self.DestroyDel-2) < CurTime() and self.DestroyThird == 0 then
			self.DestroyThird = 1
				self.MegaPortarStop:Play()		
				local effectdata = EffectData()	
				effectdata:SetOrigin( self.Entity:GetPos() ) 
				effectdata:SetMagnitude( (self.StartExpEffectDel - CurTime()))
				util.Effect( "AnnahilationDeflate", effectdata )
			end


		for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 500 ) ) do

									local effectdata = EffectData()
									effectdata:SetEntity(self.Entity)
									effectdata:SetStart( self.Entity:GetPos() )
									effectdata:SetOrigin( v:GetPos() )
									effectdata:SetScale( 10 )
									util.Effect( "TeslaZap", effectdata ) 

	if string.find(v:GetClass(), "npc_*") then	

		local Korv = v:Health() - 20
		v:Fire("sethealth", ""..Korv.."", 0)
	
	end	

	if string.find(v:GetClass(), "player*") then	

		local Korv = v:Health() - 10
		v:Fire("sethealth", ""..Korv.."", 0)
	
	end	

				if string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_ragdoll") then	

				local phys = v:GetPhysicsObject( )
				phys:ApplyForceCenter(Vector(0,0,(phys:GetMass()*10)))
				v:SetGravity( 0.1 ) 

				local direction = v:GetPos()-self.Entity:GetPos()
				direction:Normalize()
				direction = direction*(phys:GetMass()*-5000)

				phys:ApplyForceCenter(direction)
				end
		end

		for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 100 ) ) do
			if string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_ragdoll") then	
			v:Remove()
			end
		end

						for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 700 ) ) do
						local distance = self.Entity:GetPos():Distance(v:GetPos())
	
							if distance > 500 then
	
									if string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_ragdoll") and self.OpenClosed == 0 then	
										local phys = v:GetPhysicsObject()
										phys:EnableGravity(true)
										v:SetColor(255,255,255,255)
									end
							end
						end


	end

	if self.DestroyDel < CurTime() then
	self.MegaPortal:Stop()
	self.MegaPortarStart:Stop()
	self.MegaPortarStop:Play()
	end


if self.DestroyFirst == 1 and self.DestroySecond == 1 and self.DestroyThird == 1 then
self.MegaPortal:Stop()
self.Entity:Remove()
end

end
-------------------------------------------USE
function ENT:Use()
if self.UseDel < CurTime() then
 self.UseDel = CurTime()+10

	if self.IsFull == 0 and self.FullExplosion == 0 then
	self.StartExplosion = 1
	self.StartExpEffectDel = CurTime()+4
	self.Entity:EmitSound("BeerBomb/explosion.wav", 100, 100)
	self.OpenClosed = 0
	end

	if self.IsFull == 1 then
	self.FullExplosion = 1
	self.OpenClosed = 1
	self.Inflate = 0
	self.Deflate = 0
	self.StartExplosion = 1
	self.StartExpEffectDel = CurTime()+4
	self.Entity:EmitSound("BeerBomb/explosion.wav", 100, 100)
	end

end
end
-------------------------------------------Damage
function ENT:OnTakeDamage(dmg)

self.Destroyed = 1
self.DestroyDel = CurTime()+10

end
