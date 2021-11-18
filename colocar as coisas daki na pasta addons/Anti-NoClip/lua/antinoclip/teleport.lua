
function Teleport( ply, ent )
	local spawn = gamemode.Call( "PlayerSelectSpawn", ply )
	if ( spawn && spawn:IsValid() ) then
		ply:SetPos( spawn:GetPos() )
	end
end
AntiNoClip_RegisterAction( "Teleport To Spawn", Teleport )