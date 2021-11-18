
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.StartTimer = CurTime()+4
ENT.SelfRemoveTimer = CurTime() + 24
ENT.FreezeTimeOnce = 0
ENT.EntLib = {}
ENT.SecEntLib = {}
ENT.BeanCounter = 0
ENT.SecBeanCounter = 0
ENT.StayTimer = CurTime()

ENT.PlayersLib = {}
ENT.FreezeAngle = {}
ENT.FreezePos = {}
ENT.PlyLibNum = 0
ENT.StopDel = CurTime()


function StopMovement(player, move)  
   return true  
end 


function ENT:Initialize()
	self.Entity:SetModel("models/Items/grenadeAmmo.mdl")

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	self.Entity:SetSolid(SOLID_VPHYSICS)	
    local phys = self.Entity:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end

	self.StartTimer = CurTime()+4
	self.SelfRemoveTimer = CurTime() + 24	

	self.Entity:EmitSound( "TimeGrenade/Timer.mp3",100 )
	
end

function ENT:PhysicsCollide( data, phys ) 
end

function ENT:Think()

------------INITIATING THE GRENADE
	if self.StartTimer < CurTime() then
		if self.FreezeTimeOnce < 2 then
			self.Entity:GetPhysicsObject():EnableMotion( false )
			self.FreezeTimeOnce = self.FreezeTimeOnce + 1

			if self.FreezeTimeOnce == 1 then
				self.Entity:EmitSound( "TimeGrenade/TimeExplosion.mp3",100 )
				self.Entity:EmitSound( "TimeGrenade/Ineffect2.mp3", 100 )

					  local effectdata = EffectData()
					  effectdata:SetOrigin( self.Entity:GetPos() )
					  util.Effect( "TimeStop", effectdata ) 

				for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 400 ) ) do	
					if v:IsNPC() and v:IsValid() then

						local Korv = v:Health() - 100000
						v:Fire("sethealth", ""..Korv.."", 0)

					end

					if v:IsPlayer() and v:IsValid() then

						if v:Health() > 1 then
						local Korv = (v:Health())/2
						v:Fire("sethealth", ""..Korv.."", 0)
						end

						self.PlyLibNum = self.PlyLibNum + 1

						self.PlayersLib[self.PlyLibNum] = v
						v:Freeze(true)
						self.FreezeAngle[self.PlyLibNum] = v:EyeAngles( )
						self.FreezePos[self.PlyLibNum] = v:GetPos()

						
					end

				end
			end
				
				if self.FreezeTimeOnce == 2 then			
					self.StayTimer = CurTime() + 1
					for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 400 ) ) do	

					if string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_vehicle_*") or string.find(v:GetClass(), "npc_manhack") or string.find(v:GetClass(), "npc_rollermine") and v:IsValid() and v ~= NULL and v ~= nil and v:IsPlayer() == false then
								self.BeanCounter = self.BeanCounter + 1
								
								v:GetPhysicsObject():SetVelocity( Vector(0,0,0) )
								v:GetPhysicsObject():Sleep()
								v:GetPhysicsObject():EnableGravity( false )
								self.EntLib[self.BeanCounter] = v

						end

							if string.find(v:GetClass(), "prop_ragdoll") and v:IsValid() and v ~= NULL and v ~= nil and v:IsPlayer() == false  then

								local bones = v:GetPhysicsObjectCount()
							   	self.BeanCounter = self.BeanCounter + 1
								self.EntLib[self.BeanCounter] = v
									for i=0,bones-1 do

										v:GetPhysicsObjectNum(i):SetVelocity( Vector(0,0,0) )
										v:GetPhysicsObjectNum(i):Sleep()
										v:GetPhysicsObjectNum(i):EnableGravity( false )
									end 
							
							end
					end
				end
		end

	end
------------INITIATING THE GRENADE END
------------SLOWING DOWN PROPS
if self.StartTimer < CurTime() and self.FreezeTimeOnce == 2 then

		for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 600 ) ) do

		if v ~= NULL and v ~= nil then
			if string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_vehicle_*") or string.find(v:GetClass(), "npc_manhack") or string.find(v:GetClass(), "npc_rollermine") and v:IsValid() and v:IsPlayer() == false then

				local HowManyTimes = table.Count(self.SecEntLib)
				local doit = 0

					for i=1,HowManyTimes do 
						if v == self.SecEntLib[i] then
						doit = 1
						end
					end

						v:GetPhysicsObject():EnableGravity(false)
						v:GetPhysicsObject():SetVelocity(((v:GetPhysicsObject():GetVelocity())/2))
						local thing = v:GetPhysicsObject()
						thing:AddAngleVelocity( ((thing:GetAngleVelocity())*-0.5) )

						if doit == 0 then
						self.SecEntLib[self.SecBeanCounter] = v
						self.SecBeanCounter = self.SecBeanCounter + 1
						end

			end

					if string.find(v:GetClass(), "prop_ragdoll") and  v:IsValid() and v:IsPlayer() == false then

					
						local HowManyTimes = table.Count(self.SecEntLib)
						local doit = 0

							--for i=1,HowManyTimes do 
							--	if v == self.SecEntLib[i] then
							--	doit = 1
							--	end
							--end
					
									local bones = v:GetPhysicsObjectCount()								
	
										for i=0,bones-1 do
											v:GetPhysicsObjectNum(i):EnableGravity(false)
											v:GetPhysicsObjectNum(i):SetVelocity( (v:GetPhysicsObjectNum(i):GetVelocity())/2 )
										end 
							--if doit == 0 then
								self.SecBeanCounter = self.SecBeanCounter + 1
								self.SecEntLib[self.SecBeanCounter] = v	
							--end
					end
			end



		end
