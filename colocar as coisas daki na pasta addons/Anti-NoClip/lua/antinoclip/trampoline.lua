
function Trampoline( ply, ent )
	ply:SetVelocity( Vector( 0, 0, 2000 ) )
end
AntiNoClip_RegisterAction( "Trampoline", Trampoline )