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
	Particle:SetEndSize(math.random(4,8))
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
		
		Particle:SetColor(50,0,0)
		
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



local BloodSprite = Material( "effects/bloodstream" )

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )

		// Table to hold particles
		self.Particles = {}
		
		self.PlaybackSpeed 	= math.Rand( 2, 5 )
		self.Width 			= math.Rand( 4, 16 )
		self.ParCount		= 500
		
		local Dir = VectorRand() * 0.5 + data:GetNormal() * 0.5
		
		local Speed = math.Rand( 100, 1000 )
		
		local SquirtDelay = math.Rand( 3, 5 )
		
		Dir.z = math.max( Dir.z, Dir.z * -1 )
		if (Dir.z > 0.5) then
			Dir.z = Dir.z - 0.3
		end
		
		for i=1, math.random( 4, 8 ) do
		
			Dir = Dir * 0.95 + VectorRand() * 0.02
		
			local p = {}
			
				p.Pos = data:GetOrigin()
				p.Vel = Dir * (Speed * (i /40))
				p.Delay = (10 - i)  * SquirtDelay
				p.Rest = false
			
			table.insert( self.Particles, p )
		
		end

		self.NextThink = CurTime() +  math.Rand( 0, 1 )
	
end


local function VectorMin( v1, v2 )
	
	if ( v1 == nil ) then return v2 end
	if ( v2 == nil ) then return v1 end
	
	local vr = Vector( v2.x, v2.y, v2.z )
	
	if ( v1.x < v2.x ) then vr.x = v1.x end
	if ( v1.y < v2.y ) then vr.y = v1.y end
	if ( v1.z < v2.z ) then vr.z = v1.z end
	
	return vr

end

local function VectorMax( v1, v2 )
	
	if ( v1 == nil ) then return v2 end
	if ( v2 == nil ) then return v1 end
	
	local vr = Vector( v2.x, v2.y, v2.z )
	
	if ( v1.x > v2.x ) then vr.x = v1.x end
	if ( v1.y > v2.y ) then vr.y = v1.y end
	if ( v1.z > v2.z ) then vr.z = v1.z end
	
	return vr

end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	//if ( self.NextThink > CurTime() ) then return true end

	local FrameSpeed = self.PlaybackSpeed * FrameTime()
	
	local bMoved = false
	local min = self.Entity:GetPos()
	local max = min
	
	self.Width = self.Width - 0.1 * FrameSpeed
	if ( self.Width < 0 ) then
		return false
	end
	
	for k, p in pairs( self.Particles ) do
	
			if ( p.Rest ) then
									
			// Waiting to be spawned. Some particles have an initial delay 
			// to give a stream effect..
			elseif ( p.Delay > 0 ) then
			
				p.Delay = p.Delay - 100 * FrameSpeed
			
			// Normal movement code. Handling particles in Lua isn't great for 
			// performance but since this is clientside and only happening sometimes
			// for short periods - it should be fine.
			else
				
				// Gravity
				p.Vel:Sub( Vector( 0, 0, 30 * FrameSpeed ) )
				
				// Air resistance
				p.Vel.x = math.Approach( p.Vel.x, 0, 2 * FrameSpeed )
				p.Vel.y = math.Approach( p.Vel.y, 0, 2 * FrameSpeed )
				
				local trace = {}
				trace.start 	= p.Pos
				trace.endpos 	= p.Pos + p.Vel * FrameSpeed
				trace.mask 		= MASK_NPCWORLDSTATIC
				local tr = util.TraceLine( trace )

				if (tr.Hit) then
								
					tr.HitPos:Add( tr.HitNormal * 2 )
					
					local effectdata = EffectData()
						effectdata:SetOrigin( tr.HitPos )
						effectdata:SetNormal( tr.HitNormal )
					util.Effect( "bloodsplash", effectdata )
					
					// If we hit the ceiling just stunt the vertical velocity
					// else enter a rested state
					if ( tr.HitNormal.z < -0.75 ) then
					
						p.Vel.z = 0
					
					else
					
						p.Rest = true
					
					end
		
				end
				
				// Add velocity to position
				p.Pos = tr.HitPos
				bMoved = true
			
			end
			
	end
	
	self.ParCount = table.Count( self.Particles )
	
	
	// I really need to make a better/faster way to do this
	if (bMoved) then
	
		for k, p in pairs( self.Particles ) do
		
			min = VectorMin( min, p.Pos )
			max = VectorMax( max, p.Pos )
			
		end

		local Pos = min + ((max - min) * 0.5)
		self.Entity:SetPos( Pos )
		self.Entity:SetCollisionBounds( Pos - min, Pos - max )
	end
	
	
	// Returning false kills the effect
	return (self.ParCount > 0)
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	render.SetMaterial( BloodSprite )
	
	local LastPos = nil
	local pCount = 0
	
	// I don't know what kind of performance hit this gives us..
	local LightColor = render.GetLightColor( self.Entity:GetPos() ) * 255
		LightColor.r = math.Clamp( LightColor.r, 70, 255 )
	local color = Color( LightColor.r*0.5, 0, 0, 255 )

	for k, p in pairs( self.Particles ) do
	
		local Sin = math.sin( (pCount / (self.ParCount-2)) * math.pi )
		
		if ( LastPos ) then
		
			render.DrawBeam( LastPos, 		
					 p.Pos,
					 self.Width * Sin,					
					 1,					
					 0,				
					 color )
		
		end
		
		pCount = pCount + 1
		LastPos = p.Pos
	
	end
	
	
	//render.DrawSprite( self.Entity:GetPos(), 32, 32, color_white )
	
end


