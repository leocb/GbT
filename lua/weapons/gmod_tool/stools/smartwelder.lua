TOOL.Category		= "Constraints"
TOOL.Name			= "#Weld - Smart"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.busy           =false

--the default smartweld settings
TOOL.ClientConVar["radius"]=128
TOOL.ClientConVar["nocollideradius"]=128
TOOL.ClientConVar["maxweldspp"]=3
TOOL.ClientConVar["randomwelds"]=1
TOOL.ClientConVar["nocollide"]=1
TOOL.ClientConVar["unfreeze"]=1
TOOL.ClientConVar["autofreeze"]=0
TOOL.ClientConVar["refreshwelds"]=1
TOOL.ClientConVar["weldstrength"]=0



--edit these variables to customise your install

--when welding over time, weldtime is the gap between successive welds/nocollides
WELDTIME=0.01
--notifygap is the multiple of which the player will be informed of the smartweld progress (ie. weld 50, 100, 150 placed)
NOTIFYGAP=50
--slowmode is welding over time.  Turning this off will make smart welder perform the weld in one go, making it more likely to crash with big contraptions
SLOWMODE=true
--if you have this on, the script will attempt to follow Conna's prop protection scheme
USEPROPPROTECTION=false

if ( CLIENT ) then

	language.Add( "Tool_smartwelder_name", "Smart Welder" )
	language.Add( "Tool_smartwelder_desc", "Automatically welds selected props" )
	language.Add( "Tool_smartwelder_0", "Select props with left click (hold use key to auto-select). Smart-weld with right click (hold use to weld to one prop). Reload clears selection." )

	language.Add( "Undone_smartweld", "Undone Smart Weld" )

end


function TOOL:LeftClick( trace )

	if(!self.busy) then
    if(self.props==nil) then
	      self.props={}
	end
	
	for a,v in ipairs(self.props) do
			--Msg("V="..v.."\n")
			if(!v.ent:IsValid()) then
				table.remove(self.props,a)
				--Msg("Removing...\n")
			end
	end
    --Msg("Start\n")
	if (!trace.HitPos) then return false end
	if (trace.Entity:IsPlayer()) then return false end
	
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	if ( CLIENT ) then return true end
	
	// Get client's CVars
	local ply = self:GetOwner()
	
	local radius=self:GetClientNumber("radius")
	local nocollideradius=self:GetClientNumber("nocollideradius")
	local randomwelds = self:GetClientNumber("randomwelds")
	local smartnocollide = self:GetClientNumber("nocollide") == 1
	local weldsperprop = self:GetClientNumber("maxweldspp")
	
	if ( trace.Entity:IsValid() && trace.Entity:GetPhysicsObject():IsValid()) then
	   if(ply:KeyDown(IN_USE)||ply:KeyDown(IN_SPEED)) then
	   
	        --autoselect
	        
			local selectedcount=self:Autoselect(trace.Entity,radius)
			if(selectedcount>1) then
		    self:GetOwner():PrintMessage(HUD_PRINTCENTER,selectedcount.." props auto-selected")
		    end
	   
       else
	
	   	   self:ChooseEnt(trace.Entity)
	   end
	end
	--Msg("End\n")
	return true
	else
	return false
	end
	
end

function TOOL:Autoselect(ent,radius)
		 local counted=0
         if ( ent:IsValid() && ent:GetPhysicsObject():IsValid() && !ent:IsPlayer()) then

            if(!self:IsSelected(ent)) then
            
                if(self:IsPropOwner(self:GetOwner(),ent)) then
                
                --add to list, try adding everything near it to list
            	self:SelectEnt(ent,false)
            	counted=1
            	
            	local close_ents = ents.FindInSphere( ent:GetPos(), radius )
            	
            	for i,v in ipairs(close_ents) do
            	    if(v!=ent) then
            	        counted=counted+self:Autoselect(v,radius)
            	    end
            	end
            	end
			end
         end
         return counted
end

function TOOL:IsSelected(ent)

    	 local selected=-1
       for i,v in ipairs(self.props) do
           if(v.ent==ent) then
		   selected=i
		   break
		   end
	   end
	   
	   if(selected==-1) then
	        return false
		else
		    return true
	   end

end

--Based on a function by Conna
function TOOL:IsPropOwner(ply, ent)

	if(USEPROPPROTECTION) then
	for k, v in pairs(g_SBoxObjects) do
		for b, j in pairs(v) do
			for _, e in pairs(j) do
				if(e == ent) then
					if(k == ply:UniqueID()) then
						return true
					end
				end
			end
		end
	end

	for k, v in pairs(GAMEMODE.CameraList) do
		for b, j in pairs(v) do
			if(j == ent) then
				if(k == ply:UniqueID()) then
					return true
				end
			end
		end
	end
	return false
	else
	return true
	end
end

function TOOL:ChooseEnt(ent)

		  if(self:IsPropOwner(self:GetOwner(),ent)) then
		  
	         local selected=-1
	       for i,v in ipairs(self.props) do
	           if(v.ent==ent) then
			   selected=i
			   break
			   end
		   end
	         if(selected==-1) then
		       --Msg("Setting colour\n")
		       local r,g,b,a = ent:GetColor();
			   table.insert(self.props,{ent=ent,r=r,g=g,b=b,a=a})
			   ent:SetColor(0,255,0,255)
		   else
			   ent:SetColor(self.props[selected].r,self.props[selected].g,self.props[selected].b,self.props[selected].a)
			   table.remove(self.props,selected)
		   end
	   end
end




function TOOL:DeselectEnt(ent)

         if(self:IsPropOwner(self:GetOwner(),ent)) then
         local selected=-1
       for i,v in ipairs(self.props) do
           if(v.ent==ent) then
		   selected=i
		   break
		   end
	   end
         if(selected==-1) then

	   else
       	   ent:SetColor(self.props[selected].r,self.props[selected].g,self.props[selected].b,self.props[selected].a)
		   table.remove(self.props,selected)
	   end
	   end
end



function TOOL:SelectEnt(ent)

   if(self:IsPropOwner(self:GetOwner(),ent)) then
    local r,g,b,a = ent:GetColor();
	table.insert(self.props,{ent=ent,r=r,g=g,b=b,a=a})
	ent:SetColor(0,255,0,255)
   end

end

function TOOL:WeldingFinished(unfreeze, weldcount, holdinguse, proptable,ply)
		 undo.SetPlayer( ply )
			undo.Finish()

			--if set to auto unfreeze
			if(unfreeze) then

				 for a,v in ipairs(proptable) do
				     if(v.ent:IsValid()) then
						 local entphys=v.ent:GetPhysicsObject()
						 if(entphys:IsValid()) then
						        entphys:EnableMotion(true)
						        entphys:Wake()
						 end
					 end
				 end

			end
			


			if(holdinguse) then
			    if(weldcount!=1) then
      				self:GetOwner():PrintMessage(HUD_PRINTCENTER,"Weld to prop complete! "..weldcount.." welds placed")
		    	else
      			self:GetOwner():PrintMessage(HUD_PRINTCENTER,"Weld to prop complete! "..weldcount.." weld placed")
		    	end

			else

				if(weldcount!=1) then
			    self:GetOwner():PrintMessage(HUD_PRINTCENTER,"Smart-weld complete! "..weldcount.." welds placed")
			    else
			    self:GetOwner():PrintMessage(HUD_PRINTCENTER,"Smart-weld complete! "..weldcount.." weld placed")
			    end
		    end
		    
		    --deselect
		    self.busy=false
		    self:ResetSelection()
		    
		    --Msg("Smart-weld complete!\n")
end

function TOOL:WeldEnts(ent1, ent2,bone1, bone2, weldstrength, smartnocollide,weldcount)

         if(ent1:IsValid() and ent2:IsValid()) then
	         local const = constraint.Weld( ent1, ent2, bone1, bone2, weldstrength, smartnocollide )
			 undo.AddEntity( const )

			 if(((weldcount+1)%NOTIFYGAP)==0) then

			 		self:GetOwner():PrintMessage(HUD_PRINTCENTER,"Weld "..(weldcount+1).." placed")

			 end
		 end

