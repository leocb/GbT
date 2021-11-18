------------------------------------
--	Simple Prop Protection
--	By Spacetech
------------------------------------
Coding = false
if(SinglePlayer() and Coding == false) then
	Msg("==================================================\n")
	Msg("Simple Prop Protection by Spacetech has NOT loaded\n")
	Msg("			  You are in single player			   \n")
	Msg("==================================================\n")
	return
end
AddCSLuaFile("autorun/client/cl_SPropProtection.lua")

local SPropProtection = {}
SPropProtection["Props"] = {}

function SPropProtection.LoadSettings()
	if(!file.Exists("SPP/Config.txt")) then return false end
	local File = file.Read("SPP/Config.txt")
	SPropProtection["Config"] = util.KeyValuesToTable(File)
	return true
end

function SPropProtection.MakeSettings()
	if(file.Exists("SPP/Config.txt")) then return end
	SPropProtection["Config"] = {}
	SPropProtection["Config"]["toggle"] = 1
	SPropProtection["Config"]["admin"] = 1
	SPropProtection["Config"]["use"] = 1
	SPropProtection["Config"]["edmg"] = 1
	SPropProtection["Config"]["pgr"] = 1
	SPropProtection["Config"]["awp"] = 1
	SPropProtection["Config"]["dpd"] = 1
	SPropProtection["Config"]["dae"] = 0
	SPropProtection["Config"]["delay"] = 120
	file.Write("SPP/Config.txt", util.TableToKeyValues(SPropProtection["Config"]))
end

if(!SPropProtection.LoadSettings()) then
	SPropProtection.MakeSettings()
end

function SPropProtection.NofityAll(Text)
	for k, ply in pairs(player.GetAll()) do
		ply:SendLua("GAMEMODE:AddNotify(\""..Text.."\", NOTIFY_GENERIC, 5); surface.PlaySound(\"ambient/water/drip"..math.random(1, 4)..".wav\")")
		ply:PrintMessage(HUD_PRINTCONSOLE, Text)
	end
	Msg(Text.."\n")
end

function SPropProtection.Nofity(ply, Text)
	ply:SendLua("GAMEMODE:AddNotify(\""..Text.."\", NOTIFY_GENERIC, 5); surface.PlaySound(\"ambient/water/drip"..math.random(1, 4)..".wav\")")
	ply:PrintMessage(HUD_PRINTCONSOLE, Text)
end
	
function SPropProtection.AdminReload(ply)
	if(ply) then
		if(ply:IsValid() and ply:IsAdmin()) then
			for k, v in pairs(SPropProtection["Config"]) do
				ply:ConCommand("SPropProtection_"..k.." "..v.."\n")
			end		
		end
	else
		for k1, v1 in pairs(player.GetAll()) do
			if(v1:IsValid() and v1:IsAdmin()) then
				for k2, v2 in pairs(SPropProtection["Config"]) do
					v1:ConCommand("SPropProtection_"..k2.." "..v2.."\n")
				end
			end
		end
	end
end
	
function SPropProtection.LoadBuddies(ply)
	local SaveSteamID = string.Replace(ply:SteamID(), ":", ".")
	if(file.Exists("SPP/"..SaveSteamID..".txt")) then
		SPropProtection[ply:SteamID()] = util.KeyValuesToTable(file.Read("SPP/"..SaveSteamID..".txt"))
	end
end

function SPropProtection.PlayerMakePropOwner(ply, ent)
	if(ent:GetClass() == "transformer" and ent.spawned and !ent.Part) then
		for k, v in pairs(transpiece[ent]) do
			v.Part = true
			SPropProtection.PlayerMakePropOwner(ply, v)
		end
	end
	if(ent:IsPlayer()) then return end
	SPropProtection["Props"][ent:EntIndex()] = {ply:UniqueID(), ent}
	ent:SetNetworkedString("Owner", ply:Nick())
end

if(cleanup) then
	local Clean = cleanup.Add
	function cleanup.Add(Player, Type, Entity)
		if(Entity) then
			local Check = Player:IsPlayer()
			local Valid = Entity:IsValid()
		    if(Check and Valid) then
		        SPropProtection.PlayerMakePropOwner(Player, Entity)
		    end
		end
	    Clean(Player, Type, Entity)
	end
