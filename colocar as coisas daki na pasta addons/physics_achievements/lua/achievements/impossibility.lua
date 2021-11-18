// Created by 1/4 Life using code from the Rushhour achievement.
// These achivements require Jinto's Physics Performance and Speed Settings module. You can download it below.
// http://forums.facepunchstudios.com/showthread.php?t=585848

local maxSpeed = achievements.GetValue( "Impossibility", "total", 0 )
local function CheckSpeed()
	local veh = LocalPlayer():GetVehicle()
	if ( !veh:IsValid() ) then return end
	local speed = math.floor( math.min( veh:GetVelocity():Length() / 17.6, 114 ) )

	if ( speed <= maxSpeed ) then return end
	
	achievements.Update( "Impossibility", speed / 114, speed .. "/114" )
	achievements.SetValue( "Impossibility", "total", speed )
	
	maxSpeed = speed
end
timer.Create( "Achievements.Impossibility", 1, 0, CheckSpeed )

achievements.Register( "Impossibility", "Beat the Source Engine's 113 MPH speed limit inside of a vehicle.", "achievements/impossibility", maxSpeed / 114, maxSpeed .. "/114" )