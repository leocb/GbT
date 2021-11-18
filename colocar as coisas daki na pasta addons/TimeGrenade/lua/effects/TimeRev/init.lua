function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()	


	local emitter = ParticleEmitter( self.Position )
	local emittersed = ParticleEmitter( self.Position )
	
	for i=1,20 do

			local particle = emitter:Add( "Effects/strider_pinch_dudv", self.Position + Vector(	math.random( -20, 20 ),math.random( -20, 20 ),math.random( 0, 90 )) )	

				particle:SetVelocity( Vector( 0, 0, 0))
				particle:SetDieTime(2)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(255)
				particle:SetStartSize(math.random( 10, 50 ))
				particle:SetEndSize(0)
				particle:SetRoll( math.Rand( -10,10  ) )
				particle:SetRollDelta(math.Rand( -2, 2 ))
				particle:SetColor( 0, 0, 0)			

	emitter:Finish()
		end
end

function EFFECT:Think( )
	return false	
end

function EFFECT:Render()

end



