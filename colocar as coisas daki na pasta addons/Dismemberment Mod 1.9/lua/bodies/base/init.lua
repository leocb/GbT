function BODY:Init(npc)
	
	for i=0,self:GetPhysicsObjectCount()-1 do
	
		local bone = self:TranslatePhysBoneToBone(i)
		
		self:SetNWBool("Decapped"..bone,false)
	end
	
	umsg.Start("GoreMod_AddFunc")
		umsg.Entity(self)
	umsg.End()
end

function BODY:TakeDamage(inf,attacker,dmginfo)
	
end

function BODY:Think()

end