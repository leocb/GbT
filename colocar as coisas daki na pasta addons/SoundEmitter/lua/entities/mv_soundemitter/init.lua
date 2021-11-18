AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetUseType( SIMPLE_USE )

	self:SetOn(false)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then phys:Wake() end
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )
	if self:GetDamageActivate() then
		if self:GetDamageToggle() then
			self:ToggleSound()
		elseif !self:GetOn() then
			self:PreEmit()
		end
	end
end

/*---------------------------------------------------------
   Name: OnRemove
---------------------------------------------------------*/
function ENT:OnRemove()
	self:StopEmit()
end


/*---------------------------------------------------------
   Name: Emit Functions
---------------------------------------------------------*/
function ENT:StartEmit()
	self.MySound:PlayEx(self:GetVolume(),self:GetPitch())
	local length = self:GetLength()
	if length > 0 then
		local entindex = self.Entity:EntIndex()
		if self:GetLooping() then
			timer.Create("SoundPlay_"..entindex,length,9999,self.StartEmit,self)
		else
			timer.Create("SoundStop_"..entindex,length,1,self.StopEmit,self)
		end
	end
end

function ENT:PreEmit()
	if self:GetOn() then self:StopEmit() end
	self:SetOn( true )
	local delay = self:GetDelay()
	if delay > 0 then
		local entindex = self.Entity:EntIndex()
		timer.Create("SoundStart_"..entindex,delay,1,self.StartEmit,self)
		return true
	end
	self:StartEmit()
	return true
end

function ENT:StopEmit()
	self:SetOn( false )
	self:ClearTimers()
	if self.MySound then self.MySound:Stop() end
end

function ENT:ToggleSound()
	if self:GetOn() then
		self:StopEmit()
	else
		self:PreEmit()
	end
end

function ENT:ClearTimers()
	local entindex = self.Entity:EntIndex()
	timer.Destroy("SoundStart_"..entindex)
	timer.Destroy("SoundPlay_"..entindex)
	timer.Destroy("SoundStop_"..entindex)
	timer.Destroy("EnableUse_"..entindex)
end

function ENT:Use( activator, caller )
	if self:GetToggle() then
		self:ToggleSound()
		return true
	end

	self:PreEmit()
	return true
end


/*---------------------------------------------------------
   Numpad control functions
   These are layed out like this so it'll all get saved properly
---------------------------------------------------------*/
local function Down( pl, ent )
	if (!ent:IsValid()) then return false end

	local ENT = ent:GetTable()

	if ENT:GetToggle() then
		ENT:ToggleSound()
		return true
	end

	ENT:PreEmit()
	return true
end

local function Up( pl, ent )
	if (!ent:IsValid()) then return false end

	local ENT = ent:GetTable()

	if ENT:GetToggle() then return true end

	ENT:StopEmit()
	return true
end

numpad.Register( "mv_soundemitter_Down", Down )
numpad.Register( "mv_soundemitter_Up", Up )