resource.AddFile( "sound/TimeGrenade/TimeExplosion.mp3" )
resource.AddFile( "sound/TimeGrenade/Ineffect2.mp3" )
resource.AddFile( "sound/TimeGrenade/Timer.mp3" )
resource.AddFile( "sound/TimeGrenade/HandTime.mp3" )
resource.AddFile( "sound/TimeGrenade/TimeTravel.mp3" )
resource.AddFile( "materials/weapons/timegrenadeicon.vmt" )
resource.AddFile( "materials/weapons/timegrenadeicon.vtf" )
resource.AddFile( "materials/vgui/entities/weapon_timegrenade.vmt" )
resource.AddFile( "materials/vgui/entities/weapon_timegrenade.vtf" )

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )		

end

if ( CLIENT ) then

	SWEP.PrintName			= "Time Grenade"			
	SWEP.Author				= "Sakarias"
	SWEP.DrawCrosshair 		= true
	SWEP.DrawAmmo			= false
	SWEP.Slot				= 1
	SWEP.SlotPos			= 0
	SWEP.ViewModelFOV		= 70
	SWEP.WepSelectIcon = surface.GetTextureID("weapons/TimeGrenadeIcon")

end

SWEP.PrimDel = CurTime()
SWEP.PulledThePin = 0
SWEP.DrawOnce = 0
SWEP.ThrowDel = CurTime()

SWEP.SecPickUpGren = 0
SWEP.PickUpDel = CurTime()
SWEP.TheSlowThing = NULL
SWEP.AnotherSlowThing = NULL

SWEP.ApplyForceDel = CurTime()

SWEP.PlayRewind = 0 
SWEP.TimeTravelDel = CurTime()
SWEP.TimeTravel = NULL
SWEP.HandSound = NULL
SWEP.HandSDel = CurTime()

SWEP.TimeSwap = {}
SWEP.TimeSwapAng = {}
SWEP.TimeSwapVel = {}
SWEP.TimeNum = 0
SWEP.TimeNumTwo = 0
SWEP.TimeSwapDel = CurTime()
SWEP.RelDel = CurTime()

SWEP.DisableSecOnce = 0
SWEP.DisableFirstOnce = 0

function SWEP:Initialize()
if SERVER then
	self:SetWeaponHoldType( "grenade" )
end

 self.HandSound = CreateSound(self.Weapon,"TimeGrenade/HandTime.mp3") 
 self.TimeTravel = CreateSound(self.Weapon,"TimeGrenade/TimeTravel.mp3") 
end

----------------------------THINK
function SWEP:Think()

--[[
if self.Owner:KeyDown( IN_USE ) then

 self.TimeNum =  0
 self.TimeNumTwo = self.TimeNum

end
--]]

------TimeRewind
if self.TimeSwapDel < CurTime() and not ( self.Owner:KeyDown( IN_RELOAD  ) ) then
 self.PlayRewind = 0
 self.TimeTravelDel = CurTime()
 self.TimeTravel:Stop()
 self.TimeSwapDel = CurTime()+0.25
 self.TimeNum =  self.TimeNum + 1
 self.TimeNumTwo = self.TimeNum
 self.TimeSwap[self.TimeNum] = self.Owner:GetPos()
 self.TimeSwapAng[self.TimeNum] = self.Owner:EyeAngles( )
 self.TimeSwapVel[self.TimeNum] = self.Owner:Health()
 end
 
------TimeRewind END
	if not ( self.Owner:KeyDown( IN_ATTACK ) ) and self.PulledThePin == 1 and self.ThrowDel < CurTime() then
			self.DrawOnce = 0
			self.PulledThePin = 0
			self.PrimDel = CurTime() + 2
			self.Weapon:SendWeaponAnim(ACT_VM_THROW)
--			self.Weapon:SendWeaponAnim(ACT_WM_THROW)

			self.Weapon:EmitSound("weapons/slam/throw.wav" )
			
		local ent = ents.Create("sent_TimeGrenade")
		ent:SetPos(self.Owner:GetShootPos())
		ent:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360)))
		ent:SetOwner(self.Weapon:GetOwner())
		ent:Spawn()
		ent:Activate()

		ent:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector() * 750)
	end


		if self.DrawOnce == 0 then
		self.DrawOnce = 1
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		end

		if self.SecPickUpGren == 1 and self.PickUpDel < CurTime() then
		self.SecPickUpGren = 0
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		end
	
	if not ( self.Owner:KeyDown( IN_ATTACK2 ) ) then
	
		self.HandSound:Stop()
		self.HandSDel = CurTime()
	if self.TheSlowThing ~= NULL and self.TheSlowThing ~= nil then	
		
		if self.TheSlowThing:IsValid() and self.DisableSecOnce == 0 then

		self.DisableSecOnce = 1
		
			if string.find(self.TheSlowThing:GetClass(), "prop_physics") or string.find(self.TheSlowThing:GetClass(), "prop_vehicle_*") then
				self.TheSlowThing:GetPhysicsObject():EnableGravity(true)
				self.TheSlowThing:GetPhysicsObject():Wake()
			end
				if string.find(self.TheSlowThing:GetClass(), "prop_ragdoll") then

					local bones = self.TheSlowThing:GetPhysicsObjectCount()

						for i=0,bones-1 do
							 self.TheSlowThing:GetPhysicsObjectNum(i):EnableGravity(true)
							self.TheSlowThing:GetPhysicsObjectNum(i):Wake()
						end 

				end

		end
	end
	
	
	end
	