end

local Meta = FindMetaTable("Player")
if(Meta.AddCount) then
	local Backup = Meta.AddCount
	function Player:AddCount(Type, Entity)
		SPropProtection.PlayerMakePropOwner(self, Entity)
		Backup(self, Type, Entity)
	end
end

function SPropProtection.IsBuddy(ply, ent)
	local Players = player.GetAll()
	if(table.Count(Players) == 1) then return true end
	for k,v in pairs(Players) do
		if(v:IsValid() and v != ply) then
	        if(SPropProtection["Props"][ent:EntIndex()][1] == v:UniqueID()) then 
                if(table.HasValue(SPropProtection[v:SteamID()], ply:SteamID())) then
					return true
				else
					return false
				end
            end
		end
	end	
end

function SPropProtection.PlayerCanTouch(ply, ent)
	if(tonumber(SPropProtection["Config"]["toggle"]) == 0 || ent:GetClass() == "worldspawn") then
		return true
	end
	
	if(string.find(ent:GetClass(), "stone_") == 1 || string.find(ent:GetClass(), "rock_") == 1 || string.find(ent:GetClass(), "stargate_") == 0 || string.find(ent:GetClass(), "dhd_") == 0 || ent:GetClass() == "flag" || ent:GetClass() == "item") then
		if(!ent:GetNetworkedString("Owner") || ent:GetNetworkedString("Owner") == "") then
			ent:SetNetworkedString("Owner", "World")
		end
		if(ply:GetActiveWeapon():GetClass() != "weapon_physgun" and ply:GetActiveWeapon():GetClass() != "gmod_tool") then
			return true
		elseif(!ply:IsAdmin()) then
			--gasp
		end
	end
	
	if(!ent:GetNetworkedString("Owner") || ent:GetNetworkedString("Owner") == "" and !ent:IsPlayer()) then
		SPropProtection.PlayerMakePropOwner(ply, ent)
		SPropProtection.Nofity(ply, "You now own this prop")
		return true
	end
	
	if(ent:GetNetworkedString("Owner") == "World") then
		if(ply:IsAdmin() and tonumber(SPropProtection["Config"]["awp"]) == 1 and tonumber(SPropProtection["Config"]["admin"]) == 1) then
			return true
		end
	elseif(ply:IsAdmin() and tonumber(SPropProtection["Config"]["admin"]) == 1) then
		return true
	end

	if(SPropProtection["Props"][ent:EntIndex()] != nil) then
		if(SPropProtection["Props"][ent:EntIndex()][1] == ply:UniqueID() || SPropProtection.IsBuddy(ply, ent)) then
			return true
		end
	else
		for k, v in pairs(g_SBoxObjects) do
			for b, j in pairs(v) do
				for _, e in pairs(j) do
					if(k == ply:UniqueID() and e == ent) then
						SPropProtection.PlayerMakePropOwner(ply, ent)
						SPropProtection.Nofity(ply, "You now own this prop")
						return true
					end
				end
			end
		end
		
		for k, v in pairs(GAMEMODE.CameraList) do
			for b, j in pairs(v) do
				if(j == ent) then
					if(k == ply:UniqueID() and e == ent) then
						SPropProtection.PlayerMakePropOwner(ply, ent)
						SPropProtection.Nofity(ply, "You now own this prop")
						return true
					end
				end
			end
		end
	end
	
	--SPropProtection.Nofity(ply, "This is not your prop")
	if(game.GetMap() == "gm_construct" and ent:GetNetworkedString("Owner") == "World") then
		return true
	end
	return false
end

function SPropProtection.DRemove(UniqueID, PlayerName)
	for k, v in pairs(SPropProtection["Props"]) do
		if(v[1] == UniqueID and v[2]:IsValid()) then
			v[2]:Remove()
			SPropProtection["Props"][k] = nil
		end
	end
	SPropProtection.NofityAll(tostring(PlayerName).."'s props have been cleaned up")
end

function SPropProtection.PlayerInitialSpawn(ply)
	SPropProtection[ply:SteamID()] = {}
	SPropProtection.LoadBuddies(ply)
	SPropProtection.AdminReload(ply)
	local TimerName = "SPropProtection.DRemove: "..ply:UniqueID()
	if(timer.IsTimer(TimerName)) then
		timer.Remove(TimerName)
	end
