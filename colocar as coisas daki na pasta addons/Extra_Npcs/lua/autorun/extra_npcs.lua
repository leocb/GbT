//
// Don't try to edit this file if you're trying to add new NPCs.
// Just make a new file and copy the format below.
//

local Category = "Humans + Resistance"
local NPC = { 	Name = "ResistanceTurret", 
				Class = "npc_turret_floor",
				OnFloor = true,
				TotalSpawnFlags = SF_FLOOR_TURRET_CITIZEN,
				Skin = 1,
				Offset = 8,
				Icon = "materials\VGUI\entities\Rebelturret",
				Category = Category	}

list.Set( "NPC", "Rebelturret", NPC )				

local NPC = { 	Name = "Fisherman", 
				Class = "npc_fisherman",
				Category = Category	}

local Category = "Animals"

local NPC = { 	Name = "Ichthyosaur", 
				Class = "npc_ichthyosaur",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )


Category = "Combine"

local NPC = { 	Name = "Rollermine", 
				Class = "npc_rollermine",
				Offset = 16,
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )

local NPC = { 	Name = "Turret", 
				Class = "npc_turret_floor",
				OnFloor = true,
				TotalSpawnFlags = 0,
				Offset = 2,
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )

local NPC = { 	Name = "Combine Soldier", 
				Class = "npc_combine_s",
				Model = "models/combine_soldier.mdl",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )



local NPC = { 	Name = "Prison Guard", 
				Class = "npc_combine_s",
				Model = "models/combine_soldier_prisonguard.mdl",
				Category = Category	}

list.Set( "NPC", "CombinePrison", NPC )



local NPC = { 	Name = "Combine Elite", 
				Class = "npc_combine_s",
				Model = "models/combine_super_soldier.mdl",
				Category = Category	}

list.Set( "NPC", "CombineElite", NPC )



local NPC = { 	Name = "City Scanner", 
				Class = "npc_cscanner",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )



local NPC = { 	Name = "Manhack", 
				Class = "npc_manhack",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )


local NPC = { 	Name = "Strider", 
				Class = "npc_strider",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )


local NPC = { 	Name = "Heli", 
				Class = "npc_helicopter",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )


local NPC = { 	Name = "Hopper", 
				Class = "combine_mine",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )


local NPC = { 	Name = "Camera", 
				Class = "npc_combine_camera",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )


local NPC = { 	Name = "Drop ship", 
				Class = "npc_combinedropship",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )


local NPC = { 	Name = "Gunship", 
				Class = "npc_combinegunship",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )


local NPC = { 	Name = "Stalker", 
				Class = "npc_stalker",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )


local NPC = { 	Name = "Claw scanner", 
				Class = "npc_clawscanner",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )


local NPC = { 	Name = "Sniper", 
				Class = "npc_sniper",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )

