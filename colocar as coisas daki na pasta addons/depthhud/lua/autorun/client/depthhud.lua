/*
Depth HUD:
  modified by Hurricaaane with Night-Eagle permission
  http://www.youtube.com/user/Hurricaaane

ORIGINAL HUD:
  Eagle Predator Heads-Up Display
  Version 1.3
  © Night-Eagle 2007
  gmail sedhdi
  
Access the options of Depth HUD in:
    Q Menu > Options Tab > Depth HUD
Disable the HUD in some gamemodes:
    Type in the console:
    depthhud_disable 1
	Or go in the Depth HUD panel.
*/




depthhud = {}
depthhud.maxammo = {}
depthhud.shownames = true
depthhud.lastang = Angle(0,0,0)

depthhud.healthdeltaend = CurTime()
depthhud.healthdelta = 0
depthhud.prevalive = 0
depthhud.prevhealth = 0
depthhud.armordeltaend = CurTime()
depthhud.armordelta = 0
depthhud.prevarmor = 0
depthhud.pinglasttime = CurTime()
depthhud.realping = 0
depthhud.ping = 0
depthhud.allpings = 0

depthhud.disable = CreateClientConVar("depthhud_disable","0",false,false)
depthhud.units = {
	MPH = {
			63360 / 3600,
			"MPH",
		},
	["KM/H"] = {
			39370.0787 / 3600,
			"KM/H",
		},
	}
depthhud.unit = CreateClientConVar("depthhud_unit","MPH",true,false)
depthhud.hudlag = CreateClientConVar("depthhud_hudlag","0.4",true,false)
depthhud.reportseconds = CreateClientConVar("depthhud_reportseconds","1.4",true,false)
depthhud.hourformat = CreateClientConVar("depthhud_hourformat","1",true,false) //Is the hourformat 24h?
depthhud.showping = CreateClientConVar("depthhud_showping","1",true,false)
depthhud.healthisteam = CreateClientConVar("depthhud_healthisteam","0",true,false)

depthhud.globalr = CreateClientConVar("depthhud_global_r","255",true,false)
depthhud.globalg = CreateClientConVar("depthhud_global_g","220",true,false)
depthhud.globalb = CreateClientConVar("depthhud_global_b","0",true,false)

surface.CreateFont("halflife2", 36, 2, 0, 0, "hl2num" )
surface.CreateFont("halflife2", 20, 2, 0, 0, "hl2numsmall" )
surface.CreateFont("DIN Light", 36, 2, 0, 0, "textlarge" )
surface.CreateFont("DIN Light", 24, 2, 0, 0, "textmedium" )
surface.CreateFont("DIN Light", 16, 2, 0, 0, "textsmall" )
surface.CreateFont("DIN Medium", 24, 2, 0, 0, "compasscard" )