end
hook.Add("PlayerInitialSpawn", "SPropProtection.PlayerInitialSpawn", SPropProtection.PlayerInitialSpawn)

function SPropProtection.Disconnect(ply)
	if(tonumber(SPropProtection["Config"]["dpd"]) == 1) then
		if(ply:IsAdmin() and tonumber(SPropProtection["Config"]["dae"]) == 0) then return end
		timer.Create("SPropProtection.DRemove: "..ply:UniqueID(), tonumber(SPropProtection["Config"]["delay"]), 1, SPropProtection.DRemove, ply:UniqueID(), ply:Nick())
	end
end
hook.Add("PlayerDisconnected", "SPropProtection.Disconnect", SPropProtection.Disconnect)

function SPropProtection.PhysGravGunPickup(ply, ent)
	if(!ent:IsValid()) then return end
	if(ent:IsPlayer() and ply:IsAdmin() and tonumber(SPropProtection["Config"]["admin"]) == 1) then return end
	if(!ent:IsValid() || !SPropProtection.PlayerCanTouch(ply, ent)) then
		return false
	end
end
hook.Add("GravGunPunt", "SPropProtection.GravGunPunt", SPropProtection.PhysGravGunPickup)
hook.Add("GravGunPickupAllowed", "SPropProtection.GravGunPickupAllowed", SPropProtection.PhysGravGunPickup)
hook.Add("PhysgunPickup", "SPropProtection.PhysgunPickup", SPropProtection.PhysGravGunPickup)

function SPropProtection.CanTool(ply, tr, toolgun)
	if(tr.HitWorld) then return end
	ent = tr.Entity
	if(!ent:IsValid() || ent:IsPlayer()) then return false end
	if(!SPropProtection.PlayerCanTouch(ply, ent)) then
		return false
	elseif(toolgun == "nail") then
		local Trace = {}
		Trace.start = tr.HitPos
		Trace.endpos = tr.HitPos + (ply:GetAimVector() * 16.0)
		Trace.filter = {ply, tr.Entity}
		local tr2 = util.TraceLine(Trace)
		if(tr2.Hit and !tr2.Entity:IsPlayer()) then
			if(!SPropProtection.PlayerCanTouch(ply, tr2.Entity)) then
				return false
			end
		end
	end
end
hook.Add("CanTool", "SPropProtection.CanTool", SPropProtection.CanTool)

function SPropProtection.EntityTakeDamage(ent, inflictor, attacker, amount)
	if(tonumber(SPropProtection["Config"]["edmg"]) == 0) then return end
	if(!ent:IsValid()) then return end
    if(ent:IsPlayer() || !attacker:IsPlayer()) then return end
	if(!SPropProtection.PlayerCanTouch(attacker, ent)) then
		local Total = ent:Health() + amount
		if(ent:GetMaxHealth() > Total) then 
			ent:SetMaxHealth(Total)
		else
			ent:SetHealth(Total)
		end
	end
end
hook.Add("EntityTakeDamage", "SPropProtection.EntityTakeDamage", SPropProtection.EntityTakeDamage)

function SPropProtection.PlayerUse(ply, ent)
	if(ent:IsValid() and tonumber(SPropProtection["Config"]["use"]) == 1) then
		if(!SPropProtection.PlayerCanTouch(ply, ent) and ent:GetNetworkedString("Owner") != "World") then
			return false
		end
	end
end
hook.Add("PlayerUse", "SPropProtection.PlayerUse", SPropProtection.PlayerUse)

function SPropProtection.OnPhysgunReload(weapon, ply)
	if(tonumber(SPropProtection["Config"]["pgr"]) == 0) then return end
	local tr = util.TraceLine(util.GetPlayerTrace(ply))
	if(!tr.HitNonWorld || !tr.Entity:IsValid() || tr.Entity:IsPlayer()) then return end
	if(!SPropProtection.PlayerCanTouch(ply, tr.Entity)) then
		return false
	end
end
hook.Add("OnPhysgunReload", "SPropProtection.OnPhysgunReload", SPropProtection.OnPhysgunReload)

function SPropProtection.EntityRemoved(ent)
	SPropProtection["Props"][ent:EntIndex()] = nil