end
--------------------------SLOWING DOWN PROPS END
	
	if self.PlyLibNum > 0 and self.StopDel < CurTime() then

	self.StopDel = CurTime() + 0.05	

		for i=1,self.PlyLibNum do

			if self.PlayersLib[i] ~= NULL then
				if self.PlayersLib[i]:Alive( ) == false then
					self.PlayersLib[i]:Freeze(false)
					self.PlayersLib[i] = NULL
				end
			end

			
			if self.PlayersLib[i] ~= NULL then
			self.PlayersLib[i]:SetVelocity((self.PlayersLib[i]:GetVelocity()*-1)) 
			self.PlayersLib[i]:SetPos(self.FreezePos[i])
			self.PlayersLib[i]:SetEyeAngles( (self.FreezeAngle[i]))
			end
		
		end

	end

 
--------------------------CHECKING IF THEY ARE OUTSIDE THE RADIUS
		for k, v in pairs( ents.FindInSphere( self.Entity:GetPos(), 1000 ) ) do
	
			if string.find(v:GetClass(), "prop_physics") or string.find(v:GetClass(), "prop_vehicle_*") or string.find(v:GetClass(), "npc_manhack") or string.find(v:GetClass(), "npc_rollermine") and v:IsValid() and v ~= NULL and v ~= nil and v:IsPlayer() == false then
				local Dist = self.Entity:GetPos():Distance( v:GetPos() )

				if Dist > 600 then
				v:GetPhysicsObject():EnableGravity(true)
				v:GetPhysicsObject():Wake()
				end

			end

			if string.find(v:GetClass(), "prop_ragdoll") and v:IsValid() and v ~= NULL and v ~= nil and v:IsPlayer() == false  then
				local Dist = self.Entity:GetPos():Distance( v:GetPos() )
	
				if Dist > 600 then
					local bones = v:GetPhysicsObjectCount()

						for i=0,bones-1 do
						v:GetPhysicsObjectNum(i):EnableGravity(true)
						v:GetPhysicsObjectNum(i):Wake()

						end
				end

			end
		end
--------------------------CHECKING IF THEY ARE OUTSIDE THE RADIUS END



	if self.SelfRemoveTimer < CurTime() then
		self.Entity:Remove()
	end
	
end

function ENT:OnRemove()

					  local effectdata = EffectData()
					  effectdata:SetOrigin( self.Entity:GetPos() )
					  util.Effect( "TimeStart", effectdata ) 

if self.BeanCounter > 0 then
local HowManyTimes = self.BeanCounter
	for i=1,HowManyTimes do 

		if self.EntLib[i] ~= NULL and self.EntLib[i] ~= nil then
		if self.EntLib[i]:IsValid() and string.find(self.EntLib[i]:GetClass(), "prop_physics") or string.find(self.EntLib[i]:GetClass(), "prop_vehicle_*")  or string.find(self.EntLib[i]:GetClass(), "npc_manhack") or string.find(self.EntLib[i]:GetClass(), "npc_rollermine") then
		self.EntLib[i]:GetPhysicsObject():EnableGravity(true)
		self.EntLib[i]:GetPhysicsObject():Wake()
		end
		end

	if self.EntLib[i] ~= NULL and self.EntLib[i] ~= nil then
		if self.EntLib[i]:IsValid() and string.find(self.EntLib[i]:GetClass(), "prop_ragdoll") then
		
			local bones = self.EntLib[i]:GetPhysicsObjectCount()

				for u=0,bones-1 do
					 self.EntLib[i]:GetPhysicsObjectNum(u):EnableGravity(true)
					 self.EntLib[i]:GetPhysicsObjectNum(u):Wake()
				end 
		end
	end
	end
end


if self.SecBeanCounter > 0 then
local HowManyTimes = self.SecBeanCounter
	for i=1,HowManyTimes do 

		if self.SecEntLib[i] ~= NULL and self.SecEntLib[i] ~= nil then
			if self.SecEntLib[i]:IsValid() and string.find(self.SecEntLib[i]:GetClass(), "prop_physics") or string.find(self.SecEntLib[i]:GetClass(), "prop_vehicle_*") or string.find(self.SecEntLib[i]:GetClass(), "npc_manhack") or string.find(self.SecEntLib[i]:GetClass(), "npc_rollermine") then
			self.SecEntLib[i]:GetPhysicsObject():EnableGravity(true)
			self.SecEntLib[i]:GetPhysicsObject():Wake()
			end
		end

		if self.SecEntLib[i] ~= NULL and self.SecEntLib[i] ~= nil then
			if self.SecEntLib[i]:IsValid() and string.find(self.SecEntLib[i]:GetClass(), "prop_ragdoll") then
			
				local bones = self.SecEntLib[i]:GetPhysicsObjectCount()

					for u=0,bones-1 do
						 self.SecEntLib[i]:GetPhysicsObjectNum(u):EnableGravity(true)
						 self.SecEntLib[i]:GetPhysicsObjectNum(u):Wake()
					end 
			end
		end
	end
end


	for i=1,self.PlyLibNum do
		
			if self.PlayersLib[i] ~= NULL then
			self.PlayersLib[i]:Freeze(false)
			end
		
		end
end