end
----------------------------DRAW
function SWEP:Draw()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end
----------------------------PRIMARY ATTACK
function SWEP:PrimaryAttack()

	if self.PrimDel < CurTime() and self.PulledThePin == 0 then
		self.ThrowDel = CurTime()+0.7
		self.PulledThePin = 1
			self.Weapon:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
--			self.Weapon:SendWeaponAnim(ACT_WM_PULLBACK_HIGH)
	end

end
----------------------------SECONDARY ATTACK
function SWEP:SecondaryAttack()

	if self.PulledThePin == 0 and self.PrimDel < CurTime() then
	self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)	

	if self.HandSDel < CurTime() then
	self.HandSDel = CurTime() + 5
	self.HandSound:Stop()
	self.HandSound:Play()
	end
	
	self.SecPickUpGren = 1
	self.PickUpDel = CurTime() + 1

	
	local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + (self.Owner:GetAimVector() * 500)
	trace.filter = { self.Owner, self.Weapon }
	local tr = util.TraceLine( trace )

		if tr.HitWorld or (tr.Hit == false) then
--------------
		if self.TheSlowThing ~= NULL and self.TheSlowThing ~= nil and self.DisableFirstOnce == 0 then	
		if self.TheSlowThing:IsValid() then
		self.DisableFirstOnce = 1
			if string.find(self.TheSlowThing:GetClass(), "prop_physics") or string.find(self.TheSlowThing:GetClass(), "prop_vehicle_*") then
				self.TheSlowThing:GetPhysicsObject():EnableGravity(true)
				self.TheSlowThing:GetPhysicsObject():Wake()

			end
				if string.find(self.TheSlowThing:GetClass(), "prop_ragdoll") then

					local bones = self.TheSlowThing:GetPhysicsObjectCount()

						for i=0,bones-1 do
							 self.TheSlowThing:GetPhysicsObjectNum(i):EnableGravity(true)
							self.TheSlowThing:GetPhysicsObjectNum(i):Wake()
						end 

				end

		end
	end
-------------

		return
			else	

		self.TheSlowThing = tr.Entity
		
		if self.TheSlowThing ~= self.AnotherSlowThing and self.AnotherSlowThing ~= NULL and self.DisableFirstOnce == 0 then
			self.DisableFirstOnce = 1
			if string.find(self.AnotherSlowThing:GetClass(), "prop_physics") or string.find(self.AnotherSlowThing:GetClass(), "prop_vehicle_*") then
				self.AnotherSlowThing:GetPhysicsObject():EnableGravity(true)
				self.AnotherSlowThing:GetPhysicsObject():Wake()
			end
				if string.find(self.AnotherSlowThing:GetClass(), "prop_ragdoll") then

					local bones = self.AnotherSlowThing:GetPhysicsObjectCount()

						for i=0,bones-1 do
							 self.AnotherSlowThing:GetPhysicsObjectNum(i):EnableGravity(true)
							self.AnotherSlowThing:GetPhysicsObjectNum(i):Wake()
						end 

				end
	
		end
	
			if self.TheSlowThing:IsNPC() and self.ApplyForceDel < CurTime() then
			self.ApplyForceDel = CurTime()+0.5
			local Korv = self.TheSlowThing:Health() - 10
			self.TheSlowThing:Fire("sethealth", ""..Korv.."", 0)
			end
		
		
			if string.find(self.TheSlowThing:GetClass(), "prop_physics") or string.find(self.TheSlowThing:GetClass(), "prop_vehicle_*")  and self.TheSlowThing:IsValid() and self.TheSlowThing ~= NULL and self.TheSlowThing ~= nil and self.TheSlowThing:IsPlayer() == false and self.ApplyForceDel < CurTime() then
				self.ApplyForceDel = CurTime()+0.5
					self.AnotherSlowThing = self.TheSlowThing	
					self.DisableFirstOnce = 0
					self.DisableSecOnce = 0
						local thing = self.TheSlowThing:GetPhysicsObject()			
						thing:EnableGravity(false)
						thing:SetVelocity( ((thing:GetVelocity())*0.95) )
						thing:AddAngleVelocity( ((thing:GetAngleVelocity())*-0.05) )
			end

			if self.TheSlowThing:IsValid() and string.find(self.TheSlowThing:GetClass(), "prop_ragdoll") then
					self.AnotherSlowThing = self.TheSlowThing	
				self.DisableFirstOnce = 0
				self.DisableSecOnce = 0
				local bones = self.TheSlowThing:GetPhysicsObjectCount()

					for i=0,bones-1 do
						 self.TheSlowThing:GetPhysicsObjectNum(i):EnableGravity(false)
						self.TheSlowThing:GetPhysicsObjectNum(i):SetVelocity( ((self.TheSlowThing:GetPhysicsObjectNum(i):GetVelocity())*0.95) )
					end 	
			
			
			
			end
		end
	end
	
