if CLIENT then
  surface.CreateFont( "coolvetica", 30, 500, true, false, "HealthFont" )
  surface.CreateFont( "coolvetica", 22, 500, true, false, "HealthNumberFont" )
  function HealthBar()  
  if GetConVarNumber("cl_showhealthbar") == 1 && LocalPlayer():GetNWInt("HealthBarDisable") == 0 then
      local tr = utilx.GetPlayerTrace( LocalPlayer(), LocalPlayer():GetCursorAimVector() )
      local trace = util.TraceLine( tr )
      if (!trace.Hit) then return end
      if (!trace.HitNonWorld) then return end
      local font = "TargetID"
      local length = LocalPlayer():GetNWInt("LookingHealth") / LocalPlayer():GetNWInt("LookingMaxHealth") * 150
      local x, y = gui.MousePos()
      draw.SimpleText(trace.Entity:GetClass(), "HealthFont", x, y + 100, Color(255,255,255,255),1,1) 
      if LocalPlayer():GetNWInt("LookingHealth") != 0 && LocalPlayer():GetNWInt("LookingMaxHealth") >= LocalPlayer():GetNWInt("LookingHealth") then
        surface.SetDrawColor( 255,255,255,255 )
        surface.DrawRect( x - 75, y + 120, 150, 15 )
        surface.SetDrawColor( 0,255,0,255 )
        surface.DrawRect( x - 75, y + 120, length, 15 )
        draw.SimpleText(LocalPlayer():GetNWInt("LookingHealth") .. "/" .. LocalPlayer():GetNWInt("LookingMaxHealth"), "HealthNumberFont", x, y + 129, Color(255,0,0,255),1,1) 
      elseif LocalPlayer():GetNWInt("LookingHealth") != 0 && LocalPlayer():GetNWInt("LookingMaxHealth") <= LocalPlayer():GetNWInt("LookingHealth") then
        surface.SetDrawColor( 255,255,255,255 )
        surface.DrawRect( x - 75, y + 120, 150, 15 )
        surface.SetDrawColor( 0,255,0,255 )
        surface.DrawRect( x - 75, y + 120, 150, 15 )
        draw.SimpleText(LocalPlayer():GetNWInt("LookingHealth") .. "/" .. LocalPlayer():GetNWInt("LookingMaxHealth"), "HealthNumberFont", x, y + 129, Color(255,0,0,255),1,1) 
      end
    end
  end
  hook.Add("HUDPaint", "bleh", HealthBar)
  CreateClientConVar("cl_showhealthbar", 1, true, false)
  
else

  AddCSLuaFile("healthbar.lua")
  function HealthBarGetHealth()  
   for k, v in pairs(player.GetAll()) do
      local tr = utilx.GetPlayerTrace( v, v:GetCursorAimVector() )
      local trace = util.TraceLine( tr )
      if (!trace.Hit) then return end
      if (!trace.HitNonWorld) then return end
      v:SetNWInt("LookingHealth",trace.Entity:Health())
      v:SetNWInt("LookingMaxHealth",trace.Entity:GetMaxHealth())
      if GetConVarNumber("sv_showhealthbar") == 0 then
      v:SetNWInt("HealthBarDisable",1)
      else
      v:SetNWInt("HealthBarDisable",0)
      end
   end 
  end
  hook.Add("Think", "NpcHudGetHealth", HealthBarGetHealth)
  CreateConVar("sv_showhealthbar", 1)
end
