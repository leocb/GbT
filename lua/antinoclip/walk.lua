
function Walk( ply, ent )
	ply:SetPos( ply:GetPos() + ( ply:GetVelocity():GetNormal() * -40 ) )
	ply:SetMoveType( MOVETYPE_WALK )
end
AntiNoClip_RegisterAction( "Walk", Walk )