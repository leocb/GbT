
function Strip( ply, ent )
	ply:StripWeapons()
end
AntiNoClip_RegisterAction( "Strip Weapons", Strip )