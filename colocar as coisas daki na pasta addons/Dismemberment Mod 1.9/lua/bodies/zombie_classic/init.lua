function BODY:Init(npc)

	self.LastThink = CurTime()

	self:SetColor(npc:GetColor())
	
	if (!npc:IsOnFire()) then
	
		return
	end
	
	self:Ignite(math.random(50,100))

end

function BODY:TakeDamage(inf,attacker,dmginfo)
	
	local amount = dmginfo:GetDamage()
	local dmgpos = dmginfo:GetDamagePosition()
		
	if (amount >= 50) then
			
		local effectdata = EffectData()
			effectdata:SetOrigin(dmgpos)
		util.Effect("BloodImpact",effectdata)
		
		local norm = self:GetVelocity():GetNormalized()
		
		norm:Normalize()
		
		util.Decal("Blood",dmgpos + norm,dmgpos - norm)
		
		local phys = self:GetPhysicsObject()
		
		local physbone = self:ClosestPhysBone(dmgpos)
		
		local bone = self:TranslatePhysBoneToBone(physbone)
		
		if (!self:GetNWBool("Decapped"..bone,false) && (amount >= 75 || dmginfo:IsExplosionDamage())) then
									
			self:Gib(physbone)
			
			local has_limbs = false
		
			local body_type = self:GetBT()
			
			local bone_table = BoneInfo[body_type]
			
			if (bone_table) then
		
				for i=0,self:GetPhysicsObjectCount()-1 do
				
					local bone = self:TranslatePhysBoneToBone(i)
					
					local should_gib = false
									
					for child_bone,parent_bone in pairs(bone_table) do
					
						if (child_bone == bone) then
						
							should_gib = true
							break
						end
					end
					
					if (should_gib) then
					
						if (!self:GetNWBool("Decapped"..bone,true)) then
						
							has_limbs = true
							break
						end
					end
				end
			end
			
			if (!has_limbs) then
			
				local pos = self:GetPos()
										
				self:Remove()
				
				WorldSound("physics/flesh/flesh_bloody_break.wav",pos,100,100)
						
				for i=0,5 do
				
					local gib_effect = EffectData()
						gib_effect:SetOrigin(pos)
					util.Effect("goremod_gib",gib_effect)
					
					for j=0,3 do
					
						local blood_effect = EffectData()
							blood_effect:SetOrigin(pos + VectorRand() * j * 5)
						util.Effect("BloodImpact",blood_effect)
					end
				end
				
				return
			end	
		end
	end
end

function BODY:Think()

	if (!self:IsOnFire() || self.LastThink + .1 > CurTime()) then
		
		return
	end
	
	self.LastThink = CurTime()
	
	local R,G,B,A = self:GetColor()
	
	R = math.Clamp(R-1,0,255)
	G = math.Clamp(G-1,0,255)
	B = math.Clamp(B-1,0,255)
	
	self:SetColor(R,G,B,A)
	
	if (R + G + B > 3) then
	
		return 
	end
	
	self:Extinguish()
	self.Ignite = function(self,Time,Scale) end
end