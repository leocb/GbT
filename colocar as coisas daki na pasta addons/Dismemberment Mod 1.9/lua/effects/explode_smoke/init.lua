function EFFECT:Init( data )
       
        self.Particles = {}
        self.ParticleCount = 15;
        self.ParticleLiveTime = 4;
        self.Length = 50;
        self.Color = {120,120,120}
        self.Origin = data:GetOrigin()
        self.speed = 2;
        for i=1,10 do
            local randomVec = Vector(math.Rand(-35,35),math.Rand(-35,35),math.Rand(-35,35))
            local CPos = self.Origin + randomVec
            local emitter = ParticleEmitter( CPos )
            local particle = emitter:Add( "particles/smokey", CPos )
                particle:SetVelocity( Vector(0,0,0) )
                particle:SetDieTime( self.ParticleLiveTime )
                particle:SetStartAlpha( math.Rand( 50, 150 ) )
                particle:SetStartSize( math.Rand( 36, 42 ) )
                particle:SetRoll( 10 )
                particle:SetColor( self.Color[1], self.Color[2], self.Color[3] )
            emitter:Finish()
        end
       
        for particle = 1,self.ParticleCount do
           
            local ParticleDir = VectorRand();
           
            local Parray = {};
            Parray.Vel = ParticleDir * self.speed;
            Parray.Pos = self.Origin
            Parray.isDead = false
           
            table.insert( self.Particles, Parray );
           
        end
       
        for i=0, self.Length do
            for k,v in pairs( self.Particles ) do
                local trace = {}
                    trace.start     = v.Pos
                    trace.endpos    = v.Pos + v.Vel
                    trace.mask = MASK_NPCWORLDSTATIC
                local tr = util.TraceLine( trace )
                   
                if (tr.Hit or v.isDead) then v.isDead = true
                else
                v.Pos = v.Pos + v.Vel
               
                local emitter = ParticleEmitter( v.Pos )
                local particle = emitter:Add( "particles/smokey", v.Pos )
                    particle:SetVelocity( Vector(0,0,0) )
                    particle:SetDieTime( self.ParticleLiveTime )
                    particle:SetStartAlpha( math.Rand( 50, 150 ) )
                    if ((0.2 * i) > 1) then
                        particle:SetStartSize( math.Rand( 16, 32 )/(0.25 * i) )
                    else
                        particle:SetStartSize( math.Rand( 16, 32 ))
                    end
                    particle:SetRoll( 10 )
                    particle:SetColor( self.Color[1], self.Color[2], self.Color[3] )
                emitter:Finish()
                       
                v.Vel:Sub( Vector( 0, 0, 0.05 ) )
                end
            end
        end
    end
   
    function EFFECT:Think( )
        return false
    end
   
    function EFFECT:Render()   
    end 