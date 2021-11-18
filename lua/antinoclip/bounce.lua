
local function Bounce( ply, ent )
	ply:SetVelocity( ply:GetVelocity():GetNormal() * -2000 )
end
AntiNoClip_RegisterAction( "Bounce", Bounce )
