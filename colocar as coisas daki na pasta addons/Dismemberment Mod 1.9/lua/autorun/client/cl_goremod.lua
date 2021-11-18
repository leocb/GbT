local function BoneRemoving(self,numbones,numphysbones)
	
	for i=0,128 do
	
		local should_remove = self:GetNWBool("Decapped"..i,false)
				
		if (should_remove) then
			
			local bone_matrix = self:GetBoneMatrix(i)
				bone_matrix:Scale(Vector(0,0,0))
			self:SetBoneMatrix(i,bone_matrix)
		end
	end
end

local function AddBoneRemoveFunc(um)
	
	local ent = um:ReadEntity()
	
	ent.BuildBonePositions = BoneRemoving
end

usermessage.Hook("GoreMod_AddFunc",AddBoneRemoveFunc)