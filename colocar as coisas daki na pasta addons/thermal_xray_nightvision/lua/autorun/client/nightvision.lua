-- Clientside Night-Vision
-- Version 1.2
-- by Teta_Bonita

-- console commands:
-- toggle_nightvision			-toggles nightvision on/off


if not CLIENT then return end -- Clientside only

-- ADJUSTABLE SETTINGS

local AdjustCoefficient = 0.02 -- The bigger this number, the more quickly the nightvision starts up

-- Colormod Settings
local Color_Brightness		= 0.8
local Color_Contrast 		= 1.1
local Color_AddGreen		= -0.35
local Color_MultiplyGreen 	= 0.028


-- Alpha Add Settings (for the CSS nightvision shader)
local AlphaAdd_Alpha 			= 1
local AlphaAdd_Passes			= 1 -- The bigger this integer, the more brightness is added
									-- alpha add = AlphaAdd_Alpha*AlphaAdd_Passes
									
-- Bloom Settings
local Bloom_Multiply		= 3.6
local Bloom_Darken 			= 0
local Bloom_Blur			= 0.1
local Bloom_ColorMul 		= 0.5
local Bloom_Passes			= 1 -- Should be an integer

-- END ADJUSTABLE SETTINGS

local matNightVision = Material("effects/nightvision") -- CSS nightvision
matNightVision:SetMaterialFloat( "$alpha", AlphaAdd_Alpha )

local Color_Tab = 
{
	[ "$pp_colour_addr" ] 		= -1,
	[ "$pp_colour_addg" ] 		= Color_AddGreen,
	[ "$pp_colour_addb" ] 		= -1,
	[ "$pp_colour_brightness" ] = Color_Brightness,
	[ "$pp_colour_contrast" ]	= Color_Contrast,
	[ "$pp_colour_colour" ] 	= 0,
	[ "$pp_colour_mulr" ] 		= 0 ,
	[ "$pp_colour_mulg" ] 		= Color_MultiplyGreen,
	[ "$pp_colour_mulb" ] 		= 0
}

local sndOn = Sound( "items/nvg_on.wav" )
local sndOff = Sound( "items/nvg_off.wav" )

if render.GetDXLevel() < 80 then -- the nightvision shader reverts to  a white overlay for dx7 cards, so any more alpha add than 1 gives a white screen
	AlphaAdd_Passes			= 1
	AlphaAdd_Alpha 			= 0.6 -- Make it less to reduce the whiteness
end

local DoNightVision = false
local CurScale = 0.5

-- A most likely futile attempt to make things faster
local render = render


-- Main effect call
local function NightVisionFX() 

	if CurScale < 0.995 then 
		CurScale = CurScale + AdjustCoefficient * (1 - CurScale)
	end
	
	-- Alpha add			
	for i=1,AlphaAdd_Passes do
	
		render.UpdateScreenEffectTexture()
	 	render.SetMaterial( matNightVision )
	 	render.DrawScreenQuad()
		
	end
	
	-- Colormod
	Color_Tab[ "$pp_colour_brightness" ] = CurScale * Color_Brightness
	Color_Tab[ "$pp_colour_contrast" ] = CurScale * Color_Contrast
	
	DrawColorModify( Color_Tab )
	
	-- Bloom
	DrawBloom(	Bloom_Darken,  					-- Darken
 				CurScale * Bloom_Multiply,		-- Multiply
 				Bloom_Blur, 					-- Horizontal Blur
 				Bloom_Blur, 					-- Vertical Blur
 				Bloom_Passes, 					-- Passes
 				CurScale * Bloom_ColorMul, 		-- Color Multiplier
 				0, 								-- Red
 				1, 								-- Green
 				0 ) 							-- Blue
end


local function ToggleNightVision()
 
    if DoNightVision then
	
		DoNightVision = false
		surface.PlaySound( sndOff )
	
		hook.Remove( "RenderScreenspaceEffects", "NV_Render" )
		
	else
	
		DoNightVision = true
		CurScale = 0.5 -- This makes the nightvision start off dark when it's turned back on (for effect)
		surface.PlaySound( sndOn )
	
		hook.Add( "RenderScreenspaceEffects", "NV_Render", NightVisionFX )
		
	end
	
end
concommand.Add( "toggle_nightvision", ToggleNightVision )
