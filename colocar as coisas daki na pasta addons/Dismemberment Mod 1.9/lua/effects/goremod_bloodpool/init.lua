//decals/blood1 8

local function CollideCallback( Particle, HitPos, Normal )

	Particle:SetAngleVelocity( Particle.AngleVel )
	if (Particle.Align) then
		Particle:SetAngles( Normal:Angle() )
	end
	
	if (Particle.Stick) then
		Particle:SetVelocity( Vector( 0,0,0 ) )
		Particle:SetGravity( Vector( 0,0,0 ) )
	end
	
	Particle:SetLifeTime( 0 )
	Particle:SetDieTime( Particle.StickLifeTime )
	
	Particle:SetStartSize( Particle.StickStartSize )
	Particle:SetEndSize( Particle.StickEndSize )
	
	Particle:SetStartAlpha( Particle.StickStartAlpha )
	Particle:SetEndAlpha( Particle.StickEndAlpha )
end

function EFFECT:Init( Data )

	local Pos = Data:GetOrigin() + Vector(0,0,10)
	local Ent = Data:GetEntity()
	local Ang = 0
	if Ent:IsValid() then
		Ang = Ent:GetForward() + Angle(math.random(-10, 10),math.random(-10, 10),math.random(-10, 10))
		else
		Ang = Angle(math.random(-180, 180),math.random(-180, 180),math.random(-180, 180)) //If for whatever reason we don't have a valid killer, use random angles
	end
	
	// CLEAN THIS UP
	local Velocity 		= 150
	local Spread = math.random(30, 70) / 180
	local Number 		= 1
	local DieTime 		= 2
	local StartAlpha 	= 255
	local EndAlpha 		= 0
	local StartSize 	= 4
	local EndSize 		= 6
	local StartLength 	= 1
	local EndLength 	= 1
	local Roll 			= 50
	local RollDelta 	= 20
	local AirResistance	= 5
	local Bounce		= 1
	local Gravity		= -1500
	local Collide		= true
	local Lighting		= true
	local R				= 255
	local G				= 255
	local B				= 255
	local Material		= "decals/blood"..math.random(1,8)..""
	
	local _3D				= true
	local Align				= true
	local Stick				= true
	local AngleVelX			= 100
	local AngleVelY			= 100
	local AngleVelZ			= 100
	local StickLifeTime		= math.random(50, 60)
	local StickStartSize	= math.Rand(15, 25)
	local StickEndSize		= 0
	local StickStartAlpha	= 255
	local StickEndAlpha		= 0

	
	local Emitter = ParticleEmitter(Pos, true)
		
	for i = 1, Number do
		local P = Emitter:Add(Material, Pos)
		local Vec = Vector(math.Rand(-Spread, Spread), math.Rand(-Spread, Spread), math.Rand(-Spread, Spread))
		P:SetVelocity( (Vec + Ang) * Velocity )
		P:SetColor( R, G, B )
		P:SetDieTime( DieTime )
		P:SetStartAlpha( StartAlpha )
		P:SetEndAlpha( EndAlpha )
		P:SetStartSize( StartSize )
		P:SetEndSize( EndSize )
		P:SetStartLength( StartLength )
		P:SetEndLength( EndLength )
		P:SetRoll( Roll )
		P:SetRollDelta( RollDelta )
		P:SetAirResistance( AirResistance )
		P:SetBounce( Bounce )
		P:SetGravity( Vector(0, 0, Gravity) )
		P:SetCollide( Collide )
		P:SetLighting( Lighting )
		
		if (_3D) then
			P:SetCollideCallback( CollideCallback )
			P:SetAngleVelocity( Angle(100, 100, 0) )
			P.Align = Align
			P.Stick = Stick
			P.AngleVel = Angle(AngleVelX, AngleVelY, AngleVelZ)
			P.StickLifeTime = StickLifeTime
			P.StickStartSize = StickStartSize
			P.StickEndSize = StickEndSize
			P.StickStartAlpha = StickStartAlpha
			P.StickEndAlpha = StickEndAlpha
		end
	end
		
	Emitter:Finish()
	
end


function EFFECT:Think( )

	return false
end


function EFFECT:Render()
end



