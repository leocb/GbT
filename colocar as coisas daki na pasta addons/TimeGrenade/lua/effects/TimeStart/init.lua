function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()	
	self.Speed = data:GetMagnitude()

	self.Speed = self.Speed-4

	local emitter = ParticleEmitter( self.Position )
	local emittersed = ParticleEmitter( self.Position )
		
			local particle = emitter:Add( "Effects/strider_pinch_dudv", self.Position)

				particle:SetVelocity( Vector( 0, 0, 0))
				particle:SetDieTime(1)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(255)
				particle:SetStartSize(500)
				particle:SetEndSize(0)
				particle:SetRoll( math.Rand( -10,10  ) )
				particle:SetRollDelta(math.Rand( -2, 2 ))
				particle:SetColor( 0, 0, 0)			

	emitter:Finish()
		end


function EFFECT:Think( )
	return false	
end

function EFFECT:Render()

end



