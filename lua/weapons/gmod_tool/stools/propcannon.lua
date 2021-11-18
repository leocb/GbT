TOOL.Category		= "Destruction"
TOOL.Name			= "#Prop Cannon"
TOOL.Command		= nil
TOOL.ConfigName		= ""


TOOL.ClientConVar[ "group" ] = 1		// Current group
TOOL.ClientConVar[ "force" ] = 2000
TOOL.ClientConVar[ "recoil" ] = 1
TOOL.ClientConVar[ "reload" ] = 100
TOOL.ClientConVar[ "proptime" ] = 5
TOOL.ClientConVar[ "bangpower" ] = 0
TOOL.ClientConVar[ "bangradius" ] = 0
TOOL.ClientConVar[ "model" ] = "models/props_c17/lampShade001a.mdl"
TOOL.ClientConVar[ "ammo" ] = "models/props_junk/garbage_metalcan002a.mdl"
TOOL.ClientConVar[ "effect" ] = "Explosion"
TOOL.ClientConVar[ "explodeoncontact" ] = "1"

cleanup.Register( "propcannons" )

if (SERVER) then
  CreateConVar('sbox_maxpropcannons',10)
end

// Add Default Language translation (saves adding it to the txt files)
if ( CLIENT ) then

	language.Add( "Tool_propcannon_name", "Prop Cannon" )
	language.Add( "Tool_propcannon_desc", "A mobile cannon that can fire any prop" )
	language.Add( "Tool_propcannon_0", "Click somewhere to spawn a cannon. Click on an existing cannon to change it. Right click on a prop to use the model as ammo." )

	language.Add( "Undone_propcannon", "Undone Prop Cannon" )
	language.Add( "Cleanup_propcannons", "Prop Cannons" )
	language.Add( "Cleaned_propcannons", "Cleaned up all Prop Cannons" )

end



function TOOL:LeftClick( trace )

	if (!trace.HitPos) then return false end
	if (trace.Entity:IsPlayer()) then return false end
	
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	if ( CLIENT ) then return true end
	
	// Get client's CVars
	local ply = self:GetOwner()
	local force			= self:GetClientNumber( "force" )
	local recoil		= self:GetClientNumber( "recoil" )
	local reload		= self:GetClientNumber( "reload" )
	local model			=self:GetClientInfo("model")
	local ammo			= self:GetClientInfo( "ammo" )
	local proptime		= self:GetClientNumber( "proptime" )
	local bangpower		=self:GetClientNumber("bangpower")
	local bangradius	=self:GetClientNumber("bangradius")
	local effect			= self:GetClientInfo( "effect" )
	local explodeoncontact = self:GetClientNumber("explodeoncontact") == 1
	
	local group		= self:GetClientNumber( "group" )



	if (not util.IsValidModel(model)) then return false end
	if (not util.IsValidProp(model)) then return false end
	if (not util.IsValidModel(ammo)) then return false end
	if (not util.IsValidProp(ammo)) then return false end 

    // We shot an existing cannon - just change its values
	if ( trace.Entity:IsValid() && trace.Entity:GetClass() == "gmod_propcannon" && trace.Entity:GetTable():GetPlayer() == ply ) then

		trace.Entity:GetTable():Setup( force, model, ammo, recoil, reload, proptime, bangpower, bangradius, effect, explodeoncontact)
		return true

	end
	
	if !ply:CheckLimit('propcannons') then return end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	local cannon = MakeCannon( ply, trace.HitPos, Ang, group, force, model, ammo, recoil, reload, proptime, bangpower, bangradius, effect, explodeoncontact)
	
	local min = cannon:OBBMins()
	cannon:SetPos( trace.HitPos - trace.HitNormal * min.z )

    local const, nocollide

	// Don't weld to world
	if ( trace.Entity:IsValid() ) then
		const = constraint.Weld( cannon, trace.Entity, 0, trace.PhysicsBone, 0, systemmanager )
		nocollide = constraint.NoCollide( cannon, trace.Entity, 0, trace.PhysicsBone )
		trace.Entity:DeleteOnRemove( cannon )
	end


	undo.Create("propcannon")
		undo.AddEntity( cannon )
		undo.AddEntity( const )
		undo.AddEntity( nocollide )
		undo.SetPlayer( ply )
	undo.Finish()
	
	ply:AddCleanup( "propcannons", cannon )
	ply:AddCleanup( "propcannons", const )
	ply:AddCleanup( "propcannons", nocollide )
	
	
	--ply:AddCleanup( "propcannon", cannon )
	
	return true
	
