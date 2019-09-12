if SERVER then 
    util.AddNetworkString("Mercury::Vote") 
    local CurrentVote
    local Votes = {}
    local VoteCallback
	
    local function Mercury_Vote(ply,opt)
            if !CurrentVote then  // Check if a player is trying to vote when there's no vote.
                return false, "NO VOTE CURRENTLY RUNNING" // Return error stack
            end
            
            local AllOptions = CurrentVote.options  // Grab vote options
            local plyOption = AllOptions[opt] // Grab the text of the player's index.
            if !plyOption then return false,"VOTE OPTION INDEX DIDNT EXIST" end  // If the option is nil then stop
            
            Votes[ply:SteamID()] = opt // Store it under their steamid, so this way if they change their vote then it is uniquely keyd.
            if not CurrentVote.anonymous then  // Check if the vote is anonymous
                Mercury.Util.Broadcast({Mercury.Config.Colors.Server,ply,Mercury.Config.Colors.Default," has voted for ", Mercury.Config.Colors.Arg, plyOption})
            end             
            
            // send update to clients
            net.Start("Mercury::Vote") 
                net.WriteString("UPDATE_VOTES") 
                net.WriteTable(Votes)
            net.Send(player.GetAll())
    
    
    end


    local function Mercury_StopVote(hi)
        CurrentVote = nil // Delete vote table
        Votes = nil     // Delete vote table
        
        net.Start("Mercury::Vote") 
                net.WriteString("STOP_VOTE") 
                net.WriteString(hi)
        net.Send(player.GetAll())
    end    
    
    local function Mercury_OnVoteFinished()
    
        local vtable = {} // KV Swap table
        
        local options = CurrentVote.options //Grab the options
        
        for k,v in pairs(options) do 
            vtable[v] = 0  // Swap the value with the key, set to 0 
        end

        for k,v in pairs(Votes) do 
            local v = options[v] // convert key to value, actually turns the number into the actual text of the vote
            vtable[v] = vtable[v] + 1 // Increment vote based on player's numerical vote which has been turned into a string vote.
        end
        
        local highest = -1   // Set highest index to -1, has to be -1 in cast nobody votes so that way at least something got set to 0 and loaded into highest_index
        local highest_index = ""  // smae
        for k,v in pairs(vtable) do 
            if v > highest then // If the current number of votes is greater than the previous
                highest = v // Then this is our winning value, will loop through the whole table doing this
                highest_index = k // Store the winning text
            end
        end 
        local tied = {} // tie the knot daddy uwu
        for k,v in pairs(vtable) do  // Check for tied values
            if v==highest and k!=highest_index then  // If the number of votes is equal to the highest winning options
                tied[#tied + 1] = k // Then we tied, push into tied table.
            end
        end
        
        if #tied > 0 then // if we have multiple values.           
            local str = table.concat(tied,", ") .. " and " .. highest_index
            Mercury.Util.Broadcast({Mercury.Config.Colors.Default,"Vote over! The options ", Mercury.Config.Colors.Arg, str, Mercury.Config.Colors.Default, " have tied!"})
        else // We didn't and something had the majority votes.
            Mercury.Util.Broadcast({Mercury.Config.Colors.Default,"Vote over! The option ", Mercury.Config.Colors.Arg, highest_index , Mercury.Config.Colors.Default, " has won!"})
        end 
        
        if VoteCallback!=nil then  // If there's a callback
    	       pcall(VoteCallback,highest_index) // Call it
        end
    
        Mercury_StopVote(highest_index)
    end
	
    function Mercury.Commands.StartVote(text,time,anon, callback, ...)
        if CurrentVote then 
            return false, "A vote is already running."
        end
        local options = {...} 
        CurrentVote = {    // Setup vote table    
            prompt = text,
            duration = time, 
            options = options,        
            anonymous = anon,
        }
        Votes = {} // New votes storage table
        VoteCallback = callback // Store callback
        
        // Tell Clients its started.
        net.Start("Mercury::Vote")
            net.WriteString("START_VOTE")
            net.WriteTable(CurrentVote)
        net.Send(player.GetAll())
                
        timer.Destroy('Mercury_Vote')
        timer.Create("Mercury_Vote",time,1,Mercury_OnVoteFinished) // Timer!
    end
    
    
    local function Mercury_VoteNetHandler(len,ply)  // Handle starting vote. 
        local command = net.ReadString()
        print("GOT COMMAND " .. command)
        if command=="VOTE" then 
                   local opt = net.ReadInt(8) 
                   Mercury_Vote(ply,opt)
               
        end
    end    
    
    net.Receive("Mercury::Vote",Mercury_VoteNetHandler)
else 

    local votegui = false
    local VoteData
    local Votes
    local RawVotes
    local voted = false
    local winning = -5
    
    local function Mercury_VoteHandler()
        local command = net.ReadString()
        if command=="START_VOTE" then 
            votegui = true
            VoteData = net.ReadTable()
            Votes = {}
            RawVotes = {}
            voted = false
            winning = -5
            surface.PlaySound("mercury/mercury_error.ogg")
            timer.Create("MercuryVote",VoteData.duration,1,function() end)
        end 
        
        if command=="UPDATE_VOTES" then 
            local gv = net.ReadTable() 
            RawVotes = gv
            local opt = VoteData.options 
            Votes = {}
            for stm,vote in pairs(gv) do 
                local opt = opt[vote] 
                if opt==nil then continue end 
                if !Votes[opt] then 
                    Votes[opt] = 0
                end
                Votes[opt] = Votes[opt] + 1 
                PrintTable(Votes)
                surface.PlaySound("buttons/lightswitch2.wav")
            end
        end 
        if command=="STOP_VOTE" then 
            local vx = net.ReadString()
            for k,v in pairs(VoteData.options) do 
                if vx==v then 
                    winning = k 
                end
            end 
            timer.Simple(3, function()
                     votegui = false 
                     VoteData = nil
                     Votes = nil 
            end)
            surface.PlaySound("buttons/button4.wav")
        end 
    
    end
    net.Receive("Mercury::Vote",Mercury_VoteHandler)
    hook.Add("HUDPaint","MercuryVote",function()
        if votegui then 
            surface.SetDrawColor(255,255,255,150)
            surface.DrawRect( ScrW() * 0.005, (ScrH() * 0.37) , 256 , 265 )
            draw.DrawText(VoteData.prompt , "ChatFont",  ScrW() * 0.005, (ScrH() * 0.37) , Color( 1, 1, 1, 255 ), TEXT_ALIGN_LEFT)
            draw.DrawText(tostring(math.Round(timer.TimeLeft('MercuryVote') or 0)) , "ChatFont",  ScrW() * 0.005, (ScrH() * 0.37)  + 248, Color( 1, 1, 1, 255 ), TEXT_ALIGN_LEFT)
            
            for k,v in pairs(VoteData.options) do     
                local cnt = Votes[v] or 0
                local sz = table.Count(RawVotes)
                
                surface.SetDrawColor(150,150,150,150)
                
                
                surface.DrawRect( ScrW() * 0.005, (ScrH() * 0.39) + k*20, 256 * (cnt / sz) , 20)
            
            
                surface.SetDrawColor(1,1,1,150)
                
                
                surface.DrawOutlinedRect( ScrW() * 0.005, (ScrH() * 0.39) + k*20, 256, 20)
            
                local col = Color( 1, 1, 1, 255 )
                if winning==k then 
                    col = Color( 1, 255, 1, 255 )
                end
                
                draw.DrawText( k.. ". " .. v, "ChatFont", ScrW() * 0.005 , (ScrH() * 0.39) + k*20, col , TEXT_ALIGN_LEFT)
                
            end
        end
    end)
    local BindMap = {
        ["slot1"]= 1,
        ["slot2"] = 2,
        ["slot3"] = 3,
        ["slot4"] = 4,
        ["slot5"] = 5,
        ["slot6"] = 6,
        ["slot7"] = 7,
        ["slot8"] = 8,
        ["slot9"] = 9,
    
    }
    
    
    hook.Add("PlayerBindPress","MercuryVote",function(ply,bind)
        if votegui then 
            if not voted then 
                if BindMap[bind] then 
                    net.Start("Mercury::Vote")
                        net.WriteString("VOTE")
                        net.WriteInt(BindMap[bind],8)
                    net.SendToServer()
                    voted = true
                    return true
                end
            end 
        end   
    end)
    
end 


MCMD = {
	["Command"] = "vote",
	["Verb"] = "voted",
	["RconUse"] = true,
	["Useage"] = "'vote text' 'time' < 'o' 'p' 't' 'i' 'o' 'n' 's' > ",
	["UseImmunity"] =  false,
	["HasMenu"] = false,
	["Category"] = "Voting",
	["AllowWildcard"] = false
}

function callfunc(caller,args) 
    if !args[1] then 
        return false, "@SYNTAX_ERR"
    end 
    if !args[2] then 
        return false,"@SYNTAX_ERR"
    end
    if !args[3] then 
        return false,"@SYNTAX_ERR"
    end
    
    local txt = table.remove(args,1)
    local tim = table.remove(args,1) or 30 
    if tim==nil then tim=30 end 
    local sts, err = Mercury.Commands.StartVote(txt,tonumber(tim), false,nil,  unpack(args))
    if !sts then 
        return false,err
    end
    return true, "", false, {}
end
Mercury.Commands.AddCommand(MCMD.Command,MCMD,callfunc)
