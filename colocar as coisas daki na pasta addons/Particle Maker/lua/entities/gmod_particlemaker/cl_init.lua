
include('shared.lua')

ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.RenderGroup 		= RENDERGROUP_OPAQUE

function ENT:Initialize()
	self.Entity.NextShot = CurTime()
	self.Entity.Delay = CurTime() + 0.04
end

function ENT:GetOverlayText()
	
	if (self.Entity:GetNetworkedEntity("Player") == NULL) then
		return self:GetPlayerName()
	else
		return ""
	end
	
end

function ENT:Draw()
	
	
	if (self.Entity:GetNetworkedEntity("Player") == NULL) and (self.Entity.Delay < CurTime()) then
		
		if (LocalPlayer():GetEyeTrace().Entity == self.Entity) and (EyePos():Distance(self.Entity:GetPos()) < 512) then
			self:DrawEntityOutline(1)
			
			if (self:GetOverlayText() != "") then
				AddWorldTip(self.Entity:EntIndex(), self:GetOverlayText(), 0.5, self.Entity:GetPos(), self.Entity)
			end
		end
		
		self.Entity:DrawModel()
	end
	
end

local Status = {}
local function ParticleMakerReady(UM)
	Status = {}
	
	Status.Trace = UM:ReadBool()
	Status["3D"] = UM:ReadBool()
	Status.Gun = UM:ReadBool()
	Status.Player = UM:ReadEntity()
	
	Status.Ready = true
end
usermessage.Hook("ParticleMakerReady", ParticleMakerReady)


function ENT:Think()
	if (Status.Ready) and not (self.Entity.Ready) then
		self.Entity.Trace = Status.Trace
		self.Entity["3D"] = Status["3D"]
		self.Entity.Gun = Status.Gun
		self.Entity.Player = Status.Player
		self.Entity.Ready = true
		
		Status = {}
	end
	

	if (not self.Entity.Spawned) and (self.Entity.Player) and (self.Entity.Player == LocalPlayer()) then
		local Effect = EffectData()
			Effect:SetOrigin( LocalPlayer():GetShootPos() )
			Effect:SetEntity( self.Entity )
		util.Effect( "particle_custom", Effect )
		
		self.Entity.Spawned = true
	end
	
	if (self.Entity:GetNetworkedBool("WireActivated")) and (not self.Entity.WireSpawned) then
		local Pos = self.Entity:GetPos() + self.Entity:GetUp() * 4
		local Effect = EffectData()
			Effect:SetOrigin( Pos )
			Effect:SetEntity( self.Entity )
		util.Effect( "particle_custom", Effect )
		
		self.Entity.WireSpawned = true
	elseif (not (self.Entity:GetNetworkedBool("WireActivated"))) and (self.Entity.WireSpawned) then
		self.Entity.WireSpawned = nil
	end
	
end
