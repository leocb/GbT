function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()	
	self.Speed = data:GetMagnitude()

	self.Speed = self.Speed-4

	local emitter = ParticleEmitter( self.Position )
	local emittersed = ParticleEmitter( self.Position )



 
		
			local particle = emitter:Add( "Effects/strider_pinch_dudv", self.Position)



				particle:SetVelocity( Vector( 0, 0, 0))
				particle:SetDieTime(2)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(255)
				particle:SetStartSize(400)
				particle:SetEndSize(0)
				particle:SetRoll( math.Rand( -10,10  ) )
				particle:SetRollDelta(math.Rand( -2, 2 ))
				particle:SetColor( 0, 0, 0)			
--				particle:SetGravity( ((parpos - self.Position)*self.Speed))
--				particle:SetCollide( true )
	
			local particle2 = emitter:Add( "Effects/bluemuzzle", self.Position)

				particle2:SetVelocity( Vector( 0, 0, 0))
				particle2:SetDieTime(1)
				particle2:SetStartAlpha(200)
				particle2:SetEndAlpha(0)
				particle2:SetStartSize(300)
				particle2:SetEndSize(0)
				particle2:SetRoll( 20 )
				particle2:SetRollDelta(5)
				particle2:SetColor( 255, 0, 0, 255)	
--				particle2:SetGravity( ((parpos - self.Position)*self.Speed))
--				particle2:SetCollide( true )

	emitter:Finish()
		end


function EFFECT:Think( )
	return false	
end

function EFFECT:Render()

end



