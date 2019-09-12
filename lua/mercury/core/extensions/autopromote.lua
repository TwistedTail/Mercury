
print("AutoPromote loaded")

local RANKS = {
		[0] = "default", 
		[5] = "regular"
}

-- cant autopromote from bad ranks now can we
local function isBadRank(str)
	local bad = true
	if str=="default" then return false end
	for k,v in pairs(RANKS) do
		if v==str then return false end
	end
	return bad
end

--what is the rank the user should be promoted to
local function findPromoteRank(hours)
		local lastrank = "NONE"
		for k,v in SortedPairs(RANKS) do 
			if ((hours + 1) - k <= 0) then 
			  		return lastrank 
			end
			lastrank =v
		end
		return lastrank
end

--quality of live variable
FNDRNK = findPromoteRank


--lets do it
timer.Create("RANKTIME_AUTOPROMOTE", 8 , 0, function()
	for k, v in pairs(player.GetAll()) do

		local hours = math.floor((v:GetNWInt("ranktime") / 60 ) / 60 )

		local pr = findPromoteRank(hours)

		if v:GetRank()~=pr and pr~="NONE" then 

				if !isBadRank(v:GetRank()) then 

					print("Autopromote has been triggered, ranking")

					Mercury.Commands.Call(nil, "setrank", {v,pr}, true) 
					Mercury.Util.Broadcast({Color(50,255,50,255), "[Auto-Promote]", Mercury.Config.Colors.Default ," set the rank of ", Color(255,255,255) , v ,Mercury.Config.Colors.Default , " to ", Mercury.Config.Colors.Rank , pr ,Color(47,150,255,255) , "." } )

				end

			
		end
	end
	
end)