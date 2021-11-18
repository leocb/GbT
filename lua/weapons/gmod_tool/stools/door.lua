  /*Door stool by High6*/
 /*       v1.8b       */
/*      And CJ             */
local defaultlimit = 5

TOOL.ClientConVar[ "class" ] = "prop_dynamic"
TOOL.ClientConVar[ "model" ] = "models/props_combine/combine_door01.mdl"
TOOL.ClientConVar[ "open" ] = "1"
TOOL.ClientConVar[ "close" ] = "2"
TOOL.ClientConVar[ "autoclose" ] = "0"
TOOL.ClientConVar[ "closetime" ] = "5"
TOOL.ClientConVar[ "hardware" ] = "1"
cleanup.Register( "door" )

TOOL.Category		= "Construction"		// Name of the category
TOOL.Name			= "#Door"		// Name to display
TOOL.Command		= nil				// Command on click (nil for default)
TOOL.ConfigName		= ""				// Config file name (nil for default)

local GhostEntity
--prop_door_rotating
--prop_dynamic
if SERVER then
	local Doors = {}
	
	local function Save( save )
	
		saverestore.WriteTable( Doors, save )
		
	end
	
	local function Restore( restore )
	
		Doors = saverestore.ReadTable( restore )
		
	end
	
	saverestore.AddSaveHook( "Doors", Save )
	saverestore.AddRestoreHook( "Doors", Restore )
	
	
if !ConVarExists("sbox_maxdoors") then CreateConVar("sbox_maxdoors", defaultlimit, FCVAR_NOTIFY ) end
	function opendoor(ply,ent,autoclose,closetime)
	if not ent:IsValid() then return end
		ent:Fire("setanimation","open","0")
		if autoclose == 1 then ent:Fire("setanimation","close",closetime) end
	end
	function closedoor(ply,ent)
	if not ent:IsValid() then return end
	ent:Fire("setanimation","close","0")
	end
	numpad.Register( "door_open", opendoor ) 
	numpad.Register( "door_close", closedoor )
	function makedoor(ply,trace,ang,model,open,close,autoclose,closetime,class,hardware)
		if ( !ply:CheckLimit( "doors" ) ) then return nil end
		local entit = ents.Create(class)
		entit:SetModel(model)
		local minn = entit:OBBMins()
		local newpos = Vector(trace.HitPos.X,trace.HitPos.Y,trace.HitPos.Z - (trace.HitNormal.z * minn.z) )
		entit:SetPos( newpos )
		entit:SetAngles(Angle(0,ang.Yaw,0))
		if tostring(class) == "prop_dynamic" then
			entit:SetKeyValue("solid","6")
			entit:SetKeyValue("MinAnimTime","1")
			entit:SetKeyValue("MaxAnimTime","5")
		elseif tostring(class) == "prop_door_rotating" then
			entit:SetKeyValue("hardware",hardware)
			entit:SetKeyValue("distance","90")
			entit:SetKeyValue("speed","100")
			entit:SetKeyValue("returndelay","-1")
			entit:SetKeyValue("spawnflags","8192")
			entit:SetKeyValue("forceclosed","0")
		else
		Msg(class .. " is not a valid class. Bitch at high6 about this error.\n") --HeHe
		return
		end
		entit:Spawn()	
		entit:Activate() 
		numpad.OnDown(ply,open,"door_open",entit,autoclose,closetime)	
		if tostring(class) != "prop_door_rotating" then
			numpad.OnDown(ply,close,"door_close",entit,autoclose,closetime)	
		end
		ply:AddCount( "doors", entit )
		ply:AddCleanup( "doors", entit )
		
		local index = ply:UniqueID()
		Doors[ index ] 			= Doors[ index ] or {}
		Doors[ index ][1] 	= Doors[ index ][1] or {}
		table.insert( Doors[ index ][1], entit )
		
		
		undo.Create("Door")
		undo.AddEntity( entit )
		undo.SetPlayer( ply )
		undo.Finish()
	end
end

if ( CLIENT ) then

	language.Add( "Tool_door_name", "Door" )
	language.Add( "Tool_door_desc", "Spawn a Door" )
	language.Add( "Tool_door_0", "Click somewhere to spawn a door." )

	language.Add( "Undone_door", "Undone door" )
	language.Add( "Cleanup_door", "door" )
	language.Add( "SBoxLimit_doors", "Max Doors Reached!" )
	language.Add( "Cleaned_door", "Cleaned up all doors" )

end


function TOOL:LeftClick( tr )
	if CLIENT then return true end	
	local model	= self:GetClientInfo( "model" )
	local open = self:GetClientNumber( "open" ) 
	local close = self:GetClientNumber( "close" )  
	local class = self:GetClientInfo( "class" )  
	local ply = self:GetOwner()
	local ang = ply:GetAimVector():Angle() 
	local autoclose = self:GetClientNumber( "autoclose" )  
	local closetime = self:GetClientNumber( "closetime" )  
	local hardware = self:GetClientNumber( "hardware" )  
	if ( !self:GetSWEP():CheckLimit( "doors" ) ) then return false end
	makedoor(ply,tr,ang,model,open,close,autoclose,closetime,class,hardware)
	
	return true

end

function TOOL.BuildCPanel( CPanel )

	// HEADER
	CPanel:AddControl( "Header", { Text = "#Tool_door_name", Description	= "#Tool_door_desc" }  )
	
	// PRESETS
	local params = { Label = "#Presets", MenuButton = 1, Folder = "door", Options = {}, CVars = {} }
			
		params.Options.default = {
			door_model = "models/props_combine/combine_door01.mdl",
			door_open	= 1,
			door_close	= 2 }
			
		table.insert( params.CVars, "door_open" )
		table.insert( params.CVars, "door_close" )
		table.insert( params.CVars, "door_model" )
		
	CPanel:AddControl( "ComboBox", params )
	
	
	// KEY
	CPanel:AddControl( "Numpad", { Label = "#Door Open",Label2 = "#Door Close", Command = "door_open",Command2 = "door_close", ButtonSize = 22 } )
	
	
	// EMITTERS
	local params = { Label = "#Models", Height = 150, Options = {} }
	params.Options[ "TallCombineDoor" ] = { door_class = "prop_dynamic",door_model = "models/props_combine/combine_door01.mdl" }
	params.Options[ "ElevatorDoor" ] = { door_class = "prop_dynamic",door_model = "models/props_lab/elevatordoor.mdl" }
	params.Options[ "CombineDoor" ] = { door_class = "prop_dynamic",door_model = "models/combine_gate_Vehicle.mdl" }
	params.Options[ "SmallCombineDoor" ] = { door_class = "prop_dynamic",door_model = "models/combine_gate_citizen.mdl" }
	params.Options[ "Window" ] = { door_class = "prop_dynamic",door_model = "models/props_lab/blastwindow.mdl" }
	params.Options[ "Door1" ] = { door_hardware = "1",door_class = "prop_door_rotating",door_model = "models/props_c17/door01_left.mdl" }
	params.Options[ "Door2" ] = { door_hardware = "2",door_class = "prop_door_rotating",door_model = "models/props_c17/door01_left.mdl" }
	params.Options[ "Lab BlastDoor" ] = { door_class = "prop_dynamic",door_model = "models/props_doors/doorKLab01.mdl" }
	params.Options[ "ElevatorDoor2" ] = { door_class = "prop_dynamic",door_model = "models/props_silo/silo_elevator_door.mdl" }
	params.Options[ "GarageDoor" ] = { door_class = "prop_dynamic",door_model = "models/props_mining/techgate01_outland03.mdl" }
	params.Options[ "misc. Door" ] = { door_class = "prop_dynamic",door_model = "models/props_lab/hev_case.mdl" }
	params.Options[ "PortalDoor" ] = { door_class = "prop_dynamic",door_model = "models/props/round_elevator_doors.mdl" }
	params.Options[ "Portal Fall door" ] = { door_class = "prop_dynamic",door_model = "models/props_bts/glados_aperturedoor.mdl" }
	params.Options[ "Door Blocker" ] = { door_class = "prop_dynamic",door_model = "models/props_doors/door03_slot.mdl" }
	params.Options[ "Large GarageDoor" ] = { door_class = "prop_dynamic",door_model = "models/props_gameplay/door_slide_large_dynamic.mdl" }
	params.Options[ "Elevator door mining" ] = { door_class = "prop_dynamic",door_model = "models/props_mining/elevator01_cagedoor.mdl" }
	CPanel:AddControl( "ListBox", params )
	CPanel:AddControl( "Slider",  { Label	= "#AutoClose Delay",
								Type	= "Float",
								Min		= 0,
								Max		= 100,
								Command = "door_closetime" }	 )
	CPanel:AddControl( "Checkbox", { Label = "#AutoClose", Command = "door_autoclose" } )

end

function TOOL:UpdateGhostThruster( ent, Player )

	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end

	local tr 	= utilx.GetPlayerTrace( Player, Player:GetCursorAimVector() )
	local trace 	= util.TraceLine( tr )
	if (!trace.Hit) then return end
		local ang = Player:GetAimVector():Angle() 
		local minn = ent:OBBMins()
		local newpos = Vector(trace.HitPos.X,trace.HitPos.Y,trace.HitPos.Z - (trace.HitNormal.z * minn.z))
		ent:SetPos( newpos )
		ent:SetAngles(Angle(0,ang.Yaw,0))
	
end


function TOOL:Think()

	if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != self:GetClientInfo( "model" )) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end
	
	self:UpdateGhostThruster( self.GhostEntity, self:GetOwner() )
	
end
