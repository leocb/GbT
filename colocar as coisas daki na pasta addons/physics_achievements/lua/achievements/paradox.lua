// Created by 1/4 Life using code from the Rushhour achievement.
// These achivements require Jinto's Physics Performance and Speed Settings module. You can download it below.
// http://forums.facepunchstudios.com/showthread.php?t=585848

local maxSpeed = achievements.GetValue( "Paradox", "total", 0 )
local function CheckSpeed()
	local veh = LocalPlayer():GetVehicle()
	if ( !veh:IsValid() ) then return end
	local speed = math.floor( math.min( veh:GetVelocity():Length() / 17.6, 670616629 ) )

	if ( speed <= maxSpeed ) then return end
	
	achievements.Update( "Paradox", speed / 670616629, speed .. "/670616629" )
	achievements.SetValue( "Paradox", "total", speed )
	
	maxSpeed = speed
end
timer.Create( "Achievements.Paradox", 1, 0, CheckSpeed )

achievements.Register( "ParadoHSHI", "Hit the speed of light inside of a vehicle.", "achievements/paradox", maxSpeed / 670616629, maxSpeed .. "/670616629" )