function depthhud.load()
	function depthhud.draw()
		if depthhud.disable:GetInt() >= 1 then
			return false
		end
	
		//Start get vars

		//EHUD Compat
		local SWEP = LocalPlayer():GetActiveWeapon()
		local val = {}
		val.crx = .5*ScrW()
		val.cry = .5*ScrH()
		if SWEP:IsValid() then
			val.clip1type = SWEP:GetPrimaryAmmoType() or ""
			val.clip1 = tonumber(SWEP:Clip1()) or -1
			val.clip1left = LocalPlayer():GetAmmoCount(val.clip1type)
			val.clip2type = SWEP:GetSecondaryAmmoType() or ""
			val.clip2 = tonumber(SWEP:Clip2()) or 0
			val.clip2left = LocalPlayer():GetAmmoCount(val.clip2type)
		else
			val.clip1 = -1
			val.clip1left = -1
			val.clip2 = -1
			val.clip2left = -1
		end
		if not depthhud.maxammo[SWEP] then
			depthhud.maxammo[SWEP] = val.clip1
		elseif val.clip1 > depthhud.maxammo[SWEP] then
			depthhud.maxammo[SWEP] = val.clip1
		end
		
		val.clip1max = tonumber(depthhud.maxammo[SWEP]) or 1
		
		if SWEP:IsValid() then
			for k,v in pairs(SWEP:GetTable().huddata or {}) do
				val[k] = v
			end
		end
		
		//EHUD Compass
		// Compass
		val.pitch = LocalPlayer():EyeAngles()
		val.pitch, val.yaw, val.roll = LocalPlayer():EyeAngles().p, LocalPlayer():EyeAngles().y, LocalPlayer():EyeAngles().r
		
		//Vehicle
		if LocalPlayer():InVehicle() then
			local veh = LocalPlayer():GetVehicle()
			local vang = veh:EyeAngles()
			val.pitch, val.yaw, val.roll = val.pitch + vang.pitch, val.yaw + vang.yaw, val.roll + vang.roll
			
			val.vehicle = 1
			val.vehiclespeed = veh:GetVelocity():Length()
		else
			val.vehicle = 0
			val.vehiclespeed = -1
		end
		
		//Range finder
		//do
		//	local trace = util.TraceLine({
		//		start = LocalPlayer():GetShootPos(),
		//		endpos = LocalPlayer():GetShootPos() + LocalPlayer():EyeAngles():Forward() * 40960,
		//		filter = LocalPlayer()
		//		})
		//	val.distance = trace.Fraction * 40960
		//end
		
		//Colors
		local tcol = team.GetColor(LocalPlayer():Team())
		local cglobalr = depthhud.globalr:GetInt()
		local cglobalg = depthhud.globalg:GetInt()
		local cglobalb = depthhud.globalb:GetInt()
		
		//Hourclock
		depthhud.timemanage = {}
		depthhud.timemanage.date = os.date("*t")
		depthhud.timemanage.ampm = ""
		if not(depthhud.hourformat:GetInt() >= 1) then
			if depthhud.timemanage.date.hour < 12 then
				depthhud.timemanage.ampm = "AM"
			else
				depthhud.timemanage.ampm = "PM"
			end
			depthhud.timemanage.date.hour = ((depthhud.timemanage.date.hour-1)%12)+1
		end
		
		if depthhud.timemanage.date.min < 10 then 
			depthhud.timemanage.date.min = "0"..depthhud.timemanage.date.min
		end
		if depthhud.timemanage.date.sec < 10 then 
			depthhud.timemanage.date.sec = "0"..depthhud.timemanage.date.sec
		end
		depthhud.hourclock = depthhud.timemanage.date.hour..":"..depthhud.timemanage.date.min..":"..depthhud.timemanage.date.sec.." "..depthhud.timemanage.ampm
		
		//Ping
		
		if not(SinglePlayer()) and depthhud.showping:GetInt() >= 1 then
			depthhud.realping = LocalPlayer():Ping()
			depthhud.ping = math.floor(depthhud.ping + (depthhud.realping-depthhud.ping)/2)
			//*(CurTime()-depthhud.pinglasttime))/2+depthhud.ping)
			depthhud.pinglasttime = CurTime()
		end
		
		
		
		//End get vars
		--'
		//Draw the HUD and get more vars
		
		
		
		
		
		//HUD lag
		local hl = {}
		hl.la = depthhud.lastang
		hl.ca = LocalPlayer():EyeAngles()
		
		if hl.la.y < -90 and hl.ca.y > 90 then
			hl.la.y = hl.la.y + 360
		elseif hl.la.y > 90 and hl.ca.y < -90 then
			hl.la.y = hl.la.y - 360
		end
		
		local hudlagcustom = depthhud.hudlag:GetFloat()
		hl.x = (hl.ca.y - hl.la.y)*3*hudlagcustom
		hl.y = (hl.la.p - hl.ca.p)*3*hudlagcustom
		hl.nm = .1
		hl.na = Angle((hl.ca.p*hl.nm+hl.la.p)/(hl.nm+1),(hl.ca.y*hl.nm+hl.la.y)/(hl.nm+1))
		depthhud.lastang = hl.na

		//Left		
		local var

		local vcolor
		//Health
		var = math.Clamp(LocalPlayer():Health(),0,100)
			

		draw.RoundedBox(8,16+hl.x, ScrH()-64+hl.y, 92, 48, Color(0, 0, 0, 92))
		
		//Health DELTA
		if depthhud.prevhealth != LocalPlayer():Health() then
			depthhud.healthdeltaend = CurTime() + depthhud.reportseconds:GetFloat()
			depthhud.healthdelta = LocalPlayer():Health() - depthhud.prevhealth + depthhud.healthdelta
		end
		if CurTime() >= depthhud.healthdeltaend then
			depthhud.healthdelta = 0
		//elseif depthhud.healthdelta > 0 && depthhud.prevhealth <= 0 then
		elseif LocalPlayer():Alive() == 1 && depthhud.prevalive == 0 then
			depthhud.healthdelta = 0
		elseif depthhud.healthdelta != 0 then
			local signed
			if depthhud.healthdelta < 0 then
				vcolor = Color(255,128,128,255*((depthhud.healthdeltaend-CurTime())/depthhud.reportseconds:GetFloat())^0.5)
				signed = depthhud.healthdelta
			else
				signed = "+"..depthhud.healthdelta
				vcolor = Color(128,255,128,255*((depthhud.healthdeltaend-CurTime())/depthhud.reportseconds:GetFloat())^0.5)
			end
			draw.DrawText(signed,"textlarge",80+hl.x*5,ScrH()-84+hl.y*5,vcolor,1)
		end

		//Regular health
		if depthhud.healthisteam:GetInt() >= 1 then
			vcolor = Color(tcol.r,tcol.g,tcol.b,92)
		else
			vcolor = Color(cglobalr*var/100+255*(100-var)/100,cglobalg*var/100,cglobalb*var/100,92)
			//vcolor = Color(255,220*var/100,0,92)
		end
		draw.RoundedBox(8,24+hl.x*1.5, ScrH()-56+hl.y*1.5,32,32,vcolor)

		if LocalPlayer():Health() <=25 then
			vcolor = Color(255,0,0,255)
		else
			vcolor = Color(cglobalr,cglobalg,cglobalb,255)
		end
		draw.DrawText(LocalPlayer():Health(),"hl2num",80+hl.x*1.25,ScrH()-60+hl.y*1.25,vcolor,1)
		
		//Health DELTA 2
		depthhud.prevhealth = LocalPlayer():Health()
		
		//Armor
		var = math.Clamp(LocalPlayer():Armor(),0,100)
		
		if var != 0 then
			draw.RoundedBox(8,124+hl.x, ScrH()-64+hl.y, 92, 48, Color(0, 0, 0, 92))
			
			vcolor = Color(128*var/100,128+64*var/100,255,127+128*var/100)
			draw.RoundedBox(8,132+hl.x*1.5, ScrH()-56+hl.y*1.5,32,32,vcolor)
			draw.DrawText(LocalPlayer():Armor(),"hl2num",188+hl.x*1.25,ScrH()-60+hl.y*1.25,vcolor,1)
		end
		
		//Armor DELTA
		if depthhud.prevarmor != LocalPlayer():Armor() then
			depthhud.armordeltaend = CurTime() + depthhud.reportseconds:GetFloat()
			depthhud.armordelta = LocalPlayer():Armor() - depthhud.prevarmor + depthhud.armordelta
		end
		if CurTime() >= depthhud.armordeltaend then
			depthhud.armordelta = 0
		elseif LocalPlayer():Alive() == 1 && depthhud.prevalive == 0 then
			depthhud.armordelta = 0
		elseif depthhud.armordelta != 0 then
			local signed
			if depthhud.armordelta < 0 then
				vcolor = Color(0,92,192,255*((depthhud.armordeltaend-CurTime())/depthhud.reportseconds:GetFloat())^0.5)
				signed = depthhud.armordelta
			else
				signed = "+"..depthhud.armordelta
				vcolor = Color(128,192,255,255*((depthhud.armordeltaend-CurTime())/depthhud.reportseconds:GetFloat())^0.5)
			end
			draw.DrawText(signed,"textlarge",188+hl.x*5,ScrH()-84+hl.y*5,vcolor,1)
		end
		
		//Armor DELTA 2
		depthhud.prevarmor = LocalPlayer():Armor()
		
		//PREVALIVE DELTA
		depthhud.prevalive = LocalPlayer():Alive()
		
		
		//Right
		if LocalPlayer():Alive() then
		
			//Secondary Ammo			
			if val.clip2left > 0 then
				draw.RoundedBox(8,ScrW()-108+hl.x, ScrH()-122+hl.y, 92, 48, Color(0, 0, 0, 92))
				vcolor = Color(cglobalr,cglobalg,cglobalb,92*(CurTime()%0.5)*2)
				draw.RoundedBox(8,ScrW()-56+hl.x*1.5,ScrH()-114+hl.y*1.5,32,32,vcolor)
				vcolor = Color(cglobalr,cglobalg,cglobalb,255)
				draw.DrawText(val.clip2left,"hl2num",ScrW()-80+hl.x*1.25,ScrH()-118+hl.y*1.25,vcolor,1)
			end
			
			//Primary Ammo		
			if val.clip1 > 0 then
				vcolor = Color(cglobalr,cglobalg,cglobalb,92)
				local boxround = 8
				if val.clip1/val.clip1max <= 0.75 && val.clip1/val.clip1max > 0.5 then
					boxround = 6
				end
				if val.clip1/val.clip1max <= 0.5 && val.clip1/val.clip1max > 0.25 then
					boxround = 4
				end
				if val.clip1/val.clip1max <= 0.25 then
					boxround = 0
				end
				draw.RoundedBox(boxround,ScrW()-56+16*(1-(val.clip1/val.clip1max))+hl.x*1.5,ScrH()-56+16*(1-(val.clip1/val.clip1max))+hl.y*1.5,32*(val.clip1/val.clip1max),32*(val.clip1/val.clip1max),vcolor)
			end
			
			
			if val.clip1 >= 0 and val.clip1type ~= -1 then
				draw.RoundedBox(8,ScrW()-108+hl.x, ScrH()-64+hl.y, 92, 48, Color(0, 0, 0, 92))
				
				if val.clip1 <= 0 then
					vcolor = Color(255,0,0,255)
				else
					vcolor = Color(cglobalr,cglobalg,cglobalb,255)
				end
				draw.DrawText(val.clip1,"hl2num",ScrW()-80+hl.x*1.25,ScrH()-60+hl.y*1.25,vcolor,1)
				if val.clip1 == 0 then
					vcolor = Color(255,0,0,92*(CurTime()%0.5)*2)
					draw.RoundedBox(8,ScrW()-56+hl.x*1.5,ScrH()-56+hl.y*1.5,32,32,vcolor)
				end
				if val.clip1left > 0 then
					vcolor = Color(cglobalr,cglobalg,cglobalb,255)
					draw.DrawText(val.clip1left,"hl2numsmall",ScrW()-80+hl.x*1.25,ScrH()-32+hl.y*1.25,vcolor,1)
				end
			elseif val.clip1left > 0 then
				draw.RoundedBox(8,ScrW()-108+hl.x, ScrH()-64+hl.y, 92, 48, Color(0, 0, 0, 92))
				
				vcolor = Color(cglobalr,cglobalg,cglobalb,92*(CurTime()%0.5)*2)
				draw.RoundedBox(8,ScrW()-56+hl.x*1.5,ScrH()-56+hl.y*1.5,32,32,vcolor)
				vcolor = Color(cglobalr,cglobalg,cglobalb,255)
				draw.DrawText(val.clip1left,"hl2num",ScrW()-80+hl.x*1.25,ScrH()-60+hl.y*1.25,vcolor,1)
			end
			
		end
		
		//Compass and environment
		draw.RoundedBox(8,ScrW()/2-98+hl.x,48+hl.y,196,38,Color(0, 0, 0, 92))
		
		local points = {
			[0] = "Y+",
			[45] = "|",
			[90] = "X+",
			[135] = "|",
			[180] = "Y-",
			[225] = "|",
			[270] = "X-",
			[315] = "|",
			}
		for i = 0,359,15 do
			if not points[i] then
				points[i] = ""
			end
		end
		
		local ox = ScrW()*.5
		local oy = ScrH()*.5
		for k,v in pairs(points) do
			if math.sin((val.yaw+k)/180*math.pi) > 0 then
				local text
				local alphaformula
				local color
				
				if type(v) ~= "table" then
					text = v
					alphaformula = math.Clamp(1-math.abs(math.cos((val.yaw+k)/180*math.pi)),0,1)
					color = Color(cglobalr,cglobalg,cglobalb,255*alphaformula)
				else
					text = v[1]
					color = v[2]
				end
				if k == 90 then
					color = Color(255,0,0,255*alphaformula)
				end
				if k == 270 then
					color = Color(255,0,0,255*alphaformula)
				end
				if k == 0 then
					color = Color(0,255,0,255*alphaformula)
				end
				if k == 180 then
					color = Color(0,255,0,255*alphaformula)
				end
				draw.DrawText(tostring(text),"textsmall",-92*math.cos((val.yaw+k)/180*math.pi)+hl.x+ScrW()/2,hl.y+68+0.6*hl.y*math.sin((val.yaw+k)/180*math.pi),color,1)
			end
		end

		local pointscard = {
			[0] = "N",
			[45] = "NE",
			[90] = "E",
			[135] = "SE",
			[180] = "S",
			[225] = "SW",
			[270] = "W",
			[315] = "NW",
			}

		for i = 0,359,15 do
			if not pointscard[i] then
				pointscard[i] = "."
			end
		end
		
		for k,v in pairs(pointscard) do
			if math.sin((val.yaw+k)/180*math.pi) > 0 then
				local text
				local color
				
				if type(v) ~= "table" then
					text = v
					local alphaformula = math.Clamp(1-math.abs(math.cos((val.yaw+k)/180*math.pi)),0,1)
					color = Color(cglobalr,cglobalg,cglobalb,255*alphaformula)
				else
					text = v[1]
					color = v[2]
				end

				draw.DrawText(tostring(text),"compasscard",-92*math.cos((val.yaw+k)/180*math.pi)+hl.x*1.25+ScrW()/2,hl.y+48+0.6*hl.y*math.sin((val.yaw+k)/180*math.pi),color,1)
			end
		end



		//Vehicle Speedometer
		if val.vehicle == 1 then
			local unit = depthhud.unit:GetString()
			if not depthhud.units[unit] then
				unit = "MPH"
			end
			local conv = depthhud.units[unit][1]
			local speed = val.vehiclespeed/conv
			local speedf = val.vehiclespeed/conv/113
			speedf = val.vehiclespeed/2000
			
			local boxround = 8
			if speedf <= 0.75 && speedf > 0.5 then
				boxround = 6
			end
			if speedf <= 0.5 && speedf > 0.25 then
				boxround = 4
			end
			if speedf <= 0.25 then
				boxround = 0
			end
			draw.RoundedBox(8,ScrW()-108+hl.x,16+hl.y, 92, 48, Color(0, 0, 0, 92))
			vcolor = Color(cglobalr,cglobalg,cglobalb,92)			
			draw.RoundedBox(boxround,ScrW()-56+16*(1-(speedf))+hl.x*1.5,24+16*(1-(speedf))+hl.y*1.5,32*(speedf),32*(speedf),vcolor)
			vcolor = Color(cglobalr,cglobalg,cglobalb,255)		
			draw.DrawText(math.Round(speed),"hl2num",ScrW()-80+hl.x*1.25,20+hl.y*1.25,vcolor,1)
			draw.DrawText(depthhud.units[unit][2],"textsmall",ScrW()-80+hl.x*1.25,48+hl.y*1.25,vcolor,1)
		end

		//Hourclock and FPS
		draw.RoundedBox(8,ScrW()/2-64+hl.x,8+hl.y,128,32,Color(0, 0, 0, 92))
		
		local efps = math.Clamp(math.floor((1/FrameTime()+0.05))/100,0,1)
		draw.RoundedBox(8,ScrW()/2-60*efps+hl.x*1.5,12+hl.y*1.5,120*efps,24,Color(cglobalr,cglobalg,cglobalb,92))
		
		draw.DrawText(depthhud.hourclock,"textmedium",hl.x*1.25+ScrW()/2,hl.y*1.25+12,Color(cglobalr,cglobalg,cglobalb,255),1)
		
		//Ping
		if not(SinglePlayer()) and depthhud.showping:GetInt() >= 1 then
			draw.RoundedBox(8,16+hl.x,16+hl.y, 92, 48, Color(0, 0, 0, 92))
			
			local pingratio = math.Clamp(1-depthhud.ping/1000,0,1)
			local boxround = 8
			if pingratio <= 0.75 && pingratio > 0.5 then
				boxround = 6
			end
			if pingratio <= 0.5 && pingratio > 0.25 then
				boxround = 4
			end
			if pingratio <= 0.25 then
				boxround = 0
			end
			vcolor = Color(cglobalr,cglobalg,cglobalb,92)			
			draw.RoundedBox(boxround,24+16*(1-(pingratio))+hl.x*1.5,24+16*(1-(pingratio))+hl.y*1.5,32*(pingratio),32*(pingratio),vcolor)

			vcolor = Color(cglobalr,cglobalg,cglobalb,255)
			draw.DrawText(depthhud.ping,"hl2num",80+hl.x*1.25,20+hl.y*1.25,vcolor,1)
			draw.DrawText("MS","textsmall",80+hl.x*1.25,48+hl.y*1.25,vcolor,1)
		end
		

	end
	
	hook.Add("HUDPaint","depthhud.draw",depthhud.draw)
	
	function depthhud.HideHUD(name)
		if name == "CHudHealth" then return false end
		if name == "CHudBattery" then return false end
		if name == "CHudAmmo" then return false end
		if name == "CHudSecondaryAmmo" then return false end
	end
	hook.Add("HUDShouldDraw","depthhud.HideHUD",depthhud.HideHUD)
end

function depthhud.Panel(Panel)	
	Panel:AddControl("Checkbox", {
			Label = "Temp-disable the HUD (Gamemodes)", 
			Description = "Temporaily disables the HUD for other gamemodes.", 
			Command = "depthhud_disable" 
		}
	)
	
	Panel:AddControl("Slider", {
			Label = "HUD Lag (default 0.4)",
			Type = "Float",
			Min = "0",
			Max = "1",
			Command = "depthhud_hudlag"
		}
	)
	
	Panel:AddControl("Slider", {
			Label = "Health/Armor Report (default 1.4)",
			Type = "Float",
			Min = "0",
			Max = "1.9",
			Command = "depthhud_reportseconds"
		}
	)
	
	Panel:AddControl("Label", {
			Text = "Speedometer Unit", 
			Description = "Speedometer Unit", 
		}
	)
	depthhud.unitbox = {}
	depthhud.unitbox.Label = "Speedometer Unit"
	depthhud.unitbox.MenuButton = 0
	depthhud.unitbox.Options = {}
	depthhud.unitbox.Options["MPH"] = {depthhud_unit = "MPH"}
	depthhud.unitbox.Options["KM/H"] = {depthhud_unit = "KM/H"}
	Panel:AddControl("ComboBox",depthhud.unitbox) 

	Panel:AddControl("Checkbox", {
			Label = "24-hour format", 
			Description = "Hour is in 24h format.", 
			Command = "depthhud_hourformat" 
		}
	)
	
	Panel:AddControl("Checkbox", {
			Label = "Display ping", 
			Description = "Draws the ping on screen if checked.", 
			Command = "depthhud_showping" 
		}
	)
	
	Panel:AddControl("Checkbox", {
			Label = "Health uses Team Color", 
			Description = "Health shows Team Color.", 
			Command = "depthhud_healthisteam" 
		}
	)
	
	Panel:AddControl("Label", {
			Text = "Color (default 255,220,0)", 
			Description = "Global HUD Color", 
		}
	)
	Panel:AddControl("Color",{
			Label 	= "Color",
			Red 	= "depthhud_global_r",
			Green 	= "depthhud_global_g",
			Blue 	= "depthhud_global_b",
//			Alpha 	= "depthhud_global_a",
			ShowAlpha	= "0",
			ShowHSV		= "0",
			ShowRGB		= "0",
			Multiplier	= "255",
		}
	)
end

function depthhud.AddPanel()
	spawnmenu.AddToolMenuOption("Options","Player","Depth HUD","Depth HUD","","",depthhud.Panel,{})
end

hook.Add( "PopulateToolMenu", "AddDepthHUDPanel", depthhud.AddPanel )

depthhud.load()