end

function TOOL:RightClick( trace )
	--set the model to be the model gained by the trace
 	if (!trace.HitPos) then return false end
	if (trace.Entity:IsPlayer()) then return false end
	if ( CLIENT ) then return true end
	
	
	if(trace.Entity:IsValid() && trace.Entity:GetClass() == "prop_physics") then

		local model=trace.Entity:GetModel()
		if(util.IsValidModel(model)) then
			Msg("Selecting ammo: "..model)
		 	self:GetOwner():ConCommand("propcannon_ammo "..model.."\n")
		 	self:GetOwner():PrintMessage(HUD_PRINTCENTER,"Cannon ammo set to this model!")
			--Msg("Using ammo: "..model)
		end

	end
	
end

if SERVER then

	--local Cannons = {}

	function MakeCannon(pl, Pos, Ang, key, force, model, ammo, recoil, reload, proptime, bangpower, bangradius, effect, explodeoncontact, Vel, aVel, frozen )

		local cannon = ents.Create( "gmod_propcannon" )
			cannon:SetPos( Pos )	
			cannon:SetAngles( Ang )
			cannon:GetTable():Setup( force, model, ammo, recoil, reload, proptime, bangpower, bangradius, effect, explodeoncontact)
			
			--make it shiny black
			
			cannon:SetMaterial("models/shiny")
			cannon:SetColor(0, 0, 0, 255)
		cannon:Spawn()
		

		cannon:GetTable():SetPlayer( pl )

		numpad.OnDown( 	 pl, 	key, 	"PropCannon_On", 	cannon )
		numpad.OnUp( 	 pl, 	key, 	"PropCannon_Off", 	cannon )
		
		local ttable =
		{
			key			= key,
			force 		= force,
			model 		= model,
			ammo 		= ammo,
			pl			= pl,
			recoil 	= recoil,
			reload		= reload,
			proptime=proptime,
			bangpower=bangpower,
			bangradius=bangradius,
			effect=effect,
			explodeoncontact=explodeoncontact
		}

		table.Merge( cannon:GetTable(), ttable )
		
		
		pl:AddCount( "propcannons", cannon )
		--pl:AddCleanup( "propcannons", cannon )
		return cannon
		
	end
	
	duplicator.RegisterEntityClass( "gmod_propcannon", MakeCannon, "Pos", "Ang", "key", "force", "model", "ammo","recoil", "reload", "proptime","bangpower","bangradius","effect","explodeoncontact", "Vel", "aVel", "frozen" )
	
end

function TOOL:UpdateGhost( ent, player )

	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end

	local tr 	= utilx.GetPlayerTrace( player, player:GetCursorAimVector() )
	local trace 	= util.TraceLine( tr )
	
	if (!trace.Hit || trace.Entity:IsPlayer()||(trace.Entity && trace.Entity:GetClass() == "gmod_propcannon") ) then
		ent:SetNoDraw( true )
		return
	end
	
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	ent:SetAngles( Ang )	

	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	
	ent:SetNoDraw( false )

end

function TOOL:Think()

	if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != self:GetClientInfo( "model" ) ) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end
	
	self:UpdateGhost( self.GhostEntity, self:GetOwner() )
	
end

