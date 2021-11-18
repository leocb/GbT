
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:UpdateInputs()
	if not (WireAddon) then return end
	
	local Owner = self.Entity:GetVar("Founder")
	local Inputs = {}
	Inputs[1] = "Fire"
	
	for _,v in pairs(ParticleOptions) do
		if (v.Type != "String") then
			if (Owner) and (Owner:GetInfoNum("particle_wire_" .. v.Name) == 1) then
				Inputs[#Inputs+1] = v.Name
			end
		end
	end
	
	self.Inputs = Wire_CreateInputs(self.Entity, Inputs)
end

function ENT:Initialize()
	self.Entity:SetModel("models/items/combine_rifle_ammo01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Entity:DrawShadow(true)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	local Phys = self.Entity:GetPhysicsObject()
	if (Phys:IsValid()) then
		Phys:Wake()
		Phys:SetMass(5)
	end
	
	self.Firing = false
	
	self:UpdateInputs()
end

function ENT:OnRemove()
	if (WireAddon) then 
		Wire_Remove(self.Entity)
	end
end

function ENT:TriggerInput(Name, Value)
	if (Name == "Fire") then
		local Ent = self:GetTable()
		
		if (Value != 0) then
			Ent:SetOn(true)
			self.Entity:SetNetworkedBool("WireActivated", true)
		elseif (Value == 0) then
			Ent:SetOn(false)
			self.Entity:SetNetworkedBool("WireActivated", false)
		end
	else
		for _,v in pairs(ParticleOptions) do
			if (Name == v.Name) then
				if not (SinglePlayer()) and (util.tobool(GetConVarNumber("particle_Clamp"))) then
					-- Clamp stuff in multiplayer.. because people are idiots T_T
					Value = math.Clamp(Value, v.Min, v.Max)
				end
				
				if (v.Type == "Bool") then
					Value = util.tobool(Value)
				end
				
				self:SetData({{Name = v.Name, Type = v.Type, Value = Value}})
			end
		end
	end
end


function ENT:SetToggle(b)
	self.Toggle = b or false
end

function ENT:GetToggle()
	return self.Toggle
end

function ENT:SetOn(b)
	self.Firing = b
	self.Entity:SetNetworkedBool("Activated", b)
	
	if (b) then
		self:FireShot()
	end
end

function ENT:GetOn()
	return self.Firing
end

function ENT:SetDelay(f)
	self.Delay = f
	self.Entity:SetNetworkedFloat("Delay", f)
end

function ENT:GetDelay()
	return self.Delay
end

function ENT:SetNumber(i)
	self.Entity:SetNetworkedInt("Number", i)
end

function ENT:SetVelocity(f)
	self.Entity:SetNetworkedFloat("Velocity", f)
end

function ENT:SetSpread(f)
	self.Entity:SetNetworkedFloat("Spread", f)
end

function ENT:SetDieTime(f)
	self.Entity:SetNetworkedFloat("DieTime", f)
end

function ENT:SetStartAlpha(f)
	self.Entity:SetNetworkedFloat("StartAlpha", f)
end

function ENT:SetEndAlpha(f)
	self.Entity:SetNetworkedFloat("EndAlpha", f)
end

function ENT:SetStartSize(f)
	self.Entity:SetNetworkedFloat("StartSize", f)
end

function ENT:SetEndSize(f)
	self.Entity:SetNetworkedFloat("EndSize", f)
end

function ENT:SetStartLength(f)
	self.Entity:SetNetworkedFloat("StartLength", f)
end

function ENT:SetEndLength(f)
	self.Entity:SetNetworkedFloat("EndLength", f)
end

function ENT:SetRoll(f)
	self.Entity:SetNetworkedFloat("Roll", f)
end

function ENT:SetRollDelta(f)
	self.Entity:SetNetworkedFloat("RollDelta", f)
end

function ENT:SetAirResistance(f)
	self.Entity:SetNetworkedFloat("AirResistance", f)
end

function ENT:SetBounce(f)
	self.Entity:SetNetworkedFloat("Bounce", f)
end


function ENT:SetGravity(f)
	self.Entity:SetNetworkedFloat("Gravity", f)
end

function ENT:SetCollide(b)
	self.Entity:SetNetworkedBool("Collide", b)
end

function ENT:SetLighting(b)
	self.Entity:SetNetworkedBool("Lighting", b)
end

function ENT:SetSliding(b)
	self.Entity:SetNetworkedBool("Sliding", b)
end


function ENT:SetColor1(r, g, b)
	self.Entity:SetNetworkedInt("R1", r)
	self.Entity:SetNetworkedInt("G1", g)
	self.Entity:SetNetworkedInt("B1", b)
end

function ENT:SetColor2(r, g, b)
	self.Entity:SetNetworkedInt("R2", r)
	self.Entity:SetNetworkedInt("G2", g)
	self.Entity:SetNetworkedInt("B2", b)
end

function ENT:SetRandom(b)
	self.Entity:SetNetworkedBool("Random", b)
end

function ENT:SetMaterial(mat)
	self.Entity:SetNetworkedString("Material", mat)
end


function ENT:Set3D(b)
	self.Entity:SetNetworkedBool("3D", b)
	self.Entity["3D"] = b
end

function ENT:SetAlign(b)
	self.Entity:SetNetworkedBool("Align", b)
end

function ENT:SetStick(b)
	self.Entity:SetNetworkedBool("Stick", b)
end

function ENT:SetDoubleSided(b)
	self.Entity:SetNetworkedBool("DoubleSided", b)
end

function ENT:SetAngleVel(x, y, z)
	self.Entity:SetNetworkedFloat("AngleVelX", x)
	self.Entity:SetNetworkedFloat("AngleVelY", y)
	self.Entity:SetNetworkedFloat("AngleVelZ", z)
end

function ENT:SetStickLifeTime(f)
	self.Entity:SetNetworkedFloat("StickLifeTime", f)
end

function ENT:SetStickStartSize(f)
	self.Entity:SetNetworkedFloat("StickStartSize", f)
end

function ENT:SetStickEndSize(f)
	self.Entity:SetNetworkedFloat("StickEndSize", f)
end

function ENT:SetStickStartAlpha(f)
	self.Entity:SetNetworkedFloat("StickStartAlpha", f)
end

function ENT:SetStickEndAlpha(f)
	self.Entity:SetNetworkedFloat("StickEndAlpha", f)
end

function ENT:FireShot()
	
	local Pos = self.Entity:GetPos()
	Pos = Pos + self.Entity:GetUp() * 4
	
	local Ply = self.Entity:GetNetworkedEntity("Player")
	if (Ply != NULL) then
		Pos = Ply:GetShootPos()
	end
	
	// Make the effects
	local Effect = EffectData()
		Effect:SetOrigin(Pos)
		Effect:SetEntity(self.Entity)
	util.Effect("particle_custom", Effect)
	
end


/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage(Dmginfo)
	self.Entity:TakePhysicsDamage(Dmginfo)
end

/*---------------------------------------------------------
   Numpad control functions
   These are layed out like this so it'll all get saved properly
---------------------------------------------------------*/

local function On(Ply, Ent)
	if (not Ent) or (Ent == NULL) then return end
	local EntTable = Ent:GetTable()
	
	if (EntTable:GetToggle()) then
		EntTable:SetOn(not EntTable:GetOn())
	else
		EntTable:SetOn(true)
	end
end

local function Off(Ply, Ent)
	if (not Ent) or (Ent == NULL) then return end
	local EntTable = Ent:GetTable()
	
	if (EntTable:GetToggle()) then return end
	EntTable:SetOn(false)
end


numpad.Register("Particles_On", On)
numpad.Register("Particles_Off", Off)