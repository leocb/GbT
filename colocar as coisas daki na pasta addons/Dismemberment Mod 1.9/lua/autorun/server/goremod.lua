include("autorun/goremod_entity.lua")

BoneInfo = {}

local function PrecacheBoneInfo()

	local file_path = "goremod/bone_data/"
	
	local bone_files = file.Find(file_path.."*")
		
	for file_index,bone_file in pairs(bone_files) do
				
		local text = file.Read(file_path..bone_file)
		
		bone_file = bone_file:sub(0,bone_file:len()-4)
		
		BoneInfo[bone_file] = {}
		
		for line_index,line_text in pairs(string.Explode("\n",text)) do
			
			local bones = string.Explode("=",line_text)
			
			local bone1 = tonumber(bones[1])
			
			local bone2 = tonumber(bones[2])
			
			if (bone1 && bone2) then
									
				BoneInfo[bone_file][bone1] = bone2
			end
		end
	end
	
	PrintTable(BoneInfo)
end

PrecacheBoneInfo()

BodyFuncs = {}

local function PrecacheBodyFuncs()

	local file_path = "bodies/*"
	
	local body_folders = file.FindInLua(file_path)
			
	for folder_index,folder_name in pairs(body_folders) do
		
		if (folder_name != "") then
		
			BODY = {}
			
			include("bodies/"..folder_name.."/init.lua")
			
			BodyFuncs[folder_name] = BODY
			
			BODY = nil	
		end			
	end
	
	BODY = {}
	
	include("bodies/base/init.lua")
	
	BodyFuncs["base"] = BODY
	
	BODY = nil
end

PrecacheBodyFuncs()

ModelType = {}

local function PrecacheModelTypes()

	local file_path = "goremod/body_types/"
	
	local model_folders = file.Find(file_path.."*")
	
	for folder_index,model_folder in pairs(model_folders) do
	
		ModelType[model_folder] = {}
	
		local model_files = file.Find(file_path..model_folder.."/*")
					
		for model_index,model_file in pairs(model_files) do
		
			local text = file.Read(file_path..model_folder.."/"..model_file)
			
			local models = string.Explode("\n",text)
			
			for name_index,model_name in pairs(models) do
			
				table.insert(ModelType[model_folder],model_name)
			end
		end
	end
end

PrecacheModelTypes()

function GoreModEntityTakeDamage(ent,inf,attacker,amount,dmginfo)

	local body_type = ent:GetBT()
	
	if (body_type == "") then
	
		return
	end
		
	local FuncTable = BodyFuncs[body_type]
	
	BodyFuncs["base"].TakeDamage(ent,inf,attacker,dmginfo)
	
	if (!FuncTable) then
	
		return
	end
	
	FuncTable.TakeDamage(ent,inf,attacket,dmginfo)
end

function GoreModThink()

	for ent_index,ent in pairs(ents.FindByClass("prop_ragdoll")) do
			
		local body_type = ent:GetBT()
		
		if (body_type == "") then
		
			return
		end
						
		local FuncTable = BodyFuncs[body_type]
			
		BodyFuncs["base"].Think(ent)
		
		if (!FuncTable) then
		
			return
		end
		
		FuncTable.Think(ent)
	end
end

local LastDamageInfo = {}

function GoreModScaleNPCDamage(npc,hitgroup,dmginfo)

	if (npc:Health() - dmginfo:GetDamage() <= 0) then
	
		LastDamageInfo[npc:EntIndex()] = dmginfo
	end
end

function GoreModCreateEntityRagdoll(npc,ragdoll)

	local model = ragdoll:GetModel()
	
	model = model:lower()
	
	local body_type = ""
		
	for model_type,model_table in pairs(ModelType) do
		
		for model_index,model_name in pairs(model_table) do
				
			if (model:find(model_name)) then
				
				ragdoll:SetBT(model_type)
				body_type = model_type
				break
			end
		end
	end
		
	if (body_type == "") then
	
		return
	end
	
	local FuncTable = BodyFuncs[body_type]
	
	BodyFuncs["base"].Init(ragdoll,npc)
	
	if (!FuncTable) then
	
		return
	end
	
	FuncTable.Init(ragdoll,npc)
	
	local dmginfo = LastDamageInfo[npc:EntIndex()]
	
	if (!dmginfo) then
	
		return
	end
	
	npc:Remove()
	
	FuncTable.TakeDamage(ragdoll,dmginfo:GetInflictor(),dmginfo:GetAttacker(),dmginfo)
end
	
function GoreModInitialize()

	timer.Simple(1,function() for ragdoll_index,ragdoll in pairs(ents.FindByClass("prop_ragdoll")) do
	
			local model = ragdoll:GetModel()
			
			for model_type,model_table in pairs(ModelType) do
			
				if (table.HasValue(model_table,model)) then
				
					ragdoll:SetBT(model_type)
					BodyFuncs[model_type].Init(ragdoll,ragdoll)
				end
			end
		end
	end)
end

local function StartGoreMod()

	for key,value in pairs(_G) do
	
		if (key:sub(0,7) == "GoreMod") then
		
			hook.Add(key:sub(8,key:len()),"GoreMod",value)
		end
	end
end

StartGoreMod()

local function GoreModToggle(ply,cmd,args)

	if (!ply:IsAdmin() && !ply:IsSuperAdmin()) then
	
		return
	end
	
	local num = tonumber(args[1])
		
	if (num == 0) then
	
		for key,value in pairs(_G) do
		
			if (key:sub(0,7) == "GoreMod") then
			
				hook.Remove(key:sub(8,key:len()),"GoreMod")
			end
		end
		
		return
	elseif (num == 1) then
	
		for key,value in pairs(_G) do
		
			if (key:sub(0,7) == "GoreMod") then
											
				hook.Add(key:sub(8,key:len()),"GoreMod",value)
			end
		end
		return
	end
end

concommand.Add("goremod_enabled",GoreModToggle)