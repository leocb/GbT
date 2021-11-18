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
		Ang = Angle(math.random(-180, 180),math.random(-180, 180),math.random(0, 180))
	end
	
	
	local Velocity 		= 80
	local Spread = math.random(30, 70) / 180
	local Number 		= 1
	local DieTime 		= math.random(1,3)
	local StartAlpha 	= 255
	local EndAlpha 		= 0
	local StartSize 	= math.random(10,15)
	local EndSize 		= 0
	local StartLength 	= 0
	local EndLength 	= 0
	local Roll 			= 20
	local RollDelta 	= 20
	local AirResistance	= 5
	local Bounce		= 0
	local Gravity		= -1500
	local Collide		= false
	local Lighting		= true
	local R				= 255
	local G				= 255
	local B				= 255
	local Material		= "decals/blood"..math.random(1,8)..""
	
	/*local _3D				= false
	local Align				= false
	local Stick				= false
	local AngleVelX			= 100
	local AngleVelY			= 100
	local AngleVelZ			= 100
	local StickLifeTime		= math.random(20, 35)
	local StickStartSize	= math.Rand(5, 15)
	local StickEndSize		= math.Rand(8, 16)
	local StickStartAlpha	= 255
	local StickEndAlpha		= 0
	*/
	
	local Emitter = ParticleEmitter(Pos)
		
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
		
		/*if (_3D) then
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
		end */
	end
		
	Emitter:Finish()
	
end


function EFFECT:Think( )

	return false
end


function EFFECT:Render()
end