end
hook.Add("EntityRemoved", "SPropProtection.EntityRemoved", SPropProtection.EntityRemoved)

function SPropProtection.PlayerSpawnedSENT(ply, ent)
	SPropProtection.PlayerMakePropOwner(ply, ent)
end
hook.Add("PlayerSpawnedSENT", "SPropProtection.PlayerSpawnedSENT", SPropProtection.PlayerSpawnedSENT)

function SPropProtection.PlayerSpawnedVehicle(ply, ent)
	SPropProtection.PlayerMakePropOwner(ply, ent)
end
hook.Add("PlayerSpawnedVehicle", "SPropProtection.PlayerSpawnedVehicle", SPropProtection.PlayerSpawnedVehicle)
  
  
function SPropProtection.CleanupOwnerlessProps(ply, cmd, args)
	if(!ply:IsAdmin()) then return end
	for k, v in pairs(ents.FindByClass("*")) do
		if((!v:GetNetworkedString("Owner") || v:GetNetworkedString("Owner") == "") and v:GetClass() != "worldspawn" and v:IsValid()) then
			v:Remove()
		end
	end
	SPropProtection.NofityAll("Ownerless props have been cleaned up")
end
--concommand.Add("SPropProtection_CleanupOwnerlessProps", SPropProtection.CleanupOwnerlessProps)

function SPropProtection.CleanupDisconnectedProps(ply, cmd, args)
	if(!ply:IsAdmin()) then return end
	for k1, v1 in pairs(SPropProtection["Props"]) do
		local FoundUID = false
		for k2, v2 in pairs(player.GetAll()) do
			if(v1[1] == v2:UniqueID()) then
				FoundUID = true
			end
		end
		if(FoundUID == false and v1[2]:IsValid()) then
			v1[2]:Remove()
			SPropProtection["Props"][k1] = nil
		end
	end
	SPropProtection.NofityAll("Disconnected players props have been cleaned up")
end
concommand.Add("SPropProtection_CleanupDisconnectedProps", SPropProtection.CleanupDisconnectedProps)

function SPropProtection.CleanupProps(ply, cmd, args)
	if(!args[1] || args[1] == "") then
		for k, v in pairs(SPropProtection["Props"]) do
			if(v[1] == ply:UniqueID()) then
				if(v[2]:IsValid()) then
					v[2]:Remove()
					SPropProtection["Props"][k] = nil
				end
			end
		end	
		SPropProtection.Nofity(ply, "Your props have been cleaned up")
	elseif(ply:IsAdmin()) then
		local FoundPlayer = false
		for k1, v1 in pairs(player.GetAll()) do
			local NewNick = string.Replace(v1:Nick(), " ", "_")
			if(args[1] == NewNick) then
				for k2, v2 in pairs(SPropProtection["Props"]) do
					if(v2[1] == v1:UniqueID()) then
						if(v2[2]:IsValid()) then
							v2[2]:Remove()
							SPropProtection["Props"][k2] = nil
						end
					end
				end
				SPropProtection.NofityAll(v1:Nick().."'s props have been cleaned up")
			end
		end
	end
end
concommand.Add("SPropProtection_CleanupProps", SPropProtection.CleanupProps)

function SPropProtection.ApplyBuddySettings(ply, cmd, args)
	local Players = player.GetAll()
	if(table.Count(Players) > 1) then
		for k, v in pairs(Players) do
			local NewNick = string.Replace(v:Nick(), " ", "_")
			local PlayersSteamID = v:SteamID()
			if(tonumber(ply:GetInfo("SPropProtection_BuddyUp_"..NewNick)) == 1) then
				if(!table.HasValue(SPropProtection[ply:SteamID()], PlayersSteamID)) then
					table.insert(SPropProtection[ply:SteamID()], PlayersSteamID)
				end
			else
				if(table.HasValue(SPropProtection[ply:SteamID()], PlayersSteamID)) then
					for k2, v2 in pairs(SPropProtection[ply:SteamID()]) do
						if(v2 == PlayersSteamID) then
							table.remove(SPropProtection[ply:SteamID()], k2)
						end
					end
				end
			end
		end
		local SaveSteamID = string.Replace(ply:SteamID(), ":", ".")
		if(table.Count(SPropProtection[ply:SteamID()]) > 0) then
			file.Write("SPP/"..SaveSteamID..".txt", util.TableToKeyValues(SPropProtection[ply:SteamID()]))
		elseif(file.Exists("SPP/"..SaveSteamID..".txt")) then
			file.Delete("SPP/"..SaveSteamID..".txt")
		end
	end
	SPropProtection.Nofity(ply, "Your buddies have been updated")
