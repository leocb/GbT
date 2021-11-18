function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()	
	self.Speed = data:GetMagnitude()

	self.Speed = self.Speed-4

	local emitter = ParticleEmitter( self.Position )
	local emittersed = ParticleEmitter( self.Position )

		for i=1, 100 do	

local parpos = self.Position

 
		
			local particle = emitter:Add( "Effects/bluemuzzle", parpos)



				particle:SetVelocity( Vector(math.random(-100,100),math.random(-100,100), math.random(-100, 100))*self.Speed )
				particle:SetLifeTime(0)
				particle:SetDieTime(1)
				particle:SetStartAlpha(math.random(100, 255))
				particle:SetEndAlpha(0)
				particle:SetStartSize( math.random(10, 20))
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand(0,50 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( 255, 0, 0)
				particle:VelocityDecay( false )		
		end			


	emitter:Finish()
		end


function EFFECT:Think( )
	return false	
end

function EFFECT:Render()

end



