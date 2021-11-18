

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	ent = data:GetEntity()
	
	// Play headshot sound(s)
	if ( ent != NULL ) then
		// I frigging love this sound
		ent:EmitSound( "physics/flesh/flesh_bloody_break.wav" )
	end
	
	
	// Make Bloodstream effects
	for i= 0, 16 do
	
		local effectdata = EffectData()
			effectdata:SetOrigin( ent:GetPos() + i * Vector(0,0,4) )
			effectdata:SetNormal( data:GetNormal() )
		util.Effect( "bloodstream", effectdata )

		local effectdata2 = EffectData()
			effectdata:SetOrigin( ent:GetPos() + i * Vector(0,0,4) )
			effectdata:SetNormal( data:GetNormal() )
		util.Effect( "bloodstream", effectdata )

		local effectdata3 = EffectData()
			effectdata:SetOrigin( ent:GetPos() + i * Vector(0,0,4) )
			effectdata:SetNormal( data:GetNormal() )
		util.Effect( "bloodstream", effectdata )

		local effectdata4 = EffectData()
			effectdata:SetOrigin( ent:GetPos() + i * Vector(0,0,4) )
			effectdata:SetNormal( data:GetNormal() )
		util.Effect( "bloodstream", effectdata )

		local effectdata5 = EffectData()
			effectdata:SetOrigin( ent:GetPos() + i * Vector(0,0,4) )
			effectdata:SetNormal( data:GetNormal() )
		util.Effect( "bloodstream", effectdata )

	end
	
	for i = 0, 16 do


		local effectdata = EffectData()
			effectdata:SetOrigin( ent:GetPos() + i * Vector(0,0,4) + VectorRand() * 8 )
			effectdata:SetNormal( data:GetNormal() )
		util.Effect( "gib", effectdata )

		local effectdata2 = EffectData()
			effectdata2:SetOrigin( ent:GetPos() + i * Vector(0,0,4) + VectorRand() * 8 )
			effectdata2:SetNormal( data:GetNormal() )
		util.Effect( "gib", effectdata2 )

		local effectdata3 = EffectData()
			effectdata3:SetOrigin( ent:GetPos() + i * Vector(0,0,4) + VectorRand() * 8 )
			effectdata3:SetNormal( data:GetNormal() )
		util.Effect( "gib", effectdata3 )
	
end
end

/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

	// Die instantly
	return false
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	// Do nothing - this effect is only used to spawn the particles in Init
	
end