end
----------------------------RELOAD
function SWEP:Reload()
	if self.RelDel < CurTime() and self.TimeNum ~= 0 then 

	
	if self.PlayRewind == 0 and self.TimeTravelDel < CurTime() then
	self.TimeTravelDel = CurTime() + 20	
	self.TimeTravel:Stop()
	self.TimeTravel:Play()
	end
	
	local RewLimit = self.TimeNumTwo - 80
	
		if self.TimeNum > RewLimit then
		self.RelDel = CurTime()+0.05
		self.Owner:SetPos(self.TimeSwap[self.TimeNum])
		self.Owner:SetEyeAngles(self.TimeSwapAng[self.TimeNum])
		self.Owner:SetVelocity(Vector(0,0,0)) 
		self.Owner:SetVelocity((self.Owner:GetVelocity()*-1)) 
--		self.Owner:SetVelocity(self.TimeSwapVel[self.TimeNum]) 
		self.Owner:Fire("sethealth", ""..self.TimeSwapVel[self.TimeNum].."", 0)
		 self.TimeNum =  self.TimeNum - 1

	local ef = EffectData()
	ef:SetOrigin(self.Owner:GetPos())
	util.Effect("TimeRev",ef)

		 
		end 

				 if self.TimeNum == RewLimit then
					self.TimeNum = 0
					self.TimeTravel:Stop()
				end

	end 

if self.TimeNum == 0 then
self.TimeTravel:Stop()
end	
	
	
end
----------------------------HOLSTER
function SWEP:Holster()
 self.HandSound :Stop()
 self.TimeTravel:Stop()

	if self.TheSlowThing ~= NULL and self.TheSlowThing ~= nil then	
		if self.TheSlowThing:IsValid() then

			if string.find(self.TheSlowThing:GetClass(), "prop_physics") or string.find(self.TheSlowThing:GetClass(), "prop_vehicle_*") then
				self.TheSlowThing:GetPhysicsObject():EnableGravity(true)
				self.TheSlowThing:GetPhysicsObject():Wake()
			end
				if string.find(self.TheSlowThing:GetClass(), "prop_ragdoll") then

					local bones = self.TheSlowThing:GetPhysicsObjectCount()

						for i=0,bones-1 do
							 self.TheSlowThing:GetPhysicsObjectNum(i):EnableGravity(true)
							self.TheSlowThing:GetPhysicsObjectNum(i):Wake()
						end 

				end

		end
	end
	
 self.TimeNum =  0
 self.TimeNumTwo = self.TimeNum
	
	return true
end
------------General Swep Info---------------
SWEP.Author   			= "Sakarias"
SWEP.Contact        	= ""
SWEP.Purpose        	= ""
SWEP.Instructions   	= "Create your future by modifying time"
SWEP.Spawnable      	= false
SWEP.AdminSpawnable 	= true
--------------------------------------------

------------Models---------------------------
SWEP.ViewModel = Model( "models/weapons/v_grenade.mdl" );
SWEP.WorldModel = Model( "models/weapons/w_grenade.mdl" );
---------------------------------------------
 
-------------Primary Fire Attributes----------------------------------------
SWEP.Primary.Delay				= 0.8
SWEP.Primary.Recoil				= 0
SWEP.Primary.Damage				= 0
SWEP.Primary.NumShots			= 0
SWEP.Primary.Cone				= 0	
SWEP.Primary.ClipSize			= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic   		= true
SWEP.Primary.Ammo         		= "none"
-------------------------------------------------------------------------------------

-------------Secondary Fire Attributes---------------------------------------

SWEP.Secondary.Delay			= 0.8
SWEP.Secondary.Recoil			= 0
SWEP.Secondary.Damage			= 0
SWEP.Secondary.NumShots			= 0
SWEP.Secondary.Cone		  		= 0
SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic   		= true
SWEP.Secondary.Ammo         	= "none"
-------------------------------------------------------------------------------------
