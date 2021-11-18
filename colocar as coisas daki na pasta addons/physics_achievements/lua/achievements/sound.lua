// Created by 1/4 Life using code from the Rushhour achievement.
// These achivements require Jinto's Physics Performance and Speed Settings module. You can download it below.
// http://forums.facepunchstudios.com/showthread.php?t=585848

local maxSpeed = achievements.GetValue( "Sound", "total", 0 )
local function CheckSpeed()
	local veh = LocalPlayer():GetVehicle()
	if ( !veh:IsValid() ) then return end
	local speed = math.floor( math.min( veh:GetVelocity():Length() / 17.6, 770 ) )

	if ( speed <= maxSpeed ) then return end
	
	achievements.Update( "Sound", speed / 770, speed .. "/770" )
	achievements.SetValue( "Sound", "total", speed )
	
	maxSpeed = speed
end
timer.Create( "Achievements.Sound", 1, 0, CheckSpeed )

achievements.Register( "Speed of Sound", "Hit the speed of sound inside of a vehicle.", "achievements/sound", maxSpeed / 770, maxSpeed .. "/770" )