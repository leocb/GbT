function EFFECT:Init(data)

	self.Created = CurTime()
	self.Scale = data:GetScale() || 1
	self.Ent = data:GetEntity()
	
	if (!ValidEntity(self.Ent)) then
	
		return
	end
	
	self.Bone = data:GetAttachment() || 0
	
	self.Emitter = ParticleEmitter(Vector(),true)
	
	self.Particles = {}
end

local function ParticleCollideThink(Particle)
	
	if (!Particle.Emitter) then
			
		Particle:SetEndSize(0)
		Particle:SetEndAlpha(0)
		return
	end
	
	local Ent = Particle.Ent
	
	if (!ValidEntity(Ent)) then
			
		Particle:SetEndSize(0)
		Particle:SetEndAlpha(0)
		return
	end
	
	local EntPos = Ent:GetPos()
	local ParticlePos = Pos
	
	EntPos.z = 0
	ParticlePos.z = 0
	
	if (EntPos:Distance(ParticlePos) > 40) then
	
		Particle:SetEndSize(0)
		Particle:setEndAlpha(0)
		return
	end
end

local function ParticleCollide(Particle,Pos,Norm)

	/*Particle:SetDieTime(0)
		
	util.Decal("Impact.Flesh",Pos + Norm,Pos - Norm)*/
	
	local Ang = Norm:Angle()
		
	if (Ang.Roll == 0 && Ang.Pitch == 270) then
		
		Ang.Yaw = math.random(0,359)
	end
		
	Particle:SetThinkFunction(ParticleCollideThink)
	Particle:SetAngleVelocity(Angle(0,0,0))
	Particle:SetAngles(Ang)
	Particle:SetVelocity(Vector(0,0,0))
	Particle:SetGravity(Vector(0,0,0))
	Particle:SetPos(Pos + Norm)
	Particle:SetDieTime(math.random(2000,4000))
	Particle:SetEndSize(math.random(1,2))
end

local function ParticleThink(Particle)

	Particle:SetAngles(Particle:GetVelocity():GetNormalized():Angle())
end

function EFFECT:Think()

	if (!ValidEntity(self.Ent) || self.Ent:GetNWBool("Decapped"..self.Bone,false)) then
	
		if (self.Emitter) then
					
			self.Emitter:Finish()
		end
		
		self:Remove()
		
		return false
	end
	
	local Time = CurTime()
	
	local Compare = math.Round(math.random(self.Created,Time))
	local Compare2 = math.Round(math.random(self.Created,Time))
						
	if (FrameTime() > 0 && Compare == Compare2) then
				
		local Pos,Ang = self.Ent:GetBonePosition(self.Bone)
					
		local Particle = self.Emitter:Add("effects/blood_puff",Pos)
		
		Particle.Emitter = self.Emitter
		Particle.Ent = self.Ent
		
		Particle:SetVelocity(Ang:Forward() * math.Rand(10,10 + math.Clamp(50 - Time + self.Created,1,50)) + VectorRand() * math.random(-10,10))
		
		Particle:SetStartSize(2)
		Particle:SetEndSize(math.random(7,14))
		
		Particle:SetRoll(math.random(-80,80))
		Particle:SetRollDelta(.4)
		
		Particle:SetAngles(Angle(math.random(0,359),math.random(0,359),math.random(0,359)))
		Particle:SetAngleVelocity(Angle(math.random(-100,100),math.random(-100,100),math.random(-100,100)))
		
		Particle:SetStartAlpha(math.random(240,250))
		Particle:SetEndAlpha(math.random(200,220))
		
		Particle:SetStartLength(1)
		Particle:SetEndLength(5)
		
		Particle:SetThinkFunction(ParticleThink)
		
		Particle:SetColor(math.random(230,255),math.random(230,255),0)
		
		Particle:SetLifeTime(0)
		Particle:SetDieTime(math.random(2,4))
		
		//Particle:SetLighting(true)
		
		Particle:SetBounce(0)
		
		Particle:SetCollide(true)
		
		Particle:SetCollideCallback(ParticleCollide)
		
		Particle:SetGravity(Vector(0,0,-600))
		
		table.insert(self.Particles,Particle)
	end
		
	if (self.Created + self.Scale < CurTime()) then
	
		for Particle_Index,Particle in pairs(self.Particles) do
		
			Particle:SetEndAlpha(0)
			Particle:SetEndSize(0)
			Particle:SetDieTime(math.min(Particle:GetDieTime(),math.random(2000,2500)))
		end
		
		self.Emitter:Finish()
		
		self:Remove()
		
		return false
	end
	
	return true
end

function EFFECT:Render()

end