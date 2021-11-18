function SetSpawnpoint(ply, command, args)
ply.SpawnPoint = ply:GetPos()
ply:ChatPrint("Spawnpoint set.")
end

local function PlayerSpawn(ply)
if ply.SpawnPoint then ply:SetPos(ply.SpawnPoint + Vector(0,0,16)) end
end

concommand.Add("setspawnpoint", SetSpawnpoint)

hook.Add("PlayerSpawn", "PlayerSpawn", PlayerSpawn) 