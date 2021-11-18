function EFFECT:Init(data)

	local Pos = data:GetOrigin()
	
	self.LifeTime = CurTime() + math.random(5,10)
	
	local Count = table.Count(gib_models)
	
	local Model = gib_models[math.random(1,Count)]
	
	if (!util.IsValidModel(Model)) then
	
		self.LifeTime = 0
		return 
	end
	
	self:SetModel(Model)
	self:SetMaterial("models/flesh")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetPos(Pos)
	
	self:SetSolid(SOLID_VPHYSICS)
	
	self:SetMoveType(MOVETYPE_VPHYSICS)
	
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	self:SetCollisionBounds(Vector(-128,-128,-128),Vector(128,128,128))
	self:SetRenderBounds(Vector(-128,-128,-128),Vector(128,128,128))
	
	local Phys = self:GetPhysicsObject()
	
	if (ValidEntity(Phys)) then
	
		Phys:Wake()
		Phys:SetAngle(Angle(math.Rand(0,359),math.Rand(0,359),math.Rand(0,359)))
		Phys:SetVelocity(VectorRand() * math.random(-100,100))
		Phys:SetMaterial("zombieflesh")
	end
end

function EFFECT:Think()

	local Pos = self:GetPos()
	local Phys = self:GetPhysicsObject()
	
	if (!ValidEntity(Phys)) then
	
		return false
	end
	
	local Vel = Phys:GetVelocity()
		
	/*if (Vel:Length() < 10) then
		
		return true
	end*/
		
	Vel:Normalize()
		
	local tr = util.TraceLine{start = Pos,endpos = Pos + Vel * 5,filter = self}
			
	if (!tr.Hit) then
			
		return true
	end
	
	util.Decal("Impact.Flesh",tr.HitPos + tr.HitNormal,tr.HitPos - tr.HitNormal)
	
	local BloodEffect = EffectData()
		BloodEffect:SetOrigin(self:GetPos())
	util.Effect("BloodImpact",BloodEffect)
		
	if (self.LifeTime < CurTime()) then
	
		self:Remove()
		return false
	end
end

function EFFECT:Render()

	self:DrawModel()
end