end
concommand.Add("SPropProtection_ApplyBuddySettings", SPropProtection.ApplyBuddySettings)

function SPropProtection.ClearBuddies(ply, cmd, args)
	SPropProtection[ply:SteamID()] = {}
	file.Delete("SPP/"..string.Replace(ply:SteamID(), ":", ".")..".txt")
	local Players = player.GetAll()
	if(table.Count(Players) > 1) then
		for k, v in pairs(Players) do
			local NewNick = string.Replace(v:Nick(), " ", "_")
			ply:ConCommand("SPropProtection_BuddyUp_"..NewNick.." 0\n")
		end
	end
	SPropProtection.Nofity(ply, "Your buddies have been cleared")
end
concommand.Add("SPropProtection_ClearBuddies", SPropProtection.ClearBuddies)

function SPropProtection.ApplySettings(ply, cmd, args)
	if(!ply:IsAdmin()) then return end
	SPropProtection["Config"]["toggle"] = tonumber(ply:GetInfo("SPropProtection_toggle") || 1)
	SPropProtection["Config"]["admin"] = tonumber(ply:GetInfo("SPropProtection_admin") || 1)
	SPropProtection["Config"]["use"] = tonumber(ply:GetInfo("SPropProtection_use") || 1)
	SPropProtection["Config"]["edmg"] = tonumber(ply:GetInfo("SPropProtection_edmg") || 1)
	SPropProtection["Config"]["pgr"] = tonumber(ply:GetInfo("SPropProtection_pgr") || 1)
	SPropProtection["Config"]["awp"] = tonumber(ply:GetInfo("SPropProtection_awp") || 1)
	SPropProtection["Config"]["dpd"] = tonumber(ply:GetInfo("SPropProtection_dpd") || 1)
	SPropProtection["Config"]["dae"] = tonumber(ply:GetInfo("SPropProtection_dae") || 1)
	SPropProtection["Config"]["delay"] = tonumber(ply:GetInfo("SPropProtection_delay") || 120)
	file.Write("SPP/Config.txt", util.TableToKeyValues(SPropProtection["Config"]))
	timer.Simple(2, SPropProtection.AdminReload())
	SPropProtection.Nofity(ply, "Admin settings have been updated")
end
concommand.Add("SPropProtection_ApplyAdminSettings", SPropProtection.ApplySettings)

function PlayerCanUseConCommand(ply)
	if(ply and !ply:IsValid()) then
		return true
	elseif(ply:IsAdmin()) then
		return true
	else
		return false
	end
end
	
function SPropProtection.ReloadSettings(ply, cmd, args)
	local Check = false
	if(ply and !ply:IsValid()) then
		Check = true
	elseif(ply:IsAdmin()) then
		Check = true
	end
	if(Check == false) then return end
	
	local Text = ""
	if(SPropProtection.LoadSettings()) then
		Text = "Admin settings has been reloaded"
	else
		Text = "Admin settings has not been found...created one..."
		SPropProtection.MakeSettings()
	end	
	SPropProtection.AdminReload()	
	if(ply:IsValid()) then
		SPropProtection.Nofity(ply, Text)
	else
		Msg(Text.."\n")
	end
end
concommand.Add("SPropProtection_ReloadSettings", SPropProtection.ReloadSettings)

function SPropProtection.WorldOwner()
	local WorldEnts = 0
	for k, v in pairs(ents.FindByClass("*")) do
		v:SetNetworkedString("Owner", "World")
		WorldEnts = WorldEnts + 1
	end
	Msg("================================================\n")
	Msg("Simple Prop Protection: "..tostring(WorldEnts).." props belong to world\n")
	Msg("================================================\n")
end
timer.Simple(10, SPropProtection.WorldOwner)

Msg("==============================================\n")
Msg("Simple Prop Protection by Spacetech has loaded\n")
Msg("==============================================\n")