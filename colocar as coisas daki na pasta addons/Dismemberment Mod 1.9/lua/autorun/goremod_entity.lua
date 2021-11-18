local meta = _R["Entity"]

function meta:SetBT(bt)

	self:SetNWString("GoreMod_BodyType",bt)
end

function meta:GetBT()

	return self:GetNWString("GoreMod_BodyType","")
end

function meta:Decap(bone)

	local bone = bone || 0
	local body_type = self:GetBT()
	
	local bone_table = BoneInfo[body_type]
	
	if (!bone_table) then
	
		return
	end
	
	local should_decap = false
	
	for child_bone,parent_bone in pairs(bone_table) do
	
		if (parent_bone == bone) then
								
			for i=0,self:GetPhysicsObjectCount()-1 do
			
				if (self:TranslatePhysBoneToBone(i) == child_bone) then
				
					self:Gib(i)
				end
			end
		end
		
		if (child_bone == bone) then
		
			should_decap = true
			
			local Effect = EffectData()
				Effect:SetScale(math.random(100,300))
				Effect:SetEntity(self)
				Effect:SetAttachment(parent_bone)
			util.Effect("goremod_bloodspurt",Effect)
		end
	end
	
	if (!should_decap) then
	
		return
	end
	
	self:SetNWBool("Decapped"..bone,true)
end

function meta:ClosestPhysBone(pos)

	local closest_distance = -1
	local closest_bone = -1
	
	for i=0,self:GetPhysicsObjectCount()-1 do
	
		local bone = self:TranslatePhysBoneToBone(i)
		
		if (bone && !self:GetNWBool("Decapped"..bone,false)) then
	
			local phys = self:GetPhysicsObjectNum(i)
			
			if (ValidEntity(phys)) then
			
				local phys_pos = phys:GetPos()
				
				local phys_distance = phys_pos:Distance(pos)
				
				if (phys_distance < closest_distance || closest_distance == -1) then
				
					closest_distance = phys_distance
					closest_bone = i
				end
			end
		end
	end
	
	return closest_bone
end

gib_models = {

	"models/props_junk/watermelon01_chunk02a.mdl",
	"models/Gibs/HGIBS_scapula.mdl"
}

for gib_index,gib_model in pairs(gib_models) do

	util.PrecacheModel(gib_model)
end

function meta:Gib(physbone)

	self:Decap(self:TranslatePhysBoneToBone(physbone))
	local phys = self:GetPhysicsObjectNum(physbone)
	
	if (ValidEntity(phys)) then
	
		phys:EnableCollisions(false)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		local pos = phys:GetPos()
		local mass = phys:GetMass()
		phys:SetMass(1)
						
		for i=0,math.Round(mass/6) do
		
			local gib_effect = EffectData()
				gib_effect:SetOrigin(pos + VectorRand() * i)
			util.Effect("goremod_gib",gib_effect)
		end
						
		local blood_effect = EffectData()
			blood_effect:SetOrigin(pos + VectorRand() * math.random(3,5))
		util.Effect("BloodImpact",blood_effect)
	end
end
	
function meta:GibAlien(physbone)

	self:DecapAlien(self:TranslatePhysBoneToBone(physbone))
	local phys = self:GetPhysicsObjectNum(physbone)
	
	if (ValidEntity(phys)) then
	
		phys:EnableCollisions(false)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		local pos = phys:GetPos()
		local mass = phys:GetMass()
		phys:SetMass(1)
				
		for i=0,math.Round(mass/math.random(3,7)) do
		
			local gib_effect = EffectData()
				gib_effect:SetOrigin(pos + VectorRand() * i)
			util.Effect("goremod_gib_alien",gib_effect)
		end
						
		local blood_effect = EffectData()
			blood_effect:SetOrigin(pos + VectorRand() * math.random(3,5))
		util.Effect("AntlionGib",blood_effect)
	end
end	

function meta:DecapAlien(bone)

	local bone = bone || 0
	local body_type = self:GetBT()
	
	local bone_table = BoneInfo[body_type]
	
	if (!bone_table) then
	
		return
	end
	
	local should_decap = false
	
	for child_bone,parent_bone in pairs(bone_table) do
	
		if (parent_bone == bone) then
		
			for i=0,self:GetPhysicsObjectCount()-1 do
			
				if (self:TranslatePhysBoneToBone(i) == child_bone) then
				
					self:GibAlien(i)
				end
			end
		end
		
		if (child_bone == bone) then
		
			should_decap = true
			
			local Effect = EffectData()
				Effect:SetScale(math.random(100,300))
				Effect:SetEntity(self)
				Effect:SetAttachment(parent_bone)
			util.Effect("goremod_bloodspurt_alien",Effect)
		end
	end
	
	if (!should_decap) then
	
		return
	end
	
	self:SetNWBool("Decapped"..bone,true)
end