hook.Add("Think","TimeEffDist",
function()

local TimeGrenEnts = {}
local TimeGrenNum = 0

     for k, v in pairs( ents.GetAll() ) do

		 if v:GetClass() == "sent_timegrenade" then
			TimeGrenNum = TimeGrenNum + 1
			TimeGrenEnts[TimeGrenNum] = v 	
		end	 
	 
	 
     end 



				for k, v in pairs(player.GetAll()) do
					local MaxDist = 999999999

					
					 if TimeGrenNum > 0 then
						for i=1,TimeGrenNum do 
							local Dist = v:GetPos():Distance( TimeGrenEnts[i]:GetPos() )

								if MaxDist > Dist then
									MaxDist = Dist
								end
								
						
						end

						if MaxDist < 800 then
							v:SetNetworkedFloat("TimeDist", MaxDist) 
							v:SetNetworkedBool("TimeEffected", true)
						
						end
						
						if MaxDist > 800 then
							v:SetNetworkedBool("TimeEffected", false)
						end
					end

						if TimeGrenNum == 0 then
							v:SetNetworkedBool("TimeEffected", false)
						end
				end

	
end)