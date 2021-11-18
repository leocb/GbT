function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()	
	self.Speed = data:GetMagnitude()

	self.Speed = self.Speed-4

	local emitter = ParticleEmitter( self.Position )
	local emittersed = ParticleEmitter( self.Position )

		for i=1, 100 do	

local parpos = self.Position+Vector(math.Rand(-200,200),math.Rand(-200,200),math.Rand(-200,200))

 
		
			local particle = emitter:Add( "sprites/heatwave", parpos)



				particle:SetVelocity( Vector( 0, 0, 0))
				particle:SetDieTime(1)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(255)
				particle:SetStartSize(math.random(5, 10))
				particle:SetEndSize( math.random(5, 10) )
				particle:SetRoll( math.Rand( -10,10  ) )
				particle:SetRollDelta(math.Rand( -2, 2 ))
				particle:SetColor( 0, 200, 200)			
				particle:SetGravity( ((parpos - self.Position)*self.Speed))
--				particle:SetCollide( true )
		end			


	emitter:Finish()
		end


function EFFECT:Think( )
	return false	
end

function EFFECT:Render()

end



