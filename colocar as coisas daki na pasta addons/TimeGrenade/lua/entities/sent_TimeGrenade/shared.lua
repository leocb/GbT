ENT.Type = "anim"

ENT.Base = "base_gmodentity"

ENT.Spawnable = false

ENT.PrintName = "TimeGrenade"

ENT.Author = "Sakarias88"

ENT.AdminSpawnable = false

if(CLIENT)then

local function GasPPeffect(victim)
local victim = LocalPlayer()
local Var = victim:GetNetworkedFloat("TimeDist", Dist) 
local Yes = victim:GetNetworkedBool("TimeEffected")
local ShutDownOnce = victim:GetNetworkedBool("ShutDownTime")

if Var > 800 then Var = 800 end
Var = 800 - Var
Var = Var/800

if Yes == true then

victim:SetNetworkedBool("ShutDownTime", false)

local shit = Var*2
if shit > 1 then shit = 1 end

    local tab = {}
   tab[ "$pp_colour_addr" ] = 0
   tab[ "$pp_colour_addg" ] = 0
   tab[ "$pp_colour_addb" ] = 0
   tab[ "$pp_colour_brightness" ] = 0
   tab[ "$pp_colour_contrast" ] = 1
   tab[ "$pp_colour_colour" ] = 1-shit
   tab[ "$pp_colour_mulr" ] = 0
   tab[ "$pp_colour_mulg" ] = 0
   tab[ "$pp_colour_mulb" ] = 0  

   DrawColorModify( tab ) 

  DrawMotionBlur( 1-(0.8*Var), 1, (Var*4)/100 )
end

if Yes == false and ShutDownOnce ~= true then
victim:SetNetworkedBool("ShutDownTime", true)
    local tab = {}
   tab[ "$pp_colour_addr" ] = 0
   tab[ "$pp_colour_addg" ] = 0
   tab[ "$pp_colour_addb" ] = 0
   tab[ "$pp_colour_brightness" ] = 0
   tab[ "$pp_colour_contrast" ] = 1
   tab[ "$pp_colour_colour" ] = 1
   tab[ "$pp_colour_mulr" ] = 0
   tab[ "$pp_colour_mulg" ] = 0
   tab[ "$pp_colour_mulb" ] = 0  

   DrawColorModify( tab ) 

  DrawMotionBlur( 1, 0.8,0 )
end

end

	hook.Add("RenderScreenspaceEffects", "GasPPCol", GasPPeffect)
	
end