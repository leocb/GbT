ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"

ENT.PrintName			= "MV Sound Emitter"
ENT.Author			= "MajorVictory"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions		= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

ENT.NullSound = Sound("common/NULL.WAV")
//not sure if this is defined elsewhere, so make it 'local'
ENT.TYPE_STRING 	= 0
ENT.TYPE_BOOL		= 1
ENT.TYPE_INT		= 2
ENT.TYPE_FLOAT		= 3
//AccessorFuncNW doesn't work on SENTs
//so i'll just make my own local one, with emulated constants :P
//Angle, Vector, and Color not included, do it yourself
function ENT:AccessorFuncENT( name, varname, varDefault, iType )
	iType = iType or self.TYPE_STRING

	if iType == self.TYPE_STRING then
		self["Set"..name] = function (self,v) self.Entity:SetNetworkedString(varname,tostring(v)) end
		self["Get"..name] = function (self,v) return self.Entity:GetNetworkedString(varname) or varDefault end
		return
	end
	if iType == self.TYPE_BOOL then
		self["Set"..name] = function (self,v) self.Entity:SetNetworkedBool(varname,tobool(v)) end
		self["Get"..name] = function (self,v) local ret=self.Entity:GetNetworkedBool(varname) if ret==nil then return varDefault end return ret end
		return
	end
	if iType == self.TYPE_INT then
		self["Set"..name] = function (self,v) self.Entity:SetNetworkedInt(varname,tonumber(v)) end
		self["Get"..name] = function (self,v) return self.Entity:GetNetworkedInt(varname) or varDefault end
		return
	end
	if iType == self.TYPE_FLOAT then
		self["Set"..name] = function (self,v) self.Entity:SetNetworkedFloat(varname,tonumber(v)) end
		self["Get"..name] = function (self,v) return self.Entity:GetNetworkedFloat(varname) or varDefault end
		return
	end
end

ENT:AccessorFuncENT( "InternalSound", "SoundFile", "common/NULL.WAV", ENT.TYPE_STRING )
ENT:AccessorFuncENT( "Length", "Length", -1, ENT.TYPE_FLOAT )
ENT:AccessorFuncENT( "Looping", "Looping", false, ENT.TYPE_BOOL )
ENT:AccessorFuncENT( "Delay", "Delay", 0, ENT.TYPE_FLOAT )
ENT:AccessorFuncENT( "Toggle", "Toggle", true, ENT.TYPE_BOOL )
ENT:AccessorFuncENT( "DamageActivate", "DamageActivate", false, ENT.TYPE_BOOL )
ENT:AccessorFuncENT( "DamageToggle", "DamageToggle", false, ENT.TYPE_BOOL )
ENT:AccessorFuncENT( "Volume", "Volume", 100, ENT.TYPE_FLOAT )
ENT:AccessorFuncENT( "Pitch", "Pitch", 100, ENT.TYPE_FLOAT )
ENT:AccessorFuncENT( "Key", "Key", false, ENT.TYPE_BOOL )
ENT:AccessorFuncENT( "On", "Active", false, ENT.TYPE_BOOL )

function ENT:SetSound( s )
	// Need to stop the old sound before updating.
	if self:GetOn() then self:StopEmit() end

	util.PrecacheSound( tostring(s) )
	self:SetInternalSound(s)
	self:UpdateSound()
end

function ENT:GetSound() return self:GetInternalSound() end

function ENT:UpdateSound()
	local CSound = Sound(self:GetSound())
	if CLIENT then return end
	self.MySound = CreateSound(self.Entity,CSound)
	self.MySound = self.MySound or CreateSound(self.Entity,self.NullSound)
end