function TOOL.BuildCPanel(cp)

    cp:AddControl( "Header", { Text = "#Tool_propcannon_name", Description	= "#Tool_propcannon_desc" }  )

    local Combo = {}
	Combo["Label"] = "#Presets"
	Combo["MenuButton"] = "1"
	Combo["Folder"] = "propcannon"
	Combo["Options"] = {}
	Combo["Options"]["Default"] = {}
	Combo["Options"]["Default"]["propcannon_model"] = "models/dav0r/thruster.mdl"
	Combo["Options"]["Default"]["propcannon_ammo"] = "models/props_junk/garbage_metalcan002a.mdl"
	Combo["Options"]["Default"]["propcannon_force"] = "5000"
	Combo["Options"]["Default"]["propcannon_group"] = "1"
	Combo["Options"]["Default"]["propcannon_reload"] = "3"
	Combo["Options"]["Default"]["propcannon_recoil"] = "1"
	Combo["Options"]["Default"]["propcannon_proptime"] = "5"
	Combo["Options"]["Default"]["propcannon_bangpower"] = "0"
	Combo["Options"]["Default"]["propcannon_bangradius"] = "0"
	Combo["Options"]["Default"]["propcannon_effect"] = "Explosion"
	Combo["Options"]["Default"]["propcannon_explodeoncontact"] = "1"
	Combo["CVars"] = {}
	Combo["CVars"]["0"] = "propcannon_model"
	Combo["CVars"]["1"] = "propcannon_ammo"
	Combo["CVars"]["2"] = "propcannon_force"
	Combo["CVars"]["3"] = "propcannon_group"
	Combo["CVars"]["4"] = "propcannon_reload"
	Combo["CVars"]["5"] = "propcannon_recoil"
	Combo["CVars"]["6"] = "propcannon_proptime"
	Combo["CVars"]["7"] = "propcannon_bangpower"
	Combo["CVars"]["8"] = "propcannon_bangradius"
	Combo["CVars"]["9"] = "propcannon_effect"
	Combo["CVars"]["10"] = "propcannon_explodeoncontact"
	
	cp:AddControl("ComboBox", Combo )



	//cp:AddControl( "ComboBox", { Label = "Cannon model:", Description = "Choose the model for the cannon", MenuButton = "0", Options = Localize( "Thruster"=Localize( "propcannon_model" "models/dav0r/thruster.mdl" ), "Crate" = Localize( "propcannon_model" "models/props_junk/wood_crate001a.mdl" ) ) } )
    cp:AddControl( "Numpad", { Label = "Keypad button:", Command = "propcannon_group", Buttonsize = "22" } )
    cp:AddControl( "Slider", { Label = "Force:", Description = "How much force the cannon fires with",Type = "float", Min = "-100000", Max = "100000", Command = "propcannon_force" } )
    cp:AddControl( "Slider", { Label = "Reload:", Description = "How long it takes before the cannon can fire again", Type = "float", Min = "0", Max = "50", Command = "propcannon_reload" } )
    cp:AddControl( "Slider", { Label = "Recoil:", Description = "How much recoil the cannon will produce",Type = "float", Min = "-10", Max = "10", Command = "propcannon_recoil" } )
    cp:AddControl( "Slider", { Label = "Prop Lifetime:", Description = "How many seconds each fired prop will exist for (0 to last forever)",Type = "float", Min = "0", Max = "30", Command = "propcannon_proptime" } )
    cp:AddControl( "Slider", { Label = "Explosive Power:", Description = "How explosive is the prop being fired (use 0 for no explosion)",Type = "float", Min = "0", Max = "500", Command = "propcannon_bangpower" } )
    cp:AddControl( "Slider", { Label = "Explosive Radius:", Description = "The radius of any explosion",Type = "float", Min = "0", Max = "500", Command = "propcannon_bangradius" } )
    cp:AddControl( "Checkbox", { Label = "Explode on contact:", Description = "Should projectiles explode when they hit something", Command = "propcannon_explodeoncontact" } )
    
    local ComboModel = {}
	ComboModel["Label"] = "Cannon model:"
	ComboModel["Options"] = {}
	ComboModel["Options"]["Thruster"] = {}
	ComboModel["Options"]["Thruster"]["propcannon_model"] = "models/dav0r/thruster.mdl"
	--ComboModel["Options"]["Crate"] = {}
	--ComboModel["Options"]["Crate"]["propcannon_model"] = "models/props_junk/wood_crate001a.mdl"
	ComboModel["Options"]["Bucket"] = {}
	ComboModel["Options"]["Bucket"]["propcannon_model"] = "models/props_junk/MetalBucket01a.mdl"
	ComboModel["Options"]["Trashcan"] = {}
	ComboModel["Options"]["Trashcan"]["propcannon_model"] = "models/props_trainstation/trashcan_indoor001b.mdl"
	ComboModel["Options"]["Traffic Cone"] = {}
	ComboModel["Options"]["Traffic Cone"]["propcannon_model"] = "models/props_junk/TrafficCone001a.mdl"
	ComboModel["Options"]["Oil Drum"] = {}
	ComboModel["Options"]["Oil Drum"]["propcannon_model"] = "models/props_c17/oildrum001.mdl"
	ComboModel["Options"]["Canister"] = {}
	ComboModel["Options"]["Canister"]["propcannon_model"] = "models/props_c17/canister01a.mdl"
	ComboModel["CVars"] = {}
	ComboModel["CVars"]["0"] = "propcannon_model"
	ComboModel["Command"] ="propcannon_model"
	
	cp:AddControl("ComboBox", ComboModel )
	
	
	local ComboAmmo = {}
	ComboAmmo["Label"] = "Cannon ammo:"
	ComboAmmo["Options"] = {}
	ComboAmmo["Options"]["Propane Tank"] = {}
	ComboAmmo["Options"]["Propane Tank"]["propcannon_ammo"] = "models/props_junk/propane_tank001a.mdl"
	ComboAmmo["Options"]["Fat Canister"] = {}
	ComboAmmo["Options"]["Fat Canister"]["propcannon_ammo"] = "models/props_c17/canister_propane01a.mdl"
	ComboAmmo["Options"]["Melon"] = {}
	ComboAmmo["Options"]["Melon"]["propcannon_ammo"] = "models/props_junk/watermelon01.mdl"
	ComboAmmo["Options"]["Cinder Block"] = {}
	ComboAmmo["Options"]["Cinder Block"]["propcannon_ammo"] = "models/props_junk/CinderBlock01a.mdl"
	ComboAmmo["Options"]["Concrete Block"] = {}
	ComboAmmo["Options"]["Concrete Block"]["propcannon_ammo"] = "models/props_debris/concrete_cynderblock001.mdl"
	ComboAmmo["Options"]["Cola Can"] = {}
	ComboAmmo["Options"]["Cola Can"]["propcannon_ammo"] = "models/props_junk/PopCan01a.mdl"

	ComboAmmo["CVars"] = {}
	ComboAmmo["CVars"]["0"] = "propcannon_ammo"
	ComboAmmo["Command"] ="propcannon_ammo"
	
	cp:AddControl("ComboBox", ComboAmmo )
	
	
	
	local ComboEffect = {}
	ComboEffect["Label"] = "Fire effect:"
	ComboEffect["Options"] = {}
	ComboEffect["Options"]["Explosion"] = {}
	ComboEffect["Options"]["Explosion"]["propcannon_effect"] = "Explosion"
	ComboEffect["Options"]["Sparks"] = {}
	ComboEffect["Options"]["Sparks"]["propcannon_effect"] = "cball_explode"
	ComboEffect["Options"]["Bomb drop"] = {}
	ComboEffect["Options"]["Bomb drop"]["propcannon_effect"] = "RPGShotDown"
	ComboEffect["Options"]["Flash"] = {}
	ComboEffect["Options"]["Flash"]["propcannon_effect"] = "HelicopterMegaBomb"
	ComboEffect["Options"]["Machine Gun"] = {}
	ComboEffect["Options"]["Machine Gun"]["propcannon_effect"] = "HelicopterImpact"
	ComboEffect["Options"]["None"] = {}
	ComboEffect["Options"]["None"]["propcannon_effect"] = "none"
	

	ComboEffect["CVars"] = {}
	ComboEffect["CVars"]["0"] = "propcannon_effect"
	ComboModel["Command"] ="propcannon_effect"
	
	cp:AddControl("ComboBox", ComboEffect )


end
