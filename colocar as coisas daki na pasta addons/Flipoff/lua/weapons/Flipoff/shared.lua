
SWEP.Author			= "TechedRonan"
SWEP.Purpose		= "Flip off NPCs or give them thumbs up"
SWEP.Instructions	= "Attack1: Thumb up \nAttack2: Flip off\nReload: Threat"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.ViewModel			= "models/weapons/v_swephands.mdl"
SWEP.WorldModel			= "models/weapons/W_stunbaton.mdl"
SWEP.HoldType			= "ar2" --this is for the world model holdtype
SWEP.Primary.Automatic		= false
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Think()
end

function SWEP:Think()
	local ply = self.Owner
	if(ply:KeyPressed( IN_RELOAD )) then
		if(self.Weapon.recentfire == false) or (self.Weapon.recentfire == nil) then

			self.Weapon:SendWeaponAnim(ACT_RANGE_ATTACK1_LOW)
			local ply = self.Owner
			local vStart = ply:GetShootPos()
			local vForward = ply:GetAimVector()

			local trace = {}
			trace.start = vStart
			trace.endpos = vStart + (vForward * 5000)
			trace.filter = ply

			local tr = util.TraceLine( trace )
			local ent = tr.Entity

			self.Weapon.recentfire = true
			timer.Simple(2, function() self.Weapon.recentfire = false  end)
			if( SERVER ) then
				if(ent:IsNPC()) then
           			 ent:AddEntityRelationship( ply, 2, 99 )
				end
			end
		end
	end
end


function SWEP:PrimaryAttack()
	self.Weapon:SendWeaponAnim(ACT_RANGE_ATTACK1)

	local ply = self.Owner
	local vStart = ply:GetShootPos()
	local vForward = ply:GetAimVector()

	local trace = {}
	trace.start = vStart
	trace.endpos = vStart + (vForward * 5000)
	trace.filter = ply

	local tr = util.TraceLine( trace )
	local ent = tr.Entity

	if( SERVER ) then
		if(ent:IsNPC()) then
			ent:AddEntityRelationship( ply, 1, 99 )
		end
	end

self.Weapon:SetNextPrimaryFire(CurTime() + 3)
end

function SWEP:SecondaryAttack( )
	self.Weapon:SendWeaponAnim(ACT_RANGE_ATTACK2)

	local ply = self.Owner
	local vStart = ply:GetShootPos()
	local vForward = ply:GetAimVector()

	local trace = {}
	trace.start = vStart
	trace.endpos = vStart + (vForward * 5000)
	trace.filter = ply

	local tr = util.TraceLine( trace )
	local ent = tr.Entity
	if( SERVER ) then
		if(ent:IsNPC()) then
			ent:AddEntityRelationship( ply, 3, 99 )
		end
	end


self.Weapon:SetNextSecondaryFire(CurTime() + 2)
end