end

function TOOL:NoCollideEnts(ent1, ent2,bone1,bone2,nocollidecount)

   if(ent1:IsValid() and ent2:IsValid()) then
	   local nocoll=constraint.NoCollide(ent1,ent2,bone1,bone2)
	   --setup their undo
	   undo.AddEntity(nocoll)

	   if(((nocollidecount+1)%NOTIFYGAP)==0) then
	   		self:GetOwner():PrintMessage(HUD_PRINTCENTER,"Nocollide "..(nocollidecount+1).." placed")
	   end
   
   end
end

function TOOL:RightClick( trace )
	if(self.busy) then
	
	else
	
	local ply = self:GetOwner()
	local randomwelds = self:GetClientNumber("randomwelds")
	local smartnocollide = self:GetClientNumber("nocollide") == 1
	local autofreeze = self:GetClientNumber("autofreeze") == 1
	local unfreeze = self:GetClientNumber("unfreeze") == 1
	local refreshwelds = self:GetClientNumber("refreshwelds") == 1
	local weldsperprop = self:GetClientNumber("maxweldspp")
	local nocollideradius=self:GetClientNumber("nocollideradius")
	local weldstrength=self:GetClientNumber("weldstrength")
	
	if(self.props!=nil) then
	
		for a,v in ipairs(self.props) do
			--Msg("V="..v.."\n")
			if(!v.ent:IsValid()) then
				table.remove(self.props,a)
				--Msg("Removing...\n")
			end
		end
		
		if(#self.props>1) then
		
		
		    self.busy=true
		    --prefreeze
		    
			if(autofreeze) then

				 for a,v in ipairs(self.props) do
					 local entphys=v.ent:GetPhysicsObject()
					 if(entphys:IsValid()) then
					        entphys:EnableMotion(false)
					        entphys:Sleep()
					 end
				 end

			end
		
		    if(refreshwelds) then
			    --get rid of old contraints
			    for a,v in ipairs(self.props) do

			    	local constrs = constraint.FindConstraints( v.ent, "Weld" )

			    	--for every weld, see if it is welded to a selected prop, in which case remove it
					for b,w in ipairs(constrs) do

					    for c,p in ipairs(self.props) do

	                        if(w.Entity[2].Entity==p.ent) then
								  if(p.ent==v.ent) then

								  else

								      --remove the weld
									  w.Constraint:Remove()

								  end

	                        end

					    end


					end

			    end
		    
		    end
		
		
		
		
	        undo.Create("smartweld")

			local welds={}
			for a,v in ipairs(self.props) do
				welds[a]={}
			end

			local weldcount=0
			local holdinguse=false

            if(ply:KeyDown(IN_USE)||ply:KeyDown(IN_SPEED)) then
                if (!trace.HitPos) then return false end
				if (trace.Entity:IsPlayer()) then return false end

				if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end

				if ( CLIENT ) then return true end
				
				if ( trace.Entity:IsValid() && trace.Entity:GetPhysicsObject():IsValid()) then
				
				   local weldtarget=trace.Entity
				   holdinguse=true
				   self:DeselectEnt(trace.Entity)
				   
				   for a,v in ipairs(self.props) do
				   
				       if(v.ent==weldtarget) then
				       
				       else
				       
				   
					       local const = constraint.Weld( v.ent, weldtarget, 0, 0, weldstrength, smartnocollide )
					       undo.AddEntity( const )

					       weldcount=weldcount+1
				       
				       end

				   end
				
				end
				
				
            else
            
				for a,v in ipairs(self.props) do
	                --Msg("!Prop "..a.."!\n")
				    for x=1,weldsperprop do

	                    --Msg("Weld "..x.."\n")
					    --Msg("There a prop "..a)
					    local closestdistance=99999999
					    local closestprop=-1
					    for b,w in ipairs(self.props) do
							if(a!=b) then
									 local linked=false
									 for i,val in ipairs(welds[a]) do
	                                     --Msg("Testing "..b.." against "..val.."\n")
									 	 if(val==b) then
	                                                --Msg("Its linked!\n")
									 	 			linked=true
									 				break
										end
									 end

									 if(!linked) then

									 			 local distance=(v.ent:GetPos()-w.ent:GetPos()):Length()
									             if(distance<closestdistance) then
									             	closestdistance=distance
									             	closestprop=b
									             end
									 end
							end
					    end

					    if(closestprop!=-1) then
					    
					    	--weld to this prop and add to weld list
					    	if(SLOWMODE) then
										 timer.Simple(WELDTIME*weldcount, self.WeldEnts, self, v.ent,self.props[closestprop].ent,0, 0, weldstrength, smartnocollide,weldcount)
							else
							    self:WeldEnts(v.ent,self.props[closestprop].ent,0, 0, weldstrength, smartnocollide,weldcount)
							end

					    	--[[
					    	if(smartnocollide) then

								local nocollide = constraint.NoCollide( v, self.props[closestprop], 0, 0)
								undo.AddEntity( nocollide )


							end--]]

							weldcount=weldcount+1
	                        --Msg("Welding prop "..a.." to prop "..closestprop.."\n")

							table.insert(welds[a],closestprop)


							--[[Msg("Welds[ "..a.."]={")

							for o,p in ipairs(welds[a]) do
							    Msg(p..",")
							end
							Msg("}\n")--]]

							table.insert(welds[closestprop],a)


							--[[Msg("Welds[ "..closestprop.."]={")

							for o,p in ipairs(welds[closestprop]) do
							    Msg(p..",")
							end
							Msg("}\n")--]]
						else
						    --Msg("Prop "..a.." already welded to\n")
							break
					    end

				    end


				end

				for a,v in ipairs(self.props) do
	                --Msg("!Prop "..a.."!\n")
				    for x=1,randomwelds do

				    	--randomly pick a prop

				    	if(#self.props>1) then

							local b=math.random(#self.props)

							if(b!=a) then

								--test if it has been welded to already
								local linked=false
								 for i,val in ipairs(welds[a]) do
		                             --Msg("Testing "..b.." against "..val.."\n")
								 	 if(val==b) then
		                                        --Msg("Its linked!\n")
								 	 			linked=true
								 				break
									end
								 end

		                         --if not, weld to it
								 if(!linked) then
								 
								       if(SLOWMODE) then
										 timer.Simple(WELDTIME*weldcount, self.WeldEnts, self, v.ent,self.props[b].ent,0, 0, weldstrength, smartnocollide,weldcount)
										else
										    self:WeldEnts(v.ent,self.props[closestprop].ent,0, 0, weldstrength, smartnocollide,weldcount)
										end

						    		weldcount=weldcount+1

								 	table.insert(welds[a],b)

								 	table.insert(welds[b],a)

								 	--Msg("Welding prop "..a.." to prop "..b.."\n")

								 end

							 end

				    	end

				    end
				end
				
			end
			
			local nocollidecount=0
			for a,v in ipairs(self.props) do
			
				for b,w in ipairs(self.props) do
					if(a!=b) then
						 local linked=false
						 for i,val in ipairs(welds[a]) do
                             --Msg("Testing "..b.." against "..val.."\n")
						 	 if(val==b) then
                                        --Msg("Its linked!\n")
						 	 			linked=true
						 				break
							end
						 end

						 if((!linked)||(!smartnocollide)) then

					 			 local distance=(v.ent:GetPos()-w.ent:GetPos()):Length()
					             if(distance<nocollideradius) then
					             
					             		--nocollide the ents together
					             		
					             		if(SLOWMODE) then
										 timer.Simple(WELDTIME*(nocollidecount+weldcount), self.NoCollideEnts, self, v.ent,w.ent,0, 0,nocollidecount)
										else
										    self:NoCollideEnts(v.ent,w.ent,0, 0,nocollidecount)
										end
					             		--local nocoll=constraint.NoCollide(v,w,0,0)
										nocollidecount=nocollidecount+1
					             		
					             		--setup their undo
					             		--undo.AddEntity(nocoll)
					             
					             end
					    end
					end
				end
			end
			
			if(refreshwelds) then
				self:GetOwner():PrintMessage(HUD_PRINTCENTER,"Refreshed Smart-weld running...")
			else
				self:GetOwner():PrintMessage(HUD_PRINTCENTER,"Smart-weld running...")
			end
            

            
            if(SLOWMODE) then
			 timer.Simple(WELDTIME*(weldcount+nocollidecount), self.WeldingFinished, self,unfreeze,weldcount, holdinguse, self.props,ply)
			else
       			self:WeldingFinished(unfreeze,weldcount,holdinguse, self.props,ply)
			end
	    
	    end
	end
	
	end
	
end

function TOOL:ResetSelection()

		 local ply=self:GetOwner()
		 
		 local propscleared=false
		   --clear the selection
		   if(self.props==nil) then
			      self.props={}
			end
			for a,v in ipairs(self.props) do
					--Msg("V="..v.."\n")
					if(!v.ent:IsValid()) then
						table.remove(self.props,a)
						--Msg("Removing...\n")
					end
			end
			
			if(#self.props>0) then
			   for a,v in ipairs(self.props) do
			       if(v.ent:IsValid()) then
			       	 v.ent:SetColor(v.r,v.g,v.b,v.a)
			       end
				end
				propscleared=true
				
		   end
		   
		   self.props={}
		   return propscleared

end

function TOOL:Reload( trace )

		 if(!self.busy) then
		 local cleared=self:ResetSelection()
		 
		 if(cleared) then
		 			 self:GetOwner():PrintMessage(HUD_PRINTCENTER,"Selection cleared!")
		 end
		 end
         

end

function TOOL.BuildCPanel(cp)

    cp:AddControl( "Header", { Text = "#Tool_smartwelder_name", Description	= "#Tool_smartwelder_desc" }  )



    cp:AddControl( "Slider", { Label = "Auto-select Radius:", Description = "The autoselecting radius (hold use and left click to autoselect)",Type = "float", Min = "0", Max = "1000", Command = "smartwelder_radius" } )
    cp:AddControl( "Slider", { Label = "Auto-Nocollide Radius:", Description = "Each prop will nocollide with any props within its radius (set to 0 to disable auto-nocolliding)",Type = "float", Min = "0", Max = "1000", Command = "smartwelder_nocollideradius" } )
    cp:AddControl( "Slider", { Label = "Max welds per prop:", Description = "How many welds each prop will make to its nearest neighbours",Type = "integer", Min = "0", Max = "10", Command = "smartwelder_maxweldspp" } )
    cp:AddControl( "Slider", { Label = "Stability welds per prop:", Description = "How many welds each prop will make to random neighbours to increase stability",Type = "integer", Min = "0", Max = "10", Command = "smartwelder_randomwelds" } )
	cp:AddControl( "Slider", { Label = "Weld forcelimit:", Description = "The strength of the welds created. Use 0 for unbreakable welds.",Type = "float", Min = "0", Max = "10000", Command = "smartwelder_weldstrength" } )
	
	--cp:AddControl( "Checkbox", { Label = "Random welds:", Description = "Make extra welds across contraption to increase stability", Command = "smartwelder_randomwelds" } )
	cp:AddControl( "Checkbox", { Label = "No collide:", Description = "Whether pairs of props should be nocollided when welded", Command = "smartwelder_nocollide" } )
	cp:AddControl( "Checkbox", { Label = "Auto freeze:", Description = "Whether all selected props should be frozen before the weld (Warning! Very slow!)", Command = "smartwelder_autofreeze" } )
	cp:AddControl( "Checkbox", { Label = "Auto unfreeze:", Description = "Whether all selected props should be unfrozen after the weld", Command = "smartwelder_unfreeze" } )
	cp:AddControl( "Checkbox", { Label = "Refresh welds:", Description = "Removes old welds inside the selection before smart welding", Command = "smartwelder_refreshwelds" } )